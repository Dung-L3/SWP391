package Dal;

import Models.OrderItem;
import Dal.DBConnect;

import java.sql.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * BillDAO
 *
 * Nhiệm vụ:
 *  - Tạo snapshot bill (bills + bill_items)
 *  - Đổi trạng thái bill từ PROFORMA -> FINAL khi VNPay báo thành công
 *  - Truy vấn bill PROFORMA (bill tạm chờ VNPay) cho 1 bàn
 *  - Lấy tóm tắt bill bất kỳ để hiển thị
 *
 * Bảng bills (các cột quan trọng):
 *   bill_id (PK identity),
 *   order_id          (có thể NULL nếu bill gộp nhiều order),
 *   bill_no,
 *   status            ('PROFORMA','FINAL','VOID','REFUNDED'),
 *   subtotal,
 *   discount_amount,
 *   tax_amount,
 *   total_amount,
 *   vat_rate,
 *   created_by,
 *   created_at,
 *   finalized_at,
 *   table_id,
 *   voucher_id,
 *   voucher_code,
 *   voided            (bit/tinyint 0|1),
 *   void_reason
 *
 * Quy ước:
 * - PROFORMA: bill tạm / còn khoản PENDING (thường do VNPay chưa thành công).
 * - FINAL: bill đã thanh toán đầy đủ.
 */
public class BillDAO {

    /**
     * BillSummary
     *
     * Dùng cho:
     *  - Payment.jsp (hiển thị bill PROFORMA đang chờ thanh toán)
     *  - PaymentSuccess.jsp
     *  - VnpayReturnServlet / callback VNPay
     */
    public static class BillSummary {
        public Long billId;
        public Long orderId;            // null nếu bill gộp nhiều order
        public Integer tableId;

        public String status;           // PROFORMA / FINAL / ...
        public String billNo;

        public BigDecimal subtotal;
        public BigDecimal discountAmount;
        public BigDecimal taxAmount;
        public BigDecimal totalAmount;
        public BigDecimal vatRate;

        public Integer voucherId;
        public String  voucherCode;

        public Timestamp createdAt;
        public Timestamp finalizedAt;
    }

    /* =========================================================
     * createBill(...)
     *
     * Chụp snapshot 1 bill tại thời điểm thu tiền.
     *
     * Nếu khách chưa trả đủ (còn phần VNPay PENDING):
     *   -> status = 'PROFORMA', finalized_at = NULL
     * Nếu khách trả đủ:
     *   -> status = 'FINAL',    finalized_at = now
     *
     * Hàm dùng Connection externalConn (transaction do caller quản lý).
     * KHÔNG tự commit/rollback.
     *
     * Trả về bill_id vừa tạo (Long) hoặc null nếu fail.
     * ========================================================= */
    public Long createBill(
            Connection externalConn,
            Long orderId,             // null nếu bill gộp nhiều order
            Integer tableId,
            String billNo,
            String status,            // "FINAL" hoặc "PROFORMA"
            BigDecimal subtotal,
            BigDecimal discountAmount,
            BigDecimal taxAmount,
            BigDecimal totalAmount,
            BigDecimal vatRate,
            Integer createdBy,
            Integer voucherId,
            String voucherCode
    ) throws SQLException {

        final String sql = """
            INSERT INTO bills (
                order_id,
                bill_no,
                status,
                subtotal,
                discount_amount,
                tax_amount,
                total_amount,
                vat_rate,
                created_by,
                created_at,
                finalized_at,
                table_id,
                voucher_id,
                voucher_code,
                voided,
                void_reason
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, NULL)
        """;

        Timestamp now = Timestamp.valueOf(LocalDateTime.now());
        boolean isFinal = "FINAL".equalsIgnoreCase(status);

        try (PreparedStatement ps = externalConn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            // order_id (có thể NULL nếu bill gộp nhiều order)
            if (orderId != null) {
                ps.setLong(1, orderId);
            } else {
                ps.setNull(1, Types.BIGINT);
            }

            // bill_no
            ps.setString(2, billNo);

            // status
            ps.setString(3, status);

            // snapshot số tiền
            ps.setBigDecimal(4,  nz(subtotal));
            ps.setBigDecimal(5,  nz(discountAmount));
            ps.setBigDecimal(6,  nz(taxAmount));
            ps.setBigDecimal(7,  nz(totalAmount));
            ps.setBigDecimal(8,  nz(vatRate));

            // created_by
            if (createdBy != null) {
                ps.setInt(9, createdBy);
            } else {
                ps.setNull(9, Types.INTEGER);
            }

            // created_at
            ps.setTimestamp(10, now);

            // finalized_at
            if (isFinal) {
                ps.setTimestamp(11, now);
            } else {
                ps.setNull(11, Types.TIMESTAMP);
            }

            // table_id
            if (tableId != null) {
                ps.setInt(12, tableId);
            } else {
                ps.setNull(12, Types.INTEGER);
            }

            // voucher_id
            if (voucherId != null) {
                ps.setInt(13, voucherId);
            } else {
                ps.setNull(13, Types.INTEGER);
            }

            // voucher_code
            if (voucherCode != null) {
                ps.setString(14, voucherCode);
            } else {
                // driver SQLServer đôi khi không thích setNull(NVARCHAR)
                try {
                    ps.setNull(14, Types.NVARCHAR);
                } catch (SQLException e) {
                    ps.setNull(14, Types.VARCHAR);
                }
            }

            int rows = ps.executeUpdate();
            if (rows == 0) {
                return null;
            }

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }

        return null;
    }

