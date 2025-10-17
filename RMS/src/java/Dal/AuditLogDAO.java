package Dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDAO {

    public static class AuditLogItem {
        public long logId;
        public Integer userId;
        public String action;
        public String tableName;
        public Long recordId;
        public String oldValues;
        public String newValues;
        public Timestamp timestamp;
        public String ipAddress;
        public String username; // joined username

        // Bean getters for JSP EL
        public long getLogId() { return logId; }
        public Integer getUserId() { return userId; }
        public String getAction() { return action; }
        public String getTableName() { return tableName; }
        public Long getRecordId() { return recordId; }
        public String getOldValues() { return oldValues; }
        public String getNewValues() { return newValues; }
        public Timestamp getTimestamp() { return timestamp; }
        public String getIpAddress() { return ipAddress; }
        public String getUsername() { return username; }
    }

    public List<AuditLogItem> list(String keyword, String action, String tableName,
                                   Timestamp from, Timestamp to, int offset, int limit) {
        List<AuditLogItem> result = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT TOP (" + limit + ") ");
        sql.append(" al.log_id, al.user_id, al.action, al.table_name, al.record_id, al.old_values, al.new_values, al.timestamp, al.ip_address, u.username ");
        sql.append("FROM audit_log al LEFT JOIN users u ON u.user_id = al.user_id WHERE 1=1 ");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (al.action LIKE ? OR al.table_name LIKE ? OR u.username LIKE ?) ");
        }
        if (action != null && !action.trim().isEmpty()) {
            sql.append(" AND al.action = ? ");
        }
        if (tableName != null && !tableName.trim().isEmpty()) {
            sql.append(" AND al.table_name = ? ");
        }
        if (from != null) {
            sql.append(" AND al.timestamp >= ? ");
        }
        if (to != null) {
            sql.append(" AND al.timestamp <= ? ");
        }
        sql.append(" ORDER BY al.log_id DESC");

        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }
            if (action != null && !action.trim().isEmpty()) {
                ps.setString(idx++, action.trim());
            }
            if (tableName != null && !tableName.trim().isEmpty()) {
                ps.setString(idx++, tableName.trim());
            }
            if (from != null) {
                ps.setTimestamp(idx++, from);
            }
            if (to != null) {
                ps.setTimestamp(idx++, to);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLogItem it = new AuditLogItem();
                    it.logId = rs.getLong("log_id");
                    it.userId = (Integer) rs.getObject("user_id");
                    it.action = rs.getString("action");
                    it.tableName = rs.getString("table_name");
                    it.recordId = (Long) rs.getObject("record_id");
                    it.oldValues = rs.getString("old_values");
                    it.newValues = rs.getString("new_values");
                    it.timestamp = rs.getTimestamp("timestamp");
                    it.ipAddress = rs.getString("ip_address");
                    it.username = rs.getString("username");
                    result.add(it);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public int count(String keyword, String action, String tableName, Timestamp from, Timestamp to) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM audit_log al LEFT JOIN users u ON u.user_id = al.user_id WHERE 1=1 ");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (al.action LIKE ? OR al.table_name LIKE ? OR u.username LIKE ?) ");
        }
        if (action != null && !action.trim().isEmpty()) {
            sql.append(" AND al.action = ? ");
        }
        if (tableName != null && !tableName.trim().isEmpty()) {
            sql.append(" AND al.table_name = ? ");
        }
        if (from != null) {
            sql.append(" AND al.timestamp >= ? ");
        }
        if (to != null) {
            sql.append(" AND al.timestamp <= ? ");
        }
        try (Connection con = DBConnect.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }
            if (action != null && !action.trim().isEmpty()) {
                ps.setString(idx++, action.trim());
            }
            if (tableName != null && !tableName.trim().isEmpty()) {
                ps.setString(idx++, tableName.trim());
            }
            if (from != null) {
                ps.setTimestamp(idx++, from);
            }
            if (to != null) {
                ps.setTimestamp(idx++, to);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
