package Models;

import java.sql.Date;
import java.sql.Time;
import java.time.LocalDateTime;

public class Reservation {
    private int reservationId;
    private Integer customerId;
    private String customerName;
    private String phone;
    private String email;
    private Integer tableId;
    private Date reservationDate;
    private Time reservationTime;
    private int partySize;
    private String status;
    private String specialRequests;
    private Integer createdBy;
    private double depositAmount;
    private String depositStatus;
    private String confirmationCode;
    private String channel;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Các hằng số cho channel
    public static final String CHANNEL_WALKIN = "WALKIN";
    public static final String CHANNEL_PHONE = "PHONE";
    public static final String CHANNEL_WEB = "WEB";
    public static final String CHANNEL_APP = "APP";
    public static final String CHANNEL_OTHER = "OTHER";
    
    // Constructor mặc định
    public Reservation() {
        this.status = "PENDING";
        this.depositStatus = "NONE";
        this.channel = CHANNEL_WEB; // Đặt từ website
        this.depositAmount = 0.0;
    }
    
    // Constructor đầy đủ
    public Reservation(int reservationId, Integer customerId, Integer tableId, 
            Date reservationDate, Time reservationTime, int partySize, 
            String status, String specialRequests, Integer createdBy, 
            double depositAmount, String depositStatus, String confirmationCode, 
            String channel, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.reservationId = reservationId;
        this.customerId = customerId;
        this.tableId = tableId;
        this.reservationDate = reservationDate;
        this.reservationTime = reservationTime;
        this.partySize = partySize;
        this.status = status;
        this.specialRequests = specialRequests;
        this.createdBy = createdBy;
        this.depositAmount = depositAmount;
        this.depositStatus = depositStatus;
        this.confirmationCode = confirmationCode;
        this.channel = channel;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getters and Setters
    public int getReservationId() {
        return reservationId;
    }

    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public Integer getTableId() {
        return tableId;
    }

    public void setTableId(Integer tableId) {
        this.tableId = tableId;
    }

    public Date getReservationDate() {
        return reservationDate;
    }

    public void setReservationDate(Date reservationDate) {
        this.reservationDate = reservationDate;
    }

    public Time getReservationTime() {
        return reservationTime;
    }

    public void setReservationTime(Time reservationTime) {
        this.reservationTime = reservationTime;
    }

    public int getPartySize() {
        return partySize;
    }

    public void setPartySize(int partySize) {
        this.partySize = partySize;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getSpecialRequests() {
        return specialRequests;
    }

    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public double getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(double depositAmount) {
        this.depositAmount = depositAmount;
    }

    public String getDepositStatus() {
        return depositStatus;
    }

    public void setDepositStatus(String depositStatus) {
        this.depositStatus = depositStatus;
    }

    public String getConfirmationCode() {
        return confirmationCode;
    }

    public void setConfirmationCode(String confirmationCode) {
        this.confirmationCode = confirmationCode;
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
}