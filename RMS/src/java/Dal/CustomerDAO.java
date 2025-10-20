package Dal;

import Models.Customer;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class CustomerDAO {
    private final Connection conn;
    
    public CustomerDAO() throws Exception {
        conn = DBConnect.getConnection();
    }
    
    public int createOrUpdate(Customer customer) throws SQLException {
        // Kiểm tra nếu khách hàng đã tồn tại (dựa vào phone)
        String checkSql = "SELECT customer_id FROM customers WHERE phone = ?";
        try (PreparedStatement stmt = conn.prepareStatement(checkSql)) {
            stmt.setString(1, customer.getPhone());
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                // Cập nhật thông tin khách hàng
                int customerId = rs.getInt("customer_id");
                String updateSql = """
                    UPDATE customers 
                    SET full_name = ?, email = ?, address = ?
                    WHERE customer_id = ?
                    """;
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setString(1, customer.getFullName());
                    updateStmt.setString(2, customer.getEmail());
                    updateStmt.setString(3, customer.getAddress());
                    updateStmt.setInt(4, customerId);
                    updateStmt.executeUpdate();
                }
                return customerId;
            } else {
                // Tạo khách hàng mới
                String insertSql = """
                    INSERT INTO customers (
                        user_id, full_name, email, phone, 
                        address, registration_date, loyalty_points,
                        customer_type
                    ) VALUES (?, ?, ?, ?, ?, GETDATE(), 0, 'WALK_IN')
                    """;
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql, 
                        Statement.RETURN_GENERATED_KEYS)) {
                    insertStmt.setObject(1, customer.getUserId());
                    insertStmt.setString(2, customer.getFullName());
                    insertStmt.setString(3, customer.getEmail());
                    insertStmt.setString(4, customer.getPhone());
                    insertStmt.setString(5, customer.getAddress());
                    
                    insertStmt.executeUpdate();
                    
                    ResultSet generatedKeys = insertStmt.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        }
        throw new SQLException("Không thể tạo hoặc cập nhật khách hàng");
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