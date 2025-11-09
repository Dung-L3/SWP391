<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    request.setAttribute("page", "stock-transactions");
    request.setAttribute("overlayNav", false);
%>

<c:if test="${empty sessionScope.user}">
    <c:redirect url="/LoginServlet"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Giao dịch Kho | RMSG4</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Favicon -->
    <link href="<c:url value='/img/favicon.ico'/>" rel="icon"/>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Heebo:wght@400;500;600&display=swap" rel="stylesheet"/>

    <!-- Icons / Bootstrap -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet"/>
    <link href="<c:url value='/css/bootstrap.min.css'/>" rel="stylesheet"/>

    <!-- Base site styles -->
    <link href="<c:url value='/css/style.css'/>" rel="stylesheet"/>

    <style>
        :root {
            --bg-app:#f5f6fa;
            --bg-grad-1:rgba(88,80,200,.08);
            --bg-grad-2:rgba(254,161,22,.06);
            --ink-900:#0f172a;
            --ink-700:#334155;
            --ink-500:#64748b;
            --ink-400:#94a3b8;
            --accent:#FEA116;
            --accent-soft:rgba(254,161,22,.12);
            --brand:#4f46e5;
            --success:#16a34a;
            --warning:#f59e0b;
            --danger:#dc2626;
            --line:#e5e7eb;
            --radius-lg:20px;
            --radius-md:12px;
            --radius-sm:6px;
            --sidebar-width:280px;
        }

        body{
            background:
                radial-gradient(1000px 600px at 8% 0%, var(--bg-grad-1) 0%, transparent 60%),
                radial-gradient(800px 500px at 100% 0%, var(--bg-grad-2) 0%, transparent 60%),
                var(--bg-app);
            color:var(--ink-900);
            font-family:"Heebo", system-ui, -apple-system, BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",sans-serif;
        }

        .app-shell{
            display:grid;
            grid-template-columns:var(--sidebar-width) 1fr;
            min-height:100vh;
        }
        @media(max-width:992px){
            .app-shell{grid-template-columns:1fr;}
            #sidebar{
                position:fixed;inset:0 30% 0 0;transform:translateX(-100%);
                transition:transform .2s ease;z-index:1040;max-width:var(--sidebar-width);
                box-shadow:24px 0 60px rgba(0,0,0,.7);background:#1f2535;
            }
            #sidebar.open{transform:translateX(0);}
        }

        main.main-pane{padding:28px 32px 44px;}

        .pos-topbar{
            background:linear-gradient(135deg,#1b1e2c 0%,#2b2f46 60%,#1c1f30 100%);
            border-radius:var(--radius-md);border:1px solid rgba(255,255,255,.07);
            box-shadow:0 32px 64px rgba(0,0,0,.6);color:#fff;padding:16px 20px;
            margin-top:58px;margin-bottom:24px;
            display:flex;flex-wrap:wrap;justify-content:space-between;align-items:flex-start;
        }

        .pos-left .title-row{
            display:flex;align-items:center;gap:.6rem;
            font-weight:600;font-size:1rem;line-height:1.35;color:#fff;
        }
        .pos-left .title-row i{color:var(--accent);font-size:1.1rem;}
        .pos-left .sub{margin-top:4px;font-size:.8rem;color:var(--ink-400);}

        .pos-right{display:flex;align-items:center;flex-wrap:wrap;gap:.75rem;color:#fff;}

        .user-chip{
            display:flex;align-items:center;gap:.5rem;
            background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.18);
            border-radius:var(--radius-md);padding:6px 10px;
            font-size:.8rem;font-weight:500;line-height:1.2;color:#fff;
        }
        .user-chip .role-badge{
            background:var(--accent);color:#1e1e2f;border-radius:var(--radius-sm);
            padding:2px 6px;font-size:.7rem;font-weight:600;line-height:1.2;
        }

        .filters-card{
            position:relative;background:linear-gradient(to bottom right,#ffffff 0%,#fafaff 80%);
            border:1px solid rgba(99,102,241,.25);border-top:4px solid var(--accent);
            border-radius:var(--radius-lg);box-shadow:0 10px 40px rgba(0,0,0,.08);
            padding:1rem 1.25rem 1.25rem;margin-bottom:1.5rem;transition:all .25s ease;
        }

        .result-bar{
            display:flex;flex-wrap:wrap;justify-content:space-between;
            align-items:flex-start;row-gap:.75rem;margin-bottom:1.5rem;
        }
        .result-left{font-size:.9rem;font-weight:500;color:var(--ink-900);}

        .btn-action-group{
            display:flex;gap:.5rem;flex-wrap:wrap;
        }

        .btn-txn{
            font-weight:600;border:none;border-radius:var(--radius-sm);
            display:inline-flex;align-items:center;gap:.5rem;padding:.5rem .75rem;
            box-shadow:0 4px 20px rgba(0,0,0,.15);
        }
        .btn-txn:hover{transform:translateY(-1px);box-shadow:0 6px 25px rgba(0,0,0,.2);}
        .btn-txn-in{background:linear-gradient(135deg,#16a34a,#0f766e);color:#fff;}
        .btn-txn-out{background:linear-gradient(135deg,#dc2626,#b91c1c);color:#fff;}
        .btn-txn-adjust{background:linear-gradient(135deg,#f59e0b,#d97706);color:#fff;}

        .transaction-table{width:100%;background:#fff;border-radius:var(--radius-md);overflow:hidden;}
        .transaction-table thead{background:linear-gradient(135deg,#4f46e5,#6366f1);color:#fff;}
        .transaction-table th{padding:.75rem 1rem;font-size:.85rem;font-weight:600;}
        .transaction-table td{padding:.75rem 1rem;font-size:.85rem;border-bottom:1px solid var(--line);}
        .transaction-table tbody tr:hover{background:#f9fafb;}

        .txn-type-badge{
            font-size:.7rem;font-weight:600;padding:.3rem .5rem;
            border-radius:var(--radius-sm);white-space:nowrap;
        }
        .txn-type-IN{background:#dcfce7;color:#166534;}
        .txn-type-OUT{background:#fee2e2;color:#991b1b;}
        .txn-type-USAGE{background:#fef3c7;color:#92400e;}
        .txn-type-WASTE{background:#fce7f3;color:#9f1239;}
        .txn-type-ADJUSTMENT{background:#dbeafe;color:#1e40af;}
        .txn-type-RETURN{background:#e0e7ff;color:#3730a3;}

        .quantity-positive{color:var(--success);font-weight:600;}
        .quantity-negative{color:var(--danger);font-weight:600;}
    </style>
</head>

<body>
<jsp:include page="/layouts/Header.jsp"/>

<div class="app-shell">
    <aside id="sidebar">
        <jsp:include page="/layouts/sidebar.jsp"/>
    </aside>

    <main class="main-pane">
        <header class="pos-topbar">
            <div class="pos-left">
                <div class="title-row">
                    <i class="bi bi-arrow-left-right"></i>
                    <span>Giao dịch Kho</span>
                </div>
                <div class="sub">
                    Nhập kho · Xuất kho · Điều chỉnh · Kiểm kê
                </div>
            </div>

            <div class="pos-right">
                <div class="user-chip">
                    <i class="bi bi-person-badge"></i>
                    <span>${sessionScope.user.fullName}</span>
                    <span class="role-badge">${sessionScope.user.roleName}</span>
                </div>
            </div>
        </header>

        <!-- FLASH MESSAGE -->
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

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- FILTERS -->
        <section class="filters-card">
            <form method="GET" action="${pageContext.request.contextPath}/stock-transactions" class="row g-3">
                <div class="col-md-3">
                    <label for="itemId" class="form-label">Nguyên liệu</label>
                    <select class="form-select" id="itemId" name="itemId">
                        <option value="">Tất cả nguyên liệu</option>
                        <c:forEach var="item" items="${inventoryItems}">
                            <option value="${item.itemId}" <c:if test="${itemIdParam == item.itemId}">selected</c:if>>${item.itemName}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-2">
                    <label for="txnType" class="form-label">Loại giao dịch</label>
                    <select class="form-select" id="txnType" name="txnType">
                        <option value="">Tất cả</option>
                        <option value="IN" <c:if test="${txnTypeParam == 'IN'}">selected</c:if>>Nhập kho</option>
                        <option value="USAGE" <c:if test="${txnTypeParam == 'USAGE'}">selected</c:if>>Sử dụng</option>
                        <option value="WASTE" <c:if test="${txnTypeParam == 'WASTE'}">selected</c:if>>Hao hụt</option>
                        <option value="ADJUSTMENT" <c:if test="${txnTypeParam == 'ADJUSTMENT'}">selected</c:if>>Điều chỉnh</option>
                        <option value="RETURN" <c:if test="${txnTypeParam == 'RETURN'}">selected</c:if>>Trả hàng</option>
                    </select>
                </div>

                <div class="col-md-2">
                    <label for="fromDate" class="form-label">Từ ngày</label>
                    <input type="date" class="form-control" id="fromDate" name="fromDate" value="${fromDateParam}">
                </div>

                <div class="col-md-2">
                    <label for="toDate" class="form-label">Đến ngày</label>
                    <input type="date" class="form-control" id="toDate" name="toDate" value="${toDateParam}">
                </div>

                <div class="col-md-3 d-flex align-items-end gap-2">
                    <button type="submit" class="btn btn-primary flex-grow-1">
                        <i class="bi bi-funnel"></i> Lọc
                    </button>
                    <a href="${pageContext.request.contextPath}/stock-transactions" class="btn btn-outline-secondary">
                        <i class="bi bi-x-circle"></i>
                    </a>
                </div>
            </form>
        </section>

        <!-- RESULT BAR -->
        <section class="result-bar">
            <div class="result-left">
                <span>Tìm thấy ${fn:length(transactions)} giao dịch</span>
            </div>

            <div class="result-right">
                <c:if test="${sessionScope.user.roleName eq 'Manager'}">
                    <div class="btn-action-group">
                        <a href="${pageContext.request.contextPath}/stock-transactions?action=create&type=IN" class="btn-txn btn-txn-in">
                            <i class="bi bi-box-arrow-in-down"></i>
                            <span>Nhập kho</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/stock-transactions?action=create-batch&type=IN" class="btn-txn btn-txn-in" style="background:linear-gradient(135deg,#059669,#047857);">
                            <i class="bi bi-boxes"></i>
                            <span>Nhập nhiều</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/stock-transactions?action=create&type=ADJUSTMENT" class="btn-txn btn-txn-adjust">
                            <i class="bi bi-sliders"></i>
                            <span>Điều chỉnh</span>
                        </a>
                    </div>
                </c:if>
            </div>
        </section>

        <!-- TRANSACTION TABLE -->
        <div class="table-responsive">
            <table class="transaction-table table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Thời gian</th>
                        <th>Nguyên liệu</th>
                        <th>Loại</th>
                        <th>Số lượng</th>
                        <th>Đơn giá</th>
                        <th>Tham chiếu</th>
                        <th>Ghi chú</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty transactions}">
                            <tr>
                                <td colspan="8" class="text-center py-4 text-muted">
                                    <i class="bi bi-inbox" style="font-size:2rem;opacity:.3;"></i>
                                    <p class="mt-2 mb-0">Chưa có giao dịch nào</p>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="txn" items="${transactions}">
                                <tr>
                                    <td>#${txn.stockTxnId}</td>
                                    <td>
                                        <fmt:formatDate value="${txn.txnTimeAsDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td>
                                        <strong>${txn.itemName}</strong>
                                        <c:if test="${not empty txn.uom}">
                                            <span class="text-muted small">(${txn.uom})</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <span class="txn-type-badge txn-type-${txn.txnType}">
                                            <c:choose>
                                                <c:when test="${txn.txnType == 'IN'}">Nhập kho</c:when>
                                                <c:when test="${txn.txnType == 'OUT'}">Xuất kho</c:when>
                                                <c:when test="${txn.txnType == 'USAGE'}">Sử dụng</c:when>
                                                <c:when test="${txn.txnType == 'WASTE'}">Hao hụt</c:when>
                                                <c:when test="${txn.txnType == 'ADJUSTMENT'}">Điều chỉnh</c:when>
                                                <c:when test="${txn.txnType == 'RETURN'}">Trả hàng</c:when>
                                                <c:otherwise>${txn.txnType}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${txn.quantity != null && txn.txnType == 'ADJUSTMENT' && txn.quantity < 0}">
                                                <span class="quantity-negative">
                                                    <fmt:formatNumber value="${txn.quantity}" pattern="#,##0.000"/>
                                                </span>
                                            </c:when>
                                            <c:when test="${txn.quantity != null && (txn.txnType == 'OUT' || txn.txnType == 'USAGE' || txn.txnType == 'WASTE')}">
                                                <span class="quantity-negative">
                                                    -<fmt:formatNumber value="${txn.quantity}" pattern="#,##0.000"/>
                                                </span>
                                            </c:when>
                                            <c:when test="${txn.quantity != null}">
                                                <span class="quantity-positive">
                                                    +<fmt:formatNumber value="${txn.quantity}" pattern="#,##0.000"/>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">-</span>
                                            </c:otherwise>
                                        </c:choose>
                                        <c:if test="${not empty txn.uom}">
                                            <span class="text-muted small"> ${txn.uom}</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${txn.unitCost != null && txn.unitCost > 0}">
                                                <fmt:formatNumber value="${txn.unitCost}" pattern="#,##0" type="currency" currencySymbol="₫"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">-</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${not empty txn.refType}">
                                            <span class="badge bg-secondary">${txn.refType}</span>
                                            <c:if test="${txn.refId != null}">
                                                <span class="text-muted small">#${txn.refId}</span>
                                            </c:if>
                                        </c:if>
                                        <c:if test="${empty txn.refType}">
                                            <span class="text-muted">-</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:if test="${not empty txn.note}">
                                            <span class="text-muted small">${txn.note}</span>
                                        </c:if>
                                        <c:if test="${empty txn.note}">
                                            <span class="text-muted">-</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </main>
</div>

<script src="<c:url value='/js/bootstrap.bundle.min.js'/>"></script>
</body>
</html>

