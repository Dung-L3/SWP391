<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "recipe");
    request.setAttribute("overlayNav", false);
%>

<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Công thức: ${menuItem.name} | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>

    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <!-- fonts + icons + bootstrap giống template POS -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <style>
        :root {
            --bg-app: #f5f6fa;
            --bg-grad-1: rgba(88, 80, 200, 0.08);
            --bg-grad-2: rgba(254, 161, 22, 0.06);

            --panel-light-top: #fafaff;
            --panel-light-bottom: #ffffff;

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.12);

            --brand:#4f46e5;

            --success:#16a34a;
            --danger:#dc2626;

            --line:#e5e7eb;

            --radius-lg:20px;
            --radius-md:12px;
            --radius-sm:6px;

            --sidebar-width:280px;
        }

        body {
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            color: var(--ink-900);
            font-family: "Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
        }

        .app-shell {
            display: grid;
            grid-template-columns: var(--sidebar-width) 1fr;
            min-height: 100vh;
        }
        @media (max-width: 992px) {
            .app-shell {
                grid-template-columns: 1fr;
            }
            #sidebar {
                position: fixed;
                inset: 0 30% 0 0;
                transform: translateX(-100%);
                transition: transform .2s ease;
                z-index: 1040;
                max-width: var(--sidebar-width);
                box-shadow: 24px 0 60px rgba(0,0,0,.7);
            }
            #sidebar.open {
                transform: translateX(0);
            }
        }

        main.main-pane {
            padding: 28px 32px 44px;
        }

        /* top bar */
        .pos-topbar {
            position: relative;
            background: linear-gradient(135deg, #1b1e2c, #2b2f46 60%, #1c1f30 100%);
            border-radius: var(--radius-md);
            padding: 16px 20px;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: flex-start;
            box-shadow: 0 32px 64px rgba(0,0,0,.6);
            margin-top: 58px;
            margin-bottom: 24px;
            color: #fff;
            border:1px solid rgba(255,255,255,.1);
        }
        .pos-left .title-row {
            display:flex;
            align-items:center;
            gap:.6rem;
            font-weight:600;
            font-size:1rem;
        }
        .pos-left .title-row i {
            color:var(--accent);
        }
        .pos-left .sub {
            margin-top:4px;
            font-size:.8rem;
            color:var(--ink-400);
        }

        .pos-right {
            display:flex;
            align-items:center;
            flex-wrap:wrap;
            gap:.75rem;
        }

        .user-chip {
            display:flex;
            align-items:center;
            gap:.5rem;
            background: rgba(255,255,255,.06);
            border: 1px solid rgba(255,255,255,.18);
            border-radius: var(--radius-md);
            padding: 6px 10px;
            font-size:.8rem;
            line-height:1.2;
            font-weight:500;
        }
        .user-chip .role-badge {
            background: var(--accent);
            color: #1e1e2f;
            border-radius: var(--radius-sm);
            padding: 2px 6px;
            font-size: .7rem;
            font-weight: 600;
        }

        .btn-toggle-sidebar{
            display:none;
        }
        @media(max-width:992px){
            .btn-toggle-sidebar{
                display:inline-flex;
                align-items:center;
                gap:.4rem;
                background:transparent;
                border:1px solid rgba(255,255,255,.3);
                color:#fff;
                font-size:.8rem;
                border-radius:var(--radius-sm);
                padding:6px 10px;
            }
            .btn-toggle-sidebar:hover{
                background:rgba(255,255,255,.07);
            }
        }

        /* layout chính */
        .recipe-layout {
            display:grid;
            grid-template-columns: minmax(0, 320px) minmax(0, 1.4fr);
            gap:1.5rem;
        }
        @media(max-width:992px){
            .recipe-layout {
                grid-template-columns:1fr;
            }
        }

        .panel-soft {
            background:linear-gradient(to bottom right,
                       var(--panel-light-top) 0%,
                       var(--panel-light-bottom) 100%);
            border-radius:var(--radius-lg);
            border:1px solid var(--line);
            box-shadow:0 18px 48px rgba(15,23,42,.12);
            padding:1.1rem 1.25rem 1.25rem;
        }

        .dish-img {
            border-radius:16px;
            box-shadow:0 18px 40px rgba(0,0,0,.28);
            max-height:220px;
            object-fit:cover;
            width:100%;
        }

        .badge-category {
            background:var(--accent-soft);
            color:var(--ink-700);
            border-radius:999px;
            padding:4px 10px;
            font-size:.75rem;
            font-weight:600;
        }

        .price-chip {
            display:inline-flex;
            align-items:center;
            gap:.35rem;
            background:#ecfdf5;
            color:#166534;
            border-radius:999px;
            padding:5px 10px;
            font-size:.78rem;
            font-weight:600;
        }

        .recipe-ingredients-card {
            position:relative;
            border-radius:var(--radius-lg);
            border:1px solid rgba(99,102,241,.25);
            border-top:4px solid var(--accent);
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            box-shadow:0 10px 40px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,.8);
            padding:1rem 1.25rem 1.25rem;
        }
        .recipe-ingredients-card::before {
            content:"";
            position:absolute;
            top:0;left:0;
            width:100%;height:5px;
            background:linear-gradient(90deg,var(--accent),var(--brand));
            border-radius:8px 8px 0 0;
            opacity:.85;
        }

        .recipe-head {
            display:flex;
            justify-content:space-between;
            align-items:flex-start;
            gap:1rem;
            margin-bottom:1rem;
        }

        .ingredient-row {
            padding: .9rem 1rem;
            background: #f9fafb;
            border-radius: 12px;
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            border:1px solid rgba(148,163,184,.5);
        }
        .ingredient-row:hover {
            background:#f1f5f9;
            border-color: var(--accent);
        }

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
</head>

