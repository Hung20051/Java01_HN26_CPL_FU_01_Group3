<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<Contract> contracts=(List<Contract>)request.getAttribute("contracts"); if(contracts==null)contracts=new ArrayList<>();
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int pendingSR = request.getAttribute("pendingSR")!=null?(Integer)request.getAttribute("pendingSR"):0;
    int unpaidInv = request.getAttribute("unpaidInv")!=null?(Integer)request.getAttribute("unpaidInv"):0;
    int unreadChat = request.getAttribute("unreadChat")!=null?(Integer)request.getAttribute("unreadChat"):0;
    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Create Repair Request - DRSMS</title>
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
            background: rgba(79,126,248,0.15);
            border: 1px solid rgba(79,126,248,0.25);
            color: var(--accent-2);
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
            position: relative;
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
        .sb-item.on {
            color: #fff;
            background: linear-gradient(90deg, rgba(79,126,248,0.2), rgba(79,126,248,0.05));
            border-left: 2px solid var(--accent);
        }
        .sb-item.on i { background: rgba(79,126,248,0.25); color: var(--accent-2); }

        .sb-item.si-home:hover       { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
        .sb-item.si-home:hover i     { background: rgba(79,126,248,0.2); color: var(--accent-2); }
        .sb-item.si-repair:hover     { color: #fff; background: rgba(251,191,36,0.08); border-left-color: var(--amber); }
        .sb-item.si-repair:hover i   { background: rgba(251,191,36,0.18); color: var(--amber); }
        .sb-item.si-contract:hover   { color: #fff; background: rgba(167,139,250,0.08); border-left-color: var(--purple); }
        .sb-item.si-contract:hover i { background: rgba(167,139,250,0.18); color: var(--purple); }
        .sb-item.si-equip:hover      { color: #fff; background: rgba(56,189,248,0.08); border-left-color: var(--info); }
        .sb-item.si-equip:hover i    { background: rgba(56,189,248,0.18); color: var(--info); }
        .sb-item.si-parts:hover      { color: #fff; background: rgba(52,211,153,0.07); border-left-color: var(--green); }
        .sb-item.si-parts:hover i    { background: rgba(52,211,153,0.18); color: var(--green); }
        .sb-item.si-shop:hover       { color: #fff; background: rgba(56,189,248,0.07); border-left-color: var(--info); }
        .sb-item.si-shop:hover i     { background: rgba(56,189,248,0.18); color: var(--info); }
        .sb-item.si-cart:hover       { color: #fff; background: rgba(251,146,60,0.08); border-left-color: #fb923c; }
        .sb-item.si-cart:hover i     { background: rgba(251,146,60,0.18); color: #fb923c; }
        .sb-item.si-invoice:hover    { color: #fff; background: rgba(52,211,153,0.07); border-left-color: var(--green); }
        .sb-item.si-invoice:hover i  { background: rgba(52,211,153,0.18); color: var(--green); }
        .sb-item.si-chat:hover       { color: #fff; background: rgba(251,113,133,0.08); border-left-color: #fb7185; }
        .sb-item.si-chat:hover i     { background: rgba(251,113,133,0.18); color: #fb7185; }

        .sb-badge {
            margin-left: auto;
            background: var(--danger);
            color: #fff; font-size: 0.62rem; font-weight: 700;
            padding: 2px 6px; border-radius: 20px;
            animation: badgePop 2s ease-in-out infinite;
        }
        @keyframes badgePop {
            0%,100% { transform: scale(1); }
            50%      { transform: scale(1.1); }
        }
        .sb-foot {
            padding: 12px 10px 16px;
            border-top: 1px solid var(--border);
        }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px 10px;
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
            padding: 0;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
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
        .breadcrumb {
            display: flex; align-items: center; gap: 7px;
            font-size: 0.78rem; color: var(--muted);
        }
        .breadcrumb a { color: var(--muted); text-decoration: none; transition: color 0.2s; }
        .breadcrumb a:hover { color: var(--accent-2); }
        .breadcrumb-sep { color: rgba(255,255,255,0.2); }
        .breadcrumb span:last-child { color: var(--text-2); font-weight: 500; }

        /* Content */
        .content { padding: 28px 32px; flex: 1; }

        /* ── FORM CARD ── */
        .form-card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            backdrop-filter: blur(12px);
            max-width: 820px;
            animation: cardIn 0.5s ease both;
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .form-hd {
            padding: 22px 26px;
            border-bottom: 1px solid var(--border);
            background: rgba(255,255,255,0.02);
        }
        .form-hd h2 {
            font-size: 1.05rem; font-weight: 700; color: #fff;
            display: flex; align-items: center; gap: 9px;
        }
        .form-hd h2 i { color: var(--accent-2); }
        .form-hd p { color: var(--muted); font-size: 0.82rem; margin-top: 5px; font-weight: 300; }

        .form-body { padding: 26px; }

        .sec-title {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted);
            margin-bottom: 14px; padding-bottom: 8px;
            border-bottom: 1px solid var(--border);
        }

        .fg { margin-bottom: 16px; }

        .lbl {
            display: block;
            font-size: 0.8rem; font-weight: 600;
            color: var(--text-2); margin-bottom: 6px;
        }
        .lbl span { color: var(--danger); margin-left: 3px; }

        .fc {
            width: 100%;
            padding: 10px 13px;
            background: rgba(255,255,255,0.05);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            font-family: 'Sora', sans-serif;
            font-size: 0.85rem;
            color: var(--text);
            outline: none;
            transition: all 0.2s;
        }
        .fc::placeholder { color: var(--muted); }
        .fc:focus {
            border-color: rgba(79,126,248,0.5);
            background: rgba(79,126,248,0.05);
            box-shadow: 0 0 0 3px rgba(79,126,248,0.1);
        }
        .fc option { background: #0f1c4d; color: #fff; }
        textarea.fc { resize: vertical; min-height: 90px; }

        .row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }

        /* Contract info box */
        .contract-info {
            display: none;
            background: rgba(56,189,248,0.08);
            border: 1px solid rgba(56,189,248,0.2);
            border-radius: 10px;
            padding: 10px 14px;
            font-size: 0.8rem; color: var(--info);
            margin-top: 8px;
        }
        .contract-info i { margin-right: 6px; }

        /* Equipment wrap */
        .eq-wrap {
            border: 1.5px solid var(--border);
            border-radius: 12px;
            overflow: hidden;
            min-height: 52px;
            background: rgba(255,255,255,0.02);
        }
        .eq-empty, .eq-loading {
            padding: 18px;
            text-align: center;
            color: var(--muted);
            font-size: 0.82rem;
        }
        .eq-loading { display: none; }

        .eq-item {
            display: flex; align-items: flex-start; gap: 11px;
            padding: 13px 16px;
            border-bottom: 1px solid var(--border-2);
            transition: background 0.15s;
        }
        .eq-item:last-child { border-bottom: none; }
        .eq-item:hover { background: rgba(79,126,248,0.05); }

        .eq-item input[type=checkbox] {
            width: 16px; height: 16px;
            margin-top: 2px;
            accent-color: var(--accent);
            cursor: pointer; flex-shrink: 0;
        }
        .eq-item-name { font-size: 0.85rem; font-weight: 600; color: var(--text); }
        .eq-item-serial { font-size: 0.72rem; font-family: 'Courier New', monospace; color: var(--muted); margin-top: 2px; }

        .eq-item-desc { margin-top: 8px; display: none; }
        .eq-item-desc textarea {
            width: 100%;
            padding: 8px 11px;
            background: rgba(255,255,255,0.04);
            border: 1.5px solid var(--border);
            border-radius: 8px;
            font-family: 'Sora', sans-serif;
            font-size: 0.8rem;
            color: var(--text-2);
            resize: none; height: 58px;
            outline: none; transition: border-color 0.2s;
        }
        .eq-item-desc textarea::placeholder { color: var(--muted); }
        .eq-item-desc textarea:focus { border-color: rgba(79,126,248,0.4); }

        .hint-selected {
            margin-top: 8px;
            font-size: 0.78rem; font-weight: 600;
            color: var(--green);
            display: none;
        }

        /* Source badge */
        .src-badge {
            display: inline-flex; align-items: center;
            padding: 1px 6px; border-radius: 4px;
            font-size: 0.68rem; font-weight: 700;
            margin-left: 6px;
        }
        .src-external { background: rgba(251,191,36,0.12); color: var(--amber); }
        .src-internal { background: rgba(79,126,248,0.12); color: var(--accent-2); }

        /* Priority grid */
        .prio-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
        }
        .prio-card {
            border: 1.5px solid var(--border);
            border-radius: 12px;
            padding: 14px 10px;
            cursor: pointer; text-align: center;
            transition: all 0.2s;
            background: rgba(255,255,255,0.02);
        }
        .prio-card:hover { border-color: rgba(79,126,248,0.4); background: rgba(79,126,248,0.06); }
        .prio-card.sel { border-color: var(--pc); background: var(--pb); }
        .prio-card input { display: none; }
        .prio-card-ico { font-size: 1.3rem; margin-bottom: 5px; }
        .prio-card-lbl { font-size: 0.75rem; font-weight: 700; color: var(--text-2); }
        .prio-card.sel .prio-card-lbl { color: var(--pc); }

        .p-low  { --pc: #34d399; --pb: rgba(52,211,153,0.1); }
        .p-med  { --pc: #fbbf24; --pb: rgba(251,191,36,0.1); }
        .p-high { --pc: #fb923c; --pb: rgba(251,146,60,0.1); }
        .p-urg  { --pc: #f87171; --pb: rgba(248,113,113,0.1); }

        /* Form footer */
        .form-ft {
            padding: 18px 26px;
            border-top: 1px solid var(--border);
            display: flex; gap: 10px;
            background: rgba(255,255,255,0.01);
        }

        .btn-sub {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 11px 24px;
            background: linear-gradient(135deg, var(--accent), var(--purple));
            color: #fff; border: none; cursor: pointer;
            font-family: 'Sora', sans-serif;
            font-size: 0.875rem; font-weight: 700;
            border-radius: 11px;
            box-shadow: 0 4px 20px rgba(79,126,248,0.35);
            transition: all 0.25s;
        }
        .btn-sub:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 28px rgba(79,126,248,0.5);
        }

        .btn-back {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 11px 22px;
            background: rgba(255,255,255,0.05);
            border: 1.5px solid var(--border);
            color: var(--text-2);
            font-family: 'Sora', sans-serif;
            font-size: 0.875rem; font-weight: 600;
            border-radius: 11px; text-decoration: none;
            transition: all 0.2s;
        }
        .btn-back:hover { background: rgba(255,255,255,0.08); border-color: rgba(255,255,255,0.15); color: #fff; }

        /* No contracts alert */
        .alert-warn {
            display: flex; align-items: center; gap: 12px;
            padding: 16px 20px;
            background: rgba(251,191,36,0.08);
            border: 1px solid rgba(251,191,36,0.25);
            border-radius: 14px;
            font-size: 0.85rem; color: var(--text-2);
            max-width: 820px;
            animation: cardIn 0.5s ease both;
        }
        .alert-warn i { color: var(--amber); font-size: 1.1rem; flex-shrink: 0; }
        .alert-warn a { color: var(--accent-2); font-weight: 700; text-decoration: none; }
        .alert-warn a:hover { color: #fff; }

        /* Section spacing */
        .sec-block { margin-bottom: 26px; }
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
            <a href="<%=ctx%>/customerServiceRequests" class="sb-item on si-repair">
                <i class="fas fa-clipboard-list"></i> Repair Requests
                <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
            </a>
            <a href="<%=ctx%>/customerContracts" class="sb-item si-contract">
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
                    <i class="fas fa-plus-circle" style="color:var(--accent-2);margin-right:8px;font-size:1rem"></i>
                    Create Repair Request
                </div>
                <div class="topbar-sub">
                    <span class="breadcrumb">
                        <a href="<%=ctx%>/customerDashboard"><i class="fas fa-home"></i> Dashboard</a>
                        <span class="breadcrumb-sep">›</span>
                        <a href="<%=ctx%>/customerServiceRequests">Repair Requests</a>
                        <span class="breadcrumb-sep">›</span>
                        <span>Create New</span>
                    </span>
                </div>
            </div>
        </div>

        <div class="content">

            <%if(contracts.isEmpty()){%>
            <div class="alert-warn">
                <i class="fas fa-triangle-exclamation"></i>
                <div>
                    You have <strong style="color:var(--amber)">no active service contracts.</strong>
                    Please <a href="<%=ctx%>/customerChat">contact a support agent</a> to create a contract before submitting a repair request.
                </div>
            </div>
            <%}else{%>

            <div class="form-card">
                <div class="form-hd">
                    <h2><i class="fas fa-plus-circle"></i> Create New Repair Request</h2>
                    <p>Select a contract and equipment to repair, then describe the issue to send to the technical team.</p>
                </div>

                <form method="post" action="<%=ctx%>/customerServiceRequests" onsubmit="return validate()">
                    <input type="hidden" name="action" value="create">

                    <div class="form-body">

                        <%-- Step 1 --%>
                        <div class="sec-block">
                            <div class="sec-title">1 · Select Contract</div>
                            <div class="fg">
                                <label class="lbl">Your Contract <span>*</span></label>
                                <select class="fc" name="contractId" id="contractSel" onchange="loadEquipment(this)" required>
                                    <option value="">— Select a contract —</option>
                                    <%for(Contract c:contracts){%>
                                    <option value="<%=c.getId()%>" data-type="<%=c.getContractType()%>">
                                        <%=c.getContractCode()%> — <%=c.getContractTypeLabel()%>
                                        (<%=c.getEquipmentCount()%> equipment · Expires: <%=c.getEndDate()%>)
                                    </option>
                                    <%}%>
                                </select>
                            </div>
                            <div class="contract-info" id="contractInfo"></div>
                        </div>

                        <%-- Step 2 --%>
                        <div class="sec-block">
                            <div class="sec-title">2 · Select Equipment to Repair</div>
                            <div class="eq-wrap" id="eqWrap">
                                <div class="eq-empty" id="eqEmpty">← Select a contract to view equipment list</div>
                                <div class="eq-loading" id="eqLoad"><i class="fas fa-spinner fa-spin"></i> Loading...</div>
                            </div>
                            <div class="hint-selected" id="hintSelected"></div>
                        </div>

                        <%-- Step 3 --%>
                        <div class="sec-block">
                            <div class="sec-title">3 · Describe the General Issue</div>
                            <div class="fg">
                                <label class="lbl">Request Title <span>*</span></label>
                                <input type="text" class="fc" name="title" required minlength="10" maxlength="200"
                                       placeholder="E.g.: Pump making loud noise, air conditioner not reaching temperature...">
                            </div>
                            <div class="fg">
                                <label class="lbl">Detailed Description <span>*</span></label>
                                <textarea class="fc" name="description" required minlength="20"
                                          placeholder="Describe the condition in detail, when it occurred, specific symptoms..."></textarea>
                            </div>
                        </div>

                        <%-- Step 4 --%>
                        <div class="sec-block" style="margin-bottom:0">
                            <div class="sec-title">4 · Priority Level</div>
                            <div class="prio-grid">
                                <label class="prio-card p-low" onclick="selPrio(this)">
                                    <input type="radio" name="priority" value="LOW">
                                    <div class="prio-card-ico">🟢</div>
                                    <div class="prio-card-lbl">Low</div>
                                </label>
                                <label class="prio-card p-med sel" onclick="selPrio(this)">
                                    <input type="radio" name="priority" value="MEDIUM" checked>
                                    <div class="prio-card-ico">🟡</div>
                                    <div class="prio-card-lbl">Medium</div>
                                </label>
                                <label class="prio-card p-high" onclick="selPrio(this)">
                                    <input type="radio" name="priority" value="HIGH">
                                    <div class="prio-card-ico">🟠</div>
                                    <div class="prio-card-lbl">High</div>
                                </label>
                                <label class="prio-card p-urg" onclick="selPrio(this)">
                                    <input type="radio" name="priority" value="URGENT">
                                    <div class="prio-card-ico">🔴</div>
                                    <div class="prio-card-lbl">Urgent</div>
                                </label>
                            </div>
                        </div>

                    </div>

                    <div class="form-ft">
                        <button type="submit" class="btn-sub">
                            <i class="fas fa-paper-plane"></i> Submit Request
                        </button>
                        <a href="<%=ctx%>/customerServiceRequests" class="btn-back">
                            <i class="fas fa-arrow-left"></i> Back
                        </a>
                    </div>
                </form>
            </div>

            <%}%>
        </div>
    </main>

    <script>
        const CTX = '<%=ctx%>';

        function selPrio(el) {
            document.querySelectorAll('.prio-card').forEach(c => c.classList.remove('sel'));
            el.classList.add('sel');
            el.querySelector('input').checked = true;
        }

        function loadEquipment(sel) {
            const cid = sel.value;
            const wrap = document.getElementById('eqWrap');
            const empty = document.getElementById('eqEmpty');
            const load = document.getElementById('eqLoad');
            const info = document.getElementById('contractInfo');
            const hint = document.getElementById('hintSelected');

            wrap.querySelectorAll('.eq-item').forEach(e => e.remove());
            hint.style.display = 'none';
            info.style.display = 'none';

            if (!cid) {
                empty.style.display = 'block';
                load.style.display = 'none';
                return;
            }

            const opt = sel.options[sel.selectedIndex];
            const type = opt.dataset.type;
            info.style.display = 'block';
            info.innerHTML = '<i class="fas fa-info-circle"></i> <strong>'
                + (type === 'WARRANTY' ? 'Warranty' : 'Maintenance')
                + '</strong> contract — '
                + (type === 'WARRANTY'
                    ? 'Repairs are free within the warranty period.'
                    : 'Repair costs will be charged based on actual work.');

            empty.style.display = 'none';
            load.style.display = 'block';

            fetch(CTX + '/customerServiceRequests?action=getEquipment&contractId=' + cid)
                .then(r => r.json())
                .then(data => {
                    load.style.display = 'none';
                    if (data.length === 0) {
                        empty.textContent = 'This contract has no equipment.';
                        empty.style.display = 'block';
                        return;
                    }
                    data.forEach(eq => {
                        const isExt = eq.source === 'EXTERNAL';
                        const div = document.createElement('div');
                        div.className = 'eq-item';
                        div.innerHTML =
                            '<input type="checkbox" name="equipmentIds[]" value="' + eq.id + '" id="eq' + eq.id + '"'
                            + ' onchange="toggleDesc(this,' + eq.id + ')">'
                            + '<div class="eq-item-info" style="flex:1">'
                            + '<label for="eq' + eq.id + '" style="cursor:pointer">'
                            + '<div class="eq-item-name">' + eq.name + '</div>'
                            + '<div class="eq-item-serial">'
                            + '<i class="fas fa-barcode" style="font-size:.65rem;margin-right:4px"></i>' + eq.serial
                            + '<span class="src-badge ' + (isExt ? 'src-external' : 'src-internal') + '">'
                            + (isExt ? 'External' : 'In-System') + '</span>'
                            + '</div>'
                            + '</label>'
                            + '<div class="eq-item-desc" id="desc-wrap-' + eq.id + '">'
                            + '<textarea name="issueDescs[]" placeholder="Describe the specific issue for this equipment (optional)..." id="desc-' + eq.id + '"></textarea>'
                            + '</div>'
                            + '</div>';
                        wrap.appendChild(div);
                    });
                    updateHint();
                    wrap.querySelectorAll('input[type=checkbox]').forEach(cb => cb.addEventListener('change', updateHint));
                })
                .catch(() => {
                    load.style.display = 'none';
                    empty.textContent = 'Error loading equipment list.';
                    empty.style.display = 'block';
                });
        }

        function toggleDesc(cb, id) {
            const dw = document.getElementById('desc-wrap-' + id);
            if (dw) dw.style.display = cb.checked ? 'block' : 'none';
            updateHint();
        }

        function updateHint() {
            const checked = document.querySelectorAll('input[name="equipmentIds[]"]:checked').length;
            const h = document.getElementById('hintSelected');
            h.style.display = checked > 0 ? 'block' : 'none';
            if (checked > 0) h.textContent = '✓ ' + checked + ' equipment selected';
        }

        function validate() {
            const cid = document.getElementById('contractSel').value;
            if (!cid) { alert('Please select a contract!'); return false; }
            const checked = document.querySelectorAll('input[name="equipmentIds[]"]:checked').length;
            if (checked === 0) { alert('Please select at least 1 piece of equipment to repair!'); return false; }
            return true;
        }
    </script>
    <%@ include file="customerAIBubble.jsp" %>
</body>
</html>
