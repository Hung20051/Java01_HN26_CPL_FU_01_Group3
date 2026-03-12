<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.PartType, java.util.*, java.text.NumberFormat, java.util.Locale" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Map<String, Integer> partStats = (Map<String, Integer>) request.getAttribute("partStats");
    Map<String, Integer> eqStats   = (Map<String, Integer>) request.getAttribute("eqStats");
    List<PartType> lowStockList    = (List<PartType>) request.getAttribute("lowStockList");
    List<PartType> mostUsedList    = (List<PartType>) request.getAttribute("mostUsedList");
    if (partStats == null) partStats = new HashMap<>();
    if (eqStats   == null) eqStats   = new HashMap<>();
    if (lowStockList  == null) lowStockList  = new ArrayList<>();
    if (mostUsedList  == null) mostUsedList  = new ArrayList<>();

    int totalPartTypes = partStats.getOrDefault("totalPartTypes", 0);
    int totalPartUnits = partStats.getOrDefault("totalPartUnits", 0);
    int availableUnits = partStats.getOrDefault("availableUnits", 0);
    int faultyUnits    = partStats.getOrDefault("faultyUnits", 0);
    int inuseUnits     = partStats.getOrDefault("inuseUnits", 0);
    int retiredUnits   = partStats.getOrDefault("retiredUnits", 0);
    int lowStock       = partStats.getOrDefault("lowStock", 0);
    int totalEqTypes   = eqStats.getOrDefault("totalEqTypes", 0);
    int totalEqUnits   = eqStats.getOrDefault("totalEqUnits", 0);
    int availableEq    = eqStats.getOrDefault("availableEq", 0);
    int faultyEq       = eqStats.getOrDefault("faultyEq", 0);
    int inuseEq        = eqStats.getOrDefault("inuseEq", 0);

    double pctAvailable = totalPartUnits > 0 ? (availableUnits * 100.0 / totalPartUnits) : 0;
    double pctRetired   = totalPartUnits > 0 ? (retiredUnits  * 100.0 / totalPartUnits) : 0;

    String ctx = request.getContextPath();
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Warehouse Management - DRSMS</title>
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
            background: linear-gradient(135deg, var(--green), var(--info));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: var(--navy); font-size: 0.88rem;
            box-shadow: 0 4px 14px rgba(52,211,153,0.3);
            flex-shrink: 0;
        }
        .sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
        .sb-role {
            display: inline-flex; align-items: center;
            background: rgba(52,211,153,0.12);
            border: 1px solid rgba(52,211,153,0.25);
            color: var(--green);
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
            flex-shrink: 0; transition: all 0.2s;
        }
        .sb-item.on {
            color: #fff;
            background: linear-gradient(90deg, rgba(52,211,153,0.15), rgba(52,211,153,0.04));
            border-left: 2px solid var(--green);
        }
        .sb-item.on i { background: rgba(52,211,153,0.2); color: var(--green); }

        .sb-item.si-home:hover       { color:#fff; background:rgba(79,126,248,0.1);    border-left-color:var(--accent);  }
        .sb-item.si-home:hover i     { background:rgba(79,126,248,0.2);  color:var(--accent-2); }
        .sb-item.si-stats:hover      { color:#fff; background:rgba(52,211,153,0.08);   border-left-color:var(--green);   }
        .sb-item.si-stats:hover i    { background:rgba(52,211,153,0.2);  color:var(--green);    }
        .sb-item.si-parts:hover      { color:#fff; background:rgba(251,191,36,0.08);   border-left-color:var(--amber);   }
        .sb-item.si-parts:hover i    { background:rgba(251,191,36,0.2);  color:var(--amber);    }
        .sb-item.si-equip:hover      { color:#fff; background:rgba(56,189,248,0.08);   border-left-color:var(--info);    }
        .sb-item.si-equip:hover i    { background:rgba(56,189,248,0.2);  color:var(--info);     }
        .sb-item.si-tx:hover         { color:#fff; background:rgba(167,139,250,0.08);  border-left-color:var(--purple);  }
        .sb-item.si-tx:hover i       { background:rgba(167,139,250,0.2); color:var(--purple);   }

        .sb-foot {
            padding: 12px 10px 16px;
            border-top: 1px solid var(--border);
        }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px 10px; border-radius: 10px;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border);
            margin-bottom: 6px;
            text-decoration: none; transition: all 0.2s;
        }
        .sb-user:hover { background: rgba(52,211,153,0.08); border-color: rgba(52,211,153,0.2); }
        .sb-ava {
            width: 34px; height: 34px; border-radius: 50%;
            background: linear-gradient(135deg, var(--green), var(--info));
            display: flex; align-items: center; justify-content: center;
            color: var(--navy); font-size: 0.88rem; font-weight: 700;
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
            flex: 1; padding: 0; min-height: 100vh;
            display: flex; flex-direction: column;
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
        .topbar-badge {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 8px 16px;
            background: rgba(52,211,153,0.08);
            border: 1px solid rgba(52,211,153,0.2);
            border-radius: 20px;
            color: var(--green); font-size: 0.8rem; font-weight: 600;
        }

        /* Content */
        .content { padding: 28px 32px; flex: 1; }

        /* Alert low stock */
        .alert-warn {
            display: flex; align-items: center; gap: 12px;
            padding: 13px 18px;
            background: rgba(251,191,36,0.08);
            border: 1px solid rgba(251,191,36,0.25);
            border-radius: 12px; margin-bottom: 22px;
            font-size: 0.84rem; color: var(--text-2);
            animation: cardIn 0.4s ease both;
        }
        .alert-warn i { color: var(--amber); font-size: 1rem; flex-shrink: 0; }
        .alert-warn a { color: var(--amber); font-weight: 700; text-decoration: none; margin-left: 6px; }
        .alert-warn a:hover { color: #fff; }

        /* Section label */
        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 12px;
        }

        /* ── STAT CARDS ── */
        .stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px; margin-bottom: 26px;
        }
        .sc {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px; padding: 20px;
            position: relative; overflow: hidden;
            backdrop-filter: blur(12px);
            transition: all 0.25s;
            animation: cardIn 0.5s ease both;
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .sc:nth-child(1){ animation-delay:0.04s; }
        .sc:nth-child(2){ animation-delay:0.08s; }
        .sc:nth-child(3){ animation-delay:0.12s; }
        .sc:nth-child(4){ animation-delay:0.16s; }
        .sc:nth-child(5){ animation-delay:0.20s; }
        .sc:nth-child(6){ animation-delay:0.24s; }
        .sc:nth-child(7){ animation-delay:0.28s; }
        .sc:nth-child(8){ animation-delay:0.32s; }
        .sc:hover { transform: translateY(-3px); box-shadow: 0 12px 32px rgba(0,0,0,0.25); }

        /* top shimmer line */
        .sc::before {
            content: ''; position: absolute;
            top: 0; left: 16px; right: 16px; height: 1px;
        }
        /* right accent bar */
        .sc::after {
            content: ''; position: absolute;
            top: 0; right: 0; bottom: 0;
            width: 3px; border-radius: 0 16px 16px 0;
        }
        .sc-green::before  { background: linear-gradient(90deg,transparent,var(--green),transparent); }
        .sc-green::after   { background: linear-gradient(180deg,var(--green),transparent); }
        .sc-blue::before   { background: linear-gradient(90deg,transparent,var(--accent-2),transparent); }
        .sc-blue::after    { background: linear-gradient(180deg,var(--accent),transparent); }
        .sc-amber::before  { background: linear-gradient(90deg,transparent,var(--amber),transparent); }
        .sc-amber::after   { background: linear-gradient(180deg,var(--amber),transparent); }
        .sc-red::before    { background: linear-gradient(90deg,transparent,var(--danger),transparent); }
        .sc-red::after     { background: linear-gradient(180deg,var(--danger),transparent); }
        .sc-purple::before { background: linear-gradient(90deg,transparent,var(--purple),transparent); }
        .sc-purple::after  { background: linear-gradient(180deg,var(--purple),transparent); }
        .sc-info::before   { background: linear-gradient(90deg,transparent,var(--info),transparent); }
        .sc-info::after    { background: linear-gradient(180deg,var(--info),transparent); }

        .sc-icon {
            width: 40px; height: 40px; border-radius: 11px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.95rem; margin-bottom: 14px;
        }
        .sc-green  .sc-icon { background:var(--green-dim);   color:var(--green);   }
        .sc-blue   .sc-icon { background:rgba(79,126,248,0.12); color:var(--accent-2); }
        .sc-amber  .sc-icon { background:var(--amber-dim);   color:var(--amber);   }
        .sc-red    .sc-icon { background:var(--danger-dim);  color:var(--danger);  }
        .sc-purple .sc-icon { background:var(--purple-dim);  color:var(--purple);  }
        .sc-info   .sc-icon { background:var(--info-dim);    color:var(--info);    }

        .sc-val { font-size: 2rem; font-weight: 800; color:#fff; line-height:1; letter-spacing:-1px; }
        .sc-lbl { color:var(--text-2); font-size:0.78rem; margin-top:5px; font-weight:500; }
        .sc-sub { font-size:0.72rem; margin-top:6px; color:var(--muted); }
        .sc-sub.ok   { color:var(--green); }
        .sc-sub.warn { color:var(--amber); }
        .sc-sub.bad  { color:var(--danger); }
        .sc-sub.info { color:var(--info); }

        /* ── GRID 2 ── */
        .grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px; margin-bottom: 22px;
        }

        /* ── CARD ── */
        .card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px; overflow: hidden;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s 0.25s ease both;
        }
        .card-hd {
            display: flex; justify-content: space-between; align-items: center;
            padding: 16px 20px; border-bottom: 1px solid var(--border);
        }
        .card-title {
            font-size: 0.87rem; font-weight: 700; color: #fff;
            display: flex; align-items: center; gap: 8px;
        }
        .card-title i { color:var(--green); font-size:0.82rem; }
        .card-link {
            font-size: 0.75rem; font-weight: 600;
            color: var(--accent-2); text-decoration: none; transition: color 0.2s;
        }
        .card-link:hover { color: #fff; }

        /* ── DONUT CHART ── */
        .donut-wrap {
            display: flex; align-items: center; justify-content: center;
            gap: 28px; padding: 24px 20px;
        }
        .donut-ring {
            position: relative; width: 140px; height: 140px; flex-shrink: 0;
        }
        .donut-ring svg { transform: rotate(-90deg); }
        .donut-center {
            position: absolute; inset: 0;
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
        }
        .donut-center-val { font-size: 1.5rem; font-weight: 800; color: #fff; line-height: 1; }
        .donut-center-lbl { font-size: 0.62rem; color: var(--muted); margin-top: 2px; font-weight: 500; letter-spacing: 0.5px; text-transform: uppercase; }
        .donut-legend { display: flex; flex-direction: column; gap: 10px; }
        .legend-item {
            display: flex; align-items: center; gap: 10px;
            font-size: 0.8rem; color: var(--text-2);
        }
        .legend-dot { width: 9px; height: 9px; border-radius: 50%; flex-shrink: 0; }
        .legend-count {
            margin-left: auto; padding-left: 20px;
            font-weight: 700; color: #fff; font-size: 0.82rem;
        }

        /* ── EQUIPMENT MINI STATS ── */
        .eq-grid {
            display: grid; grid-template-columns: 1fr 1fr;
            gap: 12px; padding: 16px;
        }
        .eq-card {
            border-radius: 12px; padding: 16px;
            border: 1px solid var(--border);
            background: rgba(255,255,255,0.025);
            transition: all 0.2s;
        }
        .eq-card:hover { background: rgba(255,255,255,0.04); transform: translateY(-1px); }
        .eq-icon {
            width: 34px; height: 34px; border-radius: 9px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.82rem; margin-bottom: 10px;
        }
        .eq-card.g .eq-icon { background:var(--green-dim);   color:var(--green);   }
        .eq-card.b .eq-icon { background:rgba(79,126,248,0.12); color:var(--accent-2); }
        .eq-card.r .eq-icon { background:var(--danger-dim);  color:var(--danger);  }
        .eq-card.a .eq-icon { background:var(--amber-dim);   color:var(--amber);   }
        .eq-val { font-size: 1.6rem; font-weight: 800; color:#fff; line-height:1; }
        .eq-lbl { font-size: 0.72rem; color:var(--muted); margin-top: 4px; }

        /* ── TABLE ── */
        table { width:100%; border-collapse:collapse; font-size:0.8rem; }
        thead tr { background: rgba(255,255,255,0.02); }
        th {
            padding: 10px 16px; text-align:left;
            color:var(--muted); font-weight:600;
            font-size:0.68rem; text-transform:uppercase; letter-spacing:0.8px;
            border-bottom: 1px solid var(--border);
        }
        td {
            padding: 12px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.03);
            vertical-align: middle; color:var(--text-2);
        }
        tr:last-child td { border-bottom: none; }
        tbody tr { transition: background 0.15s; }
        tbody tr:hover td { background: rgba(79,126,248,0.05); }

        /* ── BADGES ── */
        .b {
            display: inline-flex; align-items: center;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            white-space: nowrap;
        }
        .b-avail   { background:rgba(52,211,153,0.1);  color:#34d399; border:1px solid rgba(52,211,153,0.2); }
        .b-inuse   { background:rgba(79,126,248,0.12); color:#7c9ffa; border:1px solid rgba(79,126,248,0.2); }
        .b-faulty  { background:rgba(251,191,36,0.12); color:#fbbf24; border:1px solid rgba(251,191,36,0.2); }
        .b-retired { background:rgba(255,255,255,0.05);color:var(--muted); border:1px solid var(--border); }
        .b-low     { background:rgba(248,113,113,0.12);color:#f87171; border:1px solid rgba(248,113,113,0.2); }

        /* rank number */
        .rank {
            width: 22px; height: 22px; border-radius: 6px;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 0.68rem; font-weight: 700;
            background: rgba(79,126,248,0.1); color: var(--accent-2);
        }

        /* empty */
        .empty {
            text-align:center; padding:32px 24px;
            color:var(--muted); font-size:0.82rem;
        }
        .empty i { font-size:2rem; display:block; margin-bottom:10px; opacity:0.2; }
    </style>
</head>
<body>

    <!-- ═══════════ SIDEBAR ═══════════ -->
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
            <a href="<%=ctx%>/dashboard.jsp" class="sb-item si-home">
                <i class="fas fa-home"></i> Home
            </a>
            <a href="<%=ctx%>/storekeeper" class="sb-item on si-stats">
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
                <i class="fas fa-history"></i> Transaction History
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
                    <div class="sb-uname"><%=currentUser.getFullName()!=null?currentUser.getFullName():currentUser.getUsername()%></div>
                    <div class="sb-urole">Storekeeper</div>
                </div>
            </a>
            <a href="<%=ctx%>/logout" class="sb-logout">
                <i class="fas fa-sign-out-alt"></i> Sign Out
            </a>
        </div>
    </aside>

    <!-- ═══════════ MAIN ═══════════ -->
    <main class="main">

        <!-- Topbar -->
        <div class="topbar">
            <div>
                <div class="topbar-title">Warehouse Management</div>
                <div class="topbar-sub">Real-time inventory overview — parts & equipment.</div>
            </div>
            <div class="topbar-badge">
                <i class="fas fa-warehouse"></i>
                <%=currentUser.getFullName()!=null?currentUser.getFullName():currentUser.getUsername()%>
            </div>
        </div>

        <div class="content">

            <%-- Alert: low stock --%>
            <%if(lowStock > 0){%>
            <div class="alert-warn">
                <i class="fas fa-triangle-exclamation"></i>
                <div>
                    <strong style="color:var(--amber)"><%=lowStock%> part type(s)</strong> are running low on stock.
                    <a href="<%=ctx%>/numberPart?filter=low">Review now →</a>
                </div>
            </div>
            <%}%>

            <!-- ── PARTS STATS ── -->
            <div class="section-lbl">Parts Overview</div>
            <div class="stats">
                <div class="sc sc-blue">
                    <div class="sc-icon"><i class="fas fa-layer-group"></i></div>
                    <div class="sc-val"><%=totalPartTypes%></div>
                    <div class="sc-lbl">Part Types</div>
                    <div class="sc-sub info"><%=totalPartUnits%> total units</div>
                </div>
                <div class="sc sc-green">
                    <div class="sc-icon"><i class="fas fa-box-open"></i></div>
                    <div class="sc-val"><%=availableUnits%></div>
                    <div class="sc-lbl">Available Units</div>
                    <div class="sc-sub ok"><%=String.format("%.1f", pctAvailable)%>% of stock</div>
                </div>
                <div class="sc sc-amber">
                    <div class="sc-icon"><i class="fas fa-triangle-exclamation"></i></div>
                    <div class="sc-val"><%=lowStock%></div>
                    <div class="sc-lbl">Low Stock Types</div>
                    <div class="sc-sub warn">Needs reorder</div>
                </div>
                <div class="sc sc-red">
                    <div class="sc-icon"><i class="fas fa-circle-xmark"></i></div>
                    <div class="sc-val"><%=faultyUnits%></div>
                    <div class="sc-lbl">Faulty Units</div>
                    <div class="sc-sub bad">Requires inspection</div>
                </div>
                <div class="sc sc-purple">
                    <div class="sc-icon"><i class="fas fa-screwdriver-wrench"></i></div>
                    <div class="sc-val"><%=inuseUnits%></div>
                    <div class="sc-lbl">Units In Use</div>
                    <div class="sc-sub info">Currently deployed</div>
                </div>
                <div class="sc sc-info">
                    <div class="sc-icon"><i class="fas fa-archive"></i></div>
                    <div class="sc-val"><%=retiredUnits%></div>
                    <div class="sc-lbl">Retired Units</div>
                    <div class="sc-sub"><%=String.format("%.1f", pctRetired)%>% of stock</div>
                </div>
                <div class="sc sc-green">
                    <div class="sc-icon"><i class="fas fa-percent"></i></div>
                    <div class="sc-val"><%=String.format("%.0f", pctAvailable)%><span style="font-size:1.1rem">%</span></div>
                    <div class="sc-lbl">Availability Rate</div>
                    <div class="sc-sub ok">Parts health</div>
                </div>
                <div class="sc sc-blue">
                    <div class="sc-icon"><i class="fas fa-rotate-left"></i></div>
                    <div class="sc-val"><%=String.format("%.0f", pctRetired)%><span style="font-size:1.1rem">%</span></div>
                    <div class="sc-lbl">Retirement Rate</div>
                    <div class="sc-sub">End-of-life ratio</div>
                </div>
            </div>

            <!-- ── DONUT + EQUIPMENT ── -->
            <div class="section-lbl">Status Breakdown</div>
            <div class="grid-2">

                <!-- Donut -->
                <div class="card">
                    <div class="card-hd">
                        <div class="card-title"><i class="fas fa-chart-pie"></i> Parts Status Distribution</div>
                    </div>
                    <div class="donut-wrap">
                        <%
                            int total4 = availableUnits + inuseUnits + faultyUnits + retiredUnits;
                            if (total4 == 0) total4 = 1;
                            double r = 52; double cx2 = 70; double cy2 = 70;
                            double circumference = 2 * Math.PI * r;
                            int[] vals = { availableUnits, inuseUnits, faultyUnits, retiredUnits };
                            String[] colors = {"#34d399","#7c9ffa","#fbbf24","#f87171"};
                            double offset = 0;
                            StringBuilder svgPaths = new StringBuilder();
                            for (int i = 0; i < vals.length; i++) {
                                double fraction = (double)vals[i] / total4;
                                double dash = fraction * circumference;
                                if(dash < 0.01) { offset += dash; continue; }
                                svgPaths.append("<circle cx='").append(cx2).append("' cy='").append(cy2)
                                    .append("' r='").append(r)
                                    .append("' fill='none' stroke='").append(colors[i])
                                    .append("' stroke-width='16' stroke-linecap='round' stroke-dasharray='")
                                    .append(String.format("%.2f %.2f", Math.max(dash-2, 0), circumference - Math.max(dash-2, 0)))
                                    .append("' stroke-dashoffset='").append(String.format("%.2f", -offset))
                                    .append("'/>");
                                offset += dash;
                            }
                        %>
                        <div class="donut-ring">
                            <svg viewBox="0 0 140 140" width="140" height="140">
                                <circle cx="70" cy="70" r="52" fill="none" stroke="rgba(255,255,255,0.04)" stroke-width="16"/>
                                <%=svgPaths.toString()%>
                            </svg>
                            <div class="donut-center">
                                <div class="donut-center-val"><%=totalPartUnits%></div>
                                <div class="donut-center-lbl">Total</div>
                            </div>
                        </div>
                        <div class="donut-legend">
                            <div class="legend-item">
                                <span class="legend-dot" style="background:#34d399"></span>
                                Available
                                <span class="legend-count"><%=availableUnits%></span>
                            </div>
                            <div class="legend-item">
                                <span class="legend-dot" style="background:#7c9ffa"></span>
                                In Use
                                <span class="legend-count"><%=inuseUnits%></span>
                            </div>
                            <div class="legend-item">
                                <span class="legend-dot" style="background:#fbbf24"></span>
                                Faulty
                                <span class="legend-count"><%=faultyUnits%></span>
                            </div>
                            <div class="legend-item">
                                <span class="legend-dot" style="background:#f87171"></span>
                                Retired
                                <span class="legend-count"><%=retiredUnits%></span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Equipment Summary -->
                <div class="card">
                    <div class="card-hd">
                        <div class="card-title"><i class="fas fa-server"></i> Equipment Status</div>
                        <a href="<%=ctx%>/numberEquipment" class="card-link">View all →</a>
                    </div>
                    <div class="eq-grid">
                        <div class="eq-card b">
                            <div class="eq-icon"><i class="fas fa-layer-group"></i></div>
                            <div class="eq-val"><%=totalEqTypes%></div>
                            <div class="eq-lbl">Equipment Types</div>
                        </div>
                        <div class="eq-card b">
                            <div class="eq-icon"><i class="fas fa-database"></i></div>
                            <div class="eq-val"><%=totalEqUnits%></div>
                            <div class="eq-lbl">Total Units</div>
                        </div>
                        <div class="eq-card g">
                            <div class="eq-icon"><i class="fas fa-circle-check"></i></div>
                            <div class="eq-val"><%=availableEq%></div>
                            <div class="eq-lbl">Available</div>
                        </div>
                        <div class="eq-card r">
                            <div class="eq-icon"><i class="fas fa-wrench"></i></div>
                            <div class="eq-val"><%=inuseEq%> <span style="font-size:1rem;color:var(--muted)">/</span> <%=faultyEq%></div>
                            <div class="eq-lbl">In Use / Faulty</div>
                        </div>
                    </div>
                </div>

            </div>

            <!-- ── BOTTOM TABLES ── -->
            <div class="section-lbl">Parts Intelligence</div>
            <div class="grid-2">

                <!-- Low Stock -->
                <div class="card">
                    <div class="card-hd">
                        <div class="card-title"><i class="fas fa-triangle-exclamation" style="color:var(--amber)"></i> Low Stock Parts</div>
                        <a href="<%=ctx%>/numberPart" class="card-link">View all →</a>
                    </div>
                    <%if(lowStockList.isEmpty()){%>
                    <div class="empty">
                        <i class="fas fa-box-open"></i>
                        All parts are well stocked!
                    </div>
                    <%}else{%>
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Part Name</th>
                                <th>Category</th>
                                <th>Qty</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%int rowIdx=0; for(PartType pt : lowStockList){ rowIdx++; %>
                        <tr>
                            <td><span class="rank"><%=rowIdx%></span></td>
                            <td style="font-weight:600;color:var(--text)"><%=pt.getName()%></td>
                            <td style="color:var(--muted);font-size:0.75rem"><%=pt.getCategoryName()%></td>
                            <td><span class="b b-low"><%=pt.getAvailableUnits()%></span></td>
                        </tr>
                        <%}%>
                        </tbody>
                    </table>
                    <%}%>
                </div>

                <!-- Most Used -->
                <div class="card">
                    <div class="card-hd">
                        <div class="card-title"><i class="fas fa-fire" style="color:var(--accent-2)"></i> Most Used Parts</div>
                        <a href="<%=ctx%>/numberPart" class="card-link">View all →</a>
                    </div>
                    <%if(mostUsedList.isEmpty()){%>
                    <div class="empty">
                        <i class="fas fa-chart-bar"></i>
                        No usage data yet.
                    </div>
                    <%}else{%>
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Part Name</th>
                                <th>Category</th>
                                <th>In Use</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%int rowIdx2=0; for(PartType pt : mostUsedList){ rowIdx2++; %>
                        <tr>
                            <td><span class="rank"><%=rowIdx2%></span></td>
                            <td style="font-weight:600;color:var(--text)"><%=pt.getName()%></td>
                            <td style="color:var(--muted);font-size:0.75rem"><%=pt.getCategoryName()%></td>
                            <td><span class="b b-inuse"><%=pt.getInuseUnits()%></span></td>
                        </tr>
                        <%}%>
                        </tbody>
                    </table>
                    <%}%>
                </div>

            </div>
        </div>
    </main>

</body>
</html>
