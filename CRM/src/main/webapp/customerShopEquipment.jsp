<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.ShopDAO.ShopItem, java.util.*, java.text.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<ShopItem> items = (List<ShopItem>) request.getAttribute("items");
    List<Map<String,Object>> categories = (List<Map<String,Object>>) request.getAttribute("categories");
    if (items == null) items = new ArrayList<>();
    if (categories == null) categories = new ArrayList<>();
    String keyword   = (String) request.getAttribute("keyword");    if (keyword == null) keyword = "";
    String catId     = (String) request.getAttribute("categoryId"); if (catId == null) catId = "";
    String sortBy    = (String) request.getAttribute("sortBy");     if (sortBy == null) sortBy = "";
    int currentPage  = request.getAttribute("currentPage") != null ? (int)request.getAttribute("currentPage") : 1;
    int totalPages   = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages")  : 1;
    int total        = request.getAttribute("total")       != null ? (int)request.getAttribute("total")       : 0;
    int cartCount    = request.getAttribute("cartCount")   != null ? (int)request.getAttribute("cartCount")   : 0;
    int pendingSR    = request.getAttribute("pendingSR")   != null ? (int)request.getAttribute("pendingSR")   : 0;
    int unpaidInv    = request.getAttribute("unpaidInv")   != null ? (int)request.getAttribute("unpaidInv")   : 0;
    int unreadChat   = request.getAttribute("unreadChat")  != null ? (int)request.getAttribute("unreadChat")  : 0;

    String flashSuccess = (String) session.getAttribute("shopFlashSuccess");
    String flashError   = (String) session.getAttribute("shopFlashError");
    session.removeAttribute("shopFlashSuccess"); session.removeAttribute("shopFlashError");

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
    <title>Buy Equipment - DRSMS</title>
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

        .btn-cart-top {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 18px; border-radius: 11px;
            background: rgba(255,255,255,0.06);
            border: 1.5px solid var(--border);
            color: var(--text-2); text-decoration: none;
            font-size: 0.84rem; font-weight: 600;
            transition: all 0.2s; position: relative;
        }
        .btn-cart-top:hover { background: rgba(251,146,60,0.1); border-color: rgba(251,146,60,0.35); color: var(--orange); }
        .cart-badge {
            position: absolute; top: -7px; right: -7px;
            background: var(--danger); color: #fff;
            font-size: 0.62rem; font-weight: 700;
            padding: 2px 6px; border-radius: 20px;
        }

        /* Content */
        .content { padding: 28px 32px; flex: 1; }

        /* ── FLASH ALERTS ── */
        .alert {
            display: flex; align-items: center; gap: 10px;
            padding: 12px 16px; border-radius: 12px;
            font-size: 0.83rem; margin-bottom: 18px;
            animation: cardIn 0.4s ease both;
        }
        .alert-success { background: var(--green-dim);  border: 1px solid rgba(52,211,153,0.2);  color: var(--green); }
        .alert-error   { background: var(--danger-dim); border: 1px solid rgba(248,113,113,0.2); color: var(--danger); }

        /* ── SHOP TABS ── */
        .shop-tabs {
            display: flex;
            background: rgba(255,255,255,0.03);
            border: 1px solid var(--border);
            border-radius: 12px; overflow: hidden;
            margin-bottom: 22px; width: fit-content;
        }
        .shop-tab {
            padding: 10px 26px;
            font-size: 0.84rem; font-weight: 600;
            text-decoration: none; color: var(--muted);
            border-right: 1px solid var(--border);
            display: flex; align-items: center; gap: 7px;
            transition: all 0.2s;
        }
        .shop-tab:last-child { border-right: none; }
        .shop-tab:hover { background: rgba(255,255,255,0.05); color: var(--text-2); }
        .shop-tab.active {
            background: linear-gradient(135deg, var(--accent), var(--purple));
            color: #fff;
        }

        /* ── TOOLBAR ── */
        .toolbar {
            display: flex; gap: 10px;
            align-items: center; margin-bottom: 16px; flex-wrap: wrap;
        }
        .search-input {
            flex: 1; min-width: 220px;
            padding: 10px 14px;
            background: rgba(255,255,255,0.05);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            font-family: 'Sora', sans-serif;
            font-size: 0.84rem; color: var(--text);
            outline: none; transition: all 0.2s;
        }
        .search-input::placeholder { color: var(--muted); }
        .search-input:focus { border-color: rgba(79,126,248,0.5); background: rgba(79,126,248,0.05); }
        .select-box {
            padding: 10px 12px;
            background: rgba(255,255,255,0.05);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            font-family: 'Sora', sans-serif;
            font-size: 0.84rem; color: var(--text-2);
            outline: none; transition: all 0.2s;
        }
        .select-box:focus { border-color: rgba(79,126,248,0.5); }
        .select-box option { background: #0f1c4d; color: #fff; }
        .btn-search {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 10px 20px; border-radius: 10px;
            background: linear-gradient(135deg, var(--accent), var(--purple));
            color: #fff; border: none; cursor: pointer;
            font-family: 'Sora', sans-serif;
            font-size: 0.84rem; font-weight: 700;
            box-shadow: 0 3px 14px rgba(79,126,248,0.3);
            transition: all 0.2s;
        }
        .btn-search:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(79,126,248,0.5); }

        .result-info { font-size: 0.79rem; color: var(--muted); margin-bottom: 18px; }
        .result-info strong { color: var(--text-2); }

        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 12px;
        }

        /* ── EQUIPMENT LIST ── */
        .product-list {
            display: flex; flex-direction: column;
            gap: 14px; margin-bottom: 28px;
        }
        .equip-card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px 24px;
            display: flex; align-items: center; gap: 20px;
            backdrop-filter: blur(12px);
            transition: all 0.25s;
            animation: cardIn 0.5s ease both;
            position: relative; overflow: hidden;
        }
        @keyframes cardIn { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }
        .equip-card::before {
            content: ''; position: absolute;
            top: 0; left: 0; bottom: 0; width: 3px;
            background: linear-gradient(180deg, var(--info), var(--accent));
            opacity: 0; transition: opacity 0.25s;
            border-radius: 16px 0 0 16px;
        }
        .equip-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 32px rgba(0,0,0,0.3);
            border-color: rgba(56,189,248,0.25);
        }
        .equip-card:hover::before { opacity: 1; }

        .equip-icon {
            width: 68px; height: 68px; border-radius: 16px;
            background: linear-gradient(135deg, var(--purple-dim), var(--info-dim));
            display: flex; align-items: center; justify-content: center;
            font-size: 1.9rem; flex-shrink: 0;
            border: 1px solid var(--border);
        }
        .equip-info { flex: 1; min-width: 0; }
        .equip-cat {
            font-size: 0.68rem; font-weight: 700;
            color: var(--info); text-transform: uppercase;
            letter-spacing: 0.8px; margin-bottom: 4px;
        }
        .equip-name {
            font-size: 1rem; font-weight: 700;
            color: var(--text); margin-bottom: 5px;
        }
        .equip-desc {
            font-size: 0.8rem; color: var(--muted);
            margin-bottom: 8px; line-height: 1.5;
        }
        .equip-stock {
            font-size: 0.74rem; font-weight: 600;
            color: var(--green);
            display: inline-flex; align-items: center; gap: 5px;
        }
        .equip-stock.low { color: var(--amber); }

        .equip-right {
            text-align: right; flex-shrink: 0;
            display: flex; flex-direction: column; align-items: flex-end; gap: 10px;
        }
        .equip-price {
            font-size: 1.2rem; font-weight: 800;
            color: var(--orange);
        }
        .btn-add-equip {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 10px 22px; border-radius: 10px;
            background: linear-gradient(135deg, var(--info), var(--accent));
            color: #fff; border: none; cursor: pointer;
            font-family: 'Sora', sans-serif;
            font-size: 0.84rem; font-weight: 700;
            box-shadow: 0 3px 14px rgba(56,189,248,0.3);
            transition: all 0.2s;
        }
        .btn-add-equip:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 22px rgba(56,189,248,0.5);
        }
        .equip-note {
            font-size: 0.7rem; color: var(--muted);
            max-width: 180px; text-align: right; line-height: 1.4;
        }

        /* ── PAGINATION ── */
        .pagination {
            display: flex; justify-content: center;
            align-items: center; gap: 6px; margin-top: 8px;
        }
        .page-btn {
            padding: 7px 13px;
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 0.8rem; font-weight: 600;
            text-decoration: none; color: var(--text-2);
            transition: all 0.2s;
        }
        .page-btn:hover { background: rgba(79,126,248,0.1); border-color: rgba(79,126,248,0.3); color: var(--accent-2); }
        .page-btn.active {
            background: linear-gradient(135deg, var(--accent), var(--purple));
            color: #fff; border-color: transparent;
            box-shadow: 0 3px 12px rgba(79,126,248,0.35);
        }
        .page-btn.disabled { opacity: 0.3; pointer-events: none; }

        /* ── EMPTY STATE ── */
        .empty-state {
            text-align: center; padding: 60px 24px;
            color: var(--muted); font-size: 0.84rem;
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px; backdrop-filter: blur(12px);
            animation: cardIn 0.5s ease both;
        }
        .empty-state i { font-size: 2.8rem; display: block; margin-bottom: 14px; opacity: 0.2; }
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
            <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item on si-shop">
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
                    <i class="fas fa-server" style="color:var(--info);margin-right:8px;font-size:1rem"></i>
                    Shop — Equipment
                </div>
                <div class="topbar-sub">Browse and purchase equipment for your workspace</div>
            </div>
            <a href="<%=ctx%>/customerShop?action=cart" class="btn-cart-top">
                <i class="fas fa-shopping-cart"></i> Cart
                <%if(cartCount>0){%><span class="cart-badge"><%=cartCount%></span><%}%>
            </a>
        </div>

        <div class="content">

            <%if(flashSuccess!=null){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=flashSuccess%></div>
            <%}%>
            <%if(flashError!=null){%>
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=flashError%></div>
            <%}%>

            <%-- Shop Tabs --%>
            <div class="shop-tabs">
                <a href="<%=ctx%>/customerShop?action=parts" class="shop-tab">
                    <i class="fas fa-puzzle-piece"></i> Parts
                </a>
                <a href="<%=ctx%>/customerShop?action=equipment" class="shop-tab active">
                    <i class="fas fa-server"></i> Equipment
                </a>
            </div>

            <%-- Toolbar --%>
            <form method="get" action="<%=ctx%>/customerShop">
                <input type="hidden" name="action" value="equipment">
                <div class="toolbar">
                    <input class="search-input" type="text" name="keyword"
                           placeholder="Search equipment..." value="<%=keyword%>">
                    <select class="select-box" name="categoryId" onchange="this.form.submit()">
                        <option value="">— All Categories —</option>
                        <%for(Map<String,Object> cat:categories){%>
                        <option value="<%=cat.get("id")%>" <%=String.valueOf(cat.get("id")).equals(catId)?"selected":""%>>
                            <%=cat.get("name")%>
                        </option>
                        <%}%>
                    </select>
                    <select class="select-box" name="sortBy" onchange="this.form.submit()">
                        <option value="">— Sort By —</option>
                        <option value="price_asc"  <%="price_asc".equals(sortBy) ?"selected":""%>>Price: Low to High</option>
                        <option value="price_desc" <%="price_desc".equals(sortBy)?"selected":""%>>Price: High to Low</option>
                        <option value="name_asc"   <%="name_asc".equals(sortBy)  ?"selected":""%>>Name A–Z</option>
                    </select>
                    <button type="submit" class="btn-search">
                        <i class="fas fa-search"></i> Search
                    </button>
                </div>
            </form>

            <div class="result-info">Found <strong><%=total%></strong> equipment type(s)</div>

            <%if(items.isEmpty()){%>
            <div class="empty-state">
                <i class="fas fa-server"></i>
                No matching equipment found.
            </div>
            <%}else{%>

            <div class="section-lbl">Results</div>
            <div class="product-list">
                <%for(ShopItem item:items){%>
                <div class="equip-card">
                    <a href="<%=ctx%>/customerShop?action=detail&itemType=EQUIPMENT&id=<%=item.id%>" style="text-decoration:none;flex-shrink:0">
                    <div class="equip-icon">
    <%if(item.imageUrl != null && !item.imageUrl.isEmpty()){%>
      <img src="<%=(item.imageUrl.startsWith("http") ? item.imageUrl : ctx + item.imageUrl)%>" 
     alt="<%=item.name%>"
     style="width:100%;height:100%;object-fit:contain;padding:6px;border-radius:8px"
     onerror="this.style.display='none';this.parentElement.innerHTML='🖥️'">
    <%}else{%>
        🖥️
    <%}%>
</div>
                    </a>
                    <div class="equip-info">
                        <div class="equip-cat"><%=item.categoryName%></div>
                        <a href="<%=ctx%>/customerShop?action=detail&itemType=EQUIPMENT&id=<%=item.id%>"
                           style="text-decoration:none">
                        <div class="equip-name" style="cursor:pointer;transition:color 0.2s"
                             onmouseover="this.style.color='var(--info)'"
                             onmouseout="this.style.color=''"><%=item.name%></div>
                        </a>
                        <div class="equip-desc"><%=item.description!=null?item.description:""%></div>
                        <div class="equip-stock <%=item.availableQty<=2?"low":""%>">
                            <i class="fas fa-<%=item.availableQty<=2?"exclamation-triangle":"check-circle"%>"></i>
                            <%=item.availableQty%> unit<%=item.availableQty>1?"s":""%> available<%=item.availableQty<=2?" (low stock)":""%>
                        </div>
                    </div>
                    <div class="equip-right">
                        <div class="equip-price"><%=nf.format((long)item.unitPrice)%> ₫</div>
                        <form method="post" action="<%=ctx%>/customerShop">
                            <input type="hidden" name="action"   value="addToCart">
                            <input type="hidden" name="itemType" value="EQUIPMENT">
                            <input type="hidden" name="typeId"   value="<%=item.id%>">
                            <input type="hidden" name="quantity" value="1">
                            <button type="submit" class="btn-add-equip">
                                <i class="fas fa-cart-plus"></i> Add to Cart
                            </button>
                        </form>
                        <div class="equip-note">Only 1 unit per order (each has a unique serial number)</div>
                    </div>
                </div>
                <%}%>
            </div>

            <%if(totalPages>1){%>
            <div class="pagination">
                <a href="?action=equipment&page=1&keyword=<%=keyword%>&categoryId=<%=catId%>&sortBy=<%=sortBy%>"
                   class="page-btn <%=currentPage==1?"disabled":""%>">«</a>
                <a href="?action=equipment&page=<%=Math.max(1,currentPage-1)%>&keyword=<%=keyword%>&categoryId=<%=catId%>&sortBy=<%=sortBy%>"
                   class="page-btn <%=currentPage==1?"disabled":""%>">‹</a>
                <%for(int p=Math.max(1,currentPage-2);p<=Math.min(totalPages,currentPage+2);p++){%>
                <a href="?action=equipment&page=<%=p%>&keyword=<%=keyword%>&categoryId=<%=catId%>&sortBy=<%=sortBy%>"
                   class="page-btn <%=p==currentPage?"active":""%>"><%=p%></a>
                <%}%>
                <a href="?action=equipment&page=<%=Math.min(totalPages,currentPage+1)%>&keyword=<%=keyword%>&categoryId=<%=catId%>&sortBy=<%=sortBy%>"
                   class="page-btn <%=currentPage==totalPages?"disabled":""%>">›</a>
                <a href="?action=equipment&page=<%=totalPages%>&keyword=<%=keyword%>&categoryId=<%=catId%>&sortBy=<%=sortBy%>"
                   class="page-btn <%=currentPage==totalPages?"disabled":""%>">»</a>
            </div>
            <%}%>

            <%}%>
        </div>
    </main>
<%@ include file="customerAIBubble.jsp" %>
</body>
</html>
