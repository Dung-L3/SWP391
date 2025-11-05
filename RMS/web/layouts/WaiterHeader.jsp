<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    Models.User user = (Models.User) session.getAttribute("user");
    String fullName = (user != null) ? (user.getFirstName() + " " + user.getLastName()) : "Waiter";
    String shortName = (user != null) ? user.getFirstName() : "User";
%>

<style>
    /* ====== TOP BAR THEME (match KDS style) ====== */
    .waiter-topbar {
        background: linear-gradient(90deg, #0b1a3a 0%, #1f2937 60%, #2f364a 100%);
        color: #fff;
        padding: .6rem 1rem;
        display: flex;
        align-items: center;
        box-shadow: 0 20px 40px rgba(0,0,0,.5);
        border-bottom: 1px solid rgba(255,255,255,.07);
        font-family: "Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
    }

    .waiter-left,
    .waiter-right {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
    }

    .waiter-left {
        flex: 1;
        min-width: 0;
        gap: .5rem;
        font-size: .95rem;
        font-weight: 500;
        color: #fff;
    }

    .waiter-left .brand-icon {
        background: rgba(255,255,255,.08);
        border: 1px solid rgba(255,255,255,.18);
        color: #fff;
        width: 32px;
        height: 32px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: .9rem;
        line-height: 1;
        box-shadow: 0 12px 24px rgba(0,0,0,.6);
    }

    .waiter-left .brand-text {
        display: flex;
        flex-direction: column;
        line-height: 1.3;
    }

    .brand-main {
        font-weight: 600;
        color: #fff;
        display: flex;
        align-items: center;
        gap: .4rem;
        font-size: .95rem;
        white-space: nowrap;
    }

    .brand-main .app-name {
        color: #fff;
    }

    .brand-main .dash {
        opacity: .4;
        font-weight: 400;
    }

    .brand-sub {
        font-size: .7rem;
        font-weight: 400;
        color: rgba(255,255,255,.6);
        white-space: nowrap;
    }

    /* NAV LINKS (middle actions) */
    .waiter-nav {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: .75rem;
        margin-left: 1rem;
    }
    .waiter-link {
        display: inline-flex;
        align-items: center;
        gap: .4rem;
        background: rgba(255,255,255,.06);
        border: 1px solid rgba(255,255,255,.18);
        color: #fff;
        font-size: .8rem;
        line-height: 1.2;
        font-weight: 500;
        padding: .4rem .6rem;
        border-radius: .5rem;
        text-decoration: none;
        transition: all .15s ease;
        box-shadow: 0 12px 24px rgba(0,0,0,.5);
    }
    .waiter-link i {
        font-size: .8rem;
        line-height: 1;
    }
    .waiter-link:hover {
        background: rgba(255,255,255,.1);
        color: #fff;
        text-decoration: none;
        box-shadow: 0 16px 32px rgba(0,0,0,.6);
    }

    /* USER BLOCK (right side) */
    .waiter-right {
        gap: .75rem;
        margin-left: auto;
    }

    .user-chip {
        display: flex;
        align-items: center;
        gap: .5rem;
        background: rgba(255,255,255,.06);
        border: 1px solid rgba(255,255,255,.18);
        border-radius: .5rem;
        padding: .45rem .6rem;
        font-size: .8rem;
        line-height: 1.2;
        color: #fff;
        font-weight: 500;
        white-space: nowrap;
        box-shadow: 0 16px 32px rgba(0,0,0,.6);
    }

    .user-chip i {
        color: #fff;
        font-size: .8rem;
    }

    .role-badge {
        background: #FEA116;
        color: #1e1e2f;
        border-radius: .4rem;
        padding: .2rem .45rem;
        font-size: .7rem;
        line-height: 1.2;
        font-weight: 600;
        box-shadow: 0 8px 16px rgba(254,161,22,.4);
        border: 1px solid rgba(0,0,0,.15);
    }

    /* DROPDOWN (profile menu) */
    .dropdown-toggle.waiter-userbtn {
        background: transparent;
        border: 1px solid rgba(255,255,255,.25);
        border-radius: .5rem;
        color: #fff;
        font-size: .8rem;
        line-height: 1.2;
        font-weight: 500;
        padding: .45rem .6rem;
        display: flex;
        align-items: center;
        gap: .4rem;
        box-shadow: 0 16px 32px rgba(0,0,0,.6);
    }
    .dropdown-toggle.waiter-userbtn i {
        font-size: .8rem;
        line-height: 1;
        color:#fff;
    }
    .dropdown-toggle.waiter-userbtn:focus,
    .dropdown-toggle.waiter-userbtn:hover {
        background: rgba(255,255,255,.08);
        color:#fff;
        border-color: rgba(255,255,255,.4);
    }

    .dropdown-menu.waiter-menu {
        font-size: .8rem;
        border-radius: .5rem;
        border: 1px solid rgba(0,0,0,.08);
        box-shadow: 0 24px 48px rgba(0,0,0,.4);
        min-width: 180px;
    }
    .dropdown-menu.waiter-menu .dropdown-item {
        display: flex;
        align-items: center;
        gap: .5rem;
        font-weight: 500;
    }
    .dropdown-menu.waiter-menu .dropdown-item i{
        font-size: .8rem;
        width: .9rem;
        text-align: center;
    }

    /* RESPONSIVE */
    @media(max-width: 992px){
        .waiter-topbar{
            flex-wrap: wrap;
            row-gap: .75rem;
        }
        .waiter-left{
            flex: 1 1 100%;
        }
        .waiter-nav{
            flex: 1 1 auto;
            order: 3;
            width:100%;
            flex-wrap: wrap;
            gap: .5rem;
            margin-left: 2.25rem; /* indent under brand icon */
        }
        .waiter-right{
            flex: 1 1 auto;
            order:2;
            margin-left: 2.25rem;
        }
    }
</style>

<div class="waiter-topbar">
    <!-- LEFT BRAND AREA -->
    <div class="waiter-left">
        <div class="brand-icon">
            <i class="fas fa-utensils"></i>
        </div>
        <div class="brand-text">
            <div class="brand-main">
                <span class="app-name">RMS</span>
                <span class="dash">•</span>
                <span class="loc-name">
                    <c:choose>
                        <c:when test="${user != null}"><%= fullName %></c:when>
                        <c:otherwise>Waiter</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="brand-sub">
                Bản đồ bàn / Gọi món / Trạng thái bàn real-time
            </div>
        </div>
    </div>

    <!-- QUICK NAV (center) -->
    <nav class="waiter-nav">
        <a class="waiter-link"
           href="${pageContext.request.contextPath}/tables">
            <i class="fas fa-table"></i>
            <span>Sơ đồ bàn</span>
        </a>

        <a class="waiter-link"
           href="${pageContext.request.contextPath}/order-page">
            <i class="fas fa-receipt"></i>
            <span>Đặt món</span>
        </a>
    </nav>

    <!-- USER / PROFILE (right) -->
    <div class="waiter-right">
        <div class="user-chip">
            <i class="fas fa-id-badge"></i>
            <span><%= fullName %></span>
            <span class="role-badge">Waiter</span>
        </div>

        <div class="dropdown">
            <button class="dropdown-toggle waiter-userbtn" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="fas fa-user-circle"></i>
                <span><%= shortName %></span>
            </button>
            <ul class="dropdown-menu dropdown-menu-end waiter-menu">
                <li>
                    <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                        <i class="fas fa-user"></i>
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
