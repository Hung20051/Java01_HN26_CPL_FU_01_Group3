package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.UnsupportedEncodingException;

import java.util.Properties;
import java.util.Random;

public class EmailUtil {

    private static final String SENDER_EMAIL = AppConfig.getEmailSender();
    private static final String SENDER_PASSWORD = AppConfig.getEmailPassword();

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 587;

    /**
     * Tạo mã OTP 6 chữ số
     */
    public static String generateOTP() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }

    /**
     * Gửi email OTP đến địa chỉ email đăng ký
     */
    public static void sendOTP(String toEmail, String otp) throws MessagingException, UnsupportedEncodingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.trust", SMTP_HOST);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL, "CRM System", "UTF-8"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("Mã OTP xác nhận đăng ký tài khoản CRM System");
        message.setContent(buildEmailHtml(otp), "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private static String buildEmailHtml(String otp) {
        return """
            <!DOCTYPE html>
            <html>
            <body style="font-family:Arial,sans-serif; background:#f0f4f8; margin:0; padding:20px;">
              <div style="max-width:500px; margin:0 auto; background:white; border-radius:16px; overflow:hidden; box-shadow:0 4px 20px rgba(0,0,0,.1);">
                <div style="background:linear-gradient(135deg,#667eea,#764ba2); padding:30px; text-align:center;">
                  <h1 style="color:white; margin:0; font-size:1.5rem;">🔐 CRM System</h1>
                  <p style="color:rgba(255,255,255,.8); margin:8px 0 0;">Xác nhận đăng ký tài khoản</p>
                </div>
                <div style="padding:40px; text-align:center;">
                  <p style="color:#374151; font-size:1rem; margin-bottom:24px;">
                    Mã OTP của bạn để xác nhận tài khoản:
                  </p>
                  <div style="background:#eff6ff; border:2px dashed #2563eb; border-radius:12px; padding:20px; margin-bottom:24px;">
                    <span style="font-size:2.5rem; font-weight:700; color:#2563eb; letter-spacing:12px;">%s</span>
                  </div>
                  <p style="color:#6b7280; font-size:.9rem;">
                    ⏱ Mã có hiệu lực trong <strong>10 phút</strong>.<br>
                    Không chia sẻ mã này với bất kỳ ai.
                  </p>
                </div>
                <div style="background:#f8fafc; padding:16px; text-align:center;">
                  <p style="color:#9ca3af; font-size:.8rem; margin:0;">
                    Nếu bạn không yêu cầu đăng ký, hãy bỏ qua email này.
                  </p>
                </div>
              </div>
            </body>
            </html>
            """.formatted(otp);
    }
}
