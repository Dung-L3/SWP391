package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * RevenueReport - Model cho báo cáo doanh thu
 */
public class RevenueReport implements Serializable {
    private static final long serialVersionUID = 1L;

    // Thông tin filter
    private LocalDate reportDate;
    private Integer shiftId;
    private String shiftName; // "Ca sáng", "Ca chiều", etc.
    private Integer staffId;
    private String staffName;
    private String paymentMethod; // CASH, CARD, ONLINE, etc.
    private String orderType; // DINE_IN, TAKEAWAY, DELIVERY

    // Thống kê
    private int totalOrders;
    private BigDecimal totalRevenue;
    private BigDecimal totalSubtotal;
    private BigDecimal totalTax;
    private BigDecimal totalDiscount;
    private BigDecimal cashRevenue;
    private BigDecimal cardRevenue;
    private BigDecimal onlineRevenue;
    private BigDecimal transferRevenue;
    private BigDecimal voucherRevenue;

    // Chi tiết theo nhân viên (dùng trong báo cáo theo nhân viên)
    private int ordersByStaff;
    private BigDecimal revenueByStaff;

    // Chi tiết theo kênh (dùng trong báo cáo theo kênh)
    private int ordersByChannel;
    private BigDecimal revenueByChannel;

    // Constructors
    public RevenueReport() {}

    // Getters & Setters
    public LocalDate getReportDate() { return reportDate; }
    public void setReportDate(LocalDate reportDate) { this.reportDate = reportDate; }

    public Integer getShiftId() { return shiftId; }
    public void setShiftId(Integer shiftId) { this.shiftId = shiftId; }

    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }

    public Integer getStaffId() { return staffId; }
    public void setStaffId(Integer staffId) { this.staffId = staffId; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getOrderType() { return orderType; }
    public void setOrderType(String orderType) { this.orderType = orderType; }

    public int getTotalOrders() { return totalOrders; }
    public void setTotalOrders(int totalOrders) { this.totalOrders = totalOrders; }

    public BigDecimal getTotalRevenue() { return totalRevenue != null ? totalRevenue : BigDecimal.ZERO; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

    public BigDecimal getTotalSubtotal() { return totalSubtotal != null ? totalSubtotal : BigDecimal.ZERO; }
    public void setTotalSubtotal(BigDecimal totalSubtotal) { this.totalSubtotal = totalSubtotal; }

    public BigDecimal getTotalTax() { return totalTax != null ? totalTax : BigDecimal.ZERO; }
    public void setTotalTax(BigDecimal totalTax) { this.totalTax = totalTax; }

    public BigDecimal getTotalDiscount() { return totalDiscount != null ? totalDiscount : BigDecimal.ZERO; }
    public void setTotalDiscount(BigDecimal totalDiscount) { this.totalDiscount = totalDiscount; }

    public BigDecimal getCashRevenue() { return cashRevenue != null ? cashRevenue : BigDecimal.ZERO; }
    public void setCashRevenue(BigDecimal cashRevenue) { this.cashRevenue = cashRevenue; }

    public BigDecimal getCardRevenue() { return cardRevenue != null ? cardRevenue : BigDecimal.ZERO; }
    public void setCardRevenue(BigDecimal cardRevenue) { this.cardRevenue = cardRevenue; }

    public BigDecimal getOnlineRevenue() { return onlineRevenue != null ? onlineRevenue : BigDecimal.ZERO; }
    public void setOnlineRevenue(BigDecimal onlineRevenue) { this.onlineRevenue = onlineRevenue; }

    public BigDecimal getTransferRevenue() { return transferRevenue != null ? transferRevenue : BigDecimal.ZERO; }
    public void setTransferRevenue(BigDecimal transferRevenue) { this.transferRevenue = transferRevenue; }

    public BigDecimal getVoucherRevenue() { return voucherRevenue != null ? voucherRevenue : BigDecimal.ZERO; }
    public void setVoucherRevenue(BigDecimal voucherRevenue) { this.voucherRevenue = voucherRevenue; }

    public int getOrdersByStaff() { return ordersByStaff; }
    public void setOrdersByStaff(int ordersByStaff) { this.ordersByStaff = ordersByStaff; }

    public BigDecimal getRevenueByStaff() { return revenueByStaff != null ? revenueByStaff : BigDecimal.ZERO; }
    public void setRevenueByStaff(BigDecimal revenueByStaff) { this.revenueByStaff = revenueByStaff; }

    public int getOrdersByChannel() { return ordersByChannel; }
    public void setOrdersByChannel(int ordersByChannel) { this.ordersByChannel = ordersByChannel; }

    public BigDecimal getRevenueByChannel() { return revenueByChannel != null ? revenueByChannel : BigDecimal.ZERO; }
    public void setRevenueByChannel(BigDecimal revenueByChannel) { this.revenueByChannel = revenueByChannel; }

    // Helper methods
    public String getPaymentMethodDisplay() {
        if (paymentMethod == null) return "Tất cả";
        switch (paymentMethod) {
            case "CASH": return "Tiền mặt";
            case "CARD": return "Thẻ";
            case "ONLINE": return "Online";
            case "TRANSFER": return "Chuyển khoản";
            case "VOUCHER": return "Voucher";
            default: return paymentMethod;
        }
    }

    public String getOrderTypeDisplay() {
        if (orderType == null) return "Tất cả";
        switch (orderType) {
            case "DINE_IN": return "Tại bàn";
            case "TAKEAWAY": return "Mang đi";
            case "DELIVERY": return "Giao hàng";
            default: return orderType;
        }
    }
}

