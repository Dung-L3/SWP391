package Controller;

import Dal.ReservationDAO;
import Dal.TableDAO;
import Models.Reservation;
import Models.Table;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@WebServlet(urlPatterns = {"/confirm-booking"})
public class ConfirmBookingServlet extends HttpServlet {

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

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("\n=== Starting booking confirmation process ===");
        System.out.println("Request Method: " + request.getMethod());
        System.out.println("Request URI: " + request.getRequestURI());

        HttpSession session = request.getSession(false);
        if (session == null) {
            System.out.println("Error: No session found");
            request.setAttribute("errorMessage", "Phiên làm việc đã hết hạn. Vui lòng thử lại.");
            request.getRequestDispatcher("/views/guest/booking.jsp").forward(request, response);
            return;
        }

        System.out.println("\n=== Session Data ===");
        java.util.Enumeration<String> attributeNames = session.getAttributeNames();
        while (attributeNames.hasMoreElements()) {
            String name = attributeNames.nextElement();
            Object value = session.getAttribute(name);
            System.out.println(name + ": " + (value != null ? value.toString() : "null"));
        }

        ReservationDAO reservationDAO = null;
        TableDAO tableDAO = null;
        List<Reservation> reservations = new ArrayList<>();
        List<Table> tables = new ArrayList<>();

        try {
            reservationDAO = new ReservationDAO();
            tableDAO = new TableDAO();

            if (session.getAttribute("bookingInProgress") == null) {
                System.out.println("Error: No booking in progress");
                response.sendRedirect(request.getContextPath() + "/views/guest/booking.jsp");
                return;
            }

            // Debug form data
            System.out.println("\n=== Form Data ===");
            java.util.Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String name = paramNames.nextElement();
                String[] values = request.getParameterValues(name);
                System.out.println(name + ": " + String.join(", ", values));
            }

            // Lấy thông tin đặt bàn
            String customerName = (String) session.getAttribute("customerName");
            if (customerName == null || customerName.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng nhập tên khách hàng");
            }

