package Controller;

import Controller.auth.EmailServices;
import Dal.ReservationDAO;
import Models.Reservation;
import Models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import javax.mail.MessagingException;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.List;
import java.util.UUID;

/**
 * Đặt bàn cho khách (web guest)
 */
@WebServlet(name = "ReservationServlet", urlPatterns = {"/reservation", "/reservation/*"})
public class ReservationServlet extends HttpServlet {

    // ========== HELPER ==========

    private String generateConfirmationCode() {
        return UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    // ========= HIỂN THỊ FORM ĐẶT BÀN ==========

    /**
     * GET /reservation hoặc /reservation/  → hiển thị booking.jsp
     */
    private void showBookingForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
    }

    // ========= BƯỚC 1: NHẬP THÔNG TIN, CHUYỂN QUA CHỌN BÀN ==========

    private void handleSelectTable(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String customerName     = request.getParameter("customer_name");
            String phone            = request.getParameter("phone");
            String email            = request.getParameter("email");
            String partySize        = request.getParameter("party_size");
            String reservationDate  = request.getParameter("reservation_date");
            String reservationTime  = request.getParameter("reservation_time");
            String specialRequests  = request.getParameter("special_requests");

            // Validate
            if (customerName == null || customerName.trim().isEmpty()
                    || phone == null || !phone.matches("[0-9]{10}")
                    || partySize == null || reservationDate == null || reservationTime == null) {

                request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
                request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
                return;
            }

            // Lưu vào session để dùng ở màn chọn bàn
            HttpSession session = request.getSession();
            session.setAttribute("bookingInProgress", true);
            session.setAttribute("customerName", customerName);
            session.setAttribute("phone", phone);
            session.setAttribute("email", email);
            session.setAttribute("partySize", partySize);
            session.setAttribute("reservationDate", reservationDate);
            session.setAttribute("reservationTime", reservationTime);
            session.setAttribute("specialRequests", specialRequests);

            // Chuyển qua trang layout bàn
            response.sendRedirect(request.getContextPath() + "/table-layout");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
        }
    }

    // ========= BƯỚC 2: TẠO ĐẶT BÀN =========

    private void handleCreateReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Thông tin khách
            String customerName = request.getParameter("customer_name");
            String phone        = request.getParameter("phone");
            String email        = request.getParameter("email");

            if (customerName == null || customerName.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng nhập họ tên.");
                showBookingForm(request, response);
                return;
            }
            if (phone == null || !phone.matches("[0-9]{10}")) {
                request.setAttribute("errorMessage", "Số điện thoại không hợp lệ (10 chữ số).");
                showBookingForm(request, response);
                return;
            }

            int  partySize       = Integer.parseInt(request.getParameter("party_size"));
            Date reservationDate = Date.valueOf(request.getParameter("reservation_date"));

            // Chuẩn hoá time (HH:mm hoặc HH:mm:ss)
            String timeStr = request.getParameter("reservation_time");
            if (!timeStr.contains(":")) {
                timeStr += ":00";
            } else if (timeStr.length() == 5) {
                timeStr += ":00";
            }
            Time reservationTime = Time.valueOf(timeStr);

            String specialRequests = request.getParameter("special_requests");

            // Kiểm tra min 2h trước giờ đến
            java.util.Date now = new java.util.Date();
            java.util.Date reservationDateTime =
                    new java.util.Date(reservationDate.getTime() + reservationTime.getTime());
            java.util.Date twoHoursFromNow = new java.util.Date(now.getTime() + 2L * 60 * 60 * 1000);

            if (reservationDateTime.before(now)) {
                request.setAttribute("errorMessage", "Không thể đặt bàn cho thời gian đã qua.");
                showBookingForm(request, response);
                return;
            }
            if (reservationDateTime.before(twoHoursFromNow)) {
                request.setAttribute("errorMessage",
                        "Vui lòng đặt bàn trước thời điểm đến ít nhất 2 tiếng.");
                showBookingForm(request, response);
                return;
            }

            // Build đối tượng Reservation
            Reservation reservation = new Reservation();
            reservation.setPartySize(partySize);
            reservation.setReservationDate(reservationDate);
            reservation.setReservationTime(reservationTime);
            reservation.setSpecialRequests(specialRequests);
            reservation.setChannel(Reservation.CHANNEL_WEB);

            reservation.setCustomerName(customerName);
            reservation.setPhone(phone);
            reservation.setEmail(email);

            User user = (User) request.getSession().getAttribute("user");
            if (user != null) {
                reservation.setCustomerId(user.getUserId());
                reservation.setCreatedBy(user.getUserId());
            }

            reservation.setConfirmationCode(generateConfirmationCode());

            ReservationDAO dao = new ReservationDAO();

            // TODO: logic chọn bàn phù hợp theo partySize, set reservation.setTableId(...)

            if (dao.create(reservation)) {
                request.setAttribute("reservation", reservation);

                // nếu đã đăng nhập → load các đặt bàn khác
                if (user != null) {
                    List<Reservation> reservations =
                            dao.findByCustomerId(user.getUserId());
                    reservations.removeIf(r ->
                            r.getConfirmationCode().equals(reservation.getConfirmationCode()));
                    request.setAttribute("reservations", reservations);
                }

                // Gửi email
                try {
                    EmailServices emailService = new EmailServices(getServletContext());
                    emailService.sendReservationConfirmation(
                            reservation.getEmail(),
                            reservation.getConfirmationCode(),
                            reservation.getCustomerName(),
                            reservation.getReservationDate().toString(),
                            reservation.getReservationTime().toString(),
                            reservation.getPartySize(),
                            reservation.getTableId() == null
                                    ? "Chưa gán bàn"
                                    : reservation.getTableId().toString()
                    );
                } catch (MessagingException e) {
                    System.out.println("Không thể gửi email xác nhận tới: " + reservation.getEmail());
                    e.printStackTrace();
                }

                request.getRequestDispatcher("/views/guest/confirmation.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Không thể đặt bàn. Vui lòng thử lại sau.");
                showBookingForm(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            showBookingForm(request, response);
        }
    }

    // ========= HỦY – SỬA – CẬP NHẬT (giữ nguyên logic của bạn, chỉ gọn lại chút) =========

    private void handleCancelReservation(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            ReservationDAO dao = new ReservationDAO();
            Reservation reservation = dao.findById(reservationId);

            if (reservation == null) {
                request.getSession().setAttribute("errorMessage", "Không tìm thấy đặt bàn.");
                response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
                return;
            }

            User user = (User) request.getSession().getAttribute("user");
            if (user == null ||
                (reservation.getCustomerId() != null &&
                 !reservation.getCustomerId().equals(user.getUserId()))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            if (dao.updateStatus(reservationId, "CANCELLED")) {
                request.getSession().setAttribute("successMessage", "Hủy đặt bàn thành công.");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể hủy đặt bàn.");
            }

        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
    }

    private void handleEditReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            ReservationDAO dao = new ReservationDAO();
            Reservation reservation = dao.findById(reservationId);

            if (reservation == null) {
                request.getSession().setAttribute("errorMessage", "Không tìm thấy đặt bàn.");
                response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
                return;
            }

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
            request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
        }
    }

    private void handleUpdateReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int reservationId = Integer.parseInt(request.getParameter("reservation_id"));
            ReservationDAO dao = new ReservationDAO();
            Reservation existing = dao.findById(reservationId);

            if (existing == null) {
                request.getSession().setAttribute("errorMessage", "Không tìm thấy đặt bàn.");
                response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
                return;
            }

            User user = (User) request.getSession().getAttribute("user");
            if (user == null ||
                (existing.getCustomerId() != null &&
                 !existing.getCustomerId().equals(user.getUserId()))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            Reservation updated = new Reservation();
            updated.setReservationId(reservationId);
            updated.setPartySize(Integer.parseInt(request.getParameter("party_size")));
            updated.setReservationDate(Date.valueOf(request.getParameter("reservation_date")));
            updated.setReservationTime(Time.valueOf(request.getParameter("reservation_time")));
            updated.setSpecialRequests(request.getParameter("special_requests"));
            updated.setCustomerName(request.getParameter("customer_name"));
            updated.setPhone(request.getParameter("phone"));
            updated.setEmail(request.getParameter("email"));
            updated.setStatus(existing.getStatus());
            updated.setChannel(existing.getChannel());
            updated.setCreatedBy(existing.getCreatedBy());
            updated.setConfirmationCode(existing.getConfirmationCode());
            updated.setTableId(existing.getTableId());
            updated.setCustomerId(existing.getCustomerId());

            if (dao.update(updated)) {
                request.setAttribute("reservation", updated);
                request.setAttribute("successMessage", "Cập nhật đặt bàn thành công!");
                request.getRequestDispatcher("/views/guest/confirmation.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Không thể cập nhật đặt bàn.");
                request.setAttribute("reservation", existing);
                request.getRequestDispatcher("/views/guest/edit-reservation.jsp").forward(request, response);
            }

        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/guest/my-reservations.jsp");
        }
    }

    // ========= ROUTER CHÍNH =========

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // có thể null

        if (pathInfo == null || "/".equals(pathInfo)) {
            // /reservation → form đặt bàn
            showBookingForm(request, response);
            return;
        }

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
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        processRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        processRequest(req, resp);
    }
}
