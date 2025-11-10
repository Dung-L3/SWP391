package Controller.auth;

import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Hiển thị trang hồ sơ và trang chỉnh sửa hồ sơ.
 *  - GET /profile       -> profile.jsp (xem thông tin)
 *  - GET /profile/edit  -> profile-edit.jsp (form chỉnh sửa)
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile", "/profile/edit"})
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("user");

        // Bắt buộc đăng nhập
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        req.setCharacterEncoding("UTF-8");

        // Lấy flash message (nếu có) từ session đưa xuống request rồi xóa
        Object flash = session.getAttribute("flash");
        if (flash != null) {
            req.setAttribute("flash", flash);
            session.removeAttribute("flash");
        }

        // Điều hướng view theo URL
        String servletPath = req.getServletPath(); // "/profile" hoặc "/profile/edit"

        if ("/profile/edit".equals(servletPath)) {
            // Trang form chỉnh sửa
            req.getRequestDispatcher("/views/profile-edit.jsp").forward(req, resp);
        } else {
            // Trang xem hồ sơ
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
        }
    }

    // Không dùng POST ở đây, nếu có thì trả về GET
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }
}
