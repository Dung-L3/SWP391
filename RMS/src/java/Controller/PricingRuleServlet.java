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

@WebServlet(urlPatterns = {"/PricingRuleServlet", "/pricing-rules"})
public class PricingRuleServlet extends HttpServlet {

    private final PricingRuleDAO ruleDAO = new PricingRuleDAO();
    private final MenuDAO menuDAO = new MenuDAO();
    private final PricingService pricingService = new PricingService();

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("user");
    }

    private boolean hasPermission(User u) {
        return u != null && "Manager".equals(u.getRoleName());
    }

    // GET: danh sách rule và/hoặc chi tiết rule theo món
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        req.setAttribute("page", "pricing");
        String action = req.getParameter("action");
        if (action == null) {
            action = "list";
        }

        if ("list".equals(action)) {
            List<MenuItem> menuItems = menuDAO.getMenuItems(1, 50, null, null, null, "name_asc");
            for (MenuItem mi : menuItems) {
                mi.setDisplayPrice(pricingService.getCurrentPrice(mi));
            }
            req.setAttribute("menuItems", menuItems);

            String itemIdParam = req.getParameter("itemId");
            if (itemIdParam != null && !itemIdParam.isEmpty()) {
                try {
                    int itemId = Integer.parseInt(itemIdParam);
                    MenuItem item = menuDAO.getMenuItemById(itemId);
                    if (item == null) {
                        resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy món");
                        return;
                    }
                    item.setDisplayPrice(pricingService.getCurrentPrice(item));
                    List<Models.PricingRule> rules = ruleDAO.getRulesByMenuItem(itemId);

                    req.setAttribute("menuItem", item);
                    req.setAttribute("rules", rules);
                    req.getRequestDispatcher("/views/PricingRules.jsp").forward(req, resp);
                    return;
                } catch (NumberFormatException ignore) {
                    // rơi xuống forward chung
                }
            }

            req.getRequestDispatcher("/views/PricingRules.jsp").forward(req, resp);
            return;
        }

        resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported action");
    }

    // POST: tạo rule mới
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
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý giá động.");
            return;
        }

        String action = req.getParameter("action");
        if (!"add".equals(action)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported action");
            return;
        }

        try {
            PricingRule r = new PricingRule();

            int itemId = Integer.parseInt(req.getParameter("menu_item_id"));
            r.setMenuItemId(itemId);

            String dowStr = req.getParameter("day_of_week");
            r.setDayOfWeek((dowStr == null || dowStr.isEmpty() || "ALL".equalsIgnoreCase(dowStr))
                    ? null : Integer.parseInt(dowStr));

            r.setStartTime(LocalTime.parse(req.getParameter("start_time")));
            r.setEndTime(LocalTime.parse(req.getParameter("end_time")));

            String fixedPriceStr = req.getParameter("fixed_price");
            r.setFixedPrice((fixedPriceStr == null || fixedPriceStr.isEmpty())
                    ? null : Double.parseDouble(fixedPriceStr));

            String discountType = req.getParameter("discount_type");
            if (discountType != null && discountType.trim().isEmpty()) {
                discountType = null;
            }
            r.setDiscountType(discountType);

            String dv = req.getParameter("discount_value");
            r.setDiscountValue((dv == null || dv.isEmpty()) ? null : Double.parseDouble(dv));

            r.setActiveFrom(LocalDate.parse(req.getParameter("active_from")));
            String at = req.getParameter("active_to");
            r.setActiveTo((at == null || at.isEmpty()) ? null : LocalDate.parse(at));

            r.setActive(true);
            r.setCreatedBy(currentUser.getUserId());

            ruleDAO.createRule(r);

            resp.sendRedirect(req.getContextPath() + "/pricing-rules?action=list&itemId=" + itemId);
        } catch (NumberFormatException | java.time.format.DateTimeParseException ex) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Dữ liệu không hợp lệ.");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi tạo pricing rule.");
        }
    }
}
