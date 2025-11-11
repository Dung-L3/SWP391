<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="utf-8">
        <title>Đặt bàn - Nhà hàng RMSG4</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!-- Favicon -->
        <link href="${pageContext.request.contextPath}/img/favicon.ico" rel="icon">

        <!-- Google Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet">

        <!-- Icons & Bootstrap -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">
        
        <!-- jQuery UI CSS -->
        <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">

        <!-- Template Styles -->
        <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet">
        
        <!-- Booking Validation JavaScript -->
        <script src="${pageContext.request.contextPath}/js/booking-validation.js"></script>

        <!-- Custom Date Picker Style -->
        <style>
            .ui-datepicker {
                background: #fff;
                border: 1px solid #ddd;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
                font-family: 'Nunito', sans-serif;
            }
            .ui-datepicker-header {
                background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
                color: white;
                border: none;
            }
            .ui-datepicker th {
                background: #f8f9fa;
                color: #495057;
            }
            .ui-datepicker-calendar .ui-state-default {
                background: #fff;
                border: 1px solid #ddd;
                color: #495057;
                text-align: center;
            }
            .ui-datepicker-calendar .ui-state-hover {
                background: #f8f9fa;
                border: 1px solid #ddd;
                color: #FFA500;
            }
            .ui-datepicker-calendar .ui-state-active {
                background: #FFA500;
                border: 1px solid #FFA500;
                color: #fff;
            }
            .ui-datepicker-calendar .ui-state-disabled {
                background: #f8f9fa;
                color: #ddd;
            }
        </style>
        
        <style>
            .booking-header {
                background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
                color: white;
                padding: 2rem 0;
                margin-top: 80px;
                margin-bottom: 2rem;
                text-shadow: 1px 1px 2px rgba(0,0,0,0.2);
            }

            .booking-card {
                border: 1px solid #e0e0e0;
                border-radius: 10px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                background: white;
                margin-bottom: 2rem;
            }

            .form-control:focus, .form-select:focus {
                border-color: #FFA500;
                box-shadow: 0 0 0 0.2rem rgba(255, 165, 0, 0.25);
            }

            .btn-submit {
                background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
                border: none;
                color: white;
                padding: 10px 30px;
                border-radius: 50px;
                font-weight: 600;
                transition: all 0.3s ease;
                text-shadow: 1px 1px 2px rgba(0,0,0,0.2);
            }

            .btn-submit:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
            }
        </style>
    </head>
    <body>
        <jsp:include page="/layouts/Header.jsp"></jsp:include>

        <!-- Booking Header -->
        <div class="booking-header">
            <div class="container text-center">
                <h1>Đặt bàn</h1>
                <p class="lead">Hãy để chúng tôi chuẩn bị một bữa ăn tuyệt vời cho bạn</p>
            </div>
        </div>

        <!-- Booking Form -->
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="booking-card p-4"
                            <!-- Hiển thị thông báo -->
                            <c:if test="${not empty successMessage}">
                                <div class="alert alert-success" role="alert">
                                    <i class="fas fa-check-circle me-2"></i>${successMessage}
                                </div>
                            </c:if>
                            <c:if test="${not empty errorMessage}">
                                <div class="alert alert-danger" role="alert">
                                    <i class="fas fa-exclamation-circle me-2"></i>${errorMessage}
                                </div>
                            </c:if>

                            <form action="${pageContext.request.contextPath}/reservation/select-table" method="POST">
                                <!-- Thông tin khách hàng -->
                                <h5 class="mb-4"><i class="fas fa-user me-2"></i>Thông tin khách hàng</h5>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="customer_name" class="form-label">Họ và tên *</label>
                                        <div class="input-group">
                                            <span class="input-group-text"><i class="fas fa-user"></i></span>
                                            <input type="text" class="form-control" id="customer_name" 
                                                   name="customer_name" required
                                                   value="${sessionScope.user != null ? sessionScope.user.firstName.concat(' ').concat(sessionScope.user.lastName) : ''}">
                                        </div>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="phone" class="form-label">Số điện thoại *</label>
                                        <div class="input-group">
                                            <span class="input-group-text"><i class="fas fa-phone"></i></span>
                          <input type="tel" inputmode="numeric" pattern="[0-9]*" class="form-control" id="phone" 
                              name="phone" required
                              value="${sessionScope.user != null ? sessionScope.user.phone : ''}"
                              oninput="validatePhone(this)"
                              maxlength="10" placeholder="Ví dụ: 0912345678">
                                        </div>
                                        <div class="invalid-feedback" id="phoneError">
                                            Vui lòng nhập đủ 10 số điện thoại
                                        </div>
                                    </div>
                                </div>
                                    
                                <div class="mb-3">
                                    <label for="email" class="form-label">Email</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                                        <input type="email" class="form-control" id="email" 
                                               name="email"
                                               value="${sessionScope.user != null ? sessionScope.user.email : ''}"
                                               placeholder="example@email.com">
                                    </div>
                                    <div class="form-text text-muted">
                                        <i class="fas fa-info-circle me-1"></i>Chúng tôi sẽ gửi xác nhận đặt bàn qua email này
                                    </div>
                                </div>

                                <hr class="my-4">
                                
                                <!-- Thông tin đặt bàn -->
                                <h5 class="mb-4"><i class="fas fa-utensils me-2"></i>Chi tiết đặt bàn</h5>
                                
                                <div class="mb-3">
                                    <label for="reservation_date" class="form-label">Ngày đặt bàn *</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-calendar"></i></span>
                                        <input type="date" class="form-control" id="reservation_date" 
                                               name="reservation_date" required
                                               min="" 
                                               onchange="validateDateTime()"
                                               style="cursor: pointer;"
                                               onfocus="this.min=new Date().toISOString().split('T')[0];"
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="reservation_time" class="form-label">Giờ đặt bàn *</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-clock"></i></span>
                                        <select class="form-select" id="reservation_time" name="reservation_time" required>
                                            <option value="">Chọn giờ</option>
                                            <c:forEach var="hour" begin="10" end="21">
                                                <c:forEach var="minute" items="${['00', '30']}">
                                                    <option value="${hour}:${minute}:00">
                                                        ${hour}:${minute}
                                                    </option>
                                                </c:forEach>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="form-text text-muted">
                                        <i class="fas fa-info-circle me-1"></i>Vui lòng đặt bàn trước thời điểm đến ít nhất 2 tiếng
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="party_size" class="form-label">Số người *</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-users"></i></span>
                                        <select class="form-select" id="party_size" name="party_size" required>
                                            <option value="">Chọn số người</option>
                                            <c:forEach begin="1" end="8" var="i">
                                                <option value="${i}">${i} người</option>
                                        </c:forEach>
                                        </select>
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label for="special_requests" class="form-label">
                                        <i class="fas fa-comment-alt me-1"></i>Yêu cầu đặc biệt
                                    </label>
                                    <textarea class="form-control" id="special_requests" 
                                              name="special_requests" rows="3" 
                                              placeholder="Ví dụ: Ghế trẻ em, bàn ở góc yên tĩnh..."></textarea>
                                </div>

                                <!-- Submit Button -->
                                <div class="text-end">
                                    <button type="submit" class="btn btn-submit">
                                        <i class="fas fa-calendar-check me-2"></i>Xác nhận đặt bàn
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
 
            
