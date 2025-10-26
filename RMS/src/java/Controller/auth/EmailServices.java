package Controller.auth;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpSession;
import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

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

    public void sendReservationConfirmationFromSession(HttpSession session, String reservationId, String date, String time, int numOfPeople, String tableId) throws MessagingException {
        String email = (String) session.getAttribute("reservationEmail");
        String customerName = (String) session.getAttribute("reservationCustomerName");
        
        if (email == null || customerName == null) {
            throw new MessagingException("Không tìm thấy thông tin email trong session");
        }
        
        sendReservationConfirmation(email, reservationId, customerName, date, time, numOfPeople, tableId);
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

    public void sendReservationConfirmation(String to, String reservationId, String customerName, String date, String time, int numOfPeople, String tableId) throws MessagingException {
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

        String subject = "[Restoran] Xác nhận đặt bàn thành công";
        String content = "Kính gửi " + customerName + ",\n\n"
                + "Chúng tôi xin xác nhận đơn đặt bàn của quý khách tại Restoran đã được đặt thành công.\n\n"
                + "Chi tiết đặt bàn:\n"
                + "- Mã đặt bàn: " + reservationId + "\n"
                + "- Ngày: " + date + "\n"
                + "- Giờ: " + time + "\n"
                + "- Số người: " + numOfPeople + "\n"
                + "- Số bàn: " + tableId + "\n\n"
                + "Vui lòng đến đúng giờ để chúng tôi phục vụ quý khách tốt nhất.\n"
                + "Nếu quý khách cần thay đổi hoặc hủy đặt bàn, vui lòng liên hệ với chúng tôi trước thời điểm đặt bàn.\n\n"
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
    