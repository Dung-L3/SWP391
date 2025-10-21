package Models;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

/**
 * @author donny
 */
public class TableSession implements Serializable {
    private static final long serialVersionUID = 1L;

    private long tableSessionId;
    private int tableId;
    private LocalDateTime openTime;
    private LocalDateTime closeTime;
    private String status; // OPEN, CLOSED
    private Long currentOrderId;
    private Integer customerCount;
    private String notes;
    private Integer createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Thông tin bàn (join từ dining_table)
    private String tableNumber;
    private String tableStatus;
    private int tableCapacity;

    /* ================= Constructors ================= */
    public TableSession() {}

    public TableSession(int tableId, String status) {
        this.tableId = tableId;
        this.status = status;
        this.openTime = LocalDateTime.now();
    }

    /* ================= Getters & Setters ================= */
    public long getTableSessionId() { return tableSessionId; }
    public void setTableSessionId(long tableSessionId) { this.tableSessionId = tableSessionId; }

    public int getTableId() { return tableId; }
    public void setTableId(int tableId) { this.tableId = tableId; }

    public LocalDateTime getOpenTime() { return openTime; }
    public void setOpenTime(LocalDateTime openTime) { this.openTime = openTime; }

    public LocalDateTime getCloseTime() { return closeTime; }
    public void setCloseTime(LocalDateTime closeTime) { this.closeTime = closeTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Long getCurrentOrderId() { return currentOrderId; }
    public void setCurrentOrderId(Long currentOrderId) { this.currentOrderId = currentOrderId; }

    public Integer getCustomerCount() { return customerCount; }
    public void setCustomerCount(Integer customerCount) { this.customerCount = customerCount; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }

    public String getTableStatus() { return tableStatus; }
    public void setTableStatus(String tableStatus) { this.tableStatus = tableStatus; }

    public int getTableCapacity() { return tableCapacity; }
    public void setTableCapacity(int tableCapacity) { this.tableCapacity = tableCapacity; }

    /* ================= Helper Methods ================= */
    public boolean isOpen() {
        return "OPEN".equals(status);
    }

    public boolean isClosed() {
        return "CLOSED".equals(status);
    }

    public String getStatusDisplay() {
        switch (status) {
            case "OPEN": return "Đang mở";
            case "CLOSED": return "Đã đóng";
            default: return status;
        }
    }

    public long getDurationMinutes() {
        if (openTime == null) return 0;
        LocalDateTime endTime = (closeTime != null) ? closeTime : LocalDateTime.now();
        return java.time.Duration.between(openTime, endTime).toMinutes();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TableSession that = (TableSession) o;
        return tableSessionId == that.tableSessionId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(tableSessionId);
    }

    @Override
    public String toString() {
        return "TableSession{" +
                "tableSessionId=" + tableSessionId +
                ", tableId=" + tableId +
                ", status='" + status + '\'' +
                ", openTime=" + openTime +
                '}';
    }
}


