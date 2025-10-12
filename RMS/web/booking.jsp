<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đặt Bàn - RMS</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <!-- Date Time Picker CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tempusdominus-bootstrap-4/5.39.0/css/tempusdominus-bootstrap-4.min.css">
</head>
<body>
    <!-- Include Header -->
    <jsp:include page="layouts/Header.jsp" />

    <div class="container-fluid py-5">
        <div class="container">
            <div class="row">
                <div class="col-lg-8 mx-auto">
                    <div class="card shadow">
                        <div class="card-body">
                            <h2 class="text-center mb-4">Đặt Bàn</h2>
                            
                            <form id="bookingForm" onsubmit="return proceedToTableSelection(event)">
                                <div class="row g-3">
                                    <!-- Personal Information -->
                                    <div class="col-12">
                                        <h4 class="mb-3">Thông Tin Cá Nhân</h4>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <label for="fullName" class="form-label">Họ và Tên *</label>
                                        <input type="text" class="form-control" id="fullName" name="fullName" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label for="email" class="form-label">Email *</label>
                                        <input type="email" class="form-control" id="email" name="email" required>
                                    </div>

                                    <div class="col-md-6">
                                        <label for="phone" class="form-label">Số Điện Thoại *</label>
                                        <input type="tel" class="form-control" id="phone" name="phone" required>
                                    </div>

                                    <!-- Reservation Details -->
                                    <div class="col-12 mt-4">
                                        <h4 class="mb-3">Chi Tiết Đặt Bàn</h4>
                                    </div>

                                    <div class="col-md-6">
                                        <label for="date" class="form-label">Ngày *</label>
                                        <input type="date" class="form-control" id="date" name="date" required 
                                               min="${LocalDate.now()}" max="${LocalDate.now().plusMonths(1)}">
                                    </div>

                                    <div class="col-md-6">
                                        <label for="time" class="form-label">Giờ *</label>
                                        <select class="form-select" id="time" name="time" required>
                                            <option value="">Chọn giờ...</option>
                                            <option value="11:00">11:00</option>
                                            <option value="11:30">11:30</option>
                                            <option value="12:00">12:00</option>
                                            <option value="12:30">12:30</option>
                                            <option value="13:00">13:00</option>
                                            <option value="13:30">13:30</option>
                                            <option value="17:00">17:00</option>
                                            <option value="17:30">17:30</option>
                                            <option value="18:00">18:00</option>
                                            <option value="18:30">18:30</option>
                                            <option value="19:00">19:00</option>
                                            <option value="19:30">19:30</option>
                                            <option value="20:00">20:00</option>
                                        </select>
                                    </div>

                                    <div class="col-md-6">
                                        <label for="guests" class="form-label">Số Người *</label>
                                        <select class="form-select" id="guests" name="guests" required>
                                            <option value="">Chọn số người...</option>
                                            <option value="1">1 Người</option>
                                            <option value="2">2 Người</option>
                                            <option value="3">3 Người</option>
                                            <option value="4">4 Người</option>
                                            <option value="5">5 Người</option>
                                            <option value="6">6 Người</option>
                                            <option value="7">7 Người</option>
                                            <option value="8">8 Người</option>
                                            <option value="9">9 Người</option>
                                            <option value="10">10 Người</option>
                                        </select>
                                    </div>

                                    <div class="col-md-6">
                                        <label for="tableArea" class="form-label">Khu Vực</label>
                                        <select class="form-select" id="tableArea" name="tableArea">
                                            <option value="">Chọn khu vực (không bắt buộc)...</option>
                                            <c:forEach items="${tableAreas}" var="area">
                                                <option value="${area.areaId}">${area.areaName}</option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div class="col-12">
                                        <label for="specialRequests" class="form-label">Yêu Cầu Đặc Biệt</label>
                                        <textarea class="form-control" id="specialRequests" name="specialRequests" 
                                                  rows="3" maxlength="255" 
                                                  placeholder="Bạn có yêu cầu đặc biệt nào không?"></textarea>
                                    </div>

                                    <!-- Available Tables Section -->
                                    <div class="col-12 mt-4" id="availableTablesSection" style="display: none;">
                                        <h4 class="mb-3">Bàn Còn Trống</h4>
                                        <div id="tablesList" class="row g-3">
                                            <!-- Tables will be loaded here dynamically -->
                                        </div>
                                    </div>

                                    <div class="col-12 mt-4">
                                        <button class="btn btn-primary w-100" type="submit">
                                            Đặt Bàn
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Include Footer -->
    <jsp:include page="layouts/Footer.jsp" />

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.1/moment.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/tempusdominus-bootstrap-4/5.39.0/js/tempusdominus-bootstrap-4.min.js"></script>

    <script>
        $(document).ready(function() {
            // Kiểm tra form và chuyển sang trang chọn bàn
            window.proceedToTableSelection = function(event) {
                event.preventDefault();
                
                // Lưu thông tin đặt bàn
                const bookingInfo = {
                    fullName: $('#fullName').val(),
                    email: $('#email').val(),
                    phone: $('#phone').val(),
                    date: $('#date').val(),
                    time: $('#time').val(),
                    guests: $('#guests').val(),
                    areaId: $('#tableArea').val(),
                    areaName: $('#tableArea option:selected').text(),
                    specialRequests: $('#specialRequests').val()
                };

                // Validate form
                if (!bookingInfo.fullName || !bookingInfo.email || !bookingInfo.phone ||
                    !bookingInfo.date || !bookingInfo.time || !bookingInfo.guests) {
                    alert('Vui lòng điền đầy đủ thông tin bắt buộc.');
                    return false;
                }

                // Lưu thông tin vào localStorage để sử dụng ở trang chọn bàn
                localStorage.setItem('bookingInfo', JSON.stringify(bookingInfo));

                // Chuyển hướng sang trang chọn bàn
                window.location.href = 'table-selection.jsp';
                return false;
            };
        });
    </script>
</body>
</html>