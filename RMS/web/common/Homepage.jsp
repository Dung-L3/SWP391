<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- đánh dấu menu active cho Header.jsp --%>
<c:set var="page" value="home" scope="request"/>
<%-- bật overlay cho navbar (nằm đè lên hero) --%>
<c:set var="overlayNav" value="true" scope="request"/>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Trang chủ | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="RMSG4 – Nhà hàng phục vụ món ăn ngon và dịch vụ tuyệt vời">

    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet">

    <!-- Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Vendor CSS -->
    <link href="<c:url value='/lib/animate/animate.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/lib/owlcarousel/assets/owl.carousel.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/lib/tempusdominus/css/tempusdominus-bootstrap-4.min.css'/>" rel="stylesheet">

    <!-- Bootstrap -->
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">

    <!-- Theme CSS -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">
</head>
<body>

<!-- Header -->
<jsp:include page="/layouts/Header.jsp"/>

<!-- Hero -->
<section class="container-xxl py-5 bg-dark hero-header mb-5">
    <div class="container my-5 py-5">
        <div class="row align-items-center g-5">
            <div class="col-lg-6 text-center text-lg-start">
                <h1 class="display-3 text-white animated slideInLeft">Thưởng thức<br>Món ăn ngon</h1>
                <p class="text-white animated slideInLeft mb-4 pb-2">
                    Chào mừng đến với RMSG4 - Nơi hội tụ tinh hoa ẩm thực Việt Nam. 
                    Chúng tôi mang đến cho bạn những món ăn được chế biến từ nguyên liệu tươi ngon nhất.
                </p>
                <a href="<c:url value='/views/guest/booking.jsp'/>"
                   class="btn btn-primary py-sm-3 px-sm-5 me-3 animated slideInLeft">Đặt bàn ngay</a>
            </div>
            <div class="col-lg-6 text-center text-lg-end overflow-hidden">
                <img class="img-fluid" src="<c:url value='/img/hero.png'/>" alt="Hero">
            </div>
        </div>
    </div>
</section>

<!-- Services -->
<section class="container-xxl py-5">
    <div class="container">
        <div class="row g-4">
            <div class="col-lg-3 col-sm-6 wow fadeInUp" data-wow-delay="0.1s">
                <div class="service-item rounded pt-3">
                    <div class="p-4">
                        <i class="fa fa-3x fa-user-tie text-primary mb-4"></i>
                        <h5>Đầu bếp chuyên nghiệp</h5>
                        <p>Đội ngũ đầu bếp giàu kinh nghiệm, tận tâm với nghề</p>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-sm-6 wow fadeInUp" data-wow-delay="0.3s">
                <div class="service-item rounded pt-3">
                    <div class="p-4">
                        <i class="fa fa-3x fa-utensils text-primary mb-4"></i>
                        <h5>Chất lượng hàng đầu</h5>
                        <p>Món ăn được chế biến từ nguyên liệu tươi ngon</p>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-sm-6 wow fadeInUp" data-wow-delay="0.5s">
                <div class="service-item rounded pt-3">
                    <div class="p-4">
                        <i class="fa fa-3x fa-cart-plus text-primary mb-4"></i>
                        <h5>Đặt món trực tuyến</h5>
                        <p>Dễ dàng đặt món và thanh toán online</p>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-sm-6 wow fadeInUp" data-wow-delay="0.7s">
                <div class="service-item rounded pt-3">
                    <div class="p-4">
                        <i class="fa fa-3x fa-headset text-primary mb-4"></i>
                        <h5>Phục vụ 24/7</h5>
                        <p>Luôn sẵn sàng phục vụ bạn mọi lúc mọi nơi</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- About -->
<section class="container-xxl py-5">
    <div class="container">
        <div class="row g-5 align-items-center">
            <div class="col-lg-6">
                <div class="row g-3">
                    <div class="col-6 text-start">
                        <img class="img-fluid rounded w-100 wow zoomIn" data-wow-delay="0.1s"
                             src="<c:url value='/img/about-1.jpg'/>" alt="About 1">
                    </div>
                    <div class="col-6 text-start">
                        <img class="img-fluid rounded w-75 wow zoomIn" data-wow-delay="0.3s"
                             src="<c:url value='/img/about-2.jpg'/>" style="margin-top:25%;" alt="About 2">
                    </div>
                    <div class="col-6 text-end">
                        <img class="img-fluid rounded w-75 wow zoomIn" data-wow-delay="0.5s"
                             src="<c:url value='/img/about-3.jpg'/>" alt="About 3">
                    </div>
                    <div class="col-6 text-end">
                        <img class="img-fluid rounded w-100 wow zoomIn" data-wow-delay="0.7s"
                             src="<c:url value='/img/about-4.jpg'/>" alt="About 4">
                    </div>
                </div>
            </div>
            <div class="col-lg-6">
                <h5 class="section-title ff-secondary text-start text-primary fw-normal">Giới thiệu</h5>
                <h1 class="mb-4">Chào mừng đến <i class="fa fa-utensils text-primary me-2"></i>RMSG4</h1>
                <p class="mb-4">RMSG4 là nhà hàng chuyên phục vụ các món ăn Việt Nam truyền thống và hiện đại. Chúng tôi cam kết mang đến cho khách hàng những trải nghiệm ẩm thực tuyệt vời nhất.</p>
                <p class="mb-4">Với đội ngũ đầu bếp giàu kinh nghiệm và nguyên liệu tươi ngon được chọn lọc kỹ càng, mỗi món ăn tại RMSG4 đều được chế biến với tâm huyết và sự tận tâm cao nhất.</p>
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
                                <p class="mb-0">Đầu bếp</p>
                                <h6 class="text-uppercase mb-0">Chuyên nghiệp</h6>
                            </div>
                        </div>
                    </div>
                </div>
                <a class="btn btn-primary py-3 px-5 mt-2" href="#">Xem thêm</a>
            </div>
        </div>
    </div>
