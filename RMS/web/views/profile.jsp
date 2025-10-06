<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${empty sessionScope.user}">
  <c:redirect url="/LoginServlet"/>
</c:if>
<c:set var="page" value="profile" scope="request"/>
<c:set var="overlayNav" value="false" scope="request"/>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Edit Profile | Restoran</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Favicon -->
  <link href="<c:url value='/img/favicon.ico'/>" rel="icon">

  <!-- Fonts & Icons -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&family=Nunito:wght@600;700;800&family=Pacifico&display=swap" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Theme CSS -->
  <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet">
  <link href="<c:url value='/css/style.css'/>" rel="stylesheet">

  <style>
    :root{ --radius:16px; --line:#eef2f7; --ink-500:#64748b; }
    .profile-card{border:0;border-radius:var(--radius);box-shadow:0 12px 30px rgba(20,24,40,.08)}
    .avatar-wrap{position:relative;display:inline-block}
    .avatar-wrap input[type=file]{position:absolute;inset:0;opacity:0;cursor:pointer}
    .avatar-badge{position:absolute;right:0;bottom:0;background:#c9a86a;color:#111;border-radius:999px;padding:.35rem;border:2px solid #fff}
    #nav-spacer{height:0}
    .muted{color:var(--ink-500)}

    /* Nối gần tiêu đề */
    .page-head{ margin-bottom: 1rem; }
    .lift-up{ margin-top: -1.25rem; }
  </style>
</head>
<body>

  <!-- Header -->
  <jsp:include page="/layouts/Header.jsp"/>

  <!-- Spacer for sticky navbar -->
  <div id="nav-spacer" aria-hidden="true"></div>

  <c:set var="u" value="${sessionScope.user}"/>

  <div class="container-xxl py-5">
    <div class="container">
      <!-- Breadcrumb + Back -->
      <div class="d-flex align-items-center justify-content-between page-head">
        <div>
          <h3 class="mb-1">Edit Profile</h3>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
              <li class="breadcrumb-item"><a href="<c:url value='/profile'/>">Profile</a></li>
              <li class="breadcrumb-item active" aria-current="page">Edit</li>
            </ol>
          </nav>
        </div>
        <button type="button" class="btn btn-outline-secondary" onclick="goBack()">
          <i class="bi bi-arrow-left me-1"></i> Back
        </button>
      </div>

      <!-- Flash -->
      <c:if test="${not empty sessionScope.flash}">
        <div class="alert alert-info d-flex align-items-start">
          <i class="bi bi-info-circle me-2"></i>
          <div>${sessionScope.flash}</div>
        </div>
        <c:remove var="flash" scope="session"/>
      </c:if>

      <div class="card profile-card lift-up">
        <div class="card-body p-4 p-lg-5">
          <!-- NOTE: thêm id + novalidate để bật custom validation -->
          <form id="profileForm" action="<c:url value='/UpdateProfileServlet'/>" method="post" enctype="multipart/form-data" class="row g-4" novalidate>
            <!-- Left -->
            <div class="col-lg-4 text-center">
              <div class="avatar-wrap mb-3">
                <img id="avatarPreview"
                     src="<c:url value='${empty u.avatarUrl ? "/img/default-avatar.jpg" : u.avatarUrl}'/>"
                     class="rounded-circle" style="width:140px;height:140px;object-fit:cover;border:4px solid rgba(0,0,0,.05)" alt="avatar">
                <span class="avatar-badge"><i class="bi bi-camera"></i></span>
                <input type="file" name="avatar" id="avatarInput" accept="image/*">
              </div>
              <div class="small muted">JPG/PNG up to 5MB</div>
              <hr class="my-4">
              <div class="mb-2">
                <label class="form-label text-muted mb-0">Role</label><br>
                <span class="badge bg-primary"><c:out value="${empty u.roleName ? '—' : u.roleName}"/></span>
              </div>
              <div>
                <label class="form-label text-muted mb-0">Status</label><br>
                <span class="badge ${u.accountStatus=='ACTIVE' ? 'bg-success' : 'bg-secondary'}">
                  <c:out value="${u.accountStatus}"/>
                </span>
              </div>
            </div>

            <!-- Right -->
            <div class="col-lg-8">
              <div class="row g-3">
                <div class="col-12">
                  <label class="form-label">Username</label>
                  <input type="text" class="form-control" value="${u.username}" readonly>
                </div>

                <div class="col-sm-6">
                  <label for="firstName" class="form-label">First Name</label>
                  <input type="text" class="form-control" id="firstName" name="firstName" value="${u.firstName}">
                </div>
                <div class="col-sm-6">
                  <label for="lastName" class="form-label">Last Name</label>
                  <input type="text" class="form-control" id="lastName" name="lastName" value="${u.lastName}">
                </div>

                <!-- Email: chỉ chấp nhận @gmail.com, không khoảng trắng -->
                <div class="col-sm-6">
                  <label for="email" class="form-label">Email</label>
                  <input type="email"
                         class="form-control"
                         id="email"
                         name="email"
                         value="${u.email}"
                         required
                         pattern="^[a-zA-Z0-9._%+-]+@gmail\.com$"
                         inputmode="email"
                         autocomplete="email"
                         aria-describedby="emailHelp">
                  <div id="emailHelp" class="form-text">Chỉ chấp nhận địa chỉ <strong>@gmail.com</strong>, không có khoảng trắng.</div>
                  <div class="invalid-feedback">Email không hợp lệ. Vui lòng dùng định dạng <em>username@gmail.com</em>.</div>
                </div>

                <!-- Phone: 10 số, bắt đầu 0, không khoảng trắng -->
                <div class="col-sm-6">
                  <label for="phone" class="form-label">Phone</label>
                  <input type="text"
                         class="form-control"
                         id="phone"
                         name="phone"
                         value="${u.phone}"
                         required
                         pattern="^0\d{9}$"
                         inputmode="numeric"
                         maxlength="10"
                         aria-describedby="phoneHelp">
                  <div id="phoneHelp" class="form-text">Phải gồm <strong>10 số</strong>, bắt đầu bằng <strong>0</strong>, không có khoảng trắng.</div>
                  <div class="invalid-feedback">Số điện thoại không hợp lệ. Ví dụ hợp lệ: 0901234567.</div>
                </div>

                <div class="col-12">
                  <label for="address" class="form-label">Address</label>
                  <input type="text" class="form-control" id="address" name="address" value="${u.address}">
                </div>

                <div class="col-12">
                  <label class="form-label">Password</label><br>
                  <button type="button" class="btn btn-outline-warning">
                    <i class="bi bi-key me-1"></i> Change Password
                  </button>
                  
                </div>
              </div>

              <div class="d-flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary px-4">
                  <i class="bi bi-save me-1"></i> Save Changes
                </button>
                <button type="button" class="btn btn-outline-secondary" onclick="goBack()">Cancel</button>
              </div>
            </div>
          </form>
        </div>
      </div>

    </div>
  </div>

  <jsp:include page="/layouts/Footer.jsp"/>

  <!-- JS -->
  <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
  <script src="<c:url value='/js/main.js'/>"></script>

  <!-- Avatar preview + Back fallback + Spacer -->
  <script>
    // Back with fallback to /profile when no referrer
    function goBack(){
      if (document.referrer && document.referrer !== window.location.href) {
        history.back();
      } else {
        window.location.href = '<c:url value="/profile"/>';
      }
    }

    // Avatar preview
    (function(){
      const input = document.getElementById('avatarInput');
      const preview = document.getElementById('avatarPreview');
      if (input && preview) {
        input.addEventListener('change', function () {
          const file = this.files && this.files[0];
          if (!file) return;
          const reader = new FileReader();
          reader.onload = e => preview.src = e.target.result;
          reader.readAsDataURL(file);
        });
      }
    })();

    // Spacer equals sticky navbar height
    (function(){
      const nav = document.getElementById('mainNav');
      const spacer = document.getElementById('nav-spacer');
      function applySpacer(){
        if (!nav || !spacer) return;
        const isOverlay = nav.getAttribute('data-overlay') === 'true';
        spacer.style.height = isOverlay ? '0px' : (nav.offsetHeight + 'px');
      }
      applySpacer();
      window.addEventListener('resize', applySpacer);
    })();
  </script>

  <!-- Client-side validation -->
  <script>
    (function(){
      const form  = document.getElementById('profileForm');
      const email = document.getElementById('email');
      const phone = document.getElementById('phone');

      function stripSpaces(el){ if(!el) return; el.value = el.value.replace(/\s+/g,''); }

      // Chặn khoảng trắng khi nhập
      [email, phone].forEach(el => el && el.addEventListener('keydown', e => { if(e.key === ' ') e.preventDefault(); }));

      // Phone: chỉ giữ số, tối đa 10
      phone?.addEventListener('input', () => { phone.value = phone.value.replace(/\D+/g,'').slice(0,10); });

      // Email: bỏ khoảng trắng
      email?.addEventListener('input', () => stripSpaces(email));

      form?.addEventListener('submit', (e) => {
        stripSpaces(email); stripSpaces(phone);

        // Gmail only
        if (email && !/^[-\w.+%]+@gmail\.com$/i.test(email.value)){
          email.setCustomValidity('Email must be @gmail.com');
        } else { email?.setCustomValidity(''); }

        // VN phone: 10 số, bắt đầu 0
        if (phone && !/^0\d{9}$/.test(phone.value)){
          phone.setCustomValidity('VN phone must be 10 digits starting with 0');
        } else { phone?.setCustomValidity(''); }

        if (!form.checkValidity()){
          e.preventDefault();
          e.stopPropagation();
        }
        form.classList.add('was-validated');
      });
    })();
  </script>
</body>
</html>
