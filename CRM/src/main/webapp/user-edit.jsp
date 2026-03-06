<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Role, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (request.getAttribute("editUser") == null) {
        response.sendRedirect(request.getContextPath() + "/user/list");
        return;
    }
    User editUser    = (User) request.getAttribute("editUser");
    List<Role> roles = (List<Role>) request.getAttribute("roles");
    String success   = request.getParameter("success");
    String error     = request.getParameter("error");
    String ctx       = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Edit User</title>
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
                margin-bottom:20px;
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
                margin-bottom:20px;
            }
            .card-header {
                background:linear-gradient(135deg,#2c3e50,#34495e);
                color:white;
                border-radius:10px 10px 0 0;
                padding:15px 20px;
                margin:-30px -30px 25px;
                display:flex;
                align-items:center;
                gap:10px;
                font-weight:600;
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
            .form-group input, .form-group select {
                padding:10px 14px;
                border:1px solid #ddd;
                border-radius:8px;
                font-size:0.9rem;
            }
            .form-group input:disabled {
                background:#f8f9fa;
                color:#7f8c8d;
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
            .form-actions {
                display:flex;
                justify-content:flex-end;
                gap:10px;
                margin-top:15px;
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
            .btn-update {
                background:#3498db;
                color:white;
                padding:10px 22px;
                border:none;
                border-radius:8px;
                cursor:pointer;
                font-size:0.9rem;
                font-weight:600;
            }
            .btn-pass {
                background:#f39c12;
                color:white;
                padding:10px 22px;
                border:none;
                border-radius:8px;
                cursor:pointer;
                font-size:0.9rem;
                font-weight:600;
            }
            .alert {
                padding:12px 18px;
                border-radius:8px;
                margin-bottom:16px;
                font-size:0.9rem;
            }
            .alert-success {
                background:#eafaf1;
                color:#27ae60;
                border:1px solid #a9dfbf;
            }
            .alert-error {
                background:#fdedec;
                color:#e74c3c;
                border:1px solid #f5b7b1;
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
                <div class="page-title"><i class="fas fa-user-edit"></i> Edit User</div>
                <a href="<%= ctx %>/user/list" class="btn-back"><i class="fas fa-arrow-left"></i> Back</a>
            </div>

            <% if ("updated".equals(success)) { %><div class="alert alert-success">Updated successfully!</div><% } %>
            <% if ("password_changed".equals(success)) { %><div class="alert alert-success">Password changed successfully!</div><% } %>
            <% if ("password_mismatch".equals(error)) { %><div class="alert alert-error">Confirm password does not match!</div><% } %>

            <form method="post" action="<%= ctx %>/user/edit">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" value="<%= editUser.getId() %>">
                <div class="card">
                    <div class="card-header"><i class="fas fa-user-edit"></i> User Information</div>
                    <div class="form-grid">
                        <div class="form-group">
                            <label><i class="fas fa-user"></i> Username</label>
                            <input type="text" value="<%= editUser.getUsername() != null ? editUser.getUsername() : "" %>" disabled>
                            <span class="hint">Username cannot be changed</span>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-envelope"></i> Email <span style="color:#e74c3c;">*</span></label>
                            <input type="email" name="email" value="<%= editUser.getEmail() != null ? editUser.getEmail() : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-id-card"></i> Full Name</label>
                            <input type="text" name="fullName" value="<%= editUser.getFullName() %>">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-phone"></i> Phone Number</label>
                            <input type="text" name="phone" value="<%= editUser.getPhone() != null ? editUser.getPhone() : "" %>">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-toggle-on"></i> Status</label>
                            <select name="active">
                                <option value="1" <%= editUser.isActive() ? "selected" : "" %>>Active</option>
                                <option value="0" <%= !editUser.isActive() ? "selected" : "" %>>Locked</option>
                            </select>
                        </div>
                    </div>
                    <div style="margin-top:20px;">
                        <label style="font-size:0.88rem; font-weight:600; color:#2c3e50; display:flex; align-items:center; gap:6px; margin-bottom:10px;">
                            <i class="fas fa-user-tag"></i> Role
                        </label>
                        <div class="roles-grid">
                            <% if (roles != null) for (Role r : roles) { %>
                            <label class="role-option">
                                <input type="radio" name="roleId" value="<%= r.getId() %>" <%= r.getId() == editUser.getRoleId() ? "checked" : "" %>>
                                <%= r.getName().replace("_"," ") %>
                            </label>
                            <% } %>
                        </div>
                        <span class="hint" style="margin-top:8px; display:block;"><i class="fas fa-info-circle"></i> Role changes are saved automatically</span>
                    </div>
                    <div class="form-actions">
                        <a href="<%= ctx %>/user/list" class="btn-cancel">✕ Cancel</a>
                        <button type="submit" class="btn-update"><i class="fas fa-save"></i> Update</button>
                    </div>
                </div>
            </form>

            <form method="post" action="<%= ctx %>/user/edit">
                <input type="hidden" name="action" value="changePassword">
                <input type="hidden" name="id" value="<%= editUser.getId() %>">
                <div class="card">
                    <div class="card-header" style="background:linear-gradient(135deg,#1a1a2e,#16213e);"><i class="fas fa-key"></i> Change Password</div>
                    <div class="form-grid">
                        <div class="form-group">
                            <label><i class="fas fa-lock"></i> New Password <span style="color:#e74c3c;">*</span></label>
                            <div class="pass-wrapper">
                                <input type="password" name="newPassword" id="newPass" required placeholder="Enter new password">
                                <button type="button" class="pass-toggle" onclick="togglePass('newPass', this)"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-lock"></i> Confirm Password <span style="color:#e74c3c;">*</span></label>
                            <div class="pass-wrapper">
                                <input type="password" name="confirmPassword" id="confirmPass" required placeholder="Re-enter password">
                                <button type="button" class="pass-toggle" onclick="togglePass('confirmPass', this)"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="submit" class="btn-pass"><i class="fas fa-key"></i> Change Password</button>
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
