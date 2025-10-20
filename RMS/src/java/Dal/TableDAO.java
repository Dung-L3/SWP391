package Dal;

import Models.Table;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TableDAO {
    public TableDAO() {
        // Using static connection from DBConnect
    }

    public List<Table> getAllTables() {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT * FROM dining_table ORDER BY table_number";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Table table = mapResultSetToTable(rs);
                tables.add(table);
            }
        } catch (SQLException e) {
            System.out.println("Error getting all tables: " + e.getMessage());
        }

        return tables;
    }

    public List<Table> getTablesByArea(int areaId) {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT * FROM dining_table WHERE area_id = ? ORDER BY table_number";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, areaId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Table table = mapResultSetToTable(rs);
                tables.add(table);
            }
        } catch (SQLException e) {
            System.out.println("Error getting tables by area: " + e.getMessage());
        }

        return tables;
    }

    public List<Table> getVacantTables() {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT * FROM dining_table WHERE status = ? ORDER BY area_id, table_number";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, Table.STATUS_VACANT);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Table table = mapResultSetToTable(rs);
                tables.add(table);
            }
        } catch (SQLException e) {
            System.out.println("Error getting vacant tables: " + e.getMessage());
        }

        return tables;
    }

    public Table getTableByNumber(String tableNumber) throws SQLException {
        String sql = "SELECT * FROM dining_table WHERE table_number = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, tableNumber);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToTable(rs);
            } else {
                System.out.println("Table not found: " + tableNumber);
                return null;
            }
        } catch (SQLException e) {
            System.out.println("Error getting table by number: " + e.getMessage());
            throw e;
        }
    }

    public List<Table> getTablesByType(String tableType) {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT * FROM dining_table WHERE table_type = ? ORDER BY area_id, table_number";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, tableType);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Table table = mapResultSetToTable(rs);
                tables.add(table);
            }
        } catch (SQLException e) {
            System.out.println("Error getting tables by type: " + e.getMessage());
        }

        return tables;
    }

    public boolean updateTableStatus(String tableNumber, String newStatus) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        boolean success = false;
        
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);
            
            // First check if the table is still in expected state
            String checkSql = "SELECT status FROM dining_table WITH (UPDLOCK) WHERE table_number = ?";
            ps = conn.prepareStatement(checkSql);
            ps.setString(1, tableNumber);
            
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                throw new SQLException("Table not found: " + tableNumber);
            }
            
            String currentStatus = rs.getString("status");
            if (newStatus.equals(Table.STATUS_RESERVED) && !Table.STATUS_VACANT.equals(currentStatus)) {
                throw new SQLException("Table " + tableNumber + " is not available (current status: " + currentStatus + ")");
            }
            
            // Then update the status
            String updateSql = "UPDATE dining_table SET status = ? WHERE table_number = ?";
            ps = conn.prepareStatement(updateSql);
            ps.setString(1, newStatus);
            ps.setString(2, tableNumber);
            
            success = ps.executeUpdate() > 0;
            
            if (success) {
                conn.commit();
                System.out.println("Successfully updated table " + tableNumber + " status to " + newStatus);
            } else {
                conn.rollback();
                System.out.println("Failed to update table " + tableNumber + " status");
            }
            
            return success;
            
        } catch (SQLException e) {
            System.out.println("Error updating table status: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.out.println("Error during rollback: " + ex.getMessage());
                }
            }
            throw e;
            
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    System.out.println("Error resetting connection state: " + e.getMessage());
                }
            }
        }
    }

    private Table mapResultSetToTable(ResultSet rs) throws SQLException {
        Table table = new Table();
        table.setTableId(rs.getInt("table_id"));
        table.setTableNumber(rs.getString("table_number"));
        table.setCapacity(rs.getInt("capacity"));
        table.setTableType(rs.getString("table_type"));
        table.setAreaId(rs.getInt("area_id"));
        table.setStatus(rs.getString("status"));
        table.setLocation(rs.getString("location"));
        table.setMapX(rs.getInt("map_x"));
        table.setMapY(rs.getInt("map_y"));
        table.setCreatedBy(rs.getInt("created_by"));
        return table;
    }
}