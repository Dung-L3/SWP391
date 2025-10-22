/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author HoangAnh
 */
public class DBConnect {
    
    public static Connection getConnection() {
        try {
            // Load SQL Server JDBC Driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            // URL kết nối SQL Server Express
            String url = "jdbc:sqlserver://localhost:" + portNumber + ";databaseName=" + dbName + 
                        ";encrypt=true;trustServerCertificate=true";
            
            return DriverManager.getConnection(url, userID, password);
            
        } catch (ClassNotFoundException ex) {
            System.err.println("Lỗi: Không tìm thấy SQL Server JDBC Driver!");
            ex.printStackTrace();
        } catch (SQLException ex) {
            System.err.println("Lỗi kết nối cơ sở dữ liệu: " + ex.getMessage());
            ex.printStackTrace();
        }
        return null;
    }
    
    // Cấu hình cho SQL Server Express
    private final static String dbName = "RMS";  // Database 
    private final static String portNumber = "1433"; // Cổng mặc định của SQL Server
    private final static String userID = "SWP";      // Tài khoản SQL Server
    private final static String password = "1";  // Mật khẩu 

    public static void main(String[] args) {
        Connection connection = getConnection();

        if (connection != null) {
            System.out.println("Kết nối thành công đến cơ sở dữ liệu RMS!");
            try {
                connection.close();
                System.out.println("Đã đóng kết nối.");
            } catch (SQLException ex) {
                System.err.println("Lỗi khi đóng kết nối: " + ex.getMessage());
            }
        } else {
            System.err.println("Kết nối thất bại!");
        }
    }
}
