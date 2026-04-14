<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    ServiceRequest sr = (ServiceRequest) request.getAttribute("sr");
    if (sr == null) { response.sendRedirect(ctx + "/supportServiceRequests"); return; }
    List<ServiceRequestEquipment> equips = sr.getEquipmentList();
    if (equips == null) equips = new ArrayList<>();
    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title><%=sr.getRequestCode()%> – Service Request</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --sb-bg:        #1e1b4b;
                --sb-border:    rgba(255,255,255,0.08);
                --sb-text:      rgba(255,255,255,0.45);
                --sb-accent:    #818cf8;
                --sb-accent-2:  #a5b4fc;
                --sb-item-on:   rgba(129,140,248,0.2);
                --sb-width:     252px;

                --bg:           #f3f4f9;
                --bg-card:      #ffffff;
                --bg-topbar:    #ffffff;
                --border-light: #e8ecf5;
                --border-light2:#f0f2fb;
                --text-h:       #1e1b4b;
                --text-b:       #374151;
                --text-m:       #6b7280;
                --text-s:       #9ca3af;

                --primary:      #4f46e5;
                --primary-2:    #6366f1;
                --primary-light:#ede9fe;

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
                cursor:pointer;
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

            /* ═══════════ MAIN ═══════════ */
            .main{
                margin-left:var(--sb-width);
                flex:1;
                display:flex;
                flex-direction:column;
                min-height:100vh
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
                letter-spacing:-.3px;
                display:flex;
                align-items:center;
                gap:9px;
            }
            .topbar-title i{
                color:var(--primary-2);
                font-size:1rem
            }
            .topbar-sub{
                color:var(--text-s);
                font-size:.78rem;
                margin-top:2px
            }
            .content{
                padding:24px 28px;
                flex:1
            }

            /* Breadcrumb */
            .breadcrumb{
                display:flex;
                align-items:center;
                gap:7px;
                font-size:.76rem;
                color:var(--text-s);
                margin-bottom:18px;
            }
            .breadcrumb a{
                color:var(--text-s);
                text-decoration:none;
                transition:color .18s
            }
            .breadcrumb a:hover{
                color:var(--primary-2)
            }
            .bc-sep{
                color:var(--border-light)
            }
            .bc-cur{
                color:var(--primary-2);
                font-weight:700;
                font-family:'Courier New',monospace
            }

            /* Animation */
            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(14px)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }

            /* Buttons */
            .btn{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:9px 18px;
                border-radius:10px;
                font-size:.81rem;
                font-weight:600;
                font-family:'Sora',sans-serif;
                cursor:pointer;
                border:none;
                text-decoration:none;
                transition:all .2s;
            }
            .btn-secondary{
                background:#fff;
                color:var(--text-m);
                border:1.5px solid var(--border-light);
            }
            .btn-secondary:hover{
                background:#f3f4f6;
                border-color:#d1d5db;
                color:var(--text-b)
            }

            /* Detail grid */
            .detail-grid{
                display:grid;
                grid-template-columns:2fr 1fr;
                gap:20px;
                align-items:start;
            }

            /* Cards */
            .card{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                margin-bottom:18px;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                animation:cardIn .45s ease both;
            }
            .card:nth-child(1){
                animation-delay:.05s
            }
            .card:nth-child(2){
                animation-delay:.12s
            }
            .card-hd{
                display:flex;
                align-items:center;
                gap:9px;
                padding:14px 18px;
                border-bottom:1px solid var(--border-light2);
                background:#fafbff;
            }
            .card-hd-icon{
                width:30px;
                height:30px;
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.8rem;
                flex-shrink:0;
            }
            .card-hd-title{
                font-size:.88rem;
                font-weight:700;
                color:var(--text-h)
            }
            .card-hd-badge{
                margin-left:auto
            }
            .card-body{
                padding:18px 20px
            }

            /* Info rows */
            .info-row{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:9px 0;
                border-bottom:1px solid var(--border-light2);
                font-size:.82rem;
            }
            .info-row:last-child{
                border-bottom:none
            }
            .info-label{
                color:var(--text-s);
                font-weight:500
            }
            .info-value{
                color:var(--text-b);
                font-weight:600;
                text-align:right;
                display:flex;
                align-items:center;
                gap:6px;
                flex-wrap:wrap;
                justify-content:flex-end;
            }

            /* Sub label */
            .sub-lbl{
                font-size:.67rem;
                font-weight:700;
                color:var(--text-s);
                text-transform:uppercase;
                letter-spacing:1px;
                margin-bottom:7px;
                margin-top:16px;
            }

            /* Desc box */
            .desc-box{
                background:#fafbff;
                border:1px solid var(--border-light);
                border-radius:12px;
                padding:14px 16px;
                font-size:.83rem;
                color:var(--text-b);
                line-height:1.7;
                border-left:3px solid var(--primary-2);
            }

            /* Reject box */
            .reject-box{
                margin-top:14px;
                padding:13px 16px;
                background:#fee2e2;
                border:1.5px solid #fca5a5;
                border-radius:12px;
            }
            .reject-box-title{
                font-size:.72rem;
                font-weight:700;
                color:var(--red);
                margin-bottom:4px;
            }
            .reject-box-body{
                font-size:.82rem;
                color:#991b1b;
            }

            /* Contract link */
            .contract-link{
                color:var(--primary-2);
                text-decoration:none;
                font-weight:700;
                font-size:.82rem;
                font-family:'Courier New',monospace;
                transition:color .15s;
            }
            .contract-link:hover{
                color:var(--primary);
                text-decoration:underline
            }

            /* Badges */
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700;
                white-space:nowrap;
            }
            .b-pending    {
                background:#fef3c7;
                color:#92400e
            }
            .b-approved   {
                background:#d1fae5;
                color:#065f46
            }
            .b-rejected   {
                background:#fee2e2;
                color:#991b1b
            }
            .b-in_progress,.b-in-progress{
                background:#dbeafe;
                color:#1e40af
            }
            .b-completed  {
                background:#ede9fe;
                color:#5b21b6
            }
            .b-cancelled  {
                background:#f3f4f6;
                color:#6b7280
            }
            .b-low        {
                background:#dcfce7;
                color:#166534
            }
            .b-medium     {
                background:#fef3c7;
                color:#92400e
            }
            .b-high       {
                background:#ffedd5;
                color:#9a3412
            }
            .b-urgent     {
                background:#fee2e2;
                color:#991b1b
            }

            /* Contract type */
            .ct-badge{
                display:inline-flex;
                align-items:center;
                padding:2px 7px;
                border-radius:5px;
                font-size:.68rem;
                font-weight:700;
            }
            .ct-wr{
                background:#dbeafe;
                color:#1e40af
            }
            .ct-mt{
                background:#fef3c7;
                color:#92400e
            }

            /* Source badge */
            .src-badge{
                display:inline-flex;
                align-items:center;
                padding:2px 9px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700;
                background:var(--primary-light);
                color:var(--primary-2);
                border:1px solid rgba(99,102,241,0.25);
            }

            /* Table */
            table{
                width:100%;
                border-collapse:collapse;
                font-size:.8rem
            }
            thead tr{
                background:#fafbff
            }
            th{
                padding:10px 16px;
                text-align:left;
                color:var(--text-s);
                font-weight:700;
                font-size:.67rem;
                text-transform:uppercase;
                letter-spacing:.8px;
                border-bottom:1px solid var(--border-light2);
            }
            td{
                padding:12px 16px;
                border-bottom:1px solid var(--border-light2);
                vertical-align:middle;
                color:var(--text-b);
            }
            tr:last-child td{
                border-bottom:none
            }
            tbody tr{
                transition:background .12s
            }
            tbody tr:hover td{
                background:#f7f8ff
            }
            .td-muted{
                color:var(--text-s);
                font-size:.75rem
            }
            .td-num{
                color:var(--text-s);
                font-size:.75rem
            }
            .td-bold{
                font-weight:600;
                color:var(--text-h)
            }
            .td-empty{
                text-align:center;
                padding:28px 16px;
                color:var(--text-s);
                font-size:.82rem
            }
            .td-empty i{
                font-size:1.5rem;
                display:block;
                margin-bottom:8px;
                opacity:.2
            }

            /* Timeline */
            .timeline{
                display:flex;
                flex-direction:column;
                gap:0
            }
            .tl-item{
                display:flex;
                gap:13px;
                padding-bottom:18px;
                position:relative;
            }
            .tl-item:last-child{
                padding-bottom:0
            }
            .tl-dot{
                width:30px;
                height:30px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.72rem;
                flex-shrink:0;
                margin-top:1px;
            }
            .tl-dot.done    {
                background:#d1fae5;
                color:var(--green);
                border:1px solid #a7f3d0;
            }
            .tl-dot.active  {
                background:var(--primary-light);
                color:var(--primary-2);
                border:1px solid rgba(79,70,229,0.3);
            }
            .tl-dot.pending {
                background:#f9fafb;
                color:var(--text-s);
                border:1px solid var(--border-light);
            }
            .tl-dot.rejected{
                background:#fee2e2;
                color:var(--red);
                border:1px solid #fca5a5;
            }
            .tl-line{
                position:absolute;
                left:14px;
                top:32px;
                bottom:0;
                width:2px;
                background:linear-gradient(180deg,var(--border-light),transparent);
            }
            .tl-item:last-child .tl-line{
                display:none
            }
            .tl-content{
                flex:1;
                padding-top:4px
            }
            .tl-title{
                font-size:.83rem;
                font-weight:600;
                color:var(--text-h)
            }
            .tl-title.dim{
                color:var(--text-s)
            }
            .tl-sub{
                font-size:.73rem;
                color:var(--text-s);
                margin-top:3px;
                line-height:1.5
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
                    <div class="sb-role">Customer Support</div>
                </div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/supportDashboard"      class="sb-item"><i class="fas fa-home"></i> Dashboard</a>
                <div class="sb-lbl">Management</div>
                <a href="<%=ctx%>/supportCustomers"       class="sb-item"><i class="fas fa-users"></i> Customers</a>
                <a href="<%=ctx%>/supportContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/supportServiceRequests" class="sb-item on"><i class="fas fa-clipboard-list"></i> Service Requests</a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/supportChat"            class="sb-item"><i class="fas fa-comment-dots"></i> Live Chat</a>
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
                        <div class="sb-urole">Customer Support</div>
                    </div>
                </a>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
            </div>
        </aside>

        <%-- ═══════════ MAIN ═══════════ --%>
        <main class="main">

            <div class="topbar">
                <div>
                    <div class="topbar-title">
                        <i class="fas fa-clipboard-list"></i> Service Request Detail
                    </div>
                    <div class="topbar-sub"><%=sr.getRequestCode()%> · <%=sr.getCustomerName()%></div>
                </div>
                <a href="<%=ctx%>/supportServiceRequests" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back
                </a>
            </div>

            <div class="content">

                <div class="breadcrumb">
                    <a href="<%=ctx%>/supportServiceRequests">Service Requests</a>
                    <span class="bc-sep">›</span>
                    <span class="bc-cur"><%=sr.getRequestCode()%></span>
                </div>

                <div class="detail-grid">

                    <%-- ── LEFT COLUMN ── --%>
                    <div>
                        <%-- Main Info Card --%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:var(--primary-light);color:var(--primary-2)">
                                    <i class="fas fa-info-circle"></i>
                                </div>
                                <div class="card-hd-title"><%=sr.getRequestCode()%></div>
                                <div class="card-hd-badge">
                                    <span class="b b-<%=sr.getStatus().toLowerCase().replace("_","-")%>">
                                        <%=sr.getStatusLabel()!=null?sr.getStatusLabel():sr.getStatus()%>
                                    </span>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="info-row">
                                    <span class="info-label">Customer</span>
                                    <span class="info-value"><%=sr.getCustomerName()%></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Contract</span>
                                    <span class="info-value">
                                        <a href="<%=ctx%>/supportContracts?action=detail&id=<%=sr.getContractId()%>"
                                           class="contract-link"><%=sr.getContractCode()%></a>
                                        <span class="ct-badge <%="WARRANTY".equals(sr.getContractType())?"ct-wr":"ct-mt"%>">
                                            <%="WARRANTY".equals(sr.getContractType())?"WR":"MT"%>
                                        </span>
                                    </span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Priority</span>
                                    <span class="info-value">
                                        <%
                                        String pc="b-medium";
                                        if("LOW".equals(sr.getPriority()))    pc="b-low";
                                        else if("HIGH".equals(sr.getPriority()))   pc="b-high";
                                        else if("URGENT".equals(sr.getPriority())) pc="b-urgent";
                                        %>
                                        <span class="b <%=pc%>"><%=sr.getPriority()%></span>
                                    </span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Created</span>
                                    <span class="info-value td-muted">
                                        <%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().substring(0,16):""%>
                                    </span>
                                </div>

                                <div class="sub-lbl">Title</div>
                                <div style="font-weight:600;font-size:.9rem;color:var(--text-h);margin-bottom:4px">
                                    <%=sr.getTitle()%>
                                </div>

                                <div class="sub-lbl">Description</div>
                                <div class="desc-box"><%=sr.getDescription().replace("\n","<br>")%></div>

                                <%if(sr.getRejectReason()!=null&&!sr.getRejectReason().isEmpty()){%>
                                <div class="reject-box">
                                    <div class="reject-box-title"><i class="fas fa-times-circle"></i> Rejection Reason</div>
                                    <div class="reject-box-body"><%=sr.getRejectReason()%></div>
                                </div>
                                <%}%>
                            </div>
                        </div>

                        <%-- Equipment Card --%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:#e0f2fe;color:var(--info)">
                                    <i class="fas fa-desktop"></i>
                                </div>
                                <div class="card-hd-title">
                                    Equipment <span style="color:var(--text-s);font-weight:400">(<%=equips.size()%>)</span>
                                </div>
                            </div>
                            <table>
                                <thead>
                                    <tr><th>#</th><th>Equipment</th><th>Serial</th><th>Source</th><th>Issue</th></tr>
                                </thead>
                                <tbody>
                                    <%if(equips.isEmpty()){%>
                                    <tr><td colspan="5" class="td-empty">
                                            <i class="fas fa-desktop"></i>No equipment attached.
                                        </td></tr>
                                        <%}else{ int i=1; for(ServiceRequestEquipment e:equips){ %>
                                    <tr>
                                        <td class="td-num"><%=i++%></td>
                                        <td class="td-bold"><%=e.getDisplayName()%></td>
                                        <td class="td-muted"><%=e.getDisplaySerial()%></td>
                                        <td><span class="src-badge"><%=e.getSource()%></span></td>
                                        <td class="td-muted"><%=e.getIssueDescription()!=null?e.getIssueDescription():"-"%></td>
                                    </tr>
                                    <%}}%>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <%-- ── RIGHT COLUMN ── --%>
                    <div>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:#dcfce7;color:var(--green)">
                                    <i class="fas fa-stream"></i>
                                </div>
                                <div class="card-hd-title">Progress Timeline</div>
                            </div>
                            <div class="card-body">
                                <%
                                String st = sr.getStatus();
                                boolean isPending    = "PENDING".equals(st);
                                boolean isApproved   = "APPROVED".equals(st)||"IN_PROGRESS".equals(st)||"COMPLETED".equals(st);
                                boolean isInProgress = "IN_PROGRESS".equals(st)||"COMPLETED".equals(st);
                                boolean isCompleted  = "COMPLETED".equals(st);
                                boolean isRejected   = "REJECTED".equals(st);
                                boolean isCancelled  = "CANCELLED".equals(st);
                                %>
                                <div class="timeline">

                                    <%-- Submitted --%>
                                    <div class="tl-item">
                                        <div class="tl-dot done"><i class="fas fa-paper-plane"></i></div>
                                        <div class="tl-line"></div>
                                        <div class="tl-content">
                                            <div class="tl-title">Submitted</div>
                                            <div class="tl-sub"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().substring(0,16):""%></div>
                                        </div>
                                    </div>

                                    <%if(isRejected){%>
                                    <div class="tl-item">
                                        <div class="tl-dot rejected"><i class="fas fa-times"></i></div>
                                        <div class="tl-line"></div>
                                        <div class="tl-content">
                                            <div class="tl-title" style="color:var(--red)">Rejected</div>
                                            <div class="tl-sub">
                                                <%if(sr.getReviewedByName()!=null){%>By <%=sr.getReviewedByName()%> · <%}%>
                                                <%=sr.getReviewedAt()!=null?sr.getReviewedAt().toString().substring(0,16):""%>
                                            </div>
                                        </div>
                                    </div>

                                    <%}else if(isCancelled){%>
                                    <div class="tl-item">
                                        <div class="tl-dot rejected"><i class="fas fa-ban"></i></div>
                                        <div class="tl-line"></div>
                                        <div class="tl-content">
                                            <div class="tl-title dim">Cancelled</div>
                                            <div class="tl-sub">Request was cancelled</div>
                                        </div>
                                    </div>

                                    <%}else{%>

                                    <%-- Approved --%>
                                    <div class="tl-item">
                                        <div class="tl-dot <%=isApproved?"done":"pending"%>">
                                            <i class="fas fa-<%=isApproved?"check":"clock"%>"></i>
                                        </div>
                                        <div class="tl-line"></div>
                                        <div class="tl-content">
                                            <div class="tl-title <%=isApproved?"":"dim"%>"><%=isApproved?"Approved":"Awaiting Approval"%></div>
                                            <%if(isApproved&&sr.getReviewedByName()!=null){%>
                                            <div class="tl-sub">By <%=sr.getReviewedByName()%><%=sr.getReviewedAt()!=null?" · "+sr.getReviewedAt().toString().substring(0,16):""%></div>
                                            <%}%>
                                        </div>
                                    </div>

                                    <%-- In Progress --%>
                                    <div class="tl-item">
                                        <div class="tl-dot <%=isCompleted?"done":isInProgress?"active":"pending"%>">
                                            <i class="fas fa-<%=isCompleted?"check":"wrench"%>"></i>
                                        </div>
                                        <div class="tl-line"></div>
                                        <div class="tl-content">
                                            <div class="tl-title <%=isInProgress||isCompleted?"":"dim"%>"><%=isInProgress?"In Progress":isCompleted?"Work Done":"Pending Assignment"%></div>
                                            <%if(sr.getAssignedToName()!=null){%>
                                            <div class="tl-sub">Technician: <%=sr.getAssignedToName()%></div>
                                            <%}%>
                                        </div>
                                    </div>

                                    <%-- Completed --%>
                                    <div class="tl-item">
                                        <div class="tl-dot <%=isCompleted?"done":"pending"%>">
                                            <i class="fas fa-<%=isCompleted?"check-double":"flag-checkered"%>"></i>
                                        </div>
                                        <div class="tl-content">
                                            <div class="tl-title <%=isCompleted?"":"dim"%>" <%=isCompleted?"style='color:var(--green)'":""%>>
                                                <%=isCompleted?"Completed":"Not Yet Completed"%>
                                            </div>
                                            <%if(isCompleted&&sr.getCompletedAt()!=null){%>
                                            <div class="tl-sub" style="color:var(--green)"><%=sr.getCompletedAt().toString().substring(0,16)%></div>
                                            <%}%>
                                        </div>
                                    </div>

                                    <%}%>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </main>

    </body>
</html>
