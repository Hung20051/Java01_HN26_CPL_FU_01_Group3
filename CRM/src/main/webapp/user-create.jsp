<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Role, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (request.getAttribute("roles") == null) {
        response.sendRedirect(request.getContextPath() + "/user/create");
        return;
    }
    List<Role> roles = (List<Role>) request.getAttribute("roles");
    String error     = (String) request.getAttribute("error");
    String ctx       = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Create New User</title>
        <link rel="stylesheet" href="<%= ctx %>/css/style.css">
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
            }
            .sidebar-logout a:hover {
                color:#e74c3c;
            }
            .main {
                margin-left:220px;
                flex:1;
                padding:30px;
            }
            .page-header {
                display:flex;
                justify-content:space-between;
                align-items:center;
                margin-bottom:25px;
            }
            .page-title {
                font-size:1.5rem;
                font-weight:700;
                color:#2c3e50;
                display:flex;
                align-items:center;
                gap:10px;
            }
            .btn-back {
                background:#7f8c8d;
                color:white;
                padding:9px 18px;
                border-radius:8px;
                text-decoration:none;
                font-size:0.9rem;
                display:flex;
                align-items:center;
                gap:7px;
            }
            .card {
                background:white;
                border-radius:12px;
                box-shadow:0 2px 10px rgba(0,0,0,0.06);
                padding:30px;
            }
            .form-grid {
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:20px;
            }
            .form-group {
                display:flex;
                flex-direction:column;
                gap:6px;
            }
            .form-group label {
                font-size:0.88rem;
                font-weight:600;
                color:#2c3e50;
                display:flex;
                align-items:center;
                gap:6px;
            }
            .required {
                color:#e74c3c;
            }
            .form-group input, .form-group select {
                padding:10px 14px;
                border:1px solid #ddd;
                border-radius:8px;
                font-size:0.9rem;
            }
            .form-group input:focus {
                outline:none;
                border-color:#3498db;
            }
            .pass-wrapper {
                position:relative;
            }
            .pass-wrapper input {
                width:100%;
                padding-right:40px;
            }
            .pass-toggle {
                position:absolute;
                right:12px;
                top:50%;
                transform:translateY(-50%);
                cursor:pointer;
                color:#7f8c8d;
                background:none;
                border:none;
            }
            .hint {
                font-size:0.8rem;
                color:#7f8c8d;
            }
            .roles-grid {
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:10px;
                margin-top:8px;
            }
            .role-option {
                display:flex;
                align-items:center;
                gap:8px;
                padding:10px 14px;
                border:1px solid #ddd;
                border-radius:8px;
                cursor:pointer;
            }
            .role-option:hover {
                border-color:#3498db;
                background:#f0f8ff;
            }
            .form-actions {
                display:flex;
                justify-content:flex-end;
                gap:10px;
                margin-top:20px;
            }
            .btn-cancel {
                background:#ecf0f1;
                color:#7f8c8d;
                padding:10px 22px;
                border:none;
                border-radius:8px;
                cursor:pointer;
                font-size:0.9rem;
                text-decoration:none;
            }
            .btn-submit {
                background:#3498db;
                color:white;
                padding:10px 22px;
                border:none;
                border-radius:8px;
                cursor:pointer;
                font-size:0.9rem;
                font-weight:600;
            }
            .alert-error {
                background:#fdedec;
                color:#e74c3c;
                border:1px solid #f5b7b1;
                padding:12px 18px;
                border-radius:8px;
                margin-bottom:16px;
            }
            .status-note {
                font-size:0.82rem;
                color:#7f8c8d;
                margin-top:4px;
            }
        </style>
    </head>
    <body>
        <div class="sidebar">
            <div class="sidebar-brand"><i class="fas fa-cog"></i> Admin DRSMS</div>
            <div class="sidebar-menu">
                <a href="<%= ctx %>/admin.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a>
                <a href="<%= ctx %>/user/list" class="active"><i class="fas fa-users"></i> Users</a>
                <a href="<%= ctx %>/role/list"><i class="fas fa-user-tag"></i> Roles</a>
            </div>
            <div class="sidebar-logout">
                <a href="<%= ctx %>/logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
        <div class="main">
            <div class="page-header">
                <div class="page-title"><i class="fas fa-user-plus"></i> Create New User</div>
                <a href="<%= ctx %>/user/list" class="btn-back"><i class="fas fa-arrow-left"></i> Back</a>
            </div>
            <% if (error != null) { %><div class="alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div><% } %>
            <form method="post" action="<%= ctx %>/user/create">
                <input type="hidden" name="action" value="create">
                <div class="card">
                    <div class="form-grid">
                        <div class="form-group">
                            <label><i class="fas fa-user"></i> Username <span class="required">*</span></label>
                            <input type="text" name="username" required placeholder="Enter username">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-id-card"></i> Full Name</label>
                            <input type="text" name="fullName" placeholder="Enter full name">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-envelope"></i> Email <span class="required">*</span></label>
                            <input type="email" name="email" required placeholder="Enter email">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-phone"></i> Phone Number</label>
                            <input type="text" name="phone" placeholder="Enter phone number">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-lock"></i> Password <span class="required">*</span></label>
                            <div class="pass-wrapper">
                                <input type="password" name="password" id="pass1" required placeholder="Enter password">
                                <button type="button" class="pass-toggle" onclick="togglePass('pass1', this)"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-lock"></i> Confirm Password <span class="required">*</span></label>
                            <div class="pass-wrapper">
                                <input type="password" name="confirmPassword" id="pass2" required placeholder="Re-enter password">
                                <button type="button" class="pass-toggle" onclick="togglePass('pass2', this)"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-toggle-on"></i> Status</label>
                            <select name="active">
                                <option value="1">Active</option>
                                <option value="0">Inactive</option>
                            </select>
                            <span class="status-note"><b>Active:</b> Saved directly. <b>Inactive:</b> Cannot log in.</span>
                        </div>
                    </div>
                    <div style="margin-top:20px;">
                        <label style="font-size:0.88rem; font-weight:600; color:#2c3e50; display:flex; align-items:center; gap:6px; margin-bottom:10px;">
                            <i class="fas fa-user-tag"></i> Role
                        </label>
                        <div class="roles-grid">
                            <% if (roles != null) for (Role r : roles) { %>
                            <label class="role-option">
                                <input type="radio" name="roleId" value="<%= r.getId() %>" <%= r.getName().equals("CUSTOMER") ? "checked" : "" %>>
                                <%= r.getName().replace("_"," ") %>
                            </label>
                            <% } %>
                        </div>
                    </div>
                    <div class="form-actions">
                        <a href="<%= ctx %>/user/list" class="btn-cancel">✕ Cancel</a>
                        <button type="submit" class="btn-submit"><i class="fas fa-user-plus"></i> Create User</button>
                    </div>
                </div>
            </form>
        </div>
        <script>
            function togglePass(id, btn) {
                const input = document.getElementById(id);
                if (input.type === 'password') {
                    input.type = 'text';
                    btn.innerHTML = '<i class="fas fa-eye-slash"></i>';
                } else {
                    input.type = 'password';
                    btn.innerHTML = '<i class="fas fa-eye"></i>';
                }
            }
        </script>
    </body>
</html>
