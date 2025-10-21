package Controller;

import Dal.KitchenDAO;
import Models.User;
import Utils.RoleBasedRedirect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * @author donny
 */
@WebServlet(name = "KitchenServlet", urlPatterns = {"/kds", "/kds/*"})
public class KitchenServlet extends HttpServlet {

    private KitchenDAO kitchenDAO = new KitchenDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập (Chef, Manager, Supervisor)
        if (!RoleBasedRedirect.hasAnyPermission(user, "Chef", "Manager", "Supervisor")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            // GET /kds - Hiển thị KDS dashboard
            showKDSDashboard(request, response);
        } else if (pathInfo.matches("/\\d+")) {
            // GET /kds/{ticketId} - Lấy thông tin ticket cụ thể
            String ticketIdStr = pathInfo.substring(1);
            try {
                Long ticketId = Long.parseLong(ticketIdStr);
                getKitchenTicket(request, response, ticketId);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ticket ID");
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Not found");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập
        if (!RoleBasedRedirect.hasAnyPermission(user, "Chef", "Manager", "Supervisor")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo.matches("/tickets/\\d+")) {
            // PATCH /kds/tickets/{ticketId} - Cập nhật status ticket
            String ticketIdStr = pathInfo.substring(pathInfo.lastIndexOf("/") + 1);
            try {
                Long ticketId = Long.parseLong(ticketIdStr);
                updateTicketStatus(request, response, ticketId, user);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ticket ID");
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Not found");
        }
    }

    /**
     * Hiển thị KDS dashboard
     */
    private void showKDSDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String station = request.getParameter("station");
            String status = request.getParameter("status");
            
            // Lấy danh sách kitchen tickets
            List<Object[]> tickets = kitchenDAO.getKitchenTickets(station, status);
            
            request.setAttribute("tickets", tickets);
            request.setAttribute("station", station);
            request.setAttribute("status", status);
            
            request.getRequestDispatcher("/views/KDS.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("Error showing KDS dashboard: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/views/KDS.jsp").forward(request, response);
        }
    }

    /**
     * Lấy thông tin kitchen ticket cụ thể
     */
    private void getKitchenTicket(HttpServletRequest request, HttpServletResponse response, Long ticketId)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            Object ticket = kitchenDAO.getKitchenTicketById(ticketId);
            if (ticket == null) {
                out.print("{\"error\":\"Ticket not found\"}");
                return;
            }

            // TODO: Convert ticket to JSON
            out.print("{\"ticket\":{}}");
        } catch (Exception e) {
            System.err.println("Error getting kitchen ticket: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /**
     * Cập nhật status của kitchen ticket
     */
    private void updateTicketStatus(HttpServletRequest request, HttpServletResponse response, Long ticketId, User user)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            String status = request.getParameter("status");
            if (status == null || status.trim().isEmpty()) {
                out.print("{\"error\":\"Status is required\"}");
                return;
            }

            // Cập nhật kitchen ticket status
            boolean success = kitchenDAO.updateKitchenTicketStatus(ticketId, status, user.getUserId());
            
            if (success) {
                // Cập nhật order item status tương ứng
                // TODO: Get order item ID from ticket and update its status
                out.print("{\"success\":true,\"message\":\"Status updated successfully\"}");
            } else {
                out.print("{\"error\":\"Failed to update status\"}");
            }
        } catch (Exception e) {
            System.err.println("Error updating ticket status: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
}
