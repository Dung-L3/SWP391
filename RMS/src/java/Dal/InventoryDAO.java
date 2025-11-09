package Dal;

import Models.InventoryItem;
import Models.StockTransaction;
import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class InventoryDAO {

    /**
     * Get all inventory items with pagination and filters
     */
    public List<InventoryItem> getInventoryItems(int page, int pageSize, String search, String category, String status) {
        List<InventoryItem> items = new ArrayList<>();
        StringBuilder sql = new StringBuilder();

        sql.append("SELECT i.item_id, i.item_name, i.category, i.uom, i.current_stock, ");
        sql.append("i.minimum_stock, i.unit_cost, i.supplier_id, i.expiry_date, i.status, ");
        sql.append("s.company_name as supplier_name, ");
        sql.append("u.first_name + ' ' + u.last_name as created_by_name ");
        sql.append("FROM inventory_items i ");
        sql.append("LEFT JOIN suppliers s ON i.supplier_id = s.supplier_id ");
        sql.append("LEFT JOIN users u ON i.created_by = u.user_id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND i.item_name LIKE ? ");
            params.add("%" + search.trim() + "%");
        }

        if (category != null && !category.isEmpty()) {
            sql.append("AND i.category = ? ");
            params.add(category);
        }

        if (status != null && !status.isEmpty()) {
            sql.append("AND i.status = ? ");
            params.add(status);
        }

        sql.append("ORDER BY i.item_name ");
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
                    items.add(mapResultSetToInventoryItem(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return items;
    }

    /**
     * Get total count of inventory items
     */
    public int getTotalInventoryItemsCount(String search, String category, String status) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM inventory_items i WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND i.item_name LIKE ? ");
            params.add("%" + search.trim() + "%");
        }

        if (category != null && !category.isEmpty()) {
            sql.append("AND i.category = ? ");
            params.add(category);
        }

        if (status != null && !status.isEmpty()) {
            sql.append("AND i.status = ? ");
            params.add(status);
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Get inventory item by ID
     */
    public InventoryItem getInventoryItemById(int itemId) {
        String sql = "SELECT i.item_id, i.item_name, i.category, i.uom, i.current_stock, " +
                "i.minimum_stock, i.unit_cost, i.supplier_id, i.expiry_date, i.status, " +
                "s.company_name as supplier_name, " +
                "u.first_name + ' ' + u.last_name as created_by_name " +
                "FROM inventory_items i " +
                "LEFT JOIN suppliers s ON i.supplier_id = s.supplier_id " +
                "LEFT JOIN users u ON i.created_by = u.user_id " +
                "WHERE i.item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, itemId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToInventoryItem(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Create new inventory item
     */
    public boolean createInventoryItem(InventoryItem item) {
        String sql = "INSERT INTO inventory_items " +
                "(item_name, category, uom, current_stock, minimum_stock, unit_cost, " +
                "supplier_id, expiry_date, status, created_by) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getItemName());
            ps.setString(2, item.getCategory());
            ps.setString(3, item.getUom());
            ps.setBigDecimal(4, item.getCurrentStock());
            ps.setBigDecimal(5, item.getMinimumStock());
            ps.setBigDecimal(6, item.getUnitCost());
            ps.setObject(7, item.getSupplierId());
            ps.setObject(8, item.getExpiryDate());
            ps.setString(9, item.getStatus());
            ps.setObject(10, item.getCreatedBy());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update inventory item
     */
    public boolean updateInventoryItem(InventoryItem item) {
        String sql = "UPDATE inventory_items SET " +
                "item_name = ?, category = ?, uom = ?, current_stock = ?, minimum_stock = ?, " +
                "unit_cost = ?, supplier_id = ?, expiry_date = ?, status = ? " +
                "WHERE item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getItemName());
            ps.setString(2, item.getCategory());
            ps.setString(3, item.getUom());
            ps.setBigDecimal(4, item.getCurrentStock());
            ps.setBigDecimal(5, item.getMinimumStock());
            ps.setBigDecimal(6, item.getUnitCost());
            ps.setObject(7, item.getSupplierId());
            ps.setObject(8, item.getExpiryDate());
            ps.setString(9, item.getStatus());
            ps.setInt(10, item.getItemId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete (deactivate) inventory item
     */
    public boolean deleteInventoryItem(int itemId) {
        String sql = "UPDATE inventory_items SET status = ? WHERE item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, InventoryItem.STATUS_INACTIVE);
            ps.setInt(2, itemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update stock quantity (for transactions)
     */
    public boolean updateStock(int itemId, BigDecimal newQuantity) {
        String sql = "UPDATE inventory_items SET current_stock = ? WHERE item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, newQuantity);
            ps.setInt(2, itemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Adjust stock with delta (+ or -)
     */
    public boolean adjustStock(int itemId, BigDecimal delta) {
        String sql = "UPDATE inventory_items SET current_stock = current_stock + ? WHERE item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, delta);
            ps.setInt(2, itemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get all categories (distinct)
     */
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM inventory_items WHERE category IS NOT NULL ORDER BY category";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return categories;
    }

    /**
     * Get items with low stock (current_stock <= minimum_stock)
     */
    public List<InventoryItem> getLowStockItems() {
        List<InventoryItem> items = new ArrayList<>();
        String sql = "SELECT i.item_id, i.item_name, i.category, i.uom, i.current_stock, " +
                "i.minimum_stock, i.unit_cost, i.supplier_id, i.expiry_date, i.status, " +
                "s.company_name as supplier_name " +
                "FROM inventory_items i " +
                "LEFT JOIN suppliers s ON i.supplier_id = s.supplier_id " +
                "WHERE i.current_stock <= i.minimum_stock AND i.status = ? " +
                "ORDER BY (i.current_stock - i.minimum_stock) ASC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, InventoryItem.STATUS_ACTIVE);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapResultSetToInventoryItem(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return items;
    }

    private InventoryItem mapResultSetToInventoryItem(ResultSet rs) throws SQLException {
        InventoryItem item = new InventoryItem();

        item.setItemId(rs.getInt("item_id"));
        item.setItemName(rs.getString("item_name"));
        item.setCategory(rs.getString("category"));
        item.setUom(rs.getString("uom"));
        item.setCurrentStock(rs.getBigDecimal("current_stock"));
        item.setMinimumStock(rs.getBigDecimal("minimum_stock"));
        item.setUnitCost(rs.getBigDecimal("unit_cost"));
        
        int supplierId = rs.getInt("supplier_id");
        if (!rs.wasNull()) {
            item.setSupplierId(supplierId);
        }
        
        Date expiryDate = rs.getDate("expiry_date");
        if (expiryDate != null) {
            item.setExpiryDate(expiryDate.toLocalDate());
        }
        
        item.setStatus(rs.getString("status"));
        item.setSupplierName(rs.getString("supplier_name"));
        
        try {
            item.setCreatedByName(rs.getString("created_by_name"));
        } catch (SQLException e) {
            // Column may not exist in all queries
        }

        return item;
    }
}

