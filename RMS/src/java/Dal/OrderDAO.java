package Dal;

import Models.Order;
import Models.OrderItem;
import Models.MenuItem;
import Utils.PricingService;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

/**
 * OrderDAO
 *
 * Trách nhiệm:
 *  - Tạo order mới
 *  - Quản lý order_items (thêm món, cập nhật trạng thái SERVED, ...)
 *  - Tính và ghi lại tổng tiền của 1 order (subtotal/tax/discount/total)
 *  - Gộp tất cả order chưa SETTLED của một bàn để chuẩn bị thanh toán
 *  - Đóng order (SETTLED) sau khi thu tiền
 *
 * Quy ước:
 *
 * orders.status:
 *   OPEN / COOKING / SERVED / SETTLED / ...
 *   -> Sau khi thu tiền (kể cả tạo bill PROFORMA chờ VNPay) ta set SETTLED
 *      để không cho thêm món nữa.
 *
 * order_items.status:
 *   NEW / SENT / READY / SERVED / CANCELLED / ...
 *
 * Tiền (VAT 10% giả định):
 *   subtotal        = SUM(final_unit_price * quantity) của các item != CANCELLED
 *   tax_amount      = subtotal * 10%
 *   discount_amount = hiện tại = 0 (có thể mở rộng sau)
 *   total_amount    = subtotal + tax_amount - discount_amount
 */
public class OrderDAO {

    private final PricingService pricingService = new PricingService();

