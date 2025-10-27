package Models;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalTime;

/**
 * PricingRule: quy tắc giá theo khung giờ / ngày trong tuần / khoảng ngày hiệu lực.
 * Một rule có thể:
 *  - đặt "fixedPrice" (giá cố định trong Happy Hour), hoặc
 *  - đặt discount (% hoặc trừ tiền)
 */
public class PricingRule implements Serializable {

    private int ruleId;
    private int menuItemId;

    // 1 = Monday ... 7 = Sunday, null = áp dụng mọi ngày
    private Integer dayOfWeek;

    private LocalTime startTime;
    private LocalTime endTime;

    // Nếu khác null -> dùng luôn giá này thay cho basePrice
    private Double fixedPrice;

    // "PERCENT" (giảm %) / "AMOUNT" (giảm số tiền) / null
    private String discountType;
    private Double discountValue;

    // khoảng ngày rule còn hiệu lực
    private LocalDate activeFrom;
    private LocalDate activeTo; // null = vô thời hạn

    // trạng thái rule
    private boolean active;

    // user tạo rule
    private Integer createdBy;

    // --- Getters / Setters ---

    public int getRuleId() {
        return ruleId;
    }

    public void setRuleId(int ruleId) {
        this.ruleId = ruleId;
    }

    public int getMenuItemId() {
        return menuItemId;
    }

    public void setMenuItemId(int menuItemId) {
        this.menuItemId = menuItemId;
    }

    public Integer getDayOfWeek() {
        return dayOfWeek;
    }

    public void setDayOfWeek(Integer dayOfWeek) {
        this.dayOfWeek = dayOfWeek;
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

    public Double getFixedPrice() {
        return fixedPrice;
    }

    public void setFixedPrice(Double fixedPrice) {
        this.fixedPrice = fixedPrice;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public Double getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(Double discountValue) {
        this.discountValue = discountValue;
    }

    public LocalDate getActiveFrom() {
        return activeFrom;
    }

    public void setActiveFrom(LocalDate activeFrom) {
        this.activeFrom = activeFrom;
    }

    public LocalDate getActiveTo() {
        return activeTo;
    }

    public void setActiveTo(LocalDate activeTo) {
        this.activeTo = activeTo;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }
}
