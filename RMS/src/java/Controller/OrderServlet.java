package Controller;

import Dal.OrderDAO;
import Dal.KitchenDAO;
import Dal.MenuDAO;
import Models.KitchenTicket;
import Models.Order;
import Models.OrderItem;
import Models.User;
import Utils.RoleBasedRedirect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;

/**
 * @author donny
 */
@WebServlet(name = "OrderServlet", urlPatterns = {"/orders", "/orders/*"})
public class OrderServlet extends HttpServlet {

    private OrderDAO orderDAO = new OrderDAO();
    private KitchenDAO kitchenDAO = new KitchenDAO();
    private MenuDAO menuDAO = new MenuDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập
        if (!RoleBasedRedirect.hasAnyPermission(user, "Waiter", "Manager", "Supervisor")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            // GET /orders - Lấy danh sách orders
            getOrders(request, response);
        } else if (pathInfo.matches("/\\d+")) {
            // GET /orders/{id} - Lấy order cụ thể
            String orderIdStr = pathInfo.substring(1);
            try {
                Long orderId = Long.parseLong(orderIdStr);
                getOrder(request, response, orderId);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID");
            }
        } else if (pathInfo.matches("/ready")) {
            // GET /orders/ready - Lấy danh sách món sẵn sàng
            getReadyItems(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Not found");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập
        if (!RoleBasedRedirect.hasAnyPermission(user, "Waiter", "Manager", "Supervisor")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        String pathInfo = request.getPathInfo();
        String action = request.getParameter("action");
        
        System.out.println("POST pathInfo: " + pathInfo);
        
        if (pathInfo == null || pathInfo.equals("/")) {
            // POST /orders - Tạo order mới
            createOrder(request, response, user);
        } else if (pathInfo.matches("/items/\\d+/serve")) {
            // POST /orders/items/{itemId}/serve - Đánh dấu món đã phục vụ
            System.out.println("Processing /orders/items/{id}/serve, pathInfo: " + pathInfo);
            String itemIdStr = pathInfo.substring(pathInfo.lastIndexOf("/") + 1);
            System.out.println("Serving item ID: " + itemIdStr);
            try {
                Long itemId = Long.parseLong(itemIdStr);
                markItemAsServed(request, response, itemId, user);
            } catch (NumberFormatException e) {
                System.err.println("Invalid item ID: " + itemIdStr);
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid item ID: " + itemIdStr);
            }
        } else if (pathInfo.matches("/\\d+/serve")) {
            // POST /orders/{itemId}/serve - Alternative pattern
            System.out.println("Processing /orders/{id}/serve, pathInfo: " + pathInfo);
            String itemIdStr = pathInfo.substring(1, pathInfo.indexOf("/serve"));
            System.out.println("Serving item ID (alt): " + itemIdStr);
            try {
                Long itemId = Long.parseLong(itemIdStr);
                markItemAsServed(request, response, itemId, user);
            } catch (NumberFormatException e) {
                System.err.println("Invalid item ID: " + itemIdStr);
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid item ID: " + itemIdStr);
            }
        } else if (pathInfo.matches("/\\d+/items")) {
            // POST /orders/{id}/items - Thêm item vào order
            String orderIdStr = pathInfo.substring(1, pathInfo.lastIndexOf("/"));
            try {
                Long orderId = Long.parseLong(orderIdStr);
                addOrderItem(request, response, orderId, user);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID");
            }
        } else if (pathInfo.matches("/\\d+/send-to-kitchen")) {
            // POST /orders/{id}/send-to-kitchen - Gửi order đến bếp
            String orderIdStr = pathInfo.substring(1, pathInfo.lastIndexOf("/"));
            try {
                Long orderId = Long.parseLong(orderIdStr);
                sendToKitchen(request, response, orderId, user);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID");
            }
        } else if (pathInfo.matches("/\\d+/serve")) {
            // POST /orders/{itemId}/serve - Đánh dấu món đã phục vụ
            String itemIdStr = pathInfo.substring(1, pathInfo.indexOf("/serve"));
            System.out.println("Serving item ID from /{itemId}/serve: " + itemIdStr);
            try {
                Long itemId = Long.parseLong(itemIdStr);
                markItemAsServed(request, response, itemId, user);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid item ID: " + itemIdStr);
            }
        } else {
            System.err.println("Unmatched pathInfo: " + pathInfo);
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Not found: " + pathInfo);
        }
    }

    /**
     * Lấy danh sách orders
     */
    private void getOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            // TODO: Implement get orders list
            out.print("{\"orders\":[]}");
        } catch (Exception e) {
            System.err.println("Error getting orders: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /**
     * Lấy danh sách món sẵn sàng
     */
    private void getReadyItems(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            String tableIdStr = request.getParameter("tableId");
            if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                out.print("{\"error\":\"Table ID is required\"}");
                return;
            }
            
            Integer tableId = Integer.parseInt(tableIdStr);
            List<OrderItem> readyItems = orderDAO.getReadyItemsForTable(tableId);
            
            // Convert to JSON
            StringBuilder json = new StringBuilder();
            json.append("{\"readyItems\":[");
            for (int i = 0; i < readyItems.size(); i++) {
                OrderItem item = readyItems.get(i);
                json.append("{");
                json.append("\"orderItemId\":").append(item.getOrderItemId()).append(",");
                json.append("\"menuItemName\":\"").append(item.getMenuItemName() != null ? item.getMenuItemName() : "").append("\",");
                json.append("\"quantity\":").append(item.getQuantity()).append(",");
                json.append("\"tableNumber\":\"").append(item.getTableNumber() != null ? item.getTableNumber() : "").append("\"");
                json.append("}");
                if (i < readyItems.size() - 1) json.append(",");
            }
            json.append("]}");
            
            out.print(json.toString());
        } catch (Exception e) {
            System.err.println("Error getting ready items: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /**
     * Lấy order cụ thể
     */
    private void getOrder(HttpServletRequest request, HttpServletResponse response, Long orderId)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                out.print("{\"error\":\"Order not found\"}");
                return;
            }

            // Lấy order items
            List<OrderItem> items = orderDAO.getOrderItems(orderId);
            order.setOrderItems(items);

            // Tạo JSON response
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"orderId\":").append(order.getOrderId()).append(",");
            json.append("\"orderType\":\"").append(order.getOrderType()).append("\",");
            json.append("\"tableId\":").append(order.getTableId()).append(",");
            json.append("\"tableNumber\":\"").append(order.getTableNumber()).append("\",");
            json.append("\"waiterId\":").append(order.getWaiterId()).append(",");
            json.append("\"waiterName\":\"").append(order.getWaiterName()).append("\",");
            json.append("\"status\":\"").append(order.getStatus()).append("\",");
            json.append("\"subtotal\":").append(order.getSubtotal()).append(",");
            json.append("\"taxAmount\":").append(order.getTaxAmount()).append(",");
            json.append("\"totalAmount\":").append(order.getTotalAmount()).append(",");
            json.append("\"specialInstructions\":\"").append(order.getSpecialInstructions() != null ? order.getSpecialInstructions() : "").append("\",");
            json.append("\"createdAt\":\"").append(order.getCreatedAt()).append("\",");
            json.append("\"items\":[");
            
            for (int i = 0; i < items.size(); i++) {
                OrderItem item = items.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"orderItemId\":").append(item.getOrderItemId()).append(",");
                json.append("\"menuItemId\":").append(item.getMenuItemId()).append(",");
                json.append("\"menuItemName\":\"").append(item.getMenuItemName()).append("\",");
                json.append("\"quantity\":").append(item.getQuantity()).append(",");
                json.append("\"specialInstructions\":\"").append(item.getSpecialInstructions() != null ? item.getSpecialInstructions() : "").append("\",");
                json.append("\"priority\":\"").append(item.getPriority()).append("\",");
                json.append("\"course\":\"").append(item.getCourse()).append("\",");
                json.append("\"baseUnitPrice\":").append(item.getBaseUnitPrice()).append(",");
                json.append("\"finalUnitPrice\":").append(item.getFinalUnitPrice()).append(",");
                json.append("\"totalPrice\":").append(item.getTotalPrice()).append(",");
                json.append("\"status\":\"").append(item.getStatus()).append("\"");
                json.append("}");
            }
            
            json.append("]");
            json.append("}");
            
            out.print(json.toString());
        } catch (Exception e) {
            System.err.println("Error getting order: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /**
     * Tạo order mới
     */
    private void createOrder(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            String tableIdStr = request.getParameter("tableId");
            if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                out.print("{\"error\":\"Table ID is required\"}");
                return;
            }
            
            Integer tableId = Integer.parseInt(tableIdStr);
            String orderType = request.getParameter("orderType");
            if (orderType == null) orderType = Order.TYPE_DINE_IN;
            
            // Tạo order mới mỗi lần gọi món
            // Khi thanh toán, tất cả order của bàn đó sẽ được gộp lại
            Order order = new Order(orderType, tableId, user.getUserId());
            order.setCreatedBy(user.getUserId());
            
            Long orderId = orderDAO.createOrder(order);
            if (orderId != null) {
                out.print("{\"success\":true,\"orderId\":" + orderId + "}");
            } else {
                out.print("{\"error\":\"Failed to create order\"}");
            }
        } catch (NumberFormatException e) {
            System.err.println("Error parsing tableId: " + e.getMessage());
            out.print("{\"error\":\"Invalid table ID\"}");
        } catch (Exception e) {
            System.err.println("Error creating order: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /**
     * Thêm item vào order
     */
    private void addOrderItem(HttpServletRequest request, HttpServletResponse response, Long orderId, User user)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            Integer menuItemId = Integer.parseInt(request.getParameter("menuItemId"));
            Integer quantity = Integer.parseInt(request.getParameter("quantity"));
            String specialInstructions = request.getParameter("specialInstructions");
            String priority = request.getParameter("priority");
            String course = request.getParameter("course");
            
            if (priority == null) priority = OrderItem.PRIORITY_NORMAL;
            if (course == null) course = OrderItem.COURSE_MAIN;

            // Lấy thông tin menu item để lấy base price
            // TODO: Implement get menu item by ID
            BigDecimal basePrice = new BigDecimal("0.00"); // Placeholder

            OrderItem orderItem = new OrderItem(orderId, menuItemId, quantity);
            orderItem.setSpecialInstructions(specialInstructions);
            orderItem.setPriority(priority);
            orderItem.setCourse(course);
            orderItem.setBaseUnitPrice(basePrice);
            orderItem.setCreatedBy(user.getUserId());
            
            Long orderItemId = orderDAO.addOrderItem(orderItem);
            if (orderItemId != null) {
                // Tự động tạo kitchen ticket sau khi thêm order item
                KitchenTicket ticket = new KitchenTicket();
                ticket.setOrderItemId(orderItemId);
                ticket.setStation(determineStation(orderItem)); // HOT, COLD, GRILL, etc.
                ticket.setPreparationStatus(KitchenTicket.STATUS_RECEIVED);
                ticket.setChefId(null); // Set chef_id to null initially
                
                Long ticketId = kitchenDAO.createKitchenTicket(ticket);
                if (ticketId != null) {
                    System.out.println("Created kitchen ticket ID: " + ticketId + " for order item ID: " + orderItemId);
                    out.print("{\"success\":true,\"orderItemId\":" + orderItemId + ",\"ticketId\":" + ticketId + "}");
                } else {
                    System.err.println("Failed to create kitchen ticket for order item ID: " + orderItemId);
                    out.print("{\"success\":true,\"orderItemId\":" + orderItemId + ",\"warning\":\"Failed to create kitchen ticket\"}");
                }
            } else {
                out.print("{\"error\":\"Failed to add item to order\"}");
            }
        } catch (Exception e) {
            System.err.println("Error adding order item: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /**
     * Gửi order đến bếp
     */
    private void sendToKitchen(HttpServletRequest request, HttpServletResponse response, Long orderId, User user)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            // Lấy order items có status = NEW
            List<OrderItem> items = orderDAO.getOrderItems(orderId);
            int sentCount = 0;
            
            for (OrderItem item : items) {
                if (OrderItem.STATUS_NEW.equals(item.getStatus())) {
                    // Tạo kitchen ticket
                    KitchenTicket ticket = new KitchenTicket(item.getOrderItemId(), determineStation(item));
                    ticket.setCreatedBy(user.getUserId());
                    ticket.setEstimatedMinutes(item.getPreparationTime());
                    
                    Long ticketId = kitchenDAO.createKitchenTicket(ticket);
                    if (ticketId != null) {
                        // Cập nhật order item status thành SENT
                        item.setStatus(OrderItem.STATUS_SENT);
                        item.setUpdatedBy(user.getUserId());
                        orderDAO.updateOrderItem(item);
                        sentCount++;
                    }
                }
            }
            
            // Cập nhật order status
            Order order = orderDAO.getOrderById(orderId);
            if (order != null) {
                order.setStatus(Order.STATUS_COOKING); // Changed from STATUS_PREPARING
                order.setUpdatedBy(user.getUserId());
                orderDAO.updateOrder(order);
            }
            
            out.print("{\"success\":true,\"sentCount\":" + sentCount + "}");
        } catch (Exception e) {
            System.err.println("Error sending to kitchen: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /**
     * Xác định station dựa trên menu item
     */
    private String determineStation(OrderItem item) {
        // TODO: Implement logic to determine station based on menu item category
        // For now, return default station
        return KitchenTicket.STATION_HOT;
    }

    /**
     * Mark order item as served
     * @author donny
     */
    private void markItemAsServed(HttpServletRequest request, HttpServletResponse response, Long itemId, User user)
            throws ServletException, IOException {
        
        System.out.println("markItemAsServed called for itemId: " + itemId);
        
        try {
            // Get order item to retrieve orderId
            OrderItem item = orderDAO.getOrderItemById(itemId);
            if (item == null) {
                System.err.println("Order item not found: " + itemId);
                request.setAttribute("error", "Order item not found");
                response.sendRedirect(request.getContextPath() + "/tables");
                return;
            }
            
            System.out.println("Order item found: " + item.getMenuItemName() + ", status: " + item.getStatus());
            
            Order order = orderDAO.getOrderById(item.getOrderId());
            if (order == null) {
                System.err.println("Order not found: " + item.getOrderId());
                request.setAttribute("error", "Order not found");
                response.sendRedirect(request.getContextPath() + "/tables");
                return;
            }
            
            System.out.println("Order found: " + order.getOrderId() + ", tableId: " + order.getTableId());
            
            // Mark item as served
            boolean success = orderDAO.markOrderItemAsServed(itemId, user.getUserId());
            System.out.println("markOrderItemAsServed result: " + success);
            
            if (success) {
                // Cập nhật kitchen ticket status thành SERVED
                KitchenDAO kitchenDAO = new KitchenDAO();
                kitchenDAO.updateTicketStatusToServed(itemId);
                
                // Check if all items in the order are served
                boolean allServed = orderDAO.areAllItemsServed(item.getOrderId());
                
                if (allServed) {
                    // Update order status to SERVED
                    order.setStatus(Order.STATUS_SERVED);
                    order.setUpdatedBy(user.getUserId());
                    orderDAO.updateOrder(order);
                }
                
                // Redirect back to table history
                System.out.println("Redirecting to table-history with tableId: " + order.getTableId());
                response.sendRedirect(request.getContextPath() + "/table-history?tableId=" + order.getTableId() + "&success=Served+successfully");
            } else {
                System.err.println("markOrderItemAsServed returned false");
                response.sendRedirect(request.getContextPath() + "/table-history?tableId=" + order.getTableId() + "&error=Failed+to+mark+as+served");
            }
        } catch (Exception e) {
            System.err.println("Error marking item as served: " + e.getMessage());
            e.printStackTrace();
            
            // Try to get tableId from request parameter or session
            String tableIdParam = request.getParameter("tableId");
            if (tableIdParam == null || tableIdParam.isEmpty()) {
                // Try to get from referrer URL
                String referer = request.getHeader("Referer");
                if (referer != null && referer.contains("tableId=")) {
                    int startIdx = referer.indexOf("tableId=") + 8;
                    int endIdx = referer.indexOf("&", startIdx);
                    if (endIdx == -1) endIdx = referer.length();
                    tableIdParam = referer.substring(startIdx, endIdx);
                }
            }
            
            if (tableIdParam != null && !tableIdParam.isEmpty()) {
                System.out.println("Redirecting to table-history with tableId from param: " + tableIdParam);
                response.sendRedirect(request.getContextPath() + "/table-history?tableId=" + tableIdParam + "&error=An+error+occurred");
            } else {
                System.err.println("Could not determine tableId, redirecting to /tables");
                response.sendRedirect(request.getContextPath() + "/tables");
            }
        }
    }
}
