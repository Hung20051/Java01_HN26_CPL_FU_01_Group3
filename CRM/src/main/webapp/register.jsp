<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - DRSMS System</title>
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
            <a href="login.jsp" class="btn-nav-login"><i class="fas fa-sign-in-alt"></i> Login</a>
        </div>
    </nav>

    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <i class="fas fa-user-plus" style="color:#16a34a"></i>
                <h2 style="color:#16a34a">Register</h2>
                <p>Create a new account to get started with DRSMS.</p>
            </div>

            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
            <% } %>

            <form action="register" method="post" id="registerForm">
                <div class="form-group">
                    <label>Full Name <span class="required">*</span></label>
                    <input type="text" name="fullName" placeholder="Enter your full name" required>
                </div>
                <div class="form-group">
                    <label>Email <span class="required">*</span></label>
                    <input type="email" name="email" placeholder="example@domain.com" required>
                </div>
                <div class="form-group">
                    <label>Phone Number <span class="required">*</span></label>
                    <input type="tel" name="phone" placeholder="Enter your phone number" required>
                </div>
                <div class="form-group">
                    <label>Username <span class="required">*</span></label>
                    <input type="text" name="username" placeholder="Username" required>
                </div>
                <div class="form-group">
                    <label>Password <span class="required">*</span></label>
                    <div class="input-wrapper">
                        <input type="password" name="password" id="regPass" placeholder="Enter your password" required minlength="6">
                        <i class="fas fa-eye toggle-pass" onclick="toggleRegPass('regPass')"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label>Confirm Password <span class="required">*</span></label>
                    <div class="input-wrapper">
                        <input type="password" name="confirmPassword" id="regPass2" placeholder="Re-enter your password" required minlength="6">
                        <i class="fas fa-eye toggle-pass" onclick="toggleRegPass('regPass2')"></i>
                    </div>
                </div>
                <div class="form-group checkbox-group">
                    <label class="checkbox-label">
                        <input type="checkbox" required>
                        By registering, you confirm that you have read and agree to our <a href="#" style="color:#16a34a">Terms &amp; Conditions</a>.
                    </label>
                </div>
                <button type="submit" class="btn btn-success btn-full">
                    <i class="fas fa-user-plus"></i> Create Account
                </button>
            </form>

            <p style="text-align:center; margin-top:16px; color:#666;">
                Already have an account? <a href="login.jsp" style="color:#2563eb; font-weight:600;">Login now</a>
            </p>
        </div>
    </div>

    <script>
        function toggleRegPass(id) {
            const p = document.getElementById(id);
            p.type = p.type === 'password' ? 'text' : 'password';
        }
    </script>
</body>
</html>
