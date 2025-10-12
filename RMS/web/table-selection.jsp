<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chọn Bàn - RMS</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .table-map {
            position: relative;
            background: #f8f9fa;
            border: 2px solid #dee2e6;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .table-item {
            position: absolute;
            width: 80px;
            height: 80px;
            border: 2px solid #6c757d;
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            background: white;
            transition: all 0.3s;
        }
        
        .table-item:hover {
            transform: scale(1.05);
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        
        .table-item.selected {
            background: #0d6efd;
            color: white;
            border-color: #0d6efd;
        }
        
        .table-item.unavailable {
            background: #dc3545;
            color: white;
            cursor: not-allowed;
            opacity: 0.7;
        }
        
        .table-item.reserved {
            background: #ffc107;
            color: black;
            cursor: not-allowed;
        }
        
        .area-section {
            margin-bottom: 30px;
        }
        
        .table-legend {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .legend-color {
            width: 20px;
            height: 20px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <!-- Include Header -->
    <jsp:include page="layouts/Header.jsp" />

    <div class="container-fluid py-5">
        <div class="container">
            <div class="row">
                <div class="col-12">
                    <h2 class="text-center mb-4">Chọn Bàn</h2>
                    
                    <!-- Thông tin đặt bàn -->
                    <div class="card mb-4">
                        <div class="card-body">
                            <h5 class="card-title">Thông tin đặt bàn của bạn</h5>
                            <div class="row">
                                <div class="col-md-3">
                                    <p><strong>Ngày:</strong> <span id="bookingDate"></span></p>
                                </div>
                                <div class="col-md-3">
                                    <p><strong>Giờ:</strong> <span id="bookingTime"></span></p>
                                </div>
                                <div class="col-md-3">
                                    <p><strong>Số người:</strong> <span id="guestCount"></span></p>
                                </div>
                                <div class="col-md-3">
                                    <p><strong>Khu vực:</strong> <span id="areaName"></span></p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Chú thích -->
                    <div class="table-legend">
                        <div class="legend-item">
                            <div class="legend-color" style="background: white; border: 2px solid #6c757d"></div>
                            <span>Bàn trống</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-color" style="background: #0d6efd"></div>
                            <span>Bàn đã chọn</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-color" style="background: #dc3545"></div>
                            <span>Bàn không khả dụng</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-color" style="background: #ffc107"></div>
                            <span>Bàn đã đặt</span>
                        </div>
                    </div>

                    <!-- Sơ đồ bàn -->
                    <c:choose>
                        <c:when test="${empty tableAreas}">
                            <!-- Khu vực mặc định nếu không có dữ liệu -->
                            <div class="area-section">
                                <h4 class="mb-3">Sơ đồ bàn</h4>
                                <div class="table-map" id="area-1" style="height: 400px;">
                                    <!-- Các bàn sẽ được thêm vào đây bằng JavaScript -->
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${tableAreas}" var="area">
                                <div class="area-section">
                                    <h4 class="mb-3">${area.areaName}</h4>
                                    <div class="table-map" id="area-${area.areaId}" style="height: 400px;">
                                        <!-- Các bàn sẽ được thêm vào đây bằng JavaScript -->
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>

                    <!-- Nút xác nhận -->
                    <div class="text-center mt-4">
                        <button class="btn btn-secondary me-2" onclick="goBack()">Quay lại</button>
                        <button class="btn btn-primary" onclick="confirmTableSelection()">Xác nhận đặt bàn</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Include Footer -->
    <jsp:include page="layouts/Footer.jsp" />

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="js/bootstrap.bundle.min.js"></script>
<script>
    let selectedTableId = null;
    const bookingInfo = JSON.parse(localStorage.getItem('bookingInfo') || '{}');

    // Gọi hàm loadTables ngay khi jQuery đã sẵn sàng
    $(document).ready(function() {
        loadTables();
    });

    // Hiển thị thông tin đặt bàn
    document.getElementById('bookingDate').textContent = bookingInfo.date || '';
    document.getElementById('bookingTime').textContent = bookingInfo.time || '';
    document.getElementById('guestCount').textContent = bookingInfo.guests || '';
    document.getElementById('areaName').textContent = bookingInfo.areaName || 'Tất cả';

    // Lấy danh sách bàn từ server
    function loadTables() {
        $.ajax({
            url: 'GetAvailableTablesServlet',
            type: 'GET',
            data: {
                date: bookingInfo.date,
                time: bookingInfo.time,
                guests: bookingInfo.guests,
                area: bookingInfo.areaId
            },
            success: function(response) {
                displayTables(response);
            },
            error: function(xhr, status, error) {
                console.error('Error loading tables:', error);
                alert('Không thể tải thông tin bàn. Vui lòng thử lại.');
            }
        });
    }

    // Hiển thị bàn lên sơ đồ
    function displayTables(response) {
        try {
            // Parse JSON nếu response là string
            const tables = typeof response === 'string' ? JSON.parse(response) : response;
            
            if (!Array.isArray(tables)) {
                console.error('Invalid tables data:', tables);
                return;
            }

            // Xóa tất cả bàn cũ trước khi thêm bàn mới
            document.querySelectorAll('.table-item').forEach(el => el.remove());

            tables.forEach((table, index) => {
                // Sử dụng vị trí từ database nếu có
                const tableElement = createTableElement(table);
                // Sử dụng area-id từ database
                const areaElement = document.getElementById(`area-${table.areaId}`);
                if (areaElement) {
                    areaElement.appendChild(tableElement);
                } else {
                    console.error('Không tìm thấy khu vực để hiển thị bàn:', table.areaId);
                }
            });
        } catch (error) {
            console.error('Lỗi khi hiển thị bàn:', error);
            alert('Có lỗi xảy ra khi tải thông tin bàn. Vui lòng thử lại.');
        }
    }

    // Tạo element cho mỗi bàn
    function createTableElement(table) {
        const div = document.createElement('div');
        div.className = 'table-item' + (table.status !== 'VACANT' ? ' unavailable' : '');
        div.setAttribute('data-table-id', table.tableId);
        div.style.left = `${table.mapX}px`;
        div.style.top = `${table.mapY}px`;
        div.innerHTML = `
            <strong>Bàn ${table.tableNumber || ''}</strong>
            <small>${table.capacity || 0} người</small>
        `;
        
        if (table.status === 'VACANT') {
            div.onclick = () => selectTable(table.tableId, div);
        }
        
        return div;
    }

    // Xử lý chọn bàn
    function selectTable(tableId, element) {
        if (selectedTableId) {
            document.querySelector(`.table-item[data-table-id="${selectedTableId}"]`)
                ?.classList.remove('selected');
        }
        
        selectedTableId = tableId;
        element.classList.add('selected');
    }

    // Quay lại trang trước
    function goBack() {
        window.history.back();
    }

    // Xác nhận chọn bàn
    function confirmTableSelection() {
        if (!selectedTableId) {
            alert('Vui lòng chọn một bàn.');
            return;
        }

        // Lưu thông tin bàn đã chọn
        bookingInfo.tableId = selectedTableId;
        localStorage.setItem('bookingInfo', JSON.stringify(bookingInfo));

        // Gửi form đặt bàn
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'BookingServlet';

        // Thêm các trường input
        Object.entries(bookingInfo).forEach(([key, value]) => {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = key;
            input.value = value;
            form.appendChild(input);
        });

        document.body.appendChild(form);
        form.submit();
    }
</script>
</body>
</html>