<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="Models.Staff"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý nhân viên - RMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .staff-card {
            transition: transform 0.2s;
        }
        .staff-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .status-badge {
            font-size: 0.8em;
        }
        .action-buttons .btn {
            margin: 2px;
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
                            <h2><i class="fas fa-users"></i> Quản lý nhân viên</h2>
                            <p class="text-muted">Quản lý thông tin và tài khoản nhân viên</p>
                        </div>
                        <div class="col-md-4 text-end">
                            <a href="staff-management?action=add" class="btn btn-primary">
                                <i class="fas fa-plus"></i> Thêm nhân viên
                            </a>
                        </div>
                    </div>
                    
                    <!-- Alert Messages -->
                    <% 
                        String success = request.getParameter("success");
                        String error = request.getParameter("error");
                        if (success != null) {
                    %>
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fas fa-check-circle"></i> <%= success %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>
                    
                    <% if (error != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle"></i> <%= error %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>
                    
                    <!-- Staff List -->
                    <div class="row">
                        <%
                            List<Staff> staffList = (List<Staff>) request.getAttribute("staffList");
                            if (staffList != null && !staffList.isEmpty()) {
                                for (Staff staff : staffList) {
                        %>
                        <div class="col-md-6 col-lg-4 mb-4">
                            <div class="card staff-card h-100">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-start mb-3">
                                        <div>
                                            <h5 class="card-title mb-1"><%= staff.getFullName() %></h5>
                                            <p class="text-muted mb-0"><%= staff.getPosition() %></p>
                                        </div>
                                        <span class="badge <%= staff.isActive() ? "bg-success" : "bg-secondary" %> status-badge">
                                            <%= staff.getStatus() %>
                                        </span>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <p class="mb-1"><i class="fas fa-envelope text-muted"></i> <%= staff.getEmail() %></p>
                                        <p class="mb-1"><i class="fas fa-phone text-muted"></i> <%= staff.getPhone() != null ? staff.getPhone() : "N/A" %></p>
                                        <% if (staff.getHireDate() != null) { %>
                                        <p class="mb-0"><i class="fas fa-calendar text-muted"></i> <%= staff.getHireDate() %></p>
                                        <% } %>
                                    </div>
                                    
                                    <div class="action-buttons">
                                        <a href="staff-management?action=view&id=<%= staff.getStaffId() %>" 
                                           class="btn btn-sm btn-outline-info">
                                            <i class="fas fa-eye"></i> Xem
                                        </a>
                                        <a href="staff-management?action=edit&id=<%= staff.getStaffId() %>" 
                                           class="btn btn-sm btn-outline-warning">
                                            <i class="fas fa-edit"></i> Sửa
                                        </a>
                                        <% if (staff.isActive()) { %>
                                        <button class="btn btn-sm btn-outline-danger" 
                                                onclick="confirmDeactivate(<%= staff.getStaffId() %>, <%= staff.getUserId() %>, '<%= staff.getFullName() %>')">
                                            <i class="fas fa-user-times"></i> Vô hiệu hóa
                                        </button>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                                }
                            } else {
                        %>
                        <div class="col-12">
                            <div class="text-center py-5">
                                <i class="fas fa-users fa-3x text-muted mb-3"></i>
                                <h4 class="text-muted">Chưa có nhân viên nào</h4>
                                <p class="text-muted">Hãy thêm nhân viên đầu tiên để bắt đầu</p>
                                <a href="staff-management?action=add" class="btn btn-primary">
                                    <i class="fas fa-plus"></i> Thêm nhân viên
                                </a>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Deactivate Confirmation Modal -->
    <div class="modal fade" id="deactivateModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Xác nhận vô hiệu hóa</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Bạn có chắc chắn muốn vô hiệu hóa nhân viên <strong id="staffName"></strong>?</p>
                    <p class="text-danger"><small>Hành động này sẽ:</small></p>
                    <ul class="text-danger small">
                        <li>Vô hiệu hóa tài khoản đăng nhập</li>
                        <li>Đăng xuất tất cả phiên đăng nhập hiện tại</li>
                        <li>Thay đổi trạng thái nhân viên thành INACTIVE</li>
                    </ul>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <form method="post" style="display: inline;">
                        <input type="hidden" name="action" value="deactivate">
                        <input type="hidden" name="staffId" id="deactivateStaffId">
                        <input type="hidden" name="userId" id="deactivateUserId">
                        <button type="submit" class="btn btn-danger">Vô hiệu hóa</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function confirmDeactivate(staffId, userId, staffName) {
            document.getElementById('deactivateStaffId').value = staffId;
            document.getElementById('deactivateUserId').value = userId;
            document.getElementById('staffName').textContent = staffName;
            
            var modal = new bootstrap.Modal(document.getElementById('deactivateModal'));
            modal.show();
        }
    </script>
</body>
</html>
