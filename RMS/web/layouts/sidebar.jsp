<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
  Reusable sidebar for all pages.
  Requirements (set in each including page or a base filter):
   - request.setAttribute("page", "admin" | "orders" | "reservations" | "menu" | ...)
   - sessionScope.user (u) must exist after login
   - Optional: staffList (List<UserLite>) to render staff section (ADMIN only by default)
   - Optional: pendingKitchenCount, etc. for role KPIs

  Include with: <jsp:include page="/layouts/sidebar.jsp"/>
--%>

<c:set var="u" value="${sessionScope.user}"/>

<style>
  /* You can move these styles to /css/style.css */
  .sidebar { background: #111827; color: #cbd5e1; display: flex; flex-direction: column; min-height: 100%; }
  .sidebar .brand { padding: 16px 20px; border-bottom: 1px solid rgba(255,255,255,.08); }
  .sidebar .brand .title { color: #fff; font-weight: 700; letter-spacing: .3px; }
  .sidebar .section-title { font-size: 12px; text-transform: uppercase; letter-spacing: .08em; color: #9ca3af; padding: 16px 20px 8px; }
  .sidebar .menu { list-style: none; margin: 0; padding: 0; }
  .sidebar .menu a { display: flex; align-items: center; gap: 10px; padding: 10px 16px; margin: 4px 8px; border-radius: 10px; color: #e5e7eb; text-decoration: none; }
  .sidebar .menu a:hover, .sidebar .menu a.active { background: #1f2937; color: #fff; }
  .sidebar .menu .badge { margin-left: auto; }
  .sidebar .staff-list { padding: 8px 12px 16px; overflow-y: auto; max-height: 40vh; }
  .sidebar .staff-item { display: flex; align-items: center; gap: 10px; padding: 8px; border-radius: 10px; }
  .sidebar .staff-item:hover { background: rgba(255,255,255,.05); }
  .sidebar .staff-item img { width: 32px; height: 32px; object-fit: cover; border-radius: 50%; }
  .sidebar .role-pill { font-size: 11px; padding: 2px 8px; border-radius: 999px; background: #374151; color: #d1d5db; }
</style>

<aside class="sidebar">
  <!-- Brand -->
  <div class="brand d-flex align-items-center justify-content-between">
    <div>
      <div class="title">Bảng điều khiển</div>
      <div class="small text-muted">Xin chào, <span class="text-white fw-semibold"><c:out value='${empty u.fullName ? u.username : u.fullName}'/></span></div>
    </div>
    <button class="btn btn-sm btn-outline-light d-lg-none" onclick="if(window.toggleSidebar){toggleSidebar();}"><i class="bi bi-x"></i></button>
  </div>

  <!-- Common menu -->
  <div class="section-title">Chung</div>
  <ul class="menu">
    <li>
      <a class="${page == 'home' ? 'active' : ''}" href="<c:url value='/'/>"><i class="bi bi-house"></i>Trang chủ</a>
    </li>
    <li>
      <a class="${page == 'orders' ? 'active' : ''}" href="<c:url value='/orders'/>"><i class="bi bi-receipt-cutoff"></i>Đơn hàng</a>
    </li>
    <li>
      <a class="${page == 'reservations' ? 'active' : ''}" href="<c:url value='/reservations'/>"><i class="bi bi-calendar-event"></i>Đặt bàn</a>
    </li>
    <li>
      <a class="${page == 'menu' ? 'active' : ''}" href="<c:url value='/menu'/>"><i class="bi bi-journal-text"></i>Thực đơn</a>
    </li>
  </ul>

  <!-- Role-based menu -->
  <div class="section-title">Theo vai trò</div>
  <ul class="menu">
    <!-- ADMIN -->
    <c:if test="${u.roleName == 'Manager'}">
      <li><a class="${page == 'staff' ? 'active' : ''}" href="staff-management"><i class="bi bi-people"></i>Quản lý nhân viên</a></li>
      <li><a class="${page == 'shifts' ? 'active' : ''}" href="<c:url value='/shifts'/>"><i class="bi bi-clock-history"></i>Phân ca</a></li>
      <li><a class="${page == 'inventory' ? 'active' : ''}" href="<c:url value='/inventory'/>"><i class="bi bi-box-seam"></i>Kho hàng</a></li>
      <li><a class="${page == 'reports' ? 'active' : ''}" href="<c:url value='/reports'/>"><i class="bi bi-graph-up"></i>Báo cáo</a></li>
      <li><a class="${page == 'settings' ? 'active' : ''}" href="<c:url value='/settings'/>"><i class="bi bi-gear"></i>Cấu hình</a></li>
    </c:if>

    <!-- CHEF / BẾP -->
    <c:if test="${u.roleName == 'CHEF' || u.roleName == 'BEP' || u.roleName == 'ĐẦU BẾP'}">
      <li>
        <a class="${page == 'kitchen-orders' ? 'active' : ''}" href="<c:url value='/kitchen/orders'/>">
          <i class="bi bi-fire"></i>Đơn chờ bếp
          <span class="badge bg-danger">${empty pendingKitchenCount ? 0 : pendingKitchenCount}</span>
        </a>
      </li>
      <li><a class="${page == 'ingredients' ? 'active' : ''}" href="<c:url value='/inventory/ingredients'/>"><i class="bi bi-basket"></i>Nguyên liệu tồn</a></li>
      <li><a class="${page == 'top-dishes' ? 'active' : ''}" href="<c:url value='/menu/top-dishes'/>"><i class="bi bi-star"></i>Món bán chạy</a></li>
    </c:if>

    <!-- WAITER / PHỤC VỤ -->
    <c:if test="${u.roleName == 'WAITER' || u.roleName == 'PHUC VU'}">
      <li><a class="${page == 'my-tables' ? 'active' : ''}" href="<c:url value='/tables/my'/>"><i class="bi bi-grid-3x3-gap"></i>Bàn của tôi</a></li>
      <li><a class="${page == 'my-orders' ? 'active' : ''}" href="<c:url value='/orders/my'/>"><i class="bi bi-bag-check"></i>Đơn của tôi</a></li>
      <li><a class="${page == 'customer-checkin' ? 'active' : ''}" href="<c:url value='/customers/checkin'/>"><i class="bi bi-person-check"></i>Check-in khách</a></li>
    </c:if>
  </ul>

  <!-- Staff list (visible to ADMIN; show to others if you want) -->
  <c:if test="${u.roleName == 'Manager'}">
    <div class="section-title">Nhân viên</div>
    <div class="staff-list">
      <c:choose>
        <c:when test="${not empty staffList}">
          <c:forEach var="s" items="${staffList}">
            <div class="staff-item">
              <img src="<c:url value='${empty s.avatarUrl ? "/img/default-avatar.jpg" : s.avatarUrl}'/>" alt="avatar">
              <div class="flex-grow-1">
                <div class="d-flex align-items-center gap-2">
                  <span class="text-white fw-semibold">${empty s.fullName ? s.username : s.fullName}</span>
                  <span class="role-pill">${s.roleName}</span>
                </div>
                <div class="small text-muted">${empty s.phone ? s.email : s.phone}</div>
              </div>
              <span class="badge ${s.accountStatus == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">${s.accountStatus}</span>
            </div>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <div class="px-3 text-muted small">Chưa có dữ liệu nhân viên. Thêm mới trong <a class="link-light" href="<c:url value='/staff'/>">Quản lý nhân viên</a>.</div>
        </c:otherwise>
      </c:choose>
    </div>
  </c:if>
</aside>