    /* =========================================================
     * insertBillItems(...)
     *
     * Lưu snapshot từng món vào bill_items.
     * BỎ QUA item CANCELLED.
     *
     * Dùng chung transaction externalConn (KHÔNG commit ở đây).
     *
     * Quan trọng:
     * - Nếu gặp dữ liệu xấu (order_item_id null, v.v...),
     *   ta bỏ qua line đó thay vì throw -> tránh rollback nguyên bill.
     * ========================================================= */
    public void insertBillItems(
            Connection externalConn,
            Long billId,
            List<OrderItem> orderItems
    ) throws SQLException {

        final String sql = """
            INSERT INTO bill_items (
                bill_id,
                order_item_id,
                quantity,
                unit_price,
                line_total
            )
            VALUES (?, ?, ?, ?, ?)
        """;

        try (PreparedStatement ps = externalConn.prepareStatement(sql)) {

            for (OrderItem it : orderItems) {
                if (it == null) continue;

                // Bỏ item CANCELLED
                if ("CANCELLED".equalsIgnoreCase(it.getStatus())) {
                    continue;
                }

                // Lấy khóa ngoại (order_item_id)
                Long oiId = it.getOrderItemId();

                // Nếu null -> DB có thể FK NOT NULL, ta skip thay vì nổ
                if (oiId == null) {
                    System.out.println("[BillDAO] WARN: order_item_id null -> skip snapshot line");
                    continue;
                }

                // quantity
                Integer qtyObj = it.getQuantity();
                int qty = (qtyObj != null ? qtyObj : 0);

                // unit_price = finalUnitPrice fallback 0
                BigDecimal unitPrice = it.getFinalUnitPrice();
                if (unitPrice == null) {
                    unitPrice = BigDecimal.ZERO;
                }

                // line_total = it.getTotalPrice() fallback unitPrice * qty
                BigDecimal lineTotal = it.getTotalPrice();
                if (lineTotal == null) {
                    lineTotal = unitPrice.multiply(new BigDecimal(qty));
                }
                if (lineTotal == null) {
                    lineTotal = BigDecimal.ZERO;
                }

                ps.setLong(1, billId);
                ps.setLong(2, oiId);
                ps.setInt(3, qty);
                ps.setBigDecimal(4, unitPrice);
                ps.setBigDecimal(5, lineTotal);

                ps.addBatch();
            }

            ps.executeBatch();
        }
    }

