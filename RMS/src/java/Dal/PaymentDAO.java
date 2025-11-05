package Dal;

import java.sql.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * PaymentDAO
 *
 * Bảng payments:
 *  - payment_id        (PK identity)
 *  - bill_id           (thuộc bill nào)
 *  - method            (CASH / ONLINE / VNPAY / ...)
 *  - amount            (số tiền của khoản thanh toán này)
 *  - provider          (VD: 'VNPAY' nếu là QR qua VNPay)
 *  - transaction_id    (mã giao dịch do VNPay trả về)
 *  - status            ('SUCCESS','PENDING')
 *  - paid_at           (datetime lúc tiền đã xác nhận)
 *  - processed_by      (user_id thu ngân tạo khoản payment)
 *  - order_id          (có thể null nếu bill gộp nhiều order)
 *  - paid_channel_note (mô tả: "Tiền mặt tại quầy bàn #3", ... )
 *
 * Luồng chính:
 *  - Khi thu tiền trong PaymentServlet.doPost():
 *      + Tiền mặt      -> createPayment(... status=SUCCESS ...)
 *      + VNPay (còn thiếu) -> createPayment(... status=PENDING ...)
 *    Sau đó commit transaction.
 *
 *  - Khi VNPay callback (VnpayReturnServlet):
 *      + markPaymentSuccess(paymentId, transactionNo)
 *      + billDAO.markBillPaid(...)
 */
public class PaymentDAO {

    public static final String STATUS_SUCCESS = "SUCCESS";
    public static final String STATUS_PENDING = "PENDING";

    /**
     * DTO dùng để show lịch sử thanh toán và để xử lý callback.
     *
     * Lưu ý:
     *  JSP EL như ${p.status} hay ${p.method} sẽ gọi getStatus(), getMethod().
     *  Vì hiện tại bạn gán field trực tiếp (info.status = ...), ta giữ field public
     *  để không phải sửa code DAO, nhưng bổ sung getter để JSP không lỗi.
     */
    public static class PaymentInfo {
        public Long paymentId;
        public Long billId;
        public Long orderId;        // có thể null nếu bill gộp
        public BigDecimal amount;
        public String status;

        // mở rộng để show trong Payment.jsp
        public String method;           // CASH / ONLINE / ...
        public String provider;         // VNPAY / ...
        public String transactionId;    // mã giao dịch cổng
        public LocalDateTime paidAt;
        public Integer processedBy;
        public String paidChannelNote;

        // ===== GETTERs để JSP EL truy cập an toàn =====

        public Long getPaymentId() {
            return paymentId;
        }

        public Long getBillId() {
            return billId;
        }

        public Long getOrderId() {
            return orderId;
        }

        public BigDecimal getAmount() {
            return amount;
        }

        public String getStatus() {
            return status;
        }

        public String getMethod() {
            return method;
        }

        public String getProvider() {
            return provider;
        }

        public String getTransactionId() {
            return transactionId;
        }

        public LocalDateTime getPaidAt() {
            return paidAt;
        }

        public Integer getProcessedBy() {
            return processedBy;
        }

        public String getPaidChannelNote() {
            return paidChannelNote;
        }
    }

    /* =========================================================
     * 1. createPayment(...)
     *
     * Chức năng:
     *   - Ghi một khoản thanh toán mới cho bill
     *   - Nếu là tiền mặt (CASH) hoặc phần CASH của SPLIT:
     *         status = SUCCESS
     *         paid_at = NOW()
     *   - Nếu là phần cần VNPay:
     *         status = PENDING
     *         paid_at = NULL
     *
     * Thông thường được gọi trong cùng transaction với:
     *    - createBill(...)
     *    - insertBillItems(...)
     *    - closeOrder(...)
     *
     * Trả về payment_id vừa tạo.
     *
     * LƯU Ý:
     *   externalConn được truyền từ PaymentServlet,
     *   hàm KHÔNG tự commit/rollback.
     * ========================================================= */
    public Long createPayment(
            Connection externalConn,
            Long billId,
            Long orderId,
            String method,
            BigDecimal amount,
            String provider,
            String status,
            Integer processedBy,
            String paidChannelNote
    ) throws SQLException {

        BigDecimal safeAmount = (amount != null ? amount : BigDecimal.ZERO);

        // Nếu SUCCESS -> khách đã thanh toán xong khoản này ngay lập tức
        Timestamp paidAtTs = null;
        if (STATUS_SUCCESS.equalsIgnoreCase(status)) {
            paidAtTs = Timestamp.valueOf(LocalDateTime.now());
        }

        final String sql = """
            INSERT INTO payments (
                bill_id,
                method,
                amount,
                provider,
                transaction_id,
                status,
                paid_at,
                processed_by,
                order_id,
                paid_channel_note
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;

        try (PreparedStatement ps = externalConn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            // bill_id
            ps.setLong(1, billId);

            // method: "CASH", "ONLINE", ...
            ps.setString(2, method);

            // amount
            ps.setBigDecimal(3, safeAmount);

            // provider (vd: "VNPAY" cho QR)
            if (provider != null) {
                ps.setString(4, provider);
            } else {
                ps.setNull(4, Types.VARCHAR);
            }

            // transaction_id: lúc tạo payment ONLINE ban đầu chưa có -> null
            ps.setNull(5, Types.VARCHAR);

            // status: "SUCCESS" hoặc "PENDING"
            ps.setString(6, status);

            // paid_at
            if (paidAtTs != null) {
                ps.setTimestamp(7, paidAtTs);
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }

            // processed_by (thu ngân)
            if (processedBy != null) {
                ps.setInt(8, processedBy);
            } else {
                ps.setNull(8, Types.INTEGER);
            }

            // order_id:
            // với bill gộp bàn nhiều order -> null
            if (orderId != null) {
                ps.setLong(9, orderId);
            } else {
                ps.setNull(9, Types.BIGINT);
            }

            // paid_channel_note
            if (paidChannelNote != null) {
                ps.setString(10, paidChannelNote);
            } else {
                ps.setNull(10, Types.VARCHAR);
            }

            int rows = ps.executeUpdate();
            if (rows == 0) return null;

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
            }
        }

        return null;
    }

    /* =========================================================
     * 2. markPaymentSuccess(...)
     *
     * Gọi từ VnpayReturnServlet khi VNPay báo "vnp_ResponseCode=00".
     *
     * Cập nhật:
     *   - status = 'SUCCESS'
     *   - transaction_id = mã giao dịch VNPay trả về
     *   - paid_at = NOW()
     *
     * Trả về true nếu update > 0.
     * ========================================================= */
    public boolean markPaymentSuccess(Long paymentId, String transactionId) throws SQLException {
        final String sql = """
            UPDATE payments
            SET status = 'SUCCESS',
                transaction_id = ?,
                paid_at = ?
            WHERE payment_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, transactionId);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(3, paymentId);

