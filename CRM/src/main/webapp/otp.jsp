<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận OTP - DRSMS System</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="auth-page">
    <nav class="navbar">
        <div class="navbar-brand"><i class="fas fa-building"></i> DRSMS System</div>
    </nav>

    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <i class="fas fa-envelope-open-text" style="color:#2563eb; font-size:2.5rem;"></i>
                <h2>Xác nhận OTP</h2>
                <p>Mã OTP đã được gửi đến email của bạn. Vui lòng nhập mã để hoàn tất đăng ký.</p>
            </div>

            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
            <% } %>

            <form action="otp" method="post">
                <input type="hidden" name="action" value="verify">
                <div class="form-group">
                    <label>Nhập mã OTP <span class="required">*</span></label>
                    <input type="text" name="otp" placeholder="Nhập 6 chữ số OTP" maxlength="6" 
                           style="font-size:1.5rem; letter-spacing:8px; text-align:center;" required>
                </div>

                <button type="submit" class="btn btn-primary btn-full">
                    <i class="fas fa-check"></i> Xác nhận
                </button>
            </form>

            <div style="text-align:center; margin-top:20px;">
                <p style="color:#666;">Không nhận được mã?</p>
                <button id="resendBtn" class="btn btn-secondary" onclick="resendOtp()" disabled>
                    Gửi lại OTP (<span id="countdown">60</span>s)
                </button>
            </div>
        </div>
    </div>

    <script>
        let timeLeft = 60;
        const btn = document.getElementById('resendBtn');
        const cd = document.getElementById('countdown');

        const timer = setInterval(() => {
            timeLeft--;
            cd.textContent = timeLeft;
            if (timeLeft <= 0) {
                clearInterval(timer);
                btn.disabled = false;
                btn.textContent = 'Gửi lại OTP';
            }
        }, 1000);

        function resendOtp() {
            fetch('otp?action=resend', { method: 'POST' })
                .then(r => r.json())
                .then(d => {
                    if (d.success) {
                        alert('Mã OTP mới đã được gửi!');
                        location.reload();
                    } else {
                        alert(d.message || 'Có lỗi xảy ra!');
                    }
                });
        }
    </script>
</body>
</html>
