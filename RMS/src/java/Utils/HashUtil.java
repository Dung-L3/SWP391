/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Utils;
import org.mindrot.jbcrypt.BCrypt;
/**
 *
 * @author auiri
 */
public class HashUtil {
    public static String bcrypt(String raw) {
        return BCrypt.hashpw(raw, BCrypt.gensalt(12));
    }

    public static boolean verifyMixed(String raw, String stored) {
        if (stored == null) return false;
        if (stored.startsWith("$2a$") || stored.startsWith("$2y$") || stored.startsWith("$2b$")) {
            return BCrypt.checkpw(raw, stored);
        }
        // Legacy: hashCode
        return String.valueOf(raw.hashCode()).equals(stored);
    }
}
