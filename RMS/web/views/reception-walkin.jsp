<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    request.setAttribute("page", "reception-walkin");
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
    <title>Quầy lễ tân — Nhận đặt bàn (Walk-in)</title>
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
            --bg-app:#f5f6fa;
            --bg-grad-1:rgba(88,80,200,.08);
            --bg-grad-2:rgba(254,161,22,.06);

            --panel-light-top:#fafaff;
            --panel-light-bottom:#ffffff;

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.08);
            --accent-border:rgba(254,161,22,.45);

            --brand:#4f46e5;
            --brand-border:#6366f1;

            --success:#16a34a;

            --line:#e5e7eb;
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
            color:var(--ink-900);
            font-family:"Heebo",system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",sans-serif;
        }

        .app-shell {
            display:grid;
            grid-template-columns:var(--sidebar-width) 1fr;
            min-height:100vh;
        }
        @media (max-width:992px) {
            .app-shell {
                grid-template-columns:1fr;
            }
            #sidebar {
                position:fixed;
                inset:0 30% 0 0;
                transform:translateX(-100%);
                transition:transform .2s ease;
                z-index:1040;
                max-width:var(--sidebar-width);
                box-shadow:24px 0 60px rgba(0,0,0,.7);
            }
            #sidebar.open {
                transform:translateX(0);
            }
        }

        main.main-pane {
            padding:28px 32px 44px;
        }

        .pos-topbar {
            position:relative;
            background:linear-gradient(135deg,#1b1e2c,#2b2f46 60%,#1c1f30 100%);
            border-radius:var(--radius-md);
            padding:16px 20px;
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            box-shadow:0 32px 64px rgba(0,0,0,.6);
            margin-top:58px;
            margin-bottom:24px;
            color:#fff;
            border:1px solid rgba(255,255,255,.1);
        }

        .pos-left .title-row {
            display:flex;
            align-items:center;
            gap:.6rem;
            font-weight:600;
            font-size:1rem;
            line-height:1.35;
        }
        .pos-left .title-row i {
            color:var(--accent);
            font-size:1.1rem;
        }
        .pos-left .sub {
            margin-top:4px;
            font-size:.8rem;
            color:var(--ink-400);
        }

        .pos-right {
            display:flex;
            align-items:center;
            flex-wrap:wrap;
            gap:.75rem;
        }

        .user-chip {
            display:flex;
            align-items:center;
            gap:.5rem;
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.18);
            border-radius:var(--radius-md);
            padding:6px 10px;
            font-size:.8rem;
            line-height:1.2;
            font-weight:500;
        }
        .user-chip .role-badge {
            background:var(--accent);
            color:#1e1e2f;
            border-radius:var(--radius-sm);
            padding:2px 6px;
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
        }

        .btn-toggle-sidebar {
            display:none;
        }
        @media (max-width:992px) {
            .btn-toggle-sidebar {
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
            .btn-toggle-sidebar:hover {
                background:rgba(255,255,255,.07);
            }
        }

        .walkin-layout {
            display:flex;
            gap:1.5rem;
            align-items:flex-start;
            transition:all .25s ease;
        }
        @media (max-width:992px) {
            .walkin-layout {
                flex-direction:column;
            }
        }
        .walkin-layout.has-selection .detail-card {
            opacity:1;
            transform:translateY(0) scale(1);
            pointer-events:auto;
        }

        .table-picker {
            flex:0 0 320px;
            max-width:340px;
            background:linear-gradient(to bottom right,var(--panel-light-top),var(--panel-light-bottom));
            border-radius:var(--radius-lg);
            padding:14px 14px 16px;
            border:1px solid var(--line);
            box-shadow:var(--shadow-card);
            max-height:calc(100vh - 180px);
            overflow-y:auto;
            scrollbar-width:thin;
        }
        @media (max-width:992px) {
            .table-picker {
                flex:auto;
                max-width:100%;
                max-height:none;
            }
        }

        .picker-head {
            display:flex;
            flex-direction:column;
            gap:.35rem;
            margin-bottom:1rem;
        }
        .picker-title {
            display:flex;
            align-items:center;
            gap:.5rem;
            font-size:.95rem;
            font-weight:600;
            color:var(--ink-900);
        }
        .picker-title i {
            color:var(--accent);
        }
        .picker-desc {
            font-size:.8rem;
            color:var(--ink-500);
        }

        .table-list {
            display:flex;
            flex-direction:column;
            gap:.6rem;
        }

        .table-card {
            position:relative;
            border-radius:16px;
            padding:.7rem .8rem .65rem;
            background:#ffffff;
            border:1.5px solid rgba(148,163,184,.35);
            box-shadow:0 10px 28px rgba(15,23,42,.08);
            cursor:pointer;
            transition:transform .18s ease, box-shadow .18s ease, border-color .18s ease, background .18s ease;
        }
        .table-card:hover {
            transform:translateY(-2px);
            box-shadow:0 16px 40px rgba(15,23,42,.16);
            border-color:var(--accent-border);
        }
        .table-card.active {
            border-color:var(--brand-border);
            box-shadow:0 20px 52px rgba(99,102,241,.35);
            background:radial-gradient(circle at 0% 0%,#ffffff 0%,#eef2ff 70%);
        }
        .table-card.just-booked {
            border-color:#22c55e;
            box-shadow:0 20px 52px rgba(34,197,94,.55);
            background:linear-gradient(135deg,#ecfdf3,#f0fdf4);
        }

        .table-mainline {
            display:flex;
            justify-content:space-between;
            align-items:flex-start;
            margin-bottom:.25rem;
        }
        .table-name {
            font-size:.9rem;
            font-weight:600;
            color:var(--ink-900);
        }
        .capacity-chip {
            font-size:.7rem;
            padding:.15rem .45rem;
            border-radius:999px;
            background:rgba(15,23,42,.03);
            border:1px solid rgba(148,163,184,.7);
            color:var(--ink-700);
        }
        .table-subline {
            display:flex;
            justify-content:space-between;
            font-size:.75rem;
            color:var(--ink-500);
        }
        .table-badge {
            font-size:.65rem;
            padding:.15rem .4rem;
            border-radius:999px;
            background:var(--accent-soft);
            color:#92400e;
            border:1px solid var(--accent-border);
        }

        .booking-panel {
            flex:1;
            min-width:0;
            display:flex;
            flex-direction:column;
            gap:1rem;
        }

        .section-title {
            font-weight:600;
            font-size:.95rem;
            text-transform:uppercase;
            letter-spacing:.06em;
            color:var(--ink-700);
            margin-bottom:.35rem;
        }

        .detail-card {
            position:relative;
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border-radius:var(--radius-lg);
            border:1px solid rgba(99,102,241,.25);
            box-shadow:0 18px 46px rgba(15,23,42,.14);
            padding:1rem 1.25rem 1.25rem;
            opacity:0;
            transform:translateY(10px) scale(.98);
            pointer-events:none;
            transition:opacity .24s ease, transform .24s ease;
        }
        .detail-card::before {
            content:"";
            position:absolute;
            top:0;
            left:0;
            width:100%;
            height:4px;
            border-radius:16px 16px 0 0;
            background:linear-gradient(90deg,var(--accent),var(--brand));
            opacity:.9;
        }

        .detail-head {
            display:flex;
            justify-content:space-between;
            flex-wrap:wrap;
            gap:.75rem;
            margin-bottom:.9rem;
        }
        .detail-head-left {
            display:flex;
            gap:.6rem;
            align-items:flex-start;
        }
        .detail-icon {
            width:32px;
            height:32px;
            border-radius:999px;
            background:rgba(254,161,22,.1);
            display:flex;
            align-items:center;
            justify-content:center;
            color:var(--accent);
        }
        .detail-title-texts {
            display:flex;
            flex-direction:column;
            gap:.15rem;
        }
        .detail-title {
            font-size:1rem;
            font-weight:600;
            background:linear-gradient(to right,var(--accent),var(--brand));
            -webkit-background-clip:text;
            -webkit-text-fill-color:transparent;
        }
        .detail-sub {
            font-size:.8rem;
            color:var(--ink-500);
        }
        .detail-pill {
            font-size:.75rem;
            padding:.25rem .6rem;
            border-radius:999px;
            background:rgba(15,23,42,.03);
            border:1px solid rgba(148,163,184,.6);
            display:flex;
            align-items:center;
            gap:.3rem;
        }

        .detail-grid {
            display:grid;
            grid-template-columns:1.6fr 1.4fr;
            gap:1rem;
        }
        @media (max-width:992px) {
            .detail-grid {
                grid-template-columns:1fr;
            }
        }

        .detail-label {
            font-size:.8rem;
            font-weight:600;
            color:var(--ink-700);
        }

        .form-control,
        .form-select {
            border-radius:10px;
            border:1.5px solid #e2e8f0;
            transition:all .2s ease;
            background:#ffffff;
            font-size:.85rem;
        }
        .form-control:focus,
        .form-select:focus {
            border-color:var(--accent);
            box-shadow:0 0 0 .25rem rgba(254,161,22,.22);
            background:#fffefc;
        }

        .form-text.small {
            font-size:.7rem;
            color:var(--ink-500);
        }

        .btn-walkin-primary {
            background:linear-gradient(135deg,#fea116,#ea580c);
            color:#ffffff;
            border:none;
            font-weight:700;
            letter-spacing:.03em;
            text-transform:uppercase;
            box-shadow:0 6px 24px rgba(234,88,12,.5);
            border-radius:var(--radius-sm);
            font-size:.8rem;
            padding:.5rem 1.2rem;
        }
        .btn-walkin-primary:hover {
            transform:translateY(-1px);
            box-shadow:0 9px 30px rgba(234,88,12,.7);
        }

        .btn-walkin-secondary {
            border-radius:var(--radius-sm);
            font-size:.8rem;
            padding:.5rem 1.2rem;
            border-color:#cbd5e1;
            color:#0f172a;
        }
        .btn-walkin-secondary:hover {
            background:#f8fafc;
        }

        .alert {
            border-radius:var(--radius-md);
            font-size:.85rem;
            box-shadow:0 12px 32px rgba(15,23,42,.16);
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
                        <span>Nhận đặt bàn tại quầy</span>
                    </div>
                    <div class="sub">
                        Màn hình dành cho lễ tân: chọn bàn trống, nhập nhanh thông tin khách và giữ bàn tại quầy.
                    </div>
                </div>
                <div class="pos-right">
                    <div class="user-chip">
                        <i class="bi bi-person-badge"></i>
                        <span>${sessionScope.user.fullName}</span>
                        <span class="role-badge">${sessionScope.user.roleName}</span>
                    </div>
                    <button class="btn-toggle-sidebar" type="button" onclick="toggleSidebar()">
                        <i class="bi bi-list"></i>
                        <span>Menu</span>
                    </button>
                </div>
            </header>

            <!-- messages từ session -->
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

            <!-- messages từ request (forwardBack) -->
            <c:if test="${not empty requestScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle me-2"></i>${requestScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <div class="walkin-layout" id="walkinLayout">
                <!-- CỘT TRÁI: DANH SÁCH BÀN -->
                <section class="table-picker">
                    <div class="picker-head">
                        <div class="picker-title">
                            <i class="bi bi-grid-3x3-gap"></i>
                            <span>Danh sách bàn trống</span>
                        </div>
                        <div class="picker-desc">
                            Chọn một bàn để bắt đầu nhập thông tin khách.
                        </div>
                    </div>

                    <div class="table-list">
                        <c:choose>
                            <c:when test="${empty vacantTables}">
                                <div class="text-center text-muted py-4">
                                    Hiện không có bàn trống.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="t" items="${vacantTables}">
                                    <c:set var="isJustBooked"
                                           value="${not empty justBookedTableNumber && justBookedTableNumber == t.tableNumber}"/>

                                    <div class="table-card ${isJustBooked ? 'just-booked' : ''}"
                                         data-table-number="${t.tableNumber}"
                                         data-capacity="${t.capacity}"
                                         data-area="${empty t.areaName ? '-' : t.areaName}">
                                        <div class="table-mainline">
                                            <div class="table-name">Bàn ${t.tableNumber}</div>
                                            <div class="capacity-chip">Sức chứa: ${t.capacity}</div>
                                        </div>
                                        <div class="table-subline">
                                            <span>Khu vực</span>
                                            <span>${empty t.areaName ? '-' : t.areaName}</span>
                                        </div>
                                        <div class="mt-2 d-flex justify-content-between align-items-center">
                                            <span class="table-badge">
                                                <c:choose>
                                                    <c:when test="${isJustBooked}">
                                                        Đã nhận đặt (mới)
                                                    </c:when>
                                                    <c:otherwise>
                                                        Bàn trống
                                                    </c:otherwise>
                                                </c:choose>
                                            </span>
                                            <span class="text-muted" style="font-size:.7rem;">Nhấp để chọn</span>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </section>

                <!-- CỘT PHẢI: FORM THÔNG TIN ĐẶT BÀN -->
                <section class="booking-panel">
                    <div class="section-title">Thông tin đặt bàn</div>

                    <div class="detail-card" id="detailCard">
                        <div class="detail-head">
                            <div class="detail-head-left">
                                <div class="detail-icon">
                                    <i class="bi bi-person-plus"></i>
                                </div>
                                <div class="detail-title-texts">
                                    <div class="detail-title" id="detailTitle">
                                        Chưa chọn bàn
                                    </div>
                                    <div class="detail-sub" id="detailSubtitle">
                                        Chọn một bàn bên trái, thông tin bàn sẽ hiển thị tại đây để lễ tân nhập dữ liệu khách.
                                    </div>
                                </div>
                            </div>
                            <div class="detail-pill" id="detailMeta">
                                <i class="bi bi-info-circle"></i>
                                <span>Bàn: – • Khu vực: – • Sức chứa: –</span>
                            </div>
                        </div>

                        <form id="walkinForm" method="post" action="<c:url value='/reception/walkin-booking'/>">
                            <input type="hidden" name="tableNumber" id="tableNumberHidden"/>

                            <div class="detail-grid">
                                <div>
                                    <div class="mb-3">
                                        <div class="detail-label mb-1">Thông tin khách</div>
                                        <input name="customerName"
                                               id="customerName"
                                               class="form-control"
                                               placeholder="Tên khách"
                                               required/>
                                    </div>

                                    <div class="mb-3">
                                        <input name="phone"
                                               id="phone"
                                               class="form-control"
                                               placeholder="Số điện thoại"
                                               required
                                               maxlength="10"
                                               minlength="10"
                                               pattern="[0-9]{10}"
                                               inputmode="numeric"
                                               title="Nhập 10 chữ số"/>
                                    </div>

                                    <div class="mb-3 d-flex gap-2">
    <input name="email"
           id="email"
           type="email"
           class="form-control"
           placeholder="Email (bắt buộc)"
           required/>

    <select name="partySize"
            id="partySize"
            class="form-select"
            style="width:110px;"
            required>
        <!-- sẽ được JS fill lại, tạm để placeholder -->
        <option value="">Số khách</option>
    </select>
</div>
<div class="form-text small">
    Số lượng người cần đặt cho bàn (tối đa bằng sức chứa).
</div>

                                    <div class="mb-3">
                                        <input name="specialRequests"
                                               id="specialRequests"
                                               class="form-control"
                                               placeholder="Ghi chú (tùy chọn)"/>
                                    </div>
                                </div>

                                <div>
                                    <div class="mb-2">
                                        <div class="detail-label mb-1">Ngày đặt / Giờ đặt</div>
                                        <div class="input-group">
                                            <input type="date"
                                                   name="reservation_date"
                                                   id="reservationDate"
                                                   class="form-control"
                                                   required
                                                   style="flex:1 1 auto; min-width:160px;"/>
                                            <select name="reservation_time"
                                                    id="reservationTime"
                                                    class="form-select"
                                                    required
                                                    style="width:140px;">
                                                <option value="">Chọn giờ</option>
                                                <c:forEach begin="10" end="21" var="h">
                                                    <option value="${h}:00:00">${h}:00</option>
                                                    <option value="${h}:30:00">${h}:30</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="form-text small mt-1">
                                            Nếu đặt cho hôm nay, giờ nhận khách phải cách hiện tại ít nhất 2 tiếng.
                                        </div>
                                    </div>

                                    <div class="mt-4 d-flex gap-2 justify-content-end">
                                        <button class="btn btn-walkin-secondary"
                                                type="button"
                                                id="resetFormButton">
                                            XÓA FORM
                                        </button>
                                        <button class="btn btn-walkin-primary" type="submit">
                                            NHẬN ĐẶT BÀN
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </section>
            </div>
        </main>
    </div>

    <jsp:include page="/layouts/Footer.jsp"/>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="<c:url value='/js/main.js'/>"></script>
    <script>
        function toggleSidebar() {
            var el = document.getElementById("sidebar");
            if (el) el.classList.toggle("open");
        }

        setTimeout(function () {
            var alerts = document.querySelectorAll(".alert");
            alerts.forEach(function (al) {
                if (window.bootstrap && bootstrap.Alert) {
                    var bsAlert = new bootstrap.Alert(al);
                    bsAlert.close();
                } else {
                    al.remove();
                }
            });
        }, 5000);

        (function () {
            var layout = document.getElementById("walkinLayout");
            var cards = document.querySelectorAll(".table-card");
            var hiddenTable = document.getElementById("tableNumberHidden");
            var titleEl = document.getElementById("detailTitle");
            var subEl = document.getElementById("detailSubtitle");
            var metaEl = document.getElementById("detailMeta");
            var partySelect = document.getElementById("partySize");
            var justBookedTableNumber = '${empty justBookedTableNumber ? "" : justBookedTableNumber}';

            function updatePartyOptions(capacity) {
    partySelect.innerHTML = "";

    // option placeholder
    var placeholder = document.createElement("option");
    placeholder.value = "";
    placeholder.textContent = "Số khách";
    placeholder.disabled = true;
    placeholder.selected = true;
    partySelect.appendChild(placeholder);

    var cap = capacity && capacity > 0 ? capacity : 1;
    for (var i = 1; i <= cap; i++) {
        var opt = document.createElement("option");
        opt.value = String(i);
        opt.textContent = i + " khách";
        partySelect.appendChild(opt);
    }
}

            function selectCard(card) {
                cards.forEach(function (c) {
                    c.classList.remove("active");
                });
                card.classList.add("active");

                var tableNumber = card.getAttribute("data-table-number") || "";
                var capacity = parseInt(card.getAttribute("data-capacity") || "0", 10);
                var area = card.getAttribute("data-area") || "-";

                hiddenTable.value = tableNumber;

                titleEl.textContent = "Nhận khách cho bàn " + tableNumber;
                subEl.textContent = "Lễ tân nhập thông tin khách, số khách và thời gian đến cho bàn này.";
                metaEl.innerHTML =
                    '<i class="bi bi-info-circle"></i>' +
                    '<span>Bàn: ' + tableNumber +
                    " • Khu vực: " + area +
                    " • Sức chứa: " + capacity + "</span>";

                updatePartyOptions(capacity);

                if (layout) {
                    layout.classList.add("has-selection");
                }
            }

            if (cards.length > 0) {
                var initial = null;
                if (justBookedTableNumber && justBookedTableNumber.length > 0) {
                    cards.forEach(function (c) {
                        if (c.getAttribute("data-table-number") === justBookedTableNumber) {
                            initial = c;
                        }
                    });
                }
                if (!initial) initial = cards[0];
                selectCard(initial);
                initial.scrollIntoView({behavior: "smooth", block: "center"});
            }

            cards.forEach(function (card) {
                card.addEventListener("click", function () {
                    selectCard(card);
                });
            });

            var phoneEl = document.getElementById("phone");
            if (phoneEl) {
                phoneEl.addEventListener("input", function () {
                    var cleaned = phoneEl.value.replace(/\D/g, "");
                    if (phoneEl.value !== cleaned) phoneEl.value = cleaned;
                    if (cleaned.length === 10) phoneEl.setCustomValidity("");
                    else phoneEl.setCustomValidity("Số điện thoại phải có 10 chữ số.");
                });
                phoneEl.addEventListener("paste", function (e) {
                    e.preventDefault();
                    var paste = (e.clipboardData || window.clipboardData).getData("text");
                    var cleaned = paste.replace(/\D/g, "").slice(0, 10);
                    phoneEl.value = cleaned;
                    phoneEl.dispatchEvent(new Event("input"));
                });
            }

            var form = document.getElementById("walkinForm");
            var nameEl = document.getElementById("customerName");
            var emailEl = document.getElementById("email");
            var dateEl = document.getElementById("reservationDate");
            var timeEl = document.getElementById("reservationTime");
            var resetBtn = document.getElementById("resetFormButton");

            if (dateEl) {
                var todayStr = new Date().toISOString().split("T")[0];
                dateEl.min = todayStr;
                dateEl.addEventListener("focus", function () {
                    dateEl.min = new Date().toISOString().split("T")[0];
                });
            }

            function validateDateTime(e) {
                if (!dateEl || !timeEl) return true;

                var dateVal = dateEl.value;
                var timeVal = timeEl.value;
                if (!dateVal || !timeVal) {
                    if (e) e.preventDefault();
                    if (!dateVal) dateEl.reportValidity();
                    if (!timeVal) timeEl.reportValidity();
                    return false;
                }

                var selectedDate = new Date(dateVal + "T00:00:00");
                var today = new Date();
                var todayDateOnly = new Date(today.getFullYear(), today.getMonth(), today.getDate());

                if (selectedDate < todayDateOnly) {
                    if (e) e.preventDefault();
                    dateEl.setCustomValidity("Ngày không được nhỏ hơn hôm nay.");
                    dateEl.reportValidity();
                    return false;
                }

                var parts = timeVal.split(":");
                var hour = parseInt(parts[0], 10);
                var minute = parseInt(parts[1], 10);
                var selectedDateTime = new Date(
                    selectedDate.getFullYear(),
                    selectedDate.getMonth(),
                    selectedDate.getDate(),
                    hour,
                    minute,
                    0
                );
                var minAllowed = new Date();
                minAllowed.setHours(minAllowed.getHours() + 2);

                if (selectedDate.toDateString() === todayDateOnly.toDateString()) {
                    if (selectedDateTime < minAllowed) {
                        if (e) e.preventDefault();
                        timeEl.setCustomValidity("Vui lòng đặt trước ít nhất 2 tiếng cho hôm nay.");
                        timeEl.reportValidity();
                        return false;
                    }
                }

                dateEl.setCustomValidity("");
                timeEl.setCustomValidity("");
                return true;
            }

            if (form) {
                form.addEventListener("submit", function (e) {
                    if (!hiddenTable.value) {
                        e.preventDefault();
                        alert("Vui lòng chọn một bàn ở danh sách bên trái trước khi nhận đặt.");
                        return;
                    }

                    if (nameEl) {
                        var n = nameEl.value.trim();
                        if (n.length < 2) {
                            e.preventDefault();
                            nameEl.setCustomValidity("Tên khách phải có ít nhất 2 ký tự.");
                            nameEl.reportValidity();
                            return;
                        } else {
                            nameEl.setCustomValidity("");
                        }
                    }

                    if (phoneEl) {
                        if (phoneEl.value.replace(/\D/g, "").length !== 10) {
                            e.preventDefault();
                            phoneEl.setCustomValidity("Số điện thoại phải có 10 chữ số.");
                            phoneEl.reportValidity();
                            return;
                        } else {
                            phoneEl.setCustomValidity("");
                        }
                    }

                    if (emailEl && !emailEl.checkValidity()) {
                        e.preventDefault();
                        emailEl.reportValidity();
                        return;
                    }

                    if (!validateDateTime(e)) {
                        return;
                    }
                });
            }

            if (resetBtn && form) {
                resetBtn.addEventListener("click", function () {
                    form.reset();
                    if (phoneEl) phoneEl.setCustomValidity("");
                    if (nameEl) nameEl.setCustomValidity("");
                    if (emailEl) emailEl.setCustomValidity("");
                    if (dateEl) {
                        var todayStr2 = new Date().toISOString().split("T")[0];
                        dateEl.min = todayStr2;
                    }
                });
            }
        })();
    </script>
</body>
</html>
