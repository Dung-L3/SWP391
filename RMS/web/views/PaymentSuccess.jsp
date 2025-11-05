<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    // Lấy attribute từ request (có thể null)
    String uiStatus    = (String) request.getAttribute("uiStatus");    // "OK" | "FAIL" | null
    String billNo      = (String) request.getAttribute("billNo");      // có thể null
    Object paidObj     = request.getAttribute("paidAmount");           // BigDecimal | String | null
    String method      = (String) request.getAttribute("method");      // "Tiền mặt", "VNPAY", ...
    String reasonText  = (String) request.getAttribute("reasonText");  // giải thích thêm

    // fallback
    if (uiStatus == null) {
        // nếu không set (case thanh toán tiền mặt xong trong PaymentServlet), coi như OK
        uiStatus = "OK";
    }
    if (billNo == null) {
        billNo = "N/A";
    }
    String paidAmountStr;
    if (paidObj == null) {
        paidAmountStr = "0";
    } else {
        paidAmountStr = paidObj.toString();
    }
    if (method == null) {
        method = "Không xác định";
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>Kết quả thanh toán | POS RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>

    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
        rel="stylesheet"
    />

    <style>
        :root{
            --bg-grad-start:#0f172a;
            --bg-grad-end:#1e1e2f;
            --accent:#facc15;
            --accent-dark:#eab308;

            --panel-bg:#ffffff;
            --panel-border:#facc15;

            --text-strong:#0f172a;
            --text-mid:#475569;
            --text-dim:#64748b;
            --text-muted:#94a3b8;

            --success-bg:#f0fdf4;
            --success-border:#86efac;
            --success-text:#065f46;

            --fail-bg:#fff7ed;
            --fail-border:#fdba74;
            --fail-text:#9a3412;

            --radius-lg:14px;
            --radius-md:8px;
            --radius-full:999px;
        }

        *{ box-sizing:border-box; }

        body{
            margin:0;
            padding:24px;
            min-height:100vh;
            background:
                radial-gradient(circle at 0% 0%,rgba(250,204,21,.12) 0%,rgba(15,23,42,0) 60%),
                radial-gradient(circle at 100% 0%,rgba(251,191,36,.07) 0%,rgba(15,23,42,0) 60%),
                linear-gradient(135deg,var(--bg-grad-start) 0%,var(--bg-grad-end) 60%);
            color:#fff;
            font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",sans-serif;
            display:flex;
            align-items:flex-start;
            justify-content:center;
        }

        .wrap-page{
            width:100%;
            max-width:480px;
            display:flex;
            flex-direction:column;
            gap:16px;
        }

        .header-top{
            display:flex;
            flex-wrap:wrap;
            justify-content:space-between;
            align-items:flex-start;
            row-gap:12px;
        }
        .title-col{
            display:flex;
            flex-direction:column;
            gap:4px;
        }
        .main-title-row{
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:8px;
            color:#fff;
        }
        .screen-title{
            font-size:1rem;
            font-weight:600;
            line-height:1.3;
        }
        .subtitle{
            font-size:.8rem;
            line-height:1.4;
            color:var(--text-muted);
        }

        .action-col{
            display:flex;
            flex-wrap:wrap;
            gap:8px;
            align-items:flex-start;
        }
        .btn-nav{
            display:inline-flex;
            align-items:center;
            gap:6px;
            background:#1e293b;
            color:#fff;
            border:1px solid rgba(148,163,184,.4);
            border-radius:var(--radius-md);
            padding:8px 12px;
            font-size:.8rem;
            font-weight:500;
            line-height:1.2;
            text-decoration:none;
            box-shadow:0 12px 24px rgba(0,0,0,.6);
        }
        .btn-nav i{
            color:var(--accent);
            font-size:.9rem;
            line-height:1;
        }

        .card{
            background:#fff;
            border:1px solid rgba(250,204,21,.4);
            border-top:4px solid var(--panel-border);
            border-radius:var(--radius-lg);
            box-shadow:0 20px 60px rgba(0,0,0,.6),0 1px 0 rgba(255,255,255,.6) inset;
            color:var(--text-strong);
            overflow:hidden;
        }

        .card-header{
            padding:16px 20px 12px;
            background:linear-gradient(to bottom right,#fff 0%,#fffef7 60%);
            border-bottom:1px solid rgba(0,0,0,.05);

            display:flex;
            align-items:flex-start;
            gap:.75rem;
        }
        .icon-circle{
            width:36px;
            height:36px;
            border-radius:var(--radius-full);
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:1rem;
            line-height:1;
            flex-shrink:0;
            box-shadow:0 10px 25px rgba(0,0,0,.2);
        }
        .icon-ok{
            background:var(--success-bg);
            color:#16a34a;
            border:1px solid var(--success-border);
        }
        .icon-fail{
            background:var(--fail-bg);
            color:#dc2626;
            border:1px solid var(--fail-border);
        }

        .header-main{
            flex:1;
            min-width:0;
        }
        .card-title{
            font-size:.9rem;
            font-weight:600;
            line-height:1.4;
            color:var(--text-strong);
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            gap:8px;
        }
        .status-pill{
            font-size:.7rem;
            font-weight:600;
            line-height:1.2;
            border-radius:var(--radius-full);
            padding:2px 8px;
            border:1px solid;
            white-space:nowrap;
        }
        .pill-ok{
            background:var(--success-bg);
            border-color:var(--success-border);
            color:var(--success-text);
        }
        .pill-fail{
            background:var(--fail-bg);
            border-color:var(--fail-border);
            color:var(--fail-text);
        }

        .card-desc{
            margin-top:4px;
            font-size:.7rem;
            line-height:1.4;
            color:var(--text-dim);
            word-break:break-word;
        }

        .card-body{
            padding:16px 20px 20px;
            font-size:.8rem;
            line-height:1.4;
            color:var(--text-mid);
        }

        .info-row{
            display:flex;
            justify-content:space-between;
            align-items:flex-start;
            padding:8px 0;
            border-bottom:1px solid #e5e7eb;
            font-size:.8rem;
        }
        .info-row:last-child{
            border-bottom:none;
        }
        .info-label{
            font-weight:500;
            color:var(--text-dim);
            line-height:1.4;
            font-size:.75rem;
        }
        .info-value{
            text-align:right;
            font-weight:600;
            color:var(--text-strong);
            line-height:1.4;
            font-size:.8rem;
            word-break:break-all;
            max-width:60%;
        }

        .footer-hint{
            margin-top:16px;
            font-size:.7rem;
            line-height:1.4;
            color:var(--text-dim);
            text-align:center;
        }

        .again-wrap{
            margin-top:16px;
            text-align:center;
        }
        .btn-again{
            display:inline-flex;
            align-items:center;
            justify-content:center;
            background:#fff;
            color:#1e293b;
            border:1px solid #94a3b8;
            border-radius:var(--radius-md);
            font-size:.8rem;
            font-weight:600;
            padding:10px 14px;
            line-height:1.2;
            text-decoration:none;
            box-shadow:0 16px 30px rgba(0,0,0,.25);
            cursor:pointer;
        }
        .btn-again i{
            color:var(--accent-dark);
            font-size:.9rem;
            line-height:1;
            margin-right:6px;
        }

        @media(max-width:480px){
            body{padding:16px;}
            .wrap-page{max-width:100%;}
        }
    </style>
</head>
<body>

<div class="wrap-page">

    <!-- HEADER -->
    <div class="header-top">
        <div class="title-col">
            <div class="main-title-row">
                <div class="screen-title">Kết quả thanh toán</div>
            </div>
            <div class="subtitle">
                Chi tiết bill và trạng thái giao dịch vừa thực hiện.
            </div>
        </div>

        <div class="action-col">
            <a class="btn-nav" href="<c:url value='/reception'/>">
                <i class="bi bi-arrow-left-circle"></i>
                <span>Quay về lễ tân</span>
            </a>
        </div>
    </div>

    <!-- CARD RESULT -->
    <div class="card">
        <div class="card-header">
            <div class="icon-circle <%= "OK".equalsIgnoreCase(uiStatus) ? "icon-ok" : "icon-fail" %>">
                <i class="bi <%= "OK".equalsIgnoreCase(uiStatus) ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill" %>"></i>
            </div>

            <div class="header-main">
                <div class="card-title">
                    <span>
                        <%= "OK".equalsIgnoreCase(uiStatus)
                                ? "Thanh toán thành công"
                                : "Thanh toán chưa hoàn tất" %>
                    </span>

                    <span class="status-pill <%= "OK".equalsIgnoreCase(uiStatus) ? "pill-ok" : "pill-fail" %>">
                        <%= "OK".equalsIgnoreCase(uiStatus) ? "SUCCESS" : "PENDING / FAIL" %>
                    </span>
                </div>

                <div class="card-desc">
                    <c:choose>
                        <c:when test="${not empty reasonText}">
                            ${reasonText}
                        </c:when>
                        <c:otherwise>
                            <!-- fallback mô tả -->
                            <%= "OK".equalsIgnoreCase(uiStatus)
                                    ? "Thanh toán đã được ghi nhận vào hệ thống."
                                    : "Giao dịch chưa hoàn tất hoặc bị hủy. Vui lòng kiểm tra lại hoặc thử phương thức khác." %>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <div class="card-body">

            <div class="info-row">
                <div class="info-label">Mã/bill số</div>
                <div class="info-value"><%= billNo %></div>
            </div>

            <div class="info-row">
                <div class="info-label">Số tiền đã ghi nhận</div>
                <div class="info-value"><%= paidAmountStr %> đ</div>
            </div>

            <div class="info-row">
                <div class="info-label">Phương thức</div>
                <div class="info-value"><%= method %></div>
            </div>

            <div class="info-row">
                <div class="info-label">Thời điểm</div>
                <div class="info-value">
                    <%= java.time.LocalDateTime.now()
                            .format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) %>
                </div>
            </div>

            <div class="footer-hint">
                • Nếu đây là bill PROFORMA (ví dụ khách đang quét VNPay),
                bill sẽ tự chuyển FINAL khi VNPay báo "SUCCESS".<br/>
                • Bạn có thể xem lại lịch sử thanh toán và mở lại VNPay từ màn hình thanh toán bàn.
            </div>

            <div class="again-wrap">
                <a class="btn-again" href="<c:url value='/reception'/>">
                    <i class="bi bi-arrow-return-left"></i>
                    <span>Về danh sách bàn</span>
                </a>
            </div>

        </div>
    </div>

</div><!-- /wrap-page -->

</body>
</html>
