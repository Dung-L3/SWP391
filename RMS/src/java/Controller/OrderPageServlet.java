package Controller;

import Models.User;
import Utils.RoleBasedRedirect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * @author donny
 */
@WebServlet(name = "OrderPageServlet", urlPatterns = {"/order-page"})
public class OrderPageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập (Waiter, Manager, Supervisor)
        if (!RoleBasedRedirect.hasAnyPermission(user, "Waiter", "Manager", "Supervisor")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        // Forward to OrderPage.jsp
        request.getRequestDispatcher("/views/OrderPage.jsp").forward(request, response);
    }
}
