<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Role, java.util.List, java.net.URLEncoder" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (request.getAttribute("currentPage") == null) {
        response.sendRedirect(request.getContextPath() + "/user/list");
        return;
    }
    List<User> users = (List<User>) request.getAttribute("users");
    List<Role> roles  = (List<Role>) request.getAttribute("roles");
    int currentPage   = (Integer) request.getAttribute("currentPage");
    int totalPages    = (Integer) request.getAttribute("totalPages");
    int total         = (Integer) request.getAttribute("total");
    String keyword    = request.getAttribute("keyword") != null ? (String) request.getAttribute("keyword") : "";
    String status     = request.getAttribute("status")  != null ? (String) request.getAttribute("status")  : "";
    String role       = request.getAttribute("role")    != null ? (String) request.getAttribute("role")    : "";
    String success    = request.getParameter("success");
    String error      = request.getParameter("error");
    String ctx        = request.getContextPath();

    String kwEnc = URLEncoder.encode(keyword, "UTF-8");
    String stEnc = URLEncoder.encode(status, "UTF-8");
    String rlEnc = URLEncoder.encode(role, "UTF-8");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>User Management</title>
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
                font-size:1.6rem;
                font-weight:700;
                color:#2c3e50;
                display:flex;
                align-items:center;
                gap:10px;
            }
            .page-title i {
                color:#3498db;
            }
            .btn-add {
                background:#3498db;
                color:white;
                padding:10px 20px;
                border-radius:8px;
                text-decoration:none;
                font-weight:600;
                font-size:0.9rem;
                display:flex;
                align-items:center;
                gap:8px;
            }
            .btn-add:hover {
                background:#2980b9;
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
            .search-bar {
                background:white;
                border-radius:12px;
                padding:20px 25px;
                margin-bottom:20px;
                box-shadow:0 2px 10px rgba(0,0,0,0.06);
                display:flex;
                gap:12px;
                align-items:center;
                flex-wrap:wrap;
            }
            .search-bar input, .search-bar select {
                padding:9px 14px;
                border:1px solid #ddd;
                border-radius:8px;
                font-size:0.9rem;
            }
            .search-bar input {
                flex:1;
                min-width:200px;
            }
            .btn-search {
                background:#3498db;
                color:white;
                padding:9px 20px;
                border:none;
                border-radius:8px;
                cursor:pointer;
                font-weight:600;
            }
            .btn-reset {
                background:#ecf0f1;
                color:#7f8c8d;
                padding:9px 20px;
                border:none;
                border-radius:8px;
                cursor:pointer;
                font-weight:600;
                text-decoration:none;
            }
            .table-card {
                background:white;
                border-radius:12px;
                box-shadow:0 2px 10px rgba(0,0,0,0.06);
                overflow:hidden;
            }
            table {
                width:100%;
                border-collapse:collapse;
            }
            thead {
                background:#f8f9fa;
            }
            th {
                padding:14px 16px;
                text-align:left;
                font-size:0.78rem;
                font-weight:700;
                color:#7f8c8d;
                text-transform:uppercase;
            }
            td {
                padding:12px 16px;
                border-bottom:1px solid #f0f0f0;
                color:#2c3e50;
                font-size:0.88rem;
            }
            tr:last-child td {
                border-bottom:none;
            }
            tr:hover td {
                background:#fafafa;
            }
            .role-badge {
                display:inline-block;
                padding:3px 10px;
                border-radius:20px;
                font-size:0.78rem;
                font-weight:600;
            }
            .role-ADMIN {
                background:#3498db;
                color:white;
            }
            .role-CUSTOMER {
                background:#27ae60;
                color:white;
            }
            .role-CUSTOMER_SUPPORT {
                background:#9b59b6;
                color:white;
            }
            .role-TECHNICAL_MANAGER {
                background:#e67e22;
                color:white;
            }
            .role-STOREKEEPER {
                background:#1abc9c;
                color:white;
            }
            .role-TECHNICIAN {
                background:#00bcd4;
                color:white;
            }
            .status-active {
                background:#eafaf1;
                color:#27ae60;
                padding:3px 10px;
                border-radius:20px;
                font-size:0.78rem;
                font-weight:600;
            }
            .status-inactive {
                background:#fdedec;
                color:#e74c3c;
                padding:3px 10px;
                border-radius:20px;
                font-size:0.78rem;
                font-weight:600;
            }
            .action-btns {
                display:flex;
                gap:5px;
            }
            .btn-icon {
                width:30px;
                height:30px;
                border-radius:6px;
                border:none;
                cursor:pointer;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:0.8rem;
                text-decoration:none;
            }
            .btn-edit {
                background:#ebf5fb;
                color:#3498db;
            }
            .btn-delete {
                background:#fdedec;
                color:#e74c3c;
            }
            .btn-edit:hover {
                background:#3498db;
                color:white;
            }
            .btn-delete:hover {
                background:#e74c3c;
                color:white;
            }
            .pagination {
                display:flex;
                justify-content:center;
                align-items:center;
                gap:8px;
                padding:20px;
            }
            .pagination a, .pagination span {
                padding:7px 13px;
                border-radius:7px;
                text-decoration:none;
                font-size:0.9rem;
            }
            .pagination a {
                background:#ecf0f1;
                color:#2c3e50;
            }
            .pagination a:hover {
                background:#3498db;
                color:white;
            }
            .pagination .active {
                background:#3498db;
                color:white;
                font-weight:700;
            }
            .pagination .disabled {
                color:#bdc3c7;
            }
            .total-info {
                text-align:center;
                color:#7f8c8d;
                font-size:0.85rem;
                padding-bottom:10px;
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
                <div class="page-title"><i class="fas fa-users"></i> User Management</div>
                <a href="<%= ctx %>/user/create?action=create" class="btn-add"><i class="fas fa-plus"></i> Add User</a>
            </div>

            <% if ("created".equals(success)) { %><div class="alert alert-success">User created successfully!</div><% } %>
            <% if ("updated".equals(success)) { %><div class="alert alert-success">Updated successfully!</div><% } %>
            <% if ("deleted".equals(success)) { %><div class="alert alert-success">Deleted successfully!</div><% } %>
            <% if (error != null) { %><div class="alert alert-error">An error occurred!</div><% } %>

            <form method="get" action="<%= ctx %>/user/list">
                <div class="search-bar">
                    <input type="text" name="keyword" placeholder="Username, email, name..." value="<%= keyword %>">
                    <select name="status">
                        <option value="">All statuses</option>
                        <option value="1" <%= "1".equals(status) ? "selected" : "" %>>Active</option>
                        <option value="0" <%= "0".equals(status) ? "selected" : "" %>>Locked</option>
                    </select>
                    <select name="role">
                        <option value="">All roles</option>
                        <% if (roles != null) for (Role r : roles) { %>
                        <option value="<%= r.getName() %>" <%= r.getName().equals(role) ? "selected" : "" %>><%= r.getName().replace("_"," ") %></option>
                        <% } %>
                    </select>
                    <button type="submit" class="btn-search"><i class="fas fa-search"></i> Search</button>
                    <a href="<%= ctx %>/user/list" class="btn-reset"><i class="fas fa-redo"></i> Reset</a>
                </div>
            </form>

            <div class="table-card">
                <table>
                    <thead>
                        <tr>
                            <th># ID</th><th>Username</th><th>Full Name</th>
                            <th>Email</th><th>Phone</th><th>Role</th>
                            <th>Status</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (users != null) for (User u : users) { %>
                        <tr>
                            <td><strong style="color:#3498db;">#<%= u.getId() %></strong></td>
                            <td><%= u.getUsername() != null ? u.getUsername() : "-" %></td>
                            <td><%= u.getFullName() %></td>
                            <td><%= u.getEmail() != null ? u.getEmail() : "-" %></td>
                            <td><%= u.getPhone() != null ? u.getPhone() : "-" %></td>
                            <td><span class="role-badge role-<%= u.getRoleName() %>"><%= u.getRoleName() != null ? u.getRoleName().replace("_"," ") : "-" %></span></td>
                            <td>
                                <% if (u.isActive()) { %>
                                <span class="status-active"><i class="fas fa-circle" style="font-size:0.5rem;"></i> Active</span>
                                <% } else { %>
                                <span class="status-inactive"><i class="fas fa-circle" style="font-size:0.5rem;"></i> Locked</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="action-btns">
                                    <a href="<%= ctx %>/user/edit?action=edit&id=<%= u.getId() %>" class="btn-icon btn-edit" title="Edit"><i class="fas fa-edit"></i></a>
                                    <a href="<%= ctx %>/user/delete?action=delete&id=<%= u.getId() %>"
                                       class="btn-icon btn-delete" title="Delete"
                                       onclick="return confirm('Are you sure you want to delete this user?')">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <% if (currentPage > 1) { %>
                    <a href="<%= ctx %>/user/list?page=<%= currentPage-1 %>&keyword=<%= kwEnc %>&status=<%= stEnc %>&role=<%= rlEnc %>">‹ Previous</a>
                    <% } else { %><span class="disabled">‹ Previous</span><% } %>
                    <% for (int i = 1; i <= totalPages; i++) { %>
                    <% if (i == currentPage) { %><span class="active"><%= i %></span>
                    <% } else { %><a href="<%= ctx %>/user/list?page=<%= i %>&keyword=<%= kwEnc %>&status=<%= stEnc %>&role=<%= rlEnc %>"><%= i %></a><% } %>
                    <% } %>
                    <% if (currentPage < totalPages) { %>
                    <a href="<%= ctx %>/user/list?page=<%= currentPage+1 %>&keyword=<%= kwEnc %>&status=<%= stEnc %>&role=<%= rlEnc %>">Next ›</a>
                    <% } else { %><span class="disabled">Next ›</span><% } %>
                </div>
                <div class="total-info">Page <%= currentPage %> / <%= totalPages %> (Total: <%= total %> users)</div>
                <% } %>
            </div>
        </div>
    </body>
</html>
