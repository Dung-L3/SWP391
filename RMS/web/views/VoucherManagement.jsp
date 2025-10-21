<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    request.setAttribute("page", "voucher");
    request.setAttribute("overlayNav", false);
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<!-- Authentication check -->
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Quản lý Voucher | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

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

        .section { margin-top: var(--space-5); }
        .card { border: none; border-radius: var(--radius); background: var(--card); box-shadow: 0 8px 28px rgba(20, 24, 40, .08); overflow: hidden; }
        .card-header { background: linear-gradient(180deg, rgba(79,70,229,.06), rgba(79,70,229,0)); border-bottom: 1px solid var(--line); border-radius: var(--radius) var(--radius) 0 0; padding: var(--space-3) var(--space-4); }
        .card-body { padding: var(--space-4); }

        /* Tables */
        .table-tight td, .table-tight th { padding: .7rem .95rem; }
        .table thead th { font-weight: 600; color: var(--ink-700); border-bottom-color: var(--line); }
        .table-hover tbody tr:hover { background: rgba(203, 213, 225, .18); }

        /* Badges */
        .badge.bg-success{ background-color: var(--success) !important; }
        .badge.bg-warning{ background-color: var(--warning) !important; }
        .badge.bg-danger{ background-color: var(--danger) !important; }
        .badge.bg-secondary{ background-color: #cbd5e1 !important; color:#0f172a; }

        /* Buttons */
        .btn-outline-primary{ border-color: var(--primary-600); color: var(--primary-600); }
        .btn-outline-primary:hover{ background: var(--primary-600); color:#fff; }
        
        .voucher-code { 
            font-family: 'Courier New', monospace; 
            font-weight: bold; 
            font-size: 1.1rem;
            color: var(--primary);
        }
        
        .discount-badge {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-600) 100%);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-weight: 600;
        }
        
        .muted { color: var(--ink-500); }
    </style>
</head>

<body>

<!-- ===== Header ===== -->
<jsp:include page="/layouts/Header.jsp"/>

<c:set var="u" value="${sessionScope.user}"/>