            String phoneNumber = (String) session.getAttribute("phone");
            if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng nhập số điện thoại");
            }
            phoneNumber = phoneNumber.replaceAll("[^0-9]", "");
            if (phoneNumber.length() != 10) {
                throw new IllegalArgumentException("Số điện thoại không hợp lệ. Vui lòng nhập đủ 10 số.");
            }

            String email = (String) session.getAttribute("email");
            String dateStr = (String) session.getAttribute("reservationDate");
            String timeStr = (String) session.getAttribute("reservationTime");
            String specialRequests = (String) session.getAttribute("specialRequests");

            int numOfPeople;
            try {
                numOfPeople = Integer.parseInt((String) session.getAttribute("partySize"));
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Số người không hợp lệ");
            }

            String[] selectedTables = request.getParameterValues("selectedTables");
            if (selectedTables == null || selectedTables.length == 0) {
                throw new IllegalArgumentException("Vui lòng chọn ít nhất một bàn.");
            }

            // Kiểm tra bàn
            int totalCapacity = 0;
            for (String tableNumber : selectedTables) {
                Table table = tableDAO.getTableByNumber(tableNumber);
                if (table == null) {
                    throw new IllegalStateException("Bàn " + tableNumber + " không tồn tại.");
                }
                if (!Table.STATUS_VACANT.equals(table.getStatus())) {
                    throw new IllegalStateException("Bàn " + tableNumber + " đã được đặt.");
                }
                totalCapacity += table.getCapacity();
                tables.add(table);
            }

            if (totalCapacity < numOfPeople) {
                throw new IllegalArgumentException("Tổng số chỗ ngồi không đủ cho số người đặt.");
            }

            // Format ngày và giờ
            Date reservationDate = Date.valueOf(dateStr);
            String formattedTime = timeStr;
            if (!formattedTime.matches("\\d{2}:\\d{2}(:\\d{2})?")) {
                throw new IllegalArgumentException("Định dạng thời gian không hợp lệ. Vui lòng nhập theo định dạng HH:mm hoặc HH:mm:ss");
            }
            if (!formattedTime.contains(":")) {
                formattedTime += ":00";
            }
            if (formattedTime.split(":").length == 2) {
                formattedTime += ":00";
            }
            Time reservationTime = Time.valueOf(formattedTime);

            String confirmationCode = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            boolean success = true;
            String errorMessage = null;

            for (Table table : tables) {
                Table currentTable = tableDAO.getTableByNumber(table.getTableNumber());
                if (!Table.STATUS_VACANT.equals(currentTable.getStatus())) {
                    success = false;
                    errorMessage = "Bàn " + table.getTableNumber() + " đã được đặt bởi người khác.";
                    break;
                }

                Reservation reservation = new Reservation();
                reservation.setTableId(table.getTableId());
                reservation.setCustomerName(customerName);
                reservation.setPhone(phoneNumber);
                reservation.setEmail(email);
                reservation.setReservationDate(reservationDate);
                reservation.setReservationTime(reservationTime);
                reservation.setPartySize(numOfPeople);
                reservation.setStatus("PENDING");
                reservation.setChannel("WEB");
                reservation.setSpecialRequests(specialRequests);
                reservation.setConfirmationCode(confirmationCode);
                reservation.setDepositAmount(0.0);
                reservation.setDepositStatus("PENDING");

                if (!reservationDAO.create(reservation)) {
                    success = false;
                    errorMessage = "Không thể tạo đơn đặt bàn cho bàn " + table.getTableNumber();
                    break;
                }

                reservations.add(reservation);
                tableDAO.updateTableStatus(table.getTableNumber(), Table.STATUS_RESERVED);
            }

            if (success) {
                session.removeAttribute("bookingInProgress");
                session.removeAttribute("customerName");
                session.removeAttribute("phone");
                session.removeAttribute("email");
                session.removeAttribute("reservationDate");
                session.removeAttribute("reservationTime");
                session.removeAttribute("specialRequests");
                session.removeAttribute("partySize");

                session.setAttribute("successMessage", "Đặt bàn thành công! Mã đặt bàn của bạn là: " + confirmationCode);
                session.setAttribute("reservation", reservations.get(0));
                response.sendRedirect(request.getContextPath() + "/views/guest/confirmation.jsp");
            } else {
                throw new IllegalStateException(errorMessage);
            }

        } catch (IllegalArgumentException e) {
            System.out.println("\nValidation error: " + e.getMessage());
            session.setAttribute("errorMessage", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/guest/confirmation.jsp");

        } catch (IllegalStateException e) {
            System.out.println("\nTable state error: " + e.getMessage());
            session.setAttribute("errorMessage", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/guest/table-layout.jsp");

        } catch (Exception e) {
            System.out.println("\n=== ERROR DETAILS ===");
            e.printStackTrace();

            if (reservationDAO != null && !reservations.isEmpty()) {
                for (Reservation r : reservations) {
                    try {
                        reservationDAO.delete(r.getReservationId());
                    } catch (Exception ex) {
                        System.out.println("Error deleting reservation: " + ex.getMessage());
                    }
                }
            }

            if (tableDAO != null && !tables.isEmpty()) {
                for (Table t : tables) {
                    try {
                        tableDAO.updateTableStatus(t.getTableNumber(), Table.STATUS_VACANT);
                    } catch (Exception ex) {
                        System.out.println("Error resetting table: " + ex.getMessage());
                    }
                }
            }

            String errorMsg = "Có lỗi xảy ra. Vui lòng thử lại sau.";
            request.setAttribute("errorMessage", errorMsg);
            request.getRequestDispatcher("/views/guest/confirmation.jsp").forward(request, response);

        } finally {
            System.out.println("=== Booking process completed ===\n");
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles the confirmation of table booking requests";
    }
}
