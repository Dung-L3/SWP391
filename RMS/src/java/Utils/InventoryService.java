package Utils;

import Dal.RecipeDAO;
import Dal.MenuDAO;
import Dal.InventoryDAO;
import Models.Recipe;
import Models.RecipeItem;
import Models.MenuItem;
import Models.InventoryItem;

import java.math.BigDecimal;
import java.util.List;

/**
 * InventoryService - Tự động kiểm tra kho và cập nhật trạng thái món
 */
public class InventoryService {

    private RecipeDAO recipeDAO = new RecipeDAO();
    private MenuDAO menuDAO = new MenuDAO();
    private InventoryDAO inventoryDAO = new InventoryDAO();

    /**
     * Check if a menu item can be prepared based on inventory
     * Returns true if:
     * - Item has no recipe (no ingredients required)
     * - Item has recipe AND all ingredients are in stock
     */
    public boolean canPrepareMenuItem(int menuItemId, int servings) {
        Recipe recipe = recipeDAO.getRecipeByMenuItemId(menuItemId);
        
        // No recipe = no stock requirement
        if (recipe == null) {
            return true;
        }

        List<RecipeItem> recipeItems = recipeDAO.getRecipeItems(recipe.getRecipeId());
        
        // Check each ingredient
        for (RecipeItem ri : recipeItems) {
            BigDecimal requiredQty = ri.getQty().multiply(BigDecimal.valueOf(servings));
            InventoryItem inventoryItem = inventoryDAO.getInventoryItemById(ri.getItemId());
            
            if (inventoryItem == null || 
                inventoryItem.getCurrentStock().compareTo(requiredQty) < 0) {
                return false; // Insufficient stock
            }
        }

        return true;
    }

    /**
     * Auto-update menu item availability based on stock
     * Sets to TEMP_UNAVAILABLE if ingredients not sufficient
     * Sets back to AVAILABLE if stock is restored
     */
    public void updateMenuItemAvailability(int menuItemId) {
        MenuItem menuItem = menuDAO.getMenuItemById(menuItemId);
        if (menuItem == null || !menuItem.isActive()) {
            return; // Skip inactive items
        }

        boolean canPrepare = canPrepareMenuItem(menuItemId, 1);
        String currentAvailability = menuItem.getAvailability();

        // Update only if status needs to change
        if (!canPrepare && "AVAILABLE".equals(currentAvailability)) {
            // Not enough stock -> set to TEMP_UNAVAILABLE
            menuItem.setAvailability("TEMP_UNAVAILABLE");
            menuDAO.updateMenuItem(menuItem);
        } else if (canPrepare && "TEMP_UNAVAILABLE".equals(currentAvailability)) {
            // Stock restored -> set back to AVAILABLE
            menuItem.setAvailability("AVAILABLE");
            menuDAO.updateMenuItem(menuItem);
        }
    }

    /**
     * Update availability for all menu items
     * Should be called after stock transactions
     */
    public void updateAllMenuItemsAvailability() {
        List<MenuItem> menuItems = menuDAO.getMenuItems(1, 1000, null, null, null, null);
        
        for (MenuItem item : menuItems) {
            if (item.isActive()) {
                updateMenuItemAvailability(item.getItemId());
            }
        }
    }

    /**
     * Get missing ingredients for a menu item
     * Returns list of ingredient names that are insufficient
     */
    public String getMissingIngredients(int menuItemId, int servings) {
        Recipe recipe = recipeDAO.getRecipeByMenuItemId(menuItemId);
        if (recipe == null) return null;

        List<RecipeItem> recipeItems = recipeDAO.getRecipeItems(recipe.getRecipeId());
        StringBuilder missing = new StringBuilder();

        for (RecipeItem ri : recipeItems) {
            BigDecimal requiredQty = ri.getQty().multiply(BigDecimal.valueOf(servings));
            InventoryItem inventoryItem = inventoryDAO.getInventoryItemById(ri.getItemId());
            
            if (inventoryItem == null) {
                if (missing.length() > 0) missing.append(", ");
                missing.append(ri.getItemName()).append(" (không tồn tại)");
            } else if (inventoryItem.getCurrentStock().compareTo(requiredQty) < 0) {
                if (missing.length() > 0) missing.append(", ");
                BigDecimal shortage = requiredQty.subtract(inventoryItem.getCurrentStock());
                missing.append(ri.getItemName())
                       .append(" (thiếu ").append(shortage).append(" ").append(ri.getUom()).append(")");
            }
        }

        return missing.length() > 0 ? missing.toString() : null;
    }
}

