<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Theo dõi đơn hàng | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <!-- Fonts & Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Bootstrap & Template CSS -->
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&display=swap" rel="stylesheet">
    <style>
        .status-badge { font-weight:600; }
        .track-card { border-radius: .5rem; }
        .track-header .h5 { margin-bottom: 0.25rem; }
        .table th, .table td { vertical-align: middle; }
        .no-items { text-align:center; padding: 2rem 0; color: #6c757d; }
    </style>
</head>
<body>

    <%@ include file="/layouts/Header.jsp" %>

    <section class="container-xxl py-5">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card shadow-sm">
                        <div class="card-body">
                            <h2 class="mb-3"><i class="bi bi-clock-history text-primary"></i> Theo dõi đơn hàng</h2>

                            <form method="get" action="${pageContext.request.contextPath}/track-order" class="row g-2 mb-4">
                                <div class="col-md-8">
                                    <input id="code" name="code" type="text" class="form-control" value="${param.code != null ? param.code : ''}" placeholder="Nhập mã đơn (VD: ORD163...)" />
                                </div>
                                <div class="col-md-4 d-grid">
                                    <button type="submit" class="btn btn-primary">Tra cứu</button>
                                </div>
                            </form>

                            <c:if test="${not empty errorMessage}">
                                <div class="alert alert-warning">${errorMessage}</div>
                            </c:if>

                            <c:if test="${not empty order}">
                                <div class="mb-3 track-header">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <div class="h5 mb-1">Mã đơn: <strong>${order.orderCode}</strong></div>
                                            <div class="text-muted">Trạng thái:
                                                <c:choose>
                                                    <c:when test="${order.status == 'OPEN'}">
                                                        <span class="badge bg-primary">Mới</span>
                                                    </c:when>
                                                    <c:when test="${order.status == 'SENT_TO_KITCHEN' || order.status == 'COOKING'}">
                                                        <span class="badge bg-warning text-dark">Đang chế biến</span>
                                                    </c:when>
                                                    <c:when test="${order.status == 'PARTIAL_READY' || order.status == 'READY'}">
                                                        <span class="badge bg-success">Sẵn sàng</span>
                                                    </c:when>
                                                    <c:when test="${order.status == 'SERVED'}">
                                                        <span class="badge bg-secondary">Đã giao</span>
                                                    </c:when>
                                                    <c:when test="${order.status == 'CANCELLED'}">
                                                        <span class="badge bg-danger">Đã hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary"><c:out value="${order.status}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div class="text-end text-muted">Mở: <c:out value="${openedAtFormatted != null ? openedAtFormatted : order.openedAt}"/></div>
                                    </div>
                                </div>

                                <div class="table-responsive">
                                    <table class="table table-hover align-middle">
                                        <thead>
                                            <tr>
                                                <th>Món</th>
                                                <th class="text-center">Số lượng</th>
                                                <th class="text-center">Trạng thái</th>
                                                <th class="text-end">Thời gian chuẩn bị</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty orderItems}">
                                                    <c:forEach var="it" items="${orderItems}">
                                                        <tr>
                                                            <td><c:out value="${it.menuItemName}"/></td>
                                                            <td class="text-center"><c:out value="${it.quantity}"/></td>
                                                            <td class="text-center">
                                                                <c:choose>
                                                                    <c:when test="${it.status == 'NEW' || it.status == 'SENT'}">
                                                                        <span class="badge bg-primary">Chờ</span>
                                                                    </c:when>
                                                                    <c:when test="${it.status == 'COOKING'}">
                                                                        <span class="badge bg-warning text-dark">Đang chế biến</span>
                                                                    </c:when>
                                                                    <c:when test="${it.status == 'READY'}">
                                                                        <span class="badge bg-success">Sẵn sàng</span>
                                                                    </c:when>
                                                                    <c:when test="${it.status == 'SERVED'}">
                                                                        <span class="badge bg-secondary">Đã phục vụ</span>
                                                                    </c:when>
                                                                    <c:when test="${it.status == 'CANCELLED'}">
                                                                        <span class="badge bg-danger">Đã hủy</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge bg-light text-dark"><c:out value="${it.status}"/></span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td class="text-end">
                                                                <c:choose>
                                                                    <c:when test="${not empty it.preparationTime}">
                                                                        <c:out value="${it.preparationTime}"/> phút
                                                                    </c:when>
                                                                    <c:otherwise>-</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="4" class="no-items">Không có món nào trong đơn.</td>
                                                    </tr>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </c:if>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <%@ include file="/layouts/Footer.jsp" %>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
