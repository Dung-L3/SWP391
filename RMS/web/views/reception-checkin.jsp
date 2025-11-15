<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    request.setAttribute("page", "reception-checkin");
    request.setAttribute("overlayNav", false);
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<%!
    public String statusLabel(String s) {
        if (s == null) return "-";
        switch (s.toUpperCase()) {
            case "VACANT": return "Trống";
            case "HELD": return "Đã đặt";
            case "SEATED": return "Có khách";
            case "IN_USE": return "Đang dùng";
            case "REQUEST_BILL": return "Yêu cầu thanh toán";
            case "CLEANING": return "Đang dọn";
            case "OUT_OF_SERVICE": return "Không phục vụ";
            default: return s;
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Check-in | Quầy lễ tân</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>

    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <!-- Toàn bộ style reuse từ trang pricing, chỉ đổi text -->
    <style>
        :root {
            --bg-app: #f5f6fa;
            --bg-grad-1: rgba(88, 80, 200, 0.08);
            --bg-grad-2: rgba(254, 161, 22, 0.06);

            --panel-light-top: #fafaff;
            --panel-light-bottom: #ffffff;
            --panel-dark: #1f2535;
            --panel-dark-border: rgba(255,255,255,.08);

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
            --success-soft:#d1fae5;
            --danger:#dc2626;

            --line:#e5e7eb;
            --line-dark:#2d354d;
            --shadow-card:0 28px 64px rgba(15,23,42,.12);

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

        .pos-topbar {
            position: relative;
            background: linear-gradient(135deg, #1b1e2c, #2b2f46 60%, #1c1f30 100%);
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
            border:1px solid rgba(255,255,255,.1);
        }

        .pos-left .title-row {
            display: flex;
            align-items: center;
            gap: .6rem;
            font-weight: 600;
            font-size: 1rem;
            line-height: 1.35;
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

        /* layout 2 cột giống pricing */
        .pricing-layout {
            display: flex;
            flex-wrap: nowrap;
            gap: 1.5rem;
            transition: all .25s ease;
        }
        @media(max-width:768px){
            .pricing-layout {
                flex-direction: column;
            }
        }

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
            flex: 0 0 280px;
            max-width: 320px;
        }

        .pricing-layout .menu-picker {
            /* luôn dùng style "picked" để cột trái hẹp, phải rộng */
            max-height: calc(100vh - 140px);
            overflow-y: auto;
        }

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
        .picker-desc {
            font-size: .8rem;
            color: var(--ink-500);
        }

        .menu-grid {
            display: flex;
            flex-direction: column;
            gap: .6rem;
        }

        .food-card {
            background: #ffffff;
            border-radius: var(--radius-md);
            border: 2px solid transparent;
            box-shadow: 0 20px 48px rgba(15,23,42,.08);
            padding: .8rem .85rem .7rem;
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
            font-size: .9rem;
            font-weight: 600;
            line-height: 1.3;
            color: var(--ink-900);
        }
        .food-id {
            font-size: .75rem;
            color: var(--ink-500);
        }

        .chip-status {
            font-size: .7rem;
            line-height:1.2;
            border-radius: var(--radius-sm);
            padding:.25rem .55rem;
            border:1px solid transparent;
            font-weight:600;
            white-space:nowrap;
        }
        .chip-status.vacant {
            background:#dcfce7;
            border-color:#bbf7d0;
            color:#166534;
        }
        .chip-status.seated {
            background:#fee2e2;
            border-color:#fecaca;
            color:#b91c1c;
        }
        .chip-status.held {
            background:#fef9c3;
            border-color:#facc15;
            color:#92400e;
        }
        .chip-status.other {
            background:#e5e7eb;
            border-color:#d1d5db;
            color:#374151;
        }

        .pricing-detail {
            flex: 1;
            min-width: 0;
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
            transition: all .25s ease;
        }

        .detail-top {
            display: grid;
            grid-template-columns: 1.1fr 1fr;
            gap: 1.5rem;
        }
        @media(max-width:992px){
            .detail-top {
                grid-template-columns:1fr;
            }
        }

        .detail-card {
            position: relative;
            background: linear-gradient(to bottom right, #ffffff 0%, #fafaff 80%);
            border-radius: var(--radius-lg);
            border: 1px solid rgba(99,102,241,.25);
            border-top: 4px solid var(--accent);
            box-shadow: 0 10px 40px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,.8);
            padding: 1rem 1.25rem 1.25rem;
            transition: all .25s ease;
        }
        .detail-card:hover {
            box-shadow: 0 20px 60px rgba(254,161,22,.2), inset 0 1px 0 rgba(255,255,255,1);
            transform: translateY(-2px);
        }
        .detail-card::before {
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
            line-height:1.3;
            background: linear-gradient(to right, var(--accent), var(--brand));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .detail-sub {
            font-size:.8rem;
            color:var(--ink-500);
        }

        .form-label {
            font-size:.8rem;
            font-weight:600;
            color:var(--ink-700);
        }
        .form-control, .form-select {
            border-radius: 10px;
            border:1.5px solid #e2e8f0;
            transition: all .25s ease;
            background: #ffffff;
            font-size:.85rem;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 0.25rem rgba(254,161,22,.25);
            background: #fffefc;
        }

        .btn-checkin {
            background: linear-gradient(135deg, #22c55e, #16a34a);
            border: none;
            font-weight: 600;
            letter-spacing: .02em;
            box-shadow: 0 4px 20px rgba(34,197,94,.4);
            border-radius: var(--radius-sm);
            font-size:.8rem;
            text-transform:uppercase;
        }
        .btn-checkin:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 25px rgba(34,197,94,.55);
        }

        .btn-update-status {
            border-radius: var(--radius-sm);
            font-size:.8rem;
            font-weight:600;
        }

        .muted-line {
            font-size:.78rem;
            color:var(--ink-500);
            margin-top:.75rem;
        }

        .alert {
            border-radius: var(--radius-md);
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
        <!-- Topbar -->
        <header class="pos-topbar">
            <div class="pos-left">
                <div class="title-row">
                    <i class="bi bi-person-check"></i>
                    <span>Check-in / Quầy lễ tân</span>
                </div>
                <div class="sub">
                    Chọn bàn ở cột trái hoặc nhập mã xác nhận để check-in khách &amp; cập nhật trạng thái bàn.
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

        <!-- flash messages -->
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

        <!-- MAIN LAYOUT giống pricing -->
        <div class="pricing-layout">

            <!-- LEFT: danh sách bàn -->
            <aside class="menu-picker">
                <div class="picker-head">
                    <div class="picker-title">
                        <i class="bi bi-grid-3x3-gap"></i>
                        <span>Danh sách bàn</span>
                    </div>
                    <div class="picker-desc">Bấm vào 1 bàn để xem thông tin &amp; đổi trạng thái bên phải.</div>
                </div>

                <div class="menu-grid">
                    <%
                        Dal.TableDAO tdao = new Dal.TableDAO();
                        java.util.List<Models.DiningTable> tables = tdao.getAllTables();
                        if (tables == null || tables.isEmpty()) {
                    %>
                    <div class="text-center text-muted py-4">
                        Chưa có bàn nào.
                    </div>
                    <%
                        } else {
                            for (Models.DiningTable t : tables) {
                                String status = t.getStatus() == null ? "" : t.getStatus().toUpperCase();
                                String chipClass = "other";
                                if ("VACANT".equals(status)) chipClass = "vacant";
                                else if ("SEATED".equals(status) || "IN_USE".equals(status)) chipClass = "seated";
                                else if ("HELD".equals(status)) chipClass = "held";
                    %>
                    <div class="food-card table-card"
                         data-table-number="<%=t.getTableNumber()%>"
                         data-capacity="<%=t.getCapacity()%>"
                         data-status="<%=statusLabel(t.getStatus())%>">
                        <div class="food-top-row">
                            <div class="food-meta">
                                <div class="food-name">Bàn <%=t.getTableNumber()%></div>
                                <div class="food-id"><%=t.getCapacity()%> chỗ</div>
                            </div>
                            <div class="chip-status <%=chipClass%>">
                                <%=statusLabel(t.getStatus())%>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        }
                    %>
                </div>
            </aside>

            <!-- RIGHT: chi tiết check-in + trạng thái bàn -->
            <section class="pricing-detail">
                <div class="detail-top">

                    <!-- Card 1: Check-in theo mã xác nhận -->
                    <div class="detail-card">
                        <div class="detail-head">
                            <div class="detail-head-left">
                                <i class="bi bi-qr-code-scan"></i>
                                <div class="detail-textgroup">
                                    <div class="detail-title-line">Check-in theo mã xác nhận</div>
                                    <div class="detail-sub">
                                        Nhập <strong>confirmation code</strong> mà khách đã đặt online / qua điện thoại.
                                    </div>
                                </div>
                            </div>
                        </div>

                        <form method="post" action="<c:url value='/reception/checkin-table'/>" class="row g-2 mb-2">
                            <input type="hidden" name="action" value="lookup"/>
                            <div class="col-12 col-md-8">
                                <label class="form-label">Mã xác nhận</label>
                                <input name="confirmationCode"
                                       class="form-control"
                                       placeholder="Nhập mã (vd: RMS123456)"
                                       required/>
                            </div>
                            <div class="col-12 col-md-4 d-flex align-items-end">
                                <button class="btn btn-checkin w-100" type="submit">
                                    <i class="bi bi-search me-1"></i>Tìm
                                </button>
                            </div>
                        </form>

                        <div class="muted-line">
                            Sau khi tìm thấy đơn đặt bàn, kiểm tra thông tin khách và nhấn
                            <strong>"Xác nhận đến"</strong> để mở bàn và chuyển sang trạng thái <em>Có khách</em>.
                        </div>

                        <c:if test="${not empty lookupReservation}">
                            <hr/>
                            <div class="detail-textgroup mb-2">
                                <div class="detail-title-line" style="font-size:.9rem;">
                                    Đơn đặt bàn tìm được
                                </div>
                            </div>
                            <table class="table table-sm mb-2">
                                <tr><th>Khách</th><td>${lookupReservation.customerName}</td></tr>
                                <tr><th>Điện thoại</th><td>${lookupReservation.phone}</td></tr>
                                <tr><th>Email</th><td>${lookupReservation.email}</td></tr>
                                <tr><th>Ngày</th><td>${lookupReservation.reservationDate}</td></tr>
                                <tr><th>Giờ</th><td>${lookupReservation.reservationTime}</td></tr>
                                <tr><th>Số khách</th><td>${lookupReservation.partySize}</td></tr>
                                <tr><th>Bàn (ID)</th><td>${lookupReservation.tableId}</td></tr>
                                <tr><th>Trạng thái đặt</th><td>${lookupReservation.status}</td></tr>
                            </table>

                            <form method="post" action="<c:url value='/reception/checkin-table'/>">
                                <input type="hidden" name="action" value="checkin"/>
                                <input type="hidden" name="confirmationCode" value="${lookupReservation.confirmationCode}"/>
                                <button class="btn btn-success btn-sm">
                                    <i class="bi bi-person-check me-1"></i>Xác nhận khách đã đến &amp; mở bàn
                                </button>
                            </form>
                        </c:if>
                    </div>

                    <!-- Card 2: Thông tin & cập nhật trạng thái bàn -->
                    <div class="detail-card">
                        <div class="detail-head">
                            <div class="detail-head-left">
                                <i class="bi bi-table"></i>
                                <div class="detail-textgroup">
                                    <div class="detail-title-line">Thông tin &amp; trạng thái bàn</div>
                                    <div class="detail-sub">
                                        Chọn bàn ở cột trái, xem thông tin tại đây và đổi trạng thái khi cần.
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row g-2 mb-2">
                            <div class="col-12 col-md-6">
                                <label class="form-label">Bàn đang chọn</label>
                                <input type="text" id="selectedTableNumber" class="form-control" readonly
                                       placeholder="Chưa chọn bàn"/>
                            </div>
                            <div class="col-6 col-md-3">
                                <label class="form-label">Sức chứa</label>
                                <input type="text" id="selectedTableCapacity" class="form-control" readonly/>
                            </div>
                            <div class="col-6 col-md-3">
                                <label class="form-label">Trạng thái hiện tại</label>
                                <input type="text" id="selectedTableStatus" class="form-control" readonly/>
                            </div>
                        </div>

                        <form id="updateStatusForm" method="post" action="<c:url value='/reception/checkin-table'/>" class="row g-2">
                            <input type="hidden" name="action" value="update_status"/>
                            <input type="hidden" name="tableNumber" id="manualTableNumber"/>

                            <div class="col-12 col-md-7">
                                <label class="form-label">Trạng thái mới</label>
                                <select name="newStatus" class="form-select" required>
                                    <option value="VACANT">Trống (VACANT)</option>
                                    <option value="HELD">Đã đặt (HELD)</option>
                                    <option value="SEATED">Có khách (SEATED)</option>
                                    <option value="IN_USE">Đang dùng (IN_USE)</option>
                                    <option value="REQUEST_BILL">Yêu cầu thanh toán (REQUEST_BILL)</option>
                                    <option value="CLEANING">Đang dọn (CLEANING)</option>
                                    <option value="OUT_OF_SERVICE">Không phục vụ (OUT_OF_SERVICE)</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-5 d-flex align-items-end">
                                <button class="btn btn-warning w-100 btn-update-status" type="submit">
                                    Cập nhật trạng thái
                                </button>
                            </div>
                        </form>

                        <div class="muted-line">
                            * Lưu ý: khi chuyển bàn sang <strong>Trống</strong>, hệ thống sẽ giải phóng bàn để nhận khách mới.
                        </div>
                    </div>
                </div>
            </section>
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

    // auto close alert sau 5s
    setTimeout(function () {
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function (al) {
            if (window.bootstrap && bootstrap.Alert) {
                var bsAlert = new bootstrap.Alert(al);
                bsAlert.close();
            } else {
                al.remove();
            }
        });
    }, 5000);

    // chọn bàn bên trái -> fill thông tin & hidden field
    (function () {
        var cards = document.querySelectorAll('.table-card');
        var hiddenTable = document.getElementById('manualTableNumber');
        var lbNumber = document.getElementById('selectedTableNumber');
        var lbCap = document.getElementById('selectedTableCapacity');
        var lbStatus = document.getElementById('selectedTableStatus');

        function selectCard(card) {
            cards.forEach(function (c) { c.classList.remove('active'); });
            card.classList.add('active');

            var tn = card.getAttribute('data-table-number') || '';
            var cap = card.getAttribute('data-capacity') || '';
            var st = card.getAttribute('data-status') || '';

            if (hiddenTable) hiddenTable.value = tn;
            if (lbNumber) lbNumber.value = tn;
            if (lbCap) lbCap.value = cap ? (cap + ' chỗ') : '';
            if (lbStatus) lbStatus.value = st;

            // focus nhẹ xuống khu vực form
            if (lbNumber) lbNumber.scrollIntoView({behavior:'smooth', block:'center'});
        }

        cards.forEach(function (card) {
            card.addEventListener('click', function(){ selectCard(card); });
        });

        // Tự chọn bàn đầu tiên nếu có
        if (cards.length > 0) {
            selectCard(cards[0]);
        }
    })();
</script>
</body>
</html>
