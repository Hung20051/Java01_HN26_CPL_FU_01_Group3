<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.ShopDAO.ShopItem, dao.ReviewDAO, java.util.*, java.text.*" %>
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

    String typeIcon    = isPart ? "fa-puzzle-piece" : "fa-server";
    String defaultEmoji= isPart ? "🔧"              : "🖥️";

    boolean inStock  = item.availableQty > 0;
    boolean lowStock = item.availableQty > 0 && item.availableQty <= 3;
    String stockLabel = !inStock ? "Out of Stock" : lowStock ? "Low Stock" : "In Stock";
    String stockColor = !inStock ? "#dc2626"  : lowStock ? "#d97706" : "#16a34a";
    String stockBg    = !inStock ? "#fee2e2"  : lowStock ? "#fef3c7" : "#d1fae5";
    String stockBorder= !inStock ? "#fca5a5"  : lowStock ? "#fde68a" : "#a7f3d0";
    String stockIcon  = !inStock ? "fa-times-circle":lowStock ? "fa-exclamation-triangle":"fa-check-circle";

    String accentLight = isPart ? "#d1fae5" : "#e0f2fe";
    String accentColor = isPart ? "#16a34a" : "#0284c7";
    String accentBorder= isPart ? "#a7f3d0" : "#bae6fd";

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
    <script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"></script>
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

        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{scroll-behavior:smooth}
        body{font-family:'Sora',sans-serif;background:var(--bg);color:var(--text-b);min-height:100vh;display:flex;}
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-track{background:transparent}
        ::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px}

        /* ═══════════ SIDEBAR ═══════════ */
        .sb{
            width:var(--sb-width); min-height:100vh;
            background:var(--sb-bg);
            border-right:1px solid rgba(79,70,229,0.2);
            display:flex; flex-direction:column;
            position:fixed; top:0; left:0; z-index:100;
            box-shadow:4px 0 24px rgba(0,0,0,0.15);
        }
        .sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border);}
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#818cf8,#a78bfa);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;box-shadow:0 4px 12px rgba(129,140,248,0.4);flex-shrink:0;}
        .sb-name{color:#fff;font-size:1.05rem;font-weight:800;letter-spacing:-.3px}
        .sb-role{display:inline-flex;align-items:center;background:rgba(129,140,248,0.2);border:1px solid rgba(129,140,248,0.3);color:var(--sb-accent-2);font-size:.6rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:2px 8px;border-radius:20px;margin-top:3px;}
        .sb-nav{flex:1;padding:12px 10px;overflow-y:auto}
        .sb-lbl{color:rgba(255,255,255,0.22);font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:1.6px;padding:0 8px;margin:14px 0 5px;}
        .sb-item{display:flex;align-items:center;gap:9px;padding:8px 10px;border-radius:9px;margin-bottom:1px;color:var(--sb-text);text-decoration:none;font-size:.81rem;font-weight:500;transition:all .18s;border-left:2px solid transparent;}
        .sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.78rem;border-radius:8px;background:rgba(255,255,255,0.06);flex-shrink:0;transition:all .18s;}
        .sb-item.on{color:#fff;background:var(--sb-item-on);border-left-color:var(--sb-accent);}
        .sb-item.on i{background:rgba(129,140,248,0.3);color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){color:rgba(255,255,255,0.78);background:rgba(255,255,255,0.06);}
        .sb-badge{margin-left:auto;background:#ef4444;color:#fff;font-size:.6rem;font-weight:700;padding:2px 7px;border-radius:20px;box-shadow:0 2px 6px rgba(239,68,68,0.5);}
        .sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border)}
        .sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);margin-bottom:5px;text-decoration:none;transition:all .18s;}
        .sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3)}
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.8rem;font-weight:600}
        .sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem;margin-top:1px}
        .sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
        .sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1)}

        /* ═══════════ MAIN (light) ═══════════ */
        .main{margin-left:var(--sb-width);flex:1;min-height:100vh;display:flex;flex-direction:column}

        .topbar{
            display:flex;justify-content:space-between;align-items:center;
            padding:14px 28px;
            background:var(--bg-topbar);
            border-bottom:1px solid var(--border-light);
            position:sticky;top:0;z-index:50;
            box-shadow:0 1px 6px rgba(0,0,0,0.06);
        }
        .breadcrumb{display:flex;align-items:center;gap:7px;font-size:.76rem;color:var(--text-s);}
        .breadcrumb a{color:var(--text-s);text-decoration:none;transition:color .18s;}
        .breadcrumb a:hover{color:var(--primary-2)}
        .bc-sep{color:var(--border-light)}
        .bc-cur{color:var(--text-m);font-weight:600}
        .btn-cart-top{display:inline-flex;align-items:center;gap:8px;padding:9px 16px;border-radius:11px;background:#fff;border:1.5px solid var(--border-light);color:var(--text-m);text-decoration:none;font-size:.82rem;font-weight:600;transition:all .2s;position:relative;}
        .btn-cart-top:hover{background:#fff7ed;border-color:#fed7aa;color:var(--orange)}
        .cart-badge{position:absolute;top:-7px;right:-7px;background:var(--red);color:#fff;font-size:.6rem;font-weight:700;padding:2px 6px;border-radius:20px;}
        .btn-back{display:inline-flex;align-items:center;gap:7px;padding:9px 16px;border-radius:10px;background:#fff;color:var(--text-m);border:1.5px solid var(--border-light);text-decoration:none;font-size:.81rem;font-weight:600;transition:all .2s;}
        .btn-back:hover{background:#f3f4f6;border-color:#d1d5db;color:var(--text-b)}

        .content{padding:24px 28px;flex:1}

        /* Alerts */
        .alert{display:flex;align-items:center;gap:10px;padding:12px 16px;border-radius:12px;font-size:.82rem;margin-bottom:18px;animation:fadeIn .4s ease both;}
        .alert-success{background:#d1fae5;border:1px solid #a7f3d0;color:#065f46}
        .alert-error  {background:#fee2e2;border:1px solid #fca5a5;color:#991b1b}
        @keyframes fadeIn{from{opacity:0;transform:translateY(-8px)}to{opacity:1;transform:none}}

        /* ════ PRODUCT DETAIL LAYOUT ════ */
        @keyframes slideUp{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:none}}

        .detail-grid{
            display:grid; grid-template-columns:1fr 1fr;
            gap:22px; align-items:start; margin-bottom:24px;
        }

        /* ── Image Panel ── */
        .img-panel{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:20px; overflow:hidden;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
            animation:slideUp .5s ease both;
        }
        .img-main{
            height:320px;
            display:flex;align-items:center;justify-content:center;
            background:linear-gradient(135deg,<%=accentLight%>,#f8faff);
            position:relative;overflow:hidden;cursor:zoom-in;
        }
        .img-main::before{
            content:'';position:absolute;inset:0;
            background:radial-gradient(circle at 50% 30%,rgba(255,255,255,0.5),transparent 70%);
        }
        .img-main img{
            max-width:88%;max-height:88%;object-fit:contain;
            filter:drop-shadow(0 8px 24px rgba(0,0,0,0.12));
            transition:transform .4s ease;position:relative;z-index:1;
        }
        .img-main:hover img{transform:scale(1.06)}
        .img-main .emoji-placeholder{font-size:6rem;position:relative;z-index:1}

        .img-badge{
            position:absolute;top:14px;left:14px;z-index:2;
            padding:5px 12px;border-radius:20px;
            font-size:.67rem;font-weight:700;letter-spacing:.5px;text-transform:uppercase;
        }
        .img-type-badge{
            background:<%=accentLight%>;
            border:1px solid <%=accentBorder%>;
            color:<%=accentColor%>;
        }

        .img-thumbnails{
            display:flex;gap:10px;padding:12px 14px;
            border-top:1px solid var(--border-light2);
            background:#fafbff;
        }
        .thumb{
            width:60px;height:60px;border-radius:10px;
            background:var(--primary-light);
            border:2px solid var(--border-light);
            display:flex;align-items:center;justify-content:center;
            cursor:pointer;overflow:hidden;transition:all .2s;flex-shrink:0;
        }
        .thumb.active{border-color:<%=accentColor%>;box-shadow:0 0 0 3px <%=accentLight%>;}
        .thumb img{width:100%;height:100%;object-fit:contain;padding:6px}
        .thumb-add{display:flex;flex-direction:column;align-items:center;justify-content:center;color:var(--text-s);font-size:.58rem;gap:4px;text-align:center;line-height:1.2;}
        .thumb-add i{font-size:.78rem}

        /* ── Info Panel ── */
        .info-panel{display:flex;flex-direction:column;gap:14px;animation:slideUp .5s ease .08s both;}

        .info-card{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:18px;padding:20px 22px;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
        }

        .product-cat-badge{
            display:inline-flex;align-items:center;gap:6px;
            padding:4px 12px;border-radius:20px;font-size:.67rem;font-weight:700;
            letter-spacing:.8px;text-transform:uppercase;margin-bottom:10px;
            background:<%=accentLight%>;
            border:1px solid <%=accentBorder%>;
            color:<%=accentColor%>;
        }
        .product-name-h{font-size:1.45rem;font-weight:800;color:var(--text-h);line-height:1.2;letter-spacing:-.4px;margin-bottom:8px;}
        .product-desc-p{font-size:.84rem;color:var(--text-m);line-height:1.7;font-weight:400;margin-bottom:16px;}

        /* Price box */
        .price-box{display:flex;align-items:flex-end;gap:12px;margin-bottom:13px;}
        .price-main{font-size:1.95rem;font-weight:800;color:var(--orange);letter-spacing:-.5px}
        .price-label{font-size:.71rem;color:var(--text-s);margin-bottom:6px}

        /* Stock indicator */
        .stock-row{
            display:flex;align-items:center;gap:10px;
            padding:10px 14px;border-radius:11px;margin-bottom:16px;
        }
        .stock-dot{width:9px;height:9px;border-radius:50%;flex-shrink:0;animation:pulse 2s ease-in-out infinite;}
        @keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.6;transform:scale(1.3)}}
        .stock-label{font-size:.82rem;font-weight:700}
        .stock-qty{font-size:.76rem;color:var(--text-s);margin-left:auto}

        /* Add to cart area */
        .cart-area{display:flex;gap:10px;align-items:center}
        .qty-wrap{
            display:flex;align-items:center;
            background:#fff;border:1.5px solid var(--border-light);
            border-radius:12px;overflow:hidden;
        }
        .qty-btn{
            width:40px;height:48px;display:flex;align-items:center;justify-content:center;
            background:none;border:none;cursor:pointer;color:var(--text-m);font-size:1rem;transition:all .15s;
        }
        .qty-btn:hover{background:var(--primary-light);color:var(--primary-2)}
        .qty-num{width:52px;text-align:center;background:none;border:none;outline:none;font-family:'Sora',sans-serif;font-size:.94rem;font-weight:700;color:var(--text-b);}
        .qty-num::-webkit-inner-spin-button{display:none}
        .btn-add-to-cart{
            flex:1;padding:13px 20px;
            background:<%=accentColor%>;
            color:#fff;border:none;border-radius:12px;
            font-family:'Sora',sans-serif;font-size:.9rem;font-weight:800;cursor:pointer;
            display:flex;align-items:center;justify-content:center;gap:8px;
            box-shadow:0 4px 16px <%=accentLight%>;
            transition:all .25s;
        }
        .btn-add-to-cart:hover{transform:translateY(-2px);filter:brightness(1.1);box-shadow:0 8px 24px <%=accentLight%>;}
        .btn-add-to-cart:disabled{opacity:.4;cursor:not-allowed;transform:none;filter:none}

        /* Trust badges grid */
        .trust-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
        .trust-item{display:flex;align-items:center;gap:9px}
        .trust-icon{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.8rem;flex-shrink:0}
        .trust-title{font-size:.73rem;font-weight:700;color:var(--text-h)}
        .trust-sub{font-size:.66rem;color:var(--text-s);margin-top:1px}

        /* ════ BOTTOM ROW ════ */
        .bottom-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;animation:slideUp .5s ease .16s both;}

        .detail-card{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:16px;padding:18px;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
        }
        .detail-card-hd{display:flex;align-items:center;gap:9px;margin-bottom:14px;padding-bottom:11px;border-bottom:1px solid var(--border-light2);}
        .detail-card-icon{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.82rem;flex-shrink:0}
        .detail-card-title{font-size:.81rem;font-weight:700;color:var(--text-h)}

        /* Spec table */
        .spec-row{display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid var(--border-light2);}
        .spec-row:last-child{border-bottom:none}
        .spec-key{font-size:.74rem;color:var(--text-s);font-weight:500}
        .spec-val{font-size:.77rem;color:var(--text-b);font-weight:600;text-align:right}
        .spec-val.mono{font-family:'Courier New',monospace;color:var(--primary-2)}

        /* Feature list */
        .feature-item{display:flex;align-items:flex-start;gap:10px;padding:9px 0;border-bottom:1px solid var(--border-light2);}
        .feature-item:last-child{border-bottom:none}
        .feature-dot{width:22px;height:22px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.62rem;flex-shrink:0;margin-top:1px}
        .feature-text{font-size:.77rem;color:var(--text-m);line-height:1.5}

        /* Shipping / policy */
        .policy-item{display:flex;align-items:center;gap:11px;padding:10px 0;border-bottom:1px solid var(--border-light2);}
        .policy-item:last-child{border-bottom:none}
        .policy-icon{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:.85rem;flex-shrink:0}
        .policy-label{font-size:.77rem;font-weight:700;color:var(--text-h)}
        .policy-sub{font-size:.71rem;color:var(--text-m);margin-top:2px}
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
        <a href="<%=ctx%>/customerDashboard" class="sb-item"><i class="fas fa-home"></i> Dashboard</a>
        <div class="sb-lbl">Services</div>
        <a href="<%=ctx%>/customerServiceRequests" class="sb-item">
            <i class="fas fa-clipboard-list"></i> Repair Requests
            <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
        </a>
        <a href="<%=ctx%>/customerContracts"  class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
        <a href="<%=ctx%>/customerEquipment"  class="sb-item"><i class="fas fa-desktop"></i> My Equipment</a>
        <div class="sb-lbl">Shop</div>
        <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item <%=isPart?"on":""%>"><i class="fas fa-puzzle-piece"></i> Parts</a>
        <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item <%=!isPart?"on":""%>"><i class="fas fa-server"></i> Equipment</a>
        <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item">
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
                    <img src="<%=item.imageUrl!=null&&item.imageUrl.startsWith("http")?item.imageUrl:ctx+item.imageUrl%>" alt="<%=item.name%>" id="mainImg">
                    <%}else{%>
                    <span class="emoji-placeholder"><%=defaultEmoji%></span>
                    <%}%>
                </div>
                <div class="img-thumbnails">
                    <div class="thumb active" onclick="setThumb(this, '<%=ctx%><%=item.imageUrl!=null?item.imageUrl:""%>')">
                        <%if(item.imageUrl != null && !item.imageUrl.isEmpty()){%>
                        <img src="<%=item.imageUrl!=null&&item.imageUrl.startsWith("http")?item.imageUrl:ctx+item.imageUrl%>" alt="main">
                        <%}else{%>
                        <span style="font-size:1.4rem"><%=defaultEmoji%></span>
                        <%}%>
                    </div>
                    
                </div>
            </div>

            <%-- Info Panel --%>
            <div class="info-panel">
                <div class="info-card">
                    <div class="product-cat-badge">
                        <i class="fas <%=typeIcon%>"></i> <%=item.categoryName%>
                    </div>
                    <div class="product-name-h"><%=item.name%></div>
                    <div class="product-desc-p">
                        <%=item.description != null && !item.description.isEmpty() ? item.description : "No description available for this product."%>
                    </div>

                    <%-- Price --%>
                    <div class="price-box">
                        <div class="price-main"><%=nf.format((long)item.unitPrice)%> ₫</div>
                        <div class="price-label">/ unit · VAT included</div>
                    </div>

                    <%-- Stock --%>
                    <div class="stock-row" style="background:<%=stockBg%>;border:1px solid <%=stockBorder%>">
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

                <%-- Trust Badges --%>
                <div class="info-card" style="padding:14px 18px">
                    <div class="trust-grid">
                        <div class="trust-item">
                            <div class="trust-icon" style="background:var(--primary-light);color:var(--primary-2)"><i class="fas fa-shield-alt"></i></div>
                            <div><div class="trust-title">Genuine Product</div><div class="trust-sub">Verified original</div></div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-icon" style="background:#d1fae5;color:var(--green)"><i class="fas fa-truck"></i></div>
                            <div><div class="trust-title">Fast Delivery</div><div class="trust-sub">1-3 business days</div></div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-icon" style="background:#fef3c7;color:var(--amber)"><i class="fas fa-undo-alt"></i></div>
                            <div><div class="trust-title">Easy Return</div><div class="trust-sub">Within 7 days</div></div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-icon" style="background:#f5f3ff;color:var(--purple)"><i class="fas fa-headset"></i></div>
                            <div><div class="trust-title">24/7 Support</div><div class="trust-sub">Chat or call</div></div>
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
                    <div class="detail-card-icon" style="background:var(--primary-light);color:var(--primary-2)"><i class="fas fa-list-ul"></i></div>
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
                    <div class="detail-card-icon" style="background:<%=accentLight%>;color:<%=accentColor%>"><i class="fas fa-star"></i></div>
                    <div class="detail-card-title">Key Features</div>
                </div>
                <%if(isPart){%>
                <div class="feature-item">
                    <div class="feature-dot" style="background:#d1fae5;color:var(--green)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Original manufacturer specification — guaranteed compatible with your system</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:var(--primary-light);color:var(--primary-2)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Quality-tested before shipment — each unit inspected and certified</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:#fef3c7;color:var(--amber)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Suitable for industrial environments — high durability under load</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:#f5f3ff;color:var(--purple)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Full 6-month warranty with free replacement on manufacturing defects</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:#ffedd5;color:var(--orange)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Expert installation support available — contact our technical team</div>
                </div>
                <%}else{%>
                <div class="feature-item">
                    <div class="feature-dot" style="background:#e0f2fe;color:var(--info)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Industrial-grade build — designed for continuous 24/7 operation</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:#d1fae5;color:var(--green)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Comes with unique serial number — registered in DRSMS for full service history</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:var(--primary-light);color:var(--primary-2)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">12-month manufacturer warranty — covers parts and labor</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:#fef3c7;color:var(--amber)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Free setup and configuration by certified DRSMS technician</div>
                </div>
                <div class="feature-item">
                    <div class="feature-dot" style="background:#f5f3ff;color:var(--purple)"><i class="fas fa-check"></i></div>
                    <div class="feature-text">Eligible for DRSMS maintenance contracts after purchase</div>
                </div>
                <%}%>
            </div>

            <%-- Card 3: Shipping & Policy --%>
            <div class="detail-card">
                <div class="detail-card-hd">
                    <div class="detail-card-icon" style="background:#ffedd5;color:var(--orange)"><i class="fas fa-truck"></i></div>
                    <div class="detail-card-title">Shipping & Policy</div>
                </div>
                <div class="policy-item">
                    <div class="policy-icon" style="background:var(--primary-light);color:var(--primary-2)"><i class="fas fa-box-open"></i></div>
                    <div>
                        <div class="policy-label">Processing Time</div>
                        <div class="policy-sub">Order confirmed within 2 business hours. Packaged same day if ordered before 3PM.</div>
                    </div>
                </div>
                <div class="policy-item">
                    <div class="policy-icon" style="background:#d1fae5;color:var(--green)"><i class="fas fa-shipping-fast"></i></div>
                    <div>
                        <div class="policy-label">Delivery: 1–3 Business Days</div>
                        <div class="policy-sub">Tracked shipping nationwide. Express delivery available at checkout.</div>
                    </div>
                </div>
                <div class="policy-item">
                    <div class="policy-icon" style="background:#fef3c7;color:var(--amber)"><i class="fas fa-undo-alt"></i></div>
                    <div>
                        <div class="policy-label">Return Policy: 7 Days</div>
                        <div class="policy-sub">Unused and unopened items accepted. Defective items replaced free of charge.</div>
                    </div>
                </div>
                <div class="policy-item">
                    <div class="policy-icon" style="background:#f5f3ff;color:var(--purple)"><i class="fas fa-credit-card"></i></div>
                    <div>
                        <div class="policy-label">Payment Options</div>
                        <div class="policy-sub">Cash on delivery, VNPay, bank transfer. Invoice issued automatically.</div>
                    </div>
                </div>
                <div class="policy-item">
                    <div class="policy-icon" style="background:#fee2e2;color:var(--red)"><i class="fas fa-headset"></i></div>
                    <div>
                        <div class="policy-label">Need Help?</div>
                        <div class="policy-sub"><a href="<%=ctx%>/customerChat" style="color:var(--primary-2);text-decoration:none;font-weight:600">Chat with support</a> — average response under 5 minutes.</div>
                    </div>
                </div>
            </div>
        </div>

        <%-- ═══════════ [THÊM MỚI] REVIEW SECTION ═══════════ --%>
        <%
            List<ReviewDAO.Review> reviews = (List<ReviewDAO.Review>) request.getAttribute("reviews");
            double avgRating = request.getAttribute("avgRating") != null ? (double)request.getAttribute("avgRating") : 0;
            Map<Integer,Integer> ratingDist = (Map<Integer,Integer>) request.getAttribute("ratingDist");
            boolean hasReviewed = request.getAttribute("hasReviewed") != null && (boolean)request.getAttribute("hasReviewed");
            int totalReviews = reviews != null ? reviews.size() : 0;
            if (ratingDist == null) ratingDist = new java.util.HashMap<>();
        %>
        <div style="background:#fff;border:1px solid var(--border-light);border-radius:16px;padding:28px;margin-bottom:28px;">

            <%-- Header --%>
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;padding-bottom:16px;border-bottom:1px solid var(--border-light2);">
                <h3 style="font-size:1.1rem;font-weight:700;color:var(--text-h);display:flex;align-items:center;gap:8px;">
                    <span style="background:#d1fae5;color:var(--green);width:32px;height:32px;border-radius:8px;display:inline-flex;align-items:center;justify-content:center;font-size:.85rem;">
                        <i class="fas fa-star"></i>
                    </span>
                    Product Reviews
                </h3>
                <span style="font-size:.82rem;color:var(--text-s);"><%=totalReviews%> review<%=totalReviews!=1?"s":""%></span>
            </div>

            <%if(totalReviews > 0){%>
            <%-- Summary bar --%>
            <div style="display:flex;gap:24px;align-items:center;background:#f9fafb;border-radius:12px;padding:16px 20px;margin-bottom:20px;">
                <div style="text-align:center;padding-right:20px;border-right:1px solid var(--border-light);">
                    <div style="font-size:2.4rem;font-weight:800;color:var(--green);line-height:1;">
                        <%=String.format("%.1f", avgRating)%>
                    </div>
                    <div style="display:flex;gap:2px;justify-content:center;margin:5px 0 3px;">
                        <%for(int s=1;s<=5;s++){%>
                        <span style="color:<%=s<=Math.round(avgRating)?"#f59e0b":"#e5e7eb"%>;font-size:14px;">★</span>
                        <%}%>
                    </div>
                    <div style="font-size:.72rem;color:var(--text-s);"><%=totalReviews%> review<%=totalReviews!=1?"s":""%></div>
                </div>
                <div style="flex:1;display:flex;flex-direction:column;gap:5px;">
                    <%for(int s=5;s>=1;s--){
                        int cnt = ratingDist.getOrDefault(s,0);
                        int pct = totalReviews>0 ? cnt*100/totalReviews : 0;
                    %>
                    <div style="display:flex;align-items:center;gap:8px;font-size:.75rem;color:var(--text-m);">
                        <span style="min-width:18px;"><%=s%>★</span>
                        <div style="flex:1;height:6px;background:#e5e7eb;border-radius:3px;overflow:hidden;">
                            <div style="width:<%=pct%>%;height:100%;background:var(--green);border-radius:3px;"></div>
                        </div>
                        <span style="min-width:16px;"><%=cnt%></span>
                    </div>
                    <%}%>
                </div>
            </div>

            <%-- Review list --%>
            <%for(ReviewDAO.Review rv : reviews){
                String rvInitials = rv.customerName!=null&&!rv.customerName.isEmpty()
                    ? rv.customerName.substring(0,1).toUpperCase() : "?";
                java.text.SimpleDateFormat rvSdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
            %>
            <div style="border:1px solid var(--border-light2);border-radius:12px;padding:16px;margin-bottom:12px;">
                <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px;">
                    <div style="width:36px;height:36px;border-radius:50%;background:#d1fae5;display:flex;align-items:center;justify-content:center;font-size:.82rem;font-weight:700;color:var(--green);flex-shrink:0;">
                        <%=rvInitials%>
                    </div>
                    <div>
                        <div style="font-size:.85rem;font-weight:600;color:var(--text-h);"><%=rv.customerName%></div>
                        <div style="font-size:.72rem;color:var(--text-s);"><%=rvSdf.format(rv.createdAt)%></div>
                    </div>
                    <span style="margin-left:auto;background:#d1fae5;color:var(--green);font-size:.68rem;font-weight:600;padding:2px 10px;border-radius:20px;">✓ Verified Purchase</span>
                </div>
                <div style="margin-bottom:6px;">
                    <%for(int s=1;s<=5;s++){%>
                    <span style="color:<%=s<=rv.rating?"#f59e0b":"#e5e7eb"%>;font-size:14px;">★</span>
                    <%}%>
                </div>
                <p style="font-size:.84rem;color:var(--text-b);line-height:1.6;"><%=rv.comment!=null?rv.comment:""%></p>
                <%if(rv.imageUrl!=null&&!rv.imageUrl.isEmpty()){%>
                <div style="margin-top:10px;">
                    <%-- src dùng ctx + rv.imageUrl để đúng với context path /DRSMS/ --%>
                    <img src="<%=ctx + rv.imageUrl%>" alt="review"
                         style="width:80px;height:80px;object-fit:cover;border-radius:8px;border:1px solid var(--border-light);cursor:zoom-in;transition:transform .15s;"
                         onmouseover="this.style.transform='scale(1.05)'"
                         onmouseout="this.style.transform='scale(1)'"
                         onclick="openLightbox('<%=ctx + rv.imageUrl%>')">
                </div>
                <%}%>
            </div>
            <%}%>
            <%}else{%>
            <div style="text-align:center;padding:32px;color:var(--text-s);">
                <div style="font-size:2rem;margin-bottom:8px;">💬</div>
                <div style="font-size:.88rem;">No reviews yet. Be the first to share your experience!</div>
            </div>
            <%}%>

            <%-- Write review form --%>
            <div style="margin-top:24px;padding-top:20px;border-top:1px solid var(--border-light2);">
                <h4 style="font-size:.95rem;font-weight:700;color:var(--text-h);margin-bottom:16px;">
                    <%=hasReviewed ? "You have already reviewed this product" : "Write your review"%>
                </h4>

                <%if(!hasReviewed){%>
                <form method="post" action="<%=ctx%>/customerShop" enctype="multipart/form-data">
                    <input type="hidden" name="action"   value="addReview">
                    <input type="hidden" name="itemType" value="<%=item.itemType%>">
                    <input type="hidden" name="itemId"   value="<%=item.id%>">
                    <input type="hidden" name="rating"   id="ratingInput" value="0">

                    <div style="margin-bottom:14px;">
                        <label style="font-size:.8rem;color:var(--text-m);display:block;margin-bottom:6px;">Your rating</label>
                        <div id="starPicker" style="display:flex;gap:6px;cursor:pointer;">
                            <span class="rv-star" data-val="1" style="font-size:28px;color:#e5e7eb;transition:color .1s;">★</span>
                            <span class="rv-star" data-val="2" style="font-size:28px;color:#e5e7eb;transition:color .1s;">★</span>
                            <span class="rv-star" data-val="3" style="font-size:28px;color:#e5e7eb;transition:color .1s;">★</span>
                            <span class="rv-star" data-val="4" style="font-size:28px;color:#e5e7eb;transition:color .1s;">★</span>
                            <span class="rv-star" data-val="5" style="font-size:28px;color:#e5e7eb;transition:color .1s;">★</span>
                        </div>
                        <p id="starLabel" style="font-size:.75rem;color:var(--text-s);margin-top:4px;">Select a rating</p>
                    </div>

                    <div style="margin-bottom:14px;">
                        <label style="font-size:.8rem;color:var(--text-m);display:block;margin-bottom:6px;">Comment</label>
                        <textarea name="comment" maxlength="500" required
                            placeholder="Share your experience with this product..."
                            style="width:100%;padding:10px 12px;font-family:'Sora',sans-serif;font-size:.84rem;color:var(--text-b);background:#f9fafb;border:1px solid var(--border-light);border-radius:10px;resize:vertical;min-height:88px;outline:none;"
                            onfocus="this.style.borderColor='var(--green)'"
                            onblur="this.style.borderColor='var(--border-light)'"></textarea>
                    </div>

                    <%-- [THÊM MỚI] Upload ảnh từ máy thay vì nhập URL --%>
                    <div style="margin-bottom:16px;">
                        <label style="font-size:.8rem;color:var(--text-m);display:block;margin-bottom:6px;">
                            Photo <span style="color:var(--text-s)">(optional · JPG, PNG, WEBP · max 5MB)</span>
                        </label>
                        <%-- Vùng kéo thả / click chọn ảnh --%>
                        <div id="rvUploadArea"
                             style="border:1.5px dashed var(--border-light);border-radius:10px;padding:20px;text-align:center;cursor:pointer;background:#f9fafb;transition:border-color .2s;"
                             onclick="document.getElementById('reviewImage').click()"
                             ondragover="event.preventDefault();this.style.borderColor='var(--green)'"
                             ondragleave="this.style.borderColor='var(--border-light)'"
                             ondrop="handleDrop(event)">
                            <div id="rvUploadHint">
                                <div style="font-size:1.6rem;margin-bottom:6px;">📎</div>
                                <div style="font-size:.82rem;color:var(--text-m);font-weight:600;">Click to select a photo</div>
                                <div style="font-size:.73rem;color:var(--text-s);margin-top:3px;">or drag and drop here</div>
                            </div>
                            <%-- Preview ảnh sau khi chọn --%>
                            <div id="rvPreviewWrap" style="display:none;">
                                <img id="rvPreviewImg" src="" alt="preview"
                                     style="max-height:120px;max-width:100%;border-radius:8px;object-fit:contain;">
                                <div style="margin-top:8px;">
                                    <span id="rvFileName" style="font-size:.75rem;color:var(--text-m);"></span>
                                    <button type="button" onclick="clearImage(event)"
                                        style="margin-left:10px;font-size:.72rem;color:var(--red);background:none;border:none;cursor:pointer;text-decoration:underline;">
                                        Remove photo
                                    </button>
                                </div>
                            </div>
                        </div>
                        <%-- Input file ẩn, name="reviewImage" khớp với req.getPart("reviewImage") trong servlet --%>
                        <input type="file" id="reviewImage" name="reviewImage"
                               accept="image/jpeg,image/png,image/webp,image/gif"
                               style="display:none;"
                               onchange="previewReviewImage(this)">
                    </div>
                    <%-- [KẾT THÚC THÊM MỚI] --%>

                    <button type="submit" id="rvSubmit"
                        style="background:var(--green);color:#fff;border:none;border-radius:10px;padding:10px 24px;font-size:.85rem;font-weight:600;cursor:pointer;font-family:'Sora',sans-serif;opacity:.5;pointer-events:none;transition:all .2s;">
                        <i class="fas fa-paper-plane"></i> Submit Review
                    </button>
                </form>
                <%}else{%>
                <div style="background:#f0fdf4;border:1px solid #a7f3d0;border-radius:10px;padding:12px 16px;font-size:.84rem;color:#065f46;">
                    <i class="fas fa-check-circle"></i> You have already submitted a review for this product.
                </div>
                <%}%>
            </div>

        </div>
        <%-- ═══════════ [KẾT THÚC THÊM MỚI] REVIEW SECTION ═══════════ --%>

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

    // ── [THÊM MỚI] Xử lý preview ảnh review trước khi upload ──
    function previewReviewImage(input) {
        if (!input.files || !input.files[0]) return;
        var file = input.files[0];
        var reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('rvPreviewImg').src = e.target.result;
            document.getElementById('rvFileName').textContent = file.name + ' (' + (file.size / 1024).toFixed(0) + ' KB)';
            document.getElementById('rvUploadHint').style.display = 'none';
            document.getElementById('rvPreviewWrap').style.display = 'block';
            document.getElementById('rvUploadArea').style.borderColor = 'var(--green)';
        };
        reader.readAsDataURL(file);
    }

    function clearImage(event) {
        event.stopPropagation(); // không trigger click của upload area
        document.getElementById('reviewImage').value = '';
        document.getElementById('rvPreviewImg').src = '';
        document.getElementById('rvUploadHint').style.display = 'block';
        document.getElementById('rvPreviewWrap').style.display = 'none';
        document.getElementById('rvUploadArea').style.borderColor = 'var(--border-light)';
    }

    function handleDrop(event) {
        event.preventDefault();
        document.getElementById('rvUploadArea').style.borderColor = 'var(--border-light)';
        var files = event.dataTransfer.files;
        if (files && files[0]) {
            // Gán file vào input để form submit được
            var dt = new DataTransfer();
            dt.items.add(files[0]);
            var inp = document.getElementById('reviewImage');
            inp.files = dt.files;
            previewReviewImage(inp);
        }
    }
    // ── [KẾT THÚC THÊM MỚI] ────────────────────────────────
    (function(){
        var selected = 0;
        var labels = ['','Very bad','Bad','Average','Good','Excellent'];
        var stars = document.querySelectorAll('.rv-star');
        if (!stars.length) return; // không render nếu đã review rồi
        stars.forEach(function(s){
            // Click: chốt số sao
            s.addEventListener('click', function(){
                selected = +this.dataset.val;
                document.getElementById('ratingInput').value = selected;
                stars.forEach(function(x){
                    x.style.color = +x.dataset.val <= selected ? '#f59e0b' : '#e5e7eb';
                });
                document.getElementById('starLabel').textContent = labels[selected];
                var btn = document.getElementById('rvSubmit');
                btn.style.opacity = '1';
                btn.style.pointerEvents = 'auto';
            });
            // Hover: preview màu
            s.addEventListener('mouseover', function(){
                var v = +this.dataset.val;
                stars.forEach(function(x){
                    x.style.color = +x.dataset.val <= v ? '#f59e0b' : '#e5e7eb';
                });
            });
            // Mouse out: khôi phục về sao đã chọn
            s.addEventListener('mouseout', function(){
                stars.forEach(function(x){
                    x.style.color = +x.dataset.val <= selected ? '#f59e0b' : '#e5e7eb';
                });
            });
        });
    })();
    // ── [KẾT THÚC THÊM MỚI] ────────────────────────────
</script>

<%-- ── [THÊM MỚI] Lightbox xem ảnh review toàn màn hình ── --%>
<div id="rvLightbox"
     style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,0.82);
            align-items:center;justify-content:center;cursor:zoom-out;"
     onclick="closeLightbox()">
    <%-- Nút đóng góc trên phải --%>
    <button onclick="closeLightbox()" title="Đóng"
            style="position:absolute;top:18px;right:22px;background:rgba(255,255,255,0.15);
                   border:none;color:#fff;font-size:1.4rem;width:40px;height:40px;
                   border-radius:50%;cursor:pointer;display:flex;align-items:center;
                   justify-content:center;transition:background .2s;z-index:1;"
            onmouseover="this.style.background='rgba(255,255,255,0.3)'"
            onmouseout="this.style.background='rgba(255,255,255,0.15)'">✕</button>
    <%-- Ảnh lớn — click vào ảnh không đóng lightbox --%>
    <img id="rvLightboxImg" src="" alt="review full"
         style="max-width:90vw;max-height:88vh;object-fit:contain;
                border-radius:12px;box-shadow:0 8px 40px rgba(0,0,0,0.5);
                cursor:default;"
         onclick="event.stopPropagation()">
    <%-- Caption nhỏ bên dưới --%>
    <div style="position:absolute;bottom:18px;color:rgba(255,255,255,0.5);font-size:.75rem;">
        Click outside or press ESC to close
    </div>
</div>

<script>
    function openLightbox(src) {
        var lb = document.getElementById('rvLightbox');
        document.getElementById('rvLightboxImg').src = src;
        lb.style.display = 'flex';
        document.body.style.overflow = 'hidden'; // khóa scroll trang khi lightbox mở
    }
    function closeLightbox() {
        document.getElementById('rvLightbox').style.display = 'none';
        document.getElementById('rvLightboxImg').src = '';
        document.body.style.overflow = '';
    }
    // Nhấn ESC để đóng lightbox
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeLightbox();
    });
</script>
<%-- ── [KẾT THÚC THÊM MỚI] ── --%>

<%@ include file="customerAIBubble.jsp" %>
</body>
</html>
