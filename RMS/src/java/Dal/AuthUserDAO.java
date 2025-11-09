package Dal;

import Models.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;


public class AuthUserDAO {


    public User findByIdentifier(String identifier) {
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
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }


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
        u.setRoleName(rs.getString("role_name"));

        return u;
    }
}
