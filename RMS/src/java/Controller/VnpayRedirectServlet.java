package Controller;

import Dal.PaymentDAO;
import Dal.PaymentDAO.PaymentInfo;
import Utils.VnpayService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

/**
 * VnpayRedirectServlet
 *
 * Dùng khi thu ngân bấm "Mở lại VNPay" trong Payment.jsp.
 *
 * Logic: - Nhận paymentId. - Nếu payment đó vẫn PENDING: -> build lại URL VNPay
 * sandbox bằng VnpayService.buildPaymentUrl(...) -> redirect cashier tới
 * sandbox để test quét/nhập thẻ.
 *
 * - Nếu payment đã SUCCESS: -> forward PaymentSuccess.jsp với thông điệp "đã
 * thanh toán rồi".
 *
 * - Nếu payment FAIL / CANCEL / ... (không còn PENDING): -> forward
 * PaymentSuccess.jsp với cảnh báo không thể mở lại.
 *
 * - Nếu không tìm thấy payment: -> forward PaymentSuccess.jsp với cảnh báo
 * chung.
 *
 * Không tạo bill mới ở đây. Mục tiêu: tái sử dụng giao dịch PENDING đã có.
 */
@WebServlet(urlPatterns = {"/VnpayRedirectServlet"})
public class VnpayRedirectServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String rawPaymentId = req.getParameter("paymentId");

        if (rawPaymentId == null || rawPaymentId.isBlank()) {
            // Thiếu tham số => báo FAIL dạng đẹp
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
            // paymentId không parse được
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
                // Payment không tồn tại (đã xoá? đã finalize? id sai?)
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

            // 2. Nếu payment KHÔNG còn ở trạng thái PENDING
            if (!"PENDING".equalsIgnoreCase(info.status)) {

                if ("SUCCESS".equalsIgnoreCase(info.status)) {
                    // a) Đã SUCCESS rồi => coi như thanh toán xong
                    req.setAttribute("uiStatus", "OK"); // xanh lá
                    req.setAttribute("billNo", billNoText);
                    req.setAttribute("paidAmount", amountText);
                    req.setAttribute("method", "VNPAY");
                    req.setAttribute("reasonText",
                            "Khoản VNPay này đã thanh toán thành công trước đó. "
                            + "Không cần mở lại VNPay.");
                } else {
                    // b) Trạng thái khác (FAIL, CANCEL...) => không thể mở lại
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

            // 3. Đến đây nghĩa là payment vẫn đang PENDING -> Được phép mở lại VNPay sandbox
            BigDecimal amount = (info.amount != null ? info.amount : BigDecimal.ZERO);

            String clientIp = req.getRemoteAddr();
            String redirectUrl = VnpayService.buildPaymentUrl(
                    paymentId,
                    amount,
                    clientIp
            );

            // 4. Redirect cashier sang sandbox VNPay để hoàn tất test
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
