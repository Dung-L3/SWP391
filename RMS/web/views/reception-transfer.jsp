<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    request.setAttribute("page", "reception-transfer");
    request.setAttribute("overlayNav", false);
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<%!
    public String statusLabel(String s) {
        if (s == null) return "-";
        switch (s.toUpperCase()) {
            case "VACANT": return "Trống";
            case "HELD": return "Đã đặt";
            case "SEATED": return "Có khách";
            case "IN_USE": return "Đang dùng";
            case "REQUEST_BILL": return "Chờ thanh toán";
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
    <title>Chuyển bàn | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>

    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <style>
        :root {
            --bg-app:#f5f6fa;
            --bg-grad-1:rgba(88,80,200,0.08);
            --bg-grad-2:rgba(254,161,22,0.06);
            --accent:#FEA116;
            --brand:#4f46e5;
            --brand-border:#6366f1;
            --success:#16a34a;
            --line:#e5e7eb;
            --radius-lg:20px;
            --radius-md:12px;
            --radius-sm:6px;
            --shadow-card:0 28px 64px rgba(15,23,42,.12);
            --sidebar-width:280px;
        }

        body {
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            font-family:"Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
            color:#0f172a;
        }

        .app-shell {
            display:grid;
            grid-template-columns:var(--sidebar-width) 1fr;
            min-height:100vh;
        }

        @media (max-width: 992px) {
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
            #sidebar.open { transform:translateX(0); }
        }

        main.main-pane { padding:28px 32px 44px; }

        .pos-topbar {
            background:linear-gradient(135deg,#1b1e2c,#2b2f46 60%,#1c1f30);
            border-radius:var(--radius-md);
            border:1px solid rgba(255,255,255,.1);
            padding:16px 20px;
            margin-top:58px;
            margin-bottom:24px;
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            color:#fff;
            box-shadow:0 32px 64px rgba(0,0,0,.6);
        }

        .title-row {
            display:flex;
            align-items:center;
            gap:.6rem;
            font-weight:600;
            font-size:1rem;
        }
        .title-row i { color:var(--accent); font-size:1.1rem; }
        .pos-left .sub {
            margin-top:4px;
            font-size:.8rem;
            color:#94a3b8;
        }
        .pos-right {
            display:flex;
            align-items:center;
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
            font-weight:500;
        }
        .user-chip .role-badge {
            background:var(--accent);
            color:#1e1e2f;
            border-radius:var(--radius-sm);
            padding:2px 6px;
            font-size:.7rem;
            font-weight:600;
        }

        .pricing-layout { display:flex; gap:1.5rem; }

        .menu-picker {
            flex:0 0 280px;
            background:linear-gradient(to bottom right,#fafaff,#fff);
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:var(--shadow-card);
            padding:1rem 1rem 1.25rem;
        }

        .picker-title {
            font-weight:600;
            font-size:1rem;
            color:#0f172a;
            display:flex;
            gap:.5rem;
            align-items:center;
        }
        .picker-title i { color:var(--accent); }
        .picker-desc { font-size:.8rem; color:#64748b; margin:.3rem 0 1rem; }

        .menu-grid { display:flex; flex-direction:column; gap:.7rem; }

        .food-card {
            background:#fff;
            border-radius:var(--radius-md);
            border:2px solid transparent;
            box-shadow:0 20px 48px rgba(15,23,42,.08);
            padding:.8rem .9rem;
            cursor:pointer;
            transition:all .18s ease;
        }
        .food-card:hover {
            transform:translateY(-2px);
            box-shadow:0 28px 60px rgba(0,0,0,.12);
        }
        .food-card.active {
            border-color:var(--brand-border);
            background:radial-gradient(circle at 0% 0%,#fff 0%,#f5f5ff 60%);
            box-shadow:0 32px 72px rgba(99,102,241,.28);
        }
        .food-card.disabled {
            opacity:.45;
            cursor:not-allowed;
            box-shadow:none;
        }
        .food-card.disabled:hover {
            transform:none;
            box-shadow:none;
        }

        .food-name { font-size:.95rem; font-weight:600; }
        .food-id { font-size:.75rem; color:#64748b; }
        .chip-status {
            font-size:.7rem;
            font-weight:600;
            border-radius:var(--radius-sm);
            padding:.25rem .55rem;
            border:1px solid transparent;
            white-space:nowrap;
        }
        .vacant  { background:#dcfce7; color:#166534; border-color:#bbf7d0; }
        .seated  { background:#fee2e2; color:#b91c1c; border-color:#fecaca; }
        .held    { background:#fef9c3; color:#92400e; border-color:#fde047; }
        .other   { background:#e5e7eb; color:#374151; border-color:#d1d5db; }

        .pricing-detail { flex:1; display:flex; flex-direction:column; gap:1.5rem; }

        .detail-card {
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border:1px solid rgba(99,102,241,.25);
            border-top:4px solid var(--accent);
            border-radius:var(--radius-lg);
            box-shadow:0 10px 40px rgba(0,0,0,.08);
            padding:1rem 1.25rem 1.25rem;
        }
        .detail-title-line {
            font-weight:600;
            font-size:1rem;
            background:linear-gradient(to right,var(--accent),var(--brand));
            -webkit-background-clip:text;
            -webkit-text-fill-color:transparent;
        }

        .form-label { font-size:.8rem; font-weight:600; color:#334155; }
        .form-control,.form-select {
            border-radius:10px;
            border:1.5px solid #e2e8f0;
            font-size:.9rem;
        }
        .form-control:focus,.form-select:focus {
            border-color:var(--accent);
            box-shadow:0 0 0 0.25rem rgba(254,161,22,.25);
        }

        .btn-transfer {
            background:linear-gradient(135deg,#f59e0b,#d97706);
            border:none;
            font-weight:600;
            color:#fff;
            text-transform:uppercase;
            border-radius:var(--radius-sm);
            box-shadow:0 4px 18px rgba(245,158,11,.4);
        }
        .btn-transfer:hover {
            transform:translateY(-1px);
            box-shadow:0 6px 25px rgba(245,158,11,.5);
        }

        .muted-line { font-size:.78rem; color:#64748b; margin-top:.75rem; }
        .small-helper { font-size:.78rem; color:#6b7280; margin-top:.25rem; }
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
                    <i class="bi bi-arrow-left-right"></i>
                    <span>Chuyển bàn</span>
                </div>
                <div class="sub">Di chuyển phiên/bill từ bàn nguồn sang bàn đích phù hợp sức chứa.</div>
            </div>
            <div class="pos-right">
                <div class="user-chip">
                    <i class="bi bi-person-badge"></i>
                    <span>${sessionScope.user.fullName}</span>
                    <span class="role-badge">${sessionScope.user.roleName}</span>
                </div>
            </div>
        </header>

        <div class="pricing-layout">
            <!-- CỘT TRÁI: DANH SÁCH BÀN (CHỌN BÀN NGUỒN) -->
            <aside class="menu-picker">
                <div class="picker-title">
                    <i class="bi bi-table"></i>
                    <span>Bàn hiện có</span>
                </div>
                <div class="picker-desc">Chọn 1 bàn đang có khách / đang dùng để chuyển sang bàn khác.</div>

                <div class="menu-grid">
                    <%
                        Dal.TableDAO dao = new Dal.TableDAO();
                        java.util.List<Models.DiningTable> all = dao.getAllTables();
                        for (Models.DiningTable t : all) {
                            String statusRaw = t.getStatus() == null ? "" : t.getStatus().toUpperCase();
                            String chip = "other";
                            if ("VACANT".equals(statusRaw)) chip = "vacant";
                            else if ("SEATED".equals(statusRaw) || "IN_USE".equals(statusRaw)) chip = "seated";
                            else if ("HELD".equals(statusRaw)) chip = "held";

                            // Chỉ cho chọn nguồn nếu không phải VACANT & không OUT_OF_SERVICE
                            boolean canBeSource = !"VACANT".equals(statusRaw) && !"OUT_OF_SERVICE".equals(statusRaw);
                            String extraClass = canBeSource ? "" : " disabled";
                    %>
                    <div class="food-card table-card<%=extraClass%>"
                         data-table-number="<%=t.getTableNumber()%>"
                         data-status="<%=statusLabel(t.getStatus())%>"
                         data-capacity="<%=t.getCapacity()%>"
                         data-can-source="<%=canBeSource%>">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="food-name">Bàn <%=t.getTableNumber()%></div>
                                <div class="food-id"><%=t.getCapacity()%> chỗ</div>
                            </div>
                            <div class="chip-status <%=chip%>"><%=statusLabel(t.getStatus())%></div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <div class="small-helper">
                    Bàn đang <strong>Trống</strong> hoặc <strong>Không phục vụ</strong> được làm bàn đích, không dùng làm bàn nguồn.
                </div>
            </aside>

            <!-- CỘT PHẢI: FORM CHUYỂN BÀN -->
            <section class="pricing-detail">
                <div class="detail-card">
                    <div class="detail-title-line mb-3">Thực hiện chuyển bàn</div>

                    <form id="transferForm" method="post" action="<c:url value='/reception/transfer-table'/>" class="row g-3">
                        <input type="hidden" name="sourceTable" id="sourceTableInput"/>
                        <input type="hidden" name="sourceCapacity" id="sourceCapacityInput"/>

                        <div class="col-md-4">
                            <label class="form-label">Bàn nguồn (đang chọn)</label>
                            <input type="text" id="sourceTableDisplay" class="form-control" readonly placeholder="Chưa chọn bàn"/>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Trạng thái hiện tại</label>
                            <input type="text" id="sourceStatusDisplay" class="form-control" readonly/>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Sức chứa bàn nguồn</label>
                            <input type="text" id="sourceCapDisplay" class="form-control" readonly/>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Bàn đích (trống)</label>
                            <select name="targetTable" class="form-select" id="targetTableSelect" required>
                                <option value="">-- Chọn bàn đích --</option>
                                <%
                                    java.util.List<Models.DiningTable> vacant = dao.getVacantTables();
                                    for (Models.DiningTable v : vacant) {
                                %>
                                <option value="<%=v.getTableNumber()%>" data-capacity="<%=v.getCapacity()%>">
                                    Bàn <%=v.getTableNumber()%> — <%=v.getCapacity()%> chỗ
                                </option>
                                <% } %>
                            </select>
                            <div class="small-helper">
                                Quy tắc:
                                <br/>- Bàn 2 chỗ → được chuyển sang 2•4•8 chỗ
                                <br/>- Bàn 4 chỗ → được chuyển sang 4•8 chỗ
                                <br/>- Bàn 8 chỗ → chỉ chuyển sang bàn 8 chỗ
                            </div>
                        </div>

                        <div class="col-md-3 d-flex align-items-end">
                            <button class="btn btn-transfer w-100" type="submit">
                                <i class="bi bi-arrow-right-circle me-1"></i>Chuyển bàn
                            </button>
                        </div>

                        <div class="col-12">
                            <div class="muted-line">
                                Thao tác sẽ tự động chuyển phiên/bill (nếu có), cập nhật bàn nguồn → <strong>Trống</strong> và bàn đích → <strong>Có khách/Đang dùng</strong>.
                            </div>
                        </div>
                    </form>
                </div>

                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success mt-3">${sessionScope.successMessage}</div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-danger mt-3">${sessionScope.errorMessage}</div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>
            </section>
        </div>
    </main>
</div>

<jsp:include page="/layouts/Footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const cards            = document.querySelectorAll('.table-card');
    const sourceInput      = document.getElementById('sourceTableInput');
    const sourceCapInput   = document.getElementById('sourceCapacityInput');
    const srcDisplay       = document.getElementById('sourceTableDisplay');
    const srcStatus        = document.getElementById('sourceStatusDisplay');
    const srcCap           = document.getElementById('sourceCapDisplay');
    const targetSelect     = document.getElementById('targetTableSelect');
    const transferForm     = document.getElementById('transferForm');

    function isTargetAllowed(sourceCap, targetCap) {
        if (!sourceCap || !targetCap) return true; // fallback an toàn
        if (sourceCap === 2) {
            return [2,4,8].includes(targetCap);
        }
        if (sourceCap === 4) {
            return [4,8].includes(targetCap);
        }
        if (sourceCap >= 8) {
            return targetCap >= 8;
        }
        // các loại khác: không được chuyển xuống bàn nhỏ hơn
        return targetCap >= sourceCap;
    }

    function filterTargetsBySourceCap(sourceCap) {
        if (!targetSelect) return;
        const options = targetSelect.querySelectorAll('option');
        let hasVisible = false;

        options.forEach(opt => {
            if (!opt.value) { // placeholder
                opt.hidden = false;
                return;
            }
            const capAttr = opt.getAttribute('data-capacity');
            const targetCap = capAttr ? parseInt(capAttr,10) : 0;

            const allowed = isTargetAllowed(sourceCap, targetCap);
            opt.hidden = !allowed;
            if (allowed) hasVisible = true;
        });

        // Nếu option đang chọn không hợp lệ → clear
        if (targetSelect.value) {
            const currOpt = targetSelect.selectedOptions[0];
            if (currOpt && currOpt.hidden) {
                targetSelect.value = '';
            }
        }

        // Nếu không còn option phù hợp thì cũng clear value
        if (!hasVisible) {
            targetSelect.value = '';
        }
    }

    function selectCard(card) {
        const canSource = card.getAttribute('data-can-source') === 'true';
        if (!canSource) return; // không cho chọn bàn trống / OOS làm nguồn

        cards.forEach(c => c.classList.remove('active'));
        card.classList.add('active');

        const num  = card.getAttribute('data-table-number');
        const st   = card.getAttribute('data-status');
        const cap  = parseInt(card.getAttribute('data-capacity') || '0', 10);

        if (sourceInput)    sourceInput.value = num;
        if (sourceCapInput) sourceCapInput.value = cap;
        if (srcDisplay)     srcDisplay.value = num;
        if (srcStatus)      srcStatus.value = st || '';
        if (srcCap)         srcCap.value = cap ? (cap + ' chỗ') : '';

        filterTargetsBySourceCap(cap);
    }

    cards.forEach(card => {
        card.addEventListener('click', () => selectCard(card));
    });

    if (transferForm) {
        transferForm.addEventListener('submit', function (e) {
            // bắt buộc phải chọn bàn nguồn
            if (!sourceInput.value) {
                e.preventDefault();
                alert('Vui lòng chọn bàn nguồn trước khi chuyển.');
                return;
            }
            // kiểm tra lại bàn đích
            if (!targetSelect.value) {
                e.preventDefault();
                targetSelect.reportValidity();
            }
        });
    }
</script>
</body>
</html>
