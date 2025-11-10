package Controller.auth;

import Dal.DBConnect;
import Dal.TableDAO;
import Models.DiningTable;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.*;

/**
 * Trang chủ /home – đổ dữ liệu động cho Homepage.jsp
 *
 *  - Giới thiệu nhà hàng
 *  - Sơ đồ khu vực (tầng 1, tầng 2, outdoor)
 *  - Danh sách nhân viên + avatar
 *  - Menu + nhóm món
 *  - Khuyến mãi đang áp dụng hôm nay
 *  - Món bán chạy (chọn vài món từ menu)
 *
 * web.xml đã mapping /home tới servlet này.
 */
public class HomeServlet extends HttpServlet {

    private final TableDAO tableDAO = new TableDAO();

    // ====== VIEW MODEL ======

    public static class RestaurantInfo {
        private String name;
        private String heroTitle;
        private String heroSubtitle;
        private String introText;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getHeroTitle() { return heroTitle; }
        public void setHeroTitle(String heroTitle) { this.heroTitle = heroTitle; }

        public String getHeroSubtitle() { return heroSubtitle; }
        public void setHeroSubtitle(String heroSubtitle) { this.heroSubtitle = heroSubtitle; }

        public String getIntroText() { return introText; }
        public void setIntroText(String introText) { this.introText = introText; }
    }

    public static class AreaSummary {
        private String name;
        private String description;
        private int totalTables;
        private int freeTables;
        private int totalSeats;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }

        public int getTotalTables() { return totalTables; }
        public void setTotalTables(int totalTables) { this.totalTables = totalTables; }

        public int getFreeTables() { return freeTables; }
        public void setFreeTables(int freeTables) { this.freeTables = freeTables; }

