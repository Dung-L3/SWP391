<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "menu");
    request.setAttribute("overlayNav", false);
%>

<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Quản lý Menu | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <!-- Icons / Bootstrap -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>

    <!-- Base site styles (header/footer layout etc) -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <style>
        /************************************
         * THEME VARIABLES
         ************************************/
        :root {
            --bg-app:#f5f6fa;
            --bg-grad-1:rgba(88,80,200,.08);
            --bg-grad-2:rgba(254,161,22,.06);

            --panel-light-top:#fafaff;
            --panel-light-bottom:#ffffff;
            --panel-dark:#1f2535;
            --panel-dark-border:rgba(255,255,255,.08);

            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.12);
            --accent-border:rgba(254,161,22,.45);

            --brand:#4f46e5;
            --brand-border:#6366f1;
            --brand-bg-soft:#eef2ff;

            --success:#16a34a;
            --success-soft:#d1fae5;
            --danger:#dc2626;

            --line:#e5e7eb;
            --shadow-card:0 28px 64px rgba(15,23,42,.12);

            --radius-lg:20px;
            --radius-md:12px;
            --radius-sm:6px;

            --sidebar-width:280px;
        }

        /************************************
         * GLOBAL LAYOUT / BACKGROUND
         ************************************/
        body{
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            color:var(--ink-900);
            font-family:"Heebo", system-ui, -apple-system, BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",sans-serif;
        }

        .app-shell{
            display:grid;
            grid-template-columns:var(--sidebar-width) 1fr;
            min-height:100vh;
        }
        @media(max-width:992px){
            .app-shell{
                grid-template-columns:1fr;
            }
            #sidebar{
                position:fixed;
                inset:0 30% 0 0;
                transform:translateX(-100%);
                transition:transform .2s ease;
                z-index:1040;
                max-width:var(--sidebar-width);
                box-shadow:24px 0 60px rgba(0,0,0,.7);
                background:#1f2535;
            }
            #sidebar.open{
                transform:translateX(0);
            }
        }

        main.main-pane{
            padding:28px 32px 44px;
        }

        /************************************
         * TOP POS BAR
         ************************************/
        .pos-topbar{
            background:linear-gradient(135deg,#1b1e2c 0%,#2b2f46 60%,#1c1f30 100%);
            border-radius:var(--radius-md);
            border:1px solid rgba(255,255,255,.07);
            box-shadow:0 32px 64px rgba(0,0,0,.6);
            color:#fff;
            padding:16px 20px;
            margin-top:58px;
            margin-bottom:24px;

            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
        }

        .pos-left .title-row{
            display:flex;
            align-items:center;
            gap:.6rem;
            font-weight:600;
            font-size:1rem;
            line-height:1.35;
            color:#fff;
        }
        .pos-left .title-row i{
            color:var(--accent);
            font-size:1.1rem;
        }
        .pos-left .sub{
            margin-top:4px;
            font-size:.8rem;
            color:var(--ink-400);
        }

        .pos-right{
            display:flex;
            align-items:center;
            flex-wrap:wrap;
            gap:.75rem;
            color:#fff;
        }

        .user-chip{
            display:flex;
            align-items:center;
            gap:.5rem;
            background:rgba(255,255,255,.06);
            border:1px solid rgba(255,255,255,.18);
            border-radius:var(--radius-md);
            padding:6px 10px;
            font-size:.8rem;
            font-weight:500;
            line-height:1.2;
            color:#fff;
        }
        .user-chip .role-badge{
            background:var(--accent);
            color:#1e1e2f;
            border-radius:var(--radius-sm);
            padding:2px 6px;
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
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
                line-height:1.2;
                border-radius:var(--radius-sm);
                padding:6px 10px;
            }
            .btn-toggle-sidebar:hover{
                background:rgba(255,255,255,.07);
            }
        }

        /************************************
         * FILTER BAR CARD (giống detail-card)
         ************************************/
        .filters-card{
            position:relative;
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border:1px solid rgba(99,102,241,.25);
            border-top:4px solid var(--accent);
            border-radius:var(--radius-lg);
            box-shadow:0 10px 40px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,.8);
            padding:1rem 1.25rem 1.25rem;
            margin-bottom:1.5rem;
            transition:all .25s ease;
        }
        .filters-card:hover{
            box-shadow:0 20px 60px rgba(254,161,22,.18), inset 0 1px 0 rgba(255,255,255,1);
            transform:translateY(-2px);
        }

        .filters-head{
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            row-gap:.5rem;
            margin-bottom:1rem;
        }
        .filters-head-left{
            display:flex;
            gap:.6rem;
            align-items:flex-start;
        }
        .filters-head-left i{
            color:var(--accent);
            font-size:1rem;
            margin-top:.2rem;
        }
        .filters-title-wrap{
            display:flex;
            flex-direction:column;
            gap:.2rem;
        }
        .filters-title{
            font-weight:600;
            font-size:1rem;
            line-height:1.3;
            background:linear-gradient(to right,var(--accent),var(--brand));
            -webkit-background-clip:text;
            -webkit-text-fill-color:transparent;
        }
        .filters-sub{
            font-size:.8rem;
            color:var(--ink-500);
        }

        .form-label{
            font-size:.8rem;
            font-weight:600;
            color:var(--ink-700);
        }
        .form-control,
        .form-select{
            background:#fff;
            border-radius:10px;
            border:1.5px solid #e2e8f0;
            transition:all .25s ease;
        }
        .form-control:focus,
        .form-select:focus{
            border-color:var(--accent);
            box-shadow:0 0 0 .25rem rgba(254,161,22,.25);
            background:#fffefc;
        }
        .btn-filter-icon{
            border-radius:var(--radius-sm);
            border:1px solid var(--accent-border);
            background:linear-gradient(to bottom right,#fff7e6,#ffffff);
            color:var(--ink-900);
            font-weight:600;
            box-shadow:0 10px 30px rgba(254,161,22,.3);
        }
        .btn-filter-icon:hover{
            box-shadow:0 16px 40px rgba(254,161,22,.4);
            transform:translateY(-1px);
        }

        /************************************
         * TOP ACTION BAR (kết quả tìm kiếm + nút thêm món)
         ************************************/
        .result-bar{
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            row-gap:.75rem;
            margin-bottom:1.5rem;
        }
        .result-left{
            font-size:.9rem;
            font-weight:500;
            color:var(--ink-900);
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.75rem;
        }
        .clear-filter-btn{
            font-size:.75rem;
        }

        .btn-add-dish{
            background:linear-gradient(135deg,#16a34a,#0f766e);
            color:#fff;
            font-weight:600;
            border:none;
            border-radius:var(--radius-sm);
            box-shadow:0 4px 20px rgba(22,163,74,.3);
            display:inline-flex;
            align-items:center;
            gap:.5rem;
            padding:.5rem .75rem;
        }
        .btn-add-dish:hover{
            box-shadow:0 6px 25px rgba(22,163,74,.4);
            transform:translateY(-1px);
            color:#fff;
        }

        /************************************
         * GRID CÁC MÓN (card POS-style)
         ************************************/
        .menu-grid{
            display:grid;
            grid-template-columns:repeat(auto-fit,minmax(min(260px,100%),1fr));
            gap:1rem 1rem;
        }

        .menu-card{
            position:relative;
            background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border-radius:var(--radius-lg);
            border:1px solid rgba(99,102,241,.25);
            border-top:4px solid var(--accent);
            box-shadow:0 20px 48px rgba(15,23,42,.08), inset 0 1px 0 rgba(255,255,255,.8);
            padding:1rem 1rem .75rem;
            color:var(--ink-900);
            display:flex;
            flex-direction:column;
            min-height:200px;
            transition:all .22s ease;
        }
        .menu-card:hover{
            box-shadow:0 28px 60px rgba(254,161,22,.22), inset 0 1px 0 rgba(255,255,255,1);
            transform:translateY(-2px);
        }

        .item-head-row{
            display:flex;
            justify-content:space-between;
            align-items:flex-start;
            gap:.75rem;
            flex-wrap:wrap;
        }

        .item-left{
            display:flex;
            align-items:flex-start;
            gap:.75rem;
        }
        .menu-thumb{
            width:72px;
            height:72px;
            border-radius:12px;
            object-fit:cover;
            box-shadow:0 16px 32px rgba(0,0,0,.18);
            border:2px solid rgba(254,161,22,.4);
            background:#fff;
        }
        .item-main{
            min-width:0;
        }
        .item-name{
            font-weight:600;
            font-size:.95rem;
            line-height:1.3;
            color:var(--ink-900);
        }
        .item-cat{
            font-size:.75rem;
            color:var(--ink-500);
        }
        .item-desc{
            font-size:.75rem;
            color:var(--ink-500);
            line-height:1.4;
            max-width:220px;
            max-height:3.2em;
            overflow:hidden;
            text-overflow:ellipsis;
            display:-webkit-box;
            -webkit-line-clamp:2;
            -webkit-box-orient:vertical;
            word-break:break-word;
        }

        .status-badge{
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
            padding:.3rem .5rem;
            border-radius:var(--radius-sm);
            white-space:nowrap;
        }

        .price-zone{
            display:flex;
            flex-wrap:wrap;
            gap:.5rem 1rem;
            margin-top:.75rem;
            font-size:.8rem;
            line-height:1.4;
        }
        .price-block{
            display:flex;
            flex-direction:column;
            gap:.25rem;
        }

        .price-current{
            font-size:.9rem;
            font-weight:600;
            color:var(--success);
            line-height:1.3;
        }
        .price-original{
            font-size:.75rem;
            color:var(--ink-500);
            line-height:1.3;
        }
        .price-original .strike{
            text-decoration:line-through;
        }

        .cooktime{
            font-size:.75rem;
            color:var(--ink-500);
            display:flex;
            align-items:center;
            gap:.4rem;
            white-space:nowrap;
        }

        .menu-card-footer{
            border-top:1px solid var(--line);
            margin-top:1rem;
            padding-top:.75rem;
            display:flex;
            justify-content:space-between;
            align-items:center;
            flex-wrap:wrap;
            row-gap:.5rem;
        }

        .btn-action-group{
            display:flex;
            flex-wrap:nowrap;
            gap:.4rem;
        }
        .btn-action{
            border-radius:var(--radius-sm);
            font-size:.75rem;
            line-height:1.2;
            padding:.4rem .5rem;
        }

        /************************************
         * EMPTY STATE
         ************************************/
        .empty-state{
            text-align:center;
            padding:3rem 1rem;
            color:var(--ink-500);
        }
        .empty-state i{
            font-size:3rem;
            margin-bottom:1rem;
            opacity:.4;
            color:var(--brand);
        }
        .empty-state h4{
            font-size:1.1rem;
            font-weight:600;
            color:var(--ink-900);
        }

        /************************************
         * PAGINATION
         ************************************/
        .pagination-custom .page-link{
            border-radius:50px;
            margin:0 2px;
            border:none;
            color:var(--brand);
            font-weight:500;
        }
        .pagination-custom .page-link:hover{
            background-color:var(--brand);
            color:#fff;
        }
        .pagination-custom .page-item.active .page-link{
            background-color:var(--brand);
            border-color:var(--brand);
            color:#fff;
        }

        /************************************
         * MODAL OVERRIDE
         ************************************/
        .modal-content{
            border-radius:var(--radius-md);
            border:1px solid rgba(99,102,241,.25);
            box-shadow:0 28px 64px rgba(15,23,42,.25);
        }
        .modal-header{
            border-bottom:1px solid var(--line);
            background:linear-gradient(to right,rgba(254,161,22,.08),rgba(99,102,241,.08));
        }
        .modal-footer{
            border-top:1px solid var(--line);
        }

        /************************************
         * ALERT AUTOCLOSE
         ************************************/
        .alert{
            border-radius:var(--radius-md);
            box-shadow:0 20px 40px rgba(0,0,0,.12);
        }
    </style>
</head>

<body>
<!-- Global Header/Navbar -->
<jsp:include page="/layouts/Header.jsp"/>

<div class="app-shell">
    <!-- Sidebar -->
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <!-- MAIN AREA -->
    <main class="main-pane">

        <!-- Topbar kiểu POS -->
        <header class="pos-topbar">
            <div class="pos-left">
                <div class="title-row">
                    <i class="bi bi-journal-bookmark"></i>
                    <span>Quản lý Menu</span>
                </div>
                <div class="sub">
                    Danh sách món bán hiện tại · Chỉnh sửa giá / trạng thái / mô tả món
                </div>
            </div>

            <div class="pos-right">
                <div class="user-chip">
                    <i class="bi bi-person-badge"></i>
                    <span>${sessionScope.user.fullName}</span>
                    <span class="role-badge">${sessionScope.user.roleName}</span>
                </div>

                <button class="btn-toggle-sidebar" onclick="toggleSidebar()">
                    <i class="bi bi-list"></i>
                    <span>Menu</span>
                </button>
            </div>
        </header>

        <!-- FLASH MESSAGE -->
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

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- BỘ LỌC / TÌM KIẾM -->
        <section class="filters-card">
            <div class="filters-head">
                <div class="filters-head-left">
                    <i class="bi bi-funnel"></i>
                    <div class="filters-title-wrap">
                        <div class="filters-title">Bộ lọc & tìm kiếm món</div>
                        <div class="filters-sub">
                            Lọc theo danh mục, tình trạng bán, giá...
                        </div>
                    </div>
                </div>
            </div>

            <form method="GET" action="${pageContext.request.contextPath}/menu-management" class="row g-3">
                <!-- Tìm kiếm -->
                <div class="col-md-4">
                    <label for="search" class="form-label">Tìm kiếm</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input
                            type="text"
                            class="form-control"
                            id="search"
                            name="search"
                            placeholder="Tên món ăn..."
                            value="${searchParam != null ? searchParam : ''}">
                    </div>
                </div>

                <!-- Danh mục -->
                <div class="col-md-3">
                    <label for="category" class="form-label">Danh mục</label>
                    <select class="form-select" id="category" name="category">
                        <option value="">Tất cả danh mục</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}"
                                <c:if test="${categoryParam == (cat.categoryId).toString()}">selected</c:if>>
                                ${cat.categoryName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Trạng thái -->
                <div class="col-md-2">
                    <label for="availability" class="form-label">Trạng thái</label>
                    <select class="form-select" id="availability" name="availability">
                        <option value="">Tất cả</option>
                        <option value="AVAILABLE"
                            <c:if test="${availabilityParam == 'AVAILABLE'}">selected</c:if>>Có sẵn</option>
                        <option value="OUT_OF_STOCK"
                            <c:if test="${availabilityParam == 'OUT_OF_STOCK'}">selected</c:if>>Hết hàng</option>
                        <option value="DISCONTINUED"
                            <c:if test="${availabilityParam == 'DISCONTINUED'}">selected</c:if>>Ngừng bán</option>
                    </select>
                </div>

                <!-- Sắp xếp -->
                <div class="col-md-2">
                    <label for="sortBy" class="form-label">Sắp xếp</label>
                    <select class="form-select" id="sortBy" name="sortBy">
                        <option value="" <c:if test="${empty sortByParam}">selected</c:if>>Mặc định</option>
                        <option value="name_asc"    <c:if test="${sortByParam == 'name_asc'}">selected</c:if>>Tên A-Z</option>
                        <option value="name_desc"   <c:if test="${sortByParam == 'name_desc'}">selected</c:if>>Tên Z-A</option>
                        <option value="price_asc"   <c:if test="${sortByParam == 'price_asc'}">selected</c:if>>Giá tăng</option>
                        <option value="price_desc"  <c:if test="${sortByParam == 'price_desc'}">selected</c:if>>Giá giảm</option>
                        <option value="category"    <c:if test="${sortByParam == 'category'}">selected</c:if>>Theo danh mục</option>
                    </select>
                </div>

                <!-- Nút submit -->
                <div class="col-md-1 d-flex align-items-end">
                    <button type="submit" class="btn btn-filter-icon w-100">
                        <i class="bi bi-funnel"></i>
                    </button>
                </div>
            </form>
        </section>

        <!-- THANH THÔNG TIN KẾT QUẢ / ACTION -->
        <section class="result-bar">
            <div class="result-left">
                <span>Tìm thấy ${totalItems} món ăn</span>

                <c:if test="${not empty searchParam
                              or not empty categoryParam
                              or not empty availabilityParam
                              or not empty sortByParam}">
                    <a href="${pageContext.request.contextPath}/menu-management"
                       class="btn btn-outline-secondary btn-sm clear-filter-btn">
                        <i class="bi bi-x-circle me-1"></i>Xóa bộ lọc
                    </a>
                </c:if>
            </div>

            <div class="result-right">
                <c:if test="${sessionScope.user.roleName eq 'Manager'}">
                    <a href="${pageContext.request.contextPath}/menu-management?action=create"
                       class="btn-add-dish">
                        <i class="bi bi-plus-circle"></i>
                        <span>Thêm món mới</span>
                    </a>
                </c:if>
            </div>
        </section>

        <!-- GRID DANH SÁCH MÓN -->
        <c:choose>
            <c:when test="${empty menuItems}">
                <div class="empty-state">
                    <i class="bi bi-journal-x"></i>
                    <h4>Không tìm thấy món ăn nào</h4>
                    <p>Thử thay đổi bộ lọc hoặc thêm món ăn mới.</p>

                    <c:if test="${sessionScope.user.roleName eq 'Manager'}">
                        <a href="${pageContext.request.contextPath}/menu-management?action=create"
                           class="btn-add-dish" style="text-decoration:none;">
                            <i class="bi bi-plus-circle"></i>
                            <span>Thêm món đầu tiên</span>
                        </a>
                    </c:if>
                </div>
            </c:when>

            <c:otherwise>
                <section class="menu-grid">
                    <c:forEach var="item" items="${menuItems}">
                        <article class="menu-card">
                            <!-- hàng trên: ảnh + tên + badge trạng thái -->
                            <div class="item-head-row">
                                <div class="item-left">
                                    <div class="thumb-wrap">
                                        <c:choose>
                                            <c:when test="${not empty item.imageUrl}">
                                                <img src="${item.imageUrl}"
                                                     alt="${item.name}"
                                                     class="menu-thumb"
                                                     onerror="this.src='${pageContext.request.contextPath}/img/default-avatar.svg'"/>
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/img/default-avatar.svg"
                                                     alt="${item.name}"
                                                     class="menu-thumb"/>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="item-main">
                                        <div class="item-name">${item.name}</div>
                                        <div class="item-cat">${item.categoryName}</div>
                                        <div class="item-desc">${item.description}</div>
                                    </div>
                                </div>

                                <span class="status-badge ${item.statusBadgeClass}">
                                    ${item.availabilityDisplay}
                                </span>
                            </div>

                            <!-- khối giá + thời gian chế biến -->
                            <div class="price-zone">
                                <div class="price-block">
                                    <c:if test="${item.displayPrice ne null && item.displayPrice ne item.basePrice}">
                                        <div class="price-original">
                                            Giá gốc:
                                            <span class="strike">
                                                <fmt:formatNumber value="${item.basePrice}" type="currency" currencySymbol="₫"/>
                                            </span>
                                        </div>
                                        <div class="price-current">
                                            Giá áp dụng:
                                            <fmt:formatNumber value="${item.displayPrice}" type="currency" currencySymbol="₫"/>
                                        </div>
                                    </c:if>

                                    <c:if test="${item.displayPrice eq null || item.displayPrice eq item.basePrice}">
                                        <div class="price-current">
                                            Giá hiện tại:
                                            <fmt:formatNumber value="${item.basePrice}" type="currency" currencySymbol="₫"/>
                                        </div>
                                    </c:if>
                                </div>

                                <div class="cooktime">
                                    <i class="bi bi-clock"></i>
                                    <span>${item.preparationTime} phút</span>
                                </div>
                            </div>

                            <!-- footer: hành động -->
                            <div class="menu-card-footer">
                                <small class="text-muted">
                                    #${item.itemId}
                                </small>

                                <div class="btn-action-group">
                                    <a href="${pageContext.request.contextPath}/menu-management?action=view&id=${item.itemId}"
                                       class="btn btn-outline-info btn-action"
                                       title="Xem chi tiết">
                                        <i class="bi bi-eye"></i>
                                    </a>

                                    <c:if test="${sessionScope.user.roleName eq 'Manager'}">
                                        <a href="${pageContext.request.contextPath}/menu-management?action=edit&id=${item.itemId}"
                                           class="btn btn-outline-warning btn-action"
                                           title="Chỉnh sửa">
                                            <i class="bi bi-pencil"></i>
                                        </a>

                                        <button type="button"
                                                class="btn btn-outline-danger btn-action"
                                                title="Xóa"
                                                onclick="confirmDelete(${item.itemId}, '${fn:escapeXml(item.name)}')">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                        </article>
                    </c:forEach>
                </section>

                <!-- PHÂN TRANG -->
                <c:if test="${totalPages > 1}">
                    <nav aria-label="Menu pagination" class="mt-4">
                        <ul class="pagination pagination-custom justify-content-center">

                            <!-- Prev -->
                            <c:if test="${currentPage > 1}">
                                <li class="page-item">
                                    <a class="page-link"
                                       href="${pageContext.request.contextPath}/menu-management?page=${currentPage-1
                                        }<c:if test='${not empty searchParam}'>&amp;search=${fn:escapeXml(searchParam)}</c:if
                                        ><c:if test='${not empty categoryParam}'>&amp;category=${categoryParam}</c:if
                                        ><c:if test='${not empty availabilityParam}'>&amp;availability=${availabilityParam}</c:if
                                        ><c:if test='${not empty sortByParam}'>&amp;sortBy=${sortByParam}</c:if>">
                                        <i class="bi bi-chevron-left"></i>
                                    </a>
                                </li>
                            </c:if>

                            <!-- Page numbers -->
                            <c:forEach begin="1" end="${totalPages}" var="pageNum">
                                <c:if test="${pageNum <= 3
                                             or pageNum >= totalPages - 2
                                             or (pageNum >= currentPage - 1 and pageNum <= currentPage + 1)}">
                                    <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                        <a class="page-link"
                                           href="${pageContext.request.contextPath}/menu-management?page=${pageNum
                                            }<c:if test='${not empty searchParam}'>&amp;search=${fn:escapeXml(searchParam)}</c:if
                                            ><c:if test='${not empty categoryParam}'>&amp;category=${categoryParam}</c:if
                                            ><c:if test='${not empty availabilityParam}'>&amp;availability=${availabilityParam}</c:if
                                            ><c:if test='${not empty sortByParam}'>&amp;sortBy=${sortByParam}</c:if>">
                                            ${pageNum}
                                        </a>
                                    </li>
                                </c:if>

                                <c:if test="${pageNum == 3 && currentPage > 5}">
                                    <li class="page-item disabled"><span class="page-link">...</span></li>
                                </c:if>

                                <c:if test="${pageNum == totalPages - 2 && currentPage < totalPages - 4}">
                                    <li class="page-item disabled"><span class="page-link">...</span></li>
                                </c:if>
                            </c:forEach>

                            <!-- Next -->
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-item">
                                    <a class="page-link"
                                       href="${pageContext.request.contextPath}/menu-management?page=${currentPage+1
                                        }<c:if test='${not empty searchParam}'>&amp;search=${fn:escapeXml(searchParam)}</c:if
                                        ><c:if test='${not empty categoryParam}'>&amp;category=${categoryParam}</c:if
                                        ><c:if test='${not empty availabilityParam}'>&amp;availability=${availabilityParam}</c:if
                                        ><c:if test='${not empty sortByParam}'>&amp;sortBy=${sortByParam}</c:if>">
                                        <i class="bi bi-chevron-right"></i>
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </nav>
                </c:if>
            </c:otherwise>
        </c:choose>

    </main>
