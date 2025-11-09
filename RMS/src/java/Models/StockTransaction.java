package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * StockTransaction - Giao dịch nhập/xuất kho
 */
public class StockTransaction implements Serializable {
    private static final long serialVersionUID = 1L;

    private long stockTxnId;
    private int itemId;
    private String txnType;        // IN, OUT, USAGE, WASTE, ADJUSTMENT, RETURN
    private BigDecimal quantity;
    private BigDecimal unitCost;
    private LocalDateTime txnTime;
    private String refType;        // ORDER, PURCHASE, MANUAL, v.v.
    private Long refId;            // ID tham chiếu (order_id, purchase_id, v.v.)
    private String note;

    // Join fields
    private String itemName;
    private String uom;

    // Constants
    public static final String TYPE_IN = "IN";               // Nhập kho
    public static final String TYPE_OUT = "OUT";             // Xuất kho
    public static final String TYPE_USAGE = "USAGE";         // Sử dụng (chế biến món)
    public static final String TYPE_WASTE = "WASTE";         // Hao hụt/hỏng
    public static final String TYPE_ADJUSTMENT = "ADJUSTMENT"; // Điều chỉnh (kiểm kê)
    public static final String TYPE_RETURN = "RETURN";       // Trả hàng

    // Constructors
    public StockTransaction() {}

    public StockTransaction(int itemId, String txnType, BigDecimal quantity, BigDecimal unitCost) {
        this.itemId = itemId;
        this.txnType = txnType;
        this.quantity = quantity;
        this.unitCost = unitCost;
        this.txnTime = LocalDateTime.now();
    }

    // Getters & Setters
    public long getStockTxnId() { return stockTxnId; }
    public void setStockTxnId(long stockTxnId) { this.stockTxnId = stockTxnId; }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public String getTxnType() { return txnType; }
    public void setTxnType(String txnType) { this.txnType = txnType; }

    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }

    public BigDecimal getUnitCost() { return unitCost; }
    public void setUnitCost(BigDecimal unitCost) { this.unitCost = unitCost; }

    public LocalDateTime getTxnTime() { return txnTime; }
    public void setTxnTime(LocalDateTime txnTime) { this.txnTime = txnTime; }

    public String getRefType() { return refType; }
    public void setRefType(String refType) { this.refType = refType; }

    public Long getRefId() { return refId; }
    public void setRefId(Long refId) { this.refId = refId; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getUom() { return uom; }
    public void setUom(String uom) { this.uom = uom; }

    @Override
    public String toString() {
        return "StockTransaction{" +
                "stockTxnId=" + stockTxnId +
                ", itemId=" + itemId +
                ", txnType='" + txnType + '\'' +
                ", quantity=" + quantity +
                ", txnTime=" + txnTime +
                '}';
    }
}

