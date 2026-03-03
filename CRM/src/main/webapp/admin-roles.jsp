<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Role, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (request.getAttribute("roles") == null) {
        response.sendRedirect(request.getContextPath() + "/role/list");
        return;
    }
    List<Role> roles = (List<Role>) request.getAttribute("roles");
    String success   = request.getParameter("success");
    String ctx       = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản Lý Vai Trò</title>
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
            .alert-success {
                background:#eafaf1;
                color:#27ae60;
                border:1px solid #a9dfbf;
                padding:12px 18px;
                border-radius:8px;
                margin-bottom:16px;
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
                padding:14px 20px;
                text-align:left;
                font-size:0.8rem;
                font-weight:700;
                color:#7f8c8d;
                text-transform:uppercase;
            }
            td {
                padding:14px 20px;
                border-bottom:1px solid #f0f0f0;
                color:#2c3e50;
                font-size:0.95rem;
            }
            tr:last-child td {
                border-bottom:none;
            }
            tr:hover td {
                background:#fafafa;
            }
            .role-badge {
                display:inline-block;
                padding:5px 14px;
                border-radius:20px;
                font-size:0.85rem;
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
            .action-btns {
                display:flex;
                gap:8px;
            }
            .btn-icon {
                width:32px;
                height:32px;
                border-radius:6px;
                border:none;
                cursor:pointer;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:0.85rem;
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
        </style>
    </head>
    <body>
        <div class="sidebar">
            <div class="sidebar-brand"><i class="fas fa-cog"></i> Admin CRM</div>
            <div class="sidebar-menu">
                <a href="<%= ctx %>/admin.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a>
                <a href="<%= ctx %>/user/list"><i class="fas fa-users"></i> Người Dùng</a>
                <a href="<%= ctx %>/role/list" class="active"><i class="fas fa-user-tag"></i> Vai Trò</a>
            </div>
            <div class="sidebar-logout">
                <a href="<%= ctx %>/logout"><i class="fas fa-sign-out-alt"></i> Đăng Xuất</a>
            </div>
        </div>
        <div class="main">
            <div class="page-header">
                <div class="page-title"><i class="fas fa-user-tag"></i> Quản Lý Vai Trò</div>
            </div>
            <% if ("updated".equals(success)) { %><div class="alert-success">Cập nhật vai trò thành công!</div><% } %>
            <% if ("deleted".equals(success)) { %><div class="alert-success">Xóa vai trò thành công! Người dùng đã được chuyển về Customer.</div><% } %>
            <div class="table-card">
                <table>
                    <thead>
                        <tr><th># ID</th><th>Tên Vai Trò</th><th>Thao Tác</th></tr>
                    </thead>
                    <tbody>
                        <% if (roles != null) for (Role r : roles) { %>
                        <tr>
                            <td><strong style="color:#3498db;">#<%= r.getId() %></strong></td>
                            <td><span class="role-badge role-<%= r.getName() %>"><%= r.getName().replace("_"," ") %></span></td>
                            <td>
                                <div class="action-btns">
                                    <a href="<%= ctx %>/role/edit?action=edit&id=<%= r.getId() %>" class="btn-icon btn-edit" title="Sửa"><i class="fas fa-edit"></i></a>
                                    <a href="<%= ctx %>/role/delete?action=delete&id=<%= r.getId() %>"
                                       class="btn-icon btn-delete" title="Xóa"
                                       onclick="return confirm('Bạn có chắc muốn xóa vai trò này? Người dùng sẽ tự động chuyển về Customer.')">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>