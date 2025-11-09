<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    request.setAttribute("page", "reception");
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
    <meta charset="UTF-8"/>
    <title>Quầy lễ tân / Thu ngân | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>

    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <style>
        :root {
            --bg-app: #f5f6fa;
            --bg-grad-1: rgba(88, 80, 200, 0.08);
            --bg-grad-2: rgba(254, 161, 22, 0.06);

            --panel-light-top: #fafaff;
            --panel-light-bottom: #ffffff;

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --brand:#4f46e5;

            --success:#16a34a;
            --danger:#dc2626;

            --waitpay:#b45309;
            --waitpay-bg:rgba(251,191,36,.15);
            --waitpay-border:rgba(251,191,36,.55);

            --line:#e5e7eb;

            --radius-lg:18px;
            --radius-md:12px;
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
            padding: 24px 26px 40px;
        }

        .pos-topbar {
            position: relative;
            background: linear-gradient(135deg, #1b1e2c, #2b2f46 60%, #1c1f30 100%);
            border:1px solid rgba(255,255,255,.1);
            border-radius: var(--radius-md);
            padding: 12px 18px;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 32px 64px rgba(0,0,0,.6);
            margin-top: 56px;
            margin-bottom: 18px;
            color: #fff;
            gap: 0.75rem;
        }

        .pos-left .title-row {
            display: flex;
            align-items: center;
            gap: .6rem;
            font-weight: 600;
            font-size: .95rem;
            line-height: 1.35;
            color: #fff;
        }
        .pos-left .title-row i {
            color: var(--accent);
            font-size: 1.1rem;
        }
        .pos-left .sub {
            margin-top: 4px;
            font-size: .78rem;
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
            padding: 5px 9px;
            font-size: .78rem;
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
                font-size:.78rem;
                line-height:1.2;
                border-radius: var(--radius-sm);
                padding:5px 9px;
            }
            .btn-toggle-sidebar:hover { background: rgba(255,255,255,.07); }
        }

        /* Takeaway summary on top bar */
        .takeaway-summary {
            display:flex;
            flex-direction:column;
            gap: 0.15rem;
            padding:6px 10px;
            border-radius: var(--radius-md);
            background: rgba(15,23,42,.65);
            border: 1px solid rgba(148,163,184,.4);
        }
        .takeaway-summary-head {
            display:flex;
            align-items:center;
            gap:.4rem;
            font-size:.75rem;
            text-transform:uppercase;
            letter-spacing:.04em;
            color: #e5e7eb;
            font-weight:600;
        }
        .takeaway-summary-head i {
            color: var(--accent);
        }
        .takeaway-summary-body {
            display:flex;
            flex-wrap:wrap;
            gap:.35rem;
            margin-top:2px;
        }
        .takeaway-pill {
            display:inline-flex;
            align-items:center;
            gap:.25rem;
            padding:2px 6px;
            border-radius:999px;
            font-size:.72rem;
            line-height:1.2;
            border:1px solid rgba(148,163,184,.7);
            background:rgba(15,23,42,.7);
        }
        .takeaway-pill .num{
            font-weight:600;
        }
        .takeaway-pill-new{
            border-color:rgba(59,130,246,.8);
        }
        .takeaway-pill-prep{
            border-color:rgba(236,72,153,.8);
        }
        .takeaway-pill-pay{
            border-color:rgba(251,191,36,.9);
        }

        .tables-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px,1fr));
            gap: 1rem;
        }

        .card-pos {
            position: relative;
            background: linear-gradient(to bottom right, #ffffff 0%, #fafaff 80%);
            border: 1px solid rgba(99,102,241,.25);
            border-radius: var(--radius-lg);
            box-shadow: 0 8px 30px rgba(0,0,0,.06), inset 0 1px 0 rgba(255,255,255,.8);
            padding: 0.85rem 1rem 0.8rem;
            min-height: 190px;
            display:flex;
            flex-direction:column;
            justify-content:space-between;
            transition: all .22s ease;
        }
        .card-pos:hover {
            box-shadow: 0 16px 44px rgba(254,161,22,.16), inset 0 1px 0 rgba(255,255,255,1);
            transform: translateY(-1px);
        }
        .card-pos::before {
            content:"";
            position:absolute;
            top:0;
            left:0;
            width:100%;
            height:4px;
            background: linear-gradient(90deg, var(--accent), var(--brand));
            border-radius: 10px 10px 0 0;
            opacity:.85;
        }

        .table-head-block {
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            gap:.5rem;
            margin-bottom:.6rem;
        }

        .table-info-left {
            display:flex;
            flex-direction:column;
            gap:.25rem;
        }

        .table-title-row {
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.45rem;
            font-weight:600;
            font-size:.95rem;
            color:var(--ink-900);
            line-height:1.3;
        }

        .status-badge {
            font-size:.68rem;
            font-weight:600;
            line-height:1.2;
            padding: .22rem .45rem;
            border-radius: var(--radius-sm);
            border:1px solid transparent;
            white-space:nowrap;
        }
        .status-ready {
            background: rgba(254,161,22,.15);
            border:1px solid rgba(254,161,22,.45);
            color:#78350f;
        }
        .status-pending-vnpay {
            background: var(--waitpay-bg);
            border:1px solid var(--waitpay-border);
            color: var(--waitpay);
        }
        .status-dining {
            background: rgba(99,102,241,.12);
            border:1px solid rgba(99,102,241,.4);
            color:#1e1e2f;
        }
        .status-free {
            background: rgba(16,185,129,.15);
            border:1px solid rgba(16,185,129,.4);
            color:#065f46;
        }

        .table-subline {
            font-size:.78rem;
            color:var(--ink-500);
            line-height:1.35;
        }

        .table-meta-block {
            font-size:.78rem;
            line-height:1.45;
            color:var(--ink-900);
            background:#fff;
            border-radius: var(--radius-md);
            border:1px solid var(--line);
            box-shadow:0 10px 26px rgba(15,23,42,.05);
            padding:.6rem .8rem;
            margin-bottom:.6rem;
        }

        .meta-row {
            display:flex;
            justify-content:space-between;
            flex-wrap:wrap;
            font-size:.78rem;
            margin-bottom:.3rem;
        }
        .meta-row:last-child { margin-bottom:0; }

        .meta-label {
            color:var(--ink-500);
            font-weight:500;
        }
        .meta-value {
            color:var(--ink-900);
            font-weight:600;
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.35rem;
        }

        .chip-status {
            font-size:.68rem;
            line-height:1.2;
            border-radius: var(--radius-sm);
            padding:.2rem .45rem;
            background: rgba(255,255,255,.7);
            border:1px solid rgba(0,0,0,.08);
            font-weight:600;
            color:#1f2937;
        }

        .actions-block {
            display:flex;
            flex-wrap:wrap;
            gap:.55rem;
            margin-top:auto;
        }

        .btn-pay {
            flex:1;
            min-width:120px;
            display:flex;
            align-items:center;
            justify-content:center;
            gap:.4rem;
            text-align:center;
            font-size:.78rem;
            font-weight:600;
            border:none;
            border-radius: var(--radius-sm);
            padding:.5rem .7rem;
            line-height:1.2;
            cursor:pointer;
            text-decoration:none;
            color:#fff;
            background:linear-gradient(135deg,#16a34a,#0f766e);
            box-shadow:0 10px 26px rgba(22,163,74,.25);
            transition:all .18s ease;
        }
        .btn-pay[disabled] {
            cursor:not-allowed;
            background:#94a3b8;
            box-shadow:none;
        }

        .btn-view-history {
            flex:1;
            min-width:120px;
            display:flex;
            align-items:center;
            justify-content:center;
            gap:.4rem;
            text-align:center;
            font-size:.78rem;
            font-weight:600;
            background:#fff;
            color:var(--ink-900);
            border-radius: var(--radius-sm);
            padding:.5rem .7rem;
            line-height:1.2;
            border:1px solid var(--line);
            text-decoration:none;
            box-shadow:0 10px 26px rgba(15,23,42,.05);
        }
        .btn-view-history:hover {
            background:#f8fafc;
        }

        .hint-muted {
            flex-basis:100%;
            font-size:.68rem;
            color:var(--ink-500);
            line-height:1.35;
            text-align:left;
        }

        /* Takeaway list section */
        .takeaway-section {
            margin-top:22px;
            background:rgba(15,23,42,.03);
            border-radius: var(--radius-lg);
            border:1px solid rgba(148,163,184,.35);
            padding:12px 14px;
            box-shadow:0 14px 36px rgba(15,23,42,.06);
        }
        .takeaway-section-header{
            display:flex;
            justify-content:space-between;
            align-items:flex-end;
            flex-wrap:wrap;
            gap:.4rem;
            margin-bottom:8px;
        }
        .takeaway-section-title{
            font-size:.9rem;
            font-weight:600;
            color:var(--ink-900);
        }
        .takeaway-section-sub{
            font-size:.75rem;
            color:var(--ink-500);
        }
        .takeaway-empty{
            font-size:.78rem;
            color:var(--ink-500);
            padding:4px 2px;
        }
        .takeaway-row{
            display:grid;
            grid-template-columns: minmax(0,1.6fr) minmax(0,0.7fr) minmax(0,0.9fr);
            align-items:center;
            gap:.5rem;
            padding:6px 0;
            border-top:1px dashed rgba(148,163,184,.6);
            font-size:.78rem;
        }
        .takeaway-row:first-of-type{
            border-top:none;
        }
        .takeaway-code{
            font-weight:600;
            color:var(--ink-900);
        }
        .takeaway-meta{
            font-size:.72rem;
            color:var(--ink-500);
        }
        .takeaway-status-badge{
            display:inline-flex;
            align-items:center;
            justify-content:flex-start;
            gap:.25rem;
            padding:2px 8px;
            border-radius:999px;
            font-size:.7rem;
            border:1px solid rgba(148,163,184,.7);
            background:#fff;
        }
        .takeaway-status-badge span{
            font-weight:600;
        }
        .takeaway-amount{
            font-weight:600;
            text-align:right;
            color:var(--ink-900);
        }
        @media(max-width:768px){
            .takeaway-row{
                grid-template-columns: minmax(0,1.3fr) minmax(0,0.9fr);
                grid-template-rows:auto auto;
            }
            .takeaway-row .takeaway-amount{
                grid-column:2;
            }
        }

        /* Reservations chips (bàn đã đặt trong ngày) */
        .reservation-list{
            display:flex;
            flex-wrap:wrap;
            gap:.25rem;
        }
        .res-chip{
            display:inline-flex;
            align-items:center;
            gap:.2rem;
            padding:2px 6px;
            border-radius:999px;
            font-size:.7rem;
            border:1px solid rgba(59,130,246,.45);
            background:rgba(59,130,246,.06);
            color:#1d4ed8;
            font-weight:500;
        }
        .res-chip i{
            font-size:.8rem;
        }
    </style>
</head>

<body>
<jsp:include page="/layouts/Header.jsp"/>

<div class="app-shell">
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <main class="main-pane">

        <header class="pos-topbar">
            <div class="pos-left">
                <div class="title-row">
                    <i class="bi bi-door-open"></i>
                    <span>Quầy lễ tân / Thu ngân</span>
                </div>
                <div class="sub">
                    Xem trạng thái bàn • Thu tiền mặt / VNPAY • Đóng bàn • Theo dõi đơn mang đi
                </div>
            </div>

            <div class="pos-right">
                <div class="takeaway-summary">
                    <div class="takeaway-summary-head">
                        <i class="bi bi-bag-check"></i>
                        <span>Đơn mang đi</span>
                    </div>
                    <div class="takeaway-summary-body">
                        <span class="takeaway-pill takeaway-pill-new">
                            <span class="num"><c:out value="${takeawayNewCount}" default="0"/></span>
                            <span>mới</span>
                        </span>
                        <span class="takeaway-pill takeaway-pill-prep">
                            <span class="num"><c:out value="${takeawayPreparingCount}" default="0"/></span>
                            <span>đang làm</span>
                        </span>
                        <span class="takeaway-pill takeaway-pill-pay">
                            <span class="num"><c:out value="${takeawayWaitingPayCount}" default="0"/></span>
                            <span>chờ thanh toán</span>
                        </span>
                    </div>
                </div>

                <div class="user-chip">
                    <i class="bi bi-person-badge"></i>
                    <span>${sessionScope.user.firstName} ${sessionScope.user.lastName}</span>
                    <span class="role-badge">${sessionScope.user.roleName}</span>
                </div>

                <button class="btn-toggle-sidebar" onclick="toggleSidebar()">
                    <i class="bi bi-list"></i>
                    <span>Menu</span>
                </button>
            </div>
        </header>

        <div class="tables-grid">

            <c:forEach var="t" items="${tables}">

                <!-- Lấy danh sách reservation hôm nay cho bàn này -->
                <c:set var="reservationsToday" value="${reservationsByTable[t.tableId]}"/>
                <c:set var="hasReservationToday" value="${not empty reservationsToday}"/>

                <c:choose>
                    <c:when test="${t.payState == 'READY_TO_PAY'}">
                        <c:set var="statusClass" value="status-ready"/>
                        <c:set var="statusText"  value="Chờ thanh toán"/>
                    </c:when>
                    <c:when test="${t.payState == 'PENDING_VNPAY'}">
                        <c:set var="statusClass" value="status-pending-vnpay"/>
                        <c:set var="statusText"  value="Chờ VNPAY quét QR"/>
                    </c:when>
                    <c:when test="${t.payState == 'DINING'}">
                        <c:set var="statusClass" value="status-dining"/>
                        <c:set var="statusText"  value="Đang phục vụ"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="statusClass" value="status-free"/>
                        <c:set var="statusText"  value="Bàn trống / Dọn bàn"/>
                    </c:otherwise>
                </c:choose>

                <div class="card-pos">
                    <div class="table-head-block">
                        <div class="table-info-left">
                            <div class="table-title-row">
                                <span>Bàn ${t.tableNumber}</span>
                                <span class="status-badge ${statusClass}">${statusText}</span>

                                <!-- Badge nếu bàn có reservation trong ngày -->
                                <c:if test="${hasReservationToday}">
                                    <span class="status-badge"
                                          style="background:rgba(59,130,246,.12);
                                                 border-color:rgba(59,130,246,.5);
                                                 color:#1d4ed8;">
                                        Đã đặt hôm nay
                                    </span>
                                </c:if>
                            </div>

                            <div class="table-subline">
                                Khu vực:
                                <strong>
                                    <c:choose>
                                        <c:when test="${not empty t.areaName}">
                                            ${t.areaName}
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </strong>
                                • Ghế: ${t.capacity}
                                • Trạng thái bàn: ${t.tableStatus}
                            </div>
                        </div>
                    </div>

                    <div class="table-meta-block">
                        <div class="meta-row">
                            <div class="meta-label">Phiên bàn</div>
                            <div class="meta-value">
                                <c:choose>
                                    <c:when test="${t.sessionId != null}">
                                        #${t.sessionId}
                                        <span style="font-weight:400;color:var(--ink-500);">
                                            mở lúc
                                            <c:choose>
                                                <c:when test="${t.sessionOpenTime != null}">
                                                    ${t.sessionOpenTime}
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="meta-row">
                            <div class="meta-label">Order ID</div>
                            <div class="meta-value">
                                <c:choose>
                                    <c:when test="${t.orderId != null}">
                                        #${t.orderId}
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="meta-row">
                            <div class="meta-label">Trạng thái order</div>
                            <div class="meta-value">
                                <c:choose>
                                    <c:when test="${t.orderStatus != null}">
                                        <span class="chip-status">${t.orderStatus}</span>
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="meta-row">
                            <div class="meta-label">Phục vụ</div>
                            <div class="meta-value">
                                <c:choose>
                                    <c:when test="${not empty t.waiterName}">
                                        ${t.waiterName}
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="meta-row">
                            <div class="meta-label">Mở order lúc</div>
                            <div class="meta-value">
                                <c:choose>
                                    <c:when test="${t.orderOpenedAt != null}">
                                        ${t.orderOpenedAt}
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Đặt bàn hôm nay -->
                        <div class="meta-row">
                            <div class="meta-label">Đặt bàn hôm nay</div>
                            <div class="meta-value">
                                <c:choose>
                                    <c:when test="${hasReservationToday}">
                                        <div class="reservation-list">
                                            <c:forEach var="r" items="${reservationsToday}">
                                                <span class="res-chip">
                                                    <i class="bi bi-calendar-event"></i>
                                                    ${r.timeDisplay} – ${r.partySize} khách
                                                </span>
                                            </c:forEach>
                                        </div>
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="meta-row">
                            <div class="meta-label">Tổng tạm tính</div>
                            <div class="meta-value">
                                <c:choose>
                                    <c:when test="${t.totalAmountPending != null}">
                                        ${t.totalAmountPending}đ
                                    </c:when>
                                    <c:otherwise>0đ</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <div class="actions-block">
                        <c:choose>
                            <c:when test="${t.payState == 'READY_TO_PAY'
                                           || t.payState == 'PENDING_VNPAY'
                                           || t.canPayAgain == true}">
                                <a class="btn-pay"
                                   href="<c:url value='/PaymentServlet?tableId=${t.tableId}'/>">
                                    <i class="bi bi-cash-coin"></i>
                                    <span>
                                        <c:choose>
                                            <c:when test="${t.payState == 'PENDING_VNPAY' || t.canPayAgain == true}">
                                                Tiếp tục thanh toán
                                            </c:when>
                                            <c:otherwise>
                                                Tính tiền
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </a>
                            </c:when>

                            <c:otherwise>
                                <button class="btn-pay" disabled>
                                    <i class="bi bi-cash-coin"></i>
                                    <span>Không thể tính tiền</span>
                                </button>
                            </c:otherwise>
                        </c:choose>

                        <a class="btn-view-history"
                           href="<c:url value='/table-history?tableId=${t.tableId}'/>">
                            <i class="bi bi-clock-history"></i>
                            <span>Lịch sử bàn</span>
                        </a>

                        <div class="hint-muted">
                            • “Tính tiền / Tiếp tục thanh toán” sẽ gộp các order chưa SETTLED
                            hoặc mở lại bill PROFORMA đang chờ VNPAY (PENDING).<br/>
                            • “Lịch sử bàn” xem các món đã gọi / đã phục vụ.
                        </div>
                    </div>
                </div>
            </c:forEach>

        </div>

        <!-- Takeaway orders list -->
        <div class="takeaway-section">
            <div class="takeaway-section-header">
                <div>
                    <div class="takeaway-section-title">
                        Đơn mang đi đang hoạt động
                    </div>
                    <div class="takeaway-section-sub">
                        Theo dõi các đơn không gắn bàn: mới, đang làm, chờ thanh toán
                    </div>
                </div>
            </div>

            <c:if test="${empty takeawayOrders}">
                <div class="takeaway-empty">
                    Chưa có đơn mang đi nào đang mở.
                </div>
            </c:if>

            <c:forEach var="o" items="${takeawayOrders}">
                <div class="takeaway-row">
                    <div>
                        <div class="takeaway-code">Đơn #${o.orderCode}</div>
                        <div class="takeaway-meta">
                            Khách:
                            <c:choose>
                                <c:when test="${not empty o.customerName}">
                                    ${o.customerName}
                                </c:when>
                                <c:otherwise>Khách lẻ</c:otherwise>
                            </c:choose>
                            • Mở lúc
                            <c:choose>
                                <c:when test="${o.openedAt != null}">
                                    ${o.openedAt}
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div>
                        <span class="takeaway-status-badge">
                            <i class="bi bi-activity"></i>
                            <span>${o.status}</span>
                        </span>
                    </div>
                    <div class="takeaway-amount">
                        <c:choose>
                            <c:when test="${o.totalAmount != null}">
                                ${o.totalAmount}đ
                            </c:when>
                            <c:otherwise>0đ</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:forEach>
        </div>

    </main>
</div>

<jsp:include page="/layouts/Footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function toggleSidebar() {
        var el = document.getElementById('sidebar');
        if (el) el.classList.toggle('open');
    }
</script>

</body>
</html>
