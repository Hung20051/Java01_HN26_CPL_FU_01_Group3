<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DRSMS System - Device Repair Service Management System</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        html { scroll-behavior: smooth; }
    </style>
</head>
<body>
    <!-- NAVBAR -->
    <nav class="navbar">
        <div class="navbar-brand">
            <i class="fas fa-building"></i> DRSMS System
        </div>
        <div class="navbar-links">
            <a href="home.jsp" class="nav-link active">Trang chủ</a>
            <a href="#about" class="nav-link">Giới thiệu</a>
            <a href="#contact" class="nav-link">Liên hệ</a>
            <% if (currentUser != null) { %>
                <span class="nav-user">Xin chào, <%= currentUser.getFullName() %></span>
                <a href="logout" class="btn-nav-logout"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
            <% } else { %>
                <a href="login.jsp" class="btn-nav-login"><i class="fas fa-sign-in-alt"></i> Đăng nhập</a>
            <% } %>
        </div>
    </nav>

    <!-- HERO SECTION -->
    <section class="hero">
        <div class="hero-content">
            <h1>Device Repair Service Management System</h1>
            <p>Giải pháp toàn diện cho việc chăm sóc khách hàng, quản lý hợp đồng và theo dõi thiết bị, giúp doanh nghiệp tối ưu hóa quy trình và nâng cao chất lượng dịch vụ</p>
        </div>
    </section>

    <!-- CTA SECTION -->
    <div class="cta-section">
        <div class="cta-card">
            <a href="login.jsp" class="cta-link">Bắt đầu trải nghiệm ngay hôm nay</a>
        </div>
    </div>

    <!-- FEATURES -->
    <section class="features">
        <h2>Tính năng vượt trội</h2>
        <p>Tất cả những gì bạn cần để quản lý và phát triển mối quan hệ khách hàng</p>
        <div class="features-grid">
            <div class="feature-card">
                <i class="fas fa-users"></i>
                <h3>Quản lý Khách hàng</h3>
                <p>Theo dõi toàn bộ thông tin và lịch sử giao dịch của khách hàng</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-laptop"></i>
                <h3>Quản lý Thiết bị</h3>
                <p>Kiểm soát tình trạng và bảo trì thiết bị một cách hiệu quả</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-file-contract"></i>
                <h3>Quản lý Hợp đồng</h3>
                <p>Theo dõi và quản lý hợp đồng với khách hàng dễ dàng</p>
            </div>
        </div>
    </section>

    <!-- ABOUT SECTION -->
    <section class="features" id="about">
        <h2>Về chúng tôi</h2>
        <p>Chúng tôi là đội ngũ phát triển phần mềm chuyên nghiệp, tận tâm mang đến giải pháp quản lý khách hàng tối ưu nhất</p>
        <div class="features-grid">
            <div class="feature-card">
                <i class="fas fa-bullseye"></i>
                <h3>Tầm nhìn</h3>
                <p>Trở thành nền tảng DRSMS hàng đầu Việt Nam, phục vụ hàng nghìn doanh nghiệp vừa và nhỏ</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-heart"></i>
                <h3>Giá trị cốt lõi</h3>
                <p>Đặt khách hàng làm trung tâm, luôn lắng nghe và cải tiến sản phẩm không ngừng</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-trophy"></i>
                <h3>Thành tích</h3>
                <p>Hơn 500 doanh nghiệp tin dùng, 99.9% uptime và đội ngũ hỗ trợ 24/7</p>
            </div>
        </div>
    </section>

    <!-- CONTACT SECTION -->
    <section class="features" id="contact">
        <h2>Liên hệ với chúng tôi</h2>
        <p>Chúng tôi luôn sẵn sàng lắng nghe và hỗ trợ bạn</p>
        <div class="features-grid">
            <div class="feature-card">
                <i class="fas fa-map-marker-alt"></i>
                <h3>Địa chỉ</h3>
                <p>Khu Công nghệ cao Hòa Lạc, Hà Nội, Việt Nam</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-phone"></i>
                <h3>Điện thoại</h3>
                <p>Hotline: 1800 1234<br>Hỗ trợ: (024) 3768 9999</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-envelope"></i>
                <h3>Email</h3>
                <p>support@crmsystem.vn<br>sales@crmsystem.vn</p>
            </div>
        </div>

        
    </section>

    <footer class="footer">
        <p>&copy; 2026 DRSMS System. All rights reserved.</p>
    </footer>
</body>
</html>