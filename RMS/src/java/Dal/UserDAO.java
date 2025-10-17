package Dal;

import Models.User;
import Utils.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;

/**
 * UserDAO: xử lý đăng nhập và lấy/cập nhật thông tin người dùng kèm role.
 * SQL Server: dùng SYSDATETIME(), GETDATE(), COALESCE()
 */
public class UserDAO {

    /**
     * Đăng nhập (username OR email) + password_hash
     * @param usernameOrEmail username hoặc email
     * @param passwordHash    mật khẩu đã hash
     * @return User (kèm roleName/roleId, avatarUrl) nếu đúng, null nếu sai
     */
    public User login(String usernameOrEmail, String passwordHash) {
        final String sql = """
            SELECT  u.user_id, u.username, u.email, u.password_hash,
                    u.first_name, u.last_name, u.phone, u.address,
                    u.registration_date, u.last_login, u.account_status,
                    u.failed_login_attempts, u.lockout_until, u.created_at, u.updated_at,
                    u.avatar_url,
                    r.role_id, r.role_name
            FROM dbo.users u
            LEFT JOIN dbo.user_roles ur
                   ON ur.user_id = u.user_id AND ur.status = N'ACTIVE'
            LEFT JOIN dbo.roles r
                   ON r.role_id = ur.role_id AND r.status = N'ACTIVE'
            WHERE (u.username = ? OR u.email = ?)
              AND u.password_hash = ?
              AND u.account_status = N'ACTIVE';
        """;

        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            ps.setString(3, passwordHash);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = mapRowToUser(rs);
                    updateLastLogin(con, u.getUserId()); // không fail login nếu update lỗi
                    return u;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Đăng nhập với password gốc (sẽ hash và so sánh với database)
     * @param usernameOrEmail username hoặc email
     * @param password       mật khẩu gốc
     * @return User nếu đúng, null nếu sai
     */
    public User loginWithPassword(String usernameOrEmail, String password) {
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
              AND u.account_status = N'ACTIVE';
        """;

        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password_hash");
                    // Kiểm tra password với PasswordUtil
                    if (PasswordUtil.verifyPassword(password, storedHash)) {
                        User u = mapRowToUser(rs);
                        updateLastLogin(con, u.getUserId());
                        return u;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy thông tin xác thực (password_hash, account_status) cho username/email (không lọc theo status)
    public User getAuthInfo(String usernameOrEmail) {
        final String sql = """
            SELECT u.user_id, u.username, u.email, u.password_hash, u.account_status
            FROM dbo.users u
            WHERE (u.username = ? OR u.email = ?)
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setPasswordHash(rs.getString("password_hash"));
                    u.setAccountStatus(rs.getString("account_status"));
                    return u;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Lấy user theo id (kèm role + avatar). */
    public User getByIdWithRole(int userId) {
        final String sql = """
            SELECT u.user_id, u.username, u.email, u.first_name, u.last_name,
                   u.phone, u.address, u.registration_date, u.last_login,
                   u.account_status, u.avatar_url,
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
                        rs.getString("avatar_url")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Cập nhật hồ sơ cơ bản. Nếu avatarUrlNullable = null thì giữ nguyên avatar cũ.
     */
    public boolean updateProfile(int userId, String firstName, String lastName, String email,
                                 String phone, String address, String avatarUrlNullable) {
        final String sql = """
            UPDATE dbo.users
               SET first_name = ?, last_name = ?, email = ?, phone = ?, address = ?,
                   avatar_url = COALESCE(?, avatar_url),
                   updated_at = GETDATE()
             WHERE user_id = ?
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setString(5, address);
            if (avatarUrlNullable == null) {
                ps.setNull(6, Types.VARCHAR);
            } else {
                ps.setString(6, avatarUrlNullable);
            }
            ps.setInt(7, userId);

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
        u.setAvatarUrl(null); // avatar_url column doesn't exist in database

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
           SET password_hash = ?, updated_at = GETDATE()
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


    private static LocalDateTime toLocal(Timestamp ts) {
        return ts == null ? null : ts.toLocalDateTime();
    }

    public boolean verifyOTP(String email, String otp) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
