package Controller.auth;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpSession;
import java.io.UnsupportedEncodingException;
import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public class EmailServices {
    private final String host, user, pass, from;
    private final int port;
    private final ServletContext context;

    public EmailServices(ServletContext ctx) {
        this.context = ctx;
        this.host = ctx.getInitParameter("smtp.host");
        this.user = ctx.getInitParameter("smtp.username");
        this.pass = ctx.getInitParameter("smtp.password");
        this.from = ctx.getInitParameter("smtp.from");
        this.port = Integer.parseInt(ctx.getInitParameter("smtp.port"));
    }

    public void sendReservationConfirmationFromSession(HttpSession session, String confirmationCode, String date, String time, int numOfPeople, String tableId) throws MessagingException {
        String email = (String) session.getAttribute("reservationEmail");
        String customerName = (String) session.getAttribute("reservationCustomerName");
        
        if (email == null || customerName == null) {
            throw new MessagingException("Không tìm thấy thông tin email trong session");
        }
        
        sendReservationConfirmation(email, confirmationCode, customerName, date, time, numOfPeople, tableId);
    }

    public void sendResetMail(String to, String link, String otp) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", String.valueOf(port));

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, pass);
            }
        });

        String subject = "[Restoran] Đặt lại mật khẩu";
        String content = "Mã OTP của bạn là: " + otp + "\nNhấn vào đường dẫn sau để xác thực:\n" + link;

        MimeMessage msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(from));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        msg.setSubject(subject, "UTF-8");
        msg.setText(content, "UTF-8");
        Transport.send(msg);
    }

    public void sendReservationCancellation(String to, String confirmationCode, String customerName, 
            String date, String time, int numOfPeople) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", String.valueOf(port));
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, pass);
            }
        });

        String subject = "[Restoran] Xác nhận hủy đặt bàn";
        String content = "Kính gửi " + customerName + ",\n\n"
                + "Chúng tôi xác nhận rằng đơn đặt bàn của quý khách đã được hủy thành công.\n\n"
                + "Chi tiết đặt bàn đã hủy:\n"
                + "- Mã đặt bàn: " + confirmationCode + "\n"
                + "- Ngày: " + date + "\n"
                + "- Giờ: " + time + "\n"
                + "- Số người: " + numOfPeople + "\n\n"
                + "Cảm ơn quý khách đã thông báo. Chúng tôi hy vọng sẽ được phục vụ quý khách trong thời gian tới.\n\n"
                + "Trân trọng,\n"
                + "Restoran";

        MimeMessage msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(from));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        msg.setSubject(subject, "UTF-8");
        msg.setText(content, "UTF-8");
        Transport.send(msg);
    }

    public void sendReservationConfirmation(String to, String confirmationCode, String customerName, String date, String time, int numOfPeople, String tableId) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", String.valueOf(port));
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, pass);
            }
        });

        String emailEncoded;
        try {
            emailEncoded = URLEncoder.encode(to, StandardCharsets.UTF_8.toString());
        } catch (UnsupportedEncodingException e) {
            // Fallback to basic URL encoding if UTF-8 is not supported
            emailEncoded = to.replace("@", "%40");
        }
        String cancelLink = "http://localhost:9999/RMS/cancel-reservation?code=" + confirmationCode + "&email=" + emailEncoded;
        String subject = "[Restoran] Xác nhận đặt bàn thành công";
        String content = "Kính gửi " + customerName + ",\n\n"
                + "Chúng tôi xin xác nhận đơn đặt bàn của quý khách tại Restoran đã được đặt thành công.\n\n"
                + "Chi tiết đặt bàn:\n"
                + "- Mã đặt bàn: " + confirmationCode + "\n"
                + "- Ngày: " + date + "\n"
                + "- Giờ: " + time + "\n"
                + "- Số người: " + numOfPeople + "\n"
                + "- Số bàn: " + tableId + "\n\n"
                + "Vui lòng đến đúng giờ để chúng tôi phục vụ quý khách tốt nhất.\n\n"
                + "Nếu quý khách cần hủy đặt bàn, vui lòng truy cập đường dẫn sau:\n"
                + cancelLink + "\n\n"
                + "Trân trọng,\n"
                + "Restoran";

        MimeMessage msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(from));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        msg.setSubject(subject, "UTF-8");
        msg.setText(content, "UTF-8");
        Transport.send(msg);
    }
    
}
    