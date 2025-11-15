<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="Models.Staff"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="page" value="staff" scope="request"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý nhân viên · RMS POS</title>

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

            --panel-light-top: #fafaff;
            --panel-light-bottom: #ffffff;

            --panel-dark-start:#2a3048;
            --panel-dark-end:#1b1e2c;

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.08);
            --accent-border:rgba(254,161,22,.45);

            --brand:#4f46e5;

            --success:#16a34a;
            --success-soft:#dcfce7;
            --danger:#dc2626;

            --line:#e5e7eb;

            --radius-lg:20px;
            --radius-md:14px;
            --radius-sm:6px;

            --sidebar-width:280px;
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
            grid-template-columns: var(--sidebar-width) 1fr;
            min-height:100vh;
        }
        @media(max-width:992px){
            .app-shell{
                grid-template-columns:1fr;
            }
            #sidebar{
                position:fixed;
                inset:0 30% 0 0;
                max-width:var(--sidebar-width);
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

        /* Topbar */
        .pos-topbar{
            background: linear-gradient(135deg, var(--panel-dark-end) 0%, #2b2f46 60%, #1c1f30 100%);
            color:#fff;
            border-radius:var(--radius-md);
            border:1px solid rgba(255,255,255,.08);
            padding:16px 20px;
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            box-shadow:0 32px 64px rgba(0,0,0,.6);
            margin-top:58px;
            margin-bottom:24px;
        }
        .pos-left .title-row{
            display:flex;
            align-items:center;
            gap:.6rem;
            font-weight:600;
            font-size:1rem;
            line-height:1.35;
            color:#fff;
        }
        .pos-left .title-row i{
            color:var(--accent);
            font-size:1.1rem;
        }
        .pos-left .sub{
            margin-top:4px;
            font-size:.8rem;
            color:var(--ink-400);
        }
        .pos-right{
            display:flex;
            align-items:center;
            flex-wrap:wrap;
            gap:.75rem;
        }
        .user-chip{
            display:flex;
            align-items:center;
            gap:.5rem;
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.18);
            border-radius:var(--radius-md);
            padding:6px 10px;
            font-size:.8rem;
            font-weight:500;
            line-height:1.2;
            color:#fff;
        }
        .user-chip .role-badge{
            background:var(--accent);
            color:#1e1e2f;
            border-radius:var(--radius-sm);
            padding:2px 6px;
            font-size:.7rem;
            font-weight:600;
        }
        .btn-toggle-sidebar{
            display:none;
        }
        @media(max-width:992px){
            .btn-toggle-sidebar{
                display:inline-flex;
                align-items:center;
                gap:.4rem;
                background:transparent;
                border:1px solid rgba(255,255,255,.3);
                color:#fff;
                font-size:.8rem;
                border-radius:var(--radius-sm);
                padding:6px 10px;
            }
            .btn-toggle-sidebar:hover{
                background:rgba(255,255,255,.07);
            }
        }

        /* Filter card */
        .filter-card{
            background:linear-gradient(to bottom right,var(--panel-light-top) 0%,var(--panel-light-bottom) 100%);
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:0 16px 40px rgba(15,23,42,.12);
            padding:1rem 1.25rem 1.25rem;
            margin-bottom:1.25rem;
            position:relative;
        }
        .filter-card::before{
            content:"";
            position:absolute;
            top:0;
            left:0;
            width:100%;
            height:4px;
            background:linear-gradient(90deg,var(--accent),var(--brand));
            border-radius:8px 8px 0 0;
            opacity:.8;
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

        .btn-add-staff{
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
        .btn-add-staff:hover{
            filter:brightness(1.05);
            box-shadow:0 20px 40px rgba(254,161,22,.45);
        }

        /* Summary cards */
        .summary-row{
            display:flex;
            flex-wrap:wrap;
            gap:.75rem;
            margin-bottom:1rem;
        }
        .summary-card{
            flex:1 1 160px;
            background:#ffffff;
            border-radius:var(--radius-md);
            border:1px solid var(--line);
            padding:.7rem .9rem;
            display:flex;
            align-items:center;
            gap:.7rem;
        }
        .summary-icon{
            width:32px;
            height:32px;
            border-radius:999px;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:.9rem;
        }
        .summary-icon.total{
            background:rgba(79,70,229,.1);
            color:#4f46e5;
        }
        .summary-icon.active{
            background:rgba(22,163,74,.1);
            color:#16a34a;
        }
        .summary-icon.inactive{
            background:rgba(248,113,113,.12);
            color:#dc2626;
        }
        .summary-text{
            display:flex;
            flex-direction:column;
            gap:.1rem;
        }
        .summary-label{
            font-size:.75rem;
            color:var(--ink-500);
        }
        .summary-value{
            font-weight:600;
            font-size:.95rem;
        }

        /* Table card */
        .staff-table-card{
            background:#ffffff;
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:0 18px 40px rgba(15,23,42,.10);
            overflow:hidden;
        }
        .staff-table-header{
            padding:.75rem 1rem;
            display:flex;
            justify-content:space-between;
            align-items:center;
            border-bottom:1px solid var(--line);
        }
        .staff-table-header h6{
            margin:0;
            font-weight:600;
            font-size:.95rem;
            display:flex;
            align-items:center;
            gap:.5rem;
        }
        .staff-table-header h6 i{
            color:var(--accent);
        }
        .table-responsive{
            margin-bottom:0;
        }

        table.staff-table{
            margin-bottom:0;
        }
        .staff-table thead th{
            background:#f9fafb;
            font-size:.75rem;
            text-transform:uppercase;
            letter-spacing:.03em;
            color:var(--ink-500);
            border-bottom:1px solid var(--line);
            white-space:nowrap;
        }
        .staff-table tbody td{
            vertical-align:middle;
            font-size:.84rem;
            color:var(--ink-700);
        }

        /* Hiệu ứng hover hàng + tên nổi bật hơn */
        .staff-table tbody tr{
            transition: background .15s ease, box-shadow .15s ease, transform .08s ease;
        }
        .staff-table tbody tr:hover{
            background:#f1f5f9;
            box-shadow:inset 4px 0 0 var(--accent-soft);
        }
        .staff-table tbody tr:hover .staff-name-cell{
            color:var(--brand);
        }

        .staff-name-cell{
            font-weight:600;
            color:var(--ink-900);
        }
        .staff-role-cell{
            font-size:.78rem;
            color:var(--ink-500);
        }

        .badge-status{
            font-size:.7rem;
            font-weight:600;
            border-radius:999px;
            padding:.25rem .6rem;
        }
        .badge-status.active{
            background:var(--success-soft);
            color:#166534;
        }
        .badge-status.inactive{
            background:rgba(248,113,113,.10);
            color:#b91c1c;
        }

        .role-chip{
            font-size:.7rem;
            border-radius:999px;
            padding:.2rem .5rem;
            background:var(--accent-soft);
            color:#92400e;
        }

        .staff-actions .btn{
            border-radius:999px;
            font-size:.75rem;
            padding:.3rem .55rem;
        }

        .btn-outline-info{
            border-color:#38bdf8;
            color:#0ea5e9;
        }
        .btn-outline-info:hover{
            background:#e0f2fe;
            border-color:#0ea5e9;
            color:#0369a1;
        }
        .btn-outline-warning{
            border-color:#facc15;
            color:#ca8a04;
        }
        .btn-outline-warning:hover{
            background:#fef9c3;
            border-color:#eab308;
            color:#713f12;
        }
        .btn-outline-danger{
            border-color:#f87171;
            color:#dc2626;
        }
        .btn-outline-danger:hover{
            background:#fee2e2;
            border-color:#dc2626;
            color:#7f1d1d;
        }
        .btn-success-activate{
            background:#16a34a;
            border:none;
            color:#fff;
            box-shadow:0 10px 24px rgba(22,163,74,.3);
        }
        .btn-success-activate:hover{
            background:#0f766e;
        }

        .empty-row{
            text-align:center;
            padding:2rem 1rem !important;
            color:var(--ink-500);
        }

        .alert{
            border-radius:var(--radius-sm);
            border:1px solid transparent;
            box-shadow:0 10px 30px rgba(0,0,0,.12);
            font-size:.9rem;
        }

        /* Pagination */
        .pagination.custom-pagination .page-link{
            border-radius:999px;
            margin:0 .12rem;
            font-size:.78rem;
            padding:.35rem .65rem;
            border:1px solid #e5e7eb;
            color:#4b5563;
        }
        .pagination.custom-pagination .page-link:hover{
            background:#eff6ff;
            border-color:#93c5fd;
            color:#1d4ed8;
        }
        .pagination.custom-pagination .page-item.active .page-link{
            background:#2563eb;
            border-color:#2563eb;
            color:#fff;
        }
        .pagination.custom-pagination .page-item.disabled .page-link{
            background:#f9fafb;
            color:#9ca3af;
        }

        /* Deactivate modal */
        .modal-content{
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:0 32px 80px rgba(0,0,0,.5);
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
        }
        .modal-header{
            background:linear-gradient(135deg,var(--panel-dark-end) 0%,#2b2f46 60%,#1c1f30 100%);
            border-top-left-radius:var(--radius-lg);
            border-top-right-radius:var(--radius-lg);
            border-bottom:1px solid rgba(255,255,255,.08);
            color:#fff;
        }
        .modal-title i{ color:var(--accent); }
        .modal-body p{ color:var(--ink-700); font-size:.9rem; }
        .modal-body ul{ font-size:.8rem; color:#dc2626; padding-left:1.2rem; }
        .modal-footer .btn-danger{
            background:#dc2626;
            border:none;
        }
        .modal-footer .btn-danger:hover{
            background:#b91c1c;
        }

        .text-soft{color:var(--ink-500);}
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
        <header class="pos-topbar">
            <div class="pos-left">
                <div class="title-row">
                    <i class="bi bi-people-fill"></i>
                    <span>Quản lý nhân viên</span>
                </div>
                <div class="sub">
                    Quản lý hồ sơ, phân quyền và trạng thái hoạt động của nhân viên.
                </div>
            </div>
            <div class="pos-right">
                <div class="user-chip">
                    <i class="bi bi-person-badge"></i>
                    <span>${sessionScope.user.fullName}</span>
                    <span class="role-badge">${sessionScope.user.roleName}</span>
                </div>

                <button class="btn-toggle-sidebar" onclick="toggleSidebar()">
                    <i class="bi bi-list"></i><span>Menu</span>
                </button>
            </div>
        </header>

        <!-- Filter -->
        <div class="filter-card">
            <form class="row g-2 align-items-end" method="get" action="staff-management" id="staffFilterForm">
                <div class="col-md-6">
                    <label class="form-label fw-semibold small text-soft">Tìm kiếm</label>
                    <input type="text"
                           class="form-control"
                           name="q"
                           value="${q}"
                           placeholder="Tìm theo tên, email, số điện thoại..."
                           oninput="debouncedSubmit()"/>
                </div>

                <div class="col-md-4">
                    <label class="form-label fw-semibold small text-soft">Vai trò hệ thống</label>
                    <select class="form-select" name="roleId" onchange="document.getElementById('staffFilterForm').submit()">
                        <option value="">Tất cả vai trò</option>
                        <c:forEach var="r" items="${roles}">
                            <option value="${r.roleId}" ${roleId == r.roleId ? 'selected' : ''}>${r.roleName}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-2 text-md-end text-start mt-3 mt-md-0">
                    <a href="staff-management?action=add" class="btn btn-add-staff w-100 w-md-auto">
                        <i class="fa-solid fa-user-plus me-1"></i> Thêm nhân viên
                    </a>
                </div>
            </form>
        </div>

        <!-- Alert -->
        <%
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            if (success != null) {
        %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><%= success %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Summary + Table -->
        <%
            List<Staff> staffList = (List<Staff>) request.getAttribute("staffList");
            int total = 0, activeCount = 0, inactiveCount = 0;
            if (staffList != null) {
                total = staffList.size();
                for (Staff s : staffList) {
                    if (s.isActive()) activeCount++; else inactiveCount++;
                }
            }
        %>

        <div class="summary-row">
            <div class="summary-card">
                <div class="summary-icon total">
                    <i class="fa-solid fa-users"></i>
                </div>
                <div class="summary-text">
                    <span class="summary-label">Tổng nhân viên</span>
                    <span class="summary-value"><%= total %></span>
                </div>
            </div>
            <div class="summary-card">
                <div class="summary-icon active">
                    <i class="fa-solid fa-user-check"></i>
                </div>
                <div class="summary-text">
                    <span class="summary-label">Đang hoạt động</span>
                    <span class="summary-value"><%= activeCount %></span>
                </div>
            </div>
            <div class="summary-card">
                <div class="summary-icon inactive">
                    <i class="fa-solid fa-user-slash"></i>
                </div>
                <div class="summary-text">
                    <span class="summary-label">Đã vô hiệu</span>
                    <span class="summary-value"><%= inactiveCount %></span>
                </div>
            </div>
        </div>

        <div class="staff-table-card">
            <div class="staff-table-header">
                <h6>
                    <i class="bi bi-card-list"></i>
                    Danh sách nhân viên
                </h6>
                <span class="text-soft small">
                    Dùng nút <strong>Xem / Sửa / Vô hiệu hóa / Kích hoạt</strong> để thao tác nhanh.
                </span>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle staff-table">
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Nhân viên</th>
                        <th>Liên hệ</th>
                        <th>Ngày vào làm</th>
                        <th>Trạng thái</th>
                        <th class="text-end">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (staffList != null && !staffList.isEmpty()) {
                            // currentPage & pageSize được set từ Servlet
                            Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                            Integer pageSizeObj   = (Integer) request.getAttribute("pageSize");
                            int currentPage = currentPageObj != null ? currentPageObj : 1;
                            int pageSize    = pageSizeObj != null ? pageSizeObj : staffList.size();

                            int startIndex = (currentPage - 1) * pageSize + 1;
                            int idx = startIndex;

                            for (Staff s : staffList) {
                                boolean active = s.isActive();
                                String statusClass = active ? "active" : "inactive";
                    %>
                    <tr>
                        <td><%= idx++ %></td>
                        <td>
                            <div class="staff-name-cell"><%= s.getFullName() %></div>
                            <div class="staff-role-cell">
                                <span class="role-chip">
                                    <%= s.getPosition() != null ? s.getPosition() : "Chưa phân công" %>
                                </span>
                            </div>
                        </td>
                        <td>
                            <div class="staff-role-cell">
                                <i class="fa-regular fa-envelope me-1 text-soft"></i>
                                <%= s.getEmail() %>
                            </div>
                            <div class="staff-role-cell mt-1">
                                <i class="fa-solid fa-phone me-1 text-soft"></i>
                                <%= s.getPhone() != null ? s.getPhone() : "—" %>
                            </div>
                        </td>
                        <td>
                            <span class="staff-role-cell">
                                <%= s.getHireDate() != null ? s.getHireDate() : "—" %>
                            </span>
                        </td>
                        <td>
                            <span class="badge-status <%=statusClass%>">
                                <%= s.getStatus() %>
                            </span>
                        </td>
                        <td class="text-end">
                            <div class="staff-actions d-inline-flex gap-1">
                                <a href="staff-management?action=view&id=<%= s.getStaffId() %>"
                                   class="btn btn-sm btn-outline-info">
                                    <i class="fa-solid fa-eye"></i>
                                </a>
                                <a href="staff-management?action=edit&id=<%= s.getStaffId() %>"
                                   class="btn btn-sm btn-outline-warning">
                                    <i class="fa-solid fa-pen"></i>
                                </a>

                                <% if (s.isActive() && !"Manager".equals(s.getPosition())) { %>
                                <button class="btn btn-sm btn-outline-danger"
                                        onclick="confirmDeactivate(<%= s.getStaffId() %>, <%= s.getUserId() %>, '<%= s.getFullName() %>')">
                                    <i class="fa-solid fa-user-slash"></i>
                                </button>
                                <% } else if (!s.isActive()) { %>
                                <form method="post" action="staff-management" style="display:inline-block">
                                    <input type="hidden" name="action" value="activate"/>
                                    <input type="hidden" name="staffId" value="<%= s.getStaffId() %>"/>
                                    <input type="hidden" name="userId" value="<%= s.getUserId() %>"/>
                                    <button class="btn btn-sm btn-success-activate">
                                        <i class="fa-solid fa-user-check"></i>
                                    </button>
                                </form>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="6" class="empty-row">
                            <i class="fa-solid fa-user-group mb-2 text-accent" style="font-size:1.7rem;"></i><br/>
                            Chưa có nhân viên nào. Hãy thêm nhân viên đầu tiên.
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <!-- PAGINATION -->
            <c:if test="${totalPages gt 1}">
                <nav aria-label="Paging" class="px-3 py-2">
                    <ul class="pagination justify-content-end mb-0 custom-pagination">

                        <!-- Previous -->
                        <c:set var="prevPage" value="${currentPage - 1}"/>
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <c:url var="prevUrl" value="staff-management">
                                <c:param name="page" value="${prevPage}"/>
                                <c:param name="q" value="${q}"/>
                                <c:param name="roleId" value="${roleId}"/>
                            </c:url>
                            <a class="page-link" href="${prevUrl}" tabindex="-1">
                                <i class="bi bi-chevron-left"></i>
                            </a>
                        </li>

                        <!-- Page numbers -->
                        <c:forEach var="i" begin="1" end="${totalPages}">
                            <c:url var="pageUrl" value="staff-management">
                                <c:param name="page" value="${i}"/>
                                <c:param name="q" value="${q}"/>
                                <c:param name="roleId" value="${roleId}"/>
                            </c:url>
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="${pageUrl}">${i}</a>
                            </li>
                        </c:forEach>

                        <!-- Next -->
                        <c:set var="nextPage" value="${currentPage + 1}"/>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <c:url var="nextUrl" value="staff-management">
                                <c:param name="page" value="${nextPage}"/>
                                <c:param name="q" value="${q}"/>
                                <c:param name="roleId" value="${roleId}"/>
                            </c:url>
                            <a class="page-link" href="${nextUrl}">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </div>

    </main>
</div>

<!-- Modal vô hiệu hóa -->
<div class="modal fade" id="deactivateModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fa-solid fa-user-slash me-1"></i>
                    Xác nhận vô hiệu hóa
                </h5>
                <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <p>Bạn có chắc chắn muốn vô hiệu hóa <strong id="staffName"></strong>?</p>
                <ul>
                    <li>Tài khoản đăng nhập sẽ bị khóa</li>
                    <li>Nhân viên sẽ không thể truy cập hệ thống</li>
                    <li>Trạng thái chuyển sang INACTIVE</li>
                </ul>
            </div>

            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <form method="post" action="staff-management" style="display:inline;">
                    <input type="hidden" name="action" value="deactivate">
                    <input type="hidden" name="staffId" id="deactivateStaffId">
                    <input type="hidden" name="userId" id="deactivateUserId">
                    <button class="btn btn-danger">Vô hiệu hóa</button>
                </form>
            </div>

        </div>
    </div>
</div>

<jsp:include page="/layouts/Footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function toggleSidebar(){
        var el = document.getElementById('sidebar');
        if(el) el.classList.toggle('open');
    }

    let __sfTimer;
    function debouncedSubmit(){
        const form = document.getElementById('staffFilterForm');
        if(!form) return;
        clearTimeout(__sfTimer);
        __sfTimer = setTimeout(function(){
            form.submit();
        }, 350);
    }

    function confirmDeactivate(staffId, userId, staffName){
        var staffIdInput = document.getElementById('deactivateStaffId');
        var userIdInput = document.getElementById('deactivateUserId');
        var nameSpan = document.getElementById('staffName');
        if(staffIdInput) staffIdInput.value = staffId;
        if(userIdInput) userIdInput.value = userId;
        if(nameSpan) nameSpan.textContent = staffName || '';
        var modalEl = document.getElementById('deactivateModal');
        if (modalEl){
            var modal = new bootstrap.Modal(modalEl);
            modal.show();
        }
    }

    setTimeout(function(){
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(al){
            var bsAlert = new bootstrap.Alert(al);
            bsAlert.close();
        });
    }, 5000);
</script>
</body>
</html>
