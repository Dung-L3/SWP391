package Dal;

import Models.DiningTable;
import Models.TableArea;
import Models.TableSession;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * @author donny
 */
public class TableDAO {

    /**
     * Lấy danh sách tất cả khu vực
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

    /**
     * Lấy danh sách bàn theo khu vực
     */
    public List<DiningTable> getTablesByArea(Integer areaId) {
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
                    
                    // Thông tin khu vực
                    table.setAreaName(rs.getString("area_name"));
                    
                    // Thông tin session
                    if (rs.getLong("table_session_id") > 0) {
                        table.setCurrentSessionId(rs.getLong("table_session_id"));
                        table.setSessionStatus(rs.getString("session_status"));
                        table.setSessionOpenTime(rs.getTimestamp("open_time").toLocalDateTime());
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
     * Lấy thông tin bàn theo ID
     */
    public DiningTable getTableById(int tableId) {
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
}


