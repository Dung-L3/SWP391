<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="Dal.BillDAO.BillSummary" %>
<%@ page import="Dal.PaymentDAO.PaymentInfo" %>
<%@ page import="Models.Order" %>
<%@ page import="Models.Voucher" %>

<%
    Integer tableIdObj = (Integer) request.getAttribute("tableId");
    Integer tableIdSafe = (tableIdObj != null ? tableIdObj : -1);

    @SuppressWarnings("unchecked")
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    if (orders == null) orders = new ArrayList<>();

    BigDecimal subtotal =
        (BigDecimal) request.getAttribute("summarySubtotal");
    if (subtotal == null) subtotal = BigDecimal.ZERO;

    BigDecimal taxAmount =
        (BigDecimal) request.getAttribute("summaryTax");
    if (taxAmount == null) taxAmount = BigDecimal.ZERO;

    BigDecimal discountAmount =
        (BigDecimal) request.getAttribute("summaryBaseDiscount");
    if (discountAmount == null) discountAmount = BigDecimal.ZERO;

    BigDecimal totalAmountRaw =
        (BigDecimal) request.getAttribute("summaryTotal");
    if (totalAmountRaw == null) totalAmountRaw = BigDecimal.ZERO;

    BigDecimal voucherDiscount =
        (BigDecimal) request.getAttribute("voucherDiscount");
    if (voucherDiscount == null) voucherDiscount = BigDecimal.ZERO;

    BigDecimal totalAfterVoucher =
        (BigDecimal) request.getAttribute("totalAfterVoucher");
    if (totalAfterVoucher == null) totalAfterVoucher = totalAmountRaw;

    BillSummary proformaBill =
        (BillSummary) request.getAttribute("proformaBill");

    Boolean canPayAgainObj = (Boolean) request.getAttribute("canPayAgain");
    boolean canPayAgain = (canPayAgainObj != null ? canPayAgainObj : false);

    @SuppressWarnings("unchecked")
    List<PaymentInfo> paymentsForBill =
        (List<PaymentInfo>) request.getAttribute("paymentsForBill");
    if (paymentsForBill == null) paymentsForBill = new ArrayList<>();

    @SuppressWarnings("unchecked")
    List<Voucher> vouchers =
        (List<Voucher>) request.getAttribute("vouchers");
    if (vouchers == null) vouchers = new ArrayList<>();

    int pendingCount = 0;
    for (PaymentInfo p : paymentsForBill) {
        if (p != null && "PENDING".equalsIgnoreCase(p.status)) {
            pendingCount++;
        }
    }

    PaymentInfo firstPending = null;
    for (PaymentInfo p : paymentsForBill) {
        if (p != null && "PENDING".equalsIgnoreCase(p.status)) {
            firstPending = p;
            break;
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <title>Thanh toán bàn #<%= tableIdSafe %> | POS RMSG4</title>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet"/>

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
                --success:#16a34a;
                --danger:#dc2626;
                --radius-lg:14px;
                --radius-md:8px;
                --radius-full:999px;
            }
            *{
                box-sizing:border-box;
            }
            body{
                margin:0;
                padding:24px;
                min-height:100vh;
                color:#fff;
                background:
                    radial-gradient(circle at 0% 0%,rgba(250,204,21,.12) 0%,rgba(15,23,42,0) 60%),
                    radial-gradient(circle at 100% 0%,rgba(251,191,36,.07) 0%,rgba(15,23,42,0) 60%),
                    linear-gradient(135deg,var(--bg-grad-start) 0%,var(--bg-grad-end) 60%);
                font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",sans-serif;
            }
            .page{
                max-width:1400px;
                margin:0 auto;
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
            .title-wrap{
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
            .table-chip{
                background:var(--accent);
                color:#1f1f2b;
                font-size:.75rem;
                font-weight:600;
                line-height:1.2;
                border-radius:var(--radius-md);
                padding:2px 8px;
                box-shadow:0 6px 16px rgba(250,204,21,.4);
            }
            .subtitle{
                font-size:.8rem;
                line-height:1.4;
                color:var(--text-muted);
            }
            .action-wrap{
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
            .status-strip{
                display:flex;
                flex-wrap:wrap;
                row-gap:12px;
                column-gap:16px;
                background:linear-gradient(to bottom right,#ffffff 0%,#f8f9ff 80%);
                border-radius:var(--radius-lg);
                border:1px solid rgba(148,163,184,.25);
                border-top:3px solid var(--accent);
                box-shadow:0 20px 60px rgba(0,0,0,.6),inset 0 1px 0 rgba(255,255,255,.8);
                color:var(--text-strong);
                padding:12px 16px;
                font-size:.8rem;
            }
            .status-block{
                min-width:150px;
            }
            .status-label{
                font-size:.7rem;
                font-weight:500;
                color:var(--text-dim);
                text-transform:uppercase;
                letter-spacing:.03em;
            }
            .status-val{
                margin-top:2px;
                font-size:.85rem;
                font-weight:600;
                color:var(--text-strong);
                display:flex;
                flex-wrap:wrap;
                align-items:center;
                gap:.5rem;
                line-height:1.4;
            }
            .pill{
                display:inline-flex;
                align-items:center;
                border-radius:var(--radius-full);
                padding:2px 8px;
                font-size:.7rem;
                font-weight:600;
                line-height:1.2;
                border:1px solid;
                white-space:nowrap;
            }
            .pill-live{
                background:#ecfeff;
                color:#0e7490;
                border-color:#06b6d4;
            }
            .pill-proforma{
                background:#fff7ed;
                color:#b45309;
                border-color:#f59e0b;
            }
            .pill-final{
                background:#f0fdf4;
                color:#166534;
                border-color:#16a34a;
            }
            .layout{
                display:grid;
                grid-template-columns:1fr 360px;
                gap:24px;
            }
            @media(max-width:1000px){
                .layout{
                    grid-template-columns:1fr;
                }
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
                display:flex;
                align-items:flex-start;
                gap:.5rem;
                padding:16px 20px 12px;
                background:linear-gradient(to bottom right,#fff 0%,#fffef7 60%);
                border-bottom:1px solid rgba(0,0,0,.05);
            }
            .icon{
                color:var(--accent-dark);
                font-size:1rem;
                line-height:1;
            }
            .card-header-main{
                flex:1;
                min-width:0;
            }
            .card-title{
                font-size:.85rem;
                font-weight:600;
                color:var(--text-strong);
                line-height:1.3;
            }
            .card-desc{
                font-size:.7rem;
                line-height:1.4;
                color:var(--text-dim);
            }
            .card-body{
                padding:16px 20px 20px;
                font-size:.8rem;
                line-height:1.4;
                color:var(--text-mid);
            }
            table.data-table{
                width:100%;
                border-collapse:collapse;
                font-size:.75rem;
                color:var(--text-strong);
            }
            .data-table thead th{
                background:#fffdf5;
                font-size:.7rem;
                font-weight:600;
                text-transform:uppercase;
                text-align:left;
                padding:8px;
                border-bottom:1px solid #e5e7eb;
                white-space:nowrap;
                color:#334155;
            }
            .data-table tbody td{
                border-bottom:1px solid #e5e7eb;
                padding:8px;
                vertical-align:top;
                font-size:.75rem;
                line-height:1.3;
            }
            .data-table tbody tr:last-child td{
                border-bottom:none;
            }
            .badge-order{
                background:#eef2ff;
                border:1px solid #6366f1;
                color:#1e1e2f;
                font-size:.7rem;
                font-weight:600;
                border-radius:4px;
                padding:2px 6px;
                line-height:1.2;
                white-space:nowrap;
            }
            .totals-wrap{
                font-size:.8rem;
                color:var(--text-strong);
            }
            .totals-row{
                display:flex;
                justify-content:space-between;
                padding:6px 0;
            }
            .totals-label{
                font-weight:500;
                color:var(--text-dim);
            }
            .totals-value{
                font-weight:600;
            }
            .totals-grand{
                color:var(--text-strong);
                font-size:1rem;
                font-weight:700;
            }
            .totals-sep{
                border-top:1px solid #e5e7eb;
                margin-top:8px;
                padding-top:10px;
            }
            .text-save{
                color:var(--success);
            }
            .pay-success{
                color:var(--success);
                font-weight:600;
            }
            .pay-pending{
                color:#b45309;
                font-weight:600;
            }
            .alert-warn{
                background:#fff7ed;
                border:1px solid #fdba74;
                border-radius:var(--radius-md);
                padding:8px 12px;
                font-size:.75rem;
                line-height:1.4;
                color:#9a3412;
            }
            .alert-ok{
                background:#f0fdf4;
                border:1px solid #86efac;
                border-radius:var(--radius-md);
                padding:8px 12px;
                font-size:.75rem;
                line-height:1.4;
                color:#065f46;
            }
            .lock-box{
                background:#fff7ed;
                border:1px solid #fdba74;
                border-radius:var(--radius-md);
                padding:12px;
                color:#9a3412;
                font-size:.75rem;
                line-height:1.4;
            }
            .retry-box{
                background:#fffef7;
                border:1px solid #fde68a;
                border-radius:var(--radius-md);
                padding:12px;
                font-size:.75rem;
                line-height:1.5;
                color:#78350f;
            }
            .btn-small{
                display:inline-flex;
                align-items:center;
                justify-content:center;
                background:#fff;
                color:#1e293b;
                border:1px solid #94a3b8;
                border-radius:var(--radius-md);
                font-size:.7rem;
                font-weight:600;
                padding:6px 10px;
                line-height:1.2;
                text-decoration:none;
                box-shadow:0 10px 20px rgba(0,0,0,.25);
                cursor:pointer;
            }
            .btn-small i{
                color:var(--accent-dark);
                font-size:.8rem;
            }
            .form-group{
                margin-bottom:16px;
            }
            .form-label{
                font-size:.8rem;
                font-weight:600;
                color:var(--text-strong);
                margin-bottom:4px;
                display:block;
            }
            .form-hint{
                font-size:.7rem;
                color:var(--text-dim);
                line-height:1.4;
            }
            .form-control,.form-select{
                width:100%;
                font-size:.85rem;
                padding:9px 10px;
                border-radius:var(--radius-md);
                border:1.5px solid #e2e8f0;
                outline:none;
                background:#fff;
                color:#0f172a;
            }
            .form-control:focus,.form-select:focus{
                border-color:var(--accent);
                box-shadow:0 0 0 0.25rem rgba(250,204,21,.3);
                background:#fffefc;
            }
            .input-error{
                border-color:#f97316 !important;
                box-shadow:0 0 0 0.25rem rgba(249,115,22,.25) !important;
            }
            .field-error{
                margin-top:6px;
                font-size:.72rem;
                color:#b45309;
                display:none;
            }
            .btn-submit{
                width:100%;
                background:linear-gradient(135deg,#16a34a,#0f766e);
                border:none;
                border-radius:var(--radius-md);
                padding:12px 14px;
                font-size:.9rem;
                font-weight:600;
                line-height:1.2;
                color:#fff;
                cursor:pointer;
                box-shadow:0 16px 40px rgba(22,163,74,.4);
            }
            .btn-submit:active{
                transform:translateY(1px);
            }
            .footer-note{
                font-size:.7rem;
                color:var(--text-dim);
                line-height:1.4;
                margin-top:10px;
                text-align:center;
            }
            .hidden{
                display:none;
            }
            .mt16{
                margin-top:16px;
            }
        </style>
    </head>
    <body>

        <div class="page">

            <div class="header-top">
                <div class="title-wrap">
                    <div class="main-title-row">
                        <div class="screen-title">Thanh toán bàn</div>
                        <div class="table-chip">#<%= tableIdSafe %></div>
                    </div>
                    <div class="subtitle">
                        Gộp tất cả order chưa SETTLED • Áp voucher • Chọn phương thức • Chuyển VNPay khi cần
                    </div>
                </div>

                <div class="action-wrap">
                    <a class="btn-nav" href="/RMS/reception">
                        <i class="bi bi-arrow-left-circle"></i>
                        <span>Quay về quầy lễ tân</span>
                    </a>
                </div>
            </div>

            <div class="status-strip">
                <div class="status-block">
                    <div class="status-label">Bàn</div>
                    <div class="status-val"><span>#<%= tableIdSafe %></span></div>
                </div>

                <div class="status-block">
                    <div class="status-label">Tổng cần thu</div>
                    <div class="status-val"><span><%= totalAfterVoucher %></span><span>VND</span></div>
                </div>

                <div class="status-block">
                    <div class="status-label">Trạng thái hóa đơn</div>
                    <div class="status-val">
                        <%
                            if (proformaBill != null) {
                        %>
                        <span class="pill pill-proforma">PROFORMA / Đang chờ VNPay</span>
                        <%
                            if (proformaBill.billNo != null) {
                        %>
                        <span style="font-size:.7rem;font-weight:500;color:#64748b;">(#<%= proformaBill.billNo %>)</span>
                        <%
                            }
                        %>
                        <%
                            } else {
                                if (orders != null && !orders.isEmpty()) {
                        %>
                        <span class="pill pill-live">Đang phục vụ / Chưa tạo hóa đơn</span>
                        <%
                                } else {
                        %>
                        <span class="pill pill-final">Đã thanh toán</span>
                        <%
                                }
                            }
                        %>
                    </div>
                </div>

                <div class="status-block">
                    <div class="status-label">Có thể tiếp tục thu?</div>
                    <div class="status-val">
                        <%
                            if (canPayAgain) {
                        %>
                        <span class="pill pill-live">Có thể</span>
                        <%
                            } else {
                        %>
                        <span class="pill pill-final">Không</span>
                        <%
                            }
                        %>
                    </div>
                </div>
            </div>

            <div class="layout">

                <section class="col-left">
                    <div class="card">
                        <div class="card-header">
                            <div class="icon"><i class="bi bi-receipt"></i></div>
                            <div class="card-header-main">
                                <div class="card-title">Order đang mở của bàn #<%= tableIdSafe %></div>
                                <div class="card-desc">Liệt kê tất cả order chưa SETTLED. Khi chốt, các order này sẽ chuyển SETTLED.</div>
                            </div>
                        </div>
                        <div class="card-body" style="padding-top:8px;">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Mã order</th>
                                        <th>Phục vụ</th>
                                        <th>Mở lúc</th>
                                        <th>Trạng thái</th>
                                        <th>Tạm tính</th>
                                        <th>Thuế</th>
                                        <th>Giảm giá</th>
                                        <th>Tổng</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        if (orders != null && !orders.isEmpty()) {
                                            for (Order o : orders) {
                                                if (o == null) continue;
                                    %>
                                    <tr>
                                        <td><%= o.getOrderId() %></td>
                                        <td><span class="badge-order"><%= o.getOrderCode() %></span></td>
                                        <td><%= (o.getWaiterName() != null ? o.getWaiterName() : "") %></td>
                                        <td><%= o.getOpenedAt() %></td>
                                        <td><%= o.getStatus() %></td>
                                        <td><%= o.getSubtotal() %></td>
                                        <td><%= o.getTaxAmount() %></td>
                                        <td><%= o.getDiscountAmount() %></td>
                                        <td><strong><%= o.getTotalAmount() %></strong></td>
                                    </tr>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <tr>
                                        <td colspan="9" style="text-align:center;color:#64748b;padding:24px;">
                                            Không còn order mở. Có thể bàn đã tạo hóa đơn PROFORMA và chờ VNPay.
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="card mt16">
                        <div class="card-header">
                            <div class="icon"><i class="bi bi-calculator"></i></div>
                            <div class="card-header-main">
                                <div class="card-title">Tổng tiền bàn</div>
                                <div class="card-desc">Áp thuế 10%, giảm giá theo order và voucher.</div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="totals-wrap" id="totalsBox"
                                 data-subtotal="<%= subtotal %>"
                                 data-tax="<%= taxAmount %>"
                                 data-basediscount="<%= discountAmount %>">
                                <div class="totals-row">
                                    <div class="totals-label">Tạm tính</div>
                                    <div class="totals-value" id="row-subtotal"><%= subtotal %> đ</div>
                                </div>
                                <div class="totals-row">
                                    <div class="totals-label">Thuế (10%)</div>
                                    <div class="totals-value" id="row-tax"><%= taxAmount %> đ</div>
                                </div>
                                <div class="totals-row">
                                    <div class="totals-label">Giảm giá (order)</div>
                                    <div class="totals-value" id="row-basediscount"><%= discountAmount %> đ</div>
                                </div>
                                <div class="totals-row">
                                    <div class="totals-label">Giảm thêm voucher</div>
                                    <div class="totals-value text-save" id="row-voucherdiscount">- <%= voucherDiscount %> đ</div>
                                </div>
                                <div class="totals-row totals-sep">
                                    <div class="totals-label" style="color:#0f172a;font-weight:700;">TỔNG THU CUỐI</div>
                                    <div class="totals-value totals-grand" id="row-finaltotal"><%= totalAfterVoucher %> đ</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%
                        if (paymentsForBill != null && !paymentsForBill.isEmpty()) {
                    %>
                    <div class="card mt16">
                        <div class="card-header">
                            <div class="icon"><i class="bi bi-credit-card"></i></div>
                            <div class="card-header-main">
                                <div class="card-title">Các khoản thanh toán đã ghi nhận</div>
                                <div class="card-desc">“Thành công” = đã thu. “Đang chờ” = VNPay chưa hoàn tất. Có thể mở lại VNPay từ khoản “Đang chờ”.</div>
                            </div>
                        </div>
                        <div class="card-body" style="padding-top:8px;">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Phương thức</th>
                                        <th>Số tiền</th>
                                        <th>Trạng thái</th>
                                        <th>Thời điểm</th>
                                        <th>Ghi chú</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        for (PaymentInfo p : paymentsForBill) {
                                            if (p == null) continue;
                                    %>
                                    <tr>
                                        <td><%= p.paymentId %></td>
                                        <td>
                                            <%= (p.method != null ? p.method : "") %>
                                            <%
                                                if (p.provider != null && !p.provider.isEmpty()) {
                                            %>
                                            (<%= p.provider %>)
                                            <%
                                                }
                                            %>
                                        </td>
                                        <td><%= p.amount %></td>
                                        <td>
                                            <%
                                                if ("SUCCESS".equalsIgnoreCase(p.status)) {
                                            %>
                                            <span class="pay-success">Thành công</span>
                                            <%
                                                } else if ("PENDING".equalsIgnoreCase(p.status)) {
                                            %>
                                            <span class="pay-pending">Đang chờ</span>
                                            <%
                                                } else {
                                            %>
                                            <%= p.status %>
                                            <%
                                                }
                                            %>
                                        </td>
                                        <td><%= p.paidAt %></td>
                                        <td><%= (p.paidChannelNote != null ? p.paidChannelNote : "") %></td>
                                        <td>
                                            <%
                                                if ("PENDING".equalsIgnoreCase(p.status)) {
                                                    String reopenUrl = "/RMS/VnpayRedirectServlet?paymentId=" + p.paymentId;
                                            %>
                                            <a class="btn-small" href="<%= reopenUrl %>">
                                                <i class="bi bi-wallet2"></i>
                                                <span>Mở lại VNPay</span>
                                            </a>
                                            <%
                                                }
                                            %>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                            </table>

                            <%
                                if (pendingCount > 0) {
                            %>
                            <div class="alert-warn" style="margin-top:12px;">
                                <strong>Lưu ý:</strong> Có khoản VNPay đang chờ. Không cần tạo hóa đơn mới – bấm “Mở lại VNPay” để hoàn tất.
                            </div>
                            <%
                                } else {
                            %>
                            <div class="alert-ok" style="margin-top:12px;">
                                Tất cả khoản thanh toán cho hóa đơn gần nhất đều đã hoàn tất.
                            </div>
                            <%
                                }
                            %>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </section>

                <aside class="col-right">
                    <%
                        if (proformaBill != null) {
                    %>
                    <div class="card">
                        <div class="card-header">
                            <div class="icon"><i class="bi bi-cash-coin"></i></div>
                            <div class="card-header-main">
                                <div class="card-title">Đang chờ khách thanh toán VNPay</div>
                                <div class="card-desc">Hóa đơn đã snapshot &amp; bàn đã SETTLED.</div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="lock-box">
                                Đã tạo hóa đơn PROFORMA và có khoản PENDING. Khi VNPay báo thành công, hệ thống tự chuyển FINAL.
                            </div>

                            <%
                                if (firstPending != null) {
                                    String resumeUrl = "/RMS/VnpayRedirectServlet?paymentId=" + firstPending.paymentId;
                            %>
                            <div class="retry-box" style="margin-top:16px;">
                                <div style="font-weight:600;margin-bottom:6px;">VNPay đang ở trạng thái “Đang chờ”.</div>
                                <div style="margin-bottom:10px;">Nhấn nút bên dưới để mở lại trang thanh toán VNPay sandbox.</div>
                                <a class="btn-small" href="<%= resumeUrl %>">
                                    <i class="bi bi-wallet2"></i>
                                    <span>Mở lại VNPay</span>
                                </a>
                            </div>
                            <%
                                }
                            %>
                        </div>
                    </div>
                    <%
                        } else {
                    %>
                    <div class="card">
                        <div class="card-header">
                            <div class="icon"><i class="bi bi-cash-coin"></i></div>
                            <div class="card-header-main">
                                <div class="card-title">Xác nhận thanh toán &amp; đóng bàn</div>
                                <div class="card-desc">Chọn voucher, phương thức (TIỀN MẶT / VNPAY / TÁCH) và nhập tiền mặt.</div>
                            </div>
                        </div>

                        <div class="card-body">
                            <form class="pay-form" id="payForm" method="post" action="/RMS/PaymentServlet">
                                <input type="hidden" name="tableId" value="<%= tableIdSafe %>"/>

                                <div class="form-group">
                                    <label class="form-label">Chọn voucher / khuyến mãi</label>
                                    <select name="voucherId" id="voucherSelect" class="form-select">
                                        <option value="" data-type="NONE" data-val="0">-- Không áp dụng voucher --</option>
                                        <%
                                            for (Voucher v : vouchers) {
                                                if (v == null) continue;
                                                String disType = (v.getDiscountType() != null ? v.getDiscountType() : "");
                                                String disVal  = (v.getDiscountValue() != null ? v.getDiscountValue().toPlainString() : "0");
                                        %>
                                        <option value="<%= v.getVoucherId() %>"
                                                data-type="<%= disType %>"
                                                data-val="<%= disVal %>">
                                            <%= v.getCode() %> (<%= v.getDiscountValue() %><%= "PERCENT".equalsIgnoreCase(disType) ? "%" : "" %>)
                                        </option>
                                        <%
                                            }
                                        %>
                                    </select>
                                    <div class="form-hint">Voucher đang “ACTIVE” sẽ được ghi vào snapshot để đối soát cuối ca.</div>
                                </div>

                                <div class="form-group">
                                    <label class="form-label">Phương thức thanh toán</label>
                                    <select name="paymentMode" id="paymentMode" class="form-select">
                                        <option value="CASH">Chỉ TIỀN MẶT</option>
                                        <option value="VNPAY">Chỉ VNPAY</option>
                                        <option value="SPLIT">TÁCH: Tiền mặt + VNPAY</option>
                                    </select>
                                    <div class="form-hint">
                                        • “Chỉ TIỀN MẶT”: khách trả toàn bộ bằng tiền mặt.<br/>
                                        • “Chỉ VNPAY”: thanh toán toàn bộ qua VNPay sandbox.<br/>
                                        • “TÁCH”: khách đưa một phần tiền mặt, phần còn lại VNPay.
                                    </div>
                                </div>

                                <div class="form-group" id="cashBlock">
                                    <label class="form-label">Tiền khách đưa (VND)</label>
                                    <!-- type=text để tránh lỗi step/min của trình duyệt; lọc số bằng JS -->
                                    <input
                                        type="text"
                                        inputmode="numeric"
                                        pattern="[0-9]*"
                                        id="cashAmountInput"
                                        name="cashAmount"
                                        class="form-control"
                                        value="<%= totalAfterVoucher %>"/>
                                    <div class="field-error" id="cashError"></div>
                                    <div class="form-hint" id="cashHint">
                                        Tiền mặt phải khớp “Tổng thu cuối” nếu chọn “Chỉ TIỀN MẶT”.
                                    </div>
                                </div>

                                <button class="btn-submit" type="submit">XÁC NHẬN THANH TOÁN &amp; ĐÓNG BÀN</button>

                                <div class="footer-note">
                                    Tổng cần thu cuối (sau voucher):
                                    <strong id="footer-finaltotal"><%= totalAfterVoucher %></strong> đ
                                </div>
                            </form>

                            <div class="inline-hint" style="margin-top:16px;font-size:.7rem;line-height:1.4;color:#64748b;">
                                Hệ thống tạo snapshot hóa đơn. Nếu còn phần cần VNPay, hóa đơn ở trạng thái <strong>PROFORMA</strong> và tạo payment <strong>ĐANG CHỜ</strong>.
                                Khi VNPay báo thành công, hóa đơn tự chuyển <strong>FINAL</strong>.
                            </div>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </aside>
            </div>
        </div>

        <script>
            (function () {
                function toNumber(x) {
                    if (!x)
                        return 0;
                    return parseFloat(("" + x).replace(/[^0-9.-]/g, "")) || 0;
                }

                var totalsBox = document.getElementById("totalsBox");
                var voucherSelect = document.getElementById("voucherSelect");
                var rowVoucherDisc = document.getElementById("row-voucherdiscount");
                var rowFinalTotal = document.getElementById("row-finaltotal");
                var footerFinalTotal = document.getElementById("footer-finaltotal");

                var paymentModeSel = document.getElementById("paymentMode");
                var cashBlock = document.getElementById("cashBlock");
                var cashHint = document.getElementById("cashHint");
                var cashAmountInput = document.getElementById("cashAmountInput");
                var cashError = document.getElementById("cashError");
                var payForm = document.getElementById("payForm");

                if (totalsBox) {
                    var baseSubtotal = toNumber(totalsBox.dataset.subtotal);
                    var baseTax = toNumber(totalsBox.dataset.tax);
                    var baseDiscount = toNumber(totalsBox.dataset.basediscount);

                    var currentFinalTotal = toNumber("<%= totalAfterVoucher %>");

                    function setCashError(msg) {
                        if (!cashError || !cashAmountInput)
                            return;
                        if (msg) {
                            cashError.textContent = msg;
                            cashError.style.display = "block";
                            cashAmountInput.classList.add("input-error");
                            cashAmountInput.setAttribute("aria-invalid", "true");
                        } else {
                            cashError.textContent = "";
                            cashError.style.display = "none";
                            cashAmountInput.classList.remove("input-error");
                            cashAmountInput.setAttribute("aria-invalid", "false");
                        }
                    }

                    // lọc ký tự không phải số khi nhập
                    function sanitizeCash() {
                        if (!cashAmountInput)
                            return;
                        var raw = cashAmountInput.value || "";
                        var cleaned = raw.replace(/[^\d]/g, "");
                        if (raw !== cleaned)
                            cashAmountInput.value = cleaned;
                    }

                    function validateCash() {
                        if (!cashAmountInput || cashBlock.classList.contains("hidden")) {
                            setCashError("");
                            return true;
                        }
                        var mode = paymentModeSel ? paymentModeSel.value : "CASH";
                        var val = toNumber(cashAmountInput.value);

                        var err = "";
                        if (mode === "CASH") {
                            if (val !== Math.round(currentFinalTotal)) {
                                err = "Tiền mặt phải bằng Tổng thu cuối (" +
                                        Math.round(currentFinalTotal).toLocaleString('vi-VN') + " đ).";
                            }
                        } else if (mode === "SPLIT") {
                            if (val <= 0)
                                err = "Nhập số tiền khách đưa (> 0).";
                            if (val > currentFinalTotal)
                                err = "Không vượt quá Tổng thu cuối.";
                        }
                        setCashError(err);
                        return !err;
                    }

                    function recomputeTotalsWithVoucher() {
                        if (!voucherSelect)
                            return;
                        var opt = voucherSelect.options[voucherSelect.selectedIndex];
                        var discountType = (opt.getAttribute("data-type") || "").toUpperCase();
                        var discountVal = toNumber(opt.getAttribute("data-val"));

                        var voucherCut = 0;
                        if (discountType === "PERCENT") {
                            voucherCut = baseSubtotal * (discountVal / 100.0);
                        } else if (discountType !== "NONE") {
                            voucherCut = discountVal;
                        }
                        if (voucherCut < 0)
                            voucherCut = 0;

                        var finalDiscount = baseDiscount + voucherCut;
                        var finalTotal = baseSubtotal - finalDiscount + baseTax;
                        if (finalTotal < 0)
                            finalTotal = 0;
                        currentFinalTotal = finalTotal;

                        if (rowVoucherDisc)
                            rowVoucherDisc.textContent = "- " + voucherCut.toLocaleString('vi-VN') + " đ";
                        if (rowFinalTotal)
                            rowFinalTotal.textContent = finalTotal.toLocaleString('vi-VN') + " đ";
                        if (footerFinalTotal)
                            footerFinalTotal.textContent = finalTotal.toLocaleString('vi-VN') + " đ";

                        syncCashFieldWithMode();
                    }

                    function syncCashFieldWithMode() {
                        if (!paymentModeSel || !cashBlock || !cashHint || !cashAmountInput)
                            return;
                        var mode = paymentModeSel.value;

                        if (mode === "VNPAY") {
                            cashBlock.classList.add("hidden");
                            cashAmountInput.value = "";
                            setCashError("");
                        } else if (mode === "CASH") {
                            cashBlock.classList.remove("hidden");
                            cashHint.textContent = "CASH: nhập bằng đúng “Tổng thu cuối”.";
                            cashAmountInput.value = String(Math.round(currentFinalTotal));
                            setCashError("");
                        } else {
                            cashBlock.classList.remove("hidden");
                            cashHint.textContent = "TÁCH: nhập phần tiền mặt; phần còn lại sẽ thanh toán qua VNPay.";
                            // giữ nguyên giá trị người dùng đã nhập
                            validateCash();
                        }
                    }

                    if (voucherSelect)
                        voucherSelect.addEventListener("change", recomputeTotalsWithVoucher);
                    if (paymentModeSel)
                        paymentModeSel.addEventListener("change", syncCashFieldWithMode);
                    if (cashAmountInput) {
                        cashAmountInput.addEventListener("input", function () {
                            sanitizeCash();
                            validateCash();
                        });
                        cashAmountInput.addEventListener("blur", function () {
                            sanitizeCash();
                            validateCash();
                        });
                    }
                    if (payForm) {
                        payForm.addEventListener("submit", function (e) {
                            if (!validateCash()) {
                                e.preventDefault();
                                cashAmountInput && cashAmountInput.focus();
                            }
                        });
                    }

                    // khởi tạo
                    recomputeTotalsWithVoucher();
                    syncCashFieldWithMode();
                }
            })();
        </script>

    </body>
</html>
