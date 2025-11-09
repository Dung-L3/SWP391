package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * InventoryItem - Nguyên liệu trong kho
 */
public class InventoryItem implements Serializable {
    private static final long serialVersionUID = 1L;

    // DB fields
    private int itemId;
    private String itemName;
    private String category;           // Loại nguyên liệu: Rau củ, Thịt, Gia vị, v.v.
    private String uom;                // Đơn vị tính: kg, lít, gram, chai, v.v.
    private BigDecimal currentStock;   // Tồn kho hiện tại
    private BigDecimal minimumStock;   // Mức tồn kho tối thiểu (cảnh báo)
    private BigDecimal unitCost;       // Giá đơn vị
    private Integer supplierId;        // Nhà cung cấp
    private LocalDate expiryDate;      // Ngày hết hạn
    private String status;             // ACTIVE, INACTIVE
    private Integer createdBy;

    // Join fields
    private String supplierName;
    private String createdByName;

    // Constants
    public static final String STATUS_ACTIVE = "ACTIVE";
    public static final String STATUS_INACTIVE = "INACTIVE";

    // Constructors
    public InventoryItem() {}

    public InventoryItem(String itemName, String category, String uom, 
                        BigDecimal currentStock, BigDecimal minimumStock, BigDecimal unitCost) {
        this.itemName = itemName;
        this.category = category;
        this.uom = uom;
        this.currentStock = currentStock;
        this.minimumStock = minimumStock;
        this.unitCost = unitCost;
        this.status = STATUS_ACTIVE;
    }

    // Getters & Setters
    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getUom() { return uom; }
    public void setUom(String uom) { this.uom = uom; }

    public BigDecimal getCurrentStock() { return currentStock; }
    public void setCurrentStock(BigDecimal currentStock) { this.currentStock = currentStock; }

    public BigDecimal getMinimumStock() { return minimumStock; }
    public void setMinimumStock(BigDecimal minimumStock) { this.minimumStock = minimumStock; }

    public BigDecimal getUnitCost() { return unitCost; }
    public void setUnitCost(BigDecimal unitCost) { this.unitCost = unitCost; }

    public Integer getSupplierId() { return supplierId; }
    public void setSupplierId(Integer supplierId) { this.supplierId = supplierId; }

    public LocalDate getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDate expiryDate) { this.expiryDate = expiryDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public String getSupplierName() { return supplierName; }
    public void setSupplierName(String supplierName) { this.supplierName = supplierName; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    // Helper methods
    public boolean isLowStock() {
        if (currentStock == null || minimumStock == null) return false;
        return currentStock.compareTo(minimumStock) <= 0;
    }

    public String getStockStatusDisplay() {
        if (isLowStock()) return "Sắp hết";
        return "Đủ hàng";
    }

    public String getStockStatusClass() {
        if (isLowStock()) return "bg-warning text-dark";
        return "bg-success";
    }

    @Override
    public String toString() {
        return "InventoryItem{" +
                "itemId=" + itemId +
                ", itemName='" + itemName + '\'' +
                ", currentStock=" + currentStock +
                ", uom='" + uom + '\'' +
                '}';
    }
}

