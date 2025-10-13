package Dal;

import Models.MenuItem;
import Models.MenuCategory;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

/**
 * MenuDAO for menu items and categories management
 */
public class MenuDAO {

    /**
     * Get paginated menu items with search and filter
     */
    public List<MenuItem> getMenuItems(int page, int pageSize, String search, Integer categoryId, String availability, String sortBy) {
        List<MenuItem> items = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        
        sql.append("SELECT mi.menu_item_id, mi.category_id, mi.name, mi.description, mi.base_price, ");
        sql.append("mi.availability, mi.preparation_time, mi.is_active, mi.image_url, ");
        sql.append("CASE mi.category_id ");
        sql.append("  WHEN 1 THEN N'Khai vị' ");
        sql.append("  WHEN 2 THEN N'Món chính' ");
        sql.append("  WHEN 3 THEN N'Món phụ' ");
        sql.append("  WHEN 4 THEN N'Tráng miệng' ");
        sql.append("  WHEN 5 THEN N'Đồ uống' ");
        sql.append("  ELSE N'Khác' ");
        sql.append("END as category_name, ");
        sql.append("u1.first_name + ' ' + u1.last_name as created_by_name ");
        sql.append("FROM menu_items mi ");
        sql.append("LEFT JOIN users u1 ON mi.created_by = u1.user_id ");
        sql.append("WHERE mi.is_active = 1 ");

        List<Object> params = new ArrayList<>();

        // Search filter
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (mi.name LIKE ? OR mi.description LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        // Category filter - Fixed logic
        if (categoryId != null && categoryId > 0) {
            sql.append("AND mi.category_id = ? ");
            params.add(categoryId);
        }

        // Availability filter
        if (availability != null && !availability.isEmpty() && !"ALL".equals(availability)) {
            sql.append("AND mi.availability = ? ");
            params.add(availability);
        }

        // Sorting
        if (sortBy != null && !sortBy.isEmpty()) {
            switch (sortBy) {
                case "name_asc":
                    sql.append("ORDER BY mi.name ASC ");
                    break;
                case "name_desc":
                    sql.append("ORDER BY mi.name DESC ");
                    break;
                case "price_asc":
                    sql.append("ORDER BY mi.base_price ASC ");
                    break;
                case "price_desc":
                    sql.append("ORDER BY mi.base_price DESC ");
                    break;
                case "category":
                    sql.append("ORDER BY mi.category_id, mi.name ");
                    break;
                default:
                    sql.append("ORDER BY mi.category_id, mi.name ");
            }
        } else {
            sql.append("ORDER BY mi.category_id, mi.name ");
        }

        // Pagination
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MenuItem item = mapResultSetToMenuItem(rs);
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return items;
    }

    /**
     * Get total count for pagination
     */
    public int getTotalMenuItemsCount(String search, Integer categoryId, String availability) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM menu_items mi ");
        sql.append("WHERE mi.is_active = 1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (mi.name LIKE ? OR mi.description LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (categoryId != null && categoryId > 0) {
            sql.append("AND mi.category_id = ? ");
            params.add(categoryId);
        }

        if (availability != null && !availability.isEmpty() && !"ALL".equals(availability)) {
            sql.append("AND mi.availability = ? ");
            params.add(availability);
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Get all menu categories with proper encoding handling
     */
    public List<MenuCategory> getAllCategories() {
        List<MenuCategory> categories = new ArrayList<>();
        
        // Always return the hardcoded categories to ensure they work
        categories.add(new MenuCategory(1, "Khai vị", 1, true));
        categories.add(new MenuCategory(2, "Món chính", 2, true));
        categories.add(new MenuCategory(3, "Món phụ", 3, true));
        categories.add(new MenuCategory(4, "Tráng miệng", 4, true));
        categories.add(new MenuCategory(5, "Đồ uống", 5, true));

        return categories;
    }

    /**
     * Get menu item by ID
     */
    public MenuItem getMenuItemById(int itemId) {
        String sql = "SELECT mi.menu_item_id, mi.category_id, mi.name, mi.description, mi.base_price, " +
                    "mi.availability, mi.preparation_time, mi.is_active, mi.image_url, " +
                    "CASE mi.category_id " +
                    "  WHEN 1 THEN N'Khai vị' " +
                    "  WHEN 2 THEN N'Món chính' " +
                    "  WHEN 3 THEN N'Món phụ' " +
                    "  WHEN 4 THEN N'Tráng miệng' " +
                    "  WHEN 5 THEN N'Đồ uống' " +
                    "  ELSE N'Khác' " +
                    "END as category_name, " +
                    "u1.first_name + ' ' + u1.last_name as created_by_name " +
                    "FROM menu_items mi " +
                    "LEFT JOIN users u1 ON mi.created_by = u1.user_id " +
                    "WHERE mi.menu_item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, itemId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToMenuItem(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Create new menu item
     */
    public boolean createMenuItem(MenuItem item) {
        System.out.println("DAO - Creating menu item: " + item.getName());
        String sql = "INSERT INTO menu_items (category_id, name, description, base_price, " +
                    "availability, preparation_time, is_active, image_url, created_by) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, item.getCategoryId());
            ps.setString(2, item.getName());
            ps.setString(3, item.getDescription());
            ps.setBigDecimal(4, item.getBasePrice());
            ps.setString(5, item.getAvailability());
            ps.setInt(6, item.getPreparationTime());
            ps.setBoolean(7, item.isActive());
            ps.setString(8, item.getImageUrl());
            ps.setInt(9, item.getCreatedBy());

            int result = ps.executeUpdate();
            System.out.println("DAO - Insert result: " + result);
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update menu item
     */
    public boolean updateMenuItem(MenuItem item) {
        String sql = "UPDATE menu_items SET category_id = ?, name = ?, description = ?, " +
                    "base_price = ?, availability = ?, preparation_time = ?, is_active = ?, image_url = ? " +
                    "WHERE menu_item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, item.getCategoryId());
            ps.setString(2, item.getName());
            ps.setString(3, item.getDescription());
            ps.setBigDecimal(4, item.getBasePrice());
            ps.setString(5, item.getAvailability());
            ps.setInt(6, item.getPreparationTime());
            ps.setBoolean(7, item.isActive());
            ps.setString(8, item.getImageUrl());
            ps.setInt(9, item.getItemId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete menu item (soft delete - set is_active = false)
     */
    public boolean deleteMenuItem(int itemId, int updatedBy) {
        String sql = "UPDATE menu_items SET is_active = 0 WHERE menu_item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, itemId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Create new menu category
     */
    public boolean createMenuCategory(String categoryName, int sortOrder) {
        String sql = "INSERT INTO menu_categories (category_name, sort_order) VALUES (?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, categoryName);
            ps.setInt(2, sortOrder);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Map ResultSet to MenuItem
     */
    private MenuItem mapResultSetToMenuItem(ResultSet rs) throws SQLException {
        MenuItem item = new MenuItem();
        
        item.setItemId(rs.getInt("menu_item_id"));
        item.setCategoryId(rs.getInt("category_id"));
        item.setName(rs.getString("name"));
        item.setDescription(rs.getString("description"));
        item.setBasePrice(rs.getBigDecimal("base_price"));
        item.setAvailability(rs.getString("availability"));
        item.setPreparationTime(rs.getInt("preparation_time"));
        item.setActive(rs.getBoolean("is_active"));
        item.setImageUrl(rs.getString("image_url"));
        
        item.setCategoryName(rs.getString("category_name"));
        item.setCreatedByName(rs.getString("created_by_name"));
        
        return item;
    }
}
