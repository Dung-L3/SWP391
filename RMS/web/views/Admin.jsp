<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    // Trang active + navbar solid
    request.setAttribute("page", "admin");
    request.setAttribute("overlayNav", false);
%>

<!-- ===== Chặn truy cập khi chưa đăng nhập ===== -->
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Admin | Restoran</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet">

    <!-- Icons & Bootstrap -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Template Styles -->
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">

    <style>
        /* ===== Elegant theme (Indigo x Champagne) ===== */
        :root{
          /* spacing */
          --space-1: .5rem;   /* 8px  */
          --space-2: .75rem;  /* 12px */
          --space-3: 1rem;    /* 16px */
          --space-4: 1.25rem; /* 20px */
          --space-5: 1.5rem;  /* 24px */
          --radius: 16px;
          /* palette */
          --ink-900:#0f172a;   /* deep slate */
          --ink-700:#334155;   /* slate */
          --ink-500:#64748b;   /* muted */
          --paper:#f7f7fa;     /* page bg */
          --card:#ffffff;      /* card bg */
          --primary:#4f46e5;   /* indigo */
          --primary-600:#4338ca;
          --accent:#c9a86a;    /* champagne gold */
          --accent-600:#b8925a;
          --success:#16a34a;
          --warning:#f59e0b;
          --danger:#dc2626;
          --line:#eef2f7;
        }
        /* Bootstrap variable overrides (where respected) */
        :root{ --bs-primary: var(--primary); --bs-link-color: var(--primary); }

        body { background: radial-gradient(1200px 700px at 10% -10%, #ecebfd 0%, transparent 40%),
                            radial-gradient(900px 600px at 110% 10%, #fff3e0 0%, transparent 35%),
                            var(--paper); color: var(--ink-900); }
        .app { display: grid; grid-template-columns: 280px 1fr; min-height: 100vh; }
        @media (max-width: 992px) {
            .app { grid-template-columns: 1fr; }
            #sidebar { position: fixed; inset: 0 30% 0 0; transform: translateX(-100%); transition: transform .2s ease; z-index: 1040; }
            #sidebar.open { transform: translateX(0); }
        }
        .content { padding: 28px 32px 44px; }
        .page-header { display: flex; align-items: center; justify-content: space-between; gap: var(--space-3); margin-bottom: var(--space-4); }
        .page-header h3 { margin: 0 0 var(--space-1) 0; font-weight: 700; letter-spacing:.1px }
        .breadcrumb .breadcrumb-item + .breadcrumb-item::before { color: var(--ink-500); }

        .section { margin-top: var(--space-5); }
        .card { border: none; border-radius: var(--radius); background: var(--card); box-shadow: 0 8px 28px rgba(20, 24, 40, .08); overflow: hidden; }
        .card-header { background: linear-gradient(180deg, rgba(79,70,229,.06), rgba(79,70,229,0)); border-bottom: 1px solid var(--line); border-radius: var(--radius) var(--radius) 0 0; padding: var(--space-3) var(--space-4); }
        .card-body { padding: var(--space-4); }
        .card-footer { background: #fff; border-top: 1px solid var(--line); padding: var(--space-3) var(--space-4); border-radius: 0 0 var(--radius) var(--radius); }

        /* KPI */
        .kpi .icon { font-size: 28px; opacity: .9; color: var(--accent-600); }
        .kpi .value { line-height: 1; font-weight: 700; }
        .kpi .muted { color: var(--ink-500); }

        /* Tables */
        .table-tight td, .table-tight th { padding: .7rem .95rem; }
        .table thead th { font-weight: 600; color: var(--ink-700); border-bottom-color: var(--line); }
        .table-hover tbody tr:hover { background: rgba(203, 213, 225, .18); }

        /* Badges refined */
        .badge.bg-success{ background-color: var(--success) !important; }
        .badge.bg-warning{ background-color: var(--warning) !important; }
        .badge.bg-danger{ background-color: var(--danger) !important; }
        .badge.bg-secondary{ background-color: #cbd5e1 !important; color:#0f172a; }

        /* Buttons */
        .btn-outline-primary{ border-color: var(--primary-600); color: var(--primary-600); }
        .btn-outline-primary:hover{ background: var(--primary-600); color:#fff; }
        .btn-outline-dark{ border-color: var(--ink-700); color: var(--ink-700); }
        .btn-outline-dark:hover{ background: var(--ink-700); color:#fff; }
        .btn-outline-warning{ border-color: var(--accent-600); color: var(--accent-600); }
        .btn-outline-warning:hover{ background: var(--accent-600); color:#fff; }
        .btn-outline-danger{ border-color: var(--danger); color: var(--danger); }
        .btn-outline-danger:hover{ background: var(--danger); color:#fff; }
        .btn-outline-success{ border-color: var(--success); color: var(--success); }
        .btn-outline-success:hover{ background: var(--success); color:#fff; }
        .btn-outline-secondary{ border-color: var(--ink-500); color: var(--ink-700); }
        .btn-outline-secondary:hover{ background: var(--ink-700); color:#fff; }

        /* Small helpers */
        .muted { color: var(--ink-500); }
    </style>
</head>
<body>

<!-- ===== Header ===== -->
<jsp:include page="/layouts/Header.jsp"/>

<c:set var="u" value="${sessionScope.user}"/>

<div class="app">

    <!-- ===== Sidebar dùng chung ===== -->
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <!-- ===== Main content ===== -->
    <main class="content">

        <div class="page-header">
            <div>
                <h3>Admin Dashboard</h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Admin</li>
                    </ol>
                </nav>
            </div>
            <button class="btn btn-outline-secondary d-lg-none" onclick="toggleSidebar()"><i class="bi bi-list"></i> Menu</button>
        </div>

        <!-- Flash message -->
        <c:if test="${not empty sessionScope.flash}">
            <div class="alert alert-success d-flex align-items-start mb-0">
                <i class="bi bi-check-circle me-2"></i>
                <div>${sessionScope.flash}</div>
            </div>
            <c:remove var="flash" scope="session"/>
        </c:if>

        <!-- ===== KPIs nhanh ===== -->
        <div class="section">
          <div class="row g-4">
              <div class="col-6 col-lg-3">
                  <div class="card kpi">
                      <div class="card-body d-flex justify-content-between align-items-center">
                          <div>
                              <div class="muted">Đơn hôm nay</div>
                              <div class="h3 value mb-1">${empty kpi.todayOrders ? 128 : kpi.todayOrders}</div>
                              <div class="small ${empty kpi.orderDelta || kpi.orderDelta >= 0 ? 'text-success' : 'text-danger'}">
                                  ${empty kpi.orderDelta ? '+12' : (kpi.orderDelta >= 0 ? '+' : '')}${empty kpi.orderDelta ? '' : kpi.orderDelta}% so với hôm qua
                              </div>
                          </div>
                          <i class="bi bi-receipt icon"></i>
                      </div>
                  </div>
              </div>
              <div class="col-6 col-lg-3">
                  <div class="card kpi">
                      <div class="card-body d-flex justify-content-between align-items-center">
                          <div>
                              <div class="muted">Bàn đang phục vụ</div>
                              <div class="h3 value mb-1">${empty kpi.activeTables ? 23 : kpi.activeTables}</div>
                              <div class="small muted">Khu vực: ${empty kpi.servingAreas ? 'Tầng 1-2' : kpi.servingAreas}</div>
                          </div>
                          <i class="bi bi-table icon"></i>
                      </div>
                  </div>
              </div>
              <div class="col-6 col-lg-3">
                  <div class="card kpi">
                      <div class="card-body d-flex justify-content-between align-items-center">
                          <div>
                              <div class="muted">Doanh thu hôm nay</div>
                              <div class="h3 value mb-1">${empty kpi.todayRevenue ? '$2,430' : kpi.todayRevenue}</div>
                              <div class="small muted">Đã gồm VAT</div>
                          </div>
                          <i class="bi bi-currency-dollar icon"></i>
                      </div>
                  </div>
              </div>
              <div class="col-6 col-lg-3">
                  <div class="card kpi">
                      <div class="card-body d-flex justify-content-between align-items-center">
                          <div>
                              <div class="muted">Đặt bàn sắp tới</div>
                              <div class="h3 value mb-1">${empty kpi.upcomingReservations ? 7 : kpi.upcomingReservations}</div>
                              <div class="small muted">Trong 2 giờ tới</div>
                          </div>
                          <i class="bi bi-calendar-event icon"></i>
                      </div>
                  </div>
              </div>
          </div>
        </div>

        <!-- ===== Biểu đồ & Thao tác nhanh ===== -->
        <div class="section">
          <div class="row g-4">
              <div class="col-12 col-lg-8">
                  <div class="card">
                      <div class="card-header d-flex justify-content-between align-items-center">
                          <h5 class="mb-0"><i class="bi bi-graph-up-arrow me-2"></i>Xu hướng doanh thu 7 ngày</h5>
                          <span class="small muted">Cập nhật: <span id="chartUpdatedAt"></span></span>
                      </div>
                      <div class="card-body">
                          <canvas id="revenueChart" height="120"></canvas>
                      </div>
                  </div>
              </div>
              <div class="col-12 col-lg-4">
                  <div class="card">
                      <div class="card-header">
                          <h5 class="mb-0"><i class="bi bi-lightning-charge me-2"></i>Thao tác nhanh</h5>
                      </div>
                      <div class="card-body d-flex flex-wrap gap-2">
                          <c:if test="${u.roleName == 'ADMIN'}">
                              <a href="<c:url value='/staff'/>" class="btn btn-outline-primary"><i class="bi bi-people me-1"></i> Nhân sự</a>
                              <a href="<c:url value='/inventory'/>" class="btn btn-outline-warning"><i class="bi bi-box-seam me-1"></i> Kho hàng</a>
                              <a href="<c:url value='/reports'/>" class="btn btn-outline-dark"><i class="bi bi-graph-up me-1"></i> Báo cáo</a>
                          </c:if>
                          <c:if test="${u.roleName == 'CHEF' || u.roleName == 'BEP' || u.roleName == 'ĐẦU BẾP'}">
                              <a href="<c:url value='/kitchen/orders'/>" class="btn btn-outline-danger"><i class="bi bi-fire me-1"></i> Đơn chờ bếp</a>
                              <a href="<c:url value='/inventory/ingredients'/>" class="btn btn-outline-secondary"><i class="bi bi-basket me-1"></i> Nguyên liệu</a>
                          </c:if>
                          <c:if test="${u.roleName == 'WAITER' || u.roleName == 'PHUC VU'}">
                              <a href="<c:url value='/tables/my'/>" class="btn btn-outline-success"><i class="bi bi-grid-3x3-gap me-1"></i> Bàn của tôi</a>
                              <a href="<c:url value='/orders/my'/>" class="btn btn-outline-primary"><i class="bi bi-bag-check me-1"></i> Đơn của tôi</a>
                          </c:if>
                      </div>
                  </div>
              </div>
          </div>
        </div>

        <!-- ===== Đơn gần đây ===== -->
        <div class="section">
          <div class="row g-4">
              <div class="col-12">
                  <div class="card h-100">
                      <div class="card-header d-flex justify-content-between align-items-center">
                          <h5 class="mb-0"><i class="bi bi-receipt-cutoff me-2"></i>Đơn gần đây</h5>
                          <a href="<c:url value='/orders'/>" class="btn btn-sm btn-outline-secondary">Xem tất cả</a>
                      </div>
                      <div class="card-body p-0">
                          <div class="table-responsive">
                              <table class="table table-hover mb-0 table-tight">
                                  <thead class="table-light">
                                  <tr>
                                      <th>#</th>
                                      <th>Khách</th>
                                      <th>Bàn</th>
                                      <th>Tổng</th>
                                      <th>Trạng thái</th>
                                      <th>Thời gian</th>
                                  </tr>
                                  </thead>
                                  <tbody>
                                  <c:choose>
                                      <c:when test="${not empty recentOrders}">
                                          <c:forEach var="o" items="${recentOrders}">
                                              <tr>
                                                  <td>${o.id}</td>
                                                  <td>${o.customerName}</td>
                                                  <td>${o.tableName}</td>
                                                  <td>${o.totalFormatted}</td>
                                                  <td>
                                                      <span class="badge ${o.status == 'PAID' ? 'bg-success' : (o.status == 'PENDING' ? 'bg-warning text-dark' : 'bg-secondary')}">${o.status}</span>
                                                  </td>
                                                  <td>${o.createdAtFormatted}</td>
                                              </tr>
                                          </c:forEach>
                                      </c:when>
                                      <c:otherwise>
                                          <tr><td>1001</td><td>Nguyễn Văn A</td><td>B01</td><td>$45.00</td><td><span class="badge bg-success">PAID</span></td><td>09:30</td></tr>
                                          <tr><td>1002</td><td>Trần Thị B</td><td>T02</td><td>$72.50</td><td><span class="badge bg-warning text-dark">PENDING</span></td><td>10:10</td></tr>
                                          <tr><td>1003</td><td>Lê Văn C</td><td>B05</td><td>$120.00</td><td><span class="badge bg-success">PAID</span></td><td>11:00</td></tr>
                                      </c:otherwise>
                                  </c:choose>
                                  </tbody>
                              </table>
                          </div>
                      </div>
                  </div>
              </div>
          </div>
        </div>

        <!-- ===== Đặt bàn sắp tới & Tồn kho thấp ===== -->
        <div class="section">
          <div class="row g-4">
              <div class="col-12 col-lg-6">
                  <div class="card h-100">
                      <div class="card-header d-flex justify-content-between align-items-center">
                          <h5 class="mb-0"><i class="bi bi-calendar-week me-2"></i>Đặt bàn sắp tới</h5>
                          <a href="<c:url value='/reservations'/>" class="btn btn-sm btn-outline-secondary">Quản lý</a>
                      </div>
                      <div class="card-body p-0">
                          <div class="table-responsive">
                              <table class="table table-hover mb-0 table-tight">
                                  <thead class="table-light">
                                  <tr>
                                      <th>Giờ</th>
                                      <th>Khách</th>
                                      <th>Bàn</th>
                                      <th>SL</th>
                                  </tr>
                                  </thead>
                                  <tbody>
                                  <c:choose>
                                      <c:when test="${not empty upcomingReservations}">
                                          <c:forEach var="r" items="${upcomingReservations}">
                                              <tr>
                                                  <td>${r.timeFormatted}</td>
                                                  <td>${r.customerName}</td>
                                                  <td>${r.tableName}</td>
                                                  <td>${r.partySize}</td>
                                              </tr>
                                          </c:forEach>
                                      </c:when>
                                      <c:otherwise>
                                          <tr><td>12:30</td><td>Phạm Thu D</td><td>T03</td><td>4</td></tr>
                                          <tr><td>13:00</td><td>Đặng Minh E</td><td>B07</td><td>2</td></tr>
                                          <tr><td>13:15</td><td>Ngô Hải F</td><td>T01</td><td>6</td></tr>
                                      </c:otherwise>
                                  </c:choose>
                                  </tbody>
                              </table>
                          </div>
                      </div>
                  </div>
              </div>

              <div class="col-12 col-lg-6">
                  <div class="card h-100">
                      <div class="card-header d-flex justify-content-between align-items-center">
                          <h5 class="mb-0"><i class="bi bi-exclamation-triangle me-2"></i>Tồn kho thấp</h5>
                          <a href="<c:url value='/inventory'/>" class="btn btn-sm btn-outline-secondary">Tới kho</a>
                      </div>
                      <div class="card-body p-0">
                          <div class="table-responsive">
                              <table class="table table-hover mb-0 table-tight">
                                  <thead class="table-light">
                                  <tr>
                                      <th>Mã</th>
                                      <th>Tên hàng</th>
                                      <th>Tồn</th>
                                      <th>ĐVT</th>
                                      <th>Mức tối thiểu</th>
                                  </tr>
                                  </thead>
                                  <tbody>
                                  <c:choose>
                                      <c:when test="${not empty lowStocks}">
                                          <c:forEach var="i" items="${lowStocks}">
                                              <tr>
                                                  <td>${i.code}</td>
                                                  <td>${i.name}</td>
                                                  <td class="text-danger fw-semibold">${i.qty}</td>
                                                  <td>${i.uom}</td>
                                                  <td>${i.minQty}</td>
                                              </tr>
                                          </c:forEach>
                                      </c:when>
                                      <c:otherwise>
                                          <tr><td>NL-001</td><td>Thịt bò</td><td class="text-danger fw-semibold">3</td><td>kg</td><td>5</td></tr>
                                          <tr><td>NL-014</td><td>Hành tây</td><td class="text-danger fw-semibold">10</td><td>kg</td><td>15</td></tr>
                                          <tr><td>NL-023</td><td>Sốt cà chua</td><td class="text-danger fw-semibold">2</td><td>chai</td><td>6</td></tr>
                                      </c:otherwise>
                                  </c:choose>
                                  </tbody>
                              </table>
                          </div>
                      </div>
                  </div>
              </div>
          </div>
        </div>

    </main>
</div>

<!-- ===== Footer ===== -->
<jsp:include page="/layouts/Footer.jsp"/>

<!-- ===== JS ===== -->
<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- Chart.js (tuỳ chọn) -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
  function toggleSidebar(){
    var el = document.getElementById('sidebar');
    if(el){ el.classList.toggle('open'); }
  }

  // Vẽ biểu đồ với fallback demo nếu thiếu dữ liệu từ server
  (function(){
    var ctx = document.getElementById('revenueChart');
    if(!ctx) return;
    var labels = ${empty kpi.revenue7dLabels ? '[]' : kpi.revenue7dLabels};
    var values = ${empty kpi.revenue7dValues ? '[]' : kpi.revenue7dValues};
    if(!Array.isArray(labels) || labels.length === 0){
      labels = ['T2','T3','T4','T5','T6','T7','CN'];
    }
    if(!Array.isArray(values) || values.length === 0){
      values = [320, 410, 380, 450, 520, 610, 540];
    }
    document.getElementById('chartUpdatedAt').textContent = new Date().toLocaleTimeString();
    try {
      new Chart(ctx, {
        type: 'line',
        data: {
          labels: labels,
          datasets: [{ label: 'Doanh thu', data: values, fill: false, tension: 0.3 }]
        },
        options: { responsive: true, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
      });
    } catch(e) { console.error(e); }
  })();
</script>

</body>
</html>
