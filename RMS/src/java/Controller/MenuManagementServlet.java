package Controller;

import Dal.MenuDAO;
import Models.MenuItem;
import Models.MenuCategory;
import Models.User;
import Utils.PricingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * MenuManagementServlet - Handle menu items CRUD operations
 */
public class MenuManagementServlet extends HttpServlet {

    private MenuDAO menuDAO;
    private final PricingService pricingService = new PricingService();

    @Override
    public void init() throws ServletException {
        menuDAO = new MenuDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Auth check
        HttpSession session = request.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // Encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "view":
                    handleViewItem(request, response, currentUser);
                    break;
                case "create":
                    handleCreateForm(request, response, currentUser);
                    break;
                case "edit":
                    handleEditForm(request, response, currentUser);
                    break;
                case "toggle-status":
                    handleToggleStatus(request, response, currentUser);
                    break;
                case "list":
                default:
                    handleListItems(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "CÃ³ lá»—i xáº£y ra: " + e.getMessage());
            request.getRequestDispatcher("/views/MenuManagement.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Auth check
        HttpSession session = request.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // Encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
            return;
        }

        try {
            switch (action) {
                case "create":
                    handleCreateItem(request, response, currentUser);
                    break;
                case "update":
                    handleUpdateItem(request, response, currentUser);
                    break;
                case "delete":
                    handleDeleteItem(request, response, currentUser);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/menu-management");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "CÃ³ lá»—i xáº£y ra: " + e.getMessage());
            handleListItems(request, response);
        }
    }

    /* -------------------------------------------------
     * Helpers / Permissions
     * ------------------------------------------------- */

    private boolean hasMenuManagementPermission(User user) {
        if (user == null) return false;
        // tuá»³ logic: á»Ÿ Ä‘Ã¢y mÃ¬nh coi roleName = "Manager" má»›i Ä‘Æ°á»£c CRUD
        return "Manager".equalsIgnoreCase(user.getRoleName());
    }

    /* -------------------------------------------------
     * GET: List
     * ------------------------------------------------- */
    private void handleListItems(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Params
        String pageParam        = request.getParameter("page");
        String search           = request.getParameter("search");
        String categoryParam    = request.getParameter("category");
        String availability     = request.getParameter("availability");
        String sortBy           = request.getParameter("sortBy");
        String statusParam      = request.getParameter("status");

        // Page number
        int page = 1;
        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException ignore) {
            page = 1;
        }

        // Category filter
        Integer categoryId = null;
        try {
            if (categoryParam != null && !categoryParam.isEmpty() && !"0".equals(categoryParam)) {
                categoryId = Integer.parseInt(categoryParam);
            }
        } catch (NumberFormatException ignore) {
            categoryId = null;
        }

        // Status filter (active/inactive)
        Boolean isActive = null;
        if ("active".equals(statusParam)) {
            isActive = true;
        } else if ("inactive".equals(statusParam)) {
            isActive = false;
        }

        int pageSize = 10;

        // Láº¥y danh sÃ¡ch mÃ³n (bao gá»“m cáº£ mÃ³n bá»‹ táº¡m ngÆ°ng)
        List<MenuItem> menuItems = menuDAO.getAllMenuItemsForManagement(
                page,
                pageSize,
                search,
                categoryId,
                availability,
                sortBy,
                isActive
        );

        // GÃ¡n giÃ¡ hiá»‡n táº¡i (happy hour / rule) cho tá»«ng mÃ³n
        for (MenuItem mi : menuItems) {
            mi.setDisplayPrice(pricingService.getCurrentPrice(mi));
        }

        // Check if JSON response is requested
        String format = request.getParameter("format");
        if ("json".equals(format)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"menuItems\":[");
            for (int i = 0; i < menuItems.size(); i++) {
                MenuItem mi = menuItems.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"itemId\":").append(mi.getItemId()).append(",");
                json.append("\"menuItemId\":").append(mi.getItemId()).append(",");
                json.append("\"categoryId\":").append(mi.getCategoryId()).append(",");
                json.append("\"name\":\"").append(escapeJson(mi.getName())).append("\",");
                json.append("\"description\":\"").append(escapeJson(mi.getDescription())).append("\",");
                json.append("\"basePrice\":").append(mi.getBasePrice().doubleValue()).append(",");
                json.append("\"displayPrice\":").append(mi.getDisplayPrice() != null ? mi.getDisplayPrice().doubleValue() : mi.getBasePrice().doubleValue()).append(",");
                json.append("\"imageUrl\":\"").append(escapeJson(mi.getImageUrl() != null ? mi.getImageUrl() : "")).append("\",");
                json.append("\"categoryName\":\"").append(escapeJson(mi.getCategoryName() != null ? mi.getCategoryName() : "")).append("\",");
                json.append("\"isActive\":").append(mi.isActive()).append(",");
                json.append("\"availability\":\"").append(escapeJson(mi.getAvailability())).append("\"");
                json.append("}");
            }
            json.append("]");
            json.append("}");
            