</section>

<!-- Menu -->
<section class="container-xxl py-5">
    <div class="container">
        <div class="text-center wow fadeInUp" data-wow-delay="0.1s">
            <h5 class="section-title ff-secondary text-center text-primary fw-normal">Thực đơn</h5>
            <h1 class="mb-5">Món ăn phổ biến</h1>
        </div>

        <div class="tab-class text-center wow fadeInUp" data-wow-delay="0.1s">
            <ul class="nav nav-pills d-inline-flex justify-content-center border-bottom mb-5">
                <li class="nav-item">
                    <a class="d-flex align-items-center text-start mx-3 ms-0 pb-3 active" data-bs-toggle="pill" href="#tab-1">
                        <i class="fa fa-coffee fa-2x text-primary"></i>
                        <div class="ps-3">
                            <small class="text-body">Phổ biến</small>
                            <h6 class="mt-n1 mb-0">Bữa sáng</h6>
                        </div>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="d-flex align-items-center text-start mx-3 pb-3" data-bs-toggle="pill" href="#tab-2">
                        <i class="fa fa-hamburger fa-2x text-primary"></i>
                        <div class="ps-3">
                            <small class="text-body">Đặc biệt</small>
                            <h6 class="mt-n1 mb-0">Bữa trưa</h6>
                        </div>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="d-flex align-items-center text-start mx-3 me-0 pb-3" data-bs-toggle="pill" href="#tab-3">
                        <i class="fa fa-utensils fa-2x text-primary"></i>
                        <div class="ps-3">
                            <small class="text-body">Hấp dẫn</small>
                            <h6 class="mt-n1 mb-0">Bữa tối</h6>
                        </div>
                    </a>
                </li>
            </ul>

            <div class="tab-content">
                <!-- Tab 1 -->
                <div id="tab-1" class="tab-pane fade show p-0 active">
                    <div class="row g-4">
                        <c:forEach var="i" begin="1" end="8">
                            <div class="col-lg-6">
                                <div class="d-flex align-items-center">
                                    <img class="flex-shrink-0 img-fluid rounded" src="<c:url value='/img/menu-${i}.jpg'/>" alt="Menu ${i}" style="width:80px;">
                                    <div class="w-100 d-flex flex-column text-start ps-4">
                                        <h5 class="d-flex justify-content-between border-bottom pb-2">
                                            <span>Chicken Burger</span>
                                            <span class="text-primary">$115</span>
                                        </h5>
                                        <small class="fst-italic">Ipsum ipsum clita erat amet dolor justo diam</small>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Tab 2 -->
                <div id="tab-2" class="tab-pane fade show p-0">
                    <div class="row g-4">
                        <c:forEach var="i" begin="1" end="8">
                            <div class="col-lg-6">
                                <div class="d-flex align-items-center">
                                    <img class="flex-shrink-0 img-fluid rounded" src="<c:url value='/img/menu-${i}.jpg'/>" alt="Menu ${i}" style="width:80px;">
                                    <div class="w-100 d-flex flex-column text-start ps-4">
                                        <h5 class="d-flex justify-content-between border-bottom pb-2">
                                            <span>Chicken Burger</span>
                                            <span class="text-primary">$115</span>
                                        </h5>
                                        <small class="fst-italic">Ipsum ipsum clita erat amet dolor justo diam</small>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Tab 3 -->
                <div id="tab-3" class="tab-pane fade show p-0">
                    <div class="row g-4">
                        <c:forEach var="i" begin="1" end="8">
                            <div class="col-lg-6">
                                <div class="d-flex align-items-center">
                                    <img class="flex-shrink-0 img-fluid rounded" src="<c:url value='/img/menu-${i}.jpg'/>" alt="Menu ${i}" style="width:80px;">
                                    <div class="w-100 d-flex flex-column text-start ps-4">
                                        <h5 class="d-flex justify-content-between border-bottom pb-2">
                                            <span>Chicken Burger</span>
                                            <span class="text-primary">$115</span>
                                        </h5>
                                        <small class="fst-italic">Ipsum ipsum clita erat amet dolor justo diam</small>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Reservation -->
