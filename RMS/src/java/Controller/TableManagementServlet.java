package Controller;

import Dal.TableDAO;
import Models.DiningTable;
import Models.User;
import Utils.RoleBasedRedirect;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Servlet quản lý bàn (CRUD)
 */
public class TableManagementServlet extends HttpServlet {

    private TableDAO tableDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        tableDAO = new TableDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập (chỉ ADMIN/Manager)
        if (!RoleBasedRedirect.hasAnyPermission(user, "ADMIN", "Manager")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                showTableList(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            default:
                showTableList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập (chỉ ADMIN/Manager)
        if (!RoleBasedRedirect.hasAnyPermission(user, "ADMIN", "Manager")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        switch (action) {
            case "create":
                handleCreate(request, response, user);
                break;
            case "update":
                handleUpdate(request, response, user);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            default:
                showTableList(request, response);
                break;
        }
    }

    private void showTableList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Lấy filter parameters
            String tableNumberFilter = request.getParameter("q");
            String areaIdParam = request.getParameter("areaId");
            Integer areaIdFilter = null;
            
            if (areaIdParam != null && !areaIdParam.trim().isEmpty()) {
                try {
                    areaIdFilter = Integer.parseInt(areaIdParam);
                } catch (NumberFormatException e) {
                    // Ignore invalid areaId
                }
            }
            
            // Lấy danh sách bàn với filter
            List<DiningTable> tables = tableDAO.getAllTablesWithArea(tableNumberFilter, areaIdFilter);
            List<Models.TableArea> areas = tableDAO.getAllAreas();
            
            // Set attributes
            request.setAttribute("tables", tables);
            request.setAttribute("areas", areas);
            request.setAttribute("q", tableNumberFilter); // Giữ lại giá trị filter
            request.setAttribute("areaId", areaIdFilter); // Giữ lại giá trị filter
            
            request.getRequestDispatcher("/views/TableManagement.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi khi tải danh sách bàn: " + e.getMessage());
            request.getRequestDispatcher("/views/TableManagement.jsp").forward(request, response);
        }
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            List<Models.TableArea> areas = tableDAO.getAllAreas();
            request.setAttribute("areas", areas);
            request.setAttribute("action", "add");
            request.getRequestDispatcher("/views/TableManagement.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            String message = URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Lỗi hệ thống", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/table-management?error=" + message);
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String tableIdParam = request.getParameter("id");
        if (tableIdParam == null || tableIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/table-management?error=Invalid+table+ID");
            return;
        }
        
        try {
            int tableId = Integer.parseInt(tableIdParam);
            DiningTable table = tableDAO.getDiningTableById(tableId);
            
            if (table == null) {
                response.sendRedirect(request.getContextPath() + "/table-management?error=Table+not+found");
                return;
            }
            
            List<Models.TableArea> areas = tableDAO.getAllAreas();
            request.setAttribute("table", table);
            request.setAttribute("areas", areas);
            request.setAttribute("action", "edit");
            request.getRequestDispatcher("/views/TableManagement.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/table-management?error=Invalid+table+ID");
        } catch (Exception e) {
            e.printStackTrace();
            String message = URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Lỗi hệ thống", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/table-management?error=" + message);
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        
        String tableNumber = request.getParameter("tableNumber");
        String capacityParam = request.getParameter("capacity");
        String areaIdParam = request.getParameter("areaId");
        String location = request.getParameter("location");
        String status = request.getParameter("status");
        String tableType = request.getParameter("tableType");
        
        // Validation
        if (tableNumber == null || tableNumber.trim().isEmpty() ||
            capacityParam == null || capacityParam.trim().isEmpty()) {
            String message = URLEncoder.encode("Vui lòng điền đầy đủ thông tin bắt buộc", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/table-management?action=add&error=" + message);
            return;
        }
        
        try {
            int capacity = Integer.parseInt(capacityParam);
            
            // Validate capacity: chỉ cho phép 2, 4, 6, 8, 10
            if (capacity != 2 && capacity != 4 && capacity != 6 && capacity != 8 && capacity != 10) {
                String message = URLEncoder.encode("Sức chứa chỉ được chọn: 2, 4, 6, 8 hoặc 10 người", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/table-management?action=add&error=" + message);
                return;
            }
            
            DiningTable table = new DiningTable();
            table.setTableNumber(tableNumber.trim());
            table.setCapacity(capacity);
            
            if (areaIdParam != null && !areaIdParam.trim().isEmpty()) {
                table.setAreaId(Integer.parseInt(areaIdParam));
            }
            
            if (location != null && !location.trim().isEmpty()) {
                table.setLocation(location.trim());
            }
            
            table.setStatus(status != null && !status.trim().isEmpty() ? status : DiningTable.STATUS_VACANT);
            table.setTableType(tableType != null && !tableType.trim().isEmpty() ? tableType : DiningTable.TYPE_REGULAR);
            
            table.setCreatedBy(user.getUserId());
            
            boolean success = tableDAO.createTable(table);
            
            if (success) {
                String message = URLEncoder.encode("Thêm bàn thành công", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/table-management?success=" + message);
            } else {
                String message = URLEncoder.encode("Không thể thêm bàn", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/table-management?action=add&error=" + message);
            }
            
        } catch (NumberFormatException e) {
            String message = URLEncoder.encode("Dữ liệu không hợp lệ", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/table-management?action=add&error=" + message);
        } catch (Exception e) {
            e.printStackTrace();
            String message = URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Lỗi hệ thống", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/table-management?action=add&error=" + message);
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        
        String tableIdParam = request.getParameter("tableId");
        String tableNumber = request.getParameter("tableNumber");
        String capacityParam = request.getParameter("capacity");
        String areaIdParam = request.getParameter("areaId");
        String location = request.getParameter("location");
        String status = request.getParameter("status");
        String tableType = request.getParameter("tableType");
        
        // Validation
        if (tableIdParam == null || tableIdParam.trim().isEmpty() ||
            tableNumber == null || tableNumber.trim().isEmpty() ||
            capacityParam == null || capacityParam.trim().isEmpty()) {
            String message = URLEncoder.encode("Vui lòng điền đầy đủ thông tin bắt buộc", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/table-management?error=" + message);
            return;
        }
        
        try {
            int capacity = Integer.parseInt(capacityParam);
            
            // Validate capacity: chỉ cho phép 2, 4, 6, 8, 10
            if (capacity != 2 && capacity != 4 && capacity != 6 && capacity != 8 && capacity != 10) {
                String message = URLEncoder.encode("Sức chứa chỉ được chọn: 2, 4, 6, 8 hoặc 10 người", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/table-management?action=edit&id=" + tableIdParam + "&error=" + message);
                return;
            }
            
            DiningTable table = new DiningTable();
            table.setTableId(Integer.parseInt(tableIdParam));
            table.setTableNumber(tableNumber.trim());
            table.setCapacity(capacity);
            
            if (areaIdParam != null && !areaIdParam.trim().isEmpty()) {
                table.setAreaId(Integer.parseInt(areaIdParam));
            }
            
            if (location != null && !location.trim().isEmpty()) {
                table.setLocation(location.trim());
            }
            
            table.setStatus(status != null && !status.trim().isEmpty() ? status : DiningTable.STATUS_VACANT);
            table.setTableType(tableType != null && !tableType.trim().isEmpty() ? tableType : DiningTable.TYPE_REGULAR);
            
            boolean success = tableDAO.updateTable(table);
            
            if (success) {
                String message = URLEncoder.encode("Cập nhật bàn thành công", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/table-management?success=" + message);
            } else {
                String message = URLEncoder.encode("Không thể cập nhật bàn", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/table-management?action=edit&id=" + tableIdParam + "&error=" + message);
            }
            
        } catch (NumberFormatException e) {
            String message = URLEncoder.encode("Dữ liệu không hợp lệ", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/table-management?error=" + message);
        } catch (Exception e) {
            e.printStackTrace();
            String message = URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Lỗi hệ thống", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/table-management?error=" + message);
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String tableIdParam = request.getParameter("id");
        
        if (tableIdParam == null || tableIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/table-management?error=Invalid+table+ID");
            return;
        }
        
        try {
            int tableId = Integer.parseInt(tableIdParam);
            boolean success = tableDAO.deleteTable(tableId);
            
            if (success) {
                String message = URLEncoder.encode("Xóa bàn thành công", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/table-management?success=" + message);
            } else {
                String message = URLEncoder.encode("Không thể xóa bàn", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/table-management?error=" + message);
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/table-management?error=Invalid+table+ID");
        } catch (Exception e) {
            e.printStackTrace();
            String message = URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Lỗi hệ thống", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/table-management?error=" + message);
        }
    }
}

