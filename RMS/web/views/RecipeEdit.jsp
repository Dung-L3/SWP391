<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "recipe");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Công thức: ${menuItem.name} - RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>
    
    <style>
        :root {
            --bg-app:#f5f6fa;
            --primary:#4f46e5;
            --accent:#FEA116;
            --success:#16a34a;
            --danger:#dc2626;
        }
        body { background: var(--bg-app); }
        .content { padding: 28px 32px; max-width: 1400px; margin: 0 auto; }
        .card { border: none; border-radius: 16px; box-shadow: 0 8px 28px rgba(20,24,40,.08); margin-bottom: 1.5rem; }
        .card-header { background: linear-gradient(180deg, rgba(79,70,229,.06), transparent); border-bottom: 1px solid #eef2f7; padding: 1rem 1.5rem; }
        .ingredient-row {
            padding: 1rem;
            background: #f9fafb;
            border-radius: 12px;
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
        }
        .ingredient-row:hover { background: #f1f5f9; }
    </style>
</head>
<body>

<jsp:include page="/layouts/Header.jsp"/>

<div class="app-shell" style="display:grid; grid-template-columns:280px 1fr;">
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <main class="content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3><i class="bi bi-list-check text-primary"></i> Công thức: ${menuItem.name}</h3>
                <nav>
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="recipe-management">Công thức món</a></li>
                        <li class="breadcrumb-item active">${menuItem.name}</li>
                    </ol>
                </nav>
            </div>
            <a href="recipe-management" class="btn btn-secondary">
                <i class="bi bi-arrow-left"></i> Quay lại
            </a>
        </div>

        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show">
                <i class="bi bi-check-circle me-2"></i>${sessionScope.successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <div class="row">
            <!-- Left: Dish Info -->
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h6 class="mb-0">Thông tin món ăn</h6>
                    </div>
                    <div class="card-body text-center">
                        <c:if test="${not empty menuItem.imageUrl}">
                            <img src="${menuItem.imageUrl}" alt="${menuItem.name}" 
                                 class="img-fluid rounded mb-3" style="max-height:200px;">
                        </c:if>
                        <h5>${menuItem.name}</h5>
                        <p class="text-muted">${menuItem.categoryName}</p>
                        <p><strong>Giá:</strong> <fmt:formatNumber value="${menuItem.basePrice}" type="currency" currencySymbol="₫"/></p>
                    </div>
                </div>
            </div>

            <!-- Right: Recipe Ingredients -->
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h6 class="mb-0">Danh sách nguyên liệu</h6>
                        <button type="button" class="btn btn-sm btn-success" onclick="showAddIngredientModal()">
                            <i class="bi bi-plus-circle"></i> Thêm nguyên liệu
                        </button>
                    </div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty recipeItems}">
                                <div class="text-center py-4 text-muted">
                                    <i class="bi bi-inbox" style="font-size:2rem;"></i>
                                    <p class="mt-2">Chưa có nguyên liệu nào. Click "Thêm nguyên liệu" để bắt đầu.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div id="recipeItemsList">
                                    <c:forEach var="ri" items="${recipeItems}">
                                        <div class="ingredient-row" id="ri-${ri.recipeItemId}">
                                            <div class="flex-grow-1">
                                                <strong>${ri.itemName}</strong>
                                                <br>
                                                <span class="text-muted">Định lượng: ${ri.qty} ${ri.uom} / món</span>
                                            </div>
                                            <div class="d-flex gap-2">
                                                <button class="btn btn-sm btn-outline-primary" 
                                                        onclick="editIngredient(${ri.recipeItemId}, '${ri.itemName}', ${ri.qty})">
                                                    <i class="bi bi-pencil"></i>
                                                </button>
                                                <button class="btn btn-sm btn-outline-danger" 
                                                        onclick="deleteIngredient(${ri.recipeItemId}, '${ri.itemName}')">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Add Ingredient Modal -->
<div class="modal fade" id="addIngredientModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Thêm nguyên liệu vào công thức</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <!-- Search Box -->
                <div class="mb-3">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control" id="ingredientSearch" 
                               placeholder="Tìm nguyên liệu theo tên..." 
                               onkeyup="filterIngredients()">
                    </div>
                </div>

                <!-- Ingredients List -->
                <div id="ingredientsList" style="max-height:400px; overflow-y:auto;">
                    <c:forEach var="ing" items="${allIngredients}">
                        <div class="ingredient-select-item" data-id="${ing.itemId}" 
                             data-name="${ing.itemName}" data-uom="${ing.uom}"
                             onclick="selectIngredient(${ing.itemId}, '${ing.itemName}', '${ing.uom}')">
                            <div class="d-flex align-items-center gap-3">
                                <div class="flex-grow-1">
                                    <strong>${ing.itemName}</strong>
                                    <br>
                                    <small class="text-muted">
                                        Loại: ${ing.category} | 
                                        Tồn kho: ${ing.currentStock} ${ing.uom}
                                    </small>
                                </div>
                                <span class="badge bg-primary">${ing.uom}</span>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Selected Ingredient -->
                <div id="selectedIngredientSection" style="display:none;" class="mt-4 pt-3 border-top">
                    <h6 class="mb-3">
                        <i class="bi bi-check-circle text-success"></i> 
                        Đã chọn: <span id="selectedIngredientName"></span>
                    </h6>
                    <input type="hidden" id="selectedIngredientId">
                    <input type="hidden" id="selectedIngredientUom">
                    
                    <div class="row">
                        <div class="col-md-6">
                            <label class="form-label">Định lượng cần dùng (cho 1 món)</label>
                            <div class="input-group">
                                <input type="number" class="form-control" id="ingredientQty" 
                                       min="0.001" step="0.001" value="1" 
                                       placeholder="Nhập số lượng">
                                <span class="input-group-text" id="ingredientUomDisplay">đơn vị</span>
                            </div>
                            <small class="text-muted">Ví dụ: 0.5 kg thịt, 100 gram rau...</small>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-primary" id="btnAddIngredient" 
                        onclick="addIngredient()" disabled>
                    <i class="bi bi-plus-circle"></i> Thêm vào công thức
                </button>
            </div>
        </div>
    </div>
</div>

<style>
.ingredient-select-item {
    padding: 12px 16px;
    background: #fff;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    margin-bottom: 8px;
    cursor: pointer;
    transition: all 0.2s;
}
.ingredient-select-item:hover {
    border-color: #4f46e5;
    background: #f9fafb;
    transform: translateX(4px);
}
.ingredient-select-item.selected {
    border-color: #16a34a;
    background: #f0fdf4;
}
</style>

<!-- Edit Ingredient Modal -->
<div class="modal fade" id="editIngredientModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Sửa định lượng</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="editRecipeItemId">
                <div class="mb-3">
                    <label class="form-label">Nguyên liệu</label>
                    <input type="text" class="form-control" id="editIngredientName" readonly>
                </div>
                <div class="mb-3">
                    <label class="form-label">Định lượng mới</label>
                    <input type="number" class="form-control" id="editIngredientQty" min="0" step="0.001">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-primary" onclick="updateIngredient()">Lưu</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const CTX = '${pageContext.request.contextPath}';
const RECIPE_ID = ${recipe.recipeId};

function showAddIngredientModal() {
    // Reset modal
    document.getElementById('ingredientSearch').value = '';
    document.getElementById('selectedIngredientSection').style.display = 'none';
    document.getElementById('btnAddIngredient').disabled = true;
    
    // Reset all items to unselected
    document.querySelectorAll('.ingredient-select-item').forEach(item => {
        item.classList.remove('selected');
    });
    
    filterIngredients(); // Show all
    
    const modal = new bootstrap.Modal(document.getElementById('addIngredientModal'));
    modal.show();
}

function filterIngredients() {
    const search = document.getElementById('ingredientSearch').value.toLowerCase();
    const items = document.querySelectorAll('.ingredient-select-item');
    
    items.forEach(item => {
        const name = item.getAttribute('data-name').toLowerCase();
        if (name.includes(search)) {
            item.style.display = 'block';
        } else {
            item.style.display = 'none';
        }
    });
}

function selectIngredient(itemId, itemName, uom) {
    // Unselect all
    document.querySelectorAll('.ingredient-select-item').forEach(item => {
        item.classList.remove('selected');
    });
    
    // Select this one
    const selectedItem = document.querySelector('.ingredient-select-item[data-id="' + itemId + '"]');
    if (selectedItem) {
        selectedItem.classList.add('selected');
    }
    
    // Show quantity input section
    document.getElementById('selectedIngredientId').value = itemId;
    document.getElementById('selectedIngredientName').textContent = itemName;
    document.getElementById('selectedIngredientUom').value = uom;
    document.getElementById('ingredientUomDisplay').textContent = uom;
    document.getElementById('selectedIngredientSection').style.display = 'block';
    document.getElementById('btnAddIngredient').disabled = false;
    
    // Focus on quantity input
    document.getElementById('ingredientQty').focus();
    document.getElementById('ingredientQty').select();
}

function addIngredient() {
    const itemId = document.getElementById('selectedIngredientId').value;
    const qty = document.getElementById('ingredientQty').value;

    if (!itemId || !qty || qty <= 0) {
        alert('Vui lòng chọn nguyên liệu và nhập định lượng hợp lệ (> 0).');
        return;
    }

    fetch(CTX + '/recipe-management', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=add-ingredient&recipeId=' + RECIPE_ID + '&itemId=' + itemId + '&qty=' + qty
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            alert('Thêm nguyên liệu thành công!');
            location.reload();
        } else {
            alert('Lỗi: ' + (data.error || 'Không thể thêm nguyên liệu'));
        }
    })
    .catch(err => alert('Lỗi kết nối: ' + err));
}

