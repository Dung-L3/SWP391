<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="page" value="auth" scope="request"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Đặt lại mật khẩu | Restoran</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon">
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet">
    <style>
        body{background:linear-gradient(135deg,#ffcf8c 0%,#fea116 50%,#ff8c00 100%);min-height:100vh;display:flex;flex-direction:column;}
        .auth-container{flex:1;display:flex;align-items:center;justify-content:center;padding:3rem 1rem;}
        .auth-card{max-width:450px;width:100%;background:#fff;border:0;border-radius:1.25rem;box-shadow:0 12px 30px rgba(0,0,0,.15);}
        .auth-header{text-align:center;padding:2rem 1.5rem 1rem;}
        .auth-header h3{font-weight:700;margin-bottom:.25rem;}
        .auth-header p{color:#6c757d;font-size:.925rem;}
        .input-group-text{background:#fff;border-right:0;font-size:1.1rem;}
        .input-group .form-control{border-left:0;}
        .form-control:focus{box-shadow:none;border-color:#fea116;}
        .btn-auth{background:#fea116;border-color:#fea116;font-weight:600;}
        .btn-auth:hover{filter:brightness(.95);}
    </style>
</head>
<body>
<jsp:include page="/layouts/Header.jsp"/>

<div class="auth-container">
    <div class="card auth-card">
        <div class="auth-header">
            <i class="bi bi-lock-fill text-primary display-4 mb-2"></i>
            <h3>Đặt lại mật khẩu</h3>
            <p>Nhập mật khẩu mới cho tài khoản của bạn.</p>
        </div>
        <div class="card-body p-4">
            <form method="post" action="<c:url value='/reset-password'/>">
                <input type="hidden" name="token" value="${token}">
                <div class="mb-3">
                    <label class="form-label">Mật khẩu mới</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                        <input type="password" class="form-control" name="password" required minlength="6">
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label">Xác nhận mật khẩu</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                        <input type="password" class="form-control" name="confirm" required minlength="6">
                    </div>
                </div>
                <button class="btn btn-auth w-100 py-2">
                    <i class="bi bi-check-circle me-1"></i> Đặt lại mật khẩu
                </button>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/layouts/Footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
