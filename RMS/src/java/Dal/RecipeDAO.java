package Dal;

import Models.InventoryItem;
import Models.Recipe;
import Models.RecipeItem;
import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class RecipeDAO {

    /**
     * Get recipe by menu item ID
     */
    public Recipe getRecipeByMenuItemId(int menuItemId) {
        String sql = "SELECT r.recipe_id, r.menu_item_id, r.version, r.is_active, r.note, " +
                "m.name as menu_item_name " +
                "FROM recipes r " +
                "LEFT JOIN menu_items m ON r.menu_item_id = m.menu_item_id " +
                "WHERE r.menu_item_id = ? AND r.is_active = 1";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, menuItemId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Recipe recipe = new Recipe();
                    recipe.setRecipeId(rs.getInt("recipe_id"));
                    recipe.setMenuItemId(rs.getInt("menu_item_id"));
                    recipe.setVersion(rs.getInt("version"));
                    recipe.setActive(rs.getBoolean("is_active"));
                    recipe.setNote(rs.getString("note"));
                    recipe.setMenuItemName(rs.getString("menu_item_name"));
                    return recipe;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get recipe items (ingredients) for a recipe
     */
    public List<RecipeItem> getRecipeItems(int recipeId) {
        List<RecipeItem> items = new ArrayList<>();
        String sql = "SELECT ri.recipe_item_id, ri.recipe_id, ri.item_id, ri.qty, " +
                "i.item_name, i.uom " +
                "FROM recipe_items ri " +
                "LEFT JOIN inventory_items i ON ri.item_id = i.item_id " +
                "WHERE ri.recipe_id = ? " +
                "ORDER BY i.item_name";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, recipeId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RecipeItem ri = new RecipeItem();
                    ri.setRecipeItemId(rs.getInt("recipe_item_id"));
                    ri.setRecipeId(rs.getInt("recipe_id"));
                    ri.setItemId(rs.getInt("item_id"));
                    ri.setQty(rs.getBigDecimal("qty"));
                    ri.setItemName(rs.getString("item_name"));
                    ri.setUom(rs.getString("uom"));
                    items.add(ri);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return items;
    }

    /**
     * Create recipe for menu item
     */
    public int createRecipe(Recipe recipe) {
        String sql = "INSERT INTO recipes (menu_item_id, version, is_active, note) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, recipe.getMenuItemId());
            ps.setInt(2, recipe.getVersion());
            ps.setBoolean(3, recipe.isActive());
            ps.setString(4, recipe.getNote());

            if (ps.executeUpdate() > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return -1;
    }

    /**
     * Add ingredient to recipe
     */
    public boolean addRecipeItem(RecipeItem recipeItem) {
        String sql = "INSERT INTO recipe_items (recipe_id, item_id, qty) VALUES (?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, recipeItem.getRecipeId());
            ps.setInt(2, recipeItem.getItemId());
            ps.setBigDecimal(3, recipeItem.getQty());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update recipe item quantity
     */
    public boolean updateRecipeItem(int recipeItemId, BigDecimal newQty) {
        String sql = "UPDATE recipe_items SET qty = ? WHERE recipe_item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBigDecimal(1, newQty);
            ps.setInt(2, recipeItemId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete recipe item
     */
    public boolean deleteRecipeItem(int recipeItemId) {
        String sql = "DELETE FROM recipe_items WHERE recipe_item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, recipeItemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if menu item has enough ingredients in stock
     * Returns true if all ingredients are available
     */
    public boolean checkIngredientsAvailable(int menuItemId, int servings) {
        Recipe recipe = getRecipeByMenuItemId(menuItemId);
        if (recipe == null) return true; // No recipe = no stock requirement

        List<RecipeItem> recipeItems = getRecipeItems(recipe.getRecipeId());
        InventoryDAO inventoryDAO = new InventoryDAO();

        for (RecipeItem ri : recipeItems) {
            BigDecimal requiredQty = ri.getQty().multiply(BigDecimal.valueOf(servings));
            InventoryItem inventoryItem = inventoryDAO.getInventoryItemById(ri.getItemId());
            
            if (inventoryItem == null || inventoryItem.getCurrentStock().compareTo(requiredQty) < 0) {
                return false; // Not enough stock
            }
        }

        return true;
    }
}

