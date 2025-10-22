<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("page", "login");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Đăng nhập | Restoran</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon">

    <!-- Google Fonts & Icons -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Vendor CSS -->
    <link href="<c:url value='/lib/animate/animate.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">

    <style>
        body {
            background: linear-gradient(135deg, #ffcf8c 0%, #fea116 50%, #ff8c00 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .auth-container {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 3rem 1rem;
        }
        .auth-card {
            max-width: 450px;
            width: 100%;
            background: #fff;
            border: 0;
            border-radius: 1.25rem;
            box-shadow: 0 12px 30px rgba(0,0,0,.15);
            animation: fadeInUp .6s ease;
        }
        .auth-header {
            text-align: center;
            padding: 2rem 1.5rem 1rem;
        }
        .auth-header h3 {
            font-weight: 700;
            margin-bottom: .25rem;
        }
        .auth-header p {
            color: #6c757d;
            font-size: .925rem;
        }
        .input-group-text {
            background: #fff;
            border-right: 0;
            font-size: 1.1rem;
        }
        .input-group .form-control {
            border-left: 0;
        }
        .form-control:focus {
            box-shadow: none;
            border-color: #fea116;
        }
        .btn-auth {
            background: #fea116;
            border-color: #fea116;
            font-weight: 600;
            transition: 0.2s;
        }
        .btn-auth:hover {
            filter: brightness(.95);
        }
        .forgot-link {
            font-size: 0.9rem;
        }
        .small-muted {
            color: #6c757d;
            font-size: .9rem;
        }
    </style>
</head>
<body>

<jsp:include page="/layouts/Header.jsp"/>

<div class="auth-container">
    <div class="card auth-card">
        <div class="auth-header">
            <i class="bi bi-person-circle text-primary display-4 mb-2"></i>
            <h3>Đăng nhập hệ thống</h3>
            <p>Dành cho Manager, Receptionist, Waiter, Chef…</p>
        </div>

        <div class="card-body p-4">

            <!-- Lỗi -->
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

            <!-- Thành công -->
            <c:if test="${not empty sessionScope.loginMsg}">
                <div class="alert alert-success d-flex align-items-start">
                    <i class="bi bi-check-circle me-2"></i>
                    <div>${sessionScope.loginMsg}</div>
                </div>
                <c:remove var="loginMsg" scope="session"/>
            </c:if>

            <form method="post" action="<c:url value='/LoginServlet'/>" autocomplete="on">
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
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                        <input type="password" class="form-control" id="password" name="password" placeholder="••••••••" required>
                        <button type="button" class="btn btn-outline-secondary" id="togglePwd" title="Hiện/ẩn mật khẩu">
                            <i class="bi bi-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" value="true" id="remember" name="remember"
                               <c:if test="${param.remember eq 'true' || not empty cookie.username.value}">checked</c:if>>
                        <label class="form-check-label" for="remember">Nhớ tôi</label>
                    </div>
                    <a class="text-decoration-none forgot-link" href="<c:url value='/forgot'/>">Quên mật khẩu?</a>
                </div>

                <button type="submit" class="btn btn-auth w-100 py-2 mb-2">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Đăng nhập
                </button>

                <div class="text-center small-muted">
                    Bạn là khách? <a href="<c:url value='/'/>" class="text-decoration-none">Về trang chủ</a>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/layouts/Footer.jsp"/>

<!-- JS -->
<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
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
