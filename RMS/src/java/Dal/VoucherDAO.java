package Dal;

import Models.Voucher;
import Models.VoucherRedemption;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * VoucherDAO for voucher management and validation
 */
public class VoucherDAO {

    /**
     * Get paginated vouchers with search and filter
     */
    public List<Voucher> getVouchers(int page, int pageSize, String search, String status, String sortBy) {
        List<Voucher> vouchers = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        
        sql.append("SELECT v.voucher_id, v.code, v.description, v.discount_type, v.discount_value, ");
        sql.append("v.valid_from, v.valid_to, v.usage_limit, v.min_order_total, v.status, v.created_by, ");
        sql.append("u.first_name + ' ' + u.last_name as created_by_name, ");
        sql.append("(SELECT COUNT(*) FROM voucher_redemptions WHERE voucher_id = v.voucher_id) as times_used ");
        sql.append("FROM vouchers v ");
        sql.append("LEFT JOIN users u ON v.created_by = u.user_id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        // Search filter
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (v.code LIKE ? OR v.description LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        // Status filter
        if (status != null && !status.isEmpty() && !"ALL".equals(status)) {
            sql.append("AND v.status = ? ");
            params.add(status);
        }

        // Sorting
        if (sortBy != null && !sortBy.isEmpty()) {
            switch (sortBy) {
                case "code_asc":
                    sql.append("ORDER BY v.code ASC ");
                    break;
                case "code_desc":
                    sql.append("ORDER BY v.code DESC ");
                    break;
                case "value_asc":
                    sql.append("ORDER BY v.discount_value ASC ");
                    break;
                case "value_desc":
                    sql.append("ORDER BY v.discount_value DESC ");
                    break;
                case "expiry":
                    sql.append("ORDER BY v.valid_to ASC ");
                    break;
                default:
                    sql.append("ORDER BY v.voucher_id DESC ");
            }
        } else {
            sql.append("ORDER BY v.voucher_id DESC ");
        }

        // Pagination
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Voucher voucher = mapResultSetToVoucher(rs);
                    vouchers.add(voucher);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return vouchers;
    }

    /**
     * Get total count for pagination
     */
    public int getTotalVouchersCount(String search, String status) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM vouchers v WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (v.code LIKE ? OR v.description LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (status != null && !status.isEmpty() && !"ALL".equals(status)) {
            sql.append("AND v.status = ? ");
            params.add(status);
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Get voucher by ID
     */
    public Voucher getVoucherById(int voucherId) {
        String sql = "SELECT v.voucher_id, v.code, v.description, v.discount_type, v.discount_value, " +
                    "v.valid_from, v.valid_to, v.usage_limit, v.min_order_total, v.status, v.created_by, " +
                    "u.first_name + ' ' + u.last_name as created_by_name, " +
                    "(SELECT COUNT(*) FROM voucher_redemptions WHERE voucher_id = v.voucher_id) as times_used " +
                    "FROM vouchers v " +
                    "LEFT JOIN users u ON v.created_by = u.user_id " +
                    "WHERE v.voucher_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, voucherId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVoucher(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get voucher by code
     */
    public Voucher getVoucherByCode(String code) {
        String sql = "SELECT v.voucher_id, v.code, v.description, v.discount_type, v.discount_value, " +
                    "v.valid_from, v.valid_to, v.usage_limit, v.min_order_total, v.status, v.created_by, " +
                    "u.first_name + ' ' + u.last_name as created_by_name, " +
                    "(SELECT COUNT(*) FROM voucher_redemptions WHERE voucher_id = v.voucher_id) as times_used " +
                    "FROM vouchers v " +
                    "LEFT JOIN users u ON v.created_by = u.user_id " +
                    "WHERE v.code = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVoucher(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Create new voucher
     */
    public boolean createVoucher(Voucher voucher) {
        String sql = "INSERT INTO vouchers (code, description, discount_type, discount_value, " +
                    "valid_from, valid_to, usage_limit, min_order_total, status, created_by) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, voucher.getCode());
            ps.setString(2, voucher.getDescription());
            ps.setString(3, voucher.getDiscountType());
            ps.setBigDecimal(4, voucher.getDiscountValue());
            ps.setObject(5, voucher.getValidFrom());
            ps.setObject(6, voucher.getValidTo());
            ps.setObject(7, voucher.getUsageLimit());
            ps.setBigDecimal(8, voucher.getMinOrderTotal());
            ps.setString(9, voucher.getStatus());
            ps.setInt(10, voucher.getCreatedBy());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update voucher
     */
    public boolean updateVoucher(Voucher voucher) {
        String sql = "UPDATE vouchers SET code = ?, description = ?, discount_type = ?, " +
                    "discount_value = ?, valid_from = ?, valid_to = ?, usage_limit = ?, " +
                    "min_order_total = ?, status = ? WHERE voucher_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, voucher.getCode());
            ps.setString(2, voucher.getDescription());
            ps.setString(3, voucher.getDiscountType());
            ps.setBigDecimal(4, voucher.getDiscountValue());
            ps.setObject(5, voucher.getValidFrom());
            ps.setObject(6, voucher.getValidTo());
            ps.setObject(7, voucher.getUsageLimit());
            ps.setBigDecimal(8, voucher.getMinOrderTotal());
            ps.setString(9, voucher.getStatus());
            ps.setInt(10, voucher.getVoucherId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete voucher (set status = INACTIVE)
     */
    public boolean deleteVoucher(int voucherId) {
        String sql = "UPDATE vouchers SET status = 'INACTIVE' WHERE voucher_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, voucherId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if customer has used voucher (max 2 times allowed)
     */
    public int getCustomerVoucherUsageCount(int voucherId, int customerId) {
        String sql = "SELECT COUNT(*) FROM voucher_redemptions " +
                    "WHERE voucher_id = ? AND customer_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, voucherId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Validate voucher for a bill
     * Returns error message if invalid, null if valid
     */
    public String validateVoucher(String code, BigDecimal orderTotal, Integer customerId) {
        Voucher voucher = getVoucherByCode(code);

        // Check if voucher exists
        if (voucher == null) {
            return "Mã voucher không tồn tại.";
        }

        // Check if active
        if (!"ACTIVE".equals(voucher.getStatus())) {
            return "Voucher đã bị vô hiệu hóa.";
        }

        // Check validity period
        LocalDate today = LocalDate.now();
        if (voucher.getValidFrom() != null && today.isBefore(voucher.getValidFrom())) {
            return "Voucher chưa đến ngày áp dụng.";
        }
        if (voucher.getValidTo() != null && today.isAfter(voucher.getValidTo())) {
            return "Voucher đã hết hạn.";
        }

        // Check usage limit
        if (voucher.getUsageLimit() != null && voucher.getTimesUsed() >= voucher.getUsageLimit()) {
            return "Voucher đã hết lượt sử dụng.";
        }

        // Check minimum order total
        if (orderTotal.compareTo(voucher.getMinOrderTotal()) < 0) {
            return String.format("Đơn hàng tối thiểu %,.0f đ để sử dụng voucher này.", 
                               voucher.getMinOrderTotal().doubleValue());
        }

        // Check customer usage limit (max 2 times)
        if (customerId != null) {
            int customerUsage = getCustomerVoucherUsageCount(voucher.getVoucherId(), customerId);
            if (customerUsage >= 2) {
                return "Bạn đã sử dụng voucher này đủ 2 lần.";
            }
        }

        return null; // Valid
    }

    /**
     * Calculate discount amount for a voucher
     */
    public BigDecimal calculateDiscount(Voucher voucher, BigDecimal orderTotal) {
        if ("PERCENT".equals(voucher.getDiscountType())) {
            // Calculate percentage discount
            BigDecimal discount = orderTotal.multiply(voucher.getDiscountValue())
                                           .divide(new BigDecimal("100"));
            return discount;
        } else {
            // Fixed amount discount
            return voucher.getDiscountValue();
        }
    }

    /**
     * Record voucher redemption
     */
    public boolean recordRedemption(int voucherId, Integer customerId, Long billId, BigDecimal amount) {
        String sql = "INSERT INTO voucher_redemptions (voucher_id, customer_id, bill_id, amount, redeemed_at) " +
                    "VALUES (?, ?, ?, ?, GETDATE())";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, voucherId);
            ps.setObject(2, customerId);
            ps.setObject(3, billId);
            ps.setBigDecimal(4, amount);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get voucher redemption history
     */
    public List<VoucherRedemption> getRedemptionHistory(int voucherId, int page, int pageSize) {
        List<VoucherRedemption> redemptions = new ArrayList<>();
        String sql = "SELECT vr.redemption_id, vr.voucher_id, vr.customer_id, vr.bill_id, " +
                    "vr.redeemed_at, vr.amount, v.code as voucher_code, " +
                    "c.full_name as customer_name, b.bill_no " +
                    "FROM voucher_redemptions vr " +
                    "LEFT JOIN vouchers v ON vr.voucher_id = v.voucher_id " +
                    "LEFT JOIN customers c ON vr.customer_id = c.customer_id " +
                    "LEFT JOIN bills b ON vr.bill_id = b.bill_id " +
                    "WHERE vr.voucher_id = ? " +
                    "ORDER BY vr.redeemed_at DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, voucherId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VoucherRedemption redemption = new VoucherRedemption();
                    redemption.setRedemptionId(rs.getLong("redemption_id"));
                    redemption.setVoucherId(rs.getInt("voucher_id"));
                    redemption.setCustomerId((Integer) rs.getObject("customer_id"));
                    redemption.setBillId((Long) rs.getObject("bill_id"));
                    
                    Timestamp redeemedAt = rs.getTimestamp("redeemed_at");
                    if (redeemedAt != null) {
                        redemption.setRedeemedAt(redeemedAt.toLocalDateTime());
                    }
                    
                    redemption.setAmount(rs.getBigDecimal("amount"));
                    redemption.setVoucherCode(rs.getString("voucher_code"));
                    redemption.setCustomerName(rs.getString("customer_name"));
                    redemption.setBillNo(rs.getString("bill_no"));
                    
                    redemptions.add(redemption);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return redemptions;
    }

    /**
     * Check if voucher code already exists
     */
    public boolean isCodeExists(String code, Integer excludeVoucherId) {
        String sql = "SELECT COUNT(*) FROM vouchers WHERE code = ?";
        if (excludeVoucherId != null) {
            sql += " AND voucher_id != ?";
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code);
            if (excludeVoucherId != null) {
                ps.setInt(2, excludeVoucherId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Map ResultSet to Voucher
     */
    private Voucher mapResultSetToVoucher(ResultSet rs) throws SQLException {
        Voucher voucher = new Voucher();
        
        voucher.setVoucherId(rs.getInt("voucher_id"));
        voucher.setCode(rs.getString("code"));
        voucher.setDescription(rs.getString("description"));
        voucher.setDiscountType(rs.getString("discount_type"));
        voucher.setDiscountValue(rs.getBigDecimal("discount_value"));
        
        Date validFrom = rs.getDate("valid_from");
        if (validFrom != null) {
            voucher.setValidFrom(validFrom.toLocalDate());
        }
        
        Date validTo = rs.getDate("valid_to");
        if (validTo != null) {
            voucher.setValidTo(validTo.toLocalDate());
        }
        
        voucher.setUsageLimit((Integer) rs.getObject("usage_limit"));
        voucher.setMinOrderTotal(rs.getBigDecimal("min_order_total"));
        voucher.setStatus(rs.getString("status"));
        voucher.setCreatedBy(rs.getInt("created_by"));
        voucher.setCreatedByName(rs.getString("created_by_name"));
        voucher.setTimesUsed(rs.getInt("times_used"));
        
        // Calculate remaining uses
        if (voucher.getUsageLimit() != null) {
            voucher.setRemainingUses(voucher.getUsageLimit() - voucher.getTimesUsed());
        } else {
            voucher.setRemainingUses(-1); // Unlimited
        }
        
        return voucher;
    }
}

