<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    Models.User user = (Models.User) session.getAttribute("user");
    String fullName = (user != null)
            ? (user.getFirstName() + " " + user.getLastName())
            : "Chef";
    String shortName = (user != null)
            ? user.getFirstName()
            : "Chef";
    String roleName = (user != null && user.getRoleName() != null)
            ? user.getRoleName()
            : "Chef";
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KDS | Kitchen Display System | RMSG4</title>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <!-- Icons / Bootstrap -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet"/>

    <style>
        /************************************
         * DESIGN TOKENS
         ************************************/
        :root {
            --bg-app:#f5f6fa;
            --bg-grad-1:rgba(88,80,200,.08);
            --bg-grad-2:rgba(254,161,22,.06);

            --panel-dark:#1f2535;
            --panel-dark-border:rgba(255,255,255,.08);

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.12);
            --accent-border:rgba(254,161,22,.45);

            --brand:#4f46e5;
            --brand-border:#6366f1;
            --brand-bg-soft:#eef2ff;

            --success:#16a34a;

            --radius-lg:20px;
            --radius-md:12px;
            --radius-sm:6px;
        }

        /************************************
         * GLOBAL BACKGROUND
         ************************************/
        body {
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            font-family:"Heebo",system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",sans-serif;
            color:var(--ink-900);
        }

        main {
            max-width:1400px;
            margin:0 auto;
            padding:24px 16px 48px;
        }

        /************************************
         * WAITER-STYLE TOP BAR (pos-topbar-shell)
         * -> thay cho navbar đỏ
         ************************************/
        .pos-topbar-shell{
            background:
                radial-gradient(circle at 0% 0%, rgba(255,255,255,.08) 0%, rgba(0,0,0,0) 60%),
                linear-gradient(135deg,#111827 0%,#1e2537 40%,#2b3245 100%);
            border:1px solid rgba(255,255,255,.08);
            border-radius:8px;
            box-shadow:0 28px 64px rgba(0,0,0,.6);

            color:#fff;
            font-family:"Heebo",system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",sans-serif;
            padding:.75rem 1rem;
            margin:12px auto 24px;
            max-width:1400px;

            display:flex;
            flex-wrap:wrap;
            align-items:flex-start;
            justify-content:space-between;
            row-gap:.75rem;
        }

        /* LEFT: brand / description */
        .pos-left-block{
            display:flex;
            align-items:flex-start;
            gap:.75rem;
            min-width:0;
        }
        .pos-icon-box{
            background:rgba(255,255,255,.07);
            border:1px solid rgba(255,255,255,.18);
            color:#fff;
            width:32px;
            height:32px;
            border-radius:8px;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:.9rem;
            line-height:1;
            box-shadow:0 16px 32px rgba(0,0,0,.7);
        }
        .pos-brand-text{
            display:flex;
            flex-direction:column;
            line-height:1.3;
        }
        .pos-brand-row{
            display:flex;
            flex-wrap:wrap;
            align-items:baseline;
            gap:.4rem;
            color:#fff;
            font-size:.95rem;
            font-weight:600;
            white-space:nowrap;
        }
        .pos-brand-row .dot{
            opacity:.4;
            font-weight:400;
        }
        .pos-sub-line{
            font-size:.7rem;
            line-height:1.3;
            color:rgba(255,255,255,.6);
            white-space:nowrap;
        }

        /* RIGHT: actions pills */
        .pos-action-block{
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.5rem .75rem;
            margin-left:auto;
        }
        .top-pill{
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.18);
            border-radius:.5rem;
            padding:.45rem .6rem;
            color:#fff;
            font-size:.8rem;
            line-height:1.2;
            font-weight:500;
            box-shadow:0 20px 40px rgba(0,0,0,.6);
            display:inline-flex;
            align-items:center;
            gap:.4rem;
            text-decoration:none;
            white-space:nowrap;
            transition:all .18s ease;
        }
        .top-pill i{
            font-size:.8rem;
            line-height:1;
            color:#fff;
        }
        .top-pill:hover{
            background:rgba(255,255,255,.1);
            text-decoration:none;
            color:#fff;
            box-shadow:0 28px 60px rgba(0,0,0,.7);
        }

        .chef-identity{
            display:flex;
            align-items:center;
            gap:.5rem;
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.18);
            border-radius:.5rem;
            padding:.45rem .6rem;
            font-size:.8rem;
            line-height:1.2;
            font-weight:500;
            color:#fff;
            box-shadow:0 20px 40px rgba(0,0,0,.6);
            white-space:nowrap;
        }
        .chef-identity i{
            color:#fff;
            font-size:.8rem;
            line-height:1;
        }
        .chef-role-badge{
            background:var(--accent);
            color:#1e1e2f;
            border-radius:.4rem;
            padding:.2rem .45rem;
            font-size:.7rem;
            line-height:1.2;
            font-weight:600;
            box-shadow:0 8px 16px rgba(254,161,22,.4);
            border:1px solid rgba(0,0,0,.15);
        }

        .dropdown-toggle.top-pill-user{
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.18);
            border-radius:.5rem;
            padding:.45rem .6rem;
            color:#fff;
            font-size:.8rem;
            line-height:1.2;
            font-weight:500;
            display:inline-flex;
            align-items:center;
            gap:.4rem;
            box-shadow:0 20px 40px rgba(0,0,0,.6);
        }
        .dropdown-toggle.top-pill-user i{
            font-size:.8rem;
            line-height:1;
            color:#fff;
        }
        .dropdown-toggle.top-pill-user:hover{
            background:rgba(255,255,255,.1);
            border-color:rgba(255,255,255,.4);
            color:#fff;
        }
        .dropdown-menu.top-user-menu{
            font-size:.8rem;
            border-radius:.5rem;
            border:1px solid rgba(0,0,0,.08);
            box-shadow:0 24px 48px rgba(0,0,0,.45);
            min-width:180px;
        }
        .dropdown-menu.top-user-menu .dropdown-item{
            display:flex;
            align-items:center;
            gap:.5rem;
            font-weight:500;
            padding:.5rem .9rem;
        }
        .dropdown-menu.top-user-menu .dropdown-item i{
            font-size:.8rem;
            width:.9rem;
            text-align:center;
        }
        .dropdown-menu.top-user-menu .dropdown-item.text-danger:hover{
            background:rgba(220,53,69,.08);
            color:#b91c1c;
        }

        @media(max-width:992px){
            .pos-topbar-shell{
                flex-direction:column;
                align-items:stretch;
            }
            .pos-action-block{
                margin-left:0;
            }
        }

        /************************************
         * KDS TOPBAR (section headline dưới)
         ************************************/
        .kds-topbar {
            background:linear-gradient(135deg,#1b1e2c 0%,#2b2f46 60%,#1c1f30 100%);
            border-radius:var(--radius-md);
            border:1px solid rgba(255,255,255,.1);
            box-shadow:0 32px 64px rgba(0,0,0,.6);
            color:#fff;
            padding:16px 20px;
            margin-bottom:24px;

            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            row-gap:1rem;
        }

        .kds-left {
            display:flex;
            flex-direction:column;
            gap:.5rem;
        }
        .kds-title-row {
            display:flex;
            align-items:center;
            gap:.6rem;
            font-weight:600;
            font-size:1rem;
            line-height:1.35;
            color:#fff;
        }
        .kds-title-row i {
            color:var(--accent);
            font-size:1.1rem;
        }
        .kds-sub {
            font-size:.8rem;
            color:var(--ink-400);
        }

        .kds-right {
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.75rem;
            color:#fff;
        }
        .usr-chip {
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.18);
            border-radius:var(--radius-md);
            padding:6px 10px;
            font-size:.8rem;
            line-height:1.2;
            font-weight:500;
            display:flex;
            align-items:center;
            gap:.5rem;
            color:#fff;
        }
        .usr-role {
            background:var(--accent);
            color:#1e1e2f;
            border-radius:var(--radius-sm);
            padding:2px 6px;
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
        }

        /************************************
         * FILTER CARD
         ************************************/
        .filter-card {
            position:relative;
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border:1px solid rgba(99,102,241,.25);
            border-radius:var(--radius-lg);
            box-shadow:0 10px 40px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,.8);
            padding:16px 20px 20px;
            margin-bottom:24px;
        }
        .filter-card::before{
            content:"";
            position:absolute;
            top:0;left:0;
            width:100%;height:5px;
            background:linear-gradient(90deg,var(--accent),var(--brand));
            border-radius:8px 8px 0 0;
            opacity:.8;
        }

        .filter-headline {
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            row-gap:.75rem;
            margin-bottom:1rem;
        }
        .filter-head-left{
            display:flex;
            flex-wrap:wrap;
            gap:.6rem;
            align-items:flex-start;
        }
        .filter-icon{
            color:var(--accent);
            font-size:1rem;
            line-height:1;
            margin-top:.2rem;
        }
        .filter-texts{
            display:flex;
            flex-direction:column;
            gap:.25rem;
        }
        .filter-title{
            font-weight:600;
            font-size:.9rem;
            color:var(--ink-900);
            line-height:1.3;
        }
        .filter-desc{
            font-size:.8rem;
            color:var(--ink-500);
            line-height:1.3;
        }

        .live-clock-chip{
            background:var(--accent-soft);
            border:1px solid var(--accent-border);
            border-radius:var(--radius-sm);
            color:#7a4b00;
            font-size:.8rem;
            font-weight:600;
            line-height:1.2;
            padding:.4rem .6rem;
            display:flex;
            align-items:center;
            gap:.4rem;
        }
        .live-clock-chip i{
            color:var(--accent);
        }

        .filter-form-label{
            font-size:.7rem;
            font-weight:600;
            color:var(--ink-700);
            text-transform:uppercase;
            letter-spacing:.03em;
            margin-bottom:.4rem;
        }

        .form-select,
        .form-control{
            border-radius:10px;
            border:1.5px solid #e2e8f0;
            font-size:.9rem;
            line-height:1.4;
            background:#ffffff;
            color:#0f172a;
            transition:all .25s ease;
        }
        .form-select:focus,
        .form-control:focus{
            border-color:var(--accent);
            box-shadow:0 0 0 0.25rem rgba(254,161,22,.25);
            background:#fffefc;
        }

        .filter-actions{
            display:flex;
            flex-wrap:wrap;
            gap:.5rem;
            padding-top:.8rem;
        }
        .btn-filter{
            border:none;
            background:linear-gradient(135deg,#4f46e5 0%,#1f2937 100%);
            color:#fff;
            font-size:.8rem;
            font-weight:600;
            line-height:1.2;
            padding:.6rem .9rem;
            min-width:110px;
            border-radius:var(--radius-sm);
            box-shadow:0 4px 20px rgba(0,0,0,.2);
            display:inline-flex;
            align-items:center;
            justify-content:center;
            gap:.4rem;
        }
        .btn-filter.clear-btn{
            background:linear-gradient(135deg,#6b7280 0%,#374151 100%);
        }
        .btn-filter:hover{
            filter:brightness(1.05);
        }

        /************************************
         * SECTION BAR
         ************************************/
        .section-bar{
            background:linear-gradient(135deg,#1b1e2c 0%,#2b2f46 60%,#1c1f30 100%);
            border:1px solid rgba(255,255,255,.08);
            border-radius:var(--radius-md);
            box-shadow:0 24px 48px rgba(0,0,0,.5);
            color:#fff;
            padding:10px 16px;
            font-size:.8rem;
            font-weight:600;
            text-transform:uppercase;
            letter-spacing:.03em;
            line-height:1.3;
            display:flex;
            align-items:center;
            gap:.5rem;
            margin-bottom:1rem;
        }
        .section-bar i{
            color:var(--accent);
        }

        /************************************
         * TICKET GRID
         ************************************/
        .tickets-grid{
            display:flex;
            flex-wrap:wrap;
            gap:1rem;
            margin-bottom:2rem;
        }

        /************************************
         * TICKET CARD
         ************************************/
        .ticket-card{
            position:relative;
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border:1px solid rgba(99,102,241,.25);
            border-radius:var(--radius-lg);
            box-shadow:0 10px 30px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,.8);
            padding:16px 16px 14px;
            flex:0 0 340px;
            max-width:340px;
            min-width:300px;
        }
        .ticket-card::before{
            content:"";
            position:absolute;
            top:0;left:0;
            width:100%;height:4px;
            background:linear-gradient(90deg,var(--accent),var(--brand));
            border-radius:8px 8px 0 0;
            opacity:.8;
        }
        .ticket-card.ready-glow{
            border-color:#4ade80;
            box-shadow:0 0 18px rgba(74,222,128,.45),0 10px 30px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,.8);
        }
        .ticket-card.ready-glow::before{
            background:linear-gradient(90deg,#4ade80,#16a34a);
        }

        .ticket-headline{
            display:flex;
            justify-content:space-between;
            align-items:flex-start;
            flex-wrap:wrap;
            row-gap:.5rem;
            margin-bottom:.75rem;
            font-size:.8rem;
            color:var(--ink-900);
        }
        .ticket-id-line{
            display:flex;
            align-items:center;
            gap:.4rem;
            font-weight:600;
            font-size:.8rem;
            color:var(--ink-900);
        }
        .ticket-id-line i{
            color:var(--accent);
            font-size:.9rem;
        }
        .ticket-rightmeta{
            display:flex;
            flex-direction:column;
            align-items:flex-end;
            gap:.4rem;
        }

        .chip-stt{
            border-radius:var(--radius-sm);
            padding:.3rem .5rem;
            font-size:.7rem;
            line-height:1.2;
            font-weight:600;
            text-transform:uppercase;
            border:1px solid transparent;
            white-space:nowrap;
        }
        .chip-stt.RECEIVED{
            background:#eef2ff;
            color:#4f46e5;
            border-color:#c7d2fe;
        }
        .chip-stt.COOKING{
            background:#fff7db;
            color:#92400e;
            border-color:#fde68a;
        }
        .chip-stt.READY,
        .chip-stt.PICKED,
        .chip-stt.SERVED{
            background:#ecfdf5;
            color:#065f46;
            border-color:#6ee7b7;
        }

        .chip-inline{
            background:var(--brand-bg-soft);
            border:1px solid var(--brand-border);
            border-radius:var(--radius-sm);
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
            padding:.3rem .5rem;
            color:var(--brand);
            white-space:nowrap;
        }

        .chip-timer{
            background:var(--accent-soft);
            border:1px solid var(--accent-border);
            border-radius:var(--radius-sm);
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
            padding:.3rem .5rem;
            color:#7a4b00;
            display:flex;
            align-items:center;
            gap:.3rem;
            white-space:nowrap;
        }
        .chip-timer i{
            color:var(--accent);
        }

        .ticket-body {
            font-size:.75rem;
            line-height:1.4;
            color:var(--ink-900);
            display:grid;
            grid-template-columns:auto auto;
            column-gap:1rem;
            row-gap:.5rem;
            margin-bottom:.75rem;
        }
        .field-col{
            display:flex;
            flex-direction:column;
        }
        .lbl{
            font-size:.65rem;
            line-height:1.2;
            font-weight:600;
            text-transform:uppercase;
            letter-spacing:.03em;
            color:var(--ink-500);
        }
        .val{
            font-size:.75rem;
            font-weight:600;
            color:var(--ink-900);
        }

        .note-box{
            grid-column:1 / -1;
            font-size:.7rem;
            line-height:1.4;
            background:#f9fafb;
            border:1px solid #e5e7eb;
            border-radius:var(--radius-sm);
            color:#374151;
            padding:.5rem .6rem;
            display:flex;
            gap:.4rem;
            align-items:flex-start;
        }
        .note-box i{
            color:var(--accent);
            font-size:.8rem;
            margin-top:.15rem;
        }

        .done-line{
            grid-column:1 / -1;
            font-size:.7rem;
            font-weight:600;
            color:#065f46;
            display:flex;
            align-items:center;
            gap:.4rem;
            line-height:1.3;
        }
        .done-line i{
            color:#10b981;
            font-size:.8rem;
        }

        .ticket-actions{
            display:flex;
            justify-content:flex-end;
        }
        .btn-status-next{
            border:none;
            border-radius:var(--radius-sm);
            min-width:90px;
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
            padding:.5rem .6rem;
            color:#fff;
            background:linear-gradient(135deg,#4f46e5 0%,#1f2937 100%);
            box-shadow:0 4px 20px rgba(0,0,0,.2);
            display:inline-flex;
            align-items:center;
            justify-content:center;
            gap:.4rem;
        }
        .btn-status-next.ready-step{
            background:linear-gradient(135deg,#fde047 0%,#facc15 100%);
            color:#1f2937;
        }
        .btn-status-next.serve-step{
            background:linear-gradient(135deg,#16a34a 0%,#047857 100%);
            color:#fff;
        }
        .btn-status-next.disabled,
        .btn-status-next:disabled{
            background:linear-gradient(135deg,#9ca3af 0%,#6b7280 100%);
            color:#fff;
        }
        .btn-status-next:hover{
            filter:brightness(1.05);
        }

        @media(max-width:480px){
            .ticket-card{
                flex:1 1 100%;
                max-width:100%;
                min-width:0;
            }
        }
    </style>
</head>
<body>

<!-- ===================================
     WAITER-STYLE TOP BAR (NO MORE RED)
=================================== -->
<div class="pos-topbar-shell">
    <!-- brand / intro -->
    <div class="pos-left-block">
        <div class="pos-icon-box">
            <i class="fas fa-fire"></i>
        </div>
        <div class="pos-brand-text">
            <div class="pos-brand-row">
                <span>KDS</span>
                <span class="dot">•</span>
                <span><%= fullName %></span>
            </div>
            <div class="pos-sub-line">
                Bếp realtime / Ra món / Theo dõi tiến độ
            </div>
        </div>
    </div>

    <!-- actions -->
    <div class="pos-action-block">

        <!-- Màn hình KDS -->
        <a class="top-pill" href="${pageContext.request.contextPath}/kds">
            <i class="fas fa-tv"></i>
            <span>KDS Dashboard</span>
        </a>

        <!-- Danh sách phiếu bếp (tuỳ bạn có route này hay không) -->
        <a class="top-pill" href="${pageContext.request.contextPath}/kds/tickets">
            <i class="fas fa-receipt"></i>
            <span>Phiếu bếp</span>
        </a>

        <!-- chip tên / role -->
        <div class="chef-identity">
            <i class="fas fa-user-tie"></i>
            <span><%= fullName %></span>
            <span class="chef-role-badge"><%= roleName %></span>
        </div>

        <!-- dropdown user -->
        <div class="dropdown">
            <button class="dropdown-toggle top-pill-user" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="fas fa-user-circle"></i>
                <span><%= shortName %></span>
                <i class="fas fa-chevron-down" style="opacity:.7;font-size:.7rem;"></i>
            </button>
            <ul class="dropdown-menu dropdown-menu-end top-user-menu">
                <li>
                    <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                        <i class="fas fa-id-card"></i>
                        <span>Thông tin cá nhân</span>
                    </a>
                </li>
                <li><hr class="dropdown-divider"/></li>
                <li>
                    <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth/LogoutServlet">
                        <i class="fas fa-sign-out-alt"></i>
                        <span>Đăng xuất</span>
                    </a>
                </li>
            </ul>
        </div>

    </div>
</div>

<main>
    <!-- KDS TOPBAR dưới (nhỏ gọn, giữ nguyên vì bạn đang dùng làm tiêu đề "Kitchen Display System") -->
    <header class="kds-topbar">
        <div class="kds-left">
            <div class="kds-title-row">
                <i class="bi bi-fire"></i>
                <span>Kitchen Display System</span>
            </div>
            <div class="kds-sub">Real-time Order Management / Theo dõi tiến độ món</div>
        </div>

        <div class="kds-right">
            <div class="usr-chip">
                <i class="bi bi-person-badge"></i>
                <span><%= fullName %></span>
                <span class="usr-role"><%= roleName %></span>
            </div>
        </div>
    </header>

    <!-- FILTER CARD -->
    <section class="filter-card">
        <div class="filter-headline">
            <div class="filter-head-left">
                <div class="filter-icon"><i class="bi bi-sliders"></i></div>
                <div class="filter-texts">
                    <div class="filter-title">Bộ lọc bếp / trạng thái</div>
                    <div class="filter-desc">Chọn station & tình trạng. Dùng để chia màn hình theo line bếp.</div>
                </div>
            </div>

            <div class="live-clock-chip">
                <i class="bi bi-clock"></i>
                <span id="currentTime">--:--:--</span>
            </div>
        </div>

        <div class="row g-3 align-items-end">
            <div class="col-md-3">
                <label class="filter-form-label">Station</label>
                <select id="stationFilter" class="form-select">
                    <option value="">All Stations</option>
                    <option value="HOT"     ${param.station == 'HOT' ? 'selected' : ''}>Hot Kitchen</option>
                    <option value="COLD"    ${param.station == 'COLD' ? 'selected' : ''}>Cold Kitchen</option>
                    <option value="BEVERAGE"${param.station == 'BEVERAGE' ? 'selected' : ''}>Beverage</option>
                    <option value="DESSERT" ${param.station == 'DESSERT' ? 'selected' : ''}>Dessert</option>
                    <option value="GRILL"   ${param.station == 'GRILL' ? 'selected' : ''}>Grill</option>
                </select>
            </div>

            <div class="col-md-3">
                <label class="filter-form-label">Status</label>
                <select id="statusFilter" class="form-select">
                    <option value="">All Status</option>
                    <option value="RECEIVED" ${param.status == 'RECEIVED' ? 'selected' : ''}>Received</option>
                    <option value="COOKING"  ${param.status == 'COOKING' ? 'selected' : ''}>Cooking</option>
                    <option value="READY"    ${param.status == 'READY' ? 'selected' : ''}>Ready</option>
                    <option value="PICKED"   ${param.status == 'PICKED' ? 'selected' : ''}>Picked</option>
                </select>
            </div>

            <div class="col-md-4">
                <div class="filter-actions">
                    <button class="btn-filter" onclick="refreshTickets()">
                        <i class="bi bi-arrow-clockwise"></i>
                        <span>Refresh</span>
                    </button>
                    <button class="btn-filter clear-btn" onclick="clearFilters()">
                        <i class="bi bi-x"></i>
                        <span>Clear</span>
                    </button>
                </div>
            </div>
        </div>
    </section>

    <!-- MÓN ĐANG LÀM -->
    <div class="section-bar">
        <i class="bi bi-clipboard-check"></i>
        <span>Món đang làm</span>
    </div>

    <section class="tickets-grid">
        <c:choose>
            <c:when test="${not empty tickets}">
                <c:forEach var="ticket" items="${tickets}">
                    <div class="ticket-card
                        <c:if test='${ticket.preparationStatus == "READY" || ticket.preparationStatus == "PICKED" || ticket.preparationStatus == "SERVED"}'>ready-glow</c:if>"
                         data-ticket-id="${ticket.kitchenTicketId}">

                        <div class="ticket-headline">
                            <div class="ticket-id-line">
                                <i class="bi bi-hash"></i>
                                <span>#${ticket.kitchenTicketId}</span>
                            </div>
                            <div class="ticket-rightmeta">
                                <div class="chip-stt ${ticket.preparationStatus}">
                                    ${ticket.preparationStatus}
                                </div>
                                <div class="chip-inline">${ticket.priority}</div>
                                <div class="chip-timer" id="timer-${ticket.kitchenTicketId}">
                                    <i class="bi bi-clock"></i> 00:00
                                </div>
                            </div>
                        </div>

                        <div class="ticket-body">
                            <div class="field-col">
                                <div class="lbl">Table</div>
                                <div class="val">${ticket.tableNumber}</div>
                            </div>
                            <div class="field-col">
                                <div class="lbl">Item</div>
                                <div class="val">${ticket.menuItemName}</div>
                            </div>

                            <div class="field-col">
                                <div class="lbl">Qty</div>
                                <div class="val">${ticket.quantity}</div>
                            </div>
                            <div class="field-col">
                                <div class="lbl">Station</div>
                                <div class="val">${ticket.station}</div>
                            </div>

                            <div class="field-col">
                                <div class="lbl">Course</div>
                                <div class="val">${ticket.course}</div>
                            </div>
                            <div class="field-col">
                                <div class="lbl">Timer</div>
                                <div class="val">00:00</div>
                            </div>

                            <c:if test="${not empty ticket.specialInstructions}">
                                <div class="note-box">
                                    <i class="bi bi-exclamation-triangle-fill"></i>
                                    <div>${ticket.specialInstructions}</div>
                                </div>
                            </c:if>
                        </div>

                        <div class="ticket-actions">
                            <div style="display:flex; gap:.5rem; flex-wrap:wrap;">
                                <c:choose>
                                    <c:when test="${ticket.preparationStatus == 'RECEIVED'}">
                                        <button class="btn-status-next"
                                                onclick="updateStatus(${ticket.kitchenTicketId}, 'COOKING')">
                                            <i class="bi bi-play-fill"></i><span>Start</span>
                                        </button>
                                    </c:when>
                                    <c:when test="${ticket.preparationStatus == 'COOKING'}">
                                        <button class="btn-status-next ready-step"
                                                onclick="updateStatus(${ticket.kitchenTicketId}, 'READY')">
                                            <i class="bi bi-check"></i><span>Ready</span>
                                        </button>
                                    </c:when>
                                    <c:when test="${ticket.preparationStatus == 'READY'}">
                                        <button class="btn-status-next serve-step"
                                                onclick="updateStatus(${ticket.kitchenTicketId}, 'PICKED')">
                                            <i class="bi bi-hand-index-fill"></i><span>Picked</span>
                                        </button>
                                    </c:when>
                                    <c:when test="${ticket.preparationStatus == 'PICKED'}">
                                        <button class="btn-status-next serve-step"
                                                onclick="updateStatus(${ticket.kitchenTicketId}, 'SERVED')">
                                            <i class="bi bi-check2-all"></i><span>Served</span>
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn-status-next disabled" disabled>
                                            <i class="bi bi-check2"></i><span>Done</span>
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                                
                                <c:if test="${ticket.preparationStatus != 'CANCELLED' && ticket.preparationStatus != 'SERVED'}">
                                    <button class="btn-status-next" 
                                            style="background:linear-gradient(135deg,#dc2626 0%,#991b1b 100%);"
                                            onclick="showCancelModal(${ticket.kitchenTicketId}, '${fn:escapeXml(ticket.menuItemName)}', '${ticket.tableNumber}')">
                                        <i class="bi bi-x-circle"></i><span>Hủy</span>
                                    </button>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>

            <c:otherwise>
                <div class="ticket-card" style="text-align:center;">
                    <div class="ticket-headline" style="justify-content:center;">
                        <div class="ticket-id-line">
                            <i class="bi bi-emoji-neutral"></i>
                            <span>Không có món nào đang làm.</span>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <!-- MÓN ĐÃ XONG -->
    <div class="section-bar">
        <i class="bi bi-check-circle"></i>
        <span>Món đã xong</span>
    </div>

    <section class="tickets-grid">
        <c:choose>
            <c:when test="${not empty completedTickets}">
                <c:forEach var="ticket" items="${completedTickets}">
                    <div class="ticket-card ready-glow" data-ticket-id="${ticket.kitchenTicketId}">
                        <div class="ticket-headline">
                            <div class="ticket-id-line">
                                <i class="bi bi-hash"></i>
                                <span>#${ticket.kitchenTicketId}</span>
                            </div>
                            <div class="ticket-rightmeta">
                                <div class="chip-stt ${ticket.preparationStatus}">
                                    ${ticket.preparationStatus}
                                </div>
                                <div class="chip-inline">${ticket.priority}</div>
                                <div class="chip-timer" id="timer-completed-${ticket.kitchenTicketId}">
                                    <i class="bi bi-clock"></i> 00:00
                                </div>
                            </div>
                        </div>

                        <div class="ticket-body">
                            <div class="field-col">
                                <div class="lbl">Table</div>
                                <div class="val">${ticket.tableNumber}</div>
                            </div>
                            <div class="field-col">
                                <div class="lbl">Item</div>
                                <div class="val">${ticket.menuItemName}</div>
                            </div>

                            <div class="field-col">
                                <div class="lbl">Qty</div>
                                <div class="val">${ticket.quantity}</div>
                            </div>
                            <div class="field-col">
                                <div class="lbl">Station</div>
                                <div class="val">${ticket.station}</div>
                            </div>

                            <div class="field-col">
                                <div class="lbl">Course</div>
                                <div class="val">${ticket.course}</div>
                            </div>
                            <div class="field-col">
                                <div class="lbl">Timer</div>
                                <div class="val">00:00</div>
                            </div>

                            <c:if test="${not empty ticket.specialInstructions}">
                                <div class="note-box">
                                    <i class="bi bi-exclamation-triangle-fill"></i>
                                    <div>${ticket.specialInstructions}</div>
                                </div>
                            </c:if>

                            <div class="done-line">
                                <i class="bi bi-check-circle-fill"></i>
                                <span>Đã xong - Chờ phục vụ</span>
                            </div>
                        </div>

                        <div class="ticket-actions">
                            <c:choose>
                                <c:when test="${ticket.preparationStatus == 'READY'}">
                                    <button class="btn-status-next serve-step"
                                            onclick="updateStatus(${ticket.kitchenTicketId}, 'PICKED')">
                                        <i class="bi bi-hand-index-fill"></i><span>Picked</span>
                                    </button>
                                </c:when>
                                <c:when test="${ticket.preparationStatus == 'PICKED'}">
                                    <button class="btn-status-next serve-step"
                                            onclick="updateStatus(${ticket.kitchenTicketId}, 'SERVED')">
                                        <i class="bi bi-check2-all"></i><span>Served</span>
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <button class="btn-status-next disabled" disabled>
                                        <i class="bi bi-check2"></i><span>Done</span>
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
            </c:when>

            <c:otherwise>
                <div class="ticket-card ready-glow" style="text-align:center;">
                    <div class="ticket-headline" style="justify-content:center;">
                        <div class="ticket-id-line">
                            <i class="bi bi-emoji-smile"></i>
                            <span>Chưa có món nào đã xong.</span>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<!-- JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // đồng hồ realtime
    function updateCurrentTime() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('vi-VN');
        const el = document.getElementById('currentTime');
        if (el) el.textContent = timeString;
    }
    setInterval(updateCurrentTime, 1000);
    updateCurrentTime();

    // filter reload
    function refreshTickets() {
        const station = document.getElementById('stationFilter').value;
        const status = document.getElementById('statusFilter').value;

        let url = '${pageContext.request.contextPath}/kds?';
        if (station) url += 'station=' + encodeURIComponent(station) + '&';
        if (status) url += 'status=' + encodeURIComponent(status);
        window.location.href = url;
    }

    function clearFilters() {
        document.getElementById('stationFilter').value = '';
        document.getElementById('statusFilter').value = '';
        window.location.href = '${pageContext.request.contextPath}/kds';
    }

    // update trạng thái
    function updateStatus(ticketId, newStatus) {
        if (confirm('Are you sure you want to update this ticket status to ' + newStatus + '?')) {
            fetch('${pageContext.request.contextPath}/kds/tickets/' + ticketId, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'status=' + encodeURIComponent(newStatus)
            })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    location.reload();
                } else {
                    alert('Error: ' + data.error);
                }
            })
            .catch(err => {
                console.error('Error:', err);
                alert('An error occurred while updating the ticket status.');
            });
        }
    }

    // auto refresh mỗi 30s
    setInterval(refreshTickets, 30000);

    // change filters => reload
    document.getElementById('stationFilter').addEventListener('change', refreshTickets);
    document.getElementById('statusFilter').addEventListener('change', refreshTickets);
    
    // Hủy đơn
    function showCancelModal(ticketId, menuItemName, tableNumber) {
        const reason = prompt('Nhập lý do hủy đơn cho món "' + menuItemName + '" từ bàn ' + tableNumber + ':');
        if (reason && reason.trim() !== '') {
            if (confirm('Bạn có chắc chắn muốn hủy đơn này? Lý do: ' + reason)) {
                cancelTicket(ticketId, reason.trim());
            }
        }
    }
    
    function cancelTicket(ticketId, reason) {
        fetch('${pageContext.request.contextPath}/kds/tickets/' + ticketId + '/cancel', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'reason=' + encodeURIComponent(reason)
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                alert('Đã hủy đơn thành công. Thông báo đã được gửi cho manager.');
                location.reload();
            } else {
                alert('Lỗi: ' + (data.error || 'Không thể hủy đơn'));
            }
        })
        .catch(err => {
            console.error('Error:', err);
            alert('Có lỗi xảy ra khi hủy đơn.');
        });
    }
</script>

<!-- Modal hủy đơn (có thể dùng Bootstrap modal nếu muốn) -->
</body>
</html>
