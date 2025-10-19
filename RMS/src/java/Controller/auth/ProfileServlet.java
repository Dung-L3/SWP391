package Controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    // bắt buộc đăng nhập
    HttpSession ss = req.getSession(false);
    if (ss == null || ss.getAttribute("user") == null) {
      resp.sendRedirect(req.getContextPath() + "/LoginServlet");
      return;
    }
    req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
  }
}
