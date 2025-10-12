package Dal;

import Models.DiningTable;
import Models.TableArea;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TableAreaDAO {
    public List<TableArea> getAllAreas() throws SQLException {
        List<TableArea> areas = new ArrayList<>();
        String sql = "SELECT area_id, area_name, sort_order FROM table_area ORDER BY sort_order";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                TableArea area = new TableArea();
                area.setAreaId(rs.getInt("area_id"));
                area.setAreaName(rs.getString("area_name"));
                area.setSortOrder(rs.getInt("sort_order"));
                areas.add(area);
            }
        }
        
        return areas;
    }
    
    public List<DiningTable> getAllAvailableTables(String date, String time, int guests) throws SQLException {
        List<DiningTable> tables = new ArrayList<>();
        String sql = """
            SELECT dt.*
            FROM dining_table dt
            LEFT JOIN reservations r ON dt.table_id = r.table_id 
                AND r.booking_date = ? 
                AND r.booking_time = ?
            WHERE dt.capacity >= ? 
                AND (r.reservation_id IS NULL OR r.status = 'CANCELLED')
                AND dt.status = 'VACANT'
            ORDER BY dt.area_id, dt.table_number
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, date);
            stmt.setString(2, time);
            stmt.setInt(3, guests);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tables.add(extractTableFromResultSet(rs));
                }
            }
        }
        
        return tables;
    }
    
    public List<DiningTable> getAvailableTablesByArea(int areaId, String date, String time, int guests) throws SQLException {
        List<DiningTable> tables = new ArrayList<>();
        String sql = """
            SELECT dt.*
            FROM dining_table dt
            LEFT JOIN reservations r ON dt.table_id = r.table_id 
                AND r.booking_date = ? 
                AND r.booking_time = ?
            WHERE dt.area_id = ?
                AND dt.capacity >= ? 
                AND (r.reservation_id IS NULL OR r.status = 'CANCELLED')
                AND dt.status = 'VACANT'
            ORDER BY dt.table_number
        """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, date);
            stmt.setString(2, time);
            stmt.setInt(3, areaId);
            stmt.setInt(4, guests);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tables.add(extractTableFromResultSet(rs));
                }
            }
        }
        
        return tables;
    }
    
    private DiningTable extractTableFromResultSet(ResultSet rs) throws SQLException {
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
        return table;
    }
}