package Controller.auth;

import Dal.PasswordResetDAO;
import Dal.AuthUserDAO;
import Utils.HashUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final AuthUserDAO authUserDAO = new AuthUserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("reset_user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }
        req.getRequestDispatcher("/auth/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("reset_user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        String pw = req.getParameter("password");
        String cf = req.getParameter("confirm");

        if (pw == null || pw.length() < 8 || !pw.equals(cf)) {
            req.setAttribute("error", "Mật khẩu phải ≥ 8 ký tự và trùng xác nhận.");
            req.getRequestDispatcher("/auth/reset-password.jsp").forward(req, resp);
            return;
        }

        int userId = (Integer) s.getAttribute("reset_user_id");
        long resetId = (Long) s.getAttribute("reset_token_id");

        try {
            boolean ok = authUserDAO.updatePasswordHash(userId, HashUtil.bcrypt(pw));

            if (ok) {
                PasswordResetDAO prDAO = new PasswordResetDAO();
                prDAO.markUsed(resetId);

                s.removeAttribute("reset_user_id");
                s.removeAttribute("reset_token_id");

                s.setAttribute("loginMsg", "Đặt lại mật khẩu thành công. Vui lòng đăng nhập.");
                resp.sendRedirect(req.getContextPath() + "/LoginServlet");
                return;
            } else {
                req.setAttribute("error", "Không thể cập nhật mật khẩu. Thử lại.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Có lỗi xảy ra. Vui lòng thử lại sau.");
        }

        req.getRequestDispatcher("/auth/reset-password.jsp").forward(req, resp);
    }
}
