<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*,java.math.BigDecimal" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"TECHNICIAN".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();

    WorkTask       task       = (WorkTask)       request.getAttribute("task");
    ServiceRequest sr         = (ServiceRequest) request.getAttribute("sr");
    RepairReport   report     = (RepairReport)   request.getAttribute("report");

    @SuppressWarnings("unchecked")
    List<PartType> availableParts = (List<PartType>) request.getAttribute("availableParts");
    if (availableParts == null) availableParts = new ArrayList<>();

    @SuppressWarnings("unchecked")
    List<WorkTask> allTasks = (List<WorkTask>) request.getAttribute("allTasks");
    if (allTasks == null) allTasks = new ArrayList<>();

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");

    boolean isWarranty   = sr != null && "WARRANTY".equals(sr.getContractType());
    boolean canEdit      = report == null || "DRAFT".equals(report.getStatus());
    boolean isSubmitted  = report != null && "SUBMITTED".equals(report.getStatus());
    boolean taskAssigned = "Assigned".equals(task.getStatus());
    boolean taskProgress = "In Progress".equals(task.getStatus());
    boolean taskDone     = "Completed".equals(task.getStatus());

    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "T";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Task Detail – Technician</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --sb-bg:#1e1b4b;
                --sb-border:rgba(255,255,255,0.08);
                --sb-text:rgba(255,255,255,0.45);
                --sb-accent:#818cf8;
                --sb-accent-2:#a5b4fc;
                --sb-item-on:rgba(129,140,248,0.2);
                --sb-width:252px;
                --bg:#f3f4f9;
                --bg-card:#fff;
                --bg-topbar:#fff;
                --border-light:#e8ecf5;
                --border-light2:#f0f2fb;
                --text-h:#1e1b4b;
                --text-b:#374151;
                --text-m:#6b7280;
                --text-s:#9ca3af;
                --primary:#4f46e5;
                --primary-2:#6366f1;
                --primary-light:#ede9fe;
                --green:#16a34a;
                --red:#dc2626;
                --amber:#d97706;
                --blue:#2563eb;
                --teal:#0d9488;
                --purple:#7c3aed;
                --orange:#ea580c;
            }
            *,*::before,*::after{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            body{
                font-family:'Sora',sans-serif;
                background:var(--bg);
                color:var(--text-b);
                min-height:100vh;
                display:flex
            }
            ::-webkit-scrollbar{
                width:4px
            }
            ::-webkit-scrollbar-thumb{
                background:rgba(79,70,229,.3);
                border-radius:4px
            }

            /* SIDEBAR */
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
                box-shadow:4px 0 24px rgba(0,0,0,0.15)
            }
            .sb-brand{
                padding:20px 16px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid var(--sb-border)
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
                flex-shrink:0
            }
            .sb-name{
                color:#fff;
                font-size:1.05rem;
                font-weight:800
            }
            .sb-role{
                display:inline-flex;
                background:rgba(13,148,136,.2);
                border:1px solid rgba(13,148,136,.35);
                color:#5eead4;
                font-size:.6rem;
                font-weight:700;
                letter-spacing:1px;
                text-transform:uppercase;
                padding:2px 8px;
                border-radius:20px;
                margin-top:3px
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
                margin:14px 0 5px
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
                border-left:2px solid transparent
            }
            .sb-item i{
                width:28px;
                height:28px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.78rem;
                border-radius:8px;
                background:rgba(255,255,255,.06);
                flex-shrink:0
            }
            .sb-item.on{
                color:#fff;
                background:var(--sb-item-on);
                border-left-color:var(--sb-accent)
            }
            .sb-item.on i{
                background:rgba(129,140,248,.3);
                color:var(--sb-accent-2)
            }
            .sb-item:hover:not(.on){
                color:rgba(255,255,255,.78);
                background:rgba(255,255,255,.06)
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
                background:rgba(255,255,255,.07);
                border:1px solid rgba(255,255,255,.1);
                margin-bottom:5px;
                text-decoration:none;
                transition:all .18s
            }
            .sb-user:hover{
                background:rgba(129,140,248,.18);
                border-color:rgba(129,140,248,.3)
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
                overflow:hidden
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
                color:rgba(255,255,255,.35);
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
                color:rgba(255,255,255,.3);
                text-decoration:none;
                font-size:.78rem;
                transition:all .18s
            }
            .sb-logout:hover{
                color:#fca5a5;
                background:rgba(239,68,68,.1)
            }

            /* MAIN */
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
                box-shadow:0 1px 6px rgba(0,0,0,.06)
            }
            .topbar-title{
                font-size:1.2rem;
                font-weight:800;
                color:var(--text-h);
                letter-spacing:-.3px;
                display:flex;
                align-items:center;
                gap:9px
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

            /* GRID */
            .layout-grid{
                display:grid;
                grid-template-columns:7fr 5fr;
                gap:20px;
                align-items:start
            }
            .col-right{
                position:sticky;
                top:88px
            }
            @media(max-width:900px){
                .layout-grid{
                    grid-template-columns:1fr
                }
                .col-right{
                    position:static
                }
            }

            /* ALERT */
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
            .alert{
                display:flex;
                align-items:center;
                gap:12px;
                padding:12px 18px;
                border-radius:12px;
                margin-bottom:20px;
                font-size:.82rem
            }
            .alert-success{
                background:#d1fae5;
                border:1px solid #a7f3d0;
                color:#065f46
            }
            .alert-error  {
                background:#fee2e2;
                border:1px solid #fca5a5;
                color:#991b1b
            }

            /* CARD */
            .card{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                margin-bottom:18px;
                box-shadow:0 1px 6px rgba(0,0,0,.05);
                animation:cardIn .45s ease both
            }
            .card-hd{
                display:flex;
                align-items:center;
                gap:10px;
                padding:14px 18px;
                border-bottom:1px solid var(--border-light2);
                background:#fafbff
            }
            .card-hd-icon{
                width:30px;
                height:30px;
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.8rem;
                flex-shrink:0
            }
            .card-hd-title{
                font-size:.88rem;
                font-weight:700;
                color:var(--text-h)
            }
            .card-hd-badge{
                margin-left:auto;
                display:flex;
                align-items:center;
                gap:6px
            }
            .card-body{
                padding:20px
            }

            /* INFO GRID */
            .info-grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:16px
            }
            .info-item label{
                font-size:.67rem;
                font-weight:700;
                color:var(--text-s);
                text-transform:uppercase;
                letter-spacing:1px;
                display:block;
                margin-bottom:5px
            }
            .info-item .val{
                font-size:.85rem;
                color:var(--text-b);
                font-weight:500;
                line-height:1.5
            }
            .info-item .val.mono{
                font-family:'Courier New',monospace;
                color:var(--primary-2);
                font-weight:700
            }
            .desc-box{
                background:#fafbff;
                border:1px solid var(--border-light);
                border-left:3px solid var(--primary-2);
                border-radius:12px;
                padding:14px 16px;
                font-size:.83rem;
                color:var(--text-b);
                line-height:1.7;
                white-space:pre-wrap
            }

            /* BADGES */
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700
            }
            .b-assigned  {
                background:#fef3c7;
                color:#92400e
            }
            .b-progress  {
                background:#dbeafe;
                color:#1e40af
            }
            .b-completed {
                background:#d1fae5;
                color:#065f46
            }
            .b-cancelled {
                background:#f3f4f6;
                color:#6b7280
            }
            .b-warranty  {
                background:#d1fae5;
                color:#065f46
            }
            .b-maintenance{
                background:#dbeafe;
                color:#1e40af
            }
            .b-high{
                background:#ffedd5;
                color:#9a3412
            }
            .b-urgent{
                background:#fee2e2;
                color:#991b1b
            }
            .b-medium{
                background:#fef3c7;
                color:#92400e
            }
            .b-low{
                background:#dcfce7;
                color:#166534
            }
            .b-draft{
                background:#fef3c7;
                color:#92400e
            }
            .b-submitted{
                background:#d1fae5;
                color:#065f46
            }
            .ct-badge{
                display:inline-block;
                padding:2px 7px;
                border-radius:5px;
                font-size:.67rem;
                font-weight:700
            }
            .ct-wr{
                background:#d1fae5;
                color:#065f46
            }
            .ct-mt{
                background:#dbeafe;
                color:#1e40af
            }

            /* TABLE */
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
                border-bottom:1px solid var(--border-light2)
            }
            td{
                padding:10px 16px;
                border-bottom:1px solid var(--border-light2);
                vertical-align:middle
            }
            tr:last-child td{
                border-bottom:none
            }
            .td-muted{
                color:var(--text-s);
                font-size:.75rem
            }

            /* FORM */
            .form-row{
                margin-bottom:14px
            }
            .form-row label{
                display:block;
                font-size:.72rem;
                font-weight:700;
                color:var(--text-s);
                text-transform:uppercase;
                letter-spacing:.8px;
                margin-bottom:6px
            }
            .form-row input,.form-row textarea,.form-row select{
                width:100%;
                padding:10px 13px;
                border:1.5px solid var(--border-light);
                border-radius:9px;
                font-size:.83rem;
                font-family:'Sora',sans-serif;
                color:var(--text-b);
                background:#fff;
                outline:none;
                resize:vertical;
                transition:all .2s
            }
            .form-row input:focus,.form-row textarea:focus,.form-row select:focus{
                border-color:rgba(79,70,229,.4);
                background:#faf9ff;
                box-shadow:0 0 0 3px rgba(79,70,229,.07)
            }
            .form-row-2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:12px;
                margin-bottom:14px
            }

            /* PARTS ROW */
            .parts-list{
                display:flex;
                flex-direction:column;
                gap:8px
            }
            .part-row{
                display:grid;
                grid-template-columns:1fr auto auto auto;
                gap:8px;
                align-items:center;
                background:#fafbff;
                border:1px solid var(--border-light);
                border-radius:10px;
                padding:10px 12px
            }
            .part-row select,.part-row input{
                padding:6px 10px;
                border:1.5px solid var(--border-light);
                border-radius:7px;
                font-size:.8rem;
                font-family:'Sora',sans-serif;
                background:#fff;
                outline:none
            }
            .part-row select:focus,.part-row input:focus{
                border-color:rgba(79,70,229,.4);
                background:#faf9ff
            }
            .part-row .stock-info{
                font-size:.68rem;
                color:var(--text-s);
                white-space:nowrap
            }
            .part-row .total-cell{
                font-size:.8rem;
                font-weight:700;
                color:var(--primary-2);
                min-width:80px;
                text-align:right
            }
            .btn-rm{
                width:28px;
                height:28px;
                border-radius:7px;
                background:#fee2e2;
                border:none;
                color:var(--red);
                cursor:pointer;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.7rem
            }
            .btn-rm:hover{
                background:#fca5a5
            }

            /* WARRANTY NOTICE */
            .warranty-notice{
                background:linear-gradient(135deg,#d1fae5,#ecfdf5);
                border:1.5px solid #a7f3d0;
                border-radius:12px;
                padding:14px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                margin-bottom:14px
            }
            .warranty-notice i{
                color:var(--green);
                font-size:1.1rem;
                flex-shrink:0
            }
            .warranty-notice-text{
                font-size:.8rem;
                color:#065f46;
                line-height:1.5
            }
            .warranty-notice-text strong{
                font-weight:700
            }

            /* COST SUMMARY */
            .cost-summary{
                background:#fafbff;
                border:1px solid var(--border-light);
                border-radius:12px;
                padding:14px 16px
            }
            .cost-row{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:5px 0;
                font-size:.82rem;
                color:var(--text-m)
            }
            .cost-row.total{
                border-top:2px solid var(--border-light);
                margin-top:8px;
                padding-top:10px;
                font-size:.92rem;
                font-weight:700;
                color:var(--text-h)
            }
            .cost-row.free{
                color:var(--green)
            }
            .cost-val{
                font-weight:600;
                color:var(--text-h)
            }

            /* BTNS */
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
                transition:all .2s
            }
            .btn-primary{
                background:var(--primary);
                color:#fff;
                box-shadow:0 3px 10px rgba(79,70,229,.28)
            }
            .btn-primary:hover{
                background:#4338ca;
                transform:translateY(-1px)
            }
            .btn-success{
                background:var(--green);
                color:#fff;
                box-shadow:0 3px 10px rgba(22,163,74,.28)
            }
            .btn-success:hover{
                background:#15803d;
                transform:translateY(-1px)
            }
            .btn-warning{
                background:var(--amber);
                color:#fff;
                box-shadow:0 3px 10px rgba(217,119,6,.28)
            }
            .btn-warning:hover{
                background:#b45309;
                transform:translateY(-1px)
            }
            .btn-secondary{
                background:#fff;
                color:var(--text-m);
                border:1.5px solid var(--border-light)
            }
            .btn-secondary:hover{
                background:#f3f4f6;
                color:var(--text-b)
            }
            .btn-full{
                width:100%;
                justify-content:center
            }
            .action-bar{
                display:flex;
                gap:10px;
                flex-wrap:wrap;
                margin-top:4px
            }

            /* SUBMITTED READ-ONLY */
            .submitted-badge{
                display:inline-flex;
                align-items:center;
                gap:6px;
                background:#d1fae5;
                border:1.5px solid #a7f3d0;
                color:#065f46;
                font-size:.8rem;
                font-weight:700;
                padding:8px 14px;
                border-radius:10px
            }
            .co-tech-item{
                display:flex;
                align-items:center;
                justify-content:space-between;
                padding:8px 12px;
                border-radius:10px;
                background:#fafbff;
                border:1px solid var(--border-light);
                margin-bottom:6px;
                font-size:.8rem
            }
            .co-tech-name{
                font-weight:600;
                color:var(--text-h)
            }
            .co-tech-status{
                font-size:.68rem
            }
        </style>
    </head>
    <body>

        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-bolt"></i></div>
                <div><div class="sb-name">DRSMS</div><div class="sb-role">Technician</div></div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Workspace</div>
                <a href="<%=ctx%>/techTasks"   class="sb-item on"><i class="fas fa-tasks"></i> My Tasks</a>
                <a href="<%=ctx%>/techReports" class="sb-item"><i class="fas fa-file-medical-alt"></i> My Reports</a>
            </nav>
            <div class="sb-foot">
                <a href="<%=ctx%>/profile" class="sb-user">
                    <div class="sb-ava"><%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%>
                        <img src="<%=ctx%><%=me.getAvatarUrl()%>" alt=""><%}else{%><%=initials%><%}%></div>
                    <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Technician</div></div>
                </a>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
            </div>
        </aside>

        <main class="main">
            <div class="topbar">
                <div>
                    <div class="topbar-title"><i class="fas fa-tools"></i> Task Detail</div>
                    <div class="topbar-sub">Task #<%=task.getId()%>
                        <%if(sr!=null){%> · <%=sr.getRequestCode()%><%}%>
                    </div>
                </div>
                <a href="<%=ctx%>/techTasks" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Tasks
                </a>
            </div>

            <div class="content">
                <%if(flashOk!=null){%><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=flashOk%></div><%}%>
                <%if(flashErr!=null){%><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div><%}%>

                <div class="layout-grid">

                    <%-- ══ LEFT ══ --%>
                    <div class="col-left">

                        <%-- Service Request Info --%>
                        <%if(sr != null){
                            String bSt="b-assigned";
                            if("IN_PROGRESS".equals(sr.getStatus())) bSt="b-progress";
                            else if("COMPLETED".equals(sr.getStatus())) bSt="b-completed";
                            String bPr="b-medium";
                            if("HIGH".equals(sr.getPriority())) bPr="b-high";
                            else if("URGENT".equals(sr.getPriority())) bPr="b-urgent";
                            else if("LOW".equals(sr.getPriority())) bPr="b-low";
                        %>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:var(--primary-light);color:var(--primary-2)">
                                    <i class="fas fa-file-alt"></i>
                                </div>
                                <div class="card-hd-title"><%=sr.getRequestCode()%></div>
                                <div class="card-hd-badge">
                                    <span class="b <%=bSt%>"><%=sr.getStatusLabel()%></span>
                                    <span class="b <%=bPr%>"><%=sr.getPriority()%></span>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="info-grid">
                                    <div class="info-item">
                                        <label>Customer</label>
                                        <div class="val"><%=sr.getCustomerName()%></div>
                                    </div>
                                    <div class="info-item">
                                        <label>Contract</label>
                                        <div class="val" style="display:flex;align-items:center;gap:7px">
                                            <span class="val mono"><%=sr.getContractCode()%></span>
                                            <span class="ct-badge <%=isWarranty?"ct-wr":"ct-mt"%>">
                                                <%=isWarranty?"WR":"MT"%>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="info-item" style="grid-column:1/-1">
                                        <label>Title</label>
                                        <div class="val"><%=sr.getTitle()%></div>
                                    </div>
                                    <div class="info-item" style="grid-column:1/-1">
                                        <label>Description</label>
                                        <div class="desc-box"><%=sr.getDescription()%></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- Equipment list --%>
                        <%if(sr.getEquipmentList()!=null&&!sr.getEquipmentList().isEmpty()){%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:#e0f2fe;color:#0284c7">
                                    <i class="fas fa-desktop"></i>
                                </div>
                                <div class="card-hd-title">Equipment to Repair
                                    <span style="color:var(--text-s);font-weight:400"> (<%=sr.getEquipmentList().size()%>)</span>
                                </div>
                            </div>
                            <table>
                                <thead>
                                    <tr><th>#</th><th>Name</th><th>Serial</th><th>Source</th><th>Issue</th></tr>
                                </thead>
                                <tbody>
                                    <%int ei=1;for(ServiceRequestEquipment e:sr.getEquipmentList()){%>
                                    <tr>
                                        <td class="td-muted"><%=ei++%></td>
                                        <td style="font-weight:600;color:var(--text-h)"><%=e.getDisplayName()!=null?e.getDisplayName():"-"%></td>
                                        <td style="font-family:'Courier New',monospace;font-size:.78rem"><%=e.getDisplaySerial()!=null?e.getDisplaySerial():"-"%></td>
                                        <td><span style="background:var(--primary-light);color:var(--primary-2);padding:2px 8px;border-radius:20px;font-size:.67rem;font-weight:700"><%=e.getSource()!=null?e.getSource():"-"%></span></td>
                                        <td class="td-muted"><%=e.getIssueDescription()!=null?e.getIssueDescription():"-"%></td>
                                    </tr>
                                    <%}%>
                                </tbody>
                            </table>
                        </div>
                        <%}%>
                        <%}%>

                        <%-- Task Start Button --%>
                        <%if(taskAssigned){%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:#fef3c7;color:var(--amber)">
                                    <i class="fas fa-play"></i>
                                </div>
                                <div class="card-hd-title">Start Working</div>
                            </div>
                            <div class="card-body">
                                <p style="font-size:.83rem;color:var(--text-m);margin-bottom:14px">
                                    Click below to mark this task as <strong>In Progress</strong> and begin your repair work.
                                </p>
                                <form method="post" action="<%=ctx%>/techTasks">
                                    <input type="hidden" name="action" value="startTask">
                                    <input type="hidden" name="taskId" value="<%=task.getId()%>">
                                    <button type="submit" class="btn btn-warning">
                                        <i class="fas fa-play"></i> Start Task
                                    </button>
                                </form>
                            </div>
                        </div>
                        <%}%>

                        <%-- Repair Report Form --%>
                        <%if(!taskAssigned){%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:#dbeafe;color:var(--blue)">
                                    <i class="fas fa-file-medical-alt"></i>
                                </div>
                                <div class="card-hd-title">Repair Report</div>
                                <div class="card-hd-badge">
                                    <%if(report!=null){%>
                                    <span class="b <%="SUBMITTED".equals(report.getStatus())?"b-submitted":"b-draft"%>">
                                        <%=report.getStatusLabel()%>
                                    </span>
                                    <%if(report.getReportCode()!=null){%>
                                    <span style="font-family:'Courier New',monospace;font-size:.72rem;color:var(--text-s)">
                                        <%=report.getReportCode()%>
                                    </span>
                                    <%}%>
                                    <%}%>
                                </div>
                            </div>
                            <div class="card-body">

                                <%if(isSubmitted){%>
                                <%-- READ-ONLY VIEW --%>
                                <div class="submitted-badge" style="margin-bottom:16px">
                                    <i class="fas fa-check-circle"></i> Report submitted — no further edits allowed
                                </div>
                                <div class="form-row">
                                    <label>Diagnosis</label>
                                    <div class="desc-box"><%=report.getDiagnosis()%></div>
                                </div>
                                <div class="form-row">
                                    <label>Work Done</label>
                                    <div class="desc-box"><%=report.getWorkDone()%></div>
                                </div>
                                <div class="form-row">
                                    <label>Labor Cost</label>
                                    <div class="val" style="font-size:.92rem;font-weight:700;color:var(--primary-2)">
                                        <%=String.format("%,.0f", report.getLaborCost()!=null?report.getLaborCost().doubleValue():0)%> VND
                                    </div>
                                </div>
                                <%if(report.getParts()!=null&&!report.getParts().isEmpty()){%>
                                <div class="form-row">
                                    <label>Parts Used</label>
                                    <table>
                                        <thead><tr><th>Part</th><th>Qty</th><th>Unit Price</th><th>Total</th></tr></thead>
                                        <tbody>
                                            <%for(RepairReportPart p : report.getParts()){%>
                                            <tr>
                                                <td style="font-weight:600"><%=p.getPartName()%></td>
                                                <td class="td-muted"><%=p.getQuantity()%></td>
                                                <td class="td-muted"><%=String.format("%,.0f",p.getUnitPrice().doubleValue())%></td>
                                                <td style="font-weight:600;color:var(--primary-2)"><%=String.format("%,.0f",p.getTotalPrice().doubleValue())%></td>
                                            </tr>
                                            <%}%>
                                        </tbody>
                                    </table>
                                </div>
                                <%}%>

                                <%}else{%>
                                <%-- EDITABLE FORM --%>

                                <%if(isWarranty){%>
                                <div class="warranty-notice">
                                    <i class="fas fa-shield-alt"></i>
                                    <div class="warranty-notice-text">
                                        <strong>WARRANTY Contract</strong> — Parts are provided <strong>free of charge</strong>.
                                        You will select parts from inventory but the customer will only be billed for <strong>labor costs</strong>.
                                    </div>
                                </div>
                                <%}else{%>
                                <div style="background:#fff7ed;border:1.5px solid #fed7aa;border-radius:12px;padding:12px 16px;margin-bottom:14px;font-size:.8rem;color:#9a3412">
                                    <i class="fas fa-info-circle" style="margin-right:6px"></i>
                                    <strong>MAINTENANCE Contract</strong> — Customer will be billed for both <strong>parts + labor</strong>.
                                </div>
                                <%}%>

                                <form method="post" action="<%=ctx%>/techTasks" id="reportForm">
                                    <input type="hidden" name="action" value="saveReport">
                                    <input type="hidden" name="taskId" value="<%=task.getId()%>">

                                    <div class="form-row">
                                        <label>Diagnosis <span style="color:var(--red)">*</span></label>
                                        <textarea name="diagnosis" rows="3" required
                                                  placeholder="Describe the problem found…"><%=report!=null&&report.getDiagnosis()!=null?report.getDiagnosis():""%></textarea>
                                    </div>

                                    <div class="form-row">
                                        <label>Work Done <span style="color:var(--red)">*</span></label>
                                        <textarea name="workDone" rows="3" required
                                                  placeholder="Describe what was repaired/replaced…"><%=report!=null&&report.getWorkDone()!=null?report.getWorkDone():""%></textarea>
                                    </div>

                                    <div class="form-row">
                                        <label>Your Labor Cost (VND) <span style="color:var(--red)">*</span></label>
                                        <input type="number" name="laborCost" min="0" step="1000"
                                               placeholder="e.g. 500000"
                                               value="<%=report!=null&&report.getLaborCost()!=null?report.getLaborCost().toPlainString():""%>">
                                    </div>

                                    <%-- Parts Section --%>
                                    <div class="form-row">
                                        <label style="display:flex;align-items:center;justify-content:space-between">
                                            <span>Parts Used from Inventory</span>
                                            <button type="button" class="btn btn-secondary"
                                                    style="padding:4px 10px;font-size:.72rem" onclick="addPartRow()">
                                                <i class="fas fa-plus"></i> Add Part
                                            </button>
                                        </label>
                                        <!-- DEBUG: availableParts size = <%=availableParts.size()%> -->
                                        <div class="parts-list" id="partsList">
                                            <%if(report!=null&&report.getParts()!=null){
                                    for(RepairReportPart p : report.getParts()){%>
                                            <div class="part-row" data-price="<%=p.getUnitPrice().doubleValue()%>">
                                                <select name="partTypeId" onchange="updatePartRow(this)">
                                                    <option value="">Select part…</option>
                                                    <%for(PartType pt : availableParts){%>
                                                    <option value="<%=pt.getId()%>"
                                                            data-price="<%=pt.getUnitPrice()%>"
                                                            data-stock="<%=pt.getAvailableUnits()%>"
                                                            <%=pt.getId()==p.getPartTypeId()?"selected":""%>>
                                                        <%=pt.getName()%> (<%=pt.getAvailableUnits()%> avail)
                                                    </option>
                                                    <%}%>
                                                </select>
                                                <input type="number" name="partQty" min="1" value="<%=p.getQuantity()%>"
                                                       style="width:70px" onchange="updateRowTotal(this)">
                                                <span class="total-cell"><%=String.format("%,.0f",p.getTotalPrice().doubleValue())%></span>
                                                <button type="button" class="btn-rm" onclick="removePartRow(this)">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            </div>
                                            <%}}%>
                                        </div>
                                        <p style="font-size:.72rem;color:var(--text-s);margin-top:6px">
                                            <i class="fas fa-info-circle"></i>
                                            Only parts with available stock are shown. Stock will be deducted upon submission.
                                        </p>
                                    </div>

                                    <%-- Live Cost Summary --%>
                                    <div class="cost-summary" id="costSummary">
                                        <%if(isWarranty){%>
                                        <div class="cost-row free"><span>Parts cost</span><span class="cost-val">FREE (WARRANTY)</span></div>
                                        <%}else{%>
                                        <div class="cost-row"><span>Parts subtotal</span><span class="cost-val" id="partsSubtotal">0</span></div>
                                        <%}%>
                                        <div class="cost-row"><span>Your labor</span><span class="cost-val" id="laborDisplay">0</span></div>
                                        <div class="cost-row"><span>VAT (10%)</span><span class="cost-val" id="vatDisplay">0</span></div>
                                        <div class="cost-row total"><span>Estimated Total</span><span id="grandTotal">0</span></div>
                                        <%if(isWarranty){%>
                                        <p style="font-size:.67rem;color:var(--green);margin-top:8px">
                                            * Parts cost waived under warranty. Customer pays labor + VAT only.
                                        </p>
                                        <%}%>
                                    </div>

                                    <div class="action-bar" style="margin-top:16px">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save"></i> Save Draft
                                        </button>
                                        <%if(report!=null){%>
                                        <button type="button" class="btn btn-success"
                                                onclick="confirmSubmit()">
                                            <i class="fas fa-paper-plane"></i> Submit Report
                                        </button>
                                        <%}%>
                                    </div>
                                </form>

                                <%-- Submit form --%>
                                <form method="post" action="<%=ctx%>/techTasks" id="submitForm" style="display:none">
                                    <input type="hidden" name="action" value="submitReport">
                                    <input type="hidden" name="taskId" value="<%=task.getId()%>">
                                </form>
                                <%}%>
                            </div>
                        </div>
                        <%}%>

                    </div><%-- end col-left --%>

                    <%-- ══ RIGHT ══ --%>
                    <div class="col-right">

                        <%-- Task Status Card --%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:#fef3c7;color:var(--amber)">
                                    <i class="fas fa-clipboard-check"></i>
                                </div>
                                <div class="card-hd-title">Task Status</div>
                            </div>
                            <div class="card-body">
                                <div class="info-grid">
                                    <div class="info-item">
                                        <label>Task #</label>
                                        <div class="val mono"><%=task.getId()%></div>
                                    </div>
                                    <div class="info-item">
                                        <label>Status</label>
                                        <div class="val">
                                            <%String ts2="b-assigned";
                                            if("In Progress".equals(task.getStatus())) ts2="b-progress";
                                            else if("Completed".equals(task.getStatus())) ts2="b-completed";
                                            else if("Cancelled".equals(task.getStatus())) ts2="b-cancelled";%>
                                            <span class="b <%=ts2%>"><%=task.getStatus()%></span>
                                        </div>
                                    </div>
                                    <div class="info-item">
                                        <label>Task Type</label>
                                        <div class="val"><%=task.getTaskType()%></div>
                                    </div>
                                    <div class="info-item">
                                        <label>Assigned At</label>
                                        <div class="val td-muted"><%=task.getCreatedAt()!=null?task.getCreatedAt().toString().replace("T"," ").substring(0,16):"—"%></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- Co-technicians on same SR --%>
                        <%if(allTasks.size()>1){%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:#ede9fe;color:var(--purple)">
                                    <i class="fas fa-users"></i>
                                </div>
                                <div class="card-hd-title">Team on this Request
                                    <span style="color:var(--text-s);font-weight:400"> (<%=allTasks.size()%>)</span>
                                </div>
                            </div>
                            <div class="card-body" style="padding:14px 16px">
                                <%for(WorkTask wt : allTasks){
                                    String wtCls="b-assigned";
                                    if("In Progress".equals(wt.getStatus())) wtCls="b-progress";
                                    else if("Completed".equals(wt.getStatus())) wtCls="b-completed";
                                    boolean isMe = wt.getTechnicianId()==me.getId();
                                %>
                                <div class="co-tech-item">
                                    <div>
                                        <div class="co-tech-name"><%=wt.getTechnicianName()!=null?wt.getTechnicianName():"Tech #"+wt.getTechnicianId()%>
                                            <%if(isMe){%><span style="font-size:.65rem;color:var(--primary-2);font-weight:700"> (you)</span><%}%>
                                        </div>
                                        <div class="td-muted">Task #<%=wt.getId()%></div>
                                    </div>
                                    <span class="b co-tech-status <%=wtCls%>"><%=wt.getStatus()%></span>
                                </div>
                                <%}%>
                                <p style="font-size:.72rem;color:var(--text-s);margin-top:8px;padding:0 2px">
                                    <i class="fas fa-info-circle"></i>
                                    Invoice is created only when <strong>all</strong> team members submit their reports.
                                </p>
                            </div>
                        </div>
                        <%}%>

                        <%-- Report history link --%>
                        <%if(report!=null){%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:#d1fae5;color:var(--green)">
                                    <i class="fas fa-file-invoice"></i>
                                </div>
                                <div class="card-hd-title">Report Info</div>
                            </div>
                            <div class="card-body">
                                <div class="info-grid">
                                    <div class="info-item">
                                        <label>Report Code</label>
                                        <div class="val mono"><%=report.getReportCode()%></div>
                                    </div>
                                    <div class="info-item">
                                        <label>Status</label>
                                        <div class="val">
                                            <span class="b <%="SUBMITTED".equals(report.getStatus())?"b-submitted":"b-draft"%>">
                                                <%=report.getStatusLabel()%>
                                            </span>
                                        </div>
                                    </div>
                                    <%if(report.getInvoiceId()!=null){%>
                                    <div class="info-item" style="grid-column:1/-1">
                                        <label>Invoice</label>
                                        <div class="val" style="color:var(--green)">
                                            <i class="fas fa-check-circle"></i> Invoice created and sent to customer
                                        </div>
                                    </div>
                                    <%}%>
                                </div>
                                <a href="<%=ctx%>/techReports?action=detail&id=<%=report.getId()%>"
                                   class="btn btn-secondary btn-full" style="margin-top:12px">
                                    <i class="fas fa-eye"></i> View Full Report
                                </a>
                            </div>
                        </div>
                        <%}%>

                    </div><%-- end col-right --%>

                </div>
            </div>
        </main>

        <%-- Submit Confirm Modal --%>
        <div id="confirmModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);
             backdrop-filter:blur(4px);z-index:1000;align-items:center;justify-content:center">
            <div style="background:#fff;border-radius:18px;padding:28px;width:100%;max-width:440px;
                 box-shadow:0 24px 60px rgba(0,0,0,.15)">
                <h3 style="font-size:.98rem;font-weight:700;color:var(--text-h);margin-bottom:12px;
                    display:flex;align-items:center;gap:9px">
                    <i class="fas fa-paper-plane" style="color:var(--green)"></i> Submit Report
                </h3>
                <div style="font-size:.82rem;color:var(--text-m);line-height:1.65;margin-bottom:20px;
                     padding:12px 14px;background:#fafbff;border:1px solid var(--border-light);border-radius:10px">
                    Once submitted, <strong>you cannot edit this report</strong>.<br>
                    Parts will be deducted from inventory.<br>
                    <%if(allTasks.size()>1){%>
                    The invoice will be created <strong>after all technicians submit</strong>.
                    <%}else{%>
                    The invoice will be <strong>created immediately</strong> and sent to the customer.
                    <%}%>
                </div>
                <div style="display:flex;gap:10px;justify-content:flex-end">
                    <button class="btn btn-secondary" onclick="closeModal()">Cancel</button>
                    <button class="btn btn-success" onclick="document.getElementById('submitForm').submit()">
                        <i class="fas fa-check"></i> Confirm Submit
                    </button>
                </div>
            </div>
        </div>

        <script>
        // ── Part rows ──────────────────────────────────────────────────────
            const availableParts = [
            <%for(int pi=0;pi<availableParts.size();pi++){
                PartType pt = availableParts.get(pi);%>
                {id:<%=pt.getId()%>, name: "<%=pt.getName().replace("\"","\\\"")%>", price:<%=java.math.BigDecimal.valueOf(pt.getUnitPrice()).toPlainString()%>, stock:<%=pt.getAvailableUnits()%>},
            <%}%>
            ];

            const isWarranty = <%=isWarranty%>;

            function addPartRow() {
                const list = document.getElementById('partsList');
                const div = document.createElement('div');
                div.className = 'part-row';
                div.dataset.price = '0';

                // Tạo select element trực tiếp thay vì dùng innerHTML
                const sel = document.createElement('select');
                sel.name = 'partTypeId';
                sel.onchange = function () {
                    updatePartRow(this);
                };

                const defaultOpt = document.createElement('option');
                defaultOpt.value = '';
                defaultOpt.textContent = 'Select part…';
                sel.appendChild(defaultOpt);

                availableParts.forEach(p => {
                    if (p.stock > 0) {
                        const opt = document.createElement('option');
                        opt.value = p.id;
                        opt.dataset.price = p.price;
                        opt.dataset.stock = p.stock;
                        opt.textContent = p.name + ' (' + p.stock + ' avail)';
                        sel.appendChild(opt);
                    }
                });

                const qtyInput = document.createElement('input');
                qtyInput.type = 'number';
                qtyInput.name = 'partQty';
                qtyInput.min = '1';
                qtyInput.value = '1';
                qtyInput.style.width = '70px';
                qtyInput.onchange = function () {
                    updateRowTotal(this);
                };

                const totalSpan = document.createElement('span');
                totalSpan.className = 'total-cell';
                totalSpan.textContent = '0';

                const rmBtn = document.createElement('button');
                rmBtn.type = 'button';
                rmBtn.className = 'btn-rm';
                rmBtn.onclick = function () {
                    removePartRow(this);
                };
                rmBtn.innerHTML = '<i class="fas fa-times"></i>';

                div.appendChild(sel);
                div.appendChild(qtyInput);
                div.appendChild(totalSpan);
                div.appendChild(rmBtn);

                list.appendChild(div);
                recalcTotal();
            }

            function updatePartRow(sel) {
                const opt = sel.options[sel.selectedIndex];
                const price = opt.dataset.price || 0;
                const stock = opt.dataset.stock || 0;
                const row = sel.closest('.part-row');
                row.dataset.price = price;
                const qtyInput = row.querySelector('input[name="partQty"]');
                qtyInput.max = stock;
                updateRowTotal(qtyInput);
            }

            function updateRowTotal(qtyInput) {
                const row = qtyInput.closest('.part-row');
                const price = parseFloat(row.dataset.price) || 0;
                const qty = parseInt(qtyInput.value) || 0;
                const total = price * qty;
                row.querySelector('.total-cell').textContent = formatVND(total);
                recalcTotal();
            }

            function removePartRow(btn) {
                btn.closest('.part-row').remove();
                recalcTotal();
            }

            function recalcTotal() {
                let partsTotal = 0;
                document.querySelectorAll('.part-row').forEach(row => {
                    const price = parseFloat(row.dataset.price) || 0;
                    const qty = parseInt(row.querySelector('input[name="partQty"]')?.value) || 0;
                    partsTotal += price * qty;
                });
                const labor = parseFloat(document.querySelector('input[name="laborCost"]')?.value) || 0;
                const billableParts = isWarranty ? 0 : partsTotal;
                const sub = billableParts + labor;
                const vat = sub * 0.10;
                const grand = sub + vat;

                const el = id => document.getElementById(id);
                if (!isWarranty && el('partsSubtotal'))
                    el('partsSubtotal').textContent = formatVND(partsTotal);
                if (el('laborDisplay'))
                    el('laborDisplay').textContent = formatVND(labor);
                if (el('vatDisplay'))
                    el('vatDisplay').textContent = formatVND(vat);
                if (el('grandTotal'))
                    el('grandTotal').textContent = formatVND(grand);
            }

            function formatVND(n) {
                return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + ' VND';
            }

        // Bind labor cost input
            document.addEventListener('DOMContentLoaded', () => {
                const lc = document.querySelector('input[name="laborCost"]');
                if (lc)
                    lc.addEventListener('input', recalcTotal);
                recalcTotal();
            });

        // ── Modal ──────────────────────────────────────────────────────────
            function confirmSubmit() {
                document.getElementById('confirmModal').style.display = 'flex';
            }
            function closeModal() {
                document.getElementById('confirmModal').style.display = 'none';
            }
            document.getElementById('confirmModal')?.addEventListener('click', function (e) {
                if (e.target === this)
                    closeModal();
            });
        </script>
    </body>
</html>
