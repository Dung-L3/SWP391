package Dal;

import Models.Order;
import Models.OrderItem;
import Models.PricingRule;
import Models.MenuItem;
import java.sql.*;
import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

/**
 * @author donny
 */
public class OrderDAO {

    /**
     * Tạo order mới
     */
    public Long createOrder(Order order) throws SQLException {
        String sql = """
            INSERT INTO orders (order_type, table_id, waiter_id, status, subtotal, tax_amount, total_amount, 
                               special_instructions, created_at, updated_at, created_by)
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
            SELECT o.*, dt.table_number, u.first_name + ' ' + u.last_name as waiter_name
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
     * Lấy order theo table ID
     */
    public Order getOrderByTableId(Integer tableId) throws SQLException {
        String sql = """
            SELECT o.*, dt.table_number, u.first_name + ' ' + u.last_name as waiter_name
            FROM orders o
            LEFT JOIN dining_table dt ON dt.table_id = o.table_id
            LEFT JOIN users u ON u.user_id = o.waiter_id
            WHERE o.table_id = ? AND o.status IN ('NEW', 'CONFIRMED', 'PREPARING', 'READY')
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
     * Thêm item vào order
     */
    public Long addOrderItem(OrderItem orderItem) throws SQLException {
        // Tính final price với pricing rules
        BigDecimal finalPrice = calculateFinalPrice(orderItem.getMenuItemId(), orderItem.getBaseUnitPrice());
        orderItem.setFinalUnitPrice(finalPrice);
        orderItem.setTotalPrice(finalPrice.multiply(BigDecimal.valueOf(orderItem.getQuantity())));

        String sql = """
            INSERT INTO order_items (order_id, menu_item_id, quantity, special_instructions, priority, 
                                   course, base_unit_price, final_unit_price, total_price, status, 
                                   created_at, updated_at, created_by)
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
            ps.setBigDecimal(7, orderItem.getBaseUnitPrice());
            ps.setBigDecimal(8, orderItem.getFinalUnitPrice());
            ps.setBigDecimal(9, orderItem.getTotalPrice());
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
     * Lấy danh sách items của order
     */
    public List<OrderItem> getOrderItems(Long orderId) throws SQLException {
        String sql = """
            SELECT oi.*, mi.name as menu_item_name, mi.description as menu_item_description, 
                   mi.preparation_time
            FROM order_items oi
            LEFT JOIN menu_items mi ON mi.item_id = oi.menu_item_id
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
     * Cập nhật order
     */
    public boolean updateOrder(Order order) throws SQLException {
        String sql = """
            UPDATE orders SET status = ?, subtotal = ?, tax_amount = ?, total_amount = ?, 
                            special_instructions = ?, updated_at = ?, updated_by = ?
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
     * Cập nhật order item
     */
    public boolean updateOrderItem(OrderItem orderItem) throws SQLException {
        String sql = """
            UPDATE order_items SET quantity = ?, special_instructions = ?, priority = ?, 
                                 course = ?, final_unit_price = ?, total_price = ?, status = ?, 
                                 updated_at = ?, updated_by = ?
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

    /**
     * Tính final price với pricing rules
     */
    private BigDecimal calculateFinalPrice(Integer menuItemId, BigDecimal basePrice) throws SQLException {
        List<PricingRule> rules = getApplicablePricingRules(menuItemId);
        BigDecimal finalPrice = basePrice;

        for (PricingRule rule : rules) {
            if (rule.isActive() && rule.isTimeInRange(LocalTime.now()) && 
                rule.isDayMatch(LocalDateTime.now().getDayOfWeek())) {
                
                if (rule.isPercentage()) {
                    BigDecimal adjustment = finalPrice.multiply(rule.getAdjustmentValue()).divide(BigDecimal.valueOf(100));
                    if (rule.isIncrease()) {
                        finalPrice = finalPrice.add(adjustment);
                    } else {
                        finalPrice = finalPrice.subtract(adjustment);
                    }
                } else if (rule.isFixedAmount()) {
                    if (rule.isIncrease()) {
                        finalPrice = finalPrice.add(rule.getAdjustmentValue());
                    } else {
                        finalPrice = finalPrice.subtract(rule.getAdjustmentValue());
                    }
                }
            }
        }

        return finalPrice.max(BigDecimal.ZERO); // Không cho phép giá âm
    }

    /**
     * Lấy pricing rules áp dụng cho menu item
     */
    private List<PricingRule> getApplicablePricingRules(Integer menuItemId) throws SQLException {
        String sql = """
            SELECT * FROM pricing_rules 
            WHERE status = 'ACTIVE' 
            AND (menu_item_id = ? OR menu_item_id IS NULL)
            AND (valid_from IS NULL OR valid_from <= ?)
            AND (valid_to IS NULL OR valid_to >= ?)
            ORDER BY priority DESC, created_at DESC
        """;

        List<PricingRule> rules = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            LocalDateTime now = LocalDateTime.now();
            ps.setInt(1, menuItemId);
            ps.setTimestamp(2, Timestamp.valueOf(now));
            ps.setTimestamp(3, Timestamp.valueOf(now));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rules.add(mapResultSetToPricingRule(rs));
                }
            }
        }
        return rules;
    }

    /**
     * Map ResultSet to Order
     */
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
        order.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        order.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        order.setCreatedBy(rs.getInt("created_by"));
        order.setTableNumber(rs.getString("table_number"));
        order.setWaiterName(rs.getString("waiter_name"));
        return order;
    }

    /**
     * Map ResultSet to OrderItem
     */
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
        item.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        item.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        item.setCreatedBy(rs.getInt("created_by"));
        item.setMenuItemName(rs.getString("menu_item_name"));
        item.setMenuItemDescription(rs.getString("menu_item_description"));
        item.setPreparationTime(rs.getInt("preparation_time"));
        return item;
    }

    /**
     * Map ResultSet to PricingRule
     */
    private PricingRule mapResultSetToPricingRule(ResultSet rs) throws SQLException {
        PricingRule rule = new PricingRule();
        rule.setPricingRuleId(rs.getLong("pricing_rule_id"));
        rule.setRuleName(rs.getString("rule_name"));
        rule.setRuleType(rs.getString("rule_type"));
        rule.setDayOfWeek(rs.getString("day_of_week"));
        if (rs.getTime("start_time") != null) {
            rule.setStartTime(rs.getTime("start_time").toLocalTime());
        }
        if (rs.getTime("end_time") != null) {
            rule.setEndTime(rs.getTime("end_time").toLocalTime());
        }
        rule.setAdjustmentValue(rs.getBigDecimal("adjustment_value"));
        rule.setAdjustmentType(rs.getString("adjustment_type"));
        rule.setMenuItemId(rs.getInt("menu_item_id"));
        rule.setCategoryId(rs.getInt("category_id"));
        rule.setStatus(rs.getString("status"));
        rule.setDescription(rs.getString("description"));
        rule.setPriority(rs.getInt("priority"));
        if (rs.getTimestamp("valid_from") != null) {
            rule.setValidFrom(rs.getTimestamp("valid_from").toLocalDateTime());
        }
        if (rs.getTimestamp("valid_to") != null) {
            rule.setValidTo(rs.getTimestamp("valid_to").toLocalDateTime());
        }
        rule.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        rule.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        rule.setCreatedBy(rs.getInt("created_by"));
        return rule;
    }
}