        public int getTotalSeats() { return totalSeats; }
        public void setTotalSeats(int totalSeats) { this.totalSeats = totalSeats; }
    }

    public static class StaffCard {
        private int id;
        private String fullName;
        private String roleName;
        private String avatarUrl;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }

        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }

        public String getRoleName() { return roleName; }
        public void setRoleName(String roleName) { this.roleName = roleName; }

        public String getAvatarUrl() { return avatarUrl; }
        public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }
    }

    public static class MenuCategoryView {
        private int categoryId;
        private String name;

        public int getCategoryId() { return categoryId; }
        public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
    }

    public static class MenuItemView {
        private int id;
        private int categoryId;
        private String categoryName;
        private String name;
        private String description;
        private BigDecimal price;
        private String imageUrl;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }

        public int getCategoryId() { return categoryId; }
        public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

        public String getCategoryName() { return categoryName; }
        public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }

        public BigDecimal getPrice() { return price; }
        public void setPrice(BigDecimal price) { this.price = price; }

        public String getImageUrl() { return imageUrl; }
        public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    }

    public static class PromotionView {
        private int id;
        private String name;
        private String description;
        private String timeRange;
        private String discountLabel;
        private String menuItemName;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }

        public String getTimeRange() { return timeRange; }
        public void setTimeRange(String timeRange) { this.timeRange = timeRange; }

        public String getDiscountLabel() { return discountLabel; }
        public void setDiscountLabel(String discountLabel) { this.discountLabel = discountLabel; }

        public String getMenuItemName() { return menuItemName; }
        public void setMenuItemName(String menuItemName) { this.menuItemName = menuItemName; }
    }

    // ====== MAIN ======

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1. Giới thiệu
        RestaurantInfo info = new RestaurantInfo();
        info.setName("RMSG4");
        info.setHeroTitle("Thưởng thức<br>Món ăn ngon");
        info.setHeroSubtitle("Nhà hàng tích hợp POS – quản lý bàn, đặt chỗ, đơn mang đi & VNPay trên một hệ thống.");
        info.setIntroText(
                "RMSG4 phục vụ ẩm thực Việt Nam theo phong cách hiện đại. " +
                "Quy trình từ lễ tân, phục vụ, bếp đến thu ngân đều được đồng bộ trên hệ thống RMS G4.");

        // 2. Sơ đồ khu vực
        List<DiningTable> tableList = tableDAO.getDiningTablesByArea(null);
        List<AreaSummary> areaSummaries = buildAreaSummaries(tableList);

        // 3. Nhân viên
        List<StaffCard> staffCards = loadStaffCards();

        // 4. Menu & category
        List<MenuCategoryView> categories = loadCategories();
        List<MenuItemView> menuItems = loadMenuItems();
        List<MenuItemView> bestSellers = pickBestSellers(menuItems, 4);

        // 5. Khuyến mãi hôm nay
        List<PromotionView> promotions = loadTodayPromotions();

        // Bind xuống JSP
        req.setAttribute("restaurantInfo", info);
        req.setAttribute("areaSummaries", areaSummaries);
        req.setAttribute("staffCards", staffCards);
        req.setAttribute("menuCategories", categories);
        req.setAttribute("menuItems", menuItems);
        req.setAttribute("bestSellers", bestSellers);
        req.setAttribute("promotions", promotions);

        req.getRequestDispatcher("/common/Homepage.jsp").forward(req, resp);
    }

    // ====== HELPERS ======

    private List<AreaSummary> buildAreaSummaries(List<DiningTable> tables) {
        Map<String, AreaSummary> map = new LinkedHashMap<>();

        if (tables != null) {
            for (DiningTable t : tables) {
                String areaName = t.getAreaName();
                if (areaName == null || areaName.isBlank()) {
                    areaName = "Khu chung";
                }

                AreaSummary s = map.get(areaName);
                if (s == null) {
                    s = new AreaSummary();
                    s.setName(areaName);

                    String lower = areaName.toLowerCase();
                    if (lower.contains("tầng 1")) {
                        s.setDescription("Khách walk-in / gọi món nhanh");
                    } else if (lower.contains("tầng 2")) {
                        s.setDescription("Phòng riêng / VIP / nhóm đông");
                    } else if (lower.contains("outdoor") || lower.contains("ngoài trời")) {
                        s.setDescription("Khu ngoài trời · chill / hút thuốc");
                    } else {
                        s.setDescription("Khu phục vụ");
                    }

                    map.put(areaName, s);
                }

                s.setTotalTables(s.getTotalTables() + 1);

                // ⚠ FIX: getCapacity() là int, không được so sánh với null
                int cap = t.getCapacity();         // nếu là Integer IDE sẽ auto unbox
                if (cap < 0) cap = 0;              // safeguard
                s.setTotalSeats(s.getTotalSeats() + cap);

                String st = t.getStatus() == null ? "" : t.getStatus().toUpperCase();
                if ("VACANT".equals(st) || "AVAILABLE".equals(st)) {
                    s.setFreeTables(s.getFreeTables() + 1);
                }
            }
        }

        return new ArrayList<>(map.values());
    }

    /** Lấy danh sách nhân viên + avatar từ users. */
    private List<StaffCard> loadStaffCards() {
        List<StaffCard> list = new ArrayList<>();

        String sql =
                "SELECT s.staff_id, s.first_name, s.last_name, s.position, " +
                "       u.avatar_url " +
                "FROM staff s " +
                "LEFT JOIN users u ON s.user_id = u.user_id " +
                "WHERE s.status = 'ACTIVE' " +
                "ORDER BY s.hire_date, s.staff_id";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                StaffCard c = new StaffCard();
                c.setId(rs.getInt("staff_id"));

                String first = rs.getString("first_name");
                String last  = rs.getString("last_name");
                String full  = (first == null ? "" : first) + " " + (last == null ? "" : last);
                c.setFullName(full.trim());

                c.setRoleName(rs.getString("position"));
                c.setAvatarUrl(rs.getString("avatar_url"));
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    /** Lấy nhóm món. */
    private List<MenuCategoryView> loadCategories() {
        List<MenuCategoryView> list = new ArrayList<>();

        String sql =
                "SELECT category_id, category_name, sort_order " +
                "FROM menu_categories " +
                "ORDER BY sort_order, category_name";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                MenuCategoryView c = new MenuCategoryView();
                c.setCategoryId(rs.getInt("category_id"));
                c.setName(rs.getString("category_name"));
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    /** Lấy danh sách món ăn. */
    private List<MenuItemView> loadMenuItems() {
        List<MenuItemView> list = new ArrayList<>();

        String sql =
                "SELECT m.menu_item_id, m.category_id, m.name, m.description, " +
                "       m.base_price, m.image_url, c.category_name " +
                "FROM menu_items m " +
                "JOIN menu_categories c ON m.category_id = c.category_id " +
                "WHERE m.is_active = 1 " +
                "  AND m.availability = 'AVAILABLE' " +
                "ORDER BY c.sort_order, m.name";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                MenuItemView m = new MenuItemView();
                m.setId(rs.getInt("menu_item_id"));
                m.setCategoryId(rs.getInt("category_id"));
                m.setCategoryName(rs.getString("category_name"));
                m.setName(rs.getString("name"));
                m.setDescription(rs.getString("description"));
                m.setPrice(rs.getBigDecimal("base_price"));
                m.setImageUrl(rs.getString("image_url"));
                list.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    /** Lấy vài món đầu tiên làm "bán chạy". */
    private List<MenuItemView> pickBestSellers(List<MenuItemView> all, int limit) {
        List<MenuItemView> result = new ArrayList<>();
        if (all == null || all.isEmpty()) return result;

        int n = Math.min(limit, all.size());
        for (int i = 0; i < n; i++) {
            result.add(all.get(i));
        }
        return result;
    }

    /** Khuyến mãi áp dụng cho hôm nay (theo ngày trong tuần + khoảng ngày). */
    private List<PromotionView> loadTodayPromotions() {
        List<PromotionView> list = new ArrayList<>();

        LocalDate today = LocalDate.now();
        DayOfWeek dow = today.getDayOfWeek();
        int dowValue = dow.getValue(); // 1–7 (Mon–Sun)

        String sql =
                "SELECT TOP 10 r.rule_id, r.discount_type, r.discount_value, " +
                "       r.start_time, r.end_time, r.active_from, r.active_to, " +
                "       r.day_of_week, m.name AS menu_name " +
                "FROM pricing_rules r " +
                "LEFT JOIN menu_items m ON r.menu_item_id = m.menu_item_id " +
                "WHERE r.is_active = 1 " +
                "  AND (r.active_from IS NULL OR r.active_from <= ?) " +
                "  AND (r.active_to   IS NULL OR r.active_to   >= ?) " +
                "  AND (r.day_of_week IS NULL OR r.day_of_week = ?) " +
                "ORDER BY r.start_time";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(today));
            ps.setDate(2, java.sql.Date.valueOf(today));
            ps.setInt(3, dowValue);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PromotionView p = new PromotionView();
                    p.setId(rs.getInt("rule_id"));

                    String menuName = rs.getString("menu_name");
                    p.setMenuItemName(menuName);

                    if (menuName != null) {
                        p.setName("Ưu đãi cho " + menuName);
                    } else {
                        p.setName("Khuyến mãi đặc biệt");
                    }

                    Time start = rs.getTime("start_time");
                    Time end   = rs.getTime("end_time");
                    if (start != null && end != null) {
                        p.setTimeRange(
                                start.toString().substring(0, 5) + " - " +
                                end.toString().substring(0, 5));
                    } else {
                        p.setTimeRange("Cả ngày");
                    }

                    String discountType = rs.getString("discount_type");
                    BigDecimal val      = rs.getBigDecimal("discount_value");
                    String label;
                    if (val == null) {
                        label = "";
                    } else if ("PERCENT".equalsIgnoreCase(discountType)) {
                        label = "-" + val.stripTrailingZeros().toPlainString() + "%";
                    } else {
                        label = "-" + val.stripTrailingZeros().toPlainString() + "đ";
                    }
                    p.setDiscountLabel(label);

                    p.setDescription("Áp dụng trong khung giờ " + p.getTimeRange());
                    list.add(p);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
}
