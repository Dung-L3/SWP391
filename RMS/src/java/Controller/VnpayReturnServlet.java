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
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(urlPatterns = {"/VnpayReturnServlet"})
public class VnpayReturnServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final BillDAO billDAO = new BillDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy toàn bộ query param
        Map<String, String> vnpParams = new HashMap<>();
        req.getParameterMap().forEach((key, vals) -> {
            if (vals != null && vals.length > 0) {
                vnpParams.put(key, vals[0]);
            }
        });

        String vnpTxnRef = vnpParams.get("vnp_TxnRef");
        String vnpResponseCode = vnpParams.get("vnp_ResponseCode");
        String vnpTransactionNo = vnpParams.get("vnp_TransactionNo");
        String vnpSecureHash = vnpParams.get("vnp_SecureHash");

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

        // Xác thực chữ ký
        boolean isValidSignature = VnpayService.verifyReturn(vnpParams, vnpSecureHash);
        if (!isValidSignature) {
            forwardFail(req, resp, "Kết quả thanh toán không hợp lệ hoặc đã bị chỉnh sửa trên URL.");
            return;
        }

        // Đọc payment
        PaymentInfo pInfo;
        try {
            pInfo = paymentDAO.getPaymentInfo(paymentId);
        } catch (SQLException e) {
            e.printStackTrace();
            forwardFail(req, resp, "Lỗi CSDL khi đọc payment.");
            return;
        }
        if (pInfo == null) {
            forwardFail(req, resp, "Không tìm thấy giao dịch #" + paymentId + ".");
            return;
        }

        Long billId = pInfo.billId;
        Long orderId = pInfo.orderId;

        // Lấy bill
        BillSummary billSummary;
        try {
            billSummary = billDAO.getBillSummary(billId);
        } catch (SQLException e) {
            e.printStackTrace();
            forwardFail(req, resp, "Lỗi CSDL khi đọc bill.");
            return;
        }
        if (billSummary == null) {
            forwardFail(req, resp, "Không tìm thấy hóa đơn liên quan.");
            return;
        }

        // Kiểm tra số tiền
        try {
            long amountFromVnp = Long.parseLong(vnpParams.getOrDefault("vnp_Amount", "0"));
            long expected = (pInfo.amount != null ? pInfo.amount : BigDecimal.ZERO)
                    .multiply(new BigDecimal("100")).longValue();
            if (amountFromVnp != expected) {
                forwardFail(req, resp, "Số tiền VNPay trả về không khớp đơn hàng.");
                return;
            }
        } catch (NumberFormatException nf) {
            forwardFail(req, resp, "Giá trị vnp_Amount không hợp lệ.");
            return;
        }

        boolean paymentSuccess = "00".equals(vnpResponseCode);
        if (!paymentSuccess) {
            req.setAttribute("uiStatus", "FAIL");
            req.setAttribute("billNo", billSummary.billNo != null ? billSummary.billNo : String.valueOf(billSummary.billId));
            req.setAttribute("paidAmount", "0");
            req.setAttribute("method", "VNPAY");
            req.setAttribute("reasonText", "Thanh toán VNPay không thành công (code=" + vnpResponseCode + ").");
            req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);
            return;
        }

        // Thanh toán thành công
        try {
            paymentDAO.markPaymentSuccess(paymentId, vnpTransactionNo != null ? vnpTransactionNo : "");
            billDAO.markBillPaid(billId);

            if (billSummary.voucherId != null && billSummary.voucherId > 0) {
                BigDecimal discountUsed = billSummary.discountAmount != null ? billSummary.discountAmount : BigDecimal.ZERO;
                voucherDAO.recordRedemption(billSummary.voucherId, null, billId, discountUsed);
            }

            if (orderId != null) {
                orderDAO.closeOrder(orderId);
            }

            req.setAttribute("uiStatus", "OK");
            req.setAttribute("billNo", billSummary.billNo != null ? billSummary.billNo : String.valueOf(billSummary.billId));
            req.setAttribute("paidAmount", billSummary.totalAmount);
            req.setAttribute("method", "VNPAY");
            req.setAttribute("reasonText", "Thanh toán VNPay thành công"
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