</div>

<!-- Footer -->
<jsp:include page="/layouts/Footer.jsp"/>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1"
     aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="deleteModalLabel">Xác nhận xóa</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"
                        aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc chắn muốn xóa món ăn
                    <strong id="itemNameToDelete"></strong>?</p>
                <p class="text-muted small">Hành động này sẽ ẩn món ăn khỏi menu nhưng
                    không xóa vĩnh viễn.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary"
                        data-bs-dismiss="modal">Hủy</button>

                <form id="deleteForm" method="POST"
                      action="${pageContext.request.contextPath}/menu-management"
                      style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="itemId" id="itemIdToDelete">
                    <button type="submit" class="btn btn-danger">Xóa</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function toggleSidebar(){
    var el=document.getElementById('sidebar');
    if(el) el.classList.toggle('open');
}

function confirmDelete(itemId,itemName){
    document.getElementById('itemIdToDelete').value=itemId;
    document.getElementById('itemNameToDelete').textContent=itemName;
    var modal=new bootstrap.Modal(document.getElementById('deleteModal'));
    modal.show();
}

// auto-close alerts
setTimeout(function(){
    var alerts=document.querySelectorAll('.alert');
    alerts.forEach(function(alert){
        try{
            var bsAlert=new bootstrap.Alert(alert);
            bsAlert.close();
        }catch(e){}
    });
},5000);
</script>
</body>
</html>
