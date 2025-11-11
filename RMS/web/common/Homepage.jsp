<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="page" value="home" scope="request"/>
<c:set var="overlayNav" value="true" scope="request"/>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="utf-8">
        <title>Trang chủ | RMSG4</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="RMSG4 – Nhà hàng phục vụ món ăn ngon và dịch vụ tuyệt vời">

        <!-- Favicon -->
        <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

        <!-- Google Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com"/>
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
        <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet"/>

        <!-- Icons -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>

        <!-- Vendor CSS -->
        <link href="<c:url value='/lib/animate/animate.min.css'/>" rel="stylesheet"/>
        <link href="<c:url value='/lib/owlcarousel/assets/owl.carousel.min.css'/>" rel="stylesheet"/>
        <link href="<c:url value='/lib/tempusdominus/css/tempusdominus-bootstrap-4.min.css'/>" rel="stylesheet"/>

        <!-- Bootstrap -->
        <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>

        <!-- Theme CSS -->
        <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

        <!-- Three.js + OrbitControls -->
        <script src="https://cdn.jsdelivr.net/npm/three@0.152.2/build/three.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/three@0.152.2/examples/js/controls/OrbitControls.js"></script>

        <style>
            body {
                background: #edf2ff;
            }

            /* Hero */
            .hero-header {
                background: radial-gradient(circle at top, #111827, #020617);
            }
            .hero-header h1 span.badge-pos {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                font-size: .85rem;
                padding: 6px 12px;
                border-radius: 999px;
                background: rgba(15, 23, 42, .85);
                border: 1px solid rgba(248, 181, 55, .9);
            }

            /* Stats small strip dưới hero */
            .home-mini-stats {
                margin-top: -40px;
            }
            .mini-stat-card {
                background: #ffffff;
                border-radius: 18px;
                box-shadow: 0 14px 35px rgba(15, 23, 42, .12);
                padding: 14px 18px;
                display: flex;
                align-items: center;
                gap: 12px;
            }
            .mini-stat-icon {
                width: 40px;
                height: 40px;
                border-radius: 12px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                background: rgba(248, 181, 55, .12);
                color: #f59e0b;
                font-size: 1.2rem;
            }
            .mini-stat-label {
                font-size: .8rem;
                text-transform: uppercase;
                letter-spacing: .08em;
                color: #6b7280;
                margin-bottom: 2px;
            }
            .mini-stat-value {
                font-weight: 700;
                font-size: 1rem;
            }

            /* Team cards */
            .team-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 24px;
            }
            .team-card {
                background: #ffffff;
                border-radius: 18px;
                box-shadow: 0 18px 40px rgba(15, 23, 42, 0.08);
                padding: 18px 18px 20px;
                text-align: center;
                transition: transform .18s ease, box-shadow .18s ease;
            }
            .team-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 26px 60px rgba(15, 23, 42, 0.15);
            }
            .team-avatar-wrap {
                width: 120px;
                height: 120px;
                border-radius: 999px;
                overflow: hidden;
                margin: 0 auto 12px;
                border: 3px solid rgba(254, 161, 22, .85);
            }
            .team-avatar-wrap img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
            .team-name {
                font-weight: 600;
                font-size: 1rem;
                margin-bottom: 4px;
            }
            .team-role {
                font-size: .85rem;
                color: #64748b;
            }

            /* 3D floor card */
            .floor-wrapper {
                background: radial-gradient(circle at top, #1f2937, #020617);
                border-radius: 24px;
                padding: 24px 24px 14px;
                color: #e5e7eb;
                box-shadow: 0 32px 80px rgba(15, 23, 42, .75);
            }
            .floor-title {
                font-size: 1rem;
                font-weight: 600;
                margin-bottom: 4px;
            }
            .floor-subtitle {
                font-size: .85rem;
                color: #9ca3af;
            }
            #restaurant3dCanvas {
                width: 100%;
                height: 320px;
                margin-top: 18px;
                border-radius: 18px;
                overflow: hidden;
                background: radial-gradient(circle at top, #111827, #020617);
                position: relative;
            }
            .floor-legend {
                margin-top: 10px;
                font-size: .8rem;
            }
            .legend-dot {
                display: inline-block;
                width: 10px;
                height: 10px;
                border-radius: 999px;
                margin-right: 4px;
            }
            .area-summary {
                font-size: .85rem;
                color: #d1d5db;
                margin-top: 6px;
            }
            .area-summary strong {
                color: #fbbf24;
            }

            /* Menu horizontal */
            .menu-scroller {
                display: flex;
                gap: 18px;
                overflow-x: auto;
                padding-bottom: 8px;
                scroll-snap-type: x mandatory;
            }
            .menu-scroller::-webkit-scrollbar {
                height: 6px;
            }
            .menu-scroller::-webkit-scrollbar-track {
                background: #e5e7eb;
            }
            .menu-scroller::-webkit-scrollbar-thumb {
                background: #cbd5f5;
                border-radius: 999px;
            }
            .menu-card {
                min-width: 280px;
                max-width: 320px;
                background: #ffffff;
                border-radius: 18px;
                box-shadow: 0 14px 35px rgba(15, 23, 42, 0.07);
                padding: 12px 12px 14px;
                display: flex;
                gap: 10px;
                scroll-snap-align: start;
                align-items: flex-start;
            }
            .menu-card img {
                width: 80px;
                height: 80px;
                border-radius: 12px;
                object-fit: cover;
            }
            .menu-card-title {
                font-weight: 600;
                font-size: .95rem;
                margin-bottom: 4px;
            }
            .menu-card-desc {
                font-size: .8rem;
                color: #6b7280;
            }
            .menu-card-price {
                color: #f97316;
                font-weight: 700;
                font-size: .95rem;
            }

            .menu-category-pills {
                list-style: none;
                padding: 0;
                margin: 0 0 18px;
                display: flex;
                flex-wrap: wrap;
                justify-content: center;
                gap: 10px;
            }
            .menu-category-pills button {
                border-radius: 999px;
                border: 1px solid #e5e7eb;
                padding: 6px 14px;
                background: #ffffff;
                font-size: .85rem;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                cursor: pointer;
                color: #111827;
            }
            .menu-category-pills button i {
                color: #f59e0b;
            }
            .menu-category-pills button.active {
                background: #111827;
                color: #f9fafb;
                border-color: #111827;
            }

            /* Khối Khuyến mãi + Món bán chạy – dashboard style */
            .pos-home-section-wrap {
                background: #e5f0ff;
                border-radius: 32px;
                padding: 32px 28px;
            }
            .pos-panel {
                border-radius: 24px;
                padding: 22px 22px 20px;
                height: 100%;
                box-shadow: 0 18px 40px rgba(15, 23, 42, 0.10);
                background: #ffffff;
            }
            .pos-panel-dark {
                background: radial-gradient(circle at top, #111827, #020617);
                color: #e5e7eb;
                box-shadow: 0 28px 70px rgba(15, 23, 42, 0.75);
            }
            .pos-panel-header .pos-panel-kicker {
                font-family: 'Pacifico', cursive;
                font-size: 1.1rem;
            }
            .pos-panel-sub {
                font-size: .85rem;
                color: #6b7280;
            }

            /* Promo list */
            .promo-item {
                display: flex;
                gap: 14px;
                align-items: flex-start;
                padding: 10px 0;
                border-bottom: 1px dashed rgba(148, 163, 184, .40);
            }
            .promo-item:last-child {
                border-bottom: none;
                padding-bottom: 0;
            }
            .promo-badge {
                background: #f97316;
                color: #ffffff;
                font-weight: 700;
                font-size: .8rem;
                padding: 6px 12px;
                border-radius: 999px;
                min-width: 60px;
                text-align: center;
                box-shadow: 0 10px 25px rgba(248, 150, 30, .45);
            }
            .promo-title {
                font-size: .95rem;
                font-weight: 600;
            }
            .promo-meta {
                font-size: .8rem;
                color: #6b7280;
                margin-bottom: 2px;
            }
            .promo-meta .bullet {
                margin: 0 4px;
            }
            .promo-desc {
                font-size: .8rem;
            }

            /* Best seller cards – dạng grid */
            .best-seller-strip {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
                gap: 16px;
                margin-top: 12px;
            }
            .best-seller-item {
                background: radial-gradient(circle at top left, #111827, #020617);
                color: #e5e7eb;
                border-radius: 18px;
                padding: 14px 14px 16px;
                box-shadow: 0 18px 45px rgba(15, 23, 42, 0.8);
            }
            .best-seller-item h6 {
                margin-bottom: 4px;
                font-size: .95rem;
                color: #f9fafb !important; /* THÊM DÒNG NÀY */
            }
            .best-seller-tag {
                font-size: .78rem;
                text-transform: uppercase;
                letter-spacing: .04em;
                color: #9ca3af;
                margin-bottom: 2px;
            }
            .best-seller-price {
                color: #facc15;
                font-weight: 700;
                font-size: 1rem;
                margin-top: 4px;
            }

            .text-gray-300 {
                color: #d1d5db !important;
            }
            .text-gray-400 {
                color: #9ca3af !important;
            }

            @media (max-width: 768px) {
                #restaurant3dCanvas {
                    height: 260px;
                }
                .home-mini-stats {
                    margin-top: -20px;
                }
                .pos-home-section-wrap {
                    padding: 22px 18px;
                    border-radius: 24px;
                }
            }
        </style>
    </head>
    <body>

        <!-- Header -->
        <jsp:include page="/layouts/Header.jsp"/>

        <!-- Hero -->
        <section class="container-xxl py-5 bg-dark hero-header mb-5">
            <div class="container my-5 py-5">
                <div class="row align-items-center g-5">
                    <div class="col-lg-6 text-center text-lg-start">
                        <h1 class="display-3 text-white animated slideInLeft">
                            <c:out value="${restaurantInfo.heroTitle}" escapeXml="false"/>
                        </h1>
                        <p class="text-white-50 animated slideInLeft mb-4 pb-2">
                            ${restaurantInfo.heroSubtitle}
                        </p>
                        <a href="<c:url value='/booking'/>"
                           class="btn btn-primary py-sm-3 px-sm-5 me-3 animated slideInLeft">
                            Đặt bàn ngay
                        </a>
                        <span class="badge-pos text-white ms-2 animated slideInLeft">
                            <i class="bi bi-display"></i>
                            <span>RMSG4 POS · 5★ restaurant flow</span>
                        </span>
                    </div>
                    <div class="col-lg-6 text-center text-lg-end overflow-hidden">
                        <img class="img-fluid" src="<c:url value='/img/hero.png'/>" alt="Hero"/>
                    </div>
                </div>
            </div>
        </section>

        <!-- Mini stats -->
        <section class="container-xxl home-mini-stats mb-5">
            <div class="container">
                <div class="row g-3">
                    <div class="col-md-4">
                        <div class="mini-stat-card">
                            <div class="mini-stat-icon">
                                <i class="bi bi-stars"></i>
                            </div>
                            <div>
                                <div class="mini-stat-label">Kinh nghiệm</div>
                                <div class="mini-stat-value">15+ năm phục vụ ẩm thực</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="mini-stat-card">
                            <div class="mini-stat-icon">
                                <i class="bi bi-people-fill"></i>
                            </div>
                            <div>
                                <div class="mini-stat-label">Đội ngũ</div>
                                <div class="mini-stat-value">50+ đầu bếp &amp; nhân viên</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="mini-stat-card">
                            <div class="mini-stat-icon">
                                <i class="bi bi-cash-stack"></i>
                            </div>
                            <div>
                                <div class="mini-stat-label">Thanh toán</div>
                                <div class="mini-stat-value">Tiền mặt · VNPay · voucher</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- About + 3D -->
        <section class="container-xxl py-5">
            <div class="container">
                <div class="row g-5 align-items-start">
                    <div class="col-lg-6">
                        <h5 class="section-title ff-secondary text-start text-primary fw-normal">Giới thiệu</h5>
                        <h1 class="mb-4">
                            Chào mừng đến
                            <i class="fa fa-utensils text-primary me-2"></i>
                            ${restaurantInfo.name}
                        </h1>
                        <p class="mb-4">${restaurantInfo.introText}</p>
                        <p class="mb-4">
                            Hệ thống RMS G4 mô phỏng luồng POS nhà hàng 5★:
                            quản lý bàn, đặt chỗ, đơn mang đi, voucher, VNPay…
                            tất cả trong một màn hình trực quan.
                        </p>
                        <div class="row g-4 mb-4">
                            <div class="col-sm-6">
                                <div class="d-flex align-items-center border-start border-5 border-primary px-3">
                                    <h1 class="flex-shrink-0 display-5 text-primary mb-0" data-toggle="counter-up">15</h1>
                                    <div class="ps-4">
                                        <p class="mb-0">Năm</p>
                                        <h6 class="text-uppercase mb-0">Kinh nghiệm</h6>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="d-flex align-items-center border-start border-5 border-primary px-3">
                                    <h1 class="flex-shrink-0 display-5 text-primary mb-0" data-toggle="counter-up">50</h1>
                                    <div class="ps-4">
                                        <p class="mb-0">Đầu bếp &amp; nhân viên</p>
                                        <h6 class="text-uppercase mb-0">Chuyên nghiệp</h6>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 3D floor -->
                    <div class="col-lg-6">
                        <div class="floor-wrapper">
                            <div class="floor-title">
                                <i class="bi bi-diagram-3 me-2 text-warning"></i>
                                Sơ đồ nhà hàng (3D)
                            </div>
                            <div class="floor-subtitle">
                                Tầng 1 (khách walk-in), Tầng 2 (VIP/phòng riêng), khu ngoài trời (chill / hút thuốc).
                                Dùng chuột để xoay / phóng to.
                            </div>

                            <div id="restaurant3dCanvas"></div>

                            <div class="floor-legend">
                                <span class="me-3">
                                    <span class="legend-dot" style="background:#22c55e;"></span>
                                    Tầng 1
                                </span>
                                <span class="me-3">
                                    <span class="legend-dot" style="background:#3b82f6;"></span>
                                    Tầng 2
                                </span>
                                <span class="me-3">
                                    <span class="legend-dot" style="background:#facc15;"></span>
                                    Outdoor
                                </span>
                            </div>

                            <c:forEach var="a" items="${areaSummaries}">
                                <div class="area-summary">
                                    <strong>${a.name}:</strong>
                                    ${a.totalTables} bàn · ${a.totalSeats} ghế
                                    (<span style="color:#4ade80;">${a.freeTables} trống</span>)
                                    – ${a.description}
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Menu -->
        <section class="container-xxl py-5">
            <div class="container">
                <div class="text-center wow fadeInUp" data-wow-delay="0.1s">
                    <h5 class="section-title ff-secondary text-center text-primary fw-normal">Thực đơn</h5>
                    <h1 class="mb-3">Khám phá menu hôm nay</h1>
                    <p class="text-muted mb-4">
                        Kéo ngang để xem thêm món · chọn nhóm món để lọc nhanh.
                    </p>
                </div>

                <ul class="menu-category-pills" id="menuCategoryPills">
                    <li>
                        <button type="button" class="active" data-category-id="">
                            <i class="fa fa-utensils"></i>
                            Tất cả
                        </button>
                    </li>
                    <c:forEach var="cat" items="${menuCategories}">
                        <li>
                            <button type="button" data-category-id="${cat.categoryId}">
                                <i class="fa fa-utensils"></i>
                                Nhóm món ${cat.name}
                            </button>
                        </li>
                    </c:forEach>
                </ul>

                <div class="menu-scroller" id="menuScroller">
                    <c:forEach var="m" items="${menuItems}">
                        <c:url value="${empty m.imageUrl ? '/img/menu-1.jpg' : m.imageUrl}" var="menuImgUrl"/>
                        <div class="menu-card" data-category-id="${m.categoryId}">
                            <img src="${menuImgUrl}" alt="${m.name}"/>
                            <div class="flex-grow-1">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div class="menu-card-title">${m.name}</div>
                                    <div class="menu-card-price">
                                        <fmt:formatNumber value="${m.price}" type="number" groupingUsed="true"/>đ
                                    </div>
                                </div>
                                <div class="menu-card-desc">
                                    <c:out value="${m.description}"/>
                                </div>
                                <div class="text-muted mt-1" style="font-size:.75rem;">
                                    Nhóm món: ${m.categoryName}
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </section>

        <!-- Promotions + Best sellers – POS dashboard -->
        <section class="container-xxl py-5">
            <div class="container">
                <div class="pos-home-section-wrap">
                    <div class="row g-4 align-items-stretch">
                        <!-- Khuyến mãi -->
                        <div class="col-lg-6">
                            <div class="pos-panel">
                                <div class="pos-panel-header mb-3">
                                    <span class="pos-panel-kicker text-primary">Khuyến mãi</span>
                                    <h2 class="mb-1">Ưu đãi áp dụng hôm nay</h2>
                                    <p class="pos-panel-sub mb-0">
                                        Hệ thống tự áp dụng khi order đúng khung giờ &amp; món.
                                    </p>
                                </div>

                                <c:if test="${empty promotions}">
                                    <p class="text-muted mb-0">
                                        Hiện chưa có chương trình khuyến mãi nào trong ngày.
                                    </p>
                                </c:if>

                                <c:forEach var="p" items="${promotions}">
                                    <div class="promo-item">
                                        <div class="promo-badge">
                                            ${p.discountLabel}
                                        </div>
                                        <div class="promo-main">
                                            <h6 class="promo-title mb-1">${p.name}</h6>
                                            <div class="promo-meta">
                                                <i class="bi bi-clock me-1"></i>${p.timeRange}
                                                <c:if test="${not empty p.menuItemName}">
                                                    <span class="bullet">•</span> Món: ${p.menuItemName}
                                                </c:if>
                                            </div>
                                            <div class="promo-desc text-muted">
                                                ${p.description}
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>

                        <!-- Món bán chạy -->
                        <div class="col-lg-6">
                            <div class="pos-panel pos-panel-dark">
                                <div class="pos-panel-header mb-3">
                                    <span class="pos-panel-kicker text-warning">Đề xuất</span>
                                    <h2 class="mb-1 text-white">Món bán chạy</h2>
                                    <p class="pos-panel-sub text-gray-400 mb-0">
                                        Top món được gọi nhiều nhất trong ngày.
                                    </p>
                                </div>

                                <c:if test="${empty bestSellers}">
                                    <p class="text-muted mb-0">
                                        Chưa có dữ liệu món bán chạy.
                                    </p>
                                </c:if>

                                <div class="best-seller-strip">
                                    <c:forEach var="b" items="${bestSellers}">
                                        <div class="best-seller-item">
                                            <div class="best-seller-tag">${b.categoryName}</div>
                                            <h6>${b.name}</h6>
                                            <div class="small text-gray-300 mb-2">
                                                <c:out value="${b.description}"/>
                                            </div>
                                            <div class="best-seller-price">
                                                <fmt:formatNumber value="${b.price}" type="number" groupingUsed="true"/>đ
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Team -->
        <section class="container-xxl pt-5 pb-3">
            <div class="container">
                <div class="text-center wow fadeInUp" data-wow-delay="0.1s">
                    <h5 class="section-title ff-secondary text-center text-primary fw-normal">Đội ngũ</h5>
                    <h1 class="mb-5">Nhân viên &amp; đầu bếp</h1>
                </div>

                <c:if test="${empty staffCards}">
                    <p class="text-center text-muted">Chưa có dữ liệu nhân viên.</p>
                </c:if>

                <div class="team-grid">
                    <c:forEach var="s" items="${staffCards}">
                        <c:url value="${empty s.avatarUrl ? '/img/team-1.jpg' : s.avatarUrl}" var="staffAvatarUrl"/>
                        <div class="team-card">
                            <div class="team-avatar-wrap">
                                <img src="${staffAvatarUrl}" alt="${s.fullName}"/>
                            </div>
                            <div class="team-name">${s.fullName}</div>
                            <div class="team-role">${s.roleName}</div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <jsp:include page="/layouts/Footer.jsp"/>

        <!-- JS libs -->
        <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="<c:url value='/lib/wow/wow.min.js'/>"></script>
        <script src="<c:url value='/lib/easing/easing.min.js'/>"></script>
        <script src="<c:url value='/lib/waypoints/waypoints.min.js'/>"></script>
        <script src="<c:url value='/lib/counterup/counterup.min.js'/>"></script>
        <script src="<c:url value='/lib/owlcarousel/owl.carousel.min.js'/>"></script>
        <script src="<c:url value='/lib/tempusdominus/js/moment.min.js'/>"></script>
        <script src="<c:url value='/lib/tempusdominus/js/moment-timezone.min.js'/>"></script>
        <script src="<c:url value='/lib/tempusdominus/js/tempusdominus-bootstrap-4.min.js'/>"></script>
        <script src="<c:url value='/js/main.js'/>"></script>

        <!-- Navbar overlay -->
        <script>
            (function () {
                const nav = document.getElementById('mainNav');
                if (!nav)
                    return;
                const isOverlay = nav.dataset.overlay === 'true';
                if (!isOverlay)
                    return;

                function toTransparent() {
                    nav.classList.add('position-absolute', 'top-0', 'start-0', 'w-100', 'bg-transparent');
                    nav.classList.remove('bg-dark', 'sticky-top', 'shadow');
                }
                function toSolid() {
                    nav.classList.remove('position-absolute', 'bg-transparent');
                    nav.classList.add('bg-dark', 'sticky-top', 'shadow');
                }
                function onScroll() {
                    if (window.scrollY > 80)
                        toSolid();
                    else
                        toTransparent();
                }
                onScroll();
                window.addEventListener('scroll', onScroll);
            })();
        </script>

        <!-- Menu filter + auto scroll -->
        <script>
            (function () {
                const pills = document.querySelectorAll('#menuCategoryPills button');
                const cards = document.querySelectorAll('.menu-card');
                const scroller = document.getElementById('menuScroller');

                pills.forEach(btn => {
                    btn.addEventListener('click', () => {
                        const id = btn.getAttribute('data-category-id') || '';
                        pills.forEach(b => b.classList.remove('active'));
                        btn.classList.add('active');

                        cards.forEach(card => {
                            const cid = card.getAttribute('data-category-id') || '';
                            card.style.display = (!id || id === cid) ? 'flex' : 'none';
                        });

                        if (scroller) {
                            scroller.scrollTo({left: 0, behavior: 'smooth'});
                        }
                    });
                });

                // auto-scroll nhẹ
                if (scroller) {
                    let dir = 1;
                    setInterval(() => {
                        if (scroller.scrollWidth <= scroller.clientWidth)
                            return;
                        let next = scroller.scrollLeft + dir * 260;
                        if (next + scroller.clientWidth >= scroller.scrollWidth || next <= 0) {
                            dir *= -1;
                            next = Math.max(0, Math.min(scroller.scrollWidth, scroller.scrollLeft + dir * 260));
                        }
                        scroller.scrollTo({left: next, behavior: 'smooth'});
                    }, 5000);
                }
            })();
        </script>

        <!-- 3D floor plan – tòa nhà 2 tầng + outdoor + cổng + cây + RMSG4 -->
        <script>
            (function () {
                const container = document.getElementById('restaurant3dCanvas');
                if (!container || !window.THREE) {
                    if (container) {
                        container.innerHTML =
                                '<div style="padding:16px;color:#9ca3af;font-size:.85rem">' +
                                'Không tải được thư viện 3D (Three.js). Vui lòng kiểm tra kết nối mạng.' +
                                '</div>';
                    }
                    return;
                }

                container.innerHTML = '';

                // Build data từ areaSummaries
                const rawAreas = [
            <c:forEach var="a" items="${areaSummaries}" varStatus="st">
                {
                name: "<c:out value='${a.name}'/>",
                        totalTables: ${a.totalTables}
                }<c:if test="${!st.last}">,</c:if>
            </c:forEach>
                ];

                const scene = new THREE.Scene();
                scene.background = new THREE.Color(0x020617);

                const camera = new THREE.PerspectiveCamera(
                        45,
                        container.clientWidth / container.clientHeight,
                        0.1,
                        100
                        );
                camera.position.set(11, 9, 13);
                camera.lookAt(0, 1, 0);

                const renderer = new THREE.WebGLRenderer({antialias: true});
                renderer.setPixelRatio(window.devicePixelRatio || 1);
                renderer.setSize(container.clientWidth, container.clientHeight);
                container.appendChild(renderer.domElement);

                let controls = null;
                if (typeof THREE.OrbitControls !== "undefined") {
                    controls = new THREE.OrbitControls(camera, renderer.domElement);
                    controls.enableDamping = true;
                    controls.dampingFactor = 0.06;
                    controls.maxPolarAngle = Math.PI / 2.05;
                    controls.minDistance = 8;
                    controls.maxDistance = 20;
                    controls.target.set(0, 1.0, 0);
                }

                // Ánh sáng + grid
                const hemiLight = new THREE.HemisphereLight(0xffffff, 0x111827, 0.95);
                hemiLight.position.set(0, 10, 0);
                scene.add(hemiLight);

                const dirLight = new THREE.DirectionalLight(0xffffff, 0.8);
                dirLight.position.set(8, 12, 6);
                scene.add(dirLight);

                const grid = new THREE.GridHelper(20, 20, 0x1f2937, 0x0f172a);
                grid.position.y = 0.01;
                scene.add(grid);

                const FLOOR_THICKNESS = 0.3;
                const indoorFloors = [];
                let outdoorFloor = null;

                function getConfigForArea(raw, index) {
                    const name = raw.name || "";
                    let cfg;

                    if (name.indexOf("Tầng 1") >= 0 || index === 0) {
                        cfg = {
                            x: 0,
                            z: 0,
                            y: 0.25,
                            w: 6,
                            d: 4,
                            color: 0x16a34a,
                            kind: "indoor"
                        };
                    } else if (name.indexOf("Tầng 2") >= 0 || index === 1) {
                        cfg = {
                            x: 0.15,
                            z: -0.25,
                            y: 1.6,
                            w: 5.6,
                            d: 3.6,
                            color: 0x3b82f6,
                            kind: "indoor"
                        };
                    } else {
                        cfg = {
                            x: 7.5,
                            z: 0.5,
                            y: 0.25,
                            w: 4.5,
                            d: 3.8,
                            color: 0xfacc15,
                            kind: "outdoor"
                        };
                    }
                    cfg.name = name || ("Khu " + (index + 1));
                    cfg.tableCount = Math.max(1, raw.totalTables || 1);
                    return cfg;
                }

                function createTablesOnFloor(cfg) {
                    const count = cfg.tableCount;
                    const cols = Math.ceil(Math.sqrt(count));
                    const rows = Math.ceil(count / cols);

                    const usableW = cfg.w * 0.7;
                    const usableD = cfg.d * 0.7;

                    const tableGeo = new THREE.CylinderGeometry(0.28, 0.28, 0.22, 18);
                    const chairGeo = new THREE.CylinderGeometry(0.1, 0.1, 0.2, 12);

                    const tableMat = new THREE.MeshStandardMaterial({
                        color: 0xffa32a,
                        emissive: 0xffa32a,
                        emissiveIntensity: 0.35,
                        roughness: 0.3,
                        metalness: 0.25
                    });
                    const chairMat = new THREE.MeshStandardMaterial({
                        color: 0xf9fafb,
                        roughness: 0.6,
                        metalness: 0.1
                    });

                    const floorTopY = cfg.y + FLOOR_THICKNESS / 2;
                    const tableY = floorTopY + 0.18;

                    for (let i = 0; i < count; i++) {
                        const r = Math.floor(i / cols);
                        const c = i % cols;

                        const ratioX = (c + 0.5) / cols - 0.5;
                        const ratioZ = (r + 0.5) / rows - 0.5;

                        const worldX = cfg.x + ratioX * usableW;
                        const worldZ = cfg.z + ratioZ * usableD;

                        const table = new THREE.Mesh(tableGeo, tableMat);
                        table.position.set(worldX, tableY, worldZ);
                        scene.add(table);

                        const offsets = [
                            {dx: 0.45, dz: 0},
                            {dx: -0.45, dz: 0},
                            {dx: 0, dz: 0.45},
                            {dx: 0, dz: -0.45}
                        ];
                        offsets.forEach(o => {
                            const chair = new THREE.Mesh(chairGeo, chairMat);
                            chair.position.set(worldX + o.dx, tableY - 0.05, worldZ + o.dz);
                            scene.add(chair);
                        });
                    }
                }

                function createFloor(cfg) {
                    const floorGeo = new THREE.BoxGeometry(cfg.w, FLOOR_THICKNESS, cfg.d);
                    const floorMat = new THREE.MeshStandardMaterial({
                        color: cfg.color,
                        roughness: 0.4,
                        metalness: 0.15
                    });
                    const floor = new THREE.Mesh(floorGeo, floorMat);
                    floor.position.set(cfg.x, cfg.y, cfg.z);
                    scene.add(floor);

                    const edges = new THREE.EdgesGeometry(floorGeo);
                    const lineMat = new THREE.LineBasicMaterial({color: 0xf9fafb});
                    const line = new THREE.LineSegments(edges, lineMat);
                    line.position.copy(floor.position);
                    scene.add(line);

                    const labelCanvas = document.createElement('canvas');
                    labelCanvas.width = 256;
                    labelCanvas.height = 64;
                    const ctx = labelCanvas.getContext('2d');
                    ctx.fillStyle = 'rgba(15,23,42,0.96)';
                    ctx.fillRect(0, 0, labelCanvas.width, labelCanvas.height);
                    ctx.font = '24px sans-serif';
                    ctx.fillStyle = '#fbbf24';
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    ctx.fillText(cfg.name, labelCanvas.width / 2, labelCanvas.height / 2);

                    const tex = new THREE.CanvasTexture(labelCanvas);
                    const spriteMat = new THREE.SpriteMaterial({map: tex, depthTest: false});
                    const sprite = new THREE.Sprite(spriteMat);
                    sprite.scale.set(3.2, 0.9, 1);
                    sprite.position.set(cfg.x, cfg.y + 0.8 + (cfg.kind === "indoor" ? 0.4 : 0), cfg.z);
                    scene.add(sprite);

                    createTablesOnFloor(cfg);

                    if (cfg.kind === "indoor") {
                        indoorFloors.push(cfg);
                    } else {
                        outdoorFloor = cfg;
                    }
                }

                function createBuildingShell(floors) {
                    if (!floors.length)
                        return;

                    let minX = Infinity, maxX = -Infinity;
                    let minZ = Infinity, maxZ = -Infinity;
                    let minY = Infinity, maxY = -Infinity;

                    floors.forEach(f => {
                        const halfW = f.w / 2;
                        const halfD = f.d / 2;
                        minX = Math.min(minX, f.x - halfW);
                        maxX = Math.max(maxX, f.x + halfW);
                        minZ = Math.min(minZ, f.z - halfD);
                        maxZ = Math.max(maxZ, f.z + halfD);
                        minY = Math.min(minY, f.y - FLOOR_THICKNESS / 2);
                        maxY = Math.max(maxY, f.y + FLOOR_THICKNESS / 2);
                    });

                    const wallHeight = (maxY - minY) + 1.6;
                    const wallThickness = 0.18;
                    const centerY = minY + wallHeight / 2;

                    const buildingCenterX = (minX + maxX) / 2;
                    const buildingCenterZ = (minZ + maxZ) / 2;
                    const buildingW = (maxX - minX);
                    const buildingD = (maxZ - minZ);

                    const wallMat = new THREE.MeshStandardMaterial({
                        color: 0x0f172a,
                        roughness: 0.2,
                        metalness: 0.5,
                        transparent: true,
                        opacity: 0.35
                    });

                    // Không vẽ tường phía trước để nhìn rõ nội thất
                    const wallBackGeo = new THREE.BoxGeometry(buildingW + 0.2, wallHeight, wallThickness);
                    const wallSideGeo = new THREE.BoxGeometry(wallThickness, wallHeight, buildingD + 0.2);

                    const wallBack = new THREE.Mesh(wallBackGeo, wallMat);
                    wallBack.position.set(buildingCenterX, centerY, minZ - wallThickness / 2 - 0.05);
                    scene.add(wallBack);

                    const wallLeft = new THREE.Mesh(wallSideGeo, wallMat);
                    wallLeft.position.set(minX - wallThickness / 2 - 0.05, centerY, buildingCenterZ);
                    scene.add(wallLeft);

                    const wallRight = new THREE.Mesh(wallSideGeo, wallMat);
                    wallRight.position.set(maxX + wallThickness / 2 + 0.05, centerY, buildingCenterZ);
                    scene.add(wallRight);

                    const roofGeo = new THREE.BoxGeometry(buildingW + 0.4, 0.22, buildingD + 0.4);
                    const roofMat = new THREE.MeshStandardMaterial({
                        color: 0x1f2937,
                        roughness: 0.2,
                        metalness: 0.4,
                        transparent: true,
                        opacity: 0.25
                    });
                    const roof = new THREE.Mesh(roofGeo, roofMat);
                    roof.position.set(buildingCenterX, maxY + 0.5, buildingCenterZ);
                    scene.add(roof);

                    const roofEdges = new THREE.EdgesGeometry(roofGeo);
                    const roofLineMat = new THREE.LineBasicMaterial({color: 0xfbbf24});
                    const roofLines = new THREE.LineSegments(roofEdges, roofLineMat);
                    roofLines.position.copy(roof.position);
                    scene.add(roofLines);
                }

                function createTree(x, z, scale) {
                    const trunkGeo = new THREE.CylinderGeometry(0.08 * scale, 0.12 * scale, 0.8 * scale, 8);
                    const trunkMat = new THREE.MeshStandardMaterial({color: 0x78350f});
                    const trunk = new THREE.Mesh(trunkGeo, trunkMat);
                    trunk.position.set(x, 0.4 * scale, z);
                    scene.add(trunk);

                    const crownGeo = new THREE.SphereGeometry(0.4 * scale, 16, 16);
                    const crownMat = new THREE.MeshStandardMaterial({color: 0x22c55e});
                    const crown = new THREE.Mesh(crownGeo, crownMat);
                    crown.position.set(x, 0.9 * scale, z);
                    scene.add(crown);
                }

                function decorateOutdoor(cfg) {
                    if (!cfg)
                        return;

                    const halfW = cfg.w / 2;
                    const halfD = cfg.d / 2;
                    const fenceHeight = 0.4;
                    const postGeo = new THREE.BoxGeometry(0.08, fenceHeight, 0.08);
                    const postMat = new THREE.MeshStandardMaterial({color: 0x0f172a});

                    const fenceY = cfg.y + FLOOR_THICKNESS / 2 + fenceHeight / 2;
                    const step = 0.7;

                    for (let x = -halfW + 0.2; x <= halfW - 0.2; x += step) {
                        [-halfD + 0.2, halfD - 0.2].forEach(zLocal => {
                            const post = new THREE.Mesh(postGeo, postMat);
                            post.position.set(cfg.x + x, fenceY, cfg.z + zLocal);
                            scene.add(post);
                        });
                    }
                    for (let z = -halfD + 0.2; z <= halfD - 0.2; z += step) {
                        [-halfW + 0.2, halfW - 0.2].forEach(xLocal => {
                            const post = new THREE.Mesh(postGeo, postMat);
                            post.position.set(cfg.x + xLocal, fenceY, cfg.z + z);
                            scene.add(post);
                        });
                    }

                    createTree(cfg.x + halfW + 0.8, cfg.z + halfD + 0.3, 1);
                    createTree(cfg.x + halfW + 1.4, cfg.z - halfD - 0.3, 0.9);
                    createTree(cfg.x - halfW - 0.8, cfg.z + halfD + 0.2, 0.8);
                }

                function createEntranceGate() {
                    const gateZ = 5.0;
                    const gateWidth = 4.5;
                    const gateHeight = 2.2;

                    const pillarGeo = new THREE.BoxGeometry(0.28, gateHeight, 0.28);
                    const pillarMat = new THREE.MeshStandardMaterial({color: 0x0f172a});

                    const leftPillar = new THREE.Mesh(pillarGeo, pillarMat);
                    leftPillar.position.set(-gateWidth / 2, gateHeight / 2, gateZ);
                    scene.add(leftPillar);

                    const rightPillar = new THREE.Mesh(pillarGeo, pillarMat);
                    rightPillar.position.set(gateWidth / 2, gateHeight / 2, gateZ);
                    scene.add(rightPillar);

                    const beamGeo = new THREE.BoxGeometry(gateWidth + 0.6, 0.3, 0.4);
                    const beamMat = new THREE.MeshStandardMaterial({color: 0x111827});
                    const beam = new THREE.Mesh(beamGeo, beamMat);
                    beam.position.set(0, gateHeight + 0.1, gateZ);
                    scene.add(beam);

                    const canvas = document.createElement('canvas');
                    canvas.width = 512;
                    canvas.height = 160;
                    const ctx = canvas.getContext('2d');
                    const grad = ctx.createLinearGradient(0, 0, canvas.width, canvas.height);
                    grad.addColorStop(0, '#f97316');
                    grad.addColorStop(1, '#facc15');
                    ctx.fillStyle = grad;
                    ctx.fillRect(0, 0, canvas.width, canvas.height);

                    ctx.font = 'bold 70px sans-serif';
                    ctx.fillStyle = '#111827';
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    ctx.fillText('RMSG4', canvas.width / 2, canvas.height / 2);

                    const tex = new THREE.CanvasTexture(canvas);
                    const signGeo = new THREE.PlaneGeometry(3.8, 1.2);
                    const signMat = new THREE.MeshBasicMaterial({map: tex, transparent: true});
                    const sign = new THREE.Mesh(signGeo, signMat);
                    sign.position.set(0, gateHeight + 0.2, gateZ + 0.25);
                    scene.add(sign);
                }

                function createBillboard() {
                    const canvas = document.createElement('canvas');
                    canvas.width = 1024;
                    canvas.height = 512;
                    const ctx = canvas.getContext('2d');

                    const grad = ctx.createLinearGradient(0, 0, canvas.width, canvas.height);
                    grad.addColorStop(0, '#0f172a');
                    grad.addColorStop(0.4, '#111827');
                    grad.addColorStop(1, '#020617');
                    ctx.fillStyle = grad;
                    ctx.fillRect(0, 0, canvas.width, canvas.height);

                    ctx.fillStyle = '#f97316';
                    ctx.font = 'bold 120px sans-serif';
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    ctx.fillText('RMSG4 RESTAURANT', canvas.width / 2, canvas.height / 2 - 40);

                    ctx.fillStyle = '#e5e7eb';
                    ctx.font = '36px sans-serif';
                    ctx.fillText('POS · Booking · VNPay · Voucher', canvas.width / 2, canvas.height / 2 + 50);

                    const tex = new THREE.CanvasTexture(canvas);
                    const geo = new THREE.PlaneGeometry(12, 6);
                    const mat = new THREE.MeshBasicMaterial({map: tex, side: THREE.DoubleSide});
                    const board = new THREE.Mesh(geo, mat);
                    board.position.set(-10, 4, -2);
                    board.rotation.y = Math.PI / 3;
                    scene.add(board);
                }

                function createSurroundingTrees() {
                    createTree(-5.5, 3.5, 1.1);
                    createTree(-6.0, -2.5, 0.9);
                    createTree(5.0, 4.0, 1.0);
                    createTree(4.2, -3.8, 0.85);
                }

                if (!rawAreas.length) {
                    rawAreas.push({name: "Tầng 1", totalTables: 4});
                    rawAreas.push({name: "Tầng 2", totalTables: 3});
                    rawAreas.push({name: "Khu vực ngoài trời", totalTables: 3});
                }

                rawAreas.forEach((raw, idx) => {
                    const cfg = getConfigForArea(raw, idx);
                    createFloor(cfg);
                });

                createBuildingShell(indoorFloors);
                decorateOutdoor(outdoorFloor);
                createEntranceGate();
                createBillboard();
                createSurroundingTrees();

                window.addEventListener('resize', () => {
                    const w = container.clientWidth;
                    const h = container.clientHeight;
                    camera.aspect = w / h;
                    camera.updateProjectionMatrix();
                    renderer.setSize(w, h);
                });

                let autoRotate = 0;
                function animate() {
                    requestAnimationFrame(animate);
                    autoRotate += 0.0012;
                    scene.rotation.y = autoRotate;
                    if (controls)
                        controls.update();
                    renderer.render(scene, camera);
                }

                animate();
            })();
        </script>

    </body>
</html>
