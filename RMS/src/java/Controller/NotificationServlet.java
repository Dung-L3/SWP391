package Controller;

import Dal.NotificationDAO;
import Models.Notification;
import Models.User;
import Utils.RoleBasedRedirect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet quản lý thông báo cho manager
 */
@WebServlet(name = "NotificationServlet", urlPatterns = {"/notifications", "/notifications/*"})
public class NotificationServlet extends HttpServlet {
    
    private NotificationDAO notificationDAO = new NotificationDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        // Chỉ manager mới có quyền xem thông báo
        if (!RoleBasedRedirect.hasPermission(user, "Manager")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            // GET /notifications - Lấy danh sách thông báo
            getNotifications(request, response);
        } else if (pathInfo.matches("/\\d+/read")) {
            // GET /notifications/{id}/read - Đánh dấu đã đọc
            String idStr = pathInfo.substring(1, pathInfo.indexOf("/read"));
            try {
                Long notificationId = Long.parseLong(idStr);
                markAsRead(request, response, notificationId);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid notification ID");
            }
        } else if (pathInfo.equals("/count")) {
            // GET /notifications/count - Lấy số lượng thông báo chưa đọc
            getUnreadCount(request, response);
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
        
        // Chỉ manager mới có quyền
        if (!RoleBasedRedirect.hasPermission(user, "Manager")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo != null && pathInfo.matches("/\\d+/read")) {
            // POST /notifications/{id}/read - Đánh dấu đã đọc
            String idStr = pathInfo.substring(1, pathInfo.indexOf("/read"));
            try {
                Long notificationId = Long.parseLong(idStr);
                markAsRead(request, response, notificationId);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid notification ID");
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Not found");
        }
    }
    
    /**
     * Lấy danh sách thông báo
     */
    private void getNotifications(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Lấy tất cả thông báo (cả đã đọc và chưa đọc) - giới hạn 100 thông báo
            List<Notification> notifications = notificationDAO.getAllNotifications(100);
            int unreadCount = notificationDAO.getUnreadCount();
            
            request.setAttribute("notifications", notifications);
            request.setAttribute("unreadCount", unreadCount);
            
            // Forward đến trang hiển thị thông báo hoặc trả về JSON
            String format = request.getParameter("format");
            if ("json".equals(format)) {
                response.setContentType("application/json");
                PrintWriter out = response.getWriter();
                out.print("[");
                boolean first = true;
                for (Notification n : notifications) {
                    if (!first) out.print(",");
                    first = false;
                    out.print("{");
                    out.print("\"id\":" + n.getNotificationId() + ",");
                    out.print("\"type\":\"" + escapeJson(n.getNotificationType()) + "\",");
                    out.print("\"title\":\"" + escapeJson(n.getTitle()) + "\",");
                    out.print("\"message\":\"" + escapeJson(n.getMessage()) + "\",");
                    out.print("\"status\":\"" + escapeJson(n.getStatus()) + "\",");
                    out.print("\"menuItemId\":" + (n.getMenuItemId() != null ? n.getMenuItemId() : "null") + ",");
                    out.print("\"createdAt\":\"" + n.getCreatedAt() + "\"");
                    out.print("}");
                }
                out.print("]");
            } else {
                // Forward đến trang Notifications.jsp để hiển thị tất cả thông báo
                request.getRequestDispatcher("/views/Notifications.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            System.err.println("Error getting notifications: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error getting notifications");
        }
    }
    
    /**
     * Đánh dấu thông báo là đã đọc
     */
    private void markAsRead(HttpServletRequest request, HttpServletResponse response, Long notificationId)
            throws ServletException, IOException {
        
        try {
            boolean success = notificationDAO.markAsRead(notificationId);
            
            // Lấy redirect URL nếu có
            String redirectUrl = request.getParameter("redirect");
            if (redirectUrl != null && !redirectUrl.isEmpty()) {
                response.sendRedirect(redirectUrl);
                return;
            }
            
            // Nếu không có redirect, trả về JSON
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            if (success) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"error\":\"Failed to mark as read\"}");
            }
        } catch (SQLException e) {
            System.err.println("Error marking notification as read: " + e.getMessage());
            e.printStackTrace();
            
            String redirectUrl = request.getParameter("redirect");
            if (redirectUrl != null && !redirectUrl.isEmpty()) {
                response.sendRedirect(redirectUrl);
                return;
            }
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Lấy số lượng thông báo chưa đọc
     */
    private void getUnreadCount(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            int count = notificationDAO.getUnreadCount();
            out.print("{\"count\":" + count + "}");
        } catch (SQLException e) {
            System.err.println("Error getting unread count: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}

