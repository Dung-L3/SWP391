package Dal;

import Models.DiningTable;
import Models.TableArea;
import Models.TableSession;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;


public class TableDAO {
    public TableDAO() {
        // Default constructor.
    }

    // ==== Chức năng quản lý khu vực ====
    /**
     * Lấy danh sách tất cả khu vực (List all table areas)
     */
    public List<TableArea> getAllAreas() {
        final String sql = """
            SELECT area_id, area_name, sort_order
            FROM table_area
            ORDER BY sort_order, area_name
        """;

        List<TableArea> areas = new ArrayList<>();
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                TableArea area = new TableArea();
                area.setAreaId(rs.getInt("area_id"));
                area.setAreaName(rs.getString("area_name"));
                area.setSortOrder(rs.getInt("sort_order"));
                areas.add(area);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi lấy danh sách khu vực: " + e.getMessage());
            e.printStackTrace();
        }
        return areas;
    }

    // ==== Chức năng quản lý bàn DiningTable nâng cao (có session) ====

    /**
     * Lấy danh sách bàn theo khu vực có thông tin session (DiningTable full info for area).
     */
    public List<DiningTable> getDiningTablesByArea(Integer areaId) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ");
        sql.append("  dt.table_id, dt.area_id, dt.table_number, dt.capacity, ");
        sql.append("  dt.location, dt.status, dt.table_type, dt.map_x, dt.map_y, ");
        sql.append("  dt.created_by, ");
        sql.append("  ta.area_name, ");
        sql.append("  ts.table_session_id, ts.status as session_status, ");
        sql.append("  ts.open_time, ts.current_order_id ");
        sql.append("FROM dining_table dt ");
        sql.append("LEFT JOIN table_area ta ON ta.area_id = dt.area_id ");
        sql.append("LEFT JOIN table_session ts ON ts.table_id = dt.table_id AND ts.status = 'OPEN' ");
        sql.append("WHERE 1=1 ");

        if (areaId != null) {
            sql.append("AND dt.area_id = ? ");
        }

        sql.append("ORDER BY ta.sort_order, dt.table_number");

        List<DiningTable> tables = new ArrayList<>();
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            if (areaId != null) {
                ps.setInt(1, areaId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DiningTable table = new DiningTable();
                    table.setTableId(rs.getInt("table_id"));
                    table.setAreaId(rs.getInt("area_id"));
                    table.setTableNumber(rs.getString("table_number"));
                    table.setCapacity(rs.getInt("capacity"));
                    table.setLocation(rs.getString("location"));
                    table.setStatus(rs.getString("status"));
                    table.setTableType(rs.getString("table_type"));
                    table.setMapX(rs.getInt("map_x"));
                    table.setMapY(rs.getInt("map_y"));
                    table.setCreatedBy(rs.getInt("created_by"));
                    // Area info
                    table.setAreaName(rs.getString("area_name"));
                    // Session info
                    if (rs.getLong("table_session_id") > 0) {
                        table.setCurrentSessionId(rs.getLong("table_session_id"));
                        table.setSessionStatus(rs.getString("session_status"));
                        table.setSessionOpenTime(rs.getTimestamp("open_time") != null ? rs.getTimestamp("open_time").toLocalDateTime() : null);
                        table.setCurrentOrderId(rs.getLong("current_order_id"));
                    }
                    tables.add(table);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi lấy danh sách bàn: " + e.getMessage());
            e.printStackTrace();
        }
        return tables;
    }

    /**
     * Lấy thông tin bàn kiểu DiningTable theo ID (bao gồm areaName)
     */
    public DiningTable getDiningTableById(int tableId) {
        final String sql = """
            SELECT dt.table_id, dt.area_id, dt.table_number, dt.capacity,
                   dt.location, dt.status, dt.table_type, dt.map_x, dt.map_y,
                   dt.created_by,
                   ta.area_name
            FROM dining_table dt
            LEFT JOIN table_area ta ON ta.area_id = dt.area_id
            WHERE dt.table_id = ?
        """;

        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tableId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    DiningTable table = new DiningTable();
                    table.setTableId(rs.getInt("table_id"));
                    table.setAreaId(rs.getInt("area_id"));
                    table.setTableNumber(rs.getString("table_number"));
                    table.setCapacity(rs.getInt("capacity"));
                    table.setLocation(rs.getString("location"));
                    table.setStatus(rs.getString("status"));
                    table.setTableType(rs.getString("table_type"));
                    table.setMapX(rs.getInt("map_x"));
                    table.setMapY(rs.getInt("map_y"));
                    table.setCreatedBy(rs.getInt("created_by"));
                    table.setAreaName(rs.getString("area_name"));
                    return table;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi lấy thông tin bàn: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // ==== Chức năng quản lý table_session ====

    /**
     * Mở phiên bàn (seat customers)
     */
    public boolean seatTable(int tableId, Integer customerCount, String notes, Integer createdBy) {
        Connection con = null;
        try {
            con = DBConnect.getConnection();
            con.setAutoCommit(false);

            // 1. Tạo table_session mới
            String insertSessionSql = """
                INSERT INTO table_session (table_id, open_time, status)
                VALUES (?, SYSDATETIME(), 'OPEN')
            """;

            try (PreparedStatement ps = con.prepareStatement(insertSessionSql)) {
                ps.setInt(1, tableId);
                ps.executeUpdate();
            }

            // 2. Cập nhật trạng thái bàn thành SEATED
            String updateTableSql = """
                UPDATE dining_table 
                SET status = 'SEATED'
                WHERE table_id = ?
            """;

            try (PreparedStatement ps = con.prepareStatement(updateTableSql)) {
                ps.setInt(1, tableId);
                ps.executeUpdate();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            System.err.println("Lỗi mở phiên bàn: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) {
                try { 
                    con.setAutoCommit(true);
                    con.close(); 
                } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    /**
     * Đóng phiên bàn (vacate table)
     */
    public boolean vacateTable(int tableId) {
        Connection con = null;
        try {
            con = DBConnect.getConnection();
            con.setAutoCommit(false);

            // 1. Đóng table_session hiện tại
            String closeSessionSql = """
                UPDATE table_session 
                SET status = 'CLOSED', close_time = SYSDATETIME()
                WHERE table_id = ? AND status = 'OPEN'
            """;

            try (PreparedStatement ps = con.prepareStatement(closeSessionSql)) {
                ps.setInt(1, tableId);
                ps.executeUpdate();
            }

            // 2. Cập nhật trạng thái bàn thành CLEANING
            String updateTableSql = """
                UPDATE dining_table 
                SET status = 'CLEANING'
                WHERE table_id = ?
            """;

            try (PreparedStatement ps = con.prepareStatement(updateTableSql)) {
                ps.setInt(1, tableId);
                ps.executeUpdate();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            System.err.println("Lỗi đóng phiên bàn: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) {
                try { 
                    con.setAutoCommit(true);
                    con.close(); 
                } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    /**
     * Hoàn thành dọn dẹp bàn (từ CLEANING về VACANT)
     */
    public boolean cleanTable(int tableId) {
        final String sql = """
            UPDATE dining_table 
            SET status = 'VACANT'
            WHERE table_id = ? AND status = 'CLEANING'
        """;

        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tableId);
            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (SQLException e) {
            System.err.println("Lỗi hoàn thành dọn dẹp bàn: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy phiên bàn hiện tại của bàn
     */
    public TableSession getCurrentSession(int tableId) {
        final String sql = """
            SELECT ts.table_session_id, ts.table_id, ts.open_time, ts.close_time,
                   ts.status, ts.current_order_id,
                   dt.table_number, dt.status as table_status, dt.capacity
            FROM table_session ts
            JOIN dining_table dt ON dt.table_id = ts.table_id
            WHERE ts.table_id = ? AND ts.status = 'OPEN'
        """;

        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tableId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    TableSession session = new TableSession();
                    session.setTableSessionId(rs.getLong("table_session_id"));
                    session.setTableId(rs.getInt("table_id"));
                    session.setOpenTime(rs.getTimestamp("open_time").toLocalDateTime());
                    if (rs.getTimestamp("close_time") != null) {
                        session.setCloseTime(rs.getTimestamp("close_time").toLocalDateTime());
                    }
                    session.setStatus(rs.getString("status"));
                    session.setCurrentOrderId(rs.getLong("current_order_id"));
                    session.setTableNumber(rs.getString("table_number"));
                    session.setTableStatus(rs.getString("table_status"));
                    session.setTableCapacity(rs.getInt("capacity"));
                    return session;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi lấy phiên bàn: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // ==== Các method TableDAO cơ bản cho dự án tổng (Table - không chứa info sessions/areaName) ====

    public List<DiningTable> getAllTables() {
        List<DiningTable> tables = new ArrayList<>();
        String sql = "SELECT * FROM dining_table ORDER BY table_number";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                DiningTable table = mapResultSetToTable(rs);
                tables.add(table);
            }
        } catch (SQLException e) {
            System.out.println("Error getting all tables: " + e.getMessage());
        }

        return tables;
    }

    public List<DiningTable> getTablesByArea(Integer areaId) {
        List<DiningTable> tables = new ArrayList<>();
        String sql;
        
        if (areaId != null) {
            sql = "SELECT * FROM dining_table WHERE area_id = ? ORDER BY table_number";
        } else {
            sql = "SELECT * FROM dining_table ORDER BY area_id, table_number";
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (areaId != null) {
                ps.setInt(1, areaId);
            }
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                DiningTable table = mapResultSetToTable(rs);
                tables.add(table);
            }
        } catch (SQLException e) {
            System.out.println("Error getting tables by area: " + e.getMessage());
        }

        return tables;
    }

    public List<DiningTable> getVacantTables() {
        List<DiningTable> tables = new ArrayList<>();
        String sql = "SELECT * FROM dining_table WHERE status = ? ORDER BY area_id, table_number";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, DiningTable.STATUS_VACANT);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                DiningTable table = mapResultSetToTable(rs);
                tables.add(table);
            }
        } catch (SQLException e) {
            System.out.println("Error getting vacant tables: " + e.getMessage());
        }

        return tables;
    }

    public DiningTable getTableByNumber(String tableNumber) throws SQLException {
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

    public List<DiningTable> getTablesByType(String tableType) {
        List<DiningTable> tables = new ArrayList<>();
        String sql = "SELECT * FROM dining_table WHERE table_type = ? ORDER BY area_id, table_number";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, tableType);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                DiningTable table = mapResultSetToTable(rs);
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
            // If the table already has the desired status, treat as success (idempotent)
            if (currentStatus != null && currentStatus.equals(newStatus)) {
                conn.commit();
                System.out.println("Table " + tableNumber + " already in status " + newStatus);
                return true;
            }
            // If requesting to set to RESERVED/HELD, allow only when current status is VACANT or HELD
            if (newStatus.equals(DiningTable.STATUS_RESERVED) && !DiningTable.STATUS_VACANT.equals(currentStatus) && !DiningTable.STATUS_RESERVED.equals(currentStatus)) {
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

    /**
     * Lấy thông tin bàn đơn giản kiểu Table theo ID (cho các nơi không cần areaName/session)
     */
    public DiningTable getTableById(int tableId) throws SQLException {
        String sql = "SELECT * FROM dining_table WHERE table_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, tableId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToTable(rs);
            } else {
                System.out.println("Table not found with ID: " + tableId);
                return null;
            }
        } catch (SQLException e) {
            System.out.println("Error getting table by ID: " + e.getMessage());
            throw e;
        }
    }

    private DiningTable mapResultSetToTable(ResultSet rs) throws SQLException {
        DiningTable table = new DiningTable();
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
