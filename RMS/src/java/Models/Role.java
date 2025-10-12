/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Models;

import java.sql.Timestamp;

/**
 *
 * @author donny
 */
public class Role {
    private int roleId;
    private String roleName;
    private String description;
    private String status;
    private Timestamp createdAt;
    
    // Constructor mặc định
    public Role() {
    }
    
    // Constructor đầy đủ
    public Role(int roleId, String roleName, String description, String status, Timestamp createdAt) {
        this.roleId = roleId;
        this.roleName = roleName;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
    }
    
    // Getters và Setters
    public int getRoleId() {
        return roleId;
    }
    
    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }
    
    public String getRoleName() {
        return roleName;
    }
    
    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    // Phương thức tiện ích
    public boolean isActive() {
        return "ACTIVE".equals(status);
    }
    
    @Override
    public String toString() {
        return "Role{" +
                "roleId=" + roleId +
                ", roleName='" + roleName + '\'' +
                ", description='" + description + '\'' +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
