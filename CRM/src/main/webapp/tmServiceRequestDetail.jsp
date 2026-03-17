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

        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{scroll-behavior:smooth}
        body{
            font-family:'Sora',sans-serif;
            background:var(--bg);
            color:var(--text-b);
            min-height:100vh;
            display:flex;
        }
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-track{background:transparent}
        ::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px}

        /* ═══════════ SIDEBAR ═══════════ */
        .sb{
            width:var(--sb-width);min-height:100vh;
            background:var(--sb-bg);
            border-right:1px solid rgba(79,70,229,0.2);
            display:flex;flex-direction:column;
            position:fixed;top:0;left:0;z-index:100;
            box-shadow:4px 0 24px rgba(0,0,0,0.15);
        }
        .sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border);}
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#818cf8,#a78bfa);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;box-shadow:0 4px 12px rgba(129,140,248,0.4);flex-shrink:0;}
        .sb-name{color:#fff;font-size:1.05rem;font-weight:800;letter-spacing:-.3px}
        .sb-role{
            display:inline-flex;align-items:center;
            background:rgba(217,119,6,0.2);
            border:1px solid rgba(217,119,6,0.35);
            color:#fbbf24;
            font-size:.6rem;font-weight:700;
            letter-spacing:1px;text-transform:uppercase;
            padding:2px 8px;border-radius:20px;margin-top:3px;
        }
        .sb-nav{flex:1;padding:12px 10px;overflow-y:auto}
        .sb-lbl{color:rgba(255,255,255,0.22);font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:1.6px;padding:0 8px;margin:14px 0 5px;}
        .sb-item{display:flex;align-items:center;gap:9px;padding:8px 10px;border-radius:9px;margin-bottom:1px;color:var(--sb-text);text-decoration:none;font-size:.81rem;font-weight:500;transition:all .18s;border-left:2px solid transparent;}
        .sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.78rem;border-radius:8px;background:rgba(255,255,255,0.06);flex-shrink:0;transition:all .18s;}
        .sb-item.on{color:#fff;background:var(--sb-item-on);border-left-color:var(--sb-accent);}
        .sb-item.on i{background:rgba(129,140,248,0.3);color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){color:rgba(255,255,255,0.78);background:rgba(255,255,255,0.06);}
        .sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border)}
        .sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);margin-bottom:5px;text-decoration:none;transition:all .18s;cursor:pointer;}
        .sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3)}
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.8rem;font-weight:600}
        .sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem;margin-top:1px}
        .sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
        .sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1)}

        /* ═══════════ MAIN (light) ═══════════ */
        .main{margin-left:var(--sb-width);flex:1;display:flex;flex-direction:column;min-height:100vh}

        .topbar{
            display:flex;justify-content:space-between;align-items:center;
            padding:18px 28px;
            background:var(--bg-topbar);
            border-bottom:1px solid var(--border-light);
            position:sticky;top:0;z-index:50;
            box-shadow:0 1px 6px rgba(0,0,0,0.06);
        }
        .topbar-title{font-size:1.2rem;font-weight:800;color:var(--text-h);letter-spacing:-.3px;display:flex;align-items:center;gap:9px;}
        .topbar-title i{color:var(--primary-2);font-size:1rem}
        .topbar-sub{color:var(--text-s);font-size:.78rem;margin-top:2px}

        .content{padding:24px 28px;flex:1;max-width:960px}

        /* Breadcrumb */
        .breadcrumb{display:flex;align-items:center;gap:7px;font-size:.76rem;color:var(--text-s);}
        .breadcrumb a{color:var(--text-s);text-decoration:none;transition:color .18s}
        .breadcrumb a:hover{color:var(--primary-2)}
        .bc-sep{color:var(--border-light);font-size:.9rem}
        .bc-cur{color:var(--primary-2);font-weight:700;font-family:'Courier New',monospace;}

        /* Alert */
        @keyframes cardIn{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}
        .alert{display:flex;align-items:center;gap:12px;padding:12px 18px;border-radius:12px;margin-bottom:20px;font-size:.82rem;animation:cardIn .5s ease both;}
        .alert-success{background:#d1fae5;border:1px solid #a7f3d0;color:#065f46}
        .alert-success i{color:var(--green)}
        .alert-error  {background:#fee2e2;border:1px solid #fca5a5;color:#991b1b}
        .alert-error i{color:var(--red)}

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
        .card:nth-child(1){animation-delay:.04s}
        .card:nth-child(2){animation-delay:.09s}
        .card:nth-child(3){animation-delay:.14s}
        .card:nth-child(4){animation-delay:.19s}
        .card:nth-child(5){animation-delay:.24s}

        .card-hd{
            display:flex;align-items:center;gap:10px;
            padding:14px 18px;
            border-bottom:1px solid var(--border-light2);
            background:#fafbff;
        }
        .card-hd-icon{width:30px;height:30px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.8rem;flex-shrink:0;}
        .card-hd-title{font-size:.88rem;font-weight:700;color:var(--text-h)}
        .card-hd-badge{margin-left:auto}
        .card-body{padding:20px}

        /* Info grid */
        .info-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px;}
        .info-item label{
            font-size:.67rem;font-weight:700;color:var(--text-s);
            text-transform:uppercase;letter-spacing:1px;
            display:block;margin-bottom:5px;
        }
        .info-item .val{font-size:.85rem;color:var(--text-b);font-weight:500;line-height:1.5}
        .info-item .val.mono{font-family:'Courier New',monospace;color:var(--primary-2);font-weight:700;font-size:.88rem;}

        /* Sub label */
        .sub-lbl{font-size:.67rem;font-weight:700;color:var(--text-s);text-transform:uppercase;letter-spacing:1px;margin-bottom:7px;margin-top:16px;}

        /* Description box */
        .desc-box{
            background:#fafbff;
            border:1px solid var(--border-light);
            border-radius:12px;
            padding:14px 16px;
            font-size:.83rem;color:var(--text-b);
            line-height:1.7;white-space:pre-wrap;
            border-left:3px solid var(--primary-2);
        }

        /* Reject box */
        .reject-box{
            padding:13px 16px;margin-top:14px;
            background:#fee2e2;
            border:1.5px solid #fca5a5;
            border-radius:12px;
        }
        .reject-box-title{font-size:.72rem;font-weight:700;color:var(--red);margin-bottom:4px;}
        .reject-box-body{font-size:.82rem;color:#991b1b;}

        /* ── BADGES ── */
        .b{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;white-space:nowrap;}
        .b-pending    {background:#fef3c7;color:#92400e}
        .b-approved   {background:#d1fae5;color:#065f46}
        .b-rejected   {background:#fee2e2;color:#991b1b}
        .b-in_progress,
        .b-in-progress{background:#dbeafe;color:#1e40af}
        .b-completed  {background:#ede9fe;color:#5b21b6}
        .b-cancelled  {background:#f3f4f6;color:#6b7280}
        .b-low        {background:#dcfce7;color:#166534}
        .b-medium     {background:#fef3c7;color:#92400e}
        .b-high       {background:#ffedd5;color:#9a3412}
        .b-urgent     {background:#fee2e2;color:#991b1b}

        .ct-badge{display:inline-block;padding:2px 7px;border-radius:5px;font-size:.67rem;font-weight:700;}
        .ct-wr{background:#d1fae5;color:#065f46}
        .ct-mt{background:#dbeafe;color:#1e40af}

        /* ── TABLE ── */
        table{width:100%;border-collapse:collapse;font-size:.8rem}
        thead tr{background:#fafbff}
        th{padding:10px 16px;text-align:left;color:var(--text-s);font-weight:700;font-size:.67rem;text-transform:uppercase;letter-spacing:.8px;border-bottom:1px solid var(--border-light2);}
        td{padding:12px 16px;border-bottom:1px solid var(--border-light2);vertical-align:middle;color:var(--text-b);}
        tr:last-child td{border-bottom:none}
        tbody tr{transition:background .12s}
        tbody tr:hover td{background:#f7f8ff}
        .td-muted{color:var(--text-s);font-size:.75rem}
        .td-num  {color:var(--text-s);font-size:.75rem}
        .td-code {font-family:'Courier New',monospace;font-size:.78rem;color:var(--text-m)}

        /* Source badge */
        .src-badge{
            display:inline-flex;align-items:center;
            padding:2px 9px;border-radius:20px;
            font-size:.68rem;font-weight:700;
            background:var(--primary-light);
            color:var(--primary-2);
            border:1px solid rgba(99,102,241,0.25);
        }

        /* ── BUTTONS ── */
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 18px;border-radius:10px;font-size:.81rem;font-weight:600;font-family:'Sora',sans-serif;cursor:pointer;border:none;text-decoration:none;transition:all .2s;}
        .btn-success{background:var(--green);color:#fff;box-shadow:0 3px 10px rgba(22,163,74,0.28);}
        .btn-success:hover{background:#15803d;transform:translateY(-1px);box-shadow:0 6px 18px rgba(22,163,74,0.4)}
        .btn-danger{background:var(--red);color:#fff;box-shadow:0 3px 10px rgba(220,38,38,0.28);}
        .btn-danger:hover{background:#b91c1c;transform:translateY(-1px);box-shadow:0 6px 18px rgba(220,38,38,0.4)}
        .btn-primary{background:var(--primary);color:#fff;box-shadow:0 3px 10px rgba(79,70,229,0.28);}
        .btn-primary:hover{background:#4338ca;transform:translateY(-1px);box-shadow:0 6px 18px rgba(79,70,229,0.4)}
        .btn-secondary{background:#fff;color:var(--text-m);border:1.5px solid var(--border-light);}
        .btn-secondary:hover{background:#f3f4f6;border-color:#d1d5db;color:var(--text-b)}

        .action-bar{display:flex;gap:10px;flex-wrap:wrap;}

        /* ════════ MODAL ════════ */
        .modal-overlay{
            display:none;position:fixed;inset:0;
            background:rgba(0,0,0,0.45);
            backdrop-filter:blur(4px);
            z-index:1000;
            align-items:center;justify-content:center;
        }
        .modal-overlay.show{display:flex;}

        .modal{
            background:#fff;
            border:1px solid var(--border-light);
            border-radius:18px;
            padding:28px;
            width:100%;max-width:460px;
            box-shadow:0 24px 60px rgba(0,0,0,0.15),0 0 0 1px rgba(79,70,229,0.08);
            animation:modalIn .25s cubic-bezier(.4,0,.2,1) both;
        }
        @keyframes modalIn{from{opacity:0;transform:scale(0.95) translateY(10px)}to{opacity:1;transform:scale(1) translateY(0)}}

        .modal h3{
            font-size:.98rem;font-weight:700;color:var(--text-h);
            margin-bottom:14px;
            display:flex;align-items:center;gap:9px;
        }
        .modal-desc{
            font-size:.82rem;color:var(--text-m);
            line-height:1.65;margin-bottom:20px;
            padding:12px 14px;
            background:#fafbff;
            border:1px solid var(--border-light);
            border-radius:10px;
        }
        .modal-desc strong{color:var(--primary-2)}
        .modal label{
            font-size:.72rem;font-weight:700;
            color:var(--text-s);text-transform:uppercase;letter-spacing:.8px;
            display:block;margin-bottom:7px;
        }
        .modal textarea,
        .modal select{
            width:100%;
            padding:10px 13px;
            border:1.5px solid var(--border-light);
            border-radius:9px;
            font-size:.83rem;font-family:'Sora',sans-serif;
            color:var(--text-b);background:#fff;
            outline:none;resize:vertical;
            transition:all .2s;
        }
        .modal textarea:focus,
        .modal select:focus{
            border-color:rgba(79,70,229,0.4);
            background:#faf9ff;
            box-shadow:0 0 0 3px rgba(79,70,229,0.07);
        }
        .modal textarea::placeholder{color:var(--text-s)}
        .modal-footer{display:flex;gap:10px;justify-content:flex-end;margin-top:20px;}
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
    <main class="main">

        <div class="topbar">
            <div>
                <div class="topbar-title">
                    <i class="fas fa-clipboard-list"></i> Service Request Detail
                </div>
                <div class="topbar-sub"><%=sr.getRequestCode()%> · <%=sr.getTitle()%></div>
            </div>
            <a href="<%=ctx%>/tmServiceRequests" class="btn btn-secondary">
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
            if("APPROVED".equals(sr.getStatus()))         bSt="b-approved";
            else if("REJECTED".equals(sr.getStatus()))    bSt="b-rejected";
            else if("IN_PROGRESS".equals(sr.getStatus())) bSt="b-in_progress";
            else if("COMPLETED".equals(sr.getStatus()))   bSt="b-completed";
            else if("CANCELLED".equals(sr.getStatus()))   bSt="b-cancelled";
            String bPr="b-medium";
            if("LOW".equals(sr.getPriority()))             bPr="b-low";
            else if("HIGH".equals(sr.getPriority()))       bPr="b-high";
            else if("URGENT".equals(sr.getPriority()))     bPr="b-urgent";
            %>

            <%-- Request Info Card --%>
            <div class="card">
                <div class="card-hd">
                    <div class="card-hd-icon" style="background:var(--primary-light);color:var(--primary-2)">
                        <i class="fas fa-file-alt"></i>
                    </div>
                    <div class="card-hd-title"><%=sr.getRequestCode()%></div>
                    <div class="card-hd-badge"><span class="b <%=bSt%>"><%=sr.getStatusLabel()%></span></div>
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
                                <span style="font-family:'Courier New',monospace;font-size:.82rem;color:var(--primary-2);font-weight:700"><%=sr.getContractCode()%></span>
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
                                <%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().replace("T"," ").substring(0,16):"—"%>
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
                    <div class="card-hd-icon" style="background:#e0f2fe;color:var(--info)">
                        <i class="fas fa-desktop"></i>
                    </div>
                    <div class="card-hd-title">Equipment <span style="color:var(--text-s);font-weight:400">(<%=equips.size()%>)</span></div>
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
                        <td style="font-weight:600;color:var(--text-h)"><%=e.getDisplayName()!=null?e.getDisplayName():"-"%></td>
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
                    <div class="card-hd-icon" style="background:#d1fae5;color:var(--green)">
                        <i class="fas fa-user-check"></i>
                    </div>
                    <div class="card-hd-title">Review Info</div>
                </div>
                <div class="card-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <label>Reviewed By</label>
                            <div class="val"><%=sr.getReviewedByName()!=null?sr.getReviewedByName():"-"%></div>
                        </div>
                        <div class="info-item">
                            <label>Reviewed At</label>
                            <div class="val td-muted"><%=sr.getReviewedAt()!=null?sr.getReviewedAt().toString().replace("T"," ").substring(0,16):"—"%></div>
                        </div>
                    </div>
                    <%if(sr.getRejectReason()!=null&&!sr.getRejectReason().isEmpty()){%>
                    <div class="reject-box">
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
                    <div class="card-hd-icon" style="background:#e0f2fe;color:var(--info)">
                        <i class="fas fa-hard-hat"></i>
                    </div>
                    <div class="card-hd-title">Assignment</div>
                </div>
                <div class="card-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <label>Assigned To</label>
                            <div class="val"><%=sr.getAssignedToName()!=null?sr.getAssignedToName():"-"%></div>
                        </div>
                        <div class="info-item">
                            <label>Assigned At</label>
                            <div class="val td-muted"><%=sr.getAssignedAt()!=null?sr.getAssignedAt().toString().replace("T"," ").substring(0,16):"—"%></div>
                        </div>
                    </div>
                </div>
            </div>
            <%}%>

            <%-- Actions Card --%>
            <%if(isPending||isApproved){%>
            <div class="card">
                <div class="card-hd">
                    <div class="card-hd-icon" style="background:#fef3c7;color:var(--amber)">
                        <i class="fas fa-bolt"></i>
                    </div>
                    <div class="card-hd-title">Actions</div>
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
    </main>

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
            <h3><i class="fas fa-times-circle" style="color:var(--red)"></i> Reject Request</h3>
            <form method="post" action="<%=ctx%>/tmServiceRequests">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="id" value="<%=sr.getId()%>">
                <label>Reason for rejection <span style="color:var(--red)">*</span></label>
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
            <h3><i class="fas fa-user-plus" style="color:var(--primary-2)"></i> Assign Technician</h3>
            <form method="post" action="<%=ctx%>/tmServiceRequests">
                <input type="hidden" name="action" value="assign">
                <input type="hidden" name="id" value="<%=sr.getId()%>">
                <label>Select Technician <span style="color:var(--red)">*</span></label>
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
