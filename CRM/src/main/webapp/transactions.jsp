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
                --sb-bg:        #1e1b4b;
                --sb-border:    rgba(255,255,255,0.08);
                --sb-text:      rgba(255,255,255,0.45);
                --sb-accent:    #818cf8;
                --sb-accent-2:  #a5b4fc;
                --sb-item-on:   rgba(129,140,248,0.2);
                --sb-width:     252px;

                --bg:           #f3f4f9;
                --bg-card:      #ffffff;
                --bg-topbar:    #ffffff;
                --border-light: #e8ecf5;
                --border-light2:#f0f2fb;
                --text-h:       #1e1b4b;
                --text-b:       #374151;
                --text-m:       #6b7280;
                --text-s:       #9ca3af;

                --primary:      #4f46e5;
                --primary-2:    #6366f1;
                --primary-light:#ede9fe;

                --purple:  #7c3aed;
                --blue:    #2563eb;
                --teal:    #0d9488;
                --green:   #16a34a;
                --red:     #dc2626;
                --amber:   #d97706;
                --orange:  #ea580c;
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
            .sb-logo{
                width:36px;
                height:36px;
                background:linear-gradient(135deg,#818cf8,#a78bfa);
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem;
                box-shadow:0 4px 12px rgba(129,140,248,0.4);
                flex-shrink:0;
            }
            .sb-name{
                color:#fff;
                font-size:1.05rem;
                font-weight:800;
                letter-spacing:-.3px
            }
            .sb-role{
                display:inline-flex;
                align-items:center;
                background:rgba(129,140,248,0.2);
                border:1px solid rgba(129,140,248,0.3);
                color:var(--sb-accent-2);
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
            }
            .sb-user:hover{
                background:rgba(129,140,248,0.18);
                border-color:rgba(129,140,248,0.3)
            }
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:linear-gradient(135deg,#818cf8,#a78bfa);
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
            .topbar-title{
                font-size:1.15rem;
                font-weight:800;
                color:var(--text-h);
                letter-spacing:-.3px
            }
            .topbar-sub{
                color:var(--text-s);
                font-size:.78rem;
                margin-top:2px
            }
            .topbar-badge{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:7px 14px;
                background:var(--primary-light);
                border:1px solid rgba(99,102,241,0.25);
                border-radius:20px;
                color:var(--primary-2);
                font-size:.78rem;
                font-weight:600;
            }
            .content{
                padding:24px 28px;
                flex:1
            }

            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(14px)
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

            /* ── TABS ── */
            .tabs{
                display:flex;
                gap:6px;
                margin-bottom:22px;
                flex-wrap:wrap;
            }
            .tab{
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:8px 16px;
                border-radius:10px;
                font-size:.81rem;
                font-weight:600;
                text-decoration:none;
                transition:all .18s;
                border:1.5px solid var(--border-light);
                background:var(--bg-card);
                color:var(--text-m);
                white-space:nowrap;
            }
            .tab:hover{
                color:var(--text-b);
                background:#f3f4f6;
                border-color:#d1d5db;
            }
            .tab .cnt{
                padding:2px 7px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700;
                background:var(--border-light2);
                color:var(--text-s);
            }

            .tab-all.active      {
                background:var(--primary-light);
                border-color:rgba(99,102,241,0.4);
                color:var(--primary-2);
            }
            .tab-all.active .cnt {
                background:rgba(99,102,241,0.2);
                color:var(--primary-2);
            }
            .tab-purchase.active      {
                background:#d1fae5;
                border-color:#a7f3d0;
                color:#065f46;
            }
            .tab-purchase.active .cnt {
                background:#bbf7d0;
                color:#065f46;
            }
            .tab-repair.active        {
                background:#fef3c7;
                border-color:#fde68a;
                color:var(--amber);
            }
            .tab-repair.active .cnt   {
                background:#fde68a;
                color:var(--amber);
            }
            .tab-import.active        {
                background:#ede9fe;
                border-color:#c4b5fd;
                color:var(--purple);
            }
            .tab-import.active .cnt   {
                background:#ddd6fe;
                color:var(--purple);
            }

            /* ── FILTER BAR ── */
            .filter-bar{
                background:var(--bg-card);
                border:1.5px solid var(--border-light);
                border-radius:14px;
                padding:14px 16px;
                margin-bottom:14px;
                display:flex;
                gap:10px;
                align-items:center;
                flex-wrap:wrap;
                animation:cardIn .4s ease both;
            }
            .filter-bar input,
            .filter-bar select{
                padding:8px 12px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:9px;
                color:var(--text-b);
                font-size:.82rem;
                font-family:inherit;
                outline:none;
                transition:all .2s;
            }
            .filter-bar input::placeholder{
                color:var(--text-s);
            }
            .filter-bar input:focus,
            .filter-bar select:focus{
                border-color:rgba(79,70,229,0.4);
                background:#faf9ff;
                box-shadow:0 0 0 3px rgba(79,70,229,0.07);
            }
            .filter-bar input[type="text"]{
                flex:1;
                min-width:200px;
            }
            .filter-bar select option{
                background:#fff;
                color:var(--text-b);
            }

            .btn{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:9px 16px;
                border-radius:10px;
                border:none;
                font-size:.82rem;
                font-weight:600;
                font-family:inherit;
                cursor:pointer;
                text-decoration:none;
                transition:all .2s;
                white-space:nowrap;
            }
            .btn-search{
                background:var(--primary-light);
                color:var(--primary-2);
                border:1.5px solid rgba(99,102,241,0.35);
            }
            .btn-search:hover{
                background:rgba(99,102,241,0.2);
                border-color:rgba(99,102,241,0.5);
            }
            .btn-reset{
                background:#fee2e2;
                color:var(--red);
                border:1.5px solid #fca5a5;
            }
            .btn-reset:hover{
                background:#fecaca;
            }

            /* Filter tags */
            .filter-tags{
                display:flex;
                align-items:center;
                gap:8px;
                flex-wrap:wrap;
                margin-bottom:14px;
            }
            .filter-tag{
                display:inline-flex;
                align-items:center;
                gap:6px;
                padding:4px 10px;
                border-radius:20px;
                background:var(--primary-light);
                border:1px solid rgba(99,102,241,0.25);
                color:var(--primary-2);
                font-size:.72rem;
                font-weight:600;
            }
            .filter-tags-lbl{
                font-size:.72rem;
                color:var(--text-s);
                font-weight:500;
            }

            /* ── CARD / TABLE ── */
            .card{
                background:var(--bg-card);
                border:1.5px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                animation:cardIn .5s .1s ease both;
            }
            .card-hd{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:13px 18px;
                border-bottom:1px solid var(--border-light2);
                background:#fafbff;
            }
            .card-title{
                font-size:.87rem;
                font-weight:700;
                color:var(--text-h);
                display:flex;
                align-items:center;
                gap:8px;
            }
            .card-title i{
                color:var(--primary-2);
            }
            .total-badge{
                font-size:.72rem;
                color:var(--text-s);
                background:var(--border-light2);
                border:1px solid var(--border-light);
                padding:3px 10px;
                border-radius:20px;
            }

            table{
                width:100%;
                border-collapse:collapse;
                font-size:.79rem;
            }
            thead tr{
                background:#fafbff;
            }
            th{
                padding:9px 14px;
                text-align:left;
                color:var(--text-s);
                font-weight:700;
                font-size:.64rem;
                text-transform:uppercase;
                letter-spacing:.9px;
                border-bottom:1px solid var(--border-light2);
            }
            td{
                padding:10px 14px;
                border-bottom:1px solid var(--border-light2);
                vertical-align:middle;
                color:var(--text-b);
            }
            tr:last-child td{
                border-bottom:none
            }
            tbody tr{
                transition:background .12s;
            }
            tbody tr:hover td{
                background:#f7f8ff;
            }

            /* badges */
            .b{
                display:inline-flex;
                align-items:center;
                gap:4px;
                padding:3px 9px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700;
                white-space:nowrap;
            }
            .b-purchase{
                background:#d1fae5;
                color:#065f46;
                border:1px solid #a7f3d0;
            }
            .b-repair  {
                background:#fef3c7;
                color:#92400e;
                border:1px solid #fde68a;
            }
            .b-import  {
                background:#ede9fe;
                color:#5b21b6;
                border:1px solid #c4b5fd;
            }
            .b-other   {
                background:var(--border-light2);
                color:var(--text-s);
                border:1px solid var(--border-light);
            }
            .b-part     {
                background:var(--primary-light);
                color:var(--primary-2);
                border:1px solid rgba(99,102,241,0.3);
            }
            .b-equipment{
                background:#e0f2fe;
                color:var(--info);
                border:1px solid #bae6fd;
            }

            .td-id      {
                color:var(--text-s);
                font-size:.75rem;
            }
            .td-item    {
                font-weight:700;
                color:var(--text-h);
                font-size:.82rem;
            }
            .td-serial  {
                font-family:'Courier New',monospace;
                font-size:.78rem;
                color:var(--primary-2);
                font-weight:600;
            }
            .td-customer{
                font-weight:600;
                color:var(--text-b);
                font-size:.8rem;
            }
            .td-order   {
                font-family:'Courier New',monospace;
                font-size:.75rem;
                color:var(--green);
                font-weight:700;
            }
            .td-ref     {
                font-family:'Courier New',monospace;
                font-size:.75rem;
                color:var(--amber);
                font-weight:700;
            }
            .td-by      {
                font-size:.78rem;
                color:var(--text-b);
            }
            .td-note    {
                color:var(--text-s);
                font-size:.75rem;
                max-width:160px;
                overflow:hidden;
                text-overflow:ellipsis;
                white-space:nowrap;
            }
            .td-time    {
                color:var(--text-s);
                font-size:.75rem;
                white-space:nowrap;
            }
            .td-dash    {
                color:var(--text-s);
            }

            /* pagination */
            .pagination{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:13px 18px;
                border-top:1px solid var(--border-light2);
            }
            .paging-info{
                color:var(--text-s);
                font-size:.75rem;
            }
            .page-btns{
                display:flex;
                gap:5px;
            }
            .page-btn{
                padding:6px 12px;
                border-radius:8px;
                background:var(--bg-card);
                border:1.5px solid var(--border-light);
                font-size:.78rem;
                color:var(--text-m);
                cursor:pointer;
                text-decoration:none;
                transition:all .18s;
                font-family:inherit;
            }
            .page-btn.active{
                background:var(--primary);
                border-color:var(--primary);
                color:#fff;
                font-weight:700;
            }
            .page-btn:hover:not(.active):not(.disabled){
                background:var(--primary-light);
                border-color:rgba(99,102,241,0.4);
                color:var(--primary-2);
            }
            .page-btn.disabled{
                opacity:.35;
                pointer-events:none;
            }

            .empty{
                text-align:center;
                padding:48px 24px;
                color:var(--text-s);
                font-size:.82rem;
            }
            .empty i{
                font-size:2.2rem;
                display:block;
                margin-bottom:12px;
                opacity:.2;
                color:var(--text-m);
            }
        </style>
    </head>
    <body>

        <!-- ═══════════ SIDEBAR ═══════════ -->
        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-warehouse"></i></div>
                <div><div class="sb-name">DRSMS</div><div class="sb-role">Storekeeper</div></div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/dashboard.jsp"   class="sb-item"><i class="fas fa-home"></i> Home</a>
                <a href="<%=ctx%>/storekeeper"     class="sb-item"><i class="fas fa-chart-bar"></i> Statistics</a>
                <div class="sb-lbl">Inventory</div>
                <a href="<%=ctx%>/numberPart"      class="sb-item"><i class="fas fa-puzzle-piece"></i> Parts List</a>
                <a href="<%=ctx%>/numberEquipment" class="sb-item"><i class="fas fa-desktop"></i> Equipment List</a>
                <div class="sb-lbl">Records</div>
                <a href="<%=ctx%>/transactions"    class="sb-item on"><i class="fas fa-history"></i> Transaction History</a>
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
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
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
                               placeholder="Search by item name, customer, order code…"
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
                            <i class="fas fa-filter-circle-xmark"></i> Reset
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
                    <span style="color:var(--text-s);font-size:.72rem;font-style:italic">None</span>
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