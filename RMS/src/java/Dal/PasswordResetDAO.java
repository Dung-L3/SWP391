package Dal;

import Models.PasswordReset;
import Utils.HashUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class PasswordResetDAO {

    /** Vô hiệu hoá các yêu cầu đang mở của user, ghi used_at theo giờ hệ thống SQL (VN). */
    public void invalidateActiveForUser(int userId) throws SQLException {
        final String sql = """
            UPDATE dbo.password_resets
               SET used = 1, used_at = SYSDATETIME()
             WHERE user_id = ? AND used = 0
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    /**
     expires_at = now + 2 phút
     */
    public void createReset(int userId, String token, String otpRaw, java.time.Instant ignored,
                            String ip, String ua) throws SQLException {
        final String sql = """
            INSERT INTO dbo.password_resets
                (user_id, reset_token, otp_hash, created_at,               expires_at,                          used, ip_address, user_agent)
            VALUES (       ?,         ?,          ?,       SYSDATETIME(), DATEADD(MINUTE, 2, SYSDATETIME()),   0,      ?,          ?)
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, token);
            ps.setString(3, Utils.HashUtil.bcrypt(otpRaw));
            ps.setString(4, ip);
            ps.setString(5, ua);
            ps.executeUpdate();
        }
    }

    /** Lấy yêu cầu còn hạn theo token (so sánh với SYSDATETIME để đúng múi giờ VN). */
     public PasswordReset findValidByToken(String token) throws SQLException {
        final String sql = """
            SELECT TOP 1 *
              FROM dbo.password_resets
             WHERE reset_token = ?
               AND used = 0
               AND expires_at > SYSDATETIME()
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Models.PasswordReset pr = new Models.PasswordReset();
                    pr.setResetId(rs.getLong("reset_id"));
                    pr.setUserId(rs.getInt("user_id"));
                    pr.setResetToken(rs.getString("reset_token"));
                    pr.setOtpHash(rs.getString("otp_hash"));
                    pr.setExpiresAt(rs.getTimestamp("expires_at").toInstant());
                    return pr;
                }
            }
        }
        return null;
    }
      /** Đổi OTP + gia hạn 2 phút cho bản ghi theo token (chỉ khi chưa used) */
    public boolean refreshOtpByToken(String token, String newOtpRaw) throws SQLException {
        final String sql = """
            UPDATE dbo.password_resets
               SET otp_hash = ?,
                   expires_at = DATEADD(MINUTE, 2, SYSDATETIME())
             WHERE reset_token = ? AND used = 0
        """;
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, Utils.HashUtil.bcrypt(newOtpRaw));
            ps.setString(2, token);
            return ps.executeUpdate() > 0;
        }
    }
     
    /** Đánh dấu đã dùng và ghi used_at theo SYSDATETIME (giờ VN). */
    public void markUsed(long resetId) throws SQLException {
        final String sql = "UPDATE dbo.password_resets SET used = 1, used_at = SYSDATETIME() WHERE reset_id = ?";
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, resetId);
            ps.executeUpdate();
        }
    }
}

