package Controller.auth;

import Dal.PasswordResetDAO;
import Dal.UserDAO;
import Models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;

@WebServlet("/forgot")
public class ForgotPasswordServlet extends HttpServlet {

    private static final int OTP_TTL_MINUTES = 2;

    // Tạo token URL-safe
    private static String generateToken(int bytes) {
        byte[] buf = new byte[bytes];
        new SecureRandom().nextBytes(buf);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(buf);
    }
    // OTP 6 số
    private static String generateOtp(int digits) {
        int bound = (int) Math.pow(10, digits);
        int n = new SecureRandom().nextInt(bound);
        return String.format("%0" + digits + "d", n);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/auth/forgot.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String identifier = req.getParameter("identifier"); // username hoặc email
        HttpSession session = req.getSession();

        session.setAttribute("flash",
                "Nếu tài khoản tồn tại, email hướng dẫn đặt lại mật khẩu (kèm mã OTP hiệu lực "
                        + OTP_TTL_MINUTES + " phút) đã được gửi.");

        try {
            UserDAO userDAO = new UserDAO();
            User user = null; // userDAO.findByUsernameOrEmail(identifier);

            if (user != null && user.getEmail() != null && !user.getEmail().isBlank()) {
                String token = generateToken(32);
                String otp = generateOtp(6);

                PasswordResetDAO prDAO = new PasswordResetDAO();
                prDAO.invalidateActiveForUser(user.getUserId());
                // Tạo bản ghi reset mới (DAO tự set created_at, expires_at = now + 2 phút)
                prDAO.createReset(
                        user.getUserId(),
                        token,
                        otp,
                        null, 
                        req.getRemoteAddr(),
                        req.getHeader("User-Agent")
                );

                // Dựng origin + link verify
                String origin = req.getRequestURL().toString().replace(req.getRequestURI(), "");
                String link = origin + req.getContextPath() + "/verify-otp?token=" + token;

                EmailServices mailer = new EmailServices(getServletContext());
                mailer.sendResetMail(user.getEmail(), link, otp);
            }
        } catch (Exception ex) {
            
            ex.printStackTrace();
        }

        resp.sendRedirect(req.getContextPath() + "/forgot");
    }
}
