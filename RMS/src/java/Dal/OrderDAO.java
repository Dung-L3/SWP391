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
                order_code,
                order_type,
                customer_id,
                table_id,
                waiter_id,
                status,
                notes,
                opened_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, "ORD" + System.currentTimeMillis());
            ps.setString(2, order.getOrderType());
            // customer_id may be null
            if (order.getCustomerId() != null) {
                ps.setInt(3, order.getCustomerId());
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            ps.setInt(4, order.getTableId());
            ps.setInt(5, order.getWaiterId());
            ps.setString(6, order.getStatus());
            ps.setString(7, order.getSpecialInstructions());
            ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));

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
              AND o.status IN ('OPEN', 'SENT_TO_KITCHEN', 'COOKING', 'PARTIAL_READY', 'READY')
            ORDER BY o.opened_at DESC
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

            ps.setLong(1, orderItem.getOrderId());
            ps.setInt(2, orderItem.getMenuItemId());
            ps.setInt(3, orderItem.getQuantity());
            ps.setString(4, orderItem.getSpecialInstructions());
            ps.setString(5, orderItem.getPriority());
            
            // Convert course string to tinyint (course_no)
            int courseNo = 1; // Default to 1
            if ("APPETIZER".equalsIgnoreCase(orderItem.getCourse())) {
                courseNo = 1;
            } else if ("MAIN".equalsIgnoreCase(orderItem.getCourse())) {
                courseNo = 2;
            } else if ("DESSERT".equalsIgnoreCase(orderItem.getCourse())) {
                courseNo = 3;
            } else if ("BEVERAGE".equalsIgnoreCase(orderItem.getCourse())) {
                courseNo = 4;
            }
            ps.setInt(6, courseNo);
            
            ps.setBigDecimal(7, orderItem.getBaseUnitPrice());   // giá gốc lúc order
            ps.setBigDecimal(8, orderItem.getFinalUnitPrice());  // giá sau rule
            ps.setString(9, orderItem.getStatus());
            ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));

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
     * Lấy danh sách món sẵn sàng (READY) cho một bàn
     */
    public List<OrderItem> getReadyItemsForTable(Integer tableId) throws SQLException {
        String sql = """
            SELECT oi.order_item_id, oi.order_id, oi.menu_item_id, oi.quantity,
                   oi.special_instructions, oi.priority, oi.course_no, oi.status,
                   oi.served_by, oi.served_at,
                   mi.name AS menu_item_name,
                   dt.table_number, o.order_id
            FROM order_items oi
            JOIN orders o ON o.order_id = oi.order_id
            LEFT JOIN dining_table dt ON dt.table_id = o.table_id
            LEFT JOIN menu_items mi ON mi.menu_item_id = oi.menu_item_id
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
                    items.add(mapResultSetToOrderItem(rs));
                }
            }
        }
        return items;
    }
    
    /**
     * Lấy lịch sử order items của một bàn (tất cả món đã gọi, trạng thái hiện tại)
     * @author donny
     */
    public List<OrderItem> getTableHistory(Integer tableId) throws SQLException {
        String sql = """
            SELECT oi.order_item_id, oi.order_id, oi.menu_item_id, oi.quantity,
                   oi.special_instructions, oi.priority, oi.course_no, oi.status,
                   oi.served_by, oi.served_at, oi.created_at,
                   oi.base_unit_price, oi.final_unit_price,
                   mi.name AS menu_item_name,
                   dt.table_number,
                   o.order_id, o.opened_at AS order_time,
                   u.username AS waiter_name
            FROM order_items oi
            JOIN orders o ON o.order_id = oi.order_id
            LEFT JOIN dining_table dt ON dt.table_id = o.table_id
            LEFT JOIN menu_items mi ON mi.menu_item_id = oi.menu_item_id
            LEFT JOIN users u ON u.user_id = o.waiter_id
            WHERE o.table_id = ?
            ORDER BY oi.order_item_id DESC
        """;
        
        List<OrderItem> items = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tableId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = mapResultSetToOrderItem(rs);
                    // Map additional fields for history
                    item.setTableNumber(rs.getString("table_number"));
                    Timestamp orderTime = rs.getTimestamp("order_time");
                    if (orderTime != null) {
                        item.setCreatedAt(orderTime.toLocalDateTime());
                    }
                    items.add(item);
                    System.out.println("📦 Added item to history: " + item.getMenuItemName() + ", Status: " + item.getStatus());
                }
            }
        }
        System.out.println("📊 Total items in table history: " + items.size());
        return items;
    }

    /**
     * Update order tổng (status, tiền, note,...)
     */
    public boolean updateOrder(Order order) throws SQLException {
        String sql = """
            UPDATE orders
            SET status = ?
            WHERE order_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, order.getStatus());
            ps.setLong(2, order.getOrderId());

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
        // customer_id may be null
        try {
            Integer custId = rs.getObject("customer_id", Integer.class);
            if (custId != null) order.setCustomerId(custId);
        } catch (Exception e) {
            // column may not exist in older schemas; ignore
        }
        order.setWaiterId(rs.getInt("waiter_id"));
        order.setStatus(rs.getString("status"));
        
        // Set default values
        order.setSubtotal(BigDecimal.ZERO);
        order.setTaxAmount(BigDecimal.ZERO);
        order.setTotalAmount(BigDecimal.ZERO);
        
        // Use notes column instead of special_instructions
        order.setSpecialInstructions(rs.getString("notes"));

        // Use opened_at instead of created_at
        Timestamp openedAt = rs.getTimestamp("opened_at");
        if (openedAt != null) order.setCreatedAt(openedAt.toLocalDateTime());
        
        // Use closed_at instead of updated_at
        Timestamp closedAt = rs.getTimestamp("closed_at");
        if (closedAt != null) order.setUpdatedAt(closedAt.toLocalDateTime());

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
        
        // Check for course_no first, fallback to course
        String course = null;
        try {
            course = rs.getString("course_no");
        } catch (Exception e) {
            course = rs.getString("course");
        }
        item.setCourse(course);
        item.setBaseUnitPrice(rs.getBigDecimal("base_unit_price"));
        item.setFinalUnitPrice(rs.getBigDecimal("final_unit_price"));
        // total_price column doesn't exist in order_items table
        BigDecimal totalPrice = null;
        try {
            totalPrice = rs.getBigDecimal("total_price");
        } catch (Exception e) {
            // Calculate total price if not in result set
            if (item.getFinalUnitPrice() != null && item.getQuantity() != null) {
                totalPrice = item.getFinalUnitPrice().multiply(new BigDecimal(item.getQuantity()));
            }
        }
        item.setTotalPrice(totalPrice);
        item.setStatus(rs.getString("status"));

        Timestamp cAt = rs.getTimestamp("created_at");
        if (cAt != null) item.setCreatedAt(cAt.toLocalDateTime());
        
        Timestamp uAt = null;
        try {
            uAt = rs.getTimestamp("updated_at");
        } catch (Exception e) {
            // updated_at doesn't exist
        }
        if (uAt != null) item.setUpdatedAt(uAt.toLocalDateTime());

        Integer createdBy = null;
        try {
            createdBy = rs.getObject("created_by", Integer.class);
        } catch (Exception e) {
            // created_by doesn't exist
        }
        if (createdBy != null) item.setCreatedBy(createdBy);
        
        String menuItemName = rs.getString("menu_item_name");
        if (menuItemName != null) item.setMenuItemName(menuItemName);
        
        String menuItemDesc = null;
        try {
            menuItemDesc = rs.getString("menu_item_description");
        } catch (Exception e) {
            // menu_item_description doesn't exist in result set
        }
        if (menuItemDesc != null) item.setMenuItemDescription(menuItemDesc);
        
        Integer prepTime = null;
        try {
            prepTime = rs.getObject("preparation_time", Integer.class);
        } catch (Exception e) {
            // preparation_time doesn't exist in result set
        }
        if (prepTime != null) item.setPreparationTime(prepTime);
        
        // Try to get table_number (may not exist in all queries)
        try {
            String tableNumber = rs.getString("table_number");
            if (tableNumber != null) item.setTableNumber(tableNumber);
        } catch (Exception e) {
            // table_number doesn't exist in this result set
        }

        // Served fields
        Integer servedBy = rs.getObject("served_by", Integer.class);
        if (servedBy != null) item.setServedBy(servedBy);
        
        Timestamp servedAt = rs.getTimestamp("served_at");
        if (servedAt != null) item.setServedAt(servedAt.toLocalDateTime());

        return item;
    }

    /**
     * Lấy order item theo ID
     * @author donny
     */
    public OrderItem getOrderItemById(Long orderItemId) throws SQLException {
        String sql = """
            SELECT oi.*,
                   mi.name AS menu_item_name,
                   mi.description AS menu_item_description,
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
                    return mapResultSetToOrderItem(rs);
                }
            }
        }

        return null;
    }

    /**
     * Mark order item as served
     * @author donny
     */
    public boolean markOrderItemAsServed(Long orderItemId, Integer servedBy) throws SQLException {
        String sql = """
            UPDATE order_items
            SET status = 'SERVED',
                served_by = ?,
                served_at = ?
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

    /**
     * Check if all items in an order are served
     * @author donny
     */
    public boolean areAllItemsServed(Long orderId) throws SQLException {
        String sql = """
            SELECT COUNT(*) as total,
                   SUM(CASE WHEN status = 'SERVED' THEN 1 ELSE 0 END) as served_count
            FROM order_items
            WHERE order_id = ?
              AND status != 'CANCELLED'
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total");
                    int servedCount = rs.getInt("served_count");
                    return total > 0 && total == servedCount;
                }
            }
        }

        return false;
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
