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
                case "list":
                default:
                    handleListItems(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
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
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            handleListItems(request, response);
        }
    }

    /* -------------------------------------------------
     * Helpers / Permissions
     * ------------------------------------------------- */

    private boolean hasMenuManagementPermission(User user) {
        if (user == null) return false;
        // tuỳ logic: ở đây mình coi roleName = "Manager" mới được CRUD
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

        int pageSize = 10;

        // Lấy danh sách món
        List<MenuItem> menuItems = menuDAO.getMenuItems(
                page,
                pageSize,
                search,
                categoryId,
                availability,
                sortBy
        );

        // Gán giá hiện tại (happy hour / rule) cho từng món
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
                json.append("\"categoryName\":\"").append(escapeJson(mi.getCategoryName() != null ? mi.getCategoryName() : "")).append("\"");
                json.append("}");
            }
            json.append("]");
            json.append("}");
            
            response.getWriter().write(json.toString());
            return;
        }

        // Pagination info
        int totalItems = menuDAO.getTotalMenuItemsCount(search, categoryId, availability);
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

        // giữ lại filter state để form giữ giá trị
        request.setAttribute("searchParam", search);
        request.setAttribute("categoryParam", categoryParam);
        request.setAttribute("availabilityParam", availability);
        request.setAttribute("sortByParam", sortBy);

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
                request.setAttribute("errorMessage", "Không tìm thấy món ăn.");
                handleListItems(request, response);
                return;
            }

            // Giá hiện tại để show
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
            request.setAttribute("errorMessage", "Bạn không có quyền thêm món ăn mới.");
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
            request.setAttribute("errorMessage", "Bạn không có quyền chỉnh sửa món ăn.");
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
                request.setAttribute("errorMessage", "Không tìm thấy món ăn.");
                handleListItems(request, response);
                return;
            }

            // Giá hiện tại để hiển thị trong form
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
            request.setAttribute("errorMessage", "Bạn không có quyền thêm món ăn mới.");
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

            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
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
                request.getSession().setAttribute("successMessage", "Thêm món ăn thành công!");
                response.sendRedirect(request.getContextPath() + "/menu-management");
            } else {
                request.setAttribute("errorMessage", "Không thể thêm món ăn. Vui lòng thử lại.");
                handleCreateForm(request, response, currentUser);
            }

        } catch (NumberFormatException nfe) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            handleCreateForm(request, response, currentUser);
        }
    }

    /* -------------------------------------------------
     * POST: Update item
     * ------------------------------------------------- */
    private void handleUpdateItem(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasMenuManagementPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền chỉnh sửa món ăn.");
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

            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
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
                request.getSession().setAttribute("successMessage", "Cập nhật món ăn thành công!");
                response.sendRedirect(request.getContextPath() + "/menu-management");
            } else {
                request.setAttribute("errorMessage", "Không thể cập nhật món ăn. Vui lòng thử lại.");
                handleEditForm(request, response, currentUser);
            }

        } catch (NumberFormatException nfe) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            handleEditForm(request, response, currentUser);
        }
    }

    /* -------------------------------------------------
     * POST: Delete item
     * ------------------------------------------------- */
    private void handleDeleteItem(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasMenuManagementPermission(currentUser)) {
            request.getSession().setAttribute("errorMessage", "Bạn không có quyền xóa món ăn.");
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
                request.getSession().setAttribute("successMessage", "Xóa món ăn thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể xóa món ăn. Vui lòng thử lại.");
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