<div class="app">

    <!-- ===== Sidebar ===== -->
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <!-- ===== Main content ===== -->
    <main class="content">

        <div class="page-header" style="margin-top: 50px;">
            <div>
                <h3><i class="bi bi-ticket-perforated me-2"></i>Quản lý Voucher</h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="<c:url value='/'/>">Trang chủ</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Voucher</li>
                    </ol>
                </nav>
            </div>
            <div class="d-none d-lg-block">
                <a href="<c:url value='/voucher-management?action=create'/>" class="btn btn-primary">
                    <i class="bi bi-plus-circle me-1"></i> Tạo voucher mới
                </a>
            </div>
            <button class="btn btn-outline-secondary d-lg-none" onclick="toggleSidebar()"><i class="bi bi-list"></i> Menu</button>
        </div>
        
        <!-- Mobile create button -->
        <div class="d-lg-none mb-3">
            <a href="<c:url value='/voucher-management?action=create'/>" class="btn btn-primary w-100">
                <i class="bi bi-plus-circle me-1"></i> Tạo voucher mới
            </a>
        </div>

        <!-- Success/Error Messages -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle me-2"></i>${sessionScope.successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${sessionScope.errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <!-- Search and Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="GET" action="<c:url value='/voucher-management'/>" class="row g-3">
                    <div class="col-md-5">
                        <label for="search" class="form-label">Tìm kiếm</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-search"></i></span>
                            <input type="text" class="form-control" id="search" name="search" 
                                   placeholder="Mã voucher hoặc mô tả..." value="${searchParam}">
                        </div>
                    </div>

                    <div class="col-md-3">
                        <label for="status" class="form-label">Trạng thái</label>
                        <select class="form-select" id="status" name="status">
                            <option value="">Tất cả</option>
                            <option value="ACTIVE" ${statusParam eq 'ACTIVE' ? 'selected' : ''}>Hoạt động</option>
                            <option value="INACTIVE" ${statusParam eq 'INACTIVE' ? 'selected' : ''}>Không hoạt động</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label for="sortBy" class="form-label">Sắp xếp</label>
                        <select class="form-select" id="sortBy" name="sortBy">
                            <option value="" ${empty sortByParam ? 'selected' : ''}>Mới nhất</option>
                            <option value="code_asc" ${sortByParam eq 'code_asc' ? 'selected' : ''}>Mã A-Z</option>
                            <option value="code_desc" ${sortByParam eq 'code_desc' ? 'selected' : ''}>Mã Z-A</option>
                            <option value="value_desc" ${sortByParam eq 'value_desc' ? 'selected' : ''}>Giá trị cao</option>
                            <option value="expiry" ${sortByParam eq 'expiry' ? 'selected' : ''}>Gần hết hạn</option>
                        </select>
                    </div>

                    <div class="col-md-1">
                        <label class="form-label">&nbsp;</label>
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-funnel"></i>
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Vouchers List -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="bi bi-ticket-perforated me-2"></i>
                    Danh sách voucher (${totalVouchers} voucher)
                </h5>
                <c:if test="${not empty searchParam or not empty statusParam}">
                    <a href="<c:url value='/voucher-management'/>" class="btn btn-sm btn-outline-secondary">
                        <i class="bi bi-x-circle me-1"></i>Xóa bộ lọc
                    </a>
                </c:if>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0 table-tight">
                        <thead class="table-light">
                            <tr>
                                <th>Mã voucher</th>
                                <th>Mô tả</th>
                                <th>Loại</th>
                                <th>Giá trị</th>
                                <th>Đơn tối thiểu</th>
                                <th>Hiệu lực</th>
                                <th>Đã dùng</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty vouchers}">
                                    <tr>
                                        <td colspan="9" class="text-center py-4">
                                            <i class="bi bi-inbox" style="font-size: 3rem; opacity: 0.3;"></i>
                                            <p class="mt-2 mb-0 text-muted">Chưa có voucher nào. Hãy tạo voucher mới!</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="v" items="${vouchers}">
                                        <tr>
                                            <td>
                                                <span class="voucher-code">${v.code}</span>
                                            </td>
                                            <td>${v.description}</td>
                                            <td>
                                                <span class="badge ${v.discountType eq 'PERCENT' ? 'bg-info' : 'bg-warning'} text-dark">
                                                    ${v.discountTypeDisplay}
                                                </span>
                                            </td>
                                            <td>
                                                <span class="discount-badge">${v.discountDisplay}</span>
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${v.minOrderTotal}" pattern="#,##0"/> đ
                                            </td>
                                            <td class="small">
                                                ${v.validityDisplay}
                                            </td>
                                            <td>
                                                <span class="badge ${v.remainingUses == 0 ? 'bg-danger' : (v.remainingUses < 10 ? 'bg-warning' : 'bg-success')}">
                                                    ${v.usageLimitDisplay}
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge ${v.statusBadgeClass}">
                                                    ${v.statusDisplay}
                                                </span>
                                            </td>
                                            <td>
                                                <div class="btn-group" role="group">
                                                    <a href="<c:url value='/voucher-management?action=view&id=${v.voucherId}'/>" 
                                                       class="btn btn-sm btn-outline-info" title="Xem chi tiết">
                                                        <i class="bi bi-eye"></i>
                                                    </a>
                                                    <a href="<c:url value='/voucher-management?action=edit&id=${v.voucherId}'/>" 
                                                       class="btn btn-sm btn-outline-warning" title="Chỉnh sửa">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>
                                                    <button type="button" class="btn btn-sm btn-outline-danger" 
                                                            title="Vô hiệu hóa" onclick="confirmDelete(${v.voucherId}, '${v.code}')">
                                                        <i class="bi bi-trash"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="card-footer">
                    <nav aria-label="Voucher pagination">
                        <ul class="pagination pagination-sm mb-0 justify-content-center">
                            <!-- Previous -->
                            <c:if test="${currentPage > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="<c:url value='/voucher-management'>
                                        <c:param name='page' value='${currentPage - 1}'/>
                                        <c:if test='${not empty searchParam}'><c:param name='search' value='${searchParam}'/></c:if>
                                        <c:if test='${not empty statusParam}'><c:param name='status' value='${statusParam}'/></c:if>
                                        <c:if test='${not empty sortByParam}'><c:param name='sortBy' value='${sortByParam}'/></c:if>
                                    </c:url>">
                                        <i class="bi bi-chevron-left"></i>
                                    </a>
                                </li>
                            </c:if>

                            <!-- Page numbers -->
                            <c:forEach begin="1" end="${totalPages}" var="pageNum">
                                <c:if test="${pageNum <= 3 or pageNum >= totalPages - 2 or (pageNum >= currentPage - 1 and pageNum <= currentPage + 1)}">
                                    <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="<c:url value='/voucher-management'>
                                            <c:param name='page' value='${pageNum}'/>
                                            <c:if test='${not empty searchParam}'><c:param name='search' value='${searchParam}'/></c:if>
                                            <c:if test='${not empty statusParam}'><c:param name='status' value='${statusParam}'/></c:if>
                                            <c:if test='${not empty sortByParam}'><c:param name='sortBy' value='${sortByParam}'/></c:if>
                                        </c:url>">${pageNum}</a>
                                    </li>
                                </c:if>
                            </c:forEach>

                            <!-- Next -->
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-item">
                                    <a class="page-link" href="<c:url value='/voucher-management'>
                                        <c:param name='page' value='${currentPage + 1}'/>
                                        <c:if test='${not empty searchParam}'><c:param name='search' value='${searchParam}'/></c:if>
                                        <c:if test='${not empty statusParam}'><c:param name='status' value='${statusParam}'/></c:if>
                                        <c:if test='${not empty sortByParam}'><c:param name='sortBy' value='${sortByParam}'/></c:if>
                                    </c:url>">
                                        <i class="bi bi-chevron-right"></i>
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </nav>
                </div>
            </c:if>
        </div>

    </main>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="deleteModalLabel">Xác nhận vô hiệu hóa</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn vô hiệu hóa voucher <strong class="voucher-code" id="voucherCodeToDelete"></strong>?</p>
                <p class="text-muted small">Voucher sẽ không thể sử dụng nữa nhưng lịch sử vẫn được giữ lại.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <form id="deleteForm" method="POST" action="<c:url value='/voucher-management'/>" style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="voucherId" id="voucherIdToDelete">
                    <button type="submit" class="btn btn-danger">Vô hiệu hóa</button>
                </form>
            </div>
        </div>
    </div>
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

    function confirmDelete(voucherId, voucherCode) {
        document.getElementById('voucherIdToDelete').value = voucherId;
        document.getElementById('voucherCodeToDelete').textContent = voucherCode;
        new bootstrap.Modal(document.getElementById('deleteModal')).show();
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

