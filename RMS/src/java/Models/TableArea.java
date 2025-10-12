package Models;

public class TableArea {
    private int areaId;
    private String areaName;
    private int sortOrder;

    public TableArea() {
    }

    public TableArea(int areaId, String areaName, int sortOrder) {
        this.areaId = areaId;
        this.areaName = areaName;
        this.sortOrder = sortOrder;
    }

    public int getAreaId() {
        return areaId;
    }

    public void setAreaId(int areaId) {
        this.areaId = areaId;
    }

    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }
}