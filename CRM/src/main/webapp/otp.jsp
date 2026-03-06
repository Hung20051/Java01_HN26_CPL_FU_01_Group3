<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OTP Verification - DRSMS System</title>
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
                <h2>OTP Verification</h2>
                <p>An OTP code has been sent to your email. Please enter the code to complete registration.</p>
            </div>
            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
            <% } %>
            <form action="otp" method="post">
                <input type="hidden" name="action" value="verify">
                <div class="form-group">
                    <label>Enter OTP Code <span class="required">*</span></label>
                    <input type="text" name="otp" placeholder="Enter 6-digit OTP" maxlength="6"
                           style="font-size:1.5rem; letter-spacing:8px; text-align:center;" required>
                </div>
                <button type="submit" class="btn btn-primary btn-full">
                    <i class="fas fa-check"></i> Verify
                </button>
            </form>
            <div style="text-align:center; margin-top:20px;">
                <p style="color:#666;">Didn't receive the code?</p>
                <button id="resendBtn" class="btn btn-secondary" onclick="resendOtp()" disabled>
                    Resend OTP (<span id="countdown">60</span>s)
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
                btn.textContent = 'Resend OTP';
            }
        }, 1000);
        function resendOtp() {
            fetch('otp?action=resend', { method: 'POST' })
                .then(r => r.json())
                .then(d => {
                    if (d.success) {
                        alert('A new OTP code has been sent!');
                        location.reload();
                    } else {
                        alert(d.message || 'An error occurred!');
                    }
                });
        }
    </script>
</body>
</html>
