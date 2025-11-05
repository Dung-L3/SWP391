<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    // Thiết lập chung
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

            --radius-lg:20px;
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
            padding: 28px 32px 44px;
        }

        /* top bar */
        .pos-topbar {
            position: relative;
            background: linear-gradient(135deg, #1b1e2c, #2b2f46 60%, #1c1f30 100%);
            border:1px solid rgba(255,255,255,.1);
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
            .btn-toggle-sidebar:hover { background: rgba(255,255,255,.07); }
        }

        .tables-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(min(320px,100%),1fr));
            gap: 1.25rem;
        }

        .card-pos {
            position: relative;
            background: linear-gradient(to bottom right, #ffffff 0%, #fafaff 80%);
            border: 1px solid rgba(99,102,241,.25);
            border-top: 4px solid var(--accent);
            border-radius: var(--radius-lg);
            box-shadow: 0 10px 40px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,.8);
            padding: 1rem 1.25rem 1rem;
            min-height: 220px;
            display:flex;
            flex-direction:column;
            justify-content:space-between;
            transition: all .25s ease;
        }
        .card-pos:hover {
            box-shadow: 0 20px 60px rgba(254,161,22,.2), inset 0 1px 0 rgba(255,255,255,1);
            transform: translateY(-2px);
        }
        .card-pos::before {
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

        .table-head-block {
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            gap:.75rem;
            margin-bottom:.75rem;
        }

        .table-info-left {
            display:flex;
            flex-direction:column;
            gap:.4rem;
        }

        .table-title-row {
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.5rem;
            font-weight:600;
            font-size:1rem;
            color:var(--ink-900);
            line-height:1.3;
        }

        .status-badge {
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
            padding: .3rem .5rem;
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
            font-size:.8rem;
            color:var(--ink-500);
            line-height:1.4;
        }

        .table-meta-block {
            font-size:.8rem;
            line-height:1.5;
            color:var(--ink-900);
            background:#fff;
            border-radius: var(--radius-md);
            border:1px solid var(--line);
            box-shadow:0 12px 32px rgba(15,23,42,.06);
            padding:.75rem 1rem;
            margin-bottom:1rem;
        }

        .meta-row {
            display:flex;
            justify-content:space-between;
            flex-wrap:wrap;
            font-size:.8rem;
            margin-bottom:.4rem;
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
            gap:.4rem;
        }

        .chip-status {
            font-size:.7rem;
            line-height:1.2;
            border-radius: var(--radius-sm);
            padding:.25rem .5rem;
            background: rgba(255,255,255,.6);
            border:1px solid rgba(0,0,0,.1);
            font-weight:600;
            color:#1f2937;
        }

        .actions-block {
            display:flex;
            flex-wrap:wrap;
            gap:.75rem;
            margin-top:auto;
        }

        .btn-pay {
            flex:1;
            min-width:140px;
            display:flex;
            align-items:center;
            justify-content:center;
            gap:.5rem;
            text-align:center;
            font-size:.8rem;
            font-weight:600;
            border:none;
            border-radius: var(--radius-sm);
            padding:.6rem .8rem;
            line-height:1.2;
            cursor:pointer;
            text-decoration:none;
            color:#fff;
            background:linear-gradient(135deg,#16a34a,#0f766e);
            box-shadow:0 12px 32px rgba(22,163,74,.3);
            transition:all .2s ease;
        }
        .btn-pay[disabled] {
            cursor:not-allowed;
            background:#94a3b8;
            box-shadow:none;
        }

        .btn-view-history {
            flex:1;
            min-width:140px;
            display:flex;
            align-items:center;
            justify-content:center;
            gap:.5rem;
            text-align:center;
            font-size:.8rem;
            font-weight:600;
            background:#fff;
            color:var(--ink-900);
            border-radius: var(--radius-sm);
            padding:.6rem .8rem;
            line-height:1.2;
            border:1px solid var(--line);
            text-decoration:none;
            box-shadow:0 12px 32px rgba(15,23,42,.06);
        }
        .btn-view-history:hover {
            background:#f8fafc;
        }

        .hint-muted {
            flex-basis:100%;
            font-size:.7rem;
            color:var(--ink-500);
            line-height:1.4;
            text-align:left;
        }
    </style>
</head>

<body>
<jsp:include page="/layouts/Header.jsp"/>

<div class="app-shell">
    <!-- sidebar (ẩn/hiện trên mobile) -->
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <main class="main-pane">

        <!-- Thanh top hiển thị người dùng hiện tại -->
        <header class="pos-topbar">
            <div class="pos-left">
                <div class="title-row">
                    <i class="bi bi-door-open"></i>
                    <span>Quầy lễ tân / Thu ngân</span>
                </div>
                <div class="sub">
                    Xem trạng thái bàn • Thu tiền mặt / VNPAY • Đóng bàn
                </div>
            </div>

            <div class="pos-right">
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

        <!-- Lưới tất cả các bàn -->
        <div class="tables-grid">

            <c:forEach var="t" items="${tables}">
                
                <c:choose>
                    <c:when test="${t.payState == 'READY_TO_PAY'}">
                        <c:set var="statusClass" value="status-ready"/>
                        <c:set var="statusText"  value="Chờ thanh toán"/>
                    </c:when>

                    <c:when test="${t.payState == 'PENDING_VNPAY'}">
                        <c:set var="statusClass" value="status-pending-vnpay"/>
                        <c:set var="statusText"  value="Chờ VNPay quét QR"/>
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
                                        <span class="text-muted" style="font-weight:400;">
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

                    <!-- Action buttons -->
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
                            hoặc mở lại bill PROFORMA đang chờ VNPay (PENDING).<br/>
                            • “Lịch sử bàn” xem các món đã gọi / đã phục vụ.
                        </div>
                    </div>
                </div>
            </c:forEach>

        </div><!--/.tables-grid-->
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
