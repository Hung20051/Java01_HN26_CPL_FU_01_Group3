<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quên mật khẩu - DRSMS System</title>
        <link rel="stylesheet" href="css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    </head>
    <body class="auth-page">
        <nav class="navbar">
            <div class="navbar-brand"><i class="fas fa-building"></i> DRSMS System</div>
            <div class="navbar-links">
                <a href="login.jsp" class="nav-link">Đăng nhập</a>
            </div>
        </nav>

        <div class="auth-container">
            <div class="auth-card">

                <%
                    String step = request.getParameter("step");
                    if (step == null) step = (String) request.getAttribute("step");
                    if (step == null) step = "email";
                    String error = (String) request.getAttribute("error");
                %>

                <% if (error != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
                <% } %>

                <%-- ══ BƯỚC 1: Nhập Email ══ --%>
                <% if ("email".equals(step)) { %>
                <div class="auth-header">
                    <i class="fas fa-lock" style="color:#2563eb; font-size:2.5rem;"></i>
                    <h2>Quên mật khẩu</h2>
                    <p>Nhập email đã đăng ký, chúng tôi sẽ gửi mã OTP để xác nhận.</p>
                </div>
                <form action="forgot-password" method="post">
                    <input type="hidden" name="action" value="sendOtp">
                    <div class="form-group">
                        <label><i class="fas fa-envelope"></i> Email đã đăng ký <span class="required">*</span></label>
                        <input type="email" name="email" placeholder="Nhập địa chỉ email" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-full">
                        <i class="fas fa-paper-plane"></i> Gửi mã OTP
                    </button>
                </form>
                <div style="text-align:center; margin-top:16px;">
                    <a href="login.jsp" style="color:#2563eb; text-decoration:none;">
                        <i class="fas fa-arrow-left"></i> Quay lại đăng nhập
                    </a>
                </div>

                <%-- ══ BƯỚC 2: Nhập OTP ══ --%>
                <% } else if ("otp".equals(step)) {
                    HttpSession sess = request.getSession(false);
                    String maskedEmail = "";
                    if (sess != null && sess.getAttribute("resetEmail") != null) {
                        String em = (String) sess.getAttribute("resetEmail");
                        int at = em.indexOf('@');
                        if (at > 2) maskedEmail = em.substring(0, 2) + "***" + em.substring(at);
                        else maskedEmail = "***" + em.substring(at);
                    }
                %>
                <div class="auth-header">
                    <i class="fas fa-envelope-open-text" style="color:#2563eb; font-size:2.5rem;"></i>
                    <h2>Xác nhận OTP</h2>
                    <p>Mã OTP đã được gửi đến <strong><%= maskedEmail %></strong>. Có hiệu lực trong 10 phút.</p>
                </div>
                <form action="forgot-password" method="post">
                    <input type="hidden" name="action" value="verifyOtp">
                    <div class="form-group">
                        <label>Nhập mã OTP <span class="required">*</span></label>
                        <input type="text" name="otp" placeholder="Nhập 6 chữ số" maxlength="6"
                               style="font-size:1.5rem; letter-spacing:8px; text-align:center;" required autofocus>
                    </div>
                    <button type="submit" class="btn btn-primary btn-full">
                        <i class="fas fa-check"></i> Xác nhận OTP
                    </button>
                </form>
                <div style="text-align:center; margin-top:20px;">
                    <p style="color:#666;">Không nhận được mã?</p>
                    <button id="resendBtn" class="btn btn-secondary" onclick="resendOtp()" disabled>
                        Gửi lại OTP (<span id="countdown">60</span>s)
                    </button>
                </div>
                <div style="text-align:center; margin-top:12px;">
                    <a href="forgot-password" style="color:#2563eb; text-decoration:none;">
                        <i class="fas fa-arrow-left"></i> Nhập lại email
                    </a>
                </div>
                <% } %>

            </div>
        </div>

        <script>
            // Chỉ chạy timer khi ở bước OTP
            <% if ("otp".equals(step)) { %>
            let timeLeft = 60;
            const btn = document.getElementById('resendBtn');
            const cd = document.getElementById('countdown');
            const timer = setInterval(() => {
                timeLeft--;
                cd.textContent = timeLeft;
                if (timeLeft <= 0) {
                    clearInterval(timer);
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fas fa-redo"></i> Gửi lại OTP';
                }
            }, 1000);

            function resendOtp() {
                btn.disabled = true;
                fetch('forgot-password', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'action=resend'
                })
                        .then(r => r.json())
                        .then(d => {
                            if (d.success) {
                                alert('Mã OTP mới đã được gửi!');
                                location.reload();
                            } else {
                                alert(d.message || 'Có lỗi xảy ra!');
                                btn.disabled = false;
                            }
                        });
            }
            <% } %>
        </script>
    </body>
</html>