<body>
    <jsp:include page="/layouts/Header.jsp"/>

    <div class="app-shell">
        <aside id="sidebar">
            <jsp:include page="/layouts/sidebar.jsp"/>
        </aside>

        <main class="main-pane">
            <!-- top bar -->
            <header class="pos-topbar">
                <div class="pos-left">
                    <div class="title-row">
                        <i class="bi bi-list-check"></i>
                        <span>Công thức món: <strong>${menuItem.name}</strong></span>
                    </div>
                    <div class="sub">
                        Thiết lập định lượng nguyên liệu (BOM) cho từng phần món ăn.
                    </div>
                </div>
                <div class="pos-right">
                    <div class="user-chip">
                        <i class="bi bi-person-badge"></i>
                        <span>${sessionScope.user.fullName}</span>
                        <span class="role-badge">${sessionScope.user.roleName}</span>
                    </div>

                    <a href="<c:url value='/recipe-management'/>"
                       class="btn btn-sm btn-outline-light">
                        <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách
                    </a>

                    <button class="btn-toggle-sidebar" onclick="toggleSidebar()">
                        <i class="bi bi-list"></i>
                        <span>Menu</span>
                    </button>
                </div>
            </header>

            <!-- alerts -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle me-2"></i>${sessionScope.successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle me-2"></i>${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <!-- main layout -->
            <section class="recipe-layout">

                <!-- LEFT: thông tin món -->
                <aside class="panel-soft">
                    <div class="mb-3 text-center">
                        <c:if test="${not empty menuItem.imageUrl}">
                            <img src="${menuItem.imageUrl}" alt="${menuItem.name}"
                                 class="dish-img mb-3"/>
                        </c:if>
                    </div>

                    <h5 class="mb-1">${menuItem.name}</h5>
                    <div class="mb-2">
                        <span class="badge-category">
                            <i class="bi bi-grid-3x3-gap me-1"></i>${menuItem.categoryName}
                        </span>
                    </div>

                    <div class="mb-3">
                        <span class="price-chip">
                            <i class="bi bi-cash-stack"></i>
                            <fmt:formatNumber value="${menuItem.basePrice}" type="number"/> đ
                        </span>
                    </div>

                    <p class="small text-muted">
                        Công thức giúp bếp định lượng chính xác, đảm bảo cost, và hỗ trợ kiểm kho
                        tự động theo số lượng món bán ra.
                    </p>
                </aside>

                <!-- RIGHT: danh sách nguyên liệu -->
                <section class="recipe-ingredients-card">
                    <div class="recipe-head">
                        <div>
                            <div class="fw-semibold" style="font-size:.95rem;">Danh sách nguyên liệu</div>
                            <div class="text-muted small mt-1">
                                Thiết lập nguyên liệu & định lượng cho 1 phần món.
                            </div>
                        </div>
                        <button type="button" class="btn btn-sm btn-success"
                                onclick="showAddIngredientModal()">
                            <i class="bi bi-plus-circle me-1"></i> Thêm nguyên liệu
                        </button>
                    </div>

                    <div>
                        <c:choose>
                            <c:when test="${empty recipeItems}">
                                <div class="text-center py-4 text-muted">
                                    <i class="bi bi-inbox" style="font-size:2rem;"></i>
                                    <p class="mt-2 mb-0">
                                        Chưa có nguyên liệu nào. Bấm <strong>Thêm nguyên liệu</strong> để bắt đầu.
                                    </p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div id="recipeItemsList">
                                    <c:forEach var="ri" items="${recipeItems}">
                                        <div class="ingredient-row" id="ri-${ri.recipeItemId}">
                                            <div class="flex-grow-1">
                                                <strong>${ri.itemName}</strong><br/>
                                                <span class="text-muted small">
                                                    Định lượng: ${ri.qty} ${ri.uom} / 1 phần
                                                </span>
                                            </div>
                                            <div class="d-flex gap-2">
                                                <button type="button"
                                                        class="btn btn-sm btn-outline-primary"
                                                        onclick="editIngredient(${ri.recipeItemId}, '${ri.itemName}', ${ri.qty})">
                                                    <i class="bi bi-pencil"></i>
                                                </button>
                                                <button type="button"
                                                        class="btn btn-sm btn-outline-danger"
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
                </section>
            </section>
        </main>
    </div>

    <jsp:include page="/layouts/Footer.jsp"/>

    <!-- MODAL: Thêm nguyên liệu -->
    <div class="modal fade" id="addIngredientModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Thêm nguyên liệu vào công thức</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">

                    <div class="mb-3">
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-search"></i></span>
                            <input type="text" class="form-control" id="ingredientSearch"
                                   placeholder="Tìm nguyên liệu theo tên..."
                                   onkeyup="filterIngredients()">
                        </div>
                    </div>

                    <div id="ingredientsList" style="max-height:400px; overflow-y:auto;">
                        <c:forEach var="ing" items="${allIngredients}">
                            <div class="ingredient-select-item"
                                 data-id="${ing.itemId}"
                                 data-name="${ing.itemName}"
                                 data-uom="${ing.uom}"
                                 onclick="selectIngredient(${ing.itemId}, '${ing.itemName}', '${ing.uom}')">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="flex-grow-1">
                                        <strong>${ing.itemName}</strong><br/>
                                        <small class="text-muted">
                                            Loại: ${ing.category}
                                            &nbsp;|&nbsp;
                                            Tồn kho: ${ing.currentStock} ${ing.uom}
                                        </small>
                                    </div>
                                    <span class="badge bg-primary">${ing.uom}</span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <div id="selectedIngredientSection"
                         style="display:none;"
                         class="mt-4 pt-3 border-top">
                        <h6 class="mb-3">
                            <i class="bi bi-check-circle text-success"></i>
                            Đã chọn:
                            <span id="selectedIngredientName"></span>
                        </h6>
                        <input type="hidden" id="selectedIngredientId">
                        <input type="hidden" id="selectedIngredientUom">

                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label">Định lượng dùng cho 1 phần</label>
                                <div class="input-group">
                                    <input type="number" class="form-control" id="ingredientQty"
                                           min="0.001" step="0.001" value="1">
                                    <span class="input-group-text" id="ingredientUomDisplay">đơn vị</span>
                                </div>
                                <small class="text-muted">
                                    Ví dụ: 0.5 kg thịt, 100 gram rau,...
                                </small>
                            </div>
                        </div>
                    </div>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" id="btnAddIngredient"
                            onclick="addIngredient()" disabled>
                        <i class="bi bi-plus-circle me-1"></i> Thêm vào công thức
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL: Sửa định lượng -->
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
                        <input type="number" class="form-control" id="editIngredientQty"
                               min="0" step="0.001">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="updateIngredient()">Lưu</button>
                </div>
            </div>
        </div>
    </div>

    <!-- scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleSidebar() {
            var el = document.getElementById('sidebar');
            if (el) el.classList.toggle('open');
        }

        // auto ẩn alert sau 5s
        setTimeout(function () {
            var alerts = document.querySelectorAll('.alert');
            alerts.forEach(function (al) {
                var bsAlert = new bootstrap.Alert(al);
                bsAlert.close();
            });
        }, 5000);

        const CTX = '${pageContext.request.contextPath}';
        const RECIPE_ID = ${recipe.recipeId};

        function showAddIngredientModal() {
            document.getElementById('ingredientSearch').value = '';
            document.getElementById('selectedIngredientSection').style.display = 'none';
            document.getElementById('btnAddIngredient').disabled = true;

            document.querySelectorAll('.ingredient-select-item').forEach(item => {
                item.classList.remove('selected');
                item.style.display = 'block';
            });

            const modal = new bootstrap.Modal(document.getElementById('addIngredientModal'));
            modal.show();
        }

        function filterIngredients() {
            const search = document.getElementById('ingredientSearch').value.toLowerCase();
            const items = document.querySelectorAll('.ingredient-select-item');

            items.forEach(item => {
                const name = item.getAttribute('data-name').toLowerCase();
                item.style.display = name.includes(search) ? 'block' : 'none';
            });
        }

        function selectIngredient(itemId, itemName, uom) {
            document.querySelectorAll('.ingredient-select-item').forEach(item => {
                item.classList.remove('selected');
            });

            const selectedItem = document.querySelector('.ingredient-select-item[data-id="' + itemId + '"]');
            if (selectedItem) {
                selectedItem.classList.add('selected');
            }

            document.getElementById('selectedIngredientId').value = itemId;
            document.getElementById('selectedIngredientName').textContent = itemName;
            document.getElementById('selectedIngredientUom').value = uom;
            document.getElementById('ingredientUomDisplay').textContent = uom;
            document.getElementById('selectedIngredientSection').style.display = 'block';
            document.getElementById('btnAddIngredient').disabled = false;

            const qtyInput = document.getElementById('ingredientQty');
            qtyInput.focus();
            qtyInput.select();
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
