package Controller;

import Dal.VoucherDAO;
import Models.Voucher;
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
 * VoucherManagementServlet - Handle voucher CRUD operations (Admin only)
 */
public class VoucherManagementServlet extends HttpServlet {

    private VoucherDAO voucherDAO;

    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
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

        // Check authorization - Only Manager can manage vouchers
        User currentUser = (User) session.getAttribute("user");
        if (!"Manager".equals(currentUser.getRoleName())) {
            request.setAttribute("errorMessage", "Bạn không có quyền quản lý voucher.");
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "list":
                    handleListVouchers(request, response);
                    break;
                case "view":
                    handleViewVoucher(request, response);
                    break;
                case "create":
                    handleCreateForm(request, response);
                    break;
                case "edit":
                    handleEditForm(request, response);
                    break;
                default:
                    handleListVouchers(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/VoucherManagement.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication and authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (!"Manager".equals(currentUser.getRoleName())) {
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        }

        // Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/voucher-management");
            return;
        }

        try {
            switch (action) {
                case "create":
                    handleCreateVoucher(request, response);
                    break;
                case "update":
                    handleUpdateVoucher(request, response);
                    break;
                case "delete":
                    handleDeleteVoucher(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/voucher-management");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            handleListVouchers(request, response);
        }
    }

    /**
     * Handle list vouchers with pagination, search, and filters
     */
    private void handleListVouchers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get parameters
        String pageParam = request.getParameter("page");
        String search = request.getParameter("search");
        String status = request.getParameter("status");
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

        int pageSize = 10;

        // Get data
        List<Voucher> vouchers = voucherDAO.getVouchers(page, pageSize, search, status, sortBy);
        int totalVouchers = voucherDAO.getTotalVouchersCount(search, status);

        // Calculate pagination
        int totalPages = (int) Math.ceil((double) totalVouchers / pageSize);
        if (totalPages == 0) totalPages = 1;

        // Set attributes
        request.setAttribute("vouchers", vouchers);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalVouchers", totalVouchers);
        request.setAttribute("pageSize", pageSize);

        // Preserve filter parameters
        request.setAttribute("searchParam", search);
        request.setAttribute("statusParam", status);
        request.setAttribute("sortByParam", sortBy);

        // Set page context
        request.setAttribute("page", "voucher");

        // Forward to JSP
        request.getRequestDispatcher("/views/VoucherManagement.jsp").forward(request, response);
    }

    /**
     * Handle view single voucher
     */
    private void handleViewVoucher(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String voucherIdParam = request.getParameter("id");
        if (voucherIdParam == null || voucherIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/voucher-management");
            return;
        }

        try {
            int voucherId = Integer.parseInt(voucherIdParam);
            Voucher voucher = voucherDAO.getVoucherById(voucherId);

            if (voucher == null) {
                request.setAttribute("errorMessage", "Không tìm thấy voucher.");
                handleListVouchers(request, response);
                return;
            }

            request.setAttribute("voucher", voucher);
            request.setAttribute("page", "voucher");
            request.setAttribute("viewMode", "view");

            request.getRequestDispatcher("/views/VoucherForm.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/voucher-management");
        }
    }

    /**
     * Handle create form
     */
    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("page", "voucher");
        request.setAttribute("viewMode", "create");
        request.getRequestDispatcher("/views/VoucherForm.jsp").forward(request, response);
    }

    /**
     * Handle edit form
     */
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String voucherIdParam = request.getParameter("id");
        if (voucherIdParam == null || voucherIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/voucher-management");
            return;
        }

