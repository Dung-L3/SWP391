package Models;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalTime;

/**
 * Đại diện cho 1 ca làm việc của 1 staff cụ thể
 */
public class StaffShift implements Serializable {
    // field gốc từ bảng
    private int shiftId;
    private int staffId;          // FK -> users.user_id (nhân viên được phân ca)
    private LocalDate shiftDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private String status;        // SCHEDULED / DONE / CANCELLED
    private Integer createdBy;    // FK -> users.user_id (quản lý tạo ca)

    // info hiển thị thêm (JOIN)
    private String staffFullName;     // "Phuong Tran"
    private String staffRoleName;     // "Waiter", "Chef", ...
    private String staffPhone;        // "0901..."
    private String createdByFullName; // "Long Nguyen"

    // ==== getters/setters ====
    public int getShiftId() {
        return shiftId;
    }
    public void setShiftId(int shiftId) {
        this.shiftId = shiftId;
    }

    public int getStaffId() {
        return staffId;
    }
    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public LocalDate getShiftDate() {
        return shiftDate;
    }
    public void setShiftDate(LocalDate shiftDate) {
        this.shiftDate = shiftDate;
    }

    public LocalTime getStartTime() {
        return startTime;
    }
    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }
    public void setEndTime(LocalTime endTime) {
        this.endTime = endTime;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }
    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public String getStaffFullName() {
        return staffFullName;
    }
    public void setStaffFullName(String staffFullName) {
        this.staffFullName = staffFullName;
    }

    public String getStaffRoleName() {
        return staffRoleName;
    }
    public void setStaffRoleName(String staffRoleName) {
        this.staffRoleName = staffRoleName;
    }

    public String getStaffPhone() {
        return staffPhone;
    }
    public void setStaffPhone(String staffPhone) {
        this.staffPhone = staffPhone;
    }

    public String getCreatedByFullName() {
        return createdByFullName;
    }
    public void setCreatedByFullName(String createdByFullName) {
        this.createdByFullName = createdByFullName;
    }
}
