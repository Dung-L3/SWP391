package Controller;

import Dal.ReservationDAO;
import Dal.TableDAO;
import Models.Reservation;
import Models.DiningTable;
import Controller.auth.EmailServices;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import javax.mail.MessagingException;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CancelReservationServlet", urlPatterns = {"/cancel-reservation", "/view-reservation"})
public class CancelReservationServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String confirmationCode = request.getParameter("code");
        String email = request.getParameter("email");
        
        if (confirmationCode == null || email == null) {
            response.sendRedirect(request.getContextPath() + "/views/guest/cancel-reservation.jsp");
            return;
        }
        
        try {
            ReservationDAO reservationDAO = new ReservationDAO();
            Reservation reservation = reservationDAO.getReservationByConfirmationCode(confirmationCode);
            
            if (reservation == null || reservation.getEmail() == null || !reservation.getEmail().equalsIgnoreCase(email)) {
                request.setAttribute("errorMessage", "Không tìm thấy thông tin đặt bàn hoặc email không khớp.");
                request.getRequestDispatcher("/views/guest/cancel-reservation.jsp").forward(request, response);
                return;
            }
            
            request.setAttribute("reservation", reservation);
            request.getRequestDispatcher("/views/guest/cancel-reservation.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/guest/cancel-reservation.jsp");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String confirmationCode = request.getParameter("confirmationCode");
        String email = request.getParameter("email");
        
        System.out.println("=== Starting cancellation process ===");
        System.out.println("Confirmation Code: " + confirmationCode);
        System.out.println("Email: " + email);
        
        if (confirmationCode == null || email == null) {
            System.out.println("Error: Missing confirmation code or email");
            response.sendRedirect(request.getContextPath() + "/views/guest/cancel-reservation.jsp");
            return;
        }
        
        try {
            ReservationDAO reservationDAO = new ReservationDAO();
            TableDAO tableDAO = new TableDAO();
            
            Reservation reservation = reservationDAO.getReservationByConfirmationCode(confirmationCode);
            
            if (reservation == null) {
                request.setAttribute("errorMessage", "Không tìm thấy thông tin đặt bàn với mã xác nhận này.");
                request.getRequestDispatcher("/views/guest/cancel-reservation.jsp").forward(request, response);
                return;
            }
            
            // Kiểm tra email nếu có
            if (email != null && !email.trim().isEmpty()) {
                if (reservation.getEmail() == null || !reservation.getEmail().equalsIgnoreCase(email.trim())) {
                    request.setAttribute("errorMessage", "Email không khớp với thông tin đặt bàn.");
                    request.getRequestDispatcher("/views/guest/cancel-reservation.jsp").forward(request, response);
                    return;
                }
            }
            
            if ("CANCELLED".equals(reservation.getStatus())) {
                request.setAttribute("errorMessage", "Đơn đặt bàn này đã được hủy trước đó.");
                request.getRequestDispatcher("/views/guest/cancel-reservation.jsp").forward(request, response);
                return;
            }
            
            // Cập nhật trạng thái đặt bàn thành CANCELLED
            reservation.setStatus("CANCELLED");
            reservationDAO.update(reservation);
            
            // Cập nhật trạng thái bàn thành VACANT
            DiningTable table = tableDAO.getTableById(reservation.getTableId());
            if (table != null) {
                tableDAO.updateTableStatus(table.getTableNumber(), "VACANT");
            }
            
            // Đặt thông báo thành công
            request.getSession().setAttribute("successMessage", "Bạn đã hủy bàn thành công");
            
            // Gửi email xác nhận hủy đặt bàn
            try {
                EmailServices emailService = new EmailServices(getServletContext());
                emailService.sendReservationCancellation(
                    reservation.getEmail(),
                    reservation.getConfirmationCode(),
                    reservation.getCustomerName(),
                    reservation.getReservationDate().toString(),
                    reservation.getReservationTime().toString(),
                    reservation.getPartySize());
            } catch (Exception e) {
                System.out.println("Warning: Could not send cancellation confirmation email: " + e.getMessage());
            }
            
            // Chuyển hướng về trang thông báo thành công
            request.setAttribute("successMessage", "Đã hủy đặt bàn thành công!");
            request.setAttribute("reservation", reservation);
            request.getRequestDispatcher("/views/guest/cancel-reservation.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra khi hủy đặt bàn. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/views/guest/cancel-reservation.jsp").forward(request, response);
        }
    }
}