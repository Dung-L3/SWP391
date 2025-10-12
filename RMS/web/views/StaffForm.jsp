<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="Models.Staff"%>
<%@page import="Models.Role"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getAttribute("action").equals("add") ? "Thêm nhân viên" : "Sửa nhân viên" %> - RMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .form-section {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .section-title {
            color: #495057;
            border-bottom: 2px solid #dee2e6;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 bg-dark text-white min-vh-100 p-0">
                <jsp:include page="../layouts/sidebar.jsp"/>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-10">
                <div class="container-fluid py-4">
                    <!-- Header -->
                    <div class="row mb-4">
                        <div class="col-md-8">
                            <h2>
                                <i class="fas fa-user-plus"></i> 
                                <%= request.getAttribute("action").equals("add") ? "Thêm nhân viên mới" : "Sửa thông tin nhân viên" %>
                            </h2>
                            <p class="text-muted">
                                <%= request.getAttribute("action").equals("add") ? "Nhập thông tin nhân viên mới" : "Cập nhật thông tin nhân viên" %>
                            </p>
                        </div>
                        <div class="col-md-4 text-end">
                            <a href="staff-management" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Quay lại
                            </a>
                        </div>
                    </div>
                    
                    <!-- Alert Messages -->
                    <% 
                        String error = request.getParameter("error");
                        if (error != null) {
                    %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle"></i> <%= error %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>
                    
                    <!-- Form -->
                    <form method="post" action="staff-management">
                        <input type="hidden" name="action" value="<%= request.getAttribute("action").equals("add") ? "create" : "update" %>">
                        
                        <% 
                            Staff staff = (Staff) request.getAttribute("staff");
                            if (staff != null) {
                        %>
                        <input type="hidden" name="staffId" value="<%= staff.getStaffId() %>">
                        <input type="hidden" name="userId" value="<%= staff.getUserId() %>">
                        <% } %>
                        
                        <div class="row">
                            <!-- Thông tin cơ bản -->
                            <div class="col-md-6">
                                <div class="form-section">
                                    <h4 class="section-title">
                                        <i class="fas fa-user"></i> Thông tin cơ bản
                                    </h4>
                                    
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label for="firstName" class="form-label">Họ <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="firstName" name="firstName" 
                                                   value="<%= staff != null ? staff.getFirstName() : "" %>" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label for="lastName" class="form-label">Tên <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="lastName" name="lastName" 
                                                   value="<%= staff != null ? staff.getLastName() : "" %>" required>
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                                        <input type="email" class="form-control" id="email" name="email" 
                                               value="<%= staff != null ? staff.getEmail() : "" %>" required>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="phone" class="form-label">Số điện thoại</label>
                                        <input type="tel" class="form-control" id="phone" name="phone" 
                                               value="<%= staff != null ? staff.getPhone() : "" %>">
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Thông tin công việc -->
                            <div class="col-md-6">
                                <div class="form-section">
                                    <h4 class="section-title">
                                        <i class="fas fa-briefcase"></i> Thông tin công việc
                                    </h4>
                                    
                                    <div class="mb-3">
                                        <label for="position" class="form-label">Vị trí <span class="text-danger">*</span></label>
                                        <select class="form-select" id="position" name="position" required>
                                            <option value="">Chọn vị trí</option>
                                            <option value="Manager" <%= (staff != null && "Manager".equals(staff.getPosition())) ? "selected" : "" %>>Quản lý</option>
                                            <option value="Waiter" <%= (staff != null && "Waiter".equals(staff.getPosition())) ? "selected" : "" %>>Phục vụ</option>
                                            <option value="Chef" <%= (staff != null && "Chef".equals(staff.getPosition())) ? "selected" : "" %>>Đầu bếp</option>
                                            <option value="Receptionist" <%= (staff != null && "Receptionist".equals(staff.getPosition())) ? "selected" : "" %>>Lễ tân</option>
                                            <option value="Cashier" <%= (staff != null && "Cashier".equals(staff.getPosition())) ? "selected" : "" %>>Thu ngân</option>
                                            <option value="Supervisor" <%= (staff != null && "Supervisor".equals(staff.getPosition())) ? "selected" : "" %>>Giám sát</option>
                                        </select>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="roleId" class="form-label">Vai trò hệ thống <span class="text-danger">*</span></label>
                                        <select class="form-select" id="roleId" name="roleId" required>
                                            <option value="">Chọn vai trò</option>
                                            <%
                                                List<Role> roles = (List<Role>) request.getAttribute("roles");
                                                if (roles != null) {
                                                    for (Role role : roles) {
                                            %>
                                            <option value="<%= role.getRoleId() %>" 
                                                    <%= (staff != null && staff.getUserId() == role.getRoleId()) ? "selected" : "" %>>
                                                <%= role.getRoleName() %>
                                            </option>
                                            <%
                                                    }
                                                }
                                            %>
                                        </select>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="hireDate" class="form-label">Ngày vào làm</label>
                                        <input type="date" class="form-control" id="hireDate" name="hireDate" 
                                               value="<%= staff != null && staff.getHireDate() != null ? 
                                                       new SimpleDateFormat("yyyy-MM-dd").format(staff.getHireDate()) : "" %>">
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="salary" class="form-label">Lương cơ bản (VNĐ)</label>
                                        <input type="number" class="form-control" id="salary" name="salary" 
                                               value="<%= staff != null && staff.getSalary() != null ? staff.getSalary() : "" %>" 
                                               min="0" step="1000">
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="managerId" class="form-label">Quản lý trực tiếp</label>
                                        <select class="form-select" id="managerId" name="managerId">
                                            <option value="">Không có</option>
                                            <%
                                                List<Staff> managers = (List<Staff>) request.getAttribute("managers");
                                                if (managers != null) {
                                                    for (Staff manager : managers) {
                                                        if (staff == null || staff.getStaffId() != manager.getStaffId()) {
                                            %>
                                            <option value="<%= manager.getStaffId() %>" 
                                                    <%= (staff != null && staff.getManagerId() != null && 
                                                         staff.getManagerId().equals(manager.getStaffId())) ? "selected" : "" %>>
                                                <%= manager.getFullName() %> - <%= manager.getPosition() %>
                                            </option>
                                            <%
                                                        }
                                                    }
                                                }
                                            %>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Buttons -->
                        <div class="row">
                            <div class="col-12 text-end">
                                <a href="staff-management" class="btn btn-secondary me-2">
                                    <i class="fas fa-times"></i> Hủy
                                </a>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save"></i> 
                                    <%= request.getAttribute("action").equals("add") ? "Tạo nhân viên" : "Cập nhật" %>
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-fill email from first name and last name
        document.getElementById('firstName').addEventListener('input', updateEmail);
        document.getElementById('lastName').addEventListener('input', updateEmail);
        
        function updateEmail() {
            if (document.getElementById('email').value === '') {
                var firstName = document.getElementById('firstName').value.toLowerCase();
                var lastName = document.getElementById('lastName').value.toLowerCase();
                if (firstName && lastName) {
                    document.getElementById('email').value = firstName + '.' + lastName + '@rms.com';
                }
            }
        }
        
        // Set default hire date to today
        if (document.getElementById('hireDate').value === '') {
            var today = new Date().toISOString().split('T')[0];
            document.getElementById('hireDate').value = today;
        }
    </script>
</body>
</html>
