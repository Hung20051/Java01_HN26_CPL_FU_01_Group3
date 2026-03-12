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
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Dashboard - Customer Support</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root{
                --primary:#4f46e5;
                --sidebar:#0f172a;
                --bg:#f1f5f9;
                --surface:#fff;
                --border:#e2e8f0;
                --text:#0f172a;
                --muted:#64748b;
                --success:#10b981;
                --warning:#f59e0b;
                --danger:#ef4444;
                --info:#3b82f6;
                --sb-w:220px
            }
            *{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            body{
                font-family:'Inter',sans-serif;
                background:var(--bg);
                display:flex;
                min-height:100vh
            }
            .sb{
                width:var(--sb-w);
                height:100vh;
                background:var(--sidebar);
                display:flex;
                flex-direction:column;
                flex-shrink:0
            }
            .sb-brand{
                padding:20px 16px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid rgba(255,255,255,.07)
            }
            .sb-logo{
                width:32px;
                height:32px;
                background:var(--primary);
                border-radius:8px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.85rem
            }
            .sb-name{
                color:#fff;
                font-size:.95rem;
                font-weight:700
            }
            .sb-sub{
                color:rgba(255,255,255,.35);
                font-size:.65rem
            }
            .sb-nav{
                flex:1;
                padding:12px 8px;
                overflow-y:auto
            }
            .sb-lbl{
                color:rgba(255,255,255,.28);
                font-size:.6rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.2px;
                padding:0 8px;
                margin:12px 0 4px
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:8px;
                padding:8px 10px;
                border-radius:7px;
                margin-bottom:2px;
                color:rgba(255,255,255,.55);
                text-decoration:none;
                font-size:.82rem;
                font-weight:500;
                transition:.15s
            }
            .sb-item:hover{
                color:#fff;
                background:rgba(255,255,255,.07)
            }
            .sb-item.on{
                color:#fff;
                background:var(--primary)
            }
            .sb-item i{
                width:16px;
                text-align:center;
                font-size:.8rem
            }
            .sb-foot{
                padding:12px 8px 16px;
                border-top:1px solid rgba(255,255,255,.07)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:8px;
                padding:8px 10px;
                border-radius:8px;
                background:rgba(255,255,255,.05);
                margin-bottom:6px
            }
            .sb-ava{
                width:32px;
                height:32px;
                border-radius:50%;
                background:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.82rem;
                font-weight:700
            }
            .sb-uname{
                color:#fff;
                font-size:.78rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,.38);
                font-size:.67rem
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:7px 10px;
                border-radius:7px;
                color:rgba(255,255,255,.45);
                text-decoration:none;
                font-size:.78rem;
                transition:.15s
            }
            .sb-logout:hover{
                color:#f87171;
                background:rgba(248,113,113,.1)
            }
            .main{
                flex:1;
                display:flex;
                flex-direction:column;
                min-width:0
            }
            .topbar{
                background:var(--surface);
                border-bottom:1px solid var(--border);
                padding:0 28px;
                height:58px;
                display:flex;
                align-items:center;
                justify-content:space-between;
                flex-shrink:0
            }
            .topbar h1{
                font-size:1.05rem;
                font-weight:700;
                color:var(--text)
            }
            .content{
                padding:28px;
                flex:1;
                overflow-y:auto
            }
            .stat-grid{
                display:grid;
                grid-template-columns:repeat(4,1fr);
                gap:18px;
                margin-bottom:28px
            }
            .stat-card{
                background:var(--surface);
                border-radius:12px;
                padding:20px 22px;
                border:1px solid var(--border);
                display:flex;
                align-items:center;
                gap:16px
            }
            .stat-icon{
                width:46px;
                height:46px;
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.15rem;
                flex-shrink:0
            }
            .stat-icon.blue{
                background:#eff6ff;
                color:var(--info)
            }
            .stat-icon.green{
                background:#f0fdf4;
                color:var(--success)
            }
            .stat-icon.orange{
                background:#fffbeb;
                color:var(--warning)
            }
            .stat-icon.purple{
                background:#f5f3ff;
                color:var(--primary)
            }
            .stat-val{
                font-size:1.6rem;
                font-weight:800;
                color:var(--text);
                line-height:1
            }
            .stat-lbl{
                font-size:.75rem;
                color:var(--muted);
                margin-top:3px;
                font-weight:500
            }
            .grid-2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:20px
            }
            .card{
                background:var(--surface);
                border-radius:12px;
                border:1px solid var(--border);
                overflow:hidden
            }
            .card-hd{
                padding:16px 20px;
                border-bottom:1px solid var(--border);
                display:flex;
                align-items:center;
                justify-content:space-between
            }
            .card-hd h3{
                font-size:.88rem;
                font-weight:700;
                color:var(--text)
            }
            .view-all{
                font-size:.75rem;
                color:var(--primary);
                text-decoration:none;
                font-weight:600
            }
            .view-all:hover{
                text-decoration:underline
            }
            table{
                width:100%;
                border-collapse:collapse
            }
            th{
                padding:10px 16px;
                text-align:left;
                font-size:.72rem;
                font-weight:700;
                color:var(--muted);
                text-transform:uppercase;
                letter-spacing:.5px;
                background:#f8fafc;
                border-bottom:1px solid var(--border)
            }
            td{
                padding:11px 16px;
                font-size:.8rem;
                color:var(--text);
                border-bottom:1px solid #f8fafc;
                vertical-align:middle
            }
            tr:last-child td{
                border-bottom:none
            }
            tr:hover td{
                background:#fafafa
            }
            .badge{
                display:inline-flex;
                align-items:center;
                padding:2px 9px;
                border-radius:20px;
                font-size:.7rem;
                font-weight:600
            }
            .badge-active{
                background:#f0fdf4;
                color:#15803d
            }
            .badge-expired{
                background:#fef9c3;
                color:#854d0e
            }
            .badge-cancelled{
                background:#fef2f2;
                color:#991b1b
            }
            .badge-warranty{
                background:#eff6ff;
                color:#1d4ed8
            }
            .badge-maintenance{
                background:#fff7ed;
                color:#c2410c
            }
            .badge-pending{
                background:#fef3c7;
                color:#92400e
            }
            .badge-approved{
                background:#d1fae5;
                color:#065f46
            }
            .badge-in_progress{
                background:#dbeafe;
                color:#1e40af
            }
            .badge-completed{
                background:#f0fdf4;
                color:#166534
            }
            .badge-rejected{
                background:#fee2e2;
                color:#991b1b
            }
            .badge-high{
                background:#fee2e2;
                color:#991b1b
            }
            .badge-medium{
                background:#fef3c7;
                color:#92400e
            }
            .badge-low{
                background:#f0fdf4;
                color:#166534
            }
            .badge-urgent{
                background:#fce7f3;
                color:#9d174d
            }
            a.row-link{
                color:var(--primary);
                text-decoration:none;
                font-weight:600
            }
            a.row-link:hover{
                text-decoration:underline
            }
        </style>
    </head><body>

        <%-- SIDEBAR --%>
        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-bolt"></i></div>
                <div><div class="sb-name">DRSMS System</div><div class="sb-sub">Customer Support</div></div>
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
    <a href="<%=ctx%>/profile" class="sb-user" style="text-decoration:none;cursor:pointer">
        <div class="sb-ava" style="overflow:hidden;padding:0">
            <%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%>
            <img src="<%=ctx%><%=me.getAvatarUrl()%>" style="width:34px;height:34px;object-fit:cover;border-radius:50%">
            <%}else{%>
            <%=me.getFullName().substring(0,1).toUpperCase()%>
            <%}%>
        </div>
        <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer Support</div></div>
    </a>
    <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
