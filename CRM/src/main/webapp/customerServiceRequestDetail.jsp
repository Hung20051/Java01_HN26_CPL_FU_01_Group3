<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    ServiceRequest sr=(ServiceRequest)request.getAttribute("sr");
    if(sr==null){response.sendRedirect(request.getContextPath()+"/customerServiceRequests");return;}
    String ctx=request.getContextPath();
    List<ServiceRequestEquipment> eqList=sr.getEquipmentList(); if(eqList==null)eqList=new ArrayList<>();
    String sc="b-pending";
    if("APPROVED".equals(sr.getStatus()))sc="b-approved";
    else if("REJECTED".equals(sr.getStatus()))sc="b-rejected";
    else if("IN_PROGRESS".equals(sr.getStatus()))sc="b-inprogress";
    else if("COMPLETED".equals(sr.getStatus()))sc="b-completed";
    else if("CANCELLED".equals(sr.getStatus()))sc="b-cancelled";
    String pc="b-medium";
    if("LOW".equals(sr.getPriority()))pc="b-low";
    else if("HIGH".equals(sr.getPriority()))pc="b-high";
    else if("URGENT".equals(sr.getPriority()))pc="b-urgent";
    boolean isW="WARRANTY".equals(sr.getContractType());
    boolean canCancel="PENDING".equals(sr.getStatus());
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int unpaidInv=0; int unreadChat=0; int pendingSR=0;
    String initials=me.getFullName()!=null&&!me.getFullName().isEmpty()?me.getFullName().substring(0,1).toUpperCase():"?";
    boolean p2="APPROVED".equals(sr.getStatus())||"IN_PROGRESS".equals(sr.getStatus())||"COMPLETED".equals(sr.getStatus());
    boolean p3="IN_PROGRESS".equals(sr.getStatus())||"COMPLETED".equals(sr.getStatus());
    boolean p4="COMPLETED".equals(sr.getStatus());
    boolean rejected="REJECTED".equals(sr.getStatus());
    boolean cancelled="CANCELLED".equals(sr.getStatus());

    /* FIX: get technician avatar URL safely — use getAssignedToAvatarUrl() if it exists,
       otherwise fall back to null so we always show the letter-avatar gracefully */
    String techAvatarUrl = null;
    try { techAvatarUrl = sr.getAssignedToAvatarUrl(); } catch(Exception _e) {}
    boolean hasTechAvatar = techAvatarUrl != null && !techAvatarUrl.isEmpty();
    String techInitial = sr.getAssignedToName() != null && !sr.getAssignedToName().isEmpty()
        ? sr.getAssignedToName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%=sr.getRequestCode()%> - DRSMS</title>
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

            /* Status colors */
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
            padding:14px 28px;
            background:var(--bg-topbar);
            border-bottom:1px solid var(--border-light);
            position:sticky; top:0; z-index:50;
            box-shadow:0 1px 6px rgba(0,0,0,0.06);
        }
        .content{padding:24px 28px; flex:1}

        /* Breadcrumb */
        .breadcrumb{
            display:flex; align-items:center; gap:7px;
            font-size:.76rem; color:var(--text-s);
        }
        .breadcrumb a{color:var(--text-s); text-decoration:none; transition:color .18s}
        .breadcrumb a:hover{color:var(--primary-2)}
        .bc-sep{color:var(--border-light); font-size:.9rem}
        .bc-cur{
            color:var(--primary-2); font-weight:700;
            font-family:'Courier New',monospace;
        }

        /* Page header */
        .page-hd{
            display:flex; justify-content:space-between; align-items:flex-start;
            margin-bottom:20px;
        }
        .page-title{
            font-size:1.15rem; font-weight:800; color:var(--text-h);
            display:flex; align-items:center; gap:9px; letter-spacing:-.3px;
        }
        .page-title i{color:var(--amber)}
        .page-code{font-family:'Courier New',monospace; color:var(--primary-2); font-size:1rem}
        .page-sub{color:var(--text-m); font-size:.81rem; margin-top:4px}

        .actions{display:flex; gap:9px; align-items:center}

        .btn-back{
            display:inline-flex; align-items:center; gap:7px;
            padding:9px 16px; border-radius:10px;
            background:#fff; color:var(--text-m);
            border:1.5px solid var(--border-light);
            text-decoration:none; font-size:.81rem; font-weight:600;
            transition:all .18s;
        }
        .btn-back:hover{background:#f3f4f6; border-color:#d1d5db; color:var(--text-b)}

        .btn-cancel-big{
            display:inline-flex; align-items:center; gap:7px;
            padding:9px 16px; border-radius:10px;
            background:#fee2e2; color:var(--red);
            border:1.5px solid #fca5a5;
            font-size:.81rem; font-weight:600;
            cursor:pointer; font-family:'Sora',sans-serif;
            transition:all .18s;
        }
        .btn-cancel-big:hover{background:#fecaca; transform:translateY(-1px)}

        /* Reject banner */
        .reject-box{
            display:flex; align-items:flex-start; gap:12px;
            padding:12px 18px;
            background:#fee2e2;
            border:1.5px solid #fca5a5;
            border-radius:13px;
            margin-bottom:18px;
            font-size:.83rem; color:var(--red);
            animation:cardIn .4s ease both;
        }
        .reject-box i{margin-top:2px; flex-shrink:0}

        /* Grid */
        .grid-detail{
            display:grid;
            grid-template-columns:2fr 1fr;
            gap:18px;
            align-items:start;
        }

        /* Cards */
        .card{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:16px;
            overflow:hidden;
            margin-bottom:16px;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
            animation:cardIn .45s ease both;
        }
        @keyframes cardIn{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:none}}
        .card:nth-child(1){animation-delay:.05s}
        .card:nth-child(2){animation-delay:.10s}
        .card:nth-child(3){animation-delay:.15s}

        .card-hd{
            padding:13px 18px;
            border-bottom:1px solid var(--border-light2);
            background:#fafbff;
            display:flex; align-items:center; gap:10px;
        }
        .card-hd-icon{
            width:30px; height:30px; border-radius:9px;
            display:flex; align-items:center; justify-content:center;
            font-size:.8rem; flex-shrink:0;
        }
        .card-hd-title{font-size:.86rem; font-weight:700; color:var(--text-h)}
        .card-body{padding:16px 18px}

        /* Info rows */
        .info-row{
            display:flex; gap:10px;
            margin-bottom:12px; align-items:flex-start;
        }
        .info-row:last-child{margin-bottom:0}
        .info-lbl{
            font-size:.7rem; color:var(--text-s); font-weight:700;
            min-width:120px; padding-top:2px;
            text-transform:uppercase; letter-spacing:.4px;
        }
        .info-val{font-size:.83rem; color:var(--text-b); flex:1; line-height:1.5}

        /* Badges */
        .b{
            display:inline-flex; align-items:center;
            padding:3px 9px; border-radius:20px;
            font-size:.68rem; font-weight:700; white-space:nowrap;
        }
        .b-pending   {background:#fef3c7; color:#92400e}
        .b-approved  {background:#d1fae5; color:#065f46}
        .b-rejected  {background:#fee2e2; color:#991b1b}
        .b-inprogress{background:#dbeafe; color:#1e40af}
        .b-completed {background:#ede9fe; color:#5b21b6}
        .b-cancelled {background:#f3f4f6; color:#6b7280}
        .b-low       {background:#dcfce7; color:#166534}
        .b-medium    {background:#fef3c7; color:#92400e}
        .b-high      {background:#ffedd5; color:#9a3412}
        .b-urgent    {background:#fee2e2; color:#991b1b}

        /* Contract tag */
        .ct-tag{
            display:inline-block;
            padding:2px 8px; border-radius:6px;
            font-size:.68rem; font-weight:700; margin-left:8px;
        }
        .ct-wr{background:#d1fae5; color:#065f46}
        .ct-mt{background:#dbeafe; color:#1e40af}

        /* Description box */
        .desc-box{
            background:#fafbff;
            border:1px solid var(--border-light);
            border-radius:12px;
            padding:14px 16px;
            font-size:.83rem; color:var(--text-b);
            line-height:1.8;
            border-left:3px solid var(--primary-2);
        }

        /* Equipment items */
        .eq-item{
            display:flex; align-items:flex-start; gap:12px;
            padding:13px 0;
            border-bottom:1px solid var(--border-light2);
        }
        .eq-item:last-child{border-bottom:none}
        .eq-num{
            width:30px; height:30px; border-radius:50%;
            background:var(--primary-light);
            color:var(--primary-2);
            display:flex; align-items:center; justify-content:center;
            font-size:.74rem; font-weight:700; flex-shrink:0;
            border:1px solid rgba(99,102,241,0.25);
        }
        .eq-name{font-size:.86rem; font-weight:600; color:var(--text-h)}
        .eq-serial{
            font-size:.72rem; color:var(--text-s);
            font-family:'Courier New',monospace; margin-top:3px;
            display:flex; align-items:center; gap:6px;
        }
        .eq-src{padding:1px 7px; border-radius:4px; font-size:.67rem; font-weight:700}
        .eq-src-ext{background:#fef3c7; color:#92400e}
        .eq-src-sys{background:var(--primary-light); color:var(--primary)}
        .eq-issue{
            font-size:.79rem; color:var(--text-b);
            margin-top:8px; padding:8px 10px;
            background:#fffbeb;
            border-radius:8px; border-left:3px solid var(--amber);
            display:flex; gap:6px; align-items:flex-start;
        }

        /* Timeline */
        .timeline{padding:4px 0; position:relative}
        .tl-item{
            display:flex; gap:14px;
            padding:10px 0; position:relative;
        }
        .tl-item:not(:last-child)::after{
            content:''; position:absolute;
            left:14px; top:40px; bottom:-2px;
            width:2px; background:var(--border-light2); z-index:0;
        }
        .tl-dot{
            width:30px; height:30px; border-radius:50%;
            display:flex; align-items:center; justify-content:center;
            font-size:.78rem; flex-shrink:0; border:2px solid;
            position:relative; z-index:1;
        }
        .tl-dot.done{
            background:linear-gradient(135deg,#16a34a,#22c55e);
            border-color:#16a34a; color:#fff;
            box-shadow:0 0 10px rgba(22,163,74,0.25);
        }
        .tl-dot.current{
            background:var(--primary-light);
            border-color:var(--primary-2); color:var(--primary-2);
            box-shadow:0 0 10px rgba(99,102,241,0.2);
        }
        .tl-dot.wait{
            background:#f9fafb; border-color:var(--border-light); color:var(--text-s);
        }
        .tl-dot.fail{
            background:#fee2e2; border-color:var(--red); color:var(--red);
        }
        .tl-dot.skip{
            background:#f3f4f6; border-color:#e5e7eb; color:var(--text-s);
        }
        .tl-content{flex:1; padding-top:4px}
        .tl-label{font-size:.83rem; font-weight:600; color:var(--text-h)}
        .tl-label.dim{color:var(--text-s)}
        .tl-sub{font-size:.73rem; color:var(--text-s); margin-top:3px}

        /* Technician card — FIX: support img avatar */
        .tech-avatar{
            width:44px; height:44px; border-radius:50%;
            background:linear-gradient(135deg,#0284c7,#38bdf8);
            display:flex; align-items:center; justify-content:center;
            font-size:1.1rem; font-weight:700; color:#fff;
            flex-shrink:0;
            box-shadow:0 4px 12px rgba(2,132,199,0.2);
            overflow:hidden;
        }
        .tech-avatar img{
            width:44px; height:44px;
            object-fit:cover; border-radius:50%;
            display:block;
        }
        .tech-name{font-size:.875rem; font-weight:600; color:var(--text-h)}
        .tech-role{font-size:.73rem; color:var(--text-m); margin-top:2px}

        /* Contract note card */
        .note-card-w{
            background:#f0fdf4;
            border:1.5px solid #bbf7d0;
            border-radius:14px; padding:16px;
        }
        .note-card-m{
            background:#eff6ff;
            border:1.5px solid #bfdbfe;
            border-radius:14px; padding:16px;
        }
        .note-icon{font-size:1.3rem; flex-shrink:0}
        .note-title-w{font-size:.83rem; font-weight:700; color:var(--green)}
        .note-title-m{font-size:.83rem; font-weight:700; color:var(--blue)}
        .note-desc{font-size:.76rem; margin-top:3px; line-height:1.5}
        .note-desc-w{color:#166534}
        .note-desc-m{color:#1d4ed8}

        /* Code link */
        .code-link{
            color:var(--primary-2); font-weight:700;
            font-family:'Courier New',monospace; font-size:.84rem;
            text-decoration:none;
        }
        .code-link:hover{color:var(--primary); text-decoration:underline}

        .td-muted{color:var(--text-s); font-size:.8rem}
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
            <a href="<%=ctx%>/customerServiceRequests" class="sb-item on">
                <i class="fas fa-clipboard-list"></i> Repair Requests
                <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
            </a>
            <a href="<%=ctx%>/customerContracts"   class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
            <a href="<%=ctx%>/customerEquipment"   class="sb-item"><i class="fas fa-desktop"></i> My Equipment</a>
            <div class="sb-lbl">Shop</div>
            <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item"><i class="fas fa-puzzle-piece"></i> Parts</a>
            <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Equipment</a>
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

        <%-- Topbar --%>
        <div class="topbar">
            <div class="breadcrumb">
                <a href="<%=ctx%>/customerDashboard"><i class="fas fa-home"></i></a>
                <span class="bc-sep">›</span>
                <a href="<%=ctx%>/customerServiceRequests">Repair Requests</a>
                <span class="bc-sep">›</span>
                <span class="bc-cur"><%=sr.getRequestCode()%></span>
            </div>
            <div class="actions">
                <a href="<%=ctx%>/customerServiceRequests" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Back
                </a>
                <%if(canCancel){%>
                <form method="post" action="<%=ctx%>/customerServiceRequests" style="display:inline"
                      onsubmit="return confirm('Are you sure you want to cancel this request?')">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="id" value="<%=sr.getId()%>">
                    <button type="submit" class="btn-cancel-big">
                        <i class="fas fa-times-circle"></i> Cancel Request
                    </button>
                </form>
                <%}%>
            </div>
        </div>

        <div class="content">

            <%-- Page header --%>
            <div class="page-hd">
                <div>
                    <div class="page-title">
                        <i class="fas fa-clipboard-check"></i>
                        Request Detail &nbsp;<span class="page-code"><%=sr.getRequestCode()%></span>
                    </div>
                    <div class="page-sub"><%=sr.getTitle()%></div>
                </div>
            </div>

            <%-- Reject banner --%>
            <%if(rejected && sr.getRejectReason()!=null){%>
            <div class="reject-box">
                <i class="fas fa-ban"></i>
                <div><strong>Request rejected:</strong> <%=sr.getRejectReason()%></div>
            </div>
            <%}%>

            <div class="grid-detail">

                <%-- LEFT COLUMN --%>
                <div>

                    <%-- Request info --%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-icon" style="background:var(--primary-light);color:var(--primary-2)">
                                <i class="fas fa-info"></i>
                            </div>
                            <div class="card-hd-title">Request Information</div>
                        </div>
                        <div class="card-body">
                            <div class="info-row">
                                <div class="info-lbl">Request Code</div>
                                <div class="info-val">
                                    <span style="font-family:'Courier New',monospace;font-weight:700;color:var(--primary-2);font-size:.9rem"><%=sr.getRequestCode()%></span>
                                </div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">Title</div>
                                <div class="info-val" style="color:var(--text-h);font-weight:600"><%=sr.getTitle()%></div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">Contract</div>
                                <div class="info-val">
                                    <a href="<%=ctx%>/customerContracts?action=detail&id=<%=sr.getContractId()%>" class="code-link"><%=sr.getContractCode()%></a>
                                    <span class="ct-tag <%=isW?"ct-wr":"ct-mt"%>"><%=isW?"Warranty":"Maintenance"%></span>
                                </div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">Priority</div>
                                <div class="info-val"><span class="b <%=pc%>"><%=sr.getPriorityLabel()%></span></div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">Status</div>
                                <div class="info-val"><span class="b <%=sc%>"><%=sr.getStatusLabel()%></span></div>
                            </div>
                            <div class="info-row">
                                <div class="info-lbl">Created</div>
                                <div class="info-val td-muted"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().replace("T"," ").substring(0,16):"—"%></div>
                            </div>
                            <%if(sr.getCompletedAt()!=null){%>
                            <div class="info-row">
                                <div class="info-lbl">Completed</div>
                                <div class="info-val" style="color:var(--green);font-weight:600">
                                    <i class="fas fa-check-circle" style="margin-right:4px"></i><%=sr.getCompletedAt().toString().replace("T"," ").substring(0,16)%>
                                </div>
                            </div>
                            <%}%>
                        </div>
                    </div>

                    <%-- Description --%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-icon" style="background:#f5f3ff;color:var(--purple)">
                                <i class="fas fa-align-left"></i>
                            </div>
                            <div class="card-hd-title">Issue Description</div>
                        </div>
                        <div class="card-body">
                            <div class="desc-box"><%=sr.getDescription().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>")%></div>
                        </div>
                    </div>

                    <%-- Equipment --%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-icon" style="background:#e0f2fe;color:var(--info)">
                                <i class="fas fa-desktop"></i>
                            </div>
                            <div class="card-hd-title">Equipment to Repair <span style="color:var(--text-s);font-weight:400">(<%=eqList.size()%>)</span></div>
                        </div>
                        <div class="card-body" style="padding-top:4px;padding-bottom:4px">
                            <%if(eqList.isEmpty()){%>
                            <p style="color:var(--text-s);font-size:.83rem;padding:14px 0;text-align:center">
                                <i class="fas fa-desktop" style="font-size:1.5rem;display:block;margin-bottom:6px;opacity:.2"></i>
                                No equipment information available.
                            </p>
                            <%}else{for(int i=0;i<eqList.size();i++){ServiceRequestEquipment eq=eqList.get(i);%>
                            <div class="eq-item">
                                <div class="eq-num"><%=i+1%></div>
                                <div style="flex:1">
                                    <div class="eq-name"><%=eq.getDisplayName()!=null?eq.getDisplayName():"Equipment #"+eq.getCustomerEquipmentId()%></div>
                                    <div class="eq-serial">
                                        <i class="fas fa-barcode" style="font-size:.68rem"></i>
                                        <%=eq.getDisplaySerial()!=null?eq.getDisplaySerial():"N/A"%>
                                        <span class="eq-src <%="EXTERNAL".equals(eq.getSource())?"eq-src-ext":"eq-src-sys"%>">
                                            <%="EXTERNAL".equals(eq.getSource())?"External":"In-System"%>
                                        </span>
                                    </div>
                                    <%if(eq.getIssueDescription()!=null&&!eq.getIssueDescription().isEmpty()){%>
                                    <div class="eq-issue">
                                        <i class="fas fa-exclamation-circle" style="color:var(--amber);margin-top:1px;flex-shrink:0"></i>
                                        <span><%=eq.getIssueDescription()%></span>
                                    </div>
                                    <%}%>
                                </div>
                            </div>
                            <%}}%>
                        </div>
                    </div>
                </div>

                <%-- RIGHT COLUMN --%>
                <div>

                    <%-- Progress timeline --%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-icon" style="background:#dcfce7;color:var(--green)">
                                <i class="fas fa-tasks"></i>
                            </div>
                            <div class="card-hd-title">Processing Progress</div>
                        </div>
                        <div class="card-body">
                            <div class="timeline">
                                <%-- Step 1: Submitted --%>
                                <div class="tl-item">
                                    <div class="tl-dot done"><i class="fas fa-check"></i></div>
                                    <div class="tl-content">
                                        <div class="tl-label">Request Submitted</div>
                                        <div class="tl-sub"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toLocalDate():""%></div>
                                    </div>
                                </div>

                                <%if(cancelled){%>
                                <div class="tl-item">
                                    <div class="tl-dot skip"><i class="fas fa-ban"></i></div>
                                    <div class="tl-content">
                                        <div class="tl-label dim">Cancelled</div>
                                        <div class="tl-sub">Request was cancelled</div>
                                    </div>
                                </div>
                                <%}else if(rejected){%>
                                <div class="tl-item">
                                    <div class="tl-dot fail"><i class="fas fa-times"></i></div>
                                    <div class="tl-content">
                                        <div class="tl-label" style="color:var(--red)">Rejected</div>
                                        <div class="tl-sub"><%=sr.getReviewedAt()!=null?sr.getReviewedAt().toLocalDate():""%></div>
                                    </div>
                                </div>
                                <%}else{%>
                                <%-- Step 2: Approval --%>
                                <div class="tl-item">
                                    <div class="tl-dot <%=p2?"done":("PENDING".equals(sr.getStatus())?"current":"wait")%>">
                                        <i class="fas fa-<%=p2?"check":"clock"%>"></i>
                                    </div>
                                    <div class="tl-content">
                                        <div class="tl-label <%=p2?"":"dim"%>"><%=p2?"Approved":"Awaiting Approval"%></div>
                                        <%if(p2&&sr.getReviewedByName()!=null){%>
                                        <div class="tl-sub"><%=sr.getReviewedByName()%><%=sr.getReviewedAt()!=null?" · "+sr.getReviewedAt().toLocalDate():""%></div>
                                        <%}%>
                                    </div>
                                </div>
                                <%-- Step 3: In Progress --%>
                                <div class="tl-item">
                                    <div class="tl-dot <%=p3?"done":(p2?"current":"wait")%>">
                                        <i class="fas fa-<%=p3?"check":"spinner"%>"></i>
                                    </div>
                                    <div class="tl-content">
                                        <div class="tl-label <%=p3||p2?"":"dim"%>"><%=p3?"In Progress":"Awaiting Technician"%></div>
                                        <%if(sr.getAssignedToName()!=null){%>
                                        <div class="tl-sub">Technician: <%=sr.getAssignedToName()%></div>
                                        <%}%>
                                    </div>
                                </div>
                                <%-- Step 4: Completed --%>
                                <div class="tl-item">
                                    <div class="tl-dot <%=p4?"done":"wait"%>">
                                        <i class="fas fa-<%=p4?"check-circle":"flag"%>"></i>
                                    </div>
                                    <div class="tl-content">
                                        <div class="tl-label <%=p4?"":"dim"%>" <%=p4?"style='color:var(--green)'":""%>><%=p4?"Completed!":"Completion"%></div>
                                        <%if(p4&&sr.getCompletedAt()!=null){%>
                                        <div class="tl-sub" style="color:var(--green)"><%=sr.getCompletedAt().toLocalDate()%></div>
                                        <%}%>
                                    </div>
                                </div>
                                <%}%>
                            </div>
                        </div>
                    </div>

                    <%-- Assigned technician --%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-icon" style="background:#e0f2fe;color:var(--info)">
                                <i class="fas fa-user-hard-hat"></i>
                            </div>
                            <div class="card-hd-title">Assigned Staff</div>
                        </div>
                        <div class="card-body">
                            <%if(sr.getAssignedToName()!=null){%>
                            <div style="display:flex;align-items:center;gap:12px">
                                <%-- FIX: show avatar image if available, otherwise show letter --%>
                                <div class="tech-avatar">
                                    <%if(hasTechAvatar){%>
                                    <img src="<%=ctx%><%=techAvatarUrl%>" alt="avatar">
                                    <%}else{%>
                                    <%=techInitial%>
                                    <%}%>
                                </div>
                                <div>
                                    <div class="tech-name"><%=sr.getAssignedToName()%></div>
                                    <div class="tech-role"><i class="fas fa-wrench" style="margin-right:4px;color:var(--info)"></i>Technician</div>
                                </div>
                            </div>
                            <%}else{%>
                            <div style="text-align:center;padding:14px 0;color:var(--text-s);font-size:.82rem">
                                <i class="fas fa-user-clock" style="font-size:1.8rem;display:block;margin-bottom:8px;opacity:.2"></i>
                                Not yet assigned
                            </div>
                            <%}%>
                        </div>
                    </div>

                    <%-- Contract type note --%>
                    <div class="<%=isW?"note-card-w":"note-card-m"%>">
                        <div style="display:flex;align-items:flex-start;gap:12px">
                            <i class="fas fa-<%=isW?"shield-alt":"tools"%> note-icon" style="color:<%=isW?"var(--green)":"var(--blue)"%>;margin-top:2px"></i>
                            <div>
                                <div class="<%=isW?"note-title-w":"note-title-m"%>">
                                    <%=isW?"Warranty Contract":"Maintenance Contract"%>
                                </div>
                                <div class="note-desc <%=isW?"note-desc-w":"note-desc-m"%>">
                                    <%=isW?"Repair service is FREE under the warranty contract.":"Repair costs will be calculated and notified later."%>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </main>
<%@ include file="customerAIBubble.jsp" %>
</body>
</html>
