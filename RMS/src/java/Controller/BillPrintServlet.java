package Controller;

import Dal.BillDAO;
import Dal.BillDAO.BillSummary;
import Dal.BillDAO.BillLine;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class BillPrintServlet extends HttpServlet {

    private BillDAO billDAO;

    @Override
    public void init() throws ServletException {
        billDAO = new BillDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String billIdParam = request.getParameter("billId");
        if (billIdParam == null || billIdParam.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing billId");
            return;
        }

        Long billId;
        try {
            billId = Long.parseLong(billIdParam);
        } catch (NumberFormatException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid billId");
            return;
        }

        try {
            BillSummary summary = billDAO.getBillSummary(billId);
            if (summary == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Bill not found");
                return;
            }

            List<BillLine> lines = billDAO.getBillLines(billId);

            request.setAttribute("summary", summary);
            request.setAttribute("lines", lines);

            request.getRequestDispatcher("/views/BillPrint.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
