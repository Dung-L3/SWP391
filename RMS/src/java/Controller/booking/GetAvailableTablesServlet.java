package Controller;

import Dal.TableAreaDAO;
import Models.DiningTable;
import Models.TableArea;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "GetAvailableTablesServlet", urlPatterns = {"/GetAvailableTablesServlet"})
public class GetAvailableTablesServlet extends HttpServlet {

   @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    response.setContentType("application/json;charset=UTF-8");

    // Sử dụng try-with-resources để đảm bảo PrintWriter luôn được đóng
    try (PrintWriter out = response.getWriter()) {
        
        // Lấy tham số một cách an toàn
        String date = request.getParameter("date");
        String time = request.getParameter("time");
        String guestsStr = request.getParameter("guests");
        String areaIdStr = request.getParameter("area");

        // --- BƯỚC KIỂM TRA QUAN TRỌNG ---
        // Kiểm tra các tham số bắt buộc không được null hoặc rỗng
        if (date == null || date.isEmpty() || time == null || time.isEmpty() || guestsStr == null || guestsStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // Lỗi 400 Bad Request
            out.println("{\"error\": \"Missing required parameters: date, time, or guests\"}");
            return; // Dừng thực thi
        }
        
        int guests;
        try {
            guests = Integer.parseInt(guestsStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.println("{\"error\": \"Invalid format for guests parameter\"}");
            return;
        }

        // Khởi tạo DAO
        TableAreaDAO tableAreaDAO = new TableAreaDAO();
        List<DiningTable> availableTables;

        // Xử lý logic nghiệp vụ
        // Kiểm tra areaId có được cung cấp hay không
        if (areaIdStr != null && !areaIdStr.isEmpty() && !areaIdStr.equals("null") && !areaIdStr.equals("undefined")) {
            try {
                int areaId = Integer.parseInt(areaIdStr);
                availableTables = tableAreaDAO.getAvailableTablesByArea(areaId, date, time, guests);
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println("{\"error\": \"Invalid format for area parameter\"}");
                return;
            }
        } else {
            // Nếu không có areaId, lấy tất cả bàn trống phù hợp
            availableTables = tableAreaDAO.getAllAvailableTables(date, time, guests);
        }

        // Chuyển đổi và trả về JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(availableTables);
        response.setStatus(HttpServletResponse.SC_OK); // Trạng thái 200 OK
        out.println(jsonResponse);

    } catch (Exception e) {
        // Bắt tất cả các lỗi khác (ví dụ: lỗi từ CSDL)
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // Lỗi 500
        // In stack trace ra log server để debug
        e.printStackTrace(); 
        // Trả về thông báo lỗi chung
        try (PrintWriter out = response.getWriter()) {
             out.println("{\"error\": \"An internal server error occurred. Please check server logs.\"}");
        }
    }
  }
}