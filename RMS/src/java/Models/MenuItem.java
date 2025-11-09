package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * MenuItem model for menu items management & pricing display
 */
public class MenuItem implements Serializable {
    private static final long serialVersionUID = 1L;

    // DB fields
    private int itemId;                // maps menu_items.menu_item_id
    private int categoryId;
    private String name;
    private String description;
    private BigDecimal basePrice;      // base_price
    private String availability;       // AVAILABLE, OUT_OF_STOCK, DISCONTINUED
    private int preparationTime;       // minutes
    private boolean isActive;          // is_active
    private String imageUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private int createdBy;
    private Integer updatedBy;

    // Join / display fields
    private String categoryName;
    private String createdByName;
    private String updatedByName;

    // >>> dynamic (không lưu DB):
    // giá hiển thị thực tế sau khi áp dụng PricingRule (happy hour)
    private BigDecimal displayPrice;
    // có công thức hay không
    private boolean hasRecipe = false;

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

    // Getters / Setters
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

    // dynamic price getter/setter
    public BigDecimal getDisplayPrice() { return displayPrice; }
    public void setDisplayPrice(BigDecimal displayPrice) { this.displayPrice = displayPrice; }

    // recipe check getter/setter
    public boolean hasRecipe() { return hasRecipe; }
    public boolean isHasRecipe() { return hasRecipe; } // For JSP EL
    public boolean getHasRecipe() { return hasRecipe; } // For JSP EL
    public void setHasRecipe(boolean hasRecipe) { this.hasRecipe = hasRecipe; }

    // helpers for JSP
    public String getFormattedPrice() {
        return String.format("%,.0f đ", basePrice.doubleValue());
    }

    public String getFormattedDisplayPrice() {
        BigDecimal p = (displayPrice != null) ? displayPrice : basePrice;
        return String.format("%,.0f đ", p.doubleValue());
    }

    public String getAvailabilityDisplay() {
        if (availability == null) return "Có sẵn";
        switch (availability) {
            case "AVAILABLE": return "Có sẵn";
            case "TEMP_UNAVAILABLE": return "Tạm hết hàng";
            case "UNAVAILABLE": return "Tạm hết hàng";
            case "OUT_OF_STOCK": return "Tạm hết hàng";
            case "DISCONTINUED": return "Tạm hết hàng";
            default: return availability;
        }
    }

    public String getStatusDisplay() {
        return isActive ? "Hoạt động" : "Không hoạt động";
    }

    public String getStatusBadgeClass() {
        if (!isActive) return "bg-secondary";
        if (availability == null) return "bg-success";
        switch (availability) {
            case "AVAILABLE": return "bg-success";
            case "TEMP_UNAVAILABLE": return "bg-warning";
            case "UNAVAILABLE": return "bg-warning";
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
