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
    <title>Lịch Phân Ca Tuần | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap / icons / fonts -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <style>
        body {
            font-family: "Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
            background-color:#f5f6fa;
        }

        .app-shell {
            display: grid;
            grid-template-columns: 260px 1fr;
            min-height: 100vh;
        }
        @media(max-width:992px){
            .app-shell { grid-template-columns:1fr; }
            #sidebar {
                position: fixed;
                inset:0 30% 0 0;
                background:#1f2535;
                transform:translateX(-100%);
                transition:transform .2s ease;
                z-index:1040;
                max-width:260px;
                box-shadow:24px 0 60px rgba(0,0,0,.7);
            }
            #sidebar.open { transform:translateX(0); }
        }

        main.main-pane {
            padding:28px 32px 44px;
        }

        /* top bar */
        .topbar {
            background:linear-gradient(135deg,#1b1e2c 0%,#2b2f46 60%,#1c1f30 100%);
            border-radius:12px;
            border:1px solid rgba(255,255,255,.1);
            box-shadow:0 32px 64px rgba(0,0,0,.6);
            padding:16px 20px;
            margin-top:58px;
            margin-bottom:24px;
            color:#fff;
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
        }
        .top-left {
            color:#fff;
        }
        .top-left .title {
            display:flex;
            align-items:center;
            gap:.6rem;
            font-weight:600;
            font-size:1rem;
            line-height:1.35;
            color:#fff;
        }
        .top-left .title i {
            color:#FEA116;
            font-size:1.1rem;
        }
        .top-left .sub {
            margin-top:4px;
            font-size:.8rem;
            color:#94a3b8;
        }
        .top-right {
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.75rem;
            color:#fff;
        }
        .user-chip {
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.18);
            border-radius:8px;
            font-size:.8rem;
            line-height:1.2;
            font-weight:500;
            color:#fff;
            display:flex;
            align-items:center;
            gap:.5rem;
            padding:6px 10px;
        }
        .role-badge {
            background:#FEA116;
            color:#1e1e2f;
            border-radius:5px;
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
                border-radius:6px;
                padding:6px 10px;
            }
            .btn-toggle-sidebar:hover {
                background:rgba(255,255,255,.07);
            }
        }

        /* filter bar (Year / Week select row like screenshot) */
        .week-filter-bar {
            background:#fff;
            border:1px solid #cbd5e1;
            border-radius:6px 6px 0 0;
            border-bottom:0;
            font-size:.8rem;
            font-weight:600;
            display:flex;
            align-items:center;
            flex-wrap:wrap;
            gap:1rem;
            padding:.5rem .75rem;
        }
        .week-filter-bar label {
            margin:0;
            color:#1e293b;
        }
        .week-filter-bar select {
            font-size:.8rem;
            padding:.25rem .5rem;
        }

        /* timetable table */
        .timetable-wrapper {
            background:#fff;
            border:1px solid #cbd5e1;
            border-radius:6px;
            overflow-x:auto;
            box-shadow:0 20px 48px rgba(15,23,42,.08);
        }

        table.timetable {
            width:100%;
            min-width:1100px;
            border-collapse:collapse;
            font-size:.8rem;
        }

        /* Header row (MON, TUE...) */
        .timetable thead tr:first-child th {
            background:#4e68a1;
            color:#fff;
            font-weight:600;
            border:1px solid #3b4c79;
            text-align:left;
            padding:.5rem .5rem;
            font-size:.8rem;
        }
        .timetable thead tr:first-child th:first-child {
            width:120px;
        }

        /* Date row under header */
        .timetable thead tr:nth-child(2) th {
            background:#6f85bd;
            color:#fff;
            font-weight:500;
            border:1px solid #3b4c79;
            text-align:left;
            padding:.4rem .5rem;
            font-size:.8rem;
        }

        /* body rows */
        .timetable tbody td {
            border:1px solid #cbd5e1;
            vertical-align:top;
            padding:.5rem;
            line-height:1.4;
            min-height:56px;
        }
        .timetable tbody td.slot-label {
            background:#f8fafc;
            color:#1e293b;
            font-weight:600;
            width:120px;
        }

        /* inside each cell: shift block(s) */
        .shift-block {
            margin-bottom:.75rem;
        }
        .role-line {
            font-size:.8rem;
            line-height:1.3;
            margin-bottom:.25rem;
            border-left:3px solid #4f46e5;
            padding-left:.5rem;
            color:#1e293b;
        }
        .role-line .role-name {
            font-weight:600;
            color:#4f46e5;
            min-width:80px;
            display:inline-block;
        }
        .role-line .staff-name {
            font-weight:500;
            color:#334155;
        }
        .role-line .staff-phone {
            font-size:.7rem;
            color:#64748b;
        }

        /* status line */
        .status-line {
            font-size:.7rem;
            font-weight:600;
            margin-left:.5rem;
        }
        .st-scheduled { color:#1e40af; }
        .st-done { color:#065f46; }
        .st-cancelled { color:#b91c1c; }

        /* inline actions for manager/admin */
        .inline-actions {
            margin-top:.25rem;
        }
        .inline-actions form,
        .inline-actions a {
            display:inline-block;
            margin-right:.4rem;
        }
        .inline-actions .btn-sm {
            padding:.2rem .4rem;
            font-size:.7rem;
            line-height:1.2;
            border-radius:6px;
        }

        /* flash messages */
        .alert {
            font-size:.8rem;
        }
    </style>
</head>

<body>

<!-- Header -->
<jsp:include page="/layouts/Header.jsp"/>

<c:set var="u" value="${sessionScope.user}"/>

<div class="app-shell">
    <!-- Sidebar -->
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <!-- MAIN -->
    <main class="main-pane">

        <!-- top bar -->
        <section class="topbar">
            <div class="top-left">
                <div class="title">
                    <i class="bi bi-calendar-week"></i>
                    <span>Lịch phân ca (tuần)</span>
                </div>
                <div class="sub">
                    Ca 1: 08:00-14:00 &nbsp;|&nbsp;
                    Ca 2: 14:00-22:00 &nbsp;|&nbsp;
                    Ca 3: 22:00-04:00 (+1)
                </div>
            </div>

            <div class="top-right">
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
                    <i class="bi bi-list"></i>
                    <span>Menu</span>
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

        <!-- FILTER BAR giống YEAR / WEEK -->
        <section class="timetable-wrapper mb-4">
            <div class="week-filter-bar">
                <div class="d-flex align-items-center gap-2">
                    <label for="yearSel">YEAR</label>
                    <select id="yearSel" class="form-select form-select-sm" style="width:auto;">
                        <option value="${selectedYear}">${selectedYear}</option>
                        <!-- sau này bạn có thể render thêm các năm khác -->
                    </select>
                </div>

                <div class="d-flex align-items-center gap-2">
                    <label for="weekSel">WEEK</label>
                    <select id="weekSel" class="form-select form-select-sm" style="width:auto;">
                        <option>${selectedWeekLabel}</option>
                        <!-- sau này bạn loop các tuần khác -->
                    </select>
                </div>

                <div class="ms-auto d-flex flex-wrap gap-2">
                    <a href="<c:url value='/ShiftScheduleServlet'/>"
                       class="btn btn-outline-dark btn-sm">
                        <i class="bi bi-list-ul me-1"></i>Danh sách
                    </a>

                    <c:if test="${canManage}">
                        <a href="<c:url value='/ShiftScheduleServlet?action=create'/>"
                           class="btn btn-primary btn-sm">
                            <i class="bi bi-plus-circle me-1"></i>Phân ca mới
                        </a>
                    </c:if>
                </div>
            </div>

            <!-- TIMETABLE -->
            <div class="table-responsive">
                <table class="timetable">
                    <thead>
                        <!-- Row 1: MON / TUE / ... -->
                        <tr>
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

                        <!-- Row 2: 20/10, 21/10 ... -->
                        <tr>
                            <th></th>
                            <c:forEach var="d" items="${weekDays}">
                                <th>
                                    <!-- hiển thị dd/MM -->
                                    ${d.dayOfMonth}/${d.monthValue}
                                </th>
                            </c:forEach>
                        </tr>
                    </thead>

                    <tbody>
                        <!-- SLOT 1: 08:00-14:00 -->
                        <tr>
                            <td class="slot-label">
                                Slot 1<br/>
                                <small>08:00-14:00</small>
                            </td>

                            <c:forEach var="day" items="${weekDays}">
                                <td>
                                    <c:forEach var="s" items="${shifts}">
                                        <c:if test="${s.shiftDate == day && s.startTime == '08:00'}">
                                            <div class="shift-block">
                                                <div class="role-line">
                                                    <span class="role-name">${s.staffRoleName}:</span>
                                                    <span class="staff-name">${s.staffName}</span>
                                                    <span class="staff-phone">(${s.phone})</span>

                                                    <c:choose>
                                                        <c:when test="${s.status == 'SCHEDULED'}">
                                                            <span class="status-line st-scheduled">Lên lịch</span>
                                                        </c:when>
                                                        <c:when test="${s.status == 'DONE'}">
                                                            <span class="status-line st-done">Hoàn thành</span>
                                                        </c:when>
                                                        <c:when test="${s.status == 'CANCELLED'}">
                                                            <span class="status-line st-cancelled">Hủy</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-line">${s.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <c:if test="${canManage}">
                                                    <div class="inline-actions">
                                                        <a class="btn btn-outline-warning btn-sm"
                                                           title="Sửa"
                                                           href="<c:url value='/ShiftScheduleServlet?action=edit&id=${s.shiftId}'/>">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>

                                                        <form method="POST"
                                                              action="<c:url value='/ShiftScheduleServlet'/>"
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
                                                              action="<c:url value='/ShiftScheduleServlet'/>"
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

                        <!-- SLOT 2: 14:00-22:00 -->
                        <tr>
                            <td class="slot-label">
                                Slot 2<br/>
                                <small>14:00-22:00</small>
                            </td>

                            <c:forEach var="day" items="${weekDays}">
                                <td>
                                    <c:forEach var="s" items="${shifts}">
                                        <c:if test="${s.shiftDate == day && s.startTime == '14:00'}">
                                            <div class="shift-block">
                                                <div class="role-line">
                                                    <span class="role-name">${s.staffRoleName}:</span>
                                                    <span class="staff-name">${s.staffName}</span>
                                                    <span class="staff-phone">(${s.phone})</span>

                                                    <c:choose>
                                                        <c:when test="${s.status == 'SCHEDULED'}">
                                                            <span class="status-line st-scheduled">Lên lịch</span>
                                                        </c:when>
                                                        <c:when test="${s.status == 'DONE'}">
                                                            <span class="status-line st-done">Hoàn thành</span>
                                                        </c:when>
                                                        <c:when test="${s.status == 'CANCELLED'}">
                                                            <span class="status-line st-cancelled">Hủy</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-line">${s.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <c:if test="${canManage}">
                                                    <div class="inline-actions">
                                                        <a class="btn btn-outline-warning btn-sm"
                                                           title="Sửa"
                                                           href="<c:url value='/ShiftScheduleServlet?action=edit&id=${s.shiftId}'/>">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>

                                                        <form method="POST"
                                                              action="<c:url value='/ShiftScheduleServlet'/>"
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
                                                              action="<c:url value='/ShiftScheduleServlet'/>"
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

                        <!-- SLOT 3: 22:00-04:00 -->
                        <tr>
                            <td class="slot-label">
                                Slot 3<br/>
                                <small>22:00-04:00</small>
                            </td>

                            <c:forEach var="day" items="${weekDays}">
                                <td>
                                    <c:forEach var="s" items="${shifts}">
                                        <c:if test="${s.shiftDate == day && s.startTime == '22:00'}">
                                            <div class="shift-block">
                                                <div class="role-line">
                                                    <span class="role-name">${s.staffRoleName}:</span>
                                                    <span class="staff-name">${s.staffName}</span>
                                                    <span class="staff-phone">(${s.phone})</span>

                                                    <c:choose>
                                                        <c:when test="${s.status == 'SCHEDULED'}">
                                                            <span class="status-line st-scheduled">Lên lịch</span>
                                                        </c:when>
                                                        <c:when test="${s.status == 'DONE'}">
                                                            <span class="status-line st-done">Hoàn thành</span>
                                                        </c:when>
                                                        <c:when test="${s.status == 'CANCELLED'}">
                                                            <span class="status-line st-cancelled">Hủy</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-line">${s.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <c:if test="${canManage}">
                                                    <div class="inline-actions">
                                                        <a class="btn btn-outline-warning btn-sm"
                                                           title="Sửa"
                                                           href="<c:url value='/ShiftScheduleServlet?action=edit&id=${s.shiftId}'/>">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>

                                                        <form method="POST"
                                                              action="<c:url value='/ShiftScheduleServlet'/>"
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
                                                              action="<c:url value='/ShiftScheduleServlet'/>"
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

    </main>
</div>

<jsp:include page="/layouts/Footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function toggleSidebar(){
        var el = document.getElementById('sidebar');
        if(el){ el.classList.toggle('open'); }
    }

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
