package Utils;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * OTPUtil: Tạo OTP ngẫu nhiên (số) và Token bảo mật (URL-safe)
 * Dùng cho xác thực quên mật khẩu, kích hoạt tài khoản, v.v.
 */
public class OTPUtil {

    private static final SecureRandom RANDOM = new SecureRandom();

    
    public static String generateNumericOtp(int digits) {
        if (digits <= 0) throw new IllegalArgumentException("digits phải > 0");
        int bound = (int) Math.pow(10, digits);
        int n = RANDOM.nextInt(bound);
        return String.format("%0" + digits + "d", n);
    }

    /**
     * Tạo token ngẫu nhiên dạng URL-safe Base64
     */
    public static String generateToken(int byteLength) {
        if (byteLength <= 0) throw new IllegalArgumentException("byteLength phải > 0");
        byte[] buf = new byte[byteLength];
        RANDOM.nextBytes(buf);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(buf);
    }
}
