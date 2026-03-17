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
    int unpaidInv=0;
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
            /* Sidebar */
            --sb-bg:       #1e1b4b;
            --sb-border:   rgba(255,255,255,0.08);
            --sb-text:     rgba(255,255,255,0.45);
            --sb-accent:   #818cf8;
            --sb-accent-2: #a5b4fc;
            --sb-item-on:  rgba(129,140,248,0.2);
            --sb-width:    252px;

            /* Content */
            --bg:          #f3f4f9;
            --bg-card:     #ffffff;
            --bg-topbar:   #ffffff;
            --border-l:    #e8ecf5;
            --border-l2:   #f0f2fb;
            --text-h:      #1e1b4b;
            --text-b:      #374151;
            --text-m:      #6b7280;
            --text-s:      #9ca3af;

            /* Brand / primary */
            --primary:     #4f46e5;
            --primary-2:   #6366f1;
            --primary-lt:  #ede9fe;

            /* Status */
            --purple: #7c3aed;
            --blue:   #2563eb;
            --teal:   #0d9488;
            --green:  #16a34a;
            --red:    #dc2626;
            --amber:  #d97706;
            --orange: #ea580c;

            /* Semantic dims for alerts */
            --green-dim:  rgba(22,163,74,0.1);
            --red-dim:    rgba(220,38,38,0.1);
        }

        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{scroll-behavior:smooth}
        body{font-family:'Sora',sans-serif;background:var(--bg);color:var(--text-b);min-height:100vh;display:flex}
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
            box-shadow:0 4px 12px rgba(129,140,248,0.4); flex-shrink:0;
        }
        .sb-name{color:#fff; font-size:1.05rem; font-weight:800; letter-spacing:-.3px}
        .sb-role{
            display:inline-flex; align-items:center;
            background:rgba(129,140,248,0.2); border:1px solid rgba(129,140,248,0.3);
            color:var(--sb-accent-2); font-size:.6rem; font-weight:700;
            letter-spacing:1px; text-transform:uppercase;
            padding:2px 8px; border-radius:20px; margin-top:3px;
        }
        .sb-nav{flex:1; padding:12px 10px; overflow-y:auto}
        .sb-lbl{
            color:rgba(255,255,255,0.22); font-size:.6rem; font-weight:700;
            text-transform:uppercase; letter-spacing:1.6px;
            padding:0 8px; margin:14px 0 5px;
        }
        .sb-item{
            display:flex; align-items:center; gap:9px;
            padding:8px 10px; border-radius:9px; margin-bottom:1px;
            color:var(--sb-text); text-decoration:none;
            font-size:.81rem; font-weight:500; transition:all .18s;
            border-left:2px solid transparent;
        }
        .sb-item i{
            width:28px; height:28px;
            display:flex; align-items:center; justify-content:center;
            font-size:.78rem; border-radius:8px;
            background:rgba(255,255,255,0.06); flex-shrink:0; transition:all .18s;
        }
        .sb-item.on{color:#fff; background:var(--sb-item-on); border-left-color:var(--sb-accent)}
        .sb-item.on i{background:rgba(129,140,248,0.3); color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){color:rgba(255,255,255,0.78); background:rgba(255,255,255,0.06)}

        .sb-badge{
            margin-left:auto; background:#ef4444;
            color:#fff; font-size:.6rem; font-weight:700;
            padding:2px 7px; border-radius:20px;
            box-shadow:0 2px 6px rgba(239,68,68,0.5);
        }
        .sb-foot{padding:12px 10px 14px; border-top:1px solid var(--sb-border)}
        .sb-user{
            display:flex; align-items:center; gap:9px;
            padding:9px 10px; border-radius:10px;
            background:rgba(255,255,255,0.07); border:1px solid rgba(255,255,255,0.1);
            margin-bottom:5px; text-decoration:none; transition:all .18s;
        }
        .sb-user:hover{background:rgba(129,140,248,0.18); border-color:rgba(129,140,248,0.3)}
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
            color:rgba(255,255,255,0.3); text-decoration:none; font-size:.78rem; transition:all .18s;
        }
        .sb-logout:hover{color:#fca5a5; background:rgba(239,68,68,0.1)}

        /* ═══════════ MAIN ═══════════ */
        .main{margin-left:var(--sb-width);flex:1;min-height:100vh;display:flex;flex-direction:column}

        .topbar{
            display:flex; justify-content:space-between; align-items:center;
            padding:18px 28px;
            background:var(--bg-topbar); border-bottom:1px solid var(--border-l);
            position:sticky; top:0; z-index:50;
            box-shadow:0 1px 6px rgba(0,0,0,0.06);
        }
        .topbar-title{font-size:1.15rem; font-weight:800; color:var(--text-h); letter-spacing:-.3px; display:flex; align-items:center; gap:9px}
        .topbar-title i{color:var(--primary-2); font-size:.95rem}
        .topbar-sub{color:var(--text-s); font-size:.78rem; margin-top:2px}

        .btn-cta{
            display:inline-flex; align-items:center; gap:8px;
            padding:10px 22px; background:var(--primary);
            color:#fff; text-decoration:none;
            font-size:.82rem; font-weight:700; border-radius:11px;
            box-shadow:0 4px 14px rgba(79,70,229,0.35);
            transition:all .22s; border:none; cursor:pointer; font-family:'Sora',sans-serif;
        }
        .btn-cta:hover{background:#4338ca;transform:translateY(-1px);box-shadow:0 8px 22px rgba(79,70,229,0.45)}

        .content{padding:24px 28px; flex:1}

        /* Alerts */
        .alert{
            display:flex; align-items:center; gap:10px;
            padding:12px 16px; border-radius:12px;
            font-size:.83rem; font-weight:500; margin-bottom:18px;
        }
        .alert-ok {background:rgba(22,163,74,0.1); border:1.5px solid rgba(22,163,74,0.3); color:#15803d}
        .alert-err{background:rgba(220,38,38,0.1); border:1.5px solid rgba(220,38,38,0.3); color:#b91c1c}

        /* Section label */
        .section-lbl{
            font-size:.63rem; font-weight:700;
            text-transform:uppercase; letter-spacing:2px;
            color:var(--primary-2); margin-bottom:13px;
            display:flex; align-items:center; gap:10px;
        }
        .section-lbl::after{content:'';flex:1;height:1px;background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)}

        /* ── STAT CARDS ── */
        .stats{display:grid; grid-template-columns:repeat(4,1fr); gap:14px; margin-bottom:24px}
        .sc{
            border-radius:16px; padding:18px 20px;
            color:#fff; position:relative; overflow:hidden;
            transition:all .22s; animation:cardIn .45s ease both; cursor:default;
        }
        .sc:nth-child(1){animation-delay:.04s}
        .sc:nth-child(2){animation-delay:.09s}
        .sc:nth-child(3){animation-delay:.14s}
        .sc:nth-child(4){animation-delay:.19s}
        @keyframes cardIn{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}
        .sc:hover{transform:translateY(-3px); box-shadow:0 12px 32px rgba(0,0,0,0.18)}

        .sc-purple{background:var(--purple); box-shadow:0 4px 20px rgba(124,58,237,0.3)}
        .sc-amber {background:#b45309;       box-shadow:0 4px 20px rgba(180,83,9,0.3)}
        .sc-teal  {background:var(--teal);   box-shadow:0 4px 20px rgba(13,148,136,0.3)}
        .sc-green {background:var(--green);  box-shadow:0 4px 20px rgba(22,163,74,0.3)}

        .sc::after{content:'';position:absolute;width:100px;height:100px;border-radius:50%;background:rgba(255,255,255,0.12);top:-28px;right:-28px}
        .sc::before{content:'';position:absolute;width:60px;height:60px;border-radius:50%;background:rgba(255,255,255,0.07);bottom:-14px;right:28px}

        .sc-inner{display:flex; align-items:center; gap:14px; position:relative; z-index:1}
        .sc-icon{
            width:42px; height:42px; border-radius:12px;
            background:rgba(255,255,255,0.2);
            display:flex; align-items:center; justify-content:center;
            font-size:1rem; flex-shrink:0;
        }
        .sc-val{font-size:2rem; font-weight:800; color:#fff; line-height:1; letter-spacing:-1.2px}
        .sc-lbl{color:rgba(255,255,255,0.85); font-size:.74rem; margin-top:4px; font-weight:600}

        /* ── FILTER CARD ── */
        .filter-card{
            background:var(--bg-card); border:1px solid var(--border-l);
            border-radius:14px; padding:16px 20px; margin-bottom:20px;
            box-shadow:0 1px 4px rgba(0,0,0,0.05);
            animation:cardIn .45s .18s ease both;
        }
        .filter-row{display:flex; gap:10px; flex-wrap:wrap; align-items:center}

        .f-sel,.f-date{
            padding:9px 12px; border:1px solid var(--border-l);
            border-radius:10px; font-size:.82rem;
            font-family:'Sora',sans-serif; outline:none;
            background:#fff; color:var(--text-b); transition:all .2s;
        }
        .f-sel option{background:#fff; color:var(--text-b)}
        .f-sel:focus,.f-date:focus{
            border-color:rgba(79,70,229,0.4);
            box-shadow:0 0 0 3px rgba(79,70,229,0.1);
        }

        .btn-filter{
            display:inline-flex; align-items:center; gap:6px;
            padding:9px 16px; border-radius:10px;
            font-size:.82rem; font-weight:700;
            border:none; cursor:pointer; font-family:'Sora',sans-serif; transition:all .2s;
        }
        .btn-filter-blue{
            background:var(--primary); color:#fff;
            box-shadow:0 4px 12px rgba(79,70,229,0.3);
        }
        .btn-filter-blue:hover{background:#4338ca;transform:translateY(-1px)}
        .btn-filter-reset{
            background:#f3f4f6; color:var(--text-m);
            border:1px solid var(--border-l); text-decoration:none;
        }
        .btn-filter-reset:hover{background:#e5e7eb; color:var(--text-b)}

        /* ── TABLE CARD ── */
        .tbl-card{
            background:var(--bg-card); border:1px solid var(--border-l);
            border-radius:16px; overflow:hidden;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
            animation:cardIn .45s .22s ease both;
        }
        table{width:100%; border-collapse:collapse; font-size:.79rem}
        thead tr{background:#fafbff}
        th{
            padding:10px 16px; text-align:left;
            color:var(--text-s); font-weight:700;
            font-size:.64rem; text-transform:uppercase; letter-spacing:.9px;
            border-bottom:1px solid var(--border-l2);
        }
        td{
            padding:12px 16px;
            border-bottom:1px solid var(--border-l2);
            vertical-align:middle; color:var(--text-b);
        }
        tr:last-child td{border-bottom:none}
        tbody tr{transition:background .12s}
        tbody tr:hover td{background:#f7f8ff}

        /* ── BADGES ── */
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

        .ct-tag{display:inline-block; padding:2px 7px; border-radius:5px; font-size:.66rem; font-weight:700; margin-top:3px}
        .ct-wr{background:#d1fae5; color:#065f46}
        .ct-mt{background:#dbeafe; color:#1e40af}

        .code-link{
            color:var(--primary-2); font-weight:700;
            font-size:.76rem; font-family:'Courier New',monospace; text-decoration:none;
        }
        .code-link:hover{color:var(--primary); text-decoration:underline}

        .td-muted{color:var(--text-s); font-size:.73rem}
        .td-mono{font-family:'Courier New',monospace; font-size:.76rem; font-weight:700; color:var(--text-b)}

        /* Action buttons */
        .btn-view{
            padding:5px 12px; border-radius:8px;
            font-size:.74rem; font-weight:700;
            background:var(--primary-lt); color:var(--primary);
            text-decoration:none; display:inline-flex; align-items:center; gap:5px;
            border:1px solid rgba(79,70,229,0.2); transition:all .18s;
        }
        .btn-view:hover{background:rgba(79,70,229,0.15); color:#3730a3; transform:translateY(-1px)}

        .btn-cancel{
            padding:5px 12px; border-radius:8px;
            font-size:.74rem; font-weight:700;
            background:#fee2e2; color:#991b1b;
            border:1px solid rgba(220,38,38,0.2);
            cursor:pointer; font-family:'Sora',sans-serif;
            display:inline-flex; align-items:center; gap:5px; transition:all .18s;
        }
        .btn-cancel:hover{background:#fecaca; transform:translateY(-1px)}

        /* Empty */
        .empty{text-align:center; padding:48px 24px; color:var(--text-s); font-size:.83rem}
        .empty i{font-size:2.2rem; display:block; margin-bottom:10px; opacity:.18; color:var(--text-m)}
        .empty a{color:var(--primary-2); font-weight:700; text-decoration:none; display:inline-block; margin-top:8px}
        .empty a:hover{color:var(--primary)}
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
                <div class="sc-inner">
                    <div class="sc-icon"><i class="fas fa-list"></i></div>
                    <div><div class="sc-val"><%=totalSR%></div><div class="sc-lbl">Total Requests</div></div>
                </div>
            </div>
            <div class="sc sc-amber">
                <div class="sc-inner">
                    <div class="sc-icon"><i class="fas fa-clock"></i></div>
                    <div><div class="sc-val"><%=pendingCount%></div><div class="sc-lbl">Pending Approval</div></div>
                </div>
            </div>
            <div class="sc sc-teal">
                <div class="sc-inner">
                    <div class="sc-icon"><i class="fas fa-spinner"></i></div>
                    <div><div class="sc-val"><%=activeCount%></div><div class="sc-lbl">In Progress</div></div>
                </div>
            </div>
            <div class="sc sc-green">
                <div class="sc-inner">
                    <div class="sc-icon"><i class="fas fa-circle-check"></i></div>
                    <div><div class="sc-val"><%=completedCount%></div><div class="sc-lbl">Completed</div></div>
                </div>
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
                    else if("REJECTED".equals(sr.getStatus()))    sc="b-rejected";
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
                    <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--text-b)">
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
