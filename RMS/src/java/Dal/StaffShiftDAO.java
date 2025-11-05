package Dal;

import Models.StaffShift;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class StaffShiftDAO {

    // --- helper: open connection + debug DB info ---
    private Connection getConnWithDebug() throws SQLException {
        Connection conn = DBConnect.getConnection();
        if (conn != null) {
            try {
                DatabaseMetaData md = conn.getMetaData();
                System.out.println(
                        "[DAO] Connected DB = " + md.getURL() +
                        " / user=" + md.getUserName());
            } catch (Exception ignore) {}
        } else {
            System.out.println("[DAO] ERROR: DBConnect.getConnection() trả null");
        }
        return conn;
    }

    // quick ping: kiểm tra ca có tồn tại không
    public boolean pingShift(int shiftId) {
        final String sql = "SELECT 1 FROM dbo.shift_schedule WHERE shift_id = ?";
        try (Connection conn = getConnWithDebug();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, shiftId);
            try (ResultSet rs = ps.executeQuery()) {
                boolean exists = rs.next();
                System.out.println("[DAO] pingShift(" + shiftId + ") => " + exists);
                return exists;
            }
        } catch (SQLException e) {
            System.out.println("[DAO] pingShift(" + shiftId + ") SQL ERROR: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 1. lấy ca trong khoảng ngày
    public List<StaffShift> getShifts(LocalDate fromDate, LocalDate toDate) {
        List<StaffShift> list = new ArrayList<>();

        final String sql =
            "SELECT " +
            "    sh.shift_id, sh.staff_id, sh.shift_date, sh.start_time, sh.end_time, " +
            "    sh.status, sh.created_by, " +
            "    u.first_name AS staff_first, u.last_name AS staff_last, u.phone AS staff_phone, " +
            "    r.role_name AS staff_role_name, " +
            "    cr.first_name AS cr_first, cr.last_name AS cr_last " +
            "FROM dbo.shift_schedule sh " +
            "JOIN dbo.users u ON sh.staff_id = u.user_id " +
            "LEFT JOIN dbo.user_roles ur ON u.user_id = ur.user_id " +
            "LEFT JOIN dbo.roles r ON ur.role_id = r.role_id " +
            "LEFT JOIN dbo.users cr ON sh.created_by = cr.user_id " +
            "WHERE sh.shift_date BETWEEN ? AND ? " +
            "ORDER BY sh.shift_date ASC, sh.start_time ASC, r.role_name ASC";

        System.out.println("[DAO] getShifts(" + fromDate + " -> " + toDate + ") SQL start");

        try (Connection conn = getConnWithDebug();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StaffShift sh = mapRow(rs);
                    list.add(sh);
                }
            }

            System.out.println("[DAO] getShifts(): done, rows=" + list.size());

        } catch (SQLException e) {
            System.out.println("[DAO] getShifts() SQL ERROR: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    // 2. lấy chi tiết ca theo shiftId
    public StaffShift getById(int shiftId) {
        final String sql =
            "SELECT " +
            "    sh.shift_id, sh.staff_id, sh.shift_date, sh.start_time, sh.end_time, " +
            "    sh.status, sh.created_by, " +
            "    u.first_name AS staff_first, u.last_name AS staff_last, u.phone AS staff_phone, " +
            "    r.role_name AS staff_role_name, " +
            "    cr.first_name AS cr_first, cr.last_name AS cr_last " +
            "FROM dbo.shift_schedule sh " +
            "JOIN dbo.users u ON sh.staff_id = u.user_id " +
            "LEFT JOIN dbo.user_roles ur ON u.user_id = ur.user_id " +
            "LEFT JOIN dbo.roles r ON ur.role_id = r.role_id " +
            "LEFT JOIN dbo.users cr ON sh.created_by = cr.user_id " +
            "WHERE sh.shift_id = ?";

        System.out.println("[DAO] getById(" + shiftId + ") SQL start");

        try (Connection conn = getConnWithDebug();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, shiftId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    StaffShift sh = mapRow(rs);

                    System.out.println(
                        "[DAO] getById(" + shiftId + "): FOUND " +
                        " date="   + sh.getShiftDate() +
                        " start="  + sh.getStartTime() +
                        " end="    + sh.getEndTime() +
                        " staff="  + sh.getStaffFullName() +
                        " status=" + sh.getStatus()
                    );

                    return sh;
                } else {
                    System.out.println("[DAO] getById(" + shiftId + "): NOT FOUND");
                }
            }

        } catch (SQLException e) {
            System.out.println("[DAO] getById(" + shiftId + ") SQL ERROR: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    // 3. tạo ca mới
    public boolean create(StaffShift sh) {
        final String sql =
            "INSERT INTO dbo.shift_schedule " +
            "    (staff_id, shift_date, start_time, end_time, status, created_by) " +
            "VALUES (?, ?, ?, ?, ?, ?)";

        System.out.println(
            "[DAO] create(): staffId=" + sh.getStaffId() +
            ", date="   + sh.getShiftDate() +
            ", start="  + sh.getStartTime() +
            ", end="    + sh.getEndTime() +
            ", status=" + sh.getStatus() +
            ", createdBy=" + sh.getCreatedBy()
        );

        try (Connection conn = getConnWithDebug();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, sh.getStaffId());
            ps.setDate(2, Date.valueOf(sh.getShiftDate()));
            ps.setTime(3, Time.valueOf(sh.getStartTime()));
            ps.setTime(4, Time.valueOf(sh.getEndTime()));
            ps.setString(5, sh.getStatus());

            if (sh.getCreatedBy() != null) {
                ps.setInt(6, sh.getCreatedBy());
            } else {
                ps.setNull(6, Types.INTEGER);
            }

            int rows = ps.executeUpdate();
            System.out.println("[DAO] create(): executed rows=" + rows);

            return rows > 0;

        } catch (SQLException e) {
            System.out.println("[DAO] create() SQL ERROR: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    // 4. cập nhật ca
    public boolean update(StaffShift sh) {
        final String sql =
            "UPDATE dbo.shift_schedule " +
            "SET staff_id = ?, " +
            "    shift_date = ?, " +
            "    start_time = ?, " +
            "    end_time = ?, " +
            "    status = ? " +
            "WHERE shift_id = ?";

        System.out.println(
            "[DAO] update(): shiftId=" + sh.getShiftId() +
            ", staffId=" + sh.getStaffId() +
            ", date="    + sh.getShiftDate() +
            ", start="   + sh.getStartTime() +
            ", end="     + sh.getEndTime() +
            ", status="  + sh.getStatus()
        );

        try (Connection conn = getConnWithDebug();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, sh.getStaffId());
            ps.setDate(2, Date.valueOf(sh.getShiftDate()));
            ps.setTime(3, Time.valueOf(sh.getStartTime()));
            ps.setTime(4, Time.valueOf(sh.getEndTime()));
            ps.setString(5, sh.getStatus());
            ps.setInt(6, sh.getShiftId());

            int rows = ps.executeUpdate();
            System.out.println("[DAO] update(): executed rows=" + rows);

            return rows > 0;

        } catch (SQLException e) {
            System.out.println("[DAO] update() SQL ERROR: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    // 5. xoá ca
    public boolean delete(int shiftId) {
        final String sql = "DELETE FROM dbo.shift_schedule WHERE shift_id = ?";

        System.out.println("[DAO] delete(): shiftId=" + shiftId);

        try (Connection conn = getConnWithDebug();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, shiftId);

            int rows = ps.executeUpdate();
            System.out.println("[DAO] delete(): executed rows=" + rows);

            return rows > 0;

        } catch (SQLException e) {
            System.out.println("[DAO] delete() SQL ERROR: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    // 6. đổi trạng thái ca
    public boolean updateStatus(int shiftId, String newStatus) {
        final String sql =
            "UPDATE dbo.shift_schedule " +
            "SET status = ? " +
            "WHERE shift_id = ?";

        System.out.println("[DAO] updateStatus(): shiftId=" + shiftId +
                           ", newStatus=" + newStatus);

        try (Connection conn = getConnWithDebug();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, shiftId);

            int rows = ps.executeUpdate();
            System.out.println("[DAO] updateStatus(): executed rows=" + rows);

            return rows > 0;

        } catch (SQLException e) {
            System.out.println("[DAO] updateStatus() SQL ERROR: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    // mapResultSet -> StaffShift
    private StaffShift mapRow(ResultSet rs) throws SQLException {
        StaffShift sh = new StaffShift();

        sh.setShiftId(rs.getInt("shift_id"));
        sh.setStaffId(rs.getInt("staff_id"));

        Date sqlDate = rs.getDate("shift_date");
        if (sqlDate != null) {
            sh.setShiftDate(sqlDate.toLocalDate());
        }

        Time sqlStart = rs.getTime("start_time");
        if (sqlStart != null) {
            sh.setStartTime(sqlStart.toLocalTime());
        }

        Time sqlEnd = rs.getTime("end_time");
        if (sqlEnd != null) {
            sh.setEndTime(sqlEnd.toLocalTime());
        }

        sh.setStatus(rs.getString("status"));

        int createdByVal = rs.getInt("created_by");
        sh.setCreatedBy(rs.wasNull() ? null : createdByVal);

        String staffFirst = rs.getString("staff_first");
        String staffLast  = rs.getString("staff_last");
        String staffFull  = ((staffFirst != null ? staffFirst : "") + " " +
                             (staffLast  != null ? staffLast  : "")).trim();
        sh.setStaffFullName(staffFull);

        sh.setStaffPhone(rs.getString("staff_phone"));
        sh.setStaffRoleName(rs.getString("staff_role_name"));

        String crFirst = rs.getString("cr_first");
        String crLast  = rs.getString("cr_last");
        if (crFirst != null || crLast != null) {
            String crFull = ((crFirst != null ? crFirst : "") + " " +
                             (crLast  != null ? crLast  : "")).trim();
            sh.setCreatedByFullName(crFull);
        } else {
            sh.setCreatedByFullName(null);
        }

        return sh;
    }
}
