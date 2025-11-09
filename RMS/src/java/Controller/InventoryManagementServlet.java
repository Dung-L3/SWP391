package Controller;

import Dal.InventoryDAO;
import Dal.SupplierDAO;
import Models.InventoryItem;
import Models.Supplier;
import Models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * InventoryManagementServlet - Quản lý nguyên liệu/kho
 */
public class InventoryManagementServlet extends HttpServlet {

    private InventoryDAO inventoryDAO;
    private SupplierDAO supplierDAO;

    @Override
    public void init() throws ServletException {
        inventoryDAO = new InventoryDAO();
        supplierDAO = new SupplierDAO();
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
            request.getRequestDispatcher("/views/InventoryManagement.jsp").forward(request, response);
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
            response.sendRedirect(request.getContextPath() + "/inventory-management");
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
                    response.sendRedirect(request.getContextPath() + "/inventory-management");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            handleListItems(request, response);
        }
    }

    private boolean hasInventoryPermission(User user) {
        if (user == null) return false;
        return "Manager".equalsIgnoreCase(user.getRoleName());
    }

    private void handleListItems(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pageParam = request.getParameter("page");
        String search = request.getParameter("search");
        String category = request.getParameter("category");
        String status = request.getParameter("status");

        int page = 1;
        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException ignore) {
            page = 1;
        }

        int pageSize = 20;

        List<InventoryItem> items = inventoryDAO.getInventoryItems(page, pageSize, search, category, status);
        int totalItems = inventoryDAO.getTotalInventoryItemsCount(search, category, status);
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages == 0) totalPages = 1;

        List<String> categories = inventoryDAO.getAllCategories();
        List<InventoryItem> lowStockItems = inventoryDAO.getLowStockItems();

        request.setAttribute("inventoryItems", items);
        request.setAttribute("categories", categories);
        request.setAttribute("lowStockItems", lowStockItems);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("searchParam", search);
        request.setAttribute("categoryParam", category);
        request.setAttribute("statusParam", status);
        request.setAttribute("page", "inventory");

        request.getRequestDispatcher("/views/InventoryManagement.jsp").forward(request, response);
    }

    private void handleViewItem(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String itemIdParam = request.getParameter("id");
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/inventory-management");
            return;
        }

        try {
            int itemId = Integer.parseInt(itemIdParam);
            InventoryItem item = inventoryDAO.getInventoryItemById(itemId);

            if (item == null) {
                request.setAttribute("errorMessage", "Không tìm thấy nguyên liệu.");
                handleListItems(request, response);
                return;
            }

            List<Supplier> suppliers = supplierDAO.getAllActiveSuppliers();

            request.setAttribute("inventoryItem", item);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("page", "inventory");
            request.setAttribute("viewMode", "view");

            request.getRequestDispatcher("/views/InventoryItemForm.jsp").forward(request, response);

        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/inventory-management");
        }
    }

    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasInventoryPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền thêm nguyên liệu.");
            handleListItems(request, response);
            return;
        }

        List<Supplier> suppliers = supplierDAO.getAllActiveSuppliers();

        request.setAttribute("suppliers", suppliers);
        request.setAttribute("page", "inventory");
        request.setAttribute("viewMode", "create");

        request.getRequestDispatcher("/views/InventoryItemForm.jsp").forward(request, response);
    }

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasInventoryPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền chỉnh sửa nguyên liệu.");
            handleListItems(request, response);
            return;
        }

        String itemIdParam = request.getParameter("id");
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/inventory-management");
            return;
        }

        try {
            int itemId = Integer.parseInt(itemIdParam);
            InventoryItem item = inventoryDAO.getInventoryItemById(itemId);

            if (item == null) {
                request.setAttribute("errorMessage", "Không tìm thấy nguyên liệu.");
                handleListItems(request, response);
                return;
            }

            List<Supplier> suppliers = supplierDAO.getAllActiveSuppliers();

            request.setAttribute("inventoryItem", item);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("page", "inventory");
            request.setAttribute("viewMode", "edit");

            request.getRequestDispatcher("/views/InventoryItemForm.jsp").forward(request, response);

        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/inventory-management");
        }
    }

    private void handleCreateItem(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasInventoryPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền thêm nguyên liệu.");
            handleListItems(request, response);
            return;
        }

        String itemName = request.getParameter("itemName");
        String category = request.getParameter("category");
        String uom = request.getParameter("uom");
        String currentStockParam = request.getParameter("currentStock");
        String minimumStockParam = request.getParameter("minimumStock");
        String unitCostParam = request.getParameter("unitCost");
        String supplierIdParam = request.getParameter("supplierId");
        String expiryDateParam = request.getParameter("expiryDate");
        String status = request.getParameter("status");

        if (itemName == null || itemName.trim().isEmpty() ||
            uom == null || uom.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
            handleCreateForm(request, response, currentUser);
            return;
        }

        try {
            BigDecimal currentStock = new BigDecimal(currentStockParam != null ? currentStockParam : "0");
            BigDecimal minimumStock = new BigDecimal(minimumStockParam != null ? minimumStockParam : "0");
            BigDecimal unitCost = new BigDecimal(unitCostParam != null ? unitCostParam : "0");

            Integer supplierId = null;
            if (supplierIdParam != null && !supplierIdParam.isEmpty()) {
                supplierId = Integer.parseInt(supplierIdParam);
            }

            LocalDate expiryDate = null;
            if (expiryDateParam != null && !expiryDateParam.isEmpty()) {
                expiryDate = LocalDate.parse(expiryDateParam);
            }

            InventoryItem item = new InventoryItem();
            item.setItemName(itemName.trim());
            item.setCategory(category);
            item.setUom(uom.trim());
            item.setCurrentStock(currentStock);
            item.setMinimumStock(minimumStock);
            item.setUnitCost(unitCost);
            item.setSupplierId(supplierId);
            item.setExpiryDate(expiryDate);
            item.setStatus(status != null ? status : InventoryItem.STATUS_ACTIVE);
            item.setCreatedBy(currentUser.getUserId());

            boolean success = inventoryDAO.createInventoryItem(item);

            if (success) {
                request.getSession().setAttribute("successMessage", "Thêm nguyên liệu thành công!");
                response.sendRedirect(request.getContextPath() + "/inventory-management");
            } else {
                request.setAttribute("errorMessage", "Không thể thêm nguyên liệu.");
                handleCreateForm(request, response, currentUser);
            }

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ: " + e.getMessage());
            handleCreateForm(request, response, currentUser);
        }
    }

    private void handleUpdateItem(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasInventoryPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền chỉnh sửa nguyên liệu.");
            handleListItems(request, response);
            return;
        }

        String itemIdParam = request.getParameter("itemId");
        String itemName = request.getParameter("itemName");
        String category = request.getParameter("category");
        String uom = request.getParameter("uom");
        String currentStockParam = request.getParameter("currentStock");
        String minimumStockParam = request.getParameter("minimumStock");
        String unitCostParam = request.getParameter("unitCost");
        String supplierIdParam = request.getParameter("supplierId");
        String expiryDateParam = request.getParameter("expiryDate");
        String status = request.getParameter("status");

        if (itemIdParam == null || itemName == null || itemName.trim().isEmpty() ||
            uom == null || uom.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
            handleEditForm(request, response, currentUser);
            return;
        }

        try {
            int itemId = Integer.parseInt(itemIdParam);
            BigDecimal currentStock = new BigDecimal(currentStockParam != null ? currentStockParam : "0");
            BigDecimal minimumStock = new BigDecimal(minimumStockParam != null ? minimumStockParam : "0");
            BigDecimal unitCost = new BigDecimal(unitCostParam != null ? unitCostParam : "0");

            Integer supplierId = null;
            if (supplierIdParam != null && !supplierIdParam.isEmpty()) {
                supplierId = Integer.parseInt(supplierIdParam);
            }

            LocalDate expiryDate = null;
            if (expiryDateParam != null && !expiryDateParam.isEmpty()) {
                expiryDate = LocalDate.parse(expiryDateParam);
            }

            InventoryItem item = new InventoryItem();
            item.setItemId(itemId);
            item.setItemName(itemName.trim());
            item.setCategory(category);
            item.setUom(uom.trim());
            item.setCurrentStock(currentStock);
            item.setMinimumStock(minimumStock);
            item.setUnitCost(unitCost);
            item.setSupplierId(supplierId);
            item.setExpiryDate(expiryDate);
            item.setStatus(status != null ? status : InventoryItem.STATUS_ACTIVE);

            boolean success = inventoryDAO.updateInventoryItem(item);

            if (success) {
                request.getSession().setAttribute("successMessage", "Cập nhật nguyên liệu thành công!");
                response.sendRedirect(request.getContextPath() + "/inventory-management");
            } else {
                request.setAttribute("errorMessage", "Không thể cập nhật nguyên liệu.");
                handleEditForm(request, response, currentUser);
            }

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ: " + e.getMessage());
            handleEditForm(request, response, currentUser);
        }
    }

    private void handleDeleteItem(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasInventoryPermission(currentUser)) {
            request.getSession().setAttribute("errorMessage", "Bạn không có quyền xóa nguyên liệu.");
            response.sendRedirect(request.getContextPath() + "/inventory-management");
            return;
        }

        String itemIdParam = request.getParameter("itemId");
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/inventory-management");
            return;
        }

        try {
            int itemId = Integer.parseInt(itemIdParam);
            boolean success = inventoryDAO.deleteInventoryItem(itemId);

            if (success) {
                request.getSession().setAttribute("successMessage", "Xóa nguyên liệu thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể xóa nguyên liệu.");
            }

            response.sendRedirect(request.getContextPath() + "/inventory-management");

        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/inventory-management");
        }
    }
}

