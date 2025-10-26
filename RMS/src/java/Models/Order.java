package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * @author donny
 */
public class Order implements Serializable {
    private static final long serialVersionUID = 1L;

    // Order types
    public static final String TYPE_DINE_IN = "DINE_IN";
    public static final String TYPE_TAKEAWAY = "TAKEAWAY";
    public static final String TYPE_DELIVERY = "DELIVERY";
    
    // Order status
    public static final String STATUS_OPEN = "OPEN";
    public static final String STATUS_SENT_TO_KITCHEN = "SENT_TO_KITCHEN";
    public static final String STATUS_COOKING = "COOKING";
    public static final String STATUS_PARTIAL_READY = "PARTIAL_READY";
    public static final String STATUS_READY = "READY";
    public static final String STATUS_SERVED = "SERVED";
    public static final String STATUS_CANCELLED = "CANCELLED";
    public static final String STATUS_SETTLED = "SETTLED";

    private Long orderId;
    private String orderType;
    private Integer tableId;
    private Integer waiterId;
    private String status;
    private BigDecimal subtotal;
    private BigDecimal taxAmount;
    private BigDecimal totalAmount;
    private String specialInstructions;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer createdBy;
    private Integer updatedBy;
    
    // Join fields
    private String tableNumber;
    private String waiterName;
    private List<OrderItem> orderItems;

    // Constructors
    public Order() {}

    public Order(String orderType, Integer tableId, Integer waiterId) {
        this.orderType = orderType;
        this.tableId = tableId;
        this.waiterId = waiterId;
        this.status = STATUS_OPEN;
        this.subtotal = BigDecimal.ZERO;
        this.taxAmount = BigDecimal.ZERO;
        this.totalAmount = BigDecimal.ZERO;
    }

    // Getters and Setters
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }

    public String getOrderType() { return orderType; }
    public void setOrderType(String orderType) { this.orderType = orderType; }

    public Integer getTableId() { return tableId; }
    public void setTableId(Integer tableId) { this.tableId = tableId; }

    public Integer getWaiterId() { return waiterId; }
    public void setWaiterId(Integer waiterId) { this.waiterId = waiterId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getSpecialInstructions() { return specialInstructions; }
    public void setSpecialInstructions(String specialInstructions) { this.specialInstructions = specialInstructions; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }

    public String getWaiterName() { return waiterName; }
    public void setWaiterName(String waiterName) { this.waiterName = waiterName; }

    public List<OrderItem> getOrderItems() { return orderItems; }
    public void setOrderItems(List<OrderItem> orderItems) { this.orderItems = orderItems; }

    // Helper methods
    public boolean isOpen() { return STATUS_OPEN.equals(status); }
    public boolean isSentToKitchen() { return STATUS_SENT_TO_KITCHEN.equals(status); }
    public boolean isCooking() { return STATUS_COOKING.equals(status); }
    public boolean isPartialReady() { return STATUS_PARTIAL_READY.equals(status); }
    public boolean isReady() { return STATUS_READY.equals(status); }
    public boolean isServed() { return STATUS_SERVED.equals(status); }
    public boolean isCancelled() { return STATUS_CANCELLED.equals(status); }
    public boolean isSettled() { return STATUS_SETTLED.equals(status); }
}
