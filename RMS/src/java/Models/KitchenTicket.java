package Models;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * @author donny
 */
public class KitchenTicket implements Serializable {
    private static final long serialVersionUID = 1L;

    // Preparation status
    public static final String STATUS_RECEIVED = "RECEIVED";
    public static final String STATUS_COOKING = "COOKING";
    public static final String STATUS_READY = "READY";
    public static final String STATUS_PICKED = "PICKED";
    public static final String STATUS_SERVED = "SERVED";
    public static final String STATUS_CANCELLED = "CANCELLED";

    // Kitchen stations
    public static final String STATION_HOT = "HOT";
    public static final String STATION_COLD = "COLD";
    public static final String STATION_BEVERAGE = "BEVERAGE";
    public static final String STATION_DESSERT = "DESSERT";
    public static final String STATION_GRILL = "GRILL";
    public static final String STATION_SAUCE = "SAUCE";

    private Long kitchenTicketId;
    private Long orderItemId;
    private String station;
    private String preparationStatus;
    private LocalDateTime receivedTime;
    private LocalDateTime startTime;
    private LocalDateTime readyTime;
    private LocalDateTime pickedTime;
    private LocalDateTime servedTime;
    private String notes;
    private Integer estimatedMinutes;
    private Integer actualMinutes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer createdBy;
    private Integer updatedBy;
    private Integer chefId;
    
    // Join fields
    private String orderNumber;
    private String tableNumber;
    private String menuItemName;
    private Integer quantity;
    private String specialInstructions;
    private String priority;
    private String course;
    private Long orderId;

    // Constructors
    public KitchenTicket() {}

    public KitchenTicket(Long orderItemId, String station) {
        this.orderItemId = orderItemId;
        this.station = station;
        this.preparationStatus = STATUS_RECEIVED;
        this.receivedTime = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getKitchenTicketId() { return kitchenTicketId; }
    public void setKitchenTicketId(Long kitchenTicketId) { this.kitchenTicketId = kitchenTicketId; }

    public Long getOrderItemId() { return orderItemId; }
    public void setOrderItemId(Long orderItemId) { this.orderItemId = orderItemId; }

    public String getStation() { return station; }
    public void setStation(String station) { this.station = station; }

    public String getPreparationStatus() { return preparationStatus; }
    public void setPreparationStatus(String preparationStatus) { this.preparationStatus = preparationStatus; }

    public LocalDateTime getReceivedTime() { return receivedTime; }
    public void setReceivedTime(LocalDateTime receivedTime) { this.receivedTime = receivedTime; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

    public LocalDateTime getReadyTime() { return readyTime; }
    public void setReadyTime(LocalDateTime readyTime) { this.readyTime = readyTime; }

    public LocalDateTime getPickedTime() { return pickedTime; }
    public void setPickedTime(LocalDateTime pickedTime) { this.pickedTime = pickedTime; }

    public LocalDateTime getServedTime() { return servedTime; }
    public void setServedTime(LocalDateTime servedTime) { this.servedTime = servedTime; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Integer getEstimatedMinutes() { return estimatedMinutes; }
    public void setEstimatedMinutes(Integer estimatedMinutes) { this.estimatedMinutes = estimatedMinutes; }

    public Integer getActualMinutes() { return actualMinutes; }
    public void setActualMinutes(Integer actualMinutes) { this.actualMinutes = actualMinutes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    public Integer getChefId() { return chefId; }
    public void setChefId(Integer chefId) { this.chefId = chefId; }

    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
    
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }

    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }

    public String getMenuItemName() { return menuItemName; }
    public void setMenuItemName(String menuItemName) { this.menuItemName = menuItemName; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public String getSpecialInstructions() { return specialInstructions; }
    public void setSpecialInstructions(String specialInstructions) { this.specialInstructions = specialInstructions; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getCourse() { return course; }
    public void setCourse(String course) { this.course = course; }

    // Helper methods
    public boolean isReceived() { return STATUS_RECEIVED.equals(preparationStatus); }
    public boolean isCooking() { return STATUS_COOKING.equals(preparationStatus); }
    public boolean isReady() { return STATUS_READY.equals(preparationStatus); }
    public boolean isPicked() { return STATUS_PICKED.equals(preparationStatus); }
    public boolean isServed() { return STATUS_SERVED.equals(preparationStatus); }
    public boolean isCancelled() { return STATUS_CANCELLED.equals(preparationStatus); }

    public boolean isHotStation() { return STATION_HOT.equals(station) || STATION_GRILL.equals(station) || STATION_SAUCE.equals(station); }
    public boolean isColdStation() { return STATION_COLD.equals(station) || STATION_BEVERAGE.equals(station) || STATION_DESSERT.equals(station); }
}
