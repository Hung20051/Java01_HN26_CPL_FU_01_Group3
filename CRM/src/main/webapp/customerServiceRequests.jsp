<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<ServiceRequest> list=(List<ServiceRequest>)request.getAttribute("serviceRequests"); if(list==null)list=new ArrayList<>();
    int totalSR=(Integer)nvl(request.getAttribute("totalSR"),0);
    int pendingCount=(Integer)nvl(request.getAttribute("pendingCount"),0);
    int activeCount=(Integer)nvl(request.getAttribute("activeCount"),0);
    int completedCount=(Integer)nvl(request.getAttribute("completedCount"),0);
    String filterStatus=(String)nvl(request.getAttribute("filterStatus"),"");
    String filterPriority=(String)nvl(request.getAttribute("filterPriority"),"");
    String filterFrom=(String)nvl(request.getAttribute("filterFrom"),"");
    String filterTo=(String)nvl(request.getAttribute("filterTo"),"");
    String flashOk=(String)session.getAttribute("flashSuccess"); session.removeAttribute("flashSuccess");
    String flashErr=(String)session.getAttribute("flashError");  session.removeAttribute("flashError");
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int unpaidInv=0; // sidebar badge placeholder
    int unreadChat=0;
    int pendingSR=pendingCount;
    String initials = me.getFullName()!=null&&!me.getFullName().isEmpty()?me.getFullName().substring(0,1).toUpperCase():"?";
