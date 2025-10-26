<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử gọi món - RMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .history-card {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            background: white;
        }
        .status-badge {
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-new { background-color: #cfe2ff; color: #084298; }
        .status-cooking { background-color: #fff3cd; color: #856404; }
        .status-ready { background-color: #d1e7dd; color: #0f5132; }
        .status-served { background-color: #d4edda; color: #155724; }
        .status-cancelled { background-color: #f8d7da; color: #721c24; }
        
        .priority-badge {
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
        }
        .priority-normal { background-color: #e7f3ff; color: #0066cc; }
        .priority-high { background-color: #ffe7d0; color: #cc4400; }
        .priority-urgent { background-color: #ffcccc; color: #cc0000; }
        
        .course-badge {
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            background-color: #f0f0f0;
            color: #555;
        }
    </style>
</head>
<body>
    <jsp:include page="../layouts/WaiterHeader.jsp" />
    <div class="container-fluid mt-4">
        <!-- Show success/error messages -->
        <c:if test="${not empty param.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle"></i> ${param.success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle"></i> ${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <!-- Header -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <h2>
                        <i class="fas fa-history"></i> Lịch sử gọi món - Bàn ${tableId}
                    </h2>
                    <div>
                        <a href="javascript:history.back()" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                        <a href="/tables?action=map" class="btn btn-primary">
                            <i class="fas fa-map"></i> Bản đồ bàn
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Summary Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h5 class="card-title text-primary">${history.size()}</h5>
                        <p class="card-text">Tổng số món</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h5 class="card-title text-success">
                            ${history.stream().filter(item -> 'READY'.equals(item.status)).count()}
                        </h5>
                        <p class="card-text">Sẵn sàng phục vụ</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h5 class="card-title text-info">
                            ${history.stream().filter(item -> 'SERVED'.equals(item.status)).count()}
                        </h5>
                        <p class="card-text">Đã phục vụ</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h5 class="card-title text-warning">
                            ${history.stream().filter(item -> 'COOKING'.equals(item.status)).count()}
                        </h5>
                        <p class="card-text">Đang chế biến</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- History List -->
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-list"></i> Chi tiết món đã gọi</h5>
                    </div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty history}">
                                <div class="alert alert-info text-center">
                                    <i class="fas fa-info-circle"></i> Chưa có món nào được gọi cho bàn này.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Món ăn</th>
                                                <th>Số lượng</th>
                                                <th>Mục</th>
                                                <th>Trạng thái</th>
                                                <th>Ưu tiên</th>
                                                <th>Ghi chú</th>
                                                <th>Thời gian</th>
                                                <th>Hành động</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${history}">
                                                <tr>
                                                    <td>
                                                        <strong>${item.menuItemName}</strong>
                                                    </td>
                                                    <td>${item.quantity}</td>
                                                    <td>
                                                        <span class="course-badge">${item.course}</span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${item.status == 'NEW'}">
                                                                <span class="status-badge status-new">Mới</span>
                                                            </c:when>
                                                            <c:when test="${item.status == 'COOKING'}">
                                                                <span class="status-badge status-cooking">Đang nấu</span>
                                                            </c:when>
                                                            <c:when test="${item.status == 'READY'}">
                                                                <span class="status-badge status-ready">Sẵn sàng</span>
                                                            </c:when>
                                                            <c:when test="${item.status == 'SERVED'}">
                                                                <span class="status-badge status-served">Đã phục vụ</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-badge status-cancelled">${item.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${item.priority == 'NORMAL'}">
                                                                <span class="priority-badge priority-normal">Bình thường</span>
                                                            </c:when>
                                                            <c:when test="${item.priority == 'HIGH'}">
                                                                <span class="priority-badge priority-high">Cao</span>
                                                            </c:when>
                                                            <c:when test="${item.priority == 'URGENT'}">
                                                                <span class="priority-badge priority-urgent">Khẩn cấp</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="priority-badge priority-normal">${item.priority}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:if test="${not empty item.specialInstructions}">
                                                            <i class="fas fa-sticky-note"></i> ${item.specialInstructions}
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:if test="${not empty item.createdAt}">
                                                            ${item.createdAt}
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:if test="${item.status == 'READY'}">
                                                            <button class="btn btn-sm btn-success" onclick="markAsServed(${item.orderItemId})">
                                                                <i class="fas fa-check"></i> Phục vụ
                                                            </button>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function markAsServed(itemId) {
            if (!confirm('Xác nhận đã phục vụ món này?')) {
                return;
            }
            
            // Get tableId from URL
            const urlParams = new URLSearchParams(window.location.search);
            const tableId = urlParams.get('tableId');
            
            console.log('Submitting serve request for itemId: ' + itemId + ', tableId: ' + tableId);
            
            // Create a form and submit it
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/orders/' + itemId + '/serve';
            
            // Add tableId as hidden input
            const tableIdInput = document.createElement('input');
            tableIdInput.type = 'hidden';
            tableIdInput.name = 'tableId';
            tableIdInput.value = tableId || '';
            form.appendChild(tableIdInput);
            
            document.body.appendChild(form);
            form.submit();
        }
    </script>
</body>
</html>

