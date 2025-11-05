<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    Models.User user = (Models.User) session.getAttribute("user");
    String fullName = (user != null) ? (user.getFirstName() + " " + user.getLastName()) : "Chef";
    String shortName = (user != null) ? user.getFirstName() : "Chef";
%>

<style>
    /* ====== TOP BAR STYLE (giống waiter) ====== */
    .pos-topbar-shell {
        background:
            radial-gradient(circle at 0% 0%, rgba(255,255,255,.08) 0%, rgba(0,0,0,0) 60%),
            linear-gradient(135deg, #111827 0%, #1e2537 40%, #2b3245 100%);
        border: 1px solid rgba(255,255,255,.08);
        border-radius: 8px;
        box-shadow: 0 28px 64px rgba(0,0,0,.6);
        padding: .75rem 1rem;
        margin: .5rem .5rem 1rem;
        color: #fff;
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        flex-wrap: wrap;
        font-family: "Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
    }

    /* LEFT BRAND */
    .pos-brand-block{
        display:flex;
        align-items:flex-start;
        gap:.75rem;
        min-width:0;
    }
    .pos-brand-icon{
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
        align-items:baseline;
        flex-wrap:wrap;
        gap:.4rem;
        font-size:.95rem;
        font-weight:600;
        color:#fff;
        white-space:nowrap;
    }
    .pos-brand-row .dot{
        opacity:.4;
        font-weight:400;
    }
    .pos-brand-sub{
        font-size:.7rem;
        line-height:1.3;
        font-weight:400;
        color:rgba(255,255,255,.6);
        white-space:nowrap;
    }

    /* RIGHT ACTIONS */
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
        display:inline-flex;
        align-items:center;
        gap:.4rem;
        text-decoration:none;
        box-shadow:0 20px 40px rgba(0,0,0,.6);
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

    /* CHEF IDENTITY CHIP */
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
        background:#FEA116;
        color:#1e1e2f;
        border-radius:.4rem;
        padding:.2rem .45rem;
        font-size:.7rem;
        line-height:1.2;
        font-weight:600;
        box-shadow:0 8px 16px rgba(254,161,22,.4);
        border:1px solid rgba(0,0,0,.15);
    }

    /* USER DROPDOWN */
    .dropdown-toggle.top-pill-user{
        background:rgba(255,255,255,.06);
        border:1px solid rgba(255,255,255,.18);
        border-radius:.5rem;
        color:#fff;
        font-size:.8rem;
        line-height:1.2;
        font-weight:500;
        padding:.45rem .6rem;
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

    /* RESPONSIVE */
    @media(max-width:992px){
        .pos-topbar-shell{
            flex-direction:column;
            align-items:stretch;
            row-gap:.75rem;
        }
        .pos-action-block{
            margin-left:0;
        }
    }
</style>

<!-- ====== HEADER BAR ====== -->
<div class="pos-topbar-shell">
    <!-- LEFT SIDE: Brand -->
    <div class="pos-brand-block">
        <div class="pos-brand-icon">
            <i class="fas fa-fire"></i>
        </div>
        <div class="pos-brand-text">
            <div class="pos-brand-row">
                <span>KDS</span>
                <span class="dot">•</span>
                <span><%= fullName %></span>
            </div>
            <div class="pos-brand-sub">
                Kitchen Display / Theo dõi món realtime / Ra món
            </div>
        </div>
    </div>

    <!-- RIGHT SIDE: Actions -->
    <div class="pos-action-block">

        <!-- Link: Màn hình KDS -->
        <a class="top-pill" href="${pageContext.request.contextPath}/kds">
            <i class="fas fa-tv"></i>
            <span>Màn hình KDS</span>
        </a>

        <!-- Link: Phiếu bếp -->
        <a class="top-pill" href="${pageContext.request.contextPath}/kds/tickets">
            <i class="fas fa-receipt"></i>
            <span>Phiếu bếp</span>
        </a>

        <!-- Chip tên + role -->
        <div class="chef-identity">
            <i class="fas fa-user-tie"></i>
            <span><%= fullName %></span>
            <span class="chef-role-badge">Chef</span>
        </div>

        <!-- User dropdown -->
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
