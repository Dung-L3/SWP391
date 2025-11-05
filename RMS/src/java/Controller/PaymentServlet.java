package Controller;

import Dal.BillDAO;
import Dal.BillDAO.BillSummary;
import Dal.OrderDAO;
import Dal.OrderDAO.CombinedBillSummary;
import Dal.PaymentDAO;
import Dal.PaymentDAO.PaymentInfo;
import Dal.VoucherDAO;
import Dal.DBConnect;
import Models.Order;
import Models.Voucher;
import Utils.VnpayService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/PaymentServlet"})
public class PaymentServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final BillDAO billDAO = new BillDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();

    // =========================
    // GET: hiển thị màn hình thanh toán
    // =========================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String rawTableId = req.getParameter("tableId");
        if (rawTableId == null || rawTableId.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tableId");
            return;
        }

        int tableId;
        try {
            tableId = Integer.parseInt(rawTableId);
        } catch (NumberFormatException ex) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "tableId không hợp lệ");
            return;
        }

        try {
            List<Order> openOrders = orderDAO.getUnsettledOrdersByTableId(tableId);
            CombinedBillSummary combined = openOrders.isEmpty() ? null : orderDAO.buildCombinedBillForTable(tableId);
            BillSummary proformaBill = billDAO.findOpenBillForTable(tableId);

            List<PaymentInfo> paymentsForBill = new ArrayList<>();
            boolean canPayAgain = true;
            if (proformaBill != null) {
                paymentsForBill = paymentDAO.listPaymentsForBill(proformaBill.billId);
                boolean hasPending = paymentsForBill.stream()
                        .anyMatch(p -> p != null && "PENDING".equalsIgnoreCase(p.status));
                canPayAgain = !hasPending;
            } else if (openOrders.isEmpty()) {
                canPayAgain = false;
            }

            List<Voucher> vouchers = voucherDAO.getVouchers(1, 50, null, "ACTIVE", null);

            BigDecimal subtotal = BigDecimal.ZERO;
            BigDecimal taxAmount = BigDecimal.ZERO;
            BigDecimal baseDiscount = BigDecimal.ZERO;
            BigDecimal totalAmount = BigDecimal.ZERO;

            if (combined != null) {
                subtotal = nz(combined.getSubtotal());
                taxAmount = nz(combined.getTaxAmount());
                baseDiscount = nz(combined.getDiscountAmount());
                totalAmount = nz(combined.getTotalAmount());
            }

            req.setAttribute("tableId", tableId);
            req.setAttribute("orders", openOrders);
            req.setAttribute("proformaBill", proformaBill);
            req.setAttribute("paymentsForBill", paymentsForBill);
            req.setAttribute("canPayAgain", canPayAgain);
            req.setAttribute("vouchers", vouchers);
            req.setAttribute("summarySubtotal", subtotal);
            req.setAttribute("summaryTax", taxAmount);
            req.setAttribute("summaryBaseDiscount", baseDiscount);
            req.setAttribute("summaryTotal", totalAmount);
            req.setAttribute("voucherDiscount", BigDecimal.ZERO);
            req.setAttribute("totalAfterVoucher", totalAmount);

            req.getRequestDispatcher("/views/Payment.jsp").forward(req, resp);

        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi DB khi load PaymentServlet.doGet");
        }
    }

    // =========================
    // POST: chốt bill và tạo payment
    // =========================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String rawTableId = req.getParameter("tableId");
        String rawVoucherId = req.getParameter("voucherId");
        String paymentMode = req.getParameter("paymentMode");
        String rawCashPaid = req.getParameter("cashAmount");

        if (rawTableId == null || rawTableId.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tableId");
            return;
        }

        int tableId;
        try {
            tableId = Integer.parseInt(rawTableId);
        } catch (NumberFormatException ex) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "tableId không hợp lệ");
            return;
        }

        Integer voucherId = null;
        if (rawVoucherId != null && !rawVoucherId.isBlank()) {
            try {
                voucherId = Integer.parseInt(rawVoucherId);
            } catch (NumberFormatException ignore) {
            }
        }

        BigDecimal cashPaid = BigDecimal.ZERO;
        if (rawCashPaid != null && !rawCashPaid.isBlank()) {
            try {
                cashPaid = new BigDecimal(rawCashPaid);
            } catch (NumberFormatException ignore) {
            }
        }

        int cashierUserId = 3;

        String billStatusAfterCommit = null;
        String billNoAfterCommit = null;
        BigDecimal finalTotalAfterCommit = BigDecimal.ZERO;
        Long pendingPaymentIdAfterCommit = null;
        BigDecimal pendingVnpayAmountAfterCommit = BigDecimal.ZERO;

        try (Connection tx = DBConnect.getConnection()) {
            try {
                tx.setAutoCommit(false);

                CombinedBillSummary combined = orderDAO.buildCombinedBillForTable(tableId);
                BigDecimal subTotal = nz(combined.getSubtotal());
                BigDecimal taxAmount = nz(combined.getTaxAmount());
                BigDecimal baseDiscount = nz(combined.getDiscountAmount());
                BigDecimal totalAmount = nz(combined.getTotalAmount());

                String voucherCode = null;
                BigDecimal voucherCut = BigDecimal.ZERO;
                if (voucherId != null) {
                    Voucher v = voucherDAO.getVoucherById(voucherId);
                    if (v != null && "ACTIVE".equalsIgnoreCase(v.getStatus())) {
                        voucherCode = v.getCode();
                        voucherCut = voucherDAO.calculateDiscount(v, subTotal).max(BigDecimal.ZERO);
                    }
                }

                BigDecimal finalDiscount = baseDiscount.add(voucherCut);
                BigDecimal finalTotal = subTotal.subtract(finalDiscount).add(taxAmount).max(BigDecimal.ZERO);

                String billStatus;
                if ("CASH".equalsIgnoreCase(paymentMode)) {
                    billStatus = "FINAL";
                } else if ("VNPAY".equalsIgnoreCase(paymentMode)) {
                    billStatus = "PROFORMA";
                } else {
                    billStatus = cashPaid.compareTo(finalTotal) >= 0 ? "FINAL" : "PROFORMA";
                }

                String billNo = "BILL-" + System.currentTimeMillis() + "-" + tableId;

                Long billId = billDAO.createBill(tx, null, tableId, billNo, billStatus,
                        subTotal, finalDiscount, taxAmount, finalTotal,
                        new BigDecimal("10.00"), cashierUserId, voucherId, voucherCode);
                if (billId == null) {
                    throw new SQLException("Không tạo được bill snapshot");
                }

                for (Order o : combined.getOrders()) {
                    billDAO.insertBillItems(tx, billId, orderDAO.getOrderItems(o.getOrderId()));
                }

                if ("CASH".equalsIgnoreCase(paymentMode)) {
                    paymentDAO.createPayment(tx, billId, null, "CASH", finalTotal, null,
                            PaymentDAO.STATUS_SUCCESS, cashierUserId, "Tiền mặt tại bàn #" + tableId);
                } else if ("VNPAY".equalsIgnoreCase(paymentMode)) {
                    Long pid = paymentDAO.createPayment(tx, billId, null, "VNPAY", finalTotal, "VNPAY",
                            PaymentDAO.STATUS_PENDING, cashierUserId, "Thanh toán QR VNPAY bàn #" + tableId);
                    pendingPaymentIdAfterCommit = pid;
                    pendingVnpayAmountAfterCommit = finalTotal;
                } else {
                    BigDecimal remain = finalTotal.subtract(cashPaid).max(BigDecimal.ZERO);
                    if (cashPaid.compareTo(BigDecimal.ZERO) > 0) {
                        paymentDAO.createPayment(tx, billId, null, "CASH", cashPaid, null,
                                PaymentDAO.STATUS_SUCCESS, cashierUserId, "Split - tiền mặt bàn #" + tableId);
                    }
                    if (remain.compareTo(BigDecimal.ZERO) > 0) {
                        Long pid = paymentDAO.createPayment(tx, billId, null, "VNPAY", remain, "VNPAY",
                                PaymentDAO.STATUS_PENDING, cashierUserId, "Split - VNPAY bàn #" + tableId);
                        pendingPaymentIdAfterCommit = pid;
                        pendingVnpayAmountAfterCommit = remain;
                    }
                }

                for (Order o : combined.getOrders()) {
                    orderDAO.closeOrderInTx(tx, o.getOrderId());
                }

                billStatusAfterCommit = billStatus;
                billNoAfterCommit = billNo;
                finalTotalAfterCommit = finalTotal;

                tx.commit();
            } catch (Exception ex) {
                tx.rollback();
                ex.printStackTrace();
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi chốt bill / tạo payment");
                return;
            } finally {
                try {
                    tx.setAutoCommit(true);
                } catch (SQLException ignore) {
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không mở được kết nối DB");
            return;
        }

        // Sau commit
        if ("FINAL".equalsIgnoreCase(billStatusAfterCommit)) {
            req.setAttribute("uiStatus", "OK");
            req.setAttribute("billNo", billNoAfterCommit);
            req.setAttribute("paidAmount", finalTotalAfterCommit.toString());
            req.setAttribute("method", paymentMode);
            req.setAttribute("reasonText", "Thanh toán hoàn tất. Bàn đã được đóng.");
            req.getRequestDispatcher("/views/PaymentSuccess.jsp").forward(req, resp);
            return;
        }

        if (pendingPaymentIdAfterCommit != null
                && pendingVnpayAmountAfterCommit != null
                && pendingVnpayAmountAfterCommit.compareTo(BigDecimal.ZERO) > 0) {
            String redirectUrl = VnpayService.buildPaymentUrl(
                    pendingPaymentIdAfterCommit, pendingVnpayAmountAfterCommit, req.getRemoteAddr());
            resp.sendRedirect(redirectUrl);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/PaymentServlet?tableId=" + rawTableId);
    }

    private BigDecimal nz(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}
