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
 * OrderDAO:
 * - Tạo order
 * - Lấy order
 * - Gắn món vào order
 * - Update order và order_item
 *
 * Giá món (final_unit_price) sẽ được chốt tại thời điểm thêm món vào order
 * bằng PricingService -> đảm bảo in bill sau này không thay đổi theo khung giờ nữa.
 */
public class OrderDAO {

    /**
     * Tạo order mới
     */
    public Long createOrder(Order order) throws SQLException {
        String sql = """
            INSERT INTO orders (
                order_type,
                table_id,
                waiter_id,
                status,
                subtotal,
                tax_amount,
                total_amount,
                special_instructions,
                created_at,
                updated_at,
                created_by
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, order.getOrderType());
            ps.setInt(2, order.getTableId());
            ps.setInt(3, order.getWaiterId());
            ps.setString(4, order.getStatus());
            ps.setBigDecimal(5, order.getSubtotal());
            ps.setBigDecimal(6, order.getTaxAmount());
            ps.setBigDecimal(7, order.getTotalAmount());
            ps.setString(8, order.getSpecialInstructions());
            ps.setTimestamp(9, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(11, order.getCreatedBy());

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

    /**
     * Lấy order theo ID
     */
    public Order getOrderById(Long orderId) throws SQLException {
        String sql = """
            SELECT o.*,
                   dt.table_number,
                   u.first_name + ' ' + u.last_name AS waiter_name
            FROM orders o
            LEFT JOIN dining_table dt ON dt.table_id = o.table_id
            LEFT JOIN users u ON u.user_id = o.waiter_id
            WHERE o.order_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToOrder(rs);
                }
            }
        }

        return null;
    }

    /**
     * Lấy order đang mở theo table_id
     * (NEW / CONFIRMED / PREPARING / READY)
     */
    public Order getOrderByTableId(Integer tableId) throws SQLException {
        String sql = """
            SELECT o.*,
                   dt.table_number,
                   u.first_name + ' ' + u.last_name AS waiter_name
            FROM orders o
            LEFT JOIN dining_table dt ON dt.table_id = o.table_id
            LEFT JOIN users u ON u.user_id = o.waiter_id
            WHERE o.table_id = ?
              AND o.status IN ('NEW', 'CONFIRMED', 'PREPARING', 'READY')
            ORDER BY o.created_at DESC
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, tableId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToOrder(rs);
                }
            }
        }

        return null;
    }

    /**
     * Thêm item vào order:
     * - Lấy giá hiện hành từ PricingService (happy hour, khuyến mãi...)
     * - Ghi cả base_unit_price và final_unit_price vào DB
     * - Tính total_price = final_unit_price * quantity
     *
     * Chú ý:
     *  - baseUnitPrice = giá gốc (menu_items.base_price) tại thời điểm order
     *  - finalUnitPrice = giá sau khi áp dụng rule
     */
    public Long addOrderItem(OrderItem orderItem) throws SQLException {

        // 1. Lấy baseUnitPrice (bạn đã set sẵn vào orderItem ở tầng trên khi user chọn món)
        BigDecimal basePrice = orderItem.getBaseUnitPrice();

        // 2. Tính final price với PricingService (dựa vào menu_item_id)
        PricingService pricingService = new PricingService();
        BigDecimal finalPrice = pricingService.getCurrentPrice(
                buildTempMenuItem(orderItem.getMenuItemId(), basePrice)
        );

        // 3. set vào orderItem để lưu DB
        orderItem.setFinalUnitPrice(finalPrice);
        orderItem.setTotalPrice(finalPrice.multiply(BigDecimal.valueOf(orderItem.getQuantity())));

        String sql = """
            INSERT INTO order_items (
                order_id,
                menu_item_id,
                quantity,
                special_instructions,
                priority,
                course,
                base_unit_price,
                final_unit_price,
                total_price,
                status,
                created_at,
                updated_at,
                created_by
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, orderItem.getOrderId());
            ps.setInt(2, orderItem.getMenuItemId());
            ps.setInt(3, orderItem.getQuantity());
            ps.setString(4, orderItem.getSpecialInstructions());
            ps.setString(5, orderItem.getPriority());
            ps.setString(6, orderItem.getCourse());
            ps.setBigDecimal(7, orderItem.getBaseUnitPrice());   // giá gốc lúc order
            ps.setBigDecimal(8, orderItem.getFinalUnitPrice());  // giá sau rule
            ps.setBigDecimal(9, orderItem.getTotalPrice());      // final * qty
            ps.setString(10, orderItem.getStatus());
            ps.setTimestamp(11, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(12, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(13, orderItem.getCreatedBy());

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

    /**
     * Lấy toàn bộ order_items trong 1 order (bao gồm tên món, thời gian chế biến)
     */
    public List<OrderItem> getOrderItems(Long orderId) throws SQLException {
        String sql = """
            SELECT oi.*,
                   mi.name AS menu_item_name,
                   mi.description AS menu_item_description,
                   mi.preparation_time
            FROM order_items oi
            LEFT JOIN menu_items mi ON mi.menu_item_id = oi.menu_item_id
            WHERE oi.order_id = ?
            ORDER BY oi.course, oi.created_at
        """;

        List<OrderItem> items = new ArrayList<>();

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapResultSetToOrderItem(rs));
                }
            }
        }

        return items;
    }

    /**
     * Update order tổng (status, tiền, note,...)
     */
    public boolean updateOrder(Order order) throws SQLException {
        String sql = """
            UPDATE orders
            SET status = ?,
                subtotal = ?,
                tax_amount = ?,
                total_amount = ?,
                special_instructions = ?,
                updated_at = ?,
                updated_by = ?
            WHERE order_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, order.getStatus());
            ps.setBigDecimal(2, order.getSubtotal());
            ps.setBigDecimal(3, order.getTaxAmount());
            ps.setBigDecimal(4, order.getTotalAmount());
            ps.setString(5, order.getSpecialInstructions());
            ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(7, order.getUpdatedBy());
            ps.setLong(8, order.getOrderId());

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Update 1 item trong order (số lượng, note,...)
     * Lưu ý: Ở đây mình KHÔNG tự động re-calc finalUnitPrice nữa,
     * vì giá đã chốt tại thời điểm thêm món. Nếu bạn muốn cho phép cập nhật lại giá,
     * bạn phải gọi PricingService lại trước khi gọi hàm này và set finalUnitPrice mới.
     */
    public boolean updateOrderItem(OrderItem orderItem) throws SQLException {
        String sql = """
            UPDATE order_items
            SET quantity = ?,
                special_instructions = ?,
                priority = ?,
                course = ?,
                final_unit_price = ?,
                total_price = ?,
                status = ?,
                updated_at = ?,
                updated_by = ?
            WHERE order_item_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderItem.getQuantity());
            ps.setString(2, orderItem.getSpecialInstructions());
            ps.setString(3, orderItem.getPriority());
            ps.setString(4, orderItem.getCourse());
            ps.setBigDecimal(5, orderItem.getFinalUnitPrice());
            ps.setBigDecimal(6, orderItem.getTotalPrice());
            ps.setString(7, orderItem.getStatus());
            ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(9, orderItem.getUpdatedBy());
            ps.setLong(10, orderItem.getOrderItemId());

            return ps.executeUpdate() > 0;
        }
    }

    // ---------------------------------
    // Helpers mapping ResultSet -> Model
    // ---------------------------------

    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();

        order.setOrderId(rs.getLong("order_id"));
        order.setOrderType(rs.getString("order_type"));
        order.setTableId(rs.getInt("table_id"));
        order.setWaiterId(rs.getInt("waiter_id"));
        order.setStatus(rs.getString("status"));
        order.setSubtotal(rs.getBigDecimal("subtotal"));
        order.setTaxAmount(rs.getBigDecimal("tax_amount"));
        order.setTotalAmount(rs.getBigDecimal("total_amount"));
        order.setSpecialInstructions(rs.getString("special_instructions"));

        Timestamp cAt = rs.getTimestamp("created_at");
        Timestamp uAt = rs.getTimestamp("updated_at");
        if (cAt != null) order.setCreatedAt(cAt.toLocalDateTime());
        if (uAt != null) order.setUpdatedAt(uAt.toLocalDateTime());

        order.setCreatedBy(rs.getInt("created_by"));
        order.setTableNumber(rs.getString("table_number"));
        order.setWaiterName(rs.getString("waiter_name"));

        return order;
    }

    private OrderItem mapResultSetToOrderItem(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();

        item.setOrderItemId(rs.getLong("order_item_id"));
        item.setOrderId(rs.getLong("order_id"));
        item.setMenuItemId(rs.getInt("menu_item_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setSpecialInstructions(rs.getString("special_instructions"));
        item.setPriority(rs.getString("priority"));
        item.setCourse(rs.getString("course"));
        item.setBaseUnitPrice(rs.getBigDecimal("base_unit_price"));
        item.setFinalUnitPrice(rs.getBigDecimal("final_unit_price"));
        item.setTotalPrice(rs.getBigDecimal("total_price"));
        item.setStatus(rs.getString("status"));

        Timestamp cAt = rs.getTimestamp("created_at");
        Timestamp uAt = rs.getTimestamp("updated_at");
        if (cAt != null) item.setCreatedAt(cAt.toLocalDateTime());
        if (uAt != null) item.setUpdatedAt(uAt.toLocalDateTime());

        item.setCreatedBy(rs.getInt("created_by"));
        item.setMenuItemName(rs.getString("menu_item_name"));
        item.setMenuItemDescription(rs.getString("menu_item_description"));
        item.setPreparationTime(rs.getInt("preparation_time"));

        return item;
    }

    /**
     * Helper nội bộ:
     * Xây dựng 1 MenuItem "ảo" chỉ với itemId + basePrice hiện tại
     * để đưa vào PricingService.getCurrentPrice().
     *
     * Vì PricingService cần MenuItem (có itemId và basePrice),
     * nhưng ở luồng addOrderItem chúng ta chỉ có menuItemId và baseUnitPrice,
     * chưa chắc đã load đầy đủ MenuItem từ DB.
     */
    private MenuItem buildTempMenuItem(int menuItemId, BigDecimal basePrice) {
        MenuItem mi = new MenuItem();
        mi.setItemId(menuItemId);
        mi.setBasePrice(basePrice);
        return mi;
    }
}
