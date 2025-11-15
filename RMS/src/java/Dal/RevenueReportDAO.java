package Dal;

import Models.RevenueReport;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

/**
 * RevenueReportDAO - DAO cho báo cáo doanh thu
 * 
 * Liên kết:
 * - orders -> bills -> payments (doanh thu từ payments với status = SUCCESS)
 * - orders.waiter_id -> users.user_id (nhân viên)
 * - orders.opened_at + shift_schedule (ca làm việc)
 * - payments.method (kênh thanh toán: CASH, VNPAY)
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
                COALESCE(SUM(CASE WHEN p.method = 'VNPAY' THEN p.amount ELSE 0 END), 0) as vnpay_revenue
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
                    // Set các payment methods không dùng về 0
                    report.setCardRevenue(java.math.BigDecimal.ZERO);
                    report.setOnlineRevenue(java.math.BigDecimal.ZERO);
                    report.setTransferRevenue(java.math.BigDecimal.ZERO);
                    report.setVoucherRevenue(java.math.BigDecimal.ZERO);
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

        // Lấy trực tiếp từ bills và payments vì bills có đầy đủ thông tin
        // Bills được tạo khi thanh toán, nên dùng bills.created_at để filter
        // Dùng subquery riêng để tính subtotal/tax/discount (mỗi bill một lần)
        StringBuilder sql = new StringBuilder("""
            SELECT 
                (SELECT COUNT(DISTINCT o.order_id) 
                 FROM orders o 
                 WHERE CAST(o.opened_at AS DATE) BETWEEN ? AND ? 
                   AND o.status = 'SETTLED') as total_orders,
                COALESCE(SUM(p.amount), 0) as total_revenue,
                (SELECT COALESCE(SUM(b2.subtotal), 0) 
                 FROM bills b2 
                 WHERE CAST(b2.created_at AS DATE) BETWEEN ? AND ?
                   AND b2.voided = 0
                   AND EXISTS (SELECT 1 FROM payments p2 WHERE p2.bill_id = b2.bill_id AND p2.status = 'SUCCESS')) as total_subtotal,
                (SELECT COALESCE(SUM(b3.tax_amount), 0) 
                 FROM bills b3 
                 WHERE CAST(b3.created_at AS DATE) BETWEEN ? AND ?
                   AND b3.voided = 0
                   AND EXISTS (SELECT 1 FROM payments p3 WHERE p3.bill_id = b3.bill_id AND p3.status = 'SUCCESS')) as total_tax,
                (SELECT COALESCE(SUM(b4.discount_amount), 0) 
                 FROM bills b4 
                 WHERE CAST(b4.created_at AS DATE) BETWEEN ? AND ?
                   AND b4.voided = 0
                   AND EXISTS (SELECT 1 FROM payments p4 WHERE p4.bill_id = b4.bill_id AND p4.status = 'SUCCESS')) as total_discount,
                COALESCE(SUM(CASE WHEN p.method = 'CASH' THEN p.amount ELSE 0 END), 0) as cash_revenue,
                COALESCE(SUM(CASE WHEN p.method = 'VNPAY' AND p.status = 'SUCCESS' THEN p.amount ELSE 0 END), 0) as vnpay_revenue
            FROM bills b
            INNER JOIN payments p ON b.bill_id = p.bill_id
            WHERE CAST(b.created_at AS DATE) BETWEEN ? AND ?
                AND p.status = 'SUCCESS'
                AND b.voided = 0
        """);

        List<Object> params = new ArrayList<>();
        // Tham số cho subquery đếm orders
        params.add(Date.valueOf(fromDate));
        params.add(Date.valueOf(toDate));
        // Tham số cho subquery tính subtotal
        params.add(Date.valueOf(fromDate));
        params.add(Date.valueOf(toDate));
        // Tham số cho subquery tính tax
        params.add(Date.valueOf(fromDate));
        params.add(Date.valueOf(toDate));
        // Tham số cho subquery tính discount
        params.add(Date.valueOf(fromDate));
        params.add(Date.valueOf(toDate));
        // Tham số cho main query filter bills
        params.add(Date.valueOf(fromDate));
        params.add(Date.valueOf(toDate));

        if (staffId != null) {
            // Cần JOIN với orders để filter theo staffId
            sql.append(" AND EXISTS (SELECT 1 FROM orders o WHERE (o.order_id = b.order_id OR o.table_id = b.table_id) AND o.waiter_id = ?)");
            params.add(staffId);
        }

        if (paymentMethod != null && !paymentMethod.isEmpty()) {
            sql.append(" AND p.method = ?");
            params.add(paymentMethod);
        }

        if (orderType != null && !orderType.isEmpty()) {
            // Cần JOIN với orders để filter theo orderType
            sql.append(" AND EXISTS (SELECT 1 FROM orders o WHERE (o.order_id = b.order_id OR o.table_id = b.table_id) AND o.order_type = ?)");
            params.add(orderType);
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            // Debug: Log SQL query
            System.out.println("Revenue Summary Query: " + sql.toString());
            System.out.println("Params: fromDate=" + fromDate + ", toDate=" + toDate + 
                             ", staffId=" + staffId + ", paymentMethod=" + paymentMethod + 
                             ", orderType=" + orderType);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    report.setTotalOrders(rs.getInt("total_orders"));
                    report.setTotalRevenue(rs.getBigDecimal("total_revenue"));
                    report.setTotalSubtotal(rs.getBigDecimal("total_subtotal"));
                    report.setTotalTax(rs.getBigDecimal("total_tax"));
                    report.setTotalDiscount(rs.getBigDecimal("total_discount"));
                    report.setCashRevenue(rs.getBigDecimal("cash_revenue"));
                    // VNPay revenue từ payments
                    BigDecimal vnpayRev = rs.getBigDecimal("vnpay_revenue");
                    report.setCardRevenue(java.math.BigDecimal.ZERO);
                    report.setOnlineRevenue(vnpayRev != null ? vnpayRev : java.math.BigDecimal.ZERO);
                    report.setTransferRevenue(java.math.BigDecimal.ZERO);
                    report.setVoucherRevenue(java.math.BigDecimal.ZERO);
                    
                    // Debug: Log results
                    System.out.println("Query Result - Orders: " + report.getTotalOrders() + 
                                     ", Revenue: " + report.getTotalRevenue() + 
                                     ", Cash: " + report.getCashRevenue() + 
                                     ", VNPay: " + vnpayRev);
                } else {
                    System.out.println("Query returned no rows - initializing with zeros");
                    // Initialize với giá trị 0 để JSP vẫn hiển thị
                    report.setTotalOrders(0);
                    report.setTotalRevenue(java.math.BigDecimal.ZERO);
                    report.setTotalSubtotal(java.math.BigDecimal.ZERO);
                    report.setTotalTax(java.math.BigDecimal.ZERO);
                    report.setTotalDiscount(java.math.BigDecimal.ZERO);
                    report.setCashRevenue(java.math.BigDecimal.ZERO);
                    report.setCardRevenue(java.math.BigDecimal.ZERO);
                    report.setOnlineRevenue(java.math.BigDecimal.ZERO);
                    report.setTransferRevenue(java.math.BigDecimal.ZERO);
                    report.setVoucherRevenue(java.math.BigDecimal.ZERO);
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in getRevenueSummary: " + e.getMessage());
            e.printStackTrace();
            // Trả về report rỗng thay vì null để JSP vẫn hiển thị
            report.setTotalOrders(0);
            report.setTotalRevenue(java.math.BigDecimal.ZERO);
            report.setTotalSubtotal(java.math.BigDecimal.ZERO);
            report.setTotalTax(java.math.BigDecimal.ZERO);
            report.setTotalDiscount(java.math.BigDecimal.ZERO);
            report.setCashRevenue(java.math.BigDecimal.ZERO);
            report.setCardRevenue(java.math.BigDecimal.ZERO);
            report.setOnlineRevenue(java.math.BigDecimal.ZERO);
            report.setTransferRevenue(java.math.BigDecimal.ZERO);
            report.setVoucherRevenue(java.math.BigDecimal.ZERO);
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

    /**
     * Debug: Kiểm tra dữ liệu thực tế trong DB
     */
    public void debugDataCheck(LocalDate fromDate, LocalDate toDate) {
        System.out.println("=== DEBUG DATA CHECK ===");
        System.out.println("Date range: " + fromDate + " to " + toDate);
        
        // Check orders
        String sqlOrders = """
            SELECT COUNT(*) as total, 
                   MIN(opened_at) as min_date, 
                   MAX(opened_at) as max_date
            FROM orders
            WHERE CAST(opened_at AS DATE) BETWEEN ? AND ?
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlOrders)) {
            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("Orders in range: " + rs.getInt("total"));
                    if (rs.getDate("min_date") != null) {
                        System.out.println("Date range in DB: " + rs.getDate("min_date") + " to " + rs.getDate("max_date"));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking orders: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Check distinct order statuses
        String sqlStatuses = """
            SELECT DISTINCT status 
            FROM orders
            WHERE CAST(opened_at AS DATE) BETWEEN ? AND ?
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlStatuses)) {
            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));
            
            try (ResultSet rs = ps.executeQuery()) {
                List<String> statuses = new ArrayList<>();
                while (rs.next()) {
                    statuses.add(rs.getString("status"));
                }
                System.out.println("Order statuses found: " + String.join(", ", statuses));
            }
        } catch (SQLException e) {
            System.err.println("Error checking order statuses: " + e.getMessage());
        }
        
        // Check if bills exist at all
        String sqlBillsCount = "SELECT COUNT(*) as total FROM bills";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlBillsCount);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                System.out.println("Total bills in DB: " + rs.getInt("total"));
            }
        } catch (SQLException e) {
            System.err.println("Error checking bills count: " + e.getMessage());
        }
        
        // Check bills structure: order_id vs table_id
        String sqlBillsStructure = """
            SELECT 
                COUNT(*) as total,
                COUNT(order_id) as bills_with_order_id,
                COUNT(table_id) as bills_with_table_id,
                COUNT(CASE WHEN order_id IS NULL AND table_id IS NOT NULL THEN 1 END) as bills_with_table_only
            FROM bills
        """;
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlBillsStructure);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                System.out.println("Bills structure - Total: " + rs.getInt("total") + 
                                 ", With order_id: " + rs.getInt("bills_with_order_id") +
                                 ", With table_id: " + rs.getInt("bills_with_table_id") +
                                 ", Table only (no order_id): " + rs.getInt("bills_with_table_only"));
            }
        } catch (SQLException e) {
            System.err.println("Error checking bills structure: " + e.getMessage());
        }
        
        // Check orders with bills via table_id
        String sqlOrdersBillsViaTable = """
            SELECT COUNT(DISTINCT o.order_id) as total
            FROM orders o
            INNER JOIN bills b ON o.table_id = b.table_id
            WHERE CAST(o.opened_at AS DATE) BETWEEN ? AND ?
        """;
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlOrdersBillsViaTable)) {
            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("Orders with bills (via table_id): " + rs.getInt("total"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking orders+bills via table: " + e.getMessage());
        }
        
        // Check payments
        String sqlPayments = """
            SELECT COUNT(*) as total, 
                   COUNT(CASE WHEN method = 'CASH' THEN 1 END) as cash_count,
                   COUNT(CASE WHEN method = 'VNPAY' THEN 1 END) as vnpay_count,
                   COUNT(CASE WHEN method = 'VNPAY' AND status = 'SUCCESS' THEN 1 END) as vnpay_success
            FROM payments
        """;
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlPayments);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                System.out.println("Payments - Total: " + rs.getInt("total") + 
                                 ", CASH: " + rs.getInt("cash_count") +
                                 ", VNPAY: " + rs.getInt("vnpay_count") +
                                 ", VNPAY SUCCESS: " + rs.getInt("vnpay_success"));
            }
        } catch (SQLException e) {
            System.err.println("Error checking payments: " + e.getMessage());
        }
        
        // Check orders with bills
        String sqlOrdersBills = """
            SELECT COUNT(DISTINCT o.order_id) as total
            FROM orders o
            INNER JOIN bills b ON o.order_id = b.order_id
            WHERE CAST(o.opened_at AS DATE) BETWEEN ? AND ?
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlOrdersBills)) {
            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("Orders with bills: " + rs.getInt("total"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking orders+bills: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Check if orders have revenue fields directly
        String sqlOrdersDirect = """
            SELECT COUNT(*) as total,
                   SUM(COALESCE(total_amount, 0)) as total_rev,
                   SUM(COALESCE(subtotal, 0)) as total_sub
            FROM orders
            WHERE CAST(opened_at AS DATE) BETWEEN ? AND ?
                AND status = 'SETTLED'
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlOrdersDirect)) {
            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("Orders with direct revenue fields: " + rs.getInt("total"));
                    System.out.println("Total revenue from orders.total_amount: " + rs.getBigDecimal("total_rev"));
                    System.out.println("Total subtotal from orders.subtotal: " + rs.getBigDecimal("total_sub"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking orders direct revenue: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Check orders with bills and payments
        String sqlFull = """
            SELECT COUNT(DISTINCT o.order_id) as total
            FROM orders o
            INNER JOIN bills b ON o.order_id = b.order_id
            INNER JOIN payments p ON b.bill_id = p.bill_id
            WHERE CAST(o.opened_at AS DATE) BETWEEN ? AND ?
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlFull)) {
            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("Orders with bills+payments: " + rs.getInt("total"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking full chain: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Check with SETTLED and SUCCESS status
        String sqlWithStatus = """
            SELECT COUNT(DISTINCT o.order_id) as total
            FROM orders o
            INNER JOIN bills b ON o.order_id = b.order_id
            INNER JOIN payments p ON b.bill_id = p.bill_id
            WHERE CAST(o.opened_at AS DATE) BETWEEN ? AND ?
                AND o.status = 'SETTLED'
                AND p.status = 'SUCCESS'
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlWithStatus)) {
            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("Orders with SETTLED+SUCCESS: " + rs.getInt("total"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking with status filter: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("=== END DEBUG ===");
    }
}

