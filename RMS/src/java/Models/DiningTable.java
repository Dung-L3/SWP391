package Models;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

/**
 * @author donny
 */
public class DiningTable implements Serializable {
    private static final long serialVersionUID = 1L;

    private int tableId;
    private Integer areaId;
    private String tableNumber;
    private int capacity;
    private String location;
    private String status; // VACANT, HELD, SEATED, IN_USE, REQUEST_BILL, CLEANING, OUT_OF_SERVICE
    private String tableType; // REGULAR, VIP, OUTDOOR, BAR
    private Integer mapX;
    private Integer mapY;
    private Integer createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Thông tin khu vực (join từ table_area)
    private String areaName;
    
    // Thông tin session hiện tại (join từ table_session)
    private Long currentSessionId;
    private String sessionStatus; // OPEN, CLOSED
    private LocalDateTime sessionOpenTime;
    private Long currentOrderId;

    /* ================= Constructors ================= */
    public DiningTable() {}

    public DiningTable(int tableId, String tableNumber, int capacity, String status) {
        this.tableId = tableId;
        this.tableNumber = tableNumber;
        this.capacity = capacity;
        this.status = status;
    }

    /* ================= Getters & Setters ================= */
    public int getTableId() { return tableId; }
    public void setTableId(int tableId) { this.tableId = tableId; }

    public Integer getAreaId() { return areaId; }
    public void setAreaId(Integer areaId) { this.areaId = areaId; }

    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getTableType() { return tableType; }
    public void setTableType(String tableType) { this.tableType = tableType; }

    public Integer getMapX() { return mapX; }
    public void setMapX(Integer mapX) { this.mapX = mapX; }

    public Integer getMapY() { return mapY; }
    public void setMapY(Integer mapY) { this.mapY = mapY; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getAreaName() { return areaName; }
    public void setAreaName(String areaName) { this.areaName = areaName; }

    public Long getCurrentSessionId() { return currentSessionId; }
    public void setCurrentSessionId(Long currentSessionId) { this.currentSessionId = currentSessionId; }

    public String getSessionStatus() { return sessionStatus; }
    public void setSessionStatus(String sessionStatus) { this.sessionStatus = sessionStatus; }

    public LocalDateTime getSessionOpenTime() { return sessionOpenTime; }
    public void setSessionOpenTime(LocalDateTime sessionOpenTime) { this.sessionOpenTime = sessionOpenTime; }

    public Long getCurrentOrderId() { return currentOrderId; }
    public void setCurrentOrderId(Long currentOrderId) { this.currentOrderId = currentOrderId; }

    /* ================= Helper Methods ================= */
    public boolean isVacant() {
        return "VACANT".equals(status);
    }

    public boolean isSeated() {
        return "SEATED".equals(status);
    }

    public boolean isInUse() {
        return "IN_USE".equals(status);
    }

    public boolean isCleaning() {
        return "CLEANING".equals(status);
    }

    public String getStatusDisplay() {
        switch (status) {
            case "VACANT": return "Trống";
            case "HELD": return "Giữ chỗ";
            case "SEATED": return "Có khách";
            case "IN_USE": return "Đang dùng";
            case "REQUEST_BILL": return "Yêu cầu thanh toán";
            case "CLEANING": return "Đang dọn dẹp";
            case "OUT_OF_SERVICE": return "Không phục vụ";
            default: return status;
        }
    }

    public String getTableTypeDisplay() {
        switch (tableType) {
            case "REGULAR": return "Thường";
            case "VIP": return "VIP";
            case "OUTDOOR": return "Ngoài trời";
            case "BAR": return "Quầy bar";
            default: return tableType;
        }
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        DiningTable that = (DiningTable) o;
        return tableId == that.tableId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(tableId);
    }

    @Override
    public String toString() {
        return "DiningTable{" +
                "tableId=" + tableId +
                ", tableNumber='" + tableNumber + '\'' +
                ", capacity=" + capacity +
                ", status='" + status + '\'' +
                '}';
    }
}


