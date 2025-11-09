package Dal;

import Models.InventoryItem;
import Models.Recipe;
import Models.RecipeItem;
import Models.StockTransaction;
import java.sql.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class StockTransactionDAO {

    /**
     * Create stock transaction and update inventory
     */
    public boolean createTransaction(StockTransaction txn) {
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            // Insert transaction
            String sql = "INSERT INTO stock_transactions " +
                    "(item_id, txn_type, quantity, unit_cost, txn_time, ref_type, ref_id, note) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, txn.getItemId());
                ps.setString(2, txn.getTxnType());
                ps.setBigDecimal(3, txn.getQuantity());
                ps.setBigDecimal(4, txn.getUnitCost());
                ps.setTimestamp(5, Timestamp.valueOf(txn.getTxnTime() != null ? txn.getTxnTime() : LocalDateTime.now()));
                ps.setString(6, txn.getRefType());
                ps.setObject(7, txn.getRefId());
                ps.setString(8, txn.getNote());

                ps.executeUpdate();
            }

            // Update inventory stock
            BigDecimal delta = txn.getQuantity();
            if (StockTransaction.TYPE_OUT.equals(txn.getTxnType()) ||
                StockTransaction.TYPE_USAGE.equals(txn.getTxnType()) ||
                StockTransaction.TYPE_WASTE.equals(txn.getTxnType())) {
                delta = delta.negate(); // Subtract for OUT/USAGE/WASTE
            }

            String updateSql = "UPDATE inventory_items SET current_stock = current_stock + ? WHERE item_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setBigDecimal(1, delta);
                ps.setInt(2, txn.getItemId());
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * Get transaction history
     */
    public List<StockTransaction> getTransactions(int page, int pageSize, Integer itemId, String txnType, LocalDateTime fromDate, LocalDateTime toDate) {
        List<StockTransaction> transactions = new ArrayList<>();
        StringBuilder sql = new StringBuilder();

        sql.append("SELECT st.stock_txn_id, st.item_id, st.txn_type, st.quantity, st.unit_cost, ");
        sql.append("st.txn_time, st.ref_type, st.ref_id, st.note, ");
        sql.append("i.item_name, i.uom ");
        sql.append("FROM stock_transactions st ");
        sql.append("LEFT JOIN inventory_items i ON st.item_id = i.item_id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (itemId != null) {
            sql.append("AND st.item_id = ? ");
            params.add(itemId);
        }

        if (txnType != null && !txnType.isEmpty()) {
            sql.append("AND st.txn_type = ? ");
            params.add(txnType);
        }

        if (fromDate != null) {
            sql.append("AND st.txn_time >= ? ");
            params.add(Timestamp.valueOf(fromDate));
        }

        if (toDate != null) {
            sql.append("AND st.txn_time <= ? ");
            params.add(Timestamp.valueOf(toDate));
        }

        sql.append("ORDER BY st.txn_time DESC ");
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
                    StockTransaction txn = new StockTransaction();
                    txn.setStockTxnId(rs.getLong("stock_txn_id"));
                    txn.setItemId(rs.getInt("item_id"));
                    txn.setTxnType(rs.getString("txn_type"));
                    txn.setQuantity(rs.getBigDecimal("quantity"));
                    txn.setUnitCost(rs.getBigDecimal("unit_cost"));
                    
                    Timestamp ts = rs.getTimestamp("txn_time");
                    if (ts != null) {
                        txn.setTxnTime(ts.toLocalDateTime());
                    }
                    
                    txn.setRefType(rs.getString("ref_type"));
                    
                    long refId = rs.getLong("ref_id");
                    if (!rs.wasNull()) {
                        txn.setRefId(refId);
                    }
                    
                    txn.setNote(rs.getString("note"));
                    txn.setItemName(rs.getString("item_name"));
                    txn.setUom(rs.getString("uom"));
                    
                    transactions.add(txn);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return transactions;
    }

    /**
     * Deduct stock for menu item (when order is placed)
     * Returns true if successful, false if insufficient stock
     */
    public boolean deductStockForMenuItem(int menuItemId, int quantity, Long orderId) {
        RecipeDAO recipeDAO = new RecipeDAO();
        Recipe recipe = recipeDAO.getRecipeByMenuItemId(menuItemId);
        
        if (recipe == null) {
            return true; // No recipe = no stock deduction needed
        }

        List<RecipeItem> recipeItems = recipeDAO.getRecipeItems(recipe.getRecipeId());
        
        // First check if we have enough stock for all ingredients
        InventoryDAO inventoryDAO = new InventoryDAO();
        for (RecipeItem ri : recipeItems) {
            BigDecimal requiredQty = ri.getQty().multiply(BigDecimal.valueOf(quantity));
            InventoryItem inventoryItem = inventoryDAO.getInventoryItemById(ri.getItemId());
            
            if (inventoryItem == null || inventoryItem.getCurrentStock().compareTo(requiredQty) < 0) {
                return false; // Insufficient stock
            }
        }

        // Deduct stock for each ingredient
        for (RecipeItem ri : recipeItems) {
            BigDecimal usedQty = ri.getQty().multiply(BigDecimal.valueOf(quantity));
            
            StockTransaction txn = new StockTransaction();
            txn.setItemId(ri.getItemId());
            txn.setTxnType(StockTransaction.TYPE_USAGE);
            txn.setQuantity(usedQty);
            txn.setUnitCost(BigDecimal.ZERO); // Cost already tracked in inventory
            txn.setRefType("ORDER");
            txn.setRefId(orderId);
            txn.setNote("Sử dụng cho món: " + recipe.getMenuItemName() + " (x" + quantity + ")");
            txn.setTxnTime(LocalDateTime.now());

            if (!createTransaction(txn)) {
                return false;
            }
        }

        return true;
    }
}

