<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sơ đồ bàn - RMSG4</title>
    
    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&display=swap" rel="stylesheet">

    <!-- Icon Font Stylesheet -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Bootstrap -->
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">

    <!-- Template Stylesheet -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">

    <style>
        .table-layout {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 10px;
            min-height: 500px;
        }
        
        .tables-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        /* Thêm style cho selected-table-item */
        .selected-table-item {
            background: #fff;
            transition: all 0.3s ease;
        }
        
        .selected-table-item:hover {
            background: #f8f9fa;
        }
        
        /* Style cho capacity info */
        #capacityInfo .alert {
            margin-bottom: 0;
            padding: 0.5rem 1rem;
        }
        
        /* Style cho checkbox trong table */
        .table-checkbox {
            position: absolute;
            top: 5px;
            left: 5px;
        }
        
        .table-checkbox .form-check-input {
            width: 1.2em;
            height: 1.2em;
        }
        
        /* Hiệu ứng hover và selected cho bàn */
        .dining-table:hover {
            transform: scale(1.05);
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
        }
        
        .table-selected {
            transform: scale(1.05);
            box-shadow: 0 0 15px rgba(0,123,255,0.3) !important;
            border-color: #007bff !important;
        }

        #confirmButton {
            background: linear-gradient(135deg, #28a745 0%, #218838 100%);
            color: white;
            padding: 10px 20px;
            border-radius: 50px;
            border: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        #confirmButton:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3);
        }
        
        .selected-table-item {
            animation: fadeIn 0.3s ease;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .dining-table {
            width: 100%;
            aspect-ratio: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
            cursor: pointer;
            position: relative;
            transition: all 0.3s ease;
            padding: 15px;
            text-align: center;
            border: 2px solid #ddd;
            font-size: 1.2em;
            font-weight: 600;
        }
        
        .table-info {
            font-size: 0.8em;
            margin-top: 5px;
            font-weight: normal;
        }
        
        .table-capacity {
            position: absolute;
            top: 5px;
            right: 5px;
            background: rgba(0,0,0,0.1);
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 0.7em;
        }
        
        .table-status {
            position: absolute;
            bottom: 5px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 0.7em;
            white-space: nowrap;
        }
        
        .table-available {
            background-color: #d4edda;
            border-color: #c3e6cb;
            color: #155724;
        }
        
        .table-occupied {
            background-color: #f8d7da;
            border-color: #f5c6cb;
            color: #721c24;
        }
        
        .table-reserved {
            background-color: #fff3cd;
            border-color: #ffeeba;
            color: #856404;
        }
        
        .table-vip {
            border-width: 3px;
            border-color: #ffd700;
            box-shadow: 0 0 10px rgba(255, 215, 0, 0.3);
        }
        
        .table-outdoor {
            background-image: linear-gradient(45deg, rgba(255,255,255,.15) 25%, transparent 25%, transparent 50%, rgba(255,255,255,.15) 50%, rgba(255,255,255,.15) 75%, transparent 75%, transparent);
            background-size: 1rem 1rem;
        }
        
        .table-selected {
            transform: scale(1.05);
            box-shadow: 0 0 15px rgba(0,0,0,0.2);
            border-color: #007bff;
            border-width: 3px;
        }

        .dining-table:hover {
            transform: scale(1.05);
            box-shadow: 0 0 15px rgba(0,0,0,0.2);
        }
        
        .table-capacity {
            font-size: 0.9em;
            color: inherit;
            opacity: 0.8;
            margin-top: 5px;
        }
        
        .area-selector {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .area-btn {
            padding: 8px 16px;
            border: 2px solid #ddd;
            border-radius: 20px;
            background: white;
            color: #666;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .area-btn.active {
            background: #ffa500;
            border-color: #ffa500;
            color: white;
        }
        
        .area-btn:hover {
            border-color: #ffa500;
            color: #ffa500;
        }
        
        .area-btn.active:hover {
            background: #ff8c00;
            border-color: #ff8c00;
            color: white;
        }
        
        .table-filters {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .table-info {
            margin-top: 10px;
            font-size: 0.8em;
            line-height: 1.4;
            font-weight: normal;
            color: #666;
        }

        .legend {
            margin-top: 30px;
            padding: 15px;
            border-radius: 5px;
            background: white;
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            justify-content: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 5px;
            padding: 5px 10px;
            border-radius: 4px;
            background: #f8f9fa;
        }

        .legend-color {
            width: 20px;
            height: 20px;
            border-radius: 4px;
            border: 1px solid rgba(0,0,0,0.1);
        }
        
        .area-selector, .type-filter {
            max-width: 300px;
            margin: 0 auto;
        }

        .form-select {
            padding: 0.5rem;
            font-size: 1rem;
            border-radius: 0.25rem;
            border: 1px solid #ced4da;
            background-color: #fff;
            cursor: pointer;
            transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
        }

        .form-select:focus {
            border-color: #86b7fe;
            box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
            outline: none;
        }
    </style>
</head>

<body>
    <!-- Header -->
    <jsp:include page="/layouts/Header.jsp"/>

    <div class="container-xxl py-5 bg-dark hero-header mb-5">
        <div class="container text-center my-5 pt-5 pb-4">
            <h1 class="display-3 text-white mb-3 animated slideInDown">Sơ Đồ Bàn</h1>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb justify-content-center text-uppercase">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Trang chủ</a></li>
                    <li class="breadcrumb-item text-white active" aria-current="page">Sơ đồ bàn</li>
                </ol>
            </nav>
        </div>
    </div>

    <div class="container-xxl py-5">
        <div class="container">
            <!-- Error Message -->
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                    ${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% session.removeAttribute("errorMessage"); %>
            </c:if>

            <div class="text-center">
                <h4 class="section-title ff-secondary text-center text-primary fw-normal">Chọn Bàn Ăn</h4>
                <h1 class="mb-5">Sơ Đồ Bàn Trong Nhà Hàng</h1>
            </div>

            <!-- Area and Type Filters -->
            <div class="filters-row d-flex justify-content-center gap-3 mb-4">
                <div class="area-selector" style="width: 200px;">
                    <select class="form-select" id="areaSelect" onchange="changeArea(this.value)">
                        <option value="1" ${currentArea == 1 ? 'selected' : ''}>Area 1</option>
                        <option value="2" ${currentArea == 2 ? 'selected' : ''}>Area 2</option>
                        <option value="3" ${currentArea == 3 ? 'selected' : ''}>Area 3</option>
                    </select>
                </div>
                <div class="type-filter" style="width: 200px;">
                    <select class="form-select" id="typeSelect" onchange="filterByType(this.value)">
                        <option value="">All Types</option>
                        <option value="REGULAR">Regular</option>
                        <option value="VIP">VIP</option>
                        <option value="OUTDOOR">Outdoor</option>
                    </select>
                </div>
            </div>

            <div class="table-layout">
                <!-- Tables Grid -->
                <div class="tables-grid">
                    <c:forEach items="${tables}" var="table">
                        <div class="dining-table ${table.status == 'VACANT' ? 'table-available' : table.status == 'OCCUPIED' ? 'table-occupied' : 'table-reserved'} 
                             ${table.tableType == 'VIP' ? 'table-vip' : ''} ${table.tableType == 'OUTDOOR' ? 'table-outdoor' : ''}"
                             onclick="selectTable(this)"
                             data-table-number="${table.tableNumber}"
                             data-capacity="${table.capacity}"
                             data-table-type="${table.tableType}">
                            <span class="table-number">${table.tableNumber}</span>
                            <span class="table-capacity">${table.capacity} chỗ</span>
                            <div class="table-info">
                                <span class="table-status">
                                    <i class="fas ${table.status == 'VACANT' ? 'fa-check text-success' : 
                                                   table.status == 'OCCUPIED' ? 'fa-times text-danger' : 
                                                   'fa-clock text-warning'}"></i>
                                    ${table.status == 'VACANT' ? 'Còn trống' : 
                                      table.status == 'OCCUPIED' ? 'Đang sử dụng' : 'Đã đặt trước'}
                                </span>
                                <span class="table-type">
                                    <i class="fas ${table.tableType == 'VIP' ? 'fa-crown text-warning' : 
                                                   table.tableType == 'OUTDOOR' ? 'fa-tree text-success' : 
                                                   'fa-chair text-primary'}"></i>
                                    ${table.tableType == 'VIP' ? 'VIP' : 
                                      table.tableType == 'OUTDOOR' ? 'Ngoài trời' : 'Thường'}
                                </span>
                            </div>
                            <div class="table-checkbox" style="display: none;">
                                <input type="checkbox" class="form-check-input">
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Current Booking Info -->
                <div class="booking-info-summary mb-4 p-3 bg-info text-white rounded">
                    <h5><i class="fas fa-info-circle me-2"></i>Thông tin đặt bàn</h5>
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>Khách hàng:</strong> ${sessionScope.customerName}</p>
                            <p><strong>Số điện thoại:</strong> ${sessionScope.phone}</p>
                            <p><strong>Email:</strong> ${sessionScope.email}</p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Ngày đặt:</strong> ${sessionScope.reservationDate}</p>
                            <p><strong>Giờ đặt:</strong> ${sessionScope.reservationTime}</p>
                            <p><strong>Số người:</strong> ${sessionScope.partySize}</p>
                        </div>
                    </div>
                    <div class="text-end">
                        <a href="${pageContext.request.contextPath}/views/guest/booking.jsp" class="btn btn-light">
                            <i class="fas fa-edit me-2"></i>Sửa thông tin
                        </a>
                    </div>
                </div>

                <!-- Selected Tables Summary -->
                <div id="selectedTablesSummary" class="mt-4 p-3 bg-light rounded" style="display: none;">
                    <h5><i class="fas fa-clipboard-list me-2"></i>Bàn đã chọn</h5>
                    <div id="selectedTablesList" class="mb-3"></div>
                    <div id="capacityInfo" class="mb-3"></div>
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <strong>Tổng số chỗ: </strong>
                            <span id="totalCapacity">0</span>
                        </div>
                        <button id="confirmButton" class="btn btn-primary" style="display: none;" onclick="confirmTableSelection()">
                            <i class="fas fa-check me-2"></i>Xác nhận đặt bàn
                        </button>
                    </div>
                        <div>
                            <strong>Tổng số chỗ ngồi: </strong>
                            <span id="totalCapacity">0</span>
                        </div>
                        <div>
                            <button class="btn btn-outline-danger btn-sm me-2" onclick="clearSelection()">
                                <i class="fas fa-times me-1"></i>Bỏ chọn tất cả
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Legend -->
                <div class="legend mt-4">
                    <!-- Status Legend -->
                    <div class="legend-group">
                        <div class="legend-item">
                            <div class="legend-color" style="background-color: #d4edda; border-color: #c3e6cb;"></div>
                            <span>Còn trống</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-color" style="background-color: #f8d7da; border-color: #f5c6cb;"></div>
                            <span>Đang sử dụng</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-color" style="background-color: #fff3cd; border-color: #ffeeba;"></div>
                            <span>Đã đặt trước</span>
                        </div>
                    </div>
                    <!-- Type Legend -->
                    <div class="legend-group">
                        <div class="legend-item">
                            <div class="legend-color" style="border-color: #ffd700; border-width: 3px;"></div>
                            <span>VIP</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-color" style="background-image: linear-gradient(45deg, rgba(0,0,0,.1) 25%, transparent 25%, transparent 50%, rgba(0,0,0,.1) 50%, rgba(0,0,0,.1) 75%, transparent 75%, transparent);"></div>
                            <span>Ngoài trời</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Thông tin bàn đã chọn và nút xác nhận -->
            <div class="text-center mt-4">
                <div class="btn-group mb-3" role="group">
                    <button type="button" class="btn btn-outline-primary" onclick="toggleSelectionMode(false)">
                        <i class="fas fa-table me-1"></i>Chọn một bàn
                    </button>
                    <button type="button" class="btn btn-outline-primary" onclick="toggleSelectionMode(true)">
                        <i class="fas fa-object-group me-1"></i>Gộp nhiều bàn
                    </button>
                </div>

                <button id="confirmButton" class="btn btn-primary btn-lg" onclick="confirmTableSelection()" style="display: none;">
                    <i class="fas fa-check-circle me-2"></i>Xác nhận chọn bàn
                </button>
            </div>

            <script>
                // Loại bỏ khai báo biến ở đây vì đã được khai báo ở cuối trang
                function toggleSelectionMode(multiSelect) {
                    window.isMultiSelectMode = multiSelect;
                    clearSelection();
                    
                    // Hiển thị/ẩn checkbox cho từng bàn
                    document.querySelectorAll('.table-checkbox').forEach(checkbox => {
                        checkbox.style.display = multiSelect ? 'block' : 'none';
                    });
                    
                    // Hiển thị/ẩn summary
                    document.getElementById('selectedTablesSummary').style.display = 
                        multiSelect ? 'block' : 'none';
                }

                function selectTable(element) {
                    if (!element.classList.contains('table-available')) {
                        alert('Bàn này không khả dụng');
                        return;
                    }

                    const tableNumber = element.dataset.tableNumber;
                    const capacity = parseInt(element.dataset.capacity);

                    if (isMultiSelectMode) {
                        const checkbox = element.querySelector('input[type="checkbox"]');
                        checkbox.checked = !checkbox.checked;
                        
                        if (checkbox.checked) {
                            // Kiểm tra nếu bàn này đã được chọn
                            if (Array.from(selectedTables).some(t => t.number === tableNumber)) {
                                alert('Bàn này đã được chọn');
                                checkbox.checked = false;
                                return;
                            }

                            selectedTables.add({
                                number: tableNumber,
                                capacity: capacity,
                                element: element
                            });
                            element.classList.add('table-selected');
                        } else {
                            // Tìm và xóa bàn khỏi selectedTables
                            selectedTables.forEach(table => {
                                if (table.number === tableNumber) {
                                    selectedTables.delete(table);
                                }
                            });
                            element.classList.remove('table-selected');
                        }
                        
                        updateSelectedTablesSummary();
                    } else {
                        // Single select mode
                        selectedTables.clear();
                        document.querySelectorAll('.table-selected').forEach(table => {
                            table.classList.remove('table-selected');
                            table.querySelector('input[type="checkbox"]').checked = false;
                        });
                        
                        selectedTables.add({
                            number: tableNumber,
                            capacity: capacity,
                            element: element
                        });
                        element.classList.add('table-selected');
                        element.querySelector('input[type="checkbox"]').checked = true;
                        
                        // Hiển thị confirm button và cập nhật summary
                        updateSelectedTablesSummary();
                    }
                }

                function updateSelectedTablesSummary() {
                    const summaryDiv = document.getElementById('selectedTablesList');
                    const totalCapacitySpan = document.getElementById('totalCapacity');
                    let totalCapacity = 0;
                    let summaryHTML = '';

                    // Sắp xếp bàn theo số thứ tự
                    const sortedTables = Array.from(selectedTables).sort((a, b) => {
                        return a.number.localeCompare(b.number, undefined, { numeric: true });
                    });

                    sortedTables.forEach(table => {
                        totalCapacity += table.capacity;
                        summaryHTML += `
                            <div class="selected-table-item d-flex justify-content-between align-items-center mb-2 p-2 border rounded">
                                <div>
                                    <strong class="text-primary">Bàn ${table.number}</strong>
                                    <span class="badge bg-info ms-2">${table.capacity} chỗ</span>
                                </div>
                                <button class="btn btn-sm btn-outline-danger" 
                                        onclick="removeTable('${table.number}')"
                                        title="Bỏ chọn bàn này">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        `;
                    });

                    if (sortedTables.length === 0) {
                        summaryHTML = '<div class="text-muted text-center">Chưa chọn bàn nào</div>';
                    }

                    summaryDiv.innerHTML = summaryHTML;

                    // Cập nhật tổng số chỗ và hiển thị thông tin
                    const requiredSeats = parseInt(document.getElementById('requiredSeats').value);
                    const capacityInfo = document.getElementById('capacityInfo');
                    
                    if (totalCapacity < requiredSeats) {
                        capacityInfo.innerHTML = `
                            <div class="alert alert-warning">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                Cần thêm ${requiredSeats - totalCapacity} chỗ ngồi nữa
                            </div>
                        `;
                        document.getElementById('confirmButton').style.display = 'none';
                    } else if (totalCapacity > requiredSeats * 1.5) {
                        capacityInfo.innerHTML = `
                            <div class="alert alert-warning">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                Số chỗ đã chọn (${totalCapacity}) nhiều hơn nhiều so với số người đặt (${requiredSeats})
                            </div>
                        `;
                        document.getElementById('confirmButton').style.display = 'inline-block';
                    } else {
                        capacityInfo.innerHTML = `
                            <div class="alert alert-success">
                                <i class="fas fa-check-circle me-2"></i>
                                Đã đủ chỗ ngồi cho ${requiredSeats} người
                            </div>
                        `;
                        document.getElementById('confirmButton').style.display = 'inline-block';
                    }

                    // Cập nhật tổng số chỗ
                    totalCapacitySpan.textContent = totalCapacity;
                }

                function removeTable(tableNumber) {
                    const table = Array.from(selectedTables).find(t => t.number === tableNumber);
                    if (table) {
                        table.element.classList.remove('table-selected');
                        table.element.querySelector('input[type="checkbox"]').checked = false;
                        selectedTables.delete(table);
                        updateSelectedTablesSummary();
                    }
                }

                function clearSelection() {
                    selectedTables.clear();
                    document.querySelectorAll('.table-selected').forEach(table => {
                        table.classList.remove('table-selected');
                    });
                    document.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
                        checkbox.checked = false;
                    });
                    updateSelectedTablesSummary();
                    document.getElementById('confirmButton').style.display = 'none';
                }

                function confirmTableSelection() {
                    if (selectedTables.size === 0) {
                        alert('Vui lòng chọn ít nhất một bàn trước khi xác nhận.');
                        return;
                    }

                    const totalCapacity = Array.from(selectedTables)
                        .reduce((sum, table) => sum + table.capacity, 0);

                    if (totalCapacity < totalRequiredSeats) {
                        alert('Số chỗ ngồi không đủ cho số người đã đặt. Vui lòng chọn thêm bàn.');
                        return;
                    }

                    // Create booking data
                    const tables = Array.from(selectedTables).map(table => table.number);
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = '${pageContext.request.contextPath}/confirm-booking';

                    // Add tables as hidden inputs
                    tables.forEach((tableNumber, index) => {
                        const input = document.createElement('input');
                        input.type = 'hidden';
                        input.name = 'selectedTables';
                        input.value = tableNumber;
                        form.appendChild(input);
                    });

                    document.body.appendChild(form);
                    form.submit();
                }

                function changeArea(areaId) {
                    // Redirect to same page with area parameter
                    window.location.href = '${pageContext.request.contextPath}/table-layout?area=' + areaId;
                }

                function filterByType(type) {
                    const tables = document.querySelectorAll('.dining-table');
                    tables.forEach(table => {
                        if (!type || table.dataset.tableType === type) {
                            table.style.display = 'flex';
                        } else {
                            table.style.display = 'none';
                        }
                    });
                }

                // Initialize on page load
                document.addEventListener('DOMContentLoaded', function() {
                    toggleSelectionMode(false);
                });
            </script>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <jsp:include page="/layouts/Footer.jsp"/>

    <!-- JavaScript -->
    <script src="<c:url value='/js/main.js'/>"></script>
    
    <script>
        // Khởi tạo các biến toàn cục
        const selectedTables = new Set();
        let isMultiSelectMode = false;
        const totalRequiredSeats = parseInt('${sessionScope.partySize}') || 0;
        
        // Hàm chọn bàn
        function selectTable(element) {
            if (!element.classList.contains('table-available')) {
                alert('Bàn này không khả dụng');
                return;
            }

            const tableNumber = element.dataset.tableNumber;
            const capacity = parseInt(element.dataset.capacity);

            // Single select mode
            selectedTables.clear();
            document.querySelectorAll('.table-selected').forEach(table => {
                table.classList.remove('table-selected');
            });
            
            selectedTables.add({
                number: tableNumber,
                capacity: capacity,
                element: element
            });
            element.classList.add('table-selected');
            
            // Hiển thị summary và cập nhật
            document.getElementById('selectedTablesSummary').style.display = 'block';
            updateSelectedTablesSummary();
        }

        // Hàm cập nhật thông tin bàn đã chọn
        function updateSelectedTablesSummary() {
            const summaryDiv = document.getElementById('selectedTablesList');
            const totalCapacitySpan = document.getElementById('totalCapacity');
            let totalCapacity = 0;
            let summaryHTML = '';

            selectedTables.forEach(table => {
                totalCapacity += table.capacity;
                summaryHTML += `
                    <div class="selected-table-item d-flex justify-content-between align-items-center mb-2 p-2 border rounded">
                        <div>
                            <strong class="text-primary">Bàn ${table.number}</strong>
                            <span class="badge bg-info ms-2">${table.capacity} chỗ</span>
                        </div>
                        <button class="btn btn-sm btn-outline-danger" onclick="removeTable('${table.number}')">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                `;
            });

            summaryDiv.innerHTML = summaryHTML || '<div class="text-muted text-center">Chưa chọn bàn nào</div>';
            totalCapacitySpan.textContent = totalCapacity;

            const capacityInfo = document.getElementById('capacityInfo');
            const confirmButton = document.getElementById('confirmButton');

            if (totalCapacity < totalRequiredSeats) {
                capacityInfo.innerHTML = `
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        Cần thêm ${totalRequiredSeats - totalCapacity} chỗ ngồi nữa
                    </div>
                `;
                confirmButton.style.display = 'none';
            } else {
                capacityInfo.innerHTML = `
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle me-2"></i>
                        Đã đủ chỗ ngồi cho ${totalRequiredSeats} người
                    </div>
                `;
                confirmButton.style.display = 'inline-block';
            }
        }

        // Hàm xóa bàn đã chọn
        function removeTable(tableNumber) {
            selectedTables.forEach(table => {
                if (table.number === tableNumber) {
                    table.element.classList.remove('table-selected');
                    selectedTables.delete(table);
                }
            });
            updateSelectedTablesSummary();
        }

        // Hàm xác nhận chọn bàn
        function confirmTableSelection() {
            if (selectedTables.size === 0) {
                alert('Vui lòng chọn ít nhất một bàn.');
                return;
            }

            const totalCapacity = Array.from(selectedTables)
                .reduce((sum, table) => sum + table.capacity, 0);

            if (totalCapacity < totalRequiredSeats) {
                alert('Số chỗ ngồi không đủ cho số người đã đặt. Vui lòng chọn thêm bàn.');
                return;
            }

            // Tạo form để submit
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/confirm-booking';

            // Thêm các bàn đã chọn vào form
            selectedTables.forEach(table => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'selectedTables';
                input.value = table.number;
                form.appendChild(input);
            });

            // Submit form
            document.body.appendChild(form);
            form.submit();
        }

        // Khởi tạo khi trang load
        document.addEventListener('DOMContentLoaded', function() {
            // Hiển thị số người cần đặt
            document.getElementById('selectedTablesSummary').style.display = 'block';
            updateSelectedTablesSummary();
        });
    </script>
</body>
</html>