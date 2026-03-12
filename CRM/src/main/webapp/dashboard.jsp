<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String ctx = request.getContextPath();
    String displayName = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName() : currentUser.getUsername();
    String initials = displayName.substring(0,1).toUpperCase();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Dashboard - Storekeeper</title>
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
            --orange:      #fb923c;
            --orange-dim:  rgba(251,146,60,0.12);
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
            background: linear-gradient(135deg, var(--info), #0284c7);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 0.88rem;
            box-shadow: 0 4px 14px rgba(56,189,248,0.3);
            flex-shrink: 0;
        }
        .sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
        .sb-role {
            display: inline-flex; align-items: center;
            background: rgba(56,189,248,0.15);
            border: 1px solid rgba(56,189,248,0.3);
            color: var(--info);
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
        /* Active */
        .sb-item.on { color: #fff; border-left: 2px solid var(--info); background: linear-gradient(90deg, rgba(56,189,248,0.18), rgba(56,189,248,0.04)); }
        .sb-item.on i { background: rgba(56,189,248,0.2); color: var(--info); }
        /* Hover per item */
        .si-home:hover    { color:#fff; background: rgba(79,126,248,0.1);  border-left-color: var(--accent); }
        .si-home:hover i  { background: rgba(79,126,248,0.2);  color: var(--accent-2); }
        .si-stats:hover   { color:#fff; background: rgba(56,189,248,0.1);  border-left-color: var(--info); }
        .si-stats:hover i { background: rgba(56,189,248,0.2);  color: var(--info); }
        .si-parts:hover   { color:#fff; background: var(--green-dim);       border-left-color: var(--green); }
        .si-parts:hover i { background: rgba(52,211,153,0.2);  color: var(--green); }
        .si-equip:hover   { color:#fff; background: var(--info-dim);        border-left-color: var(--info); }
        .si-equip:hover i { background: rgba(56,189,248,0.2);  color: var(--info); }
        .si-tx:hover      { color:#fff; background: var(--amber-dim);       border-left-color: var(--amber); }
        .si-tx:hover i    { background: rgba(251,191,36,0.2);  color: var(--amber); }

        .sb-foot { padding: 12px 10px 16px; border-top: 1px solid var(--border); }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px; border-radius: 10px;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border);
            margin-bottom: 6px; text-decoration: none; transition: all 0.2s;
        }
        .sb-user:hover { background: rgba(56,189,248,0.08); border-color: rgba(56,189,248,0.2); }
        .sb-ava {
            width: 34px; height: 34px; border-radius: 50%;
            background: linear-gradient(135deg, var(--info), #0284c7);
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
        .main { margin-left: var(--sb-width); flex: 1; padding: 32px 36px; }

        @keyframes cardIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── TOPBAR ── */
        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 26px;
            animation: cardIn 0.4s ease both;
        }
        .topbar-title { font-size: 1.5rem; font-weight: 800; color: #fff; letter-spacing: -0.4px; }
        .topbar-sub { color: var(--muted); font-size: 0.84rem; margin-top: 3px; }
        .user-badge {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 16px;
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--border);
            border-radius: 24px;
            font-size: 0.8rem; color: var(--muted);
        }
        .user-badge i { color: var(--info); font-size: 1rem; }
        .user-badge strong { color: var(--text-2); }

        /* ── WELCOME BANNER ── */
        .welcome-banner {
            background: linear-gradient(135deg, rgba(15,28,77,0.9) 0%, rgba(22,32,80,0.9) 60%, rgba(56,189,248,0.08) 100%);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 28px 32px;
            margin-bottom: 28px;
            display: flex; align-items: center; justify-content: space-between;
            position: relative; overflow: hidden;
            backdrop-filter: blur(12px);
            animation: cardIn 0.45s 0.05s ease both;
        }
        .welcome-banner::before {
            content: '';
            position: absolute; top: -40px; right: -40px;
            width: 200px; height: 200px;
            background: radial-gradient(circle, rgba(56,189,248,0.18) 0%, transparent 70%);
            border-radius: 50%;
        }
        .welcome-banner::after {
            content: '';
            position: absolute; bottom: -50px; right: 130px;
            width: 150px; height: 150px;
            background: radial-gradient(circle, rgba(52,211,153,0.1) 0%, transparent 70%);
            border-radius: 50%;
        }
        .welcome-text { position: relative; z-index: 1; }
        .welcome-text h2 { font-size: 1.3rem; font-weight: 800; color: #fff; margin-bottom: 5px; }
        .welcome-text h2 span { color: var(--info); }
        .welcome-text p { color: var(--muted); font-size: 0.86rem; }
        .welcome-icon {
            font-size: 3.8rem; color: var(--info);
            opacity: 0.12; position: absolute; right: 36px; z-index: 0;
        }

        /* ── SECTION LABEL ── */
        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 1.3px; margin-bottom: 14px;
        }

        /* ── NAV GRID ── */
        .nav-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-bottom: 28px;
        }

        .nav-card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 22px 20px;
            text-decoration: none;
            display: flex; flex-direction: column; gap: 13px;
            position: relative; overflow: hidden;
            backdrop-filter: blur(12px);
            transition: all 0.22s ease;
            cursor: pointer;
        }
        .nav-card::before {
            content: '';
            position: absolute; top: 0; left: 0; right: 0; height: 2px;
            background: var(--c, var(--accent));
            transform: scaleX(0); transform-origin: left;
            transition: transform 0.22s ease;
        }
        .nav-card:hover { transform: translateY(-3px); border-color: rgba(255,255,255,0.12); box-shadow: 0 12px 36px rgba(0,0,0,0.3); }
        .nav-card:hover::before { transform: scaleX(1); }
        .nav-card:hover .nav-card-icon { transform: scale(1.1) rotate(-4deg); }
        .nav-card:hover .nav-arrow-icon { transform: translateX(4px); }

        .nav-card-icon {
            width: 46px; height: 46px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.15rem;
            background: var(--cb, rgba(79,126,248,0.15));
            color: var(--c, var(--accent));
            transition: transform 0.2s;
        }
        .nav-card-content h3 { font-size: 0.9rem; font-weight: 700; color: #fff; margin-bottom: 4px; }
        .nav-card-content p  { font-size: 0.77rem; color: var(--muted); line-height: 1.55; }
        .nav-card-arrow {
            display: flex; align-items: center; justify-content: space-between;
            margin-top: auto;
        }
        .nav-card-arrow span { font-size: 0.75rem; font-weight: 600; color: var(--c, var(--accent)); }
        .nav-arrow-icon { font-size: 0.72rem; color: var(--c, var(--accent)); transition: transform 0.2s; }

        /* color helpers */
        .cc-info   { --c: var(--info);   --cb: rgba(56,189,248,0.15); }
        .cc-green  { --c: var(--green);  --cb: var(--green-dim); }
        .cc-sky    { --c: #67e8f9;       --cb: rgba(103,232,249,0.12); }
        .cc-amber  { --c: var(--amber);  --cb: var(--amber-dim); }
        .cc-rose   { --c: #fb7185;       --cb: rgba(251,113,133,0.12); }
        .cc-purple { --c: var(--purple); --cb: var(--purple-dim); }

        /* stagger */
        .nav-card:nth-child(1) { animation: cardIn 0.45s 0.08s ease both; }
        .nav-card:nth-child(2) { animation: cardIn 0.45s 0.13s ease both; }
        .nav-card:nth-child(3) { animation: cardIn 0.45s 0.18s ease both; }
        .nav-card:nth-child(4) { animation: cardIn 0.45s 0.23s ease both; }
        .nav-card:nth-child(5) { animation: cardIn 0.45s 0.28s ease both; }
    </style>
</head>
<body>

    <%-- ═══════════ SIDEBAR ═══════════ --%>
    <aside class="sb">
        <div class="sb-brand">
            <div class="sb-logo"><i class="fas fa-warehouse"></i></div>
            <div>
                <div class="sb-name">DRSMS</div>
                <div class="sb-role">Storekeeper</div>
            </div>
        </div>
        <nav class="sb-nav">
            <div class="sb-lbl">Overview</div>
            <a href="<%=ctx%>/dashboard.jsp" class="sb-item on si-home">
                <i class="fas fa-house"></i> Home
            </a>
               
            <a href="<%=ctx%>/storekeeper" class="sb-item si-stats">
                <i class="fas fa-chart-bar"></i> Statistics
            </a>
                 <div class="sb-lbl">Inventory</div>
            <a href="<%=ctx%>/numberPart" class="sb-item si-parts">
                <i class="fas fa-puzzle-piece"></i> Parts List
            </a>
            <a href="<%=ctx%>/numberEquipment" class="sb-item si-equip">
                <i class="fas fa-desktop"></i> Equipment List
            </a>
                 <div class="sb-lbl">Records</div>
            <a href="<%=ctx%>/transactions" class="sb-item si-tx">
                <i class="fas fa-clock-rotate-left"></i> Transaction History
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
                    <div class="sb-uname"><%=displayName%></div>
                    <div class="sb-urole">Storekeeper</div>
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
                <div class="topbar-title">Dashboard</div>
                <div class="topbar-sub">Welcome back! Select a function below to get started.</div>
            </div>
            <div class="user-badge">
                <i class="fas fa-user-circle"></i>
                <strong><%=currentUser.getUsername()%></strong>
                &nbsp;·&nbsp; Storekeeper
            </div>
        </div>

        <%-- Welcome Banner --%>
        <div class="welcome-banner">
            <div class="welcome-text">
                <h2>Hello, <span><%=displayName%>!</span></h2>
                <p>Manage your warehouse, parts, and equipment from here.</p>
            </div>
            <i class="fas fa-warehouse welcome-icon"></i>
        </div>

        <%-- Nav Cards --%>
        <div class="section-lbl">Main Functions</div>
        <div class="nav-grid">

            <a href="<%=ctx%>/storekeeper" class="nav-card cc-info">
                <div class="nav-card-icon"><i class="fas fa-chart-bar"></i></div>
                <div class="nav-card-content">
                    <h3>Warehouse Statistics</h3>
                    <p>Overview of parts and equipment stock status.</p>
                </div>
                <div class="nav-card-arrow">
                    <span>View statistics</span>
                    <i class="fas fa-arrow-right nav-arrow-icon"></i>
                </div>
            </a>

            <a href="<%=ctx%>/numberPart" class="nav-card cc-green">
                <div class="nav-card-icon"><i class="fas fa-list-ul"></i></div>
                <div class="nav-card-content">
                    <h3>Parts List</h3>
                    <p>Manage, add, edit, and delete part types.</p>
                </div>
                <div class="nav-card-arrow">
                    <span>Manage parts</span>
                    <i class="fas fa-arrow-right nav-arrow-icon"></i>
                </div>
            </a>

            <a href="<%=ctx%>/numberEquipment" class="nav-card cc-sky">
                <div class="nav-card-icon"><i class="fas fa-desktop"></i></div>
                <div class="nav-card-content">
                    <h3>Equipment List</h3>
                    <p>Manage equipment models and serial number stock.</p>
                </div>
                <div class="nav-card-arrow">
                    <span>Manage equipment</span>
                    <i class="fas fa-arrow-right nav-arrow-icon"></i>
                </div>
            </a>

            <a href="<%=ctx%>/transactions" class="nav-card cc-amber">
                <div class="nav-card-icon"><i class="fas fa-clock-rotate-left"></i></div>
                <div class="nav-card-content">
                    <h3>Transaction History</h3>
                    <p>Browse purchase, repair, and stock-in history.</p>
                </div>
                <div class="nav-card-arrow">
                    <span>View history</span>
                    <i class="fas fa-arrow-right nav-arrow-icon"></i>
                </div>
            </a>

            <a href="<%=ctx%>/profile" class="nav-card cc-rose">
                <div class="nav-card-icon"><i class="fas fa-circle-user"></i></div>
                <div class="nav-card-content">
                    <h3>Personal Profile</h3>
                    <p>View and update your account information.</p>
                </div>
                <div class="nav-card-arrow">
                    <span>View profile</span>
                    <i class="fas fa-arrow-right nav-arrow-icon"></i>
                </div>
            </a>

        </div>

    </main>
</body>
</html>
