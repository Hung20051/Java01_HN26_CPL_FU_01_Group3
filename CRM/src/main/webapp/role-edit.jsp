<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Role" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (request.getAttribute("role") == null) {
        response.sendRedirect(request.getContextPath() + "/role/list");
        return;
    }
    Role role  = (Role) request.getAttribute("role");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Edit Role</title>
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
                margin-bottom:20px;
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
            }
            .form-group input {
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
            .warning-box {
                background:#fef9e7;
                border:1px solid #f9e79f;
                border-radius:10px;
                padding:20px 25px;
            }
            .warning-box h4 {
                color:#e67e22;
                margin-bottom:12px;
                display:flex;
                align-items:center;
                gap:8px;
            }
            .warning-box ul {
                list-style:none;
                display:flex;
                flex-direction:column;
                gap:8px;
            }
            .warning-box ul li {
                display:flex;
                align-items:center;
                gap:10px;
                color:#555;
                font-size:0.9rem;
            }
        </style>
    </head>
    <body>
        <div class="sidebar">
            <div class="sidebar-brand"><i class="fas fa-cog"></i> Admin DRSMS</div>
            <div class="sidebar-menu">
                <a href="<%= ctx %>/admin.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a>
                <a href="<%= ctx %>/user/list"><i class="fas fa-users"></i> Users</a>
                <a href="<%= ctx %>/role/list" class="active"><i class="fas fa-user-tag"></i> Roles</a>
            </div>
            <div class="sidebar-logout">
                <a href="<%= ctx %>/logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
        <div class="main">
            <div class="page-header">
                <div class="page-title"><i class="fas fa-edit"></i> Edit Role</div>
                <a href="<%= ctx %>/role/list" class="btn-back"><i class="fas fa-arrow-left"></i> Back to List</a>
            </div>
            <form method="post" action="<%= ctx %>/role/edit">
                <input type="hidden" name="id" value="<%= role.getId() %>">
                <div class="card">
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Role Name *</label>
                            <input type="text" name="name" value="<%= role.getName() %>" required placeholder="Enter role name">
                            <span class="hint">Enter a unique name for the role</span>
                        </div>
                        <div class="form-group">
                            <label>Role ID</label>
                            <input type="text" value="<%= role.getId() %>" disabled>
                            <span class="hint">Role ID cannot be changed</span>
                        </div>
                    </div>
                    <div class="form-actions">
                        <a href="<%= ctx %>/role/list" class="btn-cancel">✕ Cancel</a>
                        <button type="submit" class="btn-update"><i class="fas fa-save"></i> Update Role</button>
                    </div>
                </div>
            </form>
            <div class="card">
                <div class="warning-box">
                    <h4><i class="fas fa-exclamation-triangle"></i> Important Notes</h4>
                    <ul>
                        <li>🔄 Changing the role name will affect all users assigned to this role</li>
                        <li>✅ Ensure the new role name is clear and accurately describes its function</li>
                        <li>⚠️ Consider the impact on system permissions and access control</li>
                    </ul>
                </div>
            </div>
        </div>
    </body>
</html>
