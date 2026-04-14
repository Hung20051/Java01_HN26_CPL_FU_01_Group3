<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    Contract c = (Contract) request.getAttribute("contract");
    if (c == null) { response.sendRedirect(ctx + "/supportContracts"); return; }
    List<CustomerEquipment> equips = c.getEquipmentList();
    if (equips == null) equips = new ArrayList<>();

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");

    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title><%=c.getContractCode()%> – Contract Detail</title>
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

            /* ═══════════ MAIN (light) ═══════════ */
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

            /* Alert */
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
            .alert{
                display:flex;
                align-items:center;
                gap:12px;
                padding:12px 18px;
                border-radius:12px;
                margin-bottom:20px;
                font-size:.82rem;
                animation:cardIn .5s ease both;
            }
            .alert-success{
                background:#d1fae5;
                border:1px solid #a7f3d0;
                color:#065f46
            }
            .alert-success i{
                color:var(--green)
            }
            .alert-error  {
                background:#fee2e2;
                border:1px solid #fca5a5;
                color:#991b1b
            }
            .alert-error i{
                color:var(--red)
            }

            /* Status banner */
            .status-banner{
                padding:13px 18px;
                border-radius:13px;
                margin-bottom:20px;
                display:flex;
                align-items:center;
                gap:12px;
                font-size:.84rem;
                font-weight:500;
                animation:cardIn .4s ease both;
            }
            .status-banner.active   {
                background:#d1fae5;
                border:1.5px solid #a7f3d0;
                color:#065f46
            }
            .status-banner.active i {
                color:var(--green)
            }
            .status-banner.expired  {
                background:#fef3c7;
                border:1.5px solid #fde68a;
                color:#92400e
            }
            .status-banner.expired i{
                color:var(--amber)
            }
            .status-banner.cancelled  {
                background:#fee2e2;
                border:1.5px solid #fca5a5;
                color:#991b1b
            }
            .status-banner.cancelled i{
                color:var(--red)
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
                animation-delay:.10s
            }

            .card-hd{
                display:flex;
                align-items:center;
                justify-content:space-between;
                padding:14px 18px;
                border-bottom:1px solid var(--border-light2);
                background:#fafbff;
            }
            .card-hd-title{
                font-size:.88rem;
                font-weight:700;
                color:var(--text-h);
                display:flex;
                align-items:center;
                gap:8px;
            }
            .card-hd-title i{
                color:var(--primary-2);
                font-size:.82rem
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
                text-align:right
            }

            /* Notes box */
            .notes-box{
                margin-top:14px;
                padding:12px 14px;
                background:#fafbff;
                border:1px solid var(--border-light);
                border-radius:10px;
                border-left:3px solid var(--primary-2);
                font-size:.81rem;
                color:var(--text-m);
                line-height:1.6;
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
            .td-empty{
                text-align:center;
                padding:28px 16px;
                color:var(--text-s);
                font-size:.82rem
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
            .b-active      {
                background:#d1fae5;
                color:#065f46
            }
            .b-expired     {
                background:#fef3c7;
                color:#92400e
            }
            .b-cancelled   {
                background:#f3f4f6;
                color:#6b7280
            }
            .b-WARRANTY    {
                background:#dbeafe;
                color:#1e40af
            }
            .b-MAINTENANCE {
                background:#fef3c7;
                color:#92400e
            }
            .b-warranty-ok {
                background:#d1fae5;
                color:#065f46
            }
            .b-warranty-exp{
                background:#fee2e2;
                color:#991b1b
            }
            .b-source      {
                background:var(--primary-light);
                color:var(--primary-2);
                border:1px solid rgba(99,102,241,0.25);
            }
            .b-external    {
                background:#dbeafe;
                color:#1e40af
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
            .btn-danger-soft{
                background:#fee2e2;
                color:var(--red);
                border:1.5px solid #fca5a5;
            }
            .btn-danger-soft:hover{
                background:#fecaca;
            }
            .btn-full{
                width:100%;
                justify-content:center;
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
                <a href="<%=ctx%>/supportContracts"       class="sb-item on"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/supportServiceRequests" class="sb-item"><i class="fas fa-clipboard-list"></i> Service Requests</a>
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
                        <i class="fas fa-file-contract"></i> Contract Detail
                    </div>
                    <div class="topbar-sub"><%=c.getContractCode()%> · <%=c.getCustomerName()%></div>
                </div>
                <a href="<%=ctx%>/supportContracts" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Contracts
                </a>
            </div>

            <div class="content">

                <%if(flashOk!=null){%>
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=flashOk%></div>
                <%}%>
                <%if(flashErr!=null){%>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div>
                <%}%>

                <%-- Breadcrumb --%>
                <div class="breadcrumb">
                    <a href="<%=ctx%>/supportContracts">Contracts</a>
                    <span class="bc-sep">›</span>
                    <span class="bc-cur"><%=c.getContractCode()%></span>
                </div>

                <%-- Status banner --%>
                <div class="status-banner <%=c.getStatus().toLowerCase()%>">
                    <i class="fas fa-<%="ACTIVE".equals(c.getStatus())?"check-circle":"EXPIRED".equals(c.getStatus())?"clock":"ban"%>"></i>
                    <span>
                        Contract is <strong><%=c.getStatus()%></strong>
                        <%if("ACTIVE".equals(c.getStatus())){%>· Valid until <strong><%=c.getEndDate()%></strong><%}%>
                    </span>
                    <%if("ACTIVE".equals(c.getStatus())){%>
                    <form method="post" action="<%=ctx%>/supportContracts" style="margin-left:auto"
                          onsubmit="return confirm('Cancel this contract? This cannot be undone.')">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="id" value="<%=c.getId()%>">
                        <button type="submit" class="btn btn-danger-soft">
                            <i class="fas fa-ban"></i> Cancel Contract
                        </button>
                    </form>
                    <%}%>
                </div>

                <div class="detail-grid">

                    <%-- LEFT COLUMN --%>
                    <div>
                        <%-- Contract Info --%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-title">
                                    <i class="fas fa-info-circle"></i> Contract Information
                                </div>
                                <span class="b b-<%=c.getContractType()%>"><%=c.getContractType()%></span>
                            </div>
                            <div class="card-body">
                                <div class="info-row">
                                    <span class="info-label">Contract Code</span>
                                    <span class="info-value" style="font-family:'Courier New',monospace;color:var(--primary-2)"><%=c.getContractCode()%></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Customer</span>
                                    <span class="info-value"><%=c.getCustomerName()%></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Type</span>
                                    <span class="info-value"><span class="b b-<%=c.getContractType()%>"><%=c.getContractType()%></span></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Start Date</span>
                                    <span class="info-value"><%=c.getStartDate()%></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">End Date</span>
                                    <span class="info-value"><%=c.getEndDate()%></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Created By</span>
                                    <span class="info-value"><%=c.getCreatedByName()%></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Created At</span>
                                    <span class="info-value td-muted"><%=c.getCreatedAt()!=null?c.getCreatedAt().toString().substring(0,16):"—"%></span>
                                </div>
                                <%if(c.getNotes()!=null&&!c.getNotes().isEmpty()){%>
                                <div class="notes-box">
                                    <i class="fas fa-sticky-note" style="margin-right:6px;color:var(--primary-2)"></i><%=c.getNotes()%>
                                </div>
                                <%}%>
                            </div>
                        </div>

                        <%-- Equipment List --%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-title">
                                    <i class="fas fa-cogs"></i> Equipment
                                    <span style="color:var(--text-s);font-weight:400">(<%=equips.size()%>)</span>
                                </div>
                            </div>
                            <table>
                                <thead>
                                    <tr><th>#</th><th>Equipment</th><th>Serial</th><th>Category</th><th>Source</th><th>Warranty</th></tr>
                                </thead>
                                <tbody>
                                    <%if(equips.isEmpty()){%>
                                    <tr><td colspan="6" class="td-empty">No equipment found.</td></tr>
                                    <%}else{ int idx=1; for(CustomerEquipment e:equips){ %>
                                    <tr>
                                        <td class="td-muted"><%=idx++%></td>
                                        <td style="font-weight:600;color:var(--text-h)"><%=e.getDisplayName()%></td>
                                        <td class="td-muted"><%=e.getDisplaySerial()%></td>
                                        <td><%=e.getCategoryName()!=null?e.getCategoryName():"-"%></td>
                                        <td>
                                            <span class="b <%="EXTERNAL".equals(e.getSource())?"b-external":"b-source"%>">
                                                <%=e.getSource()%>
                                            </span>
                                        </td>
                                        <td>
                                            <%if(e.getWarrantyExpires()!=null){%>
                                            <span class="b <%=e.isUnderWarranty()?"b-warranty-ok":"b-warranty-exp"%>">
                                                <%=e.isUnderWarranty()?"Valid":"Expired"%> (<%=e.getWarrantyExpires()%>)
                                            </span>
                                            <%}else{%>
                                            <span class="td-muted">N/A</span>
                                            <%}%>
                                        </td>
                                    </tr>
                                    <%}}%>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <%-- RIGHT COLUMN --%>
                    <div>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-title">
                                    <i class="fas fa-chart-bar"></i> Summary
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="info-row">
                                    <span class="info-label">Equipment</span>
                                    <span class="info-value"><%=equips.size()%></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Service Requests</span>
                                    <span class="info-value"><%=c.getServiceRequestCount()%></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Status</span>
                                    <span class="info-value"><span class="b b-<%=c.getStatus().toLowerCase()%>"><%=c.getStatus()%></span></span>
                                </div>
                            </div>
                        </div>
                        <a href="<%=ctx%>/supportServiceRequests?status=PENDING&contractType=<%="WARRANTY".equals(c.getContractType())?"WARRANTY":"MAINTENANCE"%>"
                           class="btn btn-secondary btn-full" style="margin-top:4px">
                            <i class="fas fa-clipboard-list"></i> View Service Requests
                        </a>
                    </div>

                </div>
            </div>
        </main>

    </body>
</html>
