<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gọi Món - RMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .menu-category {
            background: linear-gradient(45deg, #007bff, #0056b3);
            color: white;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .menu-item-card {
            border: 1px solid #ddd;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
            background: white;
        }
        
        .menu-item-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            transform: translateY(-2px);
        }
        
        .menu-item-image {
            width: 100%;
            height: 150px;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 10px;
        }
        
        .menu-item-name {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }
        
        .menu-item-description {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }
        
        .menu-item-price {
            font-size: 18px;
            font-weight: bold;
            color: #28a745;
            margin-bottom: 10px;
        }
        
        .quantity-controls {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .quantity-btn {
            width: 35px;
            height: 35px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .quantity-btn:hover {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        .quantity-input {
            width: 60px;
            text-align: center;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 5px;
        }
        
        .add-to-cart-btn {
            background: linear-gradient(45deg, #28a745, #20c997);
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 20px;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        
        .add-to-cart-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(40, 167, 69, 0.3);
        }
        
        .cart-sidebar {
            background: #f8f9fa;
            border-left: 1px solid #ddd;
            height: 100vh;
            position: fixed;
            right: 0;
            top: 0;
            width: 350px;
            z-index: 1000;
            transform: translateX(100%);
            transition: transform 0.3s ease;
            overflow-y: auto;
        }
        
        .cart-sidebar.show {
            transform: translateX(0);
        }
        
        .cart-item {
            border-bottom: 1px solid #eee;
            padding: 15px;
        }
        
        .cart-item-name {
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .cart-item-details {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }
        
        .cart-item-controls {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .cart-total {
            background: #007bff;
            color: white;
            padding: 20px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
        }
        
        .order-actions {
            padding: 20px;
            border-top: 1px solid #ddd;
        }
        
        .btn-order {
            width: 100%;
            padding: 12px;
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .special-instructions {
            margin-top: 10px;
        }
        
        .special-instructions textarea {
            width: 100%;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 10px;
            resize: vertical;
        }
        
        .table-info {
            background: linear-gradient(45deg, #6c757d, #495057);
            color: white;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .priority-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .priority-urgent { background: #dc3545; color: white; }
        .priority-high { background: #fd7e14; color: white; }
        .priority-normal { background: #6c757d; color: white; }
        .priority-low { background: #adb5bd; color: white; }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Header -->
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center py-3">
                    <div class="table-info">
                        <h4><i class="fas fa-utensils"></i> Gọi Món - Bàn <span id="tableNumber">1</span></h4>
                        <p class="mb-0">Waiter: <span id="waiterName">John Doe</span></p>
                    </div>
                    <div>
                        <button class="btn btn-outline-primary" onclick="toggleCart()">
                            <i class="fas fa-shopping-cart"></i> Giỏ Hàng (<span id="cartCount">0</span>)
                        </button>
                        <button class="btn btn-secondary" onclick="goBackToTables()">
                            <i class="fas fa-arrow-left"></i> Quay Lại
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Menu Categories -->
        <div class="row">
            <div class="col-12">
                <div class="menu-category">
                    <h3><i class="fas fa-list"></i> Thực Đơn</h3>
                </div>
            </div>
        </div>

        <!-- Menu Items -->
        <div class="row" id="menuContainer">
            <!-- Menu items will be loaded here -->
        </div>
    </div>

    <!-- Cart Sidebar -->
    <div class="cart-sidebar" id="cartSidebar">
        <div class="p-3">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5><i class="fas fa-shopping-cart"></i> Giỏ Hàng</h5>
                <button class="btn btn-sm btn-outline-secondary" onclick="toggleCart()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div id="cartItems">
                <!-- Cart items will be displayed here -->
            </div>
            
            <div class="cart-total">
                Tổng: $<span id="cartTotal">0.00</span>
            </div>
            
            <div class="order-actions">
                <div class="special-instructions">
                    <label class="form-label">Ghi chú đặc biệt:</label>
                    <textarea id="specialInstructions" rows="3" placeholder="Nhập ghi chú cho đơn hàng..."></textarea>
                </div>
                
                <div class="mt-3">
                    <label class="form-label">Độ ưu tiên:</label>
                    <select id="orderPriority" class="form-select">
                        <option value="NORMAL">Bình thường</option>
                        <option value="HIGH">Cao</option>
                        <option value="URGENT">Khẩn cấp</option>
                        <option value="LOW">Thấp</option>
                    </select>
                </div>
                
                <button class="btn btn-primary btn-order" onclick="createOrder()">
                    <i class="fas fa-check"></i> Tạo Đơn Hàng
                </button>
                
                <button class="btn btn-outline-danger btn-order" onclick="clearCart()">
                    <i class="fas fa-trash"></i> Xóa Giỏ Hàng
                </button>
            </div>
        </div>
    </div>

    <!-- Overlay -->
    <div class="position-fixed top-0 start-0 w-100 h-100 bg-dark" 
         style="z-index: 999; opacity: 0; visibility: hidden; transition: all 0.3s ease;" 
         id="overlay" onclick="toggleCart()"></div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let cart = [];
        let menuItems = [];
        let currentTableId = null;
        let currentWaiterId = null;

        // Load data on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Get table ID and waiter info from URL parameters or session
            const urlParams = new URLSearchParams(window.location.search);
            currentTableId = urlParams.get('tableId') || 1;
            currentWaiterId = 1; // TODO: Get from session
            
            document.getElementById('tableNumber').textContent = currentTableId;
            
            // Load table details
            loadTableDetails();
            loadMenuItems();
            loadCartFromStorage();
        });

        // Load table details
        function loadTableDetails() {
            if (!currentTableId) return;
            
            fetch('${pageContext.request.contextPath}/tables/' + currentTableId)
                .then(response => response.json())
                .then(data => {
                    if (data.error) {
                        console.error('Error loading table details:', data.error);
                        return;
                    }
                    
                    document.getElementById('tableNumber').textContent = data.tableNumber;
                    // TODO: Load waiter name from session
                })
                .catch(error => {
                    console.error('Error loading table details:', error);
                });
        }

        // Load menu items
        function loadMenuItems() {
            // Sample menu data - TODO: Load from API
            menuItems = [
                {
                    itemId: 1,
                    name: 'Phở Bò',
                    description: 'Phở bò truyền thống với thịt bò tái, bánh phở mềm',
                    price: 15.99,
                    image: '${pageContext.request.contextPath}/img/menu-1.jpg',
                    category: 'MAIN'
                },
                {
                    itemId: 2,
                    name: 'Chả Giò',
                    description: 'Nem rán giòn tan với tôm và thịt heo',
                    price: 8.99,
                    image: '${pageContext.request.contextPath}/img/menu-2.jpg',
                    category: 'APPETIZER'
                },
                {
                    itemId: 3,
                    name: 'Cà Phê Sữa Đá',
                    description: 'Cà phê phin truyền thống với sữa đặc',
                    price: 4.99,
                    image: '${pageContext.request.contextPath}/img/menu-3.jpg',
                    category: 'BEVERAGE'
                },
                {
                    itemId: 4,
                    name: 'Thịt Nướng',
                    description: 'Thịt heo nướng với nước mắm pha chế đặc biệt',
                    price: 22.99,
                    image: '${pageContext.request.contextPath}/img/menu-4.jpg',
                    category: 'MAIN'
                },
                {
                    itemId: 5,
                    name: 'Bánh Flan',
                    description: 'Bánh flan caramel ngọt ngào',
                    price: 6.99,
                    image: '${pageContext.request.contextPath}/img/menu-5.jpg',
                    category: 'DESSERT'
                },
                {
                    itemId: 6,
                    name: 'Bò Steak',
                    description: 'Bò steak nướng vừa tái với khoai tây chiên',
                    price: 28.99,
                    image: '${pageContext.request.contextPath}/img/menu-6.jpg',
                    category: 'MAIN'
                },
                {
                    itemId: 7,
                    name: 'Trà Đá',
                    description: 'Trà đá mát lạnh giải nhiệt',
                    price: 3.99,
                    image: '${pageContext.request.contextPath}/img/menu-7.jpg',
                    category: 'BEVERAGE'
                },
                {
                    itemId: 8,
                    name: 'Bánh Mì Pate',
                    description: 'Bánh mì pate với chả lụa và rau thơm',
                    price: 7.99,
                    image: '${pageContext.request.contextPath}/img/menu-8.jpg',
                    category: 'MAIN'
                }
            ];
            
            displayMenuItems();
        }

        // Display menu items
        function displayMenuItems() {
            const container = document.getElementById('menuContainer');
            container.innerHTML = '';

            // Group items by category
            const categories = {
                'APPETIZER': { name: 'Khai Vị', items: [] },
                'MAIN': { name: 'Món Chính', items: [] },
                'BEVERAGE': { name: 'Đồ Uống', items: [] },
                'DESSERT': { name: 'Tráng Miệng', items: [] }
            };

            menuItems.forEach(item => {
                if (categories[item.category]) {
                    categories[item.category].items.push(item);
                }
            });

            // Display each category
            Object.keys(categories).forEach(categoryKey => {
                const category = categories[categoryKey];
                if (category.items.length === 0) return;

                // Category header
                const categoryDiv = document.createElement('div');
                categoryDiv.className = 'col-12';
                categoryDiv.innerHTML = `
                    <div class="menu-category">
                        <h4><i class="fas fa-utensils"></i> ${category.name}</h4>
                    </div>
                `;
                container.appendChild(categoryDiv);

                // Items in category
                category.items.forEach(item => {
                    const itemDiv = document.createElement('div');
                    itemDiv.className = 'col-md-6 col-lg-4 col-xl-3';
                    itemDiv.innerHTML = createMenuItemHTML(item);
                    container.appendChild(itemDiv);
                });
            });
        }

        // Create menu item HTML
        function createMenuItemHTML(item) {
            const cartItem = cart.find(ci => ci.itemId === item.itemId);
            const quantity = cartItem ? cartItem.quantity : 0;

            return `
                <div class="menu-item-card">
                    <img src="${item.image}" alt="${item.name}" class="menu-item-image" 
                         onerror="this.src='${pageContext.request.contextPath}/img/menu-1.jpg'">
                    <div class="menu-item-name">${item.name}</div>
                    <div class="menu-item-description">${item.description}</div>
                    <div class="menu-item-price">$${item.price.toFixed(2)}</div>
                    
                    <div class="quantity-controls">
                        <button class="quantity-btn" onclick="decreaseQuantity(${item.itemId})">
                            <i class="fas fa-minus"></i>
                        </button>
                        <input type="number" class="quantity-input" id="qty-${item.itemId}" 
                               value="${quantity}" min="0" onchange="updateQuantity(${item.itemId}, this.value)">
                        <button class="quantity-btn" onclick="increaseQuantity(${item.itemId})">
                            <i class="fas fa-plus"></i>
                        </button>
                    </div>
                    
                    <button class="btn add-to-cart-btn w-100 mt-2" 
                            onclick="addToCart(${item.itemId})" 
                            ${quantity > 0 ? 'style="display:none;"' : ''}>
                        <i class="fas fa-plus"></i> Thêm Vào Giỏ
                    </button>
                </div>
            `;
        }

        // Cart functions
        function addToCart(itemId) {
            const item = menuItems.find(i => i.itemId === itemId);
            if (!item) return;

            const existingItem = cart.find(ci => ci.itemId === itemId);
            if (existingItem) {
                existingItem.quantity += 1;
            } else {
                cart.push({
                    itemId: item.itemId,
                    name: item.name,
                    price: item.price,
                    quantity: 1,
                    specialInstructions: ''
                });
            }

            updateCartDisplay();
            saveCartToStorage();
        }

        function increaseQuantity(itemId) {
            const item = cart.find(ci => ci.itemId === itemId);
            if (item) {
                item.quantity += 1;
            } else {
                addToCart(itemId);
                return;
            }
            updateCartDisplay();
            saveCartToStorage();
        }

        function decreaseQuantity(itemId) {
            const item = cart.find(ci => ci.itemId === itemId);
            if (item) {
                item.quantity -= 1;
                if (item.quantity <= 0) {
                    cart = cart.filter(ci => ci.itemId !== itemId);
                }
            }
            updateCartDisplay();
            saveCartToStorage();
        }

        function updateQuantity(itemId, quantity) {
            const qty = parseInt(quantity) || 0;
            if (qty <= 0) {
                cart = cart.filter(ci => ci.itemId !== itemId);
            } else {
                const item = cart.find(ci => ci.itemId === itemId);
                if (item) {
                    item.quantity = qty;
                } else {
                    addToCart(itemId);
                    const newItem = cart.find(ci => ci.itemId === itemId);
                    newItem.quantity = qty;
                }
            }
            updateCartDisplay();
            saveCartToStorage();
        }

        function updateCartDisplay() {
            // Update cart count
            const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
            document.getElementById('cartCount').textContent = totalItems;

            // Update cart items display
            const cartItemsContainer = document.getElementById('cartItems');
            if (cart.length === 0) {
                cartItemsContainer.innerHTML = '<p class="text-center text-muted">Giỏ hàng trống</p>';
            } else {
                cartItemsContainer.innerHTML = cart.map(item => `
                    <div class="cart-item">
                        <div class="cart-item-name">${item.name}</div>
                        <div class="cart-item-details">
                            $${item.price.toFixed(2)} x ${item.quantity} = $${(item.price * item.quantity).toFixed(2)}
                        </div>
                        <div class="cart-item-controls">
                            <div class="quantity-controls">
                                <button class="quantity-btn" onclick="decreaseQuantity(${item.itemId})">
                                    <i class="fas fa-minus"></i>
                                </button>
                                <span>${item.quantity}</span>
                                <button class="quantity-btn" onclick="increaseQuantity(${item.itemId})">
                                    <i class="fas fa-plus"></i>
                                </button>
                            </div>
                            <button class="btn btn-sm btn-outline-danger" onclick="removeFromCart(${item.itemId})">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                `).join('');
            }

            // Update total
            const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            document.getElementById('cartTotal').textContent = total.toFixed(2);

            // Update menu display
            displayMenuItems();
        }

        function removeFromCart(itemId) {
            cart = cart.filter(ci => ci.itemId !== itemId);
            updateCartDisplay();
            saveCartToStorage();
        }

        function clearCart() {
            if (confirm('Bạn có chắc muốn xóa tất cả món trong giỏ hàng?')) {
                cart = [];
                updateCartDisplay();
                saveCartToStorage();
            }
        }

        function toggleCart() {
            const sidebar = document.getElementById('cartSidebar');
            const overlay = document.getElementById('overlay');
            
            sidebar.classList.toggle('show');
            overlay.style.opacity = sidebar.classList.contains('show') ? '0.5' : '0';
            overlay.style.visibility = sidebar.classList.contains('show') ? 'visible' : 'hidden';
        }

        function createOrder() {
            if (cart.length === 0) {
                alert('Giỏ hàng trống! Vui lòng chọn món ăn.');
                return;
            }

            const specialInstructions = document.getElementById('specialInstructions').value;
            const priority = document.getElementById('orderPriority').value;

            // Create order
            const formData = new FormData();
            formData.append('tableId', currentTableId);
            formData.append('orderType', 'DINE_IN');
            formData.append('specialInstructions', specialInstructions);

            fetch('${pageContext.request.contextPath}/orders', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const orderId = data.orderId;
                    addItemsToOrder(orderId, priority);
                } else {
                    alert('Lỗi tạo đơn hàng: ' + data.error);
                }
            })
            .catch(error => {
                console.error('Error creating order:', error);
                alert('Có lỗi xảy ra khi tạo đơn hàng.');
            });
        }

        function addItemsToOrder(orderId, priority) {
            let completed = 0;
            let totalItems = cart.length;

            cart.forEach(item => {
                const formData = new FormData();
                formData.append('menuItemId', item.itemId);
                formData.append('quantity', item.quantity);
                formData.append('priority', priority);
                formData.append('course', 'MAIN'); // TODO: Determine course based on category
                formData.append('specialInstructions', item.specialInstructions);

                fetch(`${pageContext.request.contextPath}/orders/${orderId}/items`, {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.json())
                .then(data => {
                    completed++;
                    if (completed === totalItems) {
                        alert('Đơn hàng đã được tạo thành công!');
                        cart = [];
                        updateCartDisplay();
                        saveCartToStorage();
                        toggleCart();
                    }
                })
                .catch(error => {
                    console.error('Error adding item to order:', error);
                    completed++;
                });
            });
        }

        function goBackToTables() {
            window.location.href = '${pageContext.request.contextPath}/tables';
        }

        function saveCartToStorage() {
            localStorage.setItem('orderCart', JSON.stringify(cart));
        }

        function loadCartFromStorage() {
            const saved = localStorage.getItem('orderCart');
            if (saved) {
                cart = JSON.parse(saved);
                updateCartDisplay();
            }
        }
    </script>
</body>
</html>
