<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    // Set page context for sidebar
    request.setAttribute("page", "menu");
    request.setAttribute("overlayNav", false);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${viewMode == 'create' ? 'Thêm món mới' : (viewMode == 'edit' ? 'Chỉnh sửa món ăn' : 'Chi tiết món ăn')} - RMSG4</title>
    
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
          /* spacing */
          --space-1: .5rem;   /* 8px  */
          --space-2: .75rem;  /* 12px */
          --space-3: 1rem;    /* 16px */
          --space-4: 1.25rem; /* 20px */
          --space-5: 1.5rem;  /* 24px */
          --radius: 16px;
          /* palette */
          --ink-900:#0f172a;   /* deep slate */
          --ink-700:#334155;   /* slate */
          --ink-500:#64748b;   /* muted */
          --paper:#f7f7fa;     /* page bg */
          --card:#ffffff;      /* card bg */
          --primary:#4f46e5;   /* indigo */
          --primary-600:#4338ca;
          --accent:#c9a86a;    /* champagne gold */
          --accent-600:#b8925a;
          --success:#16a34a;
          --warning:#f59e0b;
          --danger:#dc2626;
          --line:#eef2f7;
        }
        /* Bootstrap variable overrides (where respected) */
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

        .section { margin-top: var(--space-5); }
        .card { border: none; border-radius: var(--radius); background: var(--card); box-shadow: 0 8px 28px rgba(20, 24, 40, .08); overflow: hidden; }
        .card-header { background: linear-gradient(180deg, rgba(79,70,229,.06), rgba(79,70,229,0)); border-bottom: 1px solid var(--line); border-radius: var(--radius) var(--radius) 0 0; padding: var(--space-3) var(--space-4); }
        .card-body { padding: var(--space-4); }
        .card-footer { background: #fff; border-top: 1px solid var(--line); padding: var(--space-3) var(--space-4); border-radius: 0 0 var(--radius) var(--radius); }

        /* Form styling */
        .form-group { margin-bottom: var(--space-4); }
        .form-label { font-weight: 600; color: var(--ink-700); margin-bottom: var(--space-2); display: block; }
        .form-control, .form-select { 
            padding: var(--space-3); 
            border: 2px solid var(--line); 
            border-radius: var(--space-2); 
            font-size: 1rem; 
            transition: all 0.3s ease; 
        }
        .form-control:focus, .form-select:focus { 
            border-color: var(--primary); 
            box-shadow: 0 0 0 0.2rem rgba(79, 70, 229, 0.25); 
            outline: none; 
        }
        
        .readonly-field { background-color: var(--paper) !important; cursor: not-allowed; }
        
        /* Buttons */
        .btn { padding: var(--space-2) var(--space-4); border-radius: var(--space-2); font-weight: 600; transition: all 0.3s ease; text-decoration: none; display: inline-block; border: none; margin-right: var(--space-2); margin-bottom: var(--space-2); }
        .btn-primary { background: var(--primary); color: white; }
        .btn-primary:hover { background: var(--primary-600); color: white; transform: translateY(-1px); }
        .btn-secondary { background: var(--ink-500); color: white; }
        .btn-secondary:hover { background: var(--ink-700); color: white; }
        .btn-danger { background: var(--danger); color: white; }
        .btn-danger:hover { background: #b91c1c; color: white; transform: translateY(-1px); }
        
        .image-preview { max-width: 200px; max-height: 200px; border-radius: var(--space-2); border: 2px solid var(--line); margin-top: var(--space-3); }
        .info-badge { background: var(--accent); color: white; padding: var(--space-1) var(--space-3); border-radius: 20px; font-size: 0.9rem; margin-right: var(--space-2); margin-bottom: var(--space-2); display: inline-block; }
        .action-buttons { margin-top: var(--space-5); padding-top: var(--space-4); border-top: 2px solid var(--line); }
        
        /* Small helpers */
        .muted { color: var(--ink-500); }
    </style>
</head>
<body>

<!-- ===== Header ===== -->
<jsp:include page="/layouts/Header.jsp"/>

<div class="app">

    <!-- ===== Sidebar dùng chung ===== -->
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <!-- ===== Main content ===== -->
    <main class="content">

        <div class="page-header">
            <div>
                <h3>
                    <i class="bi ${viewMode == 'create' ? 'bi-plus-circle' : (viewMode == 'edit' ? 'bi-pencil-square' : 'bi-eye')}"></i>
                    ${viewMode == 'create' ? 'Thêm món mới' : (viewMode == 'edit' ? 'Chỉnh sửa món ăn' : 'Chi tiết món ăn')}
                </h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                        <li class="breadcrumb-item"><a href="menu-management">Quản lý Menu</a></li>
                        <li class="breadcrumb-item active" aria-current="page">${viewMode == 'create' ? 'Thêm mới' : (viewMode == 'edit' ? 'Chỉnh sửa' : 'Chi tiết')}</li>
                    </ol>
                </nav>
            </div>
            <button class="btn btn-outline-secondary d-lg-none" onclick="toggleSidebar()"><i class="bi bi-list"></i> Menu</button>
        </div>

        <!-- Error/Success Messages -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-circle me-2"></i> ${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle me-2"></i> ${successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <!-- Form Card -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="bi ${viewMode == 'create' ? 'bi-plus-circle' : (viewMode == 'edit' ? 'bi-pencil-square' : 'bi-eye')} me-2"></i>
                    Thông tin món ăn
                </h5>
            </div>
            <div class="card-body">
                <form action="menu-management" method="post">
                        <input type="hidden" name="action" value="${viewMode == 'edit' ? 'update' : 'create'}">
                        <c:if test="${viewMode == 'edit' or viewMode == 'view'}">
                            <input type="hidden" name="itemId" value="${menuItem.itemId}">
                        </c:if>
                    
                    <div class="row">
                        <!-- Left Column -->
                        <div class="col-lg-8">
                            <!-- Basic Information -->
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="bi bi-cup-hot text-primary me-1"></i> Tên món ăn *
                                </label>
                                <input type="text" 
                                       class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                       name="name" 
                                       value="${menuItem.name}" 
                                       ${viewMode == 'view' ? 'readonly' : ''} 
                                       required>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="bi bi-text-left text-primary me-1"></i> Mô tả
                                </label>
                                <textarea class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                          name="description" 
                                          rows="4" 
                                          ${viewMode == 'view' ? 'readonly' : ''}>${menuItem.description}</textarea>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="bi bi-tag text-primary me-1"></i> Danh mục *
                                        </label>
                                        <select class="form-select ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                                name="categoryId" 
                                                ${viewMode == 'view' ? 'disabled' : ''} 
                                                required>
                                            <option value="">Chọn danh mục</option>
                                            <c:forEach var="category" items="${categories}">
                                                <option value="${category.categoryId}" 
                                                        ${category.categoryId == menuItem.categoryId ? 'selected' : ''}>
                                                    ${category.categoryName}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="bi bi-currency-dollar text-primary me-1"></i> Giá (VNĐ) *
                                        </label>
                                        <input type="number" 
                                               class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                               name="basePrice" 
                                               value="${menuItem.basePrice}" 
                                               min="0" 
                                               step="1000" 
                                               ${viewMode == 'view' ? 'readonly' : ''} 
                                               required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="bi bi-clock text-primary me-1"></i> Thời gian chuẩn bị (phút)
                                        </label>
                                        <input type="number" 
                                               class="form-control ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                               name="preparationTime" 
                                               value="${menuItem.preparationTime}" 
                                               min="1" 
                                               ${viewMode == 'view' ? 'readonly' : ''}>
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="bi bi-check-circle text-primary me-1"></i> Trạng thái
                                        </label>
                                        <select class="form-select ${viewMode == 'view' ? 'readonly-field' : ''}" 
                                                name="availability" 
                                                ${viewMode == 'view' ? 'disabled' : ''}>
                                            <option value="AVAILABLE" ${menuItem.availability == 'AVAILABLE' ? 'selected' : ''}>Có sẵn</option>
                                            <option value="UNAVAILABLE" ${menuItem.availability == 'UNAVAILABLE' ? 'selected' : ''}>Hết hàng</option>
                                            <option value="DISCONTINUED" ${menuItem.availability == 'DISCONTINUED' ? 'selected' : ''}>Ngừng bán</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            
                            <c:if test="${viewMode != 'view'}">
                                <div class="form-group">
                                    <label class="form-label">
                                        <i class="bi bi-image text-primary me-1"></i> Hình ảnh (URL)
                                    </label>
                                    <input type="text" 
                                           class="form-control" 
                                           name="imageUrl"
                                           value="${menuItem.imageUrl}"
                                           placeholder="https://example.com/image.jpg">
                                    <small class="text-muted">Nhập URL hình ảnh món ăn</small>
                                </div>
                            </c:if>
                        </div>
                        
                        <!-- Right Column -->
                        <div class="col-lg-4">
                            <!-- Current Image -->
                            <c:if test="${not empty menuItem.imageUrl}">
                                <div class="form-group">
                                    <label class="form-label">
                                        <i class="bi bi-image text-primary me-1"></i> Hình ảnh hiện tại
                                    </label>
                                    <div class="text-center">
                                        <img src="${menuItem.imageUrl}" 
                                             alt="${menuItem.name}" 
                                             class="image-preview img-fluid">
                                    </div>
                                </div>
                            </c:if>
                            
                            <!-- Additional Info (View mode only) -->
                            <c:if test="${viewMode == 'view' and not empty menuItem}">
                                <div class="form-group">
                                    <label class="form-label">
                                        <i class="bi bi-info-circle text-primary me-1"></i> Thông tin bổ sung
                                    </label>
                                    <div>
                                        <c:if test="${not empty menuItem.createdBy}">
                                            <span class="info-badge">
                                                <i class="bi bi-person"></i> Tạo bởi: ${menuItem.createdBy}
                                            </span>
                                        </c:if>
                                        
                                        <span class="info-badge">
                                            <i class="bi bi-hash"></i> ID: ${menuItem.itemId}
                                        </span>
                                        
                                        <span class="info-badge">
                                            <i class="bi bi-toggle-${menuItem.active ? 'on' : 'off'}"></i> 
                                            ${menuItem.active ? 'Đang hoạt động' : 'Tạm dừng'}
                                        </span>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="action-buttons">
                        <c:if test="${viewMode != 'view'}">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi ${viewMode == 'create' ? 'bi-plus-circle' : 'bi-check-circle'}"></i>
                                ${viewMode == 'create' ? 'Thêm món' : 'Lưu thay đổi'}
                            </button>
                        </c:if>
                        
                        <c:if test="${viewMode == 'view' and sessionScope.user.roleName == 'Manager'}">
                            <a href="menu-management?action=edit&id=${menuItem.itemId}" class="btn btn-primary">
                                <i class="bi bi-pencil-square"></i> Chỉnh sửa
                            </a>
                            <button type="button" class="btn btn-danger" onclick="confirmDelete(${menuItem.itemId})">
                                <i class="bi bi-trash"></i> Xóa món
                            </button>
                        </c:if>
                        
                        <a href="menu-management" class="btn btn-secondary">
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

    function confirmDelete(itemId) {
        if (confirm('Bạn có chắc chắn muốn xóa món ăn này không?')) {
            window.location.href = 'menu-management?action=delete&id=' + itemId;
        }
    }
    
    // Auto-dismiss alerts after 5 seconds
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