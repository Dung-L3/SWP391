<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
  request.setAttribute("page", "audit");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Nhật ký hệ thống - RMS</title>
  <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <style>
    .filter-card { background:#fff; border-radius:12px; border:1px solid #e5e7eb; }
    .table thead th { white-space: nowrap; }
    .log-json { max-width: 480px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  </style>
</head>
<body>
  <jsp:include page="/layouts/Header.jsp"/>
  <div class="container-fluid">
    <div class="row">
      <div class="col-md-2 bg-dark text-white min-vh-100 p-0">
        <jsp:include page="/layouts/sidebar.jsp"/>
      </div>
      <div class="col-md-10">
        <div class="container-fluid py-4">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <div>
              <h3 class="mb-0">Nhật ký hệ thống</h3>
              <small class="text-muted">Theo dõi thao tác trên hệ thống</small>
            </div>
          </div>

          <div class="filter-card p-3 mb-3">
            <form method="get" class="row g-2">
              <div class="col-md-3">
                <input type="text" name="q" value="${q}" class="form-control" placeholder="Tìm kiếm (action, bảng, user)">
              </div>
              <div class="col-md-2">
                <input type="text" name="actionFilter" value="${actionFilter}" class="form-control" placeholder="Action">
              </div>
              <div class="col-md-2">
                <input type="text" name="tableFilter" value="${tableFilter}" class="form-control" placeholder="Bảng">
              </div>
              <div class="col-md-2">
                <input type="date" name="from" value="${from}" class="form-control">
              </div>
              <div class="col-md-2">
                <input type="date" name="to" value="${to}" class="form-control">
              </div>
              <div class="col-md-1 d-grid">
                <button class="btn btn-primary"><i class="bi bi-search"></i></button>
              </div>
            </form>
          </div>

          <div class="card">
            <div class="table-responsive">
              <table class="table table-striped align-middle mb-0">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Thời gian</th>
                    <th>Người dùng</th>
                    <th>Action</th>
                    <th>Bảng</th>
                    <th>Record</th>
                    <th>IP</th>
                    <th>Old</th>
                    <th>New</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="l" items="${logs}">
                    <tr>
                      <td>${l.logId}</td>
                      <td>${l.timestamp}</td>
                      <td><span class="badge bg-secondary">${empty l.username ? ('#'+l.userId) : l.username}</span></td>
                      <td>${l.action}</td>
                      <td>${l.tableName}</td>
                      <td>${l.recordId}</td>
                      <td>${l.ipAddress}</td>
                      <td><code class="log-json">${l.oldValues}</code></td>
                      <td><code class="log-json">${l.newValues}</code></td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty logs}">
                    <tr><td colspan="9" class="text-center text-muted py-4">Không có bản ghi</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>

          <nav class="mt-3">
            <ul class="pagination">
              <c:forEach begin="1" end="${totalPages}" var="p">
                <li class="page-item ${p==currentPage? 'active':''}">
                  <a class="page-link" href="?page=${p}&size=${size}&q=${q}&actionFilter=${actionFilter}&tableFilter=${tableFilter}&from=${from}&to=${to}">${p}</a>
                </li>
              </c:forEach>
            </ul>
          </nav>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
