package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Lightweight servlet that exposes a clean URL (/booking) and forwards to the
 * JSP at /views/guest/booking.jsp so the JSP path is not exposed in links.
 */
@WebServlet(name = "BookingPageServlet", urlPatterns = {"/booking"})
public class BookingPageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/views/guest/booking.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // POSTs to /booking should simply behave like GET (render form)
        doGet(req, resp);
    }
}