            response.getWriter().write(json.toString());
            return;
        }

        // Pagination info
        int totalItems = menuDAO.getTotalMenuItemsCountForManagement(search, categoryId, availability, isActive);
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages == 0) totalPages = 1;

        // Categories cho filter
        List<MenuCategory> categories = menuDAO.getAllCategories();

        // Attributes cho JSP
        request.setAttribute("menuItems", menuItems);
        request.setAttribute("categories", categories);

        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("pageSize", pageSize);

        // giá»¯ láº¡i filter state Ä‘á»ƒ form giá»¯ giÃ¡ trá»‹
        request.setAttribute("searchParam", search);
        request.setAttribute("categoryParam", categoryParam);
        request.setAttribute("availabilityParam", availability);
        request.setAttribute("sortByParam", sortBy);
        request.setAttribute("statusParam", statusParam);

        // page active -> navbar highlight
        request.setAttribute("page", "menu");

        // Forward
        request.getRequestDispatcher("/views/MenuManagement.jsp").forward(request, response);
    }

    /* -------------------------------------------------
     * GET: View detail (read-only)
     * ------------------------------------------------- */
    private void handleViewItem(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String itemIdParam = request.getParameter("id");
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
            return;
        }

        try {
            int itemId = Integer.parseInt(itemIdParam);
            MenuItem item = menuDAO.getMenuItemById(itemId);

            if (item == null) {
                request.setAttribute("errorMessage", "KhÃ´ng tÃ¬m tháº¥y mÃ³n Äƒn.");
                handleListItems(request, response);
                return;
            }

            // GiÃ¡ hiá»‡n táº¡i Ä‘á»ƒ show
            item.setDisplayPrice(pricingService.getCurrentPrice(item));

            List<MenuCategory> categories = menuDAO.getAllCategories();

            request.setAttribute("menuItem", item);
            request.setAttribute("categories", categories);
            request.setAttribute("page", "menu");
            request.setAttribute("viewMode", "view");

            request.getRequestDispatcher("/views/MenuItemForm.jsp").forward(request, response);

        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
        }
    }

    /* -------------------------------------------------
     * GET: Create form
     * ------------------------------------------------- */
    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasMenuManagementPermission(currentUser)) {
            request.setAttribute("errorMessage", "Báº¡n khÃ´ng cÃ³ quyá»n thÃªm mÃ³n Äƒn má»›i.");
            handleListItems(request, response);
            return;
        }

        List<MenuCategory> categories = menuDAO.getAllCategories();

        request.setAttribute("categories", categories);
        request.setAttribute("page", "menu");
        request.setAttribute("viewMode", "create");

        request.getRequestDispatcher("/views/MenuItemForm.jsp").forward(request, response);
    }

    /* -------------------------------------------------
     * GET: Edit form
     * ------------------------------------------------- */
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasMenuManagementPermission(currentUser)) {
            request.setAttribute("errorMessage", "Báº¡n khÃ´ng cÃ³ quyá»n chá»‰nh sá»­a mÃ³n Äƒn.");
            handleListItems(request, response);
            return;
        }

        String itemIdParam = request.getParameter("id");
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
            return;
        }

        try {
            int itemId = Integer.parseInt(itemIdParam);
            MenuItem item = menuDAO.getMenuItemById(itemId);

            if (item == null) {
                request.setAttribute("errorMessage", "KhÃ´ng tÃ¬m tháº¥y mÃ³n Äƒn.");
                handleListItems(request, response);
                return;
            }

            // GiÃ¡ hiá»‡n táº¡i Ä‘á»ƒ hiá»ƒn thá»‹ trong form
            item.setDisplayPrice(pricingService.getCurrentPrice(item));

            List<MenuCategory> categories = menuDAO.getAllCategories();

            request.setAttribute("menuItem", item);
            request.setAttribute("categories", categories);
            request.setAttribute("page", "menu");
            request.setAttribute("viewMode", "edit");

            request.getRequestDispatcher("/views/MenuItemForm.jsp").forward(request, response);

        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
        }
    }

    /* -------------------------------------------------
     * POST: Create item
     * ------------------------------------------------- */
    private void handleCreateItem(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasMenuManagementPermission(currentUser)) {
            request.setAttribute("errorMessage", "Báº¡n khÃ´ng cÃ³ quyá»n thÃªm mÃ³n Äƒn má»›i.");
            handleListItems(request, response);
            return;
        }

        String name            = request.getParameter("name");
        String description     = request.getParameter("description");
        String priceParam      = request.getParameter("basePrice");
        String categoryIdParam = request.getParameter("categoryId");
        String availability    = request.getParameter("availability");
        String prepTimeParam   = request.getParameter("preparationTime");
        String activeParam     = request.getParameter("isActive");
        String imageUrl        = request.getParameter("imageUrl");

        if (name == null || name.trim().isEmpty()
                || priceParam == null || priceParam.trim().isEmpty()
                || categoryIdParam == null || categoryIdParam.trim().isEmpty()) {

            request.setAttribute("errorMessage", "Vui lÃ²ng Ä‘iá»n Ä‘áº§y Ä‘á»§ thÃ´ng tin báº¯t buá»™c.");
            handleCreateForm(request, response, currentUser);
            return;
        }

        try {
            BigDecimal basePrice     = new BigDecimal(priceParam);
            int categoryId           = Integer.parseInt(categoryIdParam);
            int preparationTime      = Integer.parseInt(prepTimeParam != null ? prepTimeParam : "0");
            boolean isActive         = "on".equals(activeParam) || "true".equalsIgnoreCase(activeParam);

            MenuItem item = new MenuItem();
            item.setName(name.trim());
            item.setDescription(description != null ? description.trim() : "");
            item.setBasePrice(basePrice);
            item.setCategoryId(categoryId);
            item.setAvailability(availability != null ? availability : "AVAILABLE");
            item.setPreparationTime(preparationTime);
            item.setActive(isActive);
            item.setImageUrl(imageUrl);
            item.setCreatedBy(currentUser.getUserId());

            boolean success = menuDAO.createMenuItem(item);

            if (success) {
                request.getSession().setAttribute("successMessage", "ThÃªm mÃ³n Äƒn thÃ nh cÃ´ng!");
                response.sendRedirect(request.getContextPath() + "/menu-management");
            } else {
                request.setAttribute("errorMessage", "KhÃ´ng thá»ƒ thÃªm mÃ³n Äƒn. Vui lÃ²ng thá»­ láº¡i.");
                handleCreateForm(request, response, currentUser);
            }

        } catch (NumberFormatException nfe) {
            request.setAttribute("errorMessage", "Dá»¯ liá»‡u khÃ´ng há»£p lá»‡. Vui lÃ²ng kiá»ƒm tra láº¡i.");
            handleCreateForm(request, response, currentUser);
        }
    }

    /* -------------------------------------------------
     * POST: Update item
     * ------------------------------------------------- */
    private void handleUpdateItem(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasMenuManagementPermission(currentUser)) {
            request.setAttribute("errorMessage", "Báº¡n khÃ´ng cÃ³ quyá»n chá»‰nh sá»­a mÃ³n Äƒn.");
            handleListItems(request, response);
            return;
        }

        String itemIdParam     = request.getParameter("itemId");
        String name            = request.getParameter("name");
        String description     = request.getParameter("description");
        String priceParam      = request.getParameter("basePrice");
        String categoryIdParam = request.getParameter("categoryId");
        String availability    = request.getParameter("availability");
        String prepTimeParam   = request.getParameter("preparationTime");
        String activeParam     = request.getParameter("isActive");
        String imageUrl        = request.getParameter("imageUrl");

        if (itemIdParam == null || itemIdParam.isEmpty()
                || name == null || name.trim().isEmpty()
                || priceParam == null || priceParam.trim().isEmpty()
                || categoryIdParam == null || categoryIdParam.trim().isEmpty()) {

            request.setAttribute("errorMessage", "Vui lÃ²ng Ä‘iá»n Ä‘áº§y Ä‘á»§ thÃ´ng tin báº¯t buá»™c.");
            handleEditForm(request, response, currentUser);
            return;
        }

        try {
            int itemId              = Integer.parseInt(itemIdParam);
            BigDecimal basePrice    = new BigDecimal(priceParam);
            int categoryId          = Integer.parseInt(categoryIdParam);
            int preparationTime     = Integer.parseInt(prepTimeParam != null ? prepTimeParam : "0");
            boolean isActive        = "on".equals(activeParam) || "true".equalsIgnoreCase(activeParam);

            MenuItem item = new MenuItem();
            item.setItemId(itemId);
            item.setName(name.trim());
            item.setDescription(description != null ? description.trim() : "");
            item.setBasePrice(basePrice);
            item.setCategoryId(categoryId);
            item.setAvailability(availability != null ? availability : "AVAILABLE");
            item.setPreparationTime(preparationTime);
            item.setActive(isActive);
            item.setImageUrl(imageUrl);
            item.setUpdatedBy(currentUser.getUserId());

            boolean success = menuDAO.updateMenuItem(item);

            if (success) {
                request.getSession().setAttribute("successMessage", "Cáº­p nháº­t mÃ³n Äƒn thÃ nh cÃ´ng!");
                response.sendRedirect(request.getContextPath() + "/menu-management");
            } else {
                request.setAttribute("errorMessage", "KhÃ´ng thá»ƒ cáº­p nháº­t mÃ³n Äƒn. Vui lÃ²ng thá»­ láº¡i.");
                handleEditForm(request, response, currentUser);
            }

        } catch (NumberFormatException nfe) {
            request.setAttribute("errorMessage", "Dá»¯ liá»‡u khÃ´ng há»£p lá»‡. Vui lÃ²ng kiá»ƒm tra láº¡i.");
            handleEditForm(request, response, currentUser);
        }
    }

    /* -------------------------------------------------
     * POST: Delete item
     * ------------------------------------------------- */
    private void handleDeleteItem(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasMenuManagementPermission(currentUser)) {
            request.getSession().setAttribute("errorMessage", "Báº¡n khÃ´ng cÃ³ quyá»n xÃ³a mÃ³n Äƒn.");
            response.sendRedirect(request.getContextPath() + "/menu-management");
            return;
        }

        String itemIdParam = request.getParameter("itemId");
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
            return;
        }

        try {
            int itemId = Integer.parseInt(itemIdParam);

            boolean success = menuDAO.deleteMenuItem(itemId, currentUser.getUserId());

            if (success) {
                request.getSession().setAttribute("successMessage", "XÃ³a mÃ³n Äƒn thÃ nh cÃ´ng!");
            } else {
                request.getSession().setAttribute("errorMessage", "KhÃ´ng thá»ƒ xÃ³a mÃ³n Äƒn. Vui lÃ²ng thá»­ láº¡i.");
            }

            response.sendRedirect(request.getContextPath() + "/menu-management");

        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
        }
    }

    /* -------------------------------------------------
     * GET: Toggle menu item status (suspend/activate)
     * ------------------------------------------------- */
    private void handleToggleStatus(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasMenuManagementPermission(currentUser)) {
            request.getSession().setAttribute("errorMessage", "Báº¡n khÃ´ng cÃ³ quyá»n thay Ä‘á»•i tráº¡ng thÃ¡i mÃ³n Äƒn.");
            response.sendRedirect(request.getContextPath() + "/menu-management");
            return;
        }

        String itemIdParam = request.getParameter("id");
        String statusParam = request.getParameter("newStatus");

        if (itemIdParam == null || itemIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
            return;
        }

        try {
            int itemId = Integer.parseInt(itemIdParam);
            boolean newStatus = "true".equals(statusParam) || "1".equals(statusParam);

            boolean success = menuDAO.toggleMenuItemStatus(itemId, newStatus);

            if (success) {
                String message = newStatus ? "ÄÃ£ kÃ­ch hoáº¡t mÃ³n Äƒn thÃ nh cÃ´ng!" : "ÄÃ£ táº¡m ngÆ°ng bÃ¡n mÃ³n thÃ nh cÃ´ng!";
                request.getSession().setAttribute("successMessage", message);
            } else {
                request.getSession().setAttribute("errorMessage", "KhÃ´ng thá»ƒ thay Ä‘á»•i tráº¡ng thÃ¡i mÃ³n Äƒn. Vui lÃ²ng thá»­ láº¡i.");
            }

            response.sendRedirect(request.getContextPath() + "/menu-management");

        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
        }
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
