<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Management - RMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .order-card {
            border: 1px solid #ddd;
            border-radius: 8px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
        }
        .order-card:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .order-card.new { border-left: 4px solid #007bff; }
        .order-card.confirmed { border-left: 4px solid #28a745; }
        .order-card.preparing { border-left: 4px solid #ffc107; }
        .order-card.ready { border-left: 4px solid #17a2b8; }
        .order-card.served { border-left: 4px solid #6c757d; }
        .order-card.completed { border-left: 4px solid #28a745; }
        .order-card.cancelled { border-left: 4px solid #dc3545; }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-new { background: #007bff; color: white; }
        .status-confirmed { background: #28a745; color: white; }
        .status-preparing { background: #ffc107; color: black; }
        .status-ready { background: #17a2b8; color: white; }
        .status-served { background: #6c757d; color: white; }
        .status-completed { background: #28a745; color: white; }
        .status-cancelled { background: #dc3545; color: white; }
        
        .priority-urgent { color: #dc3545; font-weight: bold; }
        .priority-high { color: #fd7e14; font-weight: bold; }
        .priority-normal { color: #6c757d; }
        .priority-low { color: #adb5bd; }
        
        .item-row {
            border-bottom: 1px solid #eee;
            padding: 8px 0;
        }
        .item-row:last-child {
            border-bottom: none;
        }
        
        .btn-action {
            margin: 2px;
        }
        
        .modal-header {
            background: linear-gradient(45deg, #007bff, #0056b3);
            color: white;
        }
        
        .total-amount {
            font-size: 18px;
            font-weight: bold;
            color: #28a745;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Header -->
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center py-3">
                    <h2><i class="fas fa-shopping-cart"></i> Order Management</h2>
                    <div>
                        <button class="btn btn-primary" onclick="showCreateOrderModal()">
                            <i class="fas fa-plus"></i> New Order
                        </button>
                        <button class="btn btn-secondary" onclick="refreshOrders()">
                            <i class="fas fa-sync-alt"></i> Refresh
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="row mb-3">
            <div class="col-md-3">
                <select id="statusFilter" class="form-select">
                    <option value="">All Status</option>
                    <option value="NEW">New</option>
                    <option value="CONFIRMED">Confirmed</option>
                    <option value="PREPARING">Preparing</option>
                    <option value="READY">Ready</option>
                    <option value="SERVED">Served</option>
                    <option value="COMPLETED">Completed</option>
                </select>
            </div>
            <div class="col-md-3">
                <select id="tableFilter" class="form-select">
                    <option value="">All Tables</option>
                    <!-- Will be populated by JavaScript -->
                </select>
            </div>
            <div class="col-md-3">
                <input type="text" id="searchInput" class="form-control" placeholder="Search orders...">
            </div>
            <div class="col-md-3">
                <button class="btn btn-outline-secondary" onclick="clearFilters()">
                    <i class="fas fa-times"></i> Clear Filters
                </button>
            </div>
        </div>

        <!-- Orders List -->
        <div class="row" id="ordersContainer">
            <!-- Orders will be loaded here by JavaScript -->
        </div>
    </div>

    <!-- Create Order Modal -->
    <div class="modal fade" id="createOrderModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Create New Order</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="createOrderForm">
                        <div class="mb-3">
                            <label class="form-label">Table</label>
                            <select id="orderTableId" class="form-select" required>
                                <option value="">Select Table</option>
                                <!-- Will be populated by JavaScript -->
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Order Type</label>
                            <select id="orderType" class="form-select">
                                <option value="DINE_IN">Dine In</option>
                                <option value="TAKEAWAY">Takeaway</option>
                                <option value="DELIVERY">Delivery</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Special Instructions</label>
                            <textarea id="specialInstructions" class="form-control" rows="3"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="createOrder()">Create Order</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Item Modal -->
    <div class="modal fade" id="addItemModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add Item to Order</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="addItemForm">
                        <input type="hidden" id="currentOrderId">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Menu Item</label>
                                    <select id="menuItemId" class="form-select" required>
                                        <option value="">Select Item</option>
                                        <!-- Will be populated by JavaScript -->
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="mb-3">
                                    <label class="form-label">Quantity</label>
                                    <input type="number" id="itemQuantity" class="form-control" value="1" min="1" required>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="mb-3">
                                    <label class="form-label">Priority</label>
                                    <select id="itemPriority" class="form-select">
                                        <option value="NORMAL">Normal</option>
                                        <option value="HIGH">High</option>
                                        <option value="URGENT">Urgent</option>
                                        <option value="LOW">Low</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Course</label>
                                    <select id="itemCourse" class="form-select">
                                        <option value="APPETIZER">Appetizer</option>
                                        <option value="MAIN">Main Course</option>
                                        <option value="DESSERT">Dessert</option>
                                        <option value="BEVERAGE">Beverage</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Special Instructions</label>
                                    <input type="text" id="itemSpecialInstructions" class="form-control">
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="addOrderItem()">Add Item</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let orders = [];
        let tables = [];
        let menuItems = [];

        // Load data on page load
        document.addEventListener('DOMContentLoaded', function() {
            loadTables();
            loadMenuItems();
            loadOrders();
        });

        // Load tables
        function loadTables() {
            fetch('${pageContext.request.contextPath}/tables')
                .then(response => response.json())
                .then(data => {
                    if (data.tables) {
                        tables = data.tables;
                        populateTableSelects();
                    }
                })
                .catch(error => console.error('Error loading tables:', error));
        }

        // Load menu items
        function loadMenuItems() {
            // TODO: Implement menu items API
            menuItems = [
                {itemId: 1, name: 'Pho Bo', basePrice: 15.99, category: 'MAIN'},
                {itemId: 2, name: 'Spring Rolls', basePrice: 8.99, category: 'APPETIZER'},
                {itemId: 3, name: 'Vietnamese Coffee', basePrice: 4.99, category: 'BEVERAGE'},
                {itemId: 4, name: 'Grilled Pork', basePrice: 22.99, category: 'MAIN'},
                {itemId: 5, name: 'Cheese Cake', basePrice: 6.99, category: 'DESSERT'},
                {itemId: 6, name: 'Beef Steak', basePrice: 28.99, category: 'MAIN'},
                {itemId: 7, name: 'Green Tea', basePrice: 3.99, category: 'BEVERAGE'}
            ];
            populateMenuSelect();
        }

        // Load orders
        function loadOrders() {
            fetch('${pageContext.request.contextPath}/orders')
                .then(response => response.json())
                .then(data => {
                    if (data.orders) {
                        orders = data.orders;
                        displayOrders();
                    }
                })
                .catch(error => console.error('Error loading orders:', error));
        }

        // Display orders
        function displayOrders() {
            const container = document.getElementById('ordersContainer');
            container.innerHTML = '';

            if (orders.length === 0) {
                container.innerHTML = '<div class="col-12 text-center"><p>No orders found.</p></div>';
                return;
            }

            orders.forEach(order => {
                const orderCard = createOrderCard(order);
                container.appendChild(orderCard);
            });
        }

        // Create order card
        function createOrderCard(order) {
            const col = document.createElement('div');
            col.className = 'col-md-6 col-lg-4';

            const statusClass = order.status.toLowerCase();
            const statusBadgeClass = `status-${statusClass}`;

            col.innerHTML = `
                <div class="order-card ${statusClass}">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5 class="card-title">Order #${order.orderId}</h5>
                            <span class="status-badge ${statusBadgeClass}">${order.status}</span>
                        </div>
                        
                        <div class="mb-2">
                            <strong>Table:</strong> ${order.tableNumber || 'N/A'}<br>
                            <strong>Waiter:</strong> ${order.waiterName || 'N/A'}<br>
                            <strong>Type:</strong> ${order.orderType}<br>
                            <strong>Items:</strong> ${order.items ? order.items.length : 0}
                        </div>
                        
                        ${order.specialInstructions ? `<div class="mb-2"><strong>Notes:</strong> ${order.specialInstructions}</div>` : ''}
                        
                        <div class="mb-3">
                            <div class="total-amount">$${order.totalAmount || '0.00'}</div>
                        </div>
                        
                        <div class="d-flex flex-wrap">
                            <button class="btn btn-sm btn-outline-primary btn-action" onclick="viewOrder(${order.orderId})">
                                <i class="fas fa-eye"></i> View
                            </button>
                            <button class="btn btn-sm btn-outline-success btn-action" onclick="addItemToOrder(${order.orderId})">
                                <i class="fas fa-plus"></i> Add Item
                            </button>
                            ${order.status === 'CONFIRMED' ? `
                                <button class="btn btn-sm btn-warning btn-action" onclick="sendToKitchen(${order.orderId})">
                                    <i class="fas fa-fire"></i> Send to Kitchen
                                </button>
                            ` : ''}
                            ${order.status === 'READY' ? `
                                <button class="btn btn-sm btn-info btn-action" onclick="markAsServed(${order.orderId})">
                                    <i class="fas fa-check"></i> Mark Served
                                </button>
                            ` : ''}
                        </div>
                    </div>
                </div>
            `;

            return col;
        }

        // Populate table selects
        function populateTableSelects() {
            const orderTableSelect = document.getElementById('orderTableId');
            const tableFilterSelect = document.getElementById('tableFilter');
            
            tables.forEach(table => {
                const option1 = document.createElement('option');
                option1.value = table.tableId;
                option1.textContent = `Table ${table.tableNumber} (${table.status})`;
                orderTableSelect.appendChild(option1);
                
                const option2 = document.createElement('option');
                option2.value = table.tableId;
                option2.textContent = `Table ${table.tableNumber}`;
                tableFilterSelect.appendChild(option2);
            });
        }

        // Populate menu select
        function populateMenuSelect() {
            const menuSelect = document.getElementById('menuItemId');
            menuItems.forEach(item => {
                const option = document.createElement('option');
                option.value = item.itemId;
                option.textContent = `${item.name} - $${item.basePrice}`;
                menuSelect.appendChild(option);
            });
        }

        // Show create order modal
        function showCreateOrderModal() {
            const modal = new bootstrap.Modal(document.getElementById('createOrderModal'));
            modal.show();
        }

        // Create order
        function createOrder() {
            const tableId = document.getElementById('orderTableId').value;
            const orderType = document.getElementById('orderType').value;
            const specialInstructions = document.getElementById('specialInstructions').value;

            if (!tableId) {
                alert('Please select a table');
                return;
            }

            const formData = new FormData();
            formData.append('tableId', tableId);
            formData.append('orderType', orderType);
            formData.append('specialInstructions', specialInstructions);

            fetch('${pageContext.request.contextPath}/orders', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Order created successfully!');
                    bootstrap.Modal.getInstance(document.getElementById('createOrderModal')).hide();
                    loadOrders();
                } else {
                    alert('Error: ' + data.error);
                }
            })
            .catch(error => {
                console.error('Error creating order:', error);
                alert('An error occurred while creating the order.');
            });
        }

        // Add item to order
        function addItemToOrder(orderId) {
            document.getElementById('currentOrderId').value = orderId;
            const modal = new bootstrap.Modal(document.getElementById('addItemModal'));
            modal.show();
        }

        // Add order item
        function addOrderItem() {
            const orderId = document.getElementById('currentOrderId').value;
            const menuItemId = document.getElementById('menuItemId').value;
            const quantity = document.getElementById('itemQuantity').value;
            const priority = document.getElementById('itemPriority').value;
            const course = document.getElementById('itemCourse').value;
            const specialInstructions = document.getElementById('itemSpecialInstructions').value;

            if (!menuItemId || !quantity) {
                alert('Please fill in all required fields');
                return;
            }

            const formData = new FormData();
            formData.append('menuItemId', menuItemId);
            formData.append('quantity', quantity);
            formData.append('priority', priority);
            formData.append('course', course);
            formData.append('specialInstructions', specialInstructions);

            fetch(`${pageContext.request.contextPath}/orders/${orderId}/items`, {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Item added successfully!');
                    bootstrap.Modal.getInstance(document.getElementById('addItemModal')).hide();
                    loadOrders();
                } else {
                    alert('Error: ' + data.error);
                }
            })
            .catch(error => {
                console.error('Error adding item:', error);
                alert('An error occurred while adding the item.');
            });
        }

        // Send to kitchen
        function sendToKitchen(orderId) {
            if (confirm('Are you sure you want to send this order to the kitchen?')) {
                fetch(`${pageContext.request.contextPath}/orders/${orderId}/send-to-kitchen`, {
                    method: 'POST'
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert(`Order sent to kitchen! ${data.sentCount} items sent.`);
                        loadOrders();
                    } else {
                        alert('Error: ' + data.error);
                    }
                })
                .catch(error => {
                    console.error('Error sending to kitchen:', error);
                    alert('An error occurred while sending to kitchen.');
                });
            }
        }

        // View order details
        function viewOrder(orderId) {
            fetch(`${pageContext.request.contextPath}/orders/${orderId}`)
                .then(response => response.json())
                .then(data => {
                    if (data.error) {
                        alert('Error: ' + data.error);
                    } else {
                        // TODO: Show order details in modal or new page
                        console.log('Order details:', data);
                        alert('Order details loaded. Check console for details.');
                    }
                })
                .catch(error => {
                    console.error('Error loading order details:', error);
                    alert('An error occurred while loading order details.');
                });
        }

        // Mark as served
        function markAsServed(orderId) {
            if (confirm('Mark this order as served?')) {
                // TODO: Implement mark as served
                alert('Order marked as served!');
                loadOrders();
            }
        }

        // Refresh orders
        function refreshOrders() {
            loadOrders();
        }

        // Clear filters
        function clearFilters() {
            document.getElementById('statusFilter').value = '';
            document.getElementById('tableFilter').value = '';
            document.getElementById('searchInput').value = '';
            loadOrders();
        }
    </script>
</body>
</html>