<section class="container-xxl py-5 px-0 wow fadeInUp" data-wow-delay="0.1s">
    <div class="row g-0">
        <div class="col-md-6">
            <div class="video">
                <button type="button" class="btn-play" data-bs-toggle="modal"
                        data-src="https://www.youtube.com/embed/DWRcNpR6Kdc" data-bs-target="#videoModal">
                    <span></span>
                </button>
            </div>
        </div>
        <div class="col-md-6 bg-dark d-flex align-items-center">
            <div class="p-5 wow fadeInUp" data-wow-delay="0.2s">
                <h5 class="section-title ff-secondary text-start text-primary fw-normal">Đặt bàn</h5>
                <h1 class="text-white mb-4">Đặt bàn trực tuyến</h1>
                <form>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="text" class="form-control" id="name" placeholder="Họ và tên">
                                <label for="name">Họ và tên</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="email" class="form-control" id="email" placeholder="Email của bạn">
                                <label for="email">Email của bạn</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-floating date" id="date3" data-target-input="nearest">
                                <input type="text" class="form-control datetimepicker-input" id="datetime"
                                       placeholder="Ngày & Giờ" data-target="#date3" data-toggle="datetimepicker">
                                <label for="datetime">Ngày & Giờ</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-floating">
                                <select class="form-select" id="select1">
                                    <option value="1">1 người</option>
                                    <option value="2">2 người</option>
                                    <option value="3">3 người</option>
                                    <option value="4">4 người</option>
                                    <option value="5">5 người</option>
                                    <option value="6">6+ người</option>
                                </select>
                                <label for="select1">Số người</label>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="form-floating">
                                <textarea class="form-control" placeholder="Yêu cầu đặc biệt" id="message" style="height:100px"></textarea>
                                <label for="message">Yêu cầu đặc biệt</label>
                            </div>
                        </div>
                        <div class="col-12">
                            <button class="btn btn-primary w-100 py-3" type="submit">Đặt bàn ngay</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<!-- Video Modal -->
<div class="modal fade" id="videoModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content rounded-0">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">Video giới thiệu</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="ratio ratio-16x9">
                    <iframe class="embed-responsive-item" src="" id="video" allowfullscreen allowscriptaccess="always" allow="autoplay"></iframe>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Team -->
<section class="container-xxl pt-5 pb-3">
    <div class="container">
        <div class="text-center wow fadeInUp" data-wow-delay="0.1s">
            <h5 class="section-title ff-secondary text-center text-primary fw-normal">Đội ngũ</h5>
            <h1 class="mb-5">Đầu bếp chuyên nghiệp</h1>
        </div>
        <div class="row g-4">
            <div class="col-lg-3 col-md-6 wow fadeInUp" data-wow-delay="0.1s">
                <div class="team-item text-center rounded overflow-hidden">
                    <div class="rounded-circle overflow-hidden m-4">
                        <img class="img-fluid" src="<c:url value='/img/team-1.jpg'/>" alt="Trần Minh Tuấn">
                    </div>
                    <h5 class="mb-0">Trần Minh Tuấn</h5>
                    <small>Bếp trưởng</small>
                    <div class="d-flex justify-content-center mt-3">
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-facebook-f"></i></a>
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-twitter"></i></a>
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-instagram"></i></a>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 wow fadeInUp" data-wow-delay="0.3s">
                <div class="team-item text-center rounded overflow-hidden">
                    <div class="rounded-circle overflow-hidden m-4">
                        <img class="img-fluid" src="<c:url value='/img/team-2.jpg'/>" alt="Nguyễn Thị Lan">
                    </div>
                    <h5 class="mb-0">Nguyễn Thị Lan</h5>
                    <small>Phó bếp trưởng</small>
                    <div class="d-flex justify-content-center mt-3">
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-facebook-f"></i></a>
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-twitter"></i></a>
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-instagram"></i></a>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 wow fadeInUp" data-wow-delay="0.5s">
                <div class="team-item text-center rounded overflow-hidden">
                    <div class="rounded-circle overflow-hidden m-4">
                        <img class="img-fluid" src="<c:url value='/img/team-3.jpg'/>" alt="Lê Văn Hùng">
                    </div>
                    <h5 class="mb-0">Lê Văn Hùng</h5>
                    <small>Đầu bếp chính</small>
                    <div class="d-flex justify-content-center mt-3">
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-facebook-f"></i></a>
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-twitter"></i></a>
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-instagram"></i></a>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 wow fadeInUp" data-wow-delay="0.7s">
                <div class="team-item text-center rounded overflow-hidden">
                    <div class="rounded-circle overflow-hidden m-4">
                        <img class="img-fluid" src="<c:url value='/img/team-4.jpg'/>" alt="Phạm Thị Mai">
                    </div>
                    <h5 class="mb-0">Phạm Thị Mai</h5>
                    <small>Đầu bếp bánh</small>
                    <div class="d-flex justify-content-center mt-3">
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-facebook-f"></i></a>
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-twitter"></i></a>
                        <a class="btn btn-square btn-primary mx-1" href="#"><i class="fab fa-instagram"></i></a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Testimonial -->
