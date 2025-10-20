package Models;

public class Table {
    // Status constants
    public static final String STATUS_VACANT = "VACANT";
    public static final String STATUS_OCCUPIED = "OCCUPIED";
    public static final String STATUS_RESERVED = "RESERVED";
    
    // Type constants
    public static final String TYPE_REGULAR = "REGULAR";
    public static final String TYPE_VIP = "VIP";
    public static final String TYPE_OUTDOOR = "OUTDOOR";
    
    private int tableId;
    private String tableNumber;
    private String status;
    private String tableType;
    private int capacity;
    private int areaId;
    private Integer mapX;
    private Integer mapY;
    private String location;
    private Integer createdBy;

    // Constructors
    public Table() {
    }
    
    // Getters and Setters
    public int getTableId() {
        return tableId;
    }

    public void setTableId(int tableId) {
        this.tableId = tableId;
    }

    public int getAreaId() {
        return areaId;
    }

    public void setAreaId(int areaId) {
        this.areaId = areaId;
    }

    public String getTableNumber() {
        return tableNumber;
    }

    public void setTableNumber(String tableNumber) {
        this.tableNumber = tableNumber;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getTableType() {
        return tableType;
    }

    public void setTableType(String tableType) {
        this.tableType = tableType;
    }
    
    public Integer getMapX() {
        return mapX;
    }
    
    public void setMapX(Integer mapX) {
        this.mapX = mapX;
    }
    
    public Integer getMapY() {
        return mapY;
    }
    
    public void setMapY(Integer mapY) {
        this.mapY = mapY;
    }
    
    public Integer getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }
    
    // Helper methods
    public boolean isVacant() {
        return STATUS_VACANT.equals(this.status);
    }
    
    public boolean isOccupied() {
        return STATUS_OCCUPIED.equals(this.status);
    }
    
    public boolean isOutdoor() {
        return TYPE_OUTDOOR.equals(this.tableType);
    }
    
    public boolean isVip() {
        return TYPE_VIP.equals(this.tableType);
    }
    
    public String getCssClass() {
        if (isVacant()) {
            return "table-available";
        } else if (isOccupied()) {
            return "table-occupied";
        } else {
            return "table-reserved";
        }
    }
    
    public int getFloor() {
        // Extract floor number from table number (e.g., "T1-01" -> 1)
        if (tableNumber != null && tableNumber.startsWith("T")) {
            try {
                return Integer.parseInt(tableNumber.substring(1, 2));
            } catch (NumberFormatException e) {
                return 1; // Default to floor 1 if parsing fails
            }
        }
        return 1;
    }
}