<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>In hóa đơn | RMSG4 Restaurant</title>

    <style>
        :root {
            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;

            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.12);
            --accent-border:rgba(254,161,22,.45);

            --line:#e5e7eb;
        }

        @page {
            size: 80mm auto;
            margin: 5mm;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            padding: 0;
            min-height: 100vh;
            background: #020617;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            font-family: -apple-system, BlinkMacSystemFont, system-ui, "Segoe UI", Roboto, sans-serif;
        }

        .receipt-shell {
            width: 100%;
            max-width: 80mm;
            padding: 12px 0;
            display: flex;
            justify-content: center;
        }

        .receipt {
            width: 72mm;
            background: #ffffff;
            border-radius: 10px;
            padding: 6px;
            box-shadow:
                0 16px 40px rgba(0, 0, 0, 0.6),
                0 0 0 1px rgba(15, 23, 42, 0.06);
            color: var(--ink-900);
            position: relative;
            overflow: hidden;
        }

        /* khung chính như form hóa đơn */
        .receipt-frame {
            position: relative;
            border: 1px solid #9ca3af;
            border-radius: 6px;
            padding: 6px 6px 8px;
            min-height: 100%;
        }

        .receipt-frame::before,
        .receipt-frame::after {
            content: "";
            position: absolute;
            inset: 3px;
            border-radius: 4px;
            border: 1px dashed rgba(148,163,184,.6);
            pointer-events: none;
        }

        /* logo watermark */
        .receipt-watermark {
            position: absolute;
            top: 52%;
            left: 50%;
            width: 64mm;
            transform: translate(-50%, -50%);
            opacity: 0.09;
            pointer-events: none;
            user-select: none;
            mix-blend-mode: multiply;
        }

        .brand-block {
            text-align: center;
            margin-bottom: 4px;
        }

        .brand-name {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.14em;
            text-transform: uppercase;
            color: #111827;
        }

        .brand-tagline {
            font-size: 8px;
            letter-spacing: 0.22em;
            text-transform: uppercase;
            color: #9ca3af;
            margin-top: 1px;
        }

        .brand-meta {
            margin-top: 3px;
            font-size: 8px;
            line-height: 1.4;
            color: #6b7280;
        }

        .brand-divider {
            border-top: 1px solid #d4d4d8;
            margin: 4px 0 3px;
        }

        .title-block {
            text-align: center;
            padding: 2px 0 4px;
            margin-bottom: 4px;
            border-bottom: 1px solid #d4d4d8;
        }

        .title-main {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .16em;
        }

        .title-sub {
            margin-top: 2px;
            font-size: 8px;
            color: #6b7280;
        }

        .title-sub .value {
            font-weight: 600;
            color: #111827;
        }

        /* vùng thông tin đầu hóa đơn */
        .info-section {
            font-size: 8px;
            color: #374151;
            margin-top: 4px;
            padding-bottom: 4px;
            border-bottom: 1px solid #e5e7eb;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            gap: 4px;
            margin-bottom: 2px;
        }

        .info-row-left,
        .info-row-right {
            flex: 1;
            display: flex;
            gap: 3px;
        }

        .info-label {
            white-space: nowrap;
            color: #6b7280;
        }

        .info-value-line {
            flex: 1;
            border-bottom: 1px dotted #cbd5f5;
            margin-top: 3px;
            position: relative;
            min-height: 10px;
        }

        .info-value-line span {
            position: absolute;
            left: 0;
            top: -3px;
            font-weight: 600;
            color: #111827;
        }

        /* bảng món */
        .items-section {
            margin-top: 4px;
        }

        .items {
            width: 100%;
            border-collapse: collapse;
            font-size: 8px;
        }

        .items thead th {
            padding: 3px 0;
            border-bottom: 1px solid #9ca3af;
            font-weight: 600;
            color: #374151;
            text-transform: uppercase;
        }

        .items tbody td {
            padding: 1px 0;
            vertical-align: top;
            border-bottom: 1px dotted #e5e7eb;
        }

        .col-name { text-align: left; }
        .col-qty { text-align: center; width: 13%; }
        .col-price,
        .col-amount { text-align: right; width: 22%; }

        .item-name {
            font-weight: 500;
            color: #111827;
        }

        /* tổng tiền */
        .totals-section {
            margin-top: 4px;
            padding-top: 2px;
            border-top: 1px solid #d4d4d8;
        }

        .totals {
            width: 100%;
            font-size: 8px;
        }

        .totals tr td {
            padding: 1px 0;
        }

        .totals .label {
            text-align: right;
            color: #4b5563;
        }

        .totals .value {
            text-align: right;
            width: 32%;
            font-weight: 600;
            color: #111827;
        }

        .totals .grand-label {
            font-weight: 700;
            color: #111827;
        }

        .totals .grand-value {
            font-weight: 800;
            font-size: 10px;
            color: #111827;
        }

        .status-chip {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 1px 6px;
            border-radius: 999px;
            font-size: 7px;
            text-transform: uppercase;
            letter-spacing: .11em;
        }
        .status-final {
            background: rgba(34,197,94,.12);
            border: 1px solid rgba(34,197,94,.7);
            color: #166534;
        }
        .status-proforma {
            background: #e5e7eb;
            border: 1px solid #cbd5f5;
            color: #4b5563;
        }
        .status-void {
            background: rgba(248,113,113,.12);
            border: 1px solid rgba(248,113,113,.7);
            color: #b91c1c;
        }

        .confirm-line {
            margin-top: 3px;
            font-size: 8px;
            color: #6b7280;
        }
        .confirm-line strong { color: #111827; }

        /* khối chữ ký + dấu đỏ bên phải */
        .bottom-section {
            margin-top: 8px;
            display: flex;
            justify-content: flex-end;
        }

        .signature-block {
            position: relative;
            text-align: right;
            font-size: 8px;
            min-width: 40mm;
        }

        .signature-title {
            color: #6b7280;
            margin-bottom: 16px;
        }

        .signature-line {
            border-bottom: 1px solid #9ca3af;
            width: 100%;
            height: 18px;
        }

        .signature-name {
            margin-top: 3px;
            font-size: 8px;
            font-style: italic;
            color: #111827;
        }

        .paid-stamp {
            position: absolute;
            left: 0;
            top: -6px;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            border: 2px solid rgba(220,38,38,0.9);
            color: rgba(185,28,28,0.95);
            font-size: 7px;
            font-weight: 700;
            text-transform: uppercase;
            display: flex;
            align-items: center;
            justify-content: center;
            transform: rotate(-18deg);
            background: rgba(254,242,242,0.9);
        }

        .footer {
            margin-top: 6px;
            text-align: center;
            font-size: 8px;
            line-height: 1.5;
            color: #6b7280;
        }

        .footer strong {
            font-weight: 700;
            color: #111827;
        }

        .footer-highlight {
            margin-top: 2px;
            font-size: 7px;
            text-transform: uppercase;
            letter-spacing: 0.16em;
            color: #9ca3af;
        }

        .no-print {
            margin-top: 8px;
            text-align: center;
        }

        .no-print button {
            padding: 6px 10px;
            margin: 0 4px;
            font-size: 9px;
            border-radius: 999px;
            border: 1px solid #e5e7eb;
            background: #f9fafb;
            color: #111827;
            cursor: pointer;
        }

        .no-print button.primary {
            background: #0f172a;
            color: #facc15;
            border-color: #0f172a;
        }

        .no-print button:active {
            transform: translateY(1px);
        }

        @media print {
            body {
                background: #ffffff;
            }
            .receipt-shell {
                padding: 0;
            }
            .receipt {
                box-shadow: none;
                border-radius: 0;
            }
            .no-print {
                display: none;
            }
        }
    </style>

    <script>
        window.onload = function () {
            window.print();
        };
    </script>
</head>
<body>
<div class="receipt-shell">
    <div class="receipt">
        <div class="receipt-frame">

            <!-- logo watermark -->
            <img class="receipt-watermark"
                 src="<c:url value='/img/RMSG4 (1).png'/>"
                 alt="RMSG4 POS 5★"/>

            <!-- header thương hiệu -->
            <div class="brand-block">
                <div class="brand-name">RMSG4 RESTAURANT</div>
                <div class="brand-tagline">FINE DINING &amp; LOUNGE</div>
                <div class="brand-meta">
                    Đối diện Đại Học FPT Hà Nội – Điện thoại: 0906645965
                </div>
                <div class="brand-divider"></div>
            </div>

            <!-- tiêu đề hóa đơn -->
            <div class="title-block">
                <div class="title-main">
                    <c:choose>
                        <c:when test="${summary.status eq 'PROFORMA'}">HÓA ĐƠN TẠM TÍNH</c:when>
                        <c:otherwise>HÓA ĐƠN THANH TOÁN</c:otherwise>
                    </c:choose>
                </div>
                <div class="title-sub">
                    Số hóa đơn: <span class="value">${summary.billNo}</span>
                </div>
            </div>

            <!-- thông tin đầu hóa đơn -->
            <div class="info-section">
                <div class="info-row">
                    <div class="info-row-left">
                        <span class="info-label">Bàn:</span>
                        <div class="info-value-line">
                            <span>
                                <c:choose>
                                    <c:when test="${not empty summary.tableId}">
                                        Bàn ${summary.tableId}
                                    </c:when>
                                    <c:otherwise>Không xác định</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>

                    <div class="info-row-right">
                        <span class="info-label">Trạng thái:</span>
                        <div class="info-value-line">
                            <span>
                                <c:choose>
                                    <c:when test="${summary.status eq 'FINAL'}">
                                        <span class="status-chip status-final">ĐÃ THANH TOÁN</span>
                                    </c:when>
                                    <c:when test="${summary.status eq 'PROFORMA'}">
                                        <span class="status-chip status-proforma">TẠM TÍNH</span>
                                    </c:when>
                                    <c:when test="${summary.status eq 'VOID'}">
                                        <span class="status-chip status-void">ĐÃ HỦY</span>
                                    </c:when>
                                    <c:otherwise>${summary.status}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </div>

                <div class="info-row">
                    <div class="info-row-left">
                        <span class="info-label">Ngày tạo:</span>
                        <div class="info-value-line">
                            <span>
                                <fmt:formatDate value="${summary.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </span>
                        </div>
                    </div>

                    <div class="info-row-right">
                        <span class="info-label">Thuế VAT:</span>
                        <div class="info-value-line">
                            <span>
                                <c:choose>
                                    <c:when test="${summary.vatRate ne null}">
                                        <fmt:formatNumber value="${summary.vatRate}" pattern="#,##0"/>%
                                    </c:when>
                                    <c:otherwise>0%</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty summary.voucherCode}">
                    <div class="info-row">
                        <div class="info-row-left">
                            <span class="info-label">Voucher:</span>
                            <div class="info-value-line">
                                <span>${summary.voucherCode}</span>
                            </div>
                        </div>
                        <div class="info-row-right"></div>
                    </div>
                </c:if>
            </div>

            <!-- bảng món -->
            <div class="items-section">
                <table class="items">
                    <thead>
                    <tr>
                        <th class="col-name">Món</th>
                        <th class="col-qty">SL</th>
                        <th class="col-price">Đơn giá</th>
                        <th class="col-amount">Thành tiền</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="l" items="${lines}">
                        <tr>
                            <td class="col-name">
                                <div class="item-name">
                                    <c:choose>
                                        <c:when test="${not empty l.itemName}">
                                            ${l.itemName}
                                        </c:when>
                                        <c:otherwise>Món #${l.menuItemId}</c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td class="col-qty">${l.quantity}</td>
                            <td class="col-price">
                                <fmt:formatNumber value="${l.unitPrice}" type="number" pattern="#,##0"/> đ
                            </td>
                            <td class="col-amount">
                                <fmt:formatNumber value="${l.lineTotal}" type="number" pattern="#,##0"/> đ
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- tổng tiền -->
            <div class="totals-section">
                <table class="totals">
                    <tr>
                        <td class="label">Tổng cộng:</td>
                        <td class="value">
                            <fmt:formatNumber value="${summary.subtotal}" type="number" pattern="#,##0"/> đ
                        </td>
                    </tr>

                    <c:if test="${summary.discountAmount ne null && summary.discountAmount ne 0}">
                        <tr>
                            <td class="label">Giảm giá:</td>
                            <td class="value">
                                <fmt:formatNumber value="${summary.discountAmount}" type="number" pattern="#,##0"/> đ
                            </td>
                        </tr>
                    </c:if>

                    <c:if test="${summary.taxAmount ne null && summary.taxAmount ne 0}">
                        <tr>
                            <td class="label">Thuế VAT:</td>
                            <td class="value">
                                <fmt:formatNumber value="${summary.taxAmount}" type="number" pattern="#,##0"/> đ
                            </td>
                        </tr>
                    </c:if>

                    <tr>
                        <td class="label grand-label">Khách phải thanh toán:</td>
                        <td class="value grand-value">
                            <fmt:formatNumber value="${summary.totalAmount}" type="number" pattern="#,##0"/> đ
                        </td>
                    </tr>
                </table>

                <!-- dòng xác nhận thanh toán -->
                <c:if test="${summary.status eq 'FINAL'}">
                    <div class="confirm-line">
                        <strong>Đã thanh toán</strong>
                        lúc
                        <strong>
                            <fmt:formatDate value="${summary.createdAt}" pattern="HH:mm dd/MM/yyyy"/>
                        </strong>
                        – Thu ngân:
                        <strong>
                            <c:choose>
                                <c:when test="${not empty summary.cashierName}">
                                    ${summary.cashierName}
                                </c:when>
                                <c:otherwise>Nguyễn A</c:otherwise>
                            </c:choose>
                        </strong>
                    </div>
                </c:if>
            </div>

            <!-- chữ ký + dấu đỏ -->
            <div class="bottom-section">
                <div class="signature-block">
                    <div class="signature-title">Xác nhận thanh toán</div>
                    <div class="paid-stamp">PAID</div>
                    <div class="signature-line"></div>
                    <div class="signature-name">
                        <c:choose>
                            <c:when test="${not empty summary.cashierName}">
                                ${summary.cashierName}
                            </c:when>
                            <c:otherwise>Nguyễn A</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- footer -->
            <div class="footer">
                <strong>RMSG4 Restaurant xin chân thành cảm ơn Quý khách.</strong><br>
                Rất hân hạnh được phục vụ Quý khách trong những lần tiếp theo.
                <div class="footer-highlight">
                    HÓA ĐƠN KHÔNG CÓ GIÁ TRỊ KHẤU TRỪ THUẾ
                </div>
            </div>

            <div class="no-print">
                <button class="primary" onclick="window.print()">In lại hóa đơn</button>
                <button onclick="window.close()">Đóng</button>
            </div>
        </div>
    </div>
</div>
</body>
</html>
