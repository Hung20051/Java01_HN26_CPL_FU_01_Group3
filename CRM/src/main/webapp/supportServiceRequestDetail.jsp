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
    <title><%=sr.getRequestCode()%> - Service Request</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --navy:        #0b1437;
            --navy-2:      #0f1c4d;
            --navy-card:   #111a42;
            --navy-light:  #162050;
            --accent:      #4f7ef8;
            --accent-2:    #7c9ffa;
            --accent-glow: rgba(79,126,248,0.22);
            --green:       #34d399;
            --green-dim:   rgba(52,211,153,0.12);
            --amber:       #fbbf24;
            --amber-dim:   rgba(251,191,36,0.12);
            --danger:      #f87171;
            --danger-dim:  rgba(248,113,113,0.12);
            --purple:      #a78bfa;
            --purple-dim:  rgba(167,139,250,0.12);
            --info:        #38bdf8;
            --info-dim:    rgba(56,189,248,0.12);
            --text:        #ffffff;
            --text-2:      #c8d4f0;
            --muted:       #7a8ab8;
            --border:      rgba(255,255,255,0.07);
            --border-2:    rgba(255,255,255,0.04);
            --sb-width:    248px;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; }
        body {
            font-family: 'Sora', sans-serif;
            background: var(--navy);
            color: var(--text);
            min-height: 100vh;
            display: flex;
        }
        ::-webkit-scrollbar { width: 4px; }
        ::-webkit-scrollbar-track { background: var(--navy); }
        ::-webkit-scrollbar-thumb { background: rgba(79,126,248,0.4); border-radius: 4px; }

        /* ════════════════════ SIDEBAR ════════════════════ */
        .sb {
            width: var(--sb-width);
            min-height: 100vh;
            background: rgba(9,15,40,0.95);
            backdrop-filter: blur(20px);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0; left: 0;
            z-index: 100;
        }
        .sb-brand {
            padding: 22px 18px 16px;
            display: flex; align-items: center; gap: 10px;
            border-bottom: 1px solid var(--border);
        }
        .sb-logo {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 0.88rem;
            box-shadow: 0 4px 14px var(--accent-glow);
            flex-shrink: 0;
        }
        .sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
        .sb-role {
            display: inline-flex; align-items: center;
            background: rgba(56,189,248,0.15);
            border: 1px solid rgba(56,189,248,0.25);
            color: var(--info);
            font-size: 0.62rem; font-weight: 700;
            letter-spacing: 1px; text-transform: uppercase;
            padding: 2px 8px; border-radius: 20px;
            margin-top: 3px;
        }
        .sb-nav { flex: 1; padding: 12px 10px; overflow-y: auto; }
        .sb-lbl {
            color: rgba(255,255,255,0.22);
            font-size: 0.62rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.4px;
            padding: 0 8px; margin: 16px 0 5px;
        }
        .sb-item {
            display: flex; align-items: center; gap: 9px;
            padding: 9px 10px; border-radius: 9px;
            margin-bottom: 1px;
            color: rgba(255,255,255,0.45);
            text-decoration: none;
            font-size: 0.83rem; font-weight: 500;
            transition: all 0.2s;
            border-left: 2px solid transparent;
        }
        .sb-item i {
            width: 28px; height: 28px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.8rem; border-radius: 8px;
            background: rgba(255,255,255,0.05);
            flex-shrink: 0;
            transition: all 0.2s;
        }
        .sb-item:hover { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
        .sb-item:hover i { background: rgba(79,126,248,0.2); color: var(--accent-2); }
        .sb-item.on {
            color: #fff;
            background: linear-gradient(90deg, rgba(79,126,248,0.2), rgba(79,126,248,0.05));
            border-left: 2px solid var(--accent);
        }
        .sb-item.on i { background: rgba(79,126,248,0.25); color: var(--accent-2); }

        .sb-foot {
            padding: 12px 10px 16px;
            border-top: 1px solid var(--border);
        }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px 10px;
            border-radius: 10px;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border);
            margin-bottom: 6px;
            text-decoration: none;
            transition: all 0.2s;
            cursor: pointer;
        }
        .sb-user:hover { background: rgba(79,126,248,0.1); border-color: rgba(79,126,248,0.25); }
        .sb-ava {
            width: 34px; height: 34px; border-radius: 50%;
            background: linear-gradient(135deg, var(--accent), var(--purple));
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 0.88rem; font-weight: 700;
            flex-shrink: 0; overflow: hidden;
        }
        .sb-ava img { width: 34px; height: 34px; object-fit: cover; border-radius: 50%; }
        .sb-uname { color: #fff; font-size: 0.82rem; font-weight: 600; }
        .sb-urole { color: var(--muted); font-size: 0.68rem; margin-top: 1px; }
        .sb-logout {
            display: flex; align-items: center; gap: 8px;
            width: 100%; padding: 8px 10px; border-radius: 8px;
            color: rgba(255,255,255,0.35); text-decoration: none;
            font-size: 0.8rem; transition: all 0.2s;
        }
        .sb-logout:hover { color: var(--danger); background: rgba(248,113,113,0.08); }

        /* ════════════════════ MAIN ════════════════════ */
        .main {
            margin-left: var(--sb-width);
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* Topbar */
        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 0 32px;
            height: 64px;
            border-bottom: 1px solid var(--border);
            background: rgba(11,20,55,0.6);
            backdrop-filter: blur(16px);
            position: sticky; top: 0; z-index: 50;
            flex-shrink: 0;
        }
        .topbar-title {
            font-size: 1.05rem; font-weight: 700; color: #fff;
            display: flex; align-items: center; gap: 10px;
        }
        .topbar-title i { color: var(--accent-2); }

        /* Btn */
        .btn {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 9px 18px; border-radius: 10px;
            font-size: 0.82rem; font-weight: 600;
            font-family: 'Sora', sans-serif;
            cursor: pointer; text-decoration: none;
            border: none; transition: all 0.2s;
        }
        .btn-outline {
            background: rgba(255,255,255,0.05);
            color: var(--text-2);
            border: 1px solid var(--border);
        }
        .btn-outline:hover {
            background: rgba(79,126,248,0.12);
            border-color: rgba(79,126,248,0.4);
            color: #fff;
        }

        /* Content */
        .content { padding: 28px 32px; flex: 1; }

        /* Breadcrumb */
        .breadcrumb {
            font-size: 0.75rem; color: var(--muted);
            margin-bottom: 22px;
            display: flex; align-items: center; gap: 6px;
        }
        .breadcrumb a { color: var(--accent-2); text-decoration: none; transition: color 0.15s; }
        .breadcrumb a:hover { color: #fff; }
        .breadcrumb span { color: rgba(255,255,255,0.2); }

        /* Grid */
        .detail-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
        }

        /* Card */
        .card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            backdrop-filter: blur(12px);
            margin-bottom: 18px;
            animation: cardIn 0.45s ease both;
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .card:nth-child(1) { animation-delay: 0.05s; }
        .card:nth-child(2) { animation-delay: 0.12s; }

        .card-hd {
            display: flex; align-items: center; gap: 9px;
            padding: 15px 20px;
            border-bottom: 1px solid var(--border);
        }
        .card-hd h3 {
            font-size: 0.88rem; font-weight: 700; color: #fff;
        }
        .card-hd i { color: var(--accent-2); font-size: 0.82rem; }
        .card-body { padding: 20px; }

        /* Info rows */
        .info-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid var(--border-2);
            font-size: 0.81rem;
        }
        .info-row:last-child { border-bottom: none; }
        .info-label { color: var(--muted); font-weight: 500; }
        .info-value {
            color: var(--text-2); font-weight: 600;
            text-align: right; max-width: 62%;
            display: flex; align-items: center; gap: 6px; flex-wrap: wrap; justify-content: flex-end;
        }

        /* Section sub-label */
        .sub-lbl {
            font-size: 0.68rem; font-weight: 700;
            color: var(--muted);
            text-transform: uppercase; letter-spacing: 1px;
            margin-bottom: 7px; margin-top: 16px;
        }

        /* Desc box */
        .desc-box {
            background: rgba(255,255,255,0.03);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 14px 16px;
            font-size: 0.81rem;
            color: var(--text-2);
            line-height: 1.65;
        }

        /* Reject reason */
        .reject-box {
            margin-top: 14px;
            padding: 13px 16px;
            background: var(--danger-dim);
            border: 1px solid rgba(248,113,113,0.25);
            border-radius: 10px;
        }
        .reject-box-title {
            font-size: 0.73rem; font-weight: 700;
            color: var(--danger); margin-bottom: 5px;
        }
        .reject-box-body { font-size: 0.8rem; color: #fca5a5; }

        /* Contract link */
        .contract-link {
            color: var(--accent-2); text-decoration: none; font-weight: 700;
            font-size: 0.78rem; font-family: 'Courier New', monospace;
            transition: color 0.15s;
        }
        .contract-link:hover { color: #fff; }

        /* ── BADGES ── */
        .b {
            display: inline-flex; align-items: center;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            white-space: nowrap; letter-spacing: 0.2px;
        }
        .b-pending    { background: rgba(251,191,36,0.12);  color: #fbbf24; border: 1px solid rgba(251,191,36,0.2); }
        .b-approved   { background: rgba(52,211,153,0.1);   color: #34d399; border: 1px solid rgba(52,211,153,0.2); }
        .b-rejected   { background: rgba(248,113,113,0.1);  color: #f87171; border: 1px solid rgba(248,113,113,0.2); }
        .b-in_progress,
        .b-in-progress { background: rgba(79,126,248,0.12);  color: #7c9ffa; border: 1px solid rgba(79,126,248,0.2); }
        .b-completed  { background: rgba(167,139,250,0.12); color: #a78bfa; border: 1px solid rgba(167,139,250,0.2); }
        .b-cancelled  { background: rgba(255,255,255,0.05); color: var(--muted); border: 1px solid var(--border); }
        .b-low        { background: rgba(52,211,153,0.08);  color: #6ee7b7; border: 1px solid rgba(52,211,153,0.15); }
        .b-medium     { background: rgba(251,191,36,0.1);   color: #fcd34d; border: 1px solid rgba(251,191,36,0.2); }
        .b-high       { background: rgba(251,146,60,0.1);   color: #fb923c; border: 1px solid rgba(251,146,60,0.2); }
        .b-urgent     { background: rgba(248,113,113,0.12); color: #fca5a5; border: 1px solid rgba(248,113,113,0.2); }

        /* Contract type */
        .ct-badge {
            display: inline-flex; align-items: center;
            padding: 2px 7px; border-radius: 5px;
            font-size: 0.68rem; font-weight: 700;
        }
        .ct-wr { background: rgba(52,211,153,0.12); color: #34d399; }
        .ct-mt { background: rgba(79,126,248,0.12); color: #7c9ffa; }

        /* Source badge */
        .src-badge {
            display: inline-flex; align-items: center;
            padding: 2px 9px; border-radius: 20px;
            font-size: 0.68rem; font-weight: 700;
            background: rgba(255,255,255,0.06);
            color: var(--muted);
            border: 1px solid var(--border);
        }

        /* ── TABLE ── */
        table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
        thead tr { background: rgba(255,255,255,0.02); }
        th {
            padding: 10px 16px; text-align: left;
            color: var(--muted); font-weight: 600;
            font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.8px;
            border-bottom: 1px solid var(--border);
        }
        td {
            padding: 12px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.03);
            vertical-align: middle;
            color: var(--text-2);
        }
        tr:last-child td { border-bottom: none; }
        tbody tr { transition: background 0.15s; }
        tbody tr:hover td { background: rgba(79,126,248,0.05); }
        .td-muted { color: var(--muted); font-size: 0.75rem; }
        .td-num { color: var(--muted); font-size: 0.75rem; }
        .td-bold { font-weight: 600; color: var(--text); }
        .td-empty {
            text-align: center; padding: 28px 16px;
            color: var(--muted); font-size: 0.8rem;
        }

        /* ── TIMELINE ── */
        .timeline { display: flex; flex-direction: column; gap: 0; }
        .tl-item {
            display: flex; gap: 13px;
            padding-bottom: 18px;
            position: relative;
        }
        .tl-item:last-child { padding-bottom: 0; }
        .tl-dot {
            width: 30px; height: 30px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.72rem; flex-shrink: 0; margin-top: 1px;
        }
        .tl-dot.done    { background: var(--green-dim);   color: var(--green); border: 1px solid rgba(52,211,153,0.25); }
        .tl-dot.active  { background: rgba(79,126,248,0.15); color: var(--accent-2); border: 1px solid rgba(79,126,248,0.3); }
        .tl-dot.pending { background: rgba(255,255,255,0.04); color: var(--muted); border: 1px solid var(--border); }
        .tl-dot.rejected{ background: var(--danger-dim);  color: var(--danger); border: 1px solid rgba(248,113,113,0.25); }

        .tl-line {
            position: absolute;
            left: 14px; top: 32px; bottom: 0;
            width: 2px;
            background: linear-gradient(180deg, rgba(79,126,248,0.25), rgba(79,126,248,0.04));
        }
        .tl-item:last-child .tl-line { display: none; }

        .tl-content { flex: 1; padding-top: 4px; }
        .tl-title { font-size: 0.82rem; font-weight: 600; color: var(--text); }
        .tl-sub { font-size: 0.72rem; color: var(--muted); margin-top: 3px; line-height: 1.5; }
    </style>
</head>
<body>

    <%-- ═══════════ SIDEBAR ═══════════ --%>
    <aside class="sb">
        <div class="sb-brand">
            <div class="sb-logo"><i class="fas fa-bolt"></i></div>
            <div>
                <div class="sb-name">DRSMS</div>
                <div class="sb-role">Support</div>
            </div>
        </div>

        <nav class="sb-nav">
            <div class="sb-lbl">Overview</div>
            <a href="<%=ctx%>/supportDashboard" class="sb-item">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <div class="sb-lbl">Management</div>
            <a href="<%=ctx%>/supportCustomers" class="sb-item">
                <i class="fas fa-users"></i> Customers
            </a>
            <a href="<%=ctx%>/supportContracts" class="sb-item">
                <i class="fas fa-file-contract"></i> Contracts
            </a>
            <a href="<%=ctx%>/supportServiceRequests" class="sb-item on">
                <i class="fas fa-clipboard-list"></i> Service Requests
            </a>
            <div class="sb-lbl">Support</div>
            <a href="<%=ctx%>/supportChat" class="sb-item">
                <i class="fas fa-comment-dots"></i> Live Chat
            </a>
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
            <a href="<%=ctx%>/logout" class="sb-logout">
                <i class="fas fa-sign-out-alt"></i> Sign Out
            </a>
        </div>
    </aside>

    <%-- ═══════════ MAIN ═══════════ --%>
    <div class="main">

        <div class="topbar">
            <div class="topbar-title">
                <i class="fas fa-clipboard-list"></i> Service Request Detail
            </div>
            <a href="<%=ctx%>/supportServiceRequests" class="btn btn-outline">
                <i class="fas fa-arrow-left"></i> Back
            </a>
        </div>

        <div class="content">

            <div class="breadcrumb">
                <a href="<%=ctx%>/supportServiceRequests">Service Requests</a>
                <span>›</span>
                <span style="color:var(--text-2)"><%=sr.getRequestCode()%></span>
            </div>

            <div class="detail-grid">

                <%-- ── LEFT COLUMN ── --%>
                <div>

                    <%-- Main Info Card --%>
                    <div class="card">
                        <div class="card-hd">
                            <i class="fas fa-info-circle"></i>
                            <h3><%=sr.getRequestCode()%></h3>
                            <div style="margin-left:auto">
                                <span class="b b-<%=sr.getStatus().toLowerCase().replace("_","-")%>">
                                    <%=sr.getStatusLabel() != null ? sr.getStatusLabel() : sr.getStatus()%>
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
                                    String pc = "b-medium";
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
                            <div style="font-weight:600;font-size:0.9rem;color:var(--text);margin-bottom:4px">
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
                            <i class="fas fa-desktop"></i>
                            <h3>Equipment <span style="color:var(--muted);font-weight:400">(<%=equips.size()%>)</span></h3>
                        </div>
                        <table>
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Equipment</th>
                                    <th>Serial</th>
                                    <th>Source</th>
                                    <th>Issue Description</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%if(equips.isEmpty()){%>
                                <tr><td colspan="5" class="td-empty">
                                    <i class="fas fa-desktop" style="display:block;font-size:1.5rem;margin-bottom:8px;opacity:0.2"></i>
                                    No equipment attached
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
                            <i class="fas fa-stream"></i>
                            <h3>Progress Timeline</h3>
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
                                        <div class="tl-title">Rejected</div>
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
                                        <div class="tl-title">Cancelled</div>
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
                                        <div class="tl-title"><%=isApproved?"Approved":"Awaiting Approval"%></div>
                                        <%if(isApproved&&sr.getReviewedByName()!=null){%>
                                        <div class="tl-sub">By <%=sr.getReviewedByName()%>
                                            <%if(sr.getReviewedAt()!=null){%> · <%=sr.getReviewedAt().toString().substring(0,16)%><%}%>
                                        </div>
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
                                        <div class="tl-title"><%=isInProgress?"In Progress":isCompleted?"Work Done":"Pending Assignment"%></div>
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

</body>
</html>