function editIngredient(recipeItemId, itemName, qty) {
    document.getElementById('editRecipeItemId').value = recipeItemId;
    document.getElementById('editIngredientName').value = itemName;
    document.getElementById('editIngredientQty').value = qty;
    
    const modal = new bootstrap.Modal(document.getElementById('editIngredientModal'));
    modal.show();
}

function updateIngredient() {
    const recipeItemId = document.getElementById('editRecipeItemId').value;
    const qty = document.getElementById('editIngredientQty').value;

    if (!qty || qty <= 0) {
        alert('Vui lòng nhập định lượng hợp lệ.');
        return;
    }

    fetch(CTX + '/recipe-management', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=update-ingredient&recipeItemId=' + recipeItemId + '&qty=' + qty
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            alert('Cập nhật thành công!');
            location.reload();
        } else {
            alert('Lỗi: ' + (data.error || 'Không thể cập nhật'));
        }
    })
    .catch(err => alert('Lỗi kết nối: ' + err));
}

function deleteIngredient(recipeItemId, itemName) {
    if (!confirm('Xóa nguyên liệu "' + itemName + '" khỏi công thức?')) return;

    fetch(CTX + '/recipe-management', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=delete-ingredient&recipeItemId=' + recipeItemId
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            alert('Xóa thành công!');
            location.reload();
        } else {
            alert('Lỗi: ' + (data.error || 'Không thể xóa'));
        }
    })
    .catch(err => alert('Lỗi kết nối: ' + err));
}
</script>

</body>
</html>

