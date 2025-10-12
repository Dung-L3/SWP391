package Controller.booking;

import Dal.UserDAO;
import Dal.TableAreaDAO;
import Models.User;
import Models.TableArea;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Time;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import Dal.BookingDAO;
import Models.Reservation;

@WebServlet(name = "BookingServlet", urlPatterns = {"/BookingServlet"})
public class BookingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to booking page with necessary data
        request.getRequestDispatcher("booking.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get form data
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String dateStr = request.getParameter("date");
            String timeStr = request.getParameter("time");
            int guests = Integer.parseInt(request.getParameter("guests"));
            int tableId = Integer.parseInt(request.getParameter("tableId"));
            String specialRequests = request.getParameter("specialRequests");

            // Convert string to Date and Time
            Date reservationDate = Date.valueOf(dateStr);
            Time reservationTime = Time.valueOf(timeStr + ":00");

            // Get current user if logged in
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            // Create reservation
            Reservation reservation = new Reservation();
            reservation.setFullName(fullName);
            reservation.setEmail(email);
            reservation.setPhone(phone);
            reservation.setReservationDate(reservationDate);
            reservation.setReservationTime(reservationTime);
            reservation.setPartySize(guests);
            reservation.setTableId(tableId);
            reservation.setSpecialRequests(specialRequests);
            reservation.setStatus("PENDING");
            
            if (currentUser != null) {
                reservation.setUserId(currentUser.getUserId());
            }

            // Save reservation
            BookingDAO bookingDAO = new BookingDAO();
            boolean success = bookingDAO.createReservation(reservation);

            if (success) {
                // Send confirmation email
                String confirmationCode = generateConfirmationCode();
                sendConfirmationEmail(email, confirmationCode, reservation);
                
                // Set success message and redirect
                session.setAttribute("bookingMessage", "Đặt bàn thành công! Vui lòng kiểm tra email để xác nhận.");
                response.sendRedirect("booking.jsp");
            } else {
                // Set error message and redirect back
                session.setAttribute("bookingError", "Không thể đặt bàn. Vui lòng thử lại.");
                response.sendRedirect("booking.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("bookingError", "Đã xảy ra lỗi. Vui lòng thử lại sau.");
            response.sendRedirect("booking.jsp");
        }
    }

    private String generateConfirmationCode() {
        // Generate a random confirmation code
        return "RES" + System.currentTimeMillis() % 100000;
    }

    private void sendConfirmationEmail(String email, String confirmationCode, Reservation reservation) {
        // TODO: Implement email sending
        // You can use the existing EmailServices class
    }
}