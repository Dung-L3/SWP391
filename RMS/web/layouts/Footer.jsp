<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Footer (markup only) -->
<footer class="container-fluid bg-dark text-light footer pt-5 mt-5">
    <div class="container py-5">
        <div class="row g-5">
            <div class="col-lg-3 col-md-6">
                <h4 class="section-title ff-secondary text-start text-primary fw-normal mb-4">Công ty</h4>
                <a class="btn btn-link" href="<c:url value='/about.jsp'/>">Giới thiệu</a>
                <a class="btn btn-link" href="<c:url value='/contact.jsp'/>">Liên hệ</a>
                <a class="btn btn-link" href="<c:url value='/booking.jsp'/>">Đặt bàn</a>
                <a class="btn btn-link" href="#">Chính sách</a>
                <a class="btn btn-link" href="#">Điều khoản</a>
            </div>

            <div class="col-lg-3 col-md-6">
                <h4 class="section-title ff-secondary text-start text-primary fw-normal mb-4">Liên hệ</h4>
                <p class="mb-2"><i class="fa fa-map-marker-alt me-3"></i>Trường Đại học FPT Hà Nội</p>
                <p class="mb-2"><i class="fa fa-phone-alt me-3"></i>+84 976 054 728</p>
                <p class="mb-2"><i class="fa fa-envelope me-3"></i>RMSG4@gmail.com</p>
                <div class="d-flex pt-2">
                    <a class="btn btn-outline-light btn-social" href="#"><i class="fab fa-twitter"></i></a>
                    <a class="btn btn-outline-light btn-social" href="#"><i class="fab fa-facebook-f"></i></a>
                    <a class="btn btn-outline-light btn-social" href="#"><i class="fab fa-youtube"></i></a>
                    <a class="btn btn-outline-light btn-social" href="#"><i class="fab fa-linkedin-in"></i></a>
                </div>
            </div>

            <div class="col-lg-3 col-md-6">
                <h4 class="section-title ff-secondary text-start text-primary fw-normal mb-4">Giờ mở cửa</h4>
                <h5 class="text-light fw-normal">Thứ 2 - Thứ 7</h5>
                <p>09:00 - 21:00</p>
                <h5 class="text-light fw-normal">Chủ nhật</h5>
                <p>10:00 - 20:00</p>
            </div>

            <div class="col-lg-3 col-md-6">
                <h4 class="section-title ff-secondary text-start text-primary fw-normal mb-4">Đăng ký nhận tin</h4>
                <p>Đăng ký để nhận thông tin khuyến mãi và tin tức mới nhất từ chúng tôi.</p>
                <div class="position-relative mx-auto" style="max-width: 400px;">
                    <input class="form-control border-primary w-100 py-3 ps-4 pe-5" type="text" placeholder="Email của bạn">
                    <button type="button" class="btn btn-primary py-2 position-absolute top-0 end-0 mt-2 me-2">Đăng ký</button>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <div class="copyright">
            <div class="row">
                <div class="col-md-6 text-center text-md-start mb-3 mb-md-0">
                    &copy; <a class="border-bottom" href="<c:url value='/'/>">RMSG4</a>, Bản quyền thuộc về chúng tôi.
                </div>
                <div class="col-md-6 text-center text-md-end">
                    <div class="footer-menu">
                        <a href="<c:url value='/'/>">Trang chủ</a>
                        <a href="#">Cookies</a>
                        <a href="#">Trợ giúp</a>
                        <a href="#">FAQ</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</footer>
