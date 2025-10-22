package Controller.auth;

import Dal.PasswordResetDAO;
import Models.PasswordReset;
import Utils.HashUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/verify-otp")
public class VerifyOtpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String token = req.getParameter("token");
        if (token == null || token.isBlank()) {
            resp.sendError(400);
            return;
        }
        req.setAttribute("token", token);
        req.getRequestDispatcher("/auth/verify-otp.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String token = req.getParameter("token");
        String otp = req.getParameter("otp");

        try {
            PasswordResetDAO prDAO = new PasswordResetDAO();
            PasswordReset pr = prDAO.findValidByToken(token);

            if (pr != null && HashUtil.verifyMixed(otp, pr.getOtpHash())) {
                // Cho phép sang bước đặt lại mật khẩu
                HttpSession session = req.getSession();
                session.setAttribute("reset_user_id", pr.getUserId());
                session.setAttribute("reset_token_id", pr.getResetId());
                resp.sendRedirect(req.getContextPath() + "/reset-password");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        req.setAttribute("token", token);
        req.setAttribute("error", "OTP không hợp lệ hoặc đã hết hạn.");
        req.getRequestDispatcher("/auth/verify-otp.jsp").forward(req, resp);
    }
}
