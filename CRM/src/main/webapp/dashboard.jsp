<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dashboard - DRSMS System</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root {
                --sidebar-bg: #1a1a2e;
                --accent: #4ade80;
                --primary: #6366f1;
                --surface: #ffffff;
                --bg: #f0f2f5;
                --text: #1e293b;
                --muted: #64748b;
                --border: #e2e8f0;
            }

            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            body {
                font-family: 'Be Vietnam Pro', sans-serif;
                background: var(--bg);
                display: flex;
                min-height: 100vh;
            }

            /* ── SIDEBAR ── */
            .sidebar {
                width: 210px;
                min-height: 100vh;
                background: var(--sidebar-bg);
                display: flex;
                flex-direction: column;
                position: fixed;
                top: 0;
                left: 0;
            }
            .sidebar-brand {
                padding: 22px 18px;
                color: white;
                font-size: 1rem;
                font-weight: 800;
                border-bottom: 1px solid rgba(255,255,255,0.08);
                letter-spacing: 0.3px;
            }
            .sidebar-brand i {
                color: var(--accent);
                margin-right: 8px;
            }
            .sidebar-nav {
                flex: 1;
                padding: 14px 0;
            }
            .nav-item {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 11px 20px;
                color: rgba(255,255,255,0.65);
                text-decoration: none;
                font-size: 0.855rem;
                font-weight: 500;
                transition: all 0.2s;
                border-left: 3px solid transparent;
            }
            .nav-item:hover, .nav-item.active {
                color: white;
                background: rgba(255,255,255,0.07);
                border-left-color: var(--accent);
            }
            .nav-item i {
                width: 17px;
                text-align: center;
                font-size: 0.82rem;
            }
            .sidebar-footer {
                padding: 16px;
                border-top: 1px solid rgba(255,255,255,0.08);
            }
            .btn-logout {
                display: flex;
                align-items: center;
                gap: 8px;
                color: rgba(255,255,255,0.55);
                text-decoration: none;
                font-size: 0.83rem;
                padding: 9px 12px;
                border-radius: 8px;
                transition: all 0.2s;
            }
            .btn-logout:hover {
                color: #f87171;
                background: rgba(248,113,113,0.1);
            }

            /* ── MAIN ── */
            .main {
                margin-left: 210px;
                flex: 1;
                padding: 32px 36px;
            }

            /* ── TOPBAR ── */
            .topbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 28px;
            }
            .topbar-left h1 {
                font-size: 1.55rem;
                font-weight: 800;
                color: var(--text);
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .topbar-left h1 i {
                color: var(--primary);
                font-size: 1.4rem;
            }
            .topbar-left p {
                color: var(--muted);
                font-size: 0.875rem;
                margin-top: 4px;
            }

            .user-badge {
                background: white;
                border: 1px solid var(--border);
                border-radius: 24px;
                padding: 8px 16px;
                font-size: 0.82rem;
                color: var(--muted);
                display: flex;
                align-items: center;
                gap: 7px;
                box-shadow: 0 1px 4px rgba(0,0,0,0.06);
            }
            .user-badge i {
                color: var(--primary);
                font-size: 1rem;
            }
            .user-badge strong {
                color: var(--text);
            }

            /* ── WELCOME BANNER ── */
            .welcome-banner {
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
                border-radius: 16px;
                padding: 28px 32px;
                margin-bottom: 28px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                overflow: hidden;
                position: relative;
            }
            .welcome-banner::before {
                content: '';
                position: absolute;
                top: -40px;
                right: -40px;
                width: 200px;
                height: 200px;
                background: radial-gradient(circle, rgba(99,102,241,0.3) 0%, transparent 70%);
                border-radius: 50%;
            }
            .welcome-banner::after {
                content: '';
                position: absolute;
                bottom: -60px;
                right: 120px;
                width: 160px;
                height: 160px;
                background: radial-gradient(circle, rgba(74,222,128,0.15) 0%, transparent 70%);
                border-radius: 50%;
            }
            .welcome-text {
                position: relative;
                z-index: 1;
            }
            .welcome-text h2 {
                color: white;
                font-size: 1.35rem;
                font-weight: 700;
                margin-bottom: 6px;
            }
            .welcome-text h2 span {
                color: var(--accent);
            }
            .welcome-text p {
                color: rgba(255,255,255,0.65);
                font-size: 0.88rem;
            }
            .welcome-icon {
                font-size: 4rem;
                opacity: 0.2;
                position: absolute;
                right: 32px;
                z-index: 0;
            }

            /* ── NAV CARDS GRID ── */
            .section-title {
                font-size: 0.78rem;
                font-weight: 700;
                color: var(--muted);
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 14px;
            }

            .nav-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 16px;
                margin-bottom: 28px;
            }

            .nav-card {
                background: white;
                border-radius: 14px;
                border: 1px solid var(--border);
                padding: 24px 22px;
                text-decoration: none;
                display: flex;
                flex-direction: column;
                gap: 14px;
                transition: all 0.22s ease;
                cursor: pointer;
                position: relative;
                overflow: hidden;
            }
            .nav-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 3px;
                background: var(--card-color, #6366f1);
                transform: scaleX(0);
                transition: transform 0.22s ease;
                transform-origin: left;
            }
            .nav-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 12px 32px rgba(0,0,0,0.1);
                border-color: transparent;
            }
            .nav-card:hover::before {
                transform: scaleX(1);
            }

            .nav-card-icon {
                width: 48px;
                height: 48px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.2rem;
                background: var(--card-bg, #ede9fe);
                color: var(--card-color, #6366f1);
                transition: transform 0.2s;
            }
            .nav-card:hover .nav-card-icon {
                transform: scale(1.1) rotate(-4deg);
            }

            .nav-card-content h3 {
                font-size: 0.95rem;
                font-weight: 700;
                color: var(--text);
                margin-bottom: 4px;
            }
            .nav-card-content p {
                font-size: 0.8rem;
                color: var(--muted);
                line-height: 1.5;
            }

            .nav-card-arrow {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-top: auto;
            }
            .nav-card-arrow span {
                font-size: 0.78rem;
                font-weight: 600;
                color: var(--card-color, #6366f1);
            }
            .nav-card-arrow i {
                font-size: 0.75rem;
                color: var(--card-color, #6366f1);
                transition: transform 0.2s;
            }
            .nav-card:hover .nav-card-arrow i {
                transform: translateX(4px);
            }

            /* Color variants */
            .card-indigo  {
                --card-color: #6366f1;
                --card-bg: #ede9fe;
            }
            .card-emerald {
                --card-color: #10b981;
                --card-bg: #d1fae5;
            }
            .card-sky     {
                --card-color: #0891b2;
                --card-bg: #e0f2fe;
            }
            .card-amber   {
                --card-color: #d97706;
                --card-bg: #fef3c7;
            }
            .card-rose    {
                --card-color: #e11d48;
                --card-bg: #ffe4e6;
            }
            .card-violet  {
                --card-color: #7c3aed;
                --card-bg: #ede9fe;
            }

            /* ── QUICK LINKS ROW ── */
            .quick-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 16px;
            }
            .quick-card {
                background: white;
                border-radius: 14px;
                border: 1px solid var(--border);
                padding: 20px 22px;
                text-decoration: none;
                display: flex;
                align-items: center;
                gap: 16px;
                transition: all 0.2s;
            }
            .quick-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 24px rgba(0,0,0,0.08);
                border-color: transparent;
            }
            .quick-icon {
                width: 42px;
                height: 42px;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1rem;
                flex-shrink: 0;
            }
            .quick-text h4 {
                font-size: 0.88rem;
                font-weight: 700;
                color: var(--text);
                margin-bottom: 2px;
            }
            .quick-text p  {
                font-size: 0.77rem;
                color: var(--muted);
            }

            /* Entrance animation */
            @keyframes fadeUp {
                from {
                    opacity: 0;
                    transform: translateY(16px);
                }
                to   {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            .welcome-banner {
                animation: fadeUp 0.4s ease both;
            }
            .nav-card:nth-child(1) {
                animation: fadeUp 0.4s 0.05s ease both;
            }
            .nav-card:nth-child(2) {
                animation: fadeUp 0.4s 0.10s ease both;
            }
            .nav-card:nth-child(3) {
                animation: fadeUp 0.4s 0.15s ease both;
            }
            .nav-card:nth-child(4) {
                animation: fadeUp 0.4s 0.20s ease both;
            }
            .nav-card:nth-child(5) {
                animation: fadeUp 0.4s 0.25s ease both;
            }
            .quick-card {
                animation: fadeUp 0.4s 0.30s ease both;
            }
        </style>
    </head>
    <body>

        <!-- ── SIDEBAR ── -->
        <aside class="sidebar">
            <div class="sidebar-brand"><i class="fas fa-warehouse"></i> DRSMS System</div>
            <nav class="sidebar-nav">
                <a href="<%= ctx %>/dashboard.jsp"    class="nav-item active"><i class="fas fa-home"></i> Home</a>
                <a href="<%= ctx %>/profile.jsp"      class="nav-item"><i class="fas fa-user-circle"></i> Profile</a>
                <a href="<%= ctx %>/storekeeper"      class="nav-item"><i class="fas fa-chart-bar"></i> Statistics</a>
                <a href="<%= ctx %>/numberPart"       class="nav-item"><i class="fas fa-list-ul"></i> Parts List</a>
                <a href="<%= ctx %>/numberEquipment"  class="nav-item"><i class="fas fa-desktop"></i> Equipment List</a>
                <a href="<%= ctx %>/transactions"     class="nav-item"><i class="fas fa-history"></i> Transaction History</a>
                
            </nav>
            <div class="sidebar-footer">
                <a href="<%= ctx %>/logout" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </aside>

        <!-- ── MAIN ── -->
        <main class="main">

            <!-- Topbar -->
            <div class="topbar">
                <div class="topbar-left">
                    <h1><i class="fas fa-th-large"></i> Dashboard</h1>
                    <p>Welcome back! Select a function below to get started.</p>
                </div>
                <div class="user-badge">
                    <i class="fas fa-user-circle"></i>
                    <strong><%= currentUser.getUsername() %></strong>
                    &nbsp;·&nbsp; Storekeeper
                </div>
            </div>

            <!-- Welcome Banner -->
            <div class="welcome-banner">
                <div class="welcome-text">
                    <h2>Hello, <span><%= currentUser.getFullName() != null ? currentUser.getFullName() : currentUser.getUsername() %>!</span></h2>
                    <p>Manage your warehouse, parts, and equipment here.</p>
                </div>
                <i class="fas fa-warehouse welcome-icon"></i>
            </div>

            <!-- Main Nav Cards -->
            <div class="section-title">Main Functions</div>
            <div class="nav-grid">

                <!-- Statistics -->
                <a href="<%= ctx %>/storekeeper" class="nav-card card-indigo">
                    <div class="nav-card-icon"><i class="fas fa-chart-bar"></i></div>
                    <div class="nav-card-content">
                        <h3>Warehouse Statistics</h3>
                        <p>View an overview of parts and equipment stock status.</p>
                    </div>
                    <div class="nav-card-arrow">
                        <span>View statistics</span>
                        <i class="fas fa-arrow-right"></i>
                    </div>
                </a>

                <!-- Parts List -->
                <a href="<%= ctx %>/numberPart" class="nav-card card-emerald">
                    <div class="nav-card-icon"><i class="fas fa-list-ul"></i></div>
                    <div class="nav-card-content">
                        <h3>Parts List</h3>
                        <p>Manage, add, edit, and delete part types.</p>
                    </div>
                    <div class="nav-card-arrow">
                        <span>Manage parts</span>
                        <i class="fas fa-arrow-right"></i>
                    </div>
                </a>

                <!-- Equipment List -->
                <a href="<%= ctx %>/numberEquipment" class="nav-card card-sky">
                    <div class="nav-card-icon"><i class="fas fa-desktop"></i></div>
                    <div class="nav-card-content">
                        <h3>Equipment List</h3>
                        <p>Manage equipment models and stock entries by serial number.</p>
                    </div>
                    <div class="nav-card-arrow">
                        <span>Manage equipment</span>
                        <i class="fas fa-arrow-right"></i>
                    </div>
                </a>

                <!-- Transaction History -->
                <a href="<%= ctx %>/transactions" class="nav-card card-amber">
                    <div class="nav-card-icon"><i class="fas fa-history"></i></div>
                    <div class="nav-card-content">
                        <h3>Transaction History</h3>
                        <p>Look up purchase, repair, and stock-in history.</p>
                    </div>
                    <div class="nav-card-arrow">
                        <span>View history</span>
                        <i class="fas fa-arrow-right"></i>
                    </div>
                </a>

                <!-- Category Management -->
                

                <!-- Profile -->
                <a href="<%= ctx %>/profile.jsp" class="nav-card card-rose">
                    <div class="nav-card-icon"><i class="fas fa-user-circle"></i></div>
                    <div class="nav-card-content">
                        <h3>Personal Profile</h3>
                        <p>View and update your account information.</p>
                    </div>
                    <div class="nav-card-arrow">
                        <span>View profile</span>
                        <i class="fas fa-arrow-right"></i>
                    </div>
                </a>

            </div>

        </main>
    </body>
</html>
