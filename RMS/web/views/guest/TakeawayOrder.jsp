<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "menu");
    request.setAttribute("overlayNav", false);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Đặt món mang đi | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <!-- Fonts & Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Bootstrap & Template CSS -->
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">
    <!-- Match homepage fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&display=swap" rel="stylesheet">
    
    <style>
        .menu-card { border-radius: 12px; overflow: hidden; }
        .menu-item-img { width:100%; height:160px; object-fit:cover; border-radius:8px; }
        .cart-section { position: sticky; top: 20px; }
        .cart-thumb { width:48px; height:48px; object-fit:cover; border-radius:6px; margin-right:0.75rem; }
        .cart-item-row { display:flex; align-items:center; gap:0.5rem; }
    </style>
</head>
<body>
    <%@ include file="/layouts/Header.jsp" %>

    <div class="container py-4">
        <!-- Page header -->
        <div class="page-header mb-4 d-flex justify-content-between align-items-center">
            <div>
                <h3 class="mb-0">Đặt món mang đi</h3>
            </div>
        </div>

        <!-- Flash messages -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success">${sessionScope.successMessage}</div>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger">${sessionScope.errorMessage}</div>
        </c:if>

        <div class="row">
            <div class="col-lg-8">
                <div class="card mb-4">
                    <div class="card-body">
                        <c:forEach items="${categories}" var="category">
                            <h5 class="section-title">${category.categoryName}</h5>
                            <div class="row mt-3">
                                <c:forEach items="${menuItems}" var="item">
                                    <c:if test="${item.categoryId eq category.categoryId}">
                                        <div class="col-md-6 mb-4">
                                            <div class="card menu-card p-3" data-item-id="${item.itemId}">
                                                <img src="${item.imageUrl}" alt="${item.name}" class="menu-item-img mb-3">
                                                <h6 class="mb-1">${item.name}</h6>
                                                <p class="text-muted small mb-2">${item.description}</p>
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <div class="fw-semibold text-primary">
                                                        <fmt:formatNumber value="${priceMap[item.itemId]}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </div>
                                                    <div class="input-group input-group-sm" style="width:120px;">
                                                        <button class="btn btn-outline-secondary" type="button" onclick="updateQuantityFromBtn(this, -1)">-</button>
                                                        <input type="text" readonly id="quantity-${item.itemId}" class="form-control text-center" value="0">
                                                        <button class="btn btn-outline-secondary" type="button" onclick="updateQuantityFromBtn(this, 1)">+</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="card cart-section">
                    <div class="card-header">
                        <h5 class="mb-0">Giỏ hàng của bạn</h5>
                    </div>
                        <div class="card-body">
                            <div id="cart-items"></div>
                            <div class="mb-2">
                                <div class="input-group">
                                    <input type="text" id="voucherCodeInput" class="form-control" placeholder="Nhập mã giảm giá"> 
                                    <button type="button" class="btn btn-outline-primary" onclick="applyVoucher()">Áp dụng</button>
                                </div>
                                <div id="voucher-message" class="mt-2 small text-danger"></div>
                            </div>
                            <hr>
                            <div id="discount-row" class="d-flex justify-content-between mb-2" style="display:none;">
                                <span>Giảm giá:</span>
                                <span id="discount-amount">0 đ</span>
                            </div>
                            <div class="d-flex justify-content-between mb-3">
                                <strong>Tổng cộng:</strong>
                                <span id="total-amount">0 đ</span>
                            </div>

                            <form id="orderForm" action="${pageContext.request.contextPath}/takeaway-order" method="POST">
                                <div class="row g-3">
                                    <div class="col-12">
                                        <h5 class="section-title ff-secondary text-start text-primary fw-normal">Thông tin nhận hàng</h5>
                                        <h4 class="mb-3">Vui lòng điền thông tin</h4>
                                    </div>

                                    <div class="col-12">
                                        <div class="form-floating">
                                            <input type="text" class="form-control" id="customerName" name="customerName" placeholder="Họ và tên" required>
                                            <label for="customerName">Họ và tên</label>
                                        </div>
                                    </div>

                                    <div class="col-12">
                                        <div class="form-floating">
                                            <input type="tel" class="form-control" id="phoneNumber" name="phoneNumber" placeholder="Số điện thoại" required maxlength="10" pattern="\d{1,10}" oninput="this.value=this.value.replace(/\D/g,'').slice(0,10)">
                                            <label for="phoneNumber">Số điện thoại</label>
                                            <div class="form-text small text-muted">Chỉ nhập chữ số, tối đa 10 ký tự.</div>
                                        </div>
                                    </div>

                                    <div class="col-12">
                                        <div class="form-floating">
                                            <input type="text" class="form-control" id="address" name="address" placeholder="Địa chỉ nhận hàng" required>
                                            <label for="address">Địa chỉ nhận hàng</label>
                                        </div>
                                    </div>

                                    <div class="col-12">
                                        <div class="form-floating">
                                            <textarea class="form-control" placeholder="Ghi chú" id="note" name="note" style="height:100px"></textarea>
                                            <label for="note">Ghi chú</label>
                                        </div>
                                    </div>

                                    <input type="hidden" id="orderItems" name="orderItems">
                                    <input type="hidden" id="voucherCode" name="voucherCode">
                                    <input type="hidden" id="voucherDiscount" name="voucherDiscount">
                                    <input type="hidden" id="voucherId" name="voucherId">

                                    <div class="col-12">
                                        <button type="submit" class="btn btn-primary w-100 py-3">Đặt món ngay</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/layouts/Footer.jsp" %>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
    let cart = {};
    let prices = {};
    let currentTotalNumeric = 0; // subtotal before voucher
    let currentDiscountNumeric = 0; // discount applied

        // Initialize prices from server-side priceMap
        <c:forEach items="${menuItems}" var="item">
            prices['${item.itemId}'] = ${priceMap[item.itemId]};
        </c:forEach>

        function updateQuantity(itemId, change) {
            const currentQty = parseInt(document.getElementById('quantity-' + itemId).value) || 0;
            const newQty = Math.max(0, currentQty + change);
            document.getElementById('quantity-' + itemId).value = newQty;

            if (newQty === 0) {
                delete cart[itemId];
            } else {
                cart[itemId] = newQty;
            }
            updateCart();
        }

        function updateQuantityFromBtn(btn, change) {
            const card = btn.closest('[data-item-id]');
            if (!card) return;
            const id = card.getAttribute('data-item-id');
            if (!id) return;
            updateQuantity(id, change);
        }

        function updateCart() {
            const cartDiv = document.getElementById('cart-items');
            let total = 0;
            let html = '';
            for (const id in cart) {
                const qty = cart[id];
                const price = prices[id] || 0;
             const cardEl = document.querySelector('[data-item-id="' + id + '"]');
             const nameEl = cardEl ? cardEl.querySelector('h6, h5, h4') : null;
             const imgEl = cardEl ? cardEl.querySelector('img') : null;
             const name = nameEl ? nameEl.innerText : '';
             const imgSrc = imgEl ? imgEl.getAttribute('src') : null;
             const itemTotal = qty * price;
             total += itemTotal;
             html += '<div class="d-flex justify-content-between align-items-center mb-2">'
                 + '<div class="cart-item-row">'
                 + (imgSrc ? ('<img src="' + imgSrc + '" class="cart-thumb" alt="' + name.replace(/\"/g,'') + '"/>') : '')
                 + '<div><div>' + name + '</div><small class="text-muted">x' + qty + '</small></div>'
                 + '</div>'
                 + '<div>' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(itemTotal) + '</div>'
                 + '</div>';
            }
            cartDiv.innerHTML = html || '<div class="text-muted">Giỏ hàng trống</div>';
            currentTotalNumeric = total;
            // update displayed total considering discount
            const displayedTotal = Math.max(0, total - currentDiscountNumeric);
            document.getElementById('total-amount').innerText = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(displayedTotal);
            document.getElementById('orderItems').value = JSON.stringify(cart);
            // update discount row
            if (currentDiscountNumeric > 0) {
                document.getElementById('discount-row').style.display = 'flex';
                document.getElementById('discount-amount').innerText = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(currentDiscountNumeric);
            } else {
                document.getElementById('discount-row').style.display = 'none';
            }
        }

        function applyVoucher() {
            const code = document.getElementById('voucherCodeInput').value.trim();
            const msgEl = document.getElementById('voucher-message');
            msgEl.textContent = '';
            if (!code) {
                msgEl.textContent = 'Nhập mã voucher trước khi áp dụng.';
                return;
            }

            const orderTotal = currentTotalNumeric.toString();
            // Use fetch to POST code and orderTotal. Use server-generated URL to respect context path
            const applyUrl = '<c:url value="/apply-voucher"/>';
            // Use fetch to POST code and orderTotal
            fetch(applyUrl, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: new URLSearchParams({ code: code, orderTotal: orderTotal })
            }).then(r => r.json()).then(data => {
                if (!data) {
                    msgEl.textContent = 'Không nhận được phản hồi từ server.';
                    return;
                }
                if (!data.success) {
                    msgEl.textContent = data.message || 'Mã voucher không hợp lệ.';
                    currentDiscountNumeric = 0;
                    document.getElementById('voucherCode').value = '';
                    document.getElementById('voucherDiscount').value = '';
                    document.getElementById('voucherId').value = '';
                    updateCart();
                    return;
                }

                // success
                currentDiscountNumeric = parseFloat(data.discount || 0);
                document.getElementById('voucherCode').value = code;
                document.getElementById('voucherDiscount').value = currentDiscountNumeric;
                document.getElementById('voucherId').value = data.voucherId || '';
                msgEl.classList.remove('text-danger');
                msgEl.classList.add('text-success');
                msgEl.textContent = 'Áp dụng voucher thành công.';
                updateCart();
            }).catch(err => {
                msgEl.textContent = 'Lỗi khi áp dụng voucher.';
                console.error(err);
            });
        }

        // (address field used instead of pickup time) — no minimum time logic required
    </script>
</body>
</html>