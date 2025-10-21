/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Controller;

import Dal.StaffDAO;
import Models.Staff;
import Models.Role;
import Models.User;
import Utils.PasswordUtil;
import Utils.RoleBasedRedirect;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author donny
 */
public class StaffManagementServlet extends HttpServlet {

    private StaffDAO staffDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        staffDAO = new StaffDAO();
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
        
        // Kiểm tra quyền truy cập (chỉ Manager)
        if (!RoleBasedRedirect.hasPermission(user, "Manager")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                showStaffList(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "view":
                showStaffDetails(request, response);
                break;
            default:
                showStaffList(request, response);
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
        
        // Kiểm tra quyền truy cập (chỉ Manager)
        if (!RoleBasedRedirect.hasPermission(user, "Manager")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        switch (action) {
            case "create":
                createStaff(request, response);
                break;
            case "update":
                updateStaff(request, response);
                break;
            case "deactivate":
                deactivateStaff(request, response);
                break;
            case "activate":
                activateStaff(request, response);
                break;
            default:
                showStaffList(request, response);
                break;
        }
    }
    
    private void showStaffList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String q = request.getParameter("q");
        String roleIdParam = request.getParameter("roleId");
        Integer roleIdFilter = null;
        try { if (roleIdParam != null && !roleIdParam.isEmpty()) roleIdFilter = Integer.parseInt(roleIdParam); } catch (Exception ignored) {}
        
        List<Staff> staffList;
        if ((q != null && !q.trim().isEmpty()) || roleIdFilter != null) {
            staffList = staffDAO.getStaffFiltered(q, roleIdFilter);
        } else {
            staffList = staffDAO.getAllStaff();
        }
        request.setAttribute("staffList", staffList);

        // Roles for filter
        List<Role> roles = staffDAO.getAllRoles();
        request.setAttribute("roles", roles);
        request.setAttribute("q", q);
        request.setAttribute("roleId", roleIdFilter);
        
        request.getRequestDispatcher("/views/StaffManagement.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Role> roles = staffDAO.getAllRoles();
        List<Staff> managers = staffDAO.getManagers();
        
        request.setAttribute("roles", roles);
        request.setAttribute("managers", managers);
        request.setAttribute("action", "add");
        
        request.getRequestDispatcher("/views/StaffForm.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int staffId = Integer.parseInt(request.getParameter("id"));
        Staff staff = staffDAO.getStaffById(staffId);
        
        if (staff == null) {
            response.sendRedirect("staff-management?error=Staff not found");
            return;
        }
        
        List<Role> roles = staffDAO.getAllRoles();
        List<Staff> managers = staffDAO.getManagers();
        
        request.setAttribute("staff", staff);
        request.setAttribute("roles", roles);
        request.setAttribute("managers", managers);
        request.setAttribute("action", "edit");
        
        request.getRequestDispatcher("/views/StaffForm.jsp").forward(request, response);
    }
    
    private void showStaffDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int staffId = Integer.parseInt(request.getParameter("id"));
        Staff staff = staffDAO.getStaffById(staffId);
        
        if (staff == null) {
            response.sendRedirect("staff-management?error=Staff not found");
            return;
        }
        
        request.setAttribute("staff", staff);
        request.getRequestDispatcher("/views/StaffDetails.jsp").forward(request, response);
    }
    
    private void createStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Lấy dữ liệu từ form
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String position = request.getParameter("position");
            String hireDateStr = request.getParameter("hireDate");
            String salaryStr = request.getParameter("salary");
            String managerIdStr = request.getParameter("managerId");
            String roleIdStr = request.getParameter("roleId");
            
            // Validation
            if (firstName == null || firstName.trim().isEmpty() ||
                lastName == null || lastName.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                position == null || position.trim().isEmpty()) {
                
                response.sendRedirect("staff-management?action=add&error=Required fields are missing");
                return;
            }
            
            // Tạo Staff object
            Staff staff = new Staff();
            staff.setFirstName(firstName.trim());
            staff.setLastName(lastName.trim());
            staff.setEmail(email.trim());
            staff.setPhone(phone != null ? phone.trim() : "");
            staff.setPosition(position.trim());
            staff.setHireDate(hireDateStr != null && !hireDateStr.isEmpty() ? Date.valueOf(hireDateStr) : new Date(System.currentTimeMillis()));
            staff.setSalary(salaryStr != null && !salaryStr.isEmpty() ? new BigDecimal(salaryStr) : BigDecimal.ZERO);
            staff.setManagerId(managerIdStr != null && !managerIdStr.isEmpty() ? Integer.parseInt(managerIdStr) : null);
            
            // Tạo password mặc định
            String password = PasswordUtil.generateDefaultPassword();
            
            // Tạo nhân viên
            int roleId = roleIdStr != null && !roleIdStr.isEmpty() ? Integer.parseInt(roleIdStr) : 1; // Default role
            boolean success = staffDAO.createStaff(staff, password, roleId);
            
            if (success) {
                response.sendRedirect("staff-management?success=Staff created successfully. Default password: " + password);
            } else {
                response.sendRedirect("staff-management?action=add&error=Failed to create staff");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staff-management?action=add&error=An error occurred: " + e.getMessage());
        }
    }
    
    private void updateStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            int userId = Integer.parseInt(request.getParameter("userId"));
            
            // Lấy dữ liệu từ form
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String position = request.getParameter("position");
            String salaryStr = request.getParameter("salary");
            String managerIdStr = request.getParameter("managerId");
            
            // Validation
            if (firstName == null || firstName.trim().isEmpty() ||
                lastName == null || lastName.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                position == null || position.trim().isEmpty()) {
                
                response.sendRedirect("staff-management?action=edit&id=" + staffId + "&error=Required fields are missing");
                return;
            }
            
            // Tạo Staff object
            Staff staff = new Staff();
            staff.setStaffId(staffId);
            staff.setUserId(userId);
            staff.setFirstName(firstName.trim());
            staff.setLastName(lastName.trim());
            staff.setEmail(email.trim());
            staff.setPhone(phone != null ? phone.trim() : "");
            staff.setPosition(position.trim());
            staff.setSalary(salaryStr != null && !salaryStr.isEmpty() ? new BigDecimal(salaryStr) : BigDecimal.ZERO);
            staff.setManagerId(managerIdStr != null && !managerIdStr.isEmpty() ? Integer.parseInt(managerIdStr) : null);
            
            // Cập nhật nhân viên
            boolean success = staffDAO.updateStaff(staff);
            
            if (success) {
                response.sendRedirect("staff-management?success=Staff updated successfully");
            } else {
                response.sendRedirect("staff-management?action=edit&id=" + staffId + "&error=Failed to update staff");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staff-management?error=An error occurred: " + e.getMessage());
        }
    }
    
