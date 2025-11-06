package Controller;

import Dal.OrderDAO;
import Dal.MenuDAO;
import Models.Order;
import Models.OrderItem;
import Models.MenuItem;
import Models.Customer;
import Dal.CustomerDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "TrackOrderServlet", urlPatterns = {"/track-order"})
public class TrackOrderServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private MenuDAO menuDAO;
    private CustomerDAO customerDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        menuDAO = new MenuDAO();
        try {
            customerDAO = new CustomerDAO();
        } catch (Exception ex) {
            throw new ServletException("Không thể khởi tạo CustomerDAO", ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            // just show the input form
            request.getRequestDispatcher("/views/guest/TrackOrder.jsp").forward(request, response);
            return;
        }

        try {
            Order order = orderDAO.getOrderByCode(code.trim());
            if (order == null) {
                request.setAttribute("errorMessage", "Đơn hàng không tìm thấy hoặc mã đơn không đúng.");
                request.getRequestDispatcher("/views/guest/TrackOrder.jsp").forward(request, response);
                return;
            }

            List<OrderItem> items = orderDAO.getOrderItems(order.getOrderId());
            // populate menu item details for display
            for (OrderItem it : items) {
                MenuItem m = menuDAO.getMenuItemById(it.getMenuItemId());
                it.setMenuItem(m);
            }

            // Try to fetch customer info for display
            Customer customer = null;
            if (order.getCustomerId() != null) {
                try {
                    customer = customerDAO.findById(order.getCustomerId());
                } catch (Exception ignore) {}
            }

            // Format openedAt as a friendly string for JSP
            String openedAtFormatted = null;
            if (order.getOpenedAt() != null) {
                openedAtFormatted = order.getOpenedAt().toString().replace('T', ' ');
            }

            request.setAttribute("order", order);
            request.setAttribute("orderItems", items);
            request.setAttribute("customer", customer);
            request.setAttribute("openedAtFormatted", openedAtFormatted);
            request.getRequestDispatcher("/views/guest/TrackOrder.jsp").forward(request, response);

        } catch (Exception ex) {
            throw new ServletException("Lỗi khi truy vấn đơn hàng: " + ex.getMessage(), ex);
        }
    }
}
