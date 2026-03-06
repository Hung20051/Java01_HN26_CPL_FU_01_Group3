<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Page protection: redirect if OTP not verified
    HttpSession sess = request.getSession(false);
    if (sess == null || !Boolean.TRUE.equals(sess.getAttribute("resetOtpVerified"))) {
        response.sendRedirect(request.getContextPath() + "/forgot-password.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - DRSMS System</title>
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
                <i class="fas fa-key" style="color:#2563eb; font-size:2.5rem;"></i>
                <h2>Reset Password</h2>
                <p>Enter a new password for your account.</p>
            </div>
            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
            <% } %>
            <form action="reset-password" method="post">
                <div class="form-group">
                    <label><i class="fas fa-lock"></i> New Password <span class="required">*</span></label>
                    <div class="input-wrapper">
                        <input type="password" name="newPassword" id="newPassword"
                               placeholder="Minimum 6 characters" required minlength="6">
                        <i class="fas fa-eye toggle-pass" onclick="togglePass('newPassword', this)"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-lock"></i> Confirm Password <span class="required">*</span></label>
                    <div class="input-wrapper">
                        <input type="password" name="confirmPassword" id="confirmPassword"
                               placeholder="Re-enter your new password" required minlength="6">
                        <i class="fas fa-eye toggle-pass" onclick="togglePass('confirmPassword', this)"></i>
                    </div>
                    <small id="matchMsg" style="color:red; display:none;">
                        <i class="fas fa-times-circle"></i> Passwords do not match!
                    </small>
                </div>
                <button type="submit" class="btn btn-primary btn-full" id="submitBtn">
                    <i class="fas fa-save"></i> Save New Password
                </button>
            </form>
        </div>
    </div>
    <script>
        function togglePass(id, icon) {
            const inp = document.getElementById(id);
            inp.type = inp.type === 'password' ? 'text' : 'password';
            icon.classList.toggle('fa-eye');
            icon.classList.toggle('fa-eye-slash');
        }
        // Real-time password match check
        document.getElementById('confirmPassword').addEventListener('input', function () {
            const np = document.getElementById('newPassword').value;
            const msg = document.getElementById('matchMsg');
            const btn = document.getElementById('submitBtn');
            if (this.value && this.value !== np) {
                msg.style.display = 'block';
                btn.disabled = true;
            } else {
                msg.style.display = 'none';
                btn.disabled = false;
            }
        });
    </script>
</body>
</html>
