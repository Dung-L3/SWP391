package Controller;

import Dal.MenuDAO;
import Dal.PricingRuleDAO;
import Models.MenuItem;
import Models.PricingRule;
import Models.User;
import Utils.PricingService;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(urlPatterns = {"/PricingRuleServlet", "/pricing-rules"})
public class PricingRuleServlet extends HttpServlet {

    private final PricingRuleDAO ruleDAO        = new PricingRuleDAO();
    private final MenuDAO        menuDAO        = new MenuDAO();
    private final PricingService pricingService = new PricingService();

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session == null) ? null : (User) session.getAttribute("user");
    }

    private boolean hasPermission(User user) {
        return user != null && "Manager".equals(user.getRoleName());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        request.setAttribute("page", "pricing");

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "list";
        }

        if (!"list".equals(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported action");
            return;
        }

        // 1. Lấy danh sách món
        List<MenuItem> menuItemList =
                menuDAO.getMenuItems(1, 50, null, null, null, "name_asc");
        request.setAttribute("menuItems", menuItemList);

        // 1b. Tính giá hiện tại cho từng món (không dùng setDisplayPrice)
        Map<Integer, BigDecimal> currentPriceMap = new HashMap<>();
        for (MenuItem m : menuItemList) {
            BigDecimal p = pricingService.getCurrentPrice(m);
            if (p == null) {
                p = m.getBasePrice();
            }
            currentPriceMap.put(m.getItemId(), p);
        }
        // JSP có thể lấy giá hiện tại bằng currentPriceMap[itemId]
        request.setAttribute("currentPrices", currentPriceMap);

        // 2. Nếu có itemId -> load chi tiết món + rule
        String menuItemIdParam = request.getParameter("itemId");
        if (menuItemIdParam != null && !menuItemIdParam.isEmpty()) {
            try {
                int menuItemId = Integer.parseInt(menuItemIdParam);

                MenuItem selectedMenuItem = menuDAO.getMenuItemById(menuItemId);
                if (selectedMenuItem == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy món");
                    return;
                }

                BigDecimal selectedCurrentPrice = pricingService.getCurrentPrice(selectedMenuItem);
                if (selectedCurrentPrice == null) {
                    selectedCurrentPrice = selectedMenuItem.getBasePrice();
                }

                List<PricingRule> ruleList = ruleDAO.getRulesByMenuItem(menuItemId);

                request.setAttribute("menuItem", selectedMenuItem);
                request.setAttribute("selectedPrice", selectedCurrentPrice);
                request.setAttribute("rules", ruleList);
                request.getRequestDispatcher("/views/PricingRules.jsp").forward(request, response);
                return;

            } catch (NumberFormatException ignore) {
                // sai itemId -> bỏ qua, chỉ hiển thị list chung
            }
        }

        // 3. Không có itemId hợp lệ -> chỉ hiển thị list
        request.getRequestDispatcher("/views/PricingRules.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }
        if (!hasPermission(currentUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền quản lý giá động.");
            return;
        }

        String action = request.getParameter("action");
        if (!"add".equals(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported action");
            return;
        }

        try {
            PricingRule rule = new PricingRule();

            int menuItemId = Integer.parseInt(request.getParameter("menu_item_id"));
            rule.setMenuItemId(menuItemId);

            String dayOfWeekParam = request.getParameter("day_of_week");
            if (dayOfWeekParam == null || dayOfWeekParam.isEmpty()
                    || "ALL".equalsIgnoreCase(dayOfWeekParam)) {
                rule.setDayOfWeek(null);
            } else {
                rule.setDayOfWeek(Integer.parseInt(dayOfWeekParam));
            }

            rule.setStartTime(LocalTime.parse(request.getParameter("start_time")));
            rule.setEndTime(LocalTime.parse(request.getParameter("end_time")));

            String fixedPriceParam = request.getParameter("fixed_price");
            if (fixedPriceParam == null || fixedPriceParam.isEmpty()) {
                rule.setFixedPrice(null);
            } else {
                rule.setFixedPrice(Double.parseDouble(fixedPriceParam));
            }

            String discountType = request.getParameter("discount_type");
            if (discountType != null && discountType.trim().isEmpty()) {
                discountType = null;
            }
            rule.setDiscountType(discountType);

            String discountValueParam = request.getParameter("discount_value");
            if (discountValueParam == null || discountValueParam.isEmpty()) {
                rule.setDiscountValue(null);
            } else {
                rule.setDiscountValue(Double.parseDouble(discountValueParam));
            }

            rule.setActiveFrom(LocalDate.parse(request.getParameter("active_from")));
            String activeToParam = request.getParameter("active_to");
            if (activeToParam == null || activeToParam.isEmpty()) {
                rule.setActiveTo(null);
            } else {
                rule.setActiveTo(LocalDate.parse(activeToParam));
            }

            rule.setActive(true);
            rule.setCreatedBy(currentUser.getUserId());

            ruleDAO.createRule(rule);

            response.sendRedirect(
                    request.getContextPath()
                            + "/pricing-rules?action=list&itemId=" + menuItemId
            );

        } catch (NumberFormatException | java.time.format.DateTimeParseException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Dữ liệu không hợp lệ.");
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Lỗi khi tạo pricing rule.");
        }
    }
}
