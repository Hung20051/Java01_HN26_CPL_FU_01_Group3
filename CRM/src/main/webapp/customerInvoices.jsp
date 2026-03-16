<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*,java.math.BigDecimal" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<Invoice> invoices=(List<Invoice>)request.getAttribute("invoices"); if(invoices==null)invoices=new ArrayList<>();
    Map<String,Object> sum=(Map<String,Object>)request.getAttribute("summary"); if(sum==null)sum=new HashMap<>();
    String filterStatus=(String)request.getAttribute("filterStatus"); if(filterStatus==null)filterStatus="";
    String ctx=request.getContextPath();
    int cartCount   = session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int pendingSR   = request.getAttribute("pendingSR")  !=null?(int)request.getAttribute("pendingSR")  :0;
    int unreadChat  = request.getAttribute("unreadChat") !=null?(int)request.getAttribute("unreadChat") :0;
    int total  =(Integer)nvl(sum.get("total"),0);
    int unpaid =(Integer)nvl(sum.get("unpaid"),0);
    int paid   =(Integer)nvl(sum.get("paid"),0);
    BigDecimal unpaidAmt=(BigDecimal)sum.get("unpaidAmt");
    java.text.NumberFormat nf=java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
    String initials = me.getFullName()!=null&&!me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%><%! Object nvl(Object v,Object d){return v!=null?v:d;} %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Invoices - DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --navy:        #0b1437;
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
            --orange:      #fb923c;
            --orange-dim:  rgba(251,146,60,0.12);
            --text:        #ffffff;
            --text-2:      #c8d4f0;
            --muted:       #7a8ab8;
            --border:      rgba(255,255,255,0.07);
            --border-2:    rgba(255,255,255,0.04);
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

        /* ════════════════════ SIDEBAR ════════════════════ */
        .sb {
            width: var(--sb-width); min-height: 100vh;
            background: rgba(9,15,40,0.95); backdrop-filter: blur(20px);
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
            background: linear-gradient(90deg, rgba(52,211,153,0.18), rgba(52,211,153,0.05));
            border-left: 2px solid var(--green);
        }
        .sb-item.on i { background: rgba(52,211,153,0.2); color: var(--green); }
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
        .sb-item.si-cart:hover       { color:#fff; background:rgba(251,146,60,0.08); border-left-color:var(--orange); }
        .sb-item.si-cart:hover i     { background:rgba(251,146,60,0.18); color:var(--orange); }
        .sb-item.si-invoice:hover    { color:#fff; background:rgba(52,211,153,0.07); border-left-color:var(--green); }
        .sb-item.si-invoice:hover i  { background:rgba(52,211,153,0.18); color:var(--green); }
        .sb-item.si-chat:hover       { color:#fff; background:rgba(251,113,133,0.08);border-left-color:#fb7185; }
        .sb-item.si-chat:hover i     { background:rgba(251,113,133,0.18);color:#fb7185; }

        .sb-badge {
            margin-left: auto; background: var(--danger); color: #fff;
            font-size: 0.62rem; font-weight: 700;
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

        /* ════════════════════ MAIN ════════════════════ */
        .main { margin-left: var(--sb-width); flex: 1; min-height: 100vh; display: flex; flex-direction: column; }

        .topbar {
            display: flex; align-items: center;
            padding: 22px 32px;
            border-bottom: 1px solid var(--border);
            background: rgba(11,20,55,0.6); backdrop-filter: blur(16px);
            position: sticky; top: 0; z-index: 50;
        }
        .topbar-title { font-size: 1.25rem; font-weight: 800; color: #fff; letter-spacing: -0.3px; }
        .topbar-sub { color: var(--muted); font-size: 0.8rem; margin-top: 2px; font-weight: 300; }

        .content { padding: 28px 32px; flex: 1; }

        @keyframes cardIn { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }

        /* ── ALERT WARN ── */
        .alert-warn {
            display: flex; align-items: flex-start; gap: 12px;
            padding: 14px 18px;
            background: rgba(251,191,36,0.08);
            border: 1px solid rgba(251,191,36,0.2);
            border-radius: 13px; margin-bottom: 20px;
            font-size: 0.84rem; color: var(--amber);
            animation: cardIn 0.4s ease both;
        }
        .alert-warn a { color: var(--accent-2); font-weight: 700; }
        .alert-warn strong { color: var(--text); }

        /* ── STAT CARDS ── */
        .stats {
            display: grid; grid-template-columns: repeat(3,1fr);
            gap: 14px; margin-bottom: 20px;
        }
        .sm {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 14px; padding: 18px 20px;
            display: flex; align-items: center; gap: 14px;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s ease both;
            position: relative; overflow: hidden;
        }
        .sm::before {
            content: ''; position: absolute;
            top: 0; left: 0; right: 0; height: 2px;
        }
        .sm:nth-child(1)::before { background: linear-gradient(90deg, var(--accent), var(--accent-2)); }
        .sm:nth-child(2)::before { background: linear-gradient(90deg, var(--amber), var(--orange)); }
        .sm:nth-child(3)::before { background: linear-gradient(90deg, var(--green), var(--info)); }
        .sm-icon {
            width: 44px; height: 44px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem; flex-shrink: 0;
        }
        .sm-val { font-size: 1.65rem; font-weight: 800; color: var(--text); line-height: 1; }
        .sm-lbl { font-size: 0.73rem; color: var(--muted); margin-top: 3px; }

        /* ── FILTER ROW ── */
        .filter-row { display: flex; gap: 8px; margin-bottom: 16px; flex-wrap: wrap; }
        .f-btn {
            padding: 7px 16px; border-radius: 20px;
            font-size: 0.8rem; font-weight: 600;
            border: 1.5px solid var(--border);
            background: rgba(255,255,255,0.04);
            color: var(--muted); cursor: pointer;
            text-decoration: none; transition: all 0.2s;
            font-family: 'Sora', sans-serif;
        }
        .f-btn:hover { background: rgba(255,255,255,0.08); color: var(--text-2); border-color: rgba(255,255,255,0.15); }
        .f-btn.on {
            background: linear-gradient(135deg, var(--accent), var(--purple));
            border-color: transparent; color: #fff;
            box-shadow: 0 3px 12px rgba(79,126,248,0.3);
        }

        /* ── TABLE CARD ── */
        .tbl-card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px; overflow: hidden;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s 0.1s ease both;
        }
        table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
        thead tr { background: rgba(255,255,255,0.02); }
        th {
            padding: 11px 14px; text-align: left;
            color: var(--muted); font-weight: 600;
            font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.8px;
            border-bottom: 1px solid var(--border);
        }
        td {
            padding: 13px 14px;
            border-bottom: 1px solid var(--border-2);
            vertical-align: middle; color: var(--text-2);
        }
        tr:last-child td { border-bottom: none; }
        tbody tr { transition: background 0.15s; }
        tbody tr:hover td { background: rgba(79,126,248,0.04); }

        /* Invoice code link */
        .inv-code {
            color: var(--accent-2); font-weight: 700;
            font-family: monospace; font-size: 0.8rem;
            text-decoration: none;
        }
        .inv-code:hover { color: var(--accent); }

        /* Type badge */
        .type-badge {
            padding: 3px 9px; border-radius: 7px;
            font-size: 0.73rem; font-weight: 700;
            display: inline-flex; align-items: center; gap: 4px;
        }
        .type-repair { background: var(--purple-dim); color: var(--purple); }
        .type-shop   { background: var(--amber-dim);  color: var(--amber); }

        /* Status badges */
        .b {
            display: inline-flex; align-items: center;
            padding: 3px 10px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700;
        }
        .b-unpaid    { background: var(--amber-dim);  color: var(--amber); }
        .b-paid      { background: var(--green-dim);  color: var(--green); }
        .b-cancelled { background: rgba(255,255,255,0.07); color: var(--muted); }

        .amount { font-weight: 700; font-size: 0.88rem; }
        .amount-unpaid { color: var(--danger); }
        .amount-paid   { color: var(--text-2); }

        .due-overdue { color: var(--danger); font-weight: 700; }

        .ref-link {
            color: var(--accent-2); font-family: monospace;
            font-weight: 600; font-size: 0.78rem; text-decoration: none;
        }
        .ref-link:hover { color: var(--accent); }

        .btn-view {
            padding: 5px 13px; border-radius: 8px;
            font-size: 0.76rem; font-weight: 600;
            background: var(--accent-dim, rgba(79,126,248,0.12));
            color: var(--accent-2); text-decoration: none;
            display: inline-flex; align-items: center; gap: 5px;
            border: 1px solid rgba(79,126,248,0.2); transition: all 0.2s;
        }
        .btn-view:hover { background: rgba(79,126,248,0.22); color: #fff; }

        /* Empty */
        .empty {
            text-align: center; padding: 52px 24px;
            color: var(--muted); font-size: 0.84rem;
        }
        .empty i { font-size: 2.4rem; display: block; margin-bottom: 12px; opacity: 0.2; }
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
        <a href="<%=ctx%>/customerInvoices" class="sb-item on si-invoice">
            <i class="fas fa-receipt"></i> Invoices
            <%if(unpaid>0){%><span class="sb-badge"><%=unpaid%></span><%}%>
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

    <div class="topbar">
        <div>
            <div class="topbar-title">
                <i class="fas fa-receipt" style="color:var(--green);margin-right:8px;font-size:1rem"></i>
                Invoices
            </div>
            <div class="topbar-sub">Payment history and unpaid invoices</div>
        </div>
    </div>

    <div class="content">

        <%if(unpaid>0&&unpaidAmt!=null&&unpaidAmt.compareTo(BigDecimal.ZERO)>0){%>
        <div class="alert-warn">
            <i class="fas fa-exclamation-triangle" style="font-size:1rem;flex-shrink:0;margin-top:1px"></i>
            <div>You have <strong><%=unpaid%> unpaid invoice(s)</strong> totalling
                <strong><%=nf.format(unpaidAmt)%> ₫</strong>.
                Please contact <a href="<%=ctx%>/customerChat">a support agent</a> for payment assistance.
            </div>
        </div>
        <%}%>

        <%-- Stat cards --%>
        <div class="stats">
            <div class="sm">
                <div class="sm-icon" style="background:var(--info-dim);color:var(--info)">
                    <i class="fas fa-file-invoice"></i>
                </div>
                <div><div class="sm-val"><%=total%></div><div class="sm-lbl">Total Invoices</div></div>
            </div>
            <div class="sm">
                <div class="sm-icon" style="background:var(--amber-dim);color:var(--amber)">
                    <i class="fas fa-clock"></i>
                </div>
                <div><div class="sm-val"><%=unpaid%></div><div class="sm-lbl">Unpaid</div></div>
            </div>
            <div class="sm">
                <div class="sm-icon" style="background:var(--green-dim);color:var(--green)">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div><div class="sm-val"><%=paid%></div><div class="sm-lbl">Paid</div></div>
            </div>
        </div>

        <%-- Filter row --%>
        <div class="filter-row">
            <a href="<%=ctx%>/customerInvoices"                        class="f-btn <%=filterStatus.isEmpty()?"on":""%>">All</a>
            <a href="<%=ctx%>/customerInvoices?status=UNPAID"          class="f-btn <%="UNPAID".equals(filterStatus)?"on":""%>">Unpaid</a>
            <a href="<%=ctx%>/customerInvoices?status=PAID"            class="f-btn <%="PAID".equals(filterStatus)?"on":""%>">Paid</a>
            <a href="<%=ctx%>/customerInvoices?status=CANCELLED"       class="f-btn <%="CANCELLED".equals(filterStatus)?"on":""%>">Cancelled</a>
        </div>

        <%-- Table --%>
        <div class="tbl-card">
            <%if(invoices.isEmpty()){%>
            <div class="empty"><i class="fas fa-receipt"></i>No invoices found.</div>
            <%}else{%>
            <table>
                <thead>
                    <tr>
                        <th>Invoice #</th>
                        <th>Type</th>
                        <th>Reference</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Created</th>
                        <th>Due Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%for(Invoice inv:invoices){
                        String isc="b-unpaid";
                        if("PAID".equals(inv.getStatus()))       isc="b-paid";
                        else if("CANCELLED".equals(inv.getStatus())) isc="b-cancelled";
                        boolean overdue="UNPAID".equals(inv.getStatus())
                            &&inv.getDueDate()!=null
                            &&inv.getDueDate().isBefore(java.time.LocalDate.now());
                        boolean isRepair="REPAIR".equals(inv.getInvoiceType());
                    %>
                    <tr>
                        <td>
                            <a href="<%=ctx%>/customerInvoices?action=detail&id=<%=inv.getId()%>"
                               class="inv-code"><%=inv.getInvoiceCode()%></a>
                        </td>
                        <td>
                            <span class="type-badge <%=isRepair?"type-repair":"type-shop"%>">
                                <i class="fas fa-<%=isRepair?"tools":"shopping-bag"%>"></i>
                                <%=inv.getInvoiceTypeLabel()%>
                            </span>
                        </td>
                        <td>
                            <%if(inv.getRequestCode()!=null){%>
                            <a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=inv.getServiceRequestId()%>"
                               class="ref-link"><%=inv.getRequestCode()%></a>
                            <%}else{%>
                            <span style="color:var(--muted)">—</span>
                            <%}%>
                        </td>
                        <td>
                            <span class="amount <%="UNPAID".equals(inv.getStatus())?"amount-unpaid":"amount-paid"%>">
                                <%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫
                            </span>
                        </td>
                        <td><span class="b <%=isc%>"><%=inv.getStatusLabel()%></span></td>
                        <td style="font-size:.78rem;color:var(--muted)">
                            <%=inv.getCreatedAt()!=null?inv.getCreatedAt().toLocalDate():"—"%>
                        </td>
                        <td style="font-size:.78rem" class="<%=overdue?"due-overdue":""%>">
                            <%=inv.getDueDate()!=null?inv.getDueDate()+(overdue?" ⚠️":""):"—"%>
                        </td>
                        <td>
                            <a href="<%=ctx%>/customerInvoices?action=detail&id=<%=inv.getId()%>"
                               class="btn-view"><i class="fas fa-eye"></i> Details</a>
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
