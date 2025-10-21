<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Đặt bàn của tôi - Nhà hàng RMS</title>
        <link href="css/bootstrap.min.css" rel="stylesheet">
        <link href="css/style.css" rel="stylesheet">
    </head>
    <body>
        <jsp:include page="/layouts/Header.jsp"></jsp:include>

        <div class="container-fluid mt-5 pt-5">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-10">
                        <div class="card shadow">
                            <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                                <h4 class="mb-0">Đặt bàn của tôi</h4>
                                <a href="${pageContext.request.contextPath}/views/guest/booking.jsp" 
                                   class="btn btn-light">Đặt bàn mới</a>
                            </div>
                            <div class="card-body">
                                <!-- Hiển thị thông báo -->
                                <c:if test="${not empty successMessage}">
                                    <div class="alert alert-success" role="alert">
                                        ${successMessage}
                                    </div>
                                </c:if>
                                <c:if test="${not empty errorMessage}">
                                    <div class="alert alert-danger" role="alert">
                                        ${errorMessage}
                                    </div>
                                </c:if>

                                <c:if test="${empty reservations}">
                                    <div class="text-center py-5">
                                        <h5>Bạn chưa có đặt bàn nào.</h5>
                                        <a href="${pageContext.request.contextPath}/views/guest/booking.jsp" 
                                           class="btn btn-primary mt-3">Đặt bàn ngay</a>
                                    </div>
                                </c:if>

                                <c:if test="${not empty reservations}">
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead>
                                                <tr>
                                                    <th>Mã đặt bàn</th>
                                                    <th>Ngày</th>
                                                    <th>Giờ</th>
                                                    <th>Số người</th>
                                                    <th>Trạng thái</th>
                                                    <th>Thao tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${reservations}" var="res">
                                                    <tr>
                                                        <td>${res.confirmationCode}</td>
                                                        <td>
                                                            <fmt:formatDate value="${res.reservationDate}" 
                                                                          pattern="dd/MM/yyyy"/>
                                                        </td>
                                                        <td>
                                                            <fmt:formatDate value="${res.reservationTime}" 
                                                                          pattern="HH:mm"/>
                                                        </td>
                                                        <td>${res.partySize} người</td>
                                                        <td>
                                                            <span class="badge bg-${res.status eq 'CONFIRMED' ? 'success' : 
                                                                               res.status eq 'PENDING' ? 'warning' : 
                                                                               'danger'}">
                                                                ${res.status eq 'CONFIRMED' ? 'Đã xác nhận' :
                                                                  res.status eq 'PENDING' ? 'Chờ xác nhận' :
                                                                  'Đã hủy'}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <c:if test="${res.status ne 'CANCELLED'}">
                                                                <form action="${pageContext.request.contextPath}/reservation/cancel" 
                                                                      method="POST" style="display: inline;">
                                                                    <input type="hidden" name="id" value="${res.id}">
                                                                    <button type="submit" class="btn btn-sm btn-danger"
                                                                            onclick="return confirm('Bạn có chắc muốn hủy đặt bàn này?')">
                                                                        Hủy
                                                                    </button>
                                                                </form>
                                                            </c:if>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/layouts/Footer.jsp"></jsp:include>
    </body>
</html>