package Controller;

import Dal.ReservationDAO;
import Dal.TableDAO;
import Dal.CustomerDAO;
import Models.Reservation;
import Models.Customer;
import Models.DiningTable;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import Controller.auth.EmailServices;
import javax.mail.MessagingException;
import java.time.LocalDate;
import java.time.LocalTime;

/**
 * Handle walk-in bookings created by receptionist at counter.
 */
@WebServlet(urlPatterns = {"/reception/walkin-booking"})
public class ReceptionWalkinServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String tableNumber = request.getParameter("tableNumber");
        String customerName = request.getParameter("customerName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String partySizeStr = request.getParameter("partySize");
        String specialRequests = request.getParameter("specialRequests");

        try {
            int partySize = 1;
            try { partySize = Integer.parseInt(partySizeStr); } catch (Exception e) {}

            TableDAO tableDAO = new TableDAO();
            DiningTable table = tableDAO.getTableByNumber(tableNumber);
            if (table == null) {
                request.setAttribute("errorMessage", "Bàn không tồn tại: " + tableNumber);
                request.getRequestDispatcher("/views/reception-walkin.jsp").forward(request, response);
                return;
            }

            // Build reservation (use submitted date/time if provided)
            Reservation res = new Reservation();
            res.setCustomerName(customerName);
            res.setPhone(phone);
            res.setEmail(email);
            res.setPartySize(partySize);
            res.setSpecialRequests(specialRequests);
            String dateParam = request.getParameter("reservation_date");
            String timeParam = request.getParameter("reservation_time");
            if (dateParam != null && !dateParam.isEmpty()) {
                try {
                    res.setReservationDate(Date.valueOf(dateParam));
                } catch (Exception ex) {
                    res.setReservationDate(Date.valueOf(LocalDate.now()));
                }
            } else {
                res.setReservationDate(Date.valueOf(LocalDate.now()));
            }
            if (timeParam != null && !timeParam.isEmpty()) {
                try {
                    // expected format HH:MM:SS
                    res.setReservationTime(Time.valueOf(timeParam));
                } catch (Exception ex) {
                    res.setReservationTime(Time.valueOf(LocalTime.now().withSecond(0).withNano(0)));
                }
            } else {
                res.setReservationTime(Time.valueOf(LocalTime.now().withSecond(0).withNano(0)));
            }
            // generate a confirmation code for this reservation
            String confirmation = "RMS" + Long.toString(System.currentTimeMillis()).substring(8);
            res.setConfirmationCode(confirmation);
            res.setTableId(table.getTableId());
            res.setStatus("PENDING");
            res.setChannel("WALKIN");
            // created_by: try to get logged in user id if available
            try {
                Object user = session.getAttribute("user");
                java.lang.reflect.Method m = user.getClass().getMethod("getUserId");
                Object idObj = m.invoke(user);
                if (idObj instanceof Integer) res.setCreatedBy((Integer) idObj);
            } catch (Exception ignore) {}

            ReservationDAO reservationDAO = new ReservationDAO();
            // server-side validation: party size must not exceed table capacity
            if (table.getCapacity() > 0 && res.getPartySize() > table.getCapacity()) {
                request.setAttribute("errorMessage", "Số người vượt quá sức chứa của bàn (" + table.getCapacity() + ")");
                request.getRequestDispatcher("/views/reception-walkin.jsp").forward(request, response);
                return;
            }

            // server-side validation: date >= today, and if date == today then time >= now + 2 hours
            try {
                java.time.LocalDate rDate = res.getReservationDate().toLocalDate();
                java.time.LocalTime rTime = res.getReservationTime().toLocalTime();
                java.time.LocalDate today = java.time.LocalDate.now();
                if (rDate.isBefore(today)) {
                    request.setAttribute("errorMessage", "Ngày đặt phải là hôm nay hoặc tương lai.");
                    request.getRequestDispatcher("/views/reception-walkin.jsp").forward(request, response);
                    return;
                }
                if (rDate.equals(today)) {
                    java.time.LocalTime minTime = java.time.LocalTime.now().plusHours(2).withSecond(0).withNano(0);
                    if (rTime.isBefore(minTime)) {
                        request.setAttribute("errorMessage", "Giờ đặt phải cách hiện tại ít nhất 2 giờ.");
                        request.getRequestDispatcher("/views/reception-walkin.jsp").forward(request, response);
                        return;
                    }
                }
            } catch (Exception ex) {
                // ignore parse errors here and let DAO/db handle if necessary
            }

            boolean ok = reservationDAO.create(res);
            if (ok) {
                // try to send confirmation email (best-effort)
                try {
                    String smtpHost = request.getServletContext().getInitParameter("smtp.host");
                    String smtpPort = request.getServletContext().getInitParameter("smtp.port");
                    String smtpUser = request.getServletContext().getInitParameter("smtp.username");
                    String smtpPass = request.getServletContext().getInitParameter("smtp.password");
                    String smtpFrom = request.getServletContext().getInitParameter("smtp.from");
                    if (smtpHost != null && smtpUser != null && smtpPass != null && email != null && !email.isEmpty()) {
                        java.util.Properties props = new java.util.Properties();
                        props.put("mail.smtp.auth", "true");
                        props.put("mail.smtp.starttls.enable", "true");
                        props.put("mail.smtp.host", smtpHost);
                        props.put("mail.smtp.port", smtpPort != null ? smtpPort : "587");

                        StringBuilder body = new StringBuilder();
                        body.append("Xin chào ").append(customerName != null ? customerName : "khách hàng").append(",\n\n");
                        body.append("Đặt bàn của bạn đã được tiếp nhận. Chi tiết: \n");
                        body.append("Mã xác nhận: ").append(confirmation).append("\n");
                        body.append("Bàn: ").append(tableNumber).append("\n");
                        body.append("Ngày: ").append(res.getReservationDate()).append("\n");
                        body.append("Giờ: ").append(res.getReservationTime()).append("\n");
                        body.append("Số người: ").append(res.getPartySize()).append("\n");
                        if (res.getSpecialRequests() != null && !res.getSpecialRequests().isEmpty()) {
                            body.append("Yêu cầu: ").append(res.getSpecialRequests()).append("\n");
                        }
                        body.append("\nHẹn gặp bạn tại nhà hàng!\n");

                        // use existing EmailServices helper (centralized email templates & SMTP handling)
                        try {
                            EmailServices es = new EmailServices(request.getServletContext());
                            String dateStr = res.getReservationDate() != null ? res.getReservationDate().toString() : "";
                            String timeStr = res.getReservationTime() != null ? res.getReservationTime().toString() : "";
                            es.sendReservationConfirmation(email, confirmation, customerName != null ? customerName : "", dateStr, timeStr, res.getPartySize(), tableNumber);
                        } catch (MessagingException me) {
                            // log and continue (email best-effort)
                            me.printStackTrace();
                        }
                    }
                } catch (Exception mailEx) {
                    mailEx.printStackTrace();
                }

                request.getSession().setAttribute("successMessage", "Đặt bàn thành công cho bàn " + tableNumber);
                response.sendRedirect(request.getContextPath() + "/views/reception-walkin.jsp");
            } else {
                request.setAttribute("errorMessage", "Không thể tạo đặt bàn.");
                request.getRequestDispatcher("/views/reception-walkin.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi khi tạo đặt bàn: " + e.getMessage());
            request.getRequestDispatcher("/views/reception-walkin.jsp").forward(request, response);
        }
    }
}
