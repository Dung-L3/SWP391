package Controller.auth;

import jakarta.servlet.ServletContext;
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

    public EmailServices(ServletContext ctx) {
        this.host = ctx.getInitParameter("smtp.host");
        this.user = ctx.getInitParameter("smtp.username");
        this.pass = ctx.getInitParameter("smtp.password");
        this.from = ctx.getInitParameter("smtp.from");
        this.port = Integer.parseInt(ctx.getInitParameter("smtp.port"));
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
    
}
    