package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * @author donny
 */
public class PricingRule implements Serializable {
    private static final long serialVersionUID = 1L;

    // Rule types
    public static final String TYPE_PERCENTAGE = "PERCENTAGE";
    public static final String TYPE_FIXED_AMOUNT = "FIXED_AMOUNT";
    public static final String TYPE_TIME_BASED = "TIME_BASED";
    public static final String TYPE_DAY_BASED = "DAY_BASED";

    // Day types
    public static final String DAY_WEEKDAY = "WEEKDAY";
    public static final String DAY_WEEKEND = "WEEKEND";
    public static final String DAY_HOLIDAY = "HOLIDAY";

    private Long pricingRuleId;
    private String ruleName;
    private String ruleType;
    private String dayOfWeek;
    private LocalTime startTime;
    private LocalTime endTime;
    private BigDecimal adjustmentValue;
    private String adjustmentType; // INCREASE, DECREASE
    private Integer menuItemId;
    private Integer categoryId;
    private String status;
    private String description;
    private Integer priority;
    private LocalDateTime validFrom;
    private LocalDateTime validTo;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer createdBy;

    // Constructors
    public PricingRule() {}

    public PricingRule(String ruleName, String ruleType, BigDecimal adjustmentValue, String adjustmentType) {
        this.ruleName = ruleName;
        this.ruleType = ruleType;
        this.adjustmentValue = adjustmentValue;
        this.adjustmentType = adjustmentType;
        this.status = "ACTIVE";
        this.priority = 1;
    }

    // Getters and Setters
    public Long getPricingRuleId() { return pricingRuleId; }
    public void setPricingRuleId(Long pricingRuleId) { this.pricingRuleId = pricingRuleId; }

    public String getRuleName() { return ruleName; }
    public void setRuleName(String ruleName) { this.ruleName = ruleName; }

    public String getRuleType() { return ruleType; }
    public void setRuleType(String ruleType) { this.ruleType = ruleType; }

    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public LocalTime getEndTime() { return endTime; }
    public void setEndTime(LocalTime endTime) { this.endTime = endTime; }

    public BigDecimal getAdjustmentValue() { return adjustmentValue; }
    public void setAdjustmentValue(BigDecimal adjustmentValue) { this.adjustmentValue = adjustmentValue; }

    public String getAdjustmentType() { return adjustmentType; }
    public void setAdjustmentType(String adjustmentType) { this.adjustmentType = adjustmentType; }

    public Integer getMenuItemId() { return menuItemId; }
    public void setMenuItemId(Integer menuItemId) { this.menuItemId = menuItemId; }

    public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getPriority() { return priority; }
    public void setPriority(Integer priority) { this.priority = priority; }

    public LocalDateTime getValidFrom() { return validFrom; }
    public void setValidFrom(LocalDateTime validFrom) { this.validFrom = validFrom; }

    public LocalDateTime getValidTo() { return validTo; }
    public void setValidTo(LocalDateTime validTo) { this.validTo = validTo; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    // Helper methods
    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isPercentage() { return TYPE_PERCENTAGE.equals(ruleType); }
    public boolean isFixedAmount() { return TYPE_FIXED_AMOUNT.equals(ruleType); }
    public boolean isTimeBased() { return TYPE_TIME_BASED.equals(ruleType); }
    public boolean isDayBased() { return TYPE_DAY_BASED.equals(ruleType); }
    public boolean isIncrease() { return "INCREASE".equals(adjustmentType); }
    public boolean isDecrease() { return "DECREASE".equals(adjustmentType); }

    public boolean isWeekday() { return DAY_WEEKDAY.equals(dayOfWeek); }
    public boolean isWeekend() { return DAY_WEEKEND.equals(dayOfWeek); }
    public boolean isHoliday() { return DAY_HOLIDAY.equals(dayOfWeek); }

    public boolean isTimeInRange(LocalTime time) {
        if (startTime == null || endTime == null) return true;
        if (startTime.isBefore(endTime)) {
            return !time.isBefore(startTime) && !time.isAfter(endTime);
        } else {
            // Handle overnight ranges (e.g., 22:00 to 06:00)
            return !time.isBefore(startTime) || !time.isAfter(endTime);
        }
    }

    public boolean isDayMatch(DayOfWeek dayOfWeek) {
        if (this.dayOfWeek == null) return true;
        if (DAY_WEEKDAY.equals(this.dayOfWeek)) {
            return dayOfWeek != DayOfWeek.SATURDAY && dayOfWeek != DayOfWeek.SUNDAY;
        } else if (DAY_WEEKEND.equals(this.dayOfWeek)) {
            return dayOfWeek == DayOfWeek.SATURDAY || dayOfWeek == DayOfWeek.SUNDAY;
        }
        return this.dayOfWeek.equals(dayOfWeek.toString());
    }
}
