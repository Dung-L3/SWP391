<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kitchen Display System (KDS) - RMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .kds-container {
            background: #1a1a1a;
            color: #fff;
            min-height: 100vh;
            font-family: 'Courier New', monospace;
        }
        .station-header {
            background: linear-gradient(45deg, #ff6b35, #f7931e);
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 8px;
        }
        .ticket-card {
            background: #2d2d2d;
            border: 2px solid #444;
            border-radius: 8px;
            margin-bottom: 15px;
            padding: 15px;
            transition: all 0.3s ease;
        }
        .ticket-card:hover {
            border-color: #ff6b35;
            transform: translateY(-2px);
        }
        .ticket-card.urgent {
            border-color: #ff0000;
            background: #3d1a1a;
        }
        .ticket-card.high-priority {
            border-color: #ff6b35;
            background: #3d2a1a;
        }
        .ticket-card.ready {
            border-color: #00ff00;
            background: #1a3d1a;
        }
        .status-badge {
            padding: 5px 10px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 12px;
        }
        .status-received { background: #007bff; }
        .status-cooking { background: #ffc107; color: #000; }
        .status-ready { background: #28a745; }
        .status-picked { background: #6c757d; }
        .status-served { background: #17a2b8; }
        .priority-urgent { color: #ff0000; font-weight: bold; }
        .priority-high { color: #ff6b35; font-weight: bold; }
        .priority-normal { color: #fff; }
        .priority-low { color: #ccc; }
        .timer {
            font-size: 18px;
            font-weight: bold;
            color: #ff6b35;
        }
        .station-filter {
            background: #333;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .btn-kds {
            background: #ff6b35;
            border: none;
            color: white;
            padding: 8px 16px;
            border-radius: 4px;
            margin: 2px;
        }
        .btn-kds:hover {
            background: #e55a2b;
            color: white;
        }
        .btn-kds:disabled {
            background: #666;
            color: #999;
        }
    </style>
</head>
<body>
    <jsp:include page="../layouts/ChefHeader.jsp" />
    <div class="kds-container">
        <div class="container-fluid">
            <!-- Header -->
            <div class="row">
                <div class="col-12">
                    <div class="station-header text-center">
                        <h1><i class="fas fa-fire"></i> Kitchen Display System</h1>
                        <p class="mb-0">Real-time Order Management</p>
                    </div>
                </div>
            </div>

            <!-- Filters -->
            <div class="row">
                <div class="col-12">
                    <div class="station-filter">
                        <div class="row align-items-center">
                            <div class="col-md-3">
                                <label class="form-label text-white">Station:</label>
                                <select id="stationFilter" class="form-select">
                                    <option value="">All Stations</option>
                                    <option value="HOT" ${param.station == 'HOT' ? 'selected' : ''}>Hot Kitchen</option>
                                    <option value="COLD" ${param.station == 'COLD' ? 'selected' : ''}>Cold Kitchen</option>
                                    <option value="BEVERAGE" ${param.station == 'BEVERAGE' ? 'selected' : ''}>Beverage</option>
                                    <option value="DESSERT" ${param.station == 'DESSERT' ? 'selected' : ''}>Dessert</option>
                                    <option value="GRILL" ${param.station == 'GRILL' ? 'selected' : ''}>Grill</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label text-white">Status:</label>
                                <select id="statusFilter" class="form-select">
                                    <option value="">All Status</option>
                                    <option value="RECEIVED" ${param.status == 'RECEIVED' ? 'selected' : ''}>Received</option>
                                    <option value="COOKING" ${param.status == 'COOKING' ? 'selected' : ''}>Cooking</option>
                                    <option value="READY" ${param.status == 'READY' ? 'selected' : ''}>Ready</option>
                                    <option value="PICKED" ${param.status == 'PICKED' ? 'selected' : ''}>Picked</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <button class="btn btn-kds" onclick="refreshTickets()">
                                    <i class="fas fa-sync-alt"></i> Refresh
                                </button>
                                <button class="btn btn-kds" onclick="clearFilters()">
                                    <i class="fas fa-times"></i> Clear
                                </button>
                            </div>
                            <div class="col-md-3 text-end">
                                <div class="timer" id="currentTime"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Active Tickets (RECEIVED, COOKING) -->
            <div class="row mb-4">
                <div class="col-12">
                    <h3 class="text-center mb-3"><i class="fas fa-clipboard-list"></i> Món đang làm</h3>
                </div>
                <div class="row" id="ticketsContainer">
                    <c:choose>
                        <c:when test="${not empty tickets}">
                            <c:forEach var="ticket" items="${tickets}">
                            <div class="col-md-6 col-lg-4">
                                <div class="ticket-card" data-ticket-id="${ticket.kitchenTicketId}" data-status="${ticket.preparationStatus}">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h5 class="mb-0">#${ticket.kitchenTicketId}</h5>
                                        <span class="status-badge status-${ticket.preparationStatus.toLowerCase()}">${ticket.preparationStatus}</span>
                                    </div>
                                    
                                    <div class="mb-2">
                                        <strong>Table:</strong> ${ticket.tableNumber}<br>
                                        <strong>Item:</strong> ${ticket.menuItemName}<br>
                                        <strong>Qty:</strong> ${ticket.quantity}<br>
                                        <strong>Station:</strong> ${ticket.station}
                                    </div>
                                    
                                    <c:if test="${not empty ticket.specialInstructions}">
                                        <div class="mb-2">
                                            <strong>Notes:</strong> ${ticket.specialInstructions}
                                        </div>
                                    </c:if>
                                    
                                    <div class="mb-2">
                                        <strong>Priority:</strong> 
                                        <span class="priority-${ticket.priority.toLowerCase()}">${ticket.priority}</span>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <strong>Course:</strong> ${ticket.course}
                                    </div>
                                    
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div class="timer" id="timer-${ticket.kitchenTicketId}">
                                            <i class="fas fa-clock"></i> 00:00
                                        </div>
                                        <div>
                                            <c:choose>
                                                <c:when test="${ticket.preparationStatus == 'RECEIVED'}">
                                                    <button class="btn btn-kds btn-sm" onclick="updateStatus(${ticket.kitchenTicketId}, 'COOKING')">
                                                        <i class="fas fa-play"></i> Start
                                                    </button>
                                                </c:when>
                                                <c:when test="${ticket.preparationStatus == 'COOKING'}">
                                                    <button class="btn btn-kds btn-sm" onclick="updateStatus(${ticket.kitchenTicketId}, 'READY')">
                                                        <i class="fas fa-check"></i> Ready
                                                    </button>
                                                </c:when>
                                                <c:when test="${ticket.preparationStatus == 'READY'}">
                                                    <button class="btn btn-kds btn-sm" onclick="updateStatus(${ticket.kitchenTicketId}, 'PICKED')">
                                                        <i class="fas fa-hand-paper"></i> Picked
                                                    </button>
                                                </c:when>
                                                <c:when test="${ticket.preparationStatus == 'PICKED'}">
                                                    <button class="btn btn-kds btn-sm" onclick="updateStatus(${ticket.kitchenTicketId}, 'SERVED')">
                                                        <i class="fas fa-check-double"></i> Served
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="btn btn-kds btn-sm" disabled>
                                                        <i class="fas fa-check"></i> Complete
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="col-12 text-center">
                                <div class="ticket-card">
                                    <h3><i class="fas fa-utensils"></i></h3>
                                    <p>Không có món nào đang làm.</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Completed Tickets (READY) -->
            <div class="row">
                <div class="col-12">
                    <h3 class="text-center mb-3"><i class="fas fa-check-circle"></i> Món đã xong</h3>
                </div>
                <div class="row" id="completedContainer">
                    <c:choose>
                        <c:when test="${not empty completedTickets}">
                            <c:forEach var="ticket" items="${completedTickets}">
                                <div class="col-md-6 col-lg-4">
                                    <div class="ticket-card ready" data-ticket-id="${ticket.kitchenTicketId}" data-status="${ticket.preparationStatus}">
                                        <div class="d-flex justify-content-between align-items-start mb-2">
                                            <h5 class="mb-0">#${ticket.kitchenTicketId}</h5>
                                            <span class="status-badge status-ready">READY</span>
                                        </div>
                                        
                                        <div class="mb-2">
                                            <strong>Table:</strong> ${ticket.tableNumber}<br>
                                            <strong>Item:</strong> ${ticket.menuItemName}<br>
                                            <strong>Qty:</strong> ${ticket.quantity}<br>
                                            <strong>Station:</strong> ${ticket.station}
                                        </div>
                                        
                                        <c:if test="${not empty ticket.specialInstructions}">
                                            <div class="mb-2">
                                                <strong>Notes:</strong> ${ticket.specialInstructions}
                                            </div>
                                        </c:if>
                                        
                                        <div class="mb-2">
                                            <strong>Priority:</strong> 
                                            <span class="priority-${ticket.priority.toLowerCase()}">${ticket.priority}</span>
                                        </div>
                                        
                                        <div class="mb-3">
                                            <strong>Course:</strong> ${ticket.course}
                                        </div>
                                        
                                        <div class="text-center">
                                            <span class="text-success"><i class="fas fa-check-circle"></i> Đã xong - Chờ phục vụ</span>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="col-12 text-center">
                                <div class="ticket-card">
                                    <h3><i class="fas fa-utensils"></i></h3>
                                    <p>Không có món nào đã xong.</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Update current time
        function updateCurrentTime() {
            const now = new Date();
            const timeString = now.toLocaleTimeString('vi-VN');
            document.getElementById('currentTime').textContent = timeString;
        }
        
        // Update every second
        setInterval(updateCurrentTime, 1000);
        updateCurrentTime();

        // Filter functions
        function refreshTickets() {
            const station = document.getElementById('stationFilter').value;
            const status = document.getElementById('statusFilter').value;
            
            let url = '${pageContext.request.contextPath}/kds?';
            if (station) url += 'station=' + station + '&';
            if (status) url += 'status=' + status;
            
            window.location.href = url;
        }

        function clearFilters() {
            document.getElementById('stationFilter').value = '';
            document.getElementById('statusFilter').value = '';
            window.location.href = '${pageContext.request.contextPath}/kds';
        }

        // Update ticket status
        function updateStatus(ticketId, newStatus) {
            if (confirm('Are you sure you want to update this ticket status to ' + newStatus + '?')) {
                fetch('${pageContext.request.contextPath}/kds/tickets/' + ticketId, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'status=' + newStatus
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        location.reload();
                    } else {
                        alert('Error: ' + data.error);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while updating the ticket status.');
                });
            }
        }

        // Auto-refresh every 30 seconds
        setInterval(refreshTickets, 30000);

        // Add event listeners for filters
        document.getElementById('stationFilter').addEventListener('change', refreshTickets);
        document.getElementById('statusFilter').addEventListener('change', refreshTickets);
    </script>
</body>
</html>
