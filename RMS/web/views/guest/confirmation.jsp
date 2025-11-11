<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Xác nhận đặt bàn - Nhà hàng RMSG4</title>
        
        <!-- Favicon -->
        <link href="${pageContext.request.contextPath}/img/favicon.ico" rel="icon">

        <!-- Google Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet">

        <!-- Icons & Bootstrap -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

        <!-- Template Styles -->
        <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet">
        
        <style>
            .confirmation-header {
                background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
                color: white;
                padding: 2rem 0;
                margin-top: 80px;
                margin-bottom: 2rem;
                text-shadow: 1px 1px 2px rgba(0,0,0,0.2);
            }

            .confirmation-card {
                border: none;
                border-radius: 10px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                background: white;
                margin-bottom: 2rem;
                overflow: hidden;
            }

            .card-header {
                background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%) !important;
                color: white !important;
                border: none;
                padding: 1rem 1.5rem;
            }

            .btn-edit {
                background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
                border: none;
                color: white;
                padding: 8px 20px;
                border-radius: 50px;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .btn-edit:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
                color: white;
            }

            .confirmation-code {
                background: rgba(255, 215, 0, 0.1);
                border-left: 4px solid #FFD700;
                padding: 1rem;
                margin-bottom: 1.5rem;
            }

            .detail-label {
                color: #666;
                font-weight: 600;
                margin-bottom: 0.5rem;
            }

            .detail-value {
                color: #333;
                margin-bottom: 1rem;
            }
        </style>
    </head>
    <body>
        <jsp:include page="/layouts/Header.jsp"></jsp:include>

        <!-- Confirmation Header -->
        <div class="confirmation-header">
            <div class="container text-center">
                <c:choose>
                    <c:when test="${empty errorMessage && not empty reservation}">
                        <h1><i class="fas fa-check-circle me-2"></i>Đặt bàn thành công!</h1>
                        <p class="lead">Cảm ơn bạn đã tin tưởng nhà hàng của chúng tôi</p>
                        <div class="mt-4">
                            <p class="mb-0">Mã đặt bàn của bạn</p>
                            <h2 class="confirmation-code">${confirmationCode}</h2>
                            <p class="text-white-50">Vui lòng lưu lại mã này để tra cứu hoặc chỉnh sửa đặt bàn</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <h1><i class="fas fa-exclamation-circle me-2"></i>Đặt bàn không thành công!</h1>
                        <p class="lead">Vui lòng kiểm tra lại thông tin và thử lại</p>
                        <a href="${pageContext.request.contextPath}/booking" 
                           class="btn btn-light mt-3">
                            <i class="fas fa-redo me-2"></i>Thử lại
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="container">
            <!-- Thông tin đặt bàn -->
            <div class="row justify-content-center mb-4">
                <div class="col-lg-8">
                    <c:choose>
                        <c:when test="${empty errorMessage && not empty reservation}">
                            <div class="confirmation-card">
                                <div class="card-header">
                                    <h4 class="mb-0"><i class="fas fa-receipt me-2"></i>Chi tiết đơn đặt bàn</h4>
                                </div>
                        </c:when>
                        <c:otherwise>
                            <div class="alert alert-danger" role="alert">
                                <h4 class="alert-heading"><i class="fas fa-exclamation-triangle me-2"></i>Đặt bàn không thành công!</h4>
                                <p>${errorMessage}</p>
                                <hr>
                                <a href="${pageContext.request.contextPath}/booking" class="btn btn-warning">
                                    <i class="fas fa-redo me-2"></i>Quay lại đặt bàn
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    
                    <c:if test="${empty errorMessage && not empty reservation}">
                        <div class="card-body p-4">
                            <div class="confirmation-code">
                                <h5 class="mb-2"><i class="fas fa-ticket-alt me-2"></i>Mã đặt bàn của bạn</h5>
                                <h3 class="mb-0">${reservation.confirmationCode}</h3>
                                <small class="text-muted">Vui lòng lưu lại mã này để tra cứu hoặc thay đổi đặt bàn sau này</small>
                            </div>

                                <div class="row mb-4">
                                    <div class="col-md-6">
                                        <div class="p-3 rounded" style="background: rgba(255, 215, 0, 0.05);">
                                            <h5 class="mb-3"><i class="fas fa-user-circle me-2"></i>Thông tin khách hàng</h5>
                                            <div class="mb-3">
                                                <div class="detail-label"><i class="fas fa-user me-2"></i>Họ và tên</div>
                                                <div class="detail-value">${reservation.customerName}</div>
                                            </div>
                                            <div class="mb-3">
                                                <div class="detail-label"><i class="fas fa-phone me-2"></i>Số điện thoại</div>
                                                <div class="detail-value">${reservation.phone}</div>
                                            </div>
                                            <div>
                                                <div class="detail-label"><i class="fas fa-envelope me-2"></i>Email</div>
                                                <div class="detail-value">${reservation.email}</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="p-3 rounded" style="background: rgba(255, 165, 0, 0.05);">
                                            <h5 class="mb-3"><i class="fas fa-calendar-alt me-2"></i>Chi tiết đặt bàn</h5>
                                            <div class="mb-3">
                                                <div class="detail-label"><i class="fas fa-calendar-day me-2"></i>Ngày</div>
                                                <div class="detail-value">
                                                    <fmt:formatDate value="${reservation.reservationDate}" pattern="dd/MM/yyyy"/>
                                                    <span id="dateValidation"></span>
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <div class="detail-label"><i class="fas fa-clock me-2"></i>Giờ</div>
                                                <div class="detail-value">
                                                    <fmt:formatDate value="${reservation.reservationTime}" pattern="HH:mm"/>
                                                    <span id="timeValidation"></span>
                                                </div>
                                            </div>
                                            <div>
                                                <div class="detail-label"><i class="fas fa-users me-2"></i>Số người</div>
                                                <div class="detail-value">${reservation.partySize} người</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Booked table(s) details -->
                                <c:if test="${not empty bookedTables}">
                                    <div class="p-3 rounded mb-4" style="background: rgba(240, 248, 255, 0.6);">
                                        <h5 class="mb-3"><i class="fas fa-chair me-2"></i>Bàn đã đặt</h5>
                                        <div class="row">
                                            <c:forEach var="t" items="${bookedTables}">
                                                <div class="col-md-6 mb-3">
                                                    <div class="border p-3 rounded">
                                                        <div class="detail-label">Số bàn</div>
                                                        <div class="detail-value">${t.tableNumber}</div>
                                                        <div class="detail-label">Loại bàn</div>
                                                        <div class="detail-value">${t.tableType}</div>
                                                        <div class="detail-label">Sức chứa</div>
                                                        <div class="detail-value">${t.capacity} khách</div>
                                                        <div class="detail-label">Vị trí</div>
                                                        <div class="detail-value">${t.location}</div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:if>

                                <div class="p-3 rounded mb-4" style="background: rgba(255, 215, 0, 0.05);">
                                    <h5 class="mb-3"><i class="fas fa-comment-alt me-2"></i>Yêu cầu đặc biệt</h5>
                                    <div class="detail-value">${not empty reservation.specialRequests ? reservation.specialRequests : 'Không có'}</div>
                                </div>

                                <div class="text-center mt-4">
                                    <a href="${pageContext.request.contextPath}/booking" 
                                       class="btn btn-edit">
                                        <i class="fas fa-plus me-2"></i>Đặt bàn mới
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <jsp:include page="/layouts/Footer.jsp"></jsp:include>

        <!-- SweetAlert2 -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <!-- Font Awesome -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">

        <script>
            function confirmCancel(reservationId) {
                Swal.fire({
                    title: 'Xác nhận hủy đặt bàn?',
                    text: "Bạn không thể hoàn tác sau khi hủy!",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
                    cancelButtonColor: '#3085d6',
                    confirmButtonText: 'Hủy đặt bàn',
                    cancelButtonText: 'Đóng'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = '${pageContext.request.contextPath}/reservation/cancel?id=' + reservationId;
                    }
                })
            }

            // Kiểm tra thời gian đặt bàn khi trang load
            window.addEventListener('DOMContentLoaded', function() {
                const reservationDate = new Date('${reservation.reservationDate}');
                const reservationTime = '${reservation.reservationTime}'.split(':');
                reservationDate.setHours(parseInt(reservationTime[0]), parseInt(reservationTime[1]), 0, 0);
                
                const now = new Date();
                const twoHoursFromNow = new Date(now.getTime() + 2 * 60 * 60 * 1000);
                
                // Kiểm tra nếu thời gian đặt bàn trong quá khứ hoặc chưa đủ 2 tiếng
                if (reservationDate < now) {
                    document.getElementById('timeValidation').innerHTML = 
                        '<span class="badge bg-danger ms-2">Đã quá giờ</span>';
                    Swal.fire({
                        icon: 'error',
                        title: 'Thời gian đặt bàn không hợp lệ',
                        text: 'Thời gian đặt bàn đã qua, vui lòng đặt lại với thời gian mới.',
                        confirmButtonColor: '#FFA500'
                    });
                } else if (reservationDate < twoHoursFromNow) {
                    document.getElementById('timeValidation').innerHTML = 
                        '<span class="badge bg-warning ms-2">Chưa đủ 2 tiếng</span>';
                    Swal.fire({
                        icon: 'warning',
                        title: 'Cảnh báo thời gian đặt bàn',
                        text: 'Thời gian đặt bàn phải trước thời điểm đến ít nhất 2 tiếng.',
                        confirmButtonColor: '#FFA500'
                    });
                }
            });
        </script>
        </body>
</html>

        <jsp:include page="/layouts/Footer.jsp"></jsp:include>
    </body>
</html>