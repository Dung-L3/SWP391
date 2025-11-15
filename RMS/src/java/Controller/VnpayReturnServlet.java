package Controller;

import Dal.BillDAO;
import Dal.BillDAO.BillSummary;
import Dal.OrderDAO;
import Dal.PaymentDAO;
import Dal.PaymentDAO.PaymentInfo;
import Dal.VoucherDAO;
import Utils.VnpayService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * VnpayReturnServlet
 *
 * Xử lý callback từ VNPay sau khi khách thanh toán.
 * - Xác thực chữ ký.
 * - Kiểm tra số tiền.
 * - Cập nhật trạng thái payment + bill.
 * - Ghi nhận sử dụng voucher (nếu có).
 * - Forward sang PaymentSuccess.jsp để hiển thị kết quả đẹp cho thu ngân.
 */
@WebServlet(urlPatterns = {"/VnpayReturnServlet"})
public class VnpayReturnServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final BillDAO billDAO = new BillDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1. Lấy toàn bộ query param gửi về
        Map<String, String> vnpParams = new HashMap<>();
        req.getParameterMap().forEach((key, vals) -> {
            if (vals != null && vals.length > 0) {
                vnpParams.put(key, vals[0]);
            }
        });

        String vnpTxnRef        = vnpParams.get("vnp_TxnRef");          // paymentId
        String vnpResponseCode  = vnpParams.get("vnp_ResponseCode");    // "00" -> success
        String vnpTransactionNo = vnpParams.get("vnp_TransactionNo");   // mã GD của VNPay
        String vnpSecureHash    = vnpParams.get("vnp_SecureHash");

        if (vnpTxnRef == null || vnpTxnRef.isBlank()) {
            forwardFail(req, resp, "Thiếu vnp_TxnRef (paymentId).");
            return;
        }

        Long paymentId;
        try {
            paymentId = Long.valueOf(vnpTxnRef.trim());
        } catch (NumberFormatException nfe) {
            forwardFail(req, resp, "vnp_TxnRef không hợp lệ.");
            return;
        }

        // 2. Xác thực chữ ký
        boolean isValidSignature = VnpayService.verifyReturn(vnpParams, vnpSecureHash);
        if (!isValidSignature) {
            forwardFail(req, resp, "Kết quả thanh toán không hợp lệ hoặc đã bị chỉnh sửa trên URL.");
            return;
        }

        // 3. Đọc payment từ DB
        PaymentInfo pInfo;
        try {
            pInfo = paymentDAO.getPaymentInfo(paymentId);
        } catch (SQLException e) {
            e.printStackTrace();
            forwardFail(req, resp, "Lỗi CSDL khi đọc thông tin giao dịch.");
            return;
        }
        if (pInfo == null) {
            forwardFail(req, resp, "Không tìm thấy giao dịch #" + paymentId + ".");
            return;
        }

        Long billId  = pInfo.billId;
        Long orderId = pInfo.orderId;

        // 4. Lấy bill liên quan
        BillSummary billSummary;
        try {
            billSummary = billDAO.getBillSummary(billId);
        } catch (SQLException e) {
            e.printStackTrace();
            forwardFail(req, resp, "Lỗi CSDL khi đọc thông tin hóa đơn.");
            return;
        }
        if (billSummary == null) {
            forwardFail(req, resp, "Không tìm thấy hóa đơn liên quan.");
            return;
        }

        // 5. Kiểm tra số tiền VNPay trả về so với DB
        try {
            long amountFromVnp = Long.parseLong(vnpParams.getOrDefault("vnp_Amount", "0"));
            long expected = (pInfo.amount != null ? pInfo.amount : BigDecimal.ZERO)
                    .multiply(new BigDecimal("100")).longValue(); // VNPay *100

            if (amountFromVnp != expected) {
                forwardFail(req, resp, "Số tiền VNPay trả về không khớp với giao dịch trong hệ thống.");
                return;
            }
        } catch (NumberFormatException nf) {
            forwardFail(req, resp, "Giá trị vnp_Amount không hợp lệ.");
            return;
        }

        // 6. Kiểm tra mã phản hồi
        boolean paymentSuccess = "00".equals(vnpResponseCode);
        if (!paymentSuccess) {
            // Thanh toán không thành công
            req.setAttribute("uiStatus", "FAIL");
            req.setAttribute("billNo",
                    billSummary.billNo != null ? billSummary.billNo : String.valueOf(billSummary.billId));
            req.setAttribute("paidAmount", "0");
            req.setAttribute("method", "VNPAY");
            req.setAttribute("reasonText",
                    "Thanh toán VNPay không thành công (code=" + vnpResponseCode + ").");
            req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);
            return;
        }

        // 7. Thanh toán thành công -> cập nhật DB
        try {
            // Cập nhật payment
            paymentDAO.markPaymentSuccess(paymentId,
                    vnpTransactionNo != null ? vnpTransactionNo : "");

            // Đổi bill sang FINAL nếu chưa
            billDAO.markBillPaid(billId);

            // Ghi nhận dùng voucher (nếu có)
            if (billSummary.voucherId != null && billSummary.voucherId > 0) {
                BigDecimal discountUsed =
                        billSummary.discountAmount != null ? billSummary.discountAmount : BigDecimal.ZERO;
                voucherDAO.recordRedemption(billSummary.voucherId, null, billId, discountUsed);
            }

            // Đóng order nếu bill gắn với 1 order
            if (orderId != null) {
                orderDAO.closeOrder(orderId);
            }

            // 8. Forward ra màn hình kết quả + TRUYỀN BILL_ID để in hóa đơn
            req.setAttribute("uiStatus", "OK");
            req.setAttribute("billId", billId);  // <<< QUAN TRỌNG: cho nút In hóa đơn
            req.setAttribute("billNo",
                    billSummary.billNo != null ? billSummary.billNo : String.valueOf(billSummary.billId));
            req.setAttribute("paidAmount", billSummary.totalAmount);   // BigDecimal -> JSP toString()
            req.setAttribute("method", "VNPAY");
            req.setAttribute("reasonText",
                    "Thanh toán VNPay thành công"
                            + (vnpTransactionNo != null && !vnpTransactionNo.isBlank()
                            ? " (mã GD #" + vnpTransactionNo + ")." : "."));
            req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);

        } catch (SQLException dbEx) {
            dbEx.printStackTrace();
            forwardFail(req, resp, "Lỗi CSDL khi finalize hóa đơn sau VNPay.");
        } catch (Exception ex) {
            ex.printStackTrace();
            forwardFail(req, resp, "Lỗi không xác định khi finalize hóa đơn sau VNPay.");
        }
    }

    // Forward lỗi dạng đẹp sang PaymentSuccess.jsp, KHÔNG truyền billId
    private void forwardFail(HttpServletRequest req, HttpServletResponse resp, String reason)
            throws ServletException, IOException {
        req.setAttribute("uiStatus", "FAIL");
        req.setAttribute("billNo", "N/A");
        req.setAttribute("paidAmount", "0");
        req.setAttribute("method", "VNPAY");
        req.setAttribute("reasonText", reason);
        req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);
    }
}
