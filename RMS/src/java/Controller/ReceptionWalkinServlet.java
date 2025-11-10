package Controller;

import Dal.ReservationDAO;
import Dal.TableDAO;
import Dal.CustomerDAO;
import Models.Reservation;
import Models.Customer;
import Models.DiningTable;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.RequestDispatcher;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;

import Controller.auth.EmailServices;
import javax.mail.MessagingException;

/**
 * Handle walk-in bookings created by receptionist at counter.
 */
@WebServlet(urlPatterns = {"/reception/walkin-booking"})
public class ReceptionWalkinServlet extends HttpServlet {

    // Hiển thị form nhận đặt bàn (quầy)
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

        request.setAttribute("page", "reception-walkin");
        RequestDispatcher rd = request.getRequestDispatcher("/views/reception-walkin.jsp");
        rd.forward(request, response);
    }

    // Xử lý submit form đặt bàn (quầy)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String tableNumber      = request.getParameter("tableNumber");
        String customerName     = request.getParameter("customerName");
        String phone            = request.getParameter("phone");
        String email            = request.getParameter("email");
        String partySizeStr     = request.getParameter("partySize");
        String specialRequests  = request.getParameter("specialRequests");

        try {
            int partySize = 1;
            try {
                partySize = Integer.parseInt(partySizeStr);
            } catch (Exception ignore) {
            }

            TableDAO tableDAO = new TableDAO();
            DiningTable table = tableDAO.getTableByNumber(tableNumber);
            if (table == null) {
                request.setAttribute("errorMessage", "Bàn không tồn tại: " + tableNumber);
                forwardBack(request, response);
                return;
            }

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
                    res.setReservationTime(Time.valueOf(timeParam));
                } catch (Exception ex) {
                    res.setReservationTime(Time.valueOf(LocalTime.now().withSecond(0).withNano(0)));
                }
            } else {
                res.setReservationTime(Time.valueOf(LocalTime.now().withSecond(0).withNano(0)));
            }

            String confirmation = "RMS" + Long.toString(System.currentTimeMillis()).substring(8);
            res.setConfirmationCode(confirmation);
            res.setTableId(table.getTableId());
            res.setStatus("PENDING");
            res.setChannel("WALKIN");

            try {
                Object user = session.getAttribute("user");
                java.lang.reflect.Method m = user.getClass().getMethod("getUserId");
                Object idObj = m.invoke(user);
                if (idObj instanceof Integer) {
                    res.setCreatedBy((Integer) idObj);
                }
            } catch (Exception ignore) {
            }

            ReservationDAO reservationDAO = new ReservationDAO();

            if (table.getCapacity() > 0 && res.getPartySize() > table.getCapacity()) {
                request.setAttribute("errorMessage",
                        "Số người vượt quá sức chứa của bàn (" + table.getCapacity() + ")");
                forwardBack(request, response);
                return;
            }

            try {
                LocalDate rDate = res.getReservationDate().toLocalDate();
                LocalTime rTime = res.getReservationTime().toLocalTime();
                LocalDate today = LocalDate.now();

                if (rDate.isBefore(today)) {
                    request.setAttribute("errorMessage", "Ngày đặt phải là hôm nay hoặc tương lai.");
                    forwardBack(request, response);
                    return;
                }
                if (rDate.equals(today)) {
                    LocalTime minTime = LocalTime.now().plusHours(2).withSecond(0).withNano(0);
                    if (rTime.isBefore(minTime)) {
                        request.setAttribute("errorMessage", "Giờ đặt phải cách hiện tại ít nhất 2 giờ.");
                        forwardBack(request, response);
                        return;
                    }
                }
            } catch (Exception ignore) {
            }

            boolean ok = reservationDAO.create(res);
            if (ok) {
                try {
                    String smtpHost = request.getServletContext().getInitParameter("smtp.host");
                    String smtpPort = request.getServletContext().getInitParameter("smtp.port");
                    String smtpUser = request.getServletContext().getInitParameter("smtp.username");
                    String smtpPass = request.getServletContext().getInitParameter("smtp.password");

                    if (smtpHost != null && smtpUser != null && smtpPass != null
                            && email != null && !email.isEmpty()) {

                        try {
                            EmailServices es = new EmailServices(request.getServletContext());
                            String dateStr = res.getReservationDate() != null
                                    ? res.getReservationDate().toString() : "";
                            String timeStr = res.getReservationTime() != null
                                    ? res.getReservationTime().toString() : "";
                            es.sendReservationConfirmation(
                                    email,
                                    confirmation,
                                    customerName != null ? customerName : "",
                                    dateStr,
                                    timeStr,
                                    res.getPartySize(),
                                    tableNumber
                            );
                        } catch (MessagingException me) {
                            me.printStackTrace();
                        }
                    }
                } catch (Exception mailEx) {
                    mailEx.printStackTrace();
                }

                session.setAttribute("successMessage",
                        "Đặt bàn thành công cho bàn " + tableNumber);
                response.sendRedirect(request.getContextPath() + "/reception/walkin-booking");
            } else {
                request.setAttribute("errorMessage", "Không thể tạo đặt bàn.");
                forwardBack(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi khi tạo đặt bàn: " + e.getMessage());
            forwardBack(request, response);
        }
    }

    private void forwardBack(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("page", "reception-walkin");
        request.getRequestDispatcher("/views/reception-walkin.jsp").forward(request, response);
    }
}
