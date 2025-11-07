package Controller;

import Dal.TableDAO;
import Dal.DBConnect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Transfer open table session from one table to another.
 */
@WebServlet(urlPatterns = {"/reception/transfer-table"})
public class TransferTableServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String source = request.getParameter("sourceTable");
        String target = request.getParameter("targetTable");

        if (source == null || target == null || source.isEmpty() || target.isEmpty()) {
            request.getSession().setAttribute("errorMessage", "Vui lòng chọn cả bàn nguồn và bàn đích.");
            response.sendRedirect(request.getContextPath() + "/views/reception-transfer.jsp");
            return;
        }

        Connection con = null;
        try {
            con = DBConnect.getConnection();
            con.setAutoCommit(false);

            // find open session for source table
            String findSessionSql = "SELECT table_session_id FROM table_session WHERE table_id = (SELECT table_id FROM dining_table WHERE table_number = ?) AND status = 'OPEN'";
            try (PreparedStatement ps = con.prepareStatement(findSessionSql)) {
                ps.setString(1, source);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        // no open session — still perform status swap
                        String updSource = "UPDATE dining_table SET status = 'VACANT' WHERE table_number = ?";
                        try (PreparedStatement u1 = con.prepareStatement(updSource)) {
                            u1.setString(1, source);
                            u1.executeUpdate();
                        }
                        String updTarget = "UPDATE dining_table SET status = 'SEATED' WHERE table_number = ?";
                        try (PreparedStatement u2 = con.prepareStatement(updTarget)) {
                            u2.setString(1, target);
                            u2.executeUpdate();
                        }
                        con.commit();
                        request.getSession().setAttribute("successMessage", "Chuyển bàn hoàn tất (không có phiên mở). Có thể cần kiểm tra bill/phòng bếp.");
                        response.sendRedirect(request.getContextPath() + "/views/reception-transfer.jsp");
                        return;
                    }
                }
            }

            // update table_session to point to target table id
            String updateSessionSql = "UPDATE ts SET ts.table_id = t2.table_id FROM table_session ts JOIN dining_table t1 ON ts.table_id = t1.table_id JOIN dining_table t2 ON t2.table_number = ? WHERE t1.table_number = ? AND ts.status = 'OPEN'";
            try (PreparedStatement ps = con.prepareStatement(updateSessionSql)) {
                ps.setString(1, target);
                ps.setString(2, source);
                ps.executeUpdate();
            }

            // mark source VACANT and target SEATED
            String updSource = "UPDATE dining_table SET status = 'VACANT' WHERE table_number = ?";
            try (PreparedStatement u1 = con.prepareStatement(updSource)) {
                u1.setString(1, source);
                u1.executeUpdate();
            }

            String updTarget = "UPDATE dining_table SET status = 'SEATED' WHERE table_number = ?";
            try (PreparedStatement u2 = con.prepareStatement(updTarget)) {
                u2.setString(1, target);
                u2.executeUpdate();
            }

            con.commit();
            request.getSession().setAttribute("successMessage", "Chuyển bàn thành công: " + source + " → " + target);

        } catch (SQLException e) {
            e.printStackTrace();
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            request.getSession().setAttribute("errorMessage", "Lỗi khi chuyển bàn: " + e.getMessage());
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }

        response.sendRedirect(request.getContextPath() + "/views/reception-transfer.jsp");
    }
}
