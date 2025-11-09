<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    // Lấy user từ session để hiển thị waiterName và contextPath cho JS
    Models.User user = (Models.User) session.getAttribute("user");
    String waiterName = (user != null)
        ? (user.getFirstName() + " " + user.getLastName())
        : "Waiter";

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gọi món | RMS POS</title>

    <!-- Bootstrap + Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Font -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <style>
        :root {
            --bg-app:#f5f6fa;
            --bg-grad-1:rgba(88,80,200,.08);
            --bg-grad-2:rgba(254,161,22,.06);

            --panel-grad:linear-gradient(135deg,#111827 0%,#1e2537 40%,#2b3245 100%);
            --nav-grad:linear-gradient(135deg,#0f1a2a 0%,#1a2234 60%,#1f2535 100%);
            --surface-soft:#f9fafb;

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;

            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.12);
            --accent-border:rgba(254,161,22,.45);

            --danger:#dc3545;
            --high:#fd7e14;
            --normal:#0ea5e9;
            --low:#6b7280;
        }

        body {
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            font-family:"Heebo",system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",sans-serif;
            color:var(--ink-900);
        }

        /* ============ TOP NAV BAR ============ */
        .screen-top-shell{width:100%;padding:12px 16px 0;background:transparent;}
        .screen-top-inner{
            max-width:1400px;margin:0 auto;
            background:var(--nav-grad);
            border:1px solid rgba(255,255,255,.08);
            border-radius:10px;
            box-shadow:0 32px 64px rgba(0,0,0,.75),0 2px 4px rgba(255,255,255,.15) inset;
            color:#fff;
            display:flex;flex-wrap:wrap;align-items:flex-start;justify-content:space-between;
            gap:.75rem;padding:.75rem 1rem;
        }
        .brand-side{display:flex;align-items:flex-start;gap:.75rem;min-width:0;}
        .app-icon{
            background:rgba(255,255,255,.07);
            border:1px solid rgba(255,255,255,.18);
            color:#fff;width:36px;height:36px;border-radius:8px;
            display:flex;align-items:center;justify-content:center;
            font-size:.9rem;line-height:1;
            box-shadow:0 16px 32px rgba(0,0,0,.7);
        }
        .brand-lines{display:flex;flex-direction:column;line-height:1.3;}
        .brand-row{
            display:flex;flex-wrap:wrap;align-items:center;gap:.4rem;
            color:#fff;font-size:.9rem;font-weight:600;white-space:nowrap;
        }
        .brand-row .dot{opacity:.4;font-weight:400;}
        .brand-sub{
            font-size:.7rem;line-height:1.3;
            color:rgba(255,255,255,.6);white-space:nowrap;
        }

        .nav-side{
            display:flex;flex-wrap:wrap;align-items:center;
            gap:.5rem .6rem;margin-left:auto;
        }
        .nav-pill{
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.2);
            border-radius:.5rem;
            padding:.45rem .6rem;
            color:#fff;
            font-size:.8rem;font-weight:500;line-height:1.2;
            box-shadow:0 20px 40px rgba(0,0,0,.6);
            display:inline-flex;align-items:center;gap:.4rem;
            text-decoration:none;white-space:nowrap;
        }
        .nav-pill:hover{
            background:rgba(255,255,255,.1);color:#fff;text-decoration:none;
            box-shadow:0 28px 60px rgba(0,0,0,.7);
        }
        .role-badge{
            background:var(--accent);
            color:#1e1e2f;
            border-radius:.4rem;
            padding:.2rem .45rem;
            font-size:.7rem;font-weight:600;line-height:1.2;
            box-shadow:0 8px 16px rgba(254,161,22,.4);
            border:1px solid rgba(0,0,0,.15);
        }
        .dropdown-menu.top-user-menu{
            font-size:.8rem;border-radius:.5rem;
            border:1px solid rgba(0,0,0,.08);
            box-shadow:0 24px 48px rgba(0,0,0,.45);
            min-width:180px;
        }

        /* ============ GRID LAYOUT ============ */
        .page-wrapper{
            max-width:1400px;
            margin:24px auto 48px;
            padding:0 16px 48px;
            display:grid;
            grid-template-columns:1fr 360px;
            gap:24px;
        }
        @media(max-width:992px){
            .page-wrapper{grid-template-columns:1fr;}
        }

        /* ============ LEFT PANEL (MENU) ============ */
        .menu-section-card{
            background:#fff;
            border-radius:18px;
            box-shadow:0 24px 64px rgba(0,0,0,.08);
            border:1px solid rgba(0,0,0,.05);
            overflow:hidden;
        }
        .menu-header{
            display:flex;flex-wrap:wrap;justify-content:space-between;align-items:flex-start;
            padding:16px 20px;background:#fff;border-bottom:1px solid rgba(0,0,0,.06);
        }
        .menu-header-left{display:flex;flex-direction:column;gap:.4rem;}
        .menu-title-row{
            display:flex;flex-wrap:wrap;align-items:center;gap:.5rem;
            font-size:1rem;font-weight:600;color:var(--ink-900);
        }
        .badge-table{
            background:var(--accent-soft);
            color:#7a4b00;
            border:1px solid var(--accent-border);
            border-radius:8px;
            font-size:.7rem;font-weight:600;line-height:1.2;
            padding:.3rem .5rem;
        }
        .menu-subline{font-size:.75rem;color:var(--ink-500);}

        .menu-header-actions{
            display:flex;flex-direction:column;align-items:flex-end;gap:.5rem;flex:0 0 auto;
        }
        @media(min-width:576px){
            .menu-header-actions{
                flex-direction:row;flex-wrap:wrap;align-items:center;justify-content:flex-end;
            }
        }

        .btn-ghost{
            border-radius:8px;background:#fff;border:1px solid #cbd5e1;
            color:#475569;font-size:.8rem;font-weight:500;line-height:1.2;
            padding:.5rem .75rem;display:flex;align-items:center;gap:.4rem;
        }
        .btn-ghost:hover{
            background:#f8fafc;color:#1e293b;border-color:#94a3b8;
        }
        .btn-cart-ghost{
            border-radius:8px;background:var(--accent);border:1px solid #b45309;
            color:#1e1e2f;font-size:.8rem;font-weight:600;line-height:1.2;
            padding:.5rem .75rem;display:flex;align-items:center;gap:.4rem;
            box-shadow:0 16px 32px rgba(254,161,22,.4);
        }

        .filter-bar{
            display:flex;flex-wrap:wrap;gap:.75rem 1rem;
            background:#f8fafc;
            border-top:1px solid rgba(0,0,0,.03);
            border-bottom:1px solid rgba(0,0,0,.05);
            padding:16px 20px;
        }
        .filter-field{display:flex;flex-direction:column;}
        .filter-label{
            font-size:.7rem;font-weight:500;color:var(--ink-700);margin-bottom:.25rem;
        }
        .filter-input,.filter-select{
            background:#fff;border:1px solid #cbd5e1;border-radius:8px;
            font-size:.8rem;padding:.45rem .6rem;line-height:1.2;
            min-width:140px;box-shadow:0 4px 8px rgba(0,0,0,.03) inset;
            color:#0f172a;
        }
        .filter-actions{display:flex;align-items:flex-end;gap:.5rem;}
        .filter-btn{
            border-radius:8px;background:#1e293b;color:#fff;border:1px solid #1e293b;
            font-size:.8rem;font-weight:600;line-height:1.2;
            padding:.5rem .75rem;display:flex;align-items:center;gap:.4rem;
        }
        .filter-btn-clear{
            border-radius:8px;background:#fff;color:#475569;border:1px solid #cbd5e1;
            font-size:.8rem;font-weight:500;line-height:1.2;
            padding:.5rem .75rem;display:flex;align-items:center;gap:.4rem;
        }

        .cat-block{padding:16px 20px 8px;}
        .cat-headline{
            display:flex;align-items:center;gap:.5rem;
            margin-bottom:12px;
            font-size:.9rem;font-weight:600;color:var(--ink-900);
        }
        .cat-icon{
            background:var(--surface-soft);
            border:1px solid rgba(0,0,0,.05);
            box-shadow:0 10px 20px rgba(0,0,0,.05);
            width:32px;height:32px;border-radius:10px;
            display:flex;align-items:center;justify-content:center;
            color:var(--accent);font-size:.9rem;
        }

        .menu-item-row{
            background:#fff;border:1px solid rgba(0,0,0,.06);
            border-radius:12px;
            box-shadow:0 12px 32px rgba(0,0,0,.05);
            padding:12px 16px;
            margin-bottom:12px;
            display:grid;
            grid-template-columns:72px 1fr auto;
            column-gap:12px;
        }
        .menu-item-row.disabled-item{
            background:#f5f5f5;
            opacity:0.7;
            border:1px solid rgba(0,0,0,.12);
        }
        .menu-item-row.disabled-item .menu-name{
            color:#6b7280;
        }
        .menu-item-row.disabled-item .menu-price{
            color:#9ca3af;
        }
        @media(max-width:500px){
            .menu-item-row{grid-template-columns:60px 1fr;}
        }
        .menu-thumb img{
            width:72px;height:72px;border-radius:10px;
            object-fit:cover;border:1px solid rgba(0,0,0,.08);background:#f8fafc;
        }
        .menu-main{display:flex;flex-direction:column;justify-content:space-between;}
        .menu-name-line{
            display:flex;flex-wrap:wrap;align-items:center;justify-content:space-between;gap:.5rem;
        }
        .menu-name{font-size:.9rem;font-weight:600;color:var(--ink-900);line-height:1.3;}
        .menu-price{font-size:.9rem;font-weight:600;color:#16a34a;}
        .menu-desc{font-size:.75rem;line-height:1.3;color:var(--ink-500);margin-top:.25rem;}

        .menu-qty-col{
            display:flex;flex-direction:column;align-items:flex-end;justify-content:space-between;
        }
        @media(max-width:500px){
            .menu-qty-col{
                grid-column:span 2;
                flex-direction:row;justify-content:space-between;align-items:center;
                margin-top:.5rem;
            }
        }
        .qty-controls{
            display:flex;align-items:center;gap:.5rem;
        }
        .qty-btn{
            width:32px;height:32px;border-radius:999px;
            border:1px solid #cbd5e1;background:#fff;color:#475569;
            font-size:.75rem;display:flex;align-items:center;justify-content:center;
            cursor:pointer;box-shadow:0 8px 20px rgba(0,0,0,.05);
        }
        .qty-btn:hover{background:#1e293b;color:#fff;border-color:#1e293b;}
        .qty-input{
            width:48px;height:32px;border-radius:8px;border:1px solid #cbd5e1;
            text-align:center;font-size:.8rem;font-weight:500;color:#0f172a;
            background:#fff;box-shadow:0 4px 12px rgba(0,0,0,.04) inset;
        }

        .add-btn{
            margin-top:.5rem;border:none;border-radius:8px;
            background:var(--accent);border:1px solid #b45309;color:#1e1e2f;
            font-size:.75rem;font-weight:600;line-height:1.2;
            padding:.5rem .75rem;display:inline-flex;align-items:center;gap:.4rem;
            box-shadow:0 16px 32px rgba(254,161,22,.4);
        }
        .add-btn:disabled, .qty-btn:disabled{
            opacity:0.5;
            cursor:not-allowed;
            background:#9ca3af;
            border-color:#6b7280;
            color:#fff;
            box-shadow:none;
        }
        .qty-input:disabled{
            background:#e5e7eb;
            color:#6b7280;
            cursor:not-allowed;
        }

        /* ============ RIGHT PANEL (CART / NOTE / TOTAL) ============ */
        .order-panel{
            background:var(--panel-grad);
            border:1px solid rgba(255,255,255,.08);
            border-radius:18px;
            box-shadow:0 32px 64px rgba(0,0,0,.6);
            color:#fff;
            display:flex;flex-direction:column;
            max-height:calc(100vh - 120px);
            min-height:480px;
        }
        @media(max-width:992px){.order-panel{max-height:none;}}

        .order-head{
            padding:16px 20px;
            border-bottom:1px solid rgba(255,255,255,.08);
            display:flex;flex-direction:column;gap:.4rem;
        }
        .order-head-row1{
            display:flex;justify-content:space-between;flex-wrap:wrap;
            align-items:flex-start;gap:.5rem;
        }
        .order-left-titles{display:flex;flex-direction:column;gap:.25rem;}
        .order-title{
            font-size:.9rem;font-weight:600;color:#fff;line-height:1.3;
            display:flex;align-items:center;gap:.5rem;
        }
        .order-table-chip{
            background:var(--accent);color:#1e1e2f;border-radius:.4rem;
            padding:.25rem .5rem;font-size:.7rem;font-weight:600;line-height:1.2;
            border:1px solid rgba(0,0,0,.15);box-shadow:0 12px 24px rgba(254,161,22,.4);
        }
        .order-subtxt{
            font-size:.7rem;color:rgba(255,255,255,.6);line-height:1.3;
        }

        .order-badges{display:flex;flex-wrap:wrap;gap:.5rem;}
        .priority-chip{
            border-radius:.4rem;font-size:.7rem;font-weight:600;
            line-height:1.2;padding:.3rem .5rem;
        }
        .p-urgent{background:var(--danger);color:#fff;}
        .p-high{background:var(--high);color:#1e1e2f;}
        .p-normal{background:var(--normal);color:#fff;}
        .p-low{background:var(--low);color:#fff;}

        .cart-scroll{flex:1;overflow-y:auto;padding:16px 20px;}
        .cart-item-card{
            border-bottom:1px solid rgba(255,255,255,.08);
            padding-bottom:12px;margin-bottom:12px;
        }
        .cart-item-topline{
            display:flex;justify-content:space-between;flex-wrap:wrap;
            gap:.5rem;font-size:.8rem;font-weight:600;color:#fff;
        }
        .cart-item-meta{
            font-size:.7rem;font-weight:400;color:rgba(255,255,255,.7);
        }
        .cart-controls-row{
            margin-top:.5rem;
            display:flex;justify-content:space-between;align-items:center;
            flex-wrap:wrap;gap:.5rem;
        }
        .cart-mini-qty{display:flex;align-items:center;gap:.5rem;}
        .mini-btn{
            width:28px;height:28px;border-radius:999px;background:#fff;color:#1e293b;
            border:1px solid rgba(0,0,0,.15);font-size:.7rem;
            display:flex;align-items:center;justify-content:center;cursor:pointer;
        }
        .mini-btn:hover{background:#1e293b;color:#fff;border-color:#1e293b;}
        .mini-qty-label{
            color:#fff;font-size:.75rem;min-width:1.5rem;text-align:center;
        }
        .remove-btn{
            border-radius:.4rem;background:transparent;
            border:1px solid rgba(255,255,255,.3);color:#fff;
            font-size:.7rem;padding:.4rem .5rem;line-height:1.2;
            display:inline-flex;align-items:center;gap:.4rem;
        }
        .remove-btn:hover{background:rgba(255,255,255,.1);}

        .order-notes{
            border-top:1px solid rgba(255,255,255,.08);
            padding:16px 20px;
        }
        .order-notes label{
            color:#fff;font-size:.75rem;font-weight:500;margin-bottom:.4rem;
        }
        .notes-textarea{
            width:100%;border-radius:.5rem;border:1px solid rgba(255,255,255,.35);
            background:rgba(0,0,0,.2);color:#fff;font-size:.8rem;line-height:1.4;
            padding:.6rem .75rem;resize:vertical;min-height:70px;
            box-shadow:0 24px 48px rgba(0,0,0,.8);
        }
        .notes-textarea::placeholder{color:rgba(255,255,255,.4);}

        .priority-select{margin-top:1rem;}
        .priority-select label{
            display:block;font-size:.75rem;font-weight:500;color:#fff;margin-bottom:.4rem;
        }
        .priority-wrapper{position:relative;}
        .priority-field{
            width:100%;border-radius:.5rem;border:1px solid rgba(255,255,255,.35);
            background:rgba(0,0,0,.2);color:#fff;font-size:.8rem;line-height:1.4;
            padding:.55rem .75rem;appearance:none;cursor:pointer;
            box-shadow:0 24px 48px rgba(0,0,0,.8);
        }
        .priority-wrapper .chevron{
            pointer-events:none;position:absolute;right:.6rem;top:50%;
            transform:translateY(-50%);font-size:.7rem;color:rgba(255,255,255,.6);
        }

        .order-footer{
            border-top:1px solid rgba(255,255,255,.08);
            padding:16px 20px 20px;
            display:flex;flex-direction:column;gap:.75rem;
        }
        .total-line{
            display:flex;justify-content:space-between;
            font-size:.9rem;font-weight:600;color:#fff;
        }
        .total-line span:last-child{color:var(--accent);}
        .action-btn-main{
            width:100%;background:var(--accent);border:1px solid #b45309;border-radius:.6rem;
            font-size:.8rem;font-weight:600;color:#1e1e2f;line-height:1.2;
            padding:.75rem .75rem;
            display:flex;align-items:center;justify-content:center;gap:.5rem;
            box-shadow:0 24px 48px rgba(254,161,22,.4);
        }
        .action-btn-clear{
            width:100%;background:transparent;border:1px solid rgba(255,255,255,.4);
            border-radius:.6rem;font-size:.8rem;font-weight:600;color:#fff;line-height:1.2;
            padding:.75rem .75rem;
            display:flex;align-items:center;justify-content:center;gap:.5rem;
        }
        .action-btn-clear:hover{background:rgba(255,255,255,.08);}

        /* toast */
        .toast-wrap{
            position:fixed;right:16px;bottom:16px;z-index:9999;
            display:flex;flex-direction:column;gap:8px;pointer-events:none;
        }
        .toast-card{
            min-width:240px;max-width:320px;
            background:linear-gradient(135deg,#1f2937 0%,#111827 60%);
            border:1px solid rgba(255,255,255,.15);
            border-radius:10px;
            box-shadow:0 24px 48px rgba(0,0,0,.8);
            color:#fff;padding:.75rem .9rem;
            font-size:.8rem;line-height:1.4;font-weight:500;
            display:flex;align-items:flex-start;gap:.6rem;
            pointer-events:auto;
            opacity:0;transform:translateY(10px);
            transition:all .2s ease;
        }
        .toast-card.show{opacity:1;transform:translateY(0);}
        .toast-icon{
            flex-shrink:0;width:28px;height:28px;border-radius:8px;
            background:var(--accent);border:1px solid rgba(0,0,0,.4);
            color:#1e1e2f;font-size:.8rem;font-weight:600;
            display:flex;align-items:center;justify-content:center;
            box-shadow:0 16px 32px rgba(254,161,22,.4);
        }
        .toast-close{
            cursor:pointer;color:rgba(255,255,255,.6);
            font-size:.75rem;line-height:1;
        }
        .toast-close:hover{color:#fff;}
    </style>
</head>
<body>

<!-- HEADER -->
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
                    <span id="headerTable">Bàn ?</span>
                </div>
                <div class="brand-sub">Bản đồ bàn / Gọi món / Trạng thái bàn real-time</div>
            </div>
        </div>

        <div class="nav-side">
            <a class="nav-pill" href="<%=ctx%>/tables">
                <i class="bi bi-grid-3x3-gap-fill"></i>
                <span>Sơ đồ bàn</span>
            </a>

            <a class="nav-pill" href="<%=ctx%>/kds">
                <i class="bi bi-tv"></i>
                <span>Đặt món</span>
            </a>

            <div class="nav-pill">
                <i class="bi bi-person-badge"></i>
                <span><%= waiterName %></span>
                <span class="role-badge">Waiter</span>
            </div>

            <div class="dropdown">
                <button class="nav-pill dropdown-toggle lang-pill" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-person-circle"></i>
                    <span><%= (user != null ? user.getFirstName() : "User") %></span>
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

    <!-- LEFT: MENU -->
    <section class="menu-section-card">
        <div class="menu-header">
            <div class="menu-header-left">
                <div class="menu-title-row">
                    <span>Thực đơn phục vụ</span>
                    <span class="badge-table" id="badgeTable">Bàn ?</span>
                </div>
                <div class="menu-subline">
                    Phục vụ bởi <strong><%= waiterName %></strong>
                </div>
            </div>

            <div class="menu-header-actions">
                <button class="btn-ghost" onclick="goBackToTables()">
                    <i class="bi bi-arrow-left"></i><span>Quay lại bàn</span>
                </button>
                <button class="btn-cart-ghost d-lg-none" onclick="scrollToCart()">
                    <i class="bi bi-cart3"></i>
                    <span>Giỏ (<span id="cartCountHeader">0</span>)</span>
                </button>
            </div>
        </div>

        <div class="filter-bar">
            <div class="filter-field">
                <label class="filter-label" for="filterName">Tìm món</label>
                <input id="filterName" class="filter-input" type="text" placeholder="ví dụ: phở, bò..." />
            </div>

            <div class="filter-field">
                <label class="filter-label" for="filterMin">Giá từ</label>
                <input id="filterMin" class="filter-input" type="number" min="0" step="1000" placeholder="0" />
            </div>

            <div class="filter-field">
                <label class="filter-label" for="filterMax">Đến</label>
                <input id="filterMax" class="filter-input" type="number" min="0" step="1000" placeholder="100000" />
            </div>

            <div class="filter-field">
                <label class="filter-label" for="filterCategory">Danh mục</label>
                <select id="filterCategory" class="filter-select">
                    <option value="">Tất cả</option>
                    <option value="1">Khai Vị</option>
                    <option value="2">Món Chính</option>
                    <option value="3">Món Phụ</option>
                    <option value="4">Tráng Miệng</option>
                    <option value="5">Đồ Uống</option>
                </select>
            </div>

            <div class="filter-actions ms-sm-auto">
                <button class="filter-btn" onclick="applyFilter()">
                    <i class="bi bi-funnel"></i><span>Lọc</span>
                </button>
                <button class="filter-btn-clear" onclick="resetFilter()">
                    <i class="bi bi-x-circle"></i><span>Xóa lọc</span>
                </button>
            </div>
        </div>

        <div id="menuContainer" class="p-3"></div>
    </section>

    <!-- RIGHT: CART -->
    <aside class="order-panel" id="orderPanel">
        <div class="order-head">
            <div class="order-head-row1">
                <div class="order-left-titles">
                    <div class="order-title">
                        <i class="bi bi-receipt-cutoff"></i>
                        <span>Giỏ hàng / Phiếu tạm tính</span>
                        <span class="order-table-chip" id="orderTableChip">Bàn ?</span>
                    </div>
                    <div class="order-subtxt">
                        <span>Khách tại chỗ • Gọi món theo bàn</span>
                    </div>
                </div>

                <div class="order-badges">
                    <div class="priority-chip p-normal" id="priorityPreview">Ưu tiên: Bình thường</div>
                </div>
            </div>
        </div>

        <div class="cart-scroll" id="cartItems"><!-- cart render --></div>

        <div class="order-notes">
            <div class="mb-3">
                <label class="form-label text-white">Ghi chú đặc biệt</label>
                <textarea class="notes-textarea" id="specialInstructions"
                          placeholder="Không cay / mang ra cùng soup / khách VIP bàn 5..."></textarea>
            </div>

            <div class="priority-select">
                <label>Độ ưu tiên gửi bếp</label>
                <div class="priority-wrapper">
                    <select id="orderPriority" class="priority-field">
                        <option value="NORMAL">Bình thường</option>
                        <option value="HIGH">Cao</option>
                        <option value="URGENT">Khẩn cấp</option>
                        <option value="LOW">Thấp</option>
                    </select>
                    <span class="chevron"><i class="bi bi-chevron-down"></i></span>
                </div>
            </div>
        </div>

        <div class="order-footer">
            <div class="total-line">
                <span>Tổng</span>
                <span><span id="cartTotal">0đ</span></span>
            </div>
            <button class="action-btn-main" onclick="createOrder()">
                <i class="bi bi-check2-circle"></i>
                <span>Gửi đơn vào bếp</span>
            </button>
            <button class="action-btn-clear" onclick="clearCart()">
                <i class="bi bi-trash"></i>
                <span>Xóa giỏ hàng</span>
            </button>
        </div>
    </aside>
</div>

<!-- Toast -->
<div class="toast-wrap" id="toastWrap"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ================== GLOBAL STATE ==================
    var CTX = '<%=ctx%>';
    var cart = [];
    var menuItems = [];
    var filteredItems = [];
    var currentTableId = null;
    var currentWaiterId = <%= (user != null ? user.getUserId() : "null") %>; // có thể null nếu chưa login

    // ================== INIT ==================
    document.addEventListener('DOMContentLoaded', function() {
        var urlParams = new URLSearchParams(window.location.search);
        var tableIdStr = urlParams.get('tableId');
        currentTableId = tableIdStr ? parseInt(tableIdStr) : 1;

        // label bàn
        setTableLabels("Bàn " + currentTableId);

        loadTableDetails();
        loadMenuItems();
        loadCartFromStorage();

        // sync priority preview chip
        var prioritySelectEl = document.getElementById('orderPriority');
        prioritySelectEl.addEventListener('change', updatePriorityPreview);
        updatePriorityPreview();
    });

    // ================== UI HELPERS ==================
    function setTableLabels(txt){
        document.getElementById('headerTable').textContent = txt;
        document.getElementById('badgeTable').textContent = txt;
        document.getElementById('orderTableChip').textContent = txt;
    }

    function goBackToTables(){
        window.location.href = CTX + '/tables';
    }
    function scrollToCart(){
        document.getElementById('orderPanel').scrollIntoView({behavior:'smooth'});
    }

    function fmtPrice(p) {
        if (isNaN(p)) return "0đ";
        return Number(p).toLocaleString('vi-VN', { minimumFractionDigits: 0 }) + 'đ';
    }

    // ================== LOAD TABLE INFO ==================
    function loadTableDetails(){
        if(!currentTableId) return;
        fetch(CTX + '/tables/' + currentTableId)
            .then(r => r.json())
            .then(data => {
                if(!data || data.error){ return; }
                setTableLabels("Bàn " + data.tableNumber);
            })
            .catch(err => console.error('loadTableDetails error:', err));
    }

    // ================== LOAD MENU ITEMS ==================
    function loadMenuItems(){
        fetch(CTX + '/menu?action=list&page=1&pageSize=1000&format=json')
            .then(r => r.json())
            .then(data => {
                if(data.menuItems && data.menuItems.length>0){
                    menuItems = data.menuItems.map(function(item){
                        return {
                            itemId: item.itemId || item.menuItemId || 0,
                            name: item.name || 'Tên món',
                            description: item.description || '',
                            price: Number(item.basePrice || item.displayPrice || 0),
                            image: item.imageUrl || (CTX + '/img/menu-1.jpg'),
                            category: item.categoryId || 1,
                            isActive: item.isActive !== undefined ? item.isActive : true,
                            availability: item.availability || 'AVAILABLE'
                        };
                    });
                } else {
                    // fallback
                    menuItems = [
                        {itemId:1,name:'Phở Bò',description:'Phở bò truyền thống',price:40000,image:CTX+'/img/menu-1.jpg',category:2},
                        {itemId:2,name:'Chả Giò',description:'Nem rán giòn tan',price:25000,image:CTX+'/img/menu-2.jpg',category:1},
                        {itemId:3,name:'Cà Phê Sữa Đá',description:'Cà phê phin',price:15000,image:CTX+'/img/menu-3.jpg',category:5}
                    ];
                }
                filteredItems = menuItems.slice();
                renderMenu();
            })
            .catch(err => {
                console.error('loadMenuItems error:', err);
                // fallback
                menuItems = [
                    {itemId:1,name:'Phở Bò',description:'Phở bò truyền thống',price:40000,image:CTX+'/img/menu-1.jpg',category:2},
                    {itemId:2,name:'Chả Giò',description:'Nem rán giòn tan',price:25000,image:CTX+'/img/menu-2.jpg',category:1},
                    {itemId:3,name:'Cà Phê Sữa Đá',description:'Cà phê phin',price:15000,image:CTX+'/img/menu-3.jpg',category:5}
                ];
                filteredItems = menuItems.slice();
                renderMenu();
            });
    }

    // ================== FILTER ==================
    function applyFilter(){
        var nameVal = document.getElementById('filterName').value.trim().toLowerCase();
        var minVal = parseInt(document.getElementById('filterMin').value,10);
        var maxVal = parseInt(document.getElementById('filterMax').value,10);
        var catVal = document.getElementById('filterCategory').value;

        filteredItems = menuItems.filter(function(it){
            var okName = true, okMin = true, okMax = true, okCat = true;

            if(nameVal){
                okName =
                    it.name.toLowerCase().indexOf(nameVal) !== -1 ||
                    (it.description||'').toLowerCase().indexOf(nameVal) !== -1;
            }
            if(!isNaN(minVal)){ okMin = it.price >= minVal; }
            if(!isNaN(maxVal)){ okMax = it.price <= maxVal; }
            if(catVal){ okCat = (String(it.category) === String(catVal)); }

            return okName && okMin && okMax && okCat;
        });

        renderMenu();
    }

    function resetFilter(){
        document.getElementById('filterName').value = '';
        document.getElementById('filterMin').value = '';
        document.getElementById('filterMax').value = '';
        document.getElementById('filterCategory').value = '';
        filteredItems = menuItems.slice();
        renderMenu();
    }

    // ================== MENU RENDER ==================
    function getItemQty(itemId){
        var ci = cart.find(function(x){return x.itemId===itemId;});
        return ci ? ci.quantity : 0;
    }

    function renderMenu(){
        var container = document.getElementById('menuContainer');
        container.innerHTML = '';

        var catNames = {
            1:'Khai Vị',
            2:'Món Chính',
            3:'Món Phụ',
            4:'Tráng Miệng',
            5:'Đồ Uống'
        };

        var grouped = {};
        filteredItems.forEach(function(item){
            var c = item.category || 1;
            if(!grouped[c]) grouped[c] = [];
            grouped[c].push(item);
        });

        Object.keys(grouped).sort(function(a,b){
            return parseInt(a,10)-parseInt(b,10);
        }).forEach(function(catId){
            var items = grouped[catId];
            if(!items || !items.length){return;}

            var catBlock = document.createElement('div');
            catBlock.className = 'cat-block';
            catBlock.innerHTML =
                '<div class="cat-headline">'+
                    '<div class="cat-icon"><i class="bi bi-list-ul"></i></div>'+
                    '<div>'+ (catNames[catId] || 'Khác') +'</div>'+
                '</div>';
            container.appendChild(catBlock);

            items.forEach(function(it){
                var qty = getItemQty(it.itemId);
                var safeImg = it.image || (CTX + '/img/menu-1.jpg');
                var isDisabled = !it.isActive;

                var row = document.createElement('div');
                row.className = 'menu-item-row' + (isDisabled ? ' disabled-item' : '');

                var statusBadge = '';
                if (isDisabled) {
                    statusBadge = '<span class="badge bg-secondary ms-2"><i class="bi bi-pause-circle"></i> Tạm ngưng</span>';
                }

                row.innerHTML =
                    '<div class="menu-thumb">'+
                        '<img src="'+ safeImg +'" '+
                             'onerror="this.src=\''+ CTX +'/img/menu-1.jpg\';" '+
                             'alt="'+ it.name +'" '+
                             (isDisabled ? 'style="opacity:0.5"' : '') +'>'+
                    '</div>'+
                    '<div class="menu-main">'+
                        '<div>'+
                            '<div class="menu-name-line">'+
                                '<div class="menu-name">'+ it.name + statusBadge +'</div>'+
                                '<div class="menu-price">'+ fmtPrice(it.price) +'</div>'+
                            '</div>'+
                            '<div class="menu-desc">'+ (it.description || '') + (isDisabled ? ' <strong class="text-danger">(Không thể đặt)</strong>' : '') +'</div>'+
                        '</div>'+
                    '</div>'+
                    '<div class="menu-qty-col">'+
                        '<div class="qty-controls">'+
                            '<button class="qty-btn" onclick="decreaseQuantity('+ it.itemId +')" '+ (isDisabled ? 'disabled' : '') +'><i class="bi bi-dash-lg"></i></button>'+
                            '<input class="qty-input" id="qty-'+ it.itemId +'" type="number" min="0" value="'+ qty +'" onchange="updateQuantity('+ it.itemId +', this.value)" '+ (isDisabled ? 'disabled' : '') +'>'+
                            '<button class="qty-btn" onclick="increaseQuantity('+ it.itemId +')" '+ (isDisabled ? 'disabled' : '') +'><i class="bi bi-plus-lg"></i></button>'+
                        '</div>'+
                        '<button class="add-btn" onclick="addToCart('+ it.itemId +')" '+ (isDisabled ? 'disabled' : '') +'>'+
                            '<i class="bi bi-cart-plus"></i>'+
                            '<span>'+ (isDisabled ? 'Không có sẵn' : (qty>0 ? ('Cập nhật ('+qty+')') : 'Thêm món')) +'</span>'+
                        '</button>'+
                    '</div>';

                container.appendChild(row);
            });
        });
    }

    // ================== CART LOGIC ==================
    function addToCart(itemId){
        var m = menuItems.find(function(i){return i.itemId===itemId;});
        if(!m) return;
        
        // Check if item is active
        if(!m.isActive){
            alert('Món "' + m.name + '" hiện đang tạm ngưng bán. Vui lòng chọn món khác.');
            return;
        }
        
        var ex = cart.find(function(ci){return ci.itemId===itemId;});
        if(ex){
            ex.quantity += 1;
        }else{
            cart.push({
                itemId:m.itemId,
                name:m.name,
                price:Number(m.price),
                quantity:1,
                specialInstructions:''
            });
        }
        syncAfterCartChange();
    }

    function increaseQuantity(itemId){
        var m = menuItems.find(function(i){return i.itemId===itemId;});
        if(m && !m.isActive){
            alert('Món "' + m.name + '" hiện đang tạm ngưng bán.');
            return;
        }
        
        var it = cart.find(function(ci){return ci.itemId===itemId;});
        if(it){
            it.quantity += 1;
        }else{
            addToCart(itemId);
            return;
        }
        syncAfterCartChange();
    }

    function decreaseQuantity(itemId){
        var it = cart.find(function(ci){return ci.itemId===itemId;});
        if(it){
            it.quantity -= 1;
            if(it.quantity<=0){
                cart = cart.filter(function(ci){return ci.itemId!==itemId;});
            }
        }
        syncAfterCartChange();
    }

    function updateQuantity(itemId,val){
        var qty = parseInt(val,10)||0;
        if(qty<=0){
            cart = cart.filter(function(ci){return ci.itemId!==itemId;});
        }else{
            var it = cart.find(function(ci){return ci.itemId===itemId;});
            if(it){
                it.quantity = qty;
            }else{
                var m = menuItems.find(function(i){return i.itemId===itemId;});
                if(!m) return;
                
                // Check if item is active
                if(!m.isActive){
                    alert('Món "' + m.name + '" hiện đang tạm ngưng bán. Vui lòng chọn món khác.');
                    document.getElementById('qty-' + itemId).value = 0;
                    return;
                }
                
                cart.push({
                    itemId:m.itemId,
                    name:m.name,
                    price:Number(m.price),
                    quantity:qty,
                    specialInstructions:''
                });
            }
        }
        syncAfterCartChange();
    }

    function removeFromCart(itemId){
        cart = cart.filter(function(ci){return ci.itemId!==itemId;});
        syncAfterCartChange();
    }

    function clearCart(){
        if(!confirm('Xóa toàn bộ giỏ hàng?')) return;
        cart=[];
        syncAfterCartChange();
    }

    function syncAfterCartChange(){
        renderCart();
        renderMenu();
        saveCartToStorage();
    }

    // ================== RENDER CART ==================
    function renderCart(){
        var wrap = document.getElementById('cartItems');
        var totalItems = cart.reduce(function(s,i){return s+i.quantity;},0);
        var totalMoney = cart.reduce(function(s,i){return s+i.quantity*i.price;},0);

        document.getElementById('cartCountHeader').textContent = totalItems;

        if(cart.length===0){
            wrap.innerHTML =
                '<div class="text-center text-white-50" style="font-size:.8rem;">Giỏ hàng trống</div>';
        }else{
            var htmlAll = cart.map(function(it){
                var lineTotal = fmtPrice(it.quantity*it.price);
                var priceEach = fmtPrice(it.price);

                return ''+
                '<div class="cart-item-card">'+
                    '<div class="cart-item-topline">'+
                        '<div>'+ it.name +'</div>'+
                        '<div>'+ lineTotal +'</div>'+
                    '</div>'+
                    '<div class="cart-item-meta">'+ priceEach +' x '+ it.quantity +'</div>'+
                    '<div class="cart-controls-row">'+
                        '<div class="cart-mini-qty">'+
                            '<button class="mini-btn" onclick="decreaseQuantity('+ it.itemId +')"><i class="bi bi-dash-lg"></i></button>'+
                            '<div class="mini-qty-label">'+ it.quantity +'</div>'+
                            '<button class="mini-btn" onclick="increaseQuantity('+ it.itemId +')"><i class="bi bi-plus-lg"></i></button>'+
                        '</div>'+
                        '<button class="remove-btn" onclick="removeFromCart('+ it.itemId +')">'+
                            '<i class="bi bi-trash"></i>'+
                            '<span>Xóa</span>'+
                        '</button>'+
                    '</div>'+
                '</div>';
            }).join('');
            wrap.innerHTML = htmlAll;
        }

        document.getElementById('cartTotal').textContent = fmtPrice(totalMoney);
        updatePriorityPreview();
    }

    // ================== PRIORITY PREVIEW ==================
    function updatePriorityPreview(){
        var prioritySelectEl = document.getElementById('orderPriority');
        var priorityPreviewEl = document.getElementById('priorityPreview');

        var val = prioritySelectEl.value;
        var label = 'Bình thường';
        var cls   = 'p-normal';

        if(val==='URGENT'){ label='Khẩn cấp'; cls='p-urgent'; }
        else if(val==='HIGH'){ label='Cao'; cls='p-high'; }
        else if(val==='LOW'){ label='Thấp'; cls='p-low'; }

        priorityPreviewEl.className = 'priority-chip '+cls;
        priorityPreviewEl.textContent = 'Ưu tiên: ' + label;
    }

    // ================== STORAGE ==================
    function saveCartToStorage(){
        localStorage.setItem('orderCart', JSON.stringify(cart));
    }
    function loadCartFromStorage(){
        var saved = localStorage.getItem('orderCart');
        if(saved){
            cart = JSON.parse(saved);
        }
        renderCart();
    }

    // ================== TOAST ==================
    function showToastSuccess(msg){
        var tw = document.getElementById('toastWrap');
        var card = document.createElement('div');
        card.className = 'toast-card';

        card.innerHTML =
            '<div class="toast-icon"><i class="bi bi-check-lg"></i></div>'+
            '<div class="toast-body">'+ msg +'</div>'+
            '<div class="toast-close" onclick="closeToast(this)">✕</div>';

        tw.appendChild(card);

        requestAnimationFrame(function(){
            card.classList.add('show');
        });

        setTimeout(function(){
            hideToast(card);
        }, 3000);
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

    // ================== ORDER FLOW ==================
    /**
     * 1. Tạo order (POST /orders)
     *    -> backend sẽ tạo order.status = DINING (khách đang dùng)
     * 2. Với orderId trả về, gửi từng món (POST /orders/{orderId}/items)
     *    -> backend addOrderItem() tạo kitchen ticket và tính tiền
     * 3. Khi món được bếp nấu xong và phục vụ,
     *    nhân viên bấm "đã phục vụ" => markItemAsServed().
     *    Khi tất cả món SERVED, ReceptionServlet sẽ show bàn là READY_TO_PAY,
     *    và quầy lễ tân sẽ thấy "Chờ thanh toán".
     */
    function createOrder(){
        if(cart.length===0){
            showToastSuccess('Giỏ hàng đang trống, chưa thể gửi vào bếp.');
            return;
        }

        var urlParams = new URLSearchParams(window.location.search);
        var tableId = urlParams.get('tableId');
        if(!tableId){
            showToastSuccess('Không tìm thấy thông tin bàn!');
            return;
        }

        var specialInstructions = document.getElementById('specialInstructions').value;
        var priority = document.getElementById('orderPriority').value;

        // tạo order
        var params = new URLSearchParams();
        params.append('tableId', tableId);
        params.append('orderType', 'DINE_IN');
        params.append('notes', specialInstructions); // ghi chú chung order

        fetch(CTX + '/orders', {
            method:'POST',
            headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:params
        })
        .then(r => r.json())
        .then(data => {
            if(!data.success){
                showToastSuccess('Lỗi tạo đơn hàng: ' + data.error);
                return;
            }
            var orderId = data.orderId;
            pushItemsToOrder(orderId, priority, specialInstructions);
        })
        .catch(err => {
            console.error('createOrder error:', err);
            showToastSuccess('Có lỗi khi tạo đơn hàng.');
        });
    }

    function pushItemsToOrder(orderId, priority, noteAll){
        var done=0;
        var total=cart.length;

        cart.forEach(function(item){
            var params=new URLSearchParams();
            params.append('menuItemId', item.itemId);
            params.append('quantity', item.quantity);
            params.append('priority', priority);
            params.append('course', 'MAIN');
            params.append('specialInstructions', noteAll || item.specialInstructions || '');

            fetch(CTX + '/orders/'+orderId+'/items', {
                method:'POST',
                headers:{'Content-Type':'application/x-www-form-urlencoded'},
                body:params
            })
            .then(r => r.json())
            .then(res => {
                done++;
                if(done===total){
                    showToastSuccess('Đã gửi đơn vào bếp thành công!');
                    cart=[];
                    saveCartToStorage();
                    renderCart();
                    renderMenu();
                    document.getElementById('specialInstructions').value='';
                }
            })
            .catch(err => {
                console.error('pushItemsToOrder error:', err);
                done++;
            });
        });
    }
</script>

</body>
</html>
