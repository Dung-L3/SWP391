package Controller;

import Dal.StockTransactionDAO;
import Dal.InventoryDAO;
import Models.StockTransaction;
import Models.InventoryItem;
import Models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * StockTransactionServlet - Quản lý giao dịch nhập/xuất/điều chỉnh kho
 */
public class StockTransactionServlet extends HttpServlet {

    private StockTransactionDAO stockTransactionDAO;
    private InventoryDAO inventoryDAO;

    @Override
    public void init() throws ServletException {
        stockTransactionDAO = new StockTransactionDAO();
        inventoryDAO = new InventoryDAO();
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
                case "create":
                    handleCreateForm(request, response, currentUser);
                    break;
                case "create-batch":
                    handleCreateBatchForm(request, response, currentUser);
                    break;
                case "list":
                default:
                    handleListTransactions(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            handleListTransactions(request, response);
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
            response.sendRedirect(request.getContextPath() + "/stock-transactions");
            return;
        }

        try {
            switch (action) {
                case "create":
                    handleCreateTransaction(request, response, currentUser);
                    break;
                case "create-batch":
                    handleCreateBatchTransactions(request, response, currentUser);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/stock-transactions");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            handleCreateForm(request, response, currentUser);
        }
    }

    private boolean hasPermission(User user) {
        if (user == null) return false;
        return "Manager".equalsIgnoreCase(user.getRoleName());
    }

    private void handleListTransactions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pageParam = request.getParameter("page");
        String itemIdParam = request.getParameter("itemId");
        String txnTypeParam = request.getParameter("txnType");
        String fromDateParam = request.getParameter("fromDate");
        String toDateParam = request.getParameter("toDate");

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

        Integer itemId = null;
        if (itemIdParam != null && !itemIdParam.isEmpty()) {
            try {
                itemId = Integer.parseInt(itemIdParam);
            } catch (NumberFormatException ignore) {}
        }

        String txnType = (txnTypeParam != null && !txnTypeParam.isEmpty()) ? txnTypeParam : null;

        LocalDateTime fromDate = null;
        if (fromDateParam != null && !fromDateParam.isEmpty()) {
            try {
                fromDate = LocalDateTime.parse(fromDateParam + "T00:00:00");
            } catch (Exception ignore) {}
        }

        LocalDateTime toDate = null;
        if (toDateParam != null && !toDateParam.isEmpty()) {
            try {
                toDate = LocalDateTime.parse(toDateParam + "T23:59:59");
            } catch (Exception ignore) {}
        }

        List<StockTransaction> transactions = stockTransactionDAO.getTransactions(
            page, pageSize, itemId, txnType, fromDate, toDate
        );

        // Get all inventory items for filter dropdown
        List<InventoryItem> allItems = inventoryDAO.getInventoryItems(1, 1000, null, null, "ACTIVE");

        request.setAttribute("transactions", transactions);
        request.setAttribute("inventoryItems", allItems);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("itemIdParam", itemIdParam);
        request.setAttribute("txnTypeParam", txnTypeParam);
        request.setAttribute("fromDateParam", fromDateParam);
        request.setAttribute("toDateParam", toDateParam);
        request.setAttribute("page", "stock-transactions");

        request.getRequestDispatcher("/views/StockTransactionManagement.jsp").forward(request, response);
    }

    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền thực hiện giao dịch kho.");
            handleListTransactions(request, response);
            return;
        }

        String txnTypeParam = request.getParameter("type");
        String itemIdParam = request.getParameter("itemId");

        // Get all active inventory items
        List<InventoryItem> items = inventoryDAO.getInventoryItems(1, 1000, null, null, "ACTIVE");

        request.setAttribute("inventoryItems", items);
        request.setAttribute("txnType", txnTypeParam != null ? txnTypeParam : StockTransaction.TYPE_IN);
        request.setAttribute("selectedItemId", itemIdParam);
        request.setAttribute("page", "stock-transactions");

        request.getRequestDispatcher("/views/StockTransactionForm.jsp").forward(request, response);
    }

    private void handleCreateTransaction(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền thực hiện giao dịch kho.");
            handleListTransactions(request, response);
            return;
        }

        String itemIdParam = request.getParameter("itemId");
        String txnType = request.getParameter("txnType");
        String quantityParam = request.getParameter("quantity");
        String unitCostParam = request.getParameter("unitCost");
        String note = request.getParameter("note");

        // Validation
        if (itemIdParam == null || itemIdParam.isEmpty() ||
            txnType == null || txnType.isEmpty() ||
            quantityParam == null || quantityParam.isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
            handleCreateForm(request, response, currentUser);
            return;
        }

        try {
            int itemId = Integer.parseInt(itemIdParam);
            BigDecimal quantity = new BigDecimal(quantityParam);
            BigDecimal unitCost = (unitCostParam != null && !unitCostParam.isEmpty()) 
                ? new BigDecimal(unitCostParam) : BigDecimal.ZERO;

            // Validate quantity based on transaction type
            if (StockTransaction.TYPE_ADJUSTMENT.equals(txnType)) {
                // ADJUSTMENT: quantity can be positive (increase) or negative (decrease)
                // No validation needed for sign, but check if decrease would make stock negative
                InventoryItem item = inventoryDAO.getInventoryItemById(itemId);
                if (item != null && quantity.compareTo(BigDecimal.ZERO) < 0) {
                    // Decreasing stock - check if we have enough
                    BigDecimal newStock = item.getCurrentStock().add(quantity);
                    if (newStock.compareTo(BigDecimal.ZERO) < 0) {
                        request.setAttribute("errorMessage", 
                            "Không thể giảm kho. Tồn kho hiện tại: " + item.getCurrentStock() + " " + item.getUom());
                        handleCreateForm(request, response, currentUser);
                        return;
                    }
                }
            } else {
                // For other types, quantity must be positive
                if (quantity.compareTo(BigDecimal.ZERO) <= 0) {
                    request.setAttribute("errorMessage", "Số lượng phải lớn hơn 0.");
                    handleCreateForm(request, response, currentUser);
                    return;
                }

                // For OUT/USAGE/WASTE, validate stock availability
                if (StockTransaction.TYPE_OUT.equals(txnType) || 
                    StockTransaction.TYPE_USAGE.equals(txnType) ||
                    StockTransaction.TYPE_WASTE.equals(txnType)) {
                    
                    InventoryItem item = inventoryDAO.getInventoryItemById(itemId);
                    if (item == null || item.getCurrentStock().compareTo(quantity) < 0) {
                        request.setAttribute("errorMessage", "Số lượng tồn kho không đủ.");
                        handleCreateForm(request, response, currentUser);
                        return;
                    }
                }
            }

            StockTransaction txn = new StockTransaction();
            txn.setItemId(itemId);
            txn.setTxnType(txnType);
            txn.setQuantity(quantity);
            txn.setUnitCost(unitCost);
            txn.setTxnTime(LocalDateTime.now());
            txn.setRefType("MANUAL");
            txn.setRefId(null);
            txn.setNote(note != null ? note.trim() : null);

            boolean success = stockTransactionDAO.createTransaction(txn);

            if (success) {
                request.getSession().setAttribute("successMessage", 
                    "Thực hiện giao dịch kho thành công!");
                response.sendRedirect(request.getContextPath() + "/stock-transactions");
            } else {
                request.setAttribute("errorMessage", "Không thể thực hiện giao dịch kho.");
                handleCreateForm(request, response, currentUser);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ: " + e.getMessage());
            handleCreateForm(request, response, currentUser);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
            handleCreateForm(request, response, currentUser);
        }
    }

    private void handleCreateBatchForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền thực hiện giao dịch kho.");
            handleListTransactions(request, response);
            return;
        }

        String txnTypeParam = request.getParameter("type");

        // Get all active inventory items
        List<InventoryItem> items = inventoryDAO.getInventoryItems(1, 1000, null, null, "ACTIVE");

        request.setAttribute("inventoryItems", items);
        request.setAttribute("txnType", txnTypeParam != null ? txnTypeParam : StockTransaction.TYPE_IN);
        request.setAttribute("page", "stock-transactions");

        request.getRequestDispatcher("/views/StockTransactionBatchForm.jsp").forward(request, response);
    }

    private void handleCreateBatchTransactions(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!hasPermission(currentUser)) {
            request.setAttribute("errorMessage", "Bạn không có quyền thực hiện giao dịch kho.");
            handleListTransactions(request, response);
            return;
        }

        String txnType = request.getParameter("txnType");
        String note = request.getParameter("note");

        if (txnType == null || txnType.isEmpty()) {
            request.setAttribute("errorMessage", "Loại giao dịch không hợp lệ.");
            handleCreateBatchForm(request, response, currentUser);
            return;
        }

        int successCount = 0;
        int failCount = 0;
        StringBuilder errorMessages = new StringBuilder();

        // Get all item IDs from request
        String[] itemIds = request.getParameterValues("itemId");
        String[] quantities = request.getParameterValues("quantity");
        String[] unitCosts = request.getParameterValues("unitCost");

        if (itemIds == null || itemIds.length == 0) {
            request.setAttribute("errorMessage", "Vui lòng chọn ít nhất một nguyên liệu.");
            handleCreateBatchForm(request, response, currentUser);
            return;
        }

        for (int i = 0; i < itemIds.length; i++) {
            if (itemIds[i] == null || itemIds[i].isEmpty() ||
                quantities[i] == null || quantities[i].isEmpty()) {
                continue; // Skip empty rows
            }

            try {
                int itemId = Integer.parseInt(itemIds[i]);
                BigDecimal quantity = new BigDecimal(quantities[i]);
                BigDecimal unitCost = (unitCosts != null && i < unitCosts.length && 
                                     unitCosts[i] != null && !unitCosts[i].isEmpty()) 
                    ? new BigDecimal(unitCosts[i]) : BigDecimal.ZERO;

                // Validate quantity
                if (quantity.compareTo(BigDecimal.ZERO) <= 0) {
                    failCount++;
                    continue;
                }

                StockTransaction txn = new StockTransaction();
                txn.setItemId(itemId);
                txn.setTxnType(txnType);
                txn.setQuantity(quantity);
                txn.setUnitCost(unitCost);
                txn.setTxnTime(LocalDateTime.now());
                txn.setRefType("MANUAL");
                txn.setRefId(null);
                txn.setNote(note != null ? note.trim() : null);

                if (stockTransactionDAO.createTransaction(txn)) {
                    successCount++;
                } else {
                    failCount++;
                }

            } catch (Exception e) {
                failCount++;
                errorMessages.append("Lỗi dòng ").append(i + 1).append(": ").append(e.getMessage()).append("; ");
            }
        }

        if (successCount > 0) {
            String message = "Đã nhập thành công " + successCount + " nguyên liệu";
            if (failCount > 0) {
                message += " (" + failCount + " nguyên liệu thất bại)";
            }
            request.getSession().setAttribute("successMessage", message);
        } else {
            request.setAttribute("errorMessage", 
                "Không thể nhập kho. " + (errorMessages.length() > 0 ? errorMessages.toString() : ""));
        }

        response.sendRedirect(request.getContextPath() + "/stock-transactions");
    }
}

