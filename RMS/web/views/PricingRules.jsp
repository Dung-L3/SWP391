<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    request.setAttribute("page", "pricing");
    request.setAttribute("overlayNav", false);
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Quy tắc giá động | RMSG4</title>
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

    <!-- Base site styles (header/footer layout etc) -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <style>
        /************************************
         * COLOR SYSTEM / THEME
         ************************************/
        :root {
            /* surfaces */
            --bg-app: #f5f6fa;
            --bg-grad-1: rgba(88, 80, 200, 0.08);
            --bg-grad-2: rgba(254, 161, 22, 0.06);

            --panel-light-top: #fafaff;
            --panel-light-bottom: #ffffff;
            --panel-dark: #1f2535;
            --panel-dark-border: rgba(255,255,255,.08);

            /* ink */
            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            /* accent */
            --accent:#FEA116; /* vàng champagne */
            --accent-soft:rgba(254,161,22,.12);
            --accent-border:rgba(254,161,22,.45);

            /* brand / primary */
            --brand:#4f46e5;
            --brand-border:#6366f1;
            --brand-bg-soft:#eef2ff;

            /* success / danger */
            --success:#16a34a;
            --success-soft:#d1fae5;
            --danger:#dc2626;

            /* lines / glow */
            --line:#e5e7eb;
            --line-dark:#2d354d;
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
        @media (max-width: 992px) {
            .app-shell {
                grid-template-columns: 1fr;
            }
            #sidebar {
                position: fixed;
                inset: 0 30% 0 0;
                transform: translateX(-100%);
                transition: transform .2s ease;
                z-index: 1040;
                max-width: var(--sidebar-width);
                box-shadow: 24px 0 60px rgba(0,0,0,.7);
            }
            #sidebar.open {
                transform: translateX(0);
            }
        }

        main.main-pane {
            padding: 28px 32px 44px;
        }

        /************************************
         * TOP POS BAR (dark header inside page)
         ************************************/
        .pos-topbar {
            position: relative;
            background: radial-gradient(circle at 0% 0%, #2a3048 0%, #1b1e2c 70%);
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
        }

        .pos-left .title-row {
            display: flex;
            align-items: center;
            gap: .6rem;
            font-weight: 600;
            font-size: 1rem;
            line-height: 1.35;
            color: #fff;
        }
        .pos-left .title-row i {
            color: var(--accent);
            font-size: 1.1rem;
        }
        .pos-left .sub {
            margin-top: 4px;
            font-size: .8rem;
            color: var(--ink-400);
        }

        .pos-right {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: .75rem;
            color: #fff;
        }

        .user-chip {
            display: flex;
            align-items: center;
            gap: .5rem;
            background: rgba(255,255,255,.06);
            border: 1px solid rgba(255,255,255,.18);
            border-radius: var(--radius-md);
            padding: 6px 10px;
            font-size: .8rem;
            line-height: 1.2;
            color: #fff;
            font-weight: 500;
        }
        .user-chip .role-badge {
            background: var(--accent);
            color: #1e1e2f;
            border-radius: var(--radius-sm);
            padding: 2px 6px;
            font-size: .7rem;
            font-weight: 600;
            line-height: 1.2;
        }

        .btn-toggle-sidebar {
            display: none;
        }
        @media(max-width:992px){
            .btn-toggle-sidebar{
                display: inline-flex;
                align-items: center;
                gap: .4rem;
                background: transparent;
                border: 1px solid rgba(255,255,255,.3);
                color:#fff;
                font-size:.8rem;
                line-height:1.2;
                border-radius: var(--radius-sm);
                padding:6px 10px;
            }
            .btn-toggle-sidebar:hover {
                background: rgba(255,255,255,.07);
            }
        }

        /************************************
         * PRICING LAYOUT STATES
         * - default: full menu grid
         * - .picked: left becomes vertical dark sidebar,
         *            right shows detail cards
         ************************************/
        .pricing-layout {
            display: flex;
            flex-wrap: nowrap;
            gap: 1.5rem;
            transition: all .25s ease;
        }
        @media(max-width:768px){
            .pricing-layout.picked {
                flex-direction: column;
            }
        }

        /************************************
         * MENU PICKER (LEFT COLUMN)
         ************************************/
        .menu-picker {
            background: linear-gradient(to bottom right,
                         var(--panel-light-top) 0%,
                         var(--panel-light-bottom) 100%);
            border-radius: var(--radius-lg);
            border: 1px solid var(--line);
            box-shadow: var(--shadow-card);
            padding: 1rem 1rem 1.25rem;
            width: 100%;
            max-height: none;
            transition: all .25s ease;
            position: relative;
        }

        .pricing-layout.picked .menu-picker {
            flex: 0 0 260px;
            max-width: 260px;
            max-height: calc(100vh - 140px);
            overflow-y: auto;
            scrollbar-width: thin;
            scrollbar-color: var(--brand-border) rgba(0,0,0,0);

            background: linear-gradient(to bottom right, #2a3048 0%, #1f2535 60%);
            border: 1px solid var(--panel-dark-border);
            color: #fff;
            box-shadow: 0 32px 64px rgba(0,0,0,.7);
            padding: 14px 14px 18px;
        }

        /* Card header inside menu-picker */
        .picker-head {
            display: flex;
            flex-direction: column;
            gap: .4rem;
            margin-bottom: 1rem;
        }

        .picker-title {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: .5rem;
            font-weight: 600;
            font-size: 1rem;
            color: var(--ink-900);
        }
        .picker-title i {
            color: var(--accent);
        }
        .pricing-layout.picked .picker-title {
            color: #fff;
        }
        .pricing-layout.picked .picker-title i {
            color: var(--accent);
        }

        .picker-desc {
            font-size: .8rem;
            color: var(--ink-500);
        }
        .pricing-layout.picked .picker-desc {
            color: var(--ink-400);
        }

        /* GRID (unpicked) vs LIST (picked) */
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(min(250px,100%), 1fr));
            gap: 1rem;
            transition: all .25s ease;
        }
        .pricing-layout.picked .menu-grid {
            display: flex;
            flex-direction: column;
            gap: .6rem;
        }

        /* FOOD CARD */
        .food-card {
            background: #ffffff;
            border-radius: var(--radius-md);
            border: 2px solid transparent;
            box-shadow: 0 20px 48px rgba(15,23,42,.08);
            padding: .9rem .9rem .8rem;
            cursor: pointer;
            transition: all .18s ease;
            color: var(--ink-900);
            position: relative;
        }

        .food-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 28px 60px rgba(0,0,0,.12);
        }

        .food-card.active {
            border-color: var(--brand-border);
            background: radial-gradient(circle at 0% 0%, #ffffff 0%, #f5f5ff 60%);
            box-shadow: 0 32px 72px rgba(99,102,241,.28);
            cursor: default;
        }

        /* picked state overrides (dark list) */
        .pricing-layout.picked .food-card {
            background: rgba(255,255,255,.03);
            color: #fff;
            border: 2px solid transparent;
            border-radius: var(--radius-md);
            box-shadow: none;
            padding: .75rem .75rem .65rem;
            transition: background .18s ease, box-shadow .18s ease, border .18s ease;
        }
        .pricing-layout.picked .food-card:hover {
            background: rgba(255,255,255,.07);
            box-shadow: none;
            transform: none;
        }
        .pricing-layout.picked .food-card.active {
            background: rgba(74,222,128,.08);
            border-color: #4ade80;
            box-shadow: 0 0 16px rgba(74,222,128,.7);
            color: #fff;
        }

        .food-top-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: .5rem;
        }

        .food-meta {
            display:flex;
            flex-direction:column;
            gap:.2rem;
        }

        .food-name {
            font-size: .95rem;
            font-weight: 600;
            line-height: 1.3;
            color: var(--ink-900);
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.4rem;
        }

        .pricing-layout.picked .food-name {
            color:#fff;
            font-size: .9rem;
        }

        .inline-flag {
            display: none;
            background: var(--accent);
            color:#1f1f2b;
            font-size: .65rem;
            font-weight:600;
            line-height:1.2;
            border-radius: var(--radius-sm);
            padding:2px 6px;
        }
        .food-card.active .inline-flag { display:inline-block; }

        .food-id {
            font-size: .7rem;
            color: var(--ink-500);
        }
        .pricing-layout.picked .food-id {
            color:#9ca3af;
            font-size:.7rem;
        }

        .chip-sale {
            font-size: .7rem;
            line-height:1.2;
            background: #fde68a;
            color:#78350f;
            font-weight:600;
            border-radius: var(--radius-sm);
            padding:.25rem .5rem;
            border:1px solid rgba(250,204,21,.4);
        }
        .pricing-layout.picked .chip-sale{
            font-size:.65rem;
            background:#fde047;
            color:#78350f;
        }

        .price-block {
            margin-top: .7rem;
            display:flex;
            flex-direction:column;
            gap:.4rem;
            font-size: .85rem;
        }

        .base-line {
            font-size: .75rem;
            color: var(--ink-500);
        }
        .pricing-layout.picked .base-line {
            color:#9ca3af;
            font-size:.7rem;
        }

        .cur-line {
            font-size: .9rem;
            font-weight:600;
            color: var(--success);
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.4rem;
        }
        .pricing-layout.picked .cur-line {
            color:#4ade80;
            font-size:.8rem;
            font-weight:600;
        }

        .now-badge {
            font-size: .65rem;
            line-height:1.2;
            border-radius: var(--radius-sm);
            padding:.2rem .45rem;
            border:1px solid rgba(0,0,0,.4);
            background:#fff;
            color:#111;
            font-weight:500;
        }
        .pricing-layout.picked .now-badge{
            background:rgba(0,0,0,.2);
            color:#fff;
            border:1px solid rgba(255,255,255,.4);
        }

        /************************************
         * RIGHT DETAIL COLUMN
         ************************************/
        .pricing-detail {
            flex: 1;
            min-width: 0;
            display: none;
            flex-direction: column;
            gap: 1.5rem;
            transition: all .25s ease;
        }
        .pricing-layout.picked .pricing-detail {
            display: flex;
        }

        .detail-top {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }
        @media(max-width:992px){
            .detail-top { grid-template-columns:1fr; }
        }

        .detail-card {
            background: radial-gradient(circle at 0% 0%, #ffffff 0%, #fafaff 70%);
            border-radius: var(--radius-lg);
            border: 1px solid var(--line);
            box-shadow: var(--shadow-card);
            padding: 1rem 1.25rem 1.25rem;
        }

        .detail-head {
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            gap:.75rem;
            margin-bottom:1rem;
        }

        .detail-head-left {
            display:flex;
            gap:.6rem;
            align-items:flex-start;
        }
        .detail-head-left i {
            color: var(--accent);
            font-size:1rem;
            margin-top:.2rem;
        }
        .detail-textgroup {
            display:flex;
            flex-direction:column;
            gap:.2rem;
        }
        .detail-title-line {
            font-weight:600;
            font-size:1rem;
            color:var(--ink-900);
            line-height:1.3;
        }
        .detail-sub {
            font-size:.8rem;
            color:var(--ink-500);
        }

        .back-all-btn {
            font-size:.75rem;
            font-weight:500;
            border-radius: var(--radius-sm);
            padding: .4rem .6rem;
        }

        .price-label-row {
            display:flex;
            align-items:center;
            gap:.5rem;
            font-size:.8rem;
            font-weight:600;
            color:var(--ink-700);
            margin-top:.5rem;
            text-transform:uppercase;
            letter-spacing:.02em;
        }
        .price-label-row::before {
            content:"";
            width:24px;
            height:2px;
            background:var(--accent);
            border-radius:2px;
            display:inline-block;
        }

        .cur-price-number {
            font-size:1.5rem;
            font-weight:700;
            line-height:1.2;
            color:var(--ink-900);
        }
        .cur-price-number.discounted {
            color:var(--success);
        }

        .muted-line {
            font-size:.8rem;
            color:var(--ink-500);
            margin-top:1rem;
            line-height:1.4;
        }

        /************************************
         * FORM NEW RULE
         ************************************/
        .form-label {
            font-size:.8rem;
            font-weight:600;
            color:var(--ink-700);
        }

        .small-hint {
            font-size:.7rem;
            line-height:1.3;
            color:var(--ink-500);
        }

        .btn-save-rule {
            background:#047857;
            border-color:#047857;
            font-weight:600;
            border-radius: var(--radius-sm);
        }
        .btn-save-rule:hover {
            background:#065f46;
            border-color:#065f46;
        }

        /************************************
         * RULE LIST TABLE
         ************************************/
        .rule-list-card {
            background: radial-gradient(circle at 0% 0%, #ffffff 0%, #fafaff 70%);
            border-radius: var(--radius-lg);
            border: 1px solid var(--line);
            box-shadow: var(--shadow-card);
            padding: 1rem 1rem 0;
        }

        .rule-card-head {
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            gap:.75rem;
            margin-bottom:1rem;
        }

        .rule-left-head {
            display:flex;
            flex-direction:column;
            gap:.4rem;
        }
        .rule-card-title {
            display:flex;
            align-items:center;
            flex-wrap:wrap;
            gap:.5rem;
            color:var(--ink-900);
            font-weight:600;
            font-size:1rem;
        }
        .rule-card-title i {
            color:var(--accent);
        }
        .rule-card-desc {
            font-size:.8rem;
            color:var(--ink-500);
            line-height:1.3;
        }

        .table thead th {
            background:#fffdf5;
            font-size:.7rem;
            font-weight:600;
            text-transform:uppercase;
            color:var(--ink-700);
            border-bottom:1px solid var(--line);
            white-space:nowrap;
        }
        .table td, .table th {
            vertical-align:middle;
            font-size:.8rem;
        }

        .rule-fixedprice-badge {
            display:inline-block;
            background: var(--accent-soft);
            color:#4b5563;
            border:1px solid var(--accent-border);
            font-size:.7rem;
            font-weight:600;
            border-radius: var(--radius-sm);
            padding:.3rem .5rem;
            white-space:nowrap;
        }

        .rule-status {
            background: var(--success-soft);
            color:#065f46;
            border:1px solid rgba(16,185,129,.25);
            font-size:.7rem;
            border-radius: var(--radius-sm);
            font-weight:600;
            padding:.3rem .6rem;
            white-space:nowrap;
        }

        @media(max-width:768px){
            .pricing-layout.picked .menu-picker {
                order:2;
                flex:none;
                width:100%;
                max-width:100%;
                max-height:none;
            }
            .pricing-layout.picked .pricing-detail {
                order:1;
            }
        }
        /* === ENHANCED LUXURY POS STYLE === */

/* Viền sáng nổi bật cho form và card */
.detail-card, .rule-list-card {
    position: relative;
    background: linear-gradient(to bottom right, #ffffff 0%, #fafaff 80%);
    border: 1px solid rgba(99,102,241,.25);
    border-top: 4px solid var(--accent);
    box-shadow: 0 10px 40px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,.8);
    transition: all .25s ease;
}
.detail-card:hover, .rule-list-card:hover {
    box-shadow: 0 20px 60px rgba(254,161,22,.2), inset 0 1px 0 rgba(255,255,255,1);
    transform: translateY(-2px);
}

/* Header bar mềm trên mỗi card */
.detail-card::before, .rule-list-card::before {
    content:"";
    position:absolute;
    top:0;
    left:0;
    width:100%;
    height:5px;
    background: linear-gradient(90deg, var(--accent), var(--brand));
    border-radius: 8px 8px 0 0;
    opacity:.8;
}

/* Form input nổi bật */
.form-control, .form-select {
    border-radius: 10px;
    border:1.5px solid #e2e8f0;
    transition: all .25s ease;
    background: #ffffff;
}
.form-control:focus, .form-select:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 0.25rem rgba(254,161,22,.25);
    background: #fffefc;
}

/* Nút lưu rule nâng cấp */
.btn-save-rule {
    background: linear-gradient(135deg, #16a34a, #0f766e);
    border: none;
    font-weight: 600;
    letter-spacing: .02em;
    box-shadow: 0 4px 20px rgba(22,163,74,.3);
    transition: all .25s ease;
}
.btn-save-rule:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 25px rgba(22,163,74,.4);
}

/* Bảng danh sách rule sang trọng */
.table-striped>tbody>tr:nth-of-type(odd)>* {
    background-color: #fcfcff;
}
.table-hover tbody tr:hover {
    background: linear-gradient(to right, rgba(254,161,22,.08), rgba(99,102,241,.08));
}

/* Hiệu ứng phát sáng khi chọn món */
.food-card.active {
    border-color: var(--accent);
    box-shadow: 0 0 25px rgba(254,161,22,.35);
}
.pricing-layout.picked .food-card.active {
    border-color: #4ade80;
    box-shadow: 0 0 25px rgba(74,222,128,.5);
}

/* Thêm gradient nhẹ vào phần header trong topbar */
.pos-topbar {
    background: linear-gradient(135deg, #1b1e2c, #2b2f46 60%, #1c1f30 100%);
    border:1px solid rgba(255,255,255,.1);
}

/* Form title highlight */
.detail-title-line, .rule-card-title {
    background: linear-gradient(to right, var(--accent), var(--brand));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}
    </style>
</head>

<body>
    <!-- Global site header (navbar top of page) -->
    <jsp:include page="/layouts/Header.jsp"/>

    <div class="app-shell">
        <!-- Global sidebar (như trang voucher) -->
        <aside id="sidebar">
            <jsp:include page="/layouts/sidebar.jsp"/>
        </aside>

        <!-- MAIN CONTENT AREA -->
        <main class="main-pane">
            <!-- Dark POS-style top bar -->
            <header class="pos-topbar">
                <div class="pos-left">
                    <div class="title-row">
                        <i class="bi bi-cash-coin"></i>
                        <span>Quy tắc giá động</span>
                    </div>
                    <div class="sub">
                        Chọn món bên trái → cấu hình khung giờ / giảm giá / hiệu lực.
                    </div>
                </div>
                <div class="pos-right">
                    <div class="user-chip">
                        <i class="bi bi-person-badge"></i>
                        <span>${sessionScope.user.fullName}</span>
                        <span class="role-badge">${sessionScope.user.roleName}</span>
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

            <!-- MAIN BODY: LEFT menu list + RIGHT detail -->
            <div class="pricing-layout ${not empty menuItem ? 'picked' : ''}">

                <!-- LEFT COLUMN: Danh sách món -->
                <aside class="menu-picker">
                    <div class="picker-head">
                        <div class="picker-title">
                            <i class="bi bi-list-ul"></i>
                            <span>Danh sách món hiện có</span>
                        </div>
                        <div class="picker-desc">Bấm vào món để chỉnh khuyến mãi</div>
                    </div>

                    <div class="menu-grid">
                        <c:forEach var="m" items="${menuItems}">
                            <c:set var="isSelected" value="${not empty menuItem && menuItem.itemId == m.itemId}"/>

                            <c:choose>
                                <c:when test="${isSelected}">
                                    <div class="food-card active">
                                        <div class="food-top-row">
                                            <div class="food-meta">
                                                <div class="food-name">
                                                    ${m.name}
                                                    <span class="inline-flag">Đang chỉnh</span>
                                                </div>
                                                <div class="food-id">#${m.itemId}</div>
                                            </div>

                                            <c:if test="${not empty m.displayPrice && m.displayPrice < m.basePrice}">
                                                <div class="chip-sale">SALE</div>
                                            </c:if>
                                        </div>

                                        <div class="price-block">
                                            <div class="base-line">
                                                Base:
                                                <fmt:formatNumber value="${m.basePrice}" type="number"/>đ
                                            </div>

                                            <div class="cur-line">
                                                <c:choose>
                                                    <c:when test="${not empty m.displayPrice}">
                                                        <span><fmt:formatNumber value="${m.displayPrice}" type="number"/>đ</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span><fmt:formatNumber value="${m.basePrice}" type="number"/>đ</span>
                                                    </c:otherwise>
                                                </c:choose>

                                                <span class="now-badge">hiện tại</span>
                                            </div>
                                        </div>
                                    </div>
                                </c:when>

                                <c:otherwise>
                                    <a href="<c:url value='/pricing-rules?action=list&itemId=${m.itemId}'/>"
                                       style="text-decoration:none;color:inherit;">
                                        <div class="food-card">
                                            <div class="food-top-row">
                                                <div class="food-meta">
                                                    <div class="food-name">${m.name}</div>
                                                    <div class="food-id">#${m.itemId}</div>
                                                </div>

                                                <c:if test="${not empty m.displayPrice && m.displayPrice < m.basePrice}">
                                                    <div class="chip-sale">SALE</div>
                                                </c:if>
                                            </div>

                                            <div class="price-block">
                                                <div class="base-line">
                                                    Base:
                                                    <fmt:formatNumber value="${m.basePrice}" type="number"/>đ
                                                </div>

                                                <div class="cur-line">
                                                    <c:choose>
                                                        <c:when test="${not empty m.displayPrice}">
                                                            <span><fmt:formatNumber value="${m.displayPrice}" type="number"/>đ</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span><fmt:formatNumber value="${m.basePrice}" type="number"/>đ</span>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <span class="now-badge">hiện tại</span>
                                                </div>
                                            </div>
                                        </div>
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <c:if test="${empty menuItems}">
                            <div class="text-center text-muted py-4" style="grid-column:1 / -1;">
                                Chưa có món nào.
                            </div>
                        </c:if>
                    </div>
                </aside>

                <!-- RIGHT COLUMN: Chi tiết món đã chọn -->
                <section class="pricing-detail">
                    <!-- 2 cards row: Giá hiện tại + Form tạo rule -->
                    <div class="detail-top">
                        <!-- CARD: Giá hiện tại -->
                        <div class="detail-card">
                            <div class="detail-head">
                                <div class="detail-head-left">
                                    <i class="bi bi-currency-exchange"></i>
                                    <div class="detail-textgroup">
                                        <div class="detail-title-line">Giá hiện tại của món</div>
                                        <div class="detail-sub">${menuItem.name}</div>
                                    </div>
                                </div>

                                <a href="<c:url value='/pricing-rules?action=list'/>"
                                   class="btn btn-outline-secondary btn-sm back-all-btn">
                                    <i class="bi bi-chevron-left me-1"></i> Tất cả món
                                </a>
                            </div>

                            <div class="price-label-row">Giá gốc (base price)</div>
                            <div class="cur-price-number mb-3">
                                <fmt:formatNumber value="${menuItem.basePrice}" type="number"/> đ
                            </div>

                            <div class="price-label-row">Giá đang áp dụng NGAY BÂY GIỜ</div>
                            <div class="cur-price-number ${not empty menuItem.displayPrice && menuItem.displayPrice lt menuItem.basePrice ? 'discounted' : ''}">
                                <c:choose>
                                    <c:when test="${not empty menuItem.displayPrice}">
                                        <fmt:formatNumber value="${menuItem.displayPrice}" type="number"/> đ
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${menuItem.basePrice}" type="number"/> đ
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="muted-line">
                                Nếu khác nhau ⇒ món này đang trong giờ khuyến mãi / happy hour.
                            </div>
                        </div>

                        <!-- CARD: Form thêm rule -->
                        <div class="detail-card">
                            <div class="detail-head">
                                <div class="detail-head-left">
                                    <i class="bi bi-plus-circle"></i>
                                    <div class="detail-textgroup">
                                        <div class="detail-title-line">Thêm quy tắc giá mới cho món này</div>
                                        <div class="detail-sub">Cài khung giờ / phần trăm giảm / khoảng ngày hiệu lực</div>
                                    </div>
                                </div>
                            </div>

                            <form method="post" action="<c:url value='/PricingRuleServlet'/>" class="row g-3">
                                <input type="hidden" name="action" value="add"/>
                                <input type="hidden" name="menu_item_id" value="${menuItem.itemId}"/>

                                <!-- Ngày trong tuần -->
                                <div class="col-md-4">
                                    <label class="form-label">Ngày trong tuần</label>
                                    <select class="form-select" name="day_of_week">
                                        <option value="ALL">Tất cả ngày</option>
                                        <option value="1">Thứ 2</option>
                                        <option value="2">Thứ 3</option>
                                        <option value="3">Thứ 4</option>
                                        <option value="4">Thứ 5</option>
                                        <option value="5">Thứ 6</option>
                                        <option value="6">Thứ 7</option>
                                        <option value="7">Chủ nhật</option>
                                    </select>
                                    <div class="small-hint mt-1">
                                        Chọn cụ thể 1 ngày, hoặc "Tất cả ngày".
                                    </div>
                                </div>

                                <!-- Giờ bắt đầu / kết thúc -->
                                <div class="col-md-4">
                                    <label class="form-label">Bắt đầu</label>
                                    <input type="time" name="start_time" class="form-control" required/>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Kết thúc</label>
                                    <input type="time" name="end_time" class="form-control" required/>
                                </div>

                                <!-- Giá cố định -->
                                <div class="col-md-6">
                                    <label class="form-label">Giá cố định (VND)</label>
                                    <input type="number" name="fixed_price" class="form-control" min="0"
                                           placeholder="vd 50000"/>
                                    <div class="small-hint mt-1">
                                        Nếu nhập giá cố định thì phần giảm giá bên phải sẽ bị bỏ qua.
                                    </div>
                                </div>

                                <!-- Giảm giá -->
                                <div class="col-md-6">
                                    <label class="form-label">Giảm giá</label>
                                    <select name="discount_type" class="form-select">
                                        <option value="">(không giảm)</option>
                                        <option value="PERCENT">% từ giá gốc</option>
                                        <option value="AMOUNT">Giảm số tiền cố định</option>
                                    </select>
                                    <input type="number" step="0.01" name="discount_value"
                                           class="form-control mt-1"
                                           placeholder="vd 20 hoặc 15000"/>
                                    <div class="small-hint mt-1">
                                        20 (%) = giảm 20%. 15000 = trừ 15.000đ.
                                    </div>
                                </div>

                                <!-- Ngày hiệu lực -->
                                <div class="col-md-6">
                                    <label class="form-label">Hiệu lực từ ngày</label>
                                    <input type="date" name="active_from" class="form-control" required/>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Đến ngày</label>
                                    <input type="date" name="active_to" class="form-control"/>
                                    <div class="small-hint mt-1">
                                        Để trống = vô thời hạn
                                    </div>
                                </div>

                                <div class="col-12 text-end">
                                    <button class="btn btn-success btn-save-rule">
                                        <i class="bi bi-save me-1"></i>LƯU RULE
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- CARD: Danh sách rule -->
                    <div class="rule-list-card">
                        <div class="rule-card-head">
                            <div class="rule-left-head">
                                <div class="rule-card-title">
                                    <i class="bi bi-card-list"></i>
                                    <span>Danh sách quy tắc giá của món: ${menuItem.name}</span>
                                </div>
                                <div class="rule-card-desc">
                                    Rule mới nhất sẽ ưu tiên áp dụng nếu trùng điều kiện.
                                </div>
                            </div>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>NGÀY ÁP DỤNG</th>
                                    <th>KHUNG GIỜ</th>
                                    <th>KHOẢNG HIỆU LỰC</th>
                                    <th>KIỂU GIÁ</th>
                                    <th>TRẠNG THÁI</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${empty rules}">
                                        <tr>
                                            <td colspan="6" class="text-center py-4 text-muted">
                                                <i class="bi bi-inbox" style="font-size:2rem;opacity:.3;"></i>
                                                <div class="small text-muted mt-2">
                                                    Chưa có quy tắc giá nào cho món này.
                                                </div>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="r" items="${rules}">
                                            <tr>
                                                <!-- ID -->
                                                <td class="fw-semibold">#${r.ruleId}</td>

                                                <!-- Ngày áp dụng -->
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${empty r.dayOfWeek or r.dayOfWeek == 0}">
                                                            <span class="badge bg-primary text-light" style="font-size:.7rem;">
                                                                Tất cả ngày
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.dayOfWeek == 7}">
                                                            <span class="badge bg-info text-dark" style="font-size:.7rem;">
                                                                Chủ nhật
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.dayOfWeek == 1}">
                                                            <span class="badge bg-info text-dark" style="font-size:.7rem;">
                                                                Thứ 2
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.dayOfWeek == 2}">
                                                            <span class="badge bg-info text-dark" style="font-size:.7rem;">
                                                                Thứ 3
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.dayOfWeek == 3}">
                                                            <span class="badge bg-info text-dark" style="font-size:.7rem;">
                                                                Thứ 4
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.dayOfWeek == 4}">
                                                            <span class="badge bg-info text-dark" style="font-size:.7rem;">
                                                                Thứ 5
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.dayOfWeek == 5}">
                                                            <span class="badge bg-info text-dark" style="font-size:.7rem;">
                                                                Thứ 6
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.dayOfWeek == 6}">
                                                            <span class="badge bg-info text-dark" style="font-size:.7rem;">
                                                                Thứ 7
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary text-dark" style="font-size:.7rem;">
                                                                N/A
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- Khung giờ -->
                                                <td class="text-nowrap">
                                                    <i class="bi bi-clock me-1"></i>
                                                    ${r.startTime} - ${r.endTime}
                                                </td>

                                                <!-- Khoảng hiệu lực -->
                                                <td class="text-nowrap">
                                                    <i class="bi bi-calendar3 me-1"></i>
                                                    ${r.activeFrom}
                                                    →
                                                    <c:choose>
                                                        <c:when test="${empty r.activeTo}">
                                                            <span class="text-muted">∞</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${r.activeTo}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- Kiểu giá -->
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty r.fixedPrice}">
                                                            <span class="rule-fixedprice-badge">
                                                                Giá cố định:
                                                                <fmt:formatNumber value='${r.fixedPrice}' type='number'/> đ
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:choose>
                                                                <c:when test="${r.discountType == 'PERCENT'}">
                                                                    <div class="text-success fw-semibold">
                                                                        Giảm ${r.discountValue}%
                                                                    </div>
                                                                    <div class="small text-muted">so với giá gốc</div>
                                                                </c:when>
                                                                <c:when test="${r.discountType == 'AMOUNT'}">
                                                                    <div class="text-success fw-semibold">
                                                                        Giảm
                                                                        <fmt:formatNumber value='${r.discountValue}' type='number'/> đ
                                                                    </div>
                                                                    <div class="small text-muted">trừ thẳng vào giá gốc</div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">Không giảm</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- Trạng thái -->
                                                <td class="text-nowrap">
                                                    <span class="rule-status">
                                                        Đang áp dụng
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>
            </div>
        </main>
    </div>

    <!-- Global footer -->
    <jsp:include page="/layouts/Footer.jsp"/>

    <!-- JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleSidebar() {
            var el = document.getElementById('sidebar');
            if (el) el.classList.toggle('open');
        }

        // auto-close bootstrap alerts
        setTimeout(function () {
            var alerts = document.querySelectorAll('.alert');
            alerts.forEach(function (al) {
                var bsAlert = new bootstrap.Alert(al);
                bsAlert.close();
            });
        }, 5000);
    </script>
</body>
</html>
