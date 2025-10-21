package Dal;

import Models.Customer;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class CustomerDAO {
    private final Connection conn;
    
    public CustomerDAO() throws SQLException {
        conn = DBConnect.getConnection();
        if (conn == null) {
            throw new SQLException("Không thể tạo kết nối đến cơ sở dữ liệu");
        }
    }
    
    public int createOrUpdate(Customer customer) throws SQLException {
        if (customer == null) {
            throw new SQLException("Thông tin khách hàng không được để trống");
        }
        
        try {
            System.out.println("\nCustomer DAO - Creating/Updating customer:");
            System.out.println("Full Name: " + customer.getFullName());
            System.out.println("Phone: " + customer.getPhone());
            System.out.println("Email: " + (customer.getEmail() != null ? customer.getEmail() : "Not provided"));
            System.out.println("User ID: " + (customer.getUserId() != null ? customer.getUserId() : "Not provided"));

            if (conn == null || conn.isClosed()) {
                System.out.println("Error: No database connection");
                throw new SQLException("Mất kết nối đến cơ sở dữ liệu");
            }
            
            conn.setAutoCommit(false);  // Bắt đầu transaction
            
            // Kiểm tra và chuẩn hóa số điện thoại
            String phone = customer.getPhone();
            if (phone == null || phone.trim().isEmpty()) {
                System.out.println("Error: Phone number is empty");
                throw new SQLException("So dien thoai khong duoc de trong");
            }
            
            // Chuẩn hóa số điện thoại: chỉ giữ lại số
            phone = phone.replaceAll("[^0-9]", "");
            if (phone.length() != 10) {
                throw new SQLException("So dien thoai khong hop le (phai du 10 so)");
            }
            
            // Chuẩn hóa tên
            String fullName = customer.getFullName();
            if (fullName == null || fullName.trim().isEmpty()) {
                throw new SQLException("Ten khach hang khong duoc de trong");
            }
            fullName = fullName.trim();
            
            // Chuẩn hóa email cho registered users
            String email = null;
            if (customer.getUserId() != null) {
                email = customer.getEmail();
                if (email == null || email.trim().isEmpty()) {
                    throw new SQLException("Email không được để trống cho khách hàng có tài khoản");
                }
                email = email.trim().toLowerCase();
            }
            
            // Check if user_id exists in users table if provided
            if (customer.getUserId() != null) {
                String userCheckSql = "SELECT user_id FROM users WHERE user_id = ?";
                try (PreparedStatement userStmt = conn.prepareStatement(userCheckSql)) {
                    userStmt.setInt(1, customer.getUserId());
                    try (ResultSet rs = userStmt.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException("User ID không tồn tại trong hệ thống");
                        }
                    }
                }
                
                // Check if user_id is already linked to another customer
                String customerCheckSql = "SELECT customer_id FROM customers WHERE user_id = ? AND customer_id != COALESCE(?, -1)";
                try (PreparedStatement custStmt = conn.prepareStatement(customerCheckSql)) {
                    custStmt.setInt(1, customer.getUserId());
                    if (customer.getCustomerId() != null) {
                        custStmt.setInt(2, customer.getCustomerId());
                    } else {
                        custStmt.setInt(2, -1);
                    }
                    try (ResultSet rs = custStmt.executeQuery()) {
                        if (rs.next()) {
                            throw new SQLException("User ID đã được liên kết với một khách hàng khác");
                        }
                    }
                }
            }
            
            // Tìm khách hàng hiện có theo số điện thoại hoặc customer_id
            Integer existingId = null;
            String existingCheckSql = """
                SELECT customer_id, phone, email, user_id 
                FROM customers WITH (UPDLOCK) 
                WHERE phone = ? OR (customer_id = COALESCE(?, -1))
                """;
                
            try (PreparedStatement stmt = conn.prepareStatement(existingCheckSql)) {
                stmt.setString(1, phone);
                if (customer.getCustomerId() != null) {
                    stmt.setInt(2, customer.getCustomerId());
                } else {
                    stmt.setInt(2, -1);
                }
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        existingId = rs.getInt("customer_id");
                        // If this customer already has a different user_id, we cannot overwrite it
                        Integer existingUserId = rs.getObject("user_id", Integer.class);
                        if (existingUserId != null && !existingUserId.equals(customer.getUserId())) {
                            throw new SQLException("Khách hàng này đã được liên kết với một tài khoản khác");
                        }
                    }
                }
            }
            
            int customerId;
            String customerType = customer.getUserId() != null ? "MEMBER" : "WALK_IN";
            
            if (existingId != null) {
                // Cập nhật thông tin khách hàng hiện có
                String updateSql = """
                    UPDATE customers 
                    SET full_name = ?, 
                        email = ?, 
                        address = ?, 
                        user_id = ?,
                        customer_type = ?
                    WHERE customer_id = ?
                    """;
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setString(1, fullName);
                    updateStmt.setString(2, email);
                    updateStmt.setString(3, customer.getAddress());
                    if (customer.getUserId() != null) {
                        updateStmt.setInt(4, customer.getUserId());
                    } else {
                        updateStmt.setNull(4, java.sql.Types.INTEGER);
                    }
                    updateStmt.setString(5, customerType);
                    updateStmt.setInt(6, existingId);
                    
                    if (updateStmt.executeUpdate() > 0) {
                        customerId = existingId;
                    } else {
                        throw new SQLException("Không thể cập nhật thông tin khách hàng");
                    }
                }
            } else {
                // Tạo khách hàng mới
                String insertSql = """
                    INSERT INTO customers (
                        full_name, email, phone, address, user_id,
                        registration_date, loyalty_points, customer_type
                    ) VALUES (?, ?, ?, ?, ?, GETDATE(), 0, ?)
                    """;
                
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                    // Set parameters
                    insertStmt.setString(1, fullName);
                    insertStmt.setString(2, email);
                    insertStmt.setString(3, phone);
                    insertStmt.setString(4, customer.getAddress() != null ? customer.getAddress().trim() : null);
                    if (customer.getUserId() != null) {
                        insertStmt.setInt(5, customer.getUserId());
                    } else {
                        insertStmt.setNull(5, java.sql.Types.INTEGER);
                    }
                    insertStmt.setString(6, customerType);
                    
                    try {
                        if (insertStmt.executeUpdate() > 0) {
                            try (ResultSet generatedKeys = insertStmt.getGeneratedKeys()) {
                                if (generatedKeys.next()) {
                                    customerId = generatedKeys.getInt(1);
                                } else {
                                    throw new SQLException("Không thể lấy ID của khách hàng mới");
                                }
                            }
                        } else {
                            throw new SQLException("Không thể tạo khách hàng mới");
                        }
                    } catch (SQLException ex) {
                        // Handle potential unique constraint on user_id (duplicate NULL) or similar
                        String msg = ex.getMessage() != null ? ex.getMessage() : "";
                        // SQL Server duplicate key error codes are often 2627 or 2601; handle by message match too
                        if (msg.contains("Violation of UNIQUE KEY constraint") || msg.contains("duplicate key value is (<NULL>)") || msg.contains("UQ__customer__")) {
                            // Try to find an existing customer by phone
                            Customer existing = findByPhone(phone);
                            if (existing != null) {
                                customerId = existing.getCustomerId();
                            } else if (email != null) {
                                // Try to find by email
                                Customer byEmail = findByEmail(email);
                                if (byEmail != null) {
                                    customerId = byEmail.getCustomerId();
                                } else {
                                    // As a last resort, try to find any customer with NULL user_id
                                    String fallbackSql = "SELECT TOP 1 customer_id FROM customers WHERE user_id IS NULL";
                                    try (PreparedStatement fb = conn.prepareStatement(fallbackSql)) {
                                        try (ResultSet rsFb = fb.executeQuery()) {
                                            if (rsFb.next()) {
                                                customerId = rsFb.getInt("customer_id");
                                            } else {
                                                // Nothing we can do; rethrow the original exception
                                                throw ex;
                                            }
                                        }
                                    }
                                }
                            } else {
                                // No phone/email match, try fallback to any NULL user_id
                                String fallbackSql = "SELECT TOP 1 customer_id FROM customers WHERE user_id IS NULL";
                                try (PreparedStatement fb = conn.prepareStatement(fallbackSql)) {
                                    try (ResultSet rsFb = fb.executeQuery()) {
                                        if (rsFb.next()) {
                                            customerId = rsFb.getInt("customer_id");
                                        } else {
                                            throw ex;
                                        }
                                    }
                                }
                            }
                        } else {
                            throw ex;
                        }
                    }
                }
            }
            
            conn.commit();  // Commit transaction nếu mọi thứ OK
            return customerId;
            
        } catch (SQLException e) {
            try {
                conn.rollback();  // Rollback nếu có lỗi
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            throw e;  // Ném lại exception để xử lý ở tầng trên
        } finally {
            try {
                conn.setAutoCommit(true);  // Reset lại auto commit
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    public Customer findById(int customerId) throws SQLException {
        String sql = "SELECT * FROM customers WHERE customer_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerId(rs.getInt("customer_id"));
                customer.setUserId(rs.getObject("user_id", Integer.class));
                customer.setFullName(rs.getString("full_name"));
                customer.setEmail(rs.getString("email"));
                customer.setPhone(rs.getString("phone"));
                customer.setAddress(rs.getString("address"));
                customer.setRegistrationDate(rs.getTimestamp("registration_date").toLocalDateTime());
                customer.setLoyaltyPoints(rs.getInt("loyalty_points"));
                customer.setCustomerType(rs.getString("customer_type"));
                return customer;
            }
        }
        return null;
    }
    
    public Customer findByPhone(String phone) throws SQLException {
        String sql = "SELECT * FROM customers WHERE phone = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, phone);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerId(rs.getInt("customer_id"));
                customer.setUserId(rs.getObject("user_id", Integer.class));
                customer.setFullName(rs.getString("full_name"));
                customer.setEmail(rs.getString("email"));
                customer.setPhone(rs.getString("phone"));
                customer.setAddress(rs.getString("address"));
                customer.setRegistrationDate(rs.getTimestamp("registration_date").toLocalDateTime());
                customer.setLoyaltyPoints(rs.getInt("loyalty_points"));
                customer.setCustomerType(rs.getString("customer_type"));
                return customer;
            }
        }
        return null;
    }

    public Customer findByEmail(String email) throws SQLException {
        if (email == null) return null;
        String sql = "SELECT * FROM customers WHERE email = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerId(rs.getInt("customer_id"));
                customer.setUserId(rs.getObject("user_id", Integer.class));
                customer.setFullName(rs.getString("full_name"));
                customer.setEmail(rs.getString("email"));
                customer.setPhone(rs.getString("phone"));
                customer.setAddress(rs.getString("address"));
                if (rs.getTimestamp("registration_date") != null) {
                    customer.setRegistrationDate(rs.getTimestamp("registration_date").toLocalDateTime());
                }
                customer.setLoyaltyPoints(rs.getInt("loyalty_points"));
                customer.setCustomerType(rs.getString("customer_type"));
                return customer;
            }
        }
        return null;
    }
}