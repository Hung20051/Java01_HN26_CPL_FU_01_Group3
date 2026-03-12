<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.ShopDAO.ShopItem, java.util.*, java.text.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    ShopItem item = (ShopItem) request.getAttribute("item");
    if (item == null) {
        response.sendRedirect(request.getContextPath() + "/customerShop?action=parts"); return;
    }
    int cartCount  = request.getAttribute("cartCount")  != null ? (int)request.getAttribute("cartCount")  : 0;
    int pendingSR  = request.getAttribute("pendingSR")  != null ? (int)request.getAttribute("pendingSR")  : 0;
    int unpaidInv  = request.getAttribute("unpaidInv")  != null ? (int)request.getAttribute("unpaidInv")  : 0;
    int unreadChat = request.getAttribute("unreadChat") != null ? (int)request.getAttribute("unreadChat") : 0;

    String flashSuccess = (String) session.getAttribute("shopFlashSuccess");
    String flashError   = (String) session.getAttribute("shopFlashError");
    session.removeAttribute("shopFlashSuccess"); session.removeAttribute("shopFlashError");

    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
    String ctx = request.getContextPath();
    String initials = me.getFullName()!=null&&!me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";

    boolean isPart = "PART".equals(item.itemType);
    String backUrl = isPart ? ctx+"/customerShop?action=parts" : ctx+"/customerShop?action=equipment";
    String backLabel = isPart ? "Parts" : "Equipment";

    // Derived info based on item type
    String typeIcon    = isPart ? "fa-puzzle-piece" : "fa-server";
    String accentColor = isPart ? "var(--green)"    : "var(--info)";
    String accentDim   = isPart ? "var(--green-dim)": "var(--info-dim)";
    String defaultEmoji= isPart ? "🔧"              : "🖥️";

    // Stock status
    boolean inStock  = item.availableQty > 0;
    boolean lowStock = item.availableQty > 0 && item.availableQty <= 3;
    String stockLabel = !inStock ? "Out of Stock" : lowStock ? "Low Stock" : "In Stock";
    String stockColor = !inStock ? "var(--danger)"  : lowStock ? "var(--amber)" : "var(--green)";
    String stockDim   = !inStock ? "var(--danger-dim)":lowStock? "var(--amber-dim)":"var(--green-dim)";
    String stockIcon  = !inStock ? "fa-times-circle":lowStock ? "fa-exclamation-triangle":"fa-check-circle";

    int maxQty = item.availableQty;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%=item.name%> - DRSMS Shop</title>
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
            --sb-width:    248px;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Sora', sans-serif; background: var(--navy); color: var(--text); min-height: 100vh; display: flex; }
        ::-webkit-scrollbar { width: 4px; }
        ::-webkit-scrollbar-track { background: var(--navy); }
        ::-webkit-scrollbar-thumb { background: rgba(79,126,248,0.4); border-radius: 4px; }

        /* ════ SIDEBAR ════ */
        .sb { width:var(--sb-width); min-height:100vh; background:rgba(9,15,40,0.95); backdrop-filter:blur(20px); border-right:1px solid var(--border); display:flex; flex-direction:column; position:fixed; top:0; left:0; z-index:100; }
        .sb-brand { padding:22px 18px 16px; display:flex; align-items:center; gap:10px; border-bottom:1px solid var(--border); }
        .sb-logo { width:36px; height:36px; background:linear-gradient(135deg,var(--accent),var(--accent-2)); border-radius:10px; display:flex; align-items:center; justify-content:center; color:#fff; font-size:.88rem; box-shadow:0 4px 14px var(--accent-glow); flex-shrink:0; }
        .sb-name { color:#fff; font-size:1rem; font-weight:700; }
        .sb-role { display:inline-flex; align-items:center; background:rgba(79,126,248,0.15); border:1px solid rgba(79,126,248,0.25); color:var(--accent-2); font-size:.62rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; padding:2px 8px; border-radius:20px; margin-top:3px; }
        .sb-nav { flex:1; padding:12px 10px; overflow-y:auto; }
        .sb-lbl { color:rgba(255,255,255,0.22); font-size:.62rem; font-weight:700; text-transform:uppercase; letter-spacing:1.4px; padding:0 8px; margin:16px 0 5px; }
        .sb-item { display:flex; align-items:center; gap:9px; padding:9px 10px; border-radius:9px; margin-bottom:1px; color:rgba(255,255,255,0.45); text-decoration:none; font-size:.83rem; font-weight:500; transition:all .2s; border-left:2px solid transparent; }
        .sb-item i { width:28px; height:28px; display:flex; align-items:center; justify-content:center; font-size:.8rem; border-radius:8px; background:rgba(255,255,255,0.05); flex-shrink:0; transition:all .2s; }
        .sb-item.on { color:#fff; background:linear-gradient(90deg,rgba(79,126,248,0.2),rgba(79,126,248,0.05)); border-left:2px solid var(--accent); }
        .sb-item.on i { background:rgba(79,126,248,0.25); color:var(--accent-2); }
        .sb-item.si-home:hover     { color:#fff; background:rgba(79,126,248,0.1);   border-left-color:var(--accent); } .sb-item.si-home:hover i     { background:rgba(79,126,248,0.2);   color:var(--accent-2); }
        .sb-item.si-repair:hover   { color:#fff; background:rgba(251,191,36,0.08);  border-left-color:var(--amber);  } .sb-item.si-repair:hover i   { background:rgba(251,191,36,0.18);  color:var(--amber); }
        .sb-item.si-contract:hover { color:#fff; background:rgba(167,139,250,0.08); border-left-color:var(--purple); } .sb-item.si-contract:hover i { background:rgba(167,139,250,0.18); color:var(--purple); }
        .sb-item.si-equip:hover    { color:#fff; background:rgba(56,189,248,0.08);  border-left-color:var(--info);   } .sb-item.si-equip:hover i    { background:rgba(56,189,248,0.18);  color:var(--info); }
        .sb-item.si-parts:hover    { color:#fff; background:rgba(52,211,153,0.07);  border-left-color:var(--green);  } .sb-item.si-parts:hover i    { background:rgba(52,211,153,0.18);  color:var(--green); }
        .sb-item.si-shop:hover     { color:#fff; background:rgba(56,189,248,0.07);  border-left-color:var(--info);   } .sb-item.si-shop:hover i     { background:rgba(56,189,248,0.18);  color:var(--info); }
        .sb-item.si-cart:hover     { color:#fff; background:rgba(251,146,60,0.08);  border-left-color:var(--orange); } .sb-item.si-cart:hover i     { background:rgba(251,146,60,0.18);  color:var(--orange); }
        .sb-item.si-invoice:hover  { color:#fff; background:rgba(52,211,153,0.07);  border-left-color:var(--green);  } .sb-item.si-invoice:hover i  { background:rgba(52,211,153,0.18);  color:var(--green); }
        .sb-item.si-chat:hover     { color:#fff; background:rgba(251,113,133,0.08); border-left-color:#fb7185;       } .sb-item.si-chat:hover i     { background:rgba(251,113,133,0.18); color:#fb7185; }
        .sb-badge { margin-left:auto; background:var(--danger); color:#fff; font-size:.62rem; font-weight:700; padding:2px 6px; border-radius:20px; animation:badgePop 2s ease-in-out infinite; }
        @keyframes badgePop { 0%,100%{transform:scale(1)} 50%{transform:scale(1.1)} }
        .sb-foot { padding:12px 10px 16px; border-top:1px solid var(--border); }
        .sb-user { display:flex; align-items:center; gap:9px; padding:10px; border-radius:10px; background:rgba(255,255,255,0.04); border:1px solid var(--border); margin-bottom:6px; text-decoration:none; transition:all .2s; }
        .sb-user:hover { background:rgba(79,126,248,0.1); border-color:rgba(79,126,248,0.25); }
        .sb-ava { width:34px; height:34px; border-radius:50%; background:linear-gradient(135deg,var(--accent),var(--purple)); display:flex; align-items:center; justify-content:center; color:#fff; font-size:.88rem; font-weight:700; flex-shrink:0; overflow:hidden; }
        .sb-ava img { width:34px; height:34px; object-fit:cover; border-radius:50%; }
        .sb-uname { color:#fff; font-size:.82rem; font-weight:600; }
        .sb-urole { color:var(--muted); font-size:.68rem; margin-top:1px; }
        .sb-logout { display:flex; align-items:center; gap:8px; width:100%; padding:8px 10px; border-radius:8px; color:rgba(255,255,255,0.35); text-decoration:none; font-size:.8rem; transition:all .2s; }
        .sb-logout:hover { color:var(--danger); background:rgba(248,113,113,0.08); }

        /* ════ MAIN ════ */
        .main { margin-left:var(--sb-width); flex:1; min-height:100vh; display:flex; flex-direction:column; }
        .topbar { display:flex; justify-content:space-between; align-items:center; padding:18px 32px; border-bottom:1px solid var(--border); background:rgba(11,20,55,0.6); backdrop-filter:blur(16px); position:sticky; top:0; z-index:50; }
        .breadcrumb { display:flex; align-items:center; gap:7px; font-size:.78rem; color:var(--muted); }
        .breadcrumb a { color:var(--muted); text-decoration:none; transition:color .2s; }
        .breadcrumb a:hover { color:var(--accent-2); }
        .bc-sep { color:rgba(255,255,255,0.18); }
        .bc-cur { color:var(--text-2); font-weight:600; }
        .btn-cart-top { display:inline-flex; align-items:center; gap:8px; padding:10px 18px; border-radius:11px; background:rgba(255,255,255,0.06); border:1.5px solid var(--border); color:var(--text-2); text-decoration:none; font-size:.84rem; font-weight:600; transition:all .2s; position:relative; }
        .btn-cart-top:hover { background:rgba(251,146,60,0.1); border-color:rgba(251,146,60,0.35); color:var(--orange); }
        .cart-badge { position:absolute; top:-7px; right:-7px; background:var(--danger); color:#fff; font-size:.62rem; font-weight:700; padding:2px 6px; border-radius:20px; }
        .content { padding:28px 32px; flex:1; }

        /* Alerts */
        .alert { display:flex; align-items:center; gap:10px; padding:12px 16px; border-radius:12px; font-size:.83rem; margin-bottom:18px; animation:fadeIn .4s ease both; }
        .alert-success { background:var(--green-dim);  border:1px solid rgba(52,211,153,0.2);  color:var(--green); }
        .alert-error   { background:var(--danger-dim); border:1px solid rgba(248,113,113,0.2); color:var(--danger); }
        @keyframes fadeIn { from{opacity:0;transform:translateY(-8px)} to{opacity:1;transform:none} }

        /* ════ PRODUCT DETAIL LAYOUT ════ */
        @keyframes slideUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:none} }

        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            align-items: start;
            margin-bottom: 28px;
        }

        /* ── LEFT: Image Panel ── */
        .img-panel {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 20px;
            overflow: hidden;
            backdrop-filter: blur(12px);
            animation: slideUp .5s ease both;
        }
        .img-main {
            height: 340px;
            display: flex; align-items: center; justify-content: center;
            background: linear-gradient(135deg, rgba(17,26,66,0.9), rgba(11,20,55,0.9));
            position: relative; overflow: hidden; cursor: zoom-in;
        }
        .img-main::before {
            content: '';
            position: absolute; inset: 0;
            background: radial-gradient(circle at 50% 30%, <%=isPart?"rgba(52,211,153,0.06)":"rgba(56,189,248,0.06)"%>, transparent 70%);
        }
        .img-main img {
            max-width: 88%; max-height: 88%;
            object-fit: contain;
            filter: drop-shadow(0 8px 24px rgba(0,0,0,0.4));
            transition: transform .4s ease;
            position: relative; z-index: 1;
        }
        .img-main:hover img { transform: scale(1.06); }
        .img-main .emoji-placeholder { font-size: 6rem; position: relative; z-index: 1; }

        .img-badge {
            position: absolute; top: 14px; left: 14px; z-index: 2;
            padding: 5px 12px; border-radius: 20px;
            font-size: .68rem; font-weight: 700; letter-spacing: .5px; text-transform: uppercase;
            backdrop-filter: blur(10px);
        }
        .img-type-badge {
            background: <%=isPart?"rgba(52,211,153,0.18)":"rgba(56,189,248,0.18)"%>;
            border: 1px solid <%=isPart?"rgba(52,211,153,0.35)":"rgba(56,189,248,0.35)"%>;
            color: <%=isPart?"var(--green)":"var(--info)"%>;
        }

        .img-thumbnails {
            display: flex; gap: 10px; padding: 14px 16px;
            border-top: 1px solid var(--border);
            background: rgba(255,255,255,0.02);
        }
        .thumb {
            width: 64px; height: 64px; border-radius: 10px;
            background: rgba(255,255,255,0.05);
            border: 2px solid var(--border);
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; overflow: hidden; transition: all .2s;
            flex-shrink: 0;
        }
        .thumb.active { border-color: <%=isPart?"var(--green)":"var(--info)"%>; box-shadow: 0 0 12px <%=isPart?"rgba(52,211,153,0.3)":"rgba(56,189,248,0.3)"%>; }
        .thumb img { width: 100%; height: 100%; object-fit: contain; padding: 6px; }
        .thumb-add {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            color: var(--muted); font-size: .6rem; gap: 4px; text-align: center; line-height: 1.2;
        }
        .thumb-add i { font-size: .8rem; }

        /* ── RIGHT: Info Panel ── */
        .info-panel {
            display: flex; flex-direction: column; gap: 16px;
            animation: slideUp .5s ease .08s both;
        }

        .info-card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 22px 24px;
            backdrop-filter: blur(12px);
        }

        .product-cat-badge {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 12px; border-radius: 20px; font-size: .68rem; font-weight: 700;
            letter-spacing: .8px; text-transform: uppercase; margin-bottom: 10px;
            background: <%=isPart?"rgba(52,211,153,0.1)":"rgba(56,189,248,0.1)"%>;
            border: 1px solid <%=isPart?"rgba(52,211,153,0.25)":"rgba(56,189,248,0.25)"%>;
            color: <%=isPart?"var(--green)":"var(--info)"%>;
        }
        .product-name-h {
            font-size: 1.55rem; font-weight: 800; color: #fff;
            line-height: 1.2; letter-spacing: -.4px; margin-bottom: 8px;
        }
        .product-desc-p {
            font-size: .85rem; color: var(--text-2); line-height: 1.7;
            font-weight: 300; margin-bottom: 16px;
        }

        /* Price box */
        .price-box {
            display: flex; align-items: flex-end; gap: 12px; margin-bottom: 14px;
        }
        .price-main { font-size: 2rem; font-weight: 800; color: var(--orange); letter-spacing: -.5px; }
        .price-label { font-size: .72rem; color: var(--muted); margin-bottom: 6px; }

        /* Stock indicator */
        .stock-row {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 14px; border-radius: 11px;
            margin-bottom: 16px;
        }
        .stock-dot { width: 9px; height: 9px; border-radius: 50%; flex-shrink: 0; animation: pulse 2s ease-in-out infinite; }
        @keyframes pulse { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.6;transform:scale(1.3)} }
        .stock-label { font-size: .83rem; font-weight: 700; }
        .stock-qty { font-size: .77rem; color: var(--muted); margin-left: auto; }

        /* Add to cart area */
        .cart-area { display: flex; gap: 10px; align-items: center; }
        .qty-wrap {
            display: flex; align-items: center;
            background: rgba(255,255,255,0.05);
            border: 1.5px solid var(--border);
            border-radius: 12px; overflow: hidden;
        }
        .qty-btn {
            width: 40px; height: 48px;
            display: flex; align-items: center; justify-content: center;
            background: none; border: none; cursor: pointer;
            color: var(--text-2); font-size: 1rem;
            transition: all .15s;
        }
        .qty-btn:hover { background: rgba(255,255,255,0.07); color: #fff; }
        .qty-num {
            width: 52px; text-align: center;
            background: none; border: none; outline: none;
            font-family: 'Sora', sans-serif;
            font-size: .95rem; font-weight: 700; color: #fff;
        }
        .qty-num::-webkit-inner-spin-button { display: none; }
        .btn-add-to-cart {
            flex: 1; padding: 13px 20px;
            background: linear-gradient(135deg, <%=isPart?"var(--green), rgba(52,211,153,0.7)":"var(--info), rgba(56,189,248,0.7)"%>);
            color: <%=isPart?"#0b1437":"#0b1437"%>;
            border: none; border-radius: 12px;
            font-family: 'Sora', sans-serif;
            font-size: .9rem; font-weight: 800; cursor: pointer;
            display: flex; align-items: center; justify-content: center; gap: 8px;
            box-shadow: 0 4px 20px <%=isPart?"rgba(52,211,153,0.3)":"rgba(56,189,248,0.3)"%>;
            transition: all .25s; animation: ctaPulse 3s ease-in-out infinite;
        }
        @keyframes ctaPulse {
            0%,100%{ box-shadow: 0 4px 20px <%=isPart?"rgba(52,211,153,0.3)":"rgba(56,189,248,0.3)"%>; }
            50%    { box-shadow: 0 4px 32px <%=isPart?"rgba(52,211,153,0.55)":"rgba(56,189,248,0.55)"%>, 0 0 0 5px <%=isPart?"rgba(52,211,153,0.08)":"rgba(56,189,248,0.08)"%>; }
        }
        .btn-add-to-cart:hover { transform: translateY(-2px); animation: none; box-shadow: 0 8px 28px <%=isPart?"rgba(52,211,153,0.5)":"rgba(56,189,248,0.5)"%>; }
        .btn-add-to-cart:disabled { opacity: .4; cursor: not-allowed; animation: none; transform: none; }

        /* ════ BOTTOM ROW ════ */
        .bottom-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 18px;
            animation: slideUp .5s ease .16s both;
        }

        .detail-card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px;
            backdrop-filter: blur(12px);
        }
        .detail-card-hd {
            display: flex; align-items: center; gap: 9px;
            margin-bottom: 16px; padding-bottom: 12px;
            border-bottom: 1px solid var(--border);
        }
        .detail-card-icon {
            width: 32px; height: 32px; border-radius: 9px;
            display: flex; align-items: center; justify-content: center;
            font-size: .82rem; flex-shrink: 0;
        }
        .detail-card-title { font-size: .82rem; font-weight: 700; color: var(--text-2); }

        /* Spec table */
        .spec-row { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid rgba(255,255,255,0.04); }
        .spec-row:last-child { border-bottom: none; }
        .spec-key { font-size: .75rem; color: var(--muted); font-weight: 500; }
        .spec-val { font-size: .78rem; color: var(--text-2); font-weight: 600; text-align: right; }
        .spec-val.mono { font-family: 'Courier New', monospace; color: var(--accent-2); }

        /* Feature list */
        .feature-item { display: flex; align-items: flex-start; gap: 10px; padding: 9px 0; border-bottom: 1px solid rgba(255,255,255,0.04); }
        .feature-item:last-child { border-bottom: none; }
        .feature-dot { width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: .62rem; flex-shrink: 0; margin-top: 1px; }
        .feature-text { font-size: .78rem; color: var(--text-2); line-height: 1.5; }

        /* Shipping / policy */
        .policy-item { display: flex; align-items: center; gap: 11px; padding: 10px 0; border-bottom: 1px solid rgba(255,255,255,0.04); }
        .policy-item:last-child { border-bottom: none; }
        .policy-icon { width: 34px; height: 34px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: .85rem; flex-shrink: 0; }
        .policy-label { font-size: .78rem; font-weight: 700; color: var(--text-2); }
        .policy-sub   { font-size: .72rem; color: var(--muted); margin-top: 2px; }

        /* Back button */
        .btn-back { display:inline-flex; align-items:center; gap:7px; padding:9px 16px; border-radius:10px; background:rgba(255,255,255,0.05); color:var(--text-2); border:1px solid var(--border); text-decoration:none; font-size:.82rem; font-weight:600; transition:all .2s; }
        .btn-back:hover { background:rgba(255,255,255,0.1); color:#fff; }
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
        <a href="<%=ctx%>/customerServiceRequests" class="sb-item si-repair">
            <i class="fas fa-clipboard-list"></i> Repair Requests
            <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
        </a>
        <a href="<%=ctx%>/customerContracts"  class="sb-item si-contract"><i class="fas fa-file-contract"></i> Contracts</a>
        <a href="<%=ctx%>/customerEquipment"  class="sb-item si-equip"><i class="fas fa-desktop"></i> My Equipment</a>
        <div class="sb-lbl">Shop</div>
        <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item <%=isPart?"on":""%> si-parts"><i class="fas fa-puzzle-piece"></i> Parts</a>
        <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item <%=!isPart?"on":""%> si-shop"><i class="fas fa-server"></i> Equipment</a>
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
        <div class="breadcrumb">
            <a href="<%=ctx%>/customerDashboard"><i class="fas fa-home"></i></a>
            <span class="bc-sep">›</span>
            <a href="<%=backUrl%>"><%=backLabel%></a>
            <span class="bc-sep">›</span>
            <span class="bc-cur"><%=item.name%></span>
        </div>
        <div style="display:flex;gap:10px;align-items:center">
            <a href="<%=backUrl%>" class="btn-back"><i class="fas fa-arrow-left"></i> Back</a>
            <a href="<%=ctx%>/customerShop?action=cart" class="btn-cart-top">
                <i class="fas fa-shopping-cart"></i> Cart
                <%if(cartCount>0){%><span class="cart-badge"><%=cartCount%></span><%}%>
            </a>
        </div>
    </div>

    <div class="content">
        <%if(flashSuccess!=null){%><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=flashSuccess%></div><%}%>
        <%if(flashError!=null){%><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=flashError%></div><%}%>

        <%-- TOP ROW: Image + Info --%>
        <div class="detail-grid">

            <%-- Image Panel --%>
            <div class="img-panel">
                <div class="img-main" id="imgMain">
                    <span class="img-badge img-type-badge">
                        <i class="fas <%=typeIcon%>"></i> <%=isPart ? "Spare Part" : "Equipment"%>
                    </span>
                    <%if(item.imageUrl != null && !item.imageUrl.isEmpty()){%>
                    <img src="<%=ctx%><%=item.imageUrl%>" alt="<%=item.name%>" id="mainImg">
                    <%}else{%>
                    <span class="emoji-placeholder"><%=defaultEmoji%></span>
                    <%}%>
                </div>
                <div class="img-thumbnails">
                    <div class="thumb active" onclick="setThumb(this, '<%=ctx%><%=item.imageUrl!=null?item.imageUrl:""%>')">
                        <%if(item.imageUrl != null && !item.imageUrl.isEmpty()){%>
                        <img src="<%=ctx%><%=item.imageUrl%>" alt="main">
                        <%}else{%>
                        <span style="font-size:1.4rem"><%=defaultEmoji%></span>
                        <%}%>
                    </div>
                    <%-- Placeholder thumbnails for visual completeness --%>
                    <div class="thumb" style="opacity:.3">
                        <div class="thumb-add"><i class="fas fa-image"></i><span>View 2</span></div>
                    </div>
                    <div class="thumb" style="opacity:.3">
                        <div class="thumb-add"><i class="fas fa-image"></i><span>View 3</span></div>
                    </div>
                    <div class="thumb" style="opacity:.3">
                        <div class="thumb-add"><i class="fas fa-rotate-right"></i><span>360°</span></div>
                    </div>
                </div>
            </div>

            <%-- Info Panel --%>
            <div class="info-panel">
                <div class="info-card">
                    <div class="product-cat-badge">
                        <i class="fas <%=typeIcon%>"></i>
                        <%=item.categoryName%>
                    </div>
                    <div class="product-name-h"><%=item.name%></div>
                    <div class="product-desc-p">
                        <%=item.description != null && !item.description.isEmpty() ? item.description : "No description available for this product."%>
                    </div>

                    <%-- Price --%>
                    <div class="price-box">
                        <div class="price-main"><%=nf.format((long)item.unitPrice)%> ₫</div>
                        <div class="price-label">/ <%=isPart?"unit":"unit"%> · VAT included</div>
                    </div>

                    <%-- Stock --%>
                    <div class="stock-row" style="background:<%=stockDim%>;border:1px solid <%=!inStock?"rgba(248,113,113,0.2)":lowStock?"rgba(251,191,36,0.2)":"rgba(52,211,153,0.2)"%>">
                        <div class="stock-dot" style="background:<%=stockColor%>"></div>
                        <span class="stock-label" style="color:<%=stockColor%>">
                            <i class="fas <%=stockIcon%>" style="margin-right:5px"></i><%=stockLabel%>
                        </span>
                        <span class="stock-qty"><%=item.availableQty%> unit<%=item.availableQty!=1?"s":""%> available</span>
                    </div>

                    <%-- Add to cart --%>
                    <%if(inStock){%>
                    <form method="post" action="<%=ctx%>/customerShop" id="cartForm">
                        <input type="hidden" name="action"   value="addToCart">
                        <input type="hidden" name="itemType" value="<%=item.itemType%>">
                        <input type="hidden" name="typeId"   value="<%=item.id%>">
                        <input type="hidden" name="quantity" id="qtyHidden" value="1">
                        <div class="cart-area">
                            <%if(isPart){%>
                            <div class="qty-wrap">
                                <button type="button" class="qty-btn" onclick="changeQty(-1)"><i class="fas fa-minus"></i></button>
                                <input class="qty-num" type="text" id="qtyDisplay" value="1" readonly>
                                <button type="button" class="qty-btn" onclick="changeQty(1)"><i class="fas fa-plus"></i></button>
                            </div>
                            <%}%>
                            <button type="submit" class="btn-add-to-cart">
                                <i class="fas fa-cart-plus"></i>
                                <%=isPart ? "Add to Cart" : "Add to Cart (1 unit)"%>
                            </button>
                        </div>
                    </form>
                    <%}else{%>
                    <button class="btn-add-to-cart" disabled>
                        <i class="fas fa-times-circle"></i> Out of Stock
                    </button>
                    <%}%>
                </div>

                <%-- Quick Trust Badges --%>
                <div class="info-card" style="padding:14px 20px">
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
                        <div style="display:flex;align-items:center;gap:9px">
                            <div style="width:32px;height:32px;border-radius:9px;background:rgba(79,126,248,0.12);display:flex;align-items:center;justify-content:center;color:var(--accent-2);font-size:.8rem;flex-shrink:0"><i class="fas fa-shield-alt"></i></div>
                            <div><div style="font-size:.74rem;font-weight:700;color:var(--text-2)">Genuine Product</div><div style="font-size:.67rem;color:var(--muted)">Verified original</div></div>
                        </div>
                        <div style="display:flex;align-items:center;gap:9px">
                            <div style="width:32px;height:32px;border-radius:9px;background:rgba(52,211,153,0.12);display:flex;align-items:center;justify-content:center;color:var(--green);font-size:.8rem;flex-shrink:0"><i class="fas fa-truck"></i></div>
                            <div><div style="font-size:.74rem;font-weight:700;color:var(--text-2)">Fast Delivery</div><div style="font-size:.67rem;color:var(--muted)">1-3 business days</div></div>
                        </div>
                        <div style="display:flex;align-items:center;gap:9px">
                            <div style="width:32px;height:32px;border-radius:9px;background:rgba(251,191,36,0.12);display:flex;align-items:center;justify-content:center;color:var(--amber);font-size:.8rem;flex-shrink:0"><i class="fas fa-undo-alt"></i></div>
                            <div><div style="font-size:.74rem;font-weight:700;color:var(--text-2)">Easy Return</div><div style="font-size:.67rem;color:var(--muted)">Within 7 days</div></div>
                        </div>
                        <div style="display:flex;align-items:center;gap:9px">
                            <div style="width:32px;height:32px;border-radius:9px;background:rgba(167,139,250,0.12);display:flex;align-items:center;justify-content:center;color:var(--purple);font-size:.8rem;flex-shrink:0"><i class="fas fa-headset"></i></div>
                            <div><div style="font-size:.74rem;font-weight:700;color:var(--text-2)">24/7 Support</div><div style="font-size:.67rem;color:var(--muted)">Chat or call</div></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- BOTTOM ROW: 3 cards --%>
        <div class="bottom-grid">

            <%-- Card 1: Specifications --%>
            <div class="detail-card">
                <div class="detail-card-hd">
                    <div class="detail-card-icon" style="background:rgba(79,126,248,0.15);color:var(--accent-2)"><i class="fas fa-list-ul"></i></div>
                    <div class="detail-card-title">Product Specifications</div>
                </div>
                <div class="spec-row">
                    <span class="spec-key">Product ID</span>
                    <span class="spec-val mono">#<%=String.format("%05d", item.id)%></span>
                </div>
                <div class="spec-row">
                    <span class="spec-key">Type</span>
                    <span class="spec-val"><%=isPart ? "Spare Part" : "Equipment"%></span>
                </div>
                <div class="spec-row">
                    <span class="spec-key">Category</span>
                    <span class="spec-val"><%=item.categoryName%></span>
                </div>
                <div class="spec-row">
                    <span class="spec-key">Unit Price</span>
                    <span class="spec-val" style="color:var(--orange)"><%=nf.format((long)item.unitPrice)%> ₫</span>
                </div>
                <div class="spec-row">
                    <span class="spec-key">Availability</span>
                    <span class="spec-val" style="color:<%=stockColor%>"><%=item.availableQty%> units</span>
                </div>
                <div class="spec-row">
                    <span class="spec-key">Order Limit</span>
                    <span class="spec-val"><%=isPart ? "Max "+maxQty+" units" : "1 unit per order"%></span>
                </div>
                <div class="spec-row">
                    <span class="spec-key">Condition</span>
                    <span class="spec-val" style="color:var(--green)">Brand New</span>
                </div>
                <div class="spec-row">
                    <span class="spec-key">Warranty</span>
                    <span class="spec-val"><%=isPart ? "6 months" : "12 months"%></span>
                </div>
            </div>

            <%-- Card 2: Key Features --%>
            <div class="detail-card">
                <div class="detail-card-hd">
                    <div class="detail-card-icon" style="background:<%=isPart?"rgba(52,211,153,0.15)":"rgba(56,189,248,0.15)"%>;color:<%=isPart?"var(--green)":"var(--info)"%>"><i class="fas fa-star"></i></div>
                    <div class="detail-card-title">Key Features</div>
                </div>
                <%if(isPart){%>
                <div class="feature-item">
                    <div class="feature-dot" style="background:rgba(52,211,153,0.15);color:var(--green)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Original manufacturer specification — guaranteed compatible with your system</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:rgba(79,126,248,0.15);color:var(--accent-2)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Quality-tested before shipment — each unit inspected and certified</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:rgba(251,191,36,0.15);color:var(--amber)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Suitable for industrial environments — high durability under load</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:rgba(167,139,250,0.15);color:var(--purple)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Full 6-month warranty with free replacement on manufacturing defects</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:rgba(251,146,60,0.15);color:var(--orange)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Expert installation support available — contact our technical team</div>
                </div>
                <%}else{%>
                <div class="feature-item">
                    <div class="feature-dot" style="background:rgba(56,189,248,0.15);color:var(--info)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Industrial-grade build — designed for continuous 24/7 operation</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:rgba(52,211,153,0.15);color:var(--green)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Comes with unique serial number — registered in DRSMS for full service history</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:rgba(79,126,248,0.15);color:var(--accent-2)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">12-month manufacturer warranty — covers parts and labor</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:rgba(251,191,36,0.15);color:var(--amber)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Free setup and configuration by certified DRSMS technician</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:rgba(167,139,250,0.15);color:var(--purple)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Eligible for DRSMS maintenance contracts after purchase</div>
                </div>
                <%}%>
            </div>

            <%-- Card 3: Shipping & Policy --%>
            <div class="detail-card">
                <div class="detail-card-hd">
                    <div class="detail-card-icon" style="background:rgba(251,146,60,0.15);color:var(--orange)"><i class="fas fa-truck"></i></div>
                    <div class="detail-card-title">Shipping & Policy</div>
                </div>
                <div class="policy-item">
                    <div class="policy-icon" style="background:rgba(79,126,248,0.12);color:var(--accent-2)"><i class="fas fa-box-open"></i></div>
                    <div>
                        <div class="policy-label">Processing Time</div>
                        <div class="policy-sub">Order confirmed within 2 business hours. Packaged same day if ordered before 3PM.</div>
                    </div>
                </div>
                <div class="policy-item">
                    <div class="policy-icon" style="background:rgba(52,211,153,0.12);color:var(--green)"><i class="fas fa-shipping-fast"></i></div>
                    <div>
                        <div class="policy-label">Delivery: 1–3 Business Days</div>
                        <div class="policy-sub">Tracked shipping nationwide. Express delivery available at checkout.</div>
                    </div>
                </div>
                <div class="policy-item">
                    <div class="policy-icon" style="background:rgba(251,191,36,0.12);color:var(--amber)"><i class="fas fa-undo-alt"></i></div>
                    <div>
                        <div class="policy-label">Return Policy: 7 Days</div>
                        <div class="policy-sub">Unused and unopened items accepted. Defective items replaced free of charge.</div>
                    </div>
                </div>
                <div class="policy-item">
                    <div class="policy-icon" style="background:rgba(167,139,250,0.12);color:var(--purple)"><i class="fas fa-credit-card"></i></div>
                    <div>
                        <div class="policy-label">Payment Options</div>
                        <div class="policy-sub">Cash on delivery, VNPay, bank transfer. Invoice issued automatically.</div>
                    </div>
                </div>
                <div class="policy-item">
                    <div class="policy-icon" style="background:rgba(248,113,113,0.12);color:var(--danger)"><i class="fas fa-headset"></i></div>
                    <div>
                        <div class="policy-label">Need Help?</div>
                        <div class="policy-sub"><a href="<%=ctx%>/customerChat" style="color:var(--accent-2);text-decoration:none;font-weight:600">Chat with support</a> — average response under 5 minutes.</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    const MAX_QTY = <%=maxQty%>;
    const IS_PART = <%=isPart%>;
    let qty = 1;

    function changeQty(delta) {
        qty = Math.max(1, Math.min(MAX_QTY, qty + delta));
        document.getElementById('qtyDisplay').value = qty;
        document.getElementById('qtyHidden').value  = qty;
    }

    function setThumb(el, src) {
        document.querySelectorAll('.thumb').forEach(t => t.classList.remove('active'));
        el.classList.add('active');
        const main = document.getElementById('mainImg');
        if (main && src) main.src = src;
    }
</script>
</body>
</html>