<section class="container-xxl py-5 wow fadeInUp" data-wow-delay="0.1s">
    <div class="container">
        <div class="text-center">
            <h5 class="section-title ff-secondary text-center text-primary fw-normal">Đánh giá</h5>
            <h1 class="mb-5">Khách hàng nói gì về chúng tôi</h1>
        </div>
        <div class="owl-carousel testimonial-carousel">
            <div class="testimonial-item bg-transparent border rounded p-4">
                <i class="fa fa-quote-left fa-2x text-primary mb-3"></i>
                <p>Món ăn rất ngon, phục vụ tận tình. Tôi và gia đình rất hài lòng với chất lượng dịch vụ tại đây.</p>
                <div class="d-flex align-items-center">
                    <img class="img-fluid flex-shrink-0 rounded-circle" src="<c:url value='/img/testimonial-1.jpg'/>" style="width:50px;height:50px;" alt="Nguyễn Văn An">
                    <div class="ps-3">
                        <h5 class="mb-1">Nguyễn Văn An</h5>
                        <small>Doanh nhân</small>
                    </div>
                </div>
            </div>
            <div class="testimonial-item bg-transparent border rounded p-4">
                <i class="fa fa-quote-left fa-2x text-primary mb-3"></i>
                <p>Không gian đẹp, món ăn đa dạng và ngon miệng. Nhất định sẽ quay lại lần sau.</p>
                <div class="d-flex align-items-center">
                    <img class="img-fluid flex-shrink-0 rounded-circle" src="<c:url value='/img/testimonial-2.jpg'/>" style="width:50px;height:50px;" alt="Trần Thị Bình">
                    <div class="ps-3">
                        <h5 class="mb-1">Trần Thị Bình</h5>
                        <small>Giáo viên</small>
                    </div>
                </div>
            </div>
            <div class="testimonial-item bg-transparent border rounded p-4">
                <i class="fa fa-quote-left fa-2x text-primary mb-3"></i>
                <p>Đầu bếp rất chuyên nghiệp, món ăn được trình bày đẹp mắt. Giá cả hợp lý.</p>
                <div class="d-flex align-items-center">
                    <img class="img-fluid flex-shrink-0 rounded-circle" src="<c:url value='/img/testimonial-3.jpg'/>" style="width:50px;height:50px;" alt="Lê Hoàng Cường">
                    <div class="ps-3">
                        <h5 class="mb-1">Lê Hoàng Cường</h5>
                        <small>Kỹ sư</small>
                    </div>
                </div>
            </div>
            <div class="testimonial-item bg-transparent border rounded p-4">
                <i class="fa fa-quote-left fa-2x text-primary mb-3"></i>
                <p>Nhà hàng tuyệt vời! Thức ăn tươi ngon, phục vụ nhanh chóng và chu đáo.</p>
                <div class="d-flex align-items-center">
                    <img class="img-fluid flex-shrink-0 rounded-circle" src="<c:url value='/img/testimonial-4.jpg'/>" style="width:50px;height:50px;" alt="Phạm Thu Dung">
                    <div class="ps-3">
                        <h5 class="mb-1">Phạm Thu Dung</h5>
                        <small>Bác sĩ</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Footer -->
<jsp:include page="/layouts/Footer.jsp"/>

<!-- JS -->
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

<!-- Script chuyển navbar trong suốt -> sticky tối khi cuộn -->
<script>
(function () {
  const nav = document.getElementById('mainNav');
  if (!nav) return;
  const isOverlay = nav.dataset.overlay === 'true';
  if (!isOverlay) return;

  function toTransparent() {
    nav.classList.add('position-absolute','top-0','start-0','w-100','bg-transparent');
    nav.classList.remove('bg-dark','sticky-top','shadow');
  }
  function toSolid() {
    nav.classList.remove('position-absolute','bg-transparent');
    nav.classList.add('bg-dark','sticky-top','shadow');
  }
  function onScroll() {
    if (window.scrollY > 80) toSolid(); else toTransparent();
  }
  onScroll();
  window.addEventListener('scroll', onScroll);
})();
</script>
</body>
</html>