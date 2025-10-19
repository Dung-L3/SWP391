package Controller.auth;

import Dal.PasswordResetDAO;
import Dal.UserDAO;
import Models.PasswordReset;
import Models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.security.SecureRandom;

@WebServlet("/resend-otp")
public class ResendOtpServlet extends HttpServlet {

    private static String generateOtp(int digits) {
        int bound = (int) Math.pow(10, digits);
        int n = new SecureRandom().nextInt(bound);
        return String.format("%0" + digits + "d", n);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Long last = (Long) session.getAttribute("lastResendAt");
        long now = System.currentTimeMillis();
        if (last != null && now - last < 30_000) {
            session.setAttribute("flash", "Vui lòng chờ ít giây rồi thử gửi lại.");
            resp.sendRedirect(req.getContextPath() + "/verify-otp?token=" + req.getParameter("token"));
            return;
        }

        String token = req.getParameter("token");
        if (token == null || token.isBlank()) {
            resp.sendError(400);
            return;
        }

        try {
            PasswordResetDAO dao = new PasswordResetDAO();
            PasswordReset pr = dao.findValidByToken(token);
            if (pr == null) {
                session.setAttribute("flash", "Không thể gửi lại OTP. Vui lòng yêu cầu quên mật khẩu lại.");
                resp.sendRedirect(req.getContextPath() + "/forgot");
                return;
            }

            // tạo OTP mới + gia hạn 2 phút
            String otp = generateOtp(6);
            boolean ok = dao.refreshOtpByToken(token, otp);
            if (ok) {
                String origin = req.getRequestURL().toString().replace(req.getRequestURI(), "");
                String link = origin + req.getContextPath() + "/verify-otp?token=" + token;

                // Lấy email người dùng để gửi
                UserDAO udao = new UserDAO();
                User u = udao.getByIdWithRole(pr.getUserId());

                EmailServices mailer = new EmailServices(getServletContext());
                mailer.sendResetMail(u.getEmail(), link, otp); // nội dung nên ghi rõ “OTP hiệu lực 2 phút”

                session.setAttribute("flash", "Đã gửi lại mã OTP. Mã hiệu lực trong 2 phút.");
                session.setAttribute("lastResendAt", now);
            } else {
                session.setAttribute("flash", "Không thể gửi lại OTP lúc này, vui lòng thử lại.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flash", "Có lỗi xảy ra, vui lòng thử lại.");
        }

        resp.sendRedirect(req.getContextPath() + "/verify-otp?token=" + token);
    }
}
