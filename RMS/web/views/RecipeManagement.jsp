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
    <title>Quản lý Công thức món | RMSG4</title>
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
        }
        body { background: var(--bg-app); }
        .content { padding: 28px 32px; max-width: 1400px; margin: 0 auto; }
        .card { border: none; border-radius: 16px; box-shadow: 0 8px 28px rgba(20,24,40,.08); margin-bottom: 1.5rem; }
        .card-header { background: linear-gradient(180deg, rgba(79,70,229,.06), transparent); }
        .menu-card {
            transition: all 0.2s;
            cursor: pointer;
            border: 2px solid transparent;
        }
        .menu-card:hover {
            border-color: var(--accent);
            transform: translateY(-2px);
        }
        .menu-card.no-recipe {
            opacity: 0.7;
            border-color: #fbbf24;
        }
    </style>
</head>
<body>

<jsp:include page="/layouts/Header.jsp"/>

<div class="app-shell" style="display:grid; grid-template-columns:280px 1fr;">
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <main class="content">
        <h3 class="mb-4">
            <i class="bi bi-list-check text-primary"></i> Quản lý Công thức món ăn (BOM)
        </h3>

        <div class="alert alert-info">
            <i class="bi bi-info-circle me-2"></i>
            <strong>Hướng dẫn:</strong> Click vào món ăn để thiết lập công thức (danh sách nguyên liệu và định lượng).
            Món chưa có công thức sẽ được đánh dấu màu vàng.
        </div>

        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            <c:forEach var="item" items="${menuItems}">
                <div class="col">
                    <div class="card menu-card h-100" onclick="window.location.href='recipe-management?action=edit&menuItemId=${item.itemId}'">
                        <div class="card-body">
                            <div class="d-flex align-items-start gap-3">
                                <c:choose>
                                    <c:when test="${not empty item.imageUrl}">
                                        <img src="${item.imageUrl}" alt="${item.name}" 
                                             style="width:64px;height:64px;border-radius:8px;object-fit:cover;">
                                    </c:when>
                                    <c:otherwise>
                                        <div style="width:64px;height:64px;border-radius:8px;background:#e5e7eb;display:flex;align-items:center;justify-content:center;">
                                            <i class="bi bi-image text-muted"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                
                                <div class="flex-grow-1">
                                    <h6 class="mb-1">${item.name}</h6>
                                    <small class="text-muted">${item.categoryName}</small>
                                    <div class="mt-2">
                                        <span class="badge bg-primary">
                                            <i class="bi bi-list-ul"></i> Công thức
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <c:if test="${empty menuItems}">
            <div class="text-center py-5">
                <i class="bi bi-inbox" style="font-size:3rem;color:#cbd5e1;"></i>
                <p class="text-muted mt-3">Chưa có món ăn nào. Thêm món trong <a href="menu-management">Quản lý Menu</a>.</p>
            </div>
        </c:if>
    </main>
</div>

<jsp:include page="/layouts/Footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

