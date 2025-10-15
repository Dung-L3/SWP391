<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Sửa đặt bàn - Nhà hàng RMS</title>
        <link href="css/bootstrap.min.css" rel="stylesheet">
        <link href="css/style.css" rel="stylesheet">
    </head>
    <body>
        <jsp:include page="/layouts/Header.jsp"></jsp:include>

        <div class="container-fluid mt-5 pt-5">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <div class="card shadow">
                            <div class="card-header bg-primary text-white">
                                <h4 class="mb-0">Sửa thông tin đặt bàn</h4>
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

                                <form action="${pageContext.request.contextPath}/reservation/update" method="POST">
                                    <input type="hidden" name="reservation_id" value="${reservation.reservationId}">
                                    
                                    <!-- Thông tin khách hàng -->
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label for="customer_name" class="form-label">Họ và tên *</label>
                                            <input type="text" class="form-control" id="customer_name" 
                                                   name="customer_name" required
                                                   value="${reservation.customerName}">
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label for="phone" class="form-label">Số điện thoại *</label>
                                            <input type="tel" class="form-control" id="phone" 
                                                   name="phone" required pattern="[0-9]{10}"
                                                   value="${reservation.phone}"
                                                   title="Vui lòng nhập số điện thoại 10 số">
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="email" class="form-label">Email</label>
                                        <input type="email" class="form-control" id="email" 
                                               name="email"
                                               value="${reservation.email}">
                                        <div class="form-text">Chúng tôi sẽ gửi xác nhận đặt bàn qua email này</div>
                                    </div>

                                    <hr class="my-4">
                                    
                                    <!-- Thông tin đặt bàn -->
                                    <div class="mb-3">
                                        <label for="party_size" class="form-label">Số người *</label>
                                        <select class="form-select" id="party_size" name="party_size" required>
                                            <c:forEach begin="1" end="10" var="i">
                                                <option value="${i}" ${reservation.partySize eq i ? 'selected' : ''}>
                                                    ${i} người
                                                </option>
                                            </c:forEach>
                                            <option value="11" ${reservation.partySize gt 10 ? 'selected' : ''}>
                                                Trên 10 người
                                            </option>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label for="reservation_date" class="form-label">Ngày đặt bàn *</label>
                                        <input type="date" class="form-control" id="reservation_date" 
                                               name="reservation_date" required min="${java.time.LocalDate.now()}"
                                               value="<fmt:formatDate value="${reservation.reservationDate}" pattern="yyyy-MM-dd"/>">
                                    </div>

                                    <div class="mb-3">
                                        <label for="reservation_time" class="form-label">Giờ đặt bàn *</label>
                                        <select class="form-select" id="reservation_time" name="reservation_time" required>
                                            <c:forEach var="hour" begin="10" end="21">
                                                <c:forEach var="minute" items="${['00', '30']}">
                                                    <c:set var="timeStr" value="${hour}:${minute}:00"/>
                                                    <option value="${timeStr}" 
                                                            ${reservation.reservationTime eq timeStr ? 'selected' : ''}>
                                                        ${hour}:${minute}
                                                    </option>
                                                </c:forEach>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label for="special_requests" class="form-label">Yêu cầu đặc biệt</label>
                                        <textarea class="form-control" id="special_requests" 
                                                  name="special_requests" rows="3" 
                                                  placeholder="Ví dụ: Ghế trẻ em, bàn ở góc yên tĩnh...">${reservation.specialRequests}</textarea>
                                    </div>

                                    <div class="d-flex justify-content-between">
                                        <a href="${pageContext.request.contextPath}/views/guest/my-reservations.jsp" 
                                           class="btn btn-secondary">Quay lại</a>
                                        <button type="submit" class="btn btn-primary">Cập nhật đặt bàn</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/layouts/Footer.jsp"></jsp:include>
        
        <!-- JavaScript -->
        <script>
            // Đặt ngày tối thiểu là ngày hiện tại
            document.getElementById('reservation_date').min = new Date().toISOString().split('T')[0];
            
            // Kiểm tra thời gian đặt bàn hợp lệ
            document.querySelector('form').addEventListener('submit', function(e) {
                const date = new Date(document.getElementById('reservation_date').value);
                const time = document.getElementById('reservation_time').value;
                const [hours, minutes] = time.split(':');
                
                date.setHours(parseInt(hours));
                date.setMinutes(parseInt(minutes));
                
                const now = new Date();
                
                if (date < now) {
                    e.preventDefault();
                    alert('Vui lòng chọn thời gian trong tương lai.');
                }
            });
        </script>
    </body>
</html>