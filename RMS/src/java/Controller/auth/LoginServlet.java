package Controller.auth;

import Dal.UserDAO;
import Models.User;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = safeTrim(request.getParameter("username"));
        String password = request.getParameter("password");
        boolean remember = request.getParameter("remember") != null;

        // validate 
        if (username == null || username.isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("loginError", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
            return;
        }

        String passwordHash = String.valueOf(password.hashCode());

        UserDAO dao = new UserDAO();
        User user = dao.login(username, passwordHash);

        if (user != null) {
            //  Đăng nhập thành công
            HttpSession old = request.getSession(false);
            if (old != null) old.invalidate();
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("loginMsg", "Đăng nhập thành công!");

            // Remember me: chỉ nhớ username để autofill
            if (remember) {
                Cookie cUser = new Cookie("username", username);
                cUser.setMaxAge(7 * 24 * 60 * 60); // 7 ngày
                cUser.setHttpOnly(true);
                cUser.setSecure(request.isSecure());
                cUser.setPath(request.getContextPath());
                response.addCookie(cUser);
            } else {
                 
                Cookie cUser = new Cookie("username", "");
                cUser.setMaxAge(0);
                cUser.setHttpOnly(true);
                cUser.setSecure(request.isSecure());
                cUser.setPath(request.getContextPath());
                response.addCookie(cUser);
            }
            response.sendRedirect(request.getContextPath() + "/views/Admin.jsp");
        } else {
            // ❌ Sai tài khoản/mật khẩu
            request.setAttribute("loginError", "Tên đăng nhập hoặc mật khẩu sai.");
            request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
    }

    private String safeTrim(String s) {
        return s == null ? null : s.trim();
    }
}
