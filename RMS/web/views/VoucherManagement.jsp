<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    request.setAttribute("page", "voucher");
    request.setAttribute("overlayNav", false);
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<!-- Nếu chưa đăng nhập thì đá về login -->
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
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <!-- Icons / Bootstrap -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>

    <!-- Base site styles (header/footer layout etc) -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <style>
        /************************************
         * THEME VARIABLES (tím lam + vàng FEA116)
         ************************************/
        :root {
            --bg-app:#f5f6fa;
            --bg-grad-1:rgba(88,80,200,.08); /* tím lam */
            --bg-grad-2:rgba(254,161,22,.06); /* vàng cam FEA116 */

            --panel-light-top:#fafaff;
            --panel-light-bottom:#ffffff;
            --panel-dark-start:#2a3048;
            --panel-dark-end:#1b1e2c;
            --panel-dark-border:rgba(255,255,255,.08);

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116; /* vàng champagne */
            --accent-soft:rgba(254,161,22,.12);
            --accent-border:rgba(254,161,22,.45);

            --brand:#4f46e5;
            --brand-border:#6366f1;
            --brand-bg-soft:#eef2ff;

            --success:#16a34a;
            --danger:#dc2626;

            --line:#e5e7eb;
            --shadow-card:0 28px 64px rgba(15,23,42,.12);

            --radius-lg:20px;
            --radius-md:12px;
            --radius-sm:6px;
            --sidebar-width:280px;
        }

        /************************************
         * GLOBAL LAYOUT
         ************************************/
        body {
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            color: var(--ink-900);
            font-family: "Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
        }

        .app-shell {
            display: grid;
            grid-template-columns: var(--sidebar-width) 1fr;
            min-height: 100vh;
        }
        @media(max-width:992px){
            .app-shell {
                grid-template-columns:1fr;
            }
            #sidebar {
                position: fixed;
                inset: 0 30% 0 0;
                transform: translateX(-100%);
                transition: transform .2s ease;
                z-index: 1040;
                max-width: var(--sidebar-width);
                box-shadow: 24px 0 60px rgba(0,0,0,.7);
                background:#1f2535;
            }
            #sidebar.open {
                transform: translateX(0);
            }
        }

        main.main-pane {
            padding: 28px 32px 44px;
        }

        /************************************
         * TOP POS BAR
         ************************************/
        .pos-topbar {
            position: relative;
            background: linear-gradient(135deg, var(--panel-dark-end) 0%, #2b2f46 60%, #1c1f30 100%);
            border-radius: var(--radius-md);
            padding: 16px 20px;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: flex-start;
            box-shadow: 0 32px 64px rgba(0,0,0,.6);
            margin-top: 58px;
            margin-bottom: 24px;
            color: #fff;
            border: 1px solid rgba(255,255,255,.1);
        }

        .pos-left .title-row {
            display:flex;
            align-items:center;
            gap:.6rem;
            font-weight:600;
            font-size:1rem;
            line-height:1.35;
            color:#fff;
        }
        .pos-left .title-row i {
            color: var(--accent);
            font-size:1.1rem;
        }
        .pos-left .sub {
            margin-top:4px;
            font-size:.8rem;
            color:var(--ink-400);
        }

        .pos-right {
            display:flex;
            align-items:center;
            flex-wrap:wrap;
            gap:.75rem;
            color:#fff;
        }

        .user-chip {
            display:flex;
            align-items:center;
            gap:.5rem;
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.18);
            border-radius:var(--radius-md);
            padding:6px 10px;
            font-size:.8rem;
            line-height:1.2;
            color:#fff;
            font-weight:500;
        }
        .user-chip .role-badge {
            background:var(--accent);
            color:#1e1e2f;
            border-radius:var(--radius-sm);
            padding:2px 6px;
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
        }

        .btn-toggle-sidebar {
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
                line-height:1.2;
                border-radius:var(--radius-sm);
                padding:6px 10px;
            }
            .btn-toggle-sidebar:hover {
                background:rgba(255,255,255,.07);
            }
        }

        /************************************
         * SEARCH / FILTER CARD
         ************************************/
        .filter-card {
            position:relative;
            background: linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border-radius: var(--radius-lg);
            border:1px solid rgba(99,102,241,.25);
            box-shadow:0 24px 60px rgba(15,23,42,.08), inset 0 1px 0 rgba(255,255,255,.6);
            padding:1rem 1.25rem 1.25rem;
            margin-bottom:1.5rem;
        }
        .filter-card::before{
            content:"";
            position:absolute;
            top:0;left:0;
            width:100%;height:5px;
            background:linear-gradient(90deg,var(--accent),var(--brand));
            border-radius:16px 16px 0 0;
            opacity:.9;
            pointer-events:none;
        }
        .filter-card-label{
            font-size:.8rem;
            font-weight:600;
            color:var(--ink-700);
            margin-bottom:.4rem;
        }
        .filter-small-hint{
            font-size:.7rem;
            line-height:1.3;
            color:var(--ink-500);
        }
        .form-control, .form-select {
            border-radius:10px;
            border:1.5px solid #e2e8f0;
            background:#ffffff;
            transition:all .25s ease;
        }
        .form-control:focus, .form-select:focus {
            border-color:var(--accent);
            box-shadow:0 0 0 .25rem rgba(254,161,22,.25);
            background:#fffefc;
        }

        /************************************
         * VOUCHER LIST CARD (TABLE WRAPPER)
         ************************************/
        .voucher-list-card {
            position:relative;
            background: linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border-radius: var(--radius-lg);
            border:1px solid rgba(99,102,241,.25);
            box-shadow:0 24px 60px rgba(15,23,42,.08), inset 0 1px 0 rgba(255,255,255,.6);
            margin-bottom:2rem;
        }
        .voucher-list-card::before{
            content:"";
            position:absolute;
            top:0;left:0;
            width:100%;height:5px;
            background:linear-gradient(90deg,var(--accent) 0%, var(--brand) 100%);
            border-radius:16px 16px 0 0;
            opacity:.9;
            pointer-events:none;
        }

        .voucher-card-head {
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            gap:.75rem;
            padding:1rem 1rem .75rem;
            border-bottom:1px solid rgba(0,0,0,.07);
        }
        .voucher-head-left-title {
            display:flex;
            align-items:center;
            flex-wrap:wrap;
            gap:.5rem;
            font-weight:600;
            font-size:1rem;
            color:var(--ink-900);
            line-height:1.3;
        }
        .voucher-head-left-title i{
            color:var(--accent);
        }
        .voucher-head-left-desc{
            font-size:.8rem;
            color:var(--ink-500);
            line-height:1.4;
        }

        .btn-create-voucher {
            display:inline-flex;
            align-items:center;
            gap:.4rem;
            background:linear-gradient(135deg,#6366f1 0%,#4f46e5 60%);
            color:#fff;
            font-weight:600;
            font-size:.8rem;
            line-height:1.2;
            border:none;
            border-radius:10px;
            padding:.55rem .75rem;
            box-shadow:0 12px 24px rgba(99,102,241,.4);
            white-space:nowrap;
            text-decoration:none;
        }
        .btn-create-voucher:hover{
            background:linear-gradient(135deg,#4f46e5 0%,#4338ca 60%);
            color:#fff;
            box-shadow:0 16px 32px rgba(79,70,229,.5);
            transform:translateY(-1px);
            text-decoration:none;
        }
        .btn-create-voucher i{
            font-size:.9rem;
        }

        /* optional clear filter button */
        .btn-clear-filter {
            border-radius:8px;
            line-height:1.2;
            font-weight:500;
            font-size:.75rem;
            padding:.5rem .6rem;
        }

        /************************************
         * TABLE STYLE
         ************************************/
        .table-responsive-inner{
            padding:1rem;
        }
        .table thead th {
            background:#fffdf5;
            font-size:.7rem;
            font-weight:600;
            text-transform:uppercase;
            color:var(--ink-700);
            border-bottom:1px solid var(--line);
            white-space:nowrap;
            vertical-align:middle;
        }
        .table td, .table th {
            vertical-align:middle;
            font-size:.8rem;
        }
        .table-hover tbody tr:hover {
            background:linear-gradient(to right,rgba(254,161,22,.08),rgba(99,102,241,.08));
        }

        /* badge loại giảm giá */
        .badge-discount-type{
            background:#0ea5e9;
            color:#fff;
            font-size:.75rem;
            font-weight:600;
            line-height:1.2;
            padding:.35rem .5rem;
            border-radius:6px;
            white-space:nowrap;
            display:inline-block;
        }

        /* giá trị giảm / số lần dùng */
        .badge-uses-info{
            background:#facc15;
            color:#1e1e1e;
            border:1px solid rgba(0,0,0,.25);
            font-size:.75rem;
            font-weight:600;
            line-height:1.2;
            padding:.35rem .5rem;
            border-radius:6px;
            white-space:nowrap;
            display:inline-block;
        }

        /* trạng thái voucher */
        .badge-status-active {
            background: rgba(16,185,129,.12);
            color:#065f46;
            border:1px solid rgba(16,185,129,.4);
            font-size:.8rem;
            font-weight:600;
            line-height:1.2;
            padding:.4rem .6rem;
            border-radius:8px;
            white-space:nowrap;
            min-width:90px;
            text-align:center;
            display:inline-block;
        }
        .badge-status-inactive {
            background: rgba(220,38,38,.1);
            color:#b91c1c;
            border:1px solid rgba(220,38,38,.4);
            font-size:.8rem;
            font-weight:600;
            line-height:1.2;
            padding:.4rem .6rem;
            border-radius:8px;
            white-space:nowrap;
            min-width:110px;
            text-align:center;
            display:inline-block;
        }

        .action-col .btn{
            font-size:.75rem;
            line-height:1.2;
            padding:.4rem .5rem;
            border-radius:6px;
        }
        .action-col .btn i{
            font-size:.8rem;
        }

        /* pagination footer in card */
        .voucher-card-footer {
            border-top:1px solid rgba(0,0,0,.07);
            padding:.75rem 1rem;
        }

        /* modal override small tweaks */
        .modal-content{
            border-radius:var(--radius-md);
        }
        .modal-header{
            border-bottom:1px solid var(--line);
        }
        .modal-footer{
            border-top:1px solid var(--line);
        }
    </style>
</head>

<body>

<!-- Navbar global (header.jsp của bạn) -->
<jsp:include page="/layouts/Header.jsp"/>

<c:set var="u" value="${sessionScope.user}"/>

<div class="app-shell">
    <!-- Sidebar global -->
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <!-- MAIN AREA -->
    <main class="main-pane">

        <!-- POS TOPBAR -->
        <header class="pos-topbar">
            <div class="pos-left">
                <div class="title-row">
                    <i class="bi bi-ticket-perforated"></i>
                    <span>Quản lý Voucher</span>
                </div>
                <div class="sub">
                    Tạo, chỉnh sửa và quản lý mã khuyến mãi áp dụng tại quầy & online.
                </div>
            </div>

            <div class="pos-right">
                <div class="user-chip">
                    <i class="bi bi-person-badge"></i>
                    <span>${u.fullName}</span>
                    <span class="role-badge">${u.roleName}</span>
                </div>

                <button class="btn-toggle-sidebar" onclick="toggleSidebar()">
                    <i class="bi bi-list"></i>
                    <span>Menu</span>
                </button>
            </div>
        </header>

        <!-- FLASH MESSAGES -->
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

        <!-- FILTER CARD -->
        <section class="filter-card">
            <form method="GET" action="<c:url value='/voucher-management'/>" class="row g-3">
                <!-- search -->
                <div class="col-md-5">
                    <label for="search" class="filter-card-label">Tìm kiếm</label>
                    <div class="input-group">
                        <span class="input-group-text"
                              style="border-top-left-radius:10px;border-bottom-left-radius:10px;">
                            <i class="bi bi-search"></i>
                        </span>
                        <input
                            type="text"
                            class="form-control"
                            id="search"
                            name="search"
                            placeholder="Mã voucher hoặc mô tả..."
                            value="${searchParam}">
                    </div>
                </div>

                <!-- trạng thái -->
                <div class="col-md-3">
                    <label for="status" class="filter-card-label">Trạng thái</label>
                    <select class="form-select" id="status" name="status">
                        <option value="">Tất cả</option>
                        <option value="ACTIVE" ${statusParam eq 'ACTIVE' ? 'selected' : ''}>Hoạt động</option>
                        <option value="INACTIVE" ${statusParam eq 'INACTIVE' ? 'selected' : ''}>Không hoạt động</option>
                    </select>
                </div>

                <!-- sort -->
                <div class="col-md-3">
                    <label for="sortBy" class="filter-card-label">Sắp xếp</label>
                    <select class="form-select" id="sortBy" name="sortBy">
                        <option value="" ${empty sortByParam ? 'selected' : ''}>Mới nhất</option>
                        <option value="code_asc" ${sortByParam eq 'code_asc' ? 'selected' : ''}>Mã A-Z</option>
                        <option value="code_desc" ${sortByParam eq 'code_desc' ? 'selected' : ''}>Mã Z-A</option>
                        <option value="value_desc" ${sortByParam eq 'value_desc' ? 'selected' : ''}>Giá trị cao</option>
                        <option value="expiry" ${sortByParam eq 'expiry' ? 'selected' : ''}>Gần hết hạn</option>
                    </select>
                </div>

                <div class="col-md-1 d-flex align-items-end">
                    <button type="submit"
                            class="btn btn-create-voucher w-100"
                            style="padding:.55rem .5rem; font-size:.8rem;">
                        <i class="bi bi-funnel"></i>
                        <span>Lọc</span>
                    </button>
                </div>
            </form>
        </section>

        <!-- VOUCHER LIST CARD -->
        <section class="voucher-list-card">
            <!-- head -->
            <div class="voucher-card-head">
                <div>
                    <div class="voucher-head-left-title">
                        <i class="bi bi-ticket-perforated"></i>
                        <span>Danh sách voucher (${totalVouchers} voucher)</span>
                    </div>
                    <div class="voucher-head-left-desc">
                        Voucher đang được áp dụng cho khách hàng
                    </div>
                </div>

                <div class="d-flex flex-wrap align-items-start gap-2">
                    <c:if test="${not empty searchParam or not empty statusParam or not empty sortByParam}">
                        <a href="<c:url value='/voucher-management'/>"
                           class="btn btn-outline-secondary btn-sm btn-clear-filter">
                            <i class="bi bi-x-circle me-1"></i>Xóa bộ lọc
                        </a>
                    </c:if>

                    <a href="<c:url value='/voucher-management?action=create'/>"
                       class="btn-create-voucher">
                        <i class="bi bi-plus-circle"></i>
                        <span>Tạo mới</span>
                    </a>
                </div>
            </div>

            <!-- table -->
            <div class="table-responsive table-responsive-inner">
                <table class="table table-hover mb-0">
                    <thead>
                    <tr>
                        <th>MÃ</th>
                        <th>MÔ TẢ</th>
                        <th>LOẠI</th>
                        <th>GIÁ TRỊ</th>
                        <th>ĐƠN TỐI THIỂU</th>
                        <th>HIỆU LỰC</th>
                        <th>ĐÃ DÙNG</th>
                        <th>TRẠNG THÁI</th>
                        <th class="text-center">THAO TÁC</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty vouchers}">
                            <tr>
                                <td colspan="9" class="text-center py-4 text-muted">
                                    <i class="bi bi-inbox" style="font-size:2rem;opacity:.3;"></i>
                                    <div class="small text-muted mt-2">
                                        Chưa có voucher nào. Hãy tạo voucher mới!
                                    </div>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="v" items="${vouchers}">
                                <tr>
                                    <!-- MÃ -->
                                    <td style="font-weight:600;color:var(--brand);">
                                        ${v.code}
                                    </td>

                                    <!-- MÔ TẢ -->
                                    <td>${v.description}</td>

                                    <!-- LOẠI -->
                                    <td>
                                        <span class="badge-discount-type">
                                            ${v.discountTypeDisplay}
                                        </span>
                                    </td>

                                    <!-- GIÁ TRỊ -->
                                    <td style="font-weight:600;color:var(--success);">
                                        ${v.discountDisplay}
                                    </td>

                                    <!-- ĐƠN TỐI THIỂU -->
                                    <td>
                                        <fmt:formatNumber value="${v.minOrderTotal}" pattern="#,##0"/> đ
                                    </td>

                                    <!-- HIỆU LỰC -->
                                    <td class="small">${v.validityDisplay}</td>

                                    <!-- ĐÃ DÙNG / CÒN LẠI -->
                                    <td>
                                        <span class="badge-uses-info">
                                            ${v.usageLimitDisplay}
                                        </span>
                                    </td>

                                    <!-- TRẠNG THÁI -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${v.statusDisplay eq 'Hoạt động'}">
                                                <span class="badge-status-active">Hoạt động</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status-inactive">Không hoạt động</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- ACTION -->
                                    <td class="text-center action-col">
                                        <div class="btn-group" role="group">
                                            <a href="<c:url value='/voucher-management?action=view&id=${v.voucherId}'/>"
                                               class="btn btn-outline-info"
                                               title="Xem chi tiết">
                                                <i class="bi bi-eye"></i>
                                            </a>

                                            <a href="<c:url value='/voucher-management?action=edit&id=${v.voucherId}'/>"
                                               class="btn btn-outline-warning"
                                               title="Chỉnh sửa">
                                                <i class="bi bi-pencil"></i>
                                            </a>

                                            <button type="button"
                                                    class="btn btn-outline-danger"
                                                    title="Vô hiệu hóa"
                                                    onclick="confirmDelete(${v.voucherId}, '${v.code}')">
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

            <!-- PAGINATION -->
            <c:if test="${totalPages > 1}">
                <div class="voucher-card-footer">
                    <nav aria-label="Voucher pagination">
                        <ul class="pagination pagination-sm mb-0 justify-content-center">
                            <!-- Prev -->
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

                            <!-- page numbers -->
                            <c:forEach begin="1" end="${totalPages}" var="pageNum">
                                <c:if test="${pageNum <= 3
                                             or pageNum >= totalPages - 2
                                             or (pageNum >= currentPage - 1 and pageNum <= currentPage + 1)}">
                                    <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="<c:url value='/voucher-management'>
                                            <c:param name='page' value='${pageNum}'/>
                                            <c:if test='${not empty searchParam}'><c:param name='search' value='${searchParam}'/></c:if>
                                            <c:if test='${not empty statusParam}'><c:param name='status' value='${statusParam}'/></c:if>
                                            <c:if test='${not empty sortByParam}'><c:param name='sortBy' value='${sortByParam}'/></c:if>
                                        </c:url>">${pageNum}</a>
                                    </li>

                                    <c:if test="${pageNum == 3 && currentPage > 5}">
                                        <li class="page-item disabled"><span class="page-link">...</span></li>
                                    </c:if>

                                    <c:if test="${pageNum == totalPages-2 && currentPage < totalPages-4}">
                                        <li class="page-item disabled"><span class="page-link">...</span></li>
                                    </c:if>
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
        </section>

    </main>