        try {
            int voucherId = Integer.parseInt(voucherIdParam);
            Voucher voucher = voucherDAO.getVoucherById(voucherId);

            if (voucher == null) {
                request.setAttribute("errorMessage", "Không tìm thấy voucher.");
                handleListVouchers(request, response);
                return;
            }

            request.setAttribute("voucher", voucher);
            request.setAttribute("page", "voucher");
            request.setAttribute("viewMode", "edit");

            request.getRequestDispatcher("/views/VoucherForm.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/voucher-management");
        }
    }

    /**
     * Handle create voucher
     */
    private void handleCreateVoucher(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get form data
        String code = request.getParameter("code");
        String description = request.getParameter("description");
        String discountType = request.getParameter("discountType");
        String discountValueParam = request.getParameter("discountValue");
        String validFromParam = request.getParameter("validFrom");
        String validToParam = request.getParameter("validTo");
        String usageLimitParam = request.getParameter("usageLimit");
        String minOrderTotalParam = request.getParameter("minOrderTotal");
        String status = request.getParameter("status");

        User currentUser = (User) request.getSession().getAttribute("user");

        // Validate required fields
        if (code == null || code.trim().isEmpty() ||
            discountType == null || discountType.trim().isEmpty() ||
            discountValueParam == null || discountValueParam.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
            handleCreateForm(request, response);
            return;
        }

        // Validate code format (uppercase, no spaces, 3-20 chars)
        String trimmedCode = code.trim().toUpperCase();
        if (trimmedCode.length() < 3 || trimmedCode.length() > 20) {
            request.setAttribute("errorMessage", "Mã voucher phải từ 3-20 ký tự.");
            handleCreateForm(request, response);
            return;
        }

        if (!trimmedCode.matches("^[A-Z0-9]+$")) {
            request.setAttribute("errorMessage", "Mã voucher chỉ được chứa chữ cái và số, không dấu, không khoảng trắng.");
            handleCreateForm(request, response);
            return;
        }

        // Check if code already exists
        if (voucherDAO.isCodeExists(trimmedCode, null)) {
            request.setAttribute("errorMessage", "Mã voucher đã tồn tại. Vui lòng chọn mã khác.");
            handleCreateForm(request, response);
            return;
        }

        try {
            // Parse data
            BigDecimal discountValue = new BigDecimal(discountValueParam);
            LocalDate validFrom = validFromParam != null && !validFromParam.isEmpty() ? 
                                 LocalDate.parse(validFromParam) : null;
            LocalDate validTo = validToParam != null && !validToParam.isEmpty() ? 
                               LocalDate.parse(validToParam) : null;
            Integer usageLimit = usageLimitParam != null && !usageLimitParam.isEmpty() ? 
                                Integer.parseInt(usageLimitParam) : null;
            BigDecimal minOrderTotal = minOrderTotalParam != null && !minOrderTotalParam.isEmpty() ? 
                                      new BigDecimal(minOrderTotalParam) : BigDecimal.ZERO;

            // Validate discount value
            if (discountValue.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("errorMessage", "Giá trị giảm phải lớn hơn 0.");
                handleCreateForm(request, response);
                return;
            }

            if ("PERCENT".equals(discountType)) {
                if (discountValue.compareTo(new BigDecimal("100")) > 0) {
                    request.setAttribute("errorMessage", "Phần trăm giảm không được vượt quá 100%.");
                    handleCreateForm(request, response);
                    return;
                }
            }

            // Validate dates
            if (validFrom != null && validTo != null && validFrom.isAfter(validTo)) {
                request.setAttribute("errorMessage", "Ngày bắt đầu phải trước ngày kết thúc.");
                handleCreateForm(request, response);
                return;
            }

            // Validate usage limit
            if (usageLimit != null && usageLimit <= 0) {
                request.setAttribute("errorMessage", "Giới hạn sử dụng phải lớn hơn 0.");
                handleCreateForm(request, response);
                return;
            }

            // Create voucher
            Voucher voucher = new Voucher();
            voucher.setCode(trimmedCode);
            voucher.setDescription(description != null ? description.trim() : "");
            voucher.setDiscountType(discountType);
            voucher.setDiscountValue(discountValue);
            voucher.setValidFrom(validFrom);
            voucher.setValidTo(validTo);
            voucher.setUsageLimit(usageLimit);
            voucher.setMinOrderTotal(minOrderTotal);
            voucher.setStatus(status != null ? status : "ACTIVE");
            voucher.setCreatedBy(currentUser.getUserId());

            // Save to database
            boolean success = voucherDAO.createVoucher(voucher);

            if (success) {
                request.getSession().setAttribute("successMessage", "Tạo voucher thành công!");
                response.sendRedirect(request.getContextPath() + "/voucher-management");
            } else {
                request.setAttribute("errorMessage", "Không thể tạo voucher. Vui lòng thử lại.");
                handleCreateForm(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            handleCreateForm(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            handleCreateForm(request, response);
        }
    }

    /**
     * Handle update voucher
     */
    private void handleUpdateVoucher(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String voucherIdParam = request.getParameter("voucherId");
        if (voucherIdParam == null || voucherIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/voucher-management");
            return;
        }

        // Get form data
        String code = request.getParameter("code");
        String description = request.getParameter("description");
        String discountType = request.getParameter("discountType");
        String discountValueParam = request.getParameter("discountValue");
        String validFromParam = request.getParameter("validFrom");
        String validToParam = request.getParameter("validTo");
        String usageLimitParam = request.getParameter("usageLimit");
        String minOrderTotalParam = request.getParameter("minOrderTotal");
        String status = request.getParameter("status");

        // Validate required fields
        if (code == null || code.trim().isEmpty() ||
            discountType == null || discountType.trim().isEmpty() ||
            discountValueParam == null || discountValueParam.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
            handleEditForm(request, response);
            return;
        }

        String trimmedCode = code.trim().toUpperCase();
        int voucherId = Integer.parseInt(voucherIdParam);

        // Check if code already exists (exclude current voucher)
        if (voucherDAO.isCodeExists(trimmedCode, voucherId)) {
            request.setAttribute("errorMessage", "Mã voucher đã tồn tại. Vui lòng chọn mã khác.");
            handleEditForm(request, response);
            return;
        }

        try {
            // Parse data
            BigDecimal discountValue = new BigDecimal(discountValueParam);
            LocalDate validFrom = validFromParam != null && !validFromParam.isEmpty() ? 
                                 LocalDate.parse(validFromParam) : null;
            LocalDate validTo = validToParam != null && !validToParam.isEmpty() ? 
                               LocalDate.parse(validToParam) : null;
            Integer usageLimit = usageLimitParam != null && !usageLimitParam.isEmpty() ? 
                                Integer.parseInt(usageLimitParam) : null;
            BigDecimal minOrderTotal = minOrderTotalParam != null && !minOrderTotalParam.isEmpty() ? 
                                      new BigDecimal(minOrderTotalParam) : BigDecimal.ZERO;

            // Validate (same as create)
            if (discountValue.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("errorMessage", "Giá trị giảm phải lớn hơn 0.");
                handleEditForm(request, response);
                return;
            }

            if ("PERCENT".equals(discountType) && discountValue.compareTo(new BigDecimal("100")) > 0) {
                request.setAttribute("errorMessage", "Phần trăm giảm không được vượt quá 100%.");
                handleEditForm(request, response);
                return;
            }

            if (validFrom != null && validTo != null && validFrom.isAfter(validTo)) {
                request.setAttribute("errorMessage", "Ngày bắt đầu phải trước ngày kết thúc.");
                handleEditForm(request, response);
                return;
            }

            // Update voucher
            Voucher voucher = new Voucher();
            voucher.setVoucherId(voucherId);
            voucher.setCode(trimmedCode);
            voucher.setDescription(description != null ? description.trim() : "");
            voucher.setDiscountType(discountType);
            voucher.setDiscountValue(discountValue);
            voucher.setValidFrom(validFrom);
            voucher.setValidTo(validTo);
            voucher.setUsageLimit(usageLimit);
            voucher.setMinOrderTotal(minOrderTotal);
            voucher.setStatus(status != null ? status : "ACTIVE");

            // Save to database
            boolean success = voucherDAO.updateVoucher(voucher);

            if (success) {
                request.getSession().setAttribute("successMessage", "Cập nhật voucher thành công!");
                response.sendRedirect(request.getContextPath() + "/voucher-management");
            } else {
                request.setAttribute("errorMessage", "Không thể cập nhật voucher. Vui lòng thử lại.");
                handleEditForm(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            handleEditForm(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            handleEditForm(request, response);
        }
    }

    /**
     * Handle delete voucher (set status = INACTIVE)
     */
    private void handleDeleteVoucher(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String voucherIdParam = request.getParameter("voucherId");
        if (voucherIdParam == null || voucherIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/voucher-management");
            return;
        }

        try {
            int voucherId = Integer.parseInt(voucherIdParam);
            boolean success = voucherDAO.deleteVoucher(voucherId);

            if (success) {
                request.getSession().setAttribute("successMessage", "Vô hiệu hóa voucher thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể vô hiệu hóa voucher. Vui lòng thử lại.");
            }

            response.sendRedirect(request.getContextPath() + "/voucher-management");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/voucher-management");
        }
    }
}

