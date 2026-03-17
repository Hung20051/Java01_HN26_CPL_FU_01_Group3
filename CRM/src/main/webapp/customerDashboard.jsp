<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*,java.math.BigDecimal" %>
<%
    User me = (User) session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    long   activeContracts = request.getAttribute("activeContracts")!=null?(Long)request.getAttribute("activeContracts"):0;
    int    totalContracts  = request.getAttribute("totalContracts") !=null?(Integer)request.getAttribute("totalContracts"):0;
    int    totalSR         = request.getAttribute("totalSR")        !=null?(Integer)request.getAttribute("totalSR"):0;
    int    pendingSR       = request.getAttribute("pendingSR")      !=null?(Integer)request.getAttribute("pendingSR"):0;
    int    activeSR        = request.getAttribute("activeSR")       !=null?(Integer)request.getAttribute("activeSR"):0;
    int    completedSR     = request.getAttribute("completedSR")    !=null?(Integer)request.getAttribute("completedSR"):0;
    int    unreadChat      = request.getAttribute("unreadChat")     !=null?(Integer)request.getAttribute("unreadChat"):0;
    Map<String,Object> inv = (Map<String,Object>) request.getAttribute("invSummary");
    List<ServiceRequest> recent = (List<ServiceRequest>) request.getAttribute("recentSR");
    if(recent==null) recent=new ArrayList<>();
    int unpaidInv = inv!=null&&inv.get("unpaid")!=null?(Integer)inv.get("unpaid"):0;
    BigDecimal unpaidAmt = inv!=null?(BigDecimal)inv.get("unpaidAmt"):null;
    String ctx = request.getContextPath();
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
    Map<?,?> shopCart = (Map<?,?>) session.getAttribute("shopCart");
    int cartCount = shopCart != null ? shopCart.size() : 0;
    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Dashboard - DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            /* Sidebar (dark indigo) */
            --sb-bg:        #1e1b4b;
            --sb-bg-2:      #17144a;
            --sb-border:    rgba(255,255,255,0.08);
            --sb-text:      rgba(255,255,255,0.45);
            --sb-text-on:   #ffffff;
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
            --purple:  #7c3aed;
            --blue:    #2563eb;
            --teal:    #0d9488;
            --green:   #16a34a;
            --red:     #dc2626;
            --amber:   #d97706;
            --orange:  #ea580c;
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

        /* ═══════════ SIDEBAR (dark) ═══════════ */
        .sb{
            width:var(--sb-width);
            min-height:100vh;
            background:var(--sb-bg);
            border-right:1px solid rgba(79,70,229,0.2);
            display:flex; flex-direction:column;
            position:fixed; top:0; left:0; z-index:100;
            box-shadow:4px 0 24px rgba(0,0,0,0.15);
        }
        .sb-brand{
            padding:20px 16px 16px;
            display:flex; align-items:center; gap:10px;
            border-bottom:1px solid var(--sb-border);
        }
        .sb-logo{
            width:36px; height:36px;
            background:linear-gradient(135deg,#818cf8,#a78bfa);
            border-radius:10px;
            display:flex; align-items:center; justify-content:center;
            color:#fff; font-size:.9rem;
            box-shadow:0 4px 12px rgba(129,140,248,0.4);
            flex-shrink:0;
        }
        .sb-name{color:#fff; font-size:1.05rem; font-weight:800; letter-spacing:-.3px}
        .sb-role{
            display:inline-flex; align-items:center;
            background:rgba(129,140,248,0.2);
            border:1px solid rgba(129,140,248,0.3);
            color:var(--sb-accent-2);
            font-size:.6rem; font-weight:700;
            letter-spacing:1px; text-transform:uppercase;
            padding:2px 8px; border-radius:20px; margin-top:3px;
        }

        .sb-nav{flex:1; padding:12px 10px; overflow-y:auto}
        .sb-lbl{
            color:rgba(255,255,255,0.22);
            font-size:.6rem; font-weight:700;
            text-transform:uppercase; letter-spacing:1.6px;
            padding:0 8px; margin:14px 0 5px;
        }
        .sb-item{
            display:flex; align-items:center; gap:9px;
            padding:8px 10px; border-radius:9px;
            margin-bottom:1px;
            color:var(--sb-text);
            text-decoration:none;
            font-size:.81rem; font-weight:500;
            transition:all .18s;
            border-left:2px solid transparent;
        }
        .sb-item i{
            width:28px; height:28px;
            display:flex; align-items:center; justify-content:center;
            font-size:.78rem; border-radius:8px;
            background:rgba(255,255,255,0.06);
            flex-shrink:0; transition:all .18s;
        }
        .sb-item.on{
            color:#fff;
            background:var(--sb-item-on);
            border-left-color:var(--sb-accent);
        }
        .sb-item.on i{background:rgba(129,140,248,0.3); color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){
            color:rgba(255,255,255,0.78);
            background:rgba(255,255,255,0.06);
        }

        .sb-badge{
            margin-left:auto;
            background:#ef4444;
            color:#fff; font-size:.6rem; font-weight:700;
            padding:2px 7px; border-radius:20px;
            box-shadow:0 2px 6px rgba(239,68,68,0.5);
        }

        .sb-foot{padding:12px 10px 14px; border-top:1px solid var(--sb-border)}
        .sb-user{
            display:flex; align-items:center; gap:9px;
            padding:9px 10px; border-radius:10px;
            background:rgba(255,255,255,0.07);
            border:1px solid rgba(255,255,255,0.1);
            margin-bottom:5px; text-decoration:none; transition:all .18s;
        }
        .sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3)}
        .sb-ava{
            width:34px; height:34px; border-radius:50%;
            background:linear-gradient(135deg,#818cf8,#a78bfa);
            display:flex; align-items:center; justify-content:center;
            color:#fff; font-size:.88rem; font-weight:700;
            flex-shrink:0; overflow:hidden;
        }
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff; font-size:.8rem; font-weight:600}
        .sb-urole{color:rgba(255,255,255,0.35); font-size:.66rem; margin-top:1px}
        .sb-logout{
            display:flex; align-items:center; gap:8px;
            width:100%; padding:8px 10px; border-radius:9px;
            color:rgba(255,255,255,0.3); text-decoration:none;
            font-size:.78rem; transition:all .18s;
        }
        .sb-logout:hover{color:#fca5a5; background:rgba(239,68,68,0.1)}

        /* ═══════════ MAIN (light) ═══════════ */
        .main{margin-left:var(--sb-width);flex:1;min-height:100vh;display:flex;flex-direction:column}

        .topbar{
            display:flex; justify-content:space-between; align-items:center;
            padding:18px 28px;
            background:var(--bg-topbar);
            border-bottom:1px solid var(--border-light);
            position:sticky; top:0; z-index:50;
            box-shadow:0 1px 6px rgba(0,0,0,0.06);
        }
        .topbar-greeting{font-size:1.2rem; font-weight:800; color:var(--text-h); letter-spacing:-.3px}
        .topbar-sub{color:var(--text-s); font-size:.78rem; margin-top:2px}

        .btn-cta{
            display:inline-flex; align-items:center; gap:8px;
            padding:10px 22px;
            background:var(--primary);
            color:#fff; text-decoration:none;
            font-size:.82rem; font-weight:700;
            border-radius:11px;
            box-shadow:0 4px 14px rgba(79,70,229,0.35);
            transition:all .22s;
        }
        .btn-cta:hover{background:#4338ca;transform:translateY(-1px);box-shadow:0 8px 22px rgba(79,70,229,0.45)}

        .content{padding:24px 28px; flex:1}

        /* Alert */
        .alert-warn{
            display:flex; align-items:center; gap:12px;
            padding:12px 18px;
            background:#fffbeb;
            border:1.5px solid #fcd34d;
            border-radius:12px;
            margin-bottom:22px;
            font-size:.82rem; color:#78350f;
        }
        .alert-warn i{color:#f59e0b; font-size:1rem; flex-shrink:0}
        .alert-warn a{color:#d97706; font-weight:700; text-decoration:none; margin-left:4px}
        .alert-warn a:hover{color:#92400e}

        /* Section label */
        .section-lbl{
            font-size:.63rem; font-weight:700;
            text-transform:uppercase; letter-spacing:2px;
            color:var(--primary-2); margin-bottom:13px;
            display:flex; align-items:center; gap:10px;
        }
        .section-lbl::after{content:'';flex:1;height:1px;background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)}

        /* ── STAT CARDS ── */
        .stats{
            display:grid;
            grid-template-columns:repeat(4,1fr);
            gap:14px;
            margin-bottom:24px;
        }
        .sc{
            border-radius:16px; padding:20px;
            position:relative; overflow:hidden;
            color:#fff;
            transition:all .22s;
            animation:cardIn .45s ease both;
            cursor:default;
        }
        .sc:nth-child(1){animation-delay:.04s}
        .sc:nth-child(2){animation-delay:.09s}
        .sc:nth-child(3){animation-delay:.14s}
        .sc:nth-child(4){animation-delay:.19s}
        @keyframes cardIn{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}
        .sc:hover{transform:translateY(-3px); box-shadow:0 12px 32px rgba(0,0,0,0.18)}

        .sc-purple{background:var(--purple); box-shadow:0 4px 20px rgba(124,58,237,0.3)}
        .sc-blue  {background:var(--blue);   box-shadow:0 4px 20px rgba(37,99,235,0.3)}
        .sc-teal  {background:var(--teal);   box-shadow:0 4px 20px rgba(13,148,136,0.3)}
        .sc-red   {background:var(--red);    box-shadow:0 4px 20px rgba(220,38,38,0.3)}
        .sc-green {background:var(--green);  box-shadow:0 4px 20px rgba(22,163,74,0.3)}

        /* Decorative circle */
        .sc::after{
            content:''; position:absolute;
            width:100px; height:100px; border-radius:50%;
            background:rgba(255,255,255,0.12);
            top:-28px; right:-28px;
        }
        .sc::before{
            content:''; position:absolute;
            width:60px; height:60px; border-radius:50%;
            background:rgba(255,255,255,0.07);
            bottom:-14px; right:28px;
        }

        .sc-icon{
            width:40px; height:40px; border-radius:11px;
            background:rgba(255,255,255,0.2);
            display:flex; align-items:center; justify-content:center;
            font-size:1rem; margin-bottom:14px;
            position:relative; z-index:1;
        }
        .sc-val{
            font-size:2.2rem; font-weight:800; line-height:1;
            letter-spacing:-1.5px;
            position:relative; z-index:1;
        }
        .sc-lbl{font-size:.76rem; font-weight:600; opacity:.88; margin-top:5px; position:relative; z-index:1}
        .sc-sub{font-size:.7rem; opacity:.6; margin-top:4px; position:relative; z-index:1}

        /* ── LAYOUT ── */
        .grid-2{display:grid; grid-template-columns:3fr 2fr; gap:18px}

        /* ── CARD ── */
        .card{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:16px;
            overflow:hidden;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
            animation:cardIn .45s .22s ease both;
        }
        .card-hd{
            display:flex; justify-content:space-between; align-items:center;
            padding:14px 18px;
            border-bottom:1px solid var(--border-light2);
            background:#fafbff;
        }
        .card-title{
            font-size:.85rem; font-weight:700; color:var(--text-h);
            display:flex; align-items:center; gap:8px;
        }
        .card-title i{color:var(--primary-2); font-size:.8rem}
        .card-link{font-size:.74rem; font-weight:700; color:var(--primary-2); text-decoration:none; transition:color .18s}
        .card-link:hover{color:var(--primary)}

        /* ── TABLE ── */
        table{width:100%; border-collapse:collapse; font-size:.79rem}
        thead tr{background:#fafbff}
        th{
            padding:9px 16px;
            text-align:left;
            color:var(--text-s); font-weight:700;
            font-size:.64rem; text-transform:uppercase; letter-spacing:.9px;
            border-bottom:1px solid var(--border-light2);
        }
        td{
            padding:11px 16px;
            border-bottom:1px solid var(--border-light2);
            vertical-align:middle;
            color:var(--text-b);
        }
        tr:last-child td{border-bottom:none}
        tbody tr{transition:background .12s}
        tbody tr:hover td{background:#f7f8ff}

        /* ── BADGES ── */
        .b{
            display:inline-flex; align-items:center;
            padding:3px 9px; border-radius:20px;
            font-size:.68rem; font-weight:700; white-space:nowrap;
        }
        .b-pending   {background:#fef3c7; color:#92400e}
        .b-approved  {background:#d1fae5; color:#065f46}
        .b-rejected  {background:#fee2e2; color:#991b1b}
        .b-inprogress{background:#dbeafe; color:#1e40af}
        .b-completed {background:#ede9fe; color:#5b21b6}
        .b-cancelled {background:#f3f4f6; color:#6b7280}
        .b-low       {background:#dcfce7; color:#166534}
        .b-medium    {background:#fef3c7; color:#92400e}
        .b-high      {background:#ffedd5; color:#9a3412}
        .b-urgent    {background:#fee2e2; color:#991b1b}

        .ct-badge{display:inline-flex;align-items:center;padding:2px 7px;border-radius:5px;font-size:.66rem;font-weight:700}
        .ct-wr{background:#d1fae5;color:#065f46}
        .ct-mt{background:#dbeafe;color:#1e40af}

        .code-link{
            color:var(--primary-2); font-weight:700;
            font-size:.76rem; font-family:'Courier New',monospace;
            text-decoration:none;
        }
        .code-link:hover{color:var(--primary);text-decoration:underline}
        .td-muted{color:var(--text-s); font-size:.72rem}

        /* ── QUICK ACTIONS ── */
        .qa-grid{display:grid; grid-template-columns:1fr 1fr; gap:11px; padding:16px}
        .qa{
            display:flex; flex-direction:column; gap:5px;
            padding:14px;
            border-radius:13px;
            border:1.5px solid transparent;
            text-decoration:none;
            transition:all .2s;
        }
        .qa:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(0,0,0,0.08)}

        .qa-repair  {background:#ede9fe; border-color:#c4b5fd}
        .qa-repair:hover  {border-color:#a78bfa; background:#e5deff}
        .qa-contract{background:#dbeafe; border-color:#93c5fd}
        .qa-contract:hover{border-color:#60a5fa; background:#d0e8ff}
        .qa-equip   {background:#ccfbf1; border-color:#5eead4}
        .qa-equip:hover  {border-color:#2dd4bf; background:#b6f5e8}
        .qa-invoice {background:#dcfce7; border-color:#86efac}
        .qa-invoice:hover{border-color:#4ade80; background:#c8f7d5}
        .qa-chat    {background:#fef9c3; border-color:#fde047}
        .qa-chat:hover   {border-color:#facc15; background:#fef4a0}
        .qa-span2   {grid-column:span 2}

        .qa-icon{font-size:1.4rem; line-height:1; margin-bottom:2px}
        .qa-name{font-size:.81rem; font-weight:700; color:var(--text-h)}
        .qa-desc{font-size:.68rem; color:var(--text-m)}

        /* Empty */
        .empty{text-align:center;padding:40px 24px;color:var(--text-s);font-size:.8rem}
        .empty i{font-size:2rem;display:block;margin-bottom:10px;opacity:.2;color:var(--text-m)}
        .empty a{color:var(--primary-2);font-weight:700;text-decoration:none;display:inline-block;margin-top:8px}
        .empty a:hover{color:var(--primary)}
    </style>
</head>
<body>

<%-- ═══ SIDEBAR ═══ --%>
<aside class="sb">
    <div class="sb-brand">
        <div class="sb-logo"><i class="fas fa-bolt"></i></div>
        <div>
            <div class="sb-name">DRSMS</div>
            <div class="sb-role">Customer</div>
        </div>
    </div>

    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div>
        <a href="<%=ctx%>/customerDashboard" class="sb-item on">
            <i class="fas fa-home"></i> Dashboard
        </a>

        <div class="sb-lbl">Services</div>
        <a href="<%=ctx%>/customerServiceRequests" class="sb-item">
            <i class="fas fa-clipboard-list"></i> Repair Requests
            <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
        </a>
        <a href="<%=ctx%>/customerContracts" class="sb-item">
            <i class="fas fa-file-contract"></i> Contracts
        </a>
        <a href="<%=ctx%>/customerEquipment" class="sb-item">
            <i class="fas fa-desktop"></i> My Equipment
        </a>

        <div class="sb-lbl">Shop</div>
        <a href="<%=ctx%>/customerShop?action=parts" class="sb-item">
            <i class="fas fa-puzzle-piece"></i> Parts
        </a>
        <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item">
            <i class="fas fa-server"></i> Equipment
        </a>
        <a href="<%=ctx%>/customerShop?action=cart" class="sb-item">
            <i class="fas fa-shopping-cart"></i> Cart
            <%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%>
        </a>

        <div class="sb-lbl">Finance</div>
        <a href="<%=ctx%>/customerInvoices" class="sb-item">
            <i class="fas fa-receipt"></i> Invoices
            <%if(unpaidInv>0){%><span class="sb-badge"><%=unpaidInv%></span><%}%>
        </a>

        <div class="sb-lbl">Support</div>
        <a href="<%=ctx%>/customerChat" class="sb-item">
            <i class="fas fa-comment-dots"></i> Support Chat
            <%if(unreadChat>0){%><span class="sb-badge"><%=unreadChat%></span><%}%>
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
                <div class="sb-urole">Customer Account</div>
            </div>
        </a>
        <a href="<%=ctx%>/logout" class="sb-logout">
            <i class="fas fa-sign-out-alt"></i> Sign Out
        </a>
    </div>
</aside>

<%-- ═══ MAIN ═══ --%>
<main class="main">

    <div class="topbar">
        <div>
            <div class="topbar-greeting">Hello, <%=me.getFullName()%> 👋</div>
            <div class="topbar-sub">Here's an overview of your service account today.</div>
        </div>
        <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-cta">
            <i class="fas fa-plus"></i> New Repair Request
        </a>
    </div>

    <div class="content">

        <%if(unpaidInv>0){%>
        <div class="alert-warn">
            <i class="fas fa-triangle-exclamation"></i>
            <div>
                You have <strong><%=unpaidInv%> unpaid invoice(s)</strong>
                <%if(unpaidAmt!=null&&unpaidAmt.compareTo(BigDecimal.ZERO)>0){%>
                · Total: <strong><%=nf.format(unpaidAmt)%> ₫</strong>
                <%}%>
                <a href="<%=ctx%>/customerInvoices?status=UNPAID">View invoices →</a>
            </div>
        </div>
        <%}%>

        <%-- Stats --%>
        <div class="section-lbl">Overview</div>
        <div class="stats">
            <div class="sc sc-purple">
                <div class="sc-icon"><i class="fas fa-file-contract"></i></div>
                <div class="sc-val"><%=activeContracts%></div>
                <div class="sc-lbl">Active Contracts</div>
                <div class="sc-sub"><%=totalContracts%> total contracts</div>
            </div>
            <div class="sc sc-blue">
                <div class="sc-icon"><i class="fas fa-clipboard-list"></i></div>
                <div class="sc-val"><%=totalSR%></div>
                <div class="sc-lbl">Repair Requests</div>
                <div class="sc-sub"><%=pendingSR%> pending approval</div>
            </div>
            <div class="sc sc-teal">
                <div class="sc-icon"><i class="fas fa-circle-check"></i></div>
                <div class="sc-val"><%=completedSR%></div>
                <div class="sc-lbl">Completed</div>
                <div class="sc-sub"><%=activeSR%> in progress</div>
            </div>
            <%if(unpaidInv>0){%>
            <div class="sc sc-red">
                <div class="sc-icon"><i class="fas fa-file-invoice-dollar"></i></div>
                <div class="sc-val"><%=unpaidInv%></div>
                <div class="sc-lbl">Unpaid Invoices</div>
                <div class="sc-sub">
                    <%=unpaidAmt!=null&&unpaidAmt.compareTo(BigDecimal.ZERO)>0?nf.format(unpaidAmt)+" ₫":"Outstanding"%>
                </div>
            </div>
            <%}else{%>
            <div class="sc sc-green">
                <div class="sc-icon"><i class="fas fa-file-invoice-dollar"></i></div>
                <div class="sc-val">0</div>
                <div class="sc-lbl">Unpaid Invoices</div>
                <div class="sc-sub">All paid up ✓</div>
            </div>
            <%}%>
        </div>

        <%-- Activity --%>
        <div class="section-lbl">Activity</div>
        <div class="grid-2">

            <div class="card">
                <div class="card-hd">
                    <div class="card-title">
                        <i class="fas fa-clock-rotate-left"></i> Recent Requests
                    </div>
                    <a href="<%=ctx%>/customerServiceRequests" class="card-link">View all →</a>
                </div>
                <%if(recent.isEmpty()){%>
                <div class="empty">
                    <i class="fas fa-inbox"></i>
                    No requests yet.
                    <a href="<%=ctx%>/customerServiceRequests?action=create">+ Create your first request</a>
                </div>
                <%}else{%>
                <table>
                    <thead>
                        <tr>
                            <th>Code</th><th>Title</th><th>CT</th>
                            <th>Priority</th><th>Status</th><th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%for(ServiceRequest sr:recent){
                        String sc2="b-pending";
                        if("APPROVED".equals(sr.getStatus()))    sc2="b-approved";
                        else if("REJECTED".equals(sr.getStatus()))    sc2="b-rejected";
                        else if("IN_PROGRESS".equals(sr.getStatus())) sc2="b-inprogress";
                        else if("COMPLETED".equals(sr.getStatus()))   sc2="b-completed";
                        else if("CANCELLED".equals(sr.getStatus()))   sc2="b-cancelled";
                        String pc="b-medium";
                        if("LOW".equals(sr.getPriority()))    pc="b-low";
                        else if("HIGH".equals(sr.getPriority()))   pc="b-high";
                        else if("URGENT".equals(sr.getPriority())) pc="b-urgent";
                    %>
                    <tr>
                        <td>
                            <a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=sr.getId()%>"
                               class="code-link"><%=sr.getRequestCode()%></a>
                        </td>
                        <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
                            <%=sr.getTitle()%>
                        </td>
                        <td>
                            <span class="ct-badge <%="WARRANTY".equals(sr.getContractType())?"ct-wr":"ct-mt"%>">
                                <%="WARRANTY".equals(sr.getContractType())?"WR":"MT"%>
                            </span>
                        </td>
                        <td><span class="b <%=pc%>"><%=sr.getPriorityLabel()%></span></td>
                        <td><span class="b <%=sc2%>"><%=sr.getStatusLabel()%></span></td>
                        <td class="td-muted"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toLocalDate():"—"%></td>
                    </tr>
                    <%}%>
                    </tbody>
                </table>
                <%}%>
            </div>

            <div class="card">
                <div class="card-hd">
                    <div class="card-title"><i class="fas fa-bolt"></i> Quick Actions</div>
                </div>
                <div class="qa-grid">
                    <a href="<%=ctx%>/customerServiceRequests?action=create" class="qa qa-repair">
                        <div class="qa-icon">🔧</div>
                        <div class="qa-name">New Request</div>
                        <div class="qa-desc">Report an equipment issue</div>
                    </a>
                    <a href="<%=ctx%>/customerContracts" class="qa qa-contract">
                        <div class="qa-icon">📄</div>
                        <div class="qa-name">Contracts</div>
                        <div class="qa-desc">Warranty & maintenance</div>
                    </a>
                    <a href="<%=ctx%>/customerEquipment" class="qa qa-equip">
                        <div class="qa-icon">🖥️</div>
                        <div class="qa-name">Equipment</div>
                        <div class="qa-desc">Manage your devices</div>
                    </a>
                    <a href="<%=ctx%>/customerInvoices" class="qa qa-invoice">
                        <div class="qa-icon">💰</div>
                        <div class="qa-name">Invoices</div>
                        <div class="qa-desc">Payments & history</div>
                    </a>
                    <a href="<%=ctx%>/customerChat" class="qa qa-chat qa-span2">
                        <div class="qa-icon">💬</div>
                        <div class="qa-name">Support Chat</div>
                        <div class="qa-desc">
                            <%if(unreadChat>0){%>
                            <span style="color:#d97706;font-weight:700"><%=unreadChat%> new message(s)</span>
                            <%}else{%>Contact a support agent<%}%>
                        </div>
                    </a>
                </div>
            </div>

        </div>
    </div>
</main>

<%@ include file="customerAIBubble.jsp" %>
</body>
</html>
