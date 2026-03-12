<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.TransactionDAO.TransactionRow, java.util.*, java.text.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<TransactionRow> transactions = (List<TransactionRow>) request.getAttribute("transactions");
    Map<String, Integer> counts = (Map<String, Integer>) request.getAttribute("counts");
    if (transactions == null) transactions = new ArrayList<>();
    if (counts       == null) counts       = new HashMap<>();

    String activeType = (String) request.getAttribute("type");    if (activeType == null) activeType = "ALL";
    String itemType   = (String) request.getAttribute("itemType"); if (itemType   == null) itemType   = "";
    String keyword    = (String) request.getAttribute("keyword");  if (keyword    == null) keyword    = "";
    String fromDate   = (String) request.getAttribute("fromDate"); if (fromDate   == null) fromDate   = "";
    String toDate     = (String) request.getAttribute("toDate");   if (toDate     == null) toDate     = "";
    int currentPage   = request.getAttribute("currentPage") != null ? (int)request.getAttribute("currentPage") : 1;
    int totalPages    = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages")  : 1;
    int total         = request.getAttribute("total")       != null ? (int)request.getAttribute("total")       : 0;

    int cntAll      = counts.getOrDefault("ALL",      0);
    int cntPurchase = counts.getOrDefault("PURCHASE", 0);
    int cntRepair   = counts.getOrDefault("REPAIR",   0);
    int cntImport   = counts.getOrDefault("IMPORT",   0);

    String ctx = request.getContextPath();
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";

    boolean hasFilter  = !keyword.isEmpty() || !itemType.isEmpty() || !fromDate.isEmpty() || !toDate.isEmpty();
    boolean isPurchase = "PURCHASE".equals(activeType);
    boolean isRepair   = "REPAIR".equals(activeType);
    boolean isAll      = "ALL".equals(activeType);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction History - DRSMS</title>
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

        /* ════════ SIDEBAR ════════ */
        .sb {
            width: var(--sb-width); min-height: 100vh;
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
            background: linear-gradient(135deg, var(--green), var(--info));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: var(--navy); font-size: 0.88rem;
            box-shadow: 0 4px 14px rgba(52,211,153,0.3); flex-shrink: 0;
        }
        .sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
        .sb-role {
            display: inline-flex;
            background: rgba(52,211,153,0.12); border: 1px solid rgba(52,211,153,0.25);
            color: var(--green); font-size: 0.62rem; font-weight: 700;
            letter-spacing: 1px; text-transform: uppercase;
            padding: 2px 8px; border-radius: 20px; margin-top: 3px;
        }
        .sb-nav { flex: 1; padding: 12px 10px; overflow-y: auto; }
        .sb-lbl {
            color: rgba(255,255,255,0.22); font-size: 0.62rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.4px;
            padding: 0 8px; margin: 16px 0 5px;
        }
        .sb-item {
            display: flex; align-items: center; gap: 9px;
            padding: 9px 10px; border-radius: 9px; margin-bottom: 1px;
            color: rgba(255,255,255,0.45); text-decoration: none;
            font-size: 0.83rem; font-weight: 500;
            transition: all 0.2s; border-left: 2px solid transparent;
        }
        .sb-item i {
            width: 28px; height: 28px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.8rem; border-radius: 8px;
            background: rgba(255,255,255,0.05); flex-shrink: 0; transition: all 0.2s;
        }
        .sb-item.on {
            color: #fff;
            background: linear-gradient(90deg, rgba(167,139,250,0.15), rgba(167,139,250,0.04));
            border-left: 2px solid var(--purple);
        }
        .sb-item.on i { background: rgba(167,139,250,0.2); color: var(--purple); }

        .sb-item.si-home:hover     { color:#fff; background:rgba(79,126,248,0.1);    border-left-color:var(--accent);  }
        .sb-item.si-home:hover i   { background:rgba(79,126,248,0.2);  color:var(--accent-2); }
        .sb-item.si-stats:hover    { color:#fff; background:rgba(52,211,153,0.08);   border-left-color:var(--green);   }
        .sb-item.si-stats:hover i  { background:rgba(52,211,153,0.2);  color:var(--green);    }
        .sb-item.si-parts:hover    { color:#fff; background:rgba(251,191,36,0.08);   border-left-color:var(--amber);   }
        .sb-item.si-parts:hover i  { background:rgba(251,191,36,0.2);  color:var(--amber);    }
        .sb-item.si-equip:hover    { color:#fff; background:rgba(56,189,248,0.08);   border-left-color:var(--info);    }
        .sb-item.si-equip:hover i  { background:rgba(56,189,248,0.2);  color:var(--info);     }
        .sb-item.si-tx:hover       { color:#fff; background:rgba(167,139,250,0.08);  border-left-color:var(--purple);  }
        .sb-item.si-tx:hover i     { background:rgba(167,139,250,0.2); color:var(--purple);   }

        .sb-foot { padding: 12px 10px 16px; border-top: 1px solid var(--border); }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px; border-radius: 10px;
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
            margin-bottom: 6px; text-decoration: none; transition: all 0.2s;
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

        /* ════════ MAIN ════════ */
        .main {
            margin-left: var(--sb-width); flex: 1; padding: 0;
            min-height: 100vh; display: flex; flex-direction: column;
        }
        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 22px 32px; border-bottom: 1px solid var(--border);
            background: rgba(11,20,55,0.6); backdrop-filter: blur(16px);
            position: sticky; top: 0; z-index: 50;
        }
        .topbar-title { font-size: 1.25rem; font-weight: 800; color: #fff; letter-spacing: -0.3px; }
        .topbar-sub   { color: var(--muted); font-size: 0.8rem; margin-top: 2px; font-weight: 300; }
        .topbar-badge {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 8px 16px;
            background: rgba(167,139,250,0.08); border: 1px solid rgba(167,139,250,0.2);
            border-radius: 20px; color: var(--purple); font-size: 0.8rem; font-weight: 600;
        }
        .content { padding: 28px 32px; flex: 1; }

        @keyframes cardIn {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 12px;
        }

        /* ── TABS ── */
        .tabs { display: flex; gap: 6px; margin-bottom: 22px; flex-wrap: wrap; }
        .tab {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 9px 18px; border-radius: 11px;
            font-size: 0.82rem; font-weight: 600; text-decoration: none;
            transition: all 0.2s; border: 1px solid var(--border);
            background: rgba(255,255,255,0.03);
            color: rgba(255,255,255,0.45); white-space: nowrap;
        }
        .tab:hover { color: #fff; background: rgba(255,255,255,0.07); border-color: rgba(255,255,255,0.12); }
        .tab .cnt {
            padding: 2px 8px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            background: rgba(255,255,255,0.08); color: var(--muted);
        }
        .tab-all.active      { background:rgba(79,126,248,0.15);  border-color:rgba(79,126,248,0.35);  color:#fff; }
        .tab-all.active .cnt { background:rgba(79,126,248,0.25);  color:var(--accent-2); }
        .tab-purchase.active      { background:rgba(52,211,153,0.12);  border-color:rgba(52,211,153,0.3);  color:#fff; }
        .tab-purchase.active .cnt { background:rgba(52,211,153,0.2);   color:var(--green);   }
        .tab-repair.active        { background:rgba(251,191,36,0.12);  border-color:rgba(251,191,36,0.3);  color:#fff; }
        .tab-repair.active .cnt   { background:rgba(251,191,36,0.2);   color:var(--amber);   }
        .tab-import.active        { background:rgba(167,139,250,0.12); border-color:rgba(167,139,250,0.3); color:#fff; }
        .tab-import.active .cnt   { background:rgba(167,139,250,0.2);  color:var(--purple);  }

        /* ── FILTER BAR ── */
        .filter-bar {
            background: rgba(17,26,66,0.7); border: 1px solid var(--border);
            border-radius: 14px; padding: 14px 16px; margin-bottom: 14px;
            display: flex; gap: 10px; align-items: center; flex-wrap: wrap;
            backdrop-filter: blur(12px); animation: cardIn 0.4s ease both;
        }
        .filter-bar input,
        .filter-bar select {
            padding: 9px 12px;
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
            border-radius: 10px; color: var(--text);
            font-size: 0.82rem; font-family: inherit; outline: none; transition: border-color 0.2s;
        }
        .filter-bar input::placeholder { color: var(--muted); }
        .filter-bar input:focus,
        .filter-bar select:focus { border-color: rgba(79,126,248,0.5); background: rgba(79,126,248,0.05); }
        .filter-bar input[type="text"]  { flex: 1; min-width: 200px; }
        .filter-bar input[type="date"]  { color-scheme: dark; }
        .filter-bar select option       { background: #0f1c4d; }

        .btn {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 9px 16px; border-radius: 10px; border: none;
            font-size: 0.82rem; font-weight: 600; font-family: inherit;
            cursor: pointer; text-decoration: none; transition: all 0.2s; white-space: nowrap;
        }
        .btn-search { background:rgba(79,126,248,0.15); color:var(--accent-2); border:1px solid rgba(79,126,248,0.3); }
        .btn-search:hover { background:rgba(79,126,248,0.28); border-color:rgba(79,126,248,0.5); }
        .btn-reset  { background:rgba(248,113,113,0.1); color:var(--danger); border:1px solid rgba(248,113,113,0.25); }
        .btn-reset:hover { background:rgba(248,113,113,0.2); border-color:rgba(248,113,113,0.4); }

        /* Filter tags */
        .filter-tags { display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:14px; }
        .filter-tag {
            display:inline-flex; align-items:center; gap:6px;
            padding:4px 10px; border-radius:20px;
            background:rgba(79,126,248,0.1); border:1px solid rgba(79,126,248,0.25);
            color:var(--accent-2); font-size:0.72rem; font-weight:600;
        }
        .filter-tags-lbl { font-size:0.72rem; color:var(--muted); font-weight:500; }

        /* ── CARD / TABLE ── */
        .card {
            background: rgba(17,26,66,0.7); border: 1px solid var(--border);
            border-radius: 16px; overflow: hidden;
            backdrop-filter: blur(12px); animation: cardIn 0.5s 0.1s ease both;
        }
        .card-hd {
            display: flex; justify-content: space-between; align-items: center;
            padding: 14px 20px; border-bottom: 1px solid var(--border);
        }
        .card-title { font-size:0.87rem; font-weight:700; color:#fff; display:flex; align-items:center; gap:8px; }
        .card-title i { color: var(--purple); }
        .total-badge {
            font-size:0.72rem; color:var(--muted);
            background:rgba(255,255,255,0.04); border:1px solid var(--border);
            padding:3px 10px; border-radius:20px;
        }

        table { width:100%; border-collapse:collapse; font-size:0.8rem; }
        thead tr { background: rgba(255,255,255,0.02); }
        th {
            padding:10px 14px; text-align:left;
            color:var(--muted); font-weight:600;
            font-size:0.68rem; text-transform:uppercase; letter-spacing:0.8px;
            border-bottom:1px solid var(--border);
        }
        td {
            padding:11px 14px; border-bottom:1px solid rgba(255,255,255,0.03);
            vertical-align:middle; color:var(--text-2);
        }
        tr:last-child td { border-bottom:none; }
        tbody tr { transition:background 0.15s; }
        tbody tr:hover td { background:rgba(79,126,248,0.05); }

        /* badges */
        .b {
            display:inline-flex; align-items:center; gap:4px;
            padding:3px 9px; border-radius:20px;
            font-size:0.7rem; font-weight:700; white-space:nowrap;
        }
        .b-purchase { background:var(--green-dim);   color:var(--green);   border:1px solid rgba(52,211,153,0.2); }
        .b-repair   { background:var(--amber-dim);   color:var(--amber);   border:1px solid rgba(251,191,36,0.2); }
        .b-import   { background:var(--purple-dim);  color:var(--purple);  border:1px solid rgba(167,139,250,0.2); }
        .b-other    { background:rgba(255,255,255,0.05); color:var(--muted); border:1px solid var(--border); }
        .b-part      { background:rgba(79,126,248,0.12); color:var(--accent-2); border:1px solid rgba(79,126,248,0.2); }
        .b-equipment { background:var(--info-dim);        color:var(--info);     border:1px solid rgba(56,189,248,0.2); }

        .td-id     { color:var(--muted); font-size:0.75rem; }
        .td-item   { font-weight:700; color:var(--text); font-size:0.82rem; }
        .td-serial { font-family:'Courier New',monospace; font-size:0.78rem; color:var(--accent-2); font-weight:600; }
        .td-customer { font-weight:600; color:var(--text); font-size:0.8rem; }
        .td-order  { font-family:'Courier New',monospace; font-size:0.75rem; color:var(--green); font-weight:700; }
        .td-ref    { font-family:'Courier New',monospace; font-size:0.75rem; color:var(--amber); font-weight:700; }
        .td-by     { font-size:0.78rem; color:var(--text-2); }
        .td-note   { color:var(--muted); font-size:0.75rem; max-width:160px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
        .td-time   { color:var(--muted); font-size:0.75rem; white-space:nowrap; }
        .td-dash   { color:var(--muted); }

        /* pagination */
        .pagination {
            display:flex; justify-content:space-between; align-items:center;
            padding:14px 20px; border-top:1px solid var(--border);
        }
        .paging-info { color:var(--muted); font-size:0.75rem; }
        .page-btns { display:flex; gap:5px; }
        .page-btn {
            padding:6px 12px; border-radius:8px;
            background:rgba(255,255,255,0.04); border:1px solid var(--border);
            font-size:0.78rem; color:var(--text-2);
            cursor:pointer; text-decoration:none; transition:all 0.2s; font-family:inherit;
        }
        .page-btn.active { background:var(--accent); border-color:var(--accent); color:#fff; font-weight:700; }
        .page-btn:hover:not(.active):not(.disabled) { background:rgba(79,126,248,0.12); border-color:rgba(79,126,248,0.3); color:#fff; }
        .page-btn.disabled { opacity:0.3; pointer-events:none; }

        .empty { text-align:center; padding:52px 24px; color:var(--muted); font-size:0.82rem; }
        .empty i { font-size:2.4rem; display:block; margin-bottom:14px; opacity:0.18; }
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
            <a href="<%=ctx%>/transactions" class="sb-item on si-tx">
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
        <div class="topbar">
            <div>
                <div class="topbar-title">Transaction History</div>
                <div class="topbar-sub">Full log of purchases, repairs, and stock operations.</div>
            </div>
            <div class="topbar-badge">
                <i class="fas fa-history"></i>
                <%=currentUser.getFullName()!=null?currentUser.getFullName():currentUser.getUsername()%>
            </div>
        </div>

        <div class="content">

            <!-- TABS -->
            <div class="tabs">
                <a href="<%=ctx%>/transactions?type=ALL"
                   class="tab tab-all <%="ALL".equals(activeType)?"active":""%>">
                    <i class="fas fa-list"></i> All <span class="cnt"><%=cntAll%></span>
                </a>
                <a href="<%=ctx%>/transactions?type=PURCHASE"
                   class="tab tab-purchase <%="PURCHASE".equals(activeType)?"active":""%>">
                    <i class="fas fa-shopping-cart"></i> Purchase <span class="cnt"><%=cntPurchase%></span>
                </a>
                <a href="<%=ctx%>/transactions?type=REPAIR"
                   class="tab tab-repair <%="REPAIR".equals(activeType)?"active":""%>">
                    <i class="fas fa-screwdriver-wrench"></i> Repair <span class="cnt"><%=cntRepair%></span>
                </a>
                <a href="<%=ctx%>/transactions?type=IMPORT"
                   class="tab tab-import <%="IMPORT".equals(activeType)?"active":""%>">
                    <i class="fas fa-boxes-stacked"></i> Stock In <span class="cnt"><%=cntImport%></span>
                </a>
            </div>

            <!-- FILTER BAR -->
            <div class="section-lbl">Filter & Search</div>
            <form method="get" action="<%=ctx%>/transactions">
                <input type="hidden" name="type" value="<%=activeType%>">
                <div class="filter-bar">
                    <input type="text" name="keyword"
                           placeholder="🔍  Search by item name, customer, order code…"
                           value="<%=keyword%>">
                    <select name="itemType">
                        <option value="">All Item Types</option>
                        <option value="PART"      <%="PART".equals(itemType)      ?"selected":""%>>Part</option>
                        <option value="EQUIPMENT" <%="EQUIPMENT".equals(itemType) ?"selected":""%>>Equipment</option>
                    </select>
                    <input type="date" name="fromDate" value="<%=fromDate%>" title="From date">
                    <input type="date" name="toDate"   value="<%=toDate%>"   title="To date">
                    <button type="submit" class="btn btn-search">
                        <i class="fas fa-magnifying-glass"></i> Search
                    </button>
                    <a href="<%=ctx%>/transactions?type=<%=activeType%>" class="btn btn-reset">
                        <i class="fas fa-filter-circle-xmark"></i> Reset Filters
                    </a>
                </div>
            </form>

            <!-- Active filter tags -->
            <div class="filter-tags">
                <span class="filter-tags-lbl">Active filters:</span>
                <%if(!keyword.isEmpty()){%>
                <span class="filter-tag"><i class="fas fa-magnifying-glass"></i> "<%=keyword%>"</span>
                <%}%>
                <%if(!itemType.isEmpty()){%>
                <span class="filter-tag"><i class="fas fa-tag"></i> <%=itemType%></span>
                <%}%>
                <%if(!fromDate.isEmpty()){%>
                <span class="filter-tag"><i class="fas fa-calendar-days"></i> From <%=fromDate%></span>
                <%}%>
                <%if(!toDate.isEmpty()){%>
                <span class="filter-tag"><i class="fas fa-calendar-days"></i> To <%=toDate%></span>
                <%}%>
                <%if(!hasFilter){%>
                <span style="color:var(--muted);font-size:0.72rem;font-style:italic">None</span>
                <%}%>
            </div>

            <!-- TABLE -->
            <div class="section-lbl">Transactions (<%=total%> found)</div>
            <div class="card">
                <div class="card-hd">
                    <div class="card-title"><i class="fas fa-clock-rotate-left"></i> Transaction Log</div>
                    <span class="total-badge"><%=total%> records · Page <%=currentPage%> of <%=totalPages%></span>
                </div>

                <%if(transactions.isEmpty()){%>
                <div class="empty">
                    <i class="fas fa-inbox"></i>
                    No transactions found for this filter.
                </div>
                <%}else{%>
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Type</th>
                            <th>Item Type</th>
                            <th>Item Name</th>
                            <th>Unit / Serial</th>
                            <%if(isPurchase||isAll){%><th>Customer</th><th>Order Code</th><%}%>
                            <%if(isRepair||isAll){%><th>Repair #</th><%}%>
                            <th>Performed By</th>
                            <th>Note</th>
                            <th>Time</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%for(TransactionRow t : transactions){
                        String typeCls = "b-other", typeLabel = t.transactionType;
                        if("PURCHASE".equals(t.transactionType)){ typeCls="b-purchase"; typeLabel="Purchase"; }
                        else if("REPAIR".equals(t.transactionType)){ typeCls="b-repair"; typeLabel="Repair"; }
                        else if("IMPORT".equals(t.transactionType)){ typeCls="b-import"; typeLabel="Stock In"; }
                        String itemCls   = "PART".equals(t.itemType) ? "b-part" : "b-equipment";
                        String itemLabel = "PART".equals(t.itemType) ? "Part"   : "Equipment";
                    %>
                    <tr>
                        <td class="td-id"><%=t.id%></td>
                        <td><span class="b <%=typeCls%>"><%=typeLabel%></span></td>
                        <td><span class="b <%=itemCls%>"><%=itemLabel%></span></td>
                        <td class="td-item"><%=t.itemName!=null?t.itemName:"—"%></td>
                        <td class="td-serial"><%=t.serialOrUnitId!=null?("#"+t.serialOrUnitId):"—"%></td>
                        <%if(isPurchase||isAll){%>
                        <td class="td-customer"><%=t.customerName!=null?t.customerName:"—"%></td>
                        <td><%if(t.orderCode!=null){%><span class="td-order"><%=t.orderCode%></span><%}else{%><span class="td-dash">—</span><%}%></td>
                        <%}%>
                        <%if(isRepair||isAll){%>
                        <td><%if(t.refOrderId!=null){%><span class="td-ref">#<%=t.refOrderId%></span><%}else{%><span class="td-dash">—</span><%}%></td>
                        <%}%>
                        <td class="td-by"><%=t.performedBy!=null?t.performedBy:"—"%></td>
                        <td class="td-note" title="<%=t.note!=null?t.note:""%>"><%=t.note!=null?t.note:"—"%></td>
                        <td class="td-time"><%=t.createdAt!=null?sdf.format(t.createdAt):"—"%></td>
                    </tr>
                    <%}%>
                    </tbody>
                </table>

                <!-- PAGINATION -->
                <div class="pagination">
                    <span class="paging-info">
                        Showing <%=transactions.size()%> of <%=total%> — Page <%=currentPage%> / <%=totalPages%>
                    </span>
                    <div class="page-btns">
                        <a href="<%=ctx%>/transactions?type=<%=activeType%>&keyword=<%=keyword%>&itemType=<%=itemType%>&fromDate=<%=fromDate%>&toDate=<%=toDate%>&page=1"
                           class="page-btn <%=currentPage==1?"disabled":""%>">«</a>
                        <a href="<%=ctx%>/transactions?type=<%=activeType%>&keyword=<%=keyword%>&itemType=<%=itemType%>&fromDate=<%=fromDate%>&toDate=<%=toDate%>&page=<%=Math.max(1,currentPage-1)%>"
                           class="page-btn <%=currentPage==1?"disabled":""%>">‹</a>
                        <%for(int p=Math.max(1,currentPage-2);p<=Math.min(totalPages,currentPage+2);p++){%>
                        <a href="<%=ctx%>/transactions?type=<%=activeType%>&keyword=<%=keyword%>&itemType=<%=itemType%>&fromDate=<%=fromDate%>&toDate=<%=toDate%>&page=<%=p%>"
                           class="page-btn <%=p==currentPage?"active":""%>"><%=p%></a>
                        <%}%>
                        <a href="<%=ctx%>/transactions?type=<%=activeType%>&keyword=<%=keyword%>&itemType=<%=itemType%>&fromDate=<%=fromDate%>&toDate=<%=toDate%>&page=<%=Math.min(totalPages,currentPage+1)%>"
                           class="page-btn <%=currentPage==totalPages?"disabled":""%>">›</a>
                        <a href="<%=ctx%>/transactions?type=<%=activeType%>&keyword=<%=keyword%>&itemType=<%=itemType%>&fromDate=<%=fromDate%>&toDate=<%=toDate%>&page=<%=totalPages%>"
                           class="page-btn <%=currentPage==totalPages?"disabled":""%>">»</a>
                    </div>
                </div>
                <%}%>
            </div>

        </div><!-- /content -->
    </main>

</body>
</html>
