package Controller;

import Dal.MenuDAO;
import Dal.OrderDAO;
import Dal.CustomerDAO;
import Models.MenuItem;
import Models.MenuCategory;
import Models.Order;
import Models.OrderItem;
import Utils.PricingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;
import java.util.Map;
import java.util.HashMap;

@WebServlet(name = "TakeawayOrderServlet", urlPatterns = {"/takeaway-order"})
public class TakeawayOrderServlet extends HttpServlet {
    
    private MenuDAO menuDAO;
    private OrderDAO orderDAO;
    private CustomerDAO customerDAO;
    private final PricingService pricingService = new PricingService();
    
    @Override
    public void init() throws ServletException {
        menuDAO = new MenuDAO();
        orderDAO = new OrderDAO();
        try {
            customerDAO = new CustomerDAO();
        } catch (java.sql.SQLException ex) {
            throw new ServletException("Không thể khởi tạo CustomerDAO", ex);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get all menu items and categories
    List<MenuCategory> categories = menuDAO.getAllCategories();
    // reuse existing paginated method to fetch all available items
    List<MenuItem> menuItems = menuDAO.getMenuItems(1, 1000, null, null, "AVAILABLE", null);

        // Build a price map to avoid relying on a setter on MenuItem
        Map<Integer, BigDecimal> priceMap = new HashMap<>();
        for (MenuItem item : menuItems) {
            BigDecimal p = pricingService.getCurrentPrice(item);
            priceMap.put(item.getItemId(), p);
        }
        
        request.setAttribute("categories", categories);
    request.setAttribute("menuItems", menuItems);
    request.setAttribute("priceMap", priceMap);
        request.getRequestDispatcher("/views/guest/TakeawayOrder.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get form data
            String customerName = request.getParameter("customerName");
            String phoneNumber = request.getParameter("phoneNumber");
            String address = request.getParameter("address");
            String note = request.getParameter("note");
            String orderItemsJson = request.getParameter("orderItems");
            String voucherCode = request.getParameter("voucherCode");
            String voucherDiscountStr = request.getParameter("voucherDiscount");
            
            if (customerName == null || phoneNumber == null || address == null || orderItemsJson == null) {
                throw new ServletException("Missing required fields");
            }

            // Server-side validation: phone must be digits only and at most 10 characters
            String phoneTrim = phoneNumber == null ? "" : phoneNumber.trim();
            if (!phoneTrim.matches("\\d{1,10}")) {
                throw new ServletException("Số điện thoại không hợp lệ. Vui lòng chỉ nhập chữ số, tối đa 10 ký tự.");
            }
            // normalize phoneNumber
            phoneNumber = phoneTrim;
            
            // Parse order items from simple JSON-like string into Map<Integer,Integer>
            Map<Integer, Integer> orderMap = parseOrderItems(orderItemsJson);
            List<OrderItem> items = new ArrayList<>();
            BigDecimal totalAmount = BigDecimal.ZERO;

            // Create order items and calculate total
            for (Map.Entry<Integer, Integer> e : orderMap.entrySet()) {
                Integer menuItemId = e.getKey();
                Integer quantity = e.getValue();
                if (quantity == null || quantity <= 0) continue;

                MenuItem menuItem = menuDAO.getMenuItemById(menuItemId);
                if (menuItem == null) continue;

                BigDecimal basePrice = menuItem.getBasePrice();
                BigDecimal currentPrice = pricingService.getCurrentPrice(menuItem);
                BigDecimal itemTotal = currentPrice.multiply(BigDecimal.valueOf(quantity));

                OrderItem orderItem = new OrderItem();
                // We'll set orderId later after creating the order
                orderItem.setMenuItemId(menuItem.getItemId());
                orderItem.setQuantity(quantity);
                orderItem.setBaseUnitPrice(basePrice);
                // add to list for later DB insertion
                items.add(orderItem);

                totalAmount = totalAmount.add(itemTotal);
            }
            
            if (items.isEmpty()) {
                throw new ServletException("No valid items in order");
            }
            
            // Persist recipient as Customer (create or update)
            int customerId = -1;
            try {
                Models.Customer customer = new Models.Customer();
                customer.setFullName(customerName.trim());
                customer.setPhone(phoneNumber);
                customer.setAddress(address != null ? address.trim() : null);
                // email/userId unknown for guests
                customerId = customerDAO.createOrUpdate(customer);
            } catch (Exception ex) {
                // If customer persistence fails, log and continue as guest (no customer_id)
                System.err.println("Warning: failed to persist customer: " + ex.getMessage());
            }

            // Create new order (use existing Order model fields)
            Order order = new Order();
            order.setOrderType(Order.TYPE_TAKEAWAY);
            if (customerId > 0) order.setCustomerId(customerId);
            // tableId and waiterId are not applicable for takeaway; set to 0
            order.setTableId(0);
            order.setWaiterId(0);
            order.setStatus(Order.STATUS_OPEN);
            // Pack customer info into specialInstructions / notes
            StringBuilder notes = new StringBuilder();
          notes.append("customerName=").append(customerName)
              .append(";phone=").append(phoneNumber)
              .append(";address=").append(address);
            if (note != null && !note.trim().isEmpty()) {
                notes.append(";note=").append(note.trim());
            }
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                notes.append(";voucher=").append(voucherCode.trim());
                try {
                    java.math.BigDecimal vd = voucherDiscountStr == null || voucherDiscountStr.isEmpty() ? null : new java.math.BigDecimal(voucherDiscountStr);
                    if (vd != null) {
                        notes.append(";voucherDiscount=").append(vd.toPlainString());
                    }
                } catch (NumberFormatException ex) {
                    // ignore invalid discount format
                }
            }
            order.setSpecialInstructions(notes.toString());

            // Save order to database and get generated orderId
            Long createdOrderId = orderDAO.createOrder(order);
            if (createdOrderId == null) {
                throw new ServletException("Failed to create order record");
            }

            // Persist order items
            for (OrderItem oi : items) {
                oi.setOrderId(createdOrderId);
                // baseUnitPrice already set; addOrderItem will compute finalUnitPrice and totalPrice
                Long createdOrderItemId = orderDAO.addOrderItem(oi);
                // createdOrderItemId may be null if insert failed; continue
            }

            request.getSession().setAttribute("successMessage", "Đặt món thành công! Mã đơn hàng: " + createdOrderId);
            response.sendRedirect(request.getContextPath() + "/takeaway-order");
            
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/takeaway-order");
        }
    }

    /**
     * Very small parser to convert a JSON object like {"1":2,"3":1} into Map<Integer,Integer>
     * This avoids adding an external JSON dependency.
     */
    private Map<Integer, Integer> parseOrderItems(String json) {
        Map<Integer, Integer> map = new HashMap<>();
        if (json == null) return map;
        String s = json.trim();
        if (s.startsWith("{")) s = s.substring(1);
        if (s.endsWith("}")) s = s.substring(0, s.length() - 1);
        if (s.trim().isEmpty()) return map;

        String[] parts = s.split(",");
        for (String p : parts) {
            String[] kv = p.split(":");
            if (kv.length != 2) continue;
            String k = kv[0].trim().replaceAll("[\"']", "");
            String v = kv[1].trim().replaceAll("[\"']", "");
            try {
                Integer key = Integer.valueOf(k);
                Integer val = Integer.valueOf(v);
                map.put(key, val);
            } catch (NumberFormatException ex) {
                // ignore malformed entries
            }
        }
        return map;
    }
}