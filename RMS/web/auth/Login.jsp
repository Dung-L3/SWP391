<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("page", "login");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Login | Restoran</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSS -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="<c:url value='/lib/animate/animate.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/lib/owlcarousel/assets/owl.carousel.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/lib/tempusdominus/css/tempusdominus-bootstrap-4.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">

    <style>
        .auth-wrapper{ min-height: calc(100vh - 180px); display:flex; align-items:center; justify-content:center; background:#f6f7fb; }
        .auth-card{ max-width:480px; width:100%; border:0; border-radius:16px; box-shadow:0 12px 30px rgba(0,0,0,.08); background:#fff; }
        .auth-card .card-header{ border-bottom:0; background:#fff; }
        .form-control:focus{ box-shadow:none; border-color:#fea116; }
        .btn-auth{ background:#fea116; border-color:#fea116; }
        .btn-auth:hover{ filter:brightness(.95); }
        .input-group-text{ background:#fff; border-right:0; }
        .input-group .form-control{ border-left:0; }
        .small-muted{ color:#6c757d; font-size:.925rem; }
    </style>
</head>
<body>

    <jsp:include page="/layouts/Header.jsp"/>

    <div class="auth-wrapper py-5">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-12 col-md-10 col-lg-6">
                    <div class="card auth-card">
                        <div class="card-header text-center pt-4">
                            <h4 class="mb-1">Đăng nhập nhân viên</h4>
                            <p class="small-muted mb-0">Dành cho Manager, Receptionist, Waiter, Chef…</p>
                        </div>

                        <div class="card-body p-4 p-lg-5">
                            <!-- Thông báo lỗi (request hoặc session flash) -->
                            <c:if test="${not empty requestScope.loginError}">
                                <div class="alert alert-danger d-flex align-items-start">
                                    <i class="bi bi-exclamation-triangle me-2"></i>
                                    <div>${requestScope.loginError}</div>
                                </div>
                            </c:if>

                            <c:if test="${not empty sessionScope.loginError}">
                                <div class="alert alert-danger d-flex align-items-start">
                                    <i class="bi bi-exclamation-triangle me-2"></i>
                                    <div>${sessionScope.loginError}</div>
                                </div>
                                <c:remove var="loginError" scope="session"/>
                            </c:if>

                            <!-- Thông báo thành công (flash) -->
                            <c:if test="${not empty sessionScope.loginMsg}">
                                <div class="alert alert-success d-flex align-items-start">
                                    <i class="bi bi-check-circle me-2"></i>
                                    <div>${sessionScope.loginMsg}</div>
                                </div>
                                <c:remove var="loginMsg" scope="session"/>
                            </c:if>

                            <form method="post" action="<c:url value='/LoginServlet'/>" autocomplete="on">
                                <%
                                    // Tạo EL để lấy username: ưu tiên param rồi đến cookie
                                %>
                                <c:set var="usernamePrefill" value="${not empty param.username ? param.username : (cookie.username.value)}" />

                                <div class="mb-3">
                                    <label for="username" class="form-label">Tên đăng nhập / Email</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-person"></i></span>
                                        <input type="text" class="form-control" id="username" name="username"
                                               placeholder="username hoặc email" value="${usernamePrefill}" required>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="password" class="form-label">Mật khẩu</label>
                                    <div class="input-group" id="passwordGroup">
                                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                        <input type="password" class="form-control" id="password" name="password"
                                               placeholder="••••••••" required>
                                        <button class="btn btn-outline-secondary" type="button" id="togglePwd" title="Hiện/ẩn mật khẩu">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center mb-4">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" value="true" id="remember" name="remember"
                                               <c:if test="${param.remember eq 'true' || not empty cookie.username.value}">checked</c:if>>
                                        <label class="form-check-label" for="remember">Nhớ tôi</label>
                                    </div>
                                    <a class="text-decoration-none" href="<c:url value='/auth/forgot-password'/>">Quên mật khẩu?</a>
                                </div>

                                <button type="submit" class="btn btn-auth w-100 py-2">
                                    <i class="bi bi-box-arrow-in-right me-1"></i> Đăng nhập
                                </button>

                                <div class="text-center mt-3 small-muted">
                                    Bạn là khách? <a href="<c:url value='/'/>" class="text-decoration-none">Về trang chủ</a>
                                </div>
                            </form>
                        </div>
                    </div>

                    <c:if test="${not empty requestScope.demoAccounts}">
                        <div class="alert alert-light border mt-3">
                            <div class="fw-semibold mb-1">Tài khoản mẫu:</div>
                            <ul class="mb-0">
                                <c:forEach var="acc" items="${demoAccounts}">
                                    <li><code>${acc.username}</code> / <code>${acc.password}</code> (${acc.role})</li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>

                </div>
            </div>
        </div>
    </div>

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

    <script>
        
        (function () {
            const btn = document.getElementById('togglePwd');
            const input = document.getElementById('password');
            if (btn && input) {
                btn.addEventListener('click', function () {
                    const isPwd = input.type === 'password';
                    input.type = isPwd ? 'text' : 'password';
                    this.innerHTML = isPwd ? '<i class="bi bi-eye-slash"></i>' : '<i class="bi bi-eye"></i>';
                });
            }
        })();
    </script>
</body>
</html>
