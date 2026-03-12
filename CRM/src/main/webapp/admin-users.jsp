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
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>User Management - DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --navy:        #0b1437;
            --navy-2:      #0f1c4d;
            --navy-card:   #111a42;
            --navy-light:  #162050;
            --accent:      #4f7ef8;
            --accent-2:    #7c9ffa;
            --accent-glow: rgba(79,126,248,0.22);
            --green:       #34d399;
            --green-dim:   rgba(52,211,153,0.12);
            --amber:       #fbbf24;
            --amber-dim:   rgba(251,191,36,0.12);
            --danger:      #f87171;
            --danger-dim:  rgba(248,113,113,0.12);
            --purple:      #a78bfa;
            --purple-dim:  rgba(167,139,250,0.12);
            --info:        #38bdf8;
            --info-dim:    rgba(56,189,248,0.12);
            --text:        #ffffff;
            --text-2:      #c8d4f0;
            --muted:       #7a8ab8;
            --border:      rgba(255,255,255,0.07);
            --border-2:    rgba(255,255,255,0.04);
            --sb-width:    248px;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; }
        body {
            font-family: 'Sora', sans-serif;
            background: var(--navy);
            color: var(--text);
            min-height: 100vh;
            display: flex;
        }
        ::-webkit-scrollbar { width: 4px; }
        ::-webkit-scrollbar-track { background: var(--navy); }
        ::-webkit-scrollbar-thumb { background: rgba(79,126,248,0.4); border-radius: 4px; }

        /* ════════════════════ SIDEBAR ════════════════════ */
        .sb {
            width: var(--sb-width);
            min-height: 100vh;
            background: rgba(9,15,40,0.95);
            backdrop-filter: blur(20px);
            border-right: 1px solid var(--border);
            display: flex; flex-direction: column;
            position: fixed; top: 0; left: 0; z-index: 100;
        }
        .sb-brand {
            padding: 22px 18px 16px;
            display: flex; align-items: center; gap: 10px;
            border-bottom: 1px solid var(--border);
        }
        .sb-logo {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, var(--amber), #f97316);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 0.88rem;
            box-shadow: 0 4px 14px rgba(251,191,36,0.3);
            flex-shrink: 0;
        }
        .sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
        .sb-role {
            display: inline-flex; align-items: center;
            background: rgba(251,191,36,0.15);
            border: 1px solid rgba(251,191,36,0.3);
            color: var(--amber);
            font-size: 0.62rem; font-weight: 700;
            letter-spacing: 1px; text-transform: uppercase;
            padding: 2px 8px; border-radius: 20px; margin-top: 3px;
        }
        .sb-nav { flex: 1; padding: 12px 10px; overflow-y: auto; }
        .sb-lbl {
            color: rgba(255,255,255,0.22);
            font-size: 0.62rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.4px;
            padding: 0 8px; margin: 16px 0 5px;
        }
        .sb-item {
            display: flex; align-items: center; gap: 9px;
            padding: 9px 10px; border-radius: 9px; margin-bottom: 1px;
            color: rgba(255,255,255,0.45); text-decoration: none;
            font-size: 0.83rem; font-weight: 500; transition: all 0.2s;
            border-left: 2px solid transparent;
        }
        .sb-item i {
            width: 28px; height: 28px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.8rem; border-radius: 8px;
            background: rgba(255,255,255,0.05);
            flex-shrink: 0; transition: all 0.2s;
        }
        .sb-item.on {
            color: #fff;
            background: linear-gradient(90deg, rgba(79,126,248,0.2), rgba(79,126,248,0.05));
            border-left: 2px solid var(--accent);
        }
        .sb-item.on i { background: rgba(79,126,248,0.25); color: var(--accent-2); }
        .sb-item.si-dash:hover   { color: #fff; background: rgba(251,191,36,0.08); border-left-color: var(--amber); }
        .sb-item.si-dash:hover i { background: rgba(251,191,36,0.18); color: var(--amber); }
        .sb-item.si-users:hover    { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
        .sb-item.si-users:hover i  { background: rgba(79,126,248,0.2); color: var(--accent-2); }
        .sb-item.si-roles:hover    { color: #fff; background: rgba(167,139,250,0.08); border-left-color: var(--purple); }
        .sb-item.si-roles:hover i  { background: rgba(167,139,250,0.18); color: var(--purple); }
        .sb-foot { padding: 12px 10px 16px; border-top: 1px solid var(--border); }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px; border-radius: 10px;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border);
            margin-bottom: 6px; text-decoration: none; transition: all 0.2s;
        }
        .sb-user:hover { background: rgba(251,191,36,0.08); border-color: rgba(251,191,36,0.2); }
        .sb-ava {
            width: 34px; height: 34px; border-radius: 50%;
            background: linear-gradient(135deg, var(--amber), #f97316);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 0.88rem; font-weight: 700;
            flex-shrink: 0; overflow: hidden;
        }
        .sb-ava img { width: 34px; height: 34px; object-fit: cover; border-radius: 50%; }
        .sb-uname { color: #fff; font-size: 0.82rem; font-weight: 600; }
        .sb-urole { color: var(--muted); font-size: 0.68rem; margin-top: 1px; }
        .sb-logout {
            display: flex; align-items: center; gap: 8px;
            width: 100%; padding: 8px 10px; border-radius: 8px;
            color: rgba(255,255,255,0.35); text-decoration: none;
            font-size: 0.8rem; transition: all 0.2s;
        }
        .sb-logout:hover { color: var(--danger); background: rgba(248,113,113,0.08); }

        /* ════════════════════ MAIN ════════════════════ */
        .main { margin-left: var(--sb-width); flex: 1; min-height: 100vh; display: flex; flex-direction: column; }

        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 22px 32px;
            border-bottom: 1px solid var(--border);
            background: rgba(11,20,55,0.6);
            backdrop-filter: blur(16px);
            position: sticky; top: 0; z-index: 50;
        }
        .topbar-title { font-size: 1.25rem; font-weight: 800; color: #fff; letter-spacing: -0.3px; display: flex; align-items: center; gap: 10px; }
        .topbar-title i { color: var(--accent-2); font-size: 1rem; }
        .topbar-sub { color: var(--muted); font-size: 0.8rem; margin-top: 2px; }

        .btn-add {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 20px;
            background: linear-gradient(135deg, var(--accent), var(--purple));
            color: #fff; text-decoration: none;
            font-size: 0.84rem; font-weight: 700;
            border-radius: 11px;
            box-shadow: 0 4px 16px var(--accent-glow);
            transition: all 0.25s;
        }
        .btn-add:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(79,126,248,0.45); }

        .content { padding: 28px 32px; flex: 1; }

        @keyframes cardIn {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── ALERTS ── */
        .alert {
            display: flex; align-items: center; gap: 10px;
            padding: 12px 16px; border-radius: 11px;
            margin-bottom: 18px; font-size: 0.84rem;
            animation: cardIn 0.4s ease both;
        }
        .alert i { flex-shrink: 0; }
        .alert-success { background: var(--green-dim); border: 1px solid rgba(52,211,153,0.25); color: var(--green); }
        .alert-error   { background: var(--danger-dim); border: 1px solid rgba(248,113,113,0.25); color: var(--danger); }

        /* ── SEARCH BAR ── */
        .search-bar {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 16px 20px;
            margin-bottom: 18px;
            display: flex; gap: 10px; align-items: center; flex-wrap: wrap;
            backdrop-filter: blur(12px);
            animation: cardIn 0.4s 0.05s ease both;
        }
        .search-bar input,
        .search-bar select {
            padding: 9px 13px;
            background: rgba(255,255,255,0.05);
            border: 1.5px solid var(--border);
            border-radius: 9px;
            font-size: 0.82rem;
            font-family: 'Sora', sans-serif;
            color: var(--text);
            outline: none; transition: all 0.2s;
        }
        .search-bar input { flex: 1; min-width: 200px; }
        .search-bar input::placeholder { color: var(--muted); }
        .search-bar select option { background: var(--navy-card); color: var(--text); }
        .search-bar input:focus,
        .search-bar select:focus {
            border-color: rgba(79,126,248,0.5);
            background: rgba(79,126,248,0.06);
            box-shadow: 0 0 0 3px rgba(79,126,248,0.1);
        }
        .btn-search {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 9px 18px;
            background: linear-gradient(135deg, var(--accent), #6366f1);
            color: #fff; border: none; border-radius: 9px;
            font-size: 0.82rem; font-weight: 700;
            font-family: 'Sora', sans-serif;
            cursor: pointer; transition: all 0.2s;
        }
        .btn-search:hover { transform: translateY(-1px); box-shadow: 0 4px 14px var(--accent-glow); }
        .btn-reset {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 9px 16px;
            background: rgba(255,255,255,0.04);
            color: var(--muted); border: 1.5px solid var(--border);
            border-radius: 9px; font-size: 0.82rem; font-weight: 600;
            font-family: 'Sora', sans-serif;
            text-decoration: none; transition: all 0.2s;
        }
        .btn-reset:hover { background: rgba(255,255,255,0.07); color: var(--text-2); }

        /* ── TABLE CARD ── */
        .table-card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s 0.1s ease both;
        }
        table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
        thead tr { background: rgba(255,255,255,0.02); }
        th {
            padding: 11px 16px; text-align: left;
            color: var(--muted); font-weight: 600;
            font-size: 0.67rem; text-transform: uppercase; letter-spacing: 0.9px;
            border-bottom: 1px solid var(--border);
        }
        td {
            padding: 12px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.03);
            vertical-align: middle; color: var(--text-2);
        }
        tr:last-child td { border-bottom: none; }
        tbody tr { transition: background 0.15s; }
        tbody tr:hover td { background: rgba(79,126,248,0.05); }

        /* ── ROLE BADGES ── */
        .role-badge {
            display: inline-flex; align-items: center;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.68rem; font-weight: 700;
        }
        .role-ADMIN              { background: rgba(79,126,248,0.15);  color: var(--accent-2);  border: 1px solid rgba(79,126,248,0.25); }
        .role-CUSTOMER           { background: var(--green-dim);       color: var(--green);     border: 1px solid rgba(52,211,153,0.2); }
        .role-CUSTOMER_SUPPORT   { background: var(--purple-dim);      color: var(--purple);    border: 1px solid rgba(167,139,250,0.2); }
        .role-TECHNICAL_MANAGER  { background: var(--amber-dim);       color: var(--amber);     border: 1px solid rgba(251,191,36,0.2); }
        .role-STOREKEEPER        { background: var(--info-dim);        color: var(--info);      border: 1px solid rgba(56,189,248,0.2); }
        .role-TECHNICIAN         { background: rgba(56,189,248,0.1);   color: #67e8f9;          border: 1px solid rgba(56,189,248,0.2); }

        /* ── STATUS BADGES ── */
        .status-active   { background: var(--green-dim); color: var(--green); border: 1px solid rgba(52,211,153,0.2); padding: 3px 9px; border-radius: 20px; font-size: 0.68rem; font-weight: 700; display: inline-flex; align-items: center; gap: 5px; }
        .status-inactive { background: var(--danger-dim); color: var(--danger); border: 1px solid rgba(248,113,113,0.2); padding: 3px 9px; border-radius: 20px; font-size: 0.68rem; font-weight: 700; display: inline-flex; align-items: center; gap: 5px; }
        .status-active i, .status-inactive i { font-size: 0.42rem; }

        /* ── ACTION BUTTONS ── */
        .action-btns { display: flex; gap: 5px; }
        .btn-icon {
            width: 30px; height: 30px; border-radius: 8px;
            border: none; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.78rem; text-decoration: none; transition: all 0.2s;
        }
        .btn-edit   { background: rgba(79,126,248,0.12);  color: var(--accent-2); }
        .btn-delete { background: var(--danger-dim);       color: var(--danger); }
        .btn-edit:hover   { background: var(--accent);  color: #fff; transform: scale(1.08); }
        .btn-delete:hover { background: var(--danger);  color: #fff; transform: scale(1.08); }

        /* ── PAGINATION ── */
        .pagination {
            display: flex; justify-content: center; align-items: center;
            gap: 6px; padding: 18px 20px 14px;
        }
        .pagination a, .pagination span {
            padding: 7px 13px; border-radius: 8px;
            font-size: 0.8rem; font-weight: 600; text-decoration: none;
            transition: all 0.2s;
        }
        .pagination a {
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--border);
            color: var(--text-2);
        }
        .pagination a:hover { background: rgba(79,126,248,0.15); border-color: rgba(79,126,248,0.3); color: var(--text); }
        .pagination .active {
            background: linear-gradient(135deg, var(--accent), #6366f1);
            color: #fff; border: none;
            box-shadow: 0 3px 10px var(--accent-glow);
        }
        .pagination .disabled { color: rgba(255,255,255,0.18); font-size: 0.8rem; }
        .total-info {
            text-align: center; color: var(--muted);
            font-size: 0.75rem; padding-bottom: 14px;
        }
    </style>
</head>
<body>

    <%-- ═══════════ SIDEBAR ═══════════ --%>
    <aside class="sb">
        <div class="sb-brand">
            <div class="sb-logo"><i class="fas fa-cog"></i></div>
            <div>
                <div class="sb-name">DRSMS</div>
                <div class="sb-role">Admin</div>
            </div>
        </div>
        <nav class="sb-nav">
            <div class="sb-lbl">Overview</div>
            <a href="<%=ctx%>/admin.jsp" class="sb-item si-dash">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
            <div class="sb-lbl">Management</div>
            <a href="<%=ctx%>/user/list" class="sb-item on si-users">
                <i class="fas fa-users"></i> Users
            </a>
            <a href="<%=ctx%>/role/list" class="sb-item si-roles">
                <i class="fas fa-user-tag"></i> Roles
            </a>
        </nav>
        <div class="sb-foot">
            <a href="<%=ctx%>/profile" class="sb-user">
                <div class="sb-ava">
                    <%if(currentUser.getAvatarUrl()!=null&&!currentUser.getAvatarUrl().isEmpty()){%>
                    <img src="<%=ctx%><%=currentUser.getAvatarUrl()%>" alt="avatar">
                    <%}else{%><%=initials%><%}%>
                </div>
                <div>
                    <div class="sb-uname"><%=currentUser.getFullName()%></div>
                    <div class="sb-urole">Administrator</div>
                </div>
            </a>
            <a href="<%=ctx%>/logout" class="sb-logout">
                <i class="fas fa-sign-out-alt"></i> Sign Out
            </a>
        </div>
    </aside>

    <%-- ═══════════ MAIN ═══════════ --%>
    <main class="main">

        <div class="topbar">
            <div>
                <div class="topbar-title"><i class="fas fa-users"></i> User Management</div>
                <div class="topbar-sub"><%=total%> total users in the system</div>
            </div>
            <a href="<%=ctx%>/user/create?action=create" class="btn-add">
                <i class="fas fa-plus"></i> Add User
            </a>
        </div>

        <div class="content">

            <%-- Alerts --%>
            <%if("created".equals(success)){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> User created successfully!</div>
            <%}%>
            <%if("updated".equals(success)){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Updated successfully!</div>
            <%}%>
            <%if("deleted".equals(success)){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Deleted successfully!</div>
            <%}%>
            <%if(error != null){%>
            <div class="alert alert-error"><i class="fas fa-triangle-exclamation"></i> An error occurred!</div>
            <%}%>

            <%-- Search bar --%>
            <form method="get" action="<%=ctx%>/user/list">
                <div class="search-bar">
                    <input type="text" name="keyword" placeholder="Username, email, full name..."
                           value="<%=keyword%>">
                    <select name="status">
                        <option value="">All statuses</option>
                        <option value="1" <%="1".equals(status)?"selected":""%>>Active</option>
                        <option value="0" <%="0".equals(status)?"selected":""%>>Locked</option>
                    </select>
                    <select name="role">
                        <option value="">All roles</option>
                        <%if(roles!=null) for(Role r:roles){%>
                        <option value="<%=r.getName()%>" <%=r.getName().equals(role)?"selected":""%>>
                            <%=r.getName().replace("_"," ")%>
                        </option>
                        <%}%>
                    </select>
                    <button type="submit" class="btn-search"><i class="fas fa-search"></i> Search</button>
                    <a href="<%=ctx%>/user/list" class="btn-reset"><i class="fas fa-rotate"></i> Reset</a>
                </div>
            </form>

            <%-- Table --%>
            <div class="table-card">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Username</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%if(users!=null) for(User u:users){%>
                        <tr>
                            <td style="color:var(--accent-2);font-weight:700;font-family:'Courier New',monospace">#<%=u.getId()%></td>
                            <td style="font-weight:600;color:var(--text)"><%=u.getUsername()!=null?u.getUsername():"-"%></td>
                            <td><%=u.getFullName()%></td>
                            <td style="font-size:0.77rem"><%=u.getEmail()!=null?u.getEmail():"-"%></td>
                            <td><%=u.getPhone()!=null?u.getPhone():"-"%></td>
                            <td>
                                <span class="role-badge role-<%=u.getRoleName()!=null?u.getRoleName():""%>">
                                    <%=u.getRoleName()!=null?u.getRoleName().replace("_"," "):"-"%>
                                </span>
                            </td>
                            <td>
                                <%if(u.isActive()){%>
                                <span class="status-active"><i class="fas fa-circle"></i> Active</span>
                                <%}else{%>
                                <span class="status-inactive"><i class="fas fa-circle"></i> Locked</span>
                                <%}%>
                            </td>
                            <td>
                                <div class="action-btns">
                                    <a href="<%=ctx%>/user/edit?action=edit&id=<%=u.getId()%>"
                                       class="btn-icon btn-edit" title="Edit">
                                        <i class="fas fa-pen"></i>
                                    </a>
                                    <a href="<%=ctx%>/user/delete?action=delete&id=<%=u.getId()%>"
                                       class="btn-icon btn-delete" title="Delete"
                                       onclick="return confirm('Are you sure you want to delete this user?')">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <%}%>
                    </tbody>
                </table>

                <%if(totalPages>1){%>
                <div class="pagination">
                    <%if(currentPage>1){%>
                    <a href="<%=ctx%>/user/list?page=<%=currentPage-1%>&keyword=<%=kwEnc%>&status=<%=stEnc%>&role=<%=rlEnc%>">‹ Prev</a>
                    <%}else{%><span class="disabled">‹ Prev</span><%}%>

                    <%for(int i=1;i<=totalPages;i++){%>
                    <%if(i==currentPage){%>
                    <span class="active"><%=i%></span>
                    <%}else{%>
                    <a href="<%=ctx%>/user/list?page=<%=i%>&keyword=<%=kwEnc%>&status=<%=stEnc%>&role=<%=rlEnc%>"><%=i%></a>
                    <%}}%>

                    <%if(currentPage<totalPages){%>
                    <a href="<%=ctx%>/user/list?page=<%=currentPage+1%>&keyword=<%=kwEnc%>&status=<%=stEnc%>&role=<%=rlEnc%>">Next ›</a>
                    <%}else{%><span class="disabled">Next ›</span><%}%>
                </div>
                <div class="total-info">Page <%=currentPage%> / <%=totalPages%> · Total: <%=total%> users</div>
                <%}%>
            </div>

        </div>
    </main>

</body>
</html>
