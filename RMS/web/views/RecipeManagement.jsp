<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "recipe");
%>

<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Quản lý Công thức món | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>

    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <!-- Icons & CSS -->
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

            --primary:#4f46e5;
            --success:#16a34a;

            --line:#e5e7eb;
            --shadow-card:0 20px 48px rgba(15,23,42,.10);

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

        /* TOP BAR */
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
            display: flex;
            align-items: center;
            gap: .6rem;
            font-weight: 600;
            font-size: 1rem;
            line-height: 1.35;
        }
        .pos-left .title-row i {
            color: var(--accent);
            font-size: 1.1rem;
        }
        .pos-left .sub {
            margin-top: 4px;
            font-size: .8rem;
            color: var(--ink-400);
        }

        .pos-right {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: .75rem;
        }

        .user-chip {
            display: flex;
            align-items: center;
            gap: .5rem;
            background: rgba(255,255,255,.06);
            border: 1px solid rgba(255,255,255,.18);
            border-radius: var(--radius-md);
            padding: 6px 10px;
            font-size: .8rem;
            line-height: 1.2;
            font-weight: 500;
        }
        .user-chip .role-badge {
            background: var(--accent);
            color: #1e1e2f;
            border-radius: var(--radius-sm);
            padding: 2px 6px;
            font-size: .7rem;
            font-weight: 600;
            line-height: 1.2;
        }

        .btn-toggle-sidebar {
            display: none;
        }
        @media(max-width:992px){
            .btn-toggle-sidebar{
                display: inline-flex;
                align-items: center;
                gap: .4rem;
                background: transparent;
                border: 1px solid rgba(255,255,255,.3);
                color:#fff;
                font-size:.8rem;
                line-height:1.2;
                border-radius: var(--radius-sm);
                padding:6px 10px;
            }
            .btn-toggle-sidebar:hover {
                background: rgba(255,255,255,.07);
            }
        }

        /* INTRO & GRID */
        .page-intro {
            background: linear-gradient(to right, rgba(79,70,229,.06), rgba(254,161,22,.06));
            border-radius: var(--radius-md);
            border:1px solid rgba(148,163,184,.35);
            padding: 12px 16px;
            margin-bottom: 18px;
            font-size: .85rem;
            color: var(--ink-700);
            display:flex;
            align-items:flex-start;
            gap:.6rem;
        }
        .page-intro i {
            color: var(--accent);
            margin-top: 2px;
        }

        .recipe-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 1rem;
        }

        .menu-card {
            border-radius: 16px;
            border: 2px solid transparent;
            background: linear-gradient(to bottom right, var(--panel-light-top) 0%, var(--panel-light-bottom) 100%);
            box-shadow: var(--shadow-card);
            transition: all .18s ease;
            cursor: pointer;
        }
        .menu-card:hover {
            border-color: var(--accent);
            transform: translateY(-2px);
            box-shadow: 0 24px 64px rgba(15,23,42,.12);
        }
        .menu-card.no-recipe {
            border-color: #facc15;
            box-shadow: 0 18px 40px rgba(250, 204, 21, .35);
        }

        .menu-card-body {
            padding: 0.9rem 0.9rem 0.85rem;
        }

        .dish-name {
            font-size: .95rem;
            font-weight: 600;
            color: var(--ink-900);
        }
        .dish-category {
            font-size: .8rem;
            color: var(--ink-500);
        }

        .recipe-badge {
            font-size:.7rem;
            border-radius: var(--radius-sm);
            padding:.25rem .45rem;
            background: rgba(79,70,229,.06);
            color: #4338ca;
            border:1px solid rgba(129,140,248,.55);
            display:inline-flex;
            align-items:center;
            gap:.25rem;
        }
        .recipe-badge i { font-size:.8rem; }

        .empty-state {
            text-align:center;
            padding: 52px 16px 40px;
            border-radius: var(--radius-lg);
            border:1px dashed rgba(148,163,184,.7);
            background: radial-gradient(circle at top, rgba(148,163,184,.08), transparent 55%);
            margin-top:12px;
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
        <!-- TOP BAR -->
        <header class="pos-topbar">
            <div class="pos-left">
                <div class="title-row">
                    <i class="bi bi-list-check"></i>
                    <span>Quản lý Công thức món ăn (BOM)</span>
                </div>
                <div class="sub">
                    Định nghĩa công thức chuẩn cho từng món: nguyên liệu, định lượng → hỗ trợ cost & vận hành bếp.
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

        <!-- ALERTS (nếu sử dụng chung success/error trong session) -->
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

        <!-- INTRO -->
        <div class="page-intro">
            <i class="bi bi-info-circle"></i>
            <div>
                <strong>Hướng dẫn:</strong>
                Click vào món ăn để thiết lập công thức (danh sách nguyên liệu và định lượng).
                Món chưa có công thức sẽ được đánh dấu nổi bật.
            </div>
        </div>

        <!-- GRID MÓN ĂN -->
        <c:if test="${not empty menuItems}">
            <div class="recipe-grid">
                <c:forEach var="item" items="${menuItems}">
                    <!-- lấy trạng thái đã có công thức từ Map -->
                    <c:set var="hasRecipe" value="${hasRecipeMap[item.itemId]}"/>

                    <c:url var="editUrl" value="/recipe-management">
                        <c:param name="action" value="edit"/>
                        <c:param name="menuItemId" value="${item.itemId}"/>
                    </c:url>

                    <div class="menu-card ${hasRecipe ? '' : 'no-recipe'}"
                         onclick="window.location.href='${editUrl}'">
                        <div class="menu-card-body">
                            <div class="d-flex align-items-start gap-3">
                                <c:choose>
                                    <c:when test="${not empty item.imageUrl}">
                                        <img src="${item.imageUrl}" alt="${item.name}"
                                             style="width:64px;height:64px;border-radius:10px;object-fit:cover;">
                                    </c:when>
                                    <c:otherwise>
                                        <div style="width:64px;height:64px;border-radius:10px;background:#e5e7eb;
                                                    display:flex;align-items:center;justify-content:center;">
                                            <i class="bi bi-image text-muted"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                                <div class="flex-grow-1">
                                    <div class="dish-name mb-1">${item.name}</div>
                                    <div class="dish-category">
                                        <i class="bi bi-grid-3x3-gap me-1"></i>${item.categoryName}
                                    </div>

                                    <div class="mt-2 d-flex align-items-center gap-2">
                                        <span class="recipe-badge">
                                            <i class="bi bi-list-ul"></i>
                                            Công thức
                                        </span>

                                        <c:choose>
                                            <c:when test="${hasRecipe}">
                                                <span class="badge bg-success"
                                                      style="font-size:.7rem;">
                                                    Đã thiết lập
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning text-dark"
                                                      style="font-size:.7rem;">
                                                    Chưa thiết lập
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </c:forEach>
            </div>
        </c:if>

        <!-- EMPTY STATE -->
        <c:if test="${empty menuItems}">
            <div class="empty-state">
                <i class="bi bi-inbox" style="font-size:3rem;color:#cbd5e1;"></i>
                <p class="text-muted mt-3 mb-1">
                    Chưa có món ăn nào.
                </p>
                <p class="text-muted mb-0">
                    Thêm món trong
                    <a href="<c:url value='/menu-management'/>" class="text-decoration-none">
                        Quản lý Menu
                    </a>.
                </p>
            </div>
        </c:if>
    </main>
</div>

<jsp:include page="/layouts/Footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function toggleSidebar() {
        var el = document.getElementById('sidebar');
        if (el) el.classList.toggle('open');
    }

    // Tự ẩn alert sau 5s
    setTimeout(function () {
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function (al) {
            if (typeof bootstrap !== 'undefined') {
                var bsAlert = new bootstrap.Alert(al);
                bsAlert.close();
            }
        });
    }, 5000);
</script>
</body>
</html>
