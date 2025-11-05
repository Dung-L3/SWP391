<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    request.setAttribute("page", "shift");
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
    <title>Lịch Phân Ca (tuần) · RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap / icons / fonts -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>

    <!-- global layout css -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <style>
        :root {
            --bg-app:#f5f6fa;
            --bg-grad-1:rgba(88,80,200,.08);
            --bg-grad-2:rgba(254,161,22,.06);

            --panel-dark-end:#1b1e2c;
            --panel-dark-mid:#2b2f46;
            --panel-dark-start:#1c1f30;

            --panel-light-top:#ffffff;
            --panel-light-bottom:#fafaff;

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --brand:#4f46e5;
            --brand-border:#6366f1;

            --success:#16a34a;
            --danger:#dc2626;

            --line:#cbd5e1;

            --radius-lg:20px;
            --radius-md:14px;
            --radius-sm:6px;

            --sidebar-width:280px;
        }

        body {
            font-family:"Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            color:var(--ink-900);
            min-height:100vh;
        }

        /* ============ LAYOUT SHELL ============ */
        .app-shell {
            display:grid;
            grid-template-columns:var(--sidebar-width) 1fr;
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
                background:#1f2535;
                transform:translateX(-100%);
                transition:transform .2s ease;
                z-index:1040;
                box-shadow:24px 0 60px rgba(0,0,0,.7);
            }
            #sidebar.open{transform:translateX(0);}
        }

        main.main-pane{
            padding:28px 32px 44px;
        }

        /* ============ TOP POS BAR (giống staff-management) ============ */
        .pos-topbar{
            background:linear-gradient(135deg,var(--panel-dark-end) 0%, var(--panel-dark-mid) 60%, var(--panel-dark-start) 100%);
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
            color:#fff;
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
            line-height:1.2;
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
                line-height:1.2;
                border-radius:var(--radius-sm);
                padding:6px 10px;
            }
            .btn-toggle-sidebar:hover{
                background:rgba(255,255,255,.07);
            }
        }

        /* ============ FLASH ALERTS ============ */
        .alert{
            border-radius:var(--radius-sm);
            border:1px solid transparent;
            box-shadow:0 16px 40px rgba(0,0,0,.12);
            font-size:.9rem;
        }

        /* ============ CONTROL CARD (tuần / hành động) ============ */
        .control-card{
            background:linear-gradient(to bottom right,var(--panel-light-top) 0%,var(--panel-light-bottom) 100%);
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:0 28px 64px rgba(15,23,42,.12), inset 0 1px 0 rgba(255,255,255,.8);
            padding:1rem 1.25rem .75rem;
            margin-bottom:24px;
            position:relative;
            border-top:4px solid var(--accent);
            font-size:.8rem;
        }
        .control-card::before{
            content:"";
            position:absolute;
            top:0;
            left:0;
            width:100%;
            height:5px;
            background:linear-gradient(90deg,var(--accent),var(--brand));
            border-radius:8px 8px 0 0;
            opacity:.8;
        }

        .control-row-top{
            display:flex;
            flex-wrap:wrap;
            row-gap:1rem;
            column-gap:1.5rem;
            justify-content:space-between;
            align-items:flex-start;
        }

        .control-col{
            display:flex;
            flex-direction:column;
            min-width:180px;
        }
        .control-label{
            font-size:.75rem;
            font-weight:600;
            color:var(--ink-900);
            margin-bottom:.25rem;
        }
        .control-desc{
            font-size:.7rem;
            color:var(--ink-500);
            line-height:1.3;
        }

        .control-card .form-control,
        .control-card .form-control-sm,
        .control-card .form-select,
        .control-card .btn{
            border-radius:10px;
            font-size:.8rem;
            line-height:1.2;
        }
        .control-card .form-control,
        .control-card .form-control-sm{
            border:1.5px solid #e2e8f0;
            background:#fff;
            transition:all .25s ease;
        }
        .control-card .form-control:focus,
        .control-card .form-control-sm:focus{
            border-color:var(--accent);
            box-shadow:0 0 0 .25rem rgba(254,161,22,.25);
            background:#fffefc;
        }

        .week-nav-btns a{
            white-space:nowrap;
            border-radius:10px;
            font-size:.7rem;
            line-height:1.2;
        }
        .right-actions .btn{
            border-radius:10px;
            font-size:.75rem;
            line-height:1.2;
            font-weight:500;
        }
        .btn-outline-dark{
            border-color:#1e293b;
            color:#1e293b;
        }
        .btn-outline-dark:hover{
            background:#1e293b;
            color:#fff;
        }

        .btn-primary.btn-sm{
            background:var(--accent);
            border:none;
            color:#1e1e2f;
            font-weight:600;
            box-shadow:0 16px 30px rgba(254,161,22,.3);
        }
        .btn-primary.btn-sm:hover{
            filter:brightness(1.05);
            box-shadow:0 20px 40px rgba(254,161,22,.45);
        }

        /* ============ TIMETABLE WRAPPER ============ */
        .timetable-wrapper{
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:0 28px 64px rgba(15,23,42,.12), inset 0 1px 0 rgba(255,255,255,.8);
            overflow-x:auto;
        }

        table.timetable{
            width:100%;
            min-width:1100px;
            border-collapse:collapse;
            font-size:.8rem;
        }

        thead tr.head-day th{
            background:linear-gradient(90deg,#3b4c79 0%,#2b365c 100%);
            color:#fff;
            border:1px solid #2b365c;
            padding:.5rem .5rem;
            font-weight:600;
            text-align:left;
        }
        thead tr.head-date th{
            background:#4f5f93;
            color:#fff;
            border:1px solid #2b365c;
            padding:.4rem .5rem;
            font-weight:500;
            text-align:left;
        }
        thead tr.head-day th:first-child,
        thead tr.head-date th:first-child{
            width:200px;
        }

        tbody td{
            border:1px solid #e2e8f0;
            vertical-align:top;
            padding:.6rem .5rem;
            min-height:70px;
            background:#fff;
        }
        td.slot-label{
            background:#f8fafc;
            font-weight:600;
            color:#1e293b;
        }
        td.slot-label small{
            display:block;
            color:#475569;
            font-weight:400;
        }

        /* shift block card */
        .shift-block{
            background:#fff;
            border-left:3px solid var(--brand);
            border-radius:8px;
            padding:.6rem .6rem .5rem .6rem;
            box-shadow:0 16px 30px rgba(15,23,42,.08);
            margin-bottom:.75rem;
            position:relative;
        }
        .shift-header{
            line-height:1.3;
            margin-bottom:.25rem;
        }
        .role-label{
            font-weight:600;
            color:var(--brand);
            word-break:break-word;
        }
        .emp-name{
            font-weight:600;
            color:var(--ink-900);
            word-break:break-word;
        }
        .phone{
            font-size:.7rem;
            color:var(--ink-500);
            word-break:break-word;
        }

        /* status */
        .status-line{
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
            margin-top:.25rem;
        }
        .st-scheduled{color:#1e40af;}    /* xanh dương đậm */
        .st-done{color:#065f46;}         /* xanh lá đậm */
        .st-cancelled{color:#b91c1c;}    /* đỏ */

        /* inline actions for a shift */
        .inline-actions{
            display:flex;
            flex-wrap:wrap;
            gap:.4rem;
            margin-top:.6rem;
        }
        .inline-actions .btn-sm{
            padding:.3rem .45rem;
            font-size:.7rem;
            line-height:1.2;
            border-radius:8px;
        }
        .btn-outline-warning.btn-sm{
            border-color:#facc15;
            color:#ca8a04;
        }
        .btn-outline-warning.btn-sm:hover{
            background:#fef9c3;
            border-color:#eab308;
            color:#713f12;
        }
        .btn-outline-success.btn-sm{
            border-color:#16a34a;
            color:#16a34a;
        }
        .btn-outline-success.btn-sm:hover{
            background:#d1fae5;
            border-color:#0f766e;
            color:#065f46;
        }
        .btn-outline-secondary.btn-sm{
            border-color:#94a3b8;
            color:#475569;
        }
        .btn-outline-secondary.btn-sm:hover{
            background:#e2e8f0;
            border-color:#475569;
            color:#1e293b;
        }
        
    </style>
</head>

<body>

<!-- HEADER GLOBAL -->
<jsp:include page="/layouts/Header.jsp"/>

<c:set var="u" value="${sessionScope.user}"/>

<div class="app-shell">
    <!-- SIDEBAR -->
    <aside id="sidebar" class="text-white bg-dark">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <!-- MAIN -->
    <main class="main-pane">

        <!-- TOPBAR POS -->
        <section class="pos-topbar">
            <div class="pos-left">
                <div class="title-row">
                    <i class="bi bi-calendar-week"></i>
                    <span>Lịch phân ca (tuần)</span>
                </div>
                <div class="sub">
                    Ca 1: 08:00–14:00 | Ca 2: 14:00–22:00 | Ca 3: 22:00–04:00 (+1)
                </div>
            </div>

            <div class="pos-right">
                <div class="user-chip">
                    <i class="bi bi-person-badge"></i>
                    <span>
                        <c:choose>
                            <c:when test="${not empty u.fullName}">${u.fullName}</c:when>
                            <c:otherwise>${u.firstName} ${u.lastName}</c:otherwise>
                        </c:choose>
                    </span>
                    <span class="role-badge">${u.roleName}</span>
                </div>

                <button class="btn-toggle-sidebar" onclick="toggleSidebar()">
                    <i class="bi bi-list"></i><span>Menu</span>
                </button>
            </div>
        </section>

        <!-- FLASH -->
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

        <!-- CONTROL CARD -->
        <section class="control-card">
            <div class="control-row-top">

                <!-- Chọn ngày để xem tuần -->
                <form class="control-col"
                      method="get"
                      action="<c:url value='/StaffShiftServlet'/>">
                    <input type="hidden" name="action" value="weekTimetable"/>

                    <label class="control-label" for="baseDate">Chọn ngày</label>
                    <input class="form-control form-control-sm"
                           type="date"
                           id="baseDate"
                           name="baseDate"
                           style="min-width:150px"
                           value="${baseDate}"/>

                    <button type="submit"
                            class="btn btn-primary btn-sm mt-2"
                            style="max-width:140px;">
                        Xem tuần
                    </button>
                </form>

                <!-- Thông tin tuần đang hiển thị -->
                <div class="control-col">
                    <label class="control-label">Tuần hiển thị</label>
                    <div class="fw-semibold text-dark">
                        ${weekLabel} (${selectedYear})
                    </div>
                    <div class="control-desc">
                        ${mondayDate.dayOfMonth}/${mondayDate.monthValue}
                        đến
                        ${sundayDate.dayOfMonth}/${sundayDate.monthValue}
                    </div>

                    <div class="week-nav-btns d-flex flex-wrap gap-2 mt-2">
                        <a class="btn btn-outline-secondary btn-sm"
                           href="<c:url value='/StaffShiftServlet?action=weekTimetable&baseDate=${prevDate}'/>">
                            ← Tuần trước
                        </a>
                        <a class="btn btn-outline-secondary btn-sm"
                           href="<c:url value='/StaffShiftServlet?action=weekTimetable&baseDate=${nextDate}'/>">
                            Tuần sau →
                        </a>
                    </div>
                </div>

                <!-- Hành động -->
                <div class="control-col right-actions">
                    <div>
                        <label class="control-label">Tác vụ</label><br/>

                        <a class="btn btn-outline-dark btn-sm mb-2"
                           href="<c:url value='/StaffShiftServlet?action=list'/>">
                            <i class="bi bi-list-ul me-1"></i>Danh sách
                        </a>

                        <c:if test="${canManage}">
                            <a class="btn btn-primary btn-sm mb-2"
                               href="<c:url value='/StaffShiftServlet?action=create'/>">
                                <i class="bi bi-plus-circle me-1"></i>Phân ca mới
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>
        </section>

        <!-- TIMETABLE -->
        <section class="timetable-wrapper">
            <div class="table-responsive">
                <table class="timetable">
                    <thead>
                    <tr class="head-day">
                        <th></th>
                        <c:forEach var="d" varStatus="st" items="${weekDays}">
                            <th>
                                <c:choose>
                                    <c:when test="${st.index == 0}">MON</c:when>
                                    <c:when test="${st.index == 1}">TUE</c:when>
                                    <c:when test="${st.index == 2}">WED</c:when>
                                    <c:when test="${st.index == 3}">THU</c:when>
                                    <c:when test="${st.index == 4}">FRI</c:when>
                                    <c:when test="${st.index == 5}">SAT</c:when>
                                    <c:otherwise>SUN</c:otherwise>
                                </c:choose>
                            </th>
                        </c:forEach>
                    </tr>
                    <tr class="head-date">
                        <th></th>
                        <c:forEach var="d" items="${weekDays}">
                            <th>${d.dayOfMonth}/${d.monthValue}</th>
                        </c:forEach>
                    </tr>
                    </thead>

                    <tbody>
                    <!-- SLOT 1 -->
                    <tr>
                        <td class="slot-label">
                            Slot 1
                            <small>08:00–14:00</small>
                        </td>

                        <c:forEach var="day" items="${weekDays}">
                            <td>
                                <c:forEach var="s" items="${shifts}">
                                    <c:if test="${s.shiftDate == day && s.startTime == '08:00'}">
                                        <div class="shift-block">
                                            <div class="shift-header">
                                                <span class="role-label">${s.staffRoleName}:</span>
                                                <span class="emp-name">${s.staffFullName}</span><br/>
                                                <span class="phone">(${s.staffPhone})</span>
                                            </div>

                                            <div class="status-line">
                                                <c:choose>
                                                    <c:when test="${s.status == 'SCHEDULED'}">
                                                        <span class="st-scheduled">Lên lịch</span>
                                                    </c:when>
                                                    <c:when test="${s.status == 'DONE'}">
                                                        <span class="st-done">Hoàn thành</span>
                                                    </c:when>
                                                    <c:when test="${s.status == 'CANCELLED'}">
                                                        <span class="st-cancelled">Hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${s.status}
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <c:if test="${canManage}">
                                                <div class="inline-actions">
                                                    <!-- Sửa -->
                                                    <a class="btn btn-outline-warning btn-sm"
                                                       title="Sửa ca"
                                                       href="<c:url value='/StaffShiftServlet?action=edit&id=${s.shiftId}'/>">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>

                                                    <!-- Hoàn thành -->
                                                    <form method="POST"
                                                          action="<c:url value='/StaffShiftServlet'/>"
                                                          style="display:inline;">
                                                        <input type="hidden" name="action" value="markDone"/>
                                                        <input type="hidden" name="shift_id" value="${s.shiftId}"/>
                                                        <button type="submit"
                                                                class="btn btn-outline-success btn-sm"
                                                                title="Hoàn thành">
                                                            <i class="bi bi-check2-circle"></i>
                                                        </button>
                                                    </form>

                                                    <!-- Hủy -->
                                                    <form method="POST"
                                                          action="<c:url value='/StaffShiftServlet'/>"
                                                          style="display:inline;">
                                                        <input type="hidden" name="action" value="cancelShift"/>
                                                        <input type="hidden" name="shift_id" value="${s.shiftId}"/>
                                                        <button type="submit"
                                                                class="btn btn-outline-secondary btn-sm"
                                                                title="Hủy ca">
                                                            <i class="bi bi-x-octagon"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </td>
                        </c:forEach>
                    </tr>

                    <!-- SLOT 2 -->
                    <tr>
                        <td class="slot-label">
                            Slot 2
                            <small>14:00–22:00</small>
                        </td>

                        <c:forEach var="day" items="${weekDays}">
                            <td>
                                <c:forEach var="s" items="${shifts}">
                                    <c:if test="${s.shiftDate == day && s.startTime == '14:00'}">
                                        <div class="shift-block">
                                            <div class="shift-header">
                                                <span class="role-label">${s.staffRoleName}:</span>
                                                <span class="emp-name">${s.staffFullName}</span><br/>
                                                <span class="phone">(${s.staffPhone})</span>
                                            </div>

                                            <div class="status-line">
                                                <c:choose>
                                                    <c:when test="${s.status == 'SCHEDULED'}">
                                                        <span class="st-scheduled">Lên lịch</span>
                                                    </c:when>
                                                    <c:when test="${s.status == 'DONE'}">
                                                        <span class="st-done">Hoàn thành</span>
                                                    </c:when>
                                                    <c:when test="${s.status == 'CANCELLED'}">
                                                        <span class="st-cancelled">Hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${s.status}
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <c:if test="${canManage}">
                                                <div class="inline-actions">
                                                    <a class="btn btn-outline-warning btn-sm"
                                                       title="Sửa ca"
                                                       href="<c:url value='/StaffShiftServlet?action=edit&id=${s.shiftId}'/>">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>

                                                    <form method="POST"
                                                          action="<c:url value='/StaffShiftServlet'/>"
                                                          style="display:inline;">
                                                        <input type="hidden" name="action" value="markDone"/>
                                                        <input type="hidden" name="shift_id" value="${s.shiftId}"/>
                                                        <button type="submit"
                                                                class="btn btn-outline-success btn-sm"
                                                                title="Hoàn thành">
                                                            <i class="bi bi-check2-circle"></i>
                                                        </button>
                                                    </form>

                                                    <form method="POST"
                                                          action="<c:url value='/StaffShiftServlet'/>"
                                                          style="display:inline;">
                                                        <input type="hidden" name="action" value="cancelShift"/>
                                                        <input type="hidden" name="shift_id" value="${s.shiftId}"/>
                                                        <button type="submit"
                                                                class="btn btn-outline-secondary btn-sm"
                                                                title="Hủy ca">
                                                            <i class="bi bi-x-octagon"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </td>
                        </c:forEach>
                    </tr>

                    <!-- SLOT 3 -->
                    <tr>
                        <td class="slot-label">
                            Slot 3
                            <small>22:00–04:00</small>
                        </td>

                        <c:forEach var="day" items="${weekDays}">
                            <td>
                                <c:forEach var="s" items="${shifts}">
                                    <c:if test="${s.shiftDate == day && s.startTime == '22:00'}">
                                        <div class="shift-block">
                                            <div class="shift-header">
                                                <span class="role-label">${s.staffRoleName}:</span>
                                                <span class="emp-name">${s.staffFullName}</span><br/>
                                                <span class="phone">(${s.staffPhone})</span>
                                            </div>

                                            <div class="status-line">
                                                <c:choose>
                                                    <c:when test="${s.status == 'SCHEDULED'}">
                                                        <span class="st-scheduled">Lên lịch</span>
                                                    </c:when>
                                                    <c:when test="${s.status == 'DONE'}">
                                                        <span class="st-done">Hoàn thành</span>
                                                    </c:when>
                                                    <c:when test="${s.status == 'CANCELLED'}">
                                                        <span class="st-cancelled">Hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${s.status}
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <c:if test="${canManage}">
                                                <div class="inline-actions">
                                                    <a class="btn btn-outline-warning btn-sm"
                                                       title="Sửa ca"
                                                       href="<c:url value='/StaffShiftServlet?action=edit&id=${s.shiftId}'/>">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>

                                                    <form method="POST"
                                                          action="<c:url value='/StaffShiftServlet'/>"
                                                          style="display:inline;">
                                                        <input type="hidden" name="action" value="markDone"/>
                                                        <input type="hidden" name="shift_id" value="${s.shiftId}"/>
                                                        <button type="submit"
                                                                class="btn btn-outline-success btn-sm"
                                                                title="Hoàn thành">
                                                            <i class="bi bi-check2-circle"></i>
                                                        </button>
                                                    </form>

                                                    <form method="POST"
                                                          action="<c:url value='/StaffShiftServlet'/>"
                                                          style="display:inline;">
                                                        <input type="hidden" name="action" value="cancelShift"/>
                                                        <input type="hidden" name="shift_id" value="${s.shiftId}"/>
                                                        <button type="submit"
                                                                class="btn btn-outline-secondary btn-sm"
                                                                title="Hủy ca">
                                                            <i class="bi bi-x-octagon"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </td>
                        </c:forEach>
                    </tr>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- FOOTER -->
        <div class="page-shift-footer">
    <jsp:include page="/layouts/Footer.jsp"/>
</div>

    </main>
</div>

<!-- JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function toggleSidebar(){
        const el = document.getElementById('sidebar');
        if(el){ el.classList.toggle('open'); }
    }

    // auto close alerts
    setTimeout(function () {
        document.querySelectorAll('.alert').forEach(function (al) {
            try {
                var bsAlert = new bootstrap.Alert(al);
                bsAlert.close();
            } catch (e) {}
        });
    }, 5000);
</script>

</body>
</html>
