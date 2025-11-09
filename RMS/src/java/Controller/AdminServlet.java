package Controller;

import Dal.NotificationDAO;
import Dal.StaffDAO;
import Models.Notification;
import Models.Staff;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet to handle admin dashboard requests
 */
public class AdminServlet extends HttpServlet {
    
    private StaffDAO staffDAO;
    private NotificationDAO notificationDAO;
    
    @Override
    public void init() throws ServletException {
        staffDAO = new StaffDAO();
        notificationDAO = new NotificationDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Lấy danh sách nhân viên cho sidebar
            List<Staff> staffList = staffDAO.getAllStaff();
            request.setAttribute("staffList", staffList);
            
            // Lấy thông báo chưa đọc
            List<Notification> notifications = new java.util.ArrayList<>();
            int unreadCount = 0;
            try {
                notifications = notificationDAO.getUnreadNotifications();
                unreadCount = notificationDAO.getUnreadCount();
            } catch (SQLException e) {
                System.err.println("Error loading notifications: " + e.getMessage());
                e.printStackTrace();
            }
            request.setAttribute("notifications", notifications);
            request.setAttribute("unreadNotificationCount", unreadCount);
            
            // Forward to Admin.jsp
            request.getRequestDispatcher("/views/Admin.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            // Nếu có lỗi, vẫn forward nhưng không có staffList
            request.getRequestDispatcher("/views/Admin.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
