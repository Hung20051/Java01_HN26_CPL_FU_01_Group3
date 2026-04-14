<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();

    Map<String,Integer> cs  = (Map<String,Integer>) request.getAttribute("contractStats");
    Map<String,Integer> ss  = (Map<String,Integer>) request.getAttribute("srStats");
    int totalCustomers      = request.getAttribute("totalCustomers") != null ? (int)request.getAttribute("totalCustomers") : 0;
    List<?> recentContracts = (List<?>) request.getAttribute("recentContracts");
    List<?> pendingSRs      = (List<?>) request.getAttribute("pendingSRs");
    if (cs == null) cs = new HashMap<>();
    if (ss == null) ss = new HashMap<>();
    if (recentContracts == null) recentContracts = new ArrayList<>();
    if (pendingSRs == null) pendingSRs = new ArrayList<>();

    int cTotal  = cs.getOrDefault("total", 0);
    int cActive = cs.getOrDefault("active", 0);
    int srTotal = ss.getOrDefault("total", 0);
    int srPend  = ss.getOrDefault("pending", 0);
    int srDone  = ss.getOrDefault("completed", 0);

    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Dashboard – Customer Support</title>
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
            .topbar-greeting{
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

            .content{
                padding:24px 28px;
                flex:1
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

            /* ── STAT CARDS ── */
            .stats-grid{
                display:grid;
                grid-template-columns:repeat(4,1fr);
                gap:14px;
                margin-bottom:24px;
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
            .sc{
                border-radius:16px;
                padding:20px;
                position:relative;
                overflow:hidden;
                color:#fff;
                transition:all .22s;
                animation:cardIn .45s ease both;
            }
            .sc:nth-child(1){
                animation-delay:.04s
            }
            .sc:nth-child(2){
                animation-delay:.09s
            }
            .sc:nth-child(3){
                animation-delay:.14s
            }
            .sc:nth-child(4){
                animation-delay:.19s
            }
            .sc:hover{
                transform:translateY(-3px);
                box-shadow:0 12px 32px rgba(0,0,0,0.18)
            }

            .sc-blue  {
                background:var(--blue);
                box-shadow:0 4px 20px rgba(37,99,235,0.3)
            }
            .sc-green {
                background:var(--green);
                box-shadow:0 4px 20px rgba(22,163,74,0.3)
            }
            .sc-amber {
                background:var(--amber);
                box-shadow:0 4px 20px rgba(217,119,6,0.3)
            }
            .sc-purple{
                background:var(--purple);
                box-shadow:0 4px 20px rgba(124,58,237,0.3)
            }

            /* decorative circles */
            .sc::after {
                content:'';
                position:absolute;
                width:90px;
                height:90px;
                border-radius:50%;
                background:rgba(255,255,255,0.12);
                top:-24px;
                right:-24px;
            }
            .sc::before{
                content:'';
                position:absolute;
                width:55px;
                height:55px;
                border-radius:50%;
                background:rgba(255,255,255,0.07);
                bottom:-12px;
                right:22px;
            }

            .sc-icon{
                width:40px;
                height:40px;
                border-radius:11px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1rem;
                margin-bottom:14px;
                background:rgba(255,255,255,0.2);
                position:relative;
                z-index:1;
            }
            .sc-val{
                font-size:2.1rem;
                font-weight:800;
                line-height:1;
                letter-spacing:-1.5px;
                position:relative;
                z-index:1
            }
            .sc-lbl{
                font-size:.76rem;
                font-weight:600;
                opacity:.88;
                margin-top:5px;
                position:relative;
                z-index:1
            }
            .sc-sub{
                font-size:.7rem;
                opacity:.6;
                margin-top:3px;
                position:relative;
                z-index:1
            }

            /* ── LAYOUT ── */
            .grid-2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:18px
            }

            /* ── CARD ── */
            .card{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                animation:cardIn .45s .22s ease both;
            }
            .card-hd{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:14px 18px;
                border-bottom:1px solid var(--border-light2);
                background:#fafbff;
            }
            .card-title{
                font-size:.85rem;
                font-weight:700;
                color:var(--text-h);
                display:flex;
                align-items:center;
                gap:8px;
            }
            .card-title i{
                color:var(--primary-2);
                font-size:.8rem
            }
            .card-link{
                font-size:.74rem;
                font-weight:700;
                color:var(--primary-2);
                text-decoration:none;
                transition:color .18s
            }
            .card-link:hover{
                color:var(--primary)
            }

            /* ── TABLE ── */
            table{
                width:100%;
                border-collapse:collapse;
                font-size:.79rem
            }
            thead tr{
                background:#fafbff
            }
            th{
                padding:9px 16px;
                text-align:left;
                color:var(--text-s);
                font-weight:700;
                font-size:.64rem;
                text-transform:uppercase;
                letter-spacing:.9px;
                border-bottom:1px solid var(--border-light2);
            }
            td{
                padding:11px 16px;
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

            .td-empty{
                text-align:center;
                padding:28px 16px;
                color:var(--text-s);
                font-size:.82rem
            }

            /* ── BADGES ── */
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700;
                white-space:nowrap;
            }
            .b-active     {
                background:#d1fae5;
                color:#065f46
            }
            .b-expired    {
                background:#fef3c7;
                color:#92400e
            }
            .b-cancelled  {
                background:#f3f4f6;
                color:#6b7280
            }
            .b-warranty   {
                background:#dbeafe;
                color:#1e40af
            }
            .b-maintenance{
                background:#fef3c7;
                color:#92400e
            }
            .b-pending    {
                background:#fef3c7;
                color:#92400e
            }
            .b-approved   {
                background:#d1fae5;
                color:#065f46
            }
            .b-in_progress{
                background:#dbeafe;
                color:#1e40af
            }
            .b-completed  {
                background:#ede9fe;
                color:#5b21b6
            }
            .b-rejected   {
                background:#fee2e2;
                color:#991b1b
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

            /* Code link */
            .code-link{
                color:var(--primary-2);
                font-weight:700;
                font-size:.77rem;
                font-family:'Courier New',monospace;
                text-decoration:none;
                letter-spacing:-.3px;
            }
            .code-link:hover{
                color:var(--primary);
                text-decoration:underline
            }
            .td-muted{
                color:var(--text-s);
                font-size:.75rem
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
                <a href="<%=ctx%>/supportDashboard"      class="sb-item on"><i class="fas fa-home"></i> Dashboard</a>
                <div class="sb-lbl">Management</div>
                <a href="<%=ctx%>/supportCustomers"       class="sb-item"><i class="fas fa-users"></i> Customers</a>
                <a href="<%=ctx%>/supportContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
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
                    <div class="topbar-greeting">
                        <i class="fas fa-home" style="color:var(--primary-2);margin-right:8px;font-size:1rem"></i>Dashboard
                    </div>
                    <div class="topbar-sub">Welcome back, <%=me.getFullName()%></div>
                </div>
            </div>

            <div class="content">

                <%-- Stats --%>
                <div class="section-lbl">Overview</div>
                <div class="stats-grid">
                    <div class="sc sc-blue">
                        <div class="sc-icon"><i class="fas fa-users"></i></div>
                        <div class="sc-val"><%=totalCustomers%></div>
                        <div class="sc-lbl">Total Customers</div>
                    </div>
                    <div class="sc sc-green">
                        <div class="sc-icon"><i class="fas fa-file-contract"></i></div>
                        <div class="sc-val"><%=cActive%></div>
                        <div class="sc-lbl">Active Contracts</div>
                        <div class="sc-sub"><%=cTotal%> total</div>
                    </div>
                    <div class="sc sc-amber">
                        <div class="sc-icon"><i class="fas fa-hourglass-half"></i></div>
                        <div class="sc-val"><%=srPend%></div>
                        <div class="sc-lbl">Pending Requests</div>
                    </div>
                    <div class="sc sc-purple">
                        <div class="sc-icon"><i class="fas fa-circle-check"></i></div>
                        <div class="sc-val"><%=srDone%></div>
                        <div class="sc-lbl">Completed Requests</div>
                        <div class="sc-sub"><%=srTotal%> total</div>
                    </div>
                </div>

                <%-- Activity --%>
                <div class="section-lbl">Activity</div>
                <div class="grid-2">

                    <%-- Active Contracts --%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-title">
                                <i class="fas fa-file-contract"></i> Active Contracts
                            </div>
                            <a href="<%=ctx%>/supportContracts" class="card-link">View all →</a>
                        </div>
                        <table>
                            <thead>
                                <tr><th>Code</th><th>Customer</th><th>Type</th><th>Expires</th></tr>
                            </thead>
                            <tbody>
                                <%if(recentContracts.isEmpty()){%>
                                <tr><td colspan="4" class="td-empty">No active contracts</td></tr>
                                <%}else{for(Object obj:recentContracts){model.Contract c=(model.Contract)obj;%>
                                <tr>
                                    <td><a class="code-link" href="<%=ctx%>/supportContracts?action=detail&id=<%=c.getId()%>"><%=c.getContractCode()%></a></td>
                                    <td style="font-weight:600;color:var(--text-h)"><%=c.getCustomerName()%></td>
                                    <td><span class="b <%="WARRANTY".equals(c.getContractType())?"b-warranty":"b-maintenance"%>"><%=c.getContractType()%></span></td>
                                    <td class="td-muted"><%=c.getEndDate()%></td>
                                </tr>
                                <%}}%>
                            </tbody>
                        </table>
                    </div>

                    <%-- Pending Service Requests --%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-title">
                                <i class="fas fa-hourglass-half"></i> Pending Requests
                            </div>
                            <a href="<%=ctx%>/supportServiceRequests?status=PENDING" class="card-link">View all →</a>
                        </div>
                        <table>
                            <thead>
                                <tr><th>Code</th><th>Customer</th><th>Title</th><th>Priority</th></tr>
                            </thead>
                            <tbody>
                                <%if(pendingSRs.isEmpty()){%>
                                <tr><td colspan="4" class="td-empty">No pending requests</td></tr>
                                <%}else{for(Object obj:pendingSRs){model.ServiceRequest sr=(model.ServiceRequest)obj;String pri=sr.getPriority()!=null?sr.getPriority().toLowerCase():"medium";%>
                                <tr>
                                    <td><a class="code-link" href="<%=ctx%>/supportServiceRequests?action=detail&id=<%=sr.getId()%>"><%=sr.getRequestCode()%></a></td>
                                    <td style="font-weight:600;color:var(--text-h)"><%=sr.getCustomerName()%></td>
                                    <td style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--text-m)"><%=sr.getTitle()%></td>
                                    <td><span class="b b-<%=pri%>"><%=sr.getPriority()%></span></td>
                                </tr>
                                <%}}%>
                            </tbody>
                        </table>
                    </div>

                </div>
            </div>
        </main>

    </body>
</html>