%><%!
    Object nvl(Object v,Object def){return v!=null?v:def;}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Repair Requests - DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --navy:        #0b1437;
            --navy-card:   #111a42;
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
            --sb-width:    248px;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
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

        /* ════ SIDEBAR ════ */
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
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 0.88rem;
            box-shadow: 0 4px 14px var(--accent-glow); flex-shrink: 0;
        }
        .sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
        .sb-role {
            display: inline-flex; align-items: center;
            background: rgba(79,126,248,0.15); border: 1px solid rgba(79,126,248,0.25);
            color: var(--accent-2); font-size: 0.62rem; font-weight: 700;
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
            transition: all 0.2s; position: relative;
            border-left: 2px solid transparent;
        }
        .sb-item i {
            width: 28px; height: 28px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.8rem; border-radius: 8px;
            background: rgba(255,255,255,0.05); flex-shrink: 0; transition: all 0.2s;
        }
        .sb-item.on { color: #fff; background: linear-gradient(90deg,rgba(79,126,248,0.2),rgba(79,126,248,0.05)); border-left: 2px solid var(--accent); }
        .sb-item.on i { background: rgba(79,126,248,0.25); color: var(--accent-2); }

        .sb-item.si-home:hover       { color:#fff; background:rgba(79,126,248,0.1);    border-left-color:var(--accent); }
        .sb-item.si-home:hover i     { background:rgba(79,126,248,0.2);    color:var(--accent-2); }
        .sb-item.si-repair:hover     { color:#fff; background:rgba(251,191,36,0.08);   border-left-color:var(--amber); }
        .sb-item.si-repair:hover i   { background:rgba(251,191,36,0.18);   color:var(--amber); }
        .sb-item.si-contract:hover   { color:#fff; background:rgba(167,139,250,0.08);  border-left-color:var(--purple); }
        .sb-item.si-contract:hover i { background:rgba(167,139,250,0.18);  color:var(--purple); }
        .sb-item.si-equip:hover      { color:#fff; background:rgba(56,189,248,0.08);   border-left-color:var(--info); }
        .sb-item.si-equip:hover i    { background:rgba(56,189,248,0.18);   color:var(--info); }
        .sb-item.si-parts:hover      { color:#fff; background:rgba(52,211,153,0.07);   border-left-color:var(--green); }
        .sb-item.si-parts:hover i    { background:rgba(52,211,153,0.18);   color:var(--green); }
        .sb-item.si-shop:hover       { color:#fff; background:rgba(56,189,248,0.07);   border-left-color:var(--info); }
        .sb-item.si-shop:hover i     { background:rgba(56,189,248,0.18);   color:var(--info); }
        .sb-item.si-cart:hover       { color:#fff; background:rgba(251,146,60,0.08);   border-left-color:#fb923c; }
        .sb-item.si-cart:hover i     { background:rgba(251,146,60,0.18);   color:#fb923c; }
        .sb-item.si-invoice:hover    { color:#fff; background:rgba(52,211,153,0.07);   border-left-color:var(--green); }
        .sb-item.si-invoice:hover i  { background:rgba(52,211,153,0.18);   color:var(--green); }
        .sb-item.si-chat:hover       { color:#fff; background:rgba(251,113,133,0.08);  border-left-color:#fb7185; }
        .sb-item.si-chat:hover i     { background:rgba(251,113,133,0.18);  color:#fb7185; }

        .sb-badge {
            margin-left: auto; background: var(--danger);
            color: #fff; font-size: 0.62rem; font-weight: 700;
            padding: 2px 6px; border-radius: 20px;
            animation: badgePop 2s ease-in-out infinite;
        }
        @keyframes badgePop { 0%,100%{transform:scale(1)} 50%{transform:scale(1.1)} }
        .sb-foot { padding: 12px 10px 16px; border-top: 1px solid var(--border); }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px; border-radius: 10px;
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
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

        /* ════ MAIN ════ */
        .main { margin-left: var(--sb-width); flex: 1; min-height: 100vh; display: flex; flex-direction: column; }

        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 22px 32px; border-bottom: 1px solid var(--border);
            background: rgba(11,20,55,0.6); backdrop-filter: blur(16px);
            position: sticky; top: 0; z-index: 50;
        }
        .topbar-title { font-size: 1.2rem; font-weight: 800; color: #fff; letter-spacing: -0.3px; display: flex; align-items: center; gap: 10px; }
        .topbar-title i { color: var(--amber); font-size: 1rem; }
        .topbar-sub { color: var(--muted); font-size: 0.8rem; margin-top: 2px; font-weight: 300; }
        .btn-cta {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 11px 22px;
            background: linear-gradient(135deg, #4f7ef8, #a78bfa);
            color: #fff; text-decoration: none;
            font-size: 0.84rem; font-weight: 700; border-radius: 11px;
            box-shadow: 0 4px 20px rgba(79,126,248,0.4);
            transition: all 0.25s;
            animation: ctaPulse 3s ease-in-out infinite;
            border: none; cursor: pointer; font-family: 'Sora', sans-serif;
        }
        @keyframes ctaPulse {
            0%,100%{ box-shadow:0 4px 20px rgba(79,126,248,0.35); }
            50%     { box-shadow:0 4px 32px rgba(79,126,248,0.65),0 0 0 5px rgba(79,126,248,0.08); }
        }
        .btn-cta:hover { transform: translateY(-2px); box-shadow: 0 10px 32px rgba(79,126,248,0.55); animation: none; }

        .content { padding: 28px 32px; flex: 1; }

        /* Alerts */
        .alert {
            display: flex; align-items: center; gap: 10px;
            padding: 12px 16px; border-radius: 12px;
            font-size: 0.84rem; font-weight: 500; margin-bottom: 18px;
            animation: cardIn 0.4s ease both;
        }
        .alert-ok  { background: var(--green-dim);  border: 1px solid rgba(52,211,153,0.25);  color: var(--green); }
        .alert-err { background: var(--danger-dim);  border: 1px solid rgba(248,113,113,0.25); color: var(--danger); }

        /* Section label */
        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 12px;
        }

        /* Stats */
        .stats { display: grid; grid-template-columns: repeat(4,1fr); gap: 14px; margin-bottom: 24px; }
        .sc {
            background: rgba(17,26,66,0.7); border: 1px solid var(--border);
            border-radius: 16px; padding: 18px 20px;
            display: flex; align-items: center; gap: 14px;
            backdrop-filter: blur(12px); transition: all 0.25s;
            position: relative; overflow: hidden;
            animation: cardIn 0.5s ease both;
        }
        .sc:nth-child(1){ animation-delay:0.05s } .sc:nth-child(2){ animation-delay:0.1s }
        .sc:nth-child(3){ animation-delay:0.15s } .sc:nth-child(4){ animation-delay:0.2s }
        @keyframes cardIn { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:translateY(0)} }
        .sc:hover { transform: translateY(-2px); box-shadow: 0 10px 28px rgba(0,0,0,0.25); }
        .sc::after {
            content:''; position:absolute; top:0; right:0; bottom:0;
            width:3px; border-radius:0 16px 16px 0;
        }
        .sc-purple::after { background:linear-gradient(180deg,var(--purple),transparent); }
        .sc-amber::after  { background:linear-gradient(180deg,var(--amber),transparent); }
        .sc-info::after   { background:linear-gradient(180deg,var(--info),transparent); }
        .sc-green::after  { background:linear-gradient(180deg,var(--green),transparent); }
        .sc::before {
            content:''; position:absolute; top:0; left:16px; right:16px; height:1px;
        }
        .sc-purple::before { background:linear-gradient(90deg,transparent,var(--purple),transparent); }
        .sc-amber::before  { background:linear-gradient(90deg,transparent,var(--amber),transparent); }
        .sc-info::before   { background:linear-gradient(90deg,transparent,var(--info),transparent); }
        .sc-green::before  { background:linear-gradient(90deg,transparent,var(--green),transparent); }

        .sc-icon {
            width: 42px; height: 42px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem; flex-shrink: 0;
        }
        .sc-purple .sc-icon { background:var(--purple-dim); color:var(--purple); }
        .sc-amber  .sc-icon { background:var(--amber-dim);  color:var(--amber); }
        .sc-info   .sc-icon { background:var(--info-dim);   color:var(--info); }
        .sc-green  .sc-icon { background:var(--green-dim);  color:var(--green); }
        .sc-val { font-size: 1.8rem; font-weight: 800; color: #fff; line-height: 1; letter-spacing: -1px; }
        .sc-lbl { color: var(--text-2); font-size: 0.75rem; margin-top: 4px; }

        /* Filter card */
        .filter-card {
            background: rgba(17,26,66,0.7); border: 1px solid var(--border);
            border-radius: 14px; padding: 16px 20px; margin-bottom: 18px;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s 0.2s ease both;
        }
        .filter-row { display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }
        .f-sel, .f-date {
            padding: 9px 12px; border: 1px solid var(--border);
            border-radius: 10px; font-size: 0.82rem;
            font-family: 'Sora', sans-serif; outline: none;
            background: rgba(255,255,255,0.05);
            color: var(--text); transition: all 0.2s;
        }
        .f-sel option { background: #0f1c4d; color: #fff; }
        .f-sel:focus, .f-date:focus {
            border-color: rgba(79,126,248,0.5);
            background: rgba(79,126,248,0.07);
            box-shadow: 0 0 0 3px rgba(79,126,248,0.1);
        }
        .f-date::-webkit-calendar-picker-indicator { filter: invert(0.6); cursor: pointer; }

        .btn-filter {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 9px 16px; border-radius: 10px;
            font-size: 0.82rem; font-weight: 600;
            border: none; cursor: pointer; font-family: 'Sora', sans-serif;
            transition: all 0.2s;
        }
        .btn-filter-blue {
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            color: #fff; box-shadow: 0 4px 14px var(--accent-glow);
        }
        .btn-filter-blue:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(79,126,248,0.45); }
        .btn-filter-reset {
            background: rgba(255,255,255,0.07); color: var(--text-2);
            border: 1px solid var(--border); text-decoration: none;
        }
        .btn-filter-reset:hover { background: rgba(255,255,255,0.12); color: #fff; }

        /* Table card */
        .tbl-card {
            background: rgba(17,26,66,0.7); border: 1px solid var(--border);
            border-radius: 16px; overflow: hidden; backdrop-filter: blur(12px);
            animation: cardIn 0.5s 0.25s ease both;
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
            padding: 13px 16px; border-bottom: 1px solid rgba(255,255,255,0.03);
            vertical-align: middle; color: var(--text-2);
        }
        tr:last-child td { border-bottom: none; }
        tbody tr { transition: background 0.15s; }
        tbody tr:hover td { background: rgba(79,126,248,0.05); }

        /* Badges */
        .b {
            display: inline-flex; align-items: center;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            white-space: nowrap; letter-spacing: 0.2px;
        }
        .b-pending    { background:rgba(251,191,36,0.12);  color:#fbbf24; border:1px solid rgba(251,191,36,0.2); }
        .b-approved   { background:rgba(52,211,153,0.1);   color:#34d399; border:1px solid rgba(52,211,153,0.2); }
        .b-rejected   { background:rgba(248,113,113,0.1);  color:#f87171; border:1px solid rgba(248,113,113,0.2); }
        .b-inprogress { background:rgba(79,126,248,0.12);  color:#7c9ffa; border:1px solid rgba(79,126,248,0.2); }
        .b-completed  { background:rgba(167,139,250,0.12); color:#a78bfa; border:1px solid rgba(167,139,250,0.2); }
        .b-cancelled  { background:rgba(255,255,255,0.05); color:var(--muted); border:1px solid var(--border); }
        .b-low        { background:rgba(52,211,153,0.08);  color:#6ee7b7; border:1px solid rgba(52,211,153,0.15); }
        .b-medium     { background:rgba(251,191,36,0.1);   color:#fcd34d; border:1px solid rgba(251,191,36,0.2); }
        .b-high       { background:rgba(251,146,60,0.1);   color:#fb923c; border:1px solid rgba(251,146,60,0.2); }
        .b-urgent     { background:rgba(248,113,113,0.12); color:#fca5a5; border:1px solid rgba(248,113,113,0.2); }

        /* Contract tag */
        .ct-tag {
            display: inline-block; padding: 2px 7px;
            border-radius: 5px; font-size: 0.68rem; font-weight: 700;
        }
        .ct-wr { background:rgba(52,211,153,0.12); color:#34d399; }
        .ct-mt { background:rgba(79,126,248,0.12); color:#7c9ffa; }

        /* Code link */
        .code-link {
            color: var(--accent-2); font-weight: 700;
            font-size: 0.77rem; font-family: 'Courier New', monospace;
            text-decoration: none;
        }
        .code-link:hover { color: #fff; }

        /* Action buttons */
        .btn-view {
            padding: 5px 11px; border-radius: 7px;
            font-size: 0.75rem; font-weight: 600;
            background: rgba(79,126,248,0.15);
            color: var(--accent-2); text-decoration: none;
            display: inline-flex; align-items: center; gap: 4px;
            border: 1px solid rgba(79,126,248,0.25);
            transition: all 0.2s;
        }
        .btn-view:hover { background: rgba(79,126,248,0.28); color: #fff; transform: translateY(-1px); }

        .btn-cancel {
            padding: 5px 11px; border-radius: 7px;
            font-size: 0.75rem; font-weight: 600;
            background: var(--danger-dim); color: var(--danger);
            border: 1px solid rgba(248,113,113,0.25);
            cursor: pointer; font-family: 'Sora', sans-serif;
            display: inline-flex; align-items: center; gap: 4px;
            transition: all 0.2s;
        }
        .btn-cancel:hover { background: rgba(248,113,113,0.22); transform: translateY(-1px); }

        /* Empty */
        .empty { text-align: center; padding: 48px 24px; color: var(--muted); font-size: 0.84rem; }
        .empty i { font-size: 2.2rem; display: block; margin-bottom: 10px; opacity: 0.2; }
        .empty a { color: var(--accent-2); font-weight: 700; text-decoration: none; display: inline-block; margin-top: 8px; }
        .empty a:hover { color: #fff; }

        .td-muted { color: var(--muted); font-size: 0.75rem; }
        .td-mono  { font-family:'Courier New',monospace; font-size:0.77rem; font-weight:700; color:var(--text-2); }
    </style>
</head>
<body>

    <%-- ═══ SIDEBAR ═══ --%>
    <aside class="sb">
        <div class="sb-brand">
            <div class="sb-logo"><i class="fas fa-bolt"></i></div>
            <div><div class="sb-name">DRSMS</div><div class="sb-role">Customer</div></div>
        </div>
        <nav class="sb-nav">
            <div class="sb-lbl">Overview</div>
            <a href="<%=ctx%>/customerDashboard" class="sb-item si-home"><i class="fas fa-home"></i> Dashboard</a>

            <div class="sb-lbl">Services</div>
            <a href="<%=ctx%>/customerServiceRequests" class="sb-item on si-repair">
                <i class="fas fa-clipboard-list"></i> Repair Requests
                <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
            </a>
            <a href="<%=ctx%>/customerContracts"   class="sb-item si-contract"><i class="fas fa-file-contract"></i> Contracts</a>
            <a href="<%=ctx%>/customerEquipment"   class="sb-item si-equip"><i class="fas fa-desktop"></i> My Equipment</a>

            <div class="sb-lbl">Shop</div>
            <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item si-parts"><i class="fas fa-puzzle-piece"></i> Parts</a>
            <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item si-shop"><i class="fas fa-server"></i> Equipment</a>
            <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item si-cart">
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
                <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer Account</div></div>
            </a>
            <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
        </div>
    </aside>

    <%-- ═══ MAIN ═══ --%>
    <main class="main">
        <div class="topbar">
            <div>
                <div class="topbar-title"><i class="fas fa-clipboard-list"></i> Repair Requests</div>
                <div class="topbar-sub">Create and track your equipment repair requests</div>
            </div>
            <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-cta">
                <i class="fas fa-plus"></i> Create New Request
            </a>
        </div>

        <div class="content">

            <%if(flashOk!=null){%>
            <div class="alert alert-ok"><i class="fas fa-check-circle"></i> <%=flashOk%></div>
            <%}%>
            <%if(flashErr!=null){%>
            <div class="alert alert-err"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div>
            <%}%>

            <%-- Stats --%>
            <div class="section-lbl">Overview</div>
            <div class="stats">
                <div class="sc sc-purple">
                    <div class="sc-icon"><i class="fas fa-list"></i></div>
                    <div><div class="sc-val"><%=totalSR%></div><div class="sc-lbl">Total Requests</div></div>
                </div>
                <div class="sc sc-amber">
                    <div class="sc-icon"><i class="fas fa-clock"></i></div>
                    <div><div class="sc-val"><%=pendingCount%></div><div class="sc-lbl">Pending Approval</div></div>
                </div>
                <div class="sc sc-info">
                    <div class="sc-icon"><i class="fas fa-spinner"></i></div>
                    <div><div class="sc-val"><%=activeCount%></div><div class="sc-lbl">In Progress</div></div>
                </div>
                <div class="sc sc-green">
                    <div class="sc-icon"><i class="fas fa-circle-check"></i></div>
                    <div><div class="sc-val"><%=completedCount%></div><div class="sc-lbl">Completed</div></div>
                </div>
            </div>

            <%-- Filter --%>
            <div class="section-lbl">Filter</div>
            <div class="filter-card">
                <form method="get" action="<%=ctx%>/customerServiceRequests">
                    <div class="filter-row">
                        <select class="f-sel" name="status">
                            <option value="" <%=filterStatus.isEmpty()?"selected":""%>>All Statuses</option>
                            <option value="PENDING"     <%="PENDING".equals(filterStatus)?"selected":""%>>Pending Approval</option>
                            <option value="APPROVED"    <%="APPROVED".equals(filterStatus)?"selected":""%>>Approved</option>
                            <option value="REJECTED"    <%="REJECTED".equals(filterStatus)?"selected":""%>>Rejected</option>
                            <option value="IN_PROGRESS" <%="IN_PROGRESS".equals(filterStatus)?"selected":""%>>In Progress</option>
                            <option value="COMPLETED"   <%="COMPLETED".equals(filterStatus)?"selected":""%>>Completed</option>
                            <option value="CANCELLED"   <%="CANCELLED".equals(filterStatus)?"selected":""%>>Cancelled</option>
                        </select>
                        <select class="f-sel" name="priority">
                            <option value="" <%=filterPriority.isEmpty()?"selected":""%>>All Priorities</option>
                            <option value="LOW"    <%="LOW".equals(filterPriority)?"selected":""%>>Low</option>
                            <option value="MEDIUM" <%="MEDIUM".equals(filterPriority)?"selected":""%>>Medium</option>
                            <option value="HIGH"   <%="HIGH".equals(filterPriority)?"selected":""%>>High</option>
                            <option value="URGENT" <%="URGENT".equals(filterPriority)?"selected":""%>>Urgent</option>
                        </select>
                        <input type="date" class="f-date" name="fromDate" value="<%=filterFrom%>">
                        <input type="date" class="f-date" name="toDate"   value="<%=filterTo%>">
                        <button type="submit" class="btn-filter btn-filter-blue">
                            <i class="fas fa-search"></i> Filter
                        </button>
                        <a href="<%=ctx%>/customerServiceRequests" class="btn-filter btn-filter-reset">
                            <i class="fas fa-rotate-left"></i> Reset
                        </a>
                    </div>
                </form>
            </div>

            <%-- Table --%>
            <div class="section-lbl">Requests List</div>
            <div class="tbl-card">
                <%if(list.isEmpty()){%>
                <div class="empty">
                    <i class="fas fa-clipboard"></i>
                    No repair requests found.
                    <a href="<%=ctx%>/customerServiceRequests?action=create">+ Create your first request</a>
                </div>
                <%}else{%>
                <table>
                    <thead>
                        <tr>
                            <th>Request Code</th>
                            <th>Title</th>
                            <th>Contract</th>
                            <th>Priority</th>
                            <th>Status</th>
                            <th>Technician</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%for(ServiceRequest sr:list){
                        String sc="b-pending";
                        if("APPROVED".equals(sr.getStatus()))    sc="b-approved";
                        else if("REJECTED".equals(sr.getStatus()))   sc="b-rejected";
                        else if("IN_PROGRESS".equals(sr.getStatus())) sc="b-inprogress";
                        else if("COMPLETED".equals(sr.getStatus()))   sc="b-completed";
                        else if("CANCELLED".equals(sr.getStatus()))   sc="b-cancelled";
                        String pc="b-medium";
                        if("LOW".equals(sr.getPriority()))    pc="b-low";
                        else if("HIGH".equals(sr.getPriority()))   pc="b-high";
                        else if("URGENT".equals(sr.getPriority())) pc="b-urgent";
                    %>
                    <tr>
                        <td>
                            <a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=sr.getId()%>" class="code-link">
                                <%=sr.getRequestCode()%>
                            </a>
                        </td>
                        <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
                            <%=sr.getTitle()%>
                        </td>
                        <td>
                            <div class="td-mono"><%=sr.getContractCode()%></div>
                            <span class="ct-tag <%="WARRANTY".equals(sr.getContractType())?"ct-wr":"ct-mt"%>">
                                <%="WARRANTY".equals(sr.getContractType())?"Warranty":"Maintenance"%>
                            </span>
                        </td>
                        <td><span class="b <%=pc%>"><%=sr.getPriorityLabel()%></span></td>
                        <td><span class="b <%=sc%>"><%=sr.getStatusLabel()%></span></td>
                        <td class="td-muted"><%=sr.getAssignedToName()!=null?sr.getAssignedToName():"—"%></td>
                        <td class="td-muted"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toLocalDate():"—"%></td>
                        <td>
                            <div style="display:flex;gap:6px;align-items:center">
                                <a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=sr.getId()%>" class="btn-view">
                                    <i class="fas fa-eye"></i> View
                                </a>
                                <%if("PENDING".equals(sr.getStatus())){%>
                                <form method="post" action="<%=ctx%>/customerServiceRequests" style="display:inline"
                                      onsubmit="return confirm('Cancel this request?')">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="id" value="<%=sr.getId()%>">
                                    <button type="submit" class="btn-cancel">
                                        <i class="fas fa-xmark"></i> Cancel
                                    </button>
                                </form>
                                <%}%>
                            </div>
                        </td>
                    </tr>
                    <%}%>
                    </tbody>
                </table>
                <%}%>
            </div>

        </div>
    </main>
            <%@ include file="customerAIBubble.jsp" %>
</body>
</html>