    /* =========================================================
     * 1. Tạo ORDER mới (khách ngồi xuống, mở order)
     * ========================================================= */
    public Long createOrder(Order order) throws SQLException {
        final String sql = """
            INSERT INTO orders (
                order_code,
                order_type,
                table_id,
                waiter_id,
                status,
                notes,
                opened_at,
                subtotal,
                tax_amount,
                discount_amount,
                total_amount
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, "ORD" + System.currentTimeMillis());
            ps.setString(2, order.getOrderType());
            ps.setInt(3, order.getTableId());
            ps.setInt(4, order.getWaiterId());
            ps.setString(5, order.getStatus() != null ? order.getStatus() : Order.STATUS_OPEN);
            ps.setString(6, order.getSpecialInstructions());
            ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));

            // khi vừa tạo order chưa có món -> tiền = 0
            ps.setBigDecimal(8,  BigDecimal.ZERO); // subtotal
            ps.setBigDecimal(9,  BigDecimal.ZERO); // tax_amount
            ps.setBigDecimal(10, BigDecimal.ZERO); // discount_amount
            ps.setBigDecimal(11, BigDecimal.ZERO); // total_amount

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        }
        return null;
    }

    /* =========================================================
     * 2. Lấy 1 ORDER theo ID (join thêm table + waiter để show)
     * ========================================================= */
    public Order getOrderById(Long orderId) throws SQLException {
        final String sql = """
            SELECT o.*,
                   dt.table_number,
                   u.first_name + ' ' + u.last_name AS waiter_name
            FROM orders o
            LEFT JOIN dining_table dt ON dt.table_id = o.table_id
            LEFT JOIN users u        ON u.user_id    = o.waiter_id
            WHERE o.order_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapOrder(rs);
                }
            }
        }
        return null;
    }

    /* =========================================================
     * 3. Lấy danh sách ORDER chưa SETTLED của 1 bàn
     *    -> dùng để build bill gộp cho bàn
     * ========================================================= */
    public List<Order> getUnsettledOrdersByTableId(int tableId) throws SQLException {
        final String sql = """
            SELECT o.*,
                   dt.table_number,
                   u.first_name + ' ' + u.last_name AS waiter_name
            FROM orders o
            LEFT JOIN dining_table dt ON dt.table_id = o.table_id
            LEFT JOIN users u        ON u.user_id    = o.waiter_id
            WHERE o.table_id = ?
              AND o.status <> 'SETTLED'
            ORDER BY o.opened_at ASC
        """;

        List<Order> list = new ArrayList<>();

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, tableId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapOrder(rs));
                }
            }
        }
        return list;
    }

    /* =========================================================
     * 4. Thêm một món vào ORDER:
     *    - Tính final_unit_price theo PricingService
     *    - Insert order_items
     *    - Caller nên gọi recalculateOrderTotals(orderId) sau đó
     * ========================================================= */
    public Long addOrderItem(OrderItem item) throws SQLException {
        // Lấy giá áp dụng hiện tại
        BigDecimal basePrice = item.getBaseUnitPrice();
        BigDecimal finalPrice = pricingService.getCurrentPrice(
                buildTempMenuItem(item.getMenuItemId(), basePrice)
        );
        item.setFinalUnitPrice(finalPrice);

        // totalPrice để hiển thị UI
        item.setTotalPrice(finalPrice.multiply(BigDecimal.valueOf(item.getQuantity())));

        final String sql = """
            INSERT INTO order_items (
                order_id,
                menu_item_id,
                quantity,
                special_instructions,
                priority,
                course_no,
                base_unit_price,
                final_unit_price,
                status,
                created_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, item.getOrderId());
            ps.setInt(2, item.getMenuItemId());
            ps.setInt(3, item.getQuantity());
            ps.setString(4, item.getSpecialInstructions());
            ps.setString(5, item.getPriority());

            // map course string -> int
            ps.setInt(6, mapCourseToInt(item.getCourse()));

            ps.setBigDecimal(7, item.getBaseUnitPrice());
            ps.setBigDecimal(8, item.getFinalUnitPrice());
            ps.setString(9, item.getStatus()); // "NEW"
            ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getLong(1);
                }
            }
        }
        return null;
    }

    /* =========================================================
     * 5. Lấy danh sách MÓN của một ORDER
     * ========================================================= */
    public List<OrderItem> getOrderItems(Long orderId) throws SQLException {
        final String sql = """
            SELECT oi.*,
                   mi.name        AS menu_item_name,
                   mi.description AS menu_item_description,
                   mi.preparation_time
            FROM order_items oi
            LEFT JOIN menu_items mi ON mi.menu_item_id = oi.menu_item_id
            WHERE oi.order_id = ?
            ORDER BY oi.course_no, oi.created_at
        """;

        List<OrderItem> items = new ArrayList<>();

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapOrderItem(rs));
                }
            }
        }
        return items;
    }

    /* Lấy 1 món cụ thể theo order_item_id */
    public OrderItem getOrderItemById(Long orderItemId) throws SQLException {
        final String sql = """
            SELECT oi.*,
                   mi.name AS menu_item_name,
                   mi.preparation_time
            FROM order_items oi
            LEFT JOIN menu_items mi ON mi.menu_item_id = oi.menu_item_id
            WHERE oi.order_item_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, orderItemId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapOrderItem(rs);
                }
            }
        }
        return null;
    }

    /* =========================================================
     * 6. Các món READY cho 1 bàn - chưa SERVED
     *    -> để bồi bàn bưng ra
     * ========================================================= */
    public List<OrderItem> getReadyItemsForTable(Integer tableId) throws SQLException {
        final String sql = """
            SELECT oi.order_item_id, oi.order_id, oi.menu_item_id, oi.quantity,
                   oi.special_instructions, oi.priority, oi.course_no, oi.status,
                   oi.served_by, oi.served_at,
                   mi.name AS menu_item_name,
                   dt.table_number,
                   o.order_id
            FROM order_items oi
            JOIN orders o             ON o.order_id   = oi.order_id
            LEFT JOIN dining_table dt ON dt.table_id  = o.table_id
            LEFT JOIN menu_items mi   ON mi.menu_item_id = oi.menu_item_id
            WHERE o.table_id = ?
              AND oi.status = 'READY'
              AND oi.served_at IS NULL
            ORDER BY oi.order_item_id ASC
        """;

        List<OrderItem> items = new ArrayList<>();

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, tableId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapOrderItem(rs));
                }
            }
        }
        return items;
    }

    /* =========================================================
     * 7. Lịch sử món theo bàn (table-history)
     * ========================================================= */
    public List<OrderItem> getTableHistory(Integer tableId) throws SQLException {
        final String sql = """
            SELECT oi.order_item_id, oi.order_id, oi.menu_item_id, oi.quantity,
                   oi.special_instructions, oi.priority, oi.course_no, oi.status,
                   oi.served_by, oi.served_at, oi.created_at,
                   oi.base_unit_price, oi.final_unit_price,
                   mi.name AS menu_item_name,
                   dt.table_number,
                   o.order_id, o.opened_at AS order_time,
                   u.username AS waiter_name
            FROM order_items oi
            JOIN orders o             ON o.order_id   = oi.order_id
            LEFT JOIN dining_table dt ON dt.table_id  = o.table_id
            LEFT JOIN menu_items mi   ON mi.menu_item_id = oi.menu_item_id
            LEFT JOIN users u         ON u.user_id    = o.waiter_id
            WHERE o.table_id = ?
            ORDER BY oi.order_item_id DESC
        """;

        List<OrderItem> items = new ArrayList<>();

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, tableId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem it = mapOrderItem(rs);

                    Timestamp orderTime = rs.getTimestamp("order_time");
                    if (orderTime != null) {
                        it.setCreatedAt(orderTime.toLocalDateTime());
                    }

                    it.setTableNumber(safeGet(rs, "table_number"));
                    items.add(it);
                }
            }
        }
        return items;
    }

    /* =========================================================
     * 8. Cập nhật trạng thái ORDER (COOKING / SERVED / SETTLED / ...)
     * ========================================================= */
    public boolean updateOrderStatus(long orderId, String newStatus) throws SQLException {
        final String sql = """
            UPDATE orders
            SET status = ?
            WHERE order_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setLong(2, orderId);

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Cập nhật full một order sau khi đã tính (subtotal/tax/discount/total ...)
     */
    public boolean updateOrder(Order order) throws SQLException {
        final String sql = """
            UPDATE orders
            SET status          = ?,
                closed_at       = ?,
                subtotal        = ?,
                tax_amount      = ?,
                discount_amount = ?,
                total_amount    = ?
            WHERE order_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, order.getStatus());
            if (order.getClosedAt() != null) {
                ps.setTimestamp(2, Timestamp.valueOf(order.getClosedAt()));
            } else {
                ps.setTimestamp(2, null);
            }

            ps.setBigDecimal(3, nz(order.getSubtotal()));
            ps.setBigDecimal(4, nz(order.getTaxAmount()));
            ps.setBigDecimal(5, nz(order.getDiscountAmount()));
            ps.setBigDecimal(6, nz(order.getTotalAmount()));
            ps.setLong(7, order.getOrderId());

            return ps.executeUpdate() > 0;
        }
    }

    /* =========================================================
     * 9. Update trạng thái một món cơ bản (SERVING / SERVED ...)
     * ========================================================= */
    public boolean updateOrderItemBasic(OrderItem item) throws SQLException {
        final String sql = """
            UPDATE order_items
            SET status     = ?,
                served_by  = ?,
                served_at  = ?
            WHERE order_item_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getStatus());
            ps.setObject(2, item.getServedBy());
            ps.setTimestamp(
                    3,
                    item.getServedAt() != null
                            ? Timestamp.valueOf(item.getServedAt())
                            : null
            );
            ps.setLong(4, item.getOrderItemId());

            return ps.executeUpdate() > 0;
        }
    }

    /* =========================================================
     * 10. Mark nhanh 1 món là SERVED (bồi bàn bưng ra)
     * ========================================================= */
    public boolean markOrderItemAsServed(Long orderItemId, Integer servedBy) throws SQLException {
        final String sql = """
            UPDATE order_items
            SET status     = 'SERVED',
                served_by  = ?,
                served_at  = ?
            WHERE order_item_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, servedBy);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(3, orderItemId);

            return ps.executeUpdate() > 0;
        }
    }

    /* =========================================================
     * 11. Kiểm tra toàn bộ món trong ORDER đã SERVED chưa
     *     -> nếu toàn SERVED thì có thể set order.status = 'SERVED'
     * ========================================================= */
    public boolean areAllItemsServed(Long orderId) throws SQLException {
        final String sql = """
            SELECT COUNT(*) AS total_items,
                   SUM(CASE WHEN status = 'SERVED' THEN 1 ELSE 0 END) AS served_items
            FROM order_items
            WHERE order_id = ?
              AND status <> 'CANCELLED'
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total  = rs.getInt("total_items");
                    int served = rs.getInt("served_items");
                    return total > 0 && total == served;
                }
            }
        }
        return false;
    }

    /* =========================================================
     * 12. Đóng ORDER (sau thanh toán):
     *     status='SETTLED', closed_at=NOW()
     *
     *  -> dùng bình thường (ngoài transaction tổng)
     * ========================================================= */
    public boolean closeOrder(Long orderId) throws SQLException {
        final String sql = """
            UPDATE orders
            SET status   = 'SETTLED',
                closed_at = ?
            WHERE order_id = ?
              AND status <> 'SETTLED'
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(2, orderId);

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * 12b. closeOrderInTx(...)
     *
     * Dùng khi bạn đã có Connection đang mở transaction (ví dụ trong PaymentServlet.doPost()).
     * KHÔNG tự commit/rollback.
     */
    public boolean closeOrderInTx(Connection externalConn, Long orderId) throws SQLException {
        final String sql = """
            UPDATE orders
            SET status   = 'SETTLED',
                closed_at = ?
            WHERE order_id = ?
              AND status <> 'SETTLED'
        """;

        try (PreparedStatement ps = externalConn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(2, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    /* =========================================================
     * 13. Tính lại tổng tiền cho một ORDER và ghi ngược vào DB.
     *
     * subtotal = SUM(final_unit_price * quantity) (bỏ CANCELLED)
     * tax      = subtotal * 10%
     * discount = 0 (hiện tại)
     * total    = subtotal + tax - discount
     *
     * Có 2 overload:
     *   - recalculateOrderTotals(Long)
     *   - recalculateOrderTotals(long)
     * ========================================================= */
    public void recalculateOrderTotals(Long orderIdObj) throws SQLException {
        if (orderIdObj != null) {
            recalculateOrderTotals(orderIdObj.longValue());
        }
    }

    public void recalculateOrderTotals(long orderId) throws SQLException {
        final String subtotalSql = """
            SELECT SUM(oi.final_unit_price * oi.quantity) AS subTotal
            FROM order_items oi
            WHERE oi.order_id = ?
              AND oi.status <> 'CANCELLED'
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps1 = conn.prepareStatement(subtotalSql)) {

            ps1.setLong(1, orderId);

            BigDecimal subtotal = BigDecimal.ZERO;
            try (ResultSet rs = ps1.executeQuery()) {
                if (rs.next()) {
                    subtotal = rs.getBigDecimal("subTotal");
                    if (subtotal == null) subtotal = BigDecimal.ZERO;
                }
            }

            // VAT 10%
            BigDecimal tax = subtotal
                    .multiply(new BigDecimal("10"))
                    .divide(new BigDecimal("100"));

            // Discount hiện tại = 0
            BigDecimal discount = BigDecimal.ZERO;

            // Total = subtotal + tax - discount
            BigDecimal total = subtotal.add(tax).subtract(discount);
            if (total.compareTo(BigDecimal.ZERO) < 0) {
                total = BigDecimal.ZERO;
            }

            final String updateSql = """
                UPDATE orders
                SET subtotal        = ?,
                    tax_amount      = ?,
                    discount_amount = ?,
                    total_amount    = ?
                WHERE order_id = ?
            """;

            try (PreparedStatement ps2 = conn.prepareStatement(updateSql)) {
                ps2.setBigDecimal(1, subtotal);
                ps2.setBigDecimal(2, tax);
                ps2.setBigDecimal(3, discount);
                ps2.setBigDecimal(4, total);
                ps2.setLong(5, orderId);

                ps2.executeUpdate();
            }
        }
    }

    /* =========================================================
     * 14. Gộp tất cả order chưa SETTLED của một bàn:
     *
     *   - Lấy danh sách order chưa SETTLED
     *   - Recalc totals từng order để chắc số liệu mới nhất
     *   - Cộng dồn subtotal/tax/discount/total của từng order
     *
     *   Dùng ở PaymentServlet.doGet() + PaymentServlet.doPost()
     *   để biết bàn đang nợ bao nhiêu.
     * ========================================================= */
    public CombinedBillSummary buildCombinedBillForTable(int tableId) throws SQLException {
        List<Order> orders = getUnsettledOrdersByTableId(tableId);

        BigDecimal grandSubtotal = BigDecimal.ZERO;
        BigDecimal grandTax = BigDecimal.ZERO;
        BigDecimal grandDiscount = BigDecimal.ZERO;
        BigDecimal grandTotal = BigDecimal.ZERO;

        for (Order o : orders) {
            // đảm bảo totals mới nhất
            recalculateOrderTotals(o.getOrderId());

            // đọc lại order sau khi recalc
            Order fresh = getOrderById(o.getOrderId());
            if (fresh != null) {
                // cộng dồn vào tổng bàn
                if (fresh.getSubtotal()       != null) grandSubtotal = grandSubtotal.add(fresh.getSubtotal());
                if (fresh.getTaxAmount()      != null) grandTax      = grandTax.add(fresh.getTaxAmount());
                if (fresh.getDiscountAmount() != null) grandDiscount = grandDiscount.add(fresh.getDiscountAmount());
                if (fresh.getTotalAmount()    != null) grandTotal    = grandTotal.add(fresh.getTotalAmount());

                // copy số đã recalc vào object gốc để JSP show
                o.setSubtotal(fresh.getSubtotal());
                o.setTaxAmount(fresh.getTaxAmount());
                o.setDiscountAmount(fresh.getDiscountAmount());
                o.setTotalAmount(fresh.getTotalAmount());
            }
        }

        CombinedBillSummary sum = new CombinedBillSummary();
        sum.setOrders(orders);
        sum.setSubtotal(grandSubtotal);
        sum.setTaxAmount(grandTax);
        sum.setDiscountAmount(grandDiscount);
        sum.setTotalAmount(grandTotal);

        return sum;
    }

    /* =========================================================
     * 15. Map ResultSet -> Order model
     * ========================================================= */
    private Order mapOrder(ResultSet rs) throws SQLException {
        Order o = new Order();

        o.setOrderId(rs.getLong("order_id"));
        o.setOrderCode(rs.getString("order_code"));
        o.setOrderType(rs.getString("order_type"));
        o.setTableId(rs.getInt("table_id"));
        o.setWaiterId(rs.getInt("waiter_id"));
        o.setStatus(rs.getString("status"));
        o.setSpecialInstructions(rs.getString("notes"));

        Timestamp openedAt = rs.getTimestamp("opened_at");
        if (openedAt != null) {
            o.setOpenedAt(openedAt.toLocalDateTime());
        }

        Timestamp closedAt = rs.getTimestamp("closed_at");
        if (closedAt != null) {
            o.setClosedAt(closedAt.toLocalDateTime());
        }

        o.setSubtotal(nz(rs.getBigDecimal("subtotal")));
        o.setTaxAmount(nz(rs.getBigDecimal("tax_amount")));
        o.setDiscountAmount(nz(rs.getBigDecimal("discount_amount")));
        o.setTotalAmount(nz(rs.getBigDecimal("total_amount")));

        // optional joined columns (có thể không tồn tại trong 1 số query)
        try { o.setTableNumber(rs.getString("table_number")); } catch (Exception ignore) {}
        try { o.setWaiterName(rs.getString("waiter_name"));   } catch (Exception ignore) {}

        return o;
    }

    /* =========================================================
     * 16. Map ResultSet -> OrderItem model
     * ========================================================= */
    private OrderItem mapOrderItem(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();

        item.setOrderItemId(rs.getLong("order_item_id"));
        item.setOrderId(rs.getLong("order_id"));
        item.setMenuItemId(rs.getInt("menu_item_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setSpecialInstructions(rs.getString("special_instructions"));
        item.setPriority(rs.getString("priority"));

        // course_no -> human text
        String courseText = mapCourseToText(safeGetInt(rs, "course_no"), safeGet(rs, "course"));
        item.setCourse(courseText);

        item.setBaseUnitPrice(rs.getBigDecimal("base_unit_price"));
        item.setFinalUnitPrice(rs.getBigDecimal("final_unit_price"));

        // totalPrice: nếu chưa có trong DB thì tính (final_unit_price * qty)
        BigDecimal tp = null;
        BigDecimal fu = item.getFinalUnitPrice();
        Integer q = item.getQuantity();
        if (fu != null && q != null) {
            tp = fu.multiply(BigDecimal.valueOf(q));
        } else {
            try {
                tp = rs.getBigDecimal("total_price");
            } catch (Exception ignore) {}
        }
        item.setTotalPrice(tp);

        item.setStatus(rs.getString("status"));

        Timestamp cAt = null;
        try { cAt = rs.getTimestamp("created_at"); } catch (Exception ignore) {}
        if (cAt != null) item.setCreatedAt(cAt.toLocalDateTime());

        Timestamp sAt = null;
        try { sAt = rs.getTimestamp("served_at"); } catch (Exception ignore) {}
        if (sAt != null) item.setServedAt(sAt.toLocalDateTime());

        try {
            Integer servedBy = (Integer) rs.getObject("served_by");
            if (servedBy != null) item.setServedBy(servedBy);
        } catch (Exception ignore) {}

        // optional joined cols
        item.setMenuItemName(safeGet(rs, "menu_item_name"));
        item.setTableNumber(safeGet(rs, "table_number"));

        try {
            Integer prep = (Integer) rs.getObject("preparation_time");
            if (prep != null) item.setPreparationTime(prep);
        } catch (Exception ignore) {}

        return item;
    }

    /* =========================================================
     * 17. Helpers nội bộ
     * ========================================================= */

    private MenuItem buildTempMenuItem(int menuItemId, BigDecimal basePrice) {
        MenuItem m = new MenuItem();
        m.setItemId(menuItemId);
        m.setBasePrice(basePrice);
        return m;
    }

    private int mapCourseToInt(String course) {
        if (course == null) return 1;
        switch (course.toUpperCase()) {
            case "APPETIZER": return 1;
            case "MAIN":      return 2;
            case "DESSERT":   return 3;
            case "BEVERAGE":  return 4;
            default:          return 1;
        }
    }

    private String mapCourseToText(int cNo, String fallbackText) {
        switch (cNo) {
            case 1:  return "APPETIZER";
            case 2:  return "MAIN";
            case 3:  return "DESSERT";
            case 4:  return "BEVERAGE";
            default:
                return (fallbackText != null && !fallbackText.isBlank())
                        ? fallbackText
                        : "OTHER";
        }
    }

    private BigDecimal nz(BigDecimal v) {
        return (v == null ? BigDecimal.ZERO : v);
    }

    private String safeGet(ResultSet rs, String col) {
        try { return rs.getString(col); }
        catch (Exception ignore) { return null; }
    }

    private int safeGetInt(ResultSet rs, String col) {
        try { return rs.getInt(col); }
        catch (Exception ignore) { return 0; }
    }

    /* =========================================================
     * 18. DTO gộp bill cho bàn => dùng ở PaymentServlet
     * ========================================================= */
    public static class CombinedBillSummary {
        private List<Order>   orders;
        private BigDecimal    subtotal;
        private BigDecimal    taxAmount;
        private BigDecimal    discountAmount;
        private BigDecimal    totalAmount;

        public List<Order> getOrders() { return orders; }
        public void setOrders(List<Order> orders) { this.orders = orders; }

        public BigDecimal getSubtotal() { return subtotal; }
        public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

        public BigDecimal getTaxAmount() { return taxAmount; }
        public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

        public BigDecimal getDiscountAmount() { return discountAmount; }
        public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }

        public BigDecimal getTotalAmount() { return totalAmount; }
        public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    }
}
