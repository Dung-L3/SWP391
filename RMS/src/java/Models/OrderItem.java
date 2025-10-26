package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * @author donny
 */
public class OrderItem implements Serializable {
    private static final long serialVersionUID = 1L;

    // Order item status
    public static final String STATUS_NEW = "NEW";
    public static final String STATUS_SENT = "SENT";
    public static final String STATUS_RECEIVED = "RECEIVED";
    public static final String STATUS_COOKING = "COOKING";
    public static final String STATUS_READY = "READY";
    public static final String STATUS_PICKED = "PICKED";
    public static final String STATUS_SERVED = "SERVED";
    public static final String STATUS_CANCELLED = "CANCELLED";

    // Priority levels
    public static final String PRIORITY_LOW = "LOW";
    public static final String PRIORITY_NORMAL = "NORMAL";
    public static final String PRIORITY_HIGH = "HIGH";
    public static final String PRIORITY_URGENT = "URGENT";

    // Course types
    public static final String COURSE_APPETIZER = "APPETIZER";
    public static final String COURSE_MAIN = "MAIN";
    public static final String COURSE_DESSERT = "DESSERT";
    public static final String COURSE_BEVERAGE = "BEVERAGE";

    private Long orderItemId;
    private Long orderId;
    private Integer menuItemId;
    private Integer quantity;
    private String specialInstructions;
    private String priority;
    private String course;
    private BigDecimal baseUnitPrice;
    private BigDecimal finalUnitPrice;
    private BigDecimal totalPrice;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer createdBy;
    private Integer updatedBy;
    
    // Served fields
    private Integer servedBy;
    private LocalDateTime servedAt;
    
    // Join fields
    private String menuItemName;
    private String menuItemDescription;
    private Integer preparationTime;
    private String tableNumber;

    // Constructors
    public OrderItem() {}

    public OrderItem(Long orderId, Integer menuItemId, Integer quantity) {
        this.orderId = orderId;
        this.menuItemId = menuItemId;
        this.quantity = quantity;
        this.priority = PRIORITY_NORMAL;
        this.course = COURSE_MAIN;
        this.status = STATUS_NEW;
    }

    // Getters and Setters
    public Long getOrderItemId() { return orderItemId; }
    public void setOrderItemId(Long orderItemId) { this.orderItemId = orderItemId; }

    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }

    public Integer getMenuItemId() { return menuItemId; }
    public void setMenuItemId(Integer menuItemId) { this.menuItemId = menuItemId; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public String getSpecialInstructions() { return specialInstructions; }
    public void setSpecialInstructions(String specialInstructions) { this.specialInstructions = specialInstructions; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getCourse() { return course; }
    public void setCourse(String course) { this.course = course; }

    public BigDecimal getBaseUnitPrice() { return baseUnitPrice; }
    public void setBaseUnitPrice(BigDecimal baseUnitPrice) { this.baseUnitPrice = baseUnitPrice; }

    public BigDecimal getFinalUnitPrice() { return finalUnitPrice; }
    public void setFinalUnitPrice(BigDecimal finalUnitPrice) { this.finalUnitPrice = finalUnitPrice; }

    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    public String getMenuItemName() { return menuItemName; }
    public void setMenuItemName(String menuItemName) { this.menuItemName = menuItemName; }

    public String getMenuItemDescription() { return menuItemDescription; }
    public void setMenuItemDescription(String menuItemDescription) { this.menuItemDescription = menuItemDescription; }

    public Integer getPreparationTime() { return preparationTime; }
    public void setPreparationTime(Integer preparationTime) { this.preparationTime = preparationTime; }

    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }

    public Integer getServedBy() { return servedBy; }
    public void setServedBy(Integer servedBy) { this.servedBy = servedBy; }

    public LocalDateTime getServedAt() { return servedAt; }
    public void setServedAt(LocalDateTime servedAt) { this.servedAt = servedAt; }

    // Helper methods
    public boolean isNew() { return STATUS_NEW.equals(status); }
    public boolean isSent() { return STATUS_SENT.equals(status); }
    public boolean isReceived() { return STATUS_RECEIVED.equals(status); }
    public boolean isCooking() { return STATUS_COOKING.equals(status); }
    public boolean isReady() { return STATUS_READY.equals(status); }
    public boolean isPicked() { return STATUS_PICKED.equals(status); }
    public boolean isServed() { return STATUS_SERVED.equals(status); }
    public boolean isCancelled() { return STATUS_CANCELLED.equals(status); }

    public boolean isHighPriority() { return PRIORITY_HIGH.equals(priority) || PRIORITY_URGENT.equals(priority); }
    public boolean isUrgent() { return PRIORITY_URGENT.equals(priority); }
}
