<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("page", "reception-checkin");
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
    <meta charset="UTF-8"/>
    <title>Check-in | Quầy lễ tân</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>
    <style>body{font-family: 'Heebo', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;}</style>
    <style>
        :root { --accent:#FEA116; --radius-md:12px; --sidebar-width:280px; }
        html, body { height: 100%; }
        body { display: flex; flex-direction: column; min-height: 100vh; }
        .app-shell { flex: 1 0 auto; }
        @media (min-width: 768px) {
            #sidebar { position: fixed !important; left: 0 !important; top: 0 !important; bottom: 0 !important; width: var(--sidebar-width) !important; z-index: 1050 !important; overflow-y: auto !important; }
            .app-shell { margin-left: var(--sidebar-width) !important; }
        }
        .card-pos { border-radius: var(--radius-md); padding: 1rem; border:1px solid #e5e7eb; background:#fff; }
        .pos-topbar {
            position: relative;
            background: linear-gradient(135deg, #1b1e2c, #2b2f46 60%, #1c1f30 100%);
            border:1px solid rgba(255,255,255,.1);
            border-radius: var(--radius-md);
            padding: 16px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #fff;
            margin-top: 58px; /* clear the included site header */
            margin-bottom: 18px;
        }
        .pos-left .title-row { display:flex; align-items:center; gap:.6rem; font-weight:600; font-size:1rem; }
        .pos-left .title-row i { color: var(--accent); font-size:1.1rem; }
        .pos-left .sub { margin-top:4px; font-size:.85rem; color:#cbd5e1; }
        /* Small table-layout styles used by the manual status UI */
        .tables-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 12px; margin-top: 8px; }
        .dining-table { padding: 10px; border-radius: 8px; border: 2px solid #ddd; text-align: center; cursor: pointer; position: relative; font-weight:600; }
        .dining-table .table-number { font-size: 1.1rem; }
        .dining-table .table-capacity { font-size: .85rem; color: #444; margin-top:4px; }
        .dining-table.table-available { background: #d4edda; border-color:#c3e6cb; color:#155724; }
        .dining-table.table-occupied { background:#f8d7da; border-color:#f5c6cb; color:#721c24; }
        .dining-table.table-reserved { background:#fff3cd; border-color:#ffeeba; color:#856404; }
        .dining-table.table-selected { box-shadow: 0 0 0 3px rgba(13,110,253,0.12); transform: translateY(-3px); }
    </style>
</head>
<body>
    <jsp:include page="/layouts/Header.jsp"/>

    <div class="app-shell">
        <aside id="sidebar">
            <jsp:include page="/layouts/sidebar.jsp"/>
        </aside>

        <main class="main-pane">
            <div class="container py-4">
                <header class="pos-topbar">
                    <div class="pos-left">
                        <div class="title-row"><i class="bi bi-person-check"></i> <span>Check-in / Quầy lễ tân</span></div>
                        <div class="sub">Nhập mã xác nhận • Cập nhật trạng thái bàn</div>
                    </div>
                    <div class="pos-right">
                        <div class="user-chip"><i class="bi bi-person-badge"></i> ${sessionScope.user.firstName} ${sessionScope.user.lastName}</div>
                    </div>
                </header>

                <div class="row g-3">
                    <div class="col-12">
                        <div class="card-pos">
                            <form method="post" action="<c:url value='/reception/checkin-table'/>">
                                <input type="hidden" name="action" value="lookup"/>
                                <div class="mb-2"><strong>Check-in theo mã xác nhận</strong></div>
                                <div class="mb-2">
                                    <label class="form-label">Mã xác nhận (confirmation code)</label>
                                    <input name="confirmationCode" class="form-control" placeholder="Nhập mã xác nhận" required />
                                </div>
                                <div class="d-flex gap-2">
                                    <button class="btn btn-primary" type="submit">Tìm</button>
                                </div>
                                <div class="small text-muted mt-2">Nhấn "Tìm" để xem thông tin đặt bàn và khách; sau đó nhấn "Xác nhận đến" để hoàn tất check-in.</div>
                            </form>

                            <c:if test="${not empty lookupReservation}">
                                <hr/>
                                <div>
                                    <h6>Thông tin đặt bàn</h6>
                                    <table class="table table-sm">
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
                                        <button class="btn btn-success">Xác nhận đến</button>
                                    </form>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <div class="col-12">
                        <div class="card-pos">
                            <div class="mb-2"><strong>Cập nhật trạng thái bàn (thủ công)</strong></div>
                            <div class="small text-muted">Bấm vào một bàn bên dưới để chọn, sau đó chọn trạng thái và nhấn Cập nhật.</div>

                            <div class="tables-grid">
                                <%
                                    Dal.TableDAO tableDao2 = new Dal.TableDAO();
                                    java.util.List<Models.DiningTable> all2 = tableDao2.getAllTables();
                                    for (Models.DiningTable t : all2) {
                                        String cls = "table-reserved";
                                        if (Models.DiningTable.STATUS_VACANT.equalsIgnoreCase(t.getStatus())) cls = "table-available";
                                        else if (Models.DiningTable.STATUS_SEATED.equalsIgnoreCase(t.getStatus()) || Models.DiningTable.STATUS_OCCUPIED.equalsIgnoreCase(t.getStatus())) cls = "table-occupied";
                                %>
                                <div class="dining-table <%=cls%>" data-table-number="<%=t.getTableNumber()%>" onclick="selectManualTable(this)">
                                    <div class="table-number"><%=t.getTableNumber()%></div>
                                    <div class="table-capacity"><%=t.getCapacity()%> chỗ</div>
                                    <div class="table-status"><%= statusLabel(t.getStatus()) %></div>
                                </div>
                                <% } %>
                            </div>

                            <hr/>
                            <form id="updateStatusForm" method="post" action="<c:url value='/reception/checkin-table'/>">
                                <input type="hidden" name="action" value="update_status"/>
                                <input type="hidden" name="tableNumber" id="manualTableNumber" />
                                <div class="row g-2 align-items-center">
                                    <div class="col-md-4">
                                        <label class="form-label">Bàn đã chọn</label>
                                        <input type="text" id="manualSelectedLabel" class="form-control" readonly placeholder="Chưa chọn bàn" />
                                    </div>
                                    <div class="col-md-4">
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
                                    <div class="col-md-4 d-flex align-items-end">
                                        <button class="btn btn-warning w-100" type="submit">Cập nhật trạng thái</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div class="col-12 mt-3">
                        <c:if test="${not empty sessionScope.successMessage}">
                            <div class="alert alert-success">${sessionScope.successMessage}</div>
                            <c:remove var="successMessage" scope="session"/>
                        </c:if>
                        <c:if test="${not empty sessionScope.errorMessage}">
                            <div class="alert alert-danger">${sessionScope.errorMessage}</div>
                            <c:remove var="errorMessage" scope="session"/>
                        </c:if>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <jsp:include page="/layouts/Footer.jsp"/>
    <script src="<c:url value='/js/main.js'/>"></script>
    <script>
        function selectManualTable(el) {
            // remove previous selection
            document.querySelectorAll('.dining-table.table-selected').forEach(x => x.classList.remove('table-selected'));
            el.classList.add('table-selected');
            var tn = el.getAttribute('data-table-number');
            document.getElementById('manualTableNumber').value = tn;
            document.getElementById('manualSelectedLabel').value = tn;
            // scroll to form
            document.getElementById('manualSelectedLabel').scrollIntoView({behavior:'smooth', block:'center'});
        }
    </script>
</body>
</html>
