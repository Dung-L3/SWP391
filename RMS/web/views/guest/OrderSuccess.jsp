<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Đặt món thành công | RMSG4</title>
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
</head>
<body>
    <%@ include file="/layouts/Header.jsp" %>

    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-body text-center py-5">
                        <h2 class="card-title text-success mb-4">
                            <i class="bi bi-check-circle-fill"></i> Đặt món thành công!
                        </h2>
                        <p class="lead">Cảm ơn bạn đã đặt món tại nhà hàng chúng tôi</p>
                        
                        <!-- Mã đơn hàng -->
                        <div class="alert alert-info my-4">
                            <h5 class="mb-2">Mã đơn hàng của bạn</h5>
                            <div class="h3 mb-0"><c:out value="${order.orderCode}"/></div>
                            <small class="text-muted">Hãy lưu lại mã này để theo dõi đơn hàng của bạn</small>
                        </div>

                        <!-- Thông tin khách hàng -->
                        <div class="card mb-4">
                            <div class="card-header">
                                <h5 class="card-title mb-0">Thông tin giao hàng</h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6 text-start">
                                        <p><strong>Họ tên:</strong> <c:out value="${customer.fullName}"/></p>
                                        <p><strong>Số điện thoại:</strong> <c:out value="${customer.phone}"/></p>
                                    </div>
                                    <div class="col-md-6 text-start">
                                        <p><strong>Địa chỉ:</strong> <c:out value="${customer.address}"/></p>
                                
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Chi tiết đơn hàng -->
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title mb-0">Chi tiết đơn hàng</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table">
                                        <thead>
                                            <tr>
                                                <th>Món</th>
                                                <th class="text-center">Số lượng</th>
                                                <th class="text-end">Đơn giá</th>
                                                <th class="text-end">Thành tiền</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${orderItems}" var="item">
                                                <tr>
                                                    <td><c:out value="${item.menuItem.name}"/></td>
                                                    <td class="text-center">${item.quantity}</td>
                                                    <td class="text-end">
                                                        <fmt:formatNumber value="${item.finalUnitPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </td>
                                                    <td class="text-end">
                                                        <fmt:formatNumber value="${item.quantity * item.finalUnitPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                        <tfoot>
                                            <tr>
                                                <td colspan="3" class="text-end"><strong>Tạm tính:</strong></td>
                                                <td class="text-end">
                                                    <fmt:formatNumber value="${order.subtotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                </td>
                                            </tr>
                                            <c:if test="${order.discountAmount > 0}">
                                                <tr>
                                                    <td colspan="3" class="text-end"><strong>Giảm giá:</strong></td>
                                                    <td class="text-end">
                                                        <fmt:formatNumber value="${order.discountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </td>
                                                </tr>
                                            </c:if>
                                            <tr>
                                                <td colspan="3" class="text-end"><strong>Tổng cộng:</strong></td>
                                                <td class="text-end">
                                                    <strong>
                                                        <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </strong>
                                                </td>
                                            </tr>
                                        </tfoot>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <!-- Nút theo dõi đơn hàng -->
                        <div class="mt-4">
                            <a href="${pageContext.request.contextPath}/track-order?code=${order.orderCode}" class="btn btn-primary">
                                <i class="bi bi-clock-history"></i> Theo dõi đơn hàng
                            </a>
                            <a href="${pageContext.request.contextPath}/menu" class="btn btn-outline-primary">
                                <i class="bi bi-arrow-left"></i> Quay lại menu
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/layouts/Footer.jsp" %>
    
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>