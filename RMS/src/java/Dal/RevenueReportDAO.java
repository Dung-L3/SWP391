package Dal;

import Models.RevenueReport;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * RevenueReportDAO - DAO cho báo cáo doanh thu
 * 
 * Liên kết:
 * - orders -> bills -> payments (doanh thu từ payments với status = SUCCESS)
 * - orders.waiter_id -> users.user_id (nhân viên)
 * - orders.opened_at + shift_schedule (ca làm việc)
 * - payments.method (kênh thanh toán: CASH, CARD, ONLINE, TRANSFER, VOUCHER)
 */
public class RevenueReportDAO {

    /**
     * Báo cáo doanh thu theo ngày
     */
    public RevenueReport getRevenueByDate(LocalDate date) {
        RevenueReport report = new RevenueReport();
        report.setReportDate(date);

        String sql = """
            SELECT 
                COUNT(DISTINCT o.order_id) as total_orders,
                COALESCE(SUM(p.amount), 0) as total_revenue,
                COALESCE(SUM(b.subtotal), 0) as total_subtotal,
                COALESCE(SUM(b.tax_amount), 0) as total_tax,
                COALESCE(SUM(b.discount_amount), 0) as total_discount,
                COALESCE(SUM(CASE WHEN p.method = 'CASH' THEN p.amount ELSE 0 END), 0) as cash_revenue,
                COALESCE(SUM(CASE WHEN p.method = 'CARD' THEN p.amount ELSE 0 END), 0) as card_revenue,
                COALESCE(SUM(CASE WHEN p.method = 'ONLINE' THEN p.amount ELSE 0 END), 0) as online_revenue,
                COALESCE(SUM(CASE WHEN p.method = 'TRANSFER' THEN p.amount ELSE 0 END), 0) as transfer_revenue,
                COALESCE(SUM(CASE WHEN p.method = 'VOUCHER' THEN p.amount ELSE 0 END), 0) as voucher_revenue
            FROM orders o
            INNER JOIN bills b ON o.order_id = b.order_id
            INNER JOIN payments p ON b.bill_id = p.bill_id
            WHERE CAST(o.opened_at AS DATE) = ?
                AND o.status = 'SETTLED'
                AND p.status = 'SUCCESS'
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(date));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    report.setTotalOrders(rs.getInt("total_orders"));
                    report.setTotalRevenue(rs.getBigDecimal("total_revenue"));
                    report.setTotalSubtotal(rs.getBigDecimal("total_subtotal"));
                    report.setTotalTax(rs.getBigDecimal("total_tax"));
                    report.setTotalDiscount(rs.getBigDecimal("total_discount"));
                    report.setCashRevenue(rs.getBigDecimal("cash_revenue"));
                    report.setCardRevenue(rs.getBigDecimal("card_revenue"));
                    report.setOnlineRevenue(rs.getBigDecimal("online_revenue"));
                    report.setTransferRevenue(rs.getBigDecimal("transfer_revenue"));
                    report.setVoucherRevenue(rs.getBigDecimal("voucher_revenue"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return report;
    }

    /**
     * Báo cáo doanh thu theo ca (shift)
     */
    public RevenueReport getRevenueByShift(int shiftId) {
        RevenueReport report = new RevenueReport();
        report.setShiftId(shiftId);

        String sql = """
            SELECT 
                sh.shift_id,
                sh.shift_date,
                sh.start_time,
                sh.end_time,
                u.first_name + ' ' + u.last_name as staff_name,
                COUNT(DISTINCT o.order_id) as total_orders,
                COALESCE(SUM(p.amount), 0) as total_revenue,
                COALESCE(SUM(b.subtotal), 0) as total_subtotal,
                COALESCE(SUM(b.tax_amount), 0) as total_tax,
                COALESCE(SUM(b.discount_amount), 0) as total_discount
            FROM shift_schedule sh
            INNER JOIN users u ON sh.staff_id = u.user_id
            INNER JOIN orders o ON o.waiter_id = sh.staff_id
                AND CAST(o.opened_at AS DATE) = sh.shift_date
                AND CAST(o.opened_at AS TIME) >= sh.start_time
                AND CAST(o.opened_at AS TIME) <= sh.end_time
            INNER JOIN bills b ON o.order_id = b.order_id
            INNER JOIN payments p ON b.bill_id = p.bill_id
            WHERE sh.shift_id = ?
                AND o.status = 'SETTLED'
                AND p.status = 'SUCCESS'
            GROUP BY sh.shift_id, sh.shift_date, sh.start_time, sh.end_time, u.first_name, u.last_name
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, shiftId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    report.setReportDate(rs.getDate("shift_date").toLocalDate());
                    report.setShiftName(formatShiftName(rs.getTime("start_time"), rs.getTime("end_time")));
                    report.setStaffName(rs.getString("staff_name"));
                    report.setTotalOrders(rs.getInt("total_orders"));
                    report.setTotalRevenue(rs.getBigDecimal("total_revenue"));
                    report.setTotalSubtotal(rs.getBigDecimal("total_subtotal"));
                    report.setTotalTax(rs.getBigDecimal("total_tax"));
                    report.setTotalDiscount(rs.getBigDecimal("total_discount"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return report;
    }

    /**
     * Báo cáo doanh thu theo nhân viên
     */
    public List<RevenueReport> getRevenueByStaff(LocalDate fromDate, LocalDate toDate, Integer staffId) {
        List<RevenueReport> reports = new ArrayList<>();

        String sql = """
            SELECT 
                o.waiter_id as staff_id,
                u.first_name + ' ' + u.last_name as staff_name,
                COUNT(DISTINCT o.order_id) as total_orders,
                COALESCE(SUM(p.amount), 0) as total_revenue
            FROM orders o
            INNER JOIN users u ON o.waiter_id = u.user_id
            INNER JOIN bills b ON o.order_id = b.order_id
            INNER JOIN payments p ON b.bill_id = p.bill_id
            WHERE CAST(o.opened_at AS DATE) BETWEEN ? AND ?
                AND o.status = 'SETTLED'
                AND p.status = 'SUCCESS'
                AND (? IS NULL OR o.waiter_id = ?)
            GROUP BY o.waiter_id, u.first_name, u.last_name
            ORDER BY total_revenue DESC
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));
            if (staffId != null) {
                ps.setInt(3, staffId);
                ps.setInt(4, staffId);
            } else {
                ps.setNull(3, Types.INTEGER);
                ps.setNull(4, Types.INTEGER);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RevenueReport report = new RevenueReport();
                    report.setStaffId(rs.getInt("staff_id"));
                    report.setStaffName(rs.getString("staff_name"));
                    report.setOrdersByStaff(rs.getInt("total_orders"));
                    report.setRevenueByStaff(rs.getBigDecimal("total_revenue"));
                    reports.add(report);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return reports;
    }

    /**
     * Báo cáo doanh thu theo kênh thanh toán
     */
    public List<RevenueReport> getRevenueByChannel(LocalDate fromDate, LocalDate toDate, String paymentMethod) {
        List<RevenueReport> reports = new ArrayList<>();

        String sql = """
            SELECT 
                p.method as payment_method,
                COUNT(DISTINCT o.order_id) as total_orders,
                COALESCE(SUM(p.amount), 0) as total_revenue
            FROM orders o
            INNER JOIN bills b ON o.order_id = b.order_id
            INNER JOIN payments p ON b.bill_id = p.bill_id
            WHERE CAST(o.opened_at AS DATE) BETWEEN ? AND ?
                AND o.status = 'SETTLED'
                AND p.status = 'SUCCESS'
                AND (? IS NULL OR p.method = ?)
            GROUP BY p.method
            ORDER BY total_revenue DESC
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));
            if (paymentMethod != null && !paymentMethod.isEmpty()) {
                ps.setString(3, paymentMethod);
                ps.setString(4, paymentMethod);
            } else {
                ps.setNull(3, Types.VARCHAR);
                ps.setNull(4, Types.VARCHAR);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RevenueReport report = new RevenueReport();
                    report.setPaymentMethod(rs.getString("payment_method"));
                    report.setOrdersByChannel(rs.getInt("total_orders"));
                    report.setRevenueByChannel(rs.getBigDecimal("total_revenue"));
                    reports.add(report);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return reports;
    }

    /**
     * Báo cáo tổng hợp với nhiều filter
     */
    public RevenueReport getRevenueSummary(LocalDate fromDate, LocalDate toDate, 
                                          Integer staffId, String paymentMethod, String orderType) {
        RevenueReport report = new RevenueReport();

        StringBuilder sql = new StringBuilder("""
            SELECT 
                COUNT(DISTINCT o.order_id) as total_orders,
                COALESCE(SUM(p.amount), 0) as total_revenue,
                COALESCE(SUM(b.subtotal), 0) as total_subtotal,
                COALESCE(SUM(b.tax_amount), 0) as total_tax,
                COALESCE(SUM(b.discount_amount), 0) as total_discount,
                COALESCE(SUM(CASE WHEN p.method = 'CASH' THEN p.amount ELSE 0 END), 0) as cash_revenue,
                COALESCE(SUM(CASE WHEN p.method = 'CARD' THEN p.amount ELSE 0 END), 0) as card_revenue,
                COALESCE(SUM(CASE WHEN p.method = 'ONLINE' THEN p.amount ELSE 0 END), 0) as online_revenue,
                COALESCE(SUM(CASE WHEN p.method = 'TRANSFER' THEN p.amount ELSE 0 END), 0) as transfer_revenue,
                COALESCE(SUM(CASE WHEN p.method = 'VOUCHER' THEN p.amount ELSE 0 END), 0) as voucher_revenue
            FROM orders o
            INNER JOIN bills b ON o.order_id = b.order_id
            INNER JOIN payments p ON b.bill_id = p.bill_id
            WHERE CAST(o.opened_at AS DATE) BETWEEN ? AND ?
                AND o.status = 'SETTLED'
                AND p.status = 'SUCCESS'
        """);

        List<Object> params = new ArrayList<>();
        params.add(Date.valueOf(fromDate));
        params.add(Date.valueOf(toDate));

        if (staffId != null) {
            sql.append(" AND o.waiter_id = ?");
            params.add(staffId);
        }

        if (paymentMethod != null && !paymentMethod.isEmpty()) {
            sql.append(" AND p.method = ?");
            params.add(paymentMethod);
        }

        if (orderType != null && !orderType.isEmpty()) {
            sql.append(" AND o.order_type = ?");
            params.add(orderType);
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    report.setTotalOrders(rs.getInt("total_orders"));
                    report.setTotalRevenue(rs.getBigDecimal("total_revenue"));
                    report.setTotalSubtotal(rs.getBigDecimal("total_subtotal"));
                    report.setTotalTax(rs.getBigDecimal("total_tax"));
                    report.setTotalDiscount(rs.getBigDecimal("total_discount"));
                    report.setCashRevenue(rs.getBigDecimal("cash_revenue"));
                    report.setCardRevenue(rs.getBigDecimal("card_revenue"));
                    report.setOnlineRevenue(rs.getBigDecimal("online_revenue"));
                    report.setTransferRevenue(rs.getBigDecimal("transfer_revenue"));
                    report.setVoucherRevenue(rs.getBigDecimal("voucher_revenue"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return report;
    }

    /**
     * Lấy danh sách ca làm việc trong khoảng ngày
     */
    public List<RevenueReport> getShiftsInRange(LocalDate fromDate, LocalDate toDate) {
        List<RevenueReport> shifts = new ArrayList<>();

        String sql = """
            SELECT 
                sh.shift_id,
                sh.shift_date,
                sh.start_time,
                sh.end_time,
                u.first_name + ' ' + u.last_name as staff_name
            FROM shift_schedule sh
            INNER JOIN users u ON sh.staff_id = u.user_id
            WHERE sh.shift_date BETWEEN ? AND ?
                AND sh.status = 'DONE'
            ORDER BY sh.shift_date, sh.start_time
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RevenueReport report = new RevenueReport();
                    report.setShiftId(rs.getInt("shift_id"));
                    report.setReportDate(rs.getDate("shift_date").toLocalDate());
                    report.setShiftName(formatShiftName(rs.getTime("start_time"), rs.getTime("end_time")));
                    report.setStaffName(rs.getString("staff_name"));
                    shifts.add(report);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return shifts;
    }

    /**
     * Helper: Format tên ca
     */
    private String formatShiftName(Time startTime, Time endTime) {
        LocalTime start = startTime.toLocalTime();
        int hour = start.getHour();
        
        if (hour < 12) {
            return "Ca sáng";
        } else if (hour < 18) {
            return "Ca chiều";
        } else {
            return "Ca tối";
        }
    }
}

