package Utils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

public class OrderCodeGenerator {
    private static final String PREFIX = "TO"; // TO = Takeaway Order
    private static final Random random = new Random();
    
    public static String generate() {
        LocalDateTime now = LocalDateTime.now();
        String date = now.format(DateTimeFormatter.ofPattern("yyMMdd"));
        String randomPart = String.format("%04d", random.nextInt(10000));
        return PREFIX + date + randomPart;
    }
}