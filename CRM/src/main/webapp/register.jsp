<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - DRSMS System</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="auth-page">
    <nav class="navbar">
        <div class="navbar-brand">
            <i class="fas fa-building"></i> DRSMS System
        </div>
        <div class="navbar-links">
            <a href="home.jsp" class="nav-link">Trang chủ</a>
            <a href="login.jsp" class="btn-nav-login"><i class="fas fa-sign-in-alt"></i> Đăng nhập</a>
        </div>
    </nav>

    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <i class="fas fa-user-plus" style="color:#16a34a"></i>
                <h2 style="color:#16a34a">Đăng ký</h2>
                <p>Tạo tài khoản mới để bắt đầu với DRSMS.</p>
            </div>

            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
            <% } %>

            <form action="register" method="post" id="registerForm">
                <div class="form-group">
                    <label>Họ và tên <span class="required">*</span></label>
                    <input type="text" name="fullName" placeholder="Nhập họ và tên đầy đủ" required>
                </div>
                <div class="form-group">
                    <label>Email <span class="required">*</span></label>
                    <input type="email" name="email" placeholder="example@domain.com" required>
                </div>
                <div class="form-group">
                    <label>Số điện thoại <span class="required">*</span></label>
                    <input type="tel" name="phone" placeholder="Nhập số điện thoại" required>
                </div>
                <div class="form-group">
                    <label>Tên đăng nhập <span class="required">*</span></label>
                    <input type="text" name="username" placeholder="Tên đăng nhập" required>
                </div>
                <div class="form-group">
                    <label>Mật khẩu <span class="required">*</span></label>
                    <div class="input-wrapper">
                        <input type="password" name="password" id="regPass" placeholder="Nhập mật khẩu" required minlength="6">
                        <i class="fas fa-eye toggle-pass" onclick="toggleRegPass('regPass')"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label>Nhập lại mật khẩu <span class="required">*</span></label>
                    <div class="input-wrapper">
                        <input type="password" name="confirmPassword" id="regPass2" placeholder="Xác nhận lại mật khẩu" required minlength="6">
                        <i class="fas fa-eye toggle-pass" onclick="toggleRegPass('regPass2')"></i>
                    </div>
                </div>
                <div class="form-group checkbox-group">
                    <label class="checkbox-label">
                        <input type="checkbox" required>
                        Việc đăng ký tài khoản đồng nghĩa với việc bạn đã đọc và đồng ý với <a href="#" style="color:#16a34a">Điều khoản &amp; Dịch vụ</a> của chúng tôi.
                    </label>
                </div>
                <button type="submit" class="btn btn-success btn-full">
                    <i class="fas fa-user-plus"></i> Tạo tài khoản
                </button>
            </form>

            <p style="text-align:center; margin-top:16px; color:#666;">
                Đã có tài khoản? <a href="login.jsp" style="color:#2563eb; font-weight:600;">Đăng nhập ngay</a>
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
