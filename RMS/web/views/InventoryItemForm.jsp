<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "inventory");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>${viewMode == 'create' ? 'Thêm nguyên liệu' : (viewMode == 'edit' ? 'Sửa nguyên liệu' : 'Chi tiết nguyên liệu')} - RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">
    
    <style>
        :root {
            --primary: #4f46e5;
            --accent: #c9a86a;
            --success: #16a34a;
            --danger: #dc2626;
            --paper: #f7f7fa;
        }
        body { background: var(--paper); }
        .content { padding: 28px 32px; max-width: 1200px; margin: 0 auto; }
        .card { border: none; border-radius: 16px; box-shadow: 0 8px 28px rgba(20,24,40,.08); }
        .card-header { background: linear-gradient(180deg, rgba(79,70,229,.06), transparent); border-bottom: 1px solid #eef2f7; }
        .form-label { font-weight: 600; color: #334155; }
        .form-control, .form-select { border: 2px solid #eef2f7; border-radius: 8px; }
        .form-control:focus, .form-select:focus { border-color: var(--primary); box-shadow: 0 0 0 0.2rem rgba(79,70,229,0.25); }
        .btn { border-radius: 8px; padding: 0.5rem 1rem; font-weight: 600; }
        .btn-primary { background: var(--primary); border-color: var(--primary); }
    </style>
</head>
<body>

<jsp:include page="/layouts/Header.jsp"/>

<div class="content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3><i class="bi ${viewMode == 'create' ? 'bi-plus-circle' : (viewMode == 'edit' ? 'bi-pencil-square' : 'bi-eye')}"></i>
                ${viewMode == 'create' ? 'Thêm nguyên liệu' : (viewMode == 'edit' ? 'Sửa nguyên liệu' : 'Chi tiết nguyên liệu')}
            </h3>
            <nav>
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Trang chủ</a></li>
                    <li class="breadcrumb-item"><a href="inventory-management">Quản lý Kho</a></li>
                    <li class="breadcrumb-item active">${viewMode == 'create' ? 'Thêm mới' : (viewMode == 'edit' ? 'Chỉnh sửa' : 'Chi tiết')}</li>
                </ol>
            </nav>
        </div>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-circle me-2"></i>${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <h5 class="mb-0"><i class="bi bi-box-seam me-2"></i>Thông tin nguyên liệu</h5>
        </div>
        <div class="card-body">
            <form action="inventory-management" method="post">
                <input type="hidden" name="action" value="${viewMode == 'edit' ? 'update' : 'create'}">
                <c:if test="${viewMode == 'edit' or viewMode == 'view'}">
                    <input type="hidden" name="itemId" value="${inventoryItem.itemId}">
                </c:if>

                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-box text-primary me-1"></i>Tên nguyên liệu *</label>
                            <input type="text" class="form-control ${viewMode == 'view' ? 'readonly' : ''}" 
                                   name="itemName" value="${inventoryItem.itemName}" 
                                   ${viewMode == 'view' ? 'readonly' : ''} required>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-tags text-primary me-1"></i>Loại</label>
                            <input type="text" class="form-control ${viewMode == 'view' ? 'readonly' : ''}" 
                                   name="category" value="${inventoryItem.category}" 
                                   placeholder="Rau củ, Thịt, Gia vị..." 
                                   ${viewMode == 'view' ? 'readonly' : ''}>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-rulers text-primary me-1"></i>Đơn vị tính *</label>
                            <input type="text" class="form-control ${viewMode == 'view' ? 'readonly' : ''}" 
                                   name="uom" value="${inventoryItem.uom}" 
                                   placeholder="kg, lít, gram..." 
                                   ${viewMode == 'view' ? 'readonly' : ''} required>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-box-seam text-primary me-1"></i>Tồn kho hiện tại</label>
                            <input type="number" class="form-control ${viewMode == 'view' ? 'readonly' : ''}" 
                                   name="currentStock" value="${inventoryItem.currentStock}" 
                                   min="0" step="0.001" 
                                   ${viewMode == 'view' ? 'readonly' : ''}>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-exclamation-triangle text-warning me-1"></i>Tồn kho tối thiểu</label>
                            <input type="number" class="form-control ${viewMode == 'view' ? 'readonly' : ''}" 
                                   name="minimumStock" value="${inventoryItem.minimumStock}" 
                                   min="0" step="0.001" 
                                   ${viewMode == 'view' ? 'readonly' : ''}>
                            <small class="text-muted">Cảnh báo khi tồn kho thấp hơn mức này</small>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-currency-dollar text-primary me-1"></i>Đơn giá (VNĐ)</label>
                            <input type="number" class="form-control ${viewMode == 'view' ? 'readonly' : ''}" 
                                   name="unitCost" value="${inventoryItem.unitCost}" 
                                   min="0" step="100" 
                                   ${viewMode == 'view' ? 'readonly' : ''}>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-building text-primary me-1"></i>Nhà cung cấp</label>
                            <select class="form-select ${viewMode == 'view' ? 'readonly' : ''}" 
                                    name="supplierId" ${viewMode == 'view' ? 'disabled' : ''}>
                                <option value="">-- Chọn nhà cung cấp --</option>
                                <c:forEach var="supplier" items="${suppliers}">
                                    <option value="${supplier.supplierId}" 
                                            ${supplier.supplierId == inventoryItem.supplierId ? 'selected' : ''}>
                                        ${supplier.companyName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-calendar-x text-primary me-1"></i>Ngày hết hạn</label>
                            <input type="date" class="form-control ${viewMode == 'view' ? 'readonly' : ''}" 
                                   name="expiryDate" value="${inventoryItem.expiryDate}" 
                                   ${viewMode == 'view' ? 'readonly' : ''}>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-toggle-on text-primary me-1"></i>Trạng thái</label>
                            <select class="form-select ${viewMode == 'view' ? 'readonly' : ''}" 
                                    name="status" ${viewMode == 'view' ? 'disabled' : ''}>
                                <option value="ACTIVE" ${inventoryItem.status == 'ACTIVE' ? 'selected' : ''}>Đang dùng</option>
                                <option value="INACTIVE" ${inventoryItem.status == 'INACTIVE' ? 'selected' : ''}>Ngừng dùng</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="border-top pt-3 mt-4">
                    <c:if test="${viewMode != 'view'}">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi ${viewMode == 'create' ? 'bi-plus-circle' : 'bi-check-circle'}"></i>
                            ${viewMode == 'create' ? 'Thêm nguyên liệu' : 'Lưu thay đổi'}
                        </button>
                    </c:if>
                    
                    <c:if test="${viewMode == 'view' and sessionScope.user.roleName == 'Manager'}">
                        <a href="inventory-management?action=edit&id=${inventoryItem.itemId}" class="btn btn-primary">
                            <i class="bi bi-pencil-square"></i> Chỉnh sửa
                        </a>
                    </c:if>
                    
                    <a href="inventory-management" class="btn btn-secondary">
                        <i class="bi bi-arrow-left"></i> Quay lại
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/layouts/Footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
setTimeout(function() {
    var alerts = document.querySelectorAll('.alert');
    alerts.forEach(function(alert) {
        var bsAlert = new bootstrap.Alert(alert);
        bsAlert.close();
    });
}, 5000);
</script>

</body>
</html>

