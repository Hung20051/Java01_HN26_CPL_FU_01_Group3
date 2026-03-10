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
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title><%=c.getContractCode()%> - Contract Detail</title>
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
                --danger:#ef4444;
                --warning:#f59e0b;
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
                flex-shrink:0;
                position:sticky;
                top:0
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
                flex:1
            }
            .breadcrumb{
                font-size:.78rem;
                color:var(--muted);
                margin-bottom:20px
            }
            .breadcrumb a{
                color:var(--primary);
                text-decoration:none
            }
            .breadcrumb a:hover{
                text-decoration:underline
            }
            .detail-grid{
                display:grid;
                grid-template-columns:2fr 1fr;
                gap:20px
            }
            .card{
                background:var(--surface);
                border-radius:12px;
                border:1px solid var(--border);
                overflow:hidden;
                margin-bottom:20px
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
            .card-body{
                padding:20px
            }
            .info-row{
                display:flex;
                justify-content:space-between;
                padding:8px 0;
                border-bottom:1px solid #f8fafc;
                font-size:.82rem
            }
            .info-row:last-child{
                border-bottom:none
            }
            .info-label{
                color:var(--muted);
                font-weight:500
            }
            .info-value{
                color:var(--text);
                font-weight:600;
                text-align:right
            }
            .badge{
                display:inline-flex;
                align-items:center;
                padding:3px 10px;
                border-radius:20px;
                font-size:.72rem;
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
            .badge-WARRANTY{
                background:#eff6ff;
                color:#1d4ed8
            }
            .badge-MAINTENANCE{
                background:#fff7ed;
                color:#c2410c
            }
            .badge-warranty-ok{
                background:#f0fdf4;
                color:#15803d
            }
            .badge-warranty-exp{
                background:#fef2f2;
                color:#991b1b
            }
            .badge-external{
                background:#eff6ff;
                color:#1d4ed8
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
            .btn{
                padding:8px 16px;
                border-radius:8px;
                border:none;
                cursor:pointer;
                font-size:.82rem;
                font-weight:600;
                font-family:inherit;
                display:inline-flex;
                align-items:center;
                gap:6px;
                transition:.15s;
                text-decoration:none
            }
            .btn-outline{
                background:#fff;
                color:var(--text);
                border:1.5px solid var(--border)
            }
            .btn-outline:hover{
                border-color:var(--primary);
                color:var(--primary)
            }
            .btn-danger-soft{
                background:#fee2e2;
                color:#991b1b;
                border:none
            }
            .btn-danger-soft:hover{
                background:#fecaca
            }
            .flash{
                padding:12px 16px;
                border-radius:8px;
                margin-bottom:18px;
                font-size:.82rem;
                font-weight:500
            }
            .flash-ok{
                background:#f0fdf4;
                color:#166534;
                border:1px solid #bbf7d0
            }
            .flash-err{
                background:#fef2f2;
                color:#991b1b;
                border:1px solid #fecaca
            }
            /* status banner */
            .status-banner{
                padding:14px 20px;
                border-radius:10px;
                margin-bottom:20px;
                display:flex;
                align-items:center;
                gap:12px;
                font-size:.85rem;
                font-weight:500
            }
            .status-banner.active{
                background:#f0fdf4;
                color:#166534;
                border:1px solid #bbf7d0
            }
            .status-banner.expired{
                background:#fef9c3;
                color:#854d0e;
                border:1px solid #fde68a
            }
            .status-banner.cancelled{
                background:#fef2f2;
                color:#991b1b;
                border:1px solid #fecaca
            }
        </style>
    </head><body>

        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-bolt"></i></div>
                <div><div class="sb-name">DRSMS System</div><div class="sb-sub">Customer Support</div></div>
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
                <div class="sb-user">
                    <div class="sb-ava"><%=me.getFullName().substring(0,1).toUpperCase()%></div>
                    <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer Support</div></div>
                </div>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Log out</a>
            </div>
        </aside>

        <div class="main">
            <div class="topbar">
                <h1><i class="fas fa-file-contract" style="color:var(--primary);margin-right:8px"></i>Contract Detail</h1>
                <a href="<%=ctx%>/supportContracts" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Back to Contracts</a>
            </div>
            <div class="content">
                <%if(flashOk!=null){%><div class="flash flash-ok"><i class="fas fa-check-circle"></i> <%=flashOk%></div><%}%>
                <%if(flashErr!=null){%><div class="flash flash-err"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div><%}%>

                <div class="breadcrumb">
                    <a href="<%=ctx%>/supportContracts">Contracts</a> › <%=c.getContractCode()%>
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
                        <button type="submit" class="btn btn-danger-soft"><i class="fas fa-ban"></i> Cancel Contract</button>
                    </form>
                    <%}%>
                </div>

                <div class="detail-grid">
                    <div>
                        <%-- Contract Info --%>
                        <div class="card">
                            <div class="card-hd">
                                <h3><i class="fas fa-info-circle" style="color:var(--primary);margin-right:6px"></i>Contract Information</h3>
                                <span class="badge badge-<%=c.getContractType()%>"><%=c.getContractType()%></span>
                            </div>
                            <div class="card-body">
                                <div class="info-row"><span class="info-label">Contract Code</span><span class="info-value"><%=c.getContractCode()%></span></div>
                                <div class="info-row"><span class="info-label">Customer</span><span class="info-value"><%=c.getCustomerName()%></span></div>
                                <div class="info-row"><span class="info-label">Type</span><span class="info-value"><%=c.getContractType()%></span></div>
                                <div class="info-row"><span class="info-label">Start Date</span><span class="info-value"><%=c.getStartDate()%></span></div>
                                <div class="info-row"><span class="info-label">End Date</span><span class="info-value"><%=c.getEndDate()%></span></div>
                                <div class="info-row"><span class="info-label">Created By</span><span class="info-value"><%=c.getCreatedByName()%></span></div>
                                <div class="info-row"><span class="info-label">Created At</span><span class="info-value" style="color:var(--muted)"><%=c.getCreatedAt()!=null?c.getCreatedAt().toString().substring(0,16):""%></span></div>
                                    <%if(c.getNotes()!=null&&!c.getNotes().isEmpty()){%>
                                <div style="margin-top:12px;padding:12px;background:#f8fafc;border-radius:8px;font-size:.8rem;color:var(--muted)">
                                    <i class="fas fa-sticky-note" style="margin-right:6px"></i><%=c.getNotes()%>
                                </div>
                                <%}%>
                            </div>
                        </div>

                        <%-- Equipment List --%>
                        <div class="card">
                            <div class="card-hd">
                                <h3><i class="fas fa-cogs" style="color:var(--primary);margin-right:6px"></i>Equipment (<%=equips.size()%>)</h3>
                            </div>
                            <table>
                                <thead><tr><th>#</th><th>Equipment</th><th>Serial</th><th>Category</th><th>Source</th><th>Warranty</th></tr></thead>
                                <tbody>
                                    <%if(equips.isEmpty()){%>
                                    <tr><td colspan="6" style="text-align:center;padding:20px;color:var(--muted)">No equipment</td></tr>
                                    <%}else{int idx=1;for(CustomerEquipment e:equips){%>
                                    <tr>
                                        <td style="color:var(--muted)"><%=idx++%></td>
                                        <td style="font-weight:600"><%=e.getDisplayName()%></td>
                                        <td style="color:var(--muted);font-size:.75rem"><%=e.getDisplaySerial()%></td>
                                        <td><%=e.getCategoryName()!=null?e.getCategoryName():"-"%></td>
                                        <td><span class="badge <%="EXTERNAL".equals(e.getSource())?"badge-external":""%>" style="background:#f1f5f9;color:#475569"><%=e.getSource()%></span></td>
                                        <td>
                                            <%if(e.getWarrantyExpires()!=null){%>
                                            <span class="badge <%=e.isUnderWarranty()?"badge-warranty-ok":"badge-warranty-exp"%>">
                                                <%=e.isUnderWarranty()?"Valid":"Expired"%> (<%=e.getWarrantyExpires()%>)
                                            </span>
                                            <%}else{%><span style="color:var(--muted)">N/A</span><%}%>
                                        </td>
                                    </tr>
                                    <%}}%>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <%-- Right column: quick stats --%>
                    <div>
                        <div class="card">
                            <div class="card-hd"><h3><i class="fas fa-chart-bar" style="color:var(--primary);margin-right:6px"></i>Summary</h3></div>
                            <div class="card-body">
                                <div class="info-row"><span class="info-label">Equipment</span><span class="info-value"><%=equips.size()%></span></div>
                                <div class="info-row"><span class="info-label">Service Requests</span><span class="info-value"><%=c.getServiceRequestCount()%></span></div>
                                <div class="info-row"><span class="info-label">Status</span>
                                    <span class="info-value"><span class="badge badge-<%=c.getStatus().toLowerCase()%>"><%=c.getStatus()%></span></span>
                                </div>
                            </div>
                        </div>
                        <div style="margin-top:12px">
                            <a href="<%=ctx%>/supportServiceRequests?status=PENDING&contractType=<%="WARRANTY".equals(c.getContractType())?"WARRANTY":"MAINTENANCE"%>"
                               class="btn btn-outline" style="width:100%;justify-content:center">
                                <i class="fas fa-clipboard-list"></i> View Service Requests
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body></html>
