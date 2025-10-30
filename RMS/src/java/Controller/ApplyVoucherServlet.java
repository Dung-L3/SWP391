package Controller;

import Dal.VoucherDAO;
import Models.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;

/**
 * Simple servlet to validate a voucher code and calculate discount for a given order total.
 * Returns a small JSON payload: { success: true|false, discount: 0.00, message: "...", voucherId: 1, newTotal: 12345.00 }
 */
@WebServlet(name = "ApplyVoucherServlet", urlPatterns = {"/apply-voucher"})
public class ApplyVoucherServlet extends HttpServlet {

    private VoucherDAO voucherDAO;

    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String code = request.getParameter("code");
        String totalStr = request.getParameter("orderTotal");

        try (PrintWriter out = response.getWriter()) {
            if (code == null || code.trim().isEmpty()) {
                out.print("{\"success\":false,\"message\":\"Vui lòng nhập mã voucher.\"}");
                return;
            }

            BigDecimal orderTotal = BigDecimal.ZERO;
            try {
                orderTotal = new BigDecimal(totalStr == null || totalStr.isEmpty() ? "0" : totalStr);
            } catch (NumberFormatException ex) {
                out.print("{\"success\":false,\"message\":\"Giá trị đơn hàng không hợp lệ.\"}");
                return;
            }

            // No authentication here; pass customerId as null
            String validationError = voucherDAO.validateVoucher(code.trim(), orderTotal, null);
            if (validationError != null) {
                out.print("{\"success\":false,\"message\":\"" + escapeJson(validationError) + "\"}");
                return;
            }

            Voucher v = voucherDAO.getVoucherByCode(code.trim());
            if (v == null) {
                out.print("{\"success\":false,\"message\":\"Mã voucher không tồn tại.\"}");
                return;
            }

            BigDecimal discount = voucherDAO.calculateDiscount(v, orderTotal);
            BigDecimal newTotal = orderTotal.subtract(discount);
            if (newTotal.compareTo(BigDecimal.ZERO) < 0) newTotal = BigDecimal.ZERO;

            StringBuilder sb = new StringBuilder();
            sb.append('{');
            sb.append("\"success\":true,\"discount\":").append(discount.toPlainString());
            sb.append(",\"voucherId\":").append(v.getVoucherId());
            sb.append(",\"newTotal\":").append(newTotal.toPlainString());
            sb.append(",\"message\":\"\"");
            sb.append('}');

            out.print(sb.toString());
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }
}
