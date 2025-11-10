<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "stock-transactions");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>
        <c:choose>
            <c:when test="${txnType == 'IN'}">Nhập kho</c:when>
            <c:when test="${txnType == 'OUT'}">Xuất kho</c:when>
            <c:when test="${txnType == 'ADJUSTMENT'}">Điều chỉnh kho</c:when>
            <c:otherwise>Giao dịch kho</c:otherwise>
        </c:choose>
        - RMSG4
    </title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">
    
    <style>
        :root {
            --primary: #4f46e5;
            --accent: #c9a86a;
            --success: #16a34a;
            --danger: #dc2626;
            --warning: #f59e0b;
            --paper: #f7f7fa;
        }
        body { background: var(--paper); }
        .content { padding: 28px 32px; max-width: 800px; margin: 0 auto; }
        .card { border: none; border-radius: 16px; box-shadow: 0 8px 28px rgba(20,24,40,.08); }
        .card-header { 
            background: linear-gradient(180deg, rgba(79,70,229,.06), transparent); 
            border-bottom: 1px solid #eef2f7; 
        }
        .form-label { font-weight: 600; color: #334155; }
        .form-control, .form-select { border: 2px solid #eef2f7; border-radius: 8px; }
        .form-control:focus, .form-select:focus { border-color: var(--primary); box-shadow: 0 0 0 0.2rem rgba(79,70,229,0.25); }
        .btn { border-radius: 8px; padding: 0.5rem 1rem; font-weight: 600; }
        .btn-primary { background: var(--primary); border-color: var(--primary); }
        .txn-type-badge {
            display: inline-block;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            font-weight: 600;
            margin-bottom: 1rem;
        }
        .txn-type-IN { background: #dcfce7; color: #166534; }
        .txn-type-OUT { background: #fee2e2; color: #991b1b; }
        .txn-type-ADJUSTMENT { background: #dbeafe; color: #1e40af; }
        .info-box {
            background: #f0f9ff;
            border-left: 4px solid var(--primary);
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }
        .current-stock {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--primary);
        }
    </style>
</head>
<body>

<jsp:include page="/layouts/Header.jsp"/>

<div class="content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3>
                <i class="bi <c:choose><c:when test="${txnType == 'IN'}">bi-box-arrow-in-down</c:when><c:when test="${txnType == 'OUT'}">bi-box-arrow-up</c:when><c:when test="${txnType == 'ADJUSTMENT'}">bi-sliders</c:when><c:otherwise>bi-arrow-left-right</c:otherwise></c:choose>"></i>
                <c:choose>
                    <c:when test="${txnType == 'IN'}">Nhập kho</c:when>
                    <c:when test="${txnType == 'OUT'}">Xuất kho</c:when>
                    <c:when test="${txnType == 'ADJUSTMENT'}">Điều chỉnh kho (Kiểm kê)</c:when>
                    <c:otherwise>Giao dịch kho</c:otherwise>
                </c:choose>
            </h3>
            <nav>
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Trang chủ</a></li>
                    <li class="breadcrumb-item"><a href="stock-transactions">Giao dịch Kho</a></li>
                    <li class="breadcrumb-item active">
                        <c:choose>
                            <c:when test="${txnType == 'IN'}">Nhập kho</c:when>
                            <c:when test="${txnType == 'OUT'}">Xuất kho</c:when>
                            <c:when test="${txnType == 'ADJUSTMENT'}">Điều chỉnh</c:when>
                            <c:otherwise>Giao dịch</c:otherwise>
                        </c:choose>
                    </li>
                </ol>
            </nav>
        </div>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-circle me-2"></i>${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <h5 class="mb-0">
                <span class="txn-type-badge txn-type-${txnType}">
                    <c:choose>
                        <c:when test="${txnType == 'IN'}">Nhập kho</c:when>
                        <c:when test="${txnType == 'OUT'}">Xuất kho</c:when>
                        <c:when test="${txnType == 'ADJUSTMENT'}">Điều chỉnh kho</c:when>
                        <c:otherwise>Giao dịch</c:otherwise>
                    </c:choose>
                </span>
            </h5>
        </div>
        <div class="card-body">
            <form action="stock-transactions" method="post" id="txnForm">
                <input type="hidden" name="action" value="create">
                <input type="hidden" name="txnType" value="${txnType}">

                <div class="mb-3">
                    <label class="form-label">
                        <i class="bi bi-box text-primary me-1"></i>Nguyên liệu *
                    </label>
                    <select class="form-select" name="itemId" id="itemId" required onchange="updateCurrentStock()">
                        <option value="">-- Chọn nguyên liệu --</option>
                        <c:forEach var="item" items="${inventoryItems}">
                            <option value="${item.itemId}" 
                                data-stock="${item.currentStock}" 
                                data-uom="${item.uom}"
                                data-unit-cost="${item.unitCost != null ? item.unitCost : ''}"
                                data-supplier="${item.supplierName != null ? item.supplierName : ''}"
                                <c:if test="${selectedItemId == item.itemId}">selected</c:if>>
                                <c:out value="${item.itemName}"/>
                                <c:if test="${not empty item.supplierName}"> - <c:out value="${item.supplierName}"/></c:if>
                                (<fmt:formatNumber value="${item.currentStock}" pattern="#,##0.000"/> <c:out value="${item.uom}"/>
                                <c:if test="${item.unitCost != null}">
                                    <c:if test="${item.unitCost > 0}">
                                        , <fmt:formatNumber value="${item.unitCost}" pattern="#,##0"/> VND
                                    </c:if>
                                </c:if>)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div id="currentStockInfo" class="info-box" style="display: none;">
                    <div class="row">
                        <div class="col-md-4">
                            <small class="text-muted">Tồn kho hiện tại:</small>
                            <div class="current-stock" id="currentStockDisplay">-</div>
                        </div>
                        <div class="col-md-4">
                            <small class="text-muted">Sau giao dịch:</small>
                            <div class="current-stock" id="newStockDisplay">-</div>
                        </div>
                        <div class="col-md-4">
                            <small class="text-muted">Nhà cung cấp:</small>
                            <div class="current-stock" id="supplierDisplay" style="font-size: 0.9rem;">-</div>
                        </div>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">
                        <i class="bi bi-123 text-primary me-1"></i>
                        <c:choose>
                            <c:when test="${txnType == 'IN'}">Số lượng nhập *</c:when>
                            <c:when test="${txnType == 'OUT'}">Số lượng xuất *</c:when>
                            <c:when test="${txnType == 'ADJUSTMENT'}">Số lượng điều chỉnh *</c:when>
                            <c:otherwise>Số lượng *</c:otherwise>
                        </c:choose>
                        <c:if test="${txnType == 'ADJUSTMENT'}">
                            <small class="text-muted">(Có thể nhập số âm để giảm kho)</small>
                        </c:if>
                    </label>
                    <input type="number" 
                           class="form-control" 
                           name="quantity" 
                           id="quantity"
                           step="0.001" 
                           <c:if test="${txnType != 'ADJUSTMENT'}">min="0.001"</c:if>
                           required 
                           oninput="updateNewStock(); calculateTotal();"
                           <c:choose>
                               <c:when test="${txnType == 'ADJUSTMENT'}">
                                   placeholder="Ví dụ: -5.5 (giảm) hoặc +10 (tăng)"
                               </c:when>
                               <c:otherwise>
                                   placeholder="Nhập số lượng"
                               </c:otherwise>
                           </c:choose>>
                </div>

                <div class="mb-3">
                    <label class="form-label">
                        <i class="bi bi-currency-dollar text-primary me-1"></i>Đơn giá
                        <small class="text-muted">(Tự động từ nhà cung cấp, có thể chỉnh sửa)</small>
                    </label>
                    <div class="input-group">
                        <input type="number" 
                               class="form-control" 
                               name="unitCost" 
                               id="unitCost"
                               step="0.01" 
                               min="0"
                               placeholder="Nhập đơn giá (₫)"
                               oninput="calculateTotal()">
                        <span class="input-group-text">₫</span>
                    </div>
                    <small class="text-muted" id="unitCostHint"></small>
                </div>

                <div class="mb-3" id="totalCostBox" style="display: none;">
                    <div class="alert alert-info mb-0">
                        <strong>Thành tiền:</strong> 
                        <span id="totalCostDisplay" style="font-size: 1.2rem; font-weight: 600;">0 ₫</span>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">
                        <i class="bi bi-card-text text-primary me-1"></i>Ghi chú
                    </label>
                    <textarea class="form-control" 
                              name="note" 
                              rows="3" 
                              placeholder="Nhập ghi chú (tùy chọn)"></textarea>
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <a href="stock-transactions" class="btn btn-outline-secondary">
                        <i class="bi bi-x-circle me-1"></i>Hủy
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-circle me-1"></i>
                        <c:choose>
                            <c:when test="${txnType == 'IN'}">Xác nhận nhập kho</c:when>
                            <c:when test="${txnType == 'OUT'}">Xác nhận xuất kho</c:when>
                            <c:when test="${txnType == 'ADJUSTMENT'}">Xác nhận điều chỉnh</c:when>
                            <c:otherwise>Xác nhận</c:otherwise>
                        </c:choose>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="<c:url value='/js/bootstrap.bundle.min.js'/>"></script>
<script>
    const txnType = '${txnType}';
    let currentStock = 0;
    let uom = '';
    let defaultUnitCost = 0;

    function updateCurrentStock() {
        const select = document.getElementById('itemId');
        const selectedOption = select.options[select.selectedIndex];
        
        if (selectedOption.value) {
            currentStock = parseFloat(selectedOption.getAttribute('data-stock')) || 0;
            uom = selectedOption.getAttribute('data-uom') || '';
            defaultUnitCost = parseFloat(selectedOption.getAttribute('data-unit-cost')) || 0;
            const supplierName = selectedOption.getAttribute('data-supplier') || '';
            
            document.getElementById('currentStockDisplay').textContent = 
                currentStock.toLocaleString('vi-VN') + ' ' + uom;
            document.getElementById('supplierDisplay').textContent = 
                supplierName || 'Chưa có';
            document.getElementById('currentStockInfo').style.display = 'block';
            
            // Auto-fill unit cost if available
            if (defaultUnitCost > 0 && txnType === 'IN') {
                document.getElementById('unitCost').value = defaultUnitCost;
                document.getElementById('unitCostHint').textContent = 
                    'Giá mặc định từ nhà cung cấp: ' + defaultUnitCost.toLocaleString('vi-VN') + ' ₫';
            } else {
                document.getElementById('unitCost').value = '';
                document.getElementById('unitCostHint').textContent = '';
            }
            
            updateNewStock();
            calculateTotal();
        } else {
            document.getElementById('currentStockInfo').style.display = 'none';
            document.getElementById('unitCost').value = '';
            document.getElementById('unitCostHint').textContent = '';
            document.getElementById('totalCostBox').style.display = 'none';
        }
    }

    function calculateTotal() {
        const quantity = parseFloat(document.getElementById('quantity').value) || 0;
        const unitCost = parseFloat(document.getElementById('unitCost').value) || 0;
        
        if (quantity > 0 && unitCost > 0 && txnType === 'IN') {
            const total = quantity * unitCost;
            document.getElementById('totalCostDisplay').textContent = 
                total.toLocaleString('vi-VN') + ' ₫';
            document.getElementById('totalCostBox').style.display = 'block';
        } else {
            document.getElementById('totalCostBox').style.display = 'none';
        }
    }

    function updateNewStock() {
        const quantityInput = document.getElementById('quantity');
        const quantity = parseFloat(quantityInput.value) || 0;
        
        if (currentStock > 0) {
            let newStock = currentStock;
            
            if (txnType === 'IN') {
                newStock = currentStock + quantity;
            } else if (txnType === 'OUT' || txnType === 'USAGE' || txnType === 'WASTE') {
                newStock = currentStock - quantity;
            } else if (txnType === 'ADJUSTMENT') {
                newStock = currentStock + quantity; // quantity can be negative
            }
            
            const display = document.getElementById('newStockDisplay');
            display.textContent = newStock.toLocaleString('vi-VN') + ' ' + uom;
            
            if (newStock < 0) {
                display.style.color = 'var(--danger)';
            } else if (newStock < currentStock * 0.1) {
                display.style.color = 'var(--warning)';
            } else {
                display.style.color = 'var(--primary)';
            }
        }
    }

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function() {
        updateCurrentStock();
        
        // Validate form
        document.getElementById('txnForm').addEventListener('submit', function(e) {
            const quantity = parseFloat(document.getElementById('quantity').value);
            
            if (txnType !== 'ADJUSTMENT' && quantity <= 0) {
                e.preventDefault();
                alert('Số lượng phải lớn hơn 0');
                return false;
            }
            
            if (txnType === 'OUT' || txnType === 'USAGE' || txnType === 'WASTE') {
                if (quantity > currentStock) {
                    e.preventDefault();
                    alert('Số lượng xuất không được vượt quá tồn kho hiện tại (' + currentStock + ' ' + uom + ')');
                    return false;
                }
            }
            
            if (txnType === 'ADJUSTMENT') {
                const newStock = currentStock + quantity;
                if (newStock < 0) {
                    e.preventDefault();
                    alert('Không thể giảm kho xuống dưới 0. Tồn kho hiện tại: ' + currentStock + ' ' + uom);
                    return false;
                }
            }
        });
    });
</script>
</body>
</html>

