<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<!-- Nếu chưa đăng nhập thì đá ra login -->
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<c:set var="u" value="${sessionScope.user}" />

<!-- viewMode từ servlet: 'create' / 'edit' / 'view' -->
<c:set var="isCreate" value="${viewMode == 'create'}"/>
<c:set var="isEdit"   value="${viewMode == 'edit'}"/>
<c:set var="isView"   value="${viewMode == 'view'}"/>

<!-- Gán shift local để code ngắn -->
<c:set var="sh" value="${shift}" />

<!-- Tạo tên người tạo -->
<c:choose>
    <c:when test="${not empty sh && not empty sh.createdByFullName}">
        <c:set var="creatorName" value="${sh.createdByFullName}"/>
    </c:when>
    <c:otherwise>
        <c:set var="creatorName" value="${u.firstName} ${u.lastName}"/>
    </c:otherwise>
</c:choose>

<!-- Format ngày (yyyy-MM-dd) cho input[type=date] -->
<c:set var="shiftDateStr" value="${sh.shiftDate}" />

<!-- Format giờ HH:mm cho input[type=time] -->
<c:choose>
    <c:when test="${not empty sh.startTime}">
        <c:set var="startTimeStr" value="${fn:substring(sh.startTime,0,5)}"/>
    </c:when>
    <c:otherwise>
        <c:set var="startTimeStr" value=""/>
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${not empty sh.endTime}">
        <c:set var="endTimeStr" value="${fn:substring(sh.endTime,0,5)}"/>
    </c:when>
    <c:otherwise>
        <c:set var="endTimeStr" value=""/>
    </c:otherwise>
