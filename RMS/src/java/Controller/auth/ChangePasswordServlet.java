package Controller.auth;

import Dal.UserDAO;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/ChangePasswordServlet")
public class ChangePasswordServlet extends HttpServlet {

    private static String hash(String raw) {
        // Giữ nguyên cơ chế hash hiện có trong dự án để tương thích DB
        return String.valueOf(raw.hashCode());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("user");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String current = req.getParameter("currentPassword");
        String newPwd  = req.getParameter("newPassword");
        String confirm = req.getParameter("confirmPassword");

        if (current == null || newPwd == null || confirm == null || !newPwd.equals(confirm)) {
            session.setAttribute("flash", "Password confirmation does not match.");
            resp.sendRedirect(req.getContextPath() + "/views/profile.jsp");
            return;
        }

        UserDAO dao = new UserDAO();
        boolean ok = dao.changePassword(u.getUserId(), hash(current), hash(newPwd));

        if (ok) {
            session.setAttribute("flash", "Password updated successfully.");
        } else {
            session.setAttribute("flash", "Current password is incorrect.");
        }
        resp.sendRedirect(req.getContextPath() + "/views/profile.jsp");
    }
}
