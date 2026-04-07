package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.util.Properties;
import java.util.Random;

public class EmailUtil {

    private static final String SENDER_EMAIL    = AppConfig.getEmailSender();
    private static final String SENDER_PASSWORD = AppConfig.getEmailPassword();
    private static final String SMTP_HOST       = "smtp.gmail.com";
    private static final int    SMTP_PORT       = 587;

    // ── Brand colors ───────────────────────────────────────────────────────────
    private static final String COLOR_PRIMARY  = "#1e40af"; // blue-800
    private static final String COLOR_SUCCESS  = "#15803d"; // green-700
    private static final String COLOR_DANGER   = "#b91c1c"; // red-700
    private static final String COLOR_WARNING  = "#b45309"; // amber-700
    private static final String COLOR_INFO     = "#0e7490"; // cyan-700
    private static final String COLOR_GRAY     = "#6b7280";
    private static final String COLOR_BG       = "#f1f5f9";

    // ══════════════════════════════════════════════════════════════════════════
    //  PUBLIC API — one method per status event
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Gửi OTP xác nhận đăng ký tài khoản.
     */
    public static String generateOTP() {
        return String.valueOf(100000 + new Random().nextInt(900000));
    }

    public static void sendOTP(String toEmail, String otp)
            throws MessagingException, UnsupportedEncodingException {
        send(toEmail,
             "DRSMS – Your OTP Verification Code",
             buildOtpHtml(otp));
    }

    // ── SR: APPROVED ──────────────────────────────────────────────────────────
    /**
     * Gửi khi Technical Manager APPROVE service request.
     *
     * @param toEmail       email khách hàng
     * @param customerName  tên khách hàng
     * @param requestCode   mã SR (SR2026-015)
     * @param requestTitle  tiêu đề SR
     * @param contractType  "WARRANTY" hoặc "MAINTENANCE"
     * @param managerName   tên Technical Manager
     */
    public static void sendSRApproved(String toEmail,
                                      String customerName,
                                      String requestCode,
                                      String requestTitle,
                                      String contractType,
                                      String managerName)
            throws MessagingException, UnsupportedEncodingException {

        String subject = "[DRSMS] Service Request " + requestCode + " – Approved ✓";
        String html    = buildSRApprovedHtml(customerName, requestCode, requestTitle,
                                             contractType, managerName);
        send(toEmail, subject, html);
    }

    // ── SR: REJECTED ──────────────────────────────────────────────────────────
    /**
     * Gửi khi Technical Manager REJECT service request.
     *
     * @param rejectReason  lý do từ chối
     */
    public static void sendSRRejected(String toEmail,
                                      String customerName,
                                      String requestCode,
                                      String requestTitle,
                                      String rejectReason,
                                      String managerName)
            throws MessagingException, UnsupportedEncodingException {

        String subject = "[DRSMS] Service Request " + requestCode + " – Not Approved";
        String html    = buildSRRejectedHtml(customerName, requestCode, requestTitle,
                                             rejectReason, managerName);
        send(toEmail, subject, html);
    }

    // ── SR: IN_PROGRESS (technician assigned) ─────────────────────────────────
    /**
     * Gửi khi technician được assign → SR chuyển sang IN_PROGRESS.
     *
     * @param technicianCount  số lượng technician được giao
     */
    public static void sendSRInProgress(String toEmail,
                                        String customerName,
                                        String requestCode,
                                        String requestTitle,
                                        int    technicianCount,
                                        String managerName)
            throws MessagingException, UnsupportedEncodingException {

        String subject = "[DRSMS] Service Request " + requestCode + " – Technician Assigned";
        String html    = buildSRInProgressHtml(customerName, requestCode, requestTitle,
                                               technicianCount, managerName);
        send(toEmail, subject, html);
    }

