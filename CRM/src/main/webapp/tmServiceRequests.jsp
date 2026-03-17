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
        body{
            font-family:'Sora',sans-serif;
            background:var(--bg);
            color:var(--text-b);
            min-height:100vh;
            display:flex;
        }
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-track{background:transparent}
        ::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px}

        /* ═══════════ SIDEBAR ═══════════ */
        .sb{
            width:var(--sb-width);min-height:100vh;
            background:var(--sb-bg);
            border-right:1px solid rgba(79,70,229,0.2);
            display:flex;flex-direction:column;
            position:fixed;top:0;left:0;z-index:100;
            box-shadow:4px 0 24px rgba(0,0,0,0.15);
        }
        .sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border);}
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#818cf8,#a78bfa);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;box-shadow:0 4px 12px rgba(129,140,248,0.4);flex-shrink:0;}
        .sb-name{color:#fff;font-size:1.05rem;font-weight:800;letter-spacing:-.3px}
        /* Role badge — amber kept for Technical Manager identity */
        .sb-role{
            display:inline-flex;align-items:center;
            background:rgba(217,119,6,0.2);
            border:1px solid rgba(217,119,6,0.35);
            color:#fbbf24;
            font-size:.6rem;font-weight:700;
            letter-spacing:1px;text-transform:uppercase;
            padding:2px 8px;border-radius:20px;margin-top:3px;
        }
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
            padding:18px 28px;
            background:var(--bg-topbar);
            border-bottom:1px solid var(--border-light);
            position:sticky;top:0;z-index:50;
            box-shadow:0 1px 6px rgba(0,0,0,0.06);
        }
        .topbar-greeting{font-size:1.2rem;font-weight:800;color:var(--text-h);letter-spacing:-.3px}
        .topbar-sub{color:var(--text-s);font-size:.78rem;margin-top:2px}

        .content{padding:24px 28px;flex:1}

        /* Section label */
        .section-lbl{
            font-size:.63rem;font-weight:700;text-transform:uppercase;letter-spacing:2px;
            color:var(--primary-2);margin-bottom:13px;
            display:flex;align-items:center;gap:10px;
        }
        .section-lbl::after{content:'';flex:1;height:1px;background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)}

        /* ── ALERT ── */
        .alert{display:flex;align-items:center;gap:12px;padding:12px 18px;border-radius:12px;margin-bottom:20px;font-size:.82rem;animation:cardIn .5s ease both;}
        .alert-success{background:#d1fae5;border:1px solid #a7f3d0;color:#065f46}
        .alert-success i{color:var(--green)}
        .alert-error  {background:#fee2e2;border:1px solid #fca5a5;color:#991b1b}
        .alert-error i{color:var(--red)}

        /* ── STAT CARDS ── */
        .stats-grid{display:grid;grid-template-columns:repeat(6,1fr);gap:14px;margin-bottom:24px;}
        @keyframes cardIn{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}
        .sc{
            border-radius:16px;padding:18px 16px;
            position:relative;overflow:hidden;color:#fff;
            transition:all .22s;animation:cardIn .45s ease both;
        }
        .sc:nth-child(1){animation-delay:.04s}
        .sc:nth-child(2){animation-delay:.08s}
        .sc:nth-child(3){animation-delay:.12s}
        .sc:nth-child(4){animation-delay:.16s}
        .sc:nth-child(5){animation-delay:.20s}
        .sc:nth-child(6){animation-delay:.24s}
        .sc:hover{transform:translateY(-3px);box-shadow:0 12px 32px rgba(0,0,0,0.18)}

        .sc-total   {background:var(--blue);   box-shadow:0 4px 20px rgba(37,99,235,0.3)}
        .sc-pending {background:var(--amber);  box-shadow:0 4px 20px rgba(217,119,6,0.3)}
        .sc-approved{background:var(--info);   box-shadow:0 4px 20px rgba(2,132,199,0.3)}
        .sc-progress{background:var(--purple); box-shadow:0 4px 20px rgba(124,58,237,0.3)}
        .sc-done    {background:var(--green);  box-shadow:0 4px 20px rgba(22,163,74,0.3)}
        .sc-rejected{background:var(--red);    box-shadow:0 4px 20px rgba(220,38,38,0.3)}

        /* decorative circles */
        .sc::after {content:'';position:absolute;width:80px;height:80px;border-radius:50%;background:rgba(255,255,255,0.12);top:-20px;right:-20px;}
        .sc::before{content:'';position:absolute;width:50px;height:50px;border-radius:50%;background:rgba(255,255,255,0.07);bottom:-10px;right:20px;}

        .sc-icon{width:34px;height:34px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.82rem;margin-bottom:10px;background:rgba(255,255,255,0.2);position:relative;z-index:1;}
        .sc-val{font-size:1.75rem;font-weight:800;line-height:1;letter-spacing:-1px;position:relative;z-index:1}
        .sc-lbl{font-size:.72rem;font-weight:600;opacity:.88;margin-top:4px;position:relative;z-index:1}

        /* ── FILTER BAR ── */
        .filter-bar{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:14px;padding:14px 16px;
            display:flex;flex-wrap:wrap;gap:10px;align-items:center;
            margin-bottom:18px;
            box-shadow:0 1px 4px rgba(0,0,0,0.04);
            animation:cardIn .5s .1s ease both;
        }
        .filter-bar input,
        .filter-bar select{
            padding:9px 13px;
            border:1.5px solid var(--border-light);
            border-radius:9px;
            font-size:.81rem;font-family:'Sora',sans-serif;
            color:var(--text-b);background:#fff;
            outline:none;transition:all .2s;
        }
        .filter-bar input::placeholder{color:var(--text-s)}
        .filter-bar input:focus,
        .filter-bar select:focus{
            border-color:rgba(79,70,229,0.4);
            background:#faf9ff;
            box-shadow:0 0 0 3px rgba(79,70,229,0.07);
            color:var(--text-h);
        }
        .filter-bar select option{background:#fff;color:var(--text-b)}

        /* ── BUTTONS ── */
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 18px;border-radius:10px;font-size:.81rem;font-weight:600;font-family:'Sora',sans-serif;cursor:pointer;border:none;text-decoration:none;transition:all .2s;}
        .btn-primary{background:var(--primary);color:#fff;box-shadow:0 3px 10px rgba(79,70,229,0.28);}
        .btn-primary:hover{background:#4338ca;transform:translateY(-1px);box-shadow:0 6px 18px rgba(79,70,229,0.4)}
        .btn-secondary{background:#fff;color:var(--text-m);border:1.5px solid var(--border-light);}
        .btn-secondary:hover{background:#f3f4f6;border-color:#d1d5db;color:var(--text-b)}
        .btn-sm{padding:6px 13px;font-size:.75rem;}

        /* ── TABLE WRAP ── */
        .table-wrap{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:16px;overflow:hidden;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
            animation:cardIn .5s .2s ease both;
        }
        table{width:100%;border-collapse:collapse;font-size:.8rem}
        thead tr{background:#fafbff}
        th{padding:10px 16px;text-align:left;color:var(--text-s);font-weight:700;font-size:.67rem;text-transform:uppercase;letter-spacing:.8px;border-bottom:1px solid var(--border-light2);}
        td{padding:12px 16px;border-bottom:1px solid var(--border-light2);vertical-align:middle;color:var(--text-b);}
        tr:last-child td{border-bottom:none}
        tbody tr{transition:background .12s}
        tbody tr:hover td{background:#f7f8ff}

        /* ── BADGES ── */
        .b{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;white-space:nowrap;}
        .b-pending    {background:#fef3c7;color:#92400e}
        .b-approved   {background:#d1fae5;color:#065f46}
        .b-rejected   {background:#fee2e2;color:#991b1b}
        .b-in_progress,
        .b-in-progress{background:#dbeafe;color:#1e40af}
        .b-completed  {background:#ede9fe;color:#5b21b6}
        .b-cancelled  {background:#f3f4f6;color:#6b7280}
        .b-low        {background:#dcfce7;color:#166534}
        .b-medium     {background:#fef3c7;color:#92400e}
        .b-high       {background:#ffedd5;color:#9a3412}
        .b-urgent     {background:#fee2e2;color:#991b1b}

        /* Contract type mini */
        .ct-badge{display:inline-block;padding:2px 7px;border-radius:5px;font-size:.67rem;font-weight:700;}
        .ct-wr{background:#d1fae5;color:#065f46}
        .ct-mt{background:#dbeafe;color:#1e40af}

        /* Code link */
        .code-link{color:var(--primary-2);font-weight:700;font-size:.77rem;font-family:'Courier New',monospace;text-decoration:none;letter-spacing:-.3px;}
        .code-link:hover{color:var(--primary);text-decoration:underline}

        .td-muted{color:var(--text-s);font-size:.75rem}
        .td-bold {font-weight:600;color:var(--text-h)}
        .td-empty{text-align:center;padding:40px 16px;color:var(--text-s);font-size:.82rem}
        .td-empty i{font-size:2rem;display:block;margin-bottom:10px;opacity:.2;color:var(--text-m)}

        /* ── PAGINATION ── */
        .pagination{display:flex;justify-content:flex-end;align-items:center;gap:5px;padding:13px 16px;border-top:1px solid var(--border-light2);}
        .pagination a,
        .pagination span{padding:6px 12px;border-radius:8px;font-size:.77rem;font-weight:500;text-decoration:none;color:var(--text-m);border:1.5px solid var(--border-light);background:#fff;transition:all .15s;}
        .pagination a:hover{background:var(--primary-light);border-color:rgba(99,102,241,0.3);color:var(--primary-2)}
        .pagination .active{background:var(--primary);color:#fff;border-color:transparent;box-shadow:0 3px 8px rgba(79,70,229,0.3);}
        .pagination .dots{border:none;background:none;color:var(--text-s);cursor:default}
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
                    <i class="fas fa-clipboard-list" style="color:var(--primary-2);margin-right:8px;font-size:1rem"></i>Service Requests
                </div>
                <div class="topbar-sub">Review, approve/reject and assign technicians to service requests</div>
            </div>
        </div>

        <div class="content">

            <%-- Flash messages --%>
            <%if(flashOk!=null){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=flashOk%></div>
            <%}%>
            <%if(flashErr!=null){%>
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div>
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
                        if("APPROVED".equals(sr.getStatus()))         bSt="b-approved";
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
                        <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--text-m)">
                            <%=sr.getTitle()%>
                        </td>
                        <td>
                            <div style="font-size:.77rem;font-weight:600;color:var(--text-h)"><%=sr.getContractCode()%></div>
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