    /* =========================================================
     * markBillPaid(...)
     *
     * Khi VNPay callback thành công (sau PENDING):
     *   - đổi PROFORMA -> FINAL
     *   - set finalized_at = NOW()
     *
     * Hàm này tự mở connection riêng (xài ngoài transaction thanh toán ban đầu).
     * ========================================================= */
    public boolean markBillPaid(Long billId) throws SQLException {
        final String sql = """
            UPDATE bills
            SET status = 'FINAL',
                finalized_at = ?
            WHERE bill_id = ?
              AND status <> 'FINAL'
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(2, billId);

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * markBillPaidInTx(...)
     *
     * Phiên bản dùng connection bên ngoài (trong 1 transaction do caller quản lý).
     * Bạn có thể dùng trong VnpayReturnServlet nếu muốn mọi update (payment SUCCESS
     * + bill FINAL) commit cùng lúc.
     */
    public boolean markBillPaidInTx(Connection externalConn, Long billId) throws SQLException {
        final String sql = """
            UPDATE bills
            SET status = 'FINAL',
                finalized_at = ?
            WHERE bill_id = ?
              AND status <> 'FINAL'
        """;

        try (PreparedStatement ps = externalConn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(2, billId);
            return ps.executeUpdate() > 0;
        }
    }

    /* =========================================================
     * findOpenBillForTable(...)
     *
     * Lấy bill PROFORMA MỚI NHẤT (status='PROFORMA', voided=0)
     * cho 1 bàn. Dùng trong Payment.jsp:
     * - Bàn có thể đã snapshot & SETTLED order, nhưng khách vẫn chưa
     *   quét VNPay xong -> bill PROFORMA tồn tại.
     *
     * Trả về BillSummary hoặc null nếu không có.
     * ========================================================= */
    public BillSummary findOpenBillForTable(int tableId) throws SQLException {
        final String sql = """
            SELECT TOP 1
                bill_id,
                order_id,
                table_id,
                bill_no,
                status,
                subtotal,
                discount_amount,
                tax_amount,
                total_amount,
                vat_rate,
                voucher_id,
                voucher_code,
                created_at,
                finalized_at
            FROM bills
            WHERE table_id = ?
              AND status = 'PROFORMA'
              AND voided = 0
            ORDER BY bill_id DESC
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, tableId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapBillSummary(rs);
                }
            }
        }

        return null;
    }

    /* =========================================================
     * findAllOpenBillsForTable(...)
     *
     * Trả về DANH SÁCH TẤT CẢ bill PROFORMA (voided=0) cho 1 bàn,
     * ORDER BY bill_id DESC (mới nhất đứng đầu).
     *
     * Thu ngân sẽ thấy mọi lần "đã in QR nhưng khách chưa quét",
     * không chỉ bill mới nhất.
     * ========================================================= */
    public List<BillSummary> findAllOpenBillsForTable(int tableId) throws SQLException {
        final String sql = """
            SELECT
                bill_id,
                order_id,
                table_id,
                bill_no,
                status,
                subtotal,
                discount_amount,
                tax_amount,
                total_amount,
                vat_rate,
                voucher_id,
                voucher_code,
                created_at,
                finalized_at
            FROM bills
            WHERE table_id = ?
              AND status = 'PROFORMA'
              AND voided = 0
            ORDER BY bill_id DESC
        """;

        List<BillSummary> list = new ArrayList<>();

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, tableId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapBillSummary(rs));
                }
            }
        }

        return list;
    }

    /* =========================================================
     * getBillSummary(...)
     *
     * Lấy tóm tắt 1 bill bất kỳ (FINAL hoặc PROFORMA).
     * Dùng cho PaymentSuccess.jsp, callback VNPay,...
     *
     * Trả về BillSummary hoặc null nếu không tìm thấy.
     * ========================================================= */
    public BillSummary getBillSummary(Long billId) throws SQLException {
        final String sql = """
            SELECT
                bill_id,
                order_id,
                table_id,
                bill_no,
                status,
                subtotal,
                discount_amount,
                tax_amount,
                total_amount,
                vat_rate,
                voucher_id,
                voucher_code,
                created_at,
                finalized_at
            FROM bills
            WHERE bill_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, billId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapBillSummary(rs);
                }
            }
        }

        return null;
    }

    /* =========================================================
     * mapBillSummary(...)
     *
     * Helper private để tránh lặp code ở nhiều hàm select.
     * ========================================================= */
    private BillSummary mapBillSummary(ResultSet rs) throws SQLException {
        BillSummary bs = new BillSummary();

        bs.billId         = rs.getLong("bill_id");
        bs.orderId        = (Long)    rs.getObject("order_id");     // có thể null
        bs.tableId        = (Integer) rs.getObject("table_id");

        bs.billNo         = rs.getString("bill_no");
        bs.status         = rs.getString("status");

        bs.subtotal       = rs.getBigDecimal("subtotal");
        bs.discountAmount = rs.getBigDecimal("discount_amount");
        bs.taxAmount      = rs.getBigDecimal("tax_amount");
        bs.totalAmount    = rs.getBigDecimal("total_amount");
        bs.vatRate        = rs.getBigDecimal("vat_rate");

        bs.voucherId      = (Integer) rs.getObject("voucher_id");
        bs.voucherCode    = rs.getString("voucher_code");

        bs.createdAt      = rs.getTimestamp("created_at");
        bs.finalizedAt    = rs.getTimestamp("finalized_at");

        return bs;
    }

    /* ---------------------------------------------------------
     * Helper nội bộ
     * --------------------------------------------------------- */
    private BigDecimal nz(BigDecimal v) {
        return (v == null ? BigDecimal.ZERO : v);
    }
}
