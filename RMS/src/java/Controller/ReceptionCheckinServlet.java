package Controller;

import Dal.TableDAO;
import Dal.ReservationDAO;
import Models.Reservation;
import Models.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = {"/reception/checkin-table"})
public class ReceptionCheckinServlet extends HttpServlet {

    // Hiển thị form check-in (GET từ menu)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        request.setAttribute("page", "reception-checkin");
        RequestDispatcher rd = request.getRequestDispatcher("/views/reception-checkin.jsp");
        rd.forward(request, response);
    }

    // Xử lý các action từ form (checkin / update_status / lookup)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String action = request.getParameter("action");

        try {
            if ("checkin".equals(action)) {
                handleCheckin(request, response, session);
                return;
            } else if ("update_status".equals(action)) {
                handleUpdateStatus(request, response, session);
                return;
            } else if ("lookup".equals(action)) {
                handleLookup(request, response);
                return;
            } else {
                session.setAttribute("errorMessage", "Hành động không hợp lệ.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/reception/checkin-table");
    }

    private void handleCheckin(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws Exception {

        String code = request.getParameter("confirmationCode");
        if (code == null || code.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Vui lòng nhập mã xác nhận.");
            response.sendRedirect(request.getContextPath() + "/reception/checkin-table");
            return;
        }

        ReservationDAO rdao = new ReservationDAO();
        Reservation res = rdao.getReservationByConfirmationCode(code.trim());
        if (res == null) {
            session.setAttribute("errorMessage", "Không tìm thấy thông tin đặt bàn với mã đã cho.");
            response.sendRedirect(request.getContextPath() + "/reception/checkin-table");
            return;
        }

        TableDAO tableDao = new TableDAO();
        Integer userId = null;
        Object uObj = session.getAttribute("user");
        if (uObj instanceof User) {
            userId = ((User) uObj).getUserId();
        }

        boolean seated = tableDao.seatTable(res.getTableId(), res.getPartySize(),
                res.getSpecialRequests(), userId);
        if (!seated) {
            session.setAttribute("errorMessage", "Không thể mở phiên/bàn — vui lòng kiểm tra trạng thái bàn.");
            response.sendRedirect(request.getContextPath() + "/reception/checkin-table");
            return;
        }

        try {
            rdao.updateStatus(res.getReservationId(), "SEATED");
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("errorMessage",
                    "Khách đã được chỗ nhưng cập nhật trạng thái đặt bàn thất bại: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/reception/checkin-table");
            return;
        }

        session.setAttribute("successMessage", "Check-in thành công — khách đã được ghế tại bàn.");
        response.sendRedirect(request.getContextPath() + "/reception/checkin-table");
    }

    private void handleLookup(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String code = request.getParameter("confirmationCode");
        if (code == null || code.trim().isEmpty()) {
            request.getSession().setAttribute("errorMessage", "Vui lòng nhập mã xác nhận.");
            response.sendRedirect(request.getContextPath() + "/reception/checkin-table");
            return;
        }

        ReservationDAO rdao = new ReservationDAO();
        Reservation res = rdao.getReservationByConfirmationCode(code.trim());
        if (res == null) {
            request.getSession().setAttribute("errorMessage", "Không tìm thấy thông tin đặt bàn với mã đã cho.");
            response.sendRedirect(request.getContextPath() + "/reception/checkin-table");
            return;
        }

        request.setAttribute("page", "reception-checkin");
        request.setAttribute("lookupReservation", res);
        RequestDispatcher rd = request.getRequestDispatcher("/views/reception-checkin.jsp");
        rd.forward(request, response);
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {

        String tableNumber = request.getParameter("tableNumber");
        String newStatus = request.getParameter("newStatus");

        if (tableNumber == null || tableNumber.isEmpty()
                || newStatus == null || newStatus.isEmpty()) {
            session.setAttribute("errorMessage", "Vui lòng chọn bàn và trạng thái mới.");
            response.sendRedirect(request.getContextPath() + "/reception/checkin-table");
            return;
        }

        try {
            TableDAO tableDao = new TableDAO();
            boolean ok = tableDao.updateTableStatus(tableNumber, newStatus);
            if (ok) {
                session.setAttribute("successMessage", "Cập nhật trạng thái bàn thành công.");
            } else {
                session.setAttribute("errorMessage",
                        "Không thể cập nhật trạng thái bàn (không tìm thấy hoặc không thay đổi).");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi khi cập nhật trạng thái bàn: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/reception/checkin-table");
    }
}
