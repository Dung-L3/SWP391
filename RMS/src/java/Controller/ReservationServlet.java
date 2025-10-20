package Controller;

import Dal.ReservationDAO;
import Models.Reservation;
import Models.User;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.UUID;
import java.util.List;
import java.util.stream.Collectors;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ReservationServlet", urlPatterns = {"/reservation/*"})
public class ReservationServlet extends HttpServlet {
    
    private void handleSelectTable(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy và validate thông tin từ form
            String customerName = request.getParameter("customer_name");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            String partySize = request.getParameter("party_size");
            String reservationDate = request.getParameter("reservation_date");
            String reservationTime = request.getParameter("reservation_time");
            String specialRequests = request.getParameter("special_requests");
            
            // Validate các trường bắt buộc
            if (customerName == null || customerName.trim().isEmpty() ||
                phone == null || !phone.matches("[0-9]{10}") ||
                partySize == null || reservationDate == null || reservationTime == null) {
                request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc");
                request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
                return;
            }

            // Lưu thông tin vào session
            HttpSession session = request.getSession();
            session.setAttribute("bookingInProgress", true);
            session.setAttribute("customerName", customerName);
            session.setAttribute("phone", phone);
            session.setAttribute("email", email);
            session.setAttribute("partySize", partySize);
            session.setAttribute("reservationDate", reservationDate);
            session.setAttribute("reservationTime", reservationTime);
            session.setAttribute("specialRequests", specialRequests);
            
            // Chuyển hướng đến trang chọn bàn
            response.sendRedirect(request.getContextPath() + "/table-layout");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
        }
    }
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        try {
            switch (pathInfo) {
                case "/select-table":
                    handleSelectTable(request, response);
                    break;
                case "/create":
                    handleCreateReservation(request, response);
                    break;
                case "/cancel":
                    handleCancelReservation(request, response);
                    break;
                case "/edit":
                    handleEditReservation(request, response);
                    break;
                case "/update":
                    handleUpdateReservation(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
        }
    }
    
    private void handleCreateReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy thông tin khách hàng từ form
            String customerName = request.getParameter("customer_name");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            
            // Validate thông tin khách hàng
            if (customerName == null || customerName.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng nhập họ tên.");
                request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
                return;
            }
            
            if (phone == null || !phone.matches("[0-9]{10}")) {
                request.setAttribute("errorMessage", "Số điện thoại không hợp lệ.");
                request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
                return;
            }
            
            // Lấy thông tin đặt bàn từ form
            int partySize = Integer.parseInt(request.getParameter("party_size"));
            Date reservationDate = Date.valueOf(request.getParameter("reservation_date"));
            Time reservationTime = Time.valueOf(request.getParameter("reservation_time"));
            String specialRequests = request.getParameter("special_requests");
            
            // Kiểm tra thời gian đặt bàn
            java.util.Date now = new java.util.Date();
            java.util.Date reservationDateTime = new java.util.Date(
                reservationDate.getTime() + reservationTime.getTime() + (7 * 60 * 60 * 1000) // Convert to Vietnam timezone
            );
            java.util.Date twoHoursFromNow = new java.util.Date(now.getTime() + (2 * 60 * 60 * 1000));
            
            if (reservationDateTime.before(now)) {
                request.setAttribute("errorMessage", "Không thể đặt bàn cho thời gian đã qua.");
                request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
                return;
            }
            
            if (reservationDateTime.before(twoHoursFromNow)) {
                request.setAttribute("errorMessage", "Vui lòng đặt bàn trước thời điểm đến ít nhất 2 tiếng.");
                request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
                return;
            }
            
            // Tạo đối tượng Reservation
            Reservation reservation = new Reservation();
            reservation.setPartySize(partySize);
            reservation.setReservationDate(reservationDate);
            reservation.setReservationTime(reservationTime);
            reservation.setSpecialRequests(specialRequests);
            reservation.setChannel(Reservation.CHANNEL_WEB); // Đặt từ website
            
            // Set thông tin khách hàng
            reservation.setCustomerName(customerName);
            reservation.setPhone(phone);
            reservation.setEmail(email);
            
            // Nếu user đã đăng nhập, lưu customer_id
            User user = (User) request.getSession().getAttribute("user");
            if (user != null) {
                reservation.setCustomerId(user.getUserId());
                reservation.setCreatedBy(user.getUserId());
            }
            
            // Tạo mã xác nhận ngẫu nhiên
            reservation.setConfirmationCode(generateConfirmationCode());
            
            // Lưu vào database
            ReservationDAO dao = new ReservationDAO();
            
            // Kiểm tra xem có bàn phù hợp không
            // TODO: Implement table selection logic based on party size
            
            if (dao.create(reservation)) {
                // Thành công
                request.setAttribute("reservation", reservation);
                
                // Lấy danh sách đặt bàn khác của khách hàng (nếu đã đăng nhập)
                User currentUser = (User) request.getSession().getAttribute("user");
                if (currentUser != null) {
                    List<Reservation> reservations = dao.findByCustomerId(currentUser.getUserId());
                    // Loại bỏ đơn vừa đặt khỏi danh sách
                    reservations.removeIf(r -> r.getConfirmationCode().equals(reservation.getConfirmationCode()));
                    request.setAttribute("reservations", reservations);
                }
                
                request.getRequestDispatcher("/views/guest/confirmation.jsp").forward(request, response);
                
                // TODO: Gửi email xác nhận
                
            } else {
                request.setAttribute("errorMessage", 
                        "Không thể đặt bàn. Vui lòng thử lại sau.");
                request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
        }
    }
    
    private void handleCancelReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            ReservationDAO dao = new ReservationDAO();
            
            // Kiểm tra quyền hủy đặt bàn
            User user = (User) request.getSession().getAttribute("user");
            Reservation reservation = dao.findById(reservationId);
            
            if (reservation == null) {
                request.setAttribute("errorMessage", "Không tìm thấy đặt bàn.");
                response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
                return;
            }
            
            if (user == null || 
                (reservation.getCustomerId() != null && 
                !reservation.getCustomerId().equals(user.getUserId()))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            
            if (dao.updateStatus(reservationId, "CANCELLED")) {
                request.setAttribute("successMessage", "Hủy đặt bàn thành công.");
            } else {
                request.setAttribute("errorMessage", "Không thể hủy đặt bàn. Vui lòng thử lại sau.");
            }
            
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
    }
    
    private String generateConfirmationCode() {
        return UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
    
    private void handleEditReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            ReservationDAO dao = new ReservationDAO();
            Reservation reservation = dao.findById(reservationId);
            
            if (reservation == null) {
                request.setAttribute("errorMessage", "Không tìm thấy đặt bàn.");
                response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
                return;
            }
            
            // Kiểm tra quyền sửa đặt bàn
            User user = (User) request.getSession().getAttribute("user");
            if (user == null || 
                (reservation.getCustomerId() != null && 
                !reservation.getCustomerId().equals(user.getUserId()))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            
            request.setAttribute("reservation", reservation);
            request.getRequestDispatcher("/views/guest/edit-reservation.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
        }
    }
    
    private void handleUpdateReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy ID của đặt bàn cần cập nhật
            int reservationId = Integer.parseInt(request.getParameter("reservation_id"));
            ReservationDAO dao = new ReservationDAO();
            Reservation existingReservation = dao.findById(reservationId);
            
            if (existingReservation == null) {
                request.setAttribute("errorMessage", "Không tìm thấy đặt bàn.");
                response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
                return;
            }
            
            // Kiểm tra quyền sửa đặt bàn
            User user = (User) request.getSession().getAttribute("user");
            if (user == null || 
                (existingReservation.getCustomerId() != null && 
                !existingReservation.getCustomerId().equals(user.getUserId()))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            
            // Cập nhật thông tin đặt bàn
            Reservation updatedReservation = new Reservation();
            updatedReservation.setReservationId(reservationId);
            updatedReservation.setPartySize(Integer.parseInt(request.getParameter("party_size")));
            updatedReservation.setReservationDate(Date.valueOf(request.getParameter("reservation_date")));
            updatedReservation.setReservationTime(Time.valueOf(request.getParameter("reservation_time")));
            updatedReservation.setSpecialRequests(request.getParameter("special_requests"));
            updatedReservation.setCustomerName(request.getParameter("customer_name"));
            updatedReservation.setPhone(request.getParameter("phone"));
            updatedReservation.setEmail(request.getParameter("email"));
            updatedReservation.setStatus(existingReservation.getStatus());
            updatedReservation.setChannel(existingReservation.getChannel());
            updatedReservation.setCreatedBy(existingReservation.getCreatedBy());
            updatedReservation.setConfirmationCode(existingReservation.getConfirmationCode());
            
            if (dao.update(updatedReservation)) {
                request.setAttribute("reservation", updatedReservation);
                request.setAttribute("successMessage", "Cập nhật đặt bàn thành công!");
                request.getRequestDispatcher("/views/guest/confirmation.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Không thể cập nhật đặt bàn. Vui lòng thử lại sau.");
                request.setAttribute("reservation", existingReservation);
                request.getRequestDispatcher("/views/guest/edit-reservation.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/my-reservations");
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