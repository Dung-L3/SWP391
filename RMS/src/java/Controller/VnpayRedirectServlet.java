package Controller;

import Dal.PaymentDAO;
import Dal.PaymentDAO.PaymentInfo;
import Utils.VnpayService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

/**
 * VnpayRedirectServlet
 *
 * Khi thu ngân bấm "Mở lại VNPay" trong Payment.jsp.
 *
 * Logic:
 *  - Nhận paymentId.
 *  - Nếu payment vẫn PENDING:
 *      -> build lại URL VNPay sandbox bằng VnpayService.buildPaymentUrl(...)
 *      -> redirect tới sandbox để test quét/nhập thẻ.
 *
 *  - Nếu payment đã SUCCESS:
 *      -> forward PaymentSuccess.jsp với thông điệp "đã thanh toán rồi"
 *         + truyền billId để có thể in hóa đơn.
 *
 *  - Nếu payment FAIL / CANCEL / ...:
 *      -> forward PaymentSuccess.jsp với cảnh báo không thể mở lại.
 *
 *  - Nếu không tìm thấy payment:
 *      -> forward PaymentSuccess.jsp với cảnh báo chung.
 *
 * Không tạo bill mới ở đây. Chỉ tái sử dụng giao dịch PENDING đã có.
 */
@WebServlet(urlPatterns = {"/VnpayRedirectServlet"})
public class VnpayRedirectServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String rawPaymentId = req.getParameter("paymentId");

        if (rawPaymentId == null || rawPaymentId.isBlank()) {
            req.setAttribute("uiStatus", "FAIL");
            req.setAttribute("billNo", "N/A");
            req.setAttribute("paidAmount", "0");
            req.setAttribute("method", "VNPAY");
            req.setAttribute("reasonText",
                    "Thiếu thông tin giao dịch cần mở lại VNPay. "
                            + "Vui lòng quay lại màn hình thanh toán bàn và thử lại.");
            req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);
            return;
        }

        Long paymentId;
        try {
            paymentId = Long.parseLong(rawPaymentId.trim());
        } catch (NumberFormatException ex) {
            req.setAttribute("uiStatus", "FAIL");
            req.setAttribute("billNo", "N/A");
            req.setAttribute("paidAmount", "0");
            req.setAttribute("method", "VNPAY");
            req.setAttribute("reasonText",
                    "paymentId không hợp lệ. Không thể mở lại giao dịch VNPay.");
            req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);
            return;
        }

        try {
            // 1. Lấy payment từ DB
            PaymentInfo info = paymentDAO.getPaymentInfo(paymentId);

            if (info == null) {
                req.setAttribute("uiStatus", "FAIL");
                req.setAttribute("billNo", "N/A");
                req.setAttribute("paidAmount", "0");
                req.setAttribute("method", "VNPAY");
                req.setAttribute("reasonText",
                        "Không tìm thấy giao dịch #" + paymentId
                                + ". Có thể hóa đơn đã được chốt và giao dịch này không còn hiệu lực.");
                req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);
                return;
            }

            String billNoText = (info.billId != null ? String.valueOf(info.billId) : "N/A");
            String amountText = (info.amount != null ? info.amount.toString() : "0");

            // 2. Nếu payment không còn PENDING
            if (!"PENDING".equalsIgnoreCase(info.status)) {

                if ("SUCCESS".equalsIgnoreCase(info.status)) {
                    // a) ĐÃ THÀNH CÔNG -> cho xem màn kết quả + in hóa đơn nếu có billId
                    req.setAttribute("uiStatus", "OK");
                    if (info.billId != null) {
                        req.setAttribute("billId", info.billId);  // <<-- để in hóa đơn
                    }
                    req.setAttribute("billNo", billNoText);
                    req.setAttribute("paidAmount", amountText);
                    req.setAttribute("method", "VNPAY");
                    req.setAttribute("reasonText",
                            "Khoản VNPay này đã thanh toán thành công trước đó. "
                                    + "Không cần mở lại VNPay.");
                } else {
                    // b) FAIL / CANCEL / ... -> báo không thể mở lại
                    req.setAttribute("uiStatus", "FAIL");
                    req.setAttribute("billNo", billNoText);
                    req.setAttribute("paidAmount", "0");
                    req.setAttribute("method", "VNPAY");
                    req.setAttribute("reasonText",
                            "Khoản thanh toán không còn ở trạng thái chờ VNPay. "
                                    + "Trạng thái hiện tại: " + info.status
                                    + ". Vui lòng thu bằng phương thức khác hoặc tạo giao dịch mới nếu cần.");
                }

                req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);
                return;
            }

            // 3. Payment vẫn PENDING -> Được phép mở lại VNPay sandbox
            BigDecimal amount = (info.amount != null ? info.amount : BigDecimal.ZERO);

            String clientIp = req.getRemoteAddr();
            String redirectUrl = VnpayService.buildPaymentUrl(
                    paymentId,
                    amount,
                    clientIp
            );

            // 4. Redirect cashier sang sandbox VNPay để hoàn tất
            resp.sendRedirect(redirectUrl);

        } catch (SQLException e) {
            e.printStackTrace();

            req.setAttribute("uiStatus", "FAIL");
            req.setAttribute("billNo", "N/A");
            req.setAttribute("paidAmount", "0");
            req.setAttribute("method", "VNPAY");
            req.setAttribute("reasonText",
                    "Không thể mở lại VNPay do lỗi kết nối CSDL. Vui lòng thử lại.");
            req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);

        } catch (Exception e) {
            // phòng khi buildPaymentUrl ném runtime hoặc lỗi bất ngờ
            e.printStackTrace();

            req.setAttribute("uiStatus", "FAIL");
            req.setAttribute("billNo", "N/A");
            req.setAttribute("paidAmount", "0");
            req.setAttribute("method", "VNPAY");
            req.setAttribute("reasonText",
                    "Lỗi nội bộ khi tạo URL VNPay. Vui lòng thử lại hoặc thu bằng phương thức khác.");
            req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);
        }
    }
}
