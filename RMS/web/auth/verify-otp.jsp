<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="page" value="auth" scope="request"/>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <title>Xác thực OTP | Restoran</title>
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
    .form-control:focus{box-shadow:none;border-color:#fea116;}
    .btn-auth{background:#fea116;border-color:#fea116;font-weight:600;}
    .btn-auth:hover{filter:brightness(.95);}
    .muted{color:#6c757d;font-size:.9rem;}
  </style>
</head>
<body>
<jsp:include page="/layouts/Header.jsp"/>

<div class="auth-container">
  <div class="card auth-card">
    <div class="auth-header">
      <i class="bi bi-shield-lock-fill text-primary display-4 mb-2"></i>
      <h3>Xác thực OTP</h3>
      <p>Mã OTP có hiệu lực trong <b>2 phút</b>. Thời gian còn lại: <span id="countdown">02:00</span></p>
    </div>
    <div class="card-body p-4">

      <c:if test="${not empty error}">
        <div class="alert alert-danger d-flex align-items-start">
          <i class="bi bi-exclamation-triangle me-2"></i>
          <div>${error}</div>
        </div>
      </c:if>

      <c:if test="${not empty sessionScope.flash}">
        <div class="alert alert-info d-flex align-items-start">
          <i class="bi bi-info-circle me-2"></i>
          <div>${sessionScope.flash}</div>
        </div>
        <c:remove var="flash" scope="session"/>
      </c:if>

      <form method="post" action="<c:url value='/verify-otp'/>" class="mb-3">
        <input type="hidden" name="token" value="${token}">
        <label class="form-label">Mã OTP (6 số)</label>
        <div class="input-group mb-3">
          <span class="input-group-text"><i class="bi bi-key"></i></span>
          <input type="text" name="otp" maxlength="6" pattern="[0-9]{6}" inputmode="numeric"
                 oninput="this.value=this.value.replace(/[^0-9]/g,'')" class="form-control" required>
        </div>
        <button class="btn btn-auth w-100 py-2"><i class="bi bi-shield-check me-1"></i> Xác thực</button>
      </form>

      <form method="post" action="<c:url value='/resend-otp'/>" class="text-center">
        <input type="hidden" name="token" value="${token}">
        <button id="btnResend" class="btn btn-outline-secondary w-100 py-2" disabled>
          <i class="bi bi-arrow-clockwise me-1"></i> Gửi lại mã OTP
        </button>
        <div class="muted mt-2">Bạn có thể gửi lại sau <span id="resendIn">30</span>s.</div>
      </form>

    </div>
  </div>
</div>

<jsp:include page="/layouts/Footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // Đếm ngược 2 phút cho OTP (hiển thị)
  (function(){
    let remain = 120; // giây
    const el = document.getElementById('countdown');
    const fmt = s => {
      const m = Math.floor(s/60).toString().padStart(2,'0');
      const ss = (s%60).toString().padStart(2,'0');
      return m+':'+ss;
    };
    el.textContent = fmt(remain);
    const t = setInterval(()=>{
      remain--; if(remain<0){clearInterval(t); return;}
      el.textContent = fmt(remain);
    },1000);
  })();

  // Khoảng chờ 30s mới cho phép "Gửi lại mã"
  (function(){
    let remain = 30;
    const btn = document.getElementById('btnResend');
    const text = document.getElementById('resendIn');
    text.textContent = remain;
    const t = setInterval(()=>{
      remain--;
      if (remain<=0) {
        btn.disabled = false;
        text.parentElement.textContent = "Bạn có thể gửi lại ngay.";
        clearInterval(t);
      } else text.textContent = remain;
    },1000);
  })();
</script>
</body>
</html>
