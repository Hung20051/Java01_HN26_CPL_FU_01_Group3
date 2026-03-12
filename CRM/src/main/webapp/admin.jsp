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
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Admin Dashboard - DRSMS</title>
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
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0; left: 0;
            z-index: 100;
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
            padding: 2px 8px; border-radius: 20px;
            margin-top: 3px;
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
            padding: 9px 10px; border-radius: 9px;
            margin-bottom: 1px;
            color: rgba(255,255,255,0.45);
            text-decoration: none;
            font-size: 0.83rem; font-weight: 500;
            transition: all 0.2s;
            border-left: 2px solid transparent;
        }
        .sb-item i {
            width: 28px; height: 28px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.8rem; border-radius: 8px;
            background: rgba(255,255,255,0.05);
            flex-shrink: 0;
            transition: all 0.2s;
        }
        .sb-item.on {
            color: #fff;
            background: linear-gradient(90deg, rgba(251,191,36,0.18), rgba(251,191,36,0.04));
            border-left: 2px solid var(--amber);
        }
        .sb-item.on i { background: rgba(251,191,36,0.2); color: var(--amber); }

        /* Dashboard - amber */
        .sb-item.si-dash:hover     { color: #fff; background: rgba(251,191,36,0.08); border-left-color: var(--amber); }
        .sb-item.si-dash:hover i   { background: rgba(251,191,36,0.18); color: var(--amber); }
        /* Users - blue */
        .sb-item.si-users:hover    { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
        .sb-item.si-users:hover i  { background: rgba(79,126,248,0.2); color: var(--accent-2); }
        /* Roles - purple */
        .sb-item.si-roles:hover    { color: #fff; background: rgba(167,139,250,0.08); border-left-color: var(--purple); }
        .sb-item.si-roles:hover i  { background: rgba(167,139,250,0.18); color: var(--purple); }

        .sb-foot {
            padding: 12px 10px 16px;
            border-top: 1px solid var(--border);
        }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px;
            border-radius: 10px;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border);
            margin-bottom: 6px;
            text-decoration: none;
            transition: all 0.2s;
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
        .main {
            margin-left: var(--sb-width);
            flex: 1;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Topbar */
        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 22px 32px;
            border-bottom: 1px solid var(--border);
            background: rgba(11,20,55,0.6);
            backdrop-filter: blur(16px);
            position: sticky; top: 0; z-index: 50;
        }
        .topbar-title { font-size: 1.25rem; font-weight: 800; color: #fff; letter-spacing: -0.3px; }
        .topbar-sub { color: var(--muted); font-size: 0.8rem; margin-top: 2px; font-weight: 300; }

        /* Content */
        .content { padding: 28px 32px; flex: 1; }

        /* Section label */
        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 12px;
        }

        /* Animations */
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── WELCOME BANNER ── */
        .welcome-banner {
            background: linear-gradient(135deg, rgba(251,191,36,0.18), rgba(249,115,22,0.12));
            border: 1px solid rgba(251,191,36,0.2);
            border-radius: 16px;
            padding: 20px 24px;
            margin-bottom: 26px;
            display: flex; align-items: center; gap: 16px;
            animation: cardIn 0.4s ease both;
            position: relative; overflow: hidden;
        }
        .welcome-banner::before {
            content: '';
            position: absolute; top: 0; left: 20px; right: 20px; height: 1px;
            background: linear-gradient(90deg, transparent, var(--amber), transparent);
        }
        .welcome-icon {
            width: 48px; height: 48px; border-radius: 13px;
            background: rgba(251,191,36,0.15);
            border: 1px solid rgba(251,191,36,0.25);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem; flex-shrink: 0;
        }
        .welcome-banner h3 { font-size: 1rem; font-weight: 700; color: var(--text); margin-bottom: 4px; }
        .welcome-banner p  { font-size: 0.8rem; color: var(--muted); }

        /* ── STAT CARDS ── */
        .stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-bottom: 26px;
        }
        .sc {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px;
            position: relative; overflow: hidden;
            backdrop-filter: blur(12px);
            transition: all 0.25s;
            animation: cardIn 0.5s ease both;
        }
        .sc:nth-child(1){ animation-delay: 0.05s; }
        .sc:nth-child(2){ animation-delay: 0.10s; }
        .sc:nth-child(3){ animation-delay: 0.15s; }
        .sc:hover { transform: translateY(-3px); box-shadow: 0 12px 32px rgba(0,0,0,0.25); }
        .sc::before {
            content: ''; position: absolute;
            top: 0; left: 16px; right: 16px; height: 1px;
        }
        .sc::after {
            content: ''; position: absolute;
            top: 0; right: 0; bottom: 0;
            width: 3px; border-radius: 0 16px 16px 0;
        }
        .sc-blue::before  { background: linear-gradient(90deg, transparent, var(--accent-2), transparent); }
        .sc-blue::after   { background: linear-gradient(180deg, var(--accent), transparent); }
        .sc-green::before { background: linear-gradient(90deg, transparent, var(--green), transparent); }
        .sc-green::after  { background: linear-gradient(180deg, var(--green), transparent); }
        .sc-amber::before { background: linear-gradient(90deg, transparent, var(--amber), transparent); }
        .sc-amber::after  { background: linear-gradient(180deg, var(--amber), transparent); }

        .sc-icon {
            width: 40px; height: 40px; border-radius: 11px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.95rem; margin-bottom: 14px;
        }
        .sc-blue  .sc-icon { background: rgba(79,126,248,0.12); color: var(--accent-2); }
        .sc-green .sc-icon { background: var(--green-dim); color: var(--green); }
        .sc-amber .sc-icon { background: var(--amber-dim); color: var(--amber); }

        .sc-val { font-size: 2rem; font-weight: 800; color: #fff; line-height: 1; letter-spacing: -1px; }
        .sc-lbl { color: var(--text-2); font-size: 0.78rem; margin-top: 5px; font-weight: 500; }

        /* ── MANAGEMENT CARDS ── */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
            margin-bottom: 26px;
        }
        .mgmt-card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            backdrop-filter: blur(12px);
            transition: all 0.25s;
            animation: cardIn 0.5s ease both;
        }
        .mgmt-card:nth-child(1){ animation-delay: 0.2s; }
        .mgmt-card:nth-child(2){ animation-delay: 0.25s; }
        .mgmt-card:hover { transform: translateY(-2px); box-shadow: 0 10px 28px rgba(0,0,0,0.2); }

        .mgmt-icon {
            width: 46px; height: 46px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.15rem; margin-bottom: 14px;
        }
        .mgmt-icon.blue   { background: rgba(79,126,248,0.15); color: var(--accent-2); }
        .mgmt-icon.green  { background: var(--green-dim); color: var(--green); }

        .mgmt-card h3 { font-size: 0.92rem; font-weight: 700; color: var(--text); margin-bottom: 6px; }
        .mgmt-card p  { font-size: 0.78rem; color: var(--muted); margin-bottom: 16px; line-height: 1.6; }

        .btn-group { display: flex; flex-direction: column; gap: 8px; }
        .btn {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            padding: 10px 16px; border-radius: 10px;
            font-size: 0.82rem; font-weight: 700;
            font-family: 'Sora', sans-serif;
            text-decoration: none; border: none;
            cursor: pointer; transition: all 0.2s;
        }
        .btn-blue {
            background: linear-gradient(135deg, var(--accent), #6366f1);
            color: #fff;
            box-shadow: 0 3px 12px var(--accent-glow);
        }
        .btn-blue:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(79,126,248,0.4); }
        .btn-green {
            background: linear-gradient(135deg, var(--green), #059669);
            color: #fff;
            box-shadow: 0 3px 12px rgba(52,211,153,0.2);
        }
        .btn-green:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(52,211,153,0.35); }
        .btn-outline {
            background: rgba(255,255,255,0.04);
            color: var(--text-2);
            border: 1.5px solid var(--border);
        }
        .btn-outline:hover { background: rgba(79,126,248,0.08); border-color: rgba(79,126,248,0.3); color: var(--text); }

        /* ── SYSTEM INFO ── */
        .system-info {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 22px 24px;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s 0.3s ease both;
        }
        .system-info-hd {
            font-size: 0.87rem; font-weight: 700; color: var(--text);
            margin-bottom: 18px;
            display: flex; align-items: center; gap: 8px;
        }
        .system-info-hd i { color: var(--accent-2); }

        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        .info-col h4 {
            font-size: 0.65rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 1.4px; margin-bottom: 12px;
        }
        .info-item {
            display: flex; align-items: center; gap: 9px;
            font-size: 0.82rem; color: var(--text-2);
            margin-bottom: 9px;
        }
        .info-item i {
            width: 20px; height: 20px; border-radius: 6px;
            background: var(--green-dim);
            color: var(--green);
            display: flex; align-items: center; justify-content: center;
            font-size: 0.62rem; flex-shrink: 0;
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
            <a href="<%=ctx%>/admin.jsp" class="sb-item on si-dash">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>

            <div class="sb-lbl">Management</div>
            <a href="<%=ctx%>/user/list" class="sb-item si-users">
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

        <%-- Topbar --%>
        <div class="topbar">
            <div>
                <div class="topbar-title">Admin Control Panel</div>
                <div class="topbar-sub">Manage users, roles and system settings.</div>
            </div>
        </div>

        <div class="content">

            <%-- Welcome banner --%>
            <div class="welcome-banner">
                <div class="welcome-icon">👋</div>
                <div>
                    <h3>Welcome back, <%=currentUser.getFullName()%>!</h3>
                    <p>Here you can manage users, roles and system settings.</p>
                </div>
            </div>

            <%-- Stats --%>
            <div class="section-lbl">Overview</div>
            <div class="stats">
                <div class="sc sc-blue">
                    <div class="sc-icon"><i class="fas fa-users"></i></div>
                    <div class="sc-val"><%=totalUsers%></div>
                    <div class="sc-lbl">Total Users</div>
                </div>
                <div class="sc sc-green">
                    <div class="sc-icon"><i class="fas fa-user-tag"></i></div>
                    <div class="sc-val"><%=totalRoles%></div>
                    <div class="sc-lbl">Total Roles</div>
                </div>
                <div class="sc sc-amber">
                    <div class="sc-icon"><i class="fas fa-shield-alt"></i></div>
                    <div class="sc-val" style="font-size:1.1rem;letter-spacing:0">Active</div>
                    <div class="sc-lbl">System Status</div>
                </div>
            </div>

            <%-- Management cards --%>
            <div class="section-lbl">Management</div>
            <div class="cards-grid">
                <div class="mgmt-card">
                    <div class="mgmt-icon blue"><i class="fas fa-users"></i></div>
                    <h3>User Management</h3>
                    <p>Create, edit and assign permissions to users in the system.</p>
                    <div class="btn-group">
                        <a href="<%=ctx%>/user/list"   class="btn btn-blue"><i class="fas fa-list"></i> User List</a>
                        <a href="<%=ctx%>/user/create" class="btn btn-outline"><i class="fas fa-plus"></i> Add User</a>
                    </div>
                </div>
                <div class="mgmt-card">
                    <div class="mgmt-icon green"><i class="fas fa-user-tag"></i></div>
                    <h3>Role Management</h3>
                    <p>Create and manage roles and system access permissions.</p>
                    <div class="btn-group">
                        <a href="<%=ctx%>/role/list" class="btn btn-green"><i class="fas fa-list"></i> Role List</a>
                    </div>
                </div>
            </div>

            <%-- System info --%>
            <div class="system-info">
                <div class="system-info-hd">
                    <i class="fas fa-circle-info"></i> System Information
                </div>
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
    </main>

</body>
</html>
