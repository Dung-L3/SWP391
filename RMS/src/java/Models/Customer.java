package Models;

import java.time.LocalDateTime;

public class Customer {
    private int customerId;
    private Integer userId;
    private String fullName;
    private String email;
    private String phone;
    private String address;
    private LocalDateTime registrationDate;
    private int loyaltyPoints;
    private String customerType;
    
    public static final String TYPE_VIP = "VIP";
    public static final String TYPE_MEMBER = "MEMBER";
    public static final String TYPE_WALK_IN = "WALK_IN";
    
    public Customer() {
        this.loyaltyPoints = 0;
        this.customerType = TYPE_WALK_IN; // Default to WALK_IN for new customers
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public LocalDateTime getRegistrationDate() {
        return registrationDate;
    }

    public void setRegistrationDate(LocalDateTime registrationDate) {
        this.registrationDate = registrationDate;
    }

    public int getLoyaltyPoints() {
        return loyaltyPoints;
    }

    public void setLoyaltyPoints(int loyaltyPoints) {
        this.loyaltyPoints = loyaltyPoints;
    }

    public String getCustomerType() {
        return customerType;
    }

    public void setCustomerType(String customerType) {
        this.customerType = customerType;
    }
}