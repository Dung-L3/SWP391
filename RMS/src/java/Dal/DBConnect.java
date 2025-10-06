package Dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnect {

    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=RMS;encrypt=false";
    private static final String USER = "SWP";
    private static final String PASS = "1";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
    }

    public static Connection getConnection() {
        try {
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    // 🧪 Thêm hàm main để test trực tiếp
    public static void main(String[] args) {
        System.out.println("🔄 Đang kiểm tra kết nối SQL Server...");
        try (Connection con = getConnection()) {
            if (con != null) {
                System.out.println("✅ Kết nối thành công tới CSDL RMS!");
            } else {
                System.out.println("❌ Kết nối thất bại (Connection = null)");
            }
        } catch (Exception e) {
            System.out.println("❌ Lỗi khi kết nối:");
            e.printStackTrace();
        }
    }
}
