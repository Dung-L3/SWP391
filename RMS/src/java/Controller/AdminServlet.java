package Controller;

import Dal.StaffDAO;
import Models.Staff;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet to handle admin dashboard requests
 */
public class AdminServlet extends HttpServlet {
    
    private StaffDAO staffDAO;
    
    @Override
    public void init() throws ServletException {
        staffDAO = new StaffDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Lấy danh sách nhân viên cho sidebar
            List<Staff> staffList = staffDAO.getAllStaff();
            request.setAttribute("staffList", staffList);
            
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
