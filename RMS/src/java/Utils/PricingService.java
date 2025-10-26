package Utils;

import Dal.PricingRuleDAO;
import Models.MenuItem;
import Models.PricingRule;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;

/**
 * PricingService:
 * - Lấy rule phù hợp thời điểm hiện tại (nếu có)
 * - Trả về giá cuối cùng cho 1 món (BigDecimal)
 *
 * Ưu tiên dùng:
 * 1. fixedPrice nếu rule có price cố định
 * 2. nếu không có fixedPrice, áp dụng giảm giá (discount_type + discount_value)
 * 3. nếu không có rule hoặc rule không hợp lệ => trả basePrice
 */
public class PricingService {

    private final PricingRuleDAO ruleDAO = new PricingRuleDAO();

    /**
     * Lấy giá "đang áp dụng" cho món (ví dụ để show ra menu cho khách)
     */
    public BigDecimal getCurrentPrice(MenuItem item) {
        if (item == null) {
            return BigDecimal.ZERO;
        }

        BigDecimal base = item.getBasePrice(); // giá gốc từ menu_items
        if (base == null) {
            return BigDecimal.ZERO;
        }

        // Thông tin hiện tại
        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();

        // Java DayOfWeek: MONDAY=1 ... SUNDAY=7
        DayOfWeek jDow = today.getDayOfWeek();
        int dow = jDow.getValue(); // 1..7

        // Lấy rule đang áp dụng từ DB
        PricingRule rule = ruleDAO.getActiveRuleForNow(
                item.getItemId(), // IMPORTANT: dùng đúng getter ID trong MenuItem!
                today,
                dow,
                now
        );

        // Không có rule => trả giá gốc
        if (rule == null) {
            return base;
        }

        // 1. Nếu rule có fixedPrice -> dùng luôn fixedPrice (ví dụ Happy Hour = ly còn 5k)
        if (rule.getFixedPrice() != null) {
            return BigDecimal.valueOf(rule.getFixedPrice());
        }

        // 2. Nếu không có fixedPrice, thì thử áp dụng giảm giá
        //    discountType: "AMOUNT" (giảm số tiền cố định) / "PERCENT" (giảm %)
        String type = rule.getDiscountType();
        Double val = rule.getDiscountValue();

        if (type == null || val == null) {
            // rule không set giảm giá, cũng không set fixedPrice => trả giá gốc
            return base;
        }

        BigDecimal finalPrice = base;

        switch (type) {
            case "AMOUNT": { // giảm số tiền tuyệt đối, ví dụ -10.000đ
                BigDecimal minus = BigDecimal.valueOf(val);
                finalPrice = base.subtract(minus);
                break;
            }
            case "PERCENT": { // giảm theo %
                BigDecimal percent = BigDecimal.valueOf(val);
                // amountToSubtract = base * (percent / 100)
                BigDecimal discountAmount = base
                        .multiply(percent)
                        .divide(BigDecimal.valueOf(100));
                finalPrice = base.subtract(discountAmount);
                break;
            }
            default:
                // discount_type không hợp lệ => bỏ qua
                finalPrice = base;
        }

        // Không cho giá âm (ví dụ giảm nhiều quá)
        if (finalPrice.compareTo(BigDecimal.ZERO) < 0) {
            finalPrice = BigDecimal.ZERO;
        }

        return finalPrice;
    }
}
