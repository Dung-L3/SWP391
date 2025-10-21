package Controller;

import Dal.TableDAO;
import Models.DiningTable;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "TableLayoutServlet", urlPatterns = {"/table-layout"})
public class TableLayoutServlet extends HttpServlet {
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Kiểm tra session có thông tin đặt bàn không
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("bookingInProgress") == null) {
                response.sendRedirect(request.getContextPath() + "/views/guest/booking.jsp");
                return;
            }

            // Lấy thông tin đặt bàn từ session
            int partySize = Integer.parseInt((String) session.getAttribute("partySize"));
            String reservationDate = (String) session.getAttribute("reservationDate");
            String reservationTime = (String) session.getAttribute("reservationTime");

            TableDAO tableDAO = new TableDAO();
            
            // Get area ID from parameter, default to 1
            int areaId = 1;
            String areaParam = request.getParameter("area");
            if (areaParam != null && !areaParam.isEmpty()) {
                areaId = Integer.parseInt(areaParam);
            }
            
            // Get filter type if any
            String filterType = request.getParameter("type");
            
            List<DiningTable> tables;
            if (filterType != null && !filterType.isEmpty()) {
                tables = tableDAO.getTablesByType(filterType);
            } else {
                tables = tableDAO.getTablesByArea(areaId);
            }
            
            // Set attributes for JSP
            request.setAttribute("tables", tables);
            request.setAttribute("currentArea", areaId);
            
            // Forward đến trang sơ đồ bàn
            request.getRequestDispatcher("/views/guest/table-layout.jsp")
                  .forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                             "Có lỗi xảy ra khi tải sơ đồ bàn");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}