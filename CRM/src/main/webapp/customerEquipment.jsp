<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<CustomerEquipment> equipmentList=(List<CustomerEquipment>)request.getAttribute("equipmentList");
    if(equipmentList==null)equipmentList=new ArrayList<>();
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int pendingSR  = request.getAttribute("pendingSR") !=null?(Integer)request.getAttribute("pendingSR"):0;
    int unpaidInv  = request.getAttribute("unpaidInv") !=null?(Integer)request.getAttribute("unpaidInv"):0;
    int unreadChat = request.getAttribute("unreadChat")!=null?(Integer)request.getAttribute("unreadChat"):0;
    long totalEq      = equipmentList.size();
    long internalEq   = equipmentList.stream().filter(e->"INTERNAL".equals(e.getSource())).count();
    long externalEq   = equipmentList.stream().filter(e->"EXTERNAL".equals(e.getSource())).count();
    long underWarranty= equipmentList.stream().filter(CustomerEquipment::isUnderWarranty).count();
    String initials = me.getFullName()!=null&&!me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>My Equipment - DRSMS</title>
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
        .sb-item.si-home:hover       { color:#fff; background:rgba(79,126,248,0.1);  border-left-color:var(--accent); }
        .sb-item.si-home:hover i     { background:rgba(79,126,248,0.2);  color:var(--accent-2); }
        .sb-item.si-repair:hover     { color:#fff; background:rgba(251,191,36,0.08); border-left-color:var(--amber); }
        .sb-item.si-repair:hover i   { background:rgba(251,191,36,0.18); color:var(--amber); }
        .sb-item.si-contract:hover   { color:#fff; background:rgba(167,139,250,0.08);border-left-color:var(--purple); }
        .sb-item.si-contract:hover i { background:rgba(167,139,250,0.18);color:var(--purple); }
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
        .sb-item.si-chat:hover       { color:#fff; background:rgba(251,113,133,0.08);border-left-color:#fb7185; }
        .sb-item.si-chat:hover i     { background:rgba(251,113,133,0.18);color:#fb7185; }

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

        /* Content */
        .content { padding: 28px 32px; flex: 1; }

        /* Section label */
        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 12px;
        }

        /* ── INFO BAR ── */
        .info-bar {
            display: flex; align-items: center; gap: 10px;
            padding: 12px 16px;
            background: rgba(56,189,248,0.07);
            border: 1px solid rgba(56,189,248,0.2);
            border-radius: 12px;
            font-size: 0.82rem; color: var(--info);
            margin-bottom: 22px;
            animation: cardIn 0.4s ease both;
        }
        .info-bar i { flex-shrink: 0; }
        .info-bar a { color: var(--accent-2); font-weight: 700; text-decoration: none; }
        .info-bar a:hover { color: #fff; }

        /* ── STAT CARDS ── */
        .stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
            margin-bottom: 26px;
        }
        .sc {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px;
            position: relative; overflow: hidden;
            backdrop-filter: blur(12px);
            transition: all 0.25s;
            animation: cardIn 0.5s ease both;
            display: flex; align-items: center; gap: 14px;
        }
        .sc:nth-child(1){ animation-delay:0.05s }
        .sc:nth-child(2){ animation-delay:0.10s }
        .sc:nth-child(3){ animation-delay:0.15s }
        .sc:nth-child(4){ animation-delay:0.20s }
        @keyframes cardIn {
            from { opacity:0; transform:translateY(16px); }
            to   { opacity:1; transform:translateY(0); }
        }
        .sc:hover { transform: translateY(-3px); box-shadow: 0 12px 32px rgba(0,0,0,0.25); }
        .sc::before {
            content:''; position:absolute;
            top:0; left:16px; right:16px; height:1px;
        }
        .sc::after {
            content:''; position:absolute;
            top:0; right:0; bottom:0;
            width:3px; border-radius:0 16px 16px 0;
        }
        .sc-blue::before   { background:linear-gradient(90deg,transparent,var(--accent-2),transparent); }
        .sc-blue::after    { background:linear-gradient(180deg,var(--accent),transparent); }
        .sc-info::before   { background:linear-gradient(90deg,transparent,var(--info),transparent); }
        .sc-info::after    { background:linear-gradient(180deg,var(--info),transparent); }
        .sc-amber::before  { background:linear-gradient(90deg,transparent,var(--amber),transparent); }
        .sc-amber::after   { background:linear-gradient(180deg,var(--amber),transparent); }
        .sc-green::before  { background:linear-gradient(90deg,transparent,var(--green),transparent); }
        .sc-green::after   { background:linear-gradient(180deg,var(--green),transparent); }

        .sc-icon {
            width: 42px; height: 42px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem; flex-shrink: 0;
        }
        .sc-blue  .sc-icon { background:rgba(79,126,248,0.12); color:var(--accent-2); }
        .sc-info  .sc-icon { background:var(--info-dim);       color:var(--info); }
        .sc-amber .sc-icon { background:var(--amber-dim);      color:var(--amber); }
        .sc-green .sc-icon { background:var(--green-dim);      color:var(--green); }

        .sc-val { font-size:2rem; font-weight:800; color:#fff; line-height:1; letter-spacing:-1px; }
        .sc-lbl { color:var(--text-2); font-size:0.78rem; margin-top:4px; font-weight:500; }

        /* ── EQUIPMENT GRID ── */
        .eq-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
            gap: 16px;
        }
        .eq-card {
            background: rgba(17,26,66,0.7);
            border: 1.5px solid var(--border);
            border-radius: 16px;
            padding: 20px;
            backdrop-filter: blur(12px);
            transition: all 0.25s;
            position: relative; overflow: hidden;
            animation: cardIn 0.5s ease both;
        }
        .eq-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 32px rgba(0,0,0,0.3);
            border-color: rgba(79,126,248,0.35);
        }
        /* Left accent bar on hover */
        .eq-card::before {
            content:''; position:absolute;
            left:0; top:0; bottom:0; width:3px;
            background: linear-gradient(180deg, var(--accent), var(--purple));
            opacity:0; transition:opacity 0.25s;
            border-radius:16px 0 0 16px;
        }
        .eq-card:hover::before { opacity:1; }

        .eq-card-top {
            display: flex; justify-content: space-between; align-items: flex-start;
            margin-bottom: 14px;
        }
        .eq-icon-wrap {
            width: 46px; height: 46px; border-radius: 13px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.2rem; flex-shrink: 0;
        }
        .eq-icon-int { background: rgba(79,126,248,0.15); color: var(--accent-2); }
        .eq-icon-ext { background: var(--amber-dim); color: var(--amber); }

        .eq-tags { display: flex; flex-direction: column; align-items: flex-end; gap: 5px; }
        .tag {
            padding: 2px 8px; border-radius: 5px;
            font-size: 0.68rem; font-weight: 700;
        }
        .tag-int  { background:rgba(79,126,248,0.12); color:var(--accent-2); }
        .tag-ext  { background:var(--amber-dim);      color:var(--amber); }
        .tag-wok  { background:var(--green-dim);      color:var(--green); }
        .tag-wexp { background:var(--danger-dim);     color:var(--danger); }

        .eq-model {
            font-size: 0.94rem; font-weight: 700;
            color: var(--text); margin-bottom: 4px; line-height: 1.3;
        }
        .eq-cat {
            font-size: 0.74rem; color: var(--accent-2);
            font-weight: 600; margin-bottom: 12px;
            display: flex; align-items: center; gap: 4px;
        }
        .eq-details { display: flex; flex-direction: column; gap: 6px; }
        .eq-detail-row {
            display: flex; align-items: center; gap: 7px;
            font-size: 0.79rem; color: var(--text-2);
        }
        .eq-detail-row i { width: 13px; font-size: 0.74rem; color: var(--muted); flex-shrink: 0; }
        .eq-serial { font-family: 'Courier New', monospace; color: var(--text-2); font-size: 0.8rem; }

        /* Card footer */
        .eq-card-foot {
            margin-top: 16px; padding-top: 14px;
            border-top: 1px solid var(--border);
            display: flex; gap: 8px;
        }
        .btn-fix {
            display: inline-flex; align-items: center; justify-content: center; gap: 6px;
            padding: 8px 14px; border-radius: 9px;
            background: linear-gradient(135deg, var(--accent), var(--purple));
            color: #fff; text-decoration: none;
            font-size: 0.78rem; font-weight: 700;
            flex: 1; transition: all 0.2s;
            box-shadow: 0 3px 12px rgba(79,126,248,0.3);
        }
        .btn-fix:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(79,126,248,0.5); }

        .btn-fix-icon {
            display: inline-flex; align-items: center; justify-content: center;
            padding: 8px 12px; border-radius: 9px;
            background: rgba(255,255,255,0.05);
            border: 1.5px solid var(--border);
            color: var(--muted); text-decoration: none;
            font-size: 0.82rem; transition: all 0.2s; flex-shrink: 0;
        }
        .btn-fix-icon:hover { background: rgba(167,139,250,0.1); border-color: rgba(167,139,250,0.3); color: var(--purple); }

        /* ── EMPTY STATE ── */
        .empty {
            text-align: center; padding: 56px 24px;
            color: var(--muted); font-size: 0.84rem;
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s ease both;
        }
        .empty i { font-size: 2.5rem; display: block; margin-bottom: 14px; opacity: 0.2; }
        .empty a {
            color: var(--accent-2); font-weight: 700;
            text-decoration: none; display: inline-block; margin-top: 10px;
        }
        .empty a:hover { color: #fff; }
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
            <a href="<%=ctx%>/customerContracts" class="sb-item si-contract">
                <i class="fas fa-file-contract"></i> Contracts
            </a>
            <a href="<%=ctx%>/customerEquipment" class="sb-item on si-equip">
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
                    <i class="fas fa-desktop" style="color:var(--info);margin-right:8px;font-size:1rem"></i>
                    My Equipment
                </div>
                <div class="topbar-sub">
                    List of equipment you currently own — both purchased within the system and from outside
                </div>
            </div>
        </div>

        <div class="content">

            <%-- Info bar --%>
            <div class="info-bar">
                <i class="fas fa-info-circle"></i>
                <span>To add equipment to your profile, please contact a support agent via
                    <a href="<%=ctx%>/customerChat">Support Chat</a>.</span>
            </div>

            <%-- Stats --%>
            <div class="section-lbl">Overview</div>
            <div class="stats">
                <div class="sc sc-blue">
                    <div class="sc-icon"><i class="fas fa-desktop"></i></div>
                    <div>
                        <div class="sc-val"><%=totalEq%></div>
                        <div class="sc-lbl">Total Equipment</div>
                    </div>
                </div>
                <div class="sc sc-info">
                    <div class="sc-icon"><i class="fas fa-database"></i></div>
                    <div>
                        <div class="sc-val"><%=internalEq%></div>
                        <div class="sc-lbl">Purchased In-System</div>
                    </div>
                </div>
                <div class="sc sc-amber">
                    <div class="sc-icon"><i class="fas fa-store"></i></div>
                    <div>
                        <div class="sc-val"><%=externalEq%></div>
                        <div class="sc-lbl">Purchased Externally</div>
                    </div>
                </div>
                <div class="sc sc-green">
                    <div class="sc-icon"><i class="fas fa-shield-alt"></i></div>
                    <div>
                        <div class="sc-val"><%=underWarranty%></div>
                        <div class="sc-lbl">Under Warranty</div>
                    </div>
                </div>
            </div>

            <%-- Equipment list --%>
            <div class="section-lbl">Equipment</div>

            <%if(equipmentList.isEmpty()){%>
            <div class="empty">
                <i class="fas fa-desktop"></i>
                You have no equipment in your profile yet.
                <a href="<%=ctx%>/customerChat">Contact support to add equipment →</a>
            </div>
            <%}else{%>
            <div class="eq-grid">
                <%for(CustomerEquipment eq:equipmentList){
                    boolean isInternal="INTERNAL".equals(eq.getSource());
                    boolean underW=eq.isUnderWarranty();
                %>
                <div class="eq-card">
                    <div class="eq-card-top">
                        <div class="eq-icon-wrap <%=isInternal?"eq-icon-int":"eq-icon-ext"%>">
                            <i class="fas fa-desktop"></i>
                        </div>
                        <div class="eq-tags">
                            <span class="tag <%=isInternal?"tag-int":"tag-ext"%>">
                                <%=isInternal?"In-System":"External"%>
                            </span>
                            <%if(eq.getWarrantyExpires()!=null){%>
                            <span class="tag <%=underW?"tag-wok":"tag-wexp"%>">
                                <%=underW?"In Warranty":"Expired"%>
                            </span>
                            <%}%>
                        </div>
                    </div>

                    <div class="eq-model"><%=eq.getDisplayName()%></div>
                    <%if(eq.getCategoryName()!=null){%>
                    <div class="eq-cat">
                        <i class="fas fa-tag" style="font-size:.68rem"></i> <%=eq.getCategoryName()%>
                    </div>
                    <%}%>

                    <div class="eq-details">
                        <div class="eq-detail-row">
                            <i class="fas fa-barcode"></i>
                            <span class="eq-serial"><%=eq.getDisplaySerial()%></span>
                        </div>
                        <%if(eq.getPurchasedDate()!=null){%>
                        <div class="eq-detail-row">
                            <i class="fas fa-shopping-cart"></i>
                            <span>Purchased: <%=eq.getPurchasedDate()%></span>
                        </div>
                        <%}%>
                        <%if(eq.getWarrantyExpires()!=null){%>
                        <div class="eq-detail-row">
                            <i class="fas fa-shield-alt" style="color:<%=underW?"var(--green)":"var(--danger)"%>"></i>
                            <span style="color:<%=underW?"var(--green)":"var(--danger)"%>;font-weight:<%=underW?"500":"600"%>">
                                Warranty <%=underW?"until":"expired on"%>: <%=eq.getWarrantyExpires()%>
                            </span>
                        </div>
                        <%}%>
                        <%if(eq.getNotes()!=null&&!eq.getNotes().isEmpty()){%>
                        <div class="eq-detail-row">
                            <i class="fas fa-sticky-note"></i>
                            <span style="color:var(--muted)"><%=eq.getNotes()%></span>
                        </div>
                        <%}%>
                    </div>

                    <div class="eq-card-foot">
                        <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-fix">
                            <i class="fas fa-tools"></i> Create Repair Request
                        </a>
                        <a href="<%=ctx%>/customerContracts" class="btn-fix-icon" title="View Contracts">
                            <i class="fas fa-file-contract"></i>
                        </a>
                    </div>
                </div>
                <%}%>
            </div>
            <%}%>

        </div>
    </main>
<%@ include file="customerAIBubble.jsp" %>
</body>
</html>
