<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.CartItem, java.util.*, java.text.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<CartItem> cartList = (List<CartItem>) request.getAttribute("cartList");
    if (cartList == null) cartList = new ArrayList<>();
    double grandTotal   = request.getAttribute("grandTotal") != null ? (double)request.getAttribute("grandTotal") : 0;
    int    cartCount    = request.getAttribute("cartCount")  != null ? (int)request.getAttribute("cartCount")  : 0;
    int    pendingSR    = request.getAttribute("pendingSR")  != null ? (int)request.getAttribute("pendingSR")  : 0;
    int    unpaidInv    = request.getAttribute("unpaidInv")  != null ? (int)request.getAttribute("unpaidInv")  : 0;
    int    unreadChat   = request.getAttribute("unreadChat") != null ? (int)request.getAttribute("unreadChat") : 0;
    String flashSuccess = (String) request.getAttribute("flashSuccess");
    String flashError   = (String) request.getAttribute("flashError");
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
    String ctx = request.getContextPath();
    String initials = me.getFullName()!=null&&!me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Cart - DRSMS</title>
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
        .sb-item.si-cart:hover       { color:#fff; background:rgba(251,146,60,0.08); border-left-color:var(--orange); }
        .sb-item.si-cart:hover i     { background:rgba(251,146,60,0.18); color:var(--orange); }
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
        .content { padding: 28px 32px; flex: 1; }

        /* ── ALERTS ── */
        .alert {
            display: flex; align-items: center; gap: 10px;
            padding: 12px 16px; border-radius: 12px;
            font-size: 0.83rem; margin-bottom: 18px;
            animation: cardIn 0.4s ease both;
        }
        .alert-success { background: var(--green-dim);  border: 1px solid rgba(52,211,153,0.2);  color: var(--green); }
        .alert-error   { background: var(--danger-dim); border: 1px solid rgba(248,113,113,0.2); color: var(--danger); }
        @keyframes cardIn { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }

        /* ── LAYOUT ── */
        .layout {
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 20px; align-items: start;
        }

        /* ── CART TABLE CARD ── */
        .cart-card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px; overflow: hidden;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s ease both;
        }
        .cart-header {
            padding: 15px 20px;
            border-bottom: 1px solid var(--border);
            display: flex; justify-content: space-between; align-items: center;
            background: rgba(255,255,255,0.02);
        }
        .cart-header h2 {
            font-size: 0.92rem; font-weight: 700; color: var(--text);
            display: flex; align-items: center; gap: 8px;
        }
        .cart-header h2 i { color: var(--orange); }
        .btn-clear {
            background: none; border: none;
            color: var(--muted); font-family: 'Sora', sans-serif;
            font-size: 0.78rem; cursor: pointer;
            display: flex; align-items: center; gap: 5px;
            transition: color 0.2s; padding: 5px 8px; border-radius: 7px;
        }
        .btn-clear:hover { color: var(--danger); background: var(--danger-dim); }

        /* Table */
        table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
        thead tr { background: rgba(255,255,255,0.02); }
        th {
            padding: 10px 16px; text-align: left;
            color: var(--muted); font-weight: 600;
            font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.8px;
            border-bottom: 1px solid var(--border);
        }
        td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--border-2);
            vertical-align: middle; color: var(--text-2);
        }
        tr:last-child td { border-bottom: none; }
        tbody tr { transition: background 0.15s; }
        tbody tr:hover td { background: rgba(79,126,248,0.04); }

        .item-name { font-weight: 700; color: var(--text); margin-bottom: 2px; font-size: 0.85rem; }
        .item-cat  { font-size: 0.73rem; color: var(--muted); }

        .item-type-badge {
            display: inline-flex; align-items: center; gap: 3px;
            padding: 2px 7px; border-radius: 10px;
            font-size: 0.68rem; font-weight: 700; margin-left: 6px;
        }
        .badge-part  { background: var(--purple-dim); color: var(--purple); }
        .badge-equip { background: var(--info-dim);   color: var(--info); }

        /* Qty controls */
        .qty-form { display: flex; align-items: center; gap: 6px; }
        .qty-btn {
            width: 28px; height: 28px;
            background: rgba(255,255,255,0.06);
            border: 1px solid var(--border);
            border-radius: 7px; cursor: pointer;
            font-size: 1rem; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            color: var(--text-2); transition: all 0.15s;
        }
        .qty-btn:hover { background: rgba(79,126,248,0.15); border-color: rgba(79,126,248,0.3); color: var(--accent-2); }
        .qty-display {
            width: 36px; text-align: center;
            font-weight: 700; font-size: 0.9rem; color: var(--text);
        }
        .btn-remove {
            background: none; border: none;
            color: var(--muted); cursor: pointer;
            padding: 5px 8px; border-radius: 7px; transition: all 0.15s;
        }
        .btn-remove:hover { color: var(--danger); background: var(--danger-dim); }

        .price-cell    { font-weight: 700; color: var(--text-2); white-space: nowrap; }
        .subtotal-cell { font-weight: 800; color: var(--orange); white-space: nowrap; }

        /* ── ORDER SUMMARY ── */
        .summary-card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px; padding: 22px;
            backdrop-filter: blur(12px);
            position: sticky; top: 90px;
            animation: cardIn 0.5s 0.1s ease both;
        }
        .summary-title {
            font-size: 0.92rem; font-weight: 700; color: var(--text);
            margin-bottom: 18px;
            display: flex; align-items: center; gap: 7px;
        }
        .summary-title i { color: var(--accent-2); }
        .summary-row {
            display: flex; justify-content: space-between;
            margin-bottom: 10px;
            font-size: 0.84rem; color: var(--text-2);
        }
        .summary-divider {
            border: none; border-top: 1px solid var(--border); margin: 14px 0;
        }
        .summary-total {
            display: flex; justify-content: space-between;
            font-size: 1.08rem; font-weight: 800; color: var(--text);
        }
        .summary-total span:last-child { color: var(--orange); }
        .summary-tax {
            font-size: 0.72rem; color: var(--muted);
            text-align: right; margin-top: 4px; margin-bottom: 18px;
        }

        /* Payment section */
        .pay-title {
            font-size: 0.78rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 0.8px; margin-bottom: 10px;
        }
        .btn-pay {
            width: 100%; padding: 12px;
            border: none; border-radius: 11px;
            font-family: 'Sora', sans-serif;
            font-size: 0.9rem; font-weight: 700;
            cursor: pointer;
            display: flex; align-items: center; justify-content: center; gap: 8px;
            margin-bottom: 9px; transition: all 0.2s;
        }
        .btn-cash {
            background: linear-gradient(135deg, var(--green), rgba(52,211,153,0.7));
            color: #0b2010;
            box-shadow: 0 4px 16px rgba(52,211,153,0.3);
        }
        .btn-cash:hover { transform: translateY(-1px); box-shadow: 0 7px 22px rgba(52,211,153,0.45); }
        .btn-vnpay {
            background: linear-gradient(135deg, #e30019, #b50014);
            color: white;
            box-shadow: 0 4px 16px rgba(227,0,25,0.3);
        }
        .btn-vnpay:hover { transform: translateY(-1px); box-shadow: 0 7px 22px rgba(227,0,25,0.45); }

        .btn-continue {
            width: 100%; padding: 10px;
            background: rgba(255,255,255,0.04);
            color: var(--muted);
            border: 1.5px solid var(--border);
            border-radius: 11px;
            font-family: 'Sora', sans-serif;
            font-size: 0.84rem; font-weight: 600;
            cursor: pointer; margin-top: 6px;
            display: flex; align-items: center; justify-content: center; gap: 6px;
            text-decoration: none; transition: all 0.2s;
        }
        .btn-continue:hover { background: rgba(255,255,255,0.07); border-color: rgba(255,255,255,0.15); color: var(--text-2); }

        /* ── EMPTY CART ── */
        .empty-cart-wrap {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s ease both;
        }
        .empty-cart {
            text-align: center; padding: 64px 24px;
            color: var(--muted);
        }
        .empty-cart i { font-size: 3.5rem; margin-bottom: 16px; display: block; opacity: 0.18; }
        .empty-cart h3 { font-size: 1.1rem; font-weight: 700; margin-bottom: 8px; color: var(--text-2); }
        .empty-cart p  { font-size: 0.84rem; color: var(--muted); margin-bottom: 4px; }
        .btn-shop {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 11px 26px;
            background: linear-gradient(135deg, var(--accent), var(--purple));
            color: #fff; border-radius: 11px; text-decoration: none;
            font-size: 0.875rem; font-weight: 700; margin-top: 16px;
            box-shadow: 0 4px 18px rgba(79,126,248,0.35);
            transition: all 0.2s;
        }
        .btn-shop:hover { transform: translateY(-2px); box-shadow: 0 8px 26px rgba(79,126,248,0.5); }
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
            <a href="<%=ctx%>/customerShop?action=cart" class="sb-item on si-cart">
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

        <div class="topbar">
            <div>
                <div class="topbar-title">
                    <i class="fas fa-shopping-cart" style="color:var(--orange);margin-right:8px;font-size:1rem"></i>
                    Cart <span style="color:var(--muted);font-weight:500;font-size:1rem">(<%=cartCount%> item<%=cartCount!=1?"s":""%>)</span>
                </div>
                <div class="topbar-sub">Review your items and proceed to checkout</div>
            </div>
        </div>

        <div class="content">

            <%if(flashSuccess!=null){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=flashSuccess%></div>
            <%}%>
            <%if(flashError!=null){%>
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=flashError%></div>
            <%}%>

            <%if(cartList.isEmpty()){%>
            <div class="empty-cart-wrap">
                <div class="empty-cart">
                    <i class="fas fa-shopping-cart"></i>
                    <h3>Your cart is empty</h3>
                    <p>Add some items from the shop to get started.</p>
                    <a href="<%=ctx%>/customerShop?action=parts" class="btn-shop">
                        <i class="fas fa-store"></i> Continue Shopping
                    </a>
                </div>
            </div>
            <%}else{%>

            <div class="layout">

                <%-- Cart table --%>
                <div class="cart-card">
                    <div class="cart-header">
                        <h2><i class="fas fa-list"></i> Item List</h2>
                        <form method="post" action="<%=ctx%>/customerShop" style="display:inline">
                            <input type="hidden" name="action" value="clearCart">
                            <button type="submit" class="btn-clear"
                                    onclick="return confirm('Clear all items from cart?')">
                                <i class="fas fa-trash"></i> Clear All
                            </button>
                        </form>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>Unit Price</th>
                                <th>Quantity</th>
                                <th>Subtotal</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <%for(CartItem ci:cartList){%>
                            <tr>
                                <td>
                                    <div class="item-name">
                                        <%=ci.getName()%>
                                        <span class="item-type-badge <%="PART".equals(ci.getItemType())?"badge-part":"badge-equip"%>">
                                            <%="PART".equals(ci.getItemType())?"Part":"Equipment"%>
                                        </span>
                                    </div>
                                    <div class="item-cat"><%=ci.getCategoryName()%></div>
                                </td>
                                <td class="price-cell"><%=nf.format((long)ci.getUnitPrice())%> ₫</td>
                                <td>
                                    <div class="qty-form">
                                        <button type="button" class="qty-btn"
                                                onclick="changeQty('<%=ci.getKey()%>',<%=ci.getQuantity()-1%>)">−</button>
                                        <span class="qty-display" id="qty-<%=ci.getKey().replace("_","-")%>"><%=ci.getQuantity()%></span>
                                        <button type="button" class="qty-btn"
                                                onclick="changeQty('<%=ci.getKey()%>',<%=ci.getQuantity()+1%>)"
                                                <%=ci.getQuantity()>=ci.getMaxQty()?"disabled style='opacity:.35;cursor:not-allowed'":" "%>>+</button>
                                    </div>
                                </td>
                                <td class="subtotal-cell"><%=nf.format((long)ci.getSubtotal())%> ₫</td>
                                <td>
                                    <form method="post" action="<%=ctx%>/customerShop" style="display:inline">
                                        <input type="hidden" name="action" value="removeCart">
                                        <input type="hidden" name="key"    value="<%=ci.getKey()%>">
                                        <button type="submit" class="btn-remove">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <%}%>
                        </tbody>
                    </table>
                </div>

                <%-- Order summary --%>
                <div class="summary-card">
                    <div class="summary-title">
                        <i class="fas fa-receipt"></i> Order Summary
                    </div>
                    <div class="summary-row">
                        <span>Subtotal</span>
                        <span><%=nf.format((long)grandTotal)%> ₫</span>
                    </div>
                    <div class="summary-row">
                        <span>VAT (10%)</span>
                        <span><%=nf.format((long)(grandTotal*0.1))%> ₫</span>
                    </div>
                    <hr class="summary-divider">
                    <div class="summary-total">
                        <span>Total</span>
                        <span><%=nf.format((long)(grandTotal*1.1))%> ₫</span>
                    </div>
                    <div class="summary-tax">VAT included</div>

                    <div class="pay-title"><i class="fas fa-credit-card"></i> &nbsp;Payment Method</div>

                    <form method="post" action="<%=ctx%>/customerShop">
                        <input type="hidden" name="action"    value="checkout">
                        <input type="hidden" name="payMethod" value="cash">
                        <button type="submit" class="btn-pay btn-cash">
                            <i class="fas fa-money-bill-wave"></i> Pay with Cash
                        </button>
                    </form>

                    <form method="post" action="<%=ctx%>/customerShop">
                        <input type="hidden" name="action"    value="checkout">
                        <input type="hidden" name="payMethod" value="vnpay">
                        <button type="submit" class="btn-pay btn-vnpay">
                            <span style="font-weight:900;font-size:1rem;letter-spacing:-0.5px">VN</span>Pay &nbsp;— Pay Online
                        </button>
                    </form>

                    <a href="<%=ctx%>/customerShop?action=parts" class="btn-continue">
                        <i class="fas fa-arrow-left"></i> Continue Shopping
                    </a>
                </div>

            </div>
            <%}%>

        </div>
    </main>

    <form method="post" action="<%=ctx%>/customerShop" id="updateForm" style="display:none">
        <input type="hidden" name="action"   value="updateCart">
        <input type="hidden" name="key"      id="updateKey">
        <input type="hidden" name="quantity" id="updateQty">
    </form>

    <script>
        function changeQty(key, newQty) {
            if (newQty < 0) return;
            document.getElementById('updateKey').value = key;
            document.getElementById('updateQty').value = newQty;
            document.getElementById('updateForm').submit();
        }
    </script>
</body>
</html>
