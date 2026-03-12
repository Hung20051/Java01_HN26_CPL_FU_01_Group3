<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"TECHNICAL_MANAGER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    ServiceRequest sr = (ServiceRequest) request.getAttribute("sr");
    if (sr == null) { response.sendRedirect(ctx + "/tmServiceRequests"); return; }
    List<ServiceRequestEquipment> equips = sr.getEquipmentList();
    if (equips == null) equips = new ArrayList<>();
    List<User> technicians = (List<User>) request.getAttribute("technicians");
    if (technicians == null) technicians = new ArrayList<>();

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");

    boolean isPending  = "PENDING".equals(sr.getStatus());
    boolean isApproved = "APPROVED".equals(sr.getStatus());

    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%=sr.getRequestCode()%> – TM Detail</title>
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
            background: rgba(251,191,36,0.15);
            border: 1px solid rgba(251,191,36,0.25);
            color: var(--amber);
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
        .sb-item:hover   { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
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
            padding: 10px;
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

        /* Content */
        .content {
            padding: 28px 32px;
            flex: 1;
            max-width: 960px;
        }

        /* Back link */
        .back-link {
            display: inline-flex; align-items: center; gap: 7px;
            color: var(--accent-2); text-decoration: none;
            font-size: 0.81rem; font-weight: 600;
            margin-bottom: 22px;
            transition: color 0.2s;
        }
        .back-link:hover { color: #fff; }

        /* Alert */
        .alert {
            display: flex; align-items: center; gap: 12px;
            padding: 13px 18px; border-radius: 12px;
            margin-bottom: 20px;
            font-size: 0.84rem;
            animation: cardIn 0.4s ease both;
        }
        .alert-success { background: var(--green-dim); border: 1px solid rgba(52,211,153,0.25); color: #6ee7b7; }
        .alert-success i { color: var(--green); }
        .alert-error   { background: var(--danger-dim); border: 1px solid rgba(248,113,113,0.25); color: #fca5a5; }
        .alert-error i  { color: var(--danger); }

        @keyframes cardIn {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
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
        .card:nth-child(1){ animation-delay: 0.04s; }
        .card:nth-child(2){ animation-delay: 0.09s; }
        .card:nth-child(3){ animation-delay: 0.14s; }
        .card:nth-child(4){ animation-delay: 0.19s; }
        .card:nth-child(5){ animation-delay: 0.24s; }

        .card-hd {
            display: flex; align-items: center; gap: 9px;
            padding: 15px 20px;
            border-bottom: 1px solid var(--border);
        }
        .card-hd h3 { font-size: 0.88rem; font-weight: 700; color: #fff; }
        .card-hd i  { color: var(--accent-2); font-size: 0.82rem; }
        .card-body  { padding: 20px; }

        /* Info grid */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        .info-item label {
            font-size: 0.67rem; font-weight: 700;
            color: var(--muted);
            text-transform: uppercase; letter-spacing: 1px;
            display: block; margin-bottom: 5px;
        }
        .info-item .val {
            font-size: 0.85rem; color: var(--text-2);
            font-weight: 500; line-height: 1.5;
        }
        .info-item .val.mono {
            font-family: 'Courier New', monospace;
            color: var(--accent-2); font-weight: 700;
            font-size: 0.88rem;
        }
        .info-item .val.pre { white-space: pre-wrap; }

        /* Sub-divider inside card */
        .sub-lbl {
            font-size: 0.67rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 1px; margin-bottom: 7px; margin-top: 16px;
        }
        .desc-box {
            background: rgba(255,255,255,0.03);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 13px 16px;
            font-size: 0.81rem; color: var(--text-2);
            line-height: 1.65; white-space: pre-wrap;
        }

        /* Reject box */
        .reject-box {
            padding: 13px 16px;
            background: var(--danger-dim);
            border: 1px solid rgba(248,113,113,0.25);
            border-radius: 10px;
        }
        .reject-box-title { font-size: 0.72rem; font-weight: 700; color: var(--danger); margin-bottom: 4px; }
        .reject-box-body  { font-size: 0.8rem; color: #fca5a5; }

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
        .b-in-progress { background: rgba(79,126,248,0.12); color: #7c9ffa; border: 1px solid rgba(79,126,248,0.2); }
        .b-completed  { background: rgba(167,139,250,0.12); color: #a78bfa; border: 1px solid rgba(167,139,250,0.2); }
        .b-cancelled  { background: rgba(255,255,255,0.05); color: var(--muted); border: 1px solid var(--border); }
        .b-low        { background: rgba(52,211,153,0.08);  color: #6ee7b7; border: 1px solid rgba(52,211,153,0.15); }
        .b-medium     { background: rgba(251,191,36,0.1);   color: #fcd34d; border: 1px solid rgba(251,191,36,0.2); }
        .b-high       { background: rgba(251,146,60,0.1);   color: #fb923c; border: 1px solid rgba(251,146,60,0.2); }
        .b-urgent     { background: rgba(248,113,113,0.12); color: #fca5a5; border: 1px solid rgba(248,113,113,0.2); }

        .ct-badge {
            display: inline-block;
            padding: 2px 7px; border-radius: 5px;
            font-size: 0.68rem; font-weight: 700;
        }
        .ct-wr { background: rgba(52,211,153,0.12); color: #34d399; }
        .ct-mt { background: rgba(79,126,248,0.12); color: #7c9ffa; }

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
            vertical-align: middle; color: var(--text-2);
        }
        tr:last-child td { border-bottom: none; }
        tbody tr { transition: background 0.15s; }
        tbody tr:hover td { background: rgba(79,126,248,0.05); }
        .td-muted { color: var(--muted); font-size: 0.75rem; }
        .td-num   { color: var(--muted); font-size: 0.75rem; }
        .td-code  { font-family: 'Courier New', monospace; font-size: 0.78rem; color: var(--text-2); }

        /* ── BUTTONS ── */
        .btn {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 9px 18px; border-radius: 10px;
            font-size: 0.82rem; font-weight: 600;
            font-family: 'Sora', sans-serif;
            cursor: pointer; border: none;
            text-decoration: none; transition: all 0.2s;
        }
        .btn-success {
            background: linear-gradient(135deg, #34d399, #10b981);
            color: #fff;
            box-shadow: 0 3px 12px rgba(52,211,153,0.3);
        }
        .btn-success:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(52,211,153,0.45); }
        .btn-danger {
            background: linear-gradient(135deg, #f87171, #ef4444);
            color: #fff;
            box-shadow: 0 3px 12px rgba(248,113,113,0.3);
        }
        .btn-danger:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(248,113,113,0.45); }
        .btn-primary {
            background: linear-gradient(135deg, var(--accent), #6b8ffa);
            color: #fff;
            box-shadow: 0 3px 12px rgba(79,126,248,0.35);
        }
        .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(79,126,248,0.5); }
        .btn-secondary {
            background: rgba(255,255,255,0.06);
            color: var(--text-2);
            border: 1px solid var(--border);
        }
        .btn-secondary:hover { background: rgba(255,255,255,0.1); color: #fff; }
        .btn-outline {
            background: rgba(255,255,255,0.05);
            color: var(--text-2);
            border: 1px solid var(--border);
        }
        .btn-outline:hover { background: rgba(79,126,248,0.12); border-color: rgba(79,126,248,0.4); color: #fff; }

        .action-bar { display: flex; gap: 10px; flex-wrap: wrap; }

        /* ── SOURCE BADGE ── */
        .src-badge {
            display: inline-flex; align-items: center;
            padding: 2px 9px; border-radius: 20px;
            font-size: 0.68rem; font-weight: 700;
            background: rgba(255,255,255,0.06);
            color: var(--muted);
            border: 1px solid var(--border);
        }

        /* ════════════════════ MODAL ════════════════════ */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.65);
            backdrop-filter: blur(6px);
            z-index: 1000;
            align-items: center; justify-content: center;
        }
        .modal-overlay.show { display: flex; }

        .modal {
            background: rgba(15,28,77,0.97);
            border: 1px solid rgba(79,126,248,0.2);
            border-radius: 18px;
            padding: 28px;
            width: 100%; max-width: 460px;
            box-shadow: 0 24px 60px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.04);
            animation: modalIn 0.25s cubic-bezier(.4,0,.2,1) both;
        }
        @keyframes modalIn {
            from { opacity: 0; transform: scale(0.94) translateY(10px); }
            to   { opacity: 1; transform: scale(1) translateY(0); }
        }
        .modal h3 {
            font-size: 0.98rem; font-weight: 700; color: #fff;
            margin-bottom: 14px;
            display: flex; align-items: center; gap: 9px;
        }
        .modal-desc {
            font-size: 0.82rem; color: var(--text-2);
            line-height: 1.6; margin-bottom: 20px;
            padding: 12px 14px;
            background: rgba(255,255,255,0.03);
            border: 1px solid var(--border);
            border-radius: 10px;
        }
        .modal-desc strong { color: var(--accent-2); }
        .modal label {
            font-size: 0.72rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 0.8px;
            display: block; margin-bottom: 7px;
        }
        .modal textarea,
        .modal select {
            width: 100%;
            padding: 10px 13px;
            border: 1px solid var(--border);
            border-radius: 9px;
            font-size: 0.83rem;
            font-family: 'Sora', sans-serif;
            color: var(--text-2);
            background: rgba(255,255,255,0.05);
            outline: none; resize: vertical;
            transition: all 0.2s;
        }
        .modal textarea:focus,
        .modal select:focus {
            border-color: rgba(79,126,248,0.5);
            background: rgba(79,126,248,0.07);
            color: #fff;
        }
        .modal select option { background: #0f1c4d; color: #fff; }
        .modal textarea::placeholder { color: var(--muted); }
        .modal-footer {
            display: flex; gap: 10px; justify-content: flex-end;
            margin-top: 20px;
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
                <div class="sb-role">Tech Manager</div>
            </div>
        </div>
        <nav class="sb-nav">
            <div class="sb-lbl">Management</div>
            <a href="<%=ctx%>/tmServiceRequests" class="sb-item on">
                <i class="fas fa-clipboard-list"></i> Service Requests
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
                    <div class="sb-urole">Technical Manager</div>
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
            <a href="<%=ctx%>/tmServiceRequests" class="btn btn-outline">
                <i class="fas fa-arrow-left"></i> Back to list
            </a>
        </div>

        <div class="content">

            <%-- Flash --%>
            <%if(flashOk!=null){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=flashOk%></div>
            <%}%>
            <%if(flashErr!=null){%>
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div>
            <%}%>

            <%
            String bSt="b-pending";
            if("APPROVED".equals(sr.getStatus()))    bSt="b-approved";
            else if("REJECTED".equals(sr.getStatus()))    bSt="b-rejected";
            else if("IN_PROGRESS".equals(sr.getStatus())) bSt="b-in_progress";
            else if("COMPLETED".equals(sr.getStatus()))   bSt="b-completed";
            else if("CANCELLED".equals(sr.getStatus()))   bSt="b-cancelled";
            String bPr="b-medium";
            if("LOW".equals(sr.getPriority()))    bPr="b-low";
            else if("HIGH".equals(sr.getPriority()))   bPr="b-high";
            else if("URGENT".equals(sr.getPriority())) bPr="b-urgent";
            %>

            <%-- Request Info Card --%>
            <div class="card">
                <div class="card-hd">
                    <i class="fas fa-file-alt"></i>
                    <h3><%=sr.getRequestCode()%></h3>
                    <div style="margin-left:auto">
                        <span class="b <%=bSt%>"><%=sr.getStatusLabel()%></span>
                    </div>
                </div>
                <div class="card-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <label>Request Code</label>
                            <div class="val mono"><%=sr.getRequestCode()%></div>
                        </div>
                        <div class="info-item">
                            <label>Customer</label>
                            <div class="val"><%=sr.getCustomerName()%></div>
                        </div>
                        <div class="info-item">
                            <label>Contract</label>
                            <div class="val" style="display:flex;align-items:center;gap:7px">
                                <span style="font-family:'Courier New',monospace;font-size:0.82rem;color:var(--accent-2);font-weight:700"><%=sr.getContractCode()%></span>
                                <span class="ct-badge <%="WARRANTY".equals(sr.getContractType())?"ct-wr":"ct-mt"%>">
                                    <%="WARRANTY".equals(sr.getContractType())?"WR":"MT"%>
                                </span>
                            </div>
                        </div>
                        <div class="info-item">
                            <label>Priority</label>
                            <div class="val"><span class="b <%=bPr%>"><%=sr.getPriority()%></span></div>
                        </div>
                        <div class="info-item">
                            <label>Title</label>
                            <div class="val"><%=sr.getTitle()%></div>
                        </div>
                        <div class="info-item">
                            <label>Created At</label>
                            <div class="val td-muted">
                                <%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().replace("T"," ").substring(0,16):""%>
                            </div>
                        </div>
                    </div>
                    <div class="sub-lbl">Description</div>
                    <div class="desc-box"><%=sr.getDescription()%></div>
                </div>
            </div>

            <%-- Equipment Card --%>
            <%if(!equips.isEmpty()){%>
            <div class="card">
                <div class="card-hd">
                    <i class="fas fa-desktop"></i>
                    <h3>Equipment <span style="color:var(--muted);font-weight:400">(<%=equips.size()%>)</span></h3>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>#</th><th>Name</th><th>Serial</th><th>Source</th><th>Issue</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%int idx=1;for(ServiceRequestEquipment e:equips){%>
                    <tr>
                        <td class="td-num"><%=idx++%></td>
                        <td style="font-weight:600;color:var(--text)"><%=e.getDisplayName()!=null?e.getDisplayName():"-"%></td>
                        <td class="td-code"><%=e.getDisplaySerial()!=null?e.getDisplaySerial():"-"%></td>
                        <td><span class="src-badge"><%=e.getSource()!=null?e.getSource():"-"%></span></td>
                        <td class="td-muted"><%=e.getIssueDescription()!=null?e.getIssueDescription():"-"%></td>
                    </tr>
                    <%}%>
                    </tbody>
                </table>
            </div>
            <%}%>

            <%-- Review Info Card --%>
            <%if(sr.getReviewedBy()!=null){%>
            <div class="card">
                <div class="card-hd">
                    <i class="fas fa-user-check"></i>
                    <h3>Review Info</h3>
                </div>
                <div class="card-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <label>Reviewed By</label>
                            <div class="val"><%=sr.getReviewedByName()!=null?sr.getReviewedByName():"-"%></div>
                        </div>
                        <div class="info-item">
                            <label>Reviewed At</label>
                            <div class="val td-muted"><%=sr.getReviewedAt()!=null?sr.getReviewedAt().toString().replace("T"," ").substring(0,16):""%></div>
                        </div>
                    </div>
                    <%if(sr.getRejectReason()!=null&&!sr.getRejectReason().isEmpty()){%>
                    <div style="margin-top:14px" class="reject-box">
                        <div class="reject-box-title"><i class="fas fa-times-circle"></i> Rejection Reason</div>
                        <div class="reject-box-body"><%=sr.getRejectReason()%></div>
                    </div>
                    <%}%>
                </div>
            </div>
            <%}%>

            <%-- Assignment Card --%>
            <%if(sr.getAssignedTo()!=null){%>
            <div class="card">
                <div class="card-hd">
                    <i class="fas fa-hard-hat"></i>
                    <h3>Assignment</h3>
                </div>
                <div class="card-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <label>Assigned To</label>
                            <div class="val"><%=sr.getAssignedToName()!=null?sr.getAssignedToName():"-"%></div>
                        </div>
                        <div class="info-item">
                            <label>Assigned At</label>
                            <div class="val td-muted"><%=sr.getAssignedAt()!=null?sr.getAssignedAt().toString().replace("T"," ").substring(0,16):""%></div>
                        </div>
                    </div>
                </div>
            </div>
            <%}%>

            <%-- Actions Card --%>
            <%if(isPending||isApproved){%>
            <div class="card">
                <div class="card-hd">
                    <i class="fas fa-bolt"></i>
                    <h3>Actions</h3>
                </div>
                <div class="card-body">
                    <div class="action-bar">
                        <%if(isPending){%>
                        <button class="btn btn-success"
                                onclick="document.getElementById('modalApprove').classList.add('show')">
                            <i class="fas fa-check"></i> Approve
                        </button>
                        <button class="btn btn-danger"
                                onclick="document.getElementById('modalReject').classList.add('show')">
                            <i class="fas fa-times"></i> Reject
                        </button>
                        <%}%>
                        <%if(isApproved&&!technicians.isEmpty()){%>
                        <button class="btn btn-primary"
                                onclick="document.getElementById('modalAssign').classList.add('show')">
                            <i class="fas fa-user-plus"></i> Assign Technician
                        </button>
                        <%}%>
                    </div>
                </div>
            </div>
            <%}%>

        </div>
    </div>

    <%-- ════════ MODAL: APPROVE ════════ --%>
    <div class="modal-overlay" id="modalApprove">
        <div class="modal">
            <h3><i class="fas fa-check-circle" style="color:var(--green)"></i> Approve Request</h3>
            <div class="modal-desc">
                Are you sure you want to approve <strong><%=sr.getRequestCode()%></strong>?<br>
                After approval, you can assign a technician to handle this request.
            </div>
            <form method="post" action="<%=ctx%>/tmServiceRequests">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="id" value="<%=sr.getId()%>">
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary"
                            onclick="document.getElementById('modalApprove').classList.remove('show')">
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-check"></i> Yes, Approve
                    </button>
                </div>
            </form>
        </div>
    </div>

    <%-- ════════ MODAL: REJECT ════════ --%>
    <div class="modal-overlay" id="modalReject">
        <div class="modal">
            <h3><i class="fas fa-times-circle" style="color:var(--danger)"></i> Reject Request</h3>
            <form method="post" action="<%=ctx%>/tmServiceRequests">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="id" value="<%=sr.getId()%>">
                <label>Reason for rejection <span style="color:var(--danger)">*</span></label>
                <textarea name="rejectReason" rows="4"
                          placeholder="Explain why this request is rejected..." required></textarea>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary"
                            onclick="document.getElementById('modalReject').classList.remove('show')">
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-danger">
                        <i class="fas fa-times"></i> Reject
                    </button>
                </div>
            </form>
        </div>
    </div>

    <%-- ════════ MODAL: ASSIGN ════════ --%>
    <div class="modal-overlay" id="modalAssign">
        <div class="modal">
            <h3><i class="fas fa-user-plus" style="color:var(--accent-2)"></i> Assign Technician</h3>
            <form method="post" action="<%=ctx%>/tmServiceRequests">
                <input type="hidden" name="action" value="assign">
                <input type="hidden" name="id" value="<%=sr.getId()%>">
                <label>Select Technician <span style="color:var(--danger)">*</span></label>
                <select name="technicianId" required>
                    <option value="">-- Choose technician --</option>
                    <%for(User t:technicians){%>
                    <option value="<%=t.getId()%>">
                        <%=t.getFullName()%><%=t.getEmail()!=null?" ("+t.getEmail()+")":""%>
                    </option>
                    <%}%>
                </select>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary"
                            onclick="document.getElementById('modalAssign').classList.remove('show')">
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-paper-plane"></i> Assign
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
            overlay.addEventListener('click', function(e) {
                if (e.target === overlay) overlay.classList.remove('show');
            });
        });
    </script>
</body>
</html>
