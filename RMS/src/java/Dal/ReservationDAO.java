package Dal;

import Models.Customer;
import Models.Reservation;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDateTime;
import java.sql.Timestamp;

public class ReservationDAO {
    private final Connection conn;
    private final CustomerDAO customerDAO;
    
    public ReservationDAO() throws Exception {
        conn = DBConnect.getConnection();
        customerDAO = new CustomerDAO();
    }
    
    private Integer createOrUpdateCustomer(Reservation reservation) throws SQLException {
        Customer customer = new Customer();
        customer.setUserId(reservation.getCustomerId()); // Nếu user đã đăng nhập
        customer.setFullName(reservation.getCustomerName());
        customer.setEmail(reservation.getEmail());
        customer.setPhone(reservation.getPhone());
        
        return customerDAO.createOrUpdate(customer);
    }
    
    public boolean create(Reservation reservation) throws SQLException {
        // Tạo hoặc lấy customer_id
        Integer customerId = createOrUpdateCustomer(reservation);
        
        String sql = """
                    INSERT INTO reservations (
                        customer_id, table_id, reservation_date, reservation_time,
                        party_size, status, special_requests, created_by,
                        deposit_amount, deposit_status, confirmation_code,
                        channel, created_at, updated_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())
                    """;
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            // Set parameters
            int i = 1;
            stmt.setObject(1, customerId);
            stmt.setObject(2, reservation.getTableId());
            stmt.setDate(3, reservation.getReservationDate());
            stmt.setTime(4, reservation.getReservationTime());
            stmt.setInt(5, reservation.getPartySize());
            stmt.setString(6, reservation.getStatus());
            stmt.setString(7, reservation.getSpecialRequests());
            stmt.setObject(8, reservation.getCreatedBy());
            stmt.setDouble(9, reservation.getDepositAmount());
            stmt.setString(10, reservation.getDepositStatus());
            stmt.setString(11, reservation.getConfirmationCode());
            stmt.setString(12, reservation.getChannel());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public Reservation findById(int id) throws SQLException {
        String sql = "SELECT * FROM reservations WHERE reservation_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapReservation(rs);
                }
            }
        }
        return null;
    }
    
    public List<Reservation> findByCustomerId(int customerId) throws SQLException {
        String sql = "SELECT * FROM reservations WHERE customer_id = ? ORDER BY reservation_date DESC, reservation_time DESC";
        List<Reservation> reservations = new ArrayList<>();
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapReservation(rs));
                }
            }
        }
        return reservations;
    }
    
    public List<Reservation> findByDateAndStatus(java.sql.Date date, String status) throws SQLException {
        String sql = "SELECT * FROM reservations WHERE reservation_date = ? AND status = ? ORDER BY reservation_time";
        List<Reservation> reservations = new ArrayList<>();
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, date);
            stmt.setString(2, status);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapReservation(rs));
                }
            }
        }
        return reservations;
    }
    
    public boolean updateStatus(int reservationId, String newStatus) throws SQLException {
        String sql = "UPDATE reservations SET status = ?, updated_at = GETDATE() WHERE reservation_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newStatus);
            stmt.setInt(2, reservationId);
            
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean update(Reservation reservation) throws SQLException {
        String sql = """
                    UPDATE reservations 
                    SET reservation_date = ?, 
                        reservation_time = ?,
                        party_size = ?, 
                        special_requests = ?,
                        updated_at = GETDATE()
                    WHERE reservation_id = ?
                    """;
                    
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, reservation.getReservationDate());
            stmt.setTime(2, reservation.getReservationTime());
            stmt.setInt(3, reservation.getPartySize());
            stmt.setString(4, reservation.getSpecialRequests());
            stmt.setInt(5, reservation.getReservationId());
            
            // Cập nhật thông tin khách hàng
            Integer customerId = createOrUpdateCustomer(reservation);
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean isTableAvailable(int tableId, java.sql.Date date, java.sql.Time time) throws SQLException {
        String sql = """
                    SELECT COUNT(*) FROM reservations 
                    WHERE table_id = ? 
                    AND reservation_date = ? 
                    AND reservation_time = ? 
                    AND status IN ('PENDING', 'CONFIRMED')
                    """;
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, tableId);
            stmt.setDate(2, date);
            stmt.setTime(3, time);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }
        }
        return false;
    }
    
    private Reservation mapReservation(ResultSet rs) throws SQLException {
        Reservation reservation = new Reservation();
        reservation.setReservationId(rs.getInt("reservation_id"));
            reservation.setCustomerId(rs.getObject("customer_id", Integer.class));
            reservation.setCustomerName(rs.getString("customer_name"));
            reservation.setPhone(rs.getString("phone"));
            reservation.setEmail(rs.getString("email"));
            reservation.setTableId(rs.getObject("table_id", Integer.class));
            reservation.setReservationDate(rs.getDate("reservation_date"));
            reservation.setReservationTime(rs.getTime("reservation_time"));
            reservation.setPartySize(rs.getInt("party_size"));
            reservation.setStatus(rs.getString("status"));
            reservation.setSpecialRequests(rs.getString("special_requests"));
            reservation.setCreatedBy(rs.getObject("created_by", Integer.class));
            reservation.setDepositAmount(rs.getDouble("deposit_amount"));
            reservation.setDepositStatus(rs.getString("deposit_status"));
            reservation.setConfirmationCode(rs.getString("confirmation_code"));
            reservation.setChannel(rs.getString("channel"));        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            reservation.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            reservation.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return reservation;
    }
}