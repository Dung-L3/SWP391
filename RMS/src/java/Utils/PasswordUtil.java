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

    /** Tạo "saltB64:hashB64" bằng SHA-256(salt||password). */
    public static String hashPassword(String rawPassword) {
        String saltB64 = generateSaltB64();
        String hashB64 = sha256SaltedB64(rawPassword, saltB64);
        return saltB64 + ":" + hashB64;
    }

    /** Kiểm tra password với nhiều định dạng: 
     */
    public static boolean matches(String rawPassword, String stored) {
        if (rawPassword == null || stored == null) return false;

        // 1) BCrypt
        if (stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$")) {
            try {
                return org.mindrot.jbcrypt.BCrypt.checkpw(rawPassword, stored);
            } catch (Throwable ignore) { }
        }

        //"saltB64:hashB64"
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
        return rawPassword.equals(stored);
    }

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
        try { Base64.getDecoder().decode(s); return true; } catch (IllegalArgumentException e) { return false; }
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

    /* Giữ lại nếu bạn cần password mặc định */
    public static String generateDefaultPassword() { return "Staff@123"; }
}
