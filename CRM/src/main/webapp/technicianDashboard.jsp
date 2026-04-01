<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, java.util.Map" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"TECHNICIAN".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    @SuppressWarnings("unchecked")
    Map<String,Integer> stats = (Map<String,Integer>) request.getAttribute("stats");
    int total      = stats != null ? stats.getOrDefault("total",      0) : 0;
    int assigned   = stats != null ? stats.getOrDefault("assigned",   0) : 0;
    int inProgress = stats != null ? stats.getOrDefault("inProgress", 0) : 0;
    int completed  = stats != null ? stats.getOrDefault("completed",  0) : 0;
    int cancelled  = stats != null ? stats.getOrDefault("cancelled",  0) : 0;
    String ctx = request.getContextPath();
    String initials = (me.getFullName() != null && !me.getFullName().isEmpty())
        ? me.getFullName().substring(0,1).toUpperCase() : "T";
    String now = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Dashboard – Kỹ thuật viên</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root{
                --sb-bg:#1e1b4b;
                --sb-border:rgba(255,255,255,0.08);
                --sb-text:rgba(255,255,255,0.45);
                --sb-accent:#818cf8;
                --sb-accent-2:#a5b4fc;
                --sb-item-on:rgba(129,140,248,0.2);
                --sb-width:252px;
                --bg:#f3f4f9;
                --bg-card:#fff;
                --border-light:#e8ecf5;
                --border-light2:#f0f2fb;
                --text-h:#1e1b4b;
                --text-b:#374151;
                --text-m:#6b7280;
                --text-s:#9ca3af;
                --primary:#4f46e5;
                --primary-2:#6366f1;
                --primary-light:#ede9fe;
                --blue:#2563eb;
                --teal:#0d9488;
                --green:#16a34a;
                --red:#dc2626;
                --amber:#d97706;
                --info:#0284c7;
                --purple:#7c3aed;
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
                display:flex;
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
                flex-shrink:0;
            }
            .sb-name{
                color:#fff;
                font-size:1.05rem;
                font-weight:800
            }
            .sb-role{
                display:inline-flex;
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
            }
            .sb-user:hover{
                background:rgba(129,140,248,0.18)
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
                background:#fff;
                border-bottom:1px solid var(--border-light);
                position:sticky;
                top:0;
                z-index:50;
            }
            .topbar-title{
                font-size:1rem;
                font-weight:700;
                color:var(--text-h)
            }
            .topbar-sub{
                font-size:.75rem;
                color:var(--text-s);
                margin-top:1px
            }
            .content{
                padding:24px 28px;
                flex:1
            }
            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(12px)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }
            /* WELCOME BANNER */
            .welcome{
                background:linear-gradient(135deg,#4f46e5,#7c3aed);
                border-radius:18px;
                padding:26px 28px;
                color:#fff;
                display:flex;
                justify-content:space-between;
                align-items:center;
                margin-bottom:24px;
                animation:cardIn .4s ease;
            }
            .welcome-title{
                font-size:1.25rem;
                font-weight:800
            }
            .welcome-sub{
                font-size:.82rem;
                opacity:.8;
                margin-top:4px
            }
            .welcome-time{
                font-size:.75rem;
                opacity:.6;
                margin-top:8px;
                display:flex;
                align-items:center;
                gap:6px
            }
            .welcome-btn{
                background:rgba(255,255,255,0.18);
                border:1px solid rgba(255,255,255,0.3);
                color:#fff;
                padding:9px 18px;
                border-radius:10px;
                text-decoration:none;
                font-size:.8rem;
                font-weight:700;
                white-space:nowrap;
                transition:all .18s;
            }
            .welcome-btn:hover{
                background:rgba(255,255,255,0.28);
                color:#fff
            }
            /* STAT CARDS */
            .stats{
                display:grid;
                grid-template-columns:repeat(5,1fr);
                gap:14px;
                margin-bottom:24px;
            }
            .sc{
                border-radius:16px;
                padding:18px 16px;
                position:relative;
                overflow:hidden;
                color:#fff;
                transition:all .22s;
                animation:cardIn .45s ease both;
                cursor:pointer;
                text-decoration:none;
                display:block;
            }
            .sc:hover{
                transform:translateY(-3px);
                box-shadow:0 12px 32px rgba(0,0,0,0.18)
            }
            .sc::after{
                content:'';
                position:absolute;
                width:70px;
                height:70px;
                border-radius:50%;
                background:rgba(255,255,255,0.12);
                top:-18px;
                right:-18px;
            }
            .sc-blue{
                background:var(--blue);
                box-shadow:0 4px 20px rgba(37,99,235,0.3)
            }
            .sc-info{
                background:var(--info);
                box-shadow:0 4px 20px rgba(2,132,199,0.3)
            }
            .sc-amber{
                background:var(--amber);
                box-shadow:0 4px 20px rgba(217,119,6,0.3)
            }
            .sc-green{
                background:var(--green);
                box-shadow:0 4px 20px rgba(22,163,74,0.3)
            }
            .sc-red{
                background:var(--red);
                box-shadow:0 4px 20px rgba(220,38,38,0.3)
            }
            .sc:nth-child(1){
                animation-delay:.04s
            }
            .sc:nth-child(2){
                animation-delay:.08s
            }
            .sc:nth-child(3){
                animation-delay:.12s
            }
            .sc:nth-child(4){
                animation-delay:.16s
            }
            .sc:nth-child(5){
                animation-delay:.20s
            }
            .sc-icon{
                width:36px;
                height:36px;
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.88rem;
                margin-bottom:10px;
                background:rgba(255,255,255,0.2);
                position:relative;
                z-index:1;
            }
            .sc-val{
                font-size:1.8rem;
                font-weight:800;
                color:#fff;
                line-height:1;
                letter-spacing:-1px;
                position:relative;
                z-index:1
            }
            .sc-lbl{
                color:rgba(255,255,255,0.85);
                font-size:.72rem;
                font-weight:600;
                margin-top:4px;
                position:relative;
                z-index:1
            }
            /* GRID 2 COL */
            .grid2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:18px;
                margin-bottom:24px;
            }
            .card{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                animation:cardIn .5s .2s ease both;
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
                font-size:.87rem;
                font-weight:700;
                color:var(--text-h);
                display:flex;
                align-items:center;
                gap:8px;
            }
            .card-body{
                padding:18px
            }
            /* SHORTCUT BUTTONS */
            .shortcut-grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:10px;
            }
            .shortcut-btn{
                display:flex;
                align-items:center;
                gap:10px;
                padding:12px 14px;
                border-radius:12px;
                border:1px solid var(--border-light);
                text-decoration:none;
                color:var(--text-b);
                transition:all .18s;
                font-size:.82rem;
                font-weight:600;
            }
            .shortcut-btn:hover{
                background:var(--primary-light);
                border-color:rgba(99,102,241,0.3);
                color:var(--primary-2);
            }
            .shortcut-btn i{
                width:32px;
                height:32px;
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.82rem;
                flex-shrink:0;
            }
            .shortcut-btn.blue i{
                background:#dbeafe;
                color:var(--blue)
            }
            .shortcut-btn.green i{
                background:#d1fae5;
                color:var(--green)
            }
            .shortcut-btn.purple i{
                background:#ede9fe;
                color:var(--purple)
            }
            .shortcut-btn.teal i{
                background:#ccfbf1;
                color:var(--teal)
            }
            .shortcut-btn.amber i{
                background:#fef3c7;
                color:var(--amber)
            }
            .shortcut-btn.red i{
                background:#fee2e2;
                color:var(--red)
            }
            /* INFO ITEMS */
            .info-item{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:10px 0;
                border-bottom:1px solid var(--border-light2);
            }
            .info-item:last-child{
                border-bottom:none
            }
            .info-label{
                font-size:.78rem;
                color:var(--text-s)
            }
            .info-val{
                font-size:.82rem;
                font-weight:600;
                color:var(--text-h)
            }
        </style>
    </head>
    <body>
        <!-- SIDEBAR -->
        <aside class="sb">
            <div class="sb-brand"><div class="sb-logo"><i class="fas fa-tools"></i></div><div><div class="sb-name">DRSMS</div><div class="sb-role">Technician</div></div></div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/technicianDashboard" class="sb-item on"><i class="fas fa-th-large"></i> Dashboard</a>
                <div class="sb-lbl">Work</div>
                <a href="<%=ctx%>/technicianTasks" class="sb-item"><i class="fas fa-tasks"></i> My Tasks</a>
                <a href="<%=ctx%>/technicianReports" class="sb-item"><i class="fas fa-clipboard-list"></i> Repair Reports</a>
                <a href="<%=ctx%>/technicianWorkHistory" class="sb-item"><i class="fas fa-history"></i> Work History</a>
                <div class="sb-lbl">Reference</div>
                <a href="<%=ctx%>/technicianContracts" class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/technicianContracts?action=equipment" class="sb-item"><i class="fas fa-desktop"></i> Equipment</a>
            </nav>
            <div class="sb-foot">
                <a href="<%=ctx%>/profile" class="sb-user">
                    <div class="sb-ava"><%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%><img src="<%=ctx%><%=me.getAvatarUrl()%>" alt=""><%}else{%><%=initials%><%}%></div>
                    <div><div class="sb-uname"><%=me.getFullName()!=null?me.getFullName():me.getUsername()%></div><div class="sb-urole">Technician</div></div>
                </a>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
            </div>

        </aside>

        <!-- MAIN -->
        <main class="main">
            <div class="topbar">
                <div><div class="topbar-title">Dashboard</div><div class="topbar-sub">Technician Workspace</div></div>
                <div style="display:flex;align-items:center;gap:12px">
                    <span style="font-size:.75rem;color:var(--text-s)"><i class="fas fa-clock" style="margin-right:4px"></i><%=now%></span>
                    <a href="<%=ctx%>/technicianTasks" style="background:var(--primary);color:#fff;padding:8px 16px;border-radius:9px;text-decoration:none;font-size:.8rem;font-weight:700;display:inline-flex;align-items:center;gap:6px"><i class="fas fa-tasks"></i>My Tasks</a>
                </div>
            </div>

            <div class="content">
                <!-- Welcome -->
                <div class="welcome">
                    <div>
                        <div class="welcome-title">Xin chào, <%=me.getFullName()!=null?me.getFullName():"Kỹ thuật viên"%>! 👋</div>
                        <div class="welcome-sub">Tổng quan công việc của bạn hôm nay</div>
                        <div class="welcome-time"><i class="fas fa-calendar-alt"></i> <%=now%></div>
                    </div>
                    <a href="<%=ctx%>/technicianTasks" class="welcome-btn"><i class="fas fa-arrow-right" style="margin-right:6px"></i>Xem công việc</a>
                </div>

                <!-- Stats -->
                <div class="stats">
                    <a href="<%=ctx%>/technicianWorkHistory" class="sc sc-blue">
                        <div class="sc-icon"><i class="fas fa-layer-group"></i></div>
                        <div class="sc-val"><%=total%></div><div class="sc-lbl">Tổng công việc</div>
                    </a>
                    <a href="<%=ctx%>/technicianTasks?status=Assigned" class="sc sc-info">
                        <div class="sc-icon"><i class="fas fa-inbox"></i></div>
                        <div class="sc-val"><%=assigned%></div><div class="sc-lbl">Đã được giao</div>
                    </a>
                    <a href="<%=ctx%>/technicianTasks?status=In+Progress" class="sc sc-amber">
                        <div class="sc-icon"><i class="fas fa-spinner"></i></div>
                        <div class="sc-val"><%=inProgress%></div><div class="sc-lbl">Đang thực hiện</div>
                    </a>
                    <a href="<%=ctx%>/technicianTasks?status=Completed" class="sc sc-green">
                        <div class="sc-icon"><i class="fas fa-check-circle"></i></div>
                        <div class="sc-val"><%=completed%></div><div class="sc-lbl">Hoàn thành</div>
                    </a>
                    <a href="<%=ctx%>/technicianTasks?status=Cancelled" class="sc sc-red">
                        <div class="sc-icon"><i class="fas fa-times-circle"></i></div>
                        <div class="sc-val"><%=cancelled%></div><div class="sc-lbl">Đã hủy</div>
                    </a>
                </div>

                <!-- Bottom grid: Quick Actions + Profile Info -->
                <div class="grid2">
                    <!-- Quick Actions -->
                    <div class="card">
                        <div class="card-hd"><span class="card-title"><i class="fas fa-bolt" style="color:var(--amber)"></i> Thao tác nhanh</span></div>
                        <div class="card-body">
                            <div class="shortcut-grid">
                                <a href="<%=ctx%>/technicianTasks" class="shortcut-btn blue">
                                    <i class="fas fa-tasks"></i><span>Công việc của tôi</span>
                                </a>
                                <a href="<%=ctx%>/technicianTasks?status=Assigned" class="shortcut-btn green">
                                    <i class="fas fa-inbox"></i><span>Việc mới giao</span>
                                </a>
                                <a href="<%=ctx%>/technicianTasks?status=In+Progress" class="shortcut-btn amber">
                                    <i class="fas fa-spinner"></i><span>Đang thực hiện</span>
                                </a>
                                <a href="<%=ctx%>/technicianReports" class="shortcut-btn green">
                                    <i class="fas fa-clipboard-list"></i><span>Báo cáo sửa chữa</span>
                                </a>
                                <a href="<%=ctx%>/technicianContracts" class="shortcut-btn purple">
                                    <i class="fas fa-file-contract"></i><span>Hợp đồng</span>
                                </a>
                                <a href="<%=ctx%>/technicianContracts?action=equipment" class="shortcut-btn teal">
                                    <i class="fas fa-desktop"></i><span>Kho thiết bị</span>
                                </a>
                                <a href="<%=ctx%>/technicianWorkHistory" class="shortcut-btn red">
                                    <i class="fas fa-history"></i><span>Lịch sử</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Profile Info -->
                    <div class="card">
                        <div class="card-hd"><span class="card-title"><i class="fas fa-user-circle" style="color:var(--primary-2)"></i> Thông tin của tôi</span></div>
                        <div class="card-body">
                            <div style="display:flex;align-items:center;gap:14px;margin-bottom:16px;padding-bottom:16px;border-bottom:1px solid var(--border-light2)">
                                <div style="width:52px;height:52px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:1.3rem;font-weight:700;flex-shrink:0;overflow:hidden">
                                    <%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%><img src="<%=ctx%><%=me.getAvatarUrl()%>" alt="" style="width:52px;height:52px;object-fit:cover;border-radius:50%"><%}else{%><%=initials%><%}%>
                                </div>
                                <div>
                                    <div style="font-size:.95rem;font-weight:700;color:var(--text-h)"><%=me.getFullName()!=null?me.getFullName():""%></div>
                                    <div style="font-size:.75rem;color:var(--text-s);margin-top:2px"><%=me.getEmail()!=null?me.getEmail():""%></div>
                                </div>
                            </div>
                            <div class="info-item"><span class="info-label">Username</span><span class="info-val"><%=me.getUsername()%></span></div>
                            <div class="info-item"><span class="info-label">Điện thoại</span><span class="info-val"><%=me.getPhone()!=null?me.getPhone():"—"%></span></div>
                            <div class="info-item" style="border-bottom:none;padding-top:14px">
                                <a href="<%=ctx%>/profile" style="font-size:.8rem;font-weight:700;color:var(--primary-2);text-decoration:none"><i class="fas fa-edit" style="margin-right:5px"></i>Chỉnh sửa hồ sơ</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </body>
</html>
