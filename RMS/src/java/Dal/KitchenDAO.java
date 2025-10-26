package Dal;

import Models.KitchenTicket;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * @author donny
 */
public class KitchenDAO {

    /**
     * Tạo kitchen ticket
     */
    public Long createKitchenTicket(KitchenTicket ticket) throws SQLException {
        String sql = """
            INSERT INTO kitchen_tickets (order_item_id, station, preparation_status, received_time, chef_id)
            VALUES (?, ?, ?, ?, ?)
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, ticket.getOrderItemId());
            ps.setString(2, ticket.getStation());
            ps.setString(3, ticket.getPreparationStatus());
            ps.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now())); // received_time
            ps.setObject(5, ticket.getChefId()); // chef_id can be null

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        }
        return null;
    }

    /**
     * Lấy kitchen tickets theo station và status
     */
    public List<KitchenTicket> getKitchenTickets(String station, String status) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT kt.kt_id, kt.order_item_id, kt.station, kt.preparation_status, ");
        sql.append("kt.received_time, kt.start_time, kt.ready_time, kt.picked_time, kt.served_time, kt.chef_id, ");
        sql.append("o.order_id, dt.table_number as table_number, mi.name as menu_item_name, ");
        sql.append("oi.quantity, oi.special_instructions, oi.priority, oi.course_no as course ");
        sql.append("FROM kitchen_tickets kt ");
        sql.append("JOIN order_items oi ON oi.order_item_id = kt.order_item_id ");
        sql.append("JOIN orders o ON o.order_id = oi.order_id ");
        sql.append("LEFT JOIN dining_table dt ON dt.table_id = o.table_id ");
        sql.append("LEFT JOIN menu_items mi ON mi.menu_item_id = oi.menu_item_id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (station != null && !station.isEmpty()) {
            sql.append("AND kt.station = ? ");
            params.add(station);
        }

        if (status != null && !status.isEmpty()) {
            sql.append("AND kt.preparation_status = ? ");
            params.add(status);
        }

        sql.append("ORDER BY oi.priority DESC, kt.received_time ASC");

        List<KitchenTicket> tickets = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tickets.add(mapResultSetToKitchenTicket(rs));
                }
            }
        }
        return tickets;
    }

    /**
     * Cập nhật status của kitchen ticket
     */
    public boolean updateKitchenTicketStatus(Long ticketId, String status, Integer updatedBy) throws SQLException {
        String sql = "UPDATE kitchen_tickets SET preparation_status = ?, updated_at = ?, updated_by = ?";
        LocalDateTime now = LocalDateTime.now();

        // Cập nhật thời gian tương ứng với status
        switch (status) {
            case KitchenTicket.STATUS_COOKING:
                sql += ", start_time = ?";
                break;
            case KitchenTicket.STATUS_READY:
                sql += ", ready_time = ?";
                break;
            case KitchenTicket.STATUS_PICKED:
                sql += ", picked_time = ?";
                break;
            case KitchenTicket.STATUS_SERVED:
                sql += ", served_time = ?";
                break;
        }

        sql += " WHERE kitchen_ticket_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setTimestamp(2, Timestamp.valueOf(now));
            ps.setInt(3, updatedBy);

            int paramIndex = 4;
            switch (status) {
                case KitchenTicket.STATUS_COOKING:
                    ps.setTimestamp(paramIndex++, Timestamp.valueOf(now));
                    break;
                case KitchenTicket.STATUS_READY:
                    ps.setTimestamp(paramIndex++, Timestamp.valueOf(now));
                    break;
                case KitchenTicket.STATUS_PICKED:
                    ps.setTimestamp(paramIndex++, Timestamp.valueOf(now));
                    break;
                case KitchenTicket.STATUS_SERVED:
                    ps.setTimestamp(paramIndex++, Timestamp.valueOf(now));
                    break;
            }

            ps.setLong(paramIndex, ticketId);

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Cập nhật order item status khi kitchen ticket thay đổi
     */
    public boolean updateOrderItemStatus(Long orderItemId, String status, Integer updatedBy) throws SQLException {
        String sql = "UPDATE order_items SET status = ?, updated_at = ?, updated_by = ? WHERE order_item_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(3, updatedBy);
            ps.setLong(4, orderItemId);

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Lấy kitchen ticket theo ID
     */
    public KitchenTicket getKitchenTicketById(Long ticketId) throws SQLException {
        String sql = """
            SELECT kt.*, o.order_id, dt.table_number, mi.name as menu_item_name, 
                   oi.quantity, oi.special_instructions, oi.priority, oi.course
            FROM kitchen_tickets kt
            JOIN order_items oi ON oi.order_item_id = kt.order_item_id
            JOIN orders o ON o.order_id = oi.order_id
            LEFT JOIN dining_table dt ON dt.table_id = o.table_id
            LEFT JOIN menu_items mi ON mi.item_id = oi.menu_item_id
            WHERE kt.kitchen_ticket_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToKitchenTicket(rs);
                }
            }
        }
        return null;
    }

    /**
     * Lấy thống kê kitchen tickets
     */
    public List<Object[]> getKitchenStats() throws SQLException {
        String sql = """
            SELECT station, preparation_status, COUNT(*) as count
            FROM kitchen_tickets
            WHERE preparation_status IN ('RECEIVED', 'COOKING', 'READY')
            GROUP BY station, preparation_status
            ORDER BY station, preparation_status
        """;

        List<Object[]> stats = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Object[] stat = new Object[3];
                stat[0] = rs.getString("station");
                stat[1] = rs.getString("preparation_status");
                stat[2] = rs.getInt("count");
                stats.add(stat);
            }
        }
        return stats;
    }

    /**
     * Map ResultSet to KitchenTicket
     */
    private KitchenTicket mapResultSetToKitchenTicket(ResultSet rs) throws SQLException {
        KitchenTicket ticket = new KitchenTicket();
        ticket.setKitchenTicketId(rs.getLong("kt_id"));
        ticket.setOrderItemId(rs.getLong("order_item_id"));
        ticket.setStation(rs.getString("station"));
        ticket.setPreparationStatus(rs.getString("preparation_status"));
        
        if (rs.getTimestamp("received_time") != null) {
            ticket.setReceivedTime(rs.getTimestamp("received_time").toLocalDateTime());
        }
        if (rs.getTimestamp("start_time") != null) {
            ticket.setStartTime(rs.getTimestamp("start_time").toLocalDateTime());
        }
        if (rs.getTimestamp("ready_time") != null) {
            ticket.setReadyTime(rs.getTimestamp("ready_time").toLocalDateTime());
        }
        if (rs.getTimestamp("picked_time") != null) {
            ticket.setPickedTime(rs.getTimestamp("picked_time").toLocalDateTime());
        }
        if (rs.getTimestamp("served_time") != null) {
            ticket.setServedTime(rs.getTimestamp("served_time").toLocalDateTime());
        }
        
        // Set additional fields from join
        ticket.setTableNumber(rs.getString("table_number"));
        ticket.setMenuItemName(rs.getString("menu_item_name"));
        ticket.setQuantity(rs.getInt("quantity"));
        ticket.setSpecialInstructions(rs.getString("special_instructions"));
        ticket.setPriority(rs.getString("priority"));
        ticket.setCourse(rs.getString("course"));
        if (rs.getObject("chef_id") != null) {
            ticket.setChefId(rs.getInt("chef_id"));
        }
        
        return ticket;
    }
}
