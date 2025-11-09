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
    <title>Nhập kho nhiều nguyên liệu - RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">
    
    <style>
        :root {
            --primary: #4f46e5;
            --success: #16a34a;
            --danger: #dc2626;
            --paper: #f7f7fa;
        }
        body { background: var(--paper); }
        .content { padding: 28px 32px; max-width: 1400px; margin: 0 auto; }
        .card { border: none; border-radius: 16px; box-shadow: 0 8px 28px rgba(20,24,40,.08); }
        .card-header { 
            background: linear-gradient(180deg, rgba(79,70,229,.06), transparent); 
            border-bottom: 1px solid #eef2f7; 
        }
        .batch-table { width: 100%; }
        .batch-table thead { background: linear-gradient(135deg, #4f46e5, #6366f1); color: #fff; }
        .batch-table th { padding: 0.75rem; font-size: 0.85rem; font-weight: 600; }
        .batch-table td { padding: 0.5rem; border-bottom: 1px solid #eef2f7; }
        .batch-table tbody tr:hover { background: #f9fafb; }
        .batch-table select, .batch-table input { border: 1px solid #eef2f7; border-radius: 6px; padding: 0.4rem 0.6rem; }
        .btn-remove-row { color: var(--danger); border: none; background: none; padding: 0.25rem 0.5rem; }
        .btn-remove-row:hover { background: #fee2e2; border-radius: 4px; }
        .total-summary {
            background: linear-gradient(135deg, #dcfce7, #bbf7d0);
            border-left: 4px solid var(--success);
            padding: 1rem;
            border-radius: 8px;
            margin-top: 1rem;
        }
    </style>
</head>
<body>

<jsp:include page="/layouts/Header.jsp"/>

<div class="content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3>
                <i class="bi bi-boxes"></i> Nhập kho nhiều nguyên liệu
            </h3>
            <nav>
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Trang chủ</a></li>
                    <li class="breadcrumb-item"><a href="stock-transactions">Giao dịch Kho</a></li>
                    <li class="breadcrumb-item active">Nhập nhiều</li>
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
                <i class="bi bi-boxes me-2"></i>Danh sách nguyên liệu nhập kho
            </h5>
        </div>
        <div class="card-body">
            <form action="stock-transactions" method="post" id="batchForm">
                <input type="hidden" name="action" value="create-batch">
                <input type="hidden" name="txnType" value="${txnType}">

                <div class="table-responsive">
                    <table class="batch-table table">
                        <thead>
                            <tr>
                                <th style="width: 5%;">#</th>
                                <th style="width: 35%;">Nguyên liệu *</th>
                                <th style="width: 15%;">Số lượng *</th>
                                <th style="width: 15%;">Đơn giá (₫)</th>
                                <th style="width: 15%;">Thành tiền</th>
                                <th style="width: 10%;">Tồn kho</th>
                                <th style="width: 5%;"></th>
                            </tr>
                        </thead>
                        <tbody id="itemsTableBody">
                            <!-- Rows will be added dynamically -->
                        </tbody>
                    </table>
                </div>

                <div class="d-flex justify-content-between align-items-center mt-3">
                    <button type="button" class="btn btn-outline-primary" onclick="addRow()">
                        <i class="bi bi-plus-circle me-1"></i>Thêm dòng
                    </button>
                    <div class="total-summary">
                        <strong>Tổng thành tiền: <span id="grandTotal">0 ₫</span></strong>
                    </div>
                </div>

                <div class="mb-3 mt-4">
                    <label class="form-label">
                        <i class="bi bi-card-text text-primary me-1"></i>Ghi chú chung
                    </label>
                    <textarea class="form-control" name="note" rows="2" 
                              placeholder="Nhập ghi chú chung cho tất cả giao dịch (tùy chọn)"></textarea>
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <a href="stock-transactions" class="btn btn-outline-secondary">
                        <i class="bi bi-x-circle me-1"></i>Hủy
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-circle me-1"></i>Xác nhận nhập kho
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="<c:url value='/js/bootstrap.bundle.min.js'/>"></script>
<script>
    const inventoryItems = [
        <c:forEach var="item" items="${inventoryItems}" varStatus="status">
        {
            id: ${item.itemId},
            name: "<c:out value='${item.itemName}' escapeXml='true'/>",
            uom: "<c:out value='${item.uom}' escapeXml='true'/>",
            stock: ${item.currentStock},
            unitCost: ${item.unitCost != null ? item.unitCost : 0},
            supplier: "<c:out value='${item.supplierName != null ? item.supplierName : ""}' escapeXml='true'/>"
        }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    let rowCount = 0;

    function addRow() {
        rowCount++;
        const tbody = document.getElementById('itemsTableBody');
        const row = document.createElement('tr');
        row.id = 'row-' + rowCount;
        
        // Build options HTML
        let optionsHtml = '<option value="">-- Chọn nguyên liệu --</option>';
        inventoryItems.forEach(function(item) {
            let optionText = item.name;
            if (item.supplier) {
                optionText += ' - ' + item.supplier;
            }
            optionText += ' (Tồn: ' + item.stock.toLocaleString('vi-VN') + ' ' + item.uom;
            if (item.unitCost > 0) {
                optionText += ', Giá: ' + item.unitCost.toLocaleString('vi-VN') + ' ₫';
            }
            optionText += ')';
            
            optionsHtml += '<option value="' + item.id + '" ' +
                'data-stock="' + item.stock + '" ' +
                'data-uom="' + item.uom + '" ' +
                'data-unit-cost="' + item.unitCost + '" ' +
                'data-supplier="' + (item.supplier || '') + '">' +
                optionText + '</option>';
        });
        
        row.innerHTML = 
            '<td>' + rowCount + '</td>' +
            '<td>' +
                '<select class="form-select form-select-sm" name="itemId" required onchange="updateRow(' + rowCount + ')">' +
                    optionsHtml +
                '</select>' +
            '</td>' +
            '<td>' +
                '<input type="number" class="form-control form-control-sm" ' +
                       'name="quantity" step="0.001" min="0.001" required ' +
                       'oninput="updateRow(' + rowCount + ')" placeholder="0.000">' +
            '</td>' +
            '<td>' +
                '<input type="number" class="form-control form-control-sm" ' +
                       'name="unitCost" step="0.01" min="0" ' +
                       'oninput="updateRow(' + rowCount + ')" placeholder="0">' +
            '</td>' +
            '<td>' +
                '<span class="row-total" id="total-' + rowCount + '">0 ₫</span>' +
            '</td>' +
            '<td>' +
                '<small class="text-muted row-stock" id="stock-' + rowCount + '">-</small>' +
            '</td>' +
            '<td>' +
                '<button type="button" class="btn-remove-row" onclick="removeRow(' + rowCount + ')">' +
                    '<i class="bi bi-trash"></i>' +
                '</button>' +
            '</td>';
        
        tbody.appendChild(row);
    }

    function removeRow(rowId) {
        const row = document.getElementById('row-' + rowId);
        if (row) {
            row.remove();
            updateGrandTotal();
            renumberRows();
        }
    }

    function renumberRows() {
        const rows = document.querySelectorAll('#itemsTableBody tr');
        rows.forEach((row, index) => {
            row.querySelector('td:first-child').textContent = index + 1;
        });
    }

    function updateRow(rowId) {
        const row = document.getElementById('row-' + rowId);
        if (!row) return;

        const select = row.querySelector('select[name="itemId"]');
        const quantityInput = row.querySelector('input[name="quantity"]');
        const unitCostInput = row.querySelector('input[name="unitCost"]');
        const totalSpan = document.getElementById('total-' + rowId);
        const stockSpan = document.getElementById('stock-' + rowId);

        const selectedOption = select.options[select.selectedIndex];
        
        if (selectedOption.value) {
            const stock = parseFloat(selectedOption.getAttribute('data-stock')) || 0;
            const uom = selectedOption.getAttribute('data-uom') || '';
            const defaultUnitCost = parseFloat(selectedOption.getAttribute('data-unit-cost')) || 0;

            stockSpan.textContent = stock.toLocaleString('vi-VN') + ' ' + uom;

            // Auto-fill unit cost if available and empty
            if (defaultUnitCost > 0 && (!unitCostInput.value || unitCostInput.value == 0)) {
                unitCostInput.value = defaultUnitCost;
            }
        } else {
            stockSpan.textContent = '-';
        }

        // Calculate row total
        const quantity = parseFloat(quantityInput.value) || 0;
        const unitCost = parseFloat(unitCostInput.value) || 0;
        const total = quantity * unitCost;
        
        totalSpan.textContent = total > 0 ? total.toLocaleString('vi-VN') + ' ₫' : '0 ₫';

        updateGrandTotal();
    }

    function updateGrandTotal() {
        const totals = document.querySelectorAll('.row-total');
        let grandTotal = 0;

        totals.forEach(span => {
            const text = span.textContent.replace(/[^\d,]/g, '').replace(/,/g, '');
            const value = parseFloat(text) || 0;
            grandTotal += value;
        });

        document.getElementById('grandTotal').textContent = grandTotal.toLocaleString('vi-VN') + ' ₫';
    }

    // Initialize with 3 empty rows
    document.addEventListener('DOMContentLoaded', function() {
        for (let i = 0; i < 3; i++) {
            addRow();
        }

        // Form validation
        document.getElementById('batchForm').addEventListener('submit', function(e) {
            const rows = document.querySelectorAll('#itemsTableBody tr');
            let hasValidRow = false;

            rows.forEach(row => {
                const itemId = row.querySelector('select[name="itemId"]').value;
                const quantity = row.querySelector('input[name="quantity"]').value;
                
                if (itemId && quantity && parseFloat(quantity) > 0) {
                    hasValidRow = true;
                }
            });

            if (!hasValidRow) {
                e.preventDefault();
                alert('Vui lòng nhập ít nhất một nguyên liệu hợp lệ.');
                return false;
            }
        });
    });
</script>
</body>
</html>

