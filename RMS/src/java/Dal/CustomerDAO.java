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
            
            // Không yêu cầu email cho khách không đăng nhập
            String email = null;
            if (customer.getUserId() != null) {
                email = customer.getEmail();
                if (email != null) {
                    email = email.trim().toLowerCase();
                }
            }
            
            // Tìm khách hàng hiện có
            Integer existingId = null;
            String checkSql = "SELECT customer_id FROM customers WITH (UPDLOCK) WHERE phone = ?";
            try (PreparedStatement stmt = conn.prepareStatement(checkSql)) {
                stmt.setString(1, phone);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        existingId = rs.getInt("customer_id");
                    }
                }
            }

            int customerId;
            if (existingId != null) {
                // Cập nhật thông tin khách hàng hiện có
                String updateSql = "UPDATE customers SET full_name = ?, address = ? WHERE customer_id = ?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setString(1, fullName);
                    updateStmt.setString(2, customer.getAddress());
                    updateStmt.setInt(3, existingId);
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
                        user_id, full_name, email, phone, address, 
                        registration_date, loyalty_points, customer_type
                    ) VALUES (?, ?, ?, ?, ?, NOW(), 0, ?)
                    """;
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                    insertStmt.setObject(1, customer.getUserId());
                    insertStmt.setString(2, fullName);
                    insertStmt.setString(3, email);
                    insertStmt.setString(4, phone);
                    insertStmt.setString(5, customer.getAddress() != null ? customer.getAddress().trim() : null);
                    insertStmt.setString(6, customer.getUserId() != null ? "REGISTERED" : "GUEST");
                    
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
}