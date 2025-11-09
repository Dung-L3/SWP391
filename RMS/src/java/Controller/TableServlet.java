package Controller;

import Dal.OrderDAO;
import Dal.TableDAO;
import Models.DiningTable;
import Models.TableArea;
import Models.TableSession;
import Models.User;
import Utils.RoleBasedRedirect;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * @author donny
 */
@WebServlet(name = "TableServlet", urlPatterns = {"/tables", "/tables/*"})
public class TableServlet extends HttpServlet {

    private TableDAO tableDAO = new TableDAO();
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        // Kiểm tra quyền truy cập (Waiter, Manager, Supervisor)
        if (!RoleBasedRedirect.hasAnyPermission(user, "Waiter", "Manager", "Supervisor")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        String pathInfo = request.getPathInfo();
        String action = request.getParameter("action");
        
        if (pathInfo == null || pathInfo.equals("/")) {
            // GET /tables - Hiển thị bản đồ bàn
            showTableMap(request, response);
        } else if (pathInfo.startsWith("/")) {
            // GET /tables/{id} - Lấy thông tin bàn cụ thể
            String tableIdStr = pathInfo.substring(1);
            try {
                int tableId = Integer.parseInt(tableIdStr);
                getTableInfo(request, response, tableId);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid table ID");
            }
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
        
        // Kiểm tra quyền truy cập (Waiter, Manager, Supervisor)
        if (!RoleBasedRedirect.hasAnyPermission(user, "Waiter", "Manager", "Supervisor")) {
            request.getRequestDispatcher("/views/403.jsp").forward(request, response);
            return;
        }
        
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing table ID");
            return;
        }

        String[] pathParts = pathInfo.split("/");
        if (pathParts.length < 3) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid path");
            return;
        }

        try {
            int tableId = Integer.parseInt(pathParts[1]);
            String action = pathParts[2];

            switch (action) {
                case "seat":
                    seatTable(request, response, tableId);
                    break;
                case "vacate":
                    vacateTable(request, response, tableId);
                    break;
                case "clean":
                    cleanTable(request, response, tableId);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid table ID");
        }
    }

    private void showTableMap(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String areaIdStr = request.getParameter("area");
        Integer areaId = null;
        if (areaIdStr != null && !areaIdStr.trim().isEmpty()) {
            try {
                areaId = Integer.parseInt(areaIdStr);
            } catch (NumberFormatException e) {
                // Ignore invalid area ID
            }
        }

        List<TableArea> areas = tableDAO.getAllAreas();
        List<DiningTable> tables = tableDAO.getTablesByArea(areaId);
        
        // Lấy số lượng món READY và CANCELLED cho các bàn
        Map<Integer, Map<String, Integer>> tableItemCounts = new java.util.HashMap<>();
        try {
            tableItemCounts = orderDAO.getTableItemCounts();
        } catch (java.sql.SQLException e) {
            System.err.println("Error getting table item counts: " + e.getMessage());
            e.printStackTrace();
            // Continue with empty map if error occurs
        }

        request.setAttribute("areas", areas);
        request.setAttribute("tables", tables);
        request.setAttribute("selectedAreaId", areaId);
        request.setAttribute("tableItemCounts", tableItemCounts);

        request.getRequestDispatcher("/views/TableMap.jsp").forward(request, response);
    }

    private void getTableInfo(HttpServletRequest request, HttpServletResponse response, int tableId)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            DiningTable table = tableDAO.getTableById(tableId);
            if (table == null) {
                out.print("{\"error\":\"Table not found\"}");
                return;
            }

            TableSession session = tableDAO.getCurrentSession(tableId);
            
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"tableId\":").append(table.getTableId()).append(",");
            json.append("\"tableNumber\":\"").append(table.getTableNumber()).append("\",");
            json.append("\"capacity\":").append(table.getCapacity()).append(",");
            json.append("\"status\":\"").append(table.getStatus()).append("\",");
            json.append("\"areaName\":\"").append(table.getAreaName()).append("\",");
            json.append("\"hasSession\":").append(session != null);
            if (session != null) {
                json.append(",\"sessionId\":").append(session.getTableSessionId());
                json.append(",\"openTime\":\"").append(session.getOpenTime()).append("\"");
            }
            json.append("}");
            
            out.print(json.toString());
        } catch (Exception e) {
            System.err.println("Error in getTableInfo: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    private void seatTable(HttpServletRequest request, HttpServletResponse response, int tableId)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        boolean success = tableDAO.seatTable(tableId, null, null, user.getUserId());
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success + "}");
    }

    private void vacateTable(HttpServletRequest request, HttpServletResponse response, int tableId)
            throws ServletException, IOException {
        
        boolean success = tableDAO.vacateTable(tableId);
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success + "}");
    }

    private void cleanTable(HttpServletRequest request, HttpServletResponse response, int tableId)
            throws ServletException, IOException {
        
        boolean success = tableDAO.cleanTable(tableId);
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success + "}");
    }
}

