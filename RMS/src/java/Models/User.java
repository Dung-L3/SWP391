package Models;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

/**
 * User model (kèm thông tin role join từ user_roles + roles).
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    // ----- users -----
    private int userId;
    private String username;
    private String email;
    private String passwordHash;       // không render ra UI
    private String firstName;
    private String lastName;
    private String phone;
    private String address;
    private LocalDateTime registrationDate;
    private LocalDateTime lastLogin;
    private String accountStatus;      // ACTIVE / LOCKED / DISABLED / PENDING
    private int failedLoginAttempts;
    private LocalDateTime lockoutUntil;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // avatar (có thể null)
    private String avatarUrl;

    // ----- role (user_roles + roles) -----
    private Integer roleId;            // có thể null
    private String roleName;           // Manager / Receptionist / Waiter / Chef / Cashier / Customer

    /* ================= Constructors ================= */

    public User() { }

    /** Constructor gọn cho các trang UI cần thông tin chính + role + avatar. */
    public User(int userId,
                String username,
                String email,
                String firstName,
                String lastName,
                String phone,
                String address,
                LocalDateTime registrationDate,
                LocalDateTime lastLogin,
                String accountStatus,
                Integer roleId,
                String roleName,
                String avatarUrl) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.phone = phone;
        this.address = address;
        this.registrationDate = registrationDate;
        this.lastLogin = lastLogin;
        this.accountStatus = accountStatus;
        this.roleId = roleId;
        this.roleName = roleName;
        this.avatarUrl = avatarUrl;
    }

    /** Constructor đầy đủ khi cần set thêm security fields & timestamps. */
    public User(int userId, String username, String email, String passwordHash,
                String firstName, String lastName, String phone, String address,
                LocalDateTime registrationDate, LocalDateTime lastLogin, String accountStatus,
                int failedLoginAttempts, LocalDateTime lockoutUntil,
                LocalDateTime createdAt, LocalDateTime updatedAt,
                Integer roleId, String roleName, String avatarUrl) {
        this(userId, username, email, firstName, lastName, phone, address,
             registrationDate, lastLogin, accountStatus, roleId, roleName, avatarUrl);
        this.passwordHash = passwordHash;
        this.failedLoginAttempts = failedLoginAttempts;
        this.lockoutUntil = lockoutUntil;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    /* ================= Getters / Setters ================= */

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public LocalDateTime getRegistrationDate() { return registrationDate; }
    public void setRegistrationDate(LocalDateTime registrationDate) { this.registrationDate = registrationDate; }

    public LocalDateTime getLastLogin() { return lastLogin; }
    public void setLastLogin(LocalDateTime lastLogin) { this.lastLogin = lastLogin; }

    public String getAccountStatus() { return accountStatus; }
    public void setAccountStatus(String accountStatus) { this.accountStatus = accountStatus; }

    public int getFailedLoginAttempts() { return failedLoginAttempts; }
    public void setFailedLoginAttempts(int failedLoginAttempts) { this.failedLoginAttempts = failedLoginAttempts; }

    public LocalDateTime getLockoutUntil() { return lockoutUntil; }
    public void setLockoutUntil(LocalDateTime lockoutUntil) { this.lockoutUntil = lockoutUntil; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public Integer getRoleId() { return roleId; }
    public void setRoleId(Integer roleId) { this.roleId = roleId; }

    public String getRoleName() { return roleName; }
    public void setRoleName(String roleName) { this.roleName = roleName; }

    /* ================= Helpers ================= */

    /** Họ tên hiển thị; rỗng thì fallback username. */
    public String getFullName() {
        String f = firstName == null ? "" : firstName.trim();
        String l = lastName  == null ? "" : lastName.trim();
        String full = (f + " " + l).trim();
        return full.isEmpty() ? (username == null ? "" : username) : full;
    }

    public boolean hasRole(String expected) {
        return roleName != null && roleName.equalsIgnoreCase(expected);
    }

    @Override
    public String toString() {
        return "User{userId=" + userId +
               ", username='" + username + '\'' +
               ", email='" + email + '\'' +
               ", roleName='" + roleName + '\'' +
               '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User that)) return false;
        return userId == that.userId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId);
    }
}
