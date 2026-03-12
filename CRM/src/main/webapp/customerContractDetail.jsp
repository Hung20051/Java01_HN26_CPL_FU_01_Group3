<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    Contract c=(Contract)request.getAttribute("contract");
    if(c==null){response.sendRedirect(request.getContextPath()+"/customerContracts");return;}
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int pendingSR  = request.getAttribute("pendingSR") !=null?(Integer)request.getAttribute("pendingSR"):0;
    int unpaidInv  = request.getAttribute("unpaidInv") !=null?(Integer)request.getAttribute("unpaidInv"):0;
    int unreadChat = request.getAttribute("unreadChat")!=null?(Integer)request.getAttribute("unreadChat"):0;
    List<CustomerEquipment> eqList=c.getEquipmentList(); if(eqList==null)eqList=new ArrayList<>();
    boolean isW="WARRANTY".equals(c.getContractType());
    String sc="b-active";
    if("EXPIRED".equals(c.getStatus()))sc="b-expired";
    else if("CANCELLED".equals(c.getStatus()))sc="b-cancelled";
    String initials = me.getFullName()!=null&&!me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%=c.getContractCode()%> - DRSMS</title>
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
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 0.88rem;
            box-shadow: 0 4px 14px var(--accent-glow); flex-shrink: 0;
        }
        .sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
        .sb-role {
            display: inline-flex; align-items: center;
            background: rgba(79,126,248,0.15);
            border: 1px solid rgba(79,126,248,0.25);
            color: var(--accent-2);
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
            font-size: 0.83rem; font-weight: 500;
            transition: all 0.2s; position: relative;
            border-left: 2px solid transparent;
        }
        .sb-item i {
            width: 28px; height: 28px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.8rem; border-radius: 8px;
            background: rgba(255,255,255,0.05); flex-shrink: 0; transition: all 0.2s;
        }
        .sb-item.on {
            color: #fff;
            background: linear-gradient(90deg, rgba(79,126,248,0.2), rgba(79,126,248,0.05));
            border-left: 2px solid var(--accent);
        }
        .sb-item.on i { background: rgba(79,126,248,0.25); color: var(--accent-2); }
        .sb-item.si-home:hover       { color:#fff; background:rgba(79,126,248,0.1); border-left-color:var(--accent); }
        .sb-item.si-home:hover i     { background:rgba(79,126,248,0.2); color:var(--accent-2); }
        .sb-item.si-repair:hover     { color:#fff; background:rgba(251,191,36,0.08); border-left-color:var(--amber); }
        .sb-item.si-repair:hover i   { background:rgba(251,191,36,0.18); color:var(--amber); }
        .sb-item.si-contract:hover   { color:#fff; background:rgba(167,139,250,0.08); border-left-color:var(--purple); }
        .sb-item.si-contract:hover i { background:rgba(167,139,250,0.18); color:var(--purple); }
        .sb-item.si-equip:hover      { color:#fff; background:rgba(56,189,248,0.08); border-left-color:var(--info); }
        .sb-item.si-equip:hover i    { background:rgba(56,189,248,0.18); color:var(--info); }
        .sb-item.si-parts:hover      { color:#fff; background:rgba(52,211,153,0.07); border-left-color:var(--green); }
        .sb-item.si-parts:hover i    { background:rgba(52,211,153,0.18); color:var(--green); }
        .sb-item.si-shop:hover       { color:#fff; background:rgba(56,189,248,0.07); border-left-color:var(--info); }
        .sb-item.si-shop:hover i     { background:rgba(56,189,248,0.18); color:var(--info); }
        .sb-item.si-cart:hover       { color:#fff; background:rgba(251,146,60,0.08); border-left-color:#fb923c; }
        .sb-item.si-cart:hover i     { background:rgba(251,146,60,0.18); color:#fb923c; }
        .sb-item.si-invoice:hover    { color:#fff; background:rgba(52,211,153,0.07); border-left-color:var(--green); }
        .sb-item.si-invoice:hover i  { background:rgba(52,211,153,0.18); color:var(--green); }
        .sb-item.si-chat:hover       { color:#fff; background:rgba(251,113,133,0.08); border-left-color:#fb7185; }
        .sb-item.si-chat:hover i     { background:rgba(251,113,133,0.18); color:#fb7185; }

        .sb-badge {
            margin-left: auto;
            background: var(--danger); color: #fff;
            font-size: 0.62rem; font-weight: 700;
            padding: 2px 6px; border-radius: 20px;
            animation: badgePop 2s ease-in-out infinite;
        }
        @keyframes badgePop { 0%,100%{transform:scale(1)} 50%{transform:scale(1.1)} }
        .sb-foot { padding: 12px 10px 16px; border-top: 1px solid var(--border); }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px; border-radius: 10px;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border);
            margin-bottom: 6px; text-decoration: none; transition: all 0.2s;
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
            margin-left: var(--sb-width); flex: 1;
            min-height: 100vh; display: flex; flex-direction: column;
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

        /* Breadcrumb */
        .breadcrumb { display: flex; align-items: center; gap: 7px; font-size: 0.78rem; color: var(--muted); }
        .breadcrumb a { color: var(--muted); text-decoration: none; transition: color 0.2s; }
        .breadcrumb a:hover { color: var(--accent-2); }
        .breadcrumb-sep { color: rgba(255,255,255,0.2); }
        .breadcrumb span:last-child { color: var(--text-2); font-weight: 500; }

        /* Content */
        .content { padding: 28px 32px; flex: 1; }

        /* ── HERO BANNER ── */
        .hero {
            border-radius: 18px;
            padding: 28px 32px;
            margin-bottom: 22px;
            display: flex; justify-content: space-between; align-items: center;
            position: relative; overflow: hidden;
            animation: cardIn 0.5s ease both;
        }
        .hero-warranty {
            background: linear-gradient(135deg, rgba(6,95,70,0.9), rgba(5,150,105,0.7));
            border: 1px solid rgba(52,211,153,0.3);
        }
        .hero-maint {
            background: linear-gradient(135deg, rgba(30,64,175,0.9), rgba(79,126,248,0.6));
            border: 1px solid rgba(79,126,248,0.3);
        }
        .hero::before {
            content: '';
            position: absolute; inset: 0;
            background: radial-gradient(ellipse at top right, rgba(255,255,255,0.06), transparent 60%);
            pointer-events: none;
        }
        .hero-code {
            font-family: 'Courier New', monospace;
            font-size: 0.88rem; opacity: 0.7;
            margin-bottom: 6px; letter-spacing: 0.5px;
        }
        .hero-left h2 {
            font-size: 1.55rem; font-weight: 800;
            color: #fff; margin-bottom: 12px;
            display: flex; align-items: center; gap: 10px;
        }
        .hero-meta {
            display: flex; gap: 20px;
            font-size: 0.8rem; color: rgba(255,255,255,0.8);
        }
        .hero-meta span { display: flex; align-items: center; gap: 6px; }
        .hero-badge {
            padding: 8px 18px; border-radius: 20px;
            background: rgba(255,255,255,0.18);
            font-size: 0.85rem; font-weight: 700;
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255,255,255,0.2);
            color: #fff; white-space: nowrap;
        }

        /* ── ACTION ROW ── */
        .action-row {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 22px;
        }
        .btn-back {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 18px;
            background: rgba(255,255,255,0.05);
            border: 1.5px solid var(--border);
            color: var(--text-2); text-decoration: none;
            font-size: 0.84rem; font-weight: 600;
            border-radius: 11px; transition: all 0.2s;
        }
        .btn-back:hover { background: rgba(255,255,255,0.09); border-color: rgba(255,255,255,0.15); color: #fff; }

        .btn-create {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 20px;
            background: linear-gradient(135deg, var(--accent), var(--purple));
            color: #fff; text-decoration: none;
            font-size: 0.84rem; font-weight: 700;
            border-radius: 11px;
            box-shadow: 0 4px 18px rgba(79,126,248,0.35);
            transition: all 0.25s;
        }
        .btn-create:hover { transform: translateY(-2px); box-shadow: 0 8px 28px rgba(79,126,248,0.5); }

        /* ── GRID LAYOUT ── */
        .grid-detail {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 18px;
            align-items: start;
        }

        /* ── CARDS ── */
        .card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            backdrop-filter: blur(12px);
            margin-bottom: 16px;
            animation: cardIn 0.5s ease both;
        }
        @keyframes cardIn { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }

        .card-hd {
            padding: 15px 20px;
            border-bottom: 1px solid var(--border);
            display: flex; justify-content: space-between; align-items: center;
            background: rgba(255,255,255,0.02);
        }
        .card-hd-left { display: flex; align-items: center; gap: 10px; }
        .card-hd-icon {
            width: 32px; height: 32px; border-radius: 9px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.82rem; flex-shrink: 0;
        }
        .card-hd-title { font-size: 0.87rem; font-weight: 700; color: var(--text); }
        .card-body { padding: 18px 20px; }

        /* ── INFO ROWS ── */
        .info-row {
            display: flex; gap: 12px;
            margin-bottom: 14px; align-items: flex-start;
        }
        .info-row:last-child { margin-bottom: 0; }
        .info-lbl {
            font-size: 0.75rem; color: var(--muted);
            font-weight: 600; min-width: 110px;
            padding-top: 1px; flex-shrink: 0;
        }
        .info-val { font-size: 0.84rem; color: var(--text-2); flex: 1; }

        /* ── STATUS BADGES ── */
        .b {
            display: inline-flex; align-items: center;
            padding: 3px 10px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700; white-space: nowrap;
        }
        .b-active   { background: var(--green-dim); color: var(--green); border: 1px solid rgba(52,211,153,0.2); }
        .b-expired  { background: var(--danger-dim); color: var(--danger); border: 1px solid rgba(248,113,113,0.2); }
        .b-cancelled{ background: rgba(255,255,255,0.05); color: var(--muted); border: 1px solid var(--border); }

        /* Contract type inline badge */
        .ct-type-badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 7px;
            font-size: 0.75rem; font-weight: 700;
        }
        .ct-type-warranty { background: var(--green-dim); color: var(--green); }
        .ct-type-maint    { background: var(--info-dim);  color: var(--info);  }

        /* ── EQUIPMENT GRID ── */
        .eq-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            padding: 16px;
        }
        .eq-card {
            border: 1.5px solid var(--border);
            border-radius: 12px;
            padding: 14px;
            background: rgba(255,255,255,0.02);
            transition: all 0.2s;
        }
        .eq-card:hover {
            border-color: rgba(79,126,248,0.35);
            background: rgba(79,126,248,0.05);
        }
        .eq-card-top {
            display: flex; justify-content: space-between; align-items: flex-start;
            margin-bottom: 10px;
        }
        .eq-icon {
            width: 36px; height: 36px; border-radius: 10px;
            background: rgba(79,126,248,0.15); color: var(--accent-2);
            display: flex; align-items: center; justify-content: center;
            font-size: 0.95rem;
        }
        .eq-source {
            font-size: 0.68rem; font-weight: 700;
            padding: 2px 7px; border-radius: 5px;
        }
        .eq-source-ext { background: var(--amber-dim); color: var(--amber); }
        .eq-source-int { background: rgba(79,126,248,0.12); color: var(--accent-2); }
        .eq-model { font-size: 0.84rem; font-weight: 700; color: var(--text); margin-bottom: 3px; }
        .eq-serial { font-size: 0.73rem; color: var(--muted); font-family: 'Courier New', monospace; }
        .eq-warranty {
            margin-top: 8px;
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 9px; border-radius: 6px;
            font-size: 0.72rem; font-weight: 600;
        }
        .eq-warranty.ok  { background: var(--green-dim); color: var(--green); }
        .eq-warranty.exp { background: var(--danger-dim); color: var(--danger); }

        /* ── NOTES BOX ── */
        .note-box {
            background: var(--amber-dim);
            border: 1px solid rgba(251,191,36,0.2);
            border-radius: 10px;
            padding: 14px 16px;
            font-size: 0.83rem; color: var(--text-2);
            line-height: 1.7;
        }

        /* ── SERVICE TERMS CARD ── */
        .terms-card {
            border-radius: 14px;
            padding: 18px;
            margin-bottom: 16px;
        }
        .terms-warranty {
            background: rgba(52,211,153,0.07);
            border: 1px solid rgba(52,211,153,0.18);
        }
        .terms-maint {
            background: rgba(56,189,248,0.07);
            border: 1px solid rgba(56,189,248,0.18);
        }
        .terms-title {
            font-size: 0.84rem; font-weight: 700;
            margin-bottom: 10px;
            display: flex; align-items: center; gap: 7px;
        }
        .terms-warranty .terms-title { color: var(--green); }
        .terms-maint    .terms-title { color: var(--info); }
        .terms-list {
            font-size: 0.8rem; line-height: 1.9; color: var(--text-2);
        }

        /* Empty state in card */
        .card-empty {
            text-align: center; padding: 32px;
            color: var(--muted); font-size: 0.82rem;
        }
        .card-empty i { font-size: 2rem; display: block; margin-bottom: 10px; opacity: 0.2; }
    </style>
</head>
<body>

    <%-- ═══════════ SIDEBAR ═══════════ --%>
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
            <a href="<%=ctx%>/customerDashboard" class="sb-item si-home">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <div class="sb-lbl">Services</div>
            <a href="<%=ctx%>/customerServiceRequests" class="sb-item si-repair">
                <i class="fas fa-clipboard-list"></i> Repair Requests
                <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
            </a>
            <a href="<%=ctx%>/customerContracts" class="sb-item on si-contract">
                <i class="fas fa-file-contract"></i> Contracts
            </a>
            <a href="<%=ctx%>/customerEquipment" class="sb-item si-equip">
                <i class="fas fa-desktop"></i> My Equipment
            </a>
            <div class="sb-lbl">Shop</div>
            <a href="<%=ctx%>/customerShop?action=parts" class="sb-item si-parts">
                <i class="fas fa-puzzle-piece"></i> Parts
            </a>
            <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item si-shop">
                <i class="fas fa-server"></i> Equipment
            </a>
            <a href="<%=ctx%>/customerShop?action=cart" class="sb-item si-cart">
                <i class="fas fa-shopping-cart"></i> Cart
                <%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%>
            </a>
            <div class="sb-lbl">Finance</div>
            <a href="<%=ctx%>/customerInvoices" class="sb-item si-invoice">
                <i class="fas fa-receipt"></i> Invoices
                <%if(unpaidInv>0){%><span class="sb-badge"><%=unpaidInv%></span><%}%>
            </a>
            <div class="sb-lbl">Support</div>
            <a href="<%=ctx%>/customerChat" class="sb-item si-chat">
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

    <%-- ═══════════ MAIN ═══════════ --%>
    <main class="main">

        <%-- Topbar --%>
        <div class="topbar">
            <div>
                <div class="topbar-title">
                    <i class="fas fa-file-contract" style="color:var(--purple);margin-right:8px;font-size:1rem"></i>
                    Contract Detail
                </div>
                <div class="topbar-sub">
                    <span class="breadcrumb">
                        <a href="<%=ctx%>/customerDashboard"><i class="fas fa-home"></i> Dashboard</a>
                        <span class="breadcrumb-sep">›</span>
                        <a href="<%=ctx%>/customerContracts">Contracts</a>
                        <span class="breadcrumb-sep">›</span>
                        <span><%=c.getContractCode()%></span>
                    </span>
                </div>
            </div>
        </div>

        <div class="content">

            <%-- Hero --%>
            <div class="hero <%=isW?"hero-warranty":"hero-maint"%>">
                <div class="hero-left">
                    <div class="hero-code"><%=c.getContractCode()%></div>
                    <h2>
                        <i class="fas fa-<%=isW?"shield-alt":"tools"%>"></i>
                        <%=c.getContractTypeLabel()%> Contract
                    </h2>
                    <div class="hero-meta">
                        <span><i class="fas fa-calendar"></i> <%=c.getStartDate()%> → <%=c.getEndDate()%></span>
                        <span><i class="fas fa-desktop"></i> <%=eqList.size()%> device(s)</span>
                        <span><i class="fas fa-user-tie"></i> <%=c.getCreatedByName()%></span>
                    </div>
                </div>
                <div class="hero-badge"><%=c.getStatusLabel()%></div>
            </div>

            <%-- Action row --%>
            <div class="action-row">
                <a href="<%=ctx%>/customerContracts" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Back to Contracts
                </a>
                <%if(c.isActive()){%>
                <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-create">
                    <i class="fas fa-plus"></i> Create Repair Request
                </a>
                <%}%>
            </div>

            <%-- Main grid --%>
            <div class="grid-detail">

                <%-- Left col --%>
                <div>
                    <%-- Equipment list --%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-left">
                                <div class="card-hd-icon" style="background:var(--purple-dim);color:var(--purple)">
                                    <i class="fas fa-desktop"></i>
                                </div>
                                <div class="card-hd-title">Devices in Contract (<%=eqList.size()%>)</div>
                            </div>
                        </div>
                        <%if(eqList.isEmpty()){%>
                        <div class="card-empty">
                            <i class="fas fa-desktop"></i>No devices in this contract yet.
                        </div>
                        <%}else{%>
                        <div class="eq-grid">
                            <%for(CustomerEquipment eq:eqList){
                                boolean underW=eq.isUnderWarranty();
                                boolean isExt="EXTERNAL".equals(eq.getSource());
                            %>
                            <div class="eq-card">
                                <div class="eq-card-top">
                                    <div class="eq-icon"><i class="fas fa-desktop"></i></div>
                                    <span class="eq-source <%=isExt?"eq-source-ext":"eq-source-int"%>">
                                        <%=isExt?"External":"In-System"%>
                                    </span>
                                </div>
                                <div class="eq-model"><%=eq.getDisplayName()%></div>
                                <div class="eq-serial">
                                    <i class="fas fa-barcode" style="font-size:.65rem;margin-right:4px"></i><%=eq.getDisplaySerial()%>
                                </div>
                                <%if(eq.getWarrantyExpires()!=null){%>
                                <div>
                                    <span class="eq-warranty <%=underW?"ok":"exp"%>">
                                        <i class="fas fa-<%=underW?"shield-alt":"clock"%>"></i>
                                        Warranty: <%=underW?"valid until ":"expired since "%><%=eq.getWarrantyExpires()%>
                                    </span>
                                </div>
                                <%}%>
                            </div>
                            <%}%>
                        </div>
                        <%}%>
                    </div>

                    <%-- Notes --%>
                    <%if(c.getNotes()!=null&&!c.getNotes().isEmpty()){%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-left">
                                <div class="card-hd-icon" style="background:var(--amber-dim);color:var(--amber)">
                                    <i class="fas fa-sticky-note"></i>
                                </div>
                                <div class="card-hd-title">Contract Notes</div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="note-box"><%=c.getNotes()%></div>
                        </div>
                    </div>
                    <%}%>
                </div>

                <%-- Right col --%>
                <div>
                    <%-- Contract info --%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-left">
                                <div class="card-hd-icon" style="background:rgba(79,126,248,0.15);color:var(--accent-2)">
                                    <i class="fas fa-info"></i>
                                </div>
                                <div class="card-hd-title">Contract Information</div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="info-row">
                                <div class="info-lbl">Contract Code</div>
                                <div class="info-val">
                                    <strong style="font-family:'Courier New',monospace;color:var(--accent-2);font-size:0.9rem">
                                        <%=c.getContractCode()%>
                                    </strong>
                                </div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">Type</div>
                                <div class="info-val">
                                    <span class="ct-type-badge <%=isW?"ct-type-warranty":"ct-type-maint"%>">
                                        <i class="fas fa-<%=isW?"shield-alt":"tools"%>"></i>
                                        <%=c.getContractTypeLabel()%>
                                    </span>
                                </div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">Status</div>
                                <div class="info-val"><span class="b <%=sc%>"><%=c.getStatusLabel()%></span></div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">Start Date</div>
                                <div class="info-val"><%=c.getStartDate()%></div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">End Date</div>
                                <div class="info-val"><%=c.getEndDate()%></div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">Managed By</div>
                                <div class="info-val"><%=c.getCreatedByName()%></div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">Created On</div>
                                <div class="info-val"><%=c.getCreatedAt()!=null?c.getCreatedAt().toLocalDate():"—"%></div>
                            </div>
                        </div>
                    </div>

                    <%-- Service terms --%>
                    <div class="terms-card <%=isW?"terms-warranty":"terms-maint"%>">
                        <div class="terms-title">
                            <i class="fas fa-<%=isW?"shield-check":"tools"%>"></i> Service Terms
                        </div>
                        <div class="terms-list">
                            <%if(isW){%>
                            ✓ Free repairs during the warranty period<br>
                            ✓ Applies to devices still under warranty<br>
                            ✓ No charge for labor or parts
                            <%}else{%>
                            ✓ Periodic maintenance and repair services<br>
                            ✓ Costs will be notified after inspection<br>
                            ✓ Invoice issued upon job completion
                            <%}%>
                        </div>
                    </div>

                    <%-- CTA --%>
                    <%if(c.isActive()){%>
                    <a href="<%=ctx%>/customerServiceRequests?action=create"
                       class="btn-create" style="width:100%;justify-content:center">
                        <i class="fas fa-plus"></i> Create Repair Request
                    </a>
                    <%}%>
                </div>

            </div>
        </div>
    </main>

</body>
</html>
