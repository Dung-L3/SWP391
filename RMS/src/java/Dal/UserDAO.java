package Dal;

import Models.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * UserDAO: xử lý đăng nhập và lấy/cập nhật thông tin người dùng kèm role.
 * SQL Server: dùng SYSDATETIME(), GETDATE(), COALESCE()
 */
public class UserDAO {

    /**
     * Đăng nhập nâng cao (username hoặc email) – kiểm tra mật khẩu ở Java.
     * Hỗ trợ nhiều định dạng hash: "saltB64:hashB64", BCrypt ($2a$/$2b$/$2y$), SHA-256 hex, hoặc chuỗi cũ.
     */
    public User login(String usernameOrEmail, String rawPassword) {
        final String sql = """
            SELECT  u.user_id, u.username, u.email, u.password_hash,
                    u.first_name, u.last_name, u.phone, u.address,
                    u.registration_date, u.last_login, u.account_status,
                    u.failed_login_attempts, u.lockout_until, u.created_at, u.updated_at,
                    r.role_id, r.role_name
            FROM dbo.users u
            LEFT JOIN dbo.user_roles ur
                   ON ur.user_id = u.user_id AND ur.status = N'ACTIVE'
            LEFT JOIN dbo.roles r
                   ON r.role_id = ur.role_id AND r.status = N'ACTIVE'
            WHERE (u.username = ? OR u.email = ?)
              AND u.account_status = N'ACTIVE'
        """;

        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String stored = rs.getString("password_hash");
                    // So khớp nhiều định dạng bằng PasswordUtil.matches()
                    if (Utils.PasswordUtil.matches(rawPassword, stored)) {
                        User u = mapRowToUser(rs);
                        updateLastLogin(con, u.getUserId()); // không làm fail nếu lỗi
                        return u;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Lấy user theo id (kèm role). */
    public User getByIdWithRole(int userId) {
        final String sql = """
            SELECT u.user_id, u.username, u.email, u.first_name, u.last_name,
                   u.phone, u.address, u.registration_date, u.last_login,
                   u.account_status,
                   ur.role_id, r.role_name
            FROM dbo.users u
            LEFT JOIN dbo.user_roles ur ON ur.user_id = u.user_id AND ur.status = N'ACTIVE'
            LEFT JOIN dbo.roles r       ON r.role_id = ur.role_id AND r.status = N'ACTIVE'
            WHERE u.user_id = ?
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(
                        rs.getInt("user_id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        rs.getString("phone"),
                        rs.getString("address"),
                        toLocal(rs.getTimestamp("registration_date")),
                        toLocal(rs.getTimestamp("last_login")),
                        rs.getString("account_status"),
                        (Integer) rs.getObject("role_id"),
                        rs.getString("role_name"),
                        null
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Cập nhật hồ sơ cơ bản.
     */
    public boolean updateProfile(int userId, String firstName, String lastName, String email,
                                 String phone, String address, String avatarUrlNullable) {
        final String sql = """
            UPDATE dbo.users
               SET first_name = ?, last_name = ?, email = ?, phone = ?, address = ?,
                   updated_at = SYSDATETIME()
             WHERE user_id = ?
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setString(5, address);
            ps.setInt(6, userId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ==================== Helpers ==================== */

    /** Map 1 dòng ResultSet -> User đầy đủ field dùng UI/Admin/Header. */
    private User mapRowToUser(ResultSet rs) throws Exception {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFirstName(rs.getString("first_name"));
        u.setLastName(rs.getString("last_name"));
        u.setPhone(rs.getString("phone"));
        u.setAddress(rs.getString("address"));
        u.setAccountStatus(rs.getString("account_status"));
        u.setFailedLoginAttempts(rs.getInt("failed_login_attempts"));
        u.setAvatarUrl(null);

        Timestamp t;
        t = rs.getTimestamp("registration_date");
        if (t != null) u.setRegistrationDate(t.toLocalDateTime());
        t = rs.getTimestamp("last_login");
        if (t != null) u.setLastLogin(t.toLocalDateTime());
        t = rs.getTimestamp("lockout_until");
        if (t != null) u.setLockoutUntil(t.toLocalDateTime());
        t = rs.getTimestamp("created_at");
        if (t != null) u.setCreatedAt(t.toLocalDateTime());
        t = rs.getTimestamp("updated_at");
        if (t != null) u.setUpdatedAt(t.toLocalDateTime());

        int roleId = rs.getInt("role_id");
        if (!rs.wasNull()) u.setRoleId(roleId);
        u.setRoleName(rs.getString("role_name"));  // có thể null nếu chưa gán role

        return u;
    }

    /** Cập nhật last_login cho userId; dùng chung connection của login để gọn giao dịch. */
    private void updateLastLogin(Connection con, int userId) {
        final String sql = "UPDATE dbo.users SET last_login = SYSDATETIME() WHERE user_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            // không làm fail đăng nhập nếu update last_login lỗi
            e.printStackTrace();
        }
    }

    public boolean changePassword(int userId, String oldHash, String newHash) {
        final String sql = """
            UPDATE users
               SET password_hash = ?, updated_at = SYSDATETIME()
             WHERE user_id = ? AND password_hash = ?
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            ps.setString(3, oldHash);
            return ps.executeUpdate() > 0; // chỉ true nếu oldHash đúng
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Tìm user theo username hoặc email  */
    public User findByUsernameOrEmail(String identifier) {
        final String sql = """
            SELECT  u.user_id, u.username, u.email, u.password_hash,
                    u.first_name, u.last_name, u.phone, u.address,
                    u.registration_date, u.last_login, u.account_status,
                    u.failed_login_attempts, u.lockout_until, u.created_at, u.updated_at,
                    r.role_id, r.role_name
            FROM dbo.users u
            LEFT JOIN dbo.user_roles ur
                   ON ur.user_id = u.user_id AND ur.status = N'ACTIVE'
            LEFT JOIN dbo.roles r
                   ON r.role_id = ur.role_id AND r.status = N'ACTIVE'
            WHERE (u.username = ? OR u.email = ?)
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, identifier);
            ps.setString(2, identifier);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRowToUser(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Cập nhật password_hash (dùng khi reset mật khẩu xong). */
    public boolean updatePasswordHash(int userId, String newHash) {
        final String sql = """
            UPDATE dbo.users
               SET password_hash = ?, updated_at = SYSDATETIME()
             WHERE user_id = ?
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private static LocalDateTime toLocal(Timestamp ts) {
        return ts == null ? null : ts.toLocalDateTime();
    }
}
