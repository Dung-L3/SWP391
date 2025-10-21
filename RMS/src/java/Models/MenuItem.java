package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * MenuItem model for menu items management
 */
public class MenuItem implements Serializable {
    private static final long serialVersionUID = 1L;

    // Primary fields
    private int itemId;
    private int categoryId;
    private String name;
    private String description;
    private BigDecimal basePrice;
    private String availability; // AVAILABLE, OUT_OF_STOCK, DISCONTINUED
    private int preparationTime; // in minutes
    private boolean isActive;
    private String imageUrl; // Image URL for the menu item
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private int createdBy;
    private Integer updatedBy;

    // Join fields
    private String categoryName;
    private String createdByName;
    private String updatedByName;

    // Constructors
    public MenuItem() {}

    public MenuItem(int itemId, String name, String description, BigDecimal basePrice, 
                   String availability, int preparationTime, boolean isActive, String categoryName) {
        this.itemId = itemId;
        this.name = name;
        this.description = description;
        this.basePrice = basePrice;
        this.availability = availability;
        this.preparationTime = preparationTime;
        this.isActive = isActive;
        this.categoryName = categoryName;
    }

    // Getters and Setters
    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }

    public String getAvailability() { return availability; }
    public void setAvailability(String availability) { this.availability = availability; }

    public int getPreparationTime() { return preparationTime; }
    public void setPreparationTime(int preparationTime) { this.preparationTime = preparationTime; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public String getUpdatedByName() { return updatedByName; }
    public void setUpdatedByName(String updatedByName) { this.updatedByName = updatedByName; }

    // Utility methods
    public String getFormattedPrice() {
        return String.format("%,.0f đ", basePrice.doubleValue());
    }

    public String getAvailabilityDisplay() {
        switch (availability) {
            case "AVAILABLE": return "Có sẵn";
            case "OUT_OF_STOCK": return "Hết hàng";
            case "DISCONTINUED": return "Ngừng bán";
            default: return availability;
        }
    }

    public String getStatusDisplay() {
        return isActive ? "Hoạt động" : "Không hoạt động";
    }

    public String getStatusBadgeClass() {
        if (!isActive) return "bg-secondary";
        switch (availability) {
            case "AVAILABLE": return "bg-success";
            case "OUT_OF_STOCK": return "bg-warning";
            case "DISCONTINUED": return "bg-danger";
            default: return "bg-secondary";
        }
    }

    @Override
    public String toString() {
        return "MenuItem{" +
                "itemId=" + itemId +
                ", name='" + name + '\'' +
                ", basePrice=" + basePrice +
                ", availability='" + availability + '\'' +
                ", isActive=" + isActive +
                '}';
    }
}
