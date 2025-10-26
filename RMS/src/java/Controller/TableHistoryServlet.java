package Controller;

import Dal.OrderDAO;
import Models.OrderItem;
import Models.User;
import Utils.RoleBasedRedirect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet để xem lịch sử gọi món của bàn
 * @author donny
 */
@WebServlet(name = "TableHistoryServlet", urlPatterns = {"/table-history"})
public class TableHistoryServlet extends HttpServlet {
    
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập (Waiter, Manager, Receptionist)
        if (!RoleBasedRedirect.hasAnyPermission(user, "Waiter", "Manager", "Receptionist")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        try {
            String tableIdStr = request.getParameter("tableId");
            if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Table ID is required");
                return;
            }
            
            Integer tableId = Integer.parseInt(tableIdStr);
            
            // Lấy lịch sử order items của bàn
            List<OrderItem> history = orderDAO.getTableHistory(tableId);
            
            request.setAttribute("tableId", tableId);
            request.setAttribute("history", history);
            
            // Forward to JSP
            request.getRequestDispatcher("/views/TableHistory.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("Error showing table history: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}