</div>
        </aside>

        <div class="main">
            <div class="topbar">
                <h1><i class="fas fa-home" style="color:var(--primary);margin-right:8px"></i>Dashboard</h1>
                <span style="font-size:.8rem;color:var(--muted)">Welcome back, <%=me.getFullName()%></span>
            </div>
            <div class="content">

                <%-- STAT CARDS --%>
                <div class="stat-grid">
                    <div class="stat-card">
                        <div class="stat-icon blue"><i class="fas fa-users"></i></div>
                        <div><div class="stat-val"><%=totalCustomers%></div><div class="stat-lbl">Total Customers</div></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon green"><i class="fas fa-file-contract"></i></div>
                        <div><div class="stat-val"><%=cActive%></div><div class="stat-lbl">Active Contracts (<%=cTotal%> total)</div></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon orange"><i class="fas fa-clock"></i></div>
                        <div><div class="stat-val"><%=srPend%></div><div class="stat-lbl">Pending Requests</div></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon purple"><i class="fas fa-check-circle"></i></div>
                        <div><div class="stat-val"><%=srDone%></div><div class="stat-lbl">Completed Requests (<%=srTotal%> total)</div></div>
                    </div>
                </div>

                <div class="grid-2">
                    <%-- Recent Active Contracts --%>
                    <div class="card">
                        <div class="card-hd">
                            <h3><i class="fas fa-file-contract" style="color:var(--primary);margin-right:6px"></i>Active Contracts</h3>
                            <a href="<%=ctx%>/supportContracts" class="view-all">View all →</a>
                        </div>
                        <table>
                            <thead><tr><th>Code</th><th>Customer</th><th>Type</th><th>Expires</th></tr></thead>
                            <tbody>
                                <%  if (recentContracts.isEmpty()) { %>
                                <tr><td colspan="4" style="text-align:center;color:var(--muted);padding:20px">No active contracts</td></tr>
                                <% } else {
                                    for (Object obj : recentContracts) {
                                        model.Contract c = (model.Contract) obj;
                                %>
                                <tr>
                                    <td><a class="row-link" href="<%=ctx%>/supportContracts?action=detail&id=<%=c.getId()%>"><%=c.getContractCode()%></a></td>
                                    <td><%=c.getCustomerName()%></td>
                                    <td><span class="badge <%="WARRANTY".equals(c.getContractType())?"badge-warranty":"badge-maintenance"%>"><%=c.getContractType()%></span></td>
                                    <td style="color:var(--muted)"><%=c.getEndDate()%></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>

                    <%-- Pending Service Requests --%>
                    <div class="card">
                        <div class="card-hd">
                            <h3><i class="fas fa-clock" style="color:var(--warning);margin-right:6px"></i>Pending Requests</h3>
                            <a href="<%=ctx%>/supportServiceRequests?status=PENDING" class="view-all">View all →</a>
                        </div>
                        <table>
                            <thead><tr><th>Code</th><th>Customer</th><th>Title</th><th>Priority</th></tr></thead>
                            <tbody>
                                <% if (pendingSRs.isEmpty()) { %>
                                <tr><td colspan="4" style="text-align:center;color:var(--muted);padding:20px">No pending requests</td></tr>
                                <% } else {
                                    for (Object obj : pendingSRs) {
                                        model.ServiceRequest sr = (model.ServiceRequest) obj;
                                        String pri = sr.getPriority() != null ? sr.getPriority().toLowerCase() : "medium";
                                %>
                                <tr>
                                    <td><a class="row-link" href="<%=ctx%>/supportServiceRequests?action=detail&id=<%=sr.getId()%>"><%=sr.getRequestCode()%></a></td>
                                    <td><%=sr.getCustomerName()%></td>
                                    <td style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><%=sr.getTitle()%></td>
                                    <td><span class="badge badge-<%=pri%>"><%=sr.getPriority()%></span></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
    </body></html>
