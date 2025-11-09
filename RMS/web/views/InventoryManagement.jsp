<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "inventory");
    request.setAttribute("overlayNav", false);
%>

<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Quản lý Kho | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <!-- Icons / Bootstrap -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>

    <!-- Base site styles -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <style>
        :root {
            --bg-app:#f5f6fa;
            --bg-grad-1:rgba(88,80,200,.08);
            --bg-grad-2:rgba(254,161,22,.06);

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.12);
            --accent-border:rgba(254,161,22,.45);

            --brand:#4f46e5;
            --success:#16a34a;
            --warning:#f59e0b;
            --danger:#dc2626;

            --line:#e5e7eb;
            --radius-lg:20px;
            --radius-md:12px;
            --radius-sm:6px;
            --sidebar-width:280px;
        }

        body{
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            color:var(--ink-900);
            font-family:"Heebo", system-ui, -apple-system, BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",sans-serif;
        }

        .app-shell{
            display:grid;
            grid-template-columns:var(--sidebar-width) 1fr;
            min-height:100vh;
        }
        @media(max-width:992px){
            .app-shell{grid-template-columns:1fr;}
            #sidebar{
                position:fixed;inset:0 30% 0 0;transform:translateX(-100%);
                transition:transform .2s ease;z-index:1040;max-width:var(--sidebar-width);
                box-shadow:24px 0 60px rgba(0,0,0,.7);background:#1f2535;
            }
            #sidebar.open{transform:translateX(0);}
        }

        main.main-pane{padding:28px 32px 44px;}

        .pos-topbar{
            background:linear-gradient(135deg,#1b1e2c 0%,#2b2f46 60%,#1c1f30 100%);
            border-radius:var(--radius-md);border:1px solid rgba(255,255,255,.07);
            box-shadow:0 32px 64px rgba(0,0,0,.6);color:#fff;padding:16px 20px;
            margin-top:58px;margin-bottom:24px;
            display:flex;flex-wrap:wrap;justify-content:space-between;align-items:flex-start;
        }

        .pos-left .title-row{
            display:flex;align-items:center;gap:.6rem;
            font-weight:600;font-size:1rem;line-height:1.35;color:#fff;
        }
        .pos-left .title-row i{color:var(--accent);font-size:1.1rem;}
        .pos-left .sub{margin-top:4px;font-size:.8rem;color:var(--ink-400);}

        .pos-right{display:flex;align-items:center;flex-wrap:wrap;gap:.75rem;color:#fff;}

        .user-chip{
            display:flex;align-items:center;gap:.5rem;
            background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.18);
            border-radius:var(--radius-md);padding:6px 10px;
            font-size:.8rem;font-weight:500;line-height:1.2;color:#fff;
        }
        .user-chip .role-badge{
            background:var(--accent);color:#1e1e2f;border-radius:var(--radius-sm);
            padding:2px 6px;font-size:.7rem;font-weight:600;line-height:1.2;
        }

        .filters-card{
            position:relative;background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border:1px solid rgba(99,102,241,.25);border-top:4px solid var(--accent);
            border-radius:var(--radius-lg);box-shadow:0 10px 40px rgba(0,0,0,.08);
            padding:1rem 1.25rem 1.25rem;margin-bottom:1.5rem;transition:all .25s ease;
        }

        .result-bar{
            display:flex;flex-wrap:wrap;justify-content:space-between;
            align-items:flex-start;row-gap:.75rem;margin-bottom:1.5rem;
        }
        .result-left{font-size:.9rem;font-weight:500;color:var(--ink-900);}

        .btn-add-item{
            background:linear-gradient(135deg,#16a34a,#0f766e);color:#fff;
            font-weight:600;border:none;border-radius:var(--radius-sm);
            box-shadow:0 4px 20px rgba(22,163,74,.3);
            display:inline-flex;align-items:center;gap:.5rem;padding:.5rem .75rem;
        }
        .btn-add-item:hover{
            box-shadow:0 6px 25px rgba(22,163,74,.4);transform:translateY(-1px);color:#fff;
        }

        .inventory-table{width:100%;background:#fff;border-radius:var(--radius-md);overflow:hidden;}
        .inventory-table thead{background:linear-gradient(135deg,#4f46e5,#6366f1);color:#fff;}
        .inventory-table th{padding:.75rem 1rem;font-size:.85rem;font-weight:600;}
        .inventory-table td{padding:.75rem 1rem;font-size:.85rem;border-bottom:1px solid var(--line);}
        .inventory-table tbody tr:hover{background:#f9fafb;}

        .stock-badge{
            font-size:.7rem;font-weight:600;padding:.3rem .5rem;
            border-radius:var(--radius-sm);white-space:nowrap;
        }

        .btn-action{
            border-radius:var(--radius-sm);font-size:.75rem;
            line-height:1.2;padding:.4rem .5rem;
        }

        .low-stock-alert{
            background:linear-gradient(to right,#fef3c7,#fde68a);
            border-left:4px solid var(--warning);border-radius:var(--radius-md);
            padding:1rem;margin-bottom:1.5rem;
        }
    </style>
</head>

<body>
<jsp:include page="/layouts/Header.jsp"/>

<div class="app-shell">
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <main class="main-pane">
        <header class="pos-topbar">
            <div class="pos-left">
                <div class="title-row">
                    <i class="bi bi-box-seam"></i>
                    <span>Quản lý Kho</span>
                </div>
                <div class="sub">
                    Quản lý nguyên liệu · Tồn kho · Nhập/Xuất
                </div>
            </div>

            <div class="pos-right">
                <div class="user-chip">
                    <i class="bi bi-person-badge"></i>
                    <span>${sessionScope.user.fullName}</span>
                    <span class="role-badge">${sessionScope.user.roleName}</span>
                </div>
            </div>
        </header>

        <!-- FLASH MESSAGE -->
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

        <!-- LOW STOCK ALERT -->
        <c:if test="${not empty lowStockItems && fn:length(lowStockItems) > 0}">
            <div class="low-stock-alert">
                <h6 class="mb-2"><i class="bi bi-exclamation-triangle-fill text-warning me-2"></i>Cảnh báo: ${fn:length(lowStockItems)} nguyên liệu sắp hết</h6>
                <p class="mb-0 small">
                    <c:forEach var="item" items="${lowStockItems}" varStatus="status">
                        <strong>${item.itemName}</strong> (còn ${item.currentStock} ${item.uom})<c:if test="${!status.last}">, </c:if>
                    </c:forEach>
                </p>
            </div>
        </c:if>

        <!-- FILTERS -->
        <section class="filters-card">
            <form method="GET" action="${pageContext.request.contextPath}/inventory-management" class="row g-3">
                <div class="col-md-4">
                    <label for="search" class="form-label">Tìm kiếm</label>
                    <input type="text" class="form-control" id="search" name="search"
                           placeholder="Tên nguyên liệu..." value="${searchParam}">
                </div>

                <div class="col-md-3">
                    <label for="category" class="form-label">Loại</label>
                    <select class="form-select" id="category" name="category">
                        <option value="">Tất cả loại</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat}" <c:if test="${categoryParam == cat}">selected</c:if>>${cat}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-2">
                    <label for="status" class="form-label">Trạng thái</label>
                    <select class="form-select" id="status" name="status">
                        <option value="">Tất cả</option>
                        <option value="ACTIVE" <c:if test="${statusParam == 'ACTIVE'}">selected</c:if>>Đang dùng</option>
                        <option value="INACTIVE" <c:if test="${statusParam == 'INACTIVE'}">selected</c:if>>Ngừng dùng</option>
                    </select>
                </div>

                <div class="col-md-3 d-flex align-items-end gap-2">
                    <button type="submit" class="btn btn-primary flex-grow-1">
                        <i class="bi bi-funnel"></i> Lọc
                    </button>
                    <a href="${pageContext.request.contextPath}/inventory-management" class="btn btn-outline-secondary">
                        <i class="bi bi-x-circle"></i>
                    </a>
                </div>
            </form>
        </section>

        <!-- RESULT BAR -->
        <section class="result-bar">
            <div class="result-left">
                <span>Tìm thấy ${totalItems} nguyên liệu</span>
            </div>

            <div class="result-right">
                <c:if test="${sessionScope.user.roleName eq 'Manager'}">
                    <a href="${pageContext.request.contextPath}/inventory-management?action=create" class="btn-add-item">
                        <i class="bi bi-plus-circle"></i>
                        <span>Thêm nguyên liệu</span>
                    </a>
                </c:if>
            </div>
        </section>

        <!-- INVENTORY TABLE -->
        <div class="table-responsive">
            <table class="inventory-table table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tên nguyên liệu</th>
                        <th>Loại</th>
                        <th>Tồn kho</th>
                        <th>Tối thiểu</th>
                        <th>Đơn giá</th>
                        <th>Nhà cung cấp</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty inventoryItems}">
                            <tr>
                                <td colspan="9" class="text-center py-4">
                                    <i class="bi bi-inbox text-muted" style="font-size:2rem;"></i>
                                    <p class="text-muted mt-2">Chưa có nguyên liệu nào</p>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${inventoryItems}">
                                <tr>
                                    <td>#${item.itemId}</td>
                                    <td><strong>${item.itemName}</strong></td>
                                    <td>${item.category}</td>
                                    <td>
                                        <strong>${item.currentStock}</strong> ${item.uom}
                                        <c:if test="${item.lowStock}">
                                            <i class="bi bi-exclamation-triangle-fill text-warning ms-1" title="Sắp hết"></i>
                                        </c:if>
                                    </td>
                                    <td>${item.minimumStock} ${item.uom}</td>
                                    <td><fmt:formatNumber value="${item.unitCost}" type="currency" currencySymbol="₫"/></td>
                                    <td>${item.supplierName != null ? item.supplierName : '-'}</td>
                                    <td>
                                        <span class="stock-badge ${item.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">
                                            ${item.status == 'ACTIVE' ? 'Đang dùng' : 'Ngừng dùng'}
                                        </span>
                                        <c:if test="${item.lowStock}">
                                            <span class="stock-badge ${item.stockStatusClass}">
                                                ${item.stockStatusDisplay}
                                            </span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <div class="d-flex gap-1">
                                            <a href="${pageContext.request.contextPath}/inventory-management?action=view&id=${item.itemId}"
                                               class="btn btn-outline-info btn-action" title="Xem">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                            
                                            <c:if test="${sessionScope.user.roleName eq 'Manager'}">
                                                <a href="${pageContext.request.contextPath}/inventory-management?action=edit&id=${item.itemId}"
                                                   class="btn btn-outline-warning btn-action" title="Sửa">
                                                    <i class="bi bi-pencil"></i>
                                                </a>
                                                
                                                <button type="button" class="btn btn-outline-danger btn-action"
                                                        title="Xóa" onclick="confirmDelete(${item.itemId}, '${fn:escapeXml(item.itemName)}')">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <!-- PAGINATION -->
        <c:if test="${totalPages > 1}">
            <nav class="mt-4">
                <ul class="pagination justify-content-center">
                    <c:if test="${currentPage > 1}">
                        <li class="page-item">
                            <a class="page-link" href="?page=${currentPage-1}<c:if test='${not empty searchParam}'>&search=${searchParam}</c:if><c:if test='${not empty categoryParam}'>&category=${categoryParam}</c:if>">
                                <i class="bi bi-chevron-left"></i>
                            </a>
                        </li>
                    </c:if>

                    <c:forEach begin="1" end="${totalPages}" var="pageNum">
                        <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                            <a class="page-link" href="?page=${pageNum}<c:if test='${not empty searchParam}'>&search=${searchParam}</c:if><c:if test='${not empty categoryParam}'>&category=${categoryParam}</c:if>">
                                ${pageNum}
                            </a>
                        </li>
                    </c:forEach>

                    <c:if test="${currentPage < totalPages}">
                        <li class="page-item">
                            <a class="page-link" href="?page=${currentPage+1}<c:if test='${not empty searchParam}'>&search=${searchParam}</c:if><c:if test='${not empty categoryParam}'>&category=${categoryParam}</c:if>">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>
                    </c:if>
                </ul>
            </nav>
        </c:if>

    </main>
</div>

<jsp:include page="/layouts/Footer.jsp"/>

<!-- Delete Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Xác nhận xóa</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa nguyên liệu <strong id="itemNameToDelete"></strong>?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <form id="deleteForm" method="POST" action="${pageContext.request.contextPath}/inventory-management" style="display:inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="itemId" id="itemIdToDelete">
                    <button type="submit" class="btn btn-danger">Xóa</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function confirmDelete(itemId, itemName){
    document.getElementById('itemIdToDelete').value = itemId;
    document.getElementById('itemNameToDelete').textContent = itemName;
    var modal = new bootstrap.Modal(document.getElementById('deleteModal'));
    modal.show();
}

setTimeout(function(){
    var alerts = document.querySelectorAll('.alert');
    alerts.forEach(function(alert){
        try{
            var bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }catch(e){}
    });
}, 5000);
</script>
</body>
</html>

