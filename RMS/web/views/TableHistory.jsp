<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    // fallback tránh null
    Object tableIdObj = request.getAttribute("tableId");
    String tableLabel = (tableIdObj != null) ? ("Bàn " + tableIdObj.toString()) : "Bàn ?";
    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử gọi món - RMS</title>

    <!-- Bootstrap / Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet"/>

    <!-- Font -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <style>
        :root{
            --bg-app:#f5f6fa;
            --bg-grad-1:rgba(88,80,200,.08);
            --bg-grad-2:rgba(254,161,22,.06);
            --nav-grad:linear-gradient(135deg,#0f1a2a 0%,#1a2234 60%,#1f2535 100%);
            --accent:#FEA116;

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;

            --status-new-bg:#cfe2ff;
            --status-new-fg:#084298;
            --status-cooking-bg:#fff3cd;
            --status-cooking-fg:#856404;
            --status-ready-bg:#d1e7dd;
            --status-ready-fg:#0f5132;
            --status-served-bg:#d4edda;
            --status-served-fg:#155724;
            --status-cancel-bg:#f8d7da;
            --status-cancel-fg:#721c24;

            --prio-normal-bg:#e7f3ff;
            --prio-normal-fg:#0066cc;
            --prio-high-bg:#ffe7d0;
            --prio-high-fg:#cc4400;
            --prio-urgent-bg:#ffcccc;
            --prio-urgent-fg:#cc0000;
        }

        body{
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            font-family:"Heebo",system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",sans-serif;
            color:var(--ink-900);
        }

        /* ---------- TOP NAV giống trang POS ---------- */
        .screen-top-shell{
            width:100%;
            padding:12px 16px 0;
        }
        .screen-top-inner{
            max-width:1400px;
            margin:0 auto;
            background:var(--nav-grad);
            border:1px solid rgba(255,255,255,.08);
            border-radius:10px;
            box-shadow:
                0 32px 64px rgba(0,0,0,.75),
                0 2px 4px rgba(255,255,255,.15) inset;
            color:#fff;
            display:flex;
            flex-wrap:wrap;
            align-items:flex-start;
            justify-content:space-between;
            gap:.75rem;
            padding:.75rem 1rem;
        }
        .brand-side{
            display:flex;
            align-items:flex-start;
            gap:.75rem;
            min-width:0;
        }
        .app-icon{
            background:rgba(255,255,255,.07);
            border:1px solid rgba(255,255,255,.18);
            color:#fff;
            width:36px;
            height:36px;
            border-radius:8px;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:.9rem;
            line-height:1;
            box-shadow:0 16px 32px rgba(0,0,0,.7);
        }
        .brand-lines{
            display:flex;
            flex-direction:column;
            line-height:1.3;
        }
        .brand-row{
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.4rem;
            font-size:.9rem;
            font-weight:600;
            color:#fff;
            white-space:nowrap;
        }
        .brand-row .dot{
            opacity:.4;
            font-weight:400;
        }
        .brand-sub{
            font-size:.7rem;
            line-height:1.3;
            color:rgba(255,255,255,.6);
            white-space:nowrap;
        }

        .nav-side{
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.5rem .6rem;
            margin-left:auto;
        }
        .nav-pill{
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.2);
            border-radius:.5rem;
            padding:.45rem .6rem;
            color:#fff;
            font-size:.8rem;
            font-weight:500;
            line-height:1.2;
            box-shadow:0 20px 40px rgba(0,0,0,.6);
            display:inline-flex;
            align-items:center;
            gap:.4rem;
            text-decoration:none;
            white-space:nowrap;
        }
        .nav-pill i{
            font-size:.8rem;
            color:#fff;
        }
        .nav-pill:hover{
            background:rgba(255,255,255,.1);
            color:#fff;
            text-decoration:none;
            box-shadow:0 28px 60px rgba(0,0,0,.7);
        }

        .role-badge{
            background:var(--accent);
            color:#1e1e2f;
            border-radius:.4rem;
            padding:.2rem .45rem;
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
            border:1px solid rgba(0,0,0,.15);
            box-shadow:0 8px 16px rgba(254,161,22,.4);
        }

        .dropdown-menu.top-user-menu{
            font-size:.8rem;border-radius:.5rem;
            border:1px solid rgba(0,0,0,.08);
            box-shadow:0 24px 48px rgba(0,0,0,.45);
            min-width:180px;
        }
        .dropdown-menu.top-user-menu .dropdown-item{
            display:flex;align-items:center;gap:.5rem;
            font-weight:500;padding:.5rem .9rem;
        }

        /* ---------- PAGE WRAPPER ---------- */
        .page-wrapper{
            max-width:1400px;
            margin:24px auto 48px;
            padding:0 16px 48px;
        }

        /* ---------- SUMMARY CARDS ---------- */
        .summary-row{
            row-gap:16px;
        }
        .summary-card{
            border-radius:12px;
            border:1px solid rgba(0,0,0,.05);
            background:#fff;
            box-shadow:0 16px 40px rgba(0,0,0,.06);
            text-align:center;
            padding:16px;
        }
        .summary-number{
            font-size:1.25rem;
            font-weight:600;
            line-height:1.2;
        }
        .summary-label{
            font-size:.8rem;
            color:var(--ink-500);
            margin-top:.25rem;
        }

        /* ---------- HISTORY TABLE CARD ---------- */
        .history-card-shell{
            border-radius:18px;
            border:1px solid rgba(0,0,0,.05);
            background:#fff;
            box-shadow:0 24px 64px rgba(0,0,0,.08);
            overflow:hidden;
        }
        .history-card-head{
            background:#fff;
            border-bottom:1px solid rgba(0,0,0,.06);
            padding:16px 20px;
            font-size:1rem;
            font-weight:600;
            color:var(--ink-900);
            display:flex;
            align-items:center;
            gap:.5rem;
        }
        .history-card-body{
            padding:16px 20px;
        }

        /* ---------- BADGES ---------- */
        .status-badge{
            display:inline-block;
            padding:4px 8px;
            border-radius:6px;
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
        }
        .status-new{
            background-color:var(--status-new-bg);
            color:var(--status-new-fg);
        }
        .status-cooking{
            background-color:var(--status-cooking-bg);
            color:var(--status-cooking-fg);
        }
        .status-ready{
            background-color:var(--status-ready-bg);
            color:var(--status-ready-fg);
        }
        .status-served{
            background-color:var(--status-served-bg);
            color:var(--status-served-fg);
        }
        .status-cancelled{
            background-color:var(--status-cancel-bg);
            color:var(--status-cancel-fg);
        }

        .priority-badge{
            display:inline-block;
            padding:3px 8px;
            border-radius:4px;
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
        }
        .priority-normal{
            background-color:var(--prio-normal-bg);
            color:var(--prio-normal-fg);
        }
        .priority-high{
            background-color:var(--prio-high-bg);
            color:var(--prio-high-fg);
        }
        .priority-urgent{
            background-color:var(--prio-urgent-bg);
            color:var(--prio-urgent-fg);
        }

        .course-badge{
            display:inline-block;
            padding:3px 8px;
            border-radius:4px;
            font-size:.7rem;
            font-weight:500;
            background-color:#f0f0f0;
            color:#555;
            line-height:1.2;
        }

        /* ---------- TABLE LOOK ---------- */
        table.history-table thead th{
            font-size:.75rem;
            font-weight:600;
            white-space:nowrap;
            color:var(--ink-700);
            border-bottom:1px solid rgba(0,0,0,.08) !important;
            background-color:#f9fafb;
        }
        table.history-table tbody td{
            font-size:.8rem;
            vertical-align:middle;
        }

        /* ---------- TOAST ---------- */
        .toast-wrap{
            position:fixed;
            right:16px;
            bottom:16px;
            z-index:9999;
            display:flex;
            flex-direction:column;
            gap:8px;
            pointer-events:none;
        }
        .toast-card{
            min-width:240px;
            max-width:320px;
            background:linear-gradient(135deg,#1f2937 0%,#111827 60%);
            border:1px solid rgba(255,255,255,.15);
            border-radius:10px;
            box-shadow:0 24px 48px rgba(0,0,0,.8);
            color:#fff;
            padding:.75rem .9rem;
            font-size:.8rem;
            line-height:1.4;
            font-weight:500;
            display:flex;
            align-items:flex-start;
            gap:.6rem;
            pointer-events:auto;
            opacity:0;
            transform:translateY(10px);
            transition:all .2s ease;
        }
        .toast-card.show{
            opacity:1;
            transform:translateY(0);
        }
        .toast-icon{
            flex-shrink:0;
            width:28px;
            height:28px;
            border-radius:8px;
            background:var(--accent);
            border:1px solid rgba(0,0,0,.4);
            color:#1e1e2f;
            font-size:.8rem;
            font-weight:600;
            display:flex;
            align-items:center;
            justify-content:center;
            box-shadow:0 16px 32px rgba(254,161,22,.4);
        }
        .toast-body{
            flex:1;
            color:#fff;
            font-size:.8rem;
            line-height:1.4;
        }
        .toast-close{
            cursor:pointer;
            color:rgba(255,255,255,.6);
            font-size:.75rem;
            line-height:1;
        }
        .toast-close:hover{
            color:#fff;
        }

        /* ---------- SERVE CONFIRM MODAL CUSTOM ---------- */
        .modal-confirm-body{
            font-size:.9rem;
            color:var(--ink-700);
        }
        .btn-serve{
            background:var(--accent);
            border:1px solid #b45309;
            color:#1e1e2f;
            font-weight:600;
        }
        .btn-serve:hover{
            filter:brightness(1.05);
            color:#1e1e2f;
        }
    </style>
</head>
<body>

<!-- NAV BAR (giống style trang gọi món) -->
<header class="screen-top-shell">
    <div class="screen-top-inner">
        <div class="brand-side">
            <div class="app-icon">
                <i class="fa-solid fa-utensils"></i>
            </div>
            <div class="brand-lines">
                <div class="brand-row">
                    <span>RMS</span>
                    <span class="dot">•</span>
                    <span id="headerTable"><%=tableLabel%></span>
                </div>
                <div class="brand-sub">
                    Lịch sử gọi món / Trạng thái phục vụ theo bàn
                </div>
            </div>
        </div>

        <div class="nav-side">
            <a class="nav-pill" href="<%=ctx%>/tables">
                <i class="bi bi-grid-3x3-gap-fill"></i>
                <span>Sơ đồ bàn</span>
            </a>

            <a class="nav-pill" href="<%=ctx%>/kds">
                <i class="bi bi-tv"></i>
                <span>KDS</span>
            </a>

            <a class="nav-pill" href="<%=ctx%>/tables" onclick="returnToTableMap()">
                <i class="bi bi-arrow-left"></i>
                <span>Quay lại</span>
            </a>

            <!-- user dropdown (tùy bạn gắn real user) -->
            <div class="dropdown">
                <button class="nav-pill dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-person-circle"></i>
                    <span>Waiter</span>
                    <span class="role-badge">Staff</span>
                    <i class="bi bi-chevron-down" style="opacity:.7;font-size:.7rem;"></i>
                </button>
                <ul class="dropdown-menu dropdown-menu-end top-user-menu">
                    <li>
                        <a class="dropdown-item" href="<%=ctx%>/profile">
                            <i class="bi bi-id-card"></i><span>Thông tin cá nhân</span>
                        </a>
                    </li>
                    <li><hr class="dropdown-divider"/></li>
                    <li>
                        <a class="dropdown-item text-danger" href="<%=ctx%>/auth/LogoutServlet">
                            <i class="bi bi-box-arrow-right"></i><span>Đăng xuất</span>
                        </a>
                    </li>
                </ul>
            </div>

        </div>
    </div>
</header>

<!-- PAGE BODY -->
<div class="page-wrapper">

    <!-- Alert success/error từ param -->
    <c:if test="${not empty param.success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle"></i> ${param.success}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle"></i> ${param.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Header line "Lịch sử gọi món - Bàn X" -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
        <h2 class="m-0" style="font-size:1.1rem;font-weight:600;color:var(--ink-900);display:flex;align-items:center;gap:.5rem;">
            <i class="fas fa-history"></i>
            <span>Lịch sử gọi món • <%=tableLabel%></span>
        </h2>
        <div class="d-flex flex-wrap gap-2">
            <a href="<%=ctx%>/tables" class="btn btn-outline-secondary btn-sm d-flex align-items-center gap-2" onclick="returnToTableMap()">
                <i class="fas fa-arrow-left"></i> <span>Quay lại</span>
            </a>
            <a href="<%=ctx%>/tables?action=map" class="btn btn-outline-primary btn-sm d-flex align-items-center gap-2">
                <i class="fas fa-map"></i> <span>Bản đồ bàn</span>
            </a>
        </div>
    </div>

    <!-- Prepare counters using JSTL -->
    <c:set var="totalCount" value="0" />
    <c:set var="readyCount" value="0" />
    <c:set var="servedCount" value="0" />
    <c:set var="cookingCount" value="0" />

    <c:forEach var="item" items="${history}">
        <c:set var="totalCount" value="${totalCount + 1}" />
        <c:if test="${item.status == 'READY'}">
            <c:set var="readyCount" value="${readyCount + 1}" />
        </c:if>
        <c:if test="${item.status == 'SERVED'}">
            <c:set var="servedCount" value="${servedCount + 1}" />
        </c:if>
        <c:if test="${item.status == 'COOKING'}">
            <c:set var="cookingCount" value="${cookingCount + 1}" />
        </c:if>
    </c:forEach>

    <!-- Summary cards row -->
    <div class="row summary-row mb-4">
        <div class="col-6 col-md-3">
            <div class="summary-card">
                <div class="summary-number text-primary">${totalCount}</div>
                <div class="summary-label">Tổng số món</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="summary-card">
                <div class="summary-number text-success">${readyCount}</div>
                <div class="summary-label">Sẵn sàng phục vụ</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="summary-card">
                <div class="summary-number text-info">${servedCount}</div>
                <div class="summary-label">Đã phục vụ</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="summary-card">
                <div class="summary-number text-warning">${cookingCount}</div>
                <div class="summary-label">Đang chế biến</div>
            </div>
        </div>
    </div>

    <!-- History table -->
    <div class="history-card-shell">
        <div class="history-card-head">
            <i class="fas fa-list"></i>
            <span>Chi tiết món đã gọi</span>
        </div>

        <div class="history-card-body">
            <c:choose>
                <c:when test="${empty history}">
                    <div class="alert alert-info text-center" style="font-size:.8rem;">
                        <i class="fas fa-info-circle"></i>
                        <span>Chưa có món nào được gọi cho bàn này.</span>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-hover history-table align-middle mb-0">
                            <thead>
                            <tr>
                                <th>Món ăn</th>
                                <th class="text-center">SL</th>
                                <th>Mục</th>
                                <th>Trạng thái</th>
                                <th>Ưu tiên</th>
                                <th>Ghi chú</th>
                                <th>Thời gian</th>
                                <th class="text-end">Hành động</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="item" items="${history}">
                                <tr>
                                    <!-- Tên món -->
                                    <td style="min-width:160px;">
                                        <strong style="font-size:.8rem;">${item.menuItemName}</strong>
                                    </td>

                                    <!-- Số lượng -->
                                    <td class="text-center" style="width:60px;">${item.quantity}</td>

                                    <!-- Course -->
                                    <td style="white-space:nowrap;">
                                        <span class="course-badge">${item.course}</span>
                                    </td>

                                    <!-- Trạng thái -->
                                    <td style="white-space:nowrap;">
                                        <c:choose>
                                            <c:when test="${item.status == 'NEW'}">
                                                <span class="status-badge status-new">Mới</span>
                                            </c:when>
                                            <c:when test="${item.status == 'COOKING'}">
                                                <span class="status-badge status-cooking">Đang nấu</span>
                                            </c:when>
                                            <c:when test="${item.status == 'READY'}">
                                                <span class="status-badge status-ready">Sẵn sàng</span>
                                            </c:when>
                                            <c:when test="${item.status == 'SERVED'}">
                                                <span class="status-badge status-served">Đã phục vụ</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge status-cancelled">${item.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Ưu tiên -->
                                    <td style="white-space:nowrap;">
                                        <c:choose>
                                            <c:when test="${item.priority == 'NORMAL'}">
                                                <span class="priority-badge priority-normal">Bình thường</span>
                                            </c:when>
                                            <c:when test="${item.priority == 'HIGH'}">
                                                <span class="priority-badge priority-high">Cao</span>
                                            </c:when>
                                            <c:when test="${item.priority == 'URGENT'}">
                                                <span class="priority-badge priority-urgent">Khẩn cấp</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="priority-badge priority-normal">${item.priority}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Ghi chú -->
                                    <td style="min-width:140px;">
                                        <c:if test="${not empty item.specialInstructions}">
                                            <i class="fas fa-sticky-note"></i>
                                            <span style="font-size:.8rem;">${item.specialInstructions}</span>
                                        </c:if>
                                    </td>

                                    <!-- Thời gian -->
                                    <td style="white-space:nowrap;font-size:.75rem;color:var(--ink-500);">
                                        <c:if test="${not empty item.createdAt}">
                                            ${item.createdAt}
                                        </c:if>
                                    </td>

                                    <!-- Hành động -->
                                    <td class="text-end" style="width:140px;">
                                        <c:if test="${item.status == 'READY'}">
                                            <button
                                                class="btn btn-sm btn-serve d-inline-flex align-items-center gap-2"
                                                onclick="openServeModal(${item.orderItemId})">
                                                <i class="fas fa-check"></i>
                                                <span>Phục vụ</span>
                                            </button>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Toast container -->
<div class="toast-wrap" id="toastWrap"></div>

<!-- Serve confirm modal -->
<div class="modal fade" id="serveModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:360px;">
        <div class="modal-content" style="border-radius:12px;">
            <div class="modal-header">
                <h5 class="modal-title" style="font-size:1rem;font-weight:600;">
                    Xác nhận phục vụ
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"
                        aria-label="Close"></button>
            </div>
            <div class="modal-body modal-confirm-body">
                Bạn chắc chắn đã phục vụ món này cho khách chưa?
            </div>
            <div class="modal-footer d-flex justify-content-between">
                <button type="button" class="btn btn-outline-secondary btn-sm"
                        data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-serve btn-sm d-flex align-items-center gap-2"
                        onclick="submitServe()">
                    <i class="fas fa-check"></i> <span>Xác nhận</span>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    var CTX = '<%=ctx%>';
    var pendingServeItemId = null;

    // Toast helpers
    function showToast(msg){
        var wrap = document.getElementById('toastWrap');
        var card = document.createElement('div');
        card.className = 'toast-card';
        card.innerHTML =
            '<div class="toast-icon"><i class="bi bi-check-lg"></i></div>'+
            '<div class="toast-body">'+ msg +'</div>'+
            '<div class="toast-close" onclick="closeToast(this)">✕</div>';

        wrap.appendChild(card);
        requestAnimationFrame(function(){
            card.classList.add('show');
        });
        setTimeout(function(){
            hideToast(card);
        },3000);
    }
    function closeToast(el){
        var card = el.closest('.toast-card');
        hideToast(card);
    }
    function hideToast(card){
        if(!card) return;
        card.classList.remove('show');
        setTimeout(function(){
            if(card.parentNode){
                card.parentNode.removeChild(card);
            }
        },200);
    }

    // Open modal & store which item to serve
    function openServeModal(itemId){
        pendingServeItemId = itemId;
        var modalEl = document.getElementById('serveModal');
        var modal = new bootstrap.Modal(modalEl);
        modal.show();
    }

    // Đánh dấu đã xem lịch sử bàn này khi vào trang
    (function() {
        var qs = new URLSearchParams(window.location.search);
        var tableId = qs.get('tableId') || '';
        if (tableId) {
            sessionStorage.setItem('viewed_table_' + tableId, 'true');
        }
    })();

    // Hàm quay lại bản đồ bàn (đảm bảo đánh dấu đã xem)
    function returnToTableMap() {
        var qs = new URLSearchParams(window.location.search);
        var tableId = qs.get('tableId') || '';
        if (tableId) {
            sessionStorage.setItem('viewed_table_' + tableId, 'true');
        }
        window.location.href = '<%=ctx%>/tables';
        return false;
    }

    // Submit serve action
    function submitServe(){
        if(!pendingServeItemId){ return; }

        // tableId lấy từ query
        var qs = new URLSearchParams(window.location.search);
        var tableId = qs.get('tableId') || '';

        // tạo form post
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = CTX + '/orders/' + pendingServeItemId + '/serve';

        var hidden = document.createElement('input');
        hidden.type = 'hidden';
        hidden.name = 'tableId';
        hidden.value = tableId;
        form.appendChild(hidden);

        document.body.appendChild(form);

        // feedback nhẹ
        showToast('Đang cập nhật trạng thái phục vụ...');
        form.submit();
    }
</script>
</body>
</html>
