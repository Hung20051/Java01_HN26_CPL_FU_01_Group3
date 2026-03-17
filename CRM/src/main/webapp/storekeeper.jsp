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
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Warehouse Statistics – DRSMS</title>
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

            /* Status / accent colors */
            --purple:  #7c3aed;
            --blue:    #2563eb;
            --teal:    #0d9488;
            --green:   #16a34a;
            --red:     #dc2626;
            --amber:   #d97706;
            --orange:  #ea580c;
            --info:    #0284c7;
        }

        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{scroll-behavior:smooth}
        body{font-family:'Sora',sans-serif;background:var(--bg);color:var(--text-b);min-height:100vh;display:flex;}
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-track{background:transparent}
        ::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px}

        /* ═══════════ SIDEBAR ═══════════ */
        .sb{width:var(--sb-width);min-height:100vh;background:var(--sb-bg);border-right:1px solid rgba(79,70,229,0.2);display:flex;flex-direction:column;position:fixed;top:0;left:0;z-index:100;box-shadow:4px 0 24px rgba(0,0,0,0.15);}
        .sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border);}
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#818cf8,#a78bfa);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;box-shadow:0 4px 12px rgba(129,140,248,0.4);flex-shrink:0;}
        .sb-name{color:#fff;font-size:1.05rem;font-weight:800;letter-spacing:-.3px}
        .sb-role{display:inline-flex;align-items:center;background:rgba(129,140,248,0.2);border:1px solid rgba(129,140,248,0.3);color:var(--sb-accent-2);font-size:.6rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:2px 8px;border-radius:20px;margin-top:3px;}
        .sb-nav{flex:1;padding:12px 10px;overflow-y:auto}
        .sb-lbl{color:rgba(255,255,255,0.22);font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:1.6px;padding:0 8px;margin:14px 0 5px;}
        .sb-item{display:flex;align-items:center;gap:9px;padding:8px 10px;border-radius:9px;margin-bottom:1px;color:var(--sb-text);text-decoration:none;font-size:.81rem;font-weight:500;transition:all .18s;border-left:2px solid transparent;}
        .sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.78rem;border-radius:8px;background:rgba(255,255,255,0.06);flex-shrink:0;transition:all .18s;}
        .sb-item.on{color:#fff;background:var(--sb-item-on);border-left-color:var(--sb-accent);}
        .sb-item.on i{background:rgba(129,140,248,0.3);color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){color:rgba(255,255,255,0.78);background:rgba(255,255,255,0.06);}
        .sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border)}
        .sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);margin-bottom:5px;text-decoration:none;transition:all .18s;cursor:pointer;}
        .sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3)}
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.8rem;font-weight:600}
        .sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem;margin-top:1px}
        .sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
        .sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1)}

        /* ═══════════ MAIN (light) ═══════════ */
        .main{margin-left:var(--sb-width);flex:1;display:flex;flex-direction:column;min-height:100vh}

        .topbar{
            display:flex;justify-content:space-between;align-items:center;
            padding:18px 28px;background:var(--bg-topbar);
            border-bottom:1px solid var(--border-light);
            position:sticky;top:0;z-index:50;
            box-shadow:0 1px 6px rgba(0,0,0,0.06);
        }
        .topbar-greeting{font-size:1.2rem;font-weight:800;color:var(--text-h);letter-spacing:-.3px;display:flex;align-items:center;gap:8px;}
        .topbar-greeting i{color:var(--primary-2);font-size:1rem}
        .topbar-sub{color:var(--text-s);font-size:.78rem;margin-top:2px}
        .topbar-badge{
            display:inline-flex;align-items:center;gap:7px;
            padding:8px 16px;background:#fff;
            border:1.5px solid var(--border-light);border-radius:20px;
            color:var(--text-m);font-size:.8rem;font-weight:600;
        }
        .topbar-badge i{color:var(--primary-2)}

        .content{padding:24px 28px;flex:1}

        /* Alert */
        @keyframes cardIn{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}
        .alert-warn{
            display:flex;align-items:center;gap:12px;
            padding:13px 18px;background:#fffbeb;
            border:1.5px solid #fde68a;border-radius:12px;
            margin-bottom:22px;font-size:.84rem;color:var(--text-b);
            animation:cardIn .4s ease both;
        }
        .alert-warn i{color:var(--amber);font-size:1rem;flex-shrink:0}
        .alert-warn a{color:var(--amber);font-weight:700;text-decoration:none;margin-left:6px}
        .alert-warn a:hover{color:#92400e}

        /* Section label */
        .section-lbl{
            font-size:.63rem;font-weight:700;text-transform:uppercase;letter-spacing:2px;
            color:var(--primary-2);margin-bottom:13px;
            display:flex;align-items:center;gap:10px;
        }
        .section-lbl::after{content:'';flex:1;height:1px;background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)}

        /* ── STAT CARDS ── */
        .stats{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:26px;}
        .sc{
            border-radius:16px;padding:20px;
            position:relative;overflow:hidden;color:#fff;
            transition:all .22s;animation:cardIn .45s ease both;
        }
        .sc:nth-child(1){animation-delay:.04s} .sc:nth-child(2){animation-delay:.08s}
        .sc:nth-child(3){animation-delay:.12s} .sc:nth-child(4){animation-delay:.16s}
        .sc:nth-child(5){animation-delay:.20s} .sc:nth-child(6){animation-delay:.24s}
        .sc:nth-child(7){animation-delay:.28s} .sc:nth-child(8){animation-delay:.32s}
        .sc:hover{transform:translateY(-3px);box-shadow:0 12px 32px rgba(0,0,0,0.18)}

        /* decorative circles */
        .sc::after {content:'';position:absolute;width:80px;height:80px;border-radius:50%;background:rgba(255,255,255,0.12);top:-20px;right:-20px;}
        .sc::before{content:'';position:absolute;width:50px;height:50px;border-radius:50%;background:rgba(255,255,255,0.07);bottom:-10px;right:20px;}

        .sc-blue  {background:var(--blue);  box-shadow:0 4px 20px rgba(37,99,235,0.3)}
        .sc-green {background:var(--green); box-shadow:0 4px 20px rgba(22,163,74,0.3)}
        .sc-amber {background:var(--amber); box-shadow:0 4px 20px rgba(217,119,6,0.3)}
        .sc-red   {background:var(--red);   box-shadow:0 4px 20px rgba(220,38,38,0.3)}
        .sc-purple{background:var(--purple);box-shadow:0 4px 20px rgba(124,58,237,0.3)}
        .sc-info  {background:var(--info);  box-shadow:0 4px 20px rgba(2,132,199,0.3)}
        .sc-teal  {background:var(--teal);  box-shadow:0 4px 20px rgba(13,148,136,0.3)}

        .sc-icon{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:.9rem;margin-bottom:12px;background:rgba(255,255,255,0.2);position:relative;z-index:1;}
        .sc-val{font-size:1.9rem;font-weight:800;color:#fff;line-height:1;letter-spacing:-1px;position:relative;z-index:1}
        .sc-lbl{color:rgba(255,255,255,0.88);font-size:.76rem;font-weight:600;margin-top:5px;position:relative;z-index:1}
        .sc-sub{font-size:.7rem;opacity:.7;margin-top:4px;position:relative;z-index:1}

        /* ── GRID 2 ── */
        .grid-2{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-bottom:22px;}

        /* ── CARD ── */
        .card{background:var(--bg-card);border:1px solid var(--border-light);border-radius:16px;overflow:hidden;box-shadow:0 1px 6px rgba(0,0,0,0.05);animation:cardIn .45s .25s ease both;}
        .card-hd{display:flex;justify-content:space-between;align-items:center;padding:14px 18px;border-bottom:1px solid var(--border-light2);background:#fafbff;}
        .card-title{font-size:.87rem;font-weight:700;color:var(--text-h);display:flex;align-items:center;gap:8px;}
        .card-title i{color:var(--primary-2);font-size:.82rem}
        .card-link{font-size:.75rem;font-weight:700;color:var(--primary-2);text-decoration:none;transition:color .18s}
        .card-link:hover{color:var(--primary)}

        /* ── DONUT ── */
        .donut-wrap{display:flex;align-items:center;justify-content:center;gap:28px;padding:24px 20px;}
        .donut-ring{position:relative;width:140px;height:140px;flex-shrink:0;}
        .donut-ring svg{transform:rotate(-90deg);}
        .donut-center{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;}
        .donut-center-val{font-size:1.5rem;font-weight:800;color:var(--text-h);line-height:1;}
        .donut-center-lbl{font-size:.62rem;color:var(--text-s);margin-top:2px;font-weight:500;letter-spacing:.5px;text-transform:uppercase;}
        .donut-legend{display:flex;flex-direction:column;gap:10px;}
        .legend-item{display:flex;align-items:center;gap:10px;font-size:.8rem;color:var(--text-b);}
        .legend-dot{width:9px;height:9px;border-radius:50%;flex-shrink:0;}
        .legend-count{margin-left:auto;padding-left:20px;font-weight:700;color:var(--text-h);font-size:.82rem;}

        /* ── EQUIPMENT MINI STATS ── */
        .eq-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;padding:16px;}
        .eq-card{border-radius:12px;padding:16px;border:1.5px solid var(--border-light);background:#fafbff;transition:all .2s;}
        .eq-card:hover{background:var(--primary-light);border-color:rgba(99,102,241,0.25);transform:translateY(-1px);}
        .eq-icon{width:34px;height:34px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.82rem;margin-bottom:10px;}
        .eq-card.g .eq-icon{background:#dcfce7;color:var(--green);}
        .eq-card.b .eq-icon{background:var(--primary-light);color:var(--primary-2);}
        .eq-card.r .eq-icon{background:#fee2e2;color:var(--red);}
        .eq-card.a .eq-icon{background:#fef3c7;color:var(--amber);}
        .eq-val{font-size:1.6rem;font-weight:800;color:var(--text-h);line-height:1;}
        .eq-lbl{font-size:.72rem;color:var(--text-s);margin-top:4px;}

        /* ── TABLE ── */
        table{width:100%;border-collapse:collapse;font-size:.8rem}
        thead tr{background:#fafbff}
        th{padding:10px 16px;text-align:left;color:var(--text-s);font-weight:700;font-size:.67rem;text-transform:uppercase;letter-spacing:.8px;border-bottom:1px solid var(--border-light2);}
        td{padding:12px 16px;border-bottom:1px solid var(--border-light2);vertical-align:middle;color:var(--text-b);}
        tr:last-child td{border-bottom:none}
        tbody tr{transition:background .12s}
        tbody tr:hover td{background:#f7f8ff}
        .td-muted{color:var(--text-s);font-size:.75rem}

        /* Badges */
        .b{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;white-space:nowrap;}
        .b-avail  {background:#d1fae5;color:#065f46}
        .b-inuse  {background:#dbeafe;color:#1e40af}
        .b-faulty {background:#fef3c7;color:#92400e}
        .b-retired{background:#f3f4f6;color:#6b7280}
        .b-low    {background:#fee2e2;color:#991b1b}

        /* Rank */
        .rank{width:22px;height:22px;border-radius:6px;display:inline-flex;align-items:center;justify-content:center;font-size:.68rem;font-weight:700;background:var(--primary-light);color:var(--primary-2);}

        /* Empty */
        .empty{text-align:center;padding:32px 24px;color:var(--text-s);font-size:.82rem}
        .empty i{font-size:2rem;display:block;margin-bottom:10px;opacity:.2;color:var(--text-m)}
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
            <a href="<%=ctx%>/dashboard.jsp" class="sb-item">
                <i class="fas fa-home"></i> Home
            </a>
            <a href="<%=ctx%>/storekeeper" class="sb-item on">
                <i class="fas fa-chart-bar"></i> Statistics
            </a>
            <div class="sb-lbl">Inventory</div>
            <a href="<%=ctx%>/numberPart" class="sb-item">
                <i class="fas fa-puzzle-piece"></i> Parts List
            </a>
            <a href="<%=ctx%>/numberEquipment" class="sb-item">
                <i class="fas fa-desktop"></i> Equipment List
            </a>
            <div class="sb-lbl">Records</div>
            <a href="<%=ctx%>/transactions" class="sb-item">
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
                <div class="topbar-greeting">
                    <i class="fas fa-chart-bar"></i> Warehouse Statistics
                </div>
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
                    <strong><%=lowStock%> part type(s)</strong> are running low on stock.
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
                    <div class="sc-sub"><%=totalPartUnits%> total units</div>
                </div>
                <div class="sc sc-green">
                    <div class="sc-icon"><i class="fas fa-box-open"></i></div>
                    <div class="sc-val"><%=availableUnits%></div>
                    <div class="sc-lbl">Available Units</div>
                    <div class="sc-sub"><%=String.format("%.1f", pctAvailable)%>% of stock</div>
                </div>
                <div class="sc sc-amber">
                    <div class="sc-icon"><i class="fas fa-triangle-exclamation"></i></div>
                    <div class="sc-val"><%=lowStock%></div>
                    <div class="sc-lbl">Low Stock Types</div>
                    <div class="sc-sub">Needs reorder</div>
                </div>
                <div class="sc sc-red">
                    <div class="sc-icon"><i class="fas fa-circle-xmark"></i></div>
                    <div class="sc-val"><%=faultyUnits%></div>
                    <div class="sc-lbl">Faulty Units</div>
                    <div class="sc-sub">Requires inspection</div>
                </div>
                <div class="sc sc-purple">
                    <div class="sc-icon"><i class="fas fa-screwdriver-wrench"></i></div>
                    <div class="sc-val"><%=inuseUnits%></div>
                    <div class="sc-lbl">Units In Use</div>
                    <div class="sc-sub">Currently deployed</div>
                </div>
                <div class="sc sc-info">
                    <div class="sc-icon"><i class="fas fa-archive"></i></div>
                    <div class="sc-val"><%=retiredUnits%></div>
                    <div class="sc-lbl">Retired Units</div>
                    <div class="sc-sub"><%=String.format("%.1f", pctRetired)%>% of stock</div>
                </div>
                <div class="sc sc-teal">
                    <div class="sc-icon"><i class="fas fa-percent"></i></div>
                    <div class="sc-val"><%=String.format("%.0f", pctAvailable)%><span style="font-size:1.1rem">%</span></div>
                    <div class="sc-lbl">Availability Rate</div>
                    <div class="sc-sub">Parts health</div>
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
                            String[] colors = {"#16a34a","#2563eb","#d97706","#dc2626"};
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
                                <circle cx="70" cy="70" r="52" fill="none" stroke="var(--border-light)" stroke-width="16"/>
                                <%=svgPaths.toString()%>
                            </svg>
                            <div class="donut-center">
                                <div class="donut-center-val"><%=totalPartUnits%></div>
                                <div class="donut-center-lbl">Total</div>
                            </div>
                        </div>
                        <div class="donut-legend">
                            <div class="legend-item">
                                <span class="legend-dot" style="background:#16a34a"></span>
                                Available
                                <span class="legend-count"><%=availableUnits%></span>
                            </div>
                            <div class="legend-item">
                                <span class="legend-dot" style="background:#2563eb"></span>
                                In Use
                                <span class="legend-count"><%=inuseUnits%></span>
                            </div>
                            <div class="legend-item">
                                <span class="legend-dot" style="background:#d97706"></span>
                                Faulty
                                <span class="legend-count"><%=faultyUnits%></span>
                            </div>
                            <div class="legend-item">
                                <span class="legend-dot" style="background:#dc2626"></span>
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
                            <div class="eq-val"><%=inuseEq%> <span style="font-size:1rem;color:var(--text-s)">/</span> <%=faultyEq%></div>
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
                        <div class="card-title">
                            <i class="fas fa-triangle-exclamation" style="color:var(--amber)"></i> Low Stock Parts
                        </div>
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
                            <tr><th>#</th><th>Part Name</th><th>Category</th><th>Qty</th></tr>
                        </thead>
                        <tbody>
                        <%int rowIdx=0; for(PartType pt : lowStockList){ rowIdx++; %>
                        <tr>
                            <td><span class="rank"><%=rowIdx%></span></td>
                            <td style="font-weight:600;color:var(--text-h)"><%=pt.getName()%></td>
                            <td class="td-muted"><%=pt.getCategoryName()%></td>
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
                        <div class="card-title">
                            <i class="fas fa-fire" style="color:var(--orange)"></i> Most Used Parts
                        </div>
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
                            <tr><th>#</th><th>Part Name</th><th>Category</th><th>In Use</th></tr>
                        </thead>
                        <tbody>
                        <%int rowIdx2=0; for(PartType pt : mostUsedList){ rowIdx2++; %>
                        <tr>
                            <td><span class="rank"><%=rowIdx2%></span></td>
                            <td style="font-weight:600;color:var(--text-h)"><%=pt.getName()%></td>
                            <td class="td-muted"><%=pt.getCategoryName()%></td>
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
