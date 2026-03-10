<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
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
            <a href="home.jsp" class="nav-link active">Home</a>
            <a href="#about" class="nav-link">About</a>
            <a href="#contact" class="nav-link">Contact</a>
            <% if (currentUser != null) { %>
                <span class="nav-user">Hello, <%= currentUser.getFullName() %></span>
                <a href="logout" class="btn-nav-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <% } else { %>
                <a href="login.jsp" class="btn-nav-login"><i class="fas fa-sign-in-alt"></i> Login</a>
            <% } %>
        </div>
    </nav>

    <!-- HERO SECTION -->
    <section class="hero">
        <div class="hero-content">
            <h1>Device Repair Service Management System</h1>
            <p>A comprehensive solution for customer care, contract management, and equipment tracking — helping businesses optimize workflows and elevate service quality.</p>
        </div>
    </section>

    <!-- CTA SECTION -->
    <div class="cta-section">
        <div class="cta-card">
            <a href="login.jsp" class="cta-link">Get started today</a>
        </div>
    </div>

    <!-- FEATURES -->
    <section class="features">
        <h2>Outstanding Features</h2>
        <p>Everything you need to manage and grow your customer relationships</p>
        <div class="features-grid">
            <div class="feature-card">
                <i class="fas fa-users"></i>
                <h3>Customer Management</h3>
                <p>Track complete information and transaction history for all customers</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-laptop"></i>
                <h3>Equipment Management</h3>
                <p>Monitor equipment status and maintenance efficiently</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-file-contract"></i>
                <h3>Contract Management</h3>
                <p>Track and manage customer contracts with ease</p>
            </div>
        </div>
    </section>

    <!-- ABOUT SECTION -->
    <section class="features" id="about">
        <h2>About Us</h2>
        <p>We are a professional software development team dedicated to delivering the most optimal customer management solutions</p>
        <div class="features-grid">
            <div class="feature-card">
                <i class="fas fa-bullseye"></i>
                <h3>Vision</h3>
                <p>To become the leading DRSMS platform in Vietnam, serving thousands of small and medium-sized businesses</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-heart"></i>
                <h3>Core Values</h3>
                <p>Putting customers at the center, always listening and continuously improving our product</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-trophy"></i>
                <h3>Achievements</h3>
                <p>Trusted by over 500 businesses, 99.9% uptime, and a 24/7 support team</p>
            </div>
        </div>
    </section>

    <!-- CONTACT SECTION -->
    <section class="features" id="contact">
        <h2>Contact Us</h2>
        <p>We are always ready to listen and support you</p>
        <div class="features-grid">
            <div class="feature-card">
                <i class="fas fa-map-marker-alt"></i>
                <h3>Address</h3>
                <p>Hoa Lac Hi-Tech Park, Hanoi, Vietnam</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-phone"></i>
                <h3>Phone</h3>
                <p>Hotline: 1800 1234<br>Support: (024) 3768 9999</p>
            </div>
            <div class="feature-card">
                <i class="fas fa-envelope"></i>
                <h3>Email</h3>
                <p>support@drsmsystem.vn<br>sales@drsmsystem.vn</p>
            </div>
        </div>
    </section>

    <footer class="footer">
        <p>&copy; 2026 DRSMS System. All rights reserved.</p>
    </footer>
</body>
</html>
