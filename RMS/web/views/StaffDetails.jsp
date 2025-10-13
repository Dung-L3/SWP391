<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="Models.Staff"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết nhân viên - RMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .detail-card {
            border: none;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .info-item {
            padding: 10px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        .info-item:last-child {
            border-bottom: none;
        }
        .info-label {
            font-weight: 600;
            color: #495057;
            min-width: 150px;
        }
        .status-badge {
            font-size: 0.9em;
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
                    <%
                        Staff staff = (Staff) request.getAttribute("staff");
                        if (staff == null) {
                    %>
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle"></i> Không tìm thấy thông tin nhân viên
                    </div>
                    <% } else { %>
                    
                    <!-- Header -->
                    <div class="row mb-4">
                        <div class="col-md-8">
                            <h2><i class="fas fa-user"></i> Chi tiết nhân viên</h2>
                            <p class="text-muted">Thông tin chi tiết về nhân viên</p>
                        </div>
                        <div class="col-md-4 text-end">
                            <a href="staff-management" class="btn btn-secondary me-2">
                                <i class="fas fa-arrow-left"></i> Quay lại
                            </a>
                            <a href="staff-management?action=edit&id=<%= staff.getStaffId() %>" class="btn btn-warning">
                                <i class="fas fa-edit"></i> Chỉnh sửa
                            </a>
                        </div>
                    </div>
                    
                    <div class="row">
                        <!-- Thông tin cơ bản -->
                        <div class="col-md-6">
                            <div class="card detail-card">
                                <div class="card-header bg-primary text-white">
                                    <h5 class="mb-0"><i class="fas fa-user"></i> Thông tin cá nhân</h5>
                                </div>
                                <div class="card-body">
                                    <div class="info-item d-flex">
                                        <span class="info-label">Họ tên:</span>
                                        <span><%= staff.getFullName() %></span>
                                    </div>
                                    <div class="info-item d-flex">
                                        <span class="info-label">Email:</span>
                                        <span><%= staff.getEmail() %></span>
                                    </div>
                                    <div class="info-item d-flex">
                                        <span class="info-label">Số điện thoại:</span>
                                        <span><%= staff.getPhone() != null && !staff.getPhone().isEmpty() ? staff.getPhone() : "Chưa cập nhật" %></span>
                                    </div>
                                    <div class="info-item d-flex">
                                        <span class="info-label">Trạng thái:</span>
                                        <span class="badge <%= staff.isActive() ? "bg-success" : "bg-secondary" %> status-badge">
                                            <%= staff.getStatus() %>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Thông tin công việc -->
                        <div class="col-md-6">
                            <div class="card detail-card">
                                <div class="card-header bg-info text-white">
                                    <h5 class="mb-0"><i class="fas fa-briefcase"></i> Thông tin công việc</h5>
                                </div>
                                <div class="card-body">
                                    <div class="info-item d-flex">
                                        <span class="info-label">Vị trí:</span>
                                        <span><%= staff.getPosition() %></span>
                                    </div>
                                    <div class="info-item d-flex">
                                        <span class="info-label">Ngày vào làm:</span>
                                        <span><%= staff.getHireDate() != null ? 
                                                new SimpleDateFormat("dd/MM/yyyy").format(staff.getHireDate()) : "Chưa cập nhật" %></span>
                                    </div>
                                    <div class="info-item d-flex">
                                        <span class="info-label">Lương cơ bản:</span>
                                        <span>
                                            <% if (staff.getSalary() != null && staff.getSalary().compareTo(java.math.BigDecimal.ZERO) > 0) { %>
                                                <%= NumberFormat.getNumberInstance(Locale.US).format(staff.getSalary()) %> VNĐ
                                            <% } else { %>
                                                Chưa cập nhật
                                            <% } %>
                                        </span>
                                    </div>
                                    <div class="info-item d-flex">
                                        <span class="info-label">ID nhân viên:</span>
                                        <span class="text-muted">#<%= staff.getStaffId() %></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Thông tin bổ sung -->
                    <div class="row mt-4">
                        <div class="col-12">
                            <div class="card detail-card">
                                <div class="card-header bg-secondary text-white">
                                    <h5 class="mb-0"><i class="fas fa-info-circle"></i> Thông tin bổ sung</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="info-item d-flex">
                                                <span class="info-label">User ID:</span>
                                                <span class="text-muted">#<%= staff.getUserId() %></span>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="info-item d-flex">
                                                <span class="info-label">Manager ID:</span>
                                                <span class="text-muted">
                                                    <%= staff.getManagerId() != null ? "#" + staff.getManagerId() : "Không có" %>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="row mt-4">
                        <div class="col-12 text-center">
                            <a href="staff-management?action=edit&id=<%= staff.getStaffId() %>" class="btn btn-warning me-2">
                                <i class="fas fa-edit"></i> Chỉnh sửa thông tin
                            </a>
                            <% if (staff.isActive()) { %>
                            <button class="btn btn-danger" onclick="confirmDeactivate(<%= staff.getStaffId() %>, <%= staff.getUserId() %>, '<%= staff.getFullName() %>')">
                                <i class="fas fa-user-times"></i> Vô hiệu hóa tài khoản
                            </button>
                            <% } else { %>
                            <span class="text-muted">Tài khoản đã bị vô hiệu hóa</span>
                            <% } %>
                        </div>
                    </div>
                    
                    <% } %>
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
