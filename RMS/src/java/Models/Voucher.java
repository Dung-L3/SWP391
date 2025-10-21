package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Voucher model for discount vouchers management
 */
public class Voucher implements Serializable {
    private static final long serialVersionUID = 1L;

    // Primary fields
    private int voucherId;
    private String code;
    private String description;
    private String discountType; // PERCENT, AMOUNT
    private BigDecimal discountValue;
    private LocalDate validFrom;
    private LocalDate validTo;
    private Integer usageLimit; // null = unlimited
    private BigDecimal minOrderTotal;
    private String status; // ACTIVE, INACTIVE
    private int createdBy;

    // Calculated fields (for display)
    private int timesUsed; // Count from voucher_redemptions
    private int remainingUses; // usageLimit - timesUsed
    private String createdByName;

    // Constructors
    public Voucher() {}

    public Voucher(int voucherId, String code, String description, String discountType, 
                   BigDecimal discountValue, LocalDate validFrom, LocalDate validTo) {
        this.voucherId = voucherId;
        this.code = code;
        this.description = description;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.validFrom = validFrom;
        this.validTo = validTo;
    }

    // Getters and Setters
    public int getVoucherId() { return voucherId; }
    public void setVoucherId(int voucherId) { this.voucherId = voucherId; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }

    public BigDecimal getDiscountValue() { return discountValue; }
    public void setDiscountValue(BigDecimal discountValue) { this.discountValue = discountValue; }

    public LocalDate getValidFrom() { return validFrom; }
    public void setValidFrom(LocalDate validFrom) { this.validFrom = validFrom; }

    public LocalDate getValidTo() { return validTo; }
    public void setValidTo(LocalDate validTo) { this.validTo = validTo; }

    public Integer getUsageLimit() { return usageLimit; }
    public void setUsageLimit(Integer usageLimit) { this.usageLimit = usageLimit; }

    public BigDecimal getMinOrderTotal() { return minOrderTotal; }
    public void setMinOrderTotal(BigDecimal minOrderTotal) { this.minOrderTotal = minOrderTotal; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public int getTimesUsed() { return timesUsed; }
    public void setTimesUsed(int timesUsed) { this.timesUsed = timesUsed; }

    public int getRemainingUses() { return remainingUses; }
    public void setRemainingUses(int remainingUses) { this.remainingUses = remainingUses; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    // Utility methods
    public String getDiscountTypeDisplay() {
        return "PERCENT".equals(discountType) ? "Giảm %" : "Giảm tiền";
    }

    public String getDiscountDisplay() {
        if ("PERCENT".equals(discountType)) {
            return String.format("%.0f%%", discountValue);
        } else {
            return String.format("%,.0f đ", discountValue.doubleValue());
        }
    }

    public String getStatusDisplay() {
        return "ACTIVE".equals(status) ? "Hoạt động" : "Không hoạt động";
    }

    public String getStatusBadgeClass() {
        return "ACTIVE".equals(status) ? "bg-success" : "bg-secondary";
    }

    public boolean isValid() {
        LocalDate today = LocalDate.now();
        return "ACTIVE".equals(status) 
            && (validFrom == null || !today.isBefore(validFrom))
            && (validTo == null || !today.isAfter(validTo))
            && (usageLimit == null || timesUsed < usageLimit);
    }

    public String getValidityDisplay() {
        if (validFrom == null && validTo == null) {
            return "Không giới hạn";
        }
        if (validFrom != null && validTo != null) {
            return validFrom + " đến " + validTo;
        }
        if (validFrom != null) {
            return "Từ " + validFrom;
        }
        return "Đến " + validTo;
    }

    public String getUsageLimitDisplay() {
        if (usageLimit == null) {
            return "Không giới hạn";
        }
        return timesUsed + "/" + usageLimit;
    }

    @Override
    public String toString() {
        return "Voucher{" +
                "voucherId=" + voucherId +
                ", code='" + code + '\'' +
                ", discountType='" + discountType + '\'' +
                ", discountValue=" + discountValue +
                ", status='" + status + '\'' +
                '}';
    }
}

