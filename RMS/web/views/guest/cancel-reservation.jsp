<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Hủy đặt bàn - Nhà hàng RMSG4</title>
        
        <!-- Favicon -->
        <link href="${pageContext.request.contextPath}/img/favicon.ico" rel="icon">

        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet">

        <!-- Icons & Bootstrap -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet">
        
        <style>
            .cancel-header {
                background: linear-gradient(135deg, #FF6B6B 0%, #FF4646 100%);
                color: white;
                padding: 2rem 0;
                margin-top: 80px;
                margin-bottom: 2rem;
                text-shadow: 1px 1px 2px rgba(0,0,0,0.2);
            }

            .cancel-card {
                border: none;
                border-radius: 10px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                background: white;
                margin-bottom: 2rem;
                overflow: hidden;
            }

            .card-header {
                background: linear-gradient(135deg, #FF6B6B 0%, #FF4646 100%) !important;
                color: white !important;
                border: none;
                padding: 1rem 1.5rem;
            }
        </style>
    </head>
    <body>
        <jsp:include page="/layouts/Header.jsp"/>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="container mt-5 pt-5">
                <div class="alert alert-success text-center" role="alert">
                    ${sessionScope.successMessage}
                    <c:remove var="successMessage" scope="session" />
                </div>
            </div>
        </c:if>

        <c:if test="${empty reservation}">
            <div class="container mt-5 pt-5">
                <div class="alert alert-danger text-center" role="alert">
                    Không tìm thấy thông tin đặt bàn hoặc mã xác nhận không hợp lệ.
                </div>
            </div>
        </c:if>

        <c:if test="${not empty reservation}">
            <div class="cancel-header">
                <div class="container text-center">
                    <h2 class="mb-3">Xác nhận hủy đặt bàn</h2>
                    <p class="lead mb-0">Mã đặt bàn: ${reservation.confirmationCode}</p>
                </div>
            </div>

            <div class="container py-5">
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <div class="cancel-card">
                            <div class="card-header">
                                <h4 class="mb-0"><i class="bi bi-info-circle me-2"></i>Chi tiết đặt bàn</h4>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <tr>
                                            <th style="width: 200px;">Tên khách hàng:</th>
                                            <td>${reservation.customerName}</td>
                                        </tr>
                                        <tr>
                                            <th>Số điện thoại:</th>
                                            <td>${reservation.phone}</td>
                                        </tr>
                                        <tr>
                                            <th>Email:</th>
                                            <td>${reservation.email}</td>
                                        </tr>
                                        <tr>
                                            <th>Ngày:</th>
                                            <td><fmt:formatDate value="${reservation.reservationDate}" pattern="dd/MM/yyyy"/></td>
                                        </tr>
                                        <tr>
                                            <th>Giờ:</th>
                                            <td>${reservation.reservationTime}</td>
                                        </tr>
                                        <tr>
                                            <th>Số người:</th>
                                            <td>${reservation.partySize}</td>
                                        </tr>
                                        <tr>
                                            <th>Trạng thái:</th>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${reservation.status eq 'PENDING'}">
                                                        <span class="badge bg-warning">Chờ xác nhận</span>
                                                    </c:when>
                                                    <c:when test="${reservation.status eq 'CONFIRMED'}">
                                                        <span class="badge bg-success">Đã xác nhận</span>
                                                    </c:when>
                                                    <c:when test="${reservation.status eq 'CANCELLED'}">
                                                        <span class="badge bg-danger">Đã hủy</span>
                                                    </c:when>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </table>
                                </div>

                                <c:if test="${reservation.status ne 'CANCELLED'}">
                                    <form action="${pageContext.request.contextPath}/cancel-reservation" method="post" 
                                          class="mt-4 text-center" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đặt bàn này?');">
                                        <input type="hidden" name="confirmationCode" value="${reservation.confirmationCode}">
                                        <input type="hidden" name="email" value="${reservation.email}">
                                        <button type="submit" class="btn btn-danger btn-lg">
                                            <i class="bi bi-x-circle me-2"></i>Xác nhận hủy đặt bàn
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </div>

                        <div class="text-center">
                            <a href="${pageContext.request.contextPath}/common/Homepage.jsp" class="btn btn-secondary">
                                <i class="bi bi-house me-2"></i>Về trang chủ
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <jsp:include page="/layouts/Footer.jsp"/>

        <!-- JavaScript Libraries -->
        <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/lib/wow/wow.min.js"></script>
        <script src="${pageContext.request.contextPath}/lib/easing/easing.min.js"></script>
        <script src="${pageContext.request.contextPath}/lib/waypoints/waypoints.min.js"></script>
        <script src="${pageContext.request.contextPath}/lib/counterup/counterup.min.js"></script>
        <script src="${pageContext.request.contextPath}/lib/owlcarousel/owl.carousel.min.js"></script>
        <script src="${pageContext.request.contextPath}/lib/tempusdominus/js/moment.min.js"></script>
        <script src="${pageContext.request.contextPath}/lib/tempusdominus/js/moment-timezone.min.js"></script>
        <script src="${pageContext.request.contextPath}/lib/tempusdominus/js/tempusdominus-bootstrap-4.min.js"></script>
        <script src="${pageContext.request.contextPath}/js/main.js"></script>
    </body>
</html>