    private void deactivateStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            int userId = Integer.parseInt(request.getParameter("userId")); // target user id
            
            // Kiểm tra quyền: Manager không thể vô hiệu hóa tài khoản Manager khác
            HttpSession session = request.getSession(false);
            if (session != null) {
                Models.User currentUser = (Models.User) session.getAttribute("user");
                if (currentUser != null && "Manager".equals(currentUser.getRoleName())) {
                    // Lấy thông tin staff cần vô hiệu hóa
                    Models.Staff targetStaff = staffDAO.getStaffById(staffId);
                    if (targetStaff != null) {
                        // Kiểm tra xem staff có phải là Manager không (dựa vào position)
                        if ("Manager".equals(targetStaff.getPosition())) {
                            response.sendRedirect("staff-management?error=Cannot deactivate Manager accounts. Only system administrators can deactivate Manager accounts.");
                            return;
                        }
                    }
                }
            }
            int actorUserId = 0;
            if (session != null && session.getAttribute("user") != null) {
                actorUserId = ((Models.User) session.getAttribute("user")).getUserId();
            }
            boolean success = staffDAO.deactivateStaff(staffId, userId, actorUserId);
            
            if (success) {
                response.sendRedirect("staff-management?success=Staff deactivated successfully");
            } else {
                response.sendRedirect("staff-management?error=Failed to deactivate staff");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staff-management?error=An error occurred: " + e.getMessage());
        }
    }

    private void activateStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            int userId = Integer.parseInt(request.getParameter("userId")); // target user id

            // Kiểm tra quyền: Manager không thể kích hoạt tài khoản Manager khác (giữ nguyên chính sách)
            HttpSession session = request.getSession(false);
            if (session != null) {
                Models.User currentUser = (Models.User) session.getAttribute("user");
                if (currentUser != null && "Manager".equals(currentUser.getRoleName())) {
                    Models.Staff targetStaff = staffDAO.getStaffById(staffId);
                    if (targetStaff != null && "Manager".equals(targetStaff.getPosition())) {
                        response.sendRedirect("staff-management?error=Cannot activate Manager accounts. Only system administrators can activate Manager accounts.");
                        return;
                    }
                }
            }
            int actorUserId = 0;
            if (session != null && session.getAttribute("user") != null) {
                actorUserId = ((Models.User) session.getAttribute("user")).getUserId();
            }
            boolean success = staffDAO.activateStaff(staffId, userId, actorUserId);
            if (success) {
                response.sendRedirect("staff-management?success=Staff activated successfully");
            } else {
                response.sendRedirect("staff-management?error=Failed to activate staff");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staff-management?error=An error occurred: " + e.getMessage());
        }
    }
}
