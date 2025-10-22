package Controller.auth;

import Dal.UserDAO;
import Models.User;
import Utils.HashUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/ChangePasswordServlet")
public class ChangePasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        String oldPassword = req.getParameter("oldPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        // Validate cơ bản
        if (oldPassword == null || newPassword == null || confirmPassword == null ||
            oldPassword.isBlank() || newPassword.isBlank() || confirmPassword.isBlank()) {
            session.setAttribute("profileMsgError", "Vui lòng nhập đầy đủ các trường.");
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            session.setAttribute("profileMsgError", "Mật khẩu xác nhận không khớp.");
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        try {
            UserDAO dao = new UserDAO();

            // ✅ Kiểm tra old password bằng verifyMixed (hỗ trợ cả bcrypt và hash cũ)
            boolean oldMatch = HashUtil.verifyMixed(oldPassword, currentUser.getPasswordHash());
            if (!oldMatch) {
                session.setAttribute("profileMsgError", "Mật khẩu hiện tại không đúng.");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }

            // ✅ Bcrypt mật khẩu mới
            String newHashed = HashUtil.bcrypt(newPassword);

            boolean updated = dao.updatePasswordHash(currentUser.getUserId(), newHashed);
            if (updated) {
                // Cập nhật lại trong session để tránh lỗi đăng nhập tiếp
                currentUser.setPasswordHash(newHashed);
                session.setAttribute("user", currentUser);
                session.setAttribute("profileMsgSuccess", "Mật khẩu đã được thay đổi thành công!");
            } else {
                session.setAttribute("profileMsgError", "Không thể cập nhật mật khẩu. Vui lòng thử lại.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("profileMsgError", "Lỗi máy chủ, vui lòng thử lại sau.");
        }

        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}
