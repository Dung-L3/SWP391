package Controller;

import Dal.RevenueReportDAO;
import Dal.DBConnect;
import Models.RevenueReport;
import Models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "RevenueReportServlet", urlPatterns = {"/revenue-report", "/revenue"})
public class RevenueReportServlet extends HttpServlet {

    private RevenueReportDAO revenueDAO = new RevenueReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // Check permission (chỉ Manager mới xem được báo cáo)
        if (!hasReportPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền xem báo cáo doanh thu.");
            request.getRequestDispatcher("/views/Error.jsp").forward(request, response);
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "summary";
        }

        switch (action) {
            case "summary":
                handleSummary(request, response);
                break;
            case "by-date":
                handleByDate(request, response);
                break;
            case "by-shift":
                handleByShift(request, response);
                break;
            case "by-staff":
                handleByStaff(request, response);
                break;
            case "by-channel":
                handleByChannel(request, response);
                break;
            default:
                handleSummary(request, response);
        }
    }

    private void handleSummary(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Default: hôm nay
        LocalDate today = LocalDate.now();
        LocalDate fromDate = today;
        LocalDate toDate = today;

        String fromDateParam = request.getParameter("fromDate");
        String toDateParam = request.getParameter("toDate");
        String staffIdParam = request.getParameter("staffId");
        String paymentMethod = request.getParameter("paymentMethod");
        String orderType = request.getParameter("orderType");

        if (fromDateParam != null && !fromDateParam.isEmpty()) {
            try {
                fromDate = LocalDate.parse(fromDateParam);
            } catch (Exception e) {
                // Use default
            }
        }

        if (toDateParam != null && !toDateParam.isEmpty()) {
            try {
                toDate = LocalDate.parse(toDateParam);
            } catch (Exception e) {
                // Use default
            }
        }

        Integer staffId = null;
        if (staffIdParam != null && !staffIdParam.isEmpty()) {
            try {
                staffId = Integer.parseInt(staffIdParam);
            } catch (Exception e) {
                // Ignore
            }
        }

        // Debug: Kiểm tra dữ liệu thực tế trong DB
        revenueDAO.debugDataCheck(fromDate, toDate);
        
        RevenueReport summary = revenueDAO.getRevenueSummary(fromDate, toDate, staffId, paymentMethod, orderType);

        // Get staff list for filter
        List<User> staffList = getStaffList();
        
        // Get shifts for filter
        List<RevenueReport> shifts = revenueDAO.getShiftsInRange(fromDate, toDate);

        request.setAttribute("summary", summary);
        request.setAttribute("staffList", staffList);
        request.setAttribute("shifts", shifts);
        request.setAttribute("fromDate", fromDate != null ? fromDate.toString() : "");
        request.setAttribute("toDate", toDate != null ? toDate.toString() : "");
        request.setAttribute("selectedStaffId", staffId);
        request.setAttribute("selectedPaymentMethod", paymentMethod);
        request.setAttribute("selectedOrderType", orderType);
        request.setAttribute("page", "revenue-report");

        request.getRequestDispatcher("/views/RevenueReport.jsp").forward(request, response);
    }

    private void handleByDate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LocalDate date = LocalDate.now();
        String dateParam = request.getParameter("date");
        if (dateParam != null && !dateParam.isEmpty()) {
            try {
                date = LocalDate.parse(dateParam);
            } catch (Exception e) {
                // Use default
            }
        }

        RevenueReport report = revenueDAO.getRevenueByDate(date);

        request.setAttribute("report", report);
        request.setAttribute("reportDate", date != null ? date.toString() : "");
        request.setAttribute("page", "revenue-report");

        request.getRequestDispatcher("/views/RevenueReport.jsp").forward(request, response);
    }

    private void handleByShift(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String shiftIdParam = request.getParameter("shiftId");
        if (shiftIdParam == null || shiftIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/revenue-report");
            return;
        }

        try {
            int shiftId = Integer.parseInt(shiftIdParam);
            RevenueReport report = revenueDAO.getRevenueByShift(shiftId);

            request.setAttribute("report", report);
            request.setAttribute("page", "revenue-report");

            request.getRequestDispatcher("/views/RevenueReport.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/revenue-report");
        }
    }

    private void handleByStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LocalDate fromDate = LocalDate.now().minusDays(7);
        LocalDate toDate = LocalDate.now();

        String fromDateParam = request.getParameter("fromDate");
        String toDateParam = request.getParameter("toDate");
        String staffIdParam = request.getParameter("staffId");

        if (fromDateParam != null && !fromDateParam.isEmpty()) {
            try {
                fromDate = LocalDate.parse(fromDateParam);
            } catch (Exception e) {
                // Use default
            }
        }

        if (toDateParam != null && !toDateParam.isEmpty()) {
            try {
                toDate = LocalDate.parse(toDateParam);
            } catch (Exception e) {
                // Use default
            }
        }

        Integer staffId = null;
        if (staffIdParam != null && !staffIdParam.isEmpty()) {
            try {
                staffId = Integer.parseInt(staffIdParam);
            } catch (Exception e) {
                // Ignore
            }
        }

        List<RevenueReport> reports = revenueDAO.getRevenueByStaff(fromDate, toDate, staffId);
        List<User> staffList = getStaffList();

        request.setAttribute("reports", reports);
        request.setAttribute("staffList", staffList);
        request.setAttribute("fromDate", fromDate != null ? fromDate.toString() : "");
        request.setAttribute("toDate", toDate != null ? toDate.toString() : "");
        request.setAttribute("selectedStaffId", staffId);
        request.setAttribute("page", "revenue-report");

        request.getRequestDispatcher("/views/RevenueReport.jsp").forward(request, response);
    }

    private void handleByChannel(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LocalDate fromDate = LocalDate.now().minusDays(7);
        LocalDate toDate = LocalDate.now();

        String fromDateParam = request.getParameter("fromDate");
        String toDateParam = request.getParameter("toDate");
        String paymentMethod = request.getParameter("paymentMethod");

        if (fromDateParam != null && !fromDateParam.isEmpty()) {
            try {
                fromDate = LocalDate.parse(fromDateParam);
            } catch (Exception e) {
                // Use default
            }
        }

        if (toDateParam != null && !toDateParam.isEmpty()) {
            try {
                toDate = LocalDate.parse(toDateParam);
            } catch (Exception e) {
                // Use default
            }
        }

        List<RevenueReport> reports = revenueDAO.getRevenueByChannel(fromDate, toDate, paymentMethod);

        request.setAttribute("reports", reports);
        request.setAttribute("fromDate", fromDate != null ? fromDate.toString() : "");
        request.setAttribute("toDate", toDate != null ? toDate.toString() : "");
        request.setAttribute("selectedPaymentMethod", paymentMethod);
        request.setAttribute("page", "revenue-report");

        request.getRequestDispatcher("/views/RevenueReport.jsp").forward(request, response);
    }

    private List<User> getStaffList() {
        List<User> staffList = new ArrayList<>();
        String sql = """
            SELECT DISTINCT u.user_id, u.first_name, u.last_name, u.email, u.phone, 
                   u.account_status, r.role_name
            FROM users u
            INNER JOIN user_roles ur ON u.user_id = ur.user_id
            INNER JOIN roles r ON ur.role_id = r.role_id
            WHERE r.role_name IN ('Waiter', 'Staff', 'Manager')
                AND u.account_status = 'ACTIVE'
            ORDER BY u.first_name, u.last_name
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setFirstName(rs.getString("first_name"));
                user.setLastName(rs.getString("last_name"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone"));
                user.setAccountStatus(rs.getString("account_status"));
                user.setRoleName(rs.getString("role_name"));
                staffList.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return staffList;
    }

    private boolean hasReportPermission(User user) {
        if (user == null) return false;
        String roleName = user.getRoleName();
        return "Manager".equals(roleName) || "Admin".equals(roleName);
    }
}

