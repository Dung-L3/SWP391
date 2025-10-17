package Controller;

import Dal.AuditLogDAO;
import Dal.AuditLogDAO.AuditLogItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

public class AuditLogServlet extends HttpServlet {

    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = param(request, "q");
        String action = param(request, "actionFilter");
        String tableName = param(request, "tableFilter");
        Timestamp from = parseTs(param(request, "from"));
        Timestamp to = parseTs(param(request, "to"));
        int page = parseInt(param(request, "page"), 1);
        int size = parseInt(param(request, "size"), 20);
        int offset = (page - 1) * size;

        List<AuditLogItem> items = auditLogDAO.list(keyword, action, tableName, from, to, offset, size);
        int total = auditLogDAO.count(keyword, action, tableName, from, to);
        int totalPages = (int) Math.ceil((double) total / size);

        request.setAttribute("logs", items);
        request.setAttribute("total", total);
        request.setAttribute("currentPage", page);
        request.setAttribute("size", size);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("q", keyword);
        request.setAttribute("actionFilter", action);
        request.setAttribute("tableFilter", tableName);
        request.setAttribute("from", param(request, "from"));
        request.setAttribute("to", param(request, "to"));

        request.getRequestDispatcher("/views/AuditLog.jsp").forward(request, response);
    }

    private String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v == null ? null : v.trim();
    }

    private int parseInt(String s, int d) {
        try { return Integer.parseInt(s); } catch (Exception e) { return d; }
    }

    private Timestamp parseTs(String s) {
        try { return s == null || s.isEmpty() ? null : Timestamp.valueOf(s + " 00:00:00"); } catch (Exception e) { return null; }
    }
}
