<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("page", "reception-walkin");
    request.setAttribute("overlayNav", false);
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>Quầy lễ tân — Nhận đặt bàn (Walk-in)</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>
    <style>body{font-family: 'Heebo', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;}</style>
    <style>
        /* Ensure headings and main labels use Heebo to match reception.jsp */
        .main-pane h1,
        .main-pane h2,
        .main-pane h3,
        .main-pane h4,
        .main-pane h5,
        .main-pane h6,
        .pos-left .title-row,
        .pos-left .sub {
            font-family: 'Heebo', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
        }
        .main-pane h5 { font-weight: 600; }
    </style>
    <style>
        /* Reuse reception styles for POS look */
        :root { --accent:#FEA116; --line:#e5e7eb; --radius-lg:20px; --radius-md:12px; }
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
            min-height: 180px;
            display:flex; flex-direction:column; justify-content:space-between;
            transition: all .25s ease;
        }
        .card-pos::before { content:""; position:absolute; top:0; left:0; width:100%; height:5px; background: linear-gradient(90deg, var(--accent), #4f46e5); border-radius:8px 8px 0 0; }
        .vacant-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:1.25rem; }
        .tiny-form { display:flex; gap:.5rem; align-items:center; }
        .tiny-form input, .tiny-form select { height:38px; }
        .meta-row { display:flex; justify-content:space-between; font-size:.9rem; color:#334155; }
    </style>
    <style>
        /* Page-specific override: force sidebar fixed left on this page */
        @media (min-width: 768px) {
            #sidebar {
                position: fixed !important;
                left: 0 !important;
                top: 0 !important;
                bottom: 0 !important;
                width: var(--sidebar-width, 280px) !important;
                z-index: 1050 !important;
                overflow-y: auto !important;
            }
            .app-shell { margin-left: var(--sidebar-width, 280px) !important; }
        }
    </style>
</head>
<body>
    <jsp:include page="/layouts/Header.jsp"/>

    <div class="app-shell">
        <!-- sidebar -->
        <aside id="sidebar">
            <jsp:include page="/layouts/sidebar.jsp"/>
        </aside>

        <main class="main-pane">
            <div class="container py-4">

                <header class="pos-topbar">
                    <div class="pos-left">
                        <div class="title-row">
                            <i class="bi bi-door-open"></i>
                            <span>Nhận đặt bàn tại quầy</span>
                        </div>
                        <div class="sub">Xem bàn trống • Nhận đặt tại quầy</div>
                    </div>
                    <div class="pos-right">
                        <div class="user-chip">
                            <i class="bi bi-person-badge"></i>
                            <span>${sessionScope.user.firstName} ${sessionScope.user.lastName}</span>
                            <span class="role-badge">${sessionScope.user.roleName}</span>
                        </div>
                        
                    </div>
                </header>



        <h5>Bàn trống sẵn sàng nhận đặt</h5>
        <div class="vacant-grid mb-4">
            <%
                Dal.TableDAO dao = new Dal.TableDAO();
                java.util.List<Models.DiningTable> list = dao.getVacantTables();
                if (list.isEmpty()) {
            %>
            <div class="card-pos p-3">Hiện không có bàn trống.</div>
            <% } else {
                    for (Models.DiningTable t : list) {
            %>
            <div class="card-pos">
                <div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <div><strong>Bàn <%=t.getTableNumber()%></strong></div>
                        <div class="text-muted">Sức chứa: <%=t.getCapacity()%></div>
                    </div>
                    <div class="meta-row mb-2">
                        <div>Khu vực</div>
                        <div><c:out value='${empty t.areaName ? "-" : t.areaName}'/></div>
                    </div>
                </div>

                <form method="post" action="<c:url value='/reception/walkin-booking'/>">
                    <input type="hidden" name="tableNumber" value="<%=t.getTableNumber()%>"/>
                    <div class="mb-2">
                        <input name="customerName" class="form-control" placeholder="Tên khách" required autofocus/>
                    </div>
                    <div class="mb-2">
                        <input name="phone" class="form-control walkin-phone" placeholder="Số điện thoại" required maxlength="10" minlength="10" pattern="[0-9]{10}" inputmode="numeric" title="Nhập 10 chữ số" />
                    </div>
                    <div class="mb-2 tiny-form">
                        <input name="email" type="email" class="form-control" placeholder="Email (bắt buộc)" required />
                        <select name="partySize" class="form-select" style="width:110px;">
                            <% 
                                int cap = t.getCapacity() > 0 ? t.getCapacity() : 1;
                                int defaultSize = cap >= 2 ? 2 : 1;
                                for (int i = 1; i <= cap; i++) { 
                            %>
                                <option value="<%=i%>" <%= i==defaultSize?"selected":"" %>><%=i%></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-2">
                        <label class="form-label small">Ngày đặt / Giờ đặt</label>
                        <div class="input-group">
                <input type="date" name="reservation_date" class="form-control" required
                    onfocus="this.min=new Date().toISOString().split('T')[0];" style="flex:1 1 auto; min-width:160px;" />
                            <select name="reservation_time" class="form-select" required style="width:140px;">
                                <option value="">Chọn giờ</option>
                                <% for (int hour = 10; hour <= 21; hour++) {
                                     for (String minute : new String[]{"00","30"}) {
                                %>
                                <option value="<%=hour%>:<%=minute%>:00"><%=hour%>:<%=minute%></option>
                                <%     }
                                   }
                                %>
                            </select>
                        </div>
                        <div class="form-text text-muted small">Vui lòng đặt trước ít nhất 2 tiếng (nếu đặt cho hôm nay)</div>
                    </div>
                    <div class="mb-2">
                        <input name="specialRequests" class="form-control" placeholder="Ghi chú (tuỳ chọn)" />
                    </div>
                    <div class="d-flex gap-2">
                        <button class="btn btn-success btn-sm" type="submit">Nhận đặt bàn</button>
                        <a class="btn btn-outline-secondary btn-sm" href="<c:url value='/views/reception.jsp'/>">Hủy</a>
                    </div>
                </form>
            </div>
            <%      }
                }
            %>
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
    <script>
        (function(){
            // Attach listeners to all phone inputs on the page (there may be multiple per table)
            var phones = document.querySelectorAll('.walkin-phone');
            phones.forEach(function(phone){
                phone.addEventListener('input', function(e){
                    var cleaned = phone.value.replace(/\D/g,'');
                    if(phone.value !== cleaned) phone.value = cleaned;
                    if(cleaned.length === 10) phone.setCustomValidity('');
                    else phone.setCustomValidity('Số điện thoại phải có 10 chữ số.');
                });
                phone.addEventListener('paste', function(e){
                    e.preventDefault();
                    var paste = (e.clipboardData || window.clipboardData).getData('text');
                    var cleaned = paste.replace(/\D/g,'').slice(0,10);
                    phone.value = cleaned;
                    phone.dispatchEvent(new Event('input'));
                });
            });
            var forms = document.querySelectorAll('form[action$="/reception/walkin-booking"]');
            // helper: update time options within a form based on selected date and now+2h rule
            function updateTimeOptionsForForm(f){
                var dateEl = f.querySelector('input[name="reservation_date"]');
                var timeEl = f.querySelector('select[name="reservation_time"]');
                if(!dateEl || !timeEl) return;
                var today = new Date();
                var todayOnly = new Date(today.getFullYear(), today.getMonth(), today.getDate());
                // set min date attribute
                dateEl.min = new Date().toISOString().split('T')[0];

                var selectedDate = dateEl.value ? new Date(dateEl.value + 'T00:00:00') : null;
                var minAllowed = new Date();
                minAllowed.setHours(minAllowed.getHours() + 2);

                // iterate options; keep the first placeholder as selectable if any
                var firstEnabled = null;
                for(var i=0;i<timeEl.options.length;i++){
                    var opt = timeEl.options[i];
                    if(!opt.value) { opt.disabled = false; continue; }
                    var parts = opt.value.split(':');
                    var hour = parseInt(parts[0],10);
                    var minute = parseInt(parts[1],10);
                    var disabled = false;
                    if(!selectedDate) disabled = false;
                    else if(selectedDate < todayOnly) disabled = true;
                    else if(selectedDate.toDateString() === todayOnly.toDateString()){
                        var optDateTime = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate(), hour, minute, 0);
                        if(optDateTime < minAllowed) disabled = true;
                    }
                    opt.disabled = disabled;
                    if(!disabled && !firstEnabled && opt.value) firstEnabled = opt;
                }
                // if current selection is disabled, clear it and set to first enabled
                if(timeEl.value){
                    var curr = timeEl.options[timeEl.selectedIndex];
                    if(curr && curr.disabled){
                        if(firstEnabled) timeEl.value = firstEnabled.value;
                        else timeEl.value = '';
                    }
                }
            }

            forms.forEach(function(f){
                // on date change update time options
                var dateEl = f.querySelector('input[name="reservation_date"]');
                if(dateEl){
                    dateEl.addEventListener('change', function(){ updateTimeOptionsForForm(f); });
                    // ensure min is set on focus as well
                    dateEl.addEventListener('focus', function(){ this.min = new Date().toISOString().split('T')[0]; updateTimeOptionsForForm(f); });
                }

                // initialize options on load
                updateTimeOptionsForForm(f);

                f.addEventListener('submit', function(e){
                    var p = f.querySelector('.walkin-phone');
                    if(p && p.value.length !== 10){
                        e.preventDefault();
                        p.reportValidity();
                        return;
                    }

                    // date/time validation: date >= today; if date == today then time >= now + 2 hours
                    var dateEl = f.querySelector('input[name="reservation_date"]');
                    var timeEl = f.querySelector('select[name="reservation_time"]');
                    if(dateEl && timeEl){
                        var dateVal = dateEl.value;
                        var timeVal = timeEl.value; // expected format HH:MM:00
                        if(!dateVal || !timeVal){
                            e.preventDefault();
                            if(!dateVal) dateEl.reportValidity();
                            if(!timeVal) timeEl.reportValidity();
                            return;
                        }
                        var selectedDate = new Date(dateVal + 'T00:00:00');
                        var today = new Date();
                        var todayDateOnly = new Date(today.getFullYear(), today.getMonth(), today.getDate());
                        if(selectedDate < todayDateOnly){
                            e.preventDefault();
                            dateEl.setCustomValidity('Ngày không được nhỏ hơn hôm nay');
                            dateEl.reportValidity();
                            return;
                        }
                        // parse time
                        var parts = timeVal.split(':');
                        var hour = parseInt(parts[0],10);
                        var minute = parseInt(parts[1],10);
                        var selectedDateTime = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate(), hour, minute, 0);
                        var minAllowed = new Date();
                        minAllowed.setHours(minAllowed.getHours() + 2);
                        if(selectedDate.toDateString() === todayDateOnly.toDateString()){
                            if(selectedDateTime < minAllowed){
                                e.preventDefault();
                                timeEl.setCustomValidity('Vui lòng đặt trước ít nhất 2 tiếng cho hôm nay');
                                timeEl.reportValidity();
                                return;
                            }
                        }
                        // clear custom validity
                        dateEl.setCustomValidity('');
                        timeEl.setCustomValidity('');
                    }
                });
            });
        })();
    </script>
</body>
</html>
