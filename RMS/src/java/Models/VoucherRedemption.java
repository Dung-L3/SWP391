package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * VoucherRedemption model for tracking voucher usage
 */
public class VoucherRedemption implements Serializable {
    private static final long serialVersionUID = 1L;

    private long redemptionId;
    private int voucherId;
    private Integer customerId;
    private Long billId;
    private LocalDateTime redeemedAt;
    private BigDecimal amount;

    // Join fields
    private String voucherCode;
    private String customerName;
    private String billNo;

    // Constructors
    public VoucherRedemption() {}

    // Getters and Setters
    public long getRedemptionId() { return redemptionId; }
    public void setRedemptionId(long redemptionId) { this.redemptionId = redemptionId; }

    public int getVoucherId() { return voucherId; }
    public void setVoucherId(int voucherId) { this.voucherId = voucherId; }

    public Integer getCustomerId() { return customerId; }
    public void setCustomerId(Integer customerId) { this.customerId = customerId; }

    public Long getBillId() { return billId; }
    public void setBillId(Long billId) { this.billId = billId; }

    public LocalDateTime getRedeemedAt() { return redeemedAt; }
    public void setRedeemedAt(LocalDateTime redeemedAt) { this.redeemedAt = redeemedAt; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getVoucherCode() { return voucherCode; }
    public void setVoucherCode(String voucherCode) { this.voucherCode = voucherCode; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getBillNo() { return billNo; }
    public void setBillNo(String billNo) { this.billNo = billNo; }

    // Utility methods
    public String getFormattedAmount() {
        return String.format("%,.0f đ", amount.doubleValue());
    }

    @Override
    public String toString() {
        return "VoucherRedemption{" +
                "redemptionId=" + redemptionId +
                ", voucherCode='" + voucherCode + '\'' +
                ", amount=" + amount +
                ", redeemedAt=" + redeemedAt +
                '}';
    }
}

