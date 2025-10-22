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
        
        if (pathInfo == null || pathInfo.equals("/")) {
            // POST /orders - Tạo order mới
            createOrder(request, response, user);
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
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Not found");
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
            Integer tableId = Integer.parseInt(request.getParameter("tableId"));
            String orderType = request.getParameter("orderType");
            if (orderType == null) orderType = Order.TYPE_DINE_IN;
            
            // Kiểm tra xem table đã có order chưa
            Order existingOrder = orderDAO.getOrderByTableId(tableId);
            if (existingOrder != null) {
                out.print("{\"error\":\"Table already has an active order\",\"orderId\":" + existingOrder.getOrderId() + "}");
                return;
            }

            Order order = new Order(orderType, tableId, user.getUserId());
            order.setCreatedBy(user.getUserId());
            
            Long orderId = orderDAO.createOrder(order);
            if (orderId != null) {
                out.print("{\"success\":true,\"orderId\":" + orderId + "}");
            } else {
                out.print("{\"error\":\"Failed to create order\"}");
            }
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
                out.print("{\"success\":true,\"orderItemId\":" + orderItemId + "}");
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
                order.setStatus(Order.STATUS_PREPARING);
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
}
