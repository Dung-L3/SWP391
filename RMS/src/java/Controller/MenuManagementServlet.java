package Controller;

import Dal.MenuDAO;
import Models.MenuItem;
import Models.MenuCategory;
import Models.User;
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

    @Override
    public void init() throws ServletException {
        menuDAO = new MenuDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "list":
                    handleListItems(request, response);
                    break;
                case "view":
                    handleViewItem(request, response);
                    break;
                case "create":
                    handleCreateForm(request, response);
                    break;
                case "edit":
                    handleEditForm(request, response);
                    break;
                default:
                    handleListItems(request, response);
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

        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // Set UTF-8 encoding
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
                    handleCreateItem(request, response);
                    break;
                case "update":
                    handleUpdateItem(request, response);
                    break;
                case "delete":
                    handleDeleteItem(request, response);
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

    /**
     * Check if user has permission to manage menu
     */
    private boolean hasMenuManagementPermission(User user) {
        return "Manager".equals(user.getRoleName());
    }

    /**
     * Handle list items with pagination, search, and filters
     */
    private void handleListItems(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get parameters
        String pageParam = request.getParameter("page");
        String search = request.getParameter("search");
        String categoryParam = request.getParameter("category");
        String availability = request.getParameter("availability");
        String sortBy = request.getParameter("sortBy");

        // Parse parameters
        int page = 1;
        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        Integer categoryId = null;
        try {
            if (categoryParam != null && !categoryParam.isEmpty() && !"0".equals(categoryParam)) {
                categoryId = Integer.parseInt(categoryParam);
            }
        } catch (NumberFormatException e) {
            categoryId = null;
        }

        int pageSize = 10;

        // Get data
        List<MenuItem> menuItems = menuDAO.getMenuItems(page, pageSize, search, categoryId, availability, sortBy);
        int totalItems = menuDAO.getTotalMenuItemsCount(search, categoryId, availability);
        List<MenuCategory> categories = menuDAO.getAllCategories();

        // Calculate pagination
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages == 0) totalPages = 1;

        // Set attributes
        request.setAttribute("menuItems", menuItems);
        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("pageSize", pageSize);

        // Preserve filter parameters
        request.setAttribute("searchParam", search);
        request.setAttribute("categoryParam", categoryParam);
        request.setAttribute("availabilityParam", availability);
        request.setAttribute("sortByParam", sortBy);

        // Set page context
        request.setAttribute("page", "menu");

        // Forward to JSP
        request.getRequestDispatcher("/views/MenuManagement.jsp").forward(request, response);
    }

    /**
     * Handle view single item
     */
    private void handleViewItem(HttpServletRequest request, HttpServletResponse response)
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

            List<MenuCategory> categories = menuDAO.getAllCategories();

            request.setAttribute("menuItem", item);
            request.setAttribute("categories", categories);
            request.setAttribute("page", "menu");
            request.setAttribute("viewMode", "view");

            request.getRequestDispatcher("/views/MenuItemForm.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
        }
    }

    /**
     * Handle create form
     */
    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("user");
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

    /**
     * Handle edit form
     */
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("user");
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

            List<MenuCategory> categories = menuDAO.getAllCategories();

            request.setAttribute("menuItem", item);
            request.setAttribute("categories", categories);
            request.setAttribute("page", "menu");
            request.setAttribute("viewMode", "edit");

            request.getRequestDispatcher("/views/MenuItemForm.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
        }
    }

    /**
     * Handle create item
     */
    private void handleCreateItem(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("user");
        if (!hasMenuManagementPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền thêm món ăn mới.");
            handleListItems(request, response);
            return;
        }

        // Get form data
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String priceParam = request.getParameter("basePrice");
        String categoryIdParam = request.getParameter("categoryId");
        String availability = request.getParameter("availability");
        String prepTimeParam = request.getParameter("preparationTime");
        String activeParam = request.getParameter("isActive");
        String imageUrl = request.getParameter("imageUrl");

        // Debug logging
        System.out.println("CREATE - Parameters received:");
        System.out.println("name: " + name);
        System.out.println("priceParam: " + priceParam);
        System.out.println("categoryIdParam: " + categoryIdParam);

        // Validate required fields
        if (name == null || name.trim().isEmpty() ||
            priceParam == null || priceParam.trim().isEmpty() ||
            categoryIdParam == null || categoryIdParam.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
            handleCreateForm(request, response);
            return;
        }

        // Validate name length
        if (name.trim().length() < 3) {
            request.setAttribute("errorMessage", "Tên món ăn phải có ít nhất 3 ký tự.");
            handleCreateForm(request, response);
            return;
        }
        
        if (name.trim().length() > 100) {
            request.setAttribute("errorMessage", "Tên món ăn không được vượt quá 100 ký tự.");
            handleCreateForm(request, response);
            return;
        }

        // Validate description length
        if (description != null && description.trim().length() > 500) {
            request.setAttribute("errorMessage", "Mô tả không được vượt quá 500 ký tự.");
            handleCreateForm(request, response);
            return;
        }

        try {
            // Parse data
            BigDecimal basePrice = new BigDecimal(priceParam);
            int categoryId = Integer.parseInt(categoryIdParam);
            int preparationTime = Integer.parseInt(prepTimeParam != null && !prepTimeParam.trim().isEmpty() ? prepTimeParam : "0");
            boolean isActive = "on".equals(activeParam) || "true".equals(activeParam);

            // Validate price
            if (basePrice.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("errorMessage", "Giá món ăn phải lớn hơn 0.");
                handleCreateForm(request, response);
                return;
            }

            if (basePrice.compareTo(new BigDecimal("10000000")) > 0) {
                request.setAttribute("errorMessage", "Giá món ăn không được vượt quá 10,000,000 VNĐ.");
                handleCreateForm(request, response);
                return;
            }

            // Validate category exists
            if (categoryId < 1 || categoryId > 5) {
                request.setAttribute("errorMessage", "Danh mục không hợp lệ.");
                handleCreateForm(request, response);
                return;
            }

            // Validate preparation time
            if (preparationTime < 0) {
                request.setAttribute("errorMessage", "Thời gian chuẩn bị không được âm.");
                handleCreateForm(request, response);
                return;
            }

            if (preparationTime > 300) {
                request.setAttribute("errorMessage", "Thời gian chuẩn bị không được vượt quá 300 phút.");
                handleCreateForm(request, response);
                return;
            }

            // Validate image URL format (if provided)
            if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                String urlLower = imageUrl.trim().toLowerCase();
                if (!urlLower.startsWith("http://") && !urlLower.startsWith("https://")) {
                    request.setAttribute("errorMessage", "URL hình ảnh phải bắt đầu với http:// hoặc https://");
                    handleCreateForm(request, response);
                    return;
                }
            }

            // Create menu item
            MenuItem item = new MenuItem();
            item.setName(name.trim());
            item.setDescription(description != null ? description.trim() : "");
            item.setBasePrice(basePrice);
            item.setCategoryId(categoryId);
            item.setAvailability(availability != null ? availability : "AVAILABLE");
            item.setPreparationTime(preparationTime);
            item.setActive(true); // New items are active by default
            item.setImageUrl(imageUrl);
            item.setCreatedBy(currentUser.getUserId());

            // Save to database
            boolean success = menuDAO.createMenuItem(item);

            if (success) {
                request.getSession().setAttribute("successMessage", "Thêm món ăn thành công!");
                response.sendRedirect(request.getContextPath() + "/menu-management");
            } else {
                request.setAttribute("errorMessage", "Không thể thêm món ăn. Vui lòng thử lại.");
                handleCreateForm(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            handleCreateForm(request, response);
        }
    }

    /**
     * Handle update item
     */
    private void handleUpdateItem(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("user");
        if (!hasMenuManagementPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền chỉnh sửa món ăn.");
            handleListItems(request, response);
            return;
        }

        String itemIdParam = request.getParameter("itemId");
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
            return;
        }

        // Get form data
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String priceParam = request.getParameter("basePrice");
        String categoryIdParam = request.getParameter("categoryId");
        String availability = request.getParameter("availability");
        String prepTimeParam = request.getParameter("preparationTime");
        String activeParam = request.getParameter("isActive");
        String imageUrl = request.getParameter("imageUrl");

        // Validate required fields
        if (name == null || name.trim().isEmpty() ||
            priceParam == null || priceParam.trim().isEmpty() ||
            categoryIdParam == null || categoryIdParam.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
            handleEditForm(request, response);
            return;
        }

        // Validate name length
        if (name.trim().length() < 3) {
            request.setAttribute("errorMessage", "Tên món ăn phải có ít nhất 3 ký tự.");
            handleEditForm(request, response);
            return;
        }
        
        if (name.trim().length() > 100) {
            request.setAttribute("errorMessage", "Tên món ăn không được vượt quá 100 ký tự.");
            handleEditForm(request, response);
            return;
        }

        // Validate description length
        if (description != null && description.trim().length() > 500) {
            request.setAttribute("errorMessage", "Mô tả không được vượt quá 500 ký tự.");
            handleEditForm(request, response);
            return;
        }

        try {
            // Parse data
            int itemId = Integer.parseInt(itemIdParam);
            BigDecimal basePrice = new BigDecimal(priceParam);
            int categoryId = Integer.parseInt(categoryIdParam);
            int preparationTime = Integer.parseInt(prepTimeParam != null && !prepTimeParam.trim().isEmpty() ? prepTimeParam : "0");
            boolean isActive = "on".equals(activeParam) || "true".equals(activeParam);

            // Validate price
            if (basePrice.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("errorMessage", "Giá món ăn phải lớn hơn 0.");
                handleEditForm(request, response);
                return;
            }

            if (basePrice.compareTo(new BigDecimal("10000000")) > 0) {
                request.setAttribute("errorMessage", "Giá món ăn không được vượt quá 10,000,000 VNĐ.");
                handleEditForm(request, response);
                return;
            }

            // Validate category exists
            if (categoryId < 1 || categoryId > 5) {
                request.setAttribute("errorMessage", "Danh mục không hợp lệ.");
                handleEditForm(request, response);
                return;
            }

            // Validate preparation time
            if (preparationTime < 0) {
                request.setAttribute("errorMessage", "Thời gian chuẩn bị không được âm.");
                handleEditForm(request, response);
                return;
            }

            if (preparationTime > 300) {
                request.setAttribute("errorMessage", "Thời gian chuẩn bị không được vượt quá 300 phút.");
                handleEditForm(request, response);
                return;
            }

            // Validate image URL format (if provided)
            if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                String urlLower = imageUrl.trim().toLowerCase();
                if (!urlLower.startsWith("http://") && !urlLower.startsWith("https://")) {
                    request.setAttribute("errorMessage", "URL hình ảnh phải bắt đầu với http:// hoặc https://");
                    handleEditForm(request, response);
                    return;
                }
            }

            // Verify item exists before updating
            MenuItem existingItem = menuDAO.getMenuItemById(itemId);
            if (existingItem == null) {
                request.setAttribute("errorMessage", "Món ăn không tồn tại.");
                handleListItems(request, response);
                return;
            }

            // Create menu item
            MenuItem item = new MenuItem();
            item.setItemId(itemId);
            item.setName(name.trim());
            item.setDescription(description != null ? description.trim() : "");
            item.setBasePrice(basePrice);
            item.setCategoryId(categoryId);
            item.setAvailability(availability != null ? availability : "AVAILABLE");
            item.setPreparationTime(preparationTime);
            item.setActive(true); // Keep items active
            item.setImageUrl(imageUrl);
            item.setUpdatedBy(currentUser.getUserId());

            // Update in database
            boolean success = menuDAO.updateMenuItem(item);

            if (success) {
                request.getSession().setAttribute("successMessage", "Cập nhật món ăn thành công!");
                response.sendRedirect(request.getContextPath() + "/menu-management");
            } else {
                request.setAttribute("errorMessage", "Không thể cập nhật món ăn. Vui lòng thử lại.");
                handleEditForm(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            handleEditForm(request, response);
        }
    }

    /**
     * Handle delete item
     */
    private void handleDeleteItem(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("user");
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

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/menu-management");
        }
    }
}
