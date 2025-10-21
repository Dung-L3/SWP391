<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bản đồ bàn - RMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .table-card {
            width: 120px;
            height: 80px;
            margin: 10px;
            cursor: pointer;
            transition: all 0.3s;
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            position: relative;
        }
        .table-card:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        .table-vacant { background-color: #d4edda; border: 2px solid #28a745; }
        .table-seated { background-color: #fff3cd; border: 2px solid #ffc107; }
        .table-in-use { background-color: #f8d7da; border: 2px solid #dc3545; }
        .table-cleaning { background-color: #d1ecf1; border: 2px solid #17a2b8; }
        .table-out-service { background-color: #e2e3e5; border: 2px solid #6c757d; }
        
        .area-section {
            margin-bottom: 30px;
            padding: 20px;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            background-color: #f8f9fa;
        }
        
        .table-grid {
            display: flex;
            flex-wrap: wrap;
            justify-content: flex-start;
        }
        
        .table-number {
            font-weight: bold;
            font-size: 14px;
        }
        .table-capacity {
            font-size: 12px;
            color: #666;
        }
        .table-status {
            font-size: 10px;
            margin-top: 2px;
        }
        
        .session-info {
            position: absolute;
            top: 2px;
            right: 2px;
            background: rgba(0,0,0,0.7);
            color: white;
            padding: 2px 4px;
            border-radius: 3px;
            font-size: 8px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-map"></i> Bản đồ bàn</h2>
                    <div>
                        <select id="areaFilter" class="form-select d-inline-block w-auto">
                            <option value="">Tất cả khu vực</option>
                            <c:forEach var="area" items="${areas}">
                                <option value="${area.areaId}" ${selectedAreaId == area.areaId ? 'selected' : ''}>
                                    ${area.areaName}
                                </option>
                            </c:forEach>
                        </select>
                        <button class="btn btn-primary ms-2" onclick="refreshTables()">
                            <i class="fas fa-sync-alt"></i> Làm mới
                        </button>
                    </div>
                </div>

                <c:forEach var="area" items="${areas}">
                    <c:if test="${selectedAreaId == null || selectedAreaId == area.areaId}">
                        <div class="area-section">
                            <h4>${area.areaName}</h4>
                            <div class="table-grid">
                                <c:forEach var="table" items="${tables}">
                                    <c:if test="${table.areaId == area.areaId}">
                                        <div class="table-card table-${table.status.toLowerCase().replace('_', '-')}" 
                                             onclick="showTableDetails(${table.tableId})"
                                             data-table-id="${table.tableId}"
                                             data-status="${table.status}">
                                            
                                            <c:if test="${table.currentSessionId != null}">
                                                <div class="session-info">
                                                    <i class="fas fa-clock"></i>
                                                </div>
                                            </c:if>
                                            
                                            <div class="table-number">${table.tableNumber}</div>
                                            <div class="table-capacity">${table.capacity} người</div>
                                            <div class="table-status">${table.statusDisplay}</div>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- Modal chi tiết bàn -->
    <div class="modal fade" id="tableModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Chi tiết bàn</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="tableDetails"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <div id="tableActions"></div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentTableId = null;

        function refreshTables() {
            const areaId = document.getElementById('areaFilter').value;
            let url = 'tables';
            if (areaId) {
                url += '?area=' + areaId;
            }
            window.location.href = url;
        }

        function showTableDetails(tableId) {
            currentTableId = tableId;
            
            fetch('tables/' + tableId)
                .then(response => response.json())
                .then(data => {
                    document.getElementById('tableDetails').innerHTML = `
                        <div class="row">
                            <div class="col-6"><strong>Số bàn:</strong></div>
                            <div class="col-6">${data.tableNumber}</div>
                        </div>
                        <div class="row">
                            <div class="col-6"><strong>Sức chứa:</strong></div>
                            <div class="col-6">${data.capacity} người</div>
                        </div>
                        <div class="row">
                            <div class="col-6"><strong>Trạng thái:</strong></div>
                            <div class="col-6">${data.status}</div>
                        </div>
                        <div class="row">
                            <div class="col-6"><strong>Khu vực:</strong></div>
                            <div class="col-6">${data.areaName}</div>
                        </div>
                        ${data.hasSession ? `
                        <div class="row">
                            <div class="col-6"><strong>Số khách:</strong></div>
                            <div class="col-6">${data.customerCount || 'Chưa xác định'}</div>
                        </div>
                        <div class="row">
                            <div class="col-6"><strong>Mở lúc:</strong></div>
                            <div class="col-6">${new Date(data.openTime).toLocaleString()}</div>
                        </div>
                        ` : ''}
                    `;

                    let actions = '';
                    if (data.status === 'VACANT') {
                        actions = `
                            <button class="btn btn-success" onclick="seatTable()">
                                <i class="fas fa-user-plus"></i> Đón khách
                            </button>
                        `;
                    } else if (data.status === 'SEATED' || data.status === 'IN_USE') {
                        actions = `
                            <button class="btn btn-warning" onclick="vacateTable()">
                                <i class="fas fa-door-open"></i> Trả bàn
                            </button>
                        `;
                    } else if (data.status === 'CLEANING') {
                        actions = `
                            <button class="btn btn-info" onclick="cleanTable()">
                                <i class="fas fa-broom"></i> Hoàn thành dọn dẹp
                            </button>
                        `;
                    }
                    
                    document.getElementById('tableActions').innerHTML = actions;
                    
                    const modal = new bootstrap.Modal(document.getElementById('tableModal'));
                    modal.show();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Lỗi khi tải thông tin bàn');
                });
        }

        function seatTable() {
            const customerCount = prompt('Số lượng khách:', '');
            if (customerCount === null) return;
            
            const notes = prompt('Ghi chú (tùy chọn):', '');
            
            fetch('tables/' + currentTableId + '/seat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'customerCount=' + encodeURIComponent(customerCount) + 
                      '&notes=' + encodeURIComponent(notes || '')
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Đón khách thành công!');
                    location.reload();
                } else {
                    alert('Lỗi khi đón khách!');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Lỗi khi đón khách!');
            });
        }

        function vacateTable() {
            if (!confirm('Xác nhận trả bàn?')) return;
            
            fetch('tables/' + currentTableId + '/vacate', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Trả bàn thành công!');
                    location.reload();
                } else {
                    alert('Lỗi khi trả bàn!');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Lỗi khi trả bàn!');
            });
        }

        function cleanTable() {
            if (!confirm('Xác nhận hoàn thành dọn dẹp?')) return;
            
            fetch('tables/' + currentTableId + '/clean', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Hoàn thành dọn dẹp!');
                    location.reload();
                } else {
                    alert('Lỗi khi hoàn thành dọn dẹp!');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Lỗi khi hoàn thành dọn dẹp!');
            });
        }

        // Lọc theo khu vực
        document.getElementById('areaFilter').addEventListener('change', function() {
            refreshTables();
        });
    </script>
</body>
</html>

