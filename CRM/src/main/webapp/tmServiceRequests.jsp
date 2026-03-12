<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"TECHNICAL_MANAGER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    List<ServiceRequest> requests = (List<ServiceRequest>) request.getAttribute("requests");
    if (requests == null) requests = new ArrayList<>();
    int total       = request.getAttribute("total")      != null ? (int) request.getAttribute("total")      : 0;
    int currentPage = request.getAttribute("page")       != null ? (int) request.getAttribute("page")       : 1;
    int totalPages  = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;
    String keyword  = request.getAttribute("keyword")    != null ? (String) request.getAttribute("keyword") : "";
    String fStatus  = request.getAttribute("filterStatus")   != null ? (String) request.getAttribute("filterStatus")   : "";
    String fPriority= request.getAttribute("filterPriority") != null ? (String) request.getAttribute("filterPriority") : "";
    String fType    = request.getAttribute("filterType")     != null ? (String) request.getAttribute("filterType")     : "";
    Map<String,Integer> stats = (Map<String,Integer>) request.getAttribute("stats");
    if (stats == null) stats = new HashMap<>();

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");

    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Service Requests – Technical Manager</title>
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
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 0.88rem;
            box-shadow: 0 4px 14px var(--accent-glow);
            flex-shrink: 0;
        }
        .sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
        .sb-role {
            display: inline-flex; align-items: center;
            background: rgba(251,191,36,0.15);
            border: 1px solid rgba(251,191,36,0.25);
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
        .sb-item:hover     { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
        .sb-item:hover i   { background: rgba(79,126,248,0.2); color: var(--accent-2); }
        .sb-item.on {
            color: #fff;
            background: linear-gradient(90deg, rgba(79,126,248,0.2), rgba(79,126,248,0.05));
            border-left: 2px solid var(--accent);
        }
        .sb-item.on i { background: rgba(79,126,248,0.25); color: var(--accent-2); }

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
            cursor: pointer;
        }
        .sb-user:hover { background: rgba(79,126,248,0.1); border-color: rgba(79,126,248,0.25); }
        .sb-ava {
            width: 34px; height: 34px; border-radius: 50%;
            background: linear-gradient(135deg, var(--accent), var(--purple));
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
            display: flex;
            flex-direction: column;
            min-height: 100vh;
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
        .topbar-greeting { font-size: 1.25rem; font-weight: 800; color: #fff; letter-spacing: -0.3px; }
        .topbar-sub { color: var(--muted); font-size: 0.8rem; margin-top: 2px; font-weight: 300; }

        /* Content */
        .content { padding: 28px 32px; flex: 1; }

        /* Section label */
        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 12px;
        }

        /* ── ALERT ── */
        .alert {
            display: flex; align-items: center; gap: 12px;
            padding: 13px 18px; border-radius: 12px;
            margin-bottom: 22px;
            font-size: 0.84rem; color: var(--text-2);
            animation: cardIn 0.5s ease both;
        }
        .alert-success {
            background: var(--green-dim);
            border: 1px solid rgba(52,211,153,0.25);
        }
        .alert-success i { color: var(--green); }
        .alert-error {
            background: var(--danger-dim);
            border: 1px solid rgba(248,113,113,0.25);
        }
        .alert-error i { color: var(--danger); }

        /* ── STAT CARDS ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 14px;
            margin-bottom: 26px;
        }
        .sc {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 18px 16px;
            position: relative; overflow: hidden;
            backdrop-filter: blur(12px);
            transition: all 0.25s;
            animation: cardIn 0.5s ease both;
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .sc:nth-child(1){ animation-delay: 0.04s; }
        .sc:nth-child(2){ animation-delay: 0.08s; }
        .sc:nth-child(3){ animation-delay: 0.12s; }
        .sc:nth-child(4){ animation-delay: 0.16s; }
        .sc:nth-child(5){ animation-delay: 0.20s; }
        .sc:nth-child(6){ animation-delay: 0.24s; }
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
        .sc-total::before  { background: linear-gradient(90deg, transparent, var(--accent-2), transparent); }
        .sc-total::after   { background: linear-gradient(180deg, var(--accent), transparent); }
        .sc-pending::before{ background: linear-gradient(90deg, transparent, var(--amber), transparent); }
        .sc-pending::after { background: linear-gradient(180deg, var(--amber), transparent); }
        .sc-approved::before{ background: linear-gradient(90deg, transparent, var(--info), transparent); }
        .sc-approved::after { background: linear-gradient(180deg, var(--info), transparent); }
        .sc-progress::before{ background: linear-gradient(90deg, transparent, var(--purple), transparent); }
        .sc-progress::after { background: linear-gradient(180deg, var(--purple), transparent); }
        .sc-done::before   { background: linear-gradient(90deg, transparent, var(--green), transparent); }
        .sc-done::after    { background: linear-gradient(180deg, var(--green), transparent); }
        .sc-rejected::before{ background: linear-gradient(90deg, transparent, var(--danger), transparent); }
        .sc-rejected::after { background: linear-gradient(180deg, var(--danger), transparent); }

        .sc-icon {
            width: 34px; height: 34px; border-radius: 9px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.82rem; margin-bottom: 12px;
        }
        .sc-total .sc-icon   { background: rgba(79,126,248,0.12);  color: var(--accent-2); }
        .sc-pending .sc-icon { background: var(--amber-dim);        color: var(--amber); }
        .sc-approved .sc-icon{ background: var(--info-dim);         color: var(--info); }
        .sc-progress .sc-icon{ background: var(--purple-dim);       color: var(--purple); }
        .sc-done .sc-icon    { background: var(--green-dim);        color: var(--green); }
        .sc-rejected .sc-icon{ background: var(--danger-dim);       color: var(--danger); }

        .sc-val {
            font-size: 1.8rem; font-weight: 800;
            color: #fff; line-height: 1; letter-spacing: -1px;
        }
        .sc-lbl { color: var(--text-2); font-size: 0.74rem; margin-top: 4px; font-weight: 500; }

        /* ── FILTER BAR ── */
        .filter-bar {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 16px 18px;
            display: flex; flex-wrap: wrap; gap: 10px; align-items: center;
            margin-bottom: 18px;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s 0.1s ease both;
        }
        .filter-bar input,
        .filter-bar select {
            padding: 9px 13px;
            border: 1px solid var(--border);
            border-radius: 9px;
            font-size: 0.81rem;
            font-family: 'Sora', sans-serif;
            color: var(--text-2);
            background: rgba(255,255,255,0.05);
            outline: none;
            transition: all 0.2s;
        }
        .filter-bar input::placeholder { color: var(--muted); }
        .filter-bar input:focus,
        .filter-bar select:focus {
            border-color: rgba(79,126,248,0.5);
            background: rgba(79,126,248,0.07);
            color: #fff;
        }
        .filter-bar select option { background: #0f1c4d; color: #fff; }

        /* ── BUTTONS ── */
        .btn {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 9px 18px; border-radius: 10px;
            font-size: 0.81rem; font-weight: 600;
            font-family: 'Sora', sans-serif;
            cursor: pointer; border: none;
            text-decoration: none; transition: all 0.2s;
        }
        .btn-primary {
            background: linear-gradient(135deg, var(--accent), #6b8ffa);
            color: #fff;
            box-shadow: 0 3px 12px rgba(79,126,248,0.35);
        }
        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(79,126,248,0.5);
        }
        .btn-secondary {
            background: rgba(255,255,255,0.06);
            color: var(--text-2);
            border: 1px solid var(--border);
        }
        .btn-secondary:hover {
            background: rgba(255,255,255,0.1);
            color: #fff;
        }
        .btn-sm {
            padding: 6px 13px;
            font-size: 0.76rem;
        }

        /* ── TABLE WRAP ── */
        .table-wrap {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s 0.2s ease both;
        }
        table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
        thead tr { background: rgba(255,255,255,0.02); }
        th {
            padding: 11px 16px; text-align: left;
            color: var(--muted); font-weight: 600;
            font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.8px;
            border-bottom: 1px solid var(--border);
        }
        td {
            padding: 12px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.03);
            vertical-align: middle;
            color: var(--text-2);
        }
        tr:last-child td { border-bottom: none; }
        tbody tr { transition: background 0.15s; }
        tbody tr:hover td { background: rgba(79,126,248,0.05); }

        /* ── BADGES ── */
        .b {
            display: inline-flex; align-items: center;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            white-space: nowrap; letter-spacing: 0.2px;
        }
        .b-pending    { background: rgba(251,191,36,0.12);  color: #fbbf24; border: 1px solid rgba(251,191,36,0.2); }
        .b-approved   { background: rgba(52,211,153,0.1);   color: #34d399; border: 1px solid rgba(52,211,153,0.2); }
        .b-rejected   { background: rgba(248,113,113,0.1);  color: #f87171; border: 1px solid rgba(248,113,113,0.2); }
        .b-in_progress,
        .b-in-progress { background: rgba(79,126,248,0.12); color: #7c9ffa; border: 1px solid rgba(79,126,248,0.2); }
        .b-completed  { background: rgba(167,139,250,0.12); color: #a78bfa; border: 1px solid rgba(167,139,250,0.2); }
        .b-cancelled  { background: rgba(255,255,255,0.05); color: var(--muted); border: 1px solid var(--border); }
        .b-low        { background: rgba(52,211,153,0.08);  color: #6ee7b7; border: 1px solid rgba(52,211,153,0.15); }
        .b-medium     { background: rgba(251,191,36,0.1);   color: #fcd34d; border: 1px solid rgba(251,191,36,0.2); }
        .b-high       { background: rgba(251,146,60,0.1);   color: #fb923c; border: 1px solid rgba(251,146,60,0.2); }
        .b-urgent     { background: rgba(248,113,113,0.12); color: #fca5a5; border: 1px solid rgba(248,113,113,0.2); }

        /* Contract type mini */
        .ct-badge {
            display: inline-block;
            padding: 2px 7px; border-radius: 5px;
            font-size: 0.68rem; font-weight: 700;
        }
        .ct-wr { background: rgba(52,211,153,0.12); color: #34d399; }
        .ct-mt { background: rgba(79,126,248,0.12); color: #7c9ffa; }

        /* Code link */
        .code-link {
            color: var(--accent-2); font-weight: 700;
            font-size: 0.77rem; font-family: 'Courier New', monospace;
            text-decoration: none; letter-spacing: -0.3px;
        }
        .code-link:hover { color: #fff; }

        .td-muted  { color: var(--muted); font-size: 0.75rem; }
        .td-bold   { font-weight: 600; color: var(--text); }
        .td-empty  {
            text-align: center; padding: 40px 16px;
            color: var(--muted); font-size: 0.82rem;
        }
        .td-empty i { font-size: 2rem; display: block; margin-bottom: 10px; opacity: 0.2; }

        /* ── PAGINATION ── */
        .pagination {
            display: flex; justify-content: flex-end; align-items: center;
            gap: 5px; padding: 14px 18px;
            border-top: 1px solid var(--border);
        }
        .pagination a,
        .pagination span {
            padding: 6px 12px; border-radius: 8px;
            font-size: 0.78rem; font-weight: 500;
            text-decoration: none; color: var(--text-2);
            border: 1px solid var(--border);
            background: rgba(255,255,255,0.03);
            transition: all 0.15s;
        }
        .pagination a:hover {
            background: rgba(79,126,248,0.15);
            border-color: rgba(79,126,248,0.4);
            color: #fff;
        }
        .pagination .active {
            background: linear-gradient(135deg, var(--accent), #6b8ffa);
            color: #fff; border-color: transparent;
            box-shadow: 0 3px 10px rgba(79,126,248,0.4);
        }
        .pagination .dots {
            border: none; background: none;
            color: var(--muted); cursor: default;
        }
    </style>
</head>
<body>

    <%-- ═══════════ SIDEBAR ═══════════ --%>
    <aside class="sb">
        <div class="sb-brand">
            <div class="sb-logo"><i class="fas fa-bolt"></i></div>
            <div>
                <div class="sb-name">DRSMS</div>
                <div class="sb-role">Tech Manager</div>
            </div>
        </div>

        <nav class="sb-nav">
            <div class="sb-lbl">Management</div>
            <a href="<%=ctx%>/tmServiceRequests" class="sb-item on">
                <i class="fas fa-clipboard-list"></i> Service Requests
            </a>
        </nav>

        <div class="sb-foot">
            <a href="<%=ctx%>/profile" class="sb-user">
                <div class="sb-ava">
                    <%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%>
                    <img src="<%=ctx%><%=me.getAvatarUrl()%>" alt="avatar">
                    <%}else{%><%=initials%><%}%>
                </div>
                <div>
                    <div class="sb-uname"><%=me.getFullName()%></div>
                    <div class="sb-urole">Technical Manager</div>
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
                <div class="topbar-greeting">
                    <i class="fas fa-clipboard-list" style="color:var(--accent-2);margin-right:8px;font-size:1rem"></i>Service Requests
                </div>
                <div class="topbar-sub">Review, approve/reject and assign technicians to service requests</div>
            </div>
        </div>

        <div class="content">

            <%-- Flash messages --%>
            <%if(flashOk!=null){%>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%=flashOk%>
            </div>
            <%}%>
            <%if(flashErr!=null){%>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%=flashErr%>
            </div>
            <%}%>

            <%-- Stats --%>
            <div class="section-lbl">Overview</div>
            <div class="stats-grid">
                <div class="sc sc-total">
                    <div class="sc-icon"><i class="fas fa-layer-group"></i></div>
                    <div class="sc-val"><%=stats.getOrDefault("total",0)%></div>
                    <div class="sc-lbl">Total</div>
                </div>
                <div class="sc sc-pending">
                    <div class="sc-icon"><i class="fas fa-hourglass-half"></i></div>
                    <div class="sc-val"><%=stats.getOrDefault("pending",0)%></div>
                    <div class="sc-lbl">Pending</div>
                </div>
                <div class="sc sc-approved">
                    <div class="sc-icon"><i class="fas fa-check"></i></div>
                    <div class="sc-val"><%=stats.getOrDefault("approved",0)%></div>
                    <div class="sc-lbl">Approved</div>
                </div>
                <div class="sc sc-progress">
                    <div class="sc-icon"><i class="fas fa-wrench"></i></div>
                    <div class="sc-val"><%=stats.getOrDefault("in_progress",0)%></div>
                    <div class="sc-lbl">In Progress</div>
                </div>
                <div class="sc sc-done">
                    <div class="sc-icon"><i class="fas fa-circle-check"></i></div>
                    <div class="sc-val"><%=stats.getOrDefault("completed",0)%></div>
                    <div class="sc-lbl">Completed</div>
                </div>
                <div class="sc sc-rejected">
                    <div class="sc-icon"><i class="fas fa-times-circle"></i></div>
                    <div class="sc-val"><%=stats.getOrDefault("rejected",0)%></div>
                    <div class="sc-lbl">Rejected</div>
                </div>
            </div>

            <%-- Filters --%>
            <div class="section-lbl">Filter</div>
            <form method="get" action="<%=ctx%>/tmServiceRequests">
            <div class="filter-bar">
                <input type="text" name="keyword"
                       placeholder="🔍  Search code / customer / title..."
                       value="<%=keyword!=null?keyword:""%>"
                       style="flex:1;min-width:200px">
                <select name="status">
                    <option value="">All Status</option>
                    <%for(String s:new String[]{"PENDING","APPROVED","REJECTED","IN_PROGRESS","COMPLETED","CANCELLED"}){%>
                    <option value="<%=s%>" <%=s.equals(fStatus)?"selected":""%>><%=s.replace("_"," ")%></option>
                    <%}%>
                </select>
                <select name="priority">
                    <option value="">All Priority</option>
                    <%for(String p:new String[]{"LOW","MEDIUM","HIGH","URGENT"}){%>
                    <option value="<%=p%>" <%=p.equals(fPriority)?"selected":""%>><%=p%></option>
                    <%}%>
                </select>
                <select name="contractType">
                    <option value="">All Types</option>
                    <option value="WARRANTY"    <%="WARRANTY".equals(fType)?"selected":""%>>WARRANTY</option>
                    <option value="MAINTENANCE" <%="MAINTENANCE".equals(fType)?"selected":""%>>MAINTENANCE</option>
                </select>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-search"></i> Filter
                </button>
                <a href="<%=ctx%>/tmServiceRequests" class="btn btn-secondary">
                    <i class="fas fa-times"></i> Reset
                </a>
            </div>
            </form>

            <%-- Table --%>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Customer</th>
                            <th>Title</th>
                            <th>Contract</th>
                            <th>Priority</th>
                            <th>Status</th>
                            <th>Created</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%if(requests.isEmpty()){%>
                    <tr><td colspan="8" class="td-empty">
                        <i class="fas fa-inbox"></i>
                        No service requests found.
                    </td></tr>
                    <%}else{ for(ServiceRequest sr:requests){
                        String bSt="b-pending";
                        if("APPROVED".equals(sr.getStatus()))    bSt="b-approved";
                        else if("REJECTED".equals(sr.getStatus()))    bSt="b-rejected";
                        else if("IN_PROGRESS".equals(sr.getStatus())) bSt="b-in_progress";
                        else if("COMPLETED".equals(sr.getStatus()))   bSt="b-completed";
                        else if("CANCELLED".equals(sr.getStatus()))   bSt="b-cancelled";
                        String bPr="b-medium";
                        if("LOW".equals(sr.getPriority()))    bPr="b-low";
                        else if("HIGH".equals(sr.getPriority()))   bPr="b-high";
                        else if("URGENT".equals(sr.getPriority())) bPr="b-urgent";
                    %>
                    <tr>
                        <td>
                            <a class="code-link"
                               href="<%=ctx%>/tmServiceRequests?action=detail&id=<%=sr.getId()%>">
                                <%=sr.getRequestCode()%>
                            </a>
                        </td>
                        <td class="td-bold"><%=sr.getCustomerName()%></td>
                        <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--text-2)">
                            <%=sr.getTitle()%>
                        </td>
                        <td>
                            <div style="font-size:0.77rem;font-weight:600;color:var(--text-2)"><%=sr.getContractCode()%></div>
                            <span class="ct-badge <%="WARRANTY".equals(sr.getContractType())?"ct-wr":"ct-mt"%>" style="margin-top:3px">
                                <%="WARRANTY".equals(sr.getContractType())?"WR":"MT"%>
                            </span>
                        </td>
                        <td><span class="b <%=bPr%>"><%=sr.getPriority()%></span></td>
                        <td><span class="b <%=bSt%>"><%=sr.getStatusLabel()%></span></td>
                        <td class="td-muted"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toLocalDate():""%></td>
                        <td>
                            <a class="btn btn-primary btn-sm"
                               href="<%=ctx%>/tmServiceRequests?action=detail&id=<%=sr.getId()%>">
                                <i class="fas fa-eye"></i> View
                            </a>
                        </td>
                    </tr>
                    <%}}%>
                    </tbody>
                </table>

                <%-- Pagination --%>
                <%if(totalPages>1){
                    String q="&keyword="+keyword+"&status="+fStatus+"&priority="+fPriority+"&contractType="+fType;
                %>
                <div class="pagination">
                    <%if(currentPage>1){%>
                    <a href="<%=ctx%>/tmServiceRequests?page=<%=currentPage-1%><%=q%>">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                    <%}%>
                    <%for(int i=1;i<=totalPages;i++){
                        if(i==currentPage){%>
                        <span class="active"><%=i%></span>
                        <%}else if(i==1||i==totalPages||Math.abs(i-currentPage)<=2){%>
                        <a href="<%=ctx%>/tmServiceRequests?page=<%=i%><%=q%>"><%=i%></a>
                        <%}else if(Math.abs(i-currentPage)==3){%>
                        <span class="dots">…</span>
                        <%}%>
                    <%}%>
                    <%if(currentPage<totalPages){%>
                    <a href="<%=ctx%>/tmServiceRequests?page=<%=currentPage+1%><%=q%>">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                    <%}%>
                </div>
                <%}%>
            </div>

        </div>
    </main>

</body>
</html>
