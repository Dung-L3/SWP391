package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class Order implements Serializable {
    private static final long serialVersionUID = 1L;

    // ==========================
    // Loại order
    // ==========================
    public static final String TYPE_DINE_IN   = "DINE_IN";
    public static final String TYPE_TAKEAWAY  = "TAKEAWAY";
    public static final String TYPE_DELIVERY  = "DELIVERY";

    // ==========================
    // Trạng thái order (lifecycle)
    // ==========================
    //
    // NEW        : vừa tạo, chưa gửi bếp (chỉ có trên giấy tạm thời)
    // DINING     : khách đang ăn/uống, món đang được làm hoặc đang phục vụ
    // COOKING    : đã gửi xuống bếp, bếp đang nấu (có thể bạn dùng trong KDS)
    // READY      : toàn bộ món đã READY từ bếp (chưa chắc đã bưng ra)
    // SERVED     : tất cả món trong order đã được bưng ra bàn (order gọi xong)
    // SETTLED    : đã thanh toán (đóng bill, không còn nợ)
    // CANCELLED  : order bị huỷ
    //
    // Lưu ý:
    //  - Ở màn OrderServlet khi tạo order mới, ta set status = DINING
    //    để ReceptionServlet hiểu là bàn đang phục vụ ("Đang phục vụ").
    //  - ReceptionServlet coi bàn READY_TO_PAY khi toàn bộ món trong
    //    các order chưa SETTLED đều đã SERVED.
    //
    public static final String STATUS_NEW              = "NEW";
    public static final String STATUS_DINING           = "DINING";          // <-- thêm cho lễ tân
    public static final String STATUS_OPEN             = "OPEN";            // vẫn giữ để tương thích DAO cũ
    public static final String STATUS_SENT_TO_KITCHEN  = "SENT_TO_KITCHEN";
    public static final String STATUS_COOKING          = "COOKING";
    public static final String STATUS_PARTIAL_READY    = "PARTIAL_READY";
    public static final String STATUS_READY            = "READY";
    public static final String STATUS_SERVED           = "SERVED";
    public static final String STATUS_CANCELLED        = "CANCELLED";
    public static final String STATUS_SETTLED          = "SETTLED";

    // ==========================
    // Fields map với DB
    // ==========================
    private Long orderId;
    private String orderCode;

    private String orderType;           // TYPE_DINE_IN / TAKEAWAY / DELIVERY
    private Integer tableId;
    private Integer waiterId;
    private Integer customerId;
    private String status;              // dùng các STATUS_* ở trên

    // Tổng tiền snapshot trong bảng orders
    private BigDecimal subtotal;        // subtotal
    private BigDecimal taxAmount;       // tax_amount
    private BigDecimal discountAmount;  // discount_amount
    private BigDecimal totalAmount;     // total_amount

    private String specialInstructions; // notes
    private LocalDateTime openedAt;     // opened_at
    private LocalDateTime closedAt;     // closed_at

    // Thông tin join tiện cho UI
    private String tableNumber;
    private String waiterName;

    // Danh sách món thuộc order (không phải cột thật trong orders)
    private List<OrderItem> orderItems;

    // ==========================
    // Constructors
    // ==========================
    public Order() {
        // default
    }

    // dùng khi tạo order mới từ servlet gọi món
    public Order(String orderType, Integer tableId, Integer waiterId) {
        this.orderType = orderType;
        this.tableId = tableId;
        this.waiterId = waiterId;

        // Khi order vừa mở bàn, ta coi là khách đang ngồi ăn -> DINING
        // (để ReceptionServlet hiển thị "Đang phục vụ")
        this.status = STATUS_DINING;

        this.subtotal = BigDecimal.ZERO;
        this.taxAmount = BigDecimal.ZERO;
        this.discountAmount = BigDecimal.ZERO;
        this.totalAmount = BigDecimal.ZERO;
    }

    // ==========================
    // Getters / Setters
    // ==========================
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }

    public String getOrderType() { return orderType; }
    public void setOrderType(String orderType) { this.orderType = orderType; }

    public Integer getTableId() { return tableId; }
    public void setTableId(Integer tableId) { this.tableId = tableId; }

    public Integer getWaiterId() { return waiterId; }
    public void setWaiterId(Integer waiterId) { this.waiterId = waiterId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getSpecialInstructions() { return specialInstructions; }
    public void setSpecialInstructions(String specialInstructions) { this.specialInstructions = specialInstructions; }

    public LocalDateTime getOpenedAt() { return openedAt; }
    public void setOpenedAt(LocalDateTime openedAt) { this.openedAt = openedAt; }

    public LocalDateTime getClosedAt() { return closedAt; }
    public void setClosedAt(LocalDateTime closedAt) { this.closedAt = closedAt; }

    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }

    public String getWaiterName() { return waiterName; }
    public void setWaiterName(String waiterName) { this.waiterName = waiterName; }

    public List<OrderItem> getOrderItems() { return orderItems; }
    public void setOrderItems(List<OrderItem> orderItems) { this.orderItems = orderItems; }
    public Integer getCustomerId() { return customerId; }
    public void setCustomerId(Integer customerId) { this.customerId = customerId; }

    // ==========================
    // Helper
    // ==========================
    public boolean isSettled() {
        return STATUS_SETTLED.equalsIgnoreCase(status);
    }
}
