package Models;

import java.io.Serializable;
import java.util.Objects;

/**
 * @author donny
 */
public class TableArea implements Serializable {
    private static final long serialVersionUID = 1L;

    private int areaId;
    private String areaName;
    private int sortOrder;

    /* ================= Constructors ================= */
    public TableArea() {}

    public TableArea(int areaId, String areaName, int sortOrder) {
        this.areaId = areaId;
        this.areaName = areaName;
        this.sortOrder = sortOrder;
    }

    /* ================= Getters & Setters ================= */
    public int getAreaId() { return areaId; }
    public void setAreaId(int areaId) { this.areaId = areaId; }

    public String getAreaName() { return areaName; }
    public void setAreaName(String areaName) { this.areaName = areaName; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TableArea tableArea = (TableArea) o;
        return areaId == tableArea.areaId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(areaId);
    }

    @Override
    public String toString() {
        return "TableArea{" +
                "areaId=" + areaId +
                ", areaName='" + areaName + '\'' +
                ", sortOrder=" + sortOrder +
                '}';
    }
}


