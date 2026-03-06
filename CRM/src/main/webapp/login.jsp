<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - DRSMS System</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="auth-page">
    <nav class="navbar">
        <div class="navbar-brand">
            <i class="fas fa-building"></i> DRSMS System
        </div>
        <div class="navbar-links">
            <a href="home.jsp" class="nav-link">Home</a>
            <a href="login.jsp" class="btn-nav-login active-nav"><i class="fas fa-sign-in-alt"></i> Login</a>
        </div>
    </nav>

    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <i class="fas fa-sign-in-alt" style="color:#2563eb"></i>
                <h2>Login</h2>
                <p>Welcome back! Please log in to your account.</p>
            </div>

            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
            <% } %>
            <% String success = (String) request.getAttribute("success"); %>
            <% if (success != null) { %>
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= success %></div>
            <% } %>
            <% String resetSuccess = request.getParameter("resetSuccess"); %>
<% if ("1".equals(resetSuccess)) { %>
    <div class="alert alert-success">
        <i class="fas fa-check-circle"></i> Password reset successful! Please log in.
    </div>
<% } %>
            <form action="login" method="post">
                <div class="form-group">
                    <label><i class="fas fa-user"></i> Username <span class="required">*</span></label>
                    <div class="input-wrapper">
                        <input type="text" name="username" placeholder="Enter your username" required>
                    </div>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-lock"></i> Password <span class="required">*</span></label>
                    <div class="input-wrapper">
                        <input type="password" name="password" id="password" placeholder="Enter your password" required>
                        <i class="fas fa-eye toggle-pass" onclick="togglePass()"></i>
                    </div>
                    <div style="text-align:right; margin-top:4px;">
                        <a href="forgot-password" class="forgot-link">Forgot password?</a>
                    </div>
                </div>
                <div class="form-group checkbox-group">
                    <label class="checkbox-label">
                        <input type="checkbox" name="rememberMe"> Remember me
                    </label>
                </div>
                <button type="submit" class="btn btn-primary btn-full">
                    <i class="fas fa-sign-in-alt"></i> Login
                </button>
            </form>

            <button onclick="location.href='register.jsp'" class="btn btn-secondary btn-full" style="margin-top:10px;">
                <i class="fas fa-user-plus"></i> Create a new account
            </button>

            <div class="divider"><span>Or</span></div>

            <a href="auth/google" class="btn btn-google btn-full">
                <i class="fab fa-google"></i> Login with Google
            </a>
            <a href="auth/facebook" class="btn btn-facebook btn-full" style="margin-top:10px;">
                <i class="fab fa-facebook-f"></i> Login with Facebook
            </a>
        </div>
    </div>

    <script>
        function togglePass() {
            const p = document.getElementById('password');
            p.type = p.type === 'password' ? 'text' : 'password';
        }
    </script>
</body>
</html>
