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
%><%!
    Object nvl(Object v,Object def){return v!=null?v:def;}
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Repair Requests - DRSMS</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root{
                --primary:#4f46e5;
                --sidebar:#0f172a;
                --bg:#f8fafc;
                --surface:#fff;
                --border:#e2e8f0;
                --text:#0f172a;
                --muted:#64748b;
                --success:#10b981;
                --warning:#f59e0b;
                --danger:#ef4444;
                --info:#3b82f6
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
                width:240px;
                min-height:100vh;
                background:var(--sidebar);
                display:flex;
                flex-direction:column;
                position:fixed
            }
            .sb-brand{
                padding:22px 18px 18px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid rgba(255,255,255,.07)
            }
            .sb-logo{
                width:34px;
                height:34px;
                background:var(--primary);
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem
            }
            .sb-name{
                color:#fff;
                font-size:1rem;
                font-weight:700
            }
            .sb-sub{
                color:rgba(255,255,255,.35);
                font-size:.68rem
            }
            .sb-nav{
                flex:1;
                padding:14px 10px
            }
            .sb-lbl{
                color:rgba(255,255,255,.28);
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.2px;
                padding:0 8px;
                margin:14px 0 5px
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:8px;
                margin-bottom:2px;
                color:rgba(255,255,255,.58);
                text-decoration:none;
                font-size:.855rem;
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
                width:17px;
                text-align:center;
                font-size:.83rem
            }
            .sb-foot{
                padding:14px 10px 18px;
                border-top:1px solid rgba(255,255,255,.07)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:9px;
                background:rgba(255,255,255,.05);
                margin-bottom:7px
            }
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                font-weight:700
            }
            .sb-uname{
                color:#fff;
                font-size:.82rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,.38);
                font-size:.7rem
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:8px 10px;
                border-radius:8px;
                color:rgba(255,255,255,.45);
                text-decoration:none;
                font-size:.82rem;
                transition:.15s
            }
            .sb-logout:hover{
                color:#f87171;
                background:rgba(248,113,113,.1)
            }
            .main{
                margin-left:240px;
                flex:1;
                padding:28px 32px
            }
            .pg-hd{
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                margin-bottom:20px
            }
            .pg-hd h1{
                font-size:1.3rem;
                font-weight:800;
                color:var(--text);
                display:flex;
                align-items:center;
                gap:9px
            }
            .pg-hd h1 i{
                color:var(--primary)
            }
            .pg-hd p{
                color:var(--muted);
                font-size:.85rem;
                margin-top:3px
            }
            .btn-p{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:10px 18px;
                border-radius:10px;
                background:var(--primary);
                color:#fff;
                text-decoration:none;
                font-size:.875rem;
                font-weight:600;
                transition:.15s;
                border:none;
                cursor:pointer;
                font-family:inherit
            }
            .btn-p:hover{
                background:#4338ca
            }
            .alert-ok{
                padding:10px 14px;
                background:#d1fae5;
                border:1px solid #a7f3d0;
                border-radius:9px;
                margin-bottom:14px;
                font-size:.875rem;
                color:#065f46;
                display:flex;
                align-items:center;
                gap:8px
            }
            .alert-err{
                padding:10px 14px;
                background:#fee2e2;
                border:1px solid #fca5a5;
                border-radius:9px;
                margin-bottom:14px;
                font-size:.875rem;
                color:#991b1b;
                display:flex;
                align-items:center;
                gap:8px
            }
            .stats{
                display:grid;
                grid-template-columns:repeat(4,1fr);
                gap:12px;
                margin-bottom:16px
            }
            .sm{
                background:var(--surface);
                border-radius:11px;
                padding:14px 16px;
                border:1px solid var(--border);
                display:flex;
                align-items:center;
                gap:10px
            }
            .sm-icon{
                width:38px;
                height:38px;
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.95rem;
                flex-shrink:0
            }
            .sm-val{
                font-size:1.55rem;
                font-weight:800;
                color:var(--text);
                line-height:1
            }
            .sm-lbl{
                font-size:.74rem;
                color:var(--muted);
                margin-top:2px
            }
            .filter-card{
                background:var(--surface);
                border-radius:11px;
                border:1px solid var(--border);
                padding:14px 18px;
                margin-bottom:14px
            }
            .filter-row{
                display:flex;
                gap:9px;
                flex-wrap:wrap;
                align-items:center
            }
            .f-sel,.f-date{
                padding:8px 11px;
                border:1px solid var(--border);
                border-radius:8px;
                font-size:.85rem;
                font-family:inherit;
                outline:none;
                background:white;
                color:var(--text)
            }
            .f-sel:focus,.f-date:focus{
                border-color:var(--primary)
            }
            .btn-f{
                padding:8px 14px;
                border-radius:8px;
                font-size:.85rem;
                font-weight:500;
                border:none;
                cursor:pointer;
                display:flex;
                align-items:center;
                gap:5px;
                font-family:inherit
            }
            .btn-f-blue{
                background:var(--info);
                color:#fff
            }
            .btn-f-gray{
                background:#94a3b8;
                color:#fff;
                text-decoration:none
            }
            .tbl-card{
                background:var(--surface);
                border-radius:13px;
                border:1px solid var(--border);
                overflow:hidden
            }
            table{
                width:100%;
                border-collapse:collapse;
                font-size:.83rem
            }
            thead tr{
                background:#f8fafc
            }
            th{
                padding:10px 14px;
                text-align:left;
                color:var(--muted);
                font-weight:600;
                font-size:.72rem;
                text-transform:uppercase;
                letter-spacing:.5px;
                border-bottom:1px solid var(--border)
            }
            td{
                padding:12px 14px;
                border-bottom:1px solid #f8fafc;
                vertical-align:middle
            }
            tr:last-child td{
                border-bottom:none
            }
            tr:hover td{
                background:#fafbff
            }
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.73rem;
                font-weight:600;
                white-space:nowrap
            }
            .b-pending{
                background:#fef3c7;
                color:#92400e
            }
            .b-approved{
                background:#d1fae5;
                color:#065f46
            }
            .b-rejected{
                background:#fee2e2;
                color:#991b1b
            }
            .b-inprogress{
                background:#dbeafe;
                color:#1e40af
            }
            .b-completed{
                background:#e0e7ff;
                color:#3730a3
            }
            .b-cancelled{
                background:#f3f4f6;
                color:#6b7280
            }
            .b-low{
                background:#f0fdf4;
                color:#166534
            }
            .b-medium{
                background:#fef9c3;
                color:#854d0e
            }
            .b-high{
                background:#fff7ed;
                color:#9a3412
            }
            .b-urgent{
                background:#fef2f2;
                color:#991b1b
            }
            .btn-view{
                padding:4px 10px;
                border-radius:6px;
                font-size:.77rem;
                font-weight:600;
                background:#e0e7ff;
                color:var(--primary);
                text-decoration:none;
                display:inline-flex;
                align-items:center;
                gap:4px
            }
            .btn-cancel{
                padding:4px 10px;
                border-radius:6px;
                font-size:.77rem;
                font-weight:600;
                background:#fee2e2;
                color:var(--danger);
                border:none;
                cursor:pointer;
                font-family:inherit
            }
            .empty{
                text-align:center;
                padding:44px;
                color:var(--muted);
                font-size:.84rem
            }
            .empty i{
                font-size:2.2rem;
                display:block;
                margin-bottom:10px;
                opacity:.35
            }
            .ct-tag{
                display:inline-block;
                padding:2px 7px;
                border-radius:4px;
                font-size:.73rem;
                font-weight:600
            }
            .sb-badge{
                background:#ef4444;
                color:#fff;
                font-size:.62rem;
                font-weight:700;
                padding:1px 6px;
                border-radius:10px;
                margin-left:auto
            }
        </style>
    </head><body>
        <aside class="sb">
            <div class="sb-brand"><div class="sb-logo"><i class="fas fa-bolt"></i></div><div><div class="sb-name">DRSMS System</div><div class="sb-sub">Customer</div></div></div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/customerDashboard"       class="sb-item"><i class="fas fa-home"></i> Home</a>
                <div class="sb-lbl">Services</div>
                <a href="<%=ctx%>/customerServiceRequests" class="sb-item on"><i class="fas fa-clipboard-list"></i> Repair Requests</a>
                <a href="<%=ctx%>/customerContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/customerEquipment"       class="sb-item"><i class="fas fa-desktop"></i> My Equipment</a>
                <div class="sb-lbl">Shop</div>
                <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item"><i class="fas fa-puzzle-piece"></i> Parts</a>
                <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Equipment</a>
                <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item"><i class="fas fa-shopping-cart"></i> Cart<%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%></a>
                <div class="sb-lbl">Finance</div>
                <a href="<%=ctx%>/customerInvoices"        class="sb-item"><i class="fas fa-receipt"></i> Invoices</a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/customerChat"            class="sb-item"><i class="fas fa-comment-dots"></i> Support Chat</a>
            </nav>
            <div class="sb-foot">
                <div class="sb-user"><div class="sb-ava"><%=me.getFullName().substring(0,1).toUpperCase()%></div><div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer</div></div></div>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </aside>

        <main class="main">
            <div class="pg-hd">
                <div><h1><i class="fas fa-clipboard-list"></i> Repair Requests</h1><p>Create and track your equipment repair requests</p></div>
                <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-p"><i class="fas fa-plus"></i> Create New Request</a>
            </div>

            <%if(flashOk!=null){%><div class="alert-ok"><i class="fas fa-check-circle"></i> <%=flashOk%></div><%}%>
            <%if(flashErr!=null){%><div class="alert-err"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div><%}%>

            <div class="stats">
                <div class="sm"><div class="sm-icon" style="background:#e0e7ff;color:var(--primary)"><i class="fas fa-list"></i></div><div><div class="sm-val"><%=totalSR%></div><div class="sm-lbl">Total Requests</div></div></div>
                <div class="sm"><div class="sm-icon" style="background:#fef3c7;color:var(--warning)"><i class="fas fa-clock"></i></div><div><div class="sm-val"><%=pendingCount%></div><div class="sm-lbl">Pending Approval</div></div></div>
                <div class="sm"><div class="sm-icon" style="background:#dbeafe;color:var(--info)"><i class="fas fa-spinner"></i></div><div><div class="sm-val"><%=activeCount%></div><div class="sm-lbl">In Progress</div></div></div>
                <div class="sm"><div class="sm-icon" style="background:#d1fae5;color:var(--success)"><i class="fas fa-check-circle"></i></div><div><div class="sm-val"><%=completedCount%></div><div class="sm-lbl">Completed</div></div></div>
            </div>

            <div class="filter-card">
                <form method="get" action="<%=ctx%>/customerServiceRequests">
                    <div class="filter-row">
                        <select class="f-sel" name="status">
                            <option value="" <%=filterStatus.isEmpty()?"selected":""%>>-- All Statuses --</option>
                            <option value="PENDING"     <%="PENDING".equals(filterStatus)?"selected":""%>>Pending Approval</option>
                            <option value="APPROVED"    <%="APPROVED".equals(filterStatus)?"selected":""%>>Approved</option>
                            <option value="REJECTED"    <%="REJECTED".equals(filterStatus)?"selected":""%>>Rejected</option>
                            <option value="IN_PROGRESS" <%="IN_PROGRESS".equals(filterStatus)?"selected":""%>>In Progress</option>
                            <option value="COMPLETED"   <%="COMPLETED".equals(filterStatus)?"selected":""%>>Completed</option>
                            <option value="CANCELLED"   <%="CANCELLED".equals(filterStatus)?"selected":""%>>Cancelled</option>
                        </select>
                        <select class="f-sel" name="priority">
                            <option value="" <%=filterPriority.isEmpty()?"selected":""%>>-- All Priorities --</option>
                            <option value="LOW"    <%="LOW".equals(filterPriority)?"selected":""%>>Low</option>
                            <option value="MEDIUM" <%="MEDIUM".equals(filterPriority)?"selected":""%>>Medium</option>
                            <option value="HIGH"   <%="HIGH".equals(filterPriority)?"selected":""%>>High</option>
                            <option value="URGENT" <%="URGENT".equals(filterPriority)?"selected":""%>>Urgent</option>
                        </select>
                        <input type="date" class="f-date" name="fromDate" value="<%=filterFrom%>">
                        <input type="date" class="f-date" name="toDate"   value="<%=filterTo%>">
                        <button type="submit" class="btn-f btn-f-blue"><i class="fas fa-search"></i> Filter</button>
                        <a href="<%=ctx%>/customerServiceRequests" class="btn-f btn-f-gray" style="text-decoration:none"><i class="fas fa-undo"></i> Reset</a>
                    </div>
                </form>
            </div>

            <div class="tbl-card">
                <%if(list.isEmpty()){%>
                <div class="empty"><i class="fas fa-clipboard"></i>No repair requests found.<br>
                    <a href="<%=ctx%>/customerServiceRequests?action=create" style="color:var(--primary);font-weight:600;display:inline-block;margin-top:7px">+ Create your first request</a>
                </div>
                <%}else{%>
                <table>
                    <thead><tr><th>Request Code</th><th>Title</th><th>Contract</th><th>Priority</th><th>Status</th><th>Technician</th><th>Created Date</th><th>Actions</th></tr></thead>
                    <tbody>
                        <%for(ServiceRequest sr:list){
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
                        %>
                        <tr>
                            <td><a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=sr.getId()%>" style="color:var(--primary);font-weight:700;font-family:monospace;font-size:.8rem"><%=sr.getRequestCode()%></a></td>
                            <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><%=sr.getTitle()%></td>
                            <td>
                                <div style="font-family:monospace;font-size:.8rem;font-weight:700"><%=sr.getContractCode()%></div>
                                <span class="ct-tag" style="background:<%="WARRANTY".equals(sr.getContractType())?"#d1fae5":"#dbeafe"%>;color:<%="WARRANTY".equals(sr.getContractType())?"#065f46":"#1e40af"%>">
                                    <%="WARRANTY".equals(sr.getContractType())?"Warranty":"Maintenance"%>
                                </span>
                            </td>
                            <td><span class="b <%=pc%>"><%=sr.getPriorityLabel()%></span></td>
                            <td><span class="b <%=sc%>"><%=sr.getStatusLabel()%></span></td>
                            <td style="font-size:.8rem;color:var(--muted)"><%=sr.getAssignedToName()!=null?sr.getAssignedToName():"—"%></td>
                            <td style="font-size:.79rem;color:var(--muted)"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toLocalDate():"—"%></td>
                            <td>
                                <div style="display:flex;gap:5px;align-items:center">
                                    <a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=sr.getId()%>" class="btn-view"><i class="fas fa-eye"></i> Detail</a>
                                    <%if("PENDING".equals(sr.getStatus())){%>
                                    <form method="post" action="<%=ctx%>/customerServiceRequests" style="display:inline" onsubmit="return confirm('Cancel this request?')">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="id" value="<%=sr.getId()%>">
                                        <button type="submit" class="btn-cancel"><i class="fas fa-times"></i> Cancel</button>
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
        </main>
    </body></html>
