package Dal;

import Models.Customer;
import Models.Reservation;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.sql.Timestamp;

public class ReservationDAO {
    private final CustomerDAO customerDAO;
    
    public ReservationDAO() throws Exception {
        customerDAO = new CustomerDAO();
    }
    
    private Integer createOrUpdateCustomer(Reservation reservation) throws SQLException {
        try {
            Customer customer = new Customer();
            if (reservation.getCustomerId() != null) {
                customer.setUserId(reservation.getCustomerId());
            }
            customer.setFullName(reservation.getCustomerName());
            customer.setPhone(reservation.getPhone());
            
            if (reservation.getEmail() != null && !reservation.getEmail().trim().isEmpty()) {
                customer.setEmail(reservation.getEmail());
            }
            
            System.out.println("Creating/Updating customer: " + customer.getFullName());
            Integer customerId = customerDAO.createOrUpdate(customer);
            System.out.println("Customer ID: " + customerId);
            return customerId;
        } catch (SQLException e) {
            System.out.println("Error creating/updating customer: " + e.getMessage());
            throw e;
        }
    }
    
    public boolean create(Reservation reservation) throws SQLException {
        if (reservation == null) {
            throw new SQLException("Thông tin đặt bàn không được để trống");
        }
        
        Connection conn = null;
        boolean success = false;
        
        // Debug: Print reservation details
        System.out.println("\nReservation Details:");
        System.out.println("Customer Name: " + reservation.getCustomerName());
        System.out.println("Phone: " + reservation.getPhone());
        System.out.println("Email: " + (reservation.getEmail() != null ? reservation.getEmail() : "Not provided"));
        System.out.println("Table ID: " + reservation.getTableId());
        System.out.println("Date: " + reservation.getReservationDate());
        System.out.println("Time: " + reservation.getReservationTime());
        System.out.println("Party Size: " + reservation.getPartySize());
        
        try {
            System.out.println("\nGetting database connection...");
            conn = DBConnect.getConnection();
            if (conn == null) {
                System.out.println("Connection is null");
                throw new SQLException("Có lỗi xảy ra khi thao tác với cơ sở dữ liệu. Vui lòng thử lại sau.");
            }
            conn.setAutoCommit(false);
            
            System.out.println("Creating/Updating customer...");
            Integer customerId = createOrUpdateCustomer(reservation);
            if (customerId == null) {
                throw new SQLException("Không thể tạo hoặc cập nhật thông tin khách hàng");
            }
            
            // Kiểm tra thời gian hợp lệ
            if (reservation.getReservationTime() == null) {
                throw new SQLException("Thời gian đặt bàn không hợp lệ");
            }
            
            String checkSql = """
                    SELECT COUNT(*) FROM reservations 
                    WHERE table_id = ? 
                    AND reservation_date = ? 
                    AND CAST(reservation_time AS TIME) = ?
                    AND status != 'CANCELLED'
                    """;
                    
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, reservation.getTableId());
                checkStmt.setDate(2, reservation.getReservationDate());
                checkStmt.setTime(3, reservation.getReservationTime());
                
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new SQLException("Bàn đã được đặt cho thời gian này");
                }
            }
            
            String sql = """
                    INSERT INTO reservations (
                        customer_id, table_id, reservation_date, reservation_time,
                        party_size, status, special_requests, created_by,
                        deposit_amount, deposit_status, confirmation_code,
                        channel, created_at, updated_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
                    """;
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
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
                
                success = stmt.executeUpdate() > 0;
            }
            
            if (success) {
                conn.commit();
                System.out.println("Successfully created reservation for table " + reservation.getTableId());
            } else {
                conn.rollback();
                System.out.println("Failed to create reservation for table " + reservation.getTableId());
            }
            
        } catch (SQLException e) {
            System.out.println("Error creating reservation: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.out.println("Error rolling back transaction: " + ex.getMessage());
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    System.out.println("Error closing connection: " + e.getMessage());
                }
            }
        }
        
        return success;
    }
    
    public Reservation findById(int id) throws SQLException {
        String sql = "SELECT * FROM reservations WHERE reservation_id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
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
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapReservation(rs));
                }
            }
        }
        return reservations;
    }
    
    public void delete(int reservationId) throws SQLException {
        String sql = "DELETE FROM reservations WHERE reservation_id = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, reservationId);
            stmt.executeUpdate();
        }
    }

    public List<Reservation> findByDateAndStatus(java.sql.Date date, String status) throws SQLException {
        String sql = "SELECT * FROM reservations WHERE reservation_date = ? AND status = ? ORDER BY reservation_time";
        List<Reservation> reservations = new ArrayList<>();
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
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
        String sql = "UPDATE reservations SET status = ?, updated_at = NOW() WHERE reservation_id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
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
                        updated_at = NOW()
                    WHERE reservation_id = ?
                    """;
                    
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (createOrUpdateCustomer(reservation) == null) {
                return false;
            }
            
            stmt.setDate(1, reservation.getReservationDate());
            stmt.setTime(2, reservation.getReservationTime());
            stmt.setInt(3, reservation.getPartySize());
            stmt.setString(4, reservation.getSpecialRequests());
            stmt.setInt(5, reservation.getReservationId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean isTableAvailable(int tableId, java.sql.Date date, java.sql.Time time) throws SQLException {
        String sql = """
                    SELECT COUNT(*) FROM reservations 
                    WHERE table_id = ? 
                    AND reservation_date = ? 
                    AND CAST(reservation_time AS TIME) = ? 
                    AND status IN ('PENDING', 'CONFIRMED')
                    """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
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
        reservation.setChannel(rs.getString("channel"));        
        Timestamp createdAt = rs.getTimestamp("created_at");
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