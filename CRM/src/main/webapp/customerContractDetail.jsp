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
        body{
            font-family:'Sora',sans-serif;
            background:var(--bg);
            color:var(--text-b);
            min-height:100vh;
            display:flex;
        }
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-track{background:transparent}
        ::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px}

        /* ═══════════ SIDEBAR ═══════════ */
        .sb{
            width:var(--sb-width);
            min-height:100vh;
            background:var(--sb-bg);
            border-right:1px solid rgba(79,70,229,0.2);
            display:flex; flex-direction:column;
            position:fixed; top:0; left:0; z-index:100;
            box-shadow:4px 0 24px rgba(0,0,0,0.15);
        }
        .sb-brand{
            padding:20px 16px 16px;
            display:flex; align-items:center; gap:10px;
            border-bottom:1px solid var(--sb-border);
        }
        .sb-logo{
            width:36px; height:36px;
            background:linear-gradient(135deg,#818cf8,#a78bfa);
            border-radius:10px;
            display:flex; align-items:center; justify-content:center;
            color:#fff; font-size:.9rem;
            box-shadow:0 4px 12px rgba(129,140,248,0.4);
            flex-shrink:0;
        }
        .sb-name{color:#fff; font-size:1.05rem; font-weight:800; letter-spacing:-.3px}
        .sb-role{
            display:inline-flex; align-items:center;
            background:rgba(129,140,248,0.2);
            border:1px solid rgba(129,140,248,0.3);
            color:var(--sb-accent-2);
            font-size:.6rem; font-weight:700;
            letter-spacing:1px; text-transform:uppercase;
            padding:2px 8px; border-radius:20px; margin-top:3px;
        }
        .sb-nav{flex:1; padding:12px 10px; overflow-y:auto}
        .sb-lbl{
            color:rgba(255,255,255,0.22);
            font-size:.6rem; font-weight:700;
            text-transform:uppercase; letter-spacing:1.6px;
            padding:0 8px; margin:14px 0 5px;
        }
        .sb-item{
            display:flex; align-items:center; gap:9px;
            padding:8px 10px; border-radius:9px;
            margin-bottom:1px;
            color:var(--sb-text);
            text-decoration:none;
            font-size:.81rem; font-weight:500;
            transition:all .18s;
            border-left:2px solid transparent;
        }
        .sb-item i{
            width:28px; height:28px;
            display:flex; align-items:center; justify-content:center;
            font-size:.78rem; border-radius:8px;
            background:rgba(255,255,255,0.06);
            flex-shrink:0; transition:all .18s;
        }
        .sb-item.on{
            color:#fff;
            background:var(--sb-item-on);
            border-left-color:var(--sb-accent);
        }
        .sb-item.on i{background:rgba(129,140,248,0.3); color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){
            color:rgba(255,255,255,0.78);
            background:rgba(255,255,255,0.06);
        }
        .sb-badge{
            margin-left:auto;
            background:#ef4444;
            color:#fff; font-size:.6rem; font-weight:700;
            padding:2px 7px; border-radius:20px;
            box-shadow:0 2px 6px rgba(239,68,68,0.5);
        }
        .sb-foot{padding:12px 10px 14px; border-top:1px solid var(--sb-border)}
        .sb-user{
            display:flex; align-items:center; gap:9px;
            padding:9px 10px; border-radius:10px;
            background:rgba(255,255,255,0.07);
            border:1px solid rgba(255,255,255,0.1);
            margin-bottom:5px; text-decoration:none; transition:all .18s;
        }
        .sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3)}
        .sb-ava{
            width:34px; height:34px; border-radius:50%;
            background:linear-gradient(135deg,#818cf8,#a78bfa);
            display:flex; align-items:center; justify-content:center;
            color:#fff; font-size:.88rem; font-weight:700;
            flex-shrink:0; overflow:hidden;
        }
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff; font-size:.8rem; font-weight:600}
        .sb-urole{color:rgba(255,255,255,0.35); font-size:.66rem; margin-top:1px}
        .sb-logout{
            display:flex; align-items:center; gap:8px;
            width:100%; padding:8px 10px; border-radius:9px;
            color:rgba(255,255,255,0.3); text-decoration:none;
            font-size:.78rem; transition:all .18s;
        }
        .sb-logout:hover{color:#fca5a5; background:rgba(239,68,68,0.1)}

        /* ═══════════ MAIN (light) ═══════════ */
        .main{margin-left:var(--sb-width);flex:1;min-height:100vh;display:flex;flex-direction:column}

        .topbar{
            display:flex; justify-content:space-between; align-items:center;
            padding:18px 28px;
            background:var(--bg-topbar);
            border-bottom:1px solid var(--border-light);
            position:sticky; top:0; z-index:50;
            box-shadow:0 1px 6px rgba(0,0,0,0.06);
        }
        .topbar-title{font-size:1.2rem; font-weight:800; color:var(--text-h); letter-spacing:-.3px}
        .topbar-sub{color:var(--text-s); font-size:.78rem; margin-top:2px}

        /* Breadcrumb */
        .breadcrumb{display:flex; align-items:center; gap:7px; font-size:.76rem; color:var(--text-s)}
        .breadcrumb a{color:var(--text-s); text-decoration:none; transition:color .18s}
        .breadcrumb a:hover{color:var(--primary-2)}
        .breadcrumb-sep{color:var(--border-light)}
        .breadcrumb span:last-child{color:var(--text-m); font-weight:600}

        .content{padding:24px 28px; flex:1}

        /* ── HERO BANNER ── */
        .hero{
            border-radius:18px;
            padding:26px 28px;
            margin-bottom:20px;
            display:flex; justify-content:space-between; align-items:center;
            position:relative; overflow:hidden;
            animation:cardIn .5s ease both;
        }
        .hero-warranty{
            background:linear-gradient(135deg,#065f46,#059669);
            border:1px solid rgba(52,211,153,0.35);
        }
        .hero-maint{
            background:linear-gradient(135deg,#1e40af,#4f46e5);
            border:1px solid rgba(99,102,241,0.4);
        }
        .hero::before{
            content:''; position:absolute; inset:0;
            background:radial-gradient(ellipse at top right,rgba(255,255,255,0.08),transparent 60%);
            pointer-events:none;
        }
        /* decorative circles like dashboard stat cards */
        .hero::after{
            content:''; position:absolute;
            width:140px; height:140px; border-radius:50%;
            background:rgba(255,255,255,0.08);
            top:-40px; right:-40px;
        }
        .hero-code{
            font-family:'Courier New',monospace;
            font-size:.86rem; opacity:.75;
            margin-bottom:6px; letter-spacing:.5px; color:#fff;
        }
        .hero-left h2{
            font-size:1.45rem; font-weight:800;
            color:#fff; margin-bottom:12px;
            display:flex; align-items:center; gap:10px;
            position:relative; z-index:1;
        }
        .hero-meta{
            display:flex; gap:18px;
            font-size:.79rem; color:rgba(255,255,255,0.82);
            position:relative; z-index:1;
        }
        .hero-meta span{display:flex; align-items:center; gap:6px}
        .hero-badge{
            padding:8px 18px; border-radius:20px;
            background:rgba(255,255,255,0.2);
            font-size:.84rem; font-weight:700;
            border:1px solid rgba(255,255,255,0.25);
            color:#fff; white-space:nowrap;
            position:relative; z-index:1;
        }

        /* ── ACTION ROW ── */
        .action-row{
            display:flex; justify-content:space-between; align-items:center;
            margin-bottom:20px;
        }
        .btn-back{
            display:inline-flex; align-items:center; gap:8px;
            padding:10px 18px;
            background:#fff;
            border:1.5px solid var(--border-light);
            color:var(--text-m); text-decoration:none;
            font-size:.83rem; font-weight:600;
            border-radius:11px; transition:all .18s;
        }
        .btn-back:hover{background:#f3f4f6; border-color:#d1d5db; color:var(--text-b)}

        .btn-create{
            display:inline-flex; align-items:center; gap:8px;
            padding:10px 20px;
            background:var(--primary);
            color:#fff; text-decoration:none;
            font-size:.83rem; font-weight:700;
            border-radius:11px;
            box-shadow:0 4px 14px rgba(79,70,229,0.35);
            transition:all .22s;
        }
        .btn-create:hover{background:#4338ca;transform:translateY(-1px);box-shadow:0 8px 22px rgba(79,70,229,0.45)}

        /* ── GRID LAYOUT ── */
        .grid-detail{
            display:grid;
            grid-template-columns:2fr 1fr;
            gap:18px;
            align-items:start;
        }

        /* ── CARDS ── */
        .card{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:16px;
            overflow:hidden;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
            margin-bottom:16px;
            animation:cardIn .45s ease both;
        }
        @keyframes cardIn{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}

        .card-hd{
            padding:13px 18px;
            border-bottom:1px solid var(--border-light2);
            background:#fafbff;
            display:flex; justify-content:space-between; align-items:center;
        }
        .card-hd-left{display:flex; align-items:center; gap:10px}
        .card-hd-icon{
            width:32px; height:32px; border-radius:9px;
            display:flex; align-items:center; justify-content:center;
            font-size:.82rem; flex-shrink:0;
        }
        .card-hd-title{font-size:.86rem; font-weight:700; color:var(--text-h)}
        .card-body{padding:16px 18px}

        /* ── INFO ROWS ── */
        .info-row{
            display:flex; gap:12px;
            margin-bottom:13px; align-items:flex-start;
        }
        .info-row:last-child{margin-bottom:0}
        .info-lbl{
            font-size:.72rem; color:var(--text-s);
            font-weight:700; min-width:110px;
            padding-top:2px; flex-shrink:0;
            text-transform:uppercase; letter-spacing:.4px;
        }
        .info-val{font-size:.83rem; color:var(--text-b); flex:1}

        /* ── STATUS BADGES ── */
        .b{
            display:inline-flex; align-items:center;
            padding:3px 9px; border-radius:20px;
            font-size:.68rem; font-weight:700; white-space:nowrap;
        }
        .b-active   {background:#d1fae5; color:#065f46}
        .b-expired  {background:#fee2e2; color:#991b1b}
        .b-cancelled{background:#f3f4f6; color:#6b7280}

        /* Contract type inline badge */
        .ct-type-badge{
            display:inline-flex; align-items:center; gap:5px;
            padding:4px 10px; border-radius:7px;
            font-size:.73rem; font-weight:700;
        }
        .ct-type-warranty{background:#d1fae5; color:#065f46}
        .ct-type-maint   {background:#dbeafe; color:#1e40af}

        /* ── EQUIPMENT GRID ── */
        .eq-grid{
            display:grid;
            grid-template-columns:1fr 1fr;
            gap:10px;
            padding:14px;
        }
        .eq-card{
            border:1.5px solid var(--border-light);
            border-radius:12px;
            padding:14px;
            background:#fafbff;
            transition:all .2s;
        }
        .eq-card:hover{
            border-color:rgba(79,70,229,0.3);
            background:var(--primary-light);
            box-shadow:0 4px 14px rgba(79,70,229,0.08);
        }
        .eq-card-top{
            display:flex; justify-content:space-between; align-items:flex-start;
            margin-bottom:10px;
        }
        .eq-icon{
            width:36px; height:36px; border-radius:10px;
            background:var(--primary-light); color:var(--primary-2);
            display:flex; align-items:center; justify-content:center;
            font-size:.95rem;
        }
        .eq-source{
            font-size:.67rem; font-weight:700;
            padding:2px 7px; border-radius:5px;
        }
        .eq-source-ext{background:#fef3c7; color:#92400e}
        .eq-source-int{background:var(--primary-light); color:var(--primary)}
        .eq-model{font-size:.83rem; font-weight:700; color:var(--text-h); margin-bottom:3px}
        .eq-serial{font-size:.72rem; color:var(--text-s); font-family:'Courier New',monospace}
        .eq-warranty{
            margin-top:8px;
            display:inline-flex; align-items:center; gap:5px;
            padding:4px 9px; border-radius:6px;
            font-size:.71rem; font-weight:600;
        }
        .eq-warranty.ok {background:#d1fae5; color:#065f46}
        .eq-warranty.exp{background:#fee2e2; color:#991b1b}

        /* ── NOTES BOX ── */
        .note-box{
            background:#fffbeb;
            border:1px solid #fde68a;
            border-radius:10px;
            padding:14px 16px;
            font-size:.82rem; color:var(--text-b);
            line-height:1.7;
            border-left:3px solid var(--amber);
        }

        /* ── SERVICE TERMS CARD ── */
        .terms-card{
            border-radius:14px;
            padding:18px;
            margin-bottom:16px;
        }
        .terms-warranty{
            background:#f0fdf4;
            border:1.5px solid #bbf7d0;
        }
        .terms-maint{
            background:#eff6ff;
            border:1.5px solid #bfdbfe;
        }
        .terms-title{
            font-size:.83rem; font-weight:700;
            margin-bottom:10px;
            display:flex; align-items:center; gap:7px;
        }
        .terms-warranty .terms-title{color:var(--green)}
        .terms-maint    .terms-title{color:var(--blue)}
        .terms-list{
            font-size:.79rem; line-height:1.9; color:var(--text-b);
        }

        /* Empty state in card */
        .card-empty{
            text-align:center; padding:32px;
            color:var(--text-s); font-size:.81rem;
        }
        .card-empty i{font-size:2rem; display:block; margin-bottom:10px; opacity:.2; color:var(--text-m)}
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
            <a href="<%=ctx%>/customerContracts" class="sb-item on">
                <i class="fas fa-file-contract"></i> Contracts
            </a>
            <a href="<%=ctx%>/customerEquipment" class="sb-item">
                <i class="fas fa-desktop"></i> My Equipment
            </a>
            <div class="sb-lbl">Shop</div>
            <a href="<%=ctx%>/customerShop?action=parts" class="sb-item">
                <i class="fas fa-puzzle-piece"></i> Parts
            </a>
            <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item">
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
                                <div class="card-hd-icon" style="background:var(--primary-light);color:var(--primary-2)">
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
                                <div class="card-hd-icon" style="background:#fef3c7;color:var(--amber)">
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
                                <div class="card-hd-icon" style="background:var(--primary-light);color:var(--primary-2)">
                                    <i class="fas fa-info"></i>
                                </div>
                                <div class="card-hd-title">Contract Information</div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="info-row">
                                <div class="info-lbl">Contract Code</div>
                                <div class="info-val">
                                    <strong style="font-family:'Courier New',monospace;color:var(--primary-2);font-size:.9rem">
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
<%@ include file="customerAIBubble.jsp" %>
</body>
</html>
