<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "voucher");
    request.setAttribute("overlayNav", false);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${viewMode == 'create' ? 'Tạo voucher mới' : (viewMode == 'edit' ? 'Chỉnh sửa voucher' : 'Chi tiết voucher')} - RMSG4</title>
    
    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet">

    <!-- Icons & Bootstrap -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Template Styles -->
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">
    
    <style>
        /* ===== Elegant theme (Indigo x Champagne) ===== */
        :root{
          --space-1: .5rem; --space-2: .75rem; --space-3: 1rem; --space-4: 1.25rem; --space-5: 1.5rem;
          --radius: 16px;
          --ink-900:#0f172a; --ink-700:#334155; --ink-500:#64748b;
          --paper:#f7f7fa; --card:#ffffff;
          --primary:#4f46e5; --primary-600:#4338ca;
          --accent:#c9a86a; --accent-600:#b8925a;
          --success:#16a34a; --warning:#f59e0b; --danger:#dc2626;
          --line:#eef2f7;
        }
        :root{ --bs-primary: var(--primary); --bs-link-color: var(--primary); }

        body { background: radial-gradient(1200px 700px at 10% -10%, #ecebfd 0%, transparent 40%),
                            radial-gradient(900px 600px at 110% 10%, #fff3e0 0%, transparent 35%),
                            var(--paper); color: var(--ink-900); }
        .app { display: grid; grid-template-columns: 280px 1fr; min-height: 100vh; }
        @media (max-width: 992px) {
            .app { grid-template-columns: 1fr; }
            #sidebar { position: fixed; inset: 0 30% 0 0; transform: translateX(-100%); transition: transform .2s ease; z-index: 1040; }
            #sidebar.open { transform: translateX(0); }
        }
        .content { padding: 28px 32px 44px; }
        .page-header { display: flex; align-items: center; justify-content: space-between; gap: var(--space-3); margin-bottom: var(--space-4); }
        .page-header h3 { margin: 0 0 var(--space-1) 0; font-weight: 700; letter-spacing:.1px }
        .breadcrumb .breadcrumb-item + .breadcrumb-item::before { color: var(--ink-500); }

        .card { border: none; border-radius: var(--radius); background: var(--card); box-shadow: 0 8px 28px rgba(20, 24, 40, .08); }
        .card-header { background: linear-gradient(180deg, rgba(79,70,229,.06), rgba(79,70,229,0)); border-bottom: 1px solid var(--line); padding: var(--space-3) var(--space-4); }
        .card-body { padding: var(--space-4); }

        .form-group { margin-bottom: var(--space-4); }
        .form-label { font-weight: 600; color: var(--ink-700); margin-bottom: var(--space-2); display: block; }
        .form-control, .form-select { 
            padding: var(--space-3); 
            border: 2px solid var(--line); 
            border-radius: var(--space-2); 
            transition: all 0.3s ease; 
        }
        .form-control:focus, .form-select:focus { 
            border-color: var(--primary); 
            box-shadow: 0 0 0 0.2rem rgba(79, 70, 229, 0.25); 
        }
        
        .readonly-field { background-color: var(--paper) !important; cursor: not-allowed; }
        
        .btn { padding: var(--space-2) var(--space-4); border-radius: var(--space-2); font-weight: 600; }
        .btn-primary { background: var(--primary); color: white; }
        .btn-primary:hover { background: var(--primary-600); }
        .btn-secondary { background: var(--ink-500); color: white; }
        .btn-danger { background: var(--danger); color: white; }
        
        .muted { color: var(--ink-500); }
    </style>
</head>
<body>

<!-- ===== Header ===== -->
<jsp:include page="/layouts/Header.jsp"/>

<div class="app">

    <!-- ===== Sidebar ===== -->
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <!-- ===== Main content ===== -->
    <main class="content">

        <div class="page-header">
            <div>
                <h3>
                    <i class="bi ${viewMode == 'create' ? 'bi-plus-circle' : (viewMode == 'edit' ? 'bi-pencil-square' : 'bi-eye')}"></i>
                    ${viewMode == 'create' ? 'Tạo voucher mới' : (viewMode == 'edit' ? 'Chỉnh sửa voucher' : 'Chi tiết voucher')}
                </h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="<c:url value='/'/>">Trang chủ</a></li>
                        <li class="breadcrumb-item"><a href="voucher-management">Quản lý Voucher</a></li>
                        <li class="breadcrumb-item active">${viewMode == 'create' ? 'Tạo mới' : (viewMode == 'edit' ? 'Chỉnh sửa' : 'Chi tiết')}</li>
                    </ol>
                </nav>
            </div>
            <button class="btn btn-outline-secondary d-lg-none" onclick="toggleSidebar()"><i class="bi bi-list"></i> Menu</button>
        </div>

        <!-- Error/Success Messages -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show">
                <i class="bi bi-exclamation-circle me-2"></i> ${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Form Card -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="bi bi-ticket-perforated me-2"></i>
                    Thông tin voucher
                </h5>
            </div>
            <div class="card-body">
                <form action="voucher-management" method="post">
                    <input type="hidden" name="action" value="${viewMode == 'edit' ? 'update' : 'create'}">
                    <c:if test="${viewMode == 'edit' or viewMode == 'view'}">
                        <input type="hidden" name="voucherId" value="${voucher.voucherId}">
                    </c:if>
                    
                    <div class="row">
                        <!-- Left Column -->
                        <div class="col-lg-8">
                            <!-- Voucher Code -->
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="bi bi-upc text-primary me-1"></i> Mã voucher *
                                </label>
                                <input type="text" 
                                       class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                       name="code" 
                                       value="${voucher.code}" 
                                       placeholder="VD: SALE20, NEWYEAR2024"
                                       style="text-transform: uppercase; font-family: 'Courier New', monospace; font-weight: bold;"
                                       minlength="3"
                                       maxlength="20"
                                       pattern="[A-Z0-9]+"
                                       ${viewMode == 'view' ? 'readonly' : ''} 
                                       required>
                                <small class="text-muted">Chỉ chữ HOA và số, không dấu, 3-20 ký tự</small>
                            </div>
                            
                            <!-- Description -->
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="bi bi-text-left text-primary me-1"></i> Mô tả
                                </label>
                                <textarea class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                          name="description" 
                                          rows="3" 
                                          placeholder="VD: Giảm 20% cho hóa đơn từ 500k"
                                          maxlength="255"
                                          ${viewMode == 'view' ? 'readonly' : ''}>${voucher.description}</textarea>
                            </div>
                            
                            <!-- Discount Type & Value -->
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="bi bi-tag text-primary me-1"></i> Loại giảm giá *
                                        </label>
                                        <select class="form-select ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                                name="discountType" 
                                                id="discountType"
                                                onchange="updateDiscountLabel()"
                                                ${viewMode == 'view' ? 'disabled' : ''} 
                                                required>
                                            <option value="PERCENT" ${voucher.discountType == 'PERCENT' ? 'selected' : ''}>Giảm theo %</option>
                                            <option value="AMOUNT" ${voucher.discountType == 'AMOUNT' ? 'selected' : ''}>Giảm số tiền cố định</option>
                                        </select>
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="bi bi-percent text-primary me-1"></i> 
                                            <span id="discountValueLabel">Giá trị giảm</span> *
                                        </label>
                                        <input type="number" 
                                               class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                               name="discountValue" 
                                               id="discountValue"
                                               value="${voucher.discountValue}" 
                                               min="1" 
                                               step="1"
                                               ${viewMode == 'view' ? 'readonly' : ''} 
                                               required>
                                        <small class="text-muted" id="discountHint">
                                            ${voucher.discountType == 'PERCENT' ? 'Nhập % (1-100)' : 'Nhập số tiền (VNĐ)'}
                                        </small>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Min Order & Usage Limit -->
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="bi bi-cash text-primary me-1"></i> Giá trị đơn tối thiểu
                                        </label>
                                        <input type="number" 
                                               class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                               name="minOrderTotal" 
                                               value="${voucher.minOrderTotal}" 
                                               min="0" 
                                               step="1000"
                                               placeholder="0"
                                               ${viewMode == 'view' ? 'readonly' : ''}>
                                        <small class="text-muted">Để 0 nếu không yêu cầu</small>
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="bi bi-hash text-primary me-1"></i> Giới hạn số lần dùng
                                        </label>
                                        <input type="number" 
                                               class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                               name="usageLimit" 
                                               value="${voucher.usageLimit}" 
                                               min="1" 
                                               placeholder="Để trống = không giới hạn"
                                               ${viewMode == 'view' ? 'readonly' : ''}>
                                        <small class="text-muted">Tổng số lần có thể sử dụng</small>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Valid From & Valid To -->
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="bi bi-calendar-check text-primary me-1"></i> Hiệu lực từ ngày
                                        </label>
                                        <input type="date" 
                                               class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                               name="validFrom" 
                                               value="${voucher.validFrom}" 
                                               ${viewMode == 'view' ? 'readonly' : ''}>
                                        <small class="text-muted">Để trống = hiệu lực ngay</small>
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="bi bi-calendar-x text-primary me-1"></i> Hiệu lực đến ngày
                                        </label>
                                        <input type="date" 
                                               class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                               name="validTo" 
                                               value="${voucher.validTo}" 
                                               ${viewMode == 'view' ? 'readonly' : ''}>
                                        <small class="text-muted">Để trống = không giới hạn</small>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Status -->
                            <c:if test="${viewMode != 'create'}">
                                <div class="form-group">
                                    <label class="form-label">
                                        <i class="bi bi-toggle-on text-primary me-1"></i> Trạng thái
                                    </label>
                                    <select class="form-select ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                            name="status" 
                                            ${viewMode == 'view' ? 'disabled' : ''}>
                                        <option value="ACTIVE" ${voucher.status == 'ACTIVE' ? 'selected' : ''}>Hoạt động</option>
                                        <option value="INACTIVE" ${voucher.status == 'INACTIVE' ? 'selected' : ''}>Không hoạt động</option>
                                    </select>
                                </div>
                            </c:if>
                        </div>
                        
                        <!-- Right Column - Info -->
                        <div class="col-lg-4">
                            <c:if test="${viewMode == 'view' and not empty voucher}">
                                <div class="card bg-light">
                                    <div class="card-body">
                                        <h6 class="card-title">
                                            <i class="bi bi-info-circle me-1"></i> Thông tin bổ sung
                                        </h6>
                                        
                                        <div class="mb-3">
                                            <small class="text-muted d-block">Mã voucher</small>
                                            <strong style="font-family: 'Courier New', monospace; font-size: 1.2rem;">
                                                ${voucher.code}
                                            </strong>
                                        </div>
                                        
                                        <div class="mb-3">
                                            <small class="text-muted d-block">Loại giảm</small>
                                            <span class="badge ${voucher.discountType eq 'PERCENT' ? 'bg-info' : 'bg-warning'} text-dark">
                                                ${voucher.discountTypeDisplay}
                                            </span>
                                        </div>
                                        
                                        <div class="mb-3">
                                            <small class="text-muted d-block">Giá trị</small>
                                            <strong class="text-primary" style="font-size: 1.3rem;">
                                                ${voucher.discountDisplay}
                                            </strong>
                                        </div>
                                        
                                        <div class="mb-3">
                                            <small class="text-muted d-block">Đã sử dụng</small>
                                            <strong>${voucher.usageLimitDisplay}</strong>
                                        </div>
                                        
                                        <c:if test="${not empty voucher.createdByName}">
                                            <div class="mb-3">
                                                <small class="text-muted d-block">Tạo bởi</small>
                                                <span>${voucher.createdByName}</span>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="mt-4 pt-3 border-top">
                        <c:if test="${viewMode != 'view'}">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi ${viewMode == 'create' ? 'bi-plus-circle' : 'bi-check-circle'}"></i>
                                ${viewMode == 'create' ? 'Tạo voucher' : 'Lưu thay đổi'}
                            </button>
                        </c:if>
                        
                        <c:if test="${viewMode == 'view'}">
                            <a href="voucher-management?action=edit&id=${voucher.voucherId}" class="btn btn-primary">
                                <i class="bi bi-pencil-square"></i> Chỉnh sửa
                            </a>
                            <button type="button" class="btn btn-danger" onclick="confirmDelete(${voucher.voucherId})">
                                <i class="bi bi-trash"></i> Vô hiệu hóa
                            </button>
                        </c:if>
                        
                        <a href="voucher-management" class="btn btn-secondary">
                            <i class="bi bi-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </form>
            </div>
        </div>

    </main>
</div>

<!-- ===== Footer ===== -->
<jsp:include page="/layouts/Footer.jsp"/>

<!-- ===== JS ===== -->
<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    function toggleSidebar(){
        var el = document.getElementById('sidebar');
        if(el){ el.classList.toggle('open'); }
    }

    function updateDiscountLabel() {
        var type = document.getElementById('discountType').value;
        var label = document.getElementById('discountValueLabel');
        var hint = document.getElementById('discountHint');
        var input = document.getElementById('discountValue');
        
        if (type === 'PERCENT') {
            label.innerHTML = '<i class="bi bi-percent text-primary me-1"></i> Phần trăm giảm *';
            hint.textContent = 'Nhập % (1-100)';
            input.max = '100';
            input.step = '1';
        } else {
            label.innerHTML = '<i class="bi bi-currency-dollar text-primary me-1"></i> Số tiền giảm *';
            hint.textContent = 'Nhập số tiền (VNĐ)';
            input.max = '';
            input.step = '1000';
        }
    }

    function confirmDelete(voucherId) {
        if (confirm('Bạn có chắc chắn muốn vô hiệu hóa voucher này không?')) {
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = 'voucher-management';
            
            var actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            
            var idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'voucherId';
            idInput.value = voucherId;
            
            form.appendChild(actionInput);
            form.appendChild(idInput);
            document.body.appendChild(form);
            form.submit();
        }
    }

    // Auto-dismiss alerts
    setTimeout(function() {
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(alert) {
            var bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        });
    }, 5000);
    
    // Initialize discount label on load
    window.addEventListener('DOMContentLoaded', function() {
        if (document.getElementById('discountType')) {
            updateDiscountLabel();
        }
    });
</script>

</body>
</html>

