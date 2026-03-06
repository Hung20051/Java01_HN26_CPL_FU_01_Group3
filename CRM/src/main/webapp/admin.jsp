<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.UserDAO, dao.RoleDAO" %>
<%
    User currentUser = (User) session.getAttribute("user");
    int totalUsers = 0;
    int totalRoles = 0;
    try {
        totalUsers = new UserDAO().countAll();
        totalRoles = new RoleDAO().countAll();
    } catch (Exception e) { e.printStackTrace(); }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Admin Dashboard</title>
        <link rel="stylesheet" href="css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                margin:0;
                padding:0;
                box-sizing:border-box;
            }
            body {
                font-family:'Segoe UI',sans-serif;
                background:#f0f2f5;
                display:flex;
            }
            .sidebar {
                width:220px;
                min-height:100vh;
                background:#1a1a2e;
                display:flex;
                flex-direction:column;
                position:fixed;
                top:0;
                left:0;
            }
            .sidebar-brand {
                padding:20px;
                color:white;
                font-size:1.1rem;
                font-weight:700;
                border-bottom:1px solid rgba(255,255,255,0.1);
                display:flex;
                align-items:center;
                gap:10px;
            }
            .sidebar-brand i {
                color:#f39c12;
                font-size:1.4rem;
            }
            .sidebar-menu {
                flex:1;
                padding:15px 0;
            }
            .sidebar-menu a {
                display:flex;
                align-items:center;
                gap:12px;
                padding:12px 20px;
                color:rgba(255,255,255,0.7);
                text-decoration:none;
                font-size:0.95rem;
                transition:all 0.2s;
            }
            .sidebar-menu a:hover, .sidebar-menu a.active {
                background:rgba(255,255,255,0.1);
                color:white;
                border-left:3px solid #f39c12;
            }
            .sidebar-menu a i {
                width:20px;
                text-align:center;
            }
            .sidebar-logout {
                padding:15px 20px;
                border-top:1px solid rgba(255,255,255,0.1);
            }
            .sidebar-logout a {
                display:flex;
                align-items:center;
                gap:10px;
                color:rgba(255,255,255,0.6);
                text-decoration:none;
                font-size:0.9rem;
            }
            .sidebar-logout a:hover {
                color:#e74c3c;
            }
            .main {
                margin-left:220px;
                flex:1;
                padding:30px;
            }
            .page-title {
                font-size:1.6rem;
                font-weight:700;
                color:#2c3e50;
                margin-bottom:25px;
                display:flex;
                align-items:center;
                gap:10px;
            }
            .page-title i {
                color:#3498db;
            }
            .welcome-banner {
                background:linear-gradient(135deg,#667eea,#764ba2);
                color:white;
                border-radius:12px;
                padding:20px 25px;
                margin-bottom:25px;
                display:flex;
                align-items:center;
                gap:15px;
            }
            .welcome-banner i {
                font-size:2rem;
                opacity:0.9;
            }
            .welcome-banner h3 {
                font-size:1.1rem;
                margin-bottom:4px;
            }
            .welcome-banner p {
                opacity:0.85;
                font-size:0.9rem;
            }
            .cards-grid {
                display:grid;
                grid-template-columns:repeat(2,1fr);
                gap:20px;
                margin-bottom:25px;
            }
            .card {
                background:white;
                border-radius:12px;
                padding:25px;
                box-shadow:0 2px 10px rgba(0,0,0,0.06);
                text-align:center;
            }
            .card i {
                font-size:2.5rem;
                margin-bottom:15px;
            }
            .card h3 {
                font-size:1.1rem;
                color:#2c3e50;
                margin-bottom:10px;
            }
            .card p {
                color:#7f8c8d;
                font-size:0.9rem;
                margin-bottom:15px;
            }
            .card .btn {
                display:block;
                padding:9px;
                border-radius:8px;
                text-decoration:none;
                font-size:0.9rem;
                font-weight:600;
                margin-bottom:8px;
                text-align:center;
            }
            .btn-blue {
                background:#3498db;
                color:white;
            }
            .btn-green {
                background:#27ae60;
                color:white;
            }
            .btn-outline {
                border:1px solid #3498db;
                color:#3498db;
                background:white;
            }
            .btn:hover {
                opacity:0.85;
            }
            .stats-grid {
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:20px;
                margin-bottom:25px;
            }
            .stat-card {
                background:white;
                border-radius:12px;
                padding:20px 25px;
                box-shadow:0 2px 10px rgba(0,0,0,0.06);
                display:flex;
                align-items:center;
                gap:15px;
            }
            .stat-icon {
                width:50px;
                height:50px;
                border-radius:12px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.3rem;
                color:white;
            }
            .stat-icon.blue {
                background:#3498db;
            }
            .stat-icon.green {
                background:#27ae60;
            }
            .stat-icon.orange {
                background:#f39c12;
            }
            .stat-info h4 {
                font-size:1.5rem;
                font-weight:700;
                color:#2c3e50;
            }
            .stat-info p {
                color:#7f8c8d;
                font-size:0.85rem;
            }
            .system-info {
                background:white;
                border-radius:12px;
                padding:25px;
                box-shadow:0 2px 10px rgba(0,0,0,0.06);
            }
            .system-info h3 {
                font-size:1rem;
                font-weight:700;
                color:#2c3e50;
                margin-bottom:15px;
                display:flex;
                align-items:center;
                gap:8px;
            }
            .info-grid {
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:20px;
            }
            .info-col h4 {
                font-size:0.85rem;
                font-weight:600;
                color:#3498db;
                margin-bottom:10px;
                text-transform:uppercase;
            }
            .info-item {
                display:flex;
                align-items:center;
                gap:8px;
                color:#555;
                font-size:0.9rem;
                margin-bottom:8px;
            }
            .info-item i {
                color:#27ae60;
                font-size:0.8rem;
            }
        </style>
    </head>
    <body>
        <div class="sidebar">
            <div class="sidebar-brand"><i class="fas fa-cog"></i> Admin DRSMS</div>
            <div class="sidebar-menu">
                <a href="<%= ctx %>/admin.jsp" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a>
                <a href="<%= ctx %>/user/list"><i class="fas fa-users"></i> Users</a>
                <a href="<%= ctx %>/role/list"><i class="fas fa-user-tag"></i> Roles</a>
            </div>
            <div class="sidebar-logout">
                <a href="<%= ctx %>/logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
        <div class="main">
            <div class="page-title"><i class="fas fa-tachometer-alt"></i> Admin Control Panel</div>
            <div class="welcome-banner">
                <i class="fas fa-info-circle"></i>
                <div>
                    <h3>Welcome, <%= currentUser.getFullName() %>!</h3>
                    <p>Here you can manage users, roles and system settings.</p>
                </div>
            </div>
            <div class="cards-grid">
                <div class="card">
                    <i class="fas fa-users" style="color:#3498db;"></i>
                    <h3>User Management</h3>
                    <p>Create, edit and assign permissions to users in the system.</p>
                    <a href="<%= ctx %>/user/list" class="btn btn-blue">User List</a>
                    <a href="<%= ctx %>/user/create" class="btn btn-outline">+ Add User</a>
                </div>
                <div class="card">
                    <i class="fas fa-user-tag" style="color:#27ae60;"></i>
                    <h3>Role Management</h3>
                    <p>Create and manage roles and system access permissions.</p>
                    <a href="<%= ctx %>/role/list" class="btn btn-green">Role List</a>
                </div>
            </div>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fas fa-users"></i></div>
                    <div class="stat-info"><h4><%= totalUsers %></h4><p>Total Users</p></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-user-tag"></i></div>
                    <div class="stat-info"><h4><%= totalRoles %></h4><p>Total Roles</p></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon orange"><i class="fas fa-shield-alt"></i></div>
                    <div class="stat-info"><h4>Active</h4><p>System Status</p></div>
                </div>
            </div>
            <div class="system-info">
                <h3><i class="fas fa-info-circle" style="color:#3498db;"></i> System Information</h3>
                <div class="info-grid">
                    <div class="info-col">
                        <h4>Features</h4>
                        <div class="info-item"><i class="fas fa-check"></i> User CRUD</div>
                        <div class="info-item"><i class="fas fa-check"></i> Role Management</div>
                        <div class="info-item"><i class="fas fa-check"></i> System Authorization</div>
                        <div class="info-item"><i class="fas fa-check"></i> Google / Facebook Login</div>
                    </div>
                    <div class="info-col">
                        <h4>Security</h4>
                        <div class="info-item"><i class="fas fa-check"></i> BCrypt Password Encryption</div>
                        <div class="info-item"><i class="fas fa-check"></i> Role-Based Access Control</div>
                        <div class="info-item"><i class="fas fa-check"></i> Admin Access Control</div>
                        <div class="info-item"><i class="fas fa-check"></i> Session Timeout 30 minutes</div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
