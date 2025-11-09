package Models;

import java.io.Serializable;

/**
 * Recipe - Công thức món ăn
 */
public class Recipe implements Serializable {
    private static final long serialVersionUID = 1L;

    private int recipeId;
    private int menuItemId;
    private int version;           // Phiên bản công thức
    private boolean isActive;      // Công thức đang sử dụng
    private String note;           // Ghi chú

    // Join fields
    private String menuItemName;

    // Constructors
    public Recipe() {}

    public Recipe(int menuItemId, int version, boolean isActive) {
        this.menuItemId = menuItemId;
        this.version = version;
        this.isActive = isActive;
    }

    // Getters & Setters
    public int getRecipeId() { return recipeId; }
    public void setRecipeId(int recipeId) { this.recipeId = recipeId; }

    public int getMenuItemId() { return menuItemId; }
    public void setMenuItemId(int menuItemId) { this.menuItemId = menuItemId; }

    public int getVersion() { return version; }
    public void setVersion(int version) { this.version = version; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getMenuItemName() { return menuItemName; }
    public void setMenuItemName(String menuItemName) { this.menuItemName = menuItemName; }

    @Override
    public String toString() {
        return "Recipe{" +
                "recipeId=" + recipeId +
                ", menuItemId=" + menuItemId +
                ", version=" + version +
                ", isActive=" + isActive +
                '}';
    }
}

