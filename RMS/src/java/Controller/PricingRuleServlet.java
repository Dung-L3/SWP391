package Controller;

import Dal.MenuDAO;
import Dal.PricingRuleDAO;
import Models.MenuItem;
import Models.PricingRule;
import Models.User;
import Utils.PricingService;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(urlPatterns = {
        "/PricingRuleServlet",   // form POST action="/PricingRuleServlet"
        "/pricing-rules"         // GET từ menu sidebar
})
public class PricingRuleServlet extends HttpServlet {

    private final PricingRuleDAO ruleDAO = new PricingRuleDAO();
    private final MenuDAO menuDAO = new MenuDAO();
    private final PricingService pricingService = new PricingService();

    // lấy user đăng nhập
    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute("user");
    }

    // chỉ Manager được phép chỉnh giá
    private boolean hasPermission(User u) {
        return (u != null && "Manager".equals(u.getRoleName()));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // auth
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        // sidebar highlight
        req.setAttribute("page", "pricing");

        // action
        String action = req.getParameter("action");
        if (action == null) action = "list";

        if ("list".equals(action)) {

            // luôn load danh sách món để hiển thị bên trái
            List<MenuItem> menuItems = menuDAO.getMenuItems(
                    1,          // page
                    50,         // pageSize tạm
                    null,       // search filter
                    null,       // category
                    null,       // availability
                    "name_asc"  // sort
            );
            // gán displayPrice hiện tại cho từng món
            // for (MenuItem mi : menuItems) {
            //     mi.setDisplayPrice(pricingService.getCurrentPrice(mi));
            // }
            req.setAttribute("menuItems", menuItems);

            // kiểm tra xem có chọn 1 món cụ thể không
            String itemIdParam = req.getParameter("itemId");
            if (itemIdParam != null && !itemIdParam.isEmpty()) {
                try {
                    int itemId = Integer.parseInt(itemIdParam);

                    // lấy món cụ thể
                    MenuItem item = menuDAO.getMenuItemById(itemId);
                    if (item == null) {
                        resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy món");
                        return;
                    }

                    // giá hiển thị của món đó (áp dụng rule hiện tại)
                    // item.setDisplayPrice(pricingService.getCurrentPrice(item));

                    // danh sách rule của món đó
                    List<PricingRule> rules = ruleDAO.getRulesByMenuItem(itemId);

                    // đẩy sang JSP
                    req.setAttribute("menuItem", item);   // món đang chỉnh
                    req.setAttribute("rules", rules);      // các rule của món

                    // forward sang JSP: ở JSP sẽ có class "picked" -> layout 2 cột
                    req.getRequestDispatcher("/views/PricingRules.jsp").forward(req, resp);
                    return;
                } catch (NumberFormatException ex) {
                    // parse itemId lỗi -> cứ coi như chưa chọn món, rơi xuống forward cuối
                }
            }

            // không có itemId -> chưa chọn món
            // JSP sẽ render dạng grid full width
            req.getRequestDispatcher("/views/PricingRules.jsp").forward(req, resp);
            return;
        }

        // fallback
        resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported action");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }
        if (!hasPermission(currentUser)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền quản lý giá động / khuyến mãi.");
            return;
        }

        String action = req.getParameter("action");

        if ("add".equals(action)) {
            // tạo rule mới từ form trong PricingRules.jsp
            PricingRule r = new PricingRule();

            // món
            int itemId = Integer.parseInt(req.getParameter("menu_item_id"));
            r.setMenuItemId(itemId);

            // day_of_week: "ALL" => null
            String dowStr = req.getParameter("day_of_week");
            if (dowStr == null || dowStr.isEmpty() || "ALL".equalsIgnoreCase(dowStr)) {
                r.setDayOfWeek(null);
            } else {
                r.setDayOfWeek(Integer.parseInt(dowStr));
            }

            // khung giờ
            r.setStartTime(LocalTime.parse(req.getParameter("start_time")));
            r.setEndTime(LocalTime.parse(req.getParameter("end_time")));

            // giá cố định
            String fixedPriceStr = req.getParameter("fixed_price");
            if (fixedPriceStr != null && !fixedPriceStr.isEmpty()) {
                r.setFixedPrice(Double.parseDouble(fixedPriceStr));
            } else {
                r.setFixedPrice(null);
            }

            // discount
            String discountType = req.getParameter("discount_type"); // PERCENT / AMOUNT / ""
            if (discountType != null && discountType.trim().isEmpty()) {
                discountType = null;
            }
            r.setDiscountType(discountType);

            String dv = req.getParameter("discount_value");
            if (dv != null && !dv.isEmpty()) {
                r.setDiscountValue(Double.parseDouble(dv));
            } else {
                r.setDiscountValue(null);
            }

            // khoảng ngày hiệu lực
            r.setActiveFrom(LocalDate.parse(req.getParameter("active_from")));

            String at = req.getParameter("active_to");
            if (at != null && !at.isEmpty()) {
                r.setActiveTo(LocalDate.parse(at));
            } else {
                r.setActiveTo(null);
            }

            // trạng thái + người tạo (nếu DB có cột này)
            r.setActive(true);
            r.setCreatedBy(currentUser.getUserId());

            // lưu rule
            ruleDAO.createRule(r);

            // quay lại trang list với món đang chỉnh (giữ đang ở chế độ picked)
            resp.sendRedirect(req.getContextPath()
                    + "/pricing-rules?action=list&itemId=" + itemId);
            return;
        }

        resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported action");
    }
}
