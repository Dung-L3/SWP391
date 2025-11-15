<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="Models.DiningTable"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="page" value="table-management" scope="request"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý bàn · RMS POS</title>

    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <!-- Icons / Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>
    
    <!-- global site css -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <style>
        :root {
            --bg-app: #f5f6fa;
            --bg-grad-1: rgba(88, 80, 200, 0.08);
            --bg-grad-2: rgba(254, 161, 22, 0.06);
            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --accent:#FEA116;
            --success:#16a34a;
            --danger:#dc2626;
            --line:#e5e7eb;
            --radius-lg:20px;
            --radius-md:14px;
            --radius-sm:6px;
        }

        body {
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            color: var(--ink-900);
            font-family: "Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
            min-height:100vh;
        }

        .app-shell{
            display:grid;
            grid-template-columns: 280px 1fr;
            min-height:100vh;
        }
        @media(max-width:992px){
            .app-shell{
                grid-template-columns:1fr;
            }
            #sidebar{
                position:fixed;
                inset:0 30% 0 0;
                max-width:280px;
                box-shadow:24px 0 60px rgba(0,0,0,.7);
                background:#000;
                transform:translateX(-100%);
                transition:transform .2s ease;
                z-index:1040;
            }
            #sidebar.open{transform:translateX(0);}
        }

        main.main-pane{
            padding:28px 32px 44px;
        }

        .table-card{
            background:#ffffff;
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:0 18px 40px rgba(15,23,42,.10);
            overflow:hidden;
        }
        .table-header{
            padding:.75rem 1rem;
            display:flex;
            justify-content:space-between;
            align-items:center;
            border-bottom:1px solid var(--line);
        }
        .table-header h6{
            margin:0;
            font-weight:600;
            font-size:.95rem;
            display:flex;
            align-items:center;
            gap:.5rem;
        }
        .table-header h6 i{
            color:var(--accent);
        }

        table.table-management{
            margin-bottom:0;
        }
        .table-management thead th{
            background:#f9fafb;
            font-size:.75rem;
            text-transform:uppercase;
            letter-spacing:.03em;
            color:var(--ink-500);
            border-bottom:1px solid var(--line);
            white-space:nowrap;
        }
        .table-management tbody td{
            vertical-align:middle;
            font-size:.84rem;
            color:var(--ink-700);
        }
        .table-management tbody tr:hover{
            background:#f1f5f9;
        }

        .btn-add-table{
            background:var(--accent);
            border:none;
            color:#1e1e2f;
            font-weight:600;
            border-radius:var(--radius-sm);
            padding:.55rem .85rem;
            box-shadow:0 16px 30px rgba(254,161,22,.3);
            transition:all .2s ease;
            font-size:.85rem;
        }
        .btn-add-table:hover{
            filter:brightness(1.05);
            box-shadow:0 20px 40px rgba(254,161,22,.45);
        }

        .badge-status{
            padding:.25rem .6rem;
            border-radius:999px;
            font-size:.7rem;
            font-weight:600;
            text-transform:uppercase;
            letter-spacing:.03em;
        }
        .badge-status.vacant{
            background:#dcfce7;
            color:#16a34a;
        }
        .badge-status.occupied, .badge-status.seated, .badge-status.in_use{
            background:#dbeafe;
            color:#2563eb;
        }
        .badge-status.cleaning{
            background:#fef3c7;
            color:#d97706;
        }
        .badge-status.out_of_service{
            background:#fee2e2;
            color:#dc2626;
        }

        .text-soft{color:var(--ink-500);}

        /* Filter card */
        .filter-card{
            background:#ffffff;
            border-radius:var(--radius-md);
            border:1px solid var(--line);
            padding:.75rem 1rem;
            margin-bottom:1rem;
        }
        .filter-card .form-control,
        .filter-card .form-select{
            border-radius:10px;
            border:1.5px solid #e2e8f0;
            background:#fff;
            transition:all .25s ease;
            font-size:.9rem;
        }
        .filter-card .form-control:focus,
        .filter-card .form-select:focus{
            border-color:var(--accent);
            box-shadow:0 0 0 .25rem rgba(254,161,22,.25);
            background:#fffefc;
        }
    </style>
</head>

<body>

<jsp:include page="/layouts/Header.jsp"/>

