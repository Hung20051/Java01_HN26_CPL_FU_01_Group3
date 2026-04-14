<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Role, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (request.getAttribute("editUser") == null) {
        response.sendRedirect(request.getContextPath() + "/user/list");
        return;
    }
    User       editUser = (User)       request.getAttribute("editUser");
    List<Role> roles    = (List<Role>) request.getAttribute("roles");
    String success  = request.getParameter("success");
    String error    = request.getParameter("error");
    String initTab  = request.getParameter("tab");
    if (initTab == null) initTab = "account";
    String ctx      = request.getContextPath();
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";

    String addrFull = editUser.getAddressFull();
    if (addrFull == null || addrFull.isBlank()) addrFull = editUser.buildFullAddress();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Edit User — DRSMS</title>
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

                /* Status colors */
                --purple:  #7c3aed;
                --green:   #16a34a;
                --red:     #dc2626;
                --amber:   #d97706;
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
            /* Admin logo — amber exception */
            .sb-logo{
                width:36px;
                height:36px;
                background:linear-gradient(135deg,#f59e0b,#f97316);
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem;
                box-shadow:0 4px 12px rgba(245,158,11,0.4);
                flex-shrink:0;
            }
            .sb-name{
                color:#fff;
                font-size:1.05rem;
                font-weight:800;
                letter-spacing:-.3px
            }
            /* Admin role badge — amber exception */
            .sb-badge{
                display:inline-flex;
                align-items:center;
                background:rgba(217,119,6,0.2);
                border:1px solid rgba(217,119,6,0.35);
                color:#fbbf24;
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
            /* Admin avatar — amber exception */
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:linear-gradient(135deg,#f59e0b,#f97316);
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

            /* ═══════════ MAIN ═══════════ */
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
            .topbar-title{
                font-size:1.15rem;
                font-weight:800;
                color:var(--text-h);
                letter-spacing:-.3px;
                display:flex;
                align-items:center;
                gap:9px
            }
            .topbar-title i{
                color:var(--primary-2);
                font-size:.95rem
            }
            .topbar-sub{
                color:var(--text-s);
                font-size:.78rem;
                margin-top:2px
            }
            .btn-back{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:8px 16px;
                background:#fff;
                color:var(--text-m);
                border:1.5px solid var(--border-light);
                text-decoration:none;
                font-size:.82rem;
                font-weight:600;
                border-radius:9px;
                transition:all .2s;
            }
            .btn-back:hover{
                background:#f3f4f6;
                color:var(--text-b)
            }
            .content{
                padding:24px 28px 60px;
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

            /* Alerts */
            .alert{
                display:flex;
                align-items:center;
                gap:10px;
                padding:12px 16px;
                border-radius:12px;
                margin-bottom:18px;
                font-size:.84rem;
                animation:cardIn .4s ease both;
            }
            .alert i{
                flex-shrink:0
            }
            .alert-ok {
                background:#d1fae5;
                border:1px solid #a7f3d0;
                color:#065f46
            }
            .alert-ok  i{
                color:var(--green)
            }
            .alert-err{
                background:#fee2e2;
                border:1px solid #fca5a5;
                color:#991b1b
            }
            .alert-err i{
                color:var(--red)
            }

            /* Tab nav */
            .tab-nav{
                display:flex;
                gap:4px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:12px;
                padding:4px;
                margin-bottom:22px;
                animation:cardIn .3s ease both;
                box-shadow:0 1px 4px rgba(0,0,0,0.04);
            }
            .tab-btn{
                flex:1;
                display:flex;
                align-items:center;
                justify-content:center;
                gap:7px;
                padding:9px 14px;
                border-radius:9px;
                border:none;
                background:none;
                cursor:pointer;
                font-family:'Sora',sans-serif;
                font-size:.8rem;
                font-weight:600;
                color:var(--text-m);
                transition:all .2s
            }
            .tab-btn i{
                font-size:.75rem
            }
            .tab-btn:hover{
                color:var(--text-b);
                background:#f3f4f6
            }
            .tab-btn.active{
                background:var(--primary-light);
                color:var(--primary-2);
                border:1.5px solid rgba(99,102,241,0.25)
            }

            /* Card */
            .card{
                background:var(--bg-card);
                border:1.5px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                margin-bottom:16px;
                animation:cardIn .45s ease both;
            }
            .card-header{
                display:flex;
                align-items:center;
                gap:10px;
                padding:14px 22px;
                border-bottom:1px solid var(--border-light2);
                font-size:.87rem;
                font-weight:700;
                color:var(--text-h);
                background:#fafbff;
            }
            .card-header i{
                color:var(--primary-2)
            }
            .card-header.amber  i{
                color:var(--amber)
            }
            .card-header.green  i{
                color:var(--green)
            }
            .card-header.purple i{
                color:var(--purple)
            }
            .card-header.info   i{
                color:var(--info)
            }
            .card-header.danger i{
                color:var(--red)
            }
            .card-body{
                padding:22px
            }

            /* Form */
            .fg-1{
                display:grid;
                grid-template-columns:1fr;
                gap:16px
            }
            .fg-2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:16px
            }
            .fg-3{
                display:grid;
                grid-template-columns:1fr 1fr 1fr;
                gap:16px
            }
            .form-group{
                display:flex;
                flex-direction:column;
                gap:6px
            }
            .form-group label{
                font-size:.72rem;
                font-weight:700;
                color:var(--text-s);
                text-transform:uppercase;
                letter-spacing:.6px;
                display:flex;
                align-items:center;
                gap:6px
            }
            .form-group label i{
                font-size:.65rem
            }
            .form-group input,
            .form-group select,
            .form-group textarea{
                padding:10px 13px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:9px;
                font-size:.875rem;
                font-family:'Sora',sans-serif;
                color:var(--text-b);
                outline:none;
                transition:all .2s;
            }
            .form-group textarea{
                resize:vertical;
                min-height:82px;
                line-height:1.6
            }
            .form-group input::placeholder,.form-group textarea::placeholder{
                color:var(--text-s)
            }
            .form-group select option{
                background:#fff;
                color:var(--text-b)
            }
            .form-group input:focus,.form-group select:focus,.form-group textarea:focus{
                border-color:rgba(79,70,229,0.4);
                background:#faf9ff;
                box-shadow:0 0 0 3px rgba(79,70,229,0.07);
            }
            .form-group input:disabled{
                background:#f3f4f6;
                color:var(--text-s);
                cursor:not-allowed;
                border-color:var(--border-light2)
            }
            .hint{
                font-size:.72rem;
                color:var(--text-s);
                display:flex;
                align-items:center;
                gap:5px
            }

            /* Section label inside card */
            .section-lbl{
                font-size:.68rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.2px;
                color:var(--primary-2);
                margin:20px 0 12px;
                display:flex;
                align-items:center;
                gap:8px
            }
            .section-lbl::after{
                content:'';
                flex:1;
                height:1px;
                background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)
            }
            .section-lbl i{
                font-size:.65rem
            }

            /* Roles grid */
            .roles-grid{
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:8px
            }
            .role-option{
                display:flex;
                align-items:center;
                gap:9px;
                padding:10px 13px;
                border:1.5px solid var(--border-light);
                border-radius:10px;
                cursor:pointer;
                font-size:.8rem;
                color:var(--text-b);
                background:#fafbff;
                transition:all .2s
            }
            .role-option:hover{
                border-color:rgba(79,70,229,0.35);
                background:var(--primary-light);
                color:var(--primary-2)
            }
            .role-option input[type="radio"]{
                accent-color:var(--primary);
                width:14px;
                height:14px;
                flex-shrink:0
            }

            /* Password */
            .pass-wrap{
                position:relative
            }
            .pass-wrap input{
                width:100%;
                padding-right:42px
            }
            .pass-eye{
                position:absolute;
                right:12px;
                top:50%;
                transform:translateY(-50%);
                cursor:pointer;
                color:var(--text-s);
                background:none;
                border:none;
                font-size:.85rem;
                transition:color .2s
            }
            .pass-eye:hover{
                color:var(--primary-2)
            }

            /* Address preview bar */
            .addr-bar{
                display:none;
                align-items:center;
                gap:10px;
                margin-top:10px;
                padding:11px 14px;
                background:#e0f2fe;
                border:1.5px solid #bae6fd;
                border-radius:10px;
                font-size:.8rem
            }
            .addr-bar i{
                color:var(--info);
                flex-shrink:0
            }
            .addr-bar span{
                color:var(--text-b);
                flex:1
            }
            .addr-bar a{
                color:var(--info);
                text-decoration:none;
                font-weight:600;
                font-size:.75rem;
                white-space:nowrap
            }
            .addr-bar a:hover{
                color:var(--primary)
            }

            /* Quick info badges */
            .badge-row{
                display:flex;
                gap:8px;
                flex-wrap:wrap;
                margin-bottom:18px
            }
            .badge{
                display:inline-flex;
                align-items:center;
                gap:5px;
                padding:5px 11px;
                border-radius:8px;
                font-size:.73rem;
                font-weight:600
            }
            .badge-blue  {
                background:var(--primary-light);
                color:var(--primary-2);
                border:1px solid rgba(99,102,241,0.2)
            }
            .badge-amber {
                background:#fef3c7;
                color:var(--amber);
                border:1px solid #fde68a
            }
            .badge-green {
                background:#d1fae5;
                color:var(--green);
                border:1px solid #a7f3d0
            }
            .badge-purple{
                background:#ede9fe;
                color:var(--purple);
                border:1px solid rgba(124,58,237,0.2)
            }

            /* Form actions */
            .form-actions{
                display:flex;
                justify-content:flex-end;
                gap:9px;
                margin-top:20px;
                padding-top:16px;
                border-top:1.5px solid var(--border-light)
            }
            .btn{
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:10px 22px;
                border-radius:10px;
                font-size:.875rem;
                font-weight:700;
                font-family:'Sora',sans-serif;
                border:none;
                cursor:pointer;
                text-decoration:none;
                transition:all .2s
            }
            .btn-cancel{
                background:#fff;
                color:var(--text-m);
                border:1.5px solid var(--border-light)
            }
            .btn-cancel:hover{
                background:#f3f4f6;
                color:var(--text-b)
            }
            .btn-blue {
                background:var(--primary);
                color:#fff;
                box-shadow:0 4px 14px rgba(79,70,229,0.28)
            }
            .btn-blue:hover{
                background:#4338ca;
                transform:translateY(-1px);
                box-shadow:0 6px 20px rgba(79,70,229,0.4)
            }
            .btn-amber{
                background:var(--amber);
                color:#fff;
                box-shadow:0 4px 14px rgba(217,119,6,0.25)
            }
            .btn-amber:hover{
                background:#b45309;
                transform:translateY(-1px)
            }
            .btn-green{
                background:var(--green);
                color:#fff;
                box-shadow:0 4px 14px rgba(22,163,74,0.28)
            }
            .btn-green:hover{
                background:#15803d;
                transform:translateY(-1px)
            }

            /* Tab panes */
            .tab-pane{
                display:none;
                animation:cardIn .3s ease both
            }
            .tab-pane.active{
                display:block
            }
        </style>
    </head>
    <body>

        <!-- ═══ SIDEBAR ═══ -->
        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-cog"></i></div>
                <div><div class="sb-name">DRSMS</div><div class="sb-badge">Admin</div></div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/admin.jsp" class="sb-item"><i class="fas fa-tachometer-alt"></i> Dashboard</a>
                <div class="sb-lbl">Management</div>
                <a href="<%=ctx%>/user/list" class="sb-item on"><i class="fas fa-users"></i> Users</a>
                <a href="<%=ctx%>/role/list" class="sb-item"><i class="fas fa-user-tag"></i> Roles</a>
            </nav>
            <div class="sb-foot">
                <a href="<%=ctx%>/profile" class="sb-user">
                    <div class="sb-ava">
                        <%if(currentUser.getAvatarUrl()!=null&&!currentUser.getAvatarUrl().isEmpty()){%>
                        <img src="<%=ctx%><%=currentUser.getAvatarUrl()%>" alt="avatar">
                        <%}else{%><%=initials%><%}%>
                    </div>
                    <div>
                        <div class="sb-uname"><%=currentUser.getFullName()%></div>
                        <div class="sb-urole">Administrator</div>
                    </div>
                </a>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
            </div>
        </aside>

        <!-- ═══ MAIN ═══ -->
        <main class="main">

            <div class="topbar">
                <div>
                    <div class="topbar-title"><i class="fas fa-user-pen"></i> Edit User</div>
                    <div class="topbar-sub">
                        <%=editUser.getFullName()%> &nbsp;·&nbsp; @<%=editUser.getUsername()%>
                        &nbsp;·&nbsp; <span style="color:<%=editUser.isActive()?"var(--green)":"var(--red)"%>">
                            <%=editUser.isActive()?"Active":"Locked"%></span>
                    </div>
                </div>
                <a href="<%=ctx%>/user/list" class="btn-back"><i class="fas fa-arrow-left"></i> Back</a>
            </div>

            <div class="content">

                <%if("updated".equals(success)){%>
                <div class="alert alert-ok"><i class="fas fa-check-circle"></i> Account information updated successfully.</div>
                <%}%>
                <%if("personal_updated".equals(success)){%>
                <div class="alert alert-ok"><i class="fas fa-check-circle"></i> Personal info &amp; address updated successfully.</div>
                <%}%>
                <%if("password_changed".equals(success)){%>
                <div class="alert alert-ok"><i class="fas fa-check-circle"></i> Password changed successfully.</div>
                <%}%>
                <%if("password_mismatch".equals(error)){%>
                <div class="alert alert-err"><i class="fas fa-triangle-exclamation"></i> Confirm password does not match.</div>
                <%}%>
                <%if("invalid_date".equals(error)){%>
                <div class="alert alert-err"><i class="fas fa-triangle-exclamation"></i> Invalid date of birth format.</div>
                <%}%>

                <!-- TAB NAV -->
                <div class="tab-nav">
                    <button class="tab-btn" id="btn-account"  onclick="switchTab('account')">
                        <i class="fas fa-user-pen"></i> Account &amp; Role
                    </button>
                    <button class="tab-btn" id="btn-personal" onclick="switchTab('personal')">
                        <i class="fas fa-map-location-dot"></i> Personal Info
                    </button>
                    <button class="tab-btn" id="btn-password" onclick="switchTab('password')">
                        <i class="fas fa-key"></i> Password
                    </button>
                </div>

                <!-- ══ TAB 1: ACCOUNT & ROLE ══ -->
                <div id="pane-account" class="tab-pane">
                    <form method="post" action="<%=ctx%>/user/edit">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id"     value="<%=editUser.getId()%>">

                        <div class="card">
                            <div class="card-header"><i class="fas fa-user-pen"></i> Account Information</div>
                            <div class="card-body">
                                <div class="fg-2">
                                    <div class="form-group">
                                        <label><i class="fas fa-user"></i> Username</label>
                                        <input type="text" value="<%=editUser.getUsername()!=null?editUser.getUsername():""%>" disabled>
                                        <span class="hint"><i class="fas fa-lock"></i> Cannot be changed</span>
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-envelope"></i> Email <span style="color:var(--red)">*</span></label>
                                        <input type="email" name="email" value="<%=editUser.getEmail()!=null?editUser.getEmail():""%>" required>
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-id-card"></i> Full Name</label>
                                        <input type="text" name="fullName" value="<%=editUser.getFullName()!=null?editUser.getFullName():""%>">
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-phone"></i> Phone</label>
                                        <input type="text" name="phone" value="<%=editUser.getPhone()!=null?editUser.getPhone():""%>">
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-toggle-on"></i> Status</label>
                                        <select name="active">
                                            <option value="1" <%=editUser.isActive() ?"selected":""%>>Active</option>
                                            <option value="0" <%=!editUser.isActive()?"selected":""%>>Locked</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="section-lbl"><i class="fas fa-user-tag"></i> Role Assignment</div>
                                <div class="roles-grid">
                                    <%if(roles!=null) for(Role r:roles){%>
                                    <label class="role-option">
                                        <input type="radio" name="roleId" value="<%=r.getId()%>"
                                               <%=r.getId()==editUser.getRoleId()?"checked":""%>>
                                        <%=r.getName().replace("_"," ")%>
                                    </label>
                                    <%}%>
                                </div>
                                <span class="hint" style="margin-top:8px;display:flex">
                                    <i class="fas fa-circle-info"></i> Role change takes effect on next login
                                </span>

                                <div class="form-actions">
                                    <a href="<%=ctx%>/user/list" class="btn btn-cancel"><i class="fas fa-xmark"></i> Cancel</a>
                                    <button type="submit" class="btn btn-blue"><i class="fas fa-floppy-disk"></i> Save Account</button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- ══ TAB 2: PERSONAL INFO ══ -->
                <div id="pane-personal" class="tab-pane">
                    <form method="post" action="<%=ctx%>/user/edit">
                        <input type="hidden" name="action" value="updatePersonalInfo">
                        <input type="hidden" name="id"     value="<%=editUser.getId()%>">

                        <div class="badge-row">
                            <%if(editUser.getAddressCity()!=null&&!editUser.getAddressCity().isEmpty()){%>
                            <span class="badge badge-blue"><i class="fas fa-city"></i> <%=editUser.getAddressCity()%></span>
                            <%}%>
                            <%if(editUser.getHometown()!=null&&!editUser.getHometown().isEmpty()){%>
                            <span class="badge badge-amber"><i class="fas fa-map-pin"></i> <%=editUser.getHometown()%></span>
                            <%}%>
                            <%if(editUser.getDateOfBirth()!=null){%>
                            <span class="badge badge-green"><i class="fas fa-cake-candles"></i> <%=editUser.getDateOfBirthFormatted()%> (<%=editUser.getAge()%> yrs)</span>
                            <%}%>
                            <%if(editUser.getGender()!=null&&!editUser.getGender().isEmpty()){%>
                            <span class="badge badge-purple"><i class="fas fa-venus-mars"></i> <%=editUser.getGenderLabel()%></span>
                            <%}%>
                            <%if(editUser.getCompanyName()!=null&&!editUser.getCompanyName().isEmpty()){%>
                            <span class="badge badge-blue"><i class="fas fa-building"></i> <%=editUser.getCompanyName()%></span>
                            <%}%>
                        </div>

                        <!-- Address -->
                        <div class="card">
                            <div class="card-header info"><i class="fas fa-location-dot"></i> Service Address (Technician Navigation)</div>
                            <div class="card-body">
                                <div class="fg-1">
                                    <div class="form-group">
                                        <label><i class="fas fa-road"></i> Street / House Number</label>
                                        <input type="text" name="addressStreet" id="addrStreet"
                                               value="<%=editUser.getAddressStreet()!=null?editUser.getAddressStreet():""%>"
                                               placeholder="e.g. 12 Nguyen Trai" oninput="previewAddr()">
                                    </div>
                                </div>
                                <div class="fg-3" style="margin-top:14px">
                                    <div class="form-group">
                                        <label><i class="fas fa-map"></i> Ward / Commune</label>
                                        <input type="text" name="addressWard" id="addrWard"
                                               value="<%=editUser.getAddressWard()!=null?editUser.getAddressWard():""%>"
                                               placeholder="e.g. Thuong Dinh Ward" oninput="previewAddr()">
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-map"></i> District</label>
                                        <input type="text" name="addressDistrict" id="addrDistrict"
                                               value="<%=editUser.getAddressDistrict()!=null?editUser.getAddressDistrict():""%>"
                                               placeholder="e.g. Thanh Xuan" oninput="previewAddr()">
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-city"></i> City / Province</label>
                                        <input type="text" name="addressCity" id="addrCity"
                                               value="<%=editUser.getAddressCity()!=null?editUser.getAddressCity():""%>"
                                               placeholder="e.g. Ha Noi" oninput="previewAddr()">
                                    </div>
                                </div>
                                <div class="addr-bar" id="addrBar">
                                    <i class="fas fa-location-dot"></i>
                                    <span id="addrText"></span>
                                    <a id="addrLink" href="#" target="_blank"><i class="fab fa-google"></i> Google Maps</a>
                                </div>
                            </div>
                        </div>

                        <!-- Personal details -->
                        <div class="card">
                            <div class="card-header"><i class="fas fa-user"></i> Personal Details</div>
                            <div class="card-body">
                                <div class="fg-2">
                                    <div class="form-group">
                                        <label><i class="fas fa-id-card"></i> Full Name</label>
                                        <input type="text" name="fullName" value="<%=editUser.getFullName()!=null?editUser.getFullName():""%>">
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-phone"></i> Phone</label>
                                        <input type="tel" name="phone" value="<%=editUser.getPhone()!=null?editUser.getPhone():""%>" placeholder="e.g. 0901 234 567">
                                    </div>
                                </div>
                                <div class="fg-3" style="margin-top:14px">
                                    <div class="form-group">
                                        <label><i class="fas fa-cake-candles"></i> Date of Birth</label>
                                        <input type="date" name="dateOfBirth" value="<%=editUser.getDateOfBirthIso()%>" max="<%=java.time.LocalDate.now().toString()%>">
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-venus-mars"></i> Gender</label>
                                        <select name="gender">
                                            <option value="">— Select —</option>
                                            <option value="MALE"   <%="MALE".equals(editUser.getGender())?"selected":""%>>Male</option>
                                            <option value="FEMALE" <%="FEMALE".equals(editUser.getGender())?"selected":""%>>Female</option>
                                            <option value="OTHER"  <%="OTHER".equals(editUser.getGender())?"selected":""%>>Other</option>
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-map-pin"></i> Hometown</label>
                                        <input type="text" name="hometown" value="<%=editUser.getHometown()!=null?editUser.getHometown():""%>" placeholder="e.g. Nam Dinh">
                                    </div>
                                </div>
                                <div class="fg-2" style="margin-top:14px">
                                    <div class="form-group">
                                        <label><i class="fas fa-id-badge"></i> National ID (CCCD)</label>
                                        <input type="text" name="nationalId" value="<%=editUser.getNationalId()!=null?editUser.getNationalId():""%>" placeholder="12-digit ID number" maxlength="20">
                                        <span class="hint"><i class="fas fa-lock"></i> Confidential — internal use only</span>
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-building"></i> Company / Organization</label>
                                        <input type="text" name="companyName" value="<%=editUser.getCompanyName()!=null?editUser.getCompanyName():""%>" placeholder="Company name (if applicable)">
                                    </div>
                                </div>
                                <div class="fg-1" style="margin-top:14px">
                                    <div class="form-group">
                                        <label><i class="fas fa-quote-left"></i> Bio / Notes</label>
                                        <textarea name="bio" placeholder="Short description about the user..."><%=editUser.getBio()!=null?editUser.getBio():""%></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Emergency contact -->
                        <div class="card">
                            <div class="card-header danger"><i class="fas fa-phone-volume"></i> Emergency Contact</div>
                            <div class="card-body">
                                <span class="hint" style="margin-bottom:14px;display:flex">
                                    <i class="fas fa-circle-info"></i>
                                    Used when technician cannot reach the user directly.
                                </span>
                                <div class="fg-3">
                                    <div class="form-group">
                                        <label><i class="fas fa-user"></i> Contact Name</label>
                                        <input type="text" name="emergencyName" value="<%=editUser.getEmergencyName()!=null?editUser.getEmergencyName():""%>" placeholder="e.g. Nguyen Van A">
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-phone"></i> Phone Number</label>
                                        <input type="tel" name="emergencyPhone" value="<%=editUser.getEmergencyPhone()!=null?editUser.getEmergencyPhone():""%>" placeholder="e.g. 0912 345 678">
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-people-arrows"></i> Relationship</label>
                                        <select name="emergencyRelation">
                                            <option value="">— Select —</option>
                                            <%
                                                String er = editUser.getEmergencyRelation();
                                                String[] rels  = {"Spouse","Parent","Child","Sibling","Friend","Colleague","Other"};
                                                String[] relVi = {"Vợ/Chồng","Cha/Mẹ","Con","Anh/Chị/Em","Bạn bè","Đồng nghiệp","Khác"};
                                                for(int i=0;i<rels.length;i++){
                                                    boolean sel = rels[i].equals(er) || relVi[i].equals(er);
                                            %>
                                            <option value="<%=rels[i]%>" <%=sel?"selected":""%>><%=rels[i]%></option>
                                            <%}%>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-actions">
                                    <a href="<%=ctx%>/user/list" class="btn btn-cancel"><i class="fas fa-xmark"></i> Cancel</a>
                                    <button type="submit" class="btn btn-green"><i class="fas fa-floppy-disk"></i> Save Personal Info</button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- ══ TAB 3: PASSWORD ══ -->
                <div id="pane-password" class="tab-pane">
                    <form method="post" action="<%=ctx%>/user/edit">
                        <input type="hidden" name="action" value="changePassword">
                        <input type="hidden" name="id"     value="<%=editUser.getId()%>">
                        <div class="card">
                            <div class="card-header amber"><i class="fas fa-key"></i> Change Password</div>
                            <div class="card-body">
                                <div class="fg-2">
                                    <div class="form-group">
                                        <label><i class="fas fa-lock"></i> New Password <span style="color:var(--red)">*</span></label>
                                        <div class="pass-wrap">
                                            <input type="password" name="newPassword" id="newPass" required placeholder="Enter new password">
                                            <button type="button" class="pass-eye" onclick="togglePass('newPass', this)"><i class="fas fa-eye"></i></button>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label><i class="fas fa-lock"></i> Confirm Password <span style="color:var(--red)">*</span></label>
                                        <div class="pass-wrap">
                                            <input type="password" name="confirmPassword" id="confPass" required placeholder="Re-enter new password" oninput="checkMatch()">
                                            <button type="button" class="pass-eye" onclick="togglePass('confPass', this)"><i class="fas fa-eye"></i></button>
                                        </div>
                                        <span class="hint" id="matchHint"></span>
                                    </div>
                                </div>
                                <div class="form-actions">
                                    <button type="submit" class="btn btn-amber"><i class="fas fa-key"></i> Change Password</button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>

            </div>
        </main>

        <script>
            function switchTab(name) {
                ['account', 'personal', 'password'].forEach(t => {
                    document.getElementById('pane-' + t).classList.toggle('active', t === name);
                    document.getElementById('btn-' + t).classList.toggle('active', t === name);
                });
            }
            switchTab('<%=initTab%>');

            function previewAddr() {
                const s = (document.getElementById('addrStreet')?.value || '').trim();
                const w = (document.getElementById('addrWard')?.value || '').trim();
                const d = (document.getElementById('addrDistrict')?.value || '').trim();
                const c = (document.getElementById('addrCity')?.value || '').trim();
                const parts = [s, w, d, c].filter(Boolean);
                const bar = document.getElementById('addrBar');
                if (parts.length >= 2) {
                    const full = parts.join(', ');
                    document.getElementById('addrText').textContent = full;
                    document.getElementById('addrLink').href = 'https://www.google.com/maps/search/' + encodeURIComponent(full);
                    bar.style.display = 'flex';
                } else {
                    bar.style.display = 'none';
                }
            }
            window.addEventListener('DOMContentLoaded', previewAddr);

            function togglePass(id, btn) {
                const inp = document.getElementById(id);
                inp.type = inp.type === 'password' ? 'text' : 'password';
                btn.innerHTML = inp.type === 'text' ? '<i class="fas fa-eye-slash"></i>' : '<i class="fas fa-eye"></i>';
            }
            function checkMatch() {
                const nv = document.getElementById('newPass').value;
                const cv = document.getElementById('confPass').value;
                const hint = document.getElementById('matchHint');
                if (!cv) {
                    hint.textContent = '';
                    return;
                }
                hint.innerHTML = nv === cv
                        ? '<span style="color:var(--green)"><i class="fas fa-check"></i> Passwords match</span>'
                        : '<span style="color:var(--red)"><i class="fas fa-times"></i> Passwords do not match</span>';
            }
        </script>
    </body>
</html>
