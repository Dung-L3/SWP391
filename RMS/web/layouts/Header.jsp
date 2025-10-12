<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Determine overlayNav -->
<c:choose>
  <c:when test="${not empty requestScope.overlayNav}">
    <c:set var="overlayNav" value="${requestScope.overlayNav}" />
  </c:when>
  <c:otherwise>
    <c:set var="overlayNav" value="false" />
  </c:otherwise>
</c:choose>

<div class="container-xxl p-0">
  <nav id="mainNav"
       data-overlay="${overlayNav}"
       class="navbar navbar-expand-lg
       ${overlayNav ? 
          'navbar-dark position-absolute top-0 start-0 w-100 bg-transparent' :
          'navbar-dark bg-dark sticky-top'} 
       px-4 px-lg-5 py-3 py-lg-0">

    <!-- Brand -->
    <a href="<c:url value='/'/>" class="navbar-brand p-0">
      <h1 class="text-primary m-0"><i class="fa fa-utensils me-3"></i>Restoran</h1>
    </a>

    <!-- Toggler -->
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarCollapse">
      <span class="fa fa-bars"></span>
    </button>

    <!-- Nav links -->
    <div class="collapse navbar-collapse" id="navbarCollapse">
      <div class="navbar-nav ms-auto py-0 pe-4">
        <a href="<c:url value='/'/>" class="nav-item nav-link ${page=='home' ? 'active' : ''}">Home</a>
        <a href="<c:url value='/about.jsp'/>" class="nav-item nav-link ${page=='about' ? 'active' : ''}">About</a>
        <a href="<c:url value='/service.jsp'/>" class="nav-item nav-link ${page=='service' ? 'active' : ''}">Service</a>
        <a href="<c:url value='/menu.jsp'/>" class="nav-item nav-link ${page=='menu' ? 'active' : ''}">Menu</a>

        <div class="nav-item dropdown">
          <a href="#" class="nav-link dropdown-toggle ${page=='pages' ? 'active' : ''}" data-bs-toggle="dropdown">Pages</a>
          <div class="dropdown-menu m-0">
            <a href="<c:url value='/booking.jsp'/>" class="dropdown-item">Booking</a>
            <a href="<c:url value='/team.jsp'/>" class="dropdown-item">Our Team</a>
            <a href="<c:url value='/testimonial.jsp'/>" class="dropdown-item">Testimonial</a>
          </div>
        </div>

        <a href="<c:url value='/contact.jsp'/>" class="nav-item nav-link ${page=='contact' ? 'active' : ''}">Contact</a>
      </div>

      <!-- Book Button -->
      <a href="<c:url value='/booking.jsp'/>" class="btn btn-primary py-2 px-4 me-2">Book A Table</a>

      <!-- Auth -->
      <c:choose>
        <c:when test="${empty sessionScope.user}">
          <a href="<c:url value='/LoginServlet'/>" class="btn btn-outline-light d-flex align-items-center">
            <i class="bi bi-person-circle me-2"></i> Login
          </a>
        </c:when>

        <c:otherwise>
          <c:set var="u" value="${sessionScope.user}" />
          <c:set var="displayName"
                 value="${empty u.fullName
                          ? (empty u.firstName && empty u.lastName ? u.username : (u.firstName + ' ' + u.lastName))
                          : u.fullName}" />

          <!-- Dropdown User Menu -->
          <div class="dropdown">
            <a class="d-flex align-items-center text-white text-decoration-none dropdown-toggle"
               href="#" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
              <img src="<c:url value='${empty u.avatarUrl ? "/img/default-avatar.jpg" : u.avatarUrl}'/>"
                   alt="Avatar"
                   class="rounded-circle me-2"
                   style="width:36px;height:36px;object-fit:cover;border:2px solid rgba(255,255,255,.25)">
              <span class="fw-semibold"><c:out value="${displayName}"/></span>
            </a>

            <ul class="dropdown-menu dropdown-menu-end shadow" aria-labelledby="userDropdown">
              <li class="px-3 py-2">
                <div class="d-flex align-items-center">
                  <img src="<c:url value='${empty u.avatarUrl ? "/img/default-avatar.jpg" : u.avatarUrl}'/>"
                       class="rounded-circle me-2"
                       style="width:32px;height:32px;object-fit:cover;">
                  <div>
                    <div class="fw-semibold"><c:out value="${displayName}"/></div>
                    <small class="text-muted"><c:out value="${u.email}"/></small>
                  </div>
                </div>
              </li>
              <li><hr class="dropdown-divider"></li>

              <!-- Role-based menu -->
              <c:choose>
                <c:when test="${u.roleName eq 'Manager'}">
                  <li><a class="dropdown-item" href="<c:url value='/admin'/>"><i class="bi bi-speedometer2 me-2"></i>Admin Dashboard</a></li>
                  <li><a class="dropdown-item" href="<c:url value='/reports'/>"><i class="bi bi-graph-up me-2"></i>Reports</a></li>
                </c:when>
                <c:when test="${u.roleName eq 'Receptionist'}">
                  <li><a class="dropdown-item" href="<c:url value='/reservations'/>"><i class="bi bi-calendar-check me-2"></i>Reservations</a></li>
                </c:when>
                <c:when test="${u.roleName eq 'Waiter'}">
                  <li><a class="dropdown-item" href="<c:url value='/orders'/>"><i class="bi bi-receipt-cutoff me-2"></i>Table Orders</a></li>
                </c:when>
                <c:when test="${u.roleName eq 'Chef'}">
                  <li><a class="dropdown-item" href="<c:url value='/kitchen'/>"><i class="bi bi-fire me-2"></i>Kitchen</a></li>
                </c:when>
                <c:when test="${u.roleName eq 'Cashier'}">
                  <li><a class="dropdown-item" href="<c:url value='/billing'/>"><i class="bi bi-cash-coin me-2"></i>Billing</a></li>
                </c:when>
              </c:choose>

              <!-- Profile & Edit Profile -->
              <li><a class="dropdown-item" href="<c:url value='/views/profile.jsp'/>"><i class="bi bi-person me-2"></i>Profile</a></li>
              <li><a class="dropdown-item" href="<c:url value='/views/profile-edit.jsp'/>"><i class="bi bi-pencil-square me-2"></i>Edit Profile</a></li>

              <li><hr class="dropdown-divider"></li>
              <li>
                <a class="dropdown-item text-danger" href="<c:url value='/logout'/>">
                  <i class="bi bi-box-arrow-right me-2"></i>Logout
                </a>
              </li>
            </ul>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </nav>
</div>
