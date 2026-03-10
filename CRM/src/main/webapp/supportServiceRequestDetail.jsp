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
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title><%=sr.getRequestCode()%> - Service Request</title>
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
                gap:8px
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
                text-align:right;
                max-width:60%
            }
            .badge{
                display:inline-flex;
                align-items:center;
                padding:3px 10px;
                border-radius:20px;
                font-size:.72rem;
                font-weight:600
            }
            .badge-pending{
                background:#fef3c7;
                color:#92400e
            }
            .badge-approved{
                background:#d1fae5;
                color:#065f46
            }
            .badge-in_progress,.badge-in-progress{
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
            .badge-cancelled{
                background:#f1f5f9;
                color:#475569
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
            .badge-WARRANTY{
                background:#eff6ff;
                color:#1d4ed8
            }
            .badge-MAINTENANCE{
                background:#fff7ed;
                color:#c2410c
            }
            table{
                width:100%;
                border-collapse:collapse
            }
            th{
                padding:10px 16px;
                font-size:.72rem;
                font-weight:700;
                color:var(--muted);
                text-transform:uppercase;
                letter-spacing:.5px;
                background:#f8fafc;
                border-bottom:1px solid var(--border);
                text-align:left
            }
            td{
                padding:11px 16px;
                font-size:.8rem;
                color:var(--text);
                border-bottom:1px solid #f8fafc;
                vertical-align:top
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
            .desc-box{
                background:#f8fafc;
                border-radius:8px;
                padding:14px 16px;
                font-size:.82rem;
                color:var(--text);
                line-height:1.6;
                border:1px solid var(--border)
            }
            /* timeline */
            .timeline{
                display:flex;
                flex-direction:column;
                gap:0
            }
            .tl-item{
                display:flex;
                gap:14px;
                padding-bottom:16px;
                position:relative
            }
            .tl-item:last-child{
                padding-bottom:0
            }
            .tl-dot{
                width:28px;
                height:28px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.72rem;
                flex-shrink:0;
                margin-top:1px
            }
            .tl-dot.done{
                background:#dcfce7;
                color:#166534
            }
            .tl-dot.active{
                background:#dbeafe;
                color:#1e40af
            }
            .tl-dot.pending{
                background:#f1f5f9;
                color:#94a3b8
            }
            .tl-dot.rejected{
                background:#fee2e2;
                color:#991b1b
            }
            .tl-line{
                position:absolute;
                left:13px;
                top:28px;
                bottom:0;
                width:2px;
                background:#e2e8f0
            }
            .tl-item:last-child .tl-line{
                display:none
            }
            .tl-content{
                flex:1
            }
            .tl-title{
                font-size:.8rem;
                font-weight:600;
                color:var(--text)
            }
            .tl-sub{
                font-size:.72rem;
                color:var(--muted);
                margin-top:2px
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
                <a href="<%=ctx%>/supportContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/supportServiceRequests" class="sb-item on"><i class="fas fa-clipboard-list"></i> Service Requests</a>
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
                <h1><i class="fas fa-clipboard-list" style="color:var(--primary);margin-right:8px"></i>Service Request Detail</h1>
                <a href="<%=ctx%>/supportServiceRequests" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Back</a>
            </div>
            <div class="content">
                <div class="breadcrumb">
                    <a href="<%=ctx%>/supportServiceRequests">Service Requests</a> › <%=sr.getRequestCode()%>
                </div>

                <div class="detail-grid">
                    <div>
                        <%-- Main info --%>
                        <div class="card">
                            <div class="card-hd">
                                <i class="fas fa-info-circle" style="color:var(--primary)"></i>
                                <h3><%=sr.getRequestCode()%></h3>
                                <span style="margin-left:auto" class="badge badge-<%=sr.getStatus().toLowerCase().replace("_","-")%>"><%=sr.getStatus()%></span>
                            </div>
                            <div class="card-body">
                                <div class="info-row"><span class="info-label">Customer</span><span class="info-value"><%=sr.getCustomerName()%></span></div>
                                <div class="info-row"><span class="info-label">Contract</span>
                                    <span class="info-value">
                                        <a href="<%=ctx%>/supportContracts?action=detail&id=<%=sr.getContractId()%>" style="color:var(--primary);text-decoration:none"><%=sr.getContractCode()%></a>
                                        <span class="badge badge-<%=sr.getContractType()%>" style="margin-left:4px;font-size:.65rem"><%=sr.getContractType()%></span>
                                    </span>
                                </div>
                                <div class="info-row"><span class="info-label">Priority</span><span class="info-value"><span class="badge badge-<%=sr.getPriority().toLowerCase()%>"><%=sr.getPriority()%></span></span></div>
                                <div class="info-row"><span class="info-label">Created</span><span class="info-value" style="color:var(--muted)"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().substring(0,16):""%></span></div>

                                <div style="margin-top:14px">
                                    <div style="font-size:.75rem;font-weight:600;color:var(--muted);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px">Title</div>
                                    <div style="font-weight:600;font-size:.88rem;color:var(--text);margin-bottom:12px"><%=sr.getTitle()%></div>
                                    <div style="font-size:.75rem;font-weight:600;color:var(--muted);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px">Description</div>
                                    <div class="desc-box"><%=sr.getDescription().replace("\n","<br>")%></div>
                                </div>

                                <%if(sr.getRejectReason()!=null&&!sr.getRejectReason().isEmpty()){%>
                                <div style="margin-top:14px;padding:12px 14px;background:#fef2f2;border-radius:8px;border:1px solid #fecaca">
                                    <div style="font-size:.75rem;font-weight:700;color:#991b1b;margin-bottom:4px"><i class="fas fa-times-circle"></i> Rejection Reason</div>
                                    <div style="font-size:.8rem;color:#991b1b"><%=sr.getRejectReason()%></div>
                                </div>
                                <%}%>
                            </div>
                        </div>

                        <%-- Equipment --%>
                        <div class="card">
                            <div class="card-hd"><i class="fas fa-cogs" style="color:var(--primary)"></i><h3>Equipment (<%=equips.size()%>)</h3></div>
                            <table>
                                <thead><tr><th>#</th><th>Equipment</th><th>Serial</th><th>Source</th><th>Issue Description</th></tr></thead>
                                <tbody>
                                    <%if(equips.isEmpty()){%>
                                    <tr><td colspan="5" style="text-align:center;padding:20px;color:var(--muted)">No equipment</td></tr>
                                    <%}else{int i=1;for(ServiceRequestEquipment e:equips){%>
                                    <tr>
                                        <td style="color:var(--muted)"><%=i++%></td>
                                        <td style="font-weight:600"><%=e.getDisplayName()%></td>
                                        <td style="color:var(--muted);font-size:.75rem"><%=e.getDisplaySerial()%></td>
                                        <td><span style="font-size:.7rem;padding:2px 8px;border-radius:20px;background:#f1f5f9;color:#475569;font-weight:600"><%=e.getSource()%></span></td>
                                        <td style="color:var(--muted)"><%=e.getIssueDescription()!=null?e.getIssueDescription():"-"%></td>
                                    </tr>
                                    <%}}%>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <%-- Right: Timeline --%>
                    <div>
                        <div class="card">
                            <div class="card-hd"><i class="fas fa-stream" style="color:var(--primary)"></i><h3>Progress Timeline</h3></div>
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
                                            <div class="tl-title">Rejected</div>
                                            <div class="tl-sub">By <%=sr.getReviewedByName()!=null?sr.getReviewedByName():""%> · <%=sr.getReviewedAt()!=null?sr.getReviewedAt().toString().substring(0,16):""%></div>
                                        </div>
                                    </div>
                                    <%}else if(isCancelled){%>
                                    <div class="tl-item">
                                        <div class="tl-dot rejected"><i class="fas fa-ban"></i></div>
                                        <div class="tl-line"></div>
                                        <div class="tl-content">
                                            <div class="tl-title">Cancelled</div>
                                            <div class="tl-sub">Request was cancelled</div>
                                        </div>
                                    </div>
                                    <%}else{%>
                                    <div class="tl-item">
                                        <div class="tl-dot <%=isApproved?"done":"pending"%>"><i class="fas fa-<%=isApproved?"check":"clock"%>"></i></div>
                                        <div class="tl-line"></div>
                                        <div class="tl-content">
                                            <div class="tl-title"><%=isApproved?"Approved":"Awaiting Approval"%></div>
                                            <%if(isApproved&&sr.getReviewedByName()!=null){%>
                                            <div class="tl-sub">By <%=sr.getReviewedByName()%> · <%=sr.getReviewedAt()!=null?sr.getReviewedAt().toString().substring(0,16):""%></div>
                                            <%}%>
                                        </div>
                                    </div>
                                    <div class="tl-item">
                                        <div class="tl-dot <%=isInProgress?"active":isCompleted?"done":"pending"%>"><i class="fas fa-<%=isCompleted?"check":"wrench"%>"></i></div>
                                        <div class="tl-line"></div>
                                        <div class="tl-content">
                                            <div class="tl-title"><%=isInProgress?"In Progress":isCompleted?"Completed":"Pending Assignment"%></div>
                                            <%if(sr.getAssignedToName()!=null){%>
                                            <div class="tl-sub">Technician: <%=sr.getAssignedToName()%></div>
                                            <%}%>
                                        </div>
                                    </div>
                                    <div class="tl-item">
                                        <div class="tl-dot <%=isCompleted?"done":"pending"%>"><i class="fas fa-<%=isCompleted?"check-double":"flag-checkered"%>"></i></div>
                                        <div class="tl-content">
                                            <div class="tl-title"><%=isCompleted?"Completed":"Not Yet Completed"%></div>
                                            <%if(isCompleted&&sr.getCompletedAt()!=null){%>
                                            <div class="tl-sub"><%=sr.getCompletedAt().toString().substring(0,16)%></div>
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
        </div>
    </body></html>
