<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    // giả sử sessionScope.user đã set sẵn user (firstName,lastName)
    // và request có: areas (list khu), tables (list bàn), selectedAreaId
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bản đồ bàn | RMS</title>

    <!-- Bootstrap + Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">

    <style>
        :root {
            --radius-lg:20px;
            --radius-md:12px;
            --radius-sm:6px;

            --panel-dark-start:#2b3048;
            --panel-dark-end:#1e2133;
            --panel-border:rgba(255,255,255,.08);

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.12);
            --accent-border:rgba(254,161,22,.45);

            --success:#16a34a;
            --success-bg:#d1fae5;
            --danger:#dc2626;
            --warn:#facc15;

            --brand:#4f46e5;
            --brand-bg-soft:#eef2ff;

            --line:#e5e7eb;
            --card-shadow:0 28px 64px rgba(15,23,42,.12);

            --table-bg:#ffffff;
            --table-border:#e2e8f0;

            --bg-page-top-left:rgba(88,80,200,.06);
            --bg-page-top-right:rgba(254,161,22,.05);

            --floor1-stroke:#4ade80;
            --floor2-stroke:#60a5fa;
            --outdoor-stroke:#facc15;
        }

        /*******************
         * GLOBAL PAGE BG
         *******************/
        body {
            background:
                radial-gradient(800px 500px at 10% 0%, var(--bg-page-top-left) 0%, transparent 60%),
                radial-gradient(800px 500px at 90% 0%, var(--bg-page-top-right) 0%, transparent 60%),
                linear-gradient(#eef0f6 0%, #f5f6fa 60%, #eef0f6 100%);
            font-family: "Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
            color: var(--ink-900);
        }

        /*******************
         * PAGE LAYOUT
         *******************/
        .page-shell {
    width: 100%;
    max-width: 1600px; /* vẫn giới hạn nhẹ để không quá rộng */
    margin: 24px auto 96px;
    padding: 0 40px 64px;
    display: grid;
    grid-template-columns: 340px 1fr;
    grid-gap: 28px;
}
@media (max-width: 1200px) {
    .page-shell {
        grid-template-columns: 1fr;
        padding: 0 20px 64px;
    }
}

        .right-pane {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        /*******************
         * LEFT PANEL: FLOORPLAN
         *******************/
        .floorplan-panel {
            position: relative;
            background: radial-gradient(circle at 0% 0%, var(--panel-dark-start) 0%, var(--panel-dark-end) 70%);
            border-radius: var(--radius-lg);
            border:1px solid var(--panel-border);
            box-shadow:0 32px 64px rgba(0,0,0,.6);
            padding:16px 20px 20px;
            color:#fff;
            display:flex;
            flex-direction:column;
            gap:16px;
        }

        .floorplan-head {
            display:flex;
            flex-direction:column;
            gap:.4rem;
        }
        .floorplan-title {
            font-size: .9rem;
            font-weight:600;
            line-height:1.3;
            color:#fff;
            display:flex;
            align-items:center;
            gap:.5rem;
        }
        .floorplan-title i {
            color: var(--accent);
        }
        .floorplan-sub {
            font-size:.75rem;
            color: var(--ink-400);
            line-height:1.4;
        }

        .floorplan-wrapper {
            background: rgba(0,0,0,.25);
            border:1px solid rgba(255,255,255,.1);
            border-radius: var(--radius-md);
            padding:12px;
            box-shadow:0 24px 48px rgba(0,0,0,.7) inset;
        }

        .floor-svg {
            width:100%;
            height:auto;
            display:block;
            font-family: inherit;
        }

        .fp-block {
            stroke-width:1.5;
            stroke-linejoin:round;
            stroke-linecap:round;
        }

        .fp-floor2 {
            fill:#232844;
            stroke:var(--floor2-stroke);
        }
        .fp-floor2-label {
            fill:var(--floor2-stroke);
            font-size:10px;
            font-weight:600;
        }

        .fp-floor1 {
            fill:#1e2337;
            stroke:var(--floor1-stroke);
        }
        .fp-floor1-label {
            fill:var(--floor1-stroke);
            font-size:10px;
            font-weight:600;
        }

        .fp-outdoor {
            fill:#1f2937;
            stroke:var(--outdoor-stroke);
            stroke-dasharray:4 3;
        }
        .fp-outdoor-label {
            fill:var(--outdoor-stroke);
            font-size:10px;
            font-weight:600;
        }

        .fp-arrow {
            stroke:#fff;
            stroke-width:1;
            marker-end:url(#arrowHead);
            opacity:.6;
        }

        .fp-bubble {
            fill:rgba(0,0,0,.6);
            stroke:rgba(255,255,255,.3);
            stroke-width:0.5;
            rx:4;
            ry:4;
        }
        .fp-bubble-text {
            fill:#fff;
            font-size:9px;
            font-weight:500;
        }

        .floorplan-legend {
            display:flex;
            flex-direction:column;
            gap:8px;
            font-size:.75rem;
            line-height:1.3;
        }
        .legend-row {
            display:flex;
            align-items:center;
            gap:.5rem;
            color:#fff;
            font-weight:500;
        }
        .legend-dot {
            width:12px;
            height:12px;
            border-radius:4px;
            flex-shrink:0;
            box-shadow:0 0 8px rgba(255,255,255,.4);
        }
        .dot-floor1 { background:var(--floor1-stroke); }
        .dot-floor2 { background:var(--floor2-stroke); }
        .dot-outdoor { background:var(--outdoor-stroke); }

        /*******************
         * RIGHT TOP BAR CARD
         *******************/
        .topbar-card {
            background: radial-gradient(circle at 0% 0%, var(--panel-dark-start) 0%, var(--panel-dark-end) 70%);
            border-radius: var(--radius-lg);
            border:1px solid var(--panel-border);
            box-shadow:0 32px 64px rgba(0,0,0,.6);
            padding:16px 20px;
            color:#fff;
            display:flex;
            justify-content:space-between;
            flex-wrap:wrap;
            gap:16px;
        }

        .top-left {
            display:flex;
            flex-direction:column;
            gap:.4rem;
        }

        .top-title {
            font-size:.9rem;
            font-weight:600;
            line-height:1.3;
            display:flex;
            align-items:center;
            gap:.5rem;
            color:#fff;
        }
        .top-title i {
            color:var(--accent);
        }

        .top-sub {
            font-size:.75rem;
            color:var(--ink-400);
            line-height:1.4;
        }

        .top-right {
            display:flex;
            align-items:flex-start;
            flex-wrap:wrap;
            gap:.75rem;
        }

        .staff-chip {
            display:flex;
            align-items:center;
            gap:.5rem;
            background: rgba(255,255,255,.06);
            border: 1px solid rgba(255,255,255,.18);
            border-radius: var(--radius-md);
            padding:6px 10px;
            font-size:.75rem;
            line-height:1.2;
            color:#fff;
            font-weight:500;
        }
        .staff-role {
            background: var(--accent);
            color:#1e1e2f;
            border-radius: var(--radius-sm);
            padding:2px 6px;
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
        }

        /*******************
         * FILTER CARD
         *******************/
        .filter-card {
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 70%);
            border:1px solid var(--line);
            border-top:4px solid var(--accent);
            border-radius: var(--radius-lg);
            box-shadow:var(--card-shadow);
            padding:16px 20px 20px;
        }

        .filter-headline {
            display:flex;
            align-items:flex-start;
            gap:.75rem;
            margin-bottom:16px;
        }
        .filter-icon {
            background: var(--accent-soft);
            border:1px solid var(--accent-border);
            border-radius:var(--radius-md);
            color:#6b4000;
            width:32px;
            height:32px;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:.8rem;
            flex-shrink:0;
        }
        .filter-textblock {
            display:flex;
            flex-direction:column;
            gap:.25rem;
        }
        .filter-title {
            font-weight:600;
            color:var(--ink-900);
            font-size:.9rem;
            line-height:1.3;
        }
        .filter-sub {
            font-size:.75rem;
            color:var(--ink-500);
            line-height:1.4;
        }

        .filter-col {
            display:flex;
            flex-direction:column;
            min-width:200px;
        }
        .filter-label {
            font-size:.7rem;
            font-weight:600;
            color:var(--ink-700);
            margin-bottom:4px;
            text-transform:uppercase;
            letter-spacing:.02em;
        }
        .table-filter {
            border-radius:var(--radius-md);
            border:1.5px solid #e2e8f0;
            font-size:.8rem;
            padding:.5rem .75rem;
            transition: all .2s;
        }
        .table-filter:focus {
            border-color:var(--accent);
            box-shadow:0 0 0 0.25rem rgba(254,161,22,.25);
        }

        .btn-refresh {
            border-radius:var(--radius-md);
            font-size:.8rem;
            font-weight:600;
            line-height:1.2;
            background:linear-gradient(135deg,#4f46e5,#4338ca);
            border:1px solid #4f46e5;
            color:#fff;
            padding:.6rem .9rem;
            box-shadow:0 12px 24px rgba(79,70,229,.3);
        }
        .btn-refresh:hover {
            filter:brightness(1.05);
            box-shadow:0 16px 32px rgba(79,70,229,.4);
        }

        /*******************
         * AREA SECTION
         *******************/
        .area-section {
            background:#fff;
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:var(--card-shadow);
            padding:16px 20px 20px;
        }

        .area-header {
            display:flex;
            flex-wrap:wrap;
            align-items:flex-start;
            justify-content:space-between;
            gap:1rem;
            margin-bottom:16px;
        }

        .area-left {
            display:flex;
            align-items:flex-start;
            gap:.75rem;
        }

        .area-icon {
            color:var(--accent);
            background:var(--accent-soft);
            border:1px solid var(--accent-border);
            border-radius:var(--radius-md);
            width:32px;
            height:32px;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:.8rem;
            flex-shrink:0;
        }

        .area-title-wrap {
            display:flex;
            flex-direction:column;
            gap:.25rem;
        }

        .area-name {
            font-size:.9rem;
            font-weight:600;
            color:var(--ink-900);
            line-height:1.3;
        }

        .area-meta {
            font-size:.7rem;
            color:var(--ink-500);
            line-height:1.3;
        }

        /*******************
         * TABLE GRID & CARD
         *******************/
        .table-grid {
            display:flex;
            flex-wrap:wrap;
            gap:16px;
        }

        .table-card {
            background: var(--table-bg);
            min-width:180px;
            max-width:200px;
            flex: 1 1 180px;

            border-radius: var(--radius-md);
            border:2px solid var(--table-border);
            box-shadow:0 20px 48px rgba(15,23,42,.08);
            cursor:pointer;
            padding:12px 16px;
            position:relative;
            transition:all .18s ease;
        }
        .table-card:hover {
            transform: translateY(-2px);
            box-shadow:0 28px 60px rgba(0,0,0,.12);
        }

        .table-card.status-VACANT { border-color:#86efac; background:#ecfdf5; }
        .table-card.status-SEATED,
        .table-card.status-IN_USE { border-color:#fdba74; background:#fff7ed; }
        .table-card.status-CLEANING { border-color:#93c5fd; background:#eff6ff; }
        .table-card.status-OUT_OF_SERVICE { border-color:#cbd5e1; background:#f8fafc; }

        .status-badge {
            position:absolute;
            top:8px;
            right:8px;
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
            padding:2px 6px;
            border-radius:var(--radius-sm);
            background:#fff;
            border:1px solid #cbd5e1;
            color:#334155;
            box-shadow:0 10px 20px rgba(0,0,0,.08);
        }

        /* Notification badges */
        .notification-badge {
            position:absolute;
            width:24px;
            height:24px;
            border-radius:50%;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:.7rem;
            font-weight:700;
            color:#fff;
            box-shadow:0 4px 12px rgba(0,0,0,.25);
            z-index:10;
        }
        .notification-badge.ready {
            top:8px;
            right:8px;
            background:linear-gradient(135deg,#3b82f6,#2563eb);
        }
        .notification-badge.cancelled {
            top:8px;
            left:8px;
            background:linear-gradient(135deg,#dc2626,#991b1b);
        }
        /* Adjust status-badge position when ready badge exists */
        .table-card.has-ready-badge .status-badge {
            right:36px;
        }

        .table-name {
            font-size:.85rem;
            font-weight:600;
            color:var(--ink-900);
            line-height:1.3;
            padding-top:4px;
        }

        .table-capacity {
            font-size:.75rem;
            color:var(--ink-700);
            line-height:1.4;
        }

        .table-footer {
            margin-top:12px;
            font-size:.7rem;
            line-height:1.3;
            color:var(--ink-500);
            display:flex;
            flex-wrap:wrap;
            gap:8px;
        }

        /* Modal content just inherits Bootstrap defaults */

        /* Utility: hide overflow for long names on tiny screens */
        .table-name,
        .table-capacity,
        .table-footer span {
            word-break: break-word;
        }
    </style>
</head>
<body>

    <!-- HEADER (giữ header waiter của bạn) -->
    <jsp:include page="../layouts/WaiterHeader.jsp" />

    <!-- MAIN WRAPPER -->
    <main class="page-shell">

        <!-- LEFT PANEL: SƠ ĐỒ NHÀ HÀNG -->
        <aside class="floorplan-panel">
            <div class="floorplan-head">
                <div class="floorplan-title">
                    <i class="fas fa-building"></i>
                    <span>Sơ đồ nhà hàng</span>
                </div>
                <div class="floorplan-sub">
                    Tầng 1 (khách walk-in), Tầng 2 (VIP/phòng riêng), Khu ngoài trời (chill / hút thuốc).
                </div>
            </div>

            <div class="floorplan-wrapper">
                <svg class="floor-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/200/svg">
                    <defs>
                        <marker id="arrowHead" orient="auto" markerWidth="4" markerHeight="4" refX="2" refY="2">
                            <path d="M0,0 L4,2 L0,4 Z" fill="#fff"></path>
                        </marker>
                    </defs>

                    <!-- Tầng 2 -->
                    <rect class="fp-block fp-floor2" x="60" y="20" width="80" height="40" rx="6" ry="6"/>
                    <text class="fp-floor2-label" x="100" y="43" text-anchor="middle">Tầng 2</text>

                    <!-- bubble VIP -->
                    <rect class="fp-bubble" x="62" y="55" width="60" height="14"/>
                    <text class="fp-bubble-text" x="92" y="65" text-anchor="middle">Phòng riêng / VIP</text>

                    <!-- arrow xuống tầng 1 -->
                    <line class="fp-arrow" x1="100" y1="62" x2="100" y2="78"></line>

                    <!-- Tầng 1 -->
                    <rect class="fp-block fp-floor1" x="40" y="80" width="120" height="50" rx="8" ry="8"/>
                    <text class="fp-floor1-label" x="100" y="108" text-anchor="middle">Tầng 1</text>

                    <!-- bubble lễ tân -->
                    <rect class="fp-bubble" x="45" y="118" width="70" height="14"/>
                    <text class="fp-bubble-text" x="80" y="128" text-anchor="middle">Quầy lễ tân / Bar</text>

                    <!-- arrow ra outdoor -->
                    <line class="fp-arrow" x1="130" y1="125" x2="170" y2="150"></line>

                    <!-- Outdoor -->
                    <rect class="fp-block fp-outdoor" x="140" y="140" width="50" height="40" rx="6" ry="6"/>
                    <text class="fp-outdoor-label" x="165" y="162" text-anchor="middle">Outdoor</text>

                    <!-- bubble outdoor -->
                    <rect class="fp-bubble" x="100" y="150" width="60" height="14"/>
                    <text class="fp-bubble-text" x="130" y="160" text-anchor="middle">Khu ngoài trời</text>
                </svg>
            </div>

            <div class="floorplan-legend">
                <div class="legend-row">
                    <div class="legend-dot dot-floor1"></div>
                    <div>Tầng 1: khách walk-in / gọi món nhanh</div>
                </div>
                <div class="legend-row">
                    <div class="legend-dot dot-floor2"></div>
                    <div>Tầng 2: VIP / nhóm đông / riêng tư</div>
                </div>
                <div class="legend-row">
                    <div class="legend-dot dot-outdoor"></div>
                    <div>Outdoor: hút thuốc / chill view</div>
                </div>
            </div>
        </aside>

        <!-- RIGHT PANE -->
        <section class="right-pane">

            <!-- THẺ TOPBAR (dark) -->
            <section class="topbar-card">
                <div class="top-left">
                    <div class="top-title">
                        <i class="fas fa-border-all"></i>
                        <span>Bản đồ bàn</span>
                    </div>
                    <div class="top-sub">
                        Xem nhanh tình trạng bàn / mở bill / trả bàn / dọn dẹp.
                    </div>
                </div>

                <div class="top-right">
                    <div class="staff-chip">
                        <i class="fas fa-id-badge"></i>
                        <span>
                            <c:choose>
                                <c:when test="${not empty sessionScope.user}">
                                    ${sessionScope.user.firstName} ${sessionScope.user.lastName}
                                </c:when>
                                <c:otherwise>Nhân viên</c:otherwise>
                            </c:choose>
                        </span>
                        <span class="staff-role">Waiter</span>
                    </div>
                </div>
            </section>

            <!-- THẺ BỘ LỌC -->
            <section class="filter-card">
                <div class="filter-headline">
                    <div class="filter-icon">
                        <i class="fas fa-sliders-h"></i>
                    </div>
                    <div class="filter-textblock">
                        <div class="filter-title">Bộ lọc khu vực</div>
                        <div class="filter-sub">
                            Chọn khu vực để xem bàn trong khu đó. Dùng cho phân ca theo zone.
                        </div>
                    </div>
                </div>

                <div class="d-flex flex-wrap align-items-end gap-4">
                    <div class="filter-col">
                        <label class="filter-label">Khu vực</label>
                        <select id="areaFilter" class="form-select table-filter">
                            <option value="">Tất cả khu vực</option>
                            <c:forEach var="area" items="${areas}">
                                <option value="${area.areaId}" ${selectedAreaId == area.areaId ? "selected" : ""}>
                                    ${area.areaName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <button class="btn-refresh d-flex align-items-center" onclick="refreshTables()">
                        <i class="fas fa-sync-alt me-2"></i>
                        <span>Làm mới</span>
                    </button>
                </div>
            </section>

            <!-- DANH SÁCH KHU VỰC / TẦNG -->
            <c:forEach var="area" items="${areas}">
                <c:if test="${selectedAreaId == null || selectedAreaId == area.areaId}">
                    <section class="area-section">

                        <div class="area-header">
                            <div class="area-left">
                                <div class="area-icon">
                                    <i class="fas fa-layer-group"></i>
                                </div>
                                <div class="area-title-wrap">
                                    <div class="area-name">${area.areaName}</div>
                                    <div class="area-meta">
                                        <c:set var="totalTables" value="0"/>
                                        <c:set var="busyTables" value="0"/>

                                        <c:forEach var="t" items="${tables}">
                                            <c:if test="${t.areaId == area.areaId}">
                                                <c:set var="totalTables" value="${totalTables + 1}"/>
                                                <c:if test="${t.status == 'SEATED' || t.status == 'IN_USE'}">
                                                    <c:set var="busyTables" value="${busyTables + 1}"/>
                                                </c:if>
                                            </c:if>
                                        </c:forEach>

                                        ${busyTables}/${totalTables} bàn đang có khách
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="table-grid">
                            <c:forEach var="table" items="${tables}">
                                <c:if test="${table.areaId == area.areaId}">
                                    <%-- Chỉ hiển thị badge cho bàn có khách --%>
                                    <c:set var="hasReadyBadge" value="false"/>
                                    <c:if test="${(table.status == 'SEATED' || table.status == 'IN_USE') && not empty tableItemCounts[table.tableId]}">
                                        <c:set var="counts" value="${tableItemCounts[table.tableId]}"/>
                                        <c:if test="${counts['ready'] > 0}">
                                            <c:set var="hasReadyBadge" value="true"/>
                                        </c:if>
                                    </c:if>
                                    <div class="table-card status-${table.status} ${hasReadyBadge ? 'has-ready-badge' : ''}"
                                         onclick="showTableDetails(${table.tableId})"
                                         data-table-id="${table.tableId}"
                                         data-status="${table.status}">

                                        <div class="status-badge">
                                            <c:choose>
                                                <c:when test="${table.status == 'VACANT'}">Trống</c:when>
                                                <c:when test="${table.status == 'SEATED' || table.status == 'IN_USE'}">Có khách</c:when>
                                                <c:when test="${table.status == 'CLEANING'}">Đang dọn</c:when>
                                                <c:otherwise>Khóa</c:otherwise>
                                            </c:choose>
                                        </div>

                                        <%-- Chỉ hiển thị thông báo cho bàn có khách (SEATED hoặc IN_USE) --%>
                                        <c:if test="${(table.status == 'SEATED' || table.status == 'IN_USE') && not empty tableItemCounts[table.tableId]}">
                                            <c:set var="counts" value="${tableItemCounts[table.tableId]}"/>
                                            <c:if test="${counts['ready'] > 0}">
                                                <div class="notification-badge ready" title="${counts['ready']} món sẵn sàng">
                                                    ${counts['ready']}
                                                </div>
                                            </c:if>
                                            <c:if test="${counts['cancelled'] > 0}">
                                                <div class="notification-badge cancelled" title="${counts['cancelled']} món bị hủy">
                                                    ${counts['cancelled']}
                                                </div>
                                            </c:if>
                                        </c:if>

                                        <div class="table-name">Bàn ${table.tableNumber}</div>
                                        <div class="table-capacity">${table.capacity} người</div>

                                        <div class="table-footer">
                                            <span>ID: ${table.tableId}</span>
                                            <c:if test="${table.currentSessionId != null}">
                                                <span>Session #${table.currentSessionId}</span>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </div>

                    </section>
                </c:if>
            </c:forEach>

        </section> <!-- /right-pane -->
    </main>

    <!-- MODAL CHI TIẾT BÀN / ACTIONS -->
    <div class="modal fade" id="tableModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Chi tiết bàn</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="tableDetails"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
                    <div id="tableActions"></div>
                </div>
            </div>
        </div>
    </div>

    <!-- SCRIPTS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentTableId = null;

        function refreshTables() {
            const areaId = document.getElementById('areaFilter').value;
            let url = 'tables';
            if (areaId) {
                url += '?area=' + areaId;
            }
            window.location.href = url;
        }

        function showTableDetails(tableId) {
            currentTableId = tableId;

            fetch('tables/' + tableId)
                .then(response => response.json())
                .then(data => {
                    let detailsHtml = `
                        <div class="row mb-1">
                            <div class="col-6"><strong>Số bàn:</strong></div>
                            <div class="col-6">` + data.tableNumber + `</div>
                        </div>
                        <div class="row mb-1">
                            <div class="col-6"><strong>Sức chứa:</strong></div>
                            <div class="col-6">` + data.capacity + ` người</div>
                        </div>
                        <div class="row mb-1">
                            <div class="col-6"><strong>Trạng thái:</strong></div>
                            <div class="col-6">` + data.status + `</div>
                        </div>
                        <div class="row mb-1">
                            <div class="col-6"><strong>Khu vực:</strong></div>
                            <div class="col-6">` + data.areaName + `</div>
                        </div>
                    `;

                    if (data.hasSession) {
                        detailsHtml += `
                            <div class="row mb-1">
                                <div class="col-6"><strong>Mở lúc:</strong></div>
                                <div class="col-6">` + new Date(data.openTime).toLocaleString() + `</div>
                            </div>`;
                    }

                    document.getElementById('tableDetails').innerHTML = detailsHtml;

                    let actions = '';
                    if (data.status === 'VACANT') {
                        actions = `
                            <button class="btn btn-success btn-sm" onclick="seatTable()">
                                <i class="fas fa-user-plus me-1"></i> Đón khách
                            </button>
                        `;
                    } else if (data.status === 'SEATED' || data.status === 'IN_USE') {
                        actions = `
                            <button class="btn btn-primary btn-sm" onclick="goToOrderPage()">
                                <i class="fas fa-utensils me-1"></i> Gọi món
                            </button>
                            <button class="btn btn-info btn-sm text-white" onclick="viewTableHistory()">
                                <i class="fas fa-history me-1"></i> Lịch sử
                            </button>
                            <button class="btn btn-warning btn-sm" onclick="vacateTable()">
                                <i class="fas fa-door-open me-1"></i> Trả bàn
                            </button>
                        `;
                    } else if (data.status === 'CLEANING') {
                        actions = `
                            <button class="btn btn-info btn-sm text-white" onclick="cleanTable()">
                                <i class="fas fa-broom me-1"></i> Hoàn thành dọn dẹp
                            </button>
                        `;
                    }

                    document.getElementById('tableActions').innerHTML = actions;

                    const modal = new bootstrap.Modal(document.getElementById('tableModal'));
                    modal.show();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Lỗi khi tải thông tin bàn');
                });
        }

        function seatTable() {
            if (!confirm('Xác nhận đón khách cho bàn này?')) return;

            fetch('tables/' + currentTableId + '/seat', {
                method: 'POST'
            })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    alert('Đón khách thành công!');
                    location.reload();
                } else {
                    alert('Lỗi khi đón khách!');
                }
            })
            .catch(err => {
                console.error('Error:', err);
                alert('Lỗi khi đón khách!');
            });
        }

        function vacateTable() {
            if (!confirm('Xác nhận trả bàn?')) return;

            fetch('tables/' + currentTableId + '/vacate', {
                method: 'POST'
            })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    alert('Trả bàn thành công!');
                    location.reload();
                } else {
                    alert('Lỗi khi trả bàn!');
                }
            })
            .catch(err => {
                console.error('Error:', err);
                alert('Lỗi khi trả bàn!');
            });
        }

        function cleanTable() {
            if (!confirm('Xác nhận hoàn thành dọn dẹp?')) return;

            fetch('tables/' + currentTableId + '/clean', {
                method: 'POST'
            })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    alert('Hoàn thành dọn dẹp!');
                    location.reload();
                } else {
                    alert('Lỗi khi hoàn thành dọn dẹp!');
                }
            })
            .catch(err => {
                console.error('Error:', err);
                alert('Lỗi khi hoàn thành dọn dẹp!');
            });
        }

        function goToOrderPage() {
            window.location.href = '${pageContext.request.contextPath}/order-page?tableId=' + currentTableId;
        }

        function viewTableHistory() {
            // Đánh dấu đã xem thông báo của bàn này
            if (currentTableId) {
                sessionStorage.setItem('viewed_table_' + currentTableId, 'true');
            }
            window.location.href = '${pageContext.request.contextPath}/table-history?tableId=' + currentTableId;
        }

        // Lọc khu vực thay đổi => refresh
        document.getElementById('areaFilter').addEventListener('change', function () {
            refreshTables();
        });

        // Ẩn badge cho các bàn đã xem lịch sử (chỉ ẩn nếu không có món mới)
        function hideViewedTableBadges() {
            document.querySelectorAll('.table-card').forEach(function(card) {
                const tableId = card.getAttribute('data-table-id');
                if (tableId && sessionStorage.getItem('viewed_table_' + tableId) === 'true') {
                    const readyBadge = card.querySelector('.notification-badge.ready');
                    const cancelledBadge = card.querySelector('.notification-badge.cancelled');
                    
                    // Nếu có món READY mới (badge đang hiển thị), xóa đánh dấu đã xem để hiện lại badge
                    if (readyBadge && readyBadge.offsetParent !== null) {
                        // Badge đang hiển thị = có món mới, xóa đánh dấu đã xem
                        sessionStorage.removeItem('viewed_table_' + tableId);
                        return; // Không ẩn badge này
                    }
                    
                    // Ẩn badge nếu đã xem và không có món mới
                    if (readyBadge) {
                        readyBadge.style.display = 'none';
                    }
                    if (cancelledBadge) {
                        cancelledBadge.style.display = 'none';
                    }
                }
            });
        }

        // Chạy khi trang load
        hideViewedTableBadges();

        // Auto-refresh để cập nhật thông báo món ăn mỗi 10 giây
        setInterval(function() {
            const areaId = document.getElementById('areaFilter').value;
            let url = 'tables';
            if (areaId) {
                url += '?area=' + areaId;
            }
            // Chỉ reload nếu không có modal đang mở
            if (!document.getElementById('tableModal').classList.contains('show')) {
                window.location.href = url;
            }
        }, 10000); // 10 giây
    </script>

</body>
</html>
