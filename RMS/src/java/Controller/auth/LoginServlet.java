package Controller.auth;

import Dal.UserDAO;
import Models.User;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import Utils.RoleBasedRedirect; 

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet", "/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String remembered = getCookie(request.getCookies(), "username");
        if (remembered != null && !remembered.isBlank()) {
            request.setAttribute("rememberedUsername", remembered);
        }

        String next = safeTrim(request.getParameter("next"));
        if (next != null && !next.isEmpty()) {
            request.setAttribute("next", next);
        }

        request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String usernameOrEmail = safeTrim(request.getParameter("username"));
        String password        = request.getParameter("password"); // raw
        boolean remember       = request.getParameter("remember") != null;
        String next            = safeTrim(request.getParameter("next"));

        if (isBlank(usernameOrEmail) || isBlank(password)) {
            request.setAttribute("loginError", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
            return;
        }

        // Đăng nhập: kiểm tra nhiều định dạng hash (BCrypt / salt:hash / hex / legacy)
        UserDAO dao = new UserDAO();
        User user = dao.login(usernameOrEmail, password);

        if (user != null) {
            // Ngăn session fixation
            HttpSession old = request.getSession(false);
            if (old != null) old.invalidate();

            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(60 * 60); // 60 phút
            session.setAttribute("loginMsg", "Đăng nhập thành công!");

            // Remember me: chỉ lưu username để autofill
            writeUsernameCookie(response, request.getContextPath(), request.isSecure(),
                    remember ? usernameOrEmail : "");

            String ctx = request.getContextPath();
            if (next != null && next.startsWith(ctx)) {
                response.sendRedirect(next);
                return;
            }

            RoleBasedRedirect.redirectByRole(user, request, response);
            return;
        }

        // ❌ Sai thông tin
        request.setAttribute("loginError", "Tên đăng nhập hoặc mật khẩu sai.");
        request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
    }

    private static String safeTrim(String s) { return s == null ? null : s.trim(); }
    private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }

    private void writeUsernameCookie(HttpServletResponse resp, String ctx, boolean secure, String value) {
        Cookie cUser = new Cookie("username", value == null ? "" : value);
        cUser.setMaxAge((value != null && !value.isEmpty()) ? 7 * 24 * 60 * 60 : 0);
        cUser.setHttpOnly(true);
        cUser.setSecure(secure);
        cUser.setPath((ctx == null || ctx.isEmpty()) ? "/" : ctx);
        resp.addCookie(cUser);
    }

    private String getCookie(Cookie[] cookies, String name) {
        if (cookies == null) return null;
        for (Cookie c : cookies) if (name.equals(c.getName())) return c.getValue();
        return null;
    }
}
