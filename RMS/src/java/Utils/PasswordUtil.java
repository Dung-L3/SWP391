package Utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordUtil {

    private static final String ALGO = "SHA-256";
    private static final int SALT_LENGTH = 16;
    private static final SecureRandom RNG = new SecureRandom();

    /** Tạo hash theo chuẩn dự án: "saltB64:hashB64" với SHA-256(salt || password). */
    public static String hashPassword(String rawPassword) {
        String saltB64 = generateSaltB64();
        String hashB64 = sha256SaltedB64(rawPassword, saltB64);
        return saltB64 + ":" + hashB64;
    }

    /** Kiểm tra password với nhiều định dạng hash (BCrypt / saltB64:hashB64 / SHA256-hex / legacy-hashCode / plain). */
    public static boolean matches(String rawPassword, String stored) {
        if (rawPassword == null || stored == null) return false;

        // 1) BCrypt ($2a/$2b/$2y)
        if (stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$")) {
            try {
                return org.mindrot.jbcrypt.BCrypt.checkpw(rawPassword, stored);
            } catch (Throwable ignore) {
                // rơi xuống các nhánh khác nếu thư viện không có
            }
        }

        // 2) Định dạng chuẩn của dự án: "saltB64:hashB64"
        String[] parts = stored.split(":");
        if (parts.length == 2 && isBase64(parts[0]) && isBase64(parts[1])) {
            String calc = sha256SaltedB64(rawPassword, parts[0]);
            return constantTimeEq(parts[1].getBytes(StandardCharsets.US_ASCII),
                                  calc.getBytes(StandardCharsets.US_ASCII));
        }

        // 3) SHA-256 hex (64 ký tự)
        if (stored.matches("^[0-9a-fA-F]{64}$")) {
            String hex = sha256Hex(rawPassword);
            return constantTimeEq(stored.getBytes(StandardCharsets.US_ASCII),
                                  hex.getBytes(StandardCharsets.US_ASCII));
        }

        // 4) LEGACY: String.hashCode() (số nguyên, có thể âm)
        if (isLegacyHashCode(stored)) {
            String legacy = String.valueOf(rawPassword.hashCode());
            return constantTimeEq(stored.getBytes(StandardCharsets.US_ASCII),
                                  legacy.getBytes(StandardCharsets.US_ASCII));
        }

        // 5) Fallback: so sánh thô (chỉ dùng khi DB đang lưu plain-text)
        return rawPassword.equals(stored);
    }

    /** Cho biết hash có phải legacy (nên nâng cấp) không. */
    public static boolean isLegacy(String stored) {
        if (stored == null) return true;
        // legacy khi là hashCode int hoặc SHA-256 hex (muốn chuyển hết về chuẩn saltB64:hashB64)
        return isLegacyHashCode(stored) || stored.matches("^[0-9a-fA-F]{64}$");
    }

    /**
     * Nếu hash là legacy và rawPassword đúng, trả về hash mới theo chuẩn dự án để cập nhật DB.
     * Nếu không cần nâng cấp, trả về null.
     */
    public static String maybeUpgrade(String rawPassword, String stored) {
        if (rawPassword == null || stored == null) return null;
        if (isLegacy(stored) && matches(rawPassword, stored)) {
            return hashPassword(rawPassword); // chuẩn "saltB64:hashB64"
        }
        return null;
    }

    /* ----------------------- Helpers ----------------------- */

    private static String generateSaltB64() {
        byte[] salt = new byte[SALT_LENGTH];
        RNG.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    private static String sha256SaltedB64(String raw, String saltB64) {
        try {
            MessageDigest md = MessageDigest.getInstance(ALGO);
            md.update(Base64.getDecoder().decode(saltB64));
            byte[] out = md.digest(raw.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(out);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    private static String sha256Hex(String raw) {
        try {
            MessageDigest md = MessageDigest.getInstance(ALGO);
            byte[] out = md.digest(raw.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(out.length * 2);
            for (byte b : out) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    private static boolean isBase64(String s) {
        try {
            Base64.getDecoder().decode(s);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    /** Legacy: nhận biết chuỗi là số nguyên (tối đa 10 chữ số, có thể âm) – đúng với String.hashCode(). */
    private static boolean isLegacyHashCode(String stored) {
        return stored.matches("^-?\\d{1,10}$");
    }

    /** So sánh constant-time để tránh timing attack. */
    private static boolean constantTimeEq(byte[] a, byte[] b) {
        if (a == null || b == null) return false;
        int len = Math.max(a.length, b.length);
        int diff = 0;
        for (int i = 0; i < len; i++) {
            byte aa = i < a.length ? a[i] : 0;
            byte bb = i < b.length ? b[i] : 0;
            diff |= (aa ^ bb);
        }
        return diff == 0 && a.length == b.length;
    }

    /** Mật khẩu mặc định (nếu cần). */
    public static String generateDefaultPassword() { return "Staff@123"; }
}
