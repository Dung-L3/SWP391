package Utils;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.TreeMap;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 * VnpayService
 *
 * - buildPaymentUrl(...) -> tạo link redirect sang sandbox VNPAY -
 * verifyReturn(...) -> xác thực callback từ VNPAY khi quay về
 * VnpayReturnServlet
 *
 * vnp_TxnRef = paymentId (payment_id trong DB)
 */
public class VnpayService {

    // TODO: CẬP NHẬT 3 HẰNG NÀY CHO ĐÚNG
    private static final String VNP_TMN_CODE = "XKD277RE";
    private static final String VNP_HASH_SECRET = "4PCBERBIQT3XB29N1UOYYM6Y55MJDYAR";
    private static final String VNP_RETURN_URL = "http://localhost:9999/RMS/VnpayReturnServlet";

    // Hằng số chuẩn sandbox VNPAY
    private static final String VNP_PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    private static final String VNP_VERSION = "2.1.0";
    private static final String VNP_COMMAND = "pay";
    private static final String VNP_CURRENCY = "VND";
    private static final String VNP_LOCALE = "vn";
    private static final String VNP_ORDER_TYPE = "billpayment";

    /**
     * Tạo URL thanh toán VNPAY
     *
     * @param paymentId payment_id trong bảng payments
     * @param amount số tiền cần thanh toán qua VNPAY (remaining)
     * @param clientIp IP của client (req.getRemoteAddr)
     */
    public static String buildPaymentUrl(Long paymentId,
            BigDecimal amount,
            String clientIp) {

        if (clientIp == null || clientIp.isBlank()) {
            clientIp = "127.0.0.1";
        }

        // VNPay yêu cầu vnp_Amount = số tiền * 100
        long vnpAmount = amount
                .multiply(new BigDecimal("100"))
                .longValue();

        String createDate = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));

        // Gom tham số vào TreeMap để sort ASC
        Map<String, String> vnpParams = new TreeMap<>();
        vnpParams.put("vnp_Version", VNP_VERSION);
        vnpParams.put("vnp_Command", VNP_COMMAND);
        vnpParams.put("vnp_TmnCode", VNP_TMN_CODE);
        vnpParams.put("vnp_Amount", String.valueOf(vnpAmount));
        vnpParams.put("vnp_CurrCode", VNP_CURRENCY);
        vnpParams.put("vnp_TxnRef", String.valueOf(paymentId));
        vnpParams.put("vnp_OrderInfo", "Thanh toan bill RMS #" + paymentId);
        vnpParams.put("vnp_OrderType", VNP_ORDER_TYPE);
        vnpParams.put("vnp_Locale", VNP_LOCALE);
        vnpParams.put("vnp_ReturnUrl", VNP_RETURN_URL);
        vnpParams.put("vnp_IpAddr", clientIp);
        vnpParams.put("vnp_CreateDate", createDate);

        // build query chưa hash
        String query = buildQueryString(vnpParams);

        // ký HMAC SHA512
        String secureHash = hmacSHA512(VNP_HASH_SECRET, query);

        // trả URL đầy đủ
        return VNP_PAY_URL
                + "?"
                + query
                + "&vnp_SecureHash=" + urlEncode(secureHash);
    }

    /**
     * Xác thực callback từ VNPAY.
     *
     * @param allParams Map<String,String> chứa tất cả vnp_* param trả về
     * @param receivedHash vnp_SecureHash trả về
     */
    public static boolean verifyReturn(Map<String, String> allParams,
            String receivedHash) {

        if (receivedHash == null || receivedHash.isBlank()) {
            return false;
        }

        // Lọc param, bỏ vnp_SecureHash / vnp_SecureHashType
        Map<String, String> sorted = new TreeMap<>();
        for (Map.Entry<String, String> e : allParams.entrySet()) {
            String k = e.getKey();
            if ("vnp_SecureHash".equalsIgnoreCase(k)
                    || "vnp_SecureHashType".equalsIgnoreCase(k)) {
                continue;
            }
            sorted.put(k, e.getValue());
        }

        // build chuỗi để ký
        String dataToSign = buildQueryString(sorted);

        // ký lại
        String calcHash = hmacSHA512(VNP_HASH_SECRET, dataToSign);

        // so sánh không phân biệt hoa thường
        return calcHash.equalsIgnoreCase(receivedHash);
    }

    // -------------------------------------------------
    // Helpers nội bộ
    // -------------------------------------------------
    private static String buildQueryString(Map<String, String> params) {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> e : params.entrySet()) {
            if (sb.length() > 0) {
                sb.append("&");
            }
            sb.append(urlEncode(e.getKey()))
                    .append("=")
                    .append(urlEncode(e.getValue()));
        }
        return sb.toString();
    }

    private static String urlEncode(String s) {
        try {
            return URLEncoder.encode(s, StandardCharsets.UTF_8.toString());
        } catch (Exception ex) {
            return s;
        }
    }

    private static String hmacSHA512(String secret, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));

            StringBuilder sb = new StringBuilder();
            for (byte b : raw) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Lỗi ký HMAC SHA512 cho VNPay", e);
        }
    }
}
