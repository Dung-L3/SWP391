package Controller;

import Dal.TableDAO;
import Dal.OrderDAO;
import Dal.BillDAO;
import Dal.PaymentDAO;
import Dal.BillDAO.BillSummary;
import Dal.PaymentDAO.PaymentInfo;
import Models.DiningTable;
import Models.Order;
import Models.OrderItem;
import Models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/reception"})
public class ReceptionServlet extends HttpServlet {

    private final TableDAO tableDAO = new TableDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final BillDAO billDAO = new BillDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("user");
    }

    private boolean canAccessReception(User u) {
        if (u == null) {
            return false;
        }
        String role = u.getRoleName();
        return "Manager".equals(role) || "Receptionist".equals(role);
    }

    // Xác định payState khi còn order chưa SETTLED
    private String derivePayStateForTable(List<Order> unsettledOrders, List<OrderItem> allItems) {
        if (unsettledOrders == null || unsettledOrders.isEmpty()) {
            return "FREE";
        }

        for (Order o : unsettledOrders) {
            if (Order.STATUS_SETTLED.equalsIgnoreCase(o.getStatus())) {
                continue;
            }
            for (OrderItem it : allItems) {
                if (!it.getOrderId().equals(o.getOrderId())) {
                    continue;
                }
                String st = it.getStatus();
                if ("CANCELLED".equalsIgnoreCase(st)) {
                    continue;
                }
                if (!"SERVED".equalsIgnoreCase(st)) {
                    return "DINING";
                }
            }
        }
        return "READY_TO_PAY";
    }

    // View model cho JSP
    public static class ReceptionTableView {

        private Integer tableId;
        private String tableNumber;
        private Integer capacity;
        private String areaName;
        private String tableStatus;

        private Long sessionId;
        private java.time.LocalDateTime sessionOpenTime;

        private Long orderId;
        private String orderStatus;
        private java.time.LocalDateTime orderOpenedAt;
        private String waiterName;

        private int openOrderCount;
        private BigDecimal totalAmountPending;

        // FREE / DINING / READY_TO_PAY / PENDING_VNPAY
        private String payState;
        private boolean canPayAgain;

        public Integer getTableId() {
            return tableId;
        }

        public void setTableId(Integer tableId) {
            this.tableId = tableId;
        }

        public String getTableNumber() {
            return tableNumber;
        }

        public void setTableNumber(String tableNumber) {
            this.tableNumber = tableNumber;
        }

        public Integer getCapacity() {
            return capacity;
        }

        public void setCapacity(Integer capacity) {
            this.capacity = capacity;
        }

        public String getAreaName() {
            return areaName;
        }

        public void setAreaName(String areaName) {
            this.areaName = areaName;
        }

        public String getTableStatus() {
            return tableStatus;
        }

        public void setTableStatus(String tableStatus) {
            this.tableStatus = tableStatus;
        }

        public Long getSessionId() {
            return sessionId;
        }

        public void setSessionId(Long sessionId) {
            this.sessionId = sessionId;
        }

        public java.time.LocalDateTime getSessionOpenTime() {
            return sessionOpenTime;
        }

        public void setSessionOpenTime(java.time.LocalDateTime sessionOpenTime) {
            this.sessionOpenTime = sessionOpenTime;
        }

        public Long getOrderId() {
            return orderId;
        }

        public void setOrderId(Long orderId) {
            this.orderId = orderId;
        }

        public String getOrderStatus() {
            return orderStatus;
        }

        public void setOrderStatus(String orderStatus) {
            this.orderStatus = orderStatus;
        }

        public java.time.LocalDateTime getOrderOpenedAt() {
            return orderOpenedAt;
        }

        public void setOrderOpenedAt(java.time.LocalDateTime orderOpenedAt) {
            this.orderOpenedAt = orderOpenedAt;
        }

        public String getWaiterName() {
            return waiterName;
        }

        public void setWaiterName(String waiterName) {
            this.waiterName = waiterName;
        }

        public int getOpenOrderCount() {
            return openOrderCount;
        }

        public void setOpenOrderCount(int openOrderCount) {
            this.openOrderCount = openOrderCount;
        }

        public BigDecimal getTotalAmountPending() {
            return totalAmountPending;
        }

        public void setTotalAmountPending(BigDecimal totalAmountPending) {
            this.totalAmountPending = totalAmountPending;
        }

        public String getPayState() {
            return payState;
        }

        public void setPayState(String payState) {
            this.payState = payState;
        }

        public boolean isCanPayAgain() {
            return canPayAgain;
        }

        public void setCanPayAgain(boolean canPayAgain) {
            this.canPayAgain = canPayAgain;
        }
    }

    // GET: trang lễ tân/thu ngân
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // AuthN + AuthZ
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }
        if (!canAccessReception(currentUser)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập Quầy lễ tân / Thu ngân.");
            return;
        }

        // Filter theo khu vực (nếu có)
        Integer areaId = null;
        String areaParam = req.getParameter("areaId");
        if (areaParam != null && !areaParam.isBlank()) {
            try {
                areaId = Integer.parseInt(areaParam);
            } catch (NumberFormatException ignore) {
            }
        }

        // Build view
        List<DiningTable> tables = tableDAO.getDiningTablesByArea(areaId);
        List<ReceptionTableView> viewList = new ArrayList<>();

        for (DiningTable t : tables) {
            ReceptionTableView v = new ReceptionTableView();

            v.setTableId(t.getTableId());
            v.setTableNumber(t.getTableNumber());
            v.setCapacity(t.getCapacity());
            v.setTableStatus(t.getStatus());
            v.setAreaName(t.getAreaName());
            v.setSessionId(t.getCurrentSessionId());
            v.setSessionOpenTime(t.getSessionOpenTime());

            try {
                List<Order> unsettledOrders = orderDAO.getUnsettledOrdersByTableId(t.getTableId());
                v.setOpenOrderCount(unsettledOrders.size());

                v.setOrderId(null);
                v.setOrderStatus(null);
                v.setOrderOpenedAt(null);
                v.setWaiterName(null);
                v.setTotalAmountPending(BigDecimal.ZERO);
                v.setCanPayAgain(false);
                v.setPayState("FREE");

                if (!unsettledOrders.isEmpty()) {
                    // Còn order mở
                    Order rep = unsettledOrders.get(0);
                    v.setOrderId(rep.getOrderId());
                    v.setOrderStatus(rep.getStatus());
                    v.setOrderOpenedAt(rep.getOpenedAt());
                    v.setWaiterName(rep.getWaiterName());

                    OrderDAO.CombinedBillSummary combined = orderDAO.buildCombinedBillForTable(t.getTableId());
                    if (combined != null && combined.getTotalAmount() != null) {
                        v.setTotalAmountPending(combined.getTotalAmount());
                    }

                    List<OrderItem> allItems = new ArrayList<>();
                    for (Order o : unsettledOrders) {
                        try {
                            allItems.addAll(orderDAO.getOrderItems(o.getOrderId()));
                        } catch (SQLException loadItemsEx) {
                            System.err.println("[ReceptionServlet] Lỗi load items order "
                                    + o.getOrderId() + ": " + loadItemsEx.getMessage());
                        }
                    }

                    String stateByFood = derivePayStateForTable(unsettledOrders, allItems);
                    v.setPayState(stateByFood);

                    if ("READY_TO_PAY".equals(stateByFood)) {
                        v.setCanPayAgain(true);
                    } else {
                        boolean hasAnyServed = false;
                        for (OrderItem it : allItems) {
                            if ("SERVED".equalsIgnoreCase(it.getStatus())) {
                                hasAnyServed = true;
                                break;
                            }
                        }
                        v.setCanPayAgain(hasAnyServed);
                    }

                } else {
                    // Không còn order mở: kiểm tra bill PROFORMA đang chờ VNPay
                    BillSummary openBill = billDAO.findOpenBillForTable(t.getTableId());
                    if (openBill != null) {
                        Long billId = openBill.billId;
                        List<PaymentInfo> payList = paymentDAO.listPaymentsForBill(billId);

                        BigDecimal pendingTotal = BigDecimal.ZERO;
                        if (payList != null) {
                            for (PaymentInfo pinfo : payList) {
                                boolean isVnpayLike
                                        = "ONLINE".equalsIgnoreCase(pinfo.method)
                                        || "VNPAY".equalsIgnoreCase(pinfo.method)
                                        || "VNPAY".equalsIgnoreCase(pinfo.provider)
                                        || "VNPay".equalsIgnoreCase(pinfo.provider);

                                if ("PENDING".equalsIgnoreCase(pinfo.status) && isVnpayLike && pinfo.amount != null) {
                                    pendingTotal = pendingTotal.add(pinfo.amount);
                                }
                            }
                        }

                        if (pendingTotal.compareTo(BigDecimal.ZERO) > 0) {
                            v.setPayState("PENDING_VNPAY");
                            v.setCanPayAgain(true);
                            v.setTotalAmountPending(openBill.totalAmount);
                        } else {
                            v.setPayState("FREE");
                            v.setCanPayAgain(false);
                            v.setTotalAmountPending(BigDecimal.ZERO);
                        }
                    } else {
                        v.setPayState("FREE");
                        v.setCanPayAgain(false);
                        v.setTotalAmountPending(BigDecimal.ZERO);
                    }
                }

            } catch (SQLException ex) {
                System.err.println("[ReceptionServlet] Lỗi xử lý bàn " + t.getTableNumber() + ": " + ex.getMessage());
                v.setOrderId(null);
                v.setOrderStatus(null);
                v.setOrderOpenedAt(null);
                v.setWaiterName(null);
                v.setOpenOrderCount(0);
                v.setTotalAmountPending(BigDecimal.ZERO);
                v.setPayState("FREE");
                v.setCanPayAgain(false);
            }

            viewList.add(v);
        }

        // Bind & render
        req.setAttribute("tables", viewList);
        req.setAttribute("areas", tableDAO.getAllAreas());
        req.setAttribute("selectedAreaId", areaId);
        req.setAttribute("user", currentUser);
        req.setAttribute("page", "reception");
        req.getRequestDispatcher("/views/reception.jsp").forward(req, resp);
    }
}
