package Controller;

import Dal.OrderDAO;
import Dal.KitchenDAO;
import Dal.MenuDAO;
import Models.KitchenTicket;
import Models.Order;
import Models.OrderItem;
import Models.MenuItem;
import Models.User;
import Utils.RoleBasedRedirect;
import Utils.PricingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;

/**
 * Quản lý vòng đời order và món:
 *  - Tạo order
 *  - Thêm món (tính giá động)
 *  - Gửi order xuống bếp
 *  - Đánh dấu món SERVED
 *  - API xem order / món READY để bưng ra
 *
 * URL:
 *   GET  /orders
 *   GET  /orders/{orderId}
 *   GET  /orders/ready?tableId=...
 *
 *   POST /orders
 *   POST /orders/{orderId}/items
 *   POST /orders/{orderId}/send-to-kitchen       (chưa dùng nhiều vì ta tạo ticket từng món luôn)
 *   POST /orders/items/{itemId}/serve
 *   POST /orders/{itemId}/serve                  (fallback)
 */
@WebServlet(name = "OrderServlet", urlPatterns = {"/orders", "/orders/*"})
public class OrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final KitchenDAO kitchenDAO = new KitchenDAO();
    private final MenuDAO menuDAO = new MenuDAO();
    private final PricingService pricingService = new PricingService();

    // ===== AUTH HELPERS =====
    private User requireLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return null;
        }
        return user;
    }

    private boolean hasOrderPermission(User u) {
        return RoleBasedRedirect.hasAnyPermission(u, "Waiter", "Manager", "Supervisor");
    }

    // ===== HTTP GET =====
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = requireLogin(request, response);
        if (user == null) return;

        if (!hasOrderPermission(user)) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }

        String pathInfo = request.getPathInfo();

        if (pathInfo == null || "/".equals(pathInfo)) {
            // GET /orders
            getOrders(request, response);
            return;
        }

        if (pathInfo.matches("/\\d+")) {
            // GET /orders/{id}
            String orderIdStr = pathInfo.substring(1);
            try {
                Long orderId = Long.parseLong(orderIdStr);
                getOrder(request, response, orderId);
            } catch (NumberFormatException ex) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID");
            }
            return;
        }

        if (pathInfo.equals("/ready")) {
            // GET /orders/ready?tableId=...
            getReadyItems(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Not found");
    }

    // ===== HTTP POST =====
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = requireLogin(request, response);
        if (user == null) return;

        if (!hasOrderPermission(user)) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }

        String pathInfo = request.getPathInfo();

        // POST /orders -> tạo order mới
        if (pathInfo == null || "/".equals(pathInfo)) {
            createOrder(request, response, user);
            return;
        }

        // POST /orders/items/{itemId}/serve
        if (pathInfo.matches("/items/\\d+/serve")) {
            String itemIdStr = pathInfo.substring(pathInfo.lastIndexOf('/') + 1);
            try {
                Long itemId = Long.parseLong(itemIdStr);
                markItemAsServed(request, response, itemId, user);
            } catch (NumberFormatException ex) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid item ID: " + itemIdStr);
            }
            return;
        }

        // POST /orders/{orderId}/items
        if (pathInfo.matches("/\\d+/items")) {
            String orderIdStr = pathInfo.substring(1, pathInfo.lastIndexOf('/'));
            try {
                Long orderId = Long.parseLong(orderIdStr);
                addOrderItem(request, response, orderId, user);
            } catch (NumberFormatException ex) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID");
            }
            return;
        }

        // POST /orders/{orderId}/send-to-kitchen (optional batch send)
        if (pathInfo.matches("/\\d+/send-to-kitchen")) {
            String orderIdStr = pathInfo.substring(1, pathInfo.lastIndexOf('/'));
            try {
                Long orderId = Long.parseLong(orderIdStr);
                sendToKitchen(request, response, orderId, user);
            } catch (NumberFormatException ex) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID");
            }
            return;
        }

        // fallback: POST /orders/{itemId}/serve
        if (pathInfo.matches("/\\d+/serve")) {
            String itemIdStr = pathInfo.substring(1, pathInfo.indexOf("/serve"));
            try {
                Long itemId = Long.parseLong(itemIdStr);
                markItemAsServed(request, response, itemId, user);
            } catch (NumberFormatException ex) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid item ID: " + itemIdStr);
            }
            return;
        }

        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Not found: " + pathInfo);
    }

    // ===== GET HELPERS =====
    /**
     * GET /orders
     * Hiện tại chỉ trả placeholder rỗng.
     * (Có thể mở rộng sau: liệt kê order OPEN theo bàn, vv.)
     */
    private void getOrders(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"orders\":[]}");
    }

    /**
     * GET /orders/ready?tableId=...
     * Trả về các món đã xong bếp (READY) và chưa bưng ra (served_at IS NULL),
     * để nhân viên phục vụ biết mang ra.
     */
    private void getReadyItems(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String tableIdStr = request.getParameter("tableId");
            if (tableIdStr == null || tableIdStr.isBlank()) {
                out.print("{\"error\":\"Table ID is required\"}");
                return;
            }

            Integer tableId = Integer.parseInt(tableIdStr);
            List<OrderItem> readyItems = orderDAO.getReadyItemsForTable(tableId);

            StringBuilder json = new StringBuilder();
            json.append("{\"readyItems\":[");
            for (int i = 0; i < readyItems.size(); i++) {
                OrderItem item = readyItems.get(i);
                if (i > 0) json.append(",");

                json.append("{");
                json.append("\"orderItemId\":").append(item.getOrderItemId()).append(",");
                json.append("\"menuItemName\":\"").append(safe(item.getMenuItemName())).append("\",");
                json.append("\"quantity\":").append(item.getQuantity()).append(",");
                json.append("\"tableNumber\":\"").append(safe(item.getTableNumber())).append("\"");
                json.append("}");
            }
            json.append("]}");

            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + safe(e.getMessage()) + "\"}");
        }
    }

    /**
     * GET /orders/{orderId}
     * Trả JSON chi tiết 1 order (gồm danh sách món).
     */
    private void getOrder(HttpServletRequest request, HttpServletResponse response, Long orderId)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                out.print("{\"error\":\"Order not found\"}");
                return;
            }

            List<OrderItem> items = orderDAO.getOrderItems(orderId);
            order.setOrderItems(items);

            StringBuilder json = new StringBuilder();
            json.append("{");

            json.append("\"orderId\":").append(order.getOrderId()).append(",");
            json.append("\"orderType\":\"").append(safe(order.getOrderType())).append("\",");
            json.append("\"tableId\":").append(order.getTableId()).append(",");
            json.append("\"tableNumber\":\"").append(safe(order.getTableNumber())).append("\",");
            json.append("\"waiterId\":").append(order.getWaiterId()).append(",");
            json.append("\"waiterName\":\"").append(safe(order.getWaiterName())).append("\",");

            json.append("\"status\":\"").append(safe(order.getStatus())).append("\",");

            json.append("\"subtotal\":").append(nz(order.getSubtotal())).append(",");
            json.append("\"taxAmount\":").append(nz(order.getTaxAmount())).append(",");
            json.append("\"discountAmount\":").append(nz(order.getDiscountAmount())).append(",");
            json.append("\"totalAmount\":").append(nz(order.getTotalAmount())).append(",");

            json.append("\"specialInstructions\":\"").append(safe(order.getSpecialInstructions())).append("\",");

            json.append("\"openedAt\":\"").append(order.getOpenedAt()).append("\",");

            json.append("\"items\":[");
            for (int i = 0; i < items.size(); i++) {
                OrderItem item = items.get(i);
                if (i > 0) json.append(",");

                json.append("{");
                json.append("\"orderItemId\":").append(item.getOrderItemId()).append(",");
                json.append("\"menuItemId\":").append(item.getMenuItemId()).append(",");
                json.append("\"menuItemName\":\"").append(safe(item.getMenuItemName())).append("\",");
                json.append("\"quantity\":").append(item.getQuantity()).append(",");
                json.append("\"specialInstructions\":\"").append(safe(item.getSpecialInstructions())).append("\",");
                json.append("\"priority\":\"").append(safe(item.getPriority())).append("\",");
                json.append("\"course\":\"").append(safe(item.getCourse())).append("\",");

                json.append("\"baseUnitPrice\":").append(nz(item.getBaseUnitPrice())).append(",");
                json.append("\"finalUnitPrice\":").append(nz(item.getFinalUnitPrice())).append(",");
                json.append("\"totalPrice\":").append(nz(item.getTotalPrice())).append(",");

                json.append("\"status\":\"").append(safe(item.getStatus())).append("\"");
                json.append("}");
            }
            json.append("]");

            json.append("}");

            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + safe(e.getMessage()) + "\"}");
        }
    }

    // ===== POST HELPERS =====

    /**
     * POST /orders
     * - Tạo order mới cho 1 bàn
     * - Ghi chú chung của order (notes)
     * - Gán waiterId từ session user
     * - Mặc định trạng thái order = DINING (khách đang ăn)
     *
     * ReceptionServlet sẽ đọc các order CHƯA SETTLED để tính payState:
     *   + Nếu còn món chưa SERVED -> DINING
     *   + Nếu toàn bộ món đã SERVED -> READY_TO_PAY
     */
    private void createOrder(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String tableIdStr = request.getParameter("tableId");
            if (tableIdStr == null || tableIdStr.isBlank()) {
                out.print("{\"error\":\"Table ID is required\"}");
                return;
            }
            Integer tableId = Integer.parseInt(tableIdStr);

            String orderType = request.getParameter("orderType");
            if (orderType == null || orderType.isBlank()) {
                orderType = Order.TYPE_DINE_IN;
            }

            String orderNotes = request.getParameter("notes");

            Order order = new Order(orderType, tableId, user.getUserId());
            order.setSpecialInstructions(orderNotes);

            // Khi mới tạo, set trạng thái là OPEN (theo DB constraint)
            // (order đang mở, waiter có thể thêm món)
            order.setStatus(Order.STATUS_OPEN);

            Long orderId = orderDAO.createOrder(order);
            if (orderId == null) {
                out.print("{\"error\":\"Failed to create order\"}");
                return;
            }

            out.print("{\"success\":true,\"orderId\":" + orderId + "}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + safe(e.getMessage()) + "\"}");
        }
    }

    /**
     * POST /orders/{orderId}/items
     *
     * - Lấy menu item -> base_price
     * - Tính finalUnitPrice qua PricingService (giá động / khuyến mãi)
     * - Thêm vào order_items (status = NEW)
     * - Tạo KitchenTicket (status = RECEIVED) => bếp thấy ngay
     * - Recalculate tổng bill của order
     *
     * Sau đó ReceptionServlet sẽ thấy bàn ở trạng thái DINING,
     * vì có món NEW/SENT/... chưa SERVED.
     */
    private void addOrderItem(HttpServletRequest request, HttpServletResponse response, Long orderId, User user)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Integer menuItemId = Integer.parseInt(request.getParameter("menuItemId"));
            Integer quantity   = Integer.parseInt(request.getParameter("quantity"));

            String specialInstructions = request.getParameter("specialInstructions");
            String priority = request.getParameter("priority");
            String course   = request.getParameter("course");

            if (priority == null || priority.isBlank()) {
                priority = OrderItem.PRIORITY_NORMAL;
            }
            if (course == null || course.isBlank()) {
                course = OrderItem.COURSE_MAIN;
            }

            // lấy menuItem từ DB
            MenuItem menuItem = menuDAO.getMenuItemById(menuItemId);
            if (menuItem == null) {
                out.print("{\"error\":\"Menu item not found\"}");
                return;
            }
            
            // Check if menu item is active (not suspended)
            if (!menuItem.isActive()) {
                out.print("{\"error\":\"Món này hiện đang tạm ngưng bán. Vui lòng chọn món khác.\"}");
                return;
            }

            BigDecimal basePrice = menuItem.getBasePrice() != null
                    ? menuItem.getBasePrice()
                    : BigDecimal.ZERO;

            BigDecimal effectivePrice = pricingService.getCurrentPrice(menuItem);
            if (effectivePrice == null) effectivePrice = basePrice;

            // build OrderItem
            OrderItem oi = new OrderItem(orderId, menuItemId, quantity);
            oi.setSpecialInstructions(specialInstructions);
            oi.setPriority(priority);
            oi.setCourse(course);
            oi.setBaseUnitPrice(basePrice);
            oi.setFinalUnitPrice(effectivePrice);
            oi.setStatus(OrderItem.STATUS_NEW);

            Long orderItemId = orderDAO.addOrderItem(oi);
            if (orderItemId == null) {
                out.print("{\"error\":\"Failed to add item to order\"}");
                return;
            }

            // Tạo ticket bếp
            KitchenTicket ticket = new KitchenTicket();
            ticket.setOrderItemId(orderItemId);
            ticket.setStation(determineStation(oi)); // ví dụ "HOT"
            ticket.setPreparationStatus(KitchenTicket.STATUS_RECEIVED);
            ticket.setChefId(null);
            Long ticketId = kitchenDAO.createKitchenTicket(ticket);

            // cập nhật tổng tiền order
            orderDAO.recalculateOrderTotals(orderId);

            out.print("{\"success\":true,"
                    + "\"orderItemId\":" + orderItemId + ","
                    + "\"ticketId\":" + (ticketId != null ? ticketId : "null") + ","
                    + "\"basePrice\":" + basePrice + ","
                    + "\"finalPrice\":" + effectivePrice + "}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + safe(e.getMessage()) + "\"}");
        }
    }

    /**
     * POST /orders/{orderId}/send-to-kitchen
     *
     * Batch-mode: mọi item status=NEW sẽ tạo ticket & chuyển SENT,
     * order -> COOKING.
     *
     * (Hiện tại luồng thêm món ở addOrderItem() đã tạo ticket luôn,
     * nên hàm này ít dùng, nhưng mình giữ nguyên để không gãy code.)
     */
    private void sendToKitchen(HttpServletRequest request, HttpServletResponse response, Long orderId, User user)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            List<OrderItem> items = orderDAO.getOrderItems(orderId);
            int sentCount = 0;

            for (OrderItem it : items) {
                if (OrderItem.STATUS_NEW.equals(it.getStatus())) {
                    // tạo ticket
                    KitchenTicket ticket = new KitchenTicket(it.getOrderItemId(), determineStation(it));
                    ticket.setEstimatedMinutes(it.getPreparationTime());
                    ticket.setChefId(null);
                    ticket.setPreparationStatus(KitchenTicket.STATUS_RECEIVED);
                    kitchenDAO.createKitchenTicket(ticket);

                    // đổi item -> SENT
                    it.setStatus(OrderItem.STATUS_SENT);
                    orderDAO.updateOrderItemBasic(it);
                    sentCount++;
                }
            }

            // order -> COOKING
            orderDAO.updateOrderStatus(orderId, Order.STATUS_COOKING);

            out.print("{\"success\":true,\"sentCount\":" + sentCount + "}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + safe(e.getMessage()) + "\"}");
        }
    }

    /**
     * POST /orders/items/{itemId}/serve
     * hoặc fallback POST /orders/{itemId}/serve
     *
     * Đánh dấu 1 món đã SERVED:
     *   - order_items.status = 'SERVED', served_by = user_id, served_at = NOW
     *   - kitchen_tickets.status -> SERVED
     *   - nếu tất cả món trong order đều SERVED => orders.status = 'SERVED'
     *
     * Sau đó ReceptionServlet sẽ tính:
     *   - nếu tất cả món của tất cả order của bàn đều SERVED,
     *     payState = READY_TO_PAY  => giao diện lễ tân hiện "Chờ thanh toán".
     */
    private void markItemAsServed(HttpServletRequest request, HttpServletResponse response, Long itemId, User user)
            throws IOException {

        try {
            OrderItem item = orderDAO.getOrderItemById(itemId);
            if (item == null) {
                response.sendRedirect(request.getContextPath() + "/tables?error=Item+not+found");
                return;
            }

            Order order = orderDAO.getOrderById(item.getOrderId());
            if (order == null) {
                response.sendRedirect(request.getContextPath() + "/tables?error=Order+not+found");
                return;
            }

            boolean ok = orderDAO.markOrderItemAsServed(itemId, user.getUserId());
            if (ok) {
                // update ticket bếp -> SERVED
                KitchenDAO kdao = new KitchenDAO();
                kdao.updateTicketStatusToServed(itemId);

                // nếu tất cả item trong order đã SERVED -> order.status = 'SERVED'
                boolean allServed = orderDAO.areAllItemsServed(item.getOrderId());
                if (allServed) {
                    orderDAO.updateOrderStatus(order.getOrderId(), Order.STATUS_SERVED);
                }

                response.sendRedirect(
                        request.getContextPath()
                                + "/table-history?tableId=" + order.getTableId()
                                + "&success=Served+successfully"
                );
            } else {
                response.sendRedirect(
                        request.getContextPath()
                                + "/table-history?tableId=" + order.getTableId()
                                + "&error=Failed+to+mark+as+served"
                );
            }

        } catch (Exception e) {
            e.printStackTrace();

            String tableIdParam = request.getParameter("tableId");
            if (tableIdParam == null || tableIdParam.isEmpty()) {
                String referer = request.getHeader("Referer");
                if (referer != null && referer.contains("tableId=")) {
                    int startIdx = referer.indexOf("tableId=") + 8;
                    int endIdx = referer.indexOf("&", startIdx);
                    if (endIdx == -1) endIdx = referer.length();
                    tableIdParam = referer.substring(startIdx, endIdx);
                }
            }

            if (tableIdParam != null && !tableIdParam.isEmpty()) {
                response.sendRedirect(
                        request.getContextPath()
                                + "/table-history?tableId=" + tableIdParam
                                + "&error=An+error+occurred"
                );
            } else {
                response.sendRedirect(request.getContextPath() + "/tables");
            }
        }
    }

    // ===== INTERNAL HELPERS =====
    /**
     * Xác định station bếp cho món (HOT / DRINK / v.v.)
     * Tạm thời trả HOT, bạn có thể map theo category của món.
     */
    private String determineStation(OrderItem item) {
        return KitchenTicket.STATION_HOT;
    }

    private String safe(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"");
    }

    private BigDecimal nz(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}
