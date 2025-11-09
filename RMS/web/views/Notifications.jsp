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
    <title>Thông báo | Restoran</title>
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
        
        /* Notification styles */
        .notification-item { transition: background-color 0.2s; }
        .notification-item:hover { background-color: rgba(79, 70, 229, 0.05); }
        .notification-item.read { opacity: 0.7; }
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
                <h3>Thông báo</h3>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                        <li class="breadcrumb-item"><a href="<c:url value='/admin'/>">Admin</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Thông báo</li>
                    </ol>
                </nav>
            </div>
            <div style="display:flex; gap:.75rem; align-items:center;">
                <a href="<c:url value='/admin'/>" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-1"></i> Quay lại
                </a>
                <button class="btn btn-outline-secondary d-lg-none" onclick="toggleSidebar()"><i class="bi bi-list"></i> Menu</button>
            </div>
        </div>

        <!-- ===== Danh sách thông báo ===== -->
        <div class="section">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bi bi-bell me-2"></i>Tất cả thông báo</h5>
                    <div>
                        <c:if test="${not empty unreadCount && unreadCount > 0}">
                            <span class="badge bg-danger me-2">${unreadCount} chưa đọc</span>
                        </c:if>
                    </div>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty notifications && not empty notifications[0]}">
                            <div class="list-group list-group-flush">
                                <c:forEach var="notif" items="${notifications}">
                                    <c:url var="editUrl" value="/menu-management">
                                        <c:param name="action" value="edit"/>
                                        <c:param name="id" value="${notif.menuItemId}"/>
                                    </c:url>
                                    <c:url var="notifUrl" value="/notifications/${notif.notificationId}/read">
                                        <c:param name="redirect" value="${editUrl}"/>
                                    </c:url>
                                    <a href="${notifUrl}" 
                                       class="list-group-item list-group-item-action notification-item ${notif.status == 'READ' ? 'read' : ''}">
                                        <div class="d-flex w-100 justify-content-between align-items-start">
                                            <div class="flex-grow-1">
                                                <div class="d-flex align-items-center mb-2">
                                                    <h6 class="mb-0 me-2">${notif.title}</h6>
                                                    <c:if test="${notif.status == 'UNREAD'}">
                                                        <span class="badge bg-danger">Mới</span>
                                                    </c:if>
                                                </div>
                                                <p class="mb-1">${notif.message}</p>
                                                <c:if test="${not empty notif.menuItemName}">
                                                    <small class="text-muted">
                                                        <i class="bi bi-utensils me-1"></i>Món: ${notif.menuItemName}
                                                        <c:if test="${not empty notif.tableNumber}">
                                                            | <i class="bi bi-table me-1"></i>Bàn: ${notif.tableNumber}
                                                        </c:if>
                                                    </small>
                                                </c:if>
                                            </div>
                                            <small class="text-muted ms-3">${notif.createdAt}</small>
                                        </div>
                                    </a>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="list-group list-group-flush">
                                <div class="list-group-item text-center text-muted py-5">
                                    <i class="bi bi-bell-slash fs-1 d-block mb-3"></i>
                                    <p class="mb-0 fs-5">Không có thông báo nào</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
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

<script>
  function toggleSidebar(){
    var el = document.getElementById('sidebar');
    if(el){ el.classList.toggle('open'); }
  }
</script>

</body>
</html>

