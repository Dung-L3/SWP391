package Controller.auth;

import Dal.UserDAO;
import Models.User;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Prefill username nếu có cookie
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

        String usernameOrEmail = safeTrim(request.getParameter("username"));
        String password        = request.getParameter("password"); // raw
        boolean remember       = request.getParameter("remember") != null;
        String next            = safeTrim(request.getParameter("next"));

        if (isBlank(usernameOrEmail) || isBlank(password)) {
            request.setAttribute("loginError", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
            return;
        }

        // Đăng nhập: DAO tự xử lý salt:hash/BCrypt/hex/plain
        UserDAO dao = new UserDAO();
        User user = dao.login(usernameOrEmail, password);

        if (user != null) {
            
            HttpSession old = request.getSession(false);
            if (old != null) old.invalidate();
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("loginMsg", "Đăng nhập thành công!");
            session.setMaxInactiveInterval(60 * 60); // 60 phút
            // Remember me: chỉ lưu username để autofill (không lưu token đăng nhập)
            writeUsernameCookie(response, request.getContextPath(), request.isSecure(),
                    remember ? usernameOrEmail : "");

            String target = (next != null && next.startsWith(request.getContextPath()))
                    ? next
                    : request.getContextPath() + "/admin";
            response.sendRedirect(target);
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
        cUser.setMaxAge((value != null && !value.isEmpty()) ? 7 * 24 * 60 * 60 : 0); // 7 ngày hoặc xoá
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
