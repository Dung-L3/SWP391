package Dal;

import Models.Customer;
import Models.Reservation;
import Models.DiningTable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {
    private final CustomerDAO customerDAO;
    
    public ReservationDAO() throws Exception {
        customerDAO = new CustomerDAO();
    }
    
    private Integer createOrUpdateCustomer(Reservation reservation) throws SQLException {
        try {
            Customer customer = new Customer();
            // Do not set the user_id here - it should only be set when we have a real user account
            // The customer_id is different from the user_id
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
        
        try {
            // Debug: Print reservation details
            System.out.println("\n=== Reservation Details ===");
            System.out.println("Customer Name: " + reservation.getCustomerName());
            System.out.println("Phone: " + reservation.getPhone());
            System.out.println("Email: " + (reservation.getEmail() != null ? reservation.getEmail() : "Not provided"));
            System.out.println("Table ID: " + reservation.getTableId());
            System.out.println("Date: " + reservation.getReservationDate());
            System.out.println("Time: " + reservation.getReservationTime());
            System.out.println("Party Size: " + reservation.getPartySize());
            
            System.out.println("\nGetting database connection...");
            conn = DBConnect.getConnection();
            if (conn == null) {
                throw new SQLException("Có lỗi xảy ra khi thao tác với cơ sở dữ liệu. Vui lòng thử lại sau.");
            }
            
            // Start transaction
            conn.setAutoCommit(false);
            
            // First verify the table exists and is available
            boolean tableAvailable = false;
            String tableNumber = null;
            
            try (PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT table_number, status FROM dining_table WITH (UPDLOCK, HOLDLOCK) WHERE table_id = ?")) {
                
                checkStmt.setInt(1, reservation.getTableId());
                ResultSet rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    String currentStatus = rs.getString("status");
                    tableNumber = rs.getString("table_number");
                    System.out.println("\n=== Current Table Status ===");
                    System.out.println("Table: " + tableNumber);
                    System.out.println("Status: " + currentStatus);
                    
                    tableAvailable = DiningTable.STATUS_VACANT.equals(currentStatus.toUpperCase());
                    if (!tableAvailable) {
                        throw new SQLException("Bàn " + tableNumber + " đã được đặt (status: " + currentStatus + ")");
                    }
                } else {
                    throw new SQLException("Không tìm thấy thông tin bàn");
                }
            }
            
            // Then check for existing reservations at the same time
            try (PreparedStatement resCheckStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM reservations WHERE table_id = ? " +
                    "AND reservation_date = ? " +
                    "AND CONVERT(varchar(8), reservation_time, 108) = CONVERT(varchar(8), ?, 108) " +
                    "AND status NOT IN ('CANCELLED', 'REJECTED')")) {
                
                resCheckStmt.setInt(1, reservation.getTableId());
                resCheckStmt.setDate(2, reservation.getReservationDate());
                resCheckStmt.setTime(3, reservation.getReservationTime());
                
                ResultSet rs = resCheckStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new SQLException("Bàn " + tableNumber + " đã có người đặt cho thời gian này");
                }
            }
            
            // Process the reservation
            System.out.println("\n=== Processing Reservation ===");

            // Create or update customer (we need customer_id to enforce per-day booking rule)
            System.out.println("Creating/Updating customer information...");
            Integer custId = createOrUpdateCustomer(reservation);
            if (custId == null) {
                throw new SQLException("Không thể tạo hoặc cập nhật thông tin khách hàng");
            }

            // Prevent a single customer from booking more than once on the same date
            // (ignore cancelled/rejected reservations)
            // Exclude reservations that belong to the same confirmation code being created
            // This allows creating multiple table reservations within a single booking (same confirmation code)
            try (PreparedStatement dupCheck = conn.prepareStatement(
                    "SELECT COUNT(*) FROM reservations WHERE customer_id = ? AND reservation_date = ? AND (confirmation_code IS NULL OR confirmation_code <> ?) AND status NOT IN ('CANCELLED', 'REJECTED')")) {
                dupCheck.setInt(1, custId);
                dupCheck.setDate(2, reservation.getReservationDate());
                dupCheck.setString(3, reservation.getConfirmationCode() == null ? "" : reservation.getConfirmationCode());
                ResultSet dupRs = dupCheck.executeQuery();
                if (dupRs.next() && dupRs.getInt(1) > 0) {
                    throw new SQLException("Bạn đã có đặt bàn cho ngày này rồi. Mỗi khách chỉ được đặt một lần trong cùng một ngày.");
                }
            }
            
            // Create the reservation
            System.out.println("Creating reservation record...");
            try (PreparedStatement insertStmt = conn.prepareStatement(
                    "INSERT INTO reservations (" +
                    "customer_id, table_id, reservation_date, reservation_time, " +
                    "party_size, status, special_requests, created_by, " +
                    "deposit_amount, deposit_status, confirmation_code, " +
                    "channel, created_at, updated_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())")) {
                
                insertStmt.setObject(1, custId);
                insertStmt.setObject(2, reservation.getTableId());
                insertStmt.setDate(3, reservation.getReservationDate());
                insertStmt.setTime(4, reservation.getReservationTime());
                insertStmt.setInt(5, reservation.getPartySize());
                insertStmt.setString(6, reservation.getStatus());
                insertStmt.setString(7, reservation.getSpecialRequests());
                insertStmt.setObject(8, reservation.getCreatedBy());
                insertStmt.setDouble(9, reservation.getDepositAmount());
                insertStmt.setString(10, reservation.getDepositStatus());
                insertStmt.setString(11, reservation.getConfirmationCode());
                insertStmt.setString(12, reservation.getChannel());
                
                success = insertStmt.executeUpdate() > 0;
            }
            
            if (success) {
                // Update table status
                System.out.println("Updating table status...");
                try (PreparedStatement updateStmt = conn.prepareStatement(
                        "UPDATE dining_table SET status = ? WHERE table_id = ?")) {
                    updateStmt.setString(1, DiningTable.STATUS_RESERVED);
                    updateStmt.setInt(2, reservation.getTableId());
                    updateStmt.executeUpdate();
                }
                
                conn.commit();
                System.out.println("Reservation completed successfully!");
            } else {
                throw new SQLException("Không thể tạo đơn đặt bàn");
            }
        } catch (SQLException e) {
            System.out.println("Error during reservation process: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                    System.out.println("Transaction rolled back");
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
                    System.out.println("Database connection closed");
                } catch (SQLException e) {
                    System.out.println("Error closing connection: " + e.getMessage());
                }
            }
        }
        
        return success;
    }
    
    public List<Reservation> findByCustomerId(int customerId) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT * FROM reservations WHERE customer_id = ? ORDER BY reservation_date DESC, reservation_time DESC";
        
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
    
    public List<Reservation> findActiveReservationsByTable(String tableNumber) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        String sql = """
                SELECT r.* FROM reservations r
                INNER JOIN dining_table t ON r.table_id = t.table_id
                WHERE t.table_number = ?
                AND r.status NOT IN ('CANCELLED', 'REJECTED')
                ORDER BY r.reservation_date, r.reservation_time
                """;
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, tableNumber);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapReservation(rs));
                }
            }
        }
        
        return reservations;
    }
    
    private Reservation mapReservation(ResultSet rs) throws SQLException {
        Reservation reservation = new Reservation();
        reservation.setReservationId(rs.getInt("reservation_id"));
        reservation.setCustomerId(rs.getInt("customer_id"));
        reservation.setTableId(rs.getInt("table_id"));
        reservation.setReservationDate(rs.getDate("reservation_date"));
        reservation.setReservationTime(rs.getTime("reservation_time"));
        reservation.setPartySize(rs.getInt("party_size"));
        reservation.setStatus(rs.getString("status"));
        reservation.setSpecialRequests(rs.getString("special_requests"));
        reservation.setCreatedBy(rs.getInt("created_by"));
        reservation.setConfirmationCode(rs.getString("confirmation_code"));
        reservation.setDepositAmount(rs.getDouble("deposit_amount"));
        reservation.setDepositStatus(rs.getString("deposit_status"));
        reservation.setChannel(rs.getString("channel"));
        return reservation;
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

    /**
     * Kiểm tra xem customer đã có đặt bàn (không tính CANCELLED/REJECTED) vào ngày givenDate chưa
     */
    public boolean hasReservationOnDate(int customerId, java.sql.Date givenDate) throws SQLException {
        String sql = "SELECT COUNT(*) FROM reservations WHERE customer_id = ? AND reservation_date = ? AND status NOT IN ('CANCELLED', 'REJECTED')";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            stmt.setDate(2, givenDate);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    public boolean update(Reservation reservation) throws SQLException {
        if (reservation == null || reservation.getReservationId() <= 0) {
            throw new SQLException("Thông tin đặt bàn không hợp lệ");
        }
        
        Connection conn = null;
        boolean success = false;
        
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);
            
            String sql = """
                    UPDATE reservations 
                    SET customer_id = ?, table_id = ?, reservation_date = ?, 
                        reservation_time = ?, party_size = ?, status = ?, 
                        special_requests = ?, deposit_amount = ?, deposit_status = ?,
                        updated_at = GETDATE()
                    WHERE reservation_id = ?
                    """;
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, reservation.getCustomerId());
                stmt.setInt(2, reservation.getTableId());
                stmt.setDate(3, reservation.getReservationDate());
                stmt.setTime(4, reservation.getReservationTime());
                stmt.setInt(5, reservation.getPartySize());
                stmt.setString(6, reservation.getStatus());
                stmt.setString(7, reservation.getSpecialRequests());
                stmt.setDouble(8, reservation.getDepositAmount());
                stmt.setString(9, reservation.getDepositStatus());
                stmt.setInt(10, reservation.getReservationId());
                
                success = stmt.executeUpdate() > 0;
            }
            
            if (success) {
                conn.commit();
            } else {
                conn.rollback();
            }
            
        } catch (SQLException e) {
            System.out.println("Error updating reservation: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.out.println("Error rolling back: " + ex.getMessage());
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
    
    public boolean updateStatus(int reservationId, String newStatus) throws SQLException {
        Connection conn = null;
        boolean success = false;
        
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);
            
            Reservation currentReservation = findById(reservationId);
            if (currentReservation == null) {
                throw new SQLException("Không tìm thấy đơn đặt bàn");
            }
            
            String sql = "UPDATE reservations SET status = ?, updated_at = GETDATE() WHERE reservation_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, newStatus);
                stmt.setInt(2, reservationId);
                
                success = stmt.executeUpdate() > 0;
            }
            
            // If cancelling or rejecting, update table status back to VACANT
            if (success && ("CANCELLED".equals(newStatus) || "REJECTED".equals(newStatus))) {
                try (PreparedStatement tableStmt = conn.prepareStatement(
                        "UPDATE dining_table SET status = ? WHERE table_id = ?")) {
                    tableStmt.setString(1, DiningTable.STATUS_VACANT);
                    tableStmt.setInt(2, currentReservation.getTableId());
                    tableStmt.executeUpdate();
                }
            }
            
            if (success) {
                conn.commit();
            } else {
                conn.rollback();
            }
            
        } catch (SQLException e) {
            System.out.println("Error updating reservation status: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.out.println("Error rolling back: " + ex.getMessage());
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
    
    public boolean delete(int reservationId) throws SQLException {
        Connection conn = null;
        boolean success = false;
        
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);
            
            Reservation reservation = findById(reservationId);
            if (reservation == null) {
                throw new SQLException("Không tìm thấy đơn đặt bàn");
            }
            
            String sql = "DELETE FROM reservations WHERE reservation_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, reservationId);
                success = stmt.executeUpdate() > 0;
            }
            
            if (success) {
                // Update table status back to VACANT
                try (PreparedStatement tableStmt = conn.prepareStatement(
                        "UPDATE dining_table SET status = ? WHERE table_id = ?")) {
                    tableStmt.setString(1, DiningTable.STATUS_VACANT);
                    tableStmt.setInt(2, reservation.getTableId());
                    tableStmt.executeUpdate();
                }
                
                conn.commit();
            } else {
                conn.rollback();
            }
            
        } catch (SQLException e) {
            System.out.println("Error deleting reservation: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.out.println("Error rolling back: " + ex.getMessage());
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

    public Reservation getReservationByConfirmationCode(String confirmationCode) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            String sql = "SELECT r.reservation_id, r.customer_id, r.table_id, " +
                        "r.reservation_date, r.reservation_time, r.party_size, " +
                        "r.status, r.special_requests, r.deposit_amount, " +
                        "r.deposit_status, r.confirmation_code, " +
                        "c.full_name, c.phone, c.email " +
                        "FROM reservations r " +
                        "LEFT JOIN customers c ON c.customer_id = r.customer_id " +
                        "WHERE r.confirmation_code = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, confirmationCode);
                System.out.println("Executing query for confirmation code: " + confirmationCode);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        Reservation reservation = new Reservation();
                        int customerId = rs.getInt("customer_id");
                        String customerEmail = rs.getString("email");
                        String customerName = rs.getString("full_name");
                        String phone = rs.getString("phone");
                        
                        System.out.println("=== Found Reservation Details ===");
                        System.out.println("Customer ID: " + customerId);
                        System.out.println("Customer Name: " + customerName);
                        System.out.println("Email: " + customerEmail);
                        System.out.println("Phone: " + phone);
                        System.out.println("Confirmation Code: " + rs.getString("confirmation_code"));
                        System.out.println("============================");
                        
                        reservation.setReservationId(rs.getInt("reservation_id"));
                        reservation.setCustomerId(customerId);
                        reservation.setCustomerName(rs.getString("full_name"));
                        reservation.setPhone(rs.getString("phone"));
                        reservation.setEmail(customerEmail);  // Set email từ customer
                        reservation.setReservationDate(rs.getDate("reservation_date"));
                        reservation.setReservationTime(rs.getTime("reservation_time"));
                        reservation.setPartySize(rs.getInt("party_size"));
                        reservation.setStatus(rs.getString("status"));
                        reservation.setSpecialRequests(rs.getString("special_requests"));
                        reservation.setTableId(rs.getInt("table_id"));
                        reservation.setConfirmationCode(rs.getString("confirmation_code"));
                        reservation.setDepositAmount(rs.getDouble("deposit_amount"));
                        reservation.setDepositStatus(rs.getString("deposit_status"));
                        return reservation;
                    }
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    System.out.println("Error closing connection: " + e.getMessage());
                }
            }
        }
        return null;
    }
}