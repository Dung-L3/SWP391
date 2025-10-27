<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="Models.Staff"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="page" value="staff" scope="request"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý nhân viên · RMS POS</title>

    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <!-- Google Fonts giống trang pricing -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <!-- Icons / Bootstrap -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>

    <!-- global site css (header/footer layout, etc) -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <style>
        /************************************
         * THEME COLORS (reuse vibe từ pricing page)
         ************************************/
        :root {
            --bg-app: #f5f6fa;
            --bg-grad-1: rgba(88, 80, 200, 0.08);
            --bg-grad-2: rgba(254, 161, 22, 0.06);

            --panel-light-top: #fafaff;
            --panel-light-bottom: #ffffff;

            --panel-dark-start:#2a3048;
            --panel-dark-end:#1b1e2c;
            --panel-dark-border:rgba(255,255,255,.08);

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.12);
            --accent-border:rgba(254,161,22,.45);

            --brand:#4f46e5;
            --brand-border:#6366f1;

            --success:#16a34a;
            --success-soft:#d1fae5;
            --danger:#dc2626;

            --line:#e5e7eb;

            --radius-lg:20px;
            --radius-md:14px;
            --radius-sm:6px;

            --sidebar-width:280px;
        }

        /************************************
         * GLOBAL BACKGROUND / LAYOUT GRID
         ************************************/
        body {
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            color: var(--ink-900);
            font-family: "Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
            min-height:100vh;
        }

        .app-shell{
            display:grid;
            grid-template-columns: var(--sidebar-width) 1fr;
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
                box-shadow:24px 0 60px rgba(0,0,0,.7);
                background:#000;
                transform:translateX(-100%);
                transition:transform .2s ease;
                z-index:1040;
            }
            #sidebar.open{transform:translateX(0);}
        }

        main.main-pane{
            padding:28px 32px 44px;
        }

        /************************************
         * TOP POS BAR (giống pricing topbar)
         ************************************/
        .pos-topbar{
            background: linear-gradient(135deg, var(--panel-dark-end) 0%, #2b2f46 60%, #1c1f30 100%);
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

        /************************************
         * FILTER CARD (search / role)
         ************************************/
        .filter-card{
            background:linear-gradient(to bottom right,var(--panel-light-top) 0%,var(--panel-light-bottom) 100%);
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:0 28px 64px rgba(15,23,42,.12);
            padding:1rem 1.25rem;
            margin-bottom:1.5rem;

            position:relative;
            border-top:4px solid var(--accent);
        }
        .filter-card::before{
            /* same fancy glow bar like pricing detail-card */
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

        .filter-card .form-control,
        .filter-card .form-select{
            border-radius:10px;
            border:1.5px solid #e2e8f0;
            background:#fff;
            transition:all .25s ease;
            font-size:.9rem;
        }
        .filter-card .form-control:focus,
        .filter-card .form-select:focus{
            border-color:var(--accent);
            box-shadow:0 0 0 .25rem rgba(254,161,22,.25);
            background:#fffefc;
        }

        .btn-add-staff{
            background:var(--accent);
            border:none;
            color:#1e1e2f;
            font-weight:600;
            border-radius:var(--radius-sm);
            padding:.55rem .8rem;
            box-shadow:0 16px 30px rgba(254,161,22,.3);
            transition:all .2s ease;
        }
        .btn-add-staff:hover{
            filter:brightness(1.05);
            box-shadow:0 20px 40px rgba(254,161,22,.45);
        }

        /************************************
         * STAFF CARD GRID
         ************************************/
        .staff-card{
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border-radius:var(--radius-lg);
            border:1px solid rgba(99,102,241,.25);
            border-top:4px solid var(--accent);
            box-shadow:0 10px 40px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,.8);
            transition:all .25s ease;
            position:relative;
            overflow:hidden;
            display:flex;
            flex-direction:column;
            height:100%;
        }
        .staff-card:hover{
            transform:translateY(-2px);
            box-shadow:0 20px 60px rgba(254,161,22,.2), inset 0 1px 0 rgba(255,255,255,1);
        }

        /* mini header stripe across top for visual identity */
        .staff-card::before{
            content:"";
            position:absolute;
            top:0;
            left:0;
            width:100%;
            height:5px;
            background:linear-gradient(90deg,var(--accent),var(--brand));
            opacity:.8;
        }

        .staff-head{
            display:flex;
            justify-content:space-between;
            align-items:flex-start;
            padding:1rem 1rem .75rem;
        }
        .staff-idblock{
            display:flex;
            flex-direction:column;
            gap:.25rem;
        }
        .staff-name{
            display:flex;
            align-items:center;
            flex-wrap:wrap;
            gap:.5rem;
            font-size:1rem;
            font-weight:600;
            color:var(--ink-900);
            line-height:1.3;
        }
        .staff-position{
            font-size:.8rem;
            color:var(--ink-500);
            line-height:1.3;
        }

        /* trạng thái */
        .status-badge{
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
            border-radius:var(--radius-sm);
            padding:.35rem .5rem;
            white-space:nowrap;
            min-width:80px;
            text-align:center;
            border:1px solid transparent;
        }
        .status-active{
            background:var(--success-soft);
            color:#065f46;
            border-color:rgba(16,185,129,.25);
        }
        .status-inactive{
            background:rgba(220,38,38,.08);
            color:#b91c1c;
            border-color:rgba(220,38,38,.3);
        }

        .staff-body{
            padding:0 1rem 1rem;
            flex:1;
        }
        .staff-line{
            font-size:.8rem;
            color:var(--ink-700);
            margin-bottom:.4rem;
            display:flex;
            align-items:flex-start;
            gap:.5rem;
            word-break:break-word;
        }
        .staff-line i{
            color:var(--ink-500);
            min-width:16px;
        }

        .staff-actions{
            padding: .75rem 1rem 1rem;
            border-top:1px solid var(--line);
            display:flex;
            flex-wrap:wrap;
            gap:.4rem;
        }
        .staff-actions .btn{
            border-radius:10px;
            font-size:.8rem;
            line-height:1.2;
            font-weight:500;
            padding:.4rem .6rem;
        }
        .staff-actions .btn i{
            margin-right:.4rem;
        }
        .btn-outline-info{
            border-color:#38bdf8;
            color:#0ea5e9;
        }
        .btn-outline-info:hover{
            background:#e0f2fe;
            border-color:#0ea5e9;
            color:#0369a1;
        }
        .btn-outline-warning{
            border-color:#facc15;
            color:#ca8a04;
        }
        .btn-outline-warning:hover{
            background:#fef9c3;
            border-color:#eab308;
            color:#713f12;
        }
        .btn-outline-danger{
            border-color:#f87171;
            color:#dc2626;
        }
        .btn-outline-danger:hover{
            background:#fee2e2;
            border-color:#dc2626;
            color:#7f1d1d;
        }
        .btn-success-activate{
            background:#16a34a;
            border:none;
            color:#fff;
            box-shadow:0 10px 24px rgba(22,163,74,.3);
        }
        .btn-success-activate:hover{
            background:#0f766e;
        }

        /************************************
         * EMPTY STATE
         ************************************/
        .empty-card{
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border-radius:var(--radius-lg);
            border:1px solid rgba(99,102,241,.25);
            border-top:4px solid var(--accent);
            box-shadow:0 10px 40px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,.8);
            text-align:center;
            padding:3rem 2rem;
        }
        .empty-card i{
            font-size:2.5rem;
            color:var(--accent);
            margin-bottom:1rem;
        }
        .empty-card h5{
            font-weight:600;
            color:var(--ink-900);
        }
        .empty-card p{
            font-size:.9rem;
            color:var(--ink-500);
            margin-bottom:1rem;
        }

        /************************************
         * FLASH ALERTS
         ************************************/
        .alert{
            border-radius:var(--radius-sm);
            border:1px solid transparent;
            box-shadow:0 16px 40px rgba(0,0,0,.12);
            font-size:.9rem;
        }

        /************************************
         * MODAL (Deactivate)
         ************************************/
        .modal-content{
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:0 32px 80px rgba(0,0,0,.5);
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
        }
        .modal-header{
            background:linear-gradient(135deg,var(--panel-dark-end) 0%,#2b2f46 60%,#1c1f30 100%);
            border-top-left-radius:var(--radius-lg);
            border-top-right-radius:var(--radius-lg);
            border-bottom:1px solid rgba(255,255,255,.08);
            color:#fff;
        }
        .modal-title i{
            color:var(--accent);
        }
        .modal-body p{
            color:var(--ink-700);
            font-size:.9rem;
        }
        .modal-body ul{
            font-size:.8rem;
            color:#dc2626;
            padding-left:1.2rem;
        }
        .modal-footer .btn-danger{
            background:#dc2626;
            border:none;
        }
        .modal-footer .btn-danger:hover{
            background:#b91c1c;
        }

        /* utility */
        .text-soft{color:var(--ink-500);}
        .text-accent{color:var(--accent);}
    </style>
</head>

<body>

    <!-- Header chung (navbar top) -->
    <jsp:include page="/layouts/Header.jsp"/>

    <div class="app-shell">

        <!-- Sidebar trái giữ nguyên -->
        <aside id="sidebar" class="bg-dark text-white">
            <jsp:include page="../layouts/sidebar.jsp"/>
        </aside>

        <!-- Khu vực chính -->
        <main class="main-pane">

            <!-- POS Topbar -->
            <header class="pos-topbar">
                <div class="pos-left">
                    <div class="title-row">
                        <i class="bi bi-people-fill"></i>
                        <span>Quản lý nhân viên</span>
                    </div>
                    <div class="sub">
                        Quản lý hồ sơ, phân quyền và trạng thái hoạt động của nhân viên.
                    </div>
                </div>
                <div class="pos-right">
                    <div class="user-chip">
                        <i class="bi bi-person-badge"></i>
                        <span>${sessionScope.user.fullName}</span>
                        <span class="role-badge">${sessionScope.user.roleName}</span>
                    </div>

                    <button class="btn-toggle-sidebar" onclick="toggleSidebar()">
                        <i class="bi bi-list"></i><span>Menu</span>
                    </button>
                </div>
            </header>

            <!-- FORM FILTER + nút thêm -->
            <div class="filter-card">
                <form class="row g-2 align-items-end" method="get" action="staff-management" id="staffFilterForm">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold small text-soft">Tìm kiếm</label>
                        <input type="text"
                               class="form-control"
                               name="q"
                               value="${q}"
                               placeholder="Tìm theo tên, email, số điện thoại..."
                               oninput="debouncedSubmit()"/>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label fw-semibold small text-soft">Vai trò hệ thống</label>
                        <select class="form-select" name="roleId" onchange="document.getElementById('staffFilterForm').submit()">
                            <option value="">Tất cả vai trò</option>
                            <c:forEach var="r" items="${roles}">
                                <option value="${r.roleId}" ${roleId == r.roleId ? 'selected' : ''}>${r.roleName}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-2 text-md-end text-start mt-3 mt-md-0">
                        <a href="staff-management?action=add" class="btn btn-add-staff w-100 w-md-auto">
                            <i class="fa-solid fa-user-plus me-1"></i> Thêm nhân viên
                        </a>
                    </div>
                </form>
            </div>

            <!-- FLASH MESSAGES -->
            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                if (success != null) {
            %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i><%= success %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i><%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <!-- STAFF GRID -->
            <div class="row">
                <%
                    List<Staff> staffList = (List<Staff>) request.getAttribute("staffList");
                    if (staffList != null && !staffList.isEmpty()) {
                        for (Staff s : staffList) {
                %>
                <div class="col-md-6 col-lg-4 mb-4">
                    <div class="staff-card h-100">

                        <!-- header block -->
                        <div class="staff-head">
                            <div class="staff-idblock">
                                <div class="staff-name">
                                    <i class="fa-solid fa-id-badge text-accent"></i>
                                    <span><%= s.getFullName() %></span>
                                </div>
                                <div class="staff-position">
                                    <%= s.getPosition() != null ? s.getPosition() : "Chưa phân công" %>
                                </div>
                            </div>

                            <%
                                boolean active = s.isActive();
                                String statusClass = active ? "status-active" : "status-inactive";
                            %>
                            <span class="status-badge <%=statusClass%>">
                                <%= s.getStatus() %>
                            </span>
                        </div>

                        <!-- body info -->
                        <div class="staff-body">
                            <div class="staff-line">
                                <i class="fa-regular fa-envelope"></i>
                                <span><%= s.getEmail() %></span>
                            </div>
                            <div class="staff-line">
                                <i class="fa-solid fa-phone"></i>
                                <span><%= s.getPhone() != null ? s.getPhone() : "—" %></span>
                            </div>
                            <% if (s.getHireDate() != null) { %>
                            <div class="staff-line">
                                <i class="fa-regular fa-calendar"></i>
                                <span><%= s.getHireDate() %></span>
                            </div>
                            <% } %>
                        </div>

                        <!-- actions -->
                        <div class="staff-actions">
                            <a href="staff-management?action=view&id=<%= s.getStaffId() %>"
                               class="btn btn-sm btn-outline-info flex-grow-1 flex-md-grow-0">
                                <i class="fa-solid fa-eye"></i> Xem
                            </a>

                            <a href="staff-management?action=edit&id=<%= s.getStaffId() %>"
                               class="btn btn-sm btn-outline-warning flex-grow-1 flex-md-grow-0">
                                <i class="fa-solid fa-pen"></i> Sửa
                            </a>

                            <% if (s.isActive() && !"Manager".equals(s.getPosition())) { %>
                            <button class="btn btn-sm btn-outline-danger flex-grow-1 flex-md-grow-0"
                                    onclick="confirmDeactivate(<%= s.getStaffId() %>, <%= s.getUserId() %>, '<%= s.getFullName() %>')">
                                <i class="fa-solid fa-user-slash"></i> Vô hiệu hóa
                            </button>
                            <% } else if (!s.isActive()) { %>
                            <form method="post" action="staff-management" style="display:inline-block">
                                <input type="hidden" name="action" value="activate"/>
                                <input type="hidden" name="staffId" value="<%= s.getStaffId() %>"/>
                                <input type="hidden" name="userId" value="<%= s.getUserId() %>"/>
                                <button class="btn btn-sm btn-success-activate flex-grow-1 flex-md-grow-0">
                                    <i class="fa-solid fa-user-check"></i> Kích hoạt
                                </button>
                            </form>
                            <% } %>
                        </div>

                    </div><!-- /staff-card -->
                </div>
                <%
                        }
                    } else {
                %>
                <div class="col-12">
                    <div class="empty-card">
                        <i class="fa-solid fa-user-group"></i>
                        <h5>Chưa có nhân viên nào</h5>
                        <p>Hãy thêm nhân viên đầu tiên để bắt đầu quản lý.</p>
                        <a href="staff-management?action=add" class="btn btn-add-staff">
                            <i class="fa-solid fa-user-plus me-1"></i> Thêm nhân viên
                        </a>
                    </div>
                </div>
                <% } %>
            </div>

        </main>
    </div>

    <!-- Modal xác nhận vô hiệu hóa -->
    <div class="modal fade" id="deactivateModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">

                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fa-solid fa-user-slash me-1"></i>
                        Xác nhận vô hiệu hóa
                    </h5>
                    <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <p>Bạn có chắc chắn muốn vô hiệu hóa <strong id="staffName"></strong>?</p>
                    <ul>
                        <li>Tài khoản đăng nhập sẽ bị khóa</li>
                        <li>Nhân viên sẽ không thể truy cập hệ thống</li>
                        <li>Trạng thái chuyển sang INACTIVE</li>
                    </ul>
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <form method="post" style="display:inline;">
                        <input type="hidden" name="action" value="deactivate">
                        <input type="hidden" name="staffId" id="deactivateStaffId">
                        <input type="hidden" name="userId" id="deactivateUserId">
                        <button class="btn btn-danger">Vô hiệu hóa</button>
                    </form>
                </div>

            </div>
        </div>
    </div>

    <!-- Footer chung -->
    <jsp:include page="/layouts/Footer.jsp"/>

    <!-- JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // mở / đóng sidebar trên mobile
        function toggleSidebar(){
            var el = document.getElementById('sidebar');
            if(el) el.classList.toggle('open');
        }

        // filter search debounce
        let __sfTimer;
        function debouncedSubmit(){
            const form = document.getElementById('staffFilterForm');
            if(!form) return;
            clearTimeout(__sfTimer);
            __sfTimer = setTimeout(function(){
                form.submit();
            }, 350);
        }

        // show modal deactivate
        function confirmDeactivate(staffId, userId, staffName){
            var staffIdInput = document.getElementById('deactivateStaffId');
            var userIdInput = document.getElementById('deactivateUserId');
            var nameSpan = document.getElementById('staffName');
            if(staffIdInput) staffIdInput.value = staffId;
            if(userIdInput) userIdInput.value = userId;
            if(nameSpan) nameSpan.textContent = staffName || '';
            var modalEl = document.getElementById('deactivateModal');
            if (modalEl){
                var modal = new bootstrap.Modal(modalEl);
                modal.show();
            }
        }

        // auto close alert after 5s (như trang pricing)
        setTimeout(function(){
            var alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(al){
                var bsAlert = new bootstrap.Alert(al);
                bsAlert.close();
            });
        }, 5000);
    </script>
</body>
</html>
