package Dal;

import Models.Notification;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho quản lý thông báo - sử dụng bảng audit_log có sẵn
 */
public class NotificationDAO {
    
    // Action constants cho audit_log
    public static final String ACTION_ORDER_CANCELLED = "ORDER_CANCELLED";
    public static final String ACTION_NOTIFICATION = "NOTIFICATION";
    
    /**
     * Tạo thông báo mới - lưu vào audit_log
     */
    public Long createNotification(Notification notification) throws SQLException {
        // Tạo JSON string chứa thông tin thông báo (manual JSON construction)
        StringBuilder jsonBuilder = new StringBuilder();
        jsonBuilder.append("{");
        jsonBuilder.append("\"type\":\"").append(escapeJson(notification.getNotificationType())).append("\",");
        jsonBuilder.append("\"title\":\"").append(escapeJson(notification.getTitle())).append("\",");
        jsonBuilder.append("\"message\":\"").append(escapeJson(notification.getMessage())).append("\",");
        jsonBuilder.append("\"status\":\"").append(escapeJson(notification.getStatus())).append("\"");
        if (notification.getMenuItemId() != null) {
            jsonBuilder.append(",\"menu_item_id\":").append(notification.getMenuItemId());
        }
        if (notification.getOrderItemId() != null) {
            jsonBuilder.append(",\"order_item_id\":").append(notification.getOrderItemId());
        }
        if (notification.getCancelReason() != null) {
            jsonBuilder.append(",\"cancel_reason\":\"").append(escapeJson(notification.getCancelReason())).append("\"");
        }
        if (notification.getTableNumber() != null) {
            jsonBuilder.append(",\"table_number\":\"").append(escapeJson(notification.getTableNumber())).append("\"");
        }
        if (notification.getMenuItemName() != null) {
            jsonBuilder.append(",\"menu_item_name\":\"").append(escapeJson(notification.getMenuItemName())).append("\"");
        }
        jsonBuilder.append("}");
        String notifDataJson = jsonBuilder.toString();
        
        String sql = """
            INSERT INTO audit_log (
                user_id, action, table_name, record_id, 
                new_values, timestamp
            )
            VALUES (?, ?, ?, ?, ?, ?)
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setObject(1, notification.getCreatedBy());
            ps.setString(2, ACTION_ORDER_CANCELLED); // action
            ps.setString(3, "order_items"); // table_name
            ps.setObject(4, notification.getOrderItemId()); // record_id (order_item_id)
            ps.setString(5, notifDataJson); // new_values chứa JSON
            ps.setTimestamp(6, Timestamp.valueOf(
                notification.getCreatedAt() != null ? notification.getCreatedAt() : LocalDateTime.now()
            ));
            
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
     * Lấy tất cả thông báo chưa đọc cho manager - từ audit_log
     */
    public List<Notification> getUnreadNotifications() throws SQLException {
        String sql = """
            SELECT al.log_id, al.user_id, al.action, al.table_name, al.record_id,
                   al.new_values, al.old_values, al.timestamp,
                   u.first_name + ' ' + u.last_name AS chef_name,
                   TRY_CAST(JSON_VALUE(al.new_values, '$.menu_item_id') AS int) AS menu_item_id,
                   TRY_CAST(JSON_VALUE(al.new_values, '$.order_item_id') AS int) AS order_item_id,
                   JSON_VALUE(al.new_values, '$.title') AS title,
                   JSON_VALUE(al.new_values, '$.message') AS message,
                   JSON_VALUE(al.new_values, '$.type') AS notification_type,
                   JSON_VALUE(al.new_values, '$.table_number') AS table_number,
                   JSON_VALUE(al.new_values, '$.menu_item_name') AS menu_item_name,
                   JSON_VALUE(al.new_values, '$.cancel_reason') AS cancel_reason,
                   mi.name AS menu_item_name_from_db,
                   dt.table_number AS table_number_from_db
            FROM audit_log al
            LEFT JOIN users u ON al.user_id = u.user_id
            LEFT JOIN order_items oi ON al.record_id = oi.order_item_id
            LEFT JOIN orders o ON oi.order_id = o.order_id
            LEFT JOIN dining_table dt ON o.table_id = dt.table_id
            LEFT JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
            WHERE al.action = ?
              AND (al.old_values IS NULL OR al.old_values NOT LIKE '%"status":"READ"%')
            ORDER BY al.timestamp DESC
        """;
        
        List<Notification> notifications = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, ACTION_ORDER_CANCELLED);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapResultSetToNotification(rs));
                }
            }
        }
        return notifications;
    }
    
    /**
     * Lấy tất cả thông báo (đã đọc và chưa đọc) - từ audit_log
     */
    public List<Notification> getAllNotifications(int limit) throws SQLException {
        String selectClause = """
            al.log_id, al.user_id, al.action, al.table_name, al.record_id,
            al.new_values, al.old_values, al.timestamp,
            u.first_name + ' ' + u.last_name AS chef_name,
            TRY_CAST(JSON_VALUE(al.new_values, '$.menu_item_id') AS int) AS menu_item_id,
            TRY_CAST(JSON_VALUE(al.new_values, '$.order_item_id') AS int) AS order_item_id,
            JSON_VALUE(al.new_values, '$.title') AS title,
            JSON_VALUE(al.new_values, '$.message') AS message,
            JSON_VALUE(al.new_values, '$.type') AS notification_type,
            JSON_VALUE(al.new_values, '$.table_number') AS table_number,
            JSON_VALUE(al.new_values, '$.menu_item_name') AS menu_item_name,
            JSON_VALUE(al.new_values, '$.cancel_reason') AS cancel_reason,
            mi.name AS menu_item_name_from_db,
            dt.table_number AS table_number_from_db
        """;
        
        String fromClause = """
            FROM audit_log al
            LEFT JOIN users u ON al.user_id = u.user_id
            LEFT JOIN order_items oi ON al.record_id = oi.order_item_id
            LEFT JOIN orders o ON oi.order_id = o.order_id
            LEFT JOIN dining_table dt ON o.table_id = dt.table_id
            LEFT JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
            WHERE al.action = ?
            ORDER BY al.timestamp DESC
        """;
        
        String sql = limit > 0 
            ? "SELECT TOP (" + limit + ") " + selectClause + fromClause
            : "SELECT " + selectClause + fromClause;
        
        List<Notification> notifications = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, ACTION_ORDER_CANCELLED);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapResultSetToNotification(rs));
                }
            }
        }
        return notifications;
    }
    
    /**
     * Đánh dấu thông báo là đã đọc - cập nhật old_values trong audit_log
     */
    public boolean markAsRead(Long notificationId) throws SQLException {
        // Lấy new_values hiện tại
        String getSql = "SELECT new_values FROM audit_log WHERE log_id = ?";
        String newValuesJson = null;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(getSql)) {
            
            ps.setLong(1, notificationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    newValuesJson = rs.getString("new_values");
                }
            }
        }
        
        if (newValuesJson == null) {
            return false;
        }
        
        // Parse JSON và thêm status READ (simple string manipulation)
        String updatedJson = newValuesJson;
        if (!updatedJson.contains("\"status\"")) {
            // Thêm status vào cuối JSON (trước dấu })
            updatedJson = updatedJson.substring(0, updatedJson.length() - 1) + 
                         ",\"status\":\"READ\",\"read_at\":\"" + 
                         LocalDateTime.now().toString() + "\"}";
        } else {
            // Thay thế status nếu đã có
            updatedJson = updatedJson.replaceFirst("\"status\":\"[^\"]*\"", "\"status\":\"READ\"");
            if (!updatedJson.contains("\"read_at\"")) {
                updatedJson = updatedJson.substring(0, updatedJson.length() - 1) + 
                             ",\"read_at\":\"" + LocalDateTime.now().toString() + "\"}";
            }
        }
        
        // Cập nhật old_values với status READ
        String sql = """
            UPDATE audit_log 
            SET old_values = ?
            WHERE log_id = ?
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, updatedJson);
            ps.setLong(2, notificationId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Đếm số thông báo chưa đọc - từ audit_log
     */
    public int getUnreadCount() throws SQLException {
        String sql = """
            SELECT COUNT(*) 
            FROM audit_log 
            WHERE action = ?
              AND (old_values IS NULL OR old_values NOT LIKE '%"status":"READ"%')
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, ACTION_ORDER_CANCELLED);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
    
    /**
     * Map ResultSet sang Notification object - từ audit_log
     */
    private Notification mapResultSetToNotification(ResultSet rs) throws SQLException {
        Notification notification = new Notification();
        
        // log_id từ audit_log
        notification.setNotificationId(rs.getLong("log_id"));
        
        // Parse từ JSON trong new_values
        String title = rs.getString("title");
        String message = rs.getString("message");
        String notificationType = rs.getString("notification_type");
        
        if (title == null || title.isEmpty()) {
            title = rs.getString("title"); // Fallback
        }
        if (message == null || message.isEmpty()) {
            message = rs.getString("message"); // Fallback
        }
        
        notification.setTitle(title != null ? title : "Thông báo");
        notification.setMessage(message != null ? message : "");
        notification.setNotificationType(notificationType != null ? notificationType : Notification.TYPE_ORDER_CANCELLED);
        
        // Xác định status từ old_values
        String oldValues = rs.getString("old_values");
        if (oldValues != null && oldValues.contains("\"status\":\"READ\"")) {
            notification.setStatus(Notification.STATUS_READ);
        } else {
            notification.setStatus(Notification.STATUS_UNREAD);
        }
        
        // Lấy các trường từ JSON hoặc từ join
        try {
            Integer menuItemId = rs.getInt("menu_item_id");
            if (!rs.wasNull()) {
                notification.setMenuItemId(menuItemId);
            }
        } catch (SQLException e) {
            notification.setMenuItemId(null);
        }
        
        try {
            Integer orderItemId = rs.getInt("order_item_id");
            if (!rs.wasNull()) {
                notification.setOrderItemId(orderItemId);
            }
        } catch (SQLException e) {
            notification.setOrderItemId(null);
        }
        
        try {
            Integer userId = rs.getInt("user_id");
            if (!rs.wasNull()) {
                notification.setCreatedBy(userId);
            }
        } catch (SQLException e) {
            notification.setCreatedBy(null);
        }
        
        Timestamp timestamp = rs.getTimestamp("timestamp");
        if (timestamp != null) {
            notification.setCreatedAt(timestamp.toLocalDateTime());
        }
        
        // Join fields
        try {
            notification.setChefName(rs.getString("chef_name"));
        } catch (SQLException e) {
            // Ignore
        }
        
        // Ưu tiên menu_item_name từ JSON, nếu không có thì lấy từ DB
        String menuItemName = rs.getString("menu_item_name");
        if (menuItemName == null || menuItemName.isEmpty()) {
            menuItemName = rs.getString("menu_item_name_from_db");
        }
        notification.setMenuItemName(menuItemName);
        
        // Ưu tiên table_number từ JSON, nếu không có thì lấy từ DB
        String tableNumber = rs.getString("table_number");
        if (tableNumber == null || tableNumber.isEmpty()) {
            tableNumber = rs.getString("table_number_from_db");
        }
        notification.setTableNumber(tableNumber);
        
        try {
            notification.setCancelReason(rs.getString("cancel_reason"));
        } catch (SQLException e) {
            // Ignore
        }
        
        return notification;
    }
    
    /**
     * Escape JSON string
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}

