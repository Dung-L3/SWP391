<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "revenue-report");
    request.setAttribute("overlayNav", false);
%>

<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Báo cáo Doanh thu | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>
    <style>
        :root {
            --bg-app:#f5f6fa;
            --accent:#FEA116;
            --brand:#4f46e5;
            --success:#16a34a;
            --warning:#f59e0b;
            --danger:#dc2626;
        }
        body {
            background: var(--bg-app);
            font-family: "Heebo", system-ui, sans-serif;
        }
        .app-shell {
            display: grid;
            grid-template-columns: 280px 1fr;
            min-height: 100vh;
        }
        main.main-pane {
            padding: 28px 32px 44px;
        }
        .report-card {
            background: white;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 16px;
        }
        .stat-card.success {
            background: linear-gradient(135deg, #16a34a 0%, #0f766e 100%);
        }
        .stat-card.warning {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }
        .stat-value {
            font-size: 2rem;
            font-weight: 600;
            margin: 8px 0;
        }
        .stat-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }
    </style>
</head>
<body>
<jsp:include page="/layouts/Header.jsp"/>

<div class="app-shell">
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <main class="main-pane">
        <header class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="mb-1"><i class="bi bi-graph-up-arrow text-primary me-2"></i>Báo cáo Doanh thu</h2>
                <p class="text-muted mb-0">Thống kê doanh thu theo ngày, ca, nhân viên và kênh thanh toán</p>
            </div>
        </header>

        <!-- Filters -->
        <div class="report-card">
            <h5 class="mb-3"><i class="bi bi-funnel me-2"></i>Bộ lọc</h5>
            <form method="GET" action="<c:url value='/revenue-report'/>" class="row g-3">
                <input type="hidden" name="action" value="summary"/>
                
                <div class="col-md-3">
                    <label class="form-label">Từ ngày</label>
                    <input type="date" name="fromDate" class="form-control" 
                           value="${fromDate != null ? fromDate : ''}" required>
                </div>
                
                <div class="col-md-3">
                    <label class="form-label">Đến ngày</label>
                    <input type="date" name="toDate" class="form-control" 
                           value="${toDate != null ? toDate : ''}" required>
                </div>
                
                <div class="col-md-2">
                    <label class="form-label">Nhân viên</label>
                    <select name="staffId" class="form-select">
                        <option value="">Tất cả</option>
                        <c:forEach var="staff" items="${staffList}">
                            <option value="${staff.userId}" ${selectedStaffId == staff.userId ? 'selected' : ''}>
                                ${staff.firstName} ${staff.lastName}
                            </option>
                        </c:forEach>
                    </select>
                </div>
                
                <div class="col-md-2">
                    <label class="form-label">Kênh thanh toán</label>
                    <select name="paymentMethod" class="form-select">
                        <option value="">Tất cả</option>
                        <option value="CASH" ${selectedPaymentMethod == 'CASH' ? 'selected' : ''}>Tiền mặt</option>
                        <option value="CARD" ${selectedPaymentMethod == 'CARD' ? 'selected' : ''}>Thẻ</option>
                        <option value="ONLINE" ${selectedPaymentMethod == 'ONLINE' ? 'selected' : ''}>Online</option>
                        <option value="TRANSFER" ${selectedPaymentMethod == 'TRANSFER' ? 'selected' : ''}>Chuyển khoản</option>
                        <option value="VOUCHER" ${selectedPaymentMethod == 'VOUCHER' ? 'selected' : ''}>Voucher</option>
                    </select>
                </div>
                
                <div class="col-md-2">
                    <label class="form-label">Loại đơn</label>
                    <select name="orderType" class="form-select">
                        <option value="">Tất cả</option>
                        <option value="DINE_IN" ${selectedOrderType == 'DINE_IN' ? 'selected' : ''}>Tại bàn</option>
                        <option value="TAKEAWAY" ${selectedOrderType == 'TAKEAWAY' ? 'selected' : ''}>Mang đi</option>
                    </select>
                </div>
                
                <div class="col-12">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-search me-2"></i>Lọc
                    </button>
                    <a href="<c:url value='/revenue-report'/>" class="btn btn-secondary ms-2">
                        <i class="bi bi-arrow-clockwise me-2"></i>Reset
                    </a>
                </div>
            </form>
        </div>

        <!-- Summary Report -->
        <c:if test="${not empty summary}">
            <div class="report-card">
                <h5 class="mb-4"><i class="bi bi-bar-chart me-2"></i>Tổng quan</h5>
                
                <div class="row">
                    <div class="col-md-3">
                        <div class="stat-card success">
                            <div class="stat-label">Tổng doanh thu</div>
                            <div class="stat-value">
                                <fmt:formatNumber value="${summary.totalRevenue}" pattern="#,##0" type="currency" currencySymbol="₫"/>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-label">Tổng đơn hàng</div>
                            <div class="stat-value">${summary.totalOrders}</div>
                        </div>
                    </div>
                    
                    <div class="col-md-3">
                        <div class="stat-card warning">
                            <div class="stat-label">Tổng tiền trước thuế</div>
                            <div class="stat-value">
                                <fmt:formatNumber value="${summary.totalSubtotal}" pattern="#,##0" type="currency" currencySymbol="₫"/>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-label">Thuế VAT</div>
                            <div class="stat-value">
                                <fmt:formatNumber value="${summary.totalTax}" pattern="#,##0" type="currency" currencySymbol="₫"/>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Revenue by Channel -->
                <h6 class="mt-4 mb-3">Doanh thu theo kênh thanh toán</h6>
                <div class="row">
                    <div class="col-md-2">
                        <div class="text-center p-3 bg-light rounded">
                            <div class="text-muted small">Tiền mặt</div>
                            <div class="fw-bold text-success">
                                <fmt:formatNumber value="${summary.cashRevenue}" pattern="#,##0" type="currency" currencySymbol="₫"/>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="text-center p-3 bg-light rounded">
                            <div class="text-muted small">Thẻ</div>
                            <div class="fw-bold text-primary">
                                <fmt:formatNumber value="${summary.cardRevenue}" pattern="#,##0" type="currency" currencySymbol="₫"/>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="text-center p-3 bg-light rounded">
                            <div class="text-muted small">Online</div>
                            <div class="fw-bold text-info">
                                <fmt:formatNumber value="${summary.onlineRevenue}" pattern="#,##0" type="currency" currencySymbol="₫"/>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="text-center p-3 bg-light rounded">
                            <div class="text-muted small">Chuyển khoản</div>
                            <div class="fw-bold text-warning">
                                <fmt:formatNumber value="${summary.transferRevenue}" pattern="#,##0" type="currency" currencySymbol="₫"/>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="text-center p-3 bg-light rounded">
                            <div class="text-muted small">Voucher</div>
                            <div class="fw-bold text-danger">
                                <fmt:formatNumber value="${summary.voucherRevenue}" pattern="#,##0" type="currency" currencySymbol="₫"/>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Revenue by Staff -->
        <c:if test="${not empty reports}">
            <div class="report-card">
                <h5 class="mb-4"><i class="bi bi-people me-2"></i>Doanh thu theo nhân viên</h5>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Nhân viên</th>
                                <th>Số đơn</th>
                                <th>Doanh thu</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="rpt" items="${reports}">
                                <tr>
                                    <td>${rpt.staffName}</td>
                                    <td>${rpt.ordersByStaff}</td>
                                    <td class="fw-bold text-success">
                                        <fmt:formatNumber value="${rpt.revenueByStaff}" pattern="#,##0" type="currency" currencySymbol="₫"/>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>
    </main>
</div>

<script src="<c:url value='/js/bootstrap.bundle.min.js'/>"></script>
</body>
</html>

