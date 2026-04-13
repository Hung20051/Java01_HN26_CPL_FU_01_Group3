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

            *,*::before,*::after{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            html{
                scroll-behavior:smooth
            }
            body{
                font-family:'Sora',sans-serif;
                background:var(--bg);
                color:var(--text-b);
                min-height:100vh;
                display:flex;
            }
            ::-webkit-scrollbar{
                width:4px
            }
            ::-webkit-scrollbar-track{
                background:transparent
            }
            ::-webkit-scrollbar-thumb{
                background:rgba(79,70,229,0.3);
                border-radius:4px
            }

            /* ═══════════ SIDEBAR ═══════════ */
            .sb{
                width:var(--sb-width);
                min-height:100vh;
                background:var(--sb-bg);
                border-right:1px solid rgba(79,70,229,0.2);
                display:flex;
                flex-direction:column;
                position:fixed;
                top:0;
                left:0;
                z-index:100;
                box-shadow:4px 0 24px rgba(0,0,0,0.15);
            }
            .sb-brand{
                padding:20px 16px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid var(--sb-border);
            }
            .sb-logo{
                width:36px;
                height:36px;
                background:linear-gradient(135deg,#818cf8,#a78bfa);
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem;
                box-shadow:0 4px 12px rgba(129,140,248,0.4);
                flex-shrink:0;
            }
            .sb-name{
                color:#fff;
                font-size:1.05rem;
                font-weight:800;
                letter-spacing:-.3px
            }
            .sb-role{
                display:inline-flex;
                align-items:center;
                background:rgba(129,140,248,0.2);
                border:1px solid rgba(129,140,248,0.3);
                color:var(--sb-accent-2);
                font-size:.6rem;
                font-weight:700;
                letter-spacing:1px;
                text-transform:uppercase;
                padding:2px 8px;
                border-radius:20px;
                margin-top:3px;
            }
            .sb-nav{
                flex:1;
                padding:12px 10px;
                overflow-y:auto
            }
            .sb-lbl{
                color:rgba(255,255,255,0.22);
                font-size:.6rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.6px;
                padding:0 8px;
                margin:14px 0 5px;
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:9px;
                padding:8px 10px;
                border-radius:9px;
                margin-bottom:1px;
                color:var(--sb-text);
                text-decoration:none;
                font-size:.81rem;
                font-weight:500;
                transition:all .18s;
                border-left:2px solid transparent;
            }
            .sb-item i{
                width:28px;
                height:28px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.78rem;
                border-radius:8px;
                background:rgba(255,255,255,0.06);
                flex-shrink:0;
                transition:all .18s;
            }
            .sb-item.on{
                color:#fff;
                background:var(--sb-item-on);
                border-left-color:var(--sb-accent);
            }
            .sb-item.on i{
                background:rgba(129,140,248,0.3);
                color:var(--sb-accent-2)
            }
            .sb-item:hover:not(.on){
                color:rgba(255,255,255,0.78);
                background:rgba(255,255,255,0.06);
            }
            .sb-badge{
                margin-left:auto;
                background:#ef4444;
                color:#fff;
                font-size:.6rem;
                font-weight:700;
                padding:2px 7px;
                border-radius:20px;
                box-shadow:0 2px 6px rgba(239,68,68,0.5);
            }
            .sb-foot{
                padding:12px 10px 14px;
                border-top:1px solid var(--sb-border)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:10px;
                background:rgba(255,255,255,0.07);
                border:1px solid rgba(255,255,255,0.1);
                margin-bottom:5px;
                text-decoration:none;
                transition:all .18s;
            }
            .sb-user:hover{
                background:rgba(129,140,248,0.18);
                border-color:rgba(129,140,248,0.3)
            }
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:linear-gradient(135deg,#818cf8,#a78bfa);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                font-weight:700;
                flex-shrink:0;
                overflow:hidden;
            }
            .sb-ava img{
                width:34px;
                height:34px;
                object-fit:cover;
                border-radius:50%
            }
            .sb-uname{
                color:#fff;
                font-size:.8rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,0.35);
                font-size:.66rem;
                margin-top:1px
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:8px 10px;
                border-radius:9px;
                color:rgba(255,255,255,0.3);
                text-decoration:none;
                font-size:.78rem;
                transition:all .18s;
            }
            .sb-logout:hover{
                color:#fca5a5;
                background:rgba(239,68,68,0.1)
            }

            /* ═══════════ MAIN (light) ═══════════ */
            .main{
                margin-left:var(--sb-width);
                flex:1;
                min-height:100vh;
                display:flex;
                flex-direction:column
            }

            .topbar{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:18px 28px;
                background:var(--bg-topbar);
                border-bottom:1px solid var(--border-light);
                position:sticky;
                top:0;
                z-index:50;
                box-shadow:0 1px 6px rgba(0,0,0,0.06);
            }
            .topbar-title{
                font-size:1.2rem;
                font-weight:800;
                color:var(--text-h);
                letter-spacing:-.3px
            }
            .topbar-sub{
                color:var(--text-s);
                font-size:.78rem;
                margin-top:2px
            }

            .btn-cart-top{
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:10px 18px;
                border-radius:11px;
                background:#fff;
                border:1.5px solid var(--border-light);
                color:var(--text-m);
                text-decoration:none;
                font-size:.83rem;
                font-weight:600;
                transition:all .2s;
                position:relative;
            }
            .btn-cart-top:hover{
                background:#fff7ed;
                border-color:#fed7aa;
                color:var(--orange)
            }
            .cart-badge{
                position:absolute;
                top:-7px;
                right:-7px;
                background:var(--red);
                color:#fff;
                font-size:.6rem;
                font-weight:700;
                padding:2px 6px;
                border-radius:20px;
            }

            .content{
                padding:24px 28px;
                flex:1
            }

            /* ── FLASH ALERTS ── */
            .alert{
                display:flex;
                align-items:center;
                gap:10px;
                padding:12px 16px;
                border-radius:12px;
                font-size:.82rem;
                margin-bottom:18px;
                animation:cardIn .4s ease both;
            }
            .alert-success{
                background:#d1fae5;
                border:1px solid #a7f3d0;
                color:#065f46
            }
            .alert-error  {
                background:#fee2e2;
                border:1px solid #fca5a5;
                color:#991b1b
            }

            /* ── SHOP TABS ── */
            .shop-tabs{
                display:flex;
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:12px;
                overflow:hidden;
                margin-bottom:22px;
                width:fit-content;
                box-shadow:0 1px 4px rgba(0,0,0,0.04);
            }
            .shop-tab{
                padding:10px 26px;
                font-size:.83rem;
                font-weight:600;
                text-decoration:none;
                color:var(--text-m);
                border-right:1px solid var(--border-light);
                display:flex;
                align-items:center;
                gap:7px;
                transition:all .2s;
            }
            .shop-tab:last-child{
                border-right:none
            }
            .shop-tab:hover{
                background:var(--primary-light);
                color:var(--primary-2)
            }
            .shop-tab.active{
                background:var(--primary);
                color:#fff
            }

            /* ── TOOLBAR ── */
            .toolbar{
                display:flex;
                gap:10px;
                align-items:center;
                margin-bottom:16px;
                flex-wrap:wrap;
            }
            .search-input{
                flex:1;
                min-width:220px;
                padding:10px 14px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:10px;
                font-family:'Sora',sans-serif;
                font-size:.83rem;
                color:var(--text-b);
                outline:none;
                transition:all .2s;
            }
            .search-input::placeholder{
                color:var(--text-s)
            }
            .search-input:focus{
                border-color:rgba(79,70,229,0.4);
                background:#faf9ff;
                box-shadow:0 0 0 3px rgba(79,70,229,0.07);
            }
            .select-box{
                padding:10px 12px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:10px;
                font-family:'Sora',sans-serif;
                font-size:.83rem;
                color:var(--text-b);
                outline:none;
                transition:all .2s;
            }
            .select-box:focus{
                border-color:rgba(79,70,229,0.4)
            }
            .select-box option{
                background:#fff;
                color:var(--text-b)
            }
            .btn-search{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:10px 20px;
                border-radius:10px;
                background:var(--primary);
                color:#fff;
                border:none;
                cursor:pointer;
                font-family:'Sora',sans-serif;
                font-size:.83rem;
                font-weight:700;
                box-shadow:0 3px 14px rgba(79,70,229,0.28);
                transition:all .2s;
            }
            .btn-search:hover{
                background:#4338ca;
                transform:translateY(-1px);
                box-shadow:0 6px 20px rgba(79,70,229,0.42)
            }

            .result-info{
                font-size:.78rem;
                color:var(--text-s);
                margin-bottom:18px
            }
            .result-info strong{
                color:var(--text-b)
            }

            /* Section label */
            .section-lbl{
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:2px;
                color:var(--primary-2);
                margin-bottom:13px;
                display:flex;
                align-items:center;
                gap:10px;
            }
            .section-lbl::after{
                content:'';
                flex:1;
                height:1px;
                background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)
            }

            /* ── EQUIPMENT LIST ── */
            .product-list{
                display:flex;
                flex-direction:column;
                gap:14px;
                margin-bottom:28px;
            }
            .equip-card{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                padding:18px 22px;
                display:flex;
                align-items:center;
                gap:20px;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                transition:all .22s;
                animation:cardIn .45s ease both;
                position:relative;
                overflow:hidden;
            }
            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(16px)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }
            .equip-card::before{
                content:'';
                position:absolute;
                top:0;
                left:0;
                bottom:0;
                width:3px;
                background:linear-gradient(180deg,var(--info),var(--primary));
                opacity:0;
                transition:opacity .22s;
                border-radius:16px 0 0 16px;
            }
            .equip-card:hover{
                transform:translateY(-2px);
                box-shadow:0 10px 28px rgba(79,70,229,0.1);
                border-color:rgba(99,102,241,0.25);
            }
            .equip-card:hover::before{
                opacity:1
            }

            .equip-icon{
                width:68px;
                height:68px;
                border-radius:16px;
                background:linear-gradient(135deg,var(--primary-light),#e0f2fe);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.9rem;
                flex-shrink:0;
                border:1px solid var(--border-light);
            }
            .equip-info{
                flex:1;
                min-width:0
            }
            .equip-cat{
                font-size:.67rem;
                font-weight:700;
                color:var(--info);
                text-transform:uppercase;
                letter-spacing:.8px;
                margin-bottom:4px;
            }
            .equip-name{
                font-size:.98rem;
                font-weight:700;
                color:var(--text-h);
                margin-bottom:4px;
            }
            .equip-desc{
                font-size:.79rem;
                color:var(--text-m);
                margin-bottom:8px;
                line-height:1.5;
            }
            .equip-stock{
                font-size:.73rem;
                font-weight:600;
                color:var(--green);
                display:inline-flex;
                align-items:center;
                gap:5px;
            }
            .equip-stock.low{
                color:var(--amber)
            }

            .equip-right{
                text-align:right;
                flex-shrink:0;
                display:flex;
                flex-direction:column;
                align-items:flex-end;
                gap:10px;
            }
            .equip-price{
                font-size:1.15rem;
                font-weight:800;
                color:var(--orange);
            }
            .btn-add-equip{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:10px 22px;
                border-radius:10px;
                background:var(--info);
                color:#fff;
                border:none;
                cursor:pointer;
                font-family:'Sora',sans-serif;
                font-size:.83rem;
                font-weight:700;
                box-shadow:0 3px 12px rgba(2,132,199,0.25);
                transition:all .2s;
            }
            .btn-add-equip:hover{
                background:#0369a1;
                transform:translateY(-1px);
                box-shadow:0 6px 20px rgba(2,132,199,0.38);
            }
            .equip-note{
                font-size:.69rem;
                color:var(--text-s);
                max-width:180px;
                text-align:right;
                line-height:1.4;
            }

            /* ── PAGINATION ── */
            .pagination{
                display:flex;
                justify-content:center;
                align-items:center;
                gap:6px;
                margin-top:8px;
            }
            .page-btn{
                padding:7px 13px;
                background:#fff;
                border:1px solid var(--border-light);
                border-radius:8px;
                font-size:.79rem;
                font-weight:600;
                text-decoration:none;
                color:var(--text-m);
                transition:all .2s;
            }
            .page-btn:hover{
                background:var(--primary-light);
                border-color:rgba(99,102,241,0.3);
                color:var(--primary-2)
            }
            .page-btn.active{
                background:var(--primary);
                color:#fff;
                border-color:transparent;
                box-shadow:0 3px 10px rgba(79,70,229,0.3);
            }
            .page-btn.disabled{
                opacity:.35;
                pointer-events:none
            }

            /* ── EMPTY STATE ── */
            .empty-state{
                text-align:center;
                padding:60px 24px;
                color:var(--text-s);
                font-size:.83rem;
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                animation:cardIn .45s ease both;
            }
            .empty-state i{
                font-size:2.8rem;
                display:block;
                margin-bottom:14px;
                opacity:.2;
                color:var(--text-m)
            }
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
                <a href="<%=ctx%>/customerDashboard" class="sb-item">
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
                <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item on">
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
                                <div class="equip-name" style="cursor:pointer;transition:color .2s"
                                     onmouseover="this.style.color = 'var(--info)'"
                                     onmouseout="this.style.color = ''"><%=item.name%></div>
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
