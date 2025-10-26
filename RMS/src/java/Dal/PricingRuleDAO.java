package Dal;

import Models.PricingRule;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng pricing_rules
 */
public class PricingRuleDAO {

    /**
     * Lấy rule đang áp dụng NGAY BÂY GIỜ cho 1 món.
     * Ưu tiên rule mới nhất (rule_id DESC).
     *
     * @param menuItemId id món (menu_items.menu_item_id / item_id)
     * @param today      LocalDate.now()
     * @param dayOfWeek  Thứ hiện tại (1 = Monday ... 7 = Sunday)
     * @param now        LocalTime.now()
     */
    public PricingRule getActiveRuleForNow(int menuItemId,
                                           LocalDate today,
                                           int dayOfWeek,
                                           LocalTime now) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnect.getConnection();
            if (conn == null) return null;

            // Giải thích điều kiện day_of_week:
            // - day_of_week IS NULL  -> áp dụng mọi ngày
            // - day_of_week = 0      -> áp dụng mọi ngày
            // - day_of_week = ?      -> áp dụng riêng thứ cụ thể (1..7)
            //
            // Thời gian:
            // CAST(? AS time) giữa start_time và end_time
            //
            // Ngày hiệu lực:
            // today BETWEEN active_from AND active_to (hoặc active_to NULL => 9999-12-31)
            String sql =
                "SELECT TOP 1 * " +
                "FROM pricing_rules " +
                "WHERE menu_item_id = ? " +
                "  AND (day_of_week IS NULL OR day_of_week = 0 OR day_of_week = ?) " +
                "  AND (CAST(? AS time) BETWEEN CAST(start_time AS time) AND CAST(end_time AS time)) " +
                "  AND (? BETWEEN active_from AND ISNULL(active_to, '9999-12-31')) " +
                "ORDER BY rule_id DESC";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, menuItemId);                // menu_item_id = ?
            stmt.setInt(2, dayOfWeek);                 // ... OR day_of_week = ?
            stmt.setTime(3, Time.valueOf(now));        // CAST(? AS time)
            stmt.setDate(4, Date.valueOf(today));      // ? BETWEEN active_from ...

            rs = stmt.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeQuiet(rs, stmt, conn);
        }
        return null;
    }

    /**
     * Lấy toàn bộ rule của 1 món (cho trang manager xem list rule)
     */
    public List<PricingRule> getRulesByMenuItem(int menuItemId) {
        List<PricingRule> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnect.getConnection();
            String sql =
                "SELECT * " +
                "FROM pricing_rules " +
                "WHERE menu_item_id = ? " +
                "ORDER BY rule_id DESC";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, menuItemId);
            rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeQuiet(rs, stmt, conn);
        }
        return list;
    }

    /**
     * Tạo rule mới (POST từ PricingRuleServlet khi manager submit form)
     */
    public boolean createRule(PricingRule r) {
        Connection conn = null;
        PreparedStatement stmt = null;
        try {
            conn = DBConnect.getConnection();
            if (conn == null) return false;

            // Bảng hiện tại: rule_id, menu_item_id, day_of_week, start_time, end_time,
            // price, discount_type, discount_value, active_from, active_to
            // (không có is_active / created_by theo hình bạn gửi)
            String sql =
                "INSERT INTO pricing_rules " +
                " (menu_item_id, day_of_week, start_time, end_time, price, " +
                "  discount_type, discount_value, active_from, active_to) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            stmt = conn.prepareStatement(sql);

            // menu_item_id
            stmt.setInt(1, r.getMenuItemId());

            // day_of_week:
            // cho phép NULL (mọi ngày), 0 (mọi ngày), hoặc 1..7 (cụ thể thứ)
            if (r.getDayOfWeek() == null) {
                stmt.setNull(2, Types.INTEGER);
            } else {
                stmt.setInt(2, r.getDayOfWeek());
            }

            // start_time / end_time
            stmt.setTime(3, Time.valueOf(r.getStartTime()));
            stmt.setTime(4, Time.valueOf(r.getEndTime()));

            // price (fixedPrice)
            if (r.getFixedPrice() == null) {
                stmt.setNull(5, Types.DECIMAL);
            } else {
                stmt.setDouble(5, r.getFixedPrice());
            }

            // discount_type
            if (r.getDiscountType() == null) {
                stmt.setNull(6, Types.VARCHAR);
            } else {
                stmt.setString(6, r.getDiscountType());
            }

            // discount_value
            if (r.getDiscountValue() == null) {
                stmt.setNull(7, Types.DECIMAL);
            } else {
                stmt.setDouble(7, r.getDiscountValue());
            }

            // active_from
            stmt.setDate(8, Date.valueOf(r.getActiveFrom()));

            // active_to (nullable)
            if (r.getActiveTo() == null) {
                stmt.setNull(9, Types.DATE);
            } else {
                stmt.setDate(9, Date.valueOf(r.getActiveTo()));
            }

            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeQuiet(null, stmt, conn);
        }
        return false;
    }

    /**
     * map 1 record pricing_rules -> PricingRule object
     */
    private PricingRule mapRow(ResultSet rs) throws SQLException {
        PricingRule pr = new PricingRule();

        pr.setRuleId(rs.getInt("rule_id"));
        pr.setMenuItemId(rs.getInt("menu_item_id"));

        int dowVal = rs.getInt("day_of_week");
        pr.setDayOfWeek(rs.wasNull() ? null : dowVal);

        Time st = rs.getTime("start_time");
        Time et = rs.getTime("end_time");
        pr.setStartTime(st != null ? st.toLocalTime() : null);
        pr.setEndTime(et != null ? et.toLocalTime() : null);

        double fx = rs.getDouble("price");
        pr.setFixedPrice(rs.wasNull() ? null : fx);

        pr.setDiscountType(rs.getString("discount_type"));

        double dv = rs.getDouble("discount_value");
        pr.setDiscountValue(rs.wasNull() ? null : dv);

        Date af = rs.getDate("active_from");
        Date at = rs.getDate("active_to");
        pr.setActiveFrom(af != null ? af.toLocalDate() : null);
        pr.setActiveTo(at != null ? at.toLocalDate() : null);

        // bảng chưa có is_active => mặc định true
        pr.setActive(true);

        // bảng chưa có created_by => để null
        pr.setCreatedBy(null);

        return pr;
    }

    private void closeQuiet(ResultSet rs, Statement st, Connection c) {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (st != null) st.close(); } catch (Exception ignored) {}
        try { if (c != null) c.close(); } catch (Exception ignored) {}
    }
}
