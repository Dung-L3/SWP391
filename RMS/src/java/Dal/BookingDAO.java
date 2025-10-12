package Dal;

import Models.DiningTable;
import Models.Reservation;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {
    
    public boolean createReservation(Reservation reservation) throws SQLException {
        String sql = "INSERT INTO reservations (customer_id, table_id, reservation_date, " +
                    "reservation_time, party_size, status, special_requests, created_by, " +
                    "deposit_amount, deposit_status, confirmation_code, channel) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setObject(1, reservation.getCustomerId());
            stmt.setObject(2, reservation.getTableId());
            stmt.setDate(3, reservation.getReservationDate());
            stmt.setTime(4, reservation.getReservationTime());
            stmt.setInt(5, reservation.getPartySize());
            stmt.setString(6, "PENDING");
            stmt.setString(7, reservation.getSpecialRequests());
            stmt.setObject(8, reservation.getUserId());
            stmt.setObject(9, 0.0); // Default deposit amount
            stmt.setString(10, "NONE"); // Default deposit status
            stmt.setString(11, generateConfirmationCode());
            stmt.setString(12, "WEB");
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        reservation.setReservationId(rs.getInt(1));
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    public List<DiningTable> getAvailableTables(Date date, Time time, int partySize, Integer areaId) throws SQLException {
        List<DiningTable> availableTables = new ArrayList<>();
        
        String sql = "SELECT t.*, a.area_name " +
                    "FROM dining_table t " +
                    "LEFT JOIN table_area a ON t.area_id = a.area_id " +
                    "WHERE t.capacity >= ? " +
                    "AND (t.status = 'VACANT' OR t.status = 'CLEANING') " +
                    "AND t.table_id NOT IN (" +
                    "    SELECT r.table_id FROM reservations r " +
                    "    WHERE r.reservation_date = ? " +
                    "    AND ABS(DATEDIFF(MINUTE, r.reservation_time, ?)) < 90 " + // 90 minutes buffer
                    "    AND r.status IN ('PENDING', 'CONFIRMED')" +
                    ") ";
        
        if (areaId != null) {
            sql += "AND t.area_id = ? ";
        }
        
        sql += "ORDER BY t.capacity";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, partySize);
            stmt.setDate(2, date);
            stmt.setTime(3, time);
            
            if (areaId != null) {
                stmt.setInt(4, areaId);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    DiningTable table = new DiningTable();
                    table.setTableId(rs.getInt("table_id"));
                    table.setAreaId(rs.getInt("area_id"));
                    table.setTableNumber(rs.getString("table_number"));
                    table.setCapacity(rs.getInt("capacity"));
                    table.setLocation(rs.getString("location"));
                    table.setStatus(rs.getString("status"));
                    table.setTableType(rs.getString("table_type"));
                    availableTables.add(table);
                }
            }
        }
        
        return availableTables;
    }
    
    private String generateConfirmationCode() {
        return "RES" + System.currentTimeMillis() % 100000;
    }
}