</c:choose>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>
        <c:choose>
            <c:when test="${isCreate}">Tạo ca mới</c:when>
            <c:when test="${isEdit}">Chỉnh sửa ca #${sh.shiftId}</c:when>
            <c:otherwise>Chi tiết ca #${sh.shiftId}</c:otherwise>
        </c:choose>
        · RMSG4
    </title>

    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Fonts / Icons / Bootstrap -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet"/>

    <!-- (optional) site base css -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <style>
        body{
            font-family:"Heebo", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
            background:
                radial-gradient(1000px 600px at 8% 0%, rgba(88,80,200,.08) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, rgba(254,161,22,.06) 0%, transparent 60%),
                #f5f6fa;
            min-height:100vh;
        }
        .app-shell{
            display:grid;
            grid-template-columns:280px 1fr;
            min-height:100vh;
        }
        @media(max-width:992px){
            .app-shell{
                grid-template-columns:1fr;
            }
            #sidebar{
                position:fixed;
                inset:0 30% 0 0;
                max-width:280px;
                background:#1f2535;
                color:#fff;
                box-shadow:24px 0 60px rgba(0,0,0,.7);
                transform:translateX(-100%);
                transition:transform .2s ease;
                z-index:1040;
            }
            #sidebar.open{
                transform:translateX(0);
            }
        }

        main.main-pane{
            padding:28px 32px 44px;
        }

        /* Card form ca */
        .shift-card{
            background:#fff;
            border-radius:16px;
            border:1px solid rgba(99,102,241,.25);
            box-shadow:0 24px 60px rgba(15,23,42,.08), inset 0 1px 0 rgba(255,255,255,.6);
            max-width:1100px;
        }
        .shift-card-header{
            border-top:4px solid #fea116;
            border-radius:16px 16px 0 0;
            background:linear-gradient(135deg,#1b1e2c 0%,#2b2f46 60%,#1c1f30 100%);
            color:#fff;
            padding:1rem 1.25rem;
            display:flex;
            flex-direction:column;
            gap:.5rem;
        }
        .shift-card-header .title-row{
            font-weight:600;
            font-size:1rem;
            color:#fff;
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:.5rem;
        }
        .shift-card-header .title-row i{
            color:#fea116;
        }
        .shift-card-header .sub{
            font-size:.8rem;
            color:#94a3b8;
        }
        .shift-card-body{
            padding:1rem 1.25rem 1.5rem;
        }
        .shift-card-footer{
            border-top:1px solid #e5e7eb;
            padding:1rem 1.25rem;
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            gap:.75rem;
        }

        .form-control, .form-select{
            border-radius:10px;
            border:1.5px solid #e2e8f0;
            font-size:.9rem;
        }
        .form-control:focus,
        .form-select:focus{
            border-color:#fea116;
            box-shadow:0 0 0 .25rem rgba(254,161,22,.25);
            background:#fffefc;
        }
        .readonly-field{
            background-color:#f8f9fa;
        }

        .btn-back{
            border-radius:10px;
            border:1.5px solid #cbd5e1;
            background:#fff;
            color:#475569;
            font-size:.8rem;
            font-weight:500;
            padding:.6rem .9rem;
            line-height:1.2;
        }
        .btn-back:hover{
            background:#f8fafc;
        }
        .btn-save{
            border-radius:10px;
            background:linear-gradient(135deg,#6366f1 0%,#4f46e5 60%);
            border:none;
            color:#fff;
            font-weight:600;
            font-size:.8rem;
            line-height:1.2;
            padding:.6rem 1rem;
            box-shadow:0 12px 24px rgba(99,102,241,.4);
        }
        .btn-save:hover{
            background:linear-gradient(135deg,#4f46e5 0%,#4338ca 60%);
            box-shadow:0 16px 32px rgba(79,70,229,.5);
        }

        .status-hint{
            font-size:.7rem;
            color:#64748b;
        }

        .flash-area .alert{
            font-size:.8rem;
        }

        .btn-toggle-sidebar{
            display:none;
        }
        @media(max-width:992px){
            .btn-toggle-sidebar{
                display:inline-flex;
                align-items:center;
                gap:.4rem;
                background:transparent;
                border:1px solid rgba(0,0,0,.3);
                color:#000;
                font-size:.8rem;
                line-height:1.2;
                border-radius:6px;
                padding:6px 10px;
            }
        }
    </style>
</head>
<body>

<!-- HEADER chung -->
<jsp:include page="/layouts/Header.jsp"/>

<div class="app-shell">
    <!-- SIDEBAR -->
    <aside id="sidebar" class="bg-dark text-white">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <!-- MAIN -->
    <main class="main-pane">

        <!-- FLASH MESSAGE -->
        <div class="flash-area mb-3">
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
        </div>

        <!-- CARD FORM -->
        <section class="shift-card">

            <!-- HEADER -->
            <div class="shift-card-header">
                <div class="title-row">
                    <i class="bi bi-calendar-week"></i>
                    <span>
                        <c:choose>
                            <c:when test="${isCreate}">Tạo ca mới</c:when>
                            <c:when test="${isEdit}">Chỉnh sửa ca #${sh.shiftId}</c:when>
                            <c:otherwise>Chi tiết ca #${sh.shiftId}</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="sub">
                    Quản lý phân ca cho từng nhân viên. Cập nhật thời gian làm việc và trạng thái ca.
                    <br/>
                    Người tạo: <strong>${creatorName}</strong>
                </div>
            </div>

            <!-- BODY -->
            <div class="shift-card-body">
                <form method="POST"
                      action="<c:url value='/StaffShiftServlet'/>"
                      class="row g-3">

                    <!-- action submit -->
                    <input type="hidden" name="action"
                           value="<c:choose>
                                      <c:when test='${isCreate}'>saveCreate</c:when>
                                      <c:when test='${isEdit}'>saveEdit</c:when>
                                      <c:otherwise></c:otherwise>
                                  </c:choose>"/>

                    <!-- id ca (nếu edit) -->
                    <c:if test="${isEdit or isView}">
                        <input type="hidden" name="shift_id" value="${sh.shiftId}"/>
                    </c:if>

                    <!-- Nhân viên -->
                    <div class="col-12">
                        <label class="form-label fw-semibold">Nhân viên</label>

                        <c:choose>
                            <c:when test="${isView}">
                                <input type="text"
                                       class="form-control readonly-field"
                                       value="${sh.staffFullName} (${sh.staffRoleName}) - ${sh.staffPhone}"
                                       readonly/>
                            </c:when>
                            <c:otherwise>
                                <select name="staff_id"
                                        class="form-select"
                                        required>
                                    <option value="">-- Chọn nhân viên --</option>
                                    <c:forEach var="st" items="${staffList}">
                                        <option value="${st.userId}"
                                            <c:if test="${sh.staffId == st.userId}">selected</c:if>>
                                            ${st.firstName} ${st.lastName}
                                            (${st.roleName}) - ${st.phone}
                                        </option>
                                    </c:forEach>
                                </select>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Ngày làm -->
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Ngày làm</label>
                        <input type="date"
                               name="shift_date"
                               class="form-control ${isView ? 'readonly-field' : ''}"
                               value="${shiftDateStr}"
                               ${isView ? 'readonly' : ''} required/>
                        <div class="form-text status-hint">
                            Định dạng YYYY-MM-DD
                        </div>
                    </div>

                    <!-- Bắt đầu -->
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Bắt đầu</label>
                        <input type="time"
                               name="start_time"
                               class="form-control ${isView ? 'readonly-field' : ''}"
                               value="${startTimeStr}"
                               ${isView ? 'readonly' : ''} required/>
                    </div>

                    <!-- Kết thúc -->
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Kết thúc</label>
                        <input type="time"
                               name="end_time"
                               class="form-control ${isView ? 'readonly-field' : ''}"
                               value="${endTimeStr}"
                               ${isView ? 'readonly' : ''} required/>
                    </div>

                    <!-- Trạng thái -->
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Trạng thái ca</label>

                        <c:choose>
                            <c:when test="${isView}">
                                <input type="text"
                                       class="form-control readonly-field"
                                       value="${sh.status}"
                                       readonly/>
                            </c:when>
                            <c:otherwise>
                                <select name="status" class="form-select" required>
                                    <option value="SCHEDULED"
                                        <c:if test="${sh.status=='SCHEDULED' || empty sh.status}">
                                            selected
                                        </c:if>>
                                        Lên lịch
                                    </option>
                                    <option value="DONE"
                                        <c:if test="${sh.status=='DONE'}">selected</c:if>>
                                        Hoàn thành
                                    </option>
                                    <option value="CANCELLED"
                                        <c:if test="${sh.status=='CANCELLED'}">selected</c:if>>
                                        Hủy
                                    </option>
                                </select>
                            </c:otherwise>
                        </c:choose>

                        <div class="form-text status-hint">
                            DONE = đã hoàn thành ca (thường đánh dấu sau khi ca kết thúc).
                        </div>
                    </div>

                    <!-- Người tạo -->
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Người tạo</label>
                        <input type="text"
                               class="form-control readonly-field"
                               value="${creatorName}"
                               readonly/>
                    </div>

                    <!-- FOOTER BUTTON -->
                    <div class="col-12 shift-card-footer">
                        <a class="btn-back"
                           href="<c:url value='/StaffShiftServlet?action=weekTimetable'/>">
                            <i class="bi bi-arrow-left-circle me-1"></i>
                            Quay lại lịch tuần
                        </a>

                        <c:if test="${!isView}">
                            <button type="submit" class="btn-save">
                                <i class="bi bi-save me-1"></i> Lưu ca
                            </button>
                        </c:if>
                    </div>

                </form>
            </div>
        </section>

        <!-- FOOTER CHUNG -->
        <jsp:include page="/layouts/Footer.jsp"/>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function toggleSidebar(){
        var el = document.getElementById('sidebar');
        if(el){ el.classList.toggle('open'); }
    }

    // auto close alert sau 5s
    setTimeout(function(){
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(al){
            try{
                var bsAlert = new bootstrap.Alert(al);
                bsAlert.close();
            }catch(e){}
        });
    }, 5000);
</script>
</body>
</html>
