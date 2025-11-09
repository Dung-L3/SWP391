package Models;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Model cho thông báo hệ thống
 */
public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // Notification types
    public static final String TYPE_ORDER_CANCELLED = "ORDER_CANCELLED";
    public static final String TYPE_MENU_ITEM_SUSPEND = "MENU_ITEM_SUSPEND";
    
    // Notification status
    public static final String STATUS_UNREAD = "UNREAD";
    public static final String STATUS_READ = "READ";
    
    private Long notificationId;
    private String notificationType;
    private String title;
    private String message;
    private String status;
    private Integer menuItemId; // ID của món ăn liên quan (nếu có)
    private Integer orderItemId; // ID của order item liên quan (nếu có)
    private Integer createdBy; // ID của người tạo thông báo (chef)
    private LocalDateTime createdAt;
    private LocalDateTime readAt;
    
    // Join fields
    private String chefName;
    private String menuItemName;
    private String tableNumber;
    private String cancelReason;
    
    // Constructors
    public Notification() {
        this.status = STATUS_UNREAD;
        this.createdAt = LocalDateTime.now();
    }
    
    public Notification(String notificationType, String title, String message) {
        this();
        this.notificationType = notificationType;
        this.title = title;
        this.message = message;
    }
    
    // Getters and Setters
    public Long getNotificationId() { return notificationId; }
    public void setNotificationId(Long notificationId) { this.notificationId = notificationId; }
    
    public String getNotificationType() { return notificationType; }
    public void setNotificationType(String notificationType) { this.notificationType = notificationType; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Integer getMenuItemId() { return menuItemId; }
    public void setMenuItemId(Integer menuItemId) { this.menuItemId = menuItemId; }
    
    public Integer getOrderItemId() { return orderItemId; }
    public void setOrderItemId(Integer orderItemId) { this.orderItemId = orderItemId; }
    
    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getReadAt() { return readAt; }
    public void setReadAt(LocalDateTime readAt) { this.readAt = readAt; }
    
    public String getChefName() { return chefName; }
    public void setChefName(String chefName) { this.chefName = chefName; }
    
    public String getMenuItemName() { return menuItemName; }
    public void setMenuItemName(String menuItemName) { this.menuItemName = menuItemName; }
    
    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }
    
    public String getCancelReason() { return cancelReason; }
    public void setCancelReason(String cancelReason) { this.cancelReason = cancelReason; }
    
    // Helper methods
    public boolean isUnread() { return STATUS_UNREAD.equals(status); }
    public boolean isRead() { return STATUS_READ.equals(status); }
}