</div>

<!-- DELETE MODAL -->
<div class="modal fade" id="deleteModal" tabindex="-1"
     aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="deleteModalLabel">Xác nhận vô hiệu hóa</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"
                        aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn vô hiệu hóa voucher
                    <strong style="color:var(--brand);" id="voucherCodeToDelete"></strong>?
                </p>
                <p class="text-muted small">
                    Voucher sẽ không thể sử dụng nữa nhưng lịch sử vẫn được giữ lại.
                </p>
            </div>
            <div class="modal-footer">
                <button type="button"
                        class="btn btn-secondary"
                        data-bs-dismiss="modal">Hủy</button>

                <form id="deleteForm"
                      method="POST"
                      action="<c:url value='/voucher-management'/>"
                      style="display:inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="voucherId" id="voucherIdToDelete">
                    <button type="submit" class="btn btn-danger">Vô hiệu hóa</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Footer global -->
<jsp:include page="/layouts/Footer.jsp"/>

<!-- JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    function toggleSidebar(){
        var el = document.getElementById('sidebar');
        if(el){ el.classList.toggle('open'); }
    }

    function confirmDelete(voucherId, voucherCode) {
        document.getElementById('voucherIdToDelete').value = voucherId;
        document.getElementById('voucherCodeToDelete').textContent = voucherCode;
        var modal = new bootstrap.Modal(document.getElementById('deleteModal'));
        modal.show();
    }

    // auto close alerts
    setTimeout(function () {
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function (al) {
            try {
                var bsAlert = new bootstrap.Alert(al);
                bsAlert.close();
            } catch (e) {}
        });
    }, 5000);
</script>

</body>
</html>
