<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
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
            case "SEATED": return "Có khách";
            case "DINING": return "Đang phục vụ";
            case "READY_TO_PAY": return "Chờ thanh toán";
            case "CLEANING": return "Đang dọn";
            case "RESERVED": return "Đã đặt";
            case "PENDING": return "Chờ";
            default: return s;
        }
    }
%>
<%
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>Chuyển bàn | Quầy lễ tân</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>
    <style>body{font-family: 'Heebo', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;}</style>
    <style>
        :root { --accent:#FEA116; --line:#e5e7eb; --radius-lg:20px; --radius-md:12px; --sidebar-width:280px; }
        /* Make the page a column so footer stays at bottom */
        html, body { height: 100%; }
        body { display: flex; flex-direction: column; min-height: 100vh; }
        .app-shell { flex: 1 0 auto; }
        /* POS topbar to match reception-walkin */
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

        .card-pos {
            position: relative;
            background: linear-gradient(to bottom right, #ffffff 0%, #fafaff 80%);
            border: 1px solid rgba(99,102,241,.12);
            border-top: 4px solid var(--accent);
            border-radius: var(--radius-lg);
            padding: 1rem 1.25rem;
            min-height: 120px;
            transition: all .25s ease;
        }

        /* Force sidebar fixed-left on larger screens to match reception-walkin */
        @media (min-width: 768px) {
            #sidebar {
                position: fixed !important;
                left: 0 !important;
                top: 0 !important;
                bottom: 0 !important;
                width: var(--sidebar-width) !important;
                z-index: 1050 !important;
                overflow-y: auto !important;
            }
            .app-shell { margin-left: var(--sidebar-width) !important; }
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
            <div class="container py-4">
                <header class="pos-topbar">
                    <div class="pos-left">
                        <div class="title-row"><i class="bi bi-arrow-left-right"></i> <span>Chuyển bàn</span></div>
                        <div class="sub">Di chuyển phiên/bill từ bàn nguồn sang bàn đích</div>
                    </div>
                    <div class="pos-right">
                        <div class="user-chip"><i class="bi bi-person-badge"></i> ${sessionScope.user.firstName} ${sessionScope.user.lastName}</div>
                    </div>
                </header>

                <div class="card-pos mb-3">
                    <form method="post" action="<c:url value='/reception/transfer-table'/>" class="row g-2 align-items-center">
                        <div class="col-12 mb-2"><strong>Chuyển bàn</strong></div>
                        <div class="col-md-5">
                            <label class="form-label">Bàn nguồn (có khách)</label>
                            <select name="sourceTable" class="form-select" required>
                                <option value="">-- Chọn bàn nguồn --</option>
                                <%
                                    Dal.TableDAO tableDao = new Dal.TableDAO();
                                    java.util.List<Models.DiningTable> all = tableDao.getAllTables();
                                    for (Models.DiningTable t : all) {
                                        if (!Models.DiningTable.STATUS_VACANT.equalsIgnoreCase(t.getStatus())) {
                                %>
                                <option value="<%=t.getTableNumber()%>"><%=t.getTableNumber()%> — <%= statusLabel(t.getStatus()) %></option>
                                <%      }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="col-md-5">
                            <label class="form-label">Bàn đích (trống)</label>
                            <select name="targetTable" class="form-select" required>
                                <option value="">-- Chọn bàn đích --</option>
                                <%
                                    java.util.List<Models.DiningTable> vacant = tableDao.getVacantTables();
                                    for (Models.DiningTable v : vacant) {
                                %>
                                <option value="<%=v.getTableNumber()%>"><%=v.getTableNumber()%> • sx:<%=v.getCapacity()%></option>
                                <% }
                                %>
                            </select>
                        </div>

                        <div class="col-md-2 d-flex align-items-end">
                            <button class="btn btn-warning w-100" type="submit">Chuyển</button>
                        </div>
                        <div class="col-12 text-muted small mt-2">Ghi chú: thao tác sẽ cập nhật phiên bảng (nếu có) và trạng thái bàn.</div>
                    </form>
                </div>

                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success">${sessionScope.successMessage}</div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-danger">${sessionScope.errorMessage}</div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

            </div>
        </main>
    </div>

    <jsp:include page="/layouts/Footer.jsp"/>
    <script src="<c:url value='/js/main.js'/>"></script>
</body>
</html>