<div class="app-shell">
    <aside id="sidebar" class="bg-dark text-white">
        <jsp:include page="../layouts/sidebar.jsp"/>
    </aside>

    <main class="main-pane">
        <!-- Topbar -->
        <header class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="mb-1" style="font-weight:700;color:var(--ink-900);">Quản lý bàn</h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="<c:url value='/admin'/>">Dashboard</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Quản lý bàn</li>
                    </ol>
                </nav>
            </div>
            <div>
                <a href="<c:url value='/table-management?action=add'/>" class="btn btn-add-table">
                    <i class="fa-solid fa-plus me-1"></i> Thêm bàn
                </a>
            </div>
        </header>

        <!-- Alert -->
        <c:if test="${not empty param.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i>${param.success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i>${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Filter -->
        <c:if test="${empty action || action == 'list'}">
        <div class="card mb-3" style="border-radius:var(--radius-md); border:1px solid var(--line);">
            <div class="card-body p-3">
                <form class="row g-2 align-items-end" method="get" action="<c:url value='/table-management'/>" id="tableFilterForm">
                    <div class="col-md-5">
                        <label class="form-label small text-soft fw-semibold">Tìm kiếm theo tên bàn</label>
                        <input type="text"
                               class="form-control"
                               name="q"
                               value="${q}"
                               placeholder="Nhập số bàn hoặc tên bàn..."/>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small text-soft fw-semibold">Khu vực</label>
                        <select class="form-select" name="areaId" onchange="document.getElementById('tableFilterForm').submit()">
                            <option value="">Tất cả khu vực</option>
                            <c:forEach var="area" items="${areas}">
                                <option value="${area.areaId}" ${areaId == area.areaId ? 'selected' : ''}>${area.areaName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3 text-md-end text-start mt-3 mt-md-0">
                        <button type="submit" class="btn btn-outline-primary me-2">
                            <i class="fa-solid fa-search me-1"></i> Tìm kiếm
                        </button>
                        <a href="<c:url value='/table-management'/>" class="btn btn-outline-secondary">
                            <i class="fa-solid fa-xmark me-1"></i> Xóa bộ lọc
                        </a>
                    </div>
                </form>
            </div>
        </div>
        </c:if>

        <!-- Table List -->
        <c:set var="action" value="${param.action}"/>
        <c:if test="${empty action || action == 'list'}">
        <div class="table-card">
            <div class="table-header">
                <h6>
                    <i class="bi bi-table"></i>
                    Danh sách bàn
                </h6>
                <span class="text-soft small">
                    Tổng số: <strong>${not empty tables ? tables.size() : 0}</strong> bàn
                </span>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle table-management">
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Số bàn</th>
                        <th>Khu vực</th>
                        <th>Sức chứa</th>
                        <th>Loại bàn</th>
                        <th>Trạng thái</th>
                        <th>Vị trí</th>
                        <th class="text-end">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty tables && !tables.isEmpty()}">
                            <c:forEach var="table" items="${tables}" varStatus="loop">
                                <tr>
                                    <td>${loop.index + 1}</td>
                                    <td><strong>${table.tableNumber}</strong></td>
                                    <td>${not empty table.areaName ? table.areaName : '—'}</td>
                                    <td>${table.capacity} người</td>
                                    <td>
                                        <span class="badge bg-secondary">${table.tableType}</span>
                                    </td>
                                    <td>
                                        <span class="badge-status ${fn:replace(fn:toLowerCase(table.status), '_', '-')}">
                                            ${table.status}
                                        </span>
                                    </td>
                                    <td class="text-soft">${not empty table.location ? table.location : '—'}</td>
                                    <td class="text-end">
                                        <div class="btn-group" role="group">
                                            <a href="<c:url value='/table-management?action=edit&id=${table.tableId}'/>"
                                               class="btn btn-sm btn-outline-warning">
                                                <i class="fa-solid fa-pen"></i>
                                            </a>
                                            <button class="btn btn-sm btn-outline-danger"
                                                    onclick="confirmDelete(${table.tableId}, '${table.tableNumber}')">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="8" class="text-center py-4 text-soft">
                                    <i class="bi bi-inbox fs-3 d-block mb-2"></i>
                                    Chưa có bàn nào
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
        </c:if>

        <!-- Add/Edit Form -->
        <c:if test="${action == 'add' || action == 'edit'}">
        <div class="table-card">
            <div class="table-header">
                <h6>
                    <i class="bi bi-${action == 'add' ? 'plus-circle' : 'pencil-square'}"></i>
                    ${action == 'add' ? 'Thêm bàn mới' : 'Sửa thông tin bàn'}
                </h6>
                <a href="<c:url value='/table-management'/>" class="btn btn-sm btn-outline-secondary">
                    <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                </a>
            </div>

            <div class="p-4">
                <form method="POST" action="<c:url value='/table-management'/>">
                    <input type="hidden" name="action" value="${action == 'add' ? 'create' : 'update'}"/>
                    <c:if test="${action == 'edit' && not empty table}">
                        <input type="hidden" name="tableId" value="${table.tableId}"/>
                    </c:if>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Số bàn <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="tableNumber" 
                                   value="${table.tableNumber}" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Sức chứa (người) <span class="text-danger">*</span></label>
                            <select class="form-select" name="capacity" required>
                                <option value="">-- Chọn sức chứa --</option>
                                <option value="2" ${table.capacity == 2 ? 'selected' : ''}>2 người</option>
                                <option value="4" ${table.capacity == 4 ? 'selected' : ''}>4 người</option>
                                <option value="6" ${table.capacity == 6 ? 'selected' : ''}>6 người</option>
                                <option value="8" ${table.capacity == 8 ? 'selected' : ''}>8 người</option>
                                <option value="10" ${table.capacity == 10 ? 'selected' : ''}>10 người</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Khu vực</label>
                            <select class="form-select" name="areaId">
                                <option value="">-- Chọn khu vực --</option>
                                <c:forEach var="area" items="${areas}">
                                    <option value="${area.areaId}" 
                                            ${table.areaId == area.areaId ? 'selected' : ''}>
                                        ${area.areaName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Loại bàn</label>
                            <select class="form-select" name="tableType">
                                <option value="REGULAR" ${table.tableType == 'REGULAR' ? 'selected' : ''}>Thường</option>
                                <option value="VIP" ${table.tableType == 'VIP' ? 'selected' : ''}>VIP</option>
                                <option value="OUTDOOR" ${table.tableType == 'OUTDOOR' ? 'selected' : ''}>Ngoài trời</option>
                                <option value="BAR" ${table.tableType == 'BAR' ? 'selected' : ''}>Quầy bar</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Trạng thái</label>
                            <select class="form-select" name="status">
                                <option value="VACANT" ${table.status == 'VACANT' ? 'selected' : ''}>Trống</option>
                                <option value="OCCUPIED" ${table.status == 'OCCUPIED' ? 'selected' : ''}>Đang sử dụng</option>
                                <option value="SEATED" ${table.status == 'SEATED' ? 'selected' : ''}>Đã ngồi</option>
                                <option value="CLEANING" ${table.status == 'CLEANING' ? 'selected' : ''}>Đang dọn</option>
                                <option value="OUT_OF_SERVICE" ${table.status == 'OUT_OF_SERVICE' ? 'selected' : ''}>Ngừng phục vụ</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Vị trí</label>
                            <input type="text" class="form-control" name="location" 
                                   value="${table.location}" placeholder="VD: Tầng 1, góc trái">
                        </div>
                    </div>

                    <div class="mt-4">
                        <button type="submit" class="btn btn-primary me-2">
                            <i class="fa-solid fa-check me-1"></i>
                            ${action == 'add' ? 'Thêm bàn' : 'Cập nhật'}
                        </button>
                        <a href="<c:url value='/table-management'/>" class="btn btn-secondary">
                            <i class="fa-solid fa-times me-1"></i> Hủy
                        </a>
                    </div>
                </form>
            </div>
        </div>
        </c:if>
    </main>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="bi bi-exclamation-triangle text-danger me-2"></i>
                    Xác nhận xóa bàn
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa bàn <strong id="deleteTableNumber"></strong>?</p>
                <p class="text-danger small">Hành động này không thể hoàn tác!</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <form method="POST" action="<c:url value='/table-management'/>" style="display:inline;">
                    <input type="hidden" name="action" value="delete"/>
                    <input type="hidden" name="id" id="deleteTableId"/>
                    <button type="submit" class="btn btn-danger">Xóa</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function confirmDelete(tableId, tableNumber) {
        document.getElementById('deleteTableId').value = tableId;
        document.getElementById('deleteTableNumber').textContent = tableNumber;
        var modal = new bootstrap.Modal(document.getElementById('deleteModal'));
        modal.show();
    }

    // Auto-hide alerts after 5 seconds
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

