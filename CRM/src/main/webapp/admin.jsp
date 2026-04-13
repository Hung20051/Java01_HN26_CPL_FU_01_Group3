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
        <title>Admin Dashboard – DRSMS</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                /* Sidebar (dark indigo) */
                --sb-bg:        #1e1b4b;
                --sb-border:    rgba(255,255,255,0.08);
                --sb-text:      rgba(255,255,255,0.45);
                --sb-accent:    #818cf8;
                --sb-accent-2:  #a5b4fc;
                --sb-item-on:   rgba(129,140,248,0.2);
                --sb-width:     252px;

                /* Content (light) */
                --bg:           #f3f4f9;
                --bg-card:      #ffffff;
                --bg-topbar:    #ffffff;
                --border-light: #e8ecf5;
                --border-light2:#f0f2fb;
                --text-h:       #1e1b4b;
                --text-b:       #374151;
                --text-m:       #6b7280;
                --text-s:       #9ca3af;

                /* Brand */
                --primary:      #4f46e5;
                --primary-2:    #6366f1;
                --primary-light:#ede9fe;

                /* Status colors */
                --green:   #16a34a;
                --red:     #dc2626;
                --amber:   #d97706;
                --blue:    #2563eb;
                --info:    #0284c7;
            }

            *,*::before,*::after{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            html{
                scroll-behavior:smooth
            }
            body{
                font-family:'Sora',sans-serif;
                background:var(--bg);
                color:var(--text-b);
                min-height:100vh;
                display:flex;
            }
            ::-webkit-scrollbar{
                width:4px
            }
            ::-webkit-scrollbar-track{
                background:transparent
            }
            ::-webkit-scrollbar-thumb{
                background:rgba(79,70,229,0.3);
                border-radius:4px
            }

            /* ═══════════ SIDEBAR ═══════════ */
            .sb{
                width:var(--sb-width);
                min-height:100vh;
                background:var(--sb-bg);
                border-right:1px solid rgba(79,70,229,0.2);
                display:flex;
                flex-direction:column;
                position:fixed;
                top:0;
                left:0;
                z-index:100;
                box-shadow:4px 0 24px rgba(0,0,0,0.15);
            }
            .sb-brand{
                padding:20px 16px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid var(--sb-border);
            }
            /* Admin logo uses amber gradient — role exception */
            .sb-logo{
                width:36px;
                height:36px;
                background:linear-gradient(135deg,#f59e0b,#f97316);
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem;
                box-shadow:0 4px 12px rgba(245,158,11,0.4);
                flex-shrink:0;
            }
            .sb-name{
                color:#fff;
                font-size:1.05rem;
                font-weight:800;
                letter-spacing:-.3px
            }
            /* Admin role badge uses amber — role exception (same as Tech Manager) */
            .sb-role{
                display:inline-flex;
                align-items:center;
                background:rgba(217,119,6,0.2);
                border:1px solid rgba(217,119,6,0.35);
                color:#fbbf24;
                font-size:.6rem;
                font-weight:700;
                letter-spacing:1px;
                text-transform:uppercase;
                padding:2px 8px;
                border-radius:20px;
                margin-top:3px;
            }
            .sb-nav{
                flex:1;
                padding:12px 10px;
                overflow-y:auto
            }
            .sb-lbl{
                color:rgba(255,255,255,0.22);
                font-size:.6rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.6px;
                padding:0 8px;
                margin:14px 0 5px;
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:9px;
                padding:8px 10px;
                border-radius:9px;
                margin-bottom:1px;
                color:var(--sb-text);
                text-decoration:none;
                font-size:.81rem;
                font-weight:500;
                transition:all .18s;
                border-left:2px solid transparent;
            }
            .sb-item i{
                width:28px;
                height:28px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.78rem;
                border-radius:8px;
                background:rgba(255,255,255,0.06);
                flex-shrink:0;
                transition:all .18s;
            }
            .sb-item.on{
                color:#fff;
                background:var(--sb-item-on);
                border-left-color:var(--sb-accent);
            }
            .sb-item.on i{
                background:rgba(129,140,248,0.3);
                color:var(--sb-accent-2)
            }
            .sb-item:hover:not(.on){
                color:rgba(255,255,255,0.78);
                background:rgba(255,255,255,0.06);
            }
            .sb-foot{
                padding:12px 10px 14px;
                border-top:1px solid var(--sb-border)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:10px;
                background:rgba(255,255,255,0.07);
                border:1px solid rgba(255,255,255,0.1);
                margin-bottom:5px;
                text-decoration:none;
                transition:all .18s;
                cursor:pointer;
            }
            .sb-user:hover{
                background:rgba(129,140,248,0.18);
                border-color:rgba(129,140,248,0.3)
            }
            /* Admin avatar uses amber gradient */
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:linear-gradient(135deg,#f59e0b,#f97316);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                font-weight:700;
                flex-shrink:0;
                overflow:hidden;
            }
            .sb-ava img{
                width:34px;
                height:34px;
                object-fit:cover;
                border-radius:50%
            }
            .sb-uname{
                color:#fff;
                font-size:.8rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,0.35);
                font-size:.66rem;
                margin-top:1px
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:8px 10px;
                border-radius:9px;
                color:rgba(255,255,255,0.3);
                text-decoration:none;
                font-size:.78rem;
                transition:all .18s;
            }
            .sb-logout:hover{
                color:#fca5a5;
                background:rgba(239,68,68,0.1)
            }

            /* ═══════════ MAIN ═══════════ */
            .main{
                margin-left:var(--sb-width);
                flex:1;
                display:flex;
                flex-direction:column;
                min-height:100vh
            }
            .topbar{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:18px 28px;
                background:var(--bg-topbar);
                border-bottom:1px solid var(--border-light);
                position:sticky;
                top:0;
                z-index:50;
                box-shadow:0 1px 6px rgba(0,0,0,0.06);
            }
            .topbar-greeting{
                font-size:1.2rem;
                font-weight:800;
                color:var(--text-h);
                letter-spacing:-.3px
            }
            .topbar-sub{
                color:var(--text-s);
                font-size:.78rem;
                margin-top:2px
            }
            .content{
                padding:24px 28px;
                flex:1
            }

            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(16px)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }

            .section-lbl{
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:2px;
                color:var(--primary-2);
                margin-bottom:13px;
                display:flex;
                align-items:center;
                gap:10px;
            }
            .section-lbl::after{
                content:'';
                flex:1;
                height:1px;
                background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)
            }

            /* Welcome banner */
            .welcome-banner{
                background:linear-gradient(135deg,rgba(245,158,11,0.1),rgba(249,115,22,0.07));
                border:1.5px solid rgba(245,158,11,0.25);
                border-radius:16px;
                padding:20px 24px;
                margin-bottom:26px;
                display:flex;
                align-items:center;
                gap:16px;
                animation:cardIn .4s ease both;
                position:relative;
                overflow:hidden;
            }
            .welcome-banner::before{
                content:'';
                position:absolute;
                top:0;
                left:20px;
                right:20px;
                height:1px;
                background:linear-gradient(90deg,transparent,rgba(245,158,11,0.4),transparent);
            }
            .welcome-icon{
                width:48px;
                height:48px;
                border-radius:13px;
                background:rgba(245,158,11,0.12);
                border:1.5px solid rgba(245,158,11,0.25);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.3rem;
                flex-shrink:0
            }
            .welcome-banner h3{
                font-size:1rem;
                font-weight:700;
                color:var(--text-h);
                margin-bottom:4px
            }
            .welcome-banner p{
                font-size:.8rem;
                color:var(--text-m)
            }

            /* Stat cards — solid gradient (same pattern as storekeeperStats) */
            .stats{
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:14px;
                margin-bottom:26px;
            }
            .sc{
                border-radius:16px;
                padding:20px;
                position:relative;
                overflow:hidden;
                color:#fff;
                transition:all .22s;
                animation:cardIn .5s ease both;
            }
            .sc:nth-child(1){
                animation-delay:.05s
            }
            .sc:nth-child(2){
                animation-delay:.10s
            }
            .sc:nth-child(3){
                animation-delay:.15s
            }
            .sc:hover{
                transform:translateY(-3px);
                box-shadow:0 12px 32px rgba(0,0,0,0.18)
            }
            .sc::after{
                content:'';
                position:absolute;
                width:80px;
                height:80px;
                border-radius:50%;
                background:rgba(255,255,255,0.12);
                top:-20px;
                right:-20px
            }
            .sc::before{
                content:'';
                position:absolute;
                width:50px;
                height:50px;
                border-radius:50%;
                background:rgba(255,255,255,0.07);
                bottom:-10px;
                right:20px
            }
            .sc-blue  {
                background:var(--blue);
                box-shadow:0 4px 20px rgba(37,99,235,0.3)
            }
            .sc-green {
                background:var(--green);
                box-shadow:0 4px 20px rgba(22,163,74,0.3)
            }
            .sc-amber {
                background:var(--amber);
                box-shadow:0 4px 20px rgba(217,119,6,0.3)
            }
            .sc-icon{
                width:38px;
                height:38px;
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.9rem;
                margin-bottom:12px;
                background:rgba(255,255,255,0.2);
                position:relative;
                z-index:1
            }
            .sc-val{
                font-size:2rem;
                font-weight:800;
                color:#fff;
                line-height:1;
                letter-spacing:-1px;
                position:relative;
                z-index:1
            }
            .sc-lbl{
                color:rgba(255,255,255,0.88);
                font-size:.76rem;
                font-weight:600;
                margin-top:5px;
                position:relative;
                z-index:1
            }

            /* Management cards */
            .cards-grid{
                display:grid;
                grid-template-columns:repeat(2,1fr);
                gap:16px;
                margin-bottom:26px;
            }
            .mgmt-card{
                background:var(--bg-card);
                border:1.5px solid var(--border-light);
                border-radius:16px;
                padding:24px;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                transition:all .22s;
                animation:cardIn .5s ease both;
            }
            .mgmt-card:nth-child(1){
                animation-delay:.2s
            }
            .mgmt-card:nth-child(2){
                animation-delay:.25s
            }
            .mgmt-card:hover{
                transform:translateY(-2px);
                box-shadow:0 10px 28px rgba(0,0,0,0.1)
            }
            .mgmt-icon{
                width:46px;
                height:46px;
                border-radius:12px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.15rem;
                margin-bottom:14px;
            }
            .mgmt-icon.blue {
                background:var(--primary-light);
                color:var(--primary-2)
            }
            .mgmt-icon.green{
                background:#dcfce7;
                color:var(--green)
            }
            .mgmt-card h3{
                font-size:.92rem;
                font-weight:700;
                color:var(--text-h);
                margin-bottom:6px
            }
            .mgmt-card p{
                font-size:.78rem;
                color:var(--text-m);
                margin-bottom:16px;
                line-height:1.6
            }
            .btn-group{
                display:flex;
                flex-direction:column;
                gap:8px
            }
            .btn{
                display:flex;
                align-items:center;
                justify-content:center;
                gap:8px;
                padding:10px 16px;
                border-radius:10px;
                font-size:.82rem;
                font-weight:700;
                font-family:'Sora',sans-serif;
                text-decoration:none;
                border:none;
                cursor:pointer;
                transition:all .2s;
            }
            .btn-primary{
                background:var(--primary);
                color:#fff;
                box-shadow:0 3px 10px rgba(79,70,229,0.28)
            }
            .btn-primary:hover{
                background:#4338ca;
                transform:translateY(-1px)
            }
            .btn-success{
                background:var(--green);
                color:#fff;
                box-shadow:0 3px 10px rgba(22,163,74,0.28)
            }
            .btn-success:hover{
                background:#15803d;
                transform:translateY(-1px)
            }
            .btn-secondary{
                background:#fff;
                color:var(--text-m);
                border:1.5px solid var(--border-light)
            }
            .btn-secondary:hover{
                background:#f3f4f6;
                border-color:#d1d5db
            }
            .btn-finance{
                background:linear-gradient(135deg,#22c55e,#16a34a);
                color:#fff;
                box-shadow:0 3px 10px rgba(22,163,74,0.28)
            }
            .btn-finance:hover{
                opacity:.9;
                transform:translateY(-1px)
            }
            /* System info */
            .system-info{
                background:var(--bg-card);
                border:1.5px solid var(--border-light);
                border-radius:16px;
                padding:22px 24px;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                animation:cardIn .5s .3s ease both;
            }
            .system-info-hd{
                font-size:.87rem;
                font-weight:700;
                color:var(--text-h);
                margin-bottom:18px;
                display:flex;
                align-items:center;
                gap:8px;
            }
            .system-info-hd i{
                color:var(--primary-2)
            }
            .info-grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:24px
            }
            .info-col h4{
                font-size:.65rem;
                font-weight:700;
                color:var(--text-s);
                text-transform:uppercase;
                letter-spacing:1.4px;
                margin-bottom:12px
            }
            .info-item{
                display:flex;
                align-items:center;
                gap:9px;
                font-size:.82rem;
                color:var(--text-b);
                margin-bottom:9px
            }
            .info-item i{
                width:20px;
                height:20px;
                border-radius:6px;
                background:#dcfce7;
                color:var(--green);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.62rem;
                flex-shrink:0
            }
        </style>
    </head>
    <body>

        <!-- ═══════════ SIDEBAR ═══════════ -->
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
                <a href="<%=ctx%>/admin.jsp" class="sb-item on">
                    <i class="fas fa-tachometer-alt"></i> Dashboard
                </a>
                <div class="sb-lbl">Management</div>
                <a href="<%=ctx%>/user/list" class="sb-item">
                    <i class="fas fa-users"></i> Users
                </a>
                <a href="<%=ctx%>/role/list" class="sb-item">
                    <i class="fas fa-user-tag"></i> Roles
                </a>

                <a href="<%=ctx%>/admin/finance" class="sb-item">
                    <i class="fas fa-chart-line"></i> Finance
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

        <!-- ═══════════ MAIN ═══════════ -->
        <main class="main">
            <div class="topbar">
                <div>
                    <div class="topbar-greeting">Admin Control Panel</div>
                    <div class="topbar-sub">Manage users, roles and system settings.</div>
                </div>
            </div>

            <div class="content">

                <!-- Welcome banner -->
                <div class="welcome-banner">
                    <div class="welcome-icon">👋</div>
                    <div>
                        <h3>Welcome back, <%=currentUser.getFullName()%>!</h3>
                        <p>Here you can manage users, roles and system settings.</p>
                    </div>
                </div>

                <!-- Stats -->
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

                <!-- Management cards -->
                <div class="section-lbl">Management</div>
                <div class="cards-grid">
                    <div class="mgmt-card">
                        <div class="mgmt-icon blue"><i class="fas fa-users"></i></div>
                        <h3>User Management</h3>
                        <p>Create, edit and assign permissions to users in the system.</p>
                        <div class="btn-group">
                            <a href="<%=ctx%>/user/list"   class="btn btn-primary"><i class="fas fa-list"></i> User List</a>
                            <a href="<%=ctx%>/user/create?action=create" class="btn btn-secondary"><i class="fas fa-plus"></i> Add User</a>
                        </div>
                    </div>
                    <div class="mgmt-card">
                        <div class="mgmt-icon green"><i class="fas fa-user-tag"></i></div>
                        <h3>Role Management</h3>
                        <p>Create and manage roles and system access permissions.</p>
                        <div class="btn-group">
                            <a href="<%=ctx%>/role/list" class="btn btn-success"><i class="fas fa-list"></i> Role List</a>
                        </div>
                    </div>
                </div>

                <!-- Finance Management Card -->
                <div class="mgmt-card">
                    <div class="mgmt-icon" style="background:rgba(22,163,74,0.1)">
                        <i class="fas fa-chart-line" style="color:#16a34a"></i>
                    </div>
                    <div class="mgmt-title">Finance Management</div>
                    <div class="mgmt-desc">Compile sales and repair revenue statistics and generate Excel reports.</div>
                    <a href="<%=ctx%>/admin/finance" class="btn btn-finance">

                        <i class="fas fa-chart-bar"></i> View Finance

                    </a>
                </div>

                <!-- System info -->
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
