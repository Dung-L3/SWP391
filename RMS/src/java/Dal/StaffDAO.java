/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Dal;

import Models.Staff;
import Models.Role;
import Models.User;
import Utils.PasswordUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author donny
 */
public class StaffDAO {
    
    /**
     * Tạo nhân viên mới (Create)
     */
    public boolean createStaff(Staff staff, String password, int roleId) {
        Connection conn = null;
        PreparedStatement userStmt = null;
        PreparedStatement staffStmt = null;
        PreparedStatement roleStmt = null;
        PreparedStatement auditStmt = null;
        
        try {
            conn = DBConnect.getConnection();
            if (conn == null) {
                return false;
            }
            
            conn.setAutoCommit(false); // Bắt đầu transaction
            
            // 1. Tạo user account
            String userSql = "INSERT INTO users (username, email, password_hash, first_name, last_name, phone, address, account_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            userStmt = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS);
            userStmt.setString(1, staff.getEmail()); // username = email
            userStmt.setString(2, staff.getEmail());
            userStmt.setString(3, PasswordUtil.hashPassword(password));
            userStmt.setString(4, staff.getFirstName());
            userStmt.setString(5, staff.getLastName());
            userStmt.setString(6, staff.getPhone());
            userStmt.setString(7, ""); // address empty
            userStmt.setString(8, "ACTIVE");
            
            int userResult = userStmt.executeUpdate();
            if (userResult == 0) {
                conn.rollback();
                return false;
            }
            
            // Lấy user_id vừa tạo
            int userId = 0;
            ResultSet userKeys = userStmt.getGeneratedKeys();
            if (userKeys.next()) {
                userId = userKeys.getInt(1);
            }
            userKeys.close();
            
            // 2. Tạo staff record
            String staffSql = "INSERT INTO staff (user_id, first_name, last_name, email, phone, position, hire_date, salary, status, manager_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            staffStmt = conn.prepareStatement(staffSql, Statement.RETURN_GENERATED_KEYS);
            staffStmt.setInt(1, userId);
            staffStmt.setString(2, staff.getFirstName());
            staffStmt.setString(3, staff.getLastName());
            staffStmt.setString(4, staff.getEmail());
            staffStmt.setString(5, staff.getPhone());
            staffStmt.setString(6, staff.getPosition());
            staffStmt.setDate(7, staff.getHireDate());
            staffStmt.setBigDecimal(8, staff.getSalary());
            staffStmt.setString(9, "ACTIVE");
            staffStmt.setObject(10, staff.getManagerId());
            
            int staffResult = staffStmt.executeUpdate();
            if (staffResult == 0) {
                conn.rollback();
                return false;
            }
            
            // 3. Gán role
            String roleSql = "INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)";
            roleStmt = conn.prepareStatement(roleSql);
            roleStmt.setInt(1, userId);
            roleStmt.setInt(2, roleId);
            
            int roleResult = roleStmt.executeUpdate();
            if (roleResult == 0) {
                conn.rollback();
                return false;
            }
            
            // 4. Ghi audit log
            String auditSql = "INSERT INTO audit_log (user_id, action, table_name, record_id, new_values) VALUES (?, ?, ?, ?, ?)";
            auditStmt = conn.prepareStatement(auditSql);
            auditStmt.setInt(1, userId);
            auditStmt.setString(2, "CREATE_STAFF");
            auditStmt.setString(3, "staff");
            auditStmt.setInt(4, userId);
            auditStmt.setString(5, "{\"action\":\"create\",\"staff_name\":\"" + staff.getFullName() + "\",\"position\":\"" + staff.getPosition() + "\"}");
            
            auditStmt.executeUpdate();
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (auditStmt != null) auditStmt.close();
                if (roleStmt != null) roleStmt.close();
                if (staffStmt != null) staffStmt.close();
                if (userStmt != null) userStmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Lấy danh sách tất cả nhân viên (Read)
     */
    public List<Staff> getAllStaff() {
        List<Staff> staffList = new ArrayList<>();
        String sql = "SELECT s.staff_id, s.user_id, s.first_name, s.last_name, s.email, s.phone, " +
                     "s.position, s.hire_date, s.salary, s.status, s.manager_id, " +
                     "u.account_status, r.role_name " +
                     "FROM staff s " +
                     "LEFT JOIN users u ON s.user_id = u.user_id " +
                     "LEFT JOIN user_roles ur ON u.user_id = ur.user_id " +
                     "LEFT JOIN roles r ON ur.role_id = r.role_id " +
                     "ORDER BY s.staff_id DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Staff staff = new Staff();
                staff.setStaffId(rs.getInt("staff_id"));
                staff.setUserId(rs.getInt("user_id"));
                staff.setFirstName(rs.getString("first_name"));
                staff.setLastName(rs.getString("last_name"));
                staff.setEmail(rs.getString("email"));
                staff.setPhone(rs.getString("phone"));
                staff.setPosition(rs.getString("position"));
                staff.setHireDate(rs.getDate("hire_date"));
                staff.setSalary(rs.getBigDecimal("salary"));
                staff.setStatus(rs.getString("status"));
                staff.setManagerId(rs.getObject("manager_id", Integer.class));
                
                staffList.add(staff);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return staffList;
    }

    /**
     * Tìm kiếm/lọc nhân viên theo keyword và roleId
     */
    public List<Staff> getStaffFiltered(String keywordNullable, Integer roleIdNullable) {
        List<Staff> staffList = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT s.staff_id, s.user_id, s.first_name, s.last_name, s.email, s.phone, ");
        sql.append("s.position, s.hire_date, s.salary, s.status, s.manager_id, u.account_status, r.role_name ");
        sql.append("FROM staff s ");
        sql.append("LEFT JOIN users u ON s.user_id = u.user_id ");
        sql.append("LEFT JOIN user_roles ur ON u.user_id = ur.user_id AND ur.status = 'ACTIVE' ");
        sql.append("LEFT JOIN roles r ON ur.role_id = r.role_id ");
        sql.append("WHERE 1=1 ");
        if (keywordNullable != null && !keywordNullable.trim().isEmpty()) {
            sql.append(" AND (s.first_name LIKE ? OR s.last_name LIKE ? OR s.email LIKE ? OR s.phone LIKE ?) ");
        }
        if (roleIdNullable != null) {
            sql.append(" AND r.role_id = ? ");
        }
        sql.append("ORDER BY s.staff_id DESC");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            if (keywordNullable != null && !keywordNullable.trim().isEmpty()) {
                String kw = "%" + keywordNullable.trim() + "%";
                stmt.setString(idx++, kw);
                stmt.setString(idx++, kw);
                stmt.setString(idx++, kw);
                stmt.setString(idx++, kw);
            }
            if (roleIdNullable != null) {
                stmt.setInt(idx++, roleIdNullable);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Staff staff = new Staff();
                    staff.setStaffId(rs.getInt("staff_id"));
                    staff.setUserId(rs.getInt("user_id"));
                    staff.setFirstName(rs.getString("first_name"));
                    staff.setLastName(rs.getString("last_name"));
                    staff.setEmail(rs.getString("email"));
                    staff.setPhone(rs.getString("phone"));
                    staff.setPosition(rs.getString("position"));
                    staff.setHireDate(rs.getDate("hire_date"));
                    staff.setSalary(rs.getBigDecimal("salary"));
                    staff.setStatus(rs.getString("status"));
                    staff.setManagerId(rs.getObject("manager_id", Integer.class));
                    staffList.add(staff);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return staffList;
    }
    
    /**
     * Lấy thông tin nhân viên theo ID
     */
    public Staff getStaffById(int staffId) {
        String sql = "SELECT s.staff_id, s.user_id, s.first_name, s.last_name, s.email, s.phone, " +
                     "s.position, s.hire_date, s.salary, s.status, s.manager_id, " +
                     "u.account_status, r.role_name " +
                     "FROM staff s " +
                     "LEFT JOIN users u ON s.user_id = u.user_id " +
                     "LEFT JOIN user_roles ur ON u.user_id = ur.user_id " +
                     "LEFT JOIN roles r ON ur.role_id = r.role_id " +
                     "WHERE s.staff_id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, staffId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Staff staff = new Staff();
                staff.setStaffId(rs.getInt("staff_id"));
                staff.setUserId(rs.getInt("user_id"));
                staff.setFirstName(rs.getString("first_name"));
                staff.setLastName(rs.getString("last_name"));
                staff.setEmail(rs.getString("email"));
                staff.setPhone(rs.getString("phone"));
                staff.setPosition(rs.getString("position"));
                staff.setHireDate(rs.getDate("hire_date"));
                staff.setSalary(rs.getBigDecimal("salary"));
                staff.setStatus(rs.getString("status"));
                staff.setManagerId(rs.getObject("manager_id", Integer.class));
                
                return staff;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Cập nhật thông tin nhân viên (Update)
     */
    public boolean updateStaff(Staff staff) {
        Connection conn = null;
        PreparedStatement staffStmt = null;
        PreparedStatement userStmt = null;
        PreparedStatement auditStmt = null;
        
        try {
            conn = DBConnect.getConnection();
            if (conn == null) {
                return false;
            }
            
            conn.setAutoCommit(false);
            
            // 1. Cập nhật staff table
            String staffSql = "UPDATE staff SET first_name = ?, last_name = ?, email = ?, phone = ?, " +
                             "position = ?, salary = ?, manager_id = ? WHERE staff_id = ?";
            staffStmt = conn.prepareStatement(staffSql);
            staffStmt.setString(1, staff.getFirstName());
            staffStmt.setString(2, staff.getLastName());
            staffStmt.setString(3, staff.getEmail());
            staffStmt.setString(4, staff.getPhone());
            staffStmt.setString(5, staff.getPosition());
            staffStmt.setBigDecimal(6, staff.getSalary());
            staffStmt.setObject(7, staff.getManagerId());
            staffStmt.setInt(8, staff.getStaffId());
            
            int staffResult = staffStmt.executeUpdate();
            
            // 2. Cập nhật users table (email, first_name, last_name, phone)
            String userSql = "UPDATE users SET email = ?, first_name = ?, last_name = ?, phone = ? WHERE user_id = ?";
            userStmt = conn.prepareStatement(userSql);
            userStmt.setString(1, staff.getEmail());
            userStmt.setString(2, staff.getFirstName());
            userStmt.setString(3, staff.getLastName());
            userStmt.setString(4, staff.getPhone());
            userStmt.setInt(5, staff.getUserId());
            
            int userResult = userStmt.executeUpdate();
            
            if (staffResult > 0 && userResult > 0) {
                // 3. Ghi audit log
                String auditSql = "INSERT INTO audit_log (user_id, action, table_name, record_id, new_values) VALUES (?, ?, ?, ?, ?)";
                auditStmt = conn.prepareStatement(auditSql);
                auditStmt.setInt(1, staff.getUserId());
                auditStmt.setString(2, "UPDATE_STAFF");
                auditStmt.setString(3, "staff");
                auditStmt.setInt(4, staff.getStaffId());
                auditStmt.setString(5, "{\"action\":\"update\",\"staff_name\":\"" + staff.getFullName() + "\",\"position\":\"" + staff.getPosition() + "\"}");
                
                auditStmt.executeUpdate();
                
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (auditStmt != null) auditStmt.close();
                if (userStmt != null) userStmt.close();
                if (staffStmt != null) staffStmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Vô hiệu hóa nhân viên (Deactivate)
     */
    public boolean deactivateStaff(int staffId, int targetUserId, int actorUserId) {
        Connection conn = null;
        PreparedStatement staffStmt = null;
        PreparedStatement userStmt = null;
        PreparedStatement sessionStmt = null;
        PreparedStatement auditStmt = null;
        
        try {
            conn = DBConnect.getConnection();
            if (conn == null) {
                return false;
            }
            
            conn.setAutoCommit(false);
            
            // 1. Vô hiệu hóa staff
            String staffSql = "UPDATE staff SET status = 'INACTIVE' WHERE staff_id = ?";
            staffStmt = conn.prepareStatement(staffSql);
            staffStmt.setInt(1, staffId);
            int staffResult = staffStmt.executeUpdate();
            
            // 2. Vô hiệu hóa user account
            String userSql = "UPDATE users SET account_status = 'DISABLED' WHERE user_id = ?";
            userStmt = conn.prepareStatement(userSql);
            userStmt.setInt(1, targetUserId);
            int userResult = userStmt.executeUpdate();
            
            // 3. Revoke tất cả sessions
            String sessionSql = "UPDATE sessions SET status = 'REVOKED' WHERE user_id = ? AND status = 'ACTIVE'";
            sessionStmt = conn.prepareStatement(sessionSql);
            sessionStmt.setInt(1, targetUserId);
            sessionStmt.executeUpdate();
            
            if (staffResult > 0 && userResult > 0) {
                // 4. Ghi audit log
                String auditSql = "INSERT INTO audit_log (user_id, action, table_name, record_id, new_values) VALUES (?, ?, ?, ?, ?)";
                auditStmt = conn.prepareStatement(auditSql);
                auditStmt.setInt(1, actorUserId);
                auditStmt.setString(2, "DEACTIVATE_STAFF");
                auditStmt.setString(3, "staff");
                auditStmt.setInt(4, staffId);
                auditStmt.setString(5, "{\"action\":\"deactivate\",\"staff_id\":" + staffId + ",\"target_user_id\":" + targetUserId + "}");
                
                auditStmt.executeUpdate();
                
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (auditStmt != null) auditStmt.close();
                if (sessionStmt != null) sessionStmt.close();
                if (userStmt != null) userStmt.close();
                if (staffStmt != null) staffStmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // Activate staff/user back
    public boolean activateStaff(int staffId, int targetUserId, int actorUserId) {
        Connection conn = null;
        PreparedStatement staffStmt = null;
        PreparedStatement userStmt = null;
        PreparedStatement auditStmt = null;

        try {
            conn = DBConnect.getConnection();
            if (conn == null) return false;

            conn.setAutoCommit(false);

            // 1. Kích hoạt staff
            String staffSql = "UPDATE staff SET status = 'ACTIVE' WHERE staff_id = ?";
            staffStmt = conn.prepareStatement(staffSql);
            staffStmt.setInt(1, staffId);
            int staffResult = staffStmt.executeUpdate();

            // 2. Kích hoạt user
            String userSql = "UPDATE users SET account_status = 'ACTIVE' WHERE user_id = ?";
            userStmt = conn.prepareStatement(userSql);
            userStmt.setInt(1, targetUserId);
            int userResult = userStmt.executeUpdate();

            if (staffResult > 0 && userResult > 0) {
                // 3. Ghi audit log
                String auditSql = "INSERT INTO audit_log (user_id, action, table_name, record_id, new_values) VALUES (?, ?, ?, ?, ?)";
                auditStmt = conn.prepareStatement(auditSql);
                auditStmt.setInt(1, actorUserId);
                auditStmt.setString(2, "ACTIVATE_STAFF");
                auditStmt.setString(3, "staff");
                auditStmt.setInt(4, staffId);
                auditStmt.setString(5, "{\"action\":\"activate\",\"staff_id\":" + staffId + ",\"target_user_id\":" + targetUserId + "}");
                auditStmt.executeUpdate();

                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }
        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException ignored) {}
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (auditStmt != null) auditStmt.close();
                if (userStmt != null) userStmt.close();
                if (staffStmt != null) staffStmt.close();
                if (conn != null) { conn.setAutoCommit(true); conn.close(); }
            } catch (SQLException ignored) {}
        }
    }
    
    /**
     * Lấy danh sách roles
     */
    public List<Role> getAllRoles() {
        List<Role> roleList = new ArrayList<>();
        String sql = "SELECT role_id, role_name, description, status, created_at FROM roles WHERE status = 'ACTIVE' ORDER BY role_name";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Role role = new Role();
                role.setRoleId(rs.getInt("role_id"));
                role.setRoleName(rs.getString("role_name"));
                role.setDescription(rs.getString("description"));
                role.setStatus(rs.getString("status"));
                role.setCreatedAt(rs.getTimestamp("created_at"));
                
                roleList.add(role);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return roleList;
    }
    
    /**
     * Lấy danh sách managers (staff có quyền quản lý)
     */
    public List<Staff> getManagers() {
        List<Staff> managerList = new ArrayList<>();
        String sql = "SELECT s.staff_id, s.user_id, s.first_name, s.last_name, s.position " +
                     "FROM staff s " +
                     "LEFT JOIN user_roles ur ON s.user_id = ur.user_id " +
                     "LEFT JOIN roles r ON ur.role_id = r.role_id " +
                     "WHERE s.status = 'ACTIVE' AND r.role_name IN ('Manager', 'Supervisor') " +
                     "ORDER BY s.first_name, s.last_name";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Staff staff = new Staff();
                staff.setStaffId(rs.getInt("staff_id"));
                staff.setUserId(rs.getInt("user_id"));
                staff.setFirstName(rs.getString("first_name"));
                staff.setLastName(rs.getString("last_name"));
                staff.setPosition(rs.getString("position"));
                
                managerList.add(staff);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return managerList;
    }
}