            return ps.executeUpdate() > 0;
        }
    }

    /* =========================================================
     * 3. getPaymentInfo(...)
     *
     * Lấy thông tin cơ bản của một payment theo payment_id.
     * Dùng trong callback VNPay để biết payment này thuộc bill nào.
     *
     * Trả về PaymentInfo hoặc null nếu không tìm thấy.
     * ========================================================= */
    public PaymentInfo getPaymentInfo(Long paymentId) throws SQLException {
        final String sql = """
            SELECT payment_id,
                   bill_id,
                   order_id,
                   amount,
                   status
            FROM payments
            WHERE payment_id = ?
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, paymentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PaymentInfo info = new PaymentInfo();
                    info.paymentId = rs.getLong("payment_id");
                    info.billId    = rs.getLong("bill_id");
                    info.orderId   = (Long) rs.getObject("order_id"); // có thể null
                    info.amount    = rs.getBigDecimal("amount");
                    info.status    = rs.getString("status");
                    return info;
                }
            }
        }
        return null;
    }

    /* =========================================================
     * 4. findPendingPaymentForBill(...)
     *
     * Mục đích:
     *   - Khi bàn đang có bill PROFORMA (chờ VNPay),
     *     thu ngân reload Payment.jsp
     *     => ta KHÔNG muốn tạo bill mới nữa,
     *        mà tái sử dụng payment PENDING hiện có để tạo lại QR.
     *
     * Ở đây ta tìm 1 payment PENDING gần nhất của bill đó
     * với method trong ('ONLINE','VNPAY').
     *
     * Trả về PaymentInfo hoặc null nếu không có.
     * ========================================================= */
    public PaymentInfo findPendingPaymentForBill(Long billId) throws SQLException {
        final String sql = """
            SELECT TOP 1
                   payment_id,
                   bill_id,
                   order_id,
                   amount,
                   status
            FROM payments
            WHERE bill_id = ?
              AND status = 'PENDING'
              AND method IN ('ONLINE','VNPAY')
            ORDER BY payment_id DESC
        """;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, billId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PaymentInfo info = new PaymentInfo();
                    info.paymentId = rs.getLong("payment_id");
                    info.billId    = rs.getLong("bill_id");
                    info.orderId   = (Long) rs.getObject("order_id");
                    info.amount    = rs.getBigDecimal("amount");
                    info.status    = rs.getString("status");
                    return info;
                }
            }
        }

        return null;
    }

    /* =========================================================
     * 5. listPaymentsForBill(...)
     *
     * Mục đích:
     *   - Lấy toàn bộ lịch sử payments của bill
     *   - Để show trên Payment.jsp phần "Khoản thanh toán đã ghi nhận"
     *     bao gồm CASH SUCCESS, VNPay PENDING, VNPay SUCCESS,...
     *
     * Trả về List<PaymentInfo> (có thể rỗng).
     * ========================================================= */
    public List<PaymentInfo> listPaymentsForBill(Long billId) throws SQLException {
        final String sql = """
            SELECT payment_id,
                   bill_id,
                   order_id,
                   amount,
                   status,
                   method,
                   provider,
                   transaction_id,
                   paid_at,
                   processed_by,
                   paid_channel_note
            FROM payments
            WHERE bill_id = ?
            ORDER BY payment_id ASC
        """;

        List<PaymentInfo> list = new ArrayList<>();

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, billId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PaymentInfo info = new PaymentInfo();
                    info.paymentId       = rs.getLong("payment_id");
                    info.billId          = rs.getLong("bill_id");
                    info.orderId         = (Long) rs.getObject("order_id");
                    info.amount          = rs.getBigDecimal("amount");
                    info.status          = rs.getString("status");
                    info.method          = rs.getString("method");
                    info.provider        = rs.getString("provider");
                    info.transactionId   = rs.getString("transaction_id");

                    Timestamp paidTs    = rs.getTimestamp("paid_at");
                    info.paidAt         = (paidTs != null ? paidTs.toLocalDateTime() : null);

                    info.processedBy     = (Integer) rs.getObject("processed_by");
                    info.paidChannelNote = rs.getString("paid_channel_note");

                    list.add(info);
                }
            }
        }

        return list;
    }
}
