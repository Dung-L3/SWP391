package Models;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * RecipeItem - Chi tiết nguyên liệu trong công thức
 */
public class RecipeItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int recipeItemId;
    private int recipeId;
    private int itemId;            // FK -> inventory_items.item_id
    private BigDecimal qty;        // Định lượng cần dùng

    // Join fields
    private String itemName;
    private String uom;

    // Constructors
    public RecipeItem() {}

    public RecipeItem(int recipeId, int itemId, BigDecimal qty) {
        this.recipeId = recipeId;
        this.itemId = itemId;
        this.qty = qty;
    }

    // Getters & Setters
    public int getRecipeItemId() { return recipeItemId; }
    public void setRecipeItemId(int recipeItemId) { this.recipeItemId = recipeItemId; }

    public int getRecipeId() { return recipeId; }
    public void setRecipeId(int recipeId) { this.recipeId = recipeId; }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public BigDecimal getQty() { return qty; }
    public void setQty(BigDecimal qty) { this.qty = qty; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getUom() { return uom; }
    public void setUom(String uom) { this.uom = uom; }

    @Override
    public String toString() {
        return "RecipeItem{" +
                "recipeItemId=" + recipeItemId +
                ", itemId=" + itemId +
                ", qty=" + qty +
                ", itemName='" + itemName + '\'' +
                ", uom='" + uom + '\'' +
                '}';
    }
}