    // ── SR: COMPLETED + Invoice info ──────────────────────────────────────────
    /**
     * Gửi khi toàn bộ technician submit báo cáo → SR COMPLETED.
     *
     * @param invoiceCode   mã hoá đơn vừa tạo
     * @param totalAmount   tổng tiền (BigDecimal, đơn vị VND)
     * @param contractType  "WARRANTY" hoặc "MAINTENANCE"
     * @param dueDate       hạn thanh toán (yyyy-MM-dd)
     */
    public static void sendSRCompleted(String toEmail,
                                       String customerName,
                                       String requestCode,
                                       String requestTitle,
                                       String invoiceCode,
                                       BigDecimal totalAmount,
                                       String contractType,
                                       String dueDate)
            throws MessagingException, UnsupportedEncodingException {

        String subject = "[DRSMS] Service Request " + requestCode + " – Completed 🎉";
        String html    = buildSRCompletedHtml(customerName, requestCode, requestTitle,
                                              invoiceCode, totalAmount, contractType, dueDate);
        send(toEmail, subject, html);
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  HTML BUILDERS
    // ══════════════════════════════════════════════════════════════════════════

    // ── OTP ───────────────────────────────────────────────────────────────────
    private static String buildOtpHtml(String otp) {
        return wrapper("Account Verification", COLOR_PRIMARY,
            """
            <p style="color:#374151;font-size:1rem;margin:0 0 20px;">
              Please use the OTP below to complete your account registration:
            </p>
            <div style="background:#eff6ff;border:2px dashed #2563eb;border-radius:12px;
                        padding:24px;margin-bottom:24px;text-align:center;">
              <span style="font-size:2.5rem;font-weight:700;color:#2563eb;letter-spacing:12px;">
                %s
              </span>
            </div>
            <p style="color:#6b7280;font-size:.875rem;text-align:center;">
              ⏱ This code expires in <strong>10 minutes</strong>.<br>
              Never share this code with anyone.
            </p>
            """.formatted(otp),
            "If you did not request this, please ignore this email."
        );
    }

    // ── APPROVED ──────────────────────────────────────────────────────────────
    private static String buildSRApprovedHtml(String customerName,
                                               String requestCode,
                                               String requestTitle,
                                               String contractType,
                                               String managerName) {
        boolean isWarranty = "WARRANTY".equalsIgnoreCase(contractType);
        String  contractBadge = isWarranty
            ? badge("#065f46", "#d1fae5", "WARRANTY – Repair is FREE")
            : badge("#92400e", "#fef3c7", "MAINTENANCE – Charges apply");

        String body = """
            <p style="color:#374151;font-size:.9375rem;margin:0 0 20px;">
              Dear <strong>%s</strong>,
            </p>
            <p style="color:#374151;font-size:.9375rem;margin:0 0 24px;">
              Great news! Your service request has been <strong style="color:%s;">approved</strong>
              by our Technical Manager. Our team will assign a qualified technician shortly.
            </p>
            %s
            %s
            <p style="color:#6b7280;font-size:.875rem;margin:24px 0 0;">
              Reviewed by: <strong>%s</strong>
            </p>
            """.formatted(customerName, COLOR_SUCCESS,
                          infoCard(requestCode, requestTitle),
                          contractBadge,
                          managerName);

        return wrapper("Request Approved", COLOR_SUCCESS, body,
            "You will receive another notification when a technician is assigned.");
    }

    // ── REJECTED ──────────────────────────────────────────────────────────────
    private static String buildSRRejectedHtml(String customerName,
                                               String requestCode,
                                               String requestTitle,
                                               String rejectReason,
                                               String managerName) {
        String body = """
            <p style="color:#374151;font-size:.9375rem;margin:0 0 20px;">
              Dear <strong>%s</strong>,
            </p>
            <p style="color:#374151;font-size:.9375rem;margin:0 0 24px;">
              We regret to inform you that your service request has <strong style="color:%s;">
              not been approved</strong> at this time.
            </p>
            %s
            <div style="background:#fef2f2;border-left:4px solid %s;border-radius:8px;
                        padding:16px 20px;margin:20px 0;">
              <p style="margin:0;color:#374151;font-size:.875rem;">
                <strong>Reason for rejection:</strong><br>
                <span style="color:#7f1d1d;">%s</span>
              </p>
            </div>
            <p style="color:#374151;font-size:.875rem;margin:20px 0 0;">
              If you believe this decision was made in error, or if you would like to submit
              a revised request, please contact our support team or create a new request.
            </p>
            <p style="color:#6b7280;font-size:.875rem;margin:12px 0 0;">
              Reviewed by: <strong>%s</strong>
            </p>
            """.formatted(customerName, COLOR_DANGER, COLOR_DANGER,
                          infoCard(requestCode, requestTitle),
                          rejectReason,
                          managerName);

        return wrapper("Request Not Approved", COLOR_DANGER, body,
            "For assistance, please contact our support team.");
    }

    // ── IN_PROGRESS ───────────────────────────────────────────────────────────
    private static String buildSRInProgressHtml(String customerName,
                                                 String requestCode,
                                                 String requestTitle,
                                                 int    technicianCount,
                                                 String managerName) {
        String techText = technicianCount == 1
            ? "A technician has been assigned"
            : technicianCount + " technicians have been assigned";

        String body = """
            <p style="color:#374151;font-size:.9375rem;margin:0 0 20px;">
              Dear <strong>%s</strong>,
            </p>
            <p style="color:#374151;font-size:.9375rem;margin:0 0 24px;">
              Your service request is now <strong style="color:%s;">In Progress</strong>.
              %s to handle your request and work will begin soon.
            </p>
            %s
            <div style="background:#eff6ff;border-left:4px solid %s;border-radius:8px;
                        padding:16px 20px;margin:20px 0;">
              <p style="margin:0;color:#374151;font-size:.875rem;">
                🔧 <strong>What happens next?</strong><br>
                Our technician(s) will contact you if site access is needed, diagnose the issue,
                perform the repair, and submit a completion report.
              </p>
            </div>
            <p style="color:#6b7280;font-size:.875rem;margin:20px 0 0;">
              Assigned by: <strong>%s</strong>
            </p>
            """.formatted(customerName, COLOR_INFO, techText,
                          infoCard(requestCode, requestTitle),
                          COLOR_INFO, managerName);

        return wrapper("Technician Assigned", COLOR_INFO, body,
            "You will be notified once the repair is completed.");
    }

    // ── COMPLETED ─────────────────────────────────────────────────────────────
    private static String buildSRCompletedHtml(String customerName,
                                                String requestCode,
                                                String requestTitle,
                                                String invoiceCode,
                                                BigDecimal totalAmount,
                                                String contractType,
                                                String dueDate) {
        boolean isWarranty = "WARRANTY".equalsIgnoreCase(contractType);

        String invoiceSection = isWarranty
            ? """
              <div style="background:#f0fdf4;border-left:4px solid #16a34a;border-radius:8px;
                          padding:16px 20px;margin:20px 0;">
                <p style="margin:0;color:#374151;font-size:.875rem;">
                  ✅ <strong>No charges apply</strong> — Your equipment is covered under a
                  <strong>Warranty Contract</strong>. Labor costs are included free of charge.
                </p>
              </div>
              """
            : """
              <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;
                          padding:20px;margin:20px 0;">
                <p style="margin:0 0 12px;font-weight:700;color:#1e293b;font-size:.9375rem;">
                  🧾 Invoice Summary
                </p>
                <table style="width:100%;border-collapse:collapse;font-size:.875rem;color:#374151;">
                  <tr>
                    <td style="padding:6px 0;">Invoice Code</td>
                    <td style="padding:6px 0;text-align:right;font-weight:600;">%s</td>
                  </tr>
                  <tr>
                    <td style="padding:6px 0;">Total Amount (incl. 10%% VAT)</td>
                    <td style="padding:6px 0;text-align:right;font-weight:700;color:%s;">
                      %s VND
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:6px 0;">Payment Due</td>
                    <td style="padding:6px 0;text-align:right;color:#b45309;font-weight:600;">%s</td>
                  </tr>
                </table>
                <p style="margin:14px 0 0;font-size:.8125rem;color:#6b7280;">
                  Please log in to your DRSMS account to view the full invoice and make a payment.
                </p>
              </div>
              """.formatted(invoiceCode,
                            COLOR_PRIMARY,
                            formatMoney(totalAmount),
                            dueDate);

        String body = """
            <p style="color:#374151;font-size:.9375rem;margin:0 0 20px;">
              Dear <strong>%s</strong>,
            </p>
            <p style="color:#374151;font-size:.9375rem;margin:0 0 24px;">
              🎉 We are pleased to inform you that your service request has been
              <strong style="color:%s;">successfully completed</strong>.
              Our technician(s) have finished all repair work and submitted their reports.
            </p>
            %s
            %s
            """.formatted(customerName, COLOR_SUCCESS,
                          infoCard(requestCode, requestTitle),
                          invoiceSection);

        return wrapper("Service Completed", COLOR_SUCCESS, body,
            "Thank you for choosing DRSMS. We hope to serve you again.");
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  SHARED HTML COMPONENTS
    // ══════════════════════════════════════════════════════════════════════════

    /** Master wrapper: header strip + body card + footer */
    private static String wrapper(String headerTitle,
                                   String headerColor,
                                   String bodyHtml,
                                   String footerNote) {
        return """
            <!DOCTYPE html>
            <html lang="en">
            <body style="margin:0;padding:20px;background:%s;font-family:'Segoe UI',Arial,sans-serif;">
              <div style="max-width:560px;margin:0 auto;background:#ffffff;border-radius:16px;
                          overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,.10);">

                <!-- Header -->
                <div style="background:%s;padding:28px 32px;">
                  <p style="margin:0;color:rgba(255,255,255,.75);font-size:.8125rem;letter-spacing:.05em;
                             text-transform:uppercase;">DRSMS — Device Repair Service Management</p>
                  <h1 style="margin:6px 0 0;color:#ffffff;font-size:1.375rem;font-weight:700;">%s</h1>
                </div>

                <!-- Body -->
                <div style="padding:32px;">
                  %s
                </div>

                <!-- Footer -->
                <div style="background:#f8fafc;border-top:1px solid #e2e8f0;
                            padding:16px 32px;text-align:center;">
                  <p style="margin:0;color:%s;font-size:.8125rem;">%s</p>
                  <p style="margin:6px 0 0;color:#9ca3af;font-size:.75rem;">
                    This is an automated message from DRSMS. Please do not reply to this email.
                  </p>
                </div>

              </div>
            </body>
            </html>
            """.formatted(COLOR_BG, headerColor, headerTitle, bodyHtml, COLOR_GRAY, footerNote);
    }

    /** Card hiển thị request code + title */
    private static String infoCard(String requestCode, String requestTitle) {
        return """
            <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;
                        padding:16px 20px;margin:0 0 20px;">
              <p style="margin:0;font-size:.8125rem;color:#6b7280;text-transform:uppercase;
                         letter-spacing:.05em;">Service Request</p>
              <p style="margin:4px 0 0;font-size:1rem;font-weight:700;color:#1e293b;">%s</p>
              <p style="margin:4px 0 0;font-size:.875rem;color:#475569;">%s</p>
            </div>
            """.formatted(requestCode, requestTitle);
    }

    /** Inline badge */
    private static String badge(String textColor, String bgColor, String label) {
        return """
            <span style="display:inline-block;background:%s;color:%s;font-size:.8125rem;
                          font-weight:600;padding:4px 12px;border-radius:9999px;margin-bottom:16px;">
              %s
            </span>
            """.formatted(bgColor, textColor, label);
    }

    /** Format số tiền VND với dấu phẩy */
    private static String formatMoney(BigDecimal amount) {
        if (amount == null) return "0";
        return String.format("%,.0f", amount);
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  TRANSPORT
    // ══════════════════════════════════════════════════════════════════════════

    private static void send(String toEmail, String subject, String htmlBody)
            throws MessagingException, UnsupportedEncodingException {

        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            SMTP_HOST);
        props.put("mail.smtp.port",            SMTP_PORT);
        props.put("mail.smtp.ssl.trust",       SMTP_HOST);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(SENDER_EMAIL, "DRSMS System", "UTF-8"));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        msg.setSubject(subject);
        msg.setContent(htmlBody, "text/html; charset=UTF-8");
        Transport.send(msg);
    }
}