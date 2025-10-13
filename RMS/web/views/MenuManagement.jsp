<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    request.setAttribute("page", "menu");
    request.setAttribute("overlayNav", false);
    
    // Set UTF-8 encoding for request
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
    <title>Quản lý Menu | RMSG4</title>
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
        .menu-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
            margin-top: 80px;
            margin-bottom: 2rem;
        }

        .search-filters {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .menu-card {
            border: 1px solid #e0e0e0;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            transition: all 0.3s ease;
            margin-bottom: 1.5rem;
            background: white;
        }

        .menu-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
            border-color: #4CAF50;
        }

        .menu-card .card-body {
            padding: 1.25rem;
        }

        .menu-image {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 8px;
        }

        .price-tag {
            font-size: 1.2rem;
            font-weight: bold;
            color: #28a745;
        }

        .status-badge {
            font-size: 0.8rem;
            padding: 0.25rem 0.5rem;
        }

        .pagination-custom .page-link {
            border-radius: 50px;
            margin: 0 2px;
            border: none;
            color: #667eea;
        }

        .pagination-custom .page-link:hover {
            background-color: #667eea;
            color: white;
        }

        .pagination-custom .page-item.active .page-link {
            background-color: #667eea;
            border-color: #667eea;
        }

        .btn-action {
            padding: 0.25rem 0.5rem;
            font-size: 0.8rem;
            border-radius: 4px;
            margin: 0 2px;
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #6c757d;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }
    </style>
</head>

<body>
    <div class="container-xxl bg-white p-0">
        <!-- Header -->
        <jsp:include page="/layouts/Header.jsp" />

        <!-- Page Header -->
        <div class="menu-header">
            <div class="container">
                <div class="row">
                    <div class="col-lg-12">
                        <h1 class="display-4 mb-3">
                            <i class="bi bi-journal-bookmark me-3"></i>Quản lý Menu
                        </h1>
                        <p class="lead mb-0">Quản lý món ăn, thực đơn và danh mục</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="container-fluid py-5">
            <div class="container">
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

                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Search and Filters -->
                <div class="search-filters">
                    <form method="GET" action="<c:url value='/menu-management'/>" class="row g-3">
                        <div class="col-md-4">
                            <label for="search" class="form-label">Tìm kiếm</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-search"></i></span>
                                <input type="text" class="form-control" id="search" name="search" 
                                       placeholder="Tên món ăn..." value="${searchParam}">
                            </div>
                        </div>

                        <div class="col-md-3">
                            <label for="category" class="form-label">Danh mục</label>
                            <select class="form-select" id="category" name="category">
                                <option value="">Tất cả danh mục</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}" 
                                            ${categoryParam eq cat.categoryId.toString() ? 'selected' : ''}>
                                        ${cat.categoryName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label for="availability" class="form-label">Trạng thái</label>
                            <select class="form-select" id="availability" name="availability">
                                <option value="">Tất cả</option>
                                <option value="AVAILABLE" ${availabilityParam eq 'AVAILABLE' ? 'selected' : ''}>Có sẵn</option>
                                <option value="OUT_OF_STOCK" ${availabilityParam eq 'OUT_OF_STOCK' ? 'selected' : ''}>Hết hàng</option>
                                <option value="DISCONTINUED" ${availabilityParam eq 'DISCONTINUED' ? 'selected' : ''}>Ngừng bán</option>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label for="sortBy" class="form-label">Sắp xếp</label>
                            <select class="form-select" id="sortBy" name="sortBy">
                                <option value="" ${empty sortByParam ? 'selected' : ''}>Mặc định</option>
                                <option value="name_asc" ${sortByParam eq 'name_asc' ? 'selected' : ''}>Tên A-Z</option>
                                <option value="name_desc" ${sortByParam eq 'name_desc' ? 'selected' : ''}>Tên Z-A</option>
                                <option value="price_asc" ${sortByParam eq 'price_asc' ? 'selected' : ''}>Giá tăng</option>
                                <option value="price_desc" ${sortByParam eq 'price_desc' ? 'selected' : ''}>Giá giảm</option>
                                <option value="category" ${sortByParam eq 'category' ? 'selected' : ''}>Theo danh mục</option>
                            </select>
                        </div>

                        <div class="col-md-1">
                            <label class="form-label">&nbsp;</label>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-funnel"></i>
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Action Bar -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h5 class="mb-0">
                            Tìm thấy ${totalItems} món ăn
                            <c:if test="${not empty searchParam or not empty categoryParam or not empty availabilityParam}">
                                <a href="<c:url value='/menu-management'/>" class="btn btn-sm btn-outline-secondary ms-2">
                                    <i class="bi bi-x-circle me-1"></i>Xóa bộ lọc
                                </a>
                            </c:if>
                        </h5>
                    </div>
                    <div>
                        <c:if test="${sessionScope.user.roleName eq 'Manager'}">
                            <a href="<c:url value='/menu-management?action=create'/>" class="btn btn-success">
                                <i class="bi bi-plus-circle me-2"></i>Thêm món mới
                            </a>
                        </c:if>
                    </div>
                </div>

                <!-- Menu Items List -->
                <c:choose>
                    <c:when test="${empty menuItems}">
                        <div class="empty-state">
                            <i class="bi bi-journal-x"></i>
                            <h4>Không tìm thấy món ăn nào</h4>
                            <p>Thử thay đổi bộ lọc hoặc thêm món ăn mới.</p>
                            <c:if test="${sessionScope.user.roleName eq 'Manager'}">
                                <a href="<c:url value='/menu-management?action=create'/>" class="btn btn-primary">
                                    <i class="bi bi-plus-circle me-2"></i>Thêm món đầu tiên
                                </a>
                            </c:if>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="row g-4">
                            <c:forEach var="item" items="${menuItems}">
                                <div class="col-lg-6 col-xl-4 mb-3">
                                    <div class="card menu-card h-100">
                                        <div class="card-body">
                                            <div class="d-flex align-items-start">
                                                <div class="flex-shrink-0 me-3">
                                                    <c:choose>
                                                        <c:when test="${not empty item.imageUrl}">
                                                            <img src="${item.imageUrl}" 
                                                                 alt="${item.name}" 
                                                                 class="menu-image"
                                                                 onerror="this.src='<c:url value='/img/default-avatar.svg'/>'">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src="<c:url value='/img/default-avatar.svg'/>" 
                                                                 alt="${item.name}" 
                                                                 class="menu-image">
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="flex-grow-1">
                                                    <h6 class="card-title mb-1">${item.name}</h6>
                                                    <p class="text-muted small mb-2">${item.categoryName}</p>
                                                    <p class="card-text small text-truncate" style="max-width: 200px;">
                                                        ${item.description}
                                                    </p>
                                                    <div class="d-flex justify-content-between align-items-center">
                                                        <span class="price-tag">${item.formattedPrice}</span>
                                                        <span class="badge ${item.statusBadgeClass} status-badge">
                                                            ${item.availabilityDisplay}
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="mt-3 pt-3 border-top">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <small class="text-muted">
                                                        <i class="bi bi-clock me-1"></i>${item.preparationTime} phút
                                                    </small>
                                                    <div class="btn-group" role="group">
                                                        <a href="<c:url value='/menu-management?action=view&id=${item.itemId}'/>" 
                                                           class="btn btn-outline-info btn-action" title="Xem chi tiết">
                                                            <i class="bi bi-eye"></i>
                                                        </a>
                                                        <c:if test="${sessionScope.user.roleName eq 'Manager'}">
                                                            <a href="<c:url value='/menu-management?action=edit&id=${item.itemId}'/>" 
                                                               class="btn btn-outline-warning btn-action" title="Chỉnh sửa">
                                                                <i class="bi bi-pencil"></i>
                                                            </a>
                                                            <button type="button" class="btn btn-outline-danger btn-action" 
                                                                    title="Xóa" onclick="confirmDelete(${item.itemId}, '${item.name}')">
                                                                <i class="bi bi-trash"></i>
                                                            </button>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <!-- Pagination -->
                        <c:if test="${totalPages > 1}">
                            <nav aria-label="Menu pagination" class="mt-4">
                                <ul class="pagination pagination-custom justify-content-center">
                                    <!-- Previous -->
                                    <c:if test="${currentPage > 1}">
                                        <li class="page-item">
                                            <a class="page-link" href="<c:url value='/menu-management'>
                                                <c:param name='page' value='${currentPage - 1}'/>
                                                <c:if test='${not empty searchParam}'><c:param name='search' value='${searchParam}'/></c:if>
                                                <c:if test='${not empty categoryParam}'><c:param name='category' value='${categoryParam}'/></c:if>
                                                <c:if test='${not empty availabilityParam}'><c:param name='availability' value='${availabilityParam}'/></c:if>
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
                                                <a class="page-link" href="<c:url value='/menu-management'>
                                                    <c:param name='page' value='${pageNum}'/>
                                                    <c:if test='${not empty searchParam}'><c:param name='search' value='${searchParam}'/></c:if>
                                                    <c:if test='${not empty categoryParam}'><c:param name='category' value='${categoryParam}'/></c:if>
                                                    <c:if test='${not empty availabilityParam}'><c:param name='availability' value='${availabilityParam}'/></c:if>
                                                    <c:if test='${not empty sortByParam}'><c:param name='sortBy' value='${sortByParam}'/></c:if>
                                                </c:url>">${pageNum}</a>
                                            </li>
                                        </c:if>
                                        <c:if test="${pageNum == 3 and currentPage > 5}">
                                            <li class="page-item disabled"><span class="page-link">...</span></li>
                                        </c:if>
                                        <c:if test="${pageNum == totalPages - 2 and currentPage < totalPages - 4}">
                                            <li class="page-item disabled"><span class="page-link">...</span></li>
                                        </c:if>
                                    </c:forEach>

                                    <!-- Next -->
                                    <c:if test="${currentPage < totalPages}">
                                        <li class="page-item">
                                            <a class="page-link" href="<c:url value='/menu-management'>
                                                <c:param name='page' value='${currentPage + 1}'/>
                                                <c:if test='${not empty searchParam}'><c:param name='search' value='${searchParam}'/></c:if>
                                                <c:if test='${not empty categoryParam}'><c:param name='category' value='${categoryParam}'/></c:if>
                                                <c:if test='${not empty availabilityParam}'><c:param name='availability' value='${availabilityParam}'/></c:if>
                                                <c:if test='${not empty sortByParam}'><c:param name='sortBy' value='${sortByParam}'/></c:if>
                                            </c:url>">
                                                <i class="bi bi-chevron-right"></i>
                                            </a>
                                        </li>
                                    </c:if>
                                </ul>
                            </nav>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Footer -->
        <jsp:include page="/layouts/Footer.jsp" />
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="deleteModalLabel">Xác nhận xóa</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Bạn có chắc chắn muốn xóa món ăn <strong id="itemNameToDelete"></strong>?</p>
                    <p class="text-muted small">Hành động này sẽ ẩn món ăn khỏi menu nhưng không xóa vĩnh viễn.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <form id="deleteForm" method="POST" action="<c:url value='/menu-management'/>" style="display: inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="itemId" id="itemIdToDelete">
                        <button type="submit" class="btn btn-danger">Xóa</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function confirmDelete(itemId, itemName) {
            document.getElementById('itemIdToDelete').value = itemId;
            document.getElementById('itemNameToDelete').textContent = itemName;
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
