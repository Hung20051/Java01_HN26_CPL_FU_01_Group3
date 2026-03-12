<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    User u = (User) request.getAttribute("profileUser");
    if (u == null) u = me;
    String ctx = request.getContextPath();

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");

    String dashLink = "/customerDashboard";
    String roleLabel = "Customer";
    String roleIcon = "fas fa-user";
    if ("CUSTOMER_SUPPORT".equals(me.getRoleName())) { dashLink = "/supportDashboard"; roleLabel = "Customer Support"; roleIcon = "fas fa-headset"; }
    else if ("STOREKEEPER".equals(me.getRoleName()))  { dashLink = "/dashboard.jsp"; roleLabel = "Store Keeper"; roleIcon = "fas fa-store"; }
    else if ("ADMIN".equals(me.getRoleName()))         { dashLink = "/admin.jsp"; roleLabel = "Admin"; roleIcon = "fas fa-crown"; }

    String avatarLetter = u.getFullName() != null && !u.getFullName().isEmpty()
        ? u.getFullName().substring(0,1).toUpperCase() : "?";

    String tab = request.getParameter("tab");
    if (tab == null) tab = "info";
    boolean isSocial = me.getPassword() == null || me.getPassword().isEmpty();
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>My Profile — DRSMS</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
        <style>
            /* ══════════════════════════════════════════
               ROOT & RESET
            ══════════════════════════════════════════ */
            :root {
                --ink:    #08091a;
                --ink-2:  #0d1030;
                --glass:  rgba(255,255,255,0.04);
                --glass-2:rgba(255,255,255,0.08);
                --rim:    rgba(255,255,255,0.10);
                --rim-2:  rgba(255,255,255,0.18);
                --gold:   #c9a84c;
                --gold-2: #f0d080;
                --gold-glow: rgba(201,168,76,0.3);
                --blue:   #4f7ef8;
                --blue-2: #93b4fd;
                --text:   #f0eeea;
                --text-2: #b8b4ac;
                --muted:  #6a6880;
                --success:#56cfaa;
                --danger: #f0706a;
                --sidebar-w: 340px;
            }
            *, *::before, *::after {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            html {
                height: 100%;
            }
            body {
                font-family: 'DM Sans', sans-serif;
                background: var(--ink);
                color: var(--text);
                min-height: 100vh;
                overflow-x: hidden;
            }
            ::-webkit-scrollbar {
                width: 4px;
            }
            ::-webkit-scrollbar-track {
                background: transparent;
            }
            ::-webkit-scrollbar-thumb {
                background: rgba(201,168,76,0.3);
                border-radius: 4px;
            }

            /* ══════════════════════════════════════════
               AURORA CANVAS
            ══════════════════════════════════════════ */
            #aurora {
                position: fixed;
                inset: 0;
                z-index: 0;
                pointer-events: none;
            }

            /* ══════════════════════════════════════════
               LAYOUT
            ══════════════════════════════════════════ */
            .layout {
                display: flex;
                min-height: 100vh;
                position: relative;
                z-index: 1;
            }

            /* ──────── LEFT SIDEBAR ──────── */
            .sidebar {
                width: var(--sidebar-w);
                flex-shrink: 0;
                position: sticky;
                top: 0;
                height: 100vh;
                display: flex;
                flex-direction: column;
                padding: 32px 28px;
                border-right: 1px solid var(--rim);
                background: rgba(8,9,26,0.6);
                backdrop-filter: blur(24px);
            }

            .sb-back {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                color: var(--muted);
                text-decoration: none;
                font-size: .78rem;
                font-weight: 500;
                letter-spacing: .5px;
                text-transform: uppercase;
                padding: 8px 0;
                margin-bottom: 40px;
                transition: color .2s;
                border: none;
                background: none;
                cursor: pointer;
                font-family: inherit;
            }
            .sb-back:hover {
                color: var(--text-2);
            }
            .sb-back i {
                font-size: .7rem;
            }

            /* Avatar area */
            .sb-avatar-wrap {
                position: relative;
                width: 110px;
                height: 110px;
                margin: 0 auto 20px;
                cursor: pointer;
            }
            .sb-avatar-wrap:hover .sb-avatar-overlay {
                opacity: 1;
            }
            .sb-avatar {
                width: 110px;
                height: 110px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-family: 'Cormorant Garamond', serif;
                font-size: 3rem;
                font-weight: 600;
                color: var(--gold);
                background: radial-gradient(135deg at 30% 30%, rgba(201,168,76,.15), rgba(79,126,248,.1));
                border: 1.5px solid var(--gold);
                box-shadow: 0 0 40px rgba(201,168,76,.15), 0 0 80px rgba(79,126,248,.08);
                position: relative;
                overflow: hidden;
            }
            .sb-avatar img {
                width: 110px;
                height: 110px;
                border-radius: 50%;
                object-fit: cover;
            }
            .sb-avatar::before {
                content: '';
                position: absolute;
                inset: 0;
                background: conic-gradient(from 0deg, transparent 60%, rgba(201,168,76,.3) 80%, transparent 100%);
                animation: avatarSpin 6s linear infinite;
                border-radius: 50%;
            }
            @keyframes avatarSpin {
                to {
                    transform: rotate(360deg);
                }
            }
            .sb-avatar-overlay {
                position: absolute;
                inset: 0;
                border-radius: 50%;
                background: rgba(8,9,26,.65);
                display: flex;
                align-items: center;
                justify-content: center;
                color: var(--gold);
                font-size: 1.4rem;
                opacity: 0;
                transition: .25s;
                backdrop-filter: blur(4px);
            }

            /* Name & role */
            .sb-name {
                text-align: center;
                font-family: 'Cormorant Garamond', serif;
                font-size: 1.55rem;
                font-weight: 600;
                letter-spacing: -.2px;
                color: var(--text);
                line-height: 1.2;
                margin-bottom: 8px;
            }
            .sb-role {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                font-size: .72rem;
                font-weight: 500;
                letter-spacing: 1.5px;
                text-transform: uppercase;
                color: var(--gold);
                margin-bottom: 28px;
            }
            .sb-role i {
                font-size: .65rem;
            }

            /* Status pill */
            .sb-status {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                font-size: .75rem;
                font-weight: 500;
                color: var(--text-2);
                margin-bottom: 32px;
            }
            .sb-dot {
                width: 7px;
                height: 7px;
                border-radius: 50%;
                background: var(--success);
                box-shadow: 0 0 8px var(--success);
                animation: pulse 2.5s ease-in-out infinite;
            }
            @keyframes pulse {
                0%,100% {
                    box-shadow: 0 0 6px var(--success);
                }
                50%      {
                    box-shadow: 0 0 16px var(--success);
                }
            }

            /* Divider */
            .sb-divider {
                border: none;
                border-top: 1px solid var(--rim);
                margin: 0 0 24px;
            }

            /* Nav tabs */
            .sb-nav {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }
            .sb-tab {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 11px 14px;
                border-radius: 10px;
                border: 1px solid transparent;
                background: none;
                color: var(--muted);
                font-family: 'DM Sans', sans-serif;
                font-size: .84rem;
                font-weight: 500;
                cursor: pointer;
                transition: all .2s;
                text-align: left;
                width: 100%;
            }
            .sb-tab i {
                width: 16px;
                text-align: center;
                font-size: .8rem;
            }
            .sb-tab:hover {
                color: var(--text-2);
                background: var(--glass);
                border-color: var(--rim);
            }
            .sb-tab.active {
                color: var(--gold);
                background: rgba(201,168,76,.08);
                border-color: rgba(201,168,76,.25);
            }
            .sb-tab.active i {
                color: var(--gold);
            }

            /* Username chip at bottom */
            .sb-username {
                margin-top: auto;
                padding: 12px 14px;
                background: var(--glass);
                border: 1px solid var(--rim);
                border-radius: 10px;
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: .78rem;
                color: var(--text-2);
            }
            .sb-username i {
                color: var(--muted);
                font-size: .75rem;
            }

            /* ──────── MAIN CONTENT ──────── */
            .main {
                flex: 1;
                padding: 48px 52px 80px;
                min-width: 0;
            }

            /* Flash */
            .flash {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 13px 16px;
                border-radius: 12px;
                font-size: .83rem;
                font-weight: 500;
                margin-bottom: 28px;
                animation: slideDown .3s ease;
            }
            @keyframes slideDown {
                from {
                    opacity:0;
                    transform:translateY(-8px);
                }
                to {
                    opacity:1;
                    transform:none;
                }
            }
            .flash-ok  {
                background: rgba(86,207,170,.08);
                color: var(--success);
                border: 1px solid rgba(86,207,170,.2);
            }
            .flash-err {
                background: rgba(240,112,106,.08);
                color: var(--danger);
                border: 1px solid rgba(240,112,106,.2);
            }

            /* Section header */
            .section-eyebrow {
                font-size: .65rem;
                letter-spacing: 2.5px;
                text-transform: uppercase;
                color: var(--gold);
                font-weight: 600;
                margin-bottom: 8px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .section-eyebrow::after {
                content:'';
                flex:1;
                height:1px;
                background: linear-gradient(to right, rgba(201,168,76,.3), transparent);
            }
            .section-title {
                font-family: 'Cormorant Garamond', serif;
                font-size: 2rem;
                font-weight: 300;
                letter-spacing: -.5px;
                color: var(--text);
                margin-bottom: 32px;
                line-height: 1.15;
            }
            .section-title em {
                font-style: italic;
                color: var(--text-2);
            }

            /* Tab content panels */
            .tab-panel {
                display: none;
                animation: fadeIn .3s ease;
            }
            .tab-panel.active {
                display: block;
            }
            @keyframes fadeIn {
                from {
                    opacity:0;
                    transform:translateY(10px);
                }
                to {
                    opacity:1;
                    transform:none;
                }
            }

            /* ── INFO GRID ── */
            .info-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 1px;
                background: var(--rim);
                border: 1px solid var(--rim);
                border-radius: 16px;
                overflow: hidden;
                margin-bottom: 28px;
            }
            .info-cell {
                background: var(--ink-2);
                padding: 22px 24px;
                transition: background .2s;
            }
            .info-cell:hover {
                background: rgba(201,168,76,.04);
            }
            .info-cell-label {
                font-size: .62rem;
                letter-spacing: 1.5px;
                text-transform: uppercase;
                color: var(--muted);
                font-weight: 600;
                margin-bottom: 7px;
                display: flex;
                align-items: center;
                gap: 6px;
            }
            .info-cell-label i {
                color: var(--gold);
                font-size: .6rem;
            }
            .info-cell-value {
                font-size: .92rem;
                font-weight: 500;
                color: var(--text);
            }
            .info-cell-value.empty {
                color: var(--muted);
                font-style: italic;
                font-weight: 300;
            }

            /* ── ACTION ROW ── */
            .action-row {
                display: flex;
                gap: 12px;
                flex-wrap: wrap;
                padding-top: 4px;
            }

            /* ── FORM CARD ── */
            .form-card {
                background: var(--ink-2);
                border: 1px solid var(--rim);
                border-radius: 16px;
                overflow: hidden;
            }
            .form-section {
                padding: 28px 32px;
                border-bottom: 1px solid var(--rim);
            }
            .form-section:last-child {
                border-bottom: none;
            }
            .form-section-label {
                font-size: .62rem;
                letter-spacing: 1.5px;
                text-transform: uppercase;
                color: var(--muted);
                font-weight: 600;
                margin-bottom: 18px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .form-section-label::after {
                content:'';
                flex:1;
                height:1px;
                background: var(--rim);
            }

            .field-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 16px;
            }
            .field {
                margin-bottom: 16px;
            }
            .field:last-child {
                margin-bottom: 0;
            }
            .field label {
                display: block;
                font-size: .7rem;
                font-weight: 600;
                letter-spacing: .5px;
                text-transform: uppercase;
                color: var(--text-2);
                margin-bottom: 8px;
            }
            .field input {
                width: 100%;
                padding: 12px 16px;
                background: rgba(255,255,255,.04);
                border: 1px solid var(--rim);
                border-radius: 10px;
                color: var(--text);
                font-family: 'DM Sans', sans-serif;
                font-size: .88rem;
                outline: none;
                transition: all .25s;
            }
            .field input::placeholder {
                color: var(--muted);
            }
            .field input:focus {
                border-color: rgba(201,168,76,.5);
                background: rgba(201,168,76,.04);
                box-shadow: 0 0 0 3px rgba(201,168,76,.08);
            }
            .field input[readonly] {
                color: var(--muted);
                opacity: .6;
                cursor: not-allowed;
            }
            .field-hint {
                font-size: .72rem;
                color: var(--muted);
                margin-top: 6px;
            }
            .pass-wrap {
                position: relative;
            }
            .pass-wrap input {
                padding-right: 44px;
            }
            .pass-eye {
                position: absolute;
                right: 13px;
                top: 50%;
                transform: translateY(-50%);
                background: none;
                border: none;
                color: var(--muted);
                cursor: pointer;
                font-size: .85rem;
                transition: color .2s;
            }
            .pass-eye:hover {
                color: var(--gold);
            }

            /* Strength */
            .strength-track {
                height: 3px;
                border-radius: 2px;
                margin-top: 8px;
                background: var(--rim);
                overflow: hidden;
            }
            .strength-fill {
                height: 100%;
                border-radius: 2px;
                transition: all .35s;
                width: 0;
            }
            .strength-label {
                font-size: .7rem;
                margin-top: 5px;
            }

            /* ── BUTTONS ── */
            .btn {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 11px 22px;
                border-radius: 10px;
                border: none;
                font-family: 'DM Sans', sans-serif;
                font-size: .84rem;
                font-weight: 600;
                cursor: pointer;
                transition: all .25s;
                text-decoration: none;
                letter-spacing: .2px;
            }
            .btn-gold {
                background: linear-gradient(135deg, var(--gold), var(--gold-2));
                color: #08091a;
                box-shadow: 0 4px 16px var(--gold-glow);
            }
            .btn-gold:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 28px rgba(201,168,76,.45);
            }
            .btn-ghost {
                background: var(--glass);
                color: var(--text-2);
                border: 1px solid var(--rim);
            }
            .btn-ghost:hover {
                border-color: var(--rim-2);
                color: var(--text);
                background: var(--glass-2);
            }
            .btn-sm {
                padding: 8px 16px;
                font-size: .78rem;
            }

            /* Form footer */
            .form-footer {
                padding: 20px 32px;
                display: flex;
                align-items: center;
                justify-content: flex-end;
                gap: 12px;
                border-top: 1px solid var(--rim);
                background: rgba(8,9,26,.4);
            }

            /* Social box */
            .social-tag {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 9px 14px;
                background: var(--glass);
                border: 1px solid var(--rim);
                border-radius: 10px;
                font-size: .8rem;
                color: var(--text-2);
            }
            .social-tag a {
                color: var(--blue-2);
                font-weight: 600;
                text-decoration: none;
            }
            .social-tag a:hover {
                color: white;
            }

            /* Empty state */
            .empty-state {
                text-align: center;
                padding: 64px 32px;
            }
            .empty-icon {
                width: 72px;
                height: 72px;
                border-radius: 50%;
                background: rgba(201,168,76,.08);
                border: 1px solid rgba(201,168,76,.2);
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 18px;
                font-size: 1.8rem;
                color: var(--gold);
            }
            .empty-title {
                font-family:'Cormorant Garamond',serif;
                font-size:1.4rem;
                font-weight:300;
                margin-bottom:8px;
            }
            .empty-sub {
                color: var(--muted);
                font-size:.85rem;
                max-width:340px;
                margin: 0 auto 28px;
                line-height:1.65;
            }
        </style>
    </head>
    <body>

        <!-- Aurora background -->
        <canvas id="aurora"></canvas>

        <div class="layout">

            <!-- ═══ SIDEBAR ═══ -->
            <aside class="sidebar">
                <a href="<%=ctx%><%=dashLink%>" class="sb-back">
                    <i class="fas fa-arrow-left"></i> Back to dashboard
                </a>

                <!-- Avatar -->
                <div class="sb-avatar-wrap" onclick="document.getElementById('avatarInput').click()" title="Change photo">
                    <div class="sb-avatar" id="avatarPreview">
                        <%if(u.getAvatarUrl()!=null&&!u.getAvatarUrl().isEmpty()){%>
                        <img src="<%=ctx%><%=u.getAvatarUrl()%>" alt="avatar">
                        <%}else{%>
                        <span><%=avatarLetter%></span>
                        <%}%>
                    </div>
                    <div class="sb-avatar-overlay"><i class="fas fa-camera"></i></div>
                </div>
                <input type="file" id="avatarInput" accept="image/jpeg,image/png,image/gif,image/webp" style="display:none" onchange="uploadAvatar(this)">

                <div class="sb-name"><%=u.getFullName()%></div>
                <div class="sb-role"><i class="<%=roleIcon%>"></i> <%=roleLabel%></div>
                <% if(u.isActive()) { %>
                <div class="sb-status"><div class="sb-dot"></div> Active account</div>
                <% } %>

                <hr class="sb-divider">

                <!-- Navigation -->
                <nav class="sb-nav">
                    <button class="sb-tab <%="info".equals(tab)?"active":""%>" onclick="switchTab('info', this)">
                        <i class="fas fa-id-card"></i> Account Overview
                    </button>
                    <button class="sb-tab <%="edit".equals(tab)?"active":""%>" onclick="switchTab('edit', this)">
                        <i class="fas fa-pen-nib"></i> Edit Profile
                    </button>
                    <% if (!isSocial) { %>
                    <button class="sb-tab <%="password".equals(tab)?"active":""%>" onclick="switchTab('password', this)">
                        <i class="fas fa-key"></i> Security
                    </button>
                    <% } %>
                </nav>

                <!-- Username chip -->
                <div class="sb-username">
                    <i class="fas fa-at"></i>
                    <span><%=u.getUsername()%></span>
                </div>
            </aside>

            <!-- ═══ MAIN ═══ -->
            <main class="main">

                <%if(flashOk!=null){%>
                <div class="flash flash-ok"><i class="fas fa-check-circle"></i> <%=flashOk%></div>
                <%}%>
                <%if(flashErr!=null){%>
                <div class="flash flash-err"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div>
                <%}%>

                <!-- ── TAB: OVERVIEW ── -->
                <div id="tab-info" class="tab-panel <%="info".equals(tab)?"active":""%>">
                    <div class="section-eyebrow">Account</div>
                    <div class="section-title">Your <em>profile</em> overview</div>

                    <div class="info-grid">
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-user"></i> Username</div>
                            <div class="info-cell-value"><%=u.getUsername()%></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-signature"></i> Full Name</div>
                            <div class="info-cell-value"><%=u.getFullName()%></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-envelope"></i> Email</div>
                            <div class="info-cell-value <%=u.getEmail()==null||u.getEmail().isEmpty()?"empty":""%>">
                                <%=u.getEmail()!=null&&!u.getEmail().isEmpty()?u.getEmail():"Not provided"%>
                            </div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-phone"></i> Phone</div>
                            <div class="info-cell-value <%=u.getPhone()==null||u.getPhone().isEmpty()?"empty":""%>">
                                <%=u.getPhone()!=null&&!u.getPhone().isEmpty()?u.getPhone():"Not provided"%>
                            </div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-shield-halved"></i> Role</div>
                            <div class="info-cell-value"><%=roleLabel%></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-circle-check"></i> Status</div>
                            <div class="info-cell-value" style="color:<%=u.isActive()?"var(--success)":"var(--danger)"%>">
                                <%=u.isActive()?"Active":"Inactive"%>
                            </div>
                        </div>
                    </div>

                    <div class="action-row">
                        <button class="btn btn-gold" onclick="switchTab('edit', this)"><i class="fas fa-pen-nib"></i> Edit Profile</button>
                        <% if (!isSocial) { %>
                        <button class="btn btn-ghost" onclick="switchTab('password', this)"><i class="fas fa-key"></i> Change Password</button>
                        <% } else { %>
                        <div class="social-tag">
                            <i class="<%="GOOGLE".equals(me.getAuthProvider())?"fab fa-google":"fab fa-facebook"%>"
                               style="color:<%="GOOGLE".equals(me.getAuthProvider())?"#ea4335":"#1877f2"%>"></i>
                            Signed in via <%=me.getAuthProvider()%> —
                            <a href="<%="GOOGLE".equals(me.getAuthProvider())?"https://myaccount.google.com/security":"https://www.facebook.com/settings?tab=security"%>" target="_blank">manage here</a>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- ── TAB: EDIT ── -->
                <div id="tab-edit" class="tab-panel <%="edit".equals(tab)?"active":""%>">
                    <div class="section-eyebrow">Edit</div>
                    <div class="section-title">Update your <em>information</em></div>

                    <div class="form-card">
                        <form method="post" action="<%=ctx%>/profile">
                            <input type="hidden" name="action" value="updateInfo">
                            <div class="form-section">
                                <div class="form-section-label">Personal Details</div>
                                <div class="field-row">
                                    <div class="field">
                                        <label>Full Name *</label>
                                        <input type="text" name="fullName" value="<%=u.getFullName()!=null?u.getFullName():""%>" required placeholder="Your full name">
                                    </div>
                                    <div class="field">
                                        <label>Phone Number</label>
                                        <input type="text" name="phone" value="<%=u.getPhone()!=null?u.getPhone():""%>" placeholder="e.g. 0901 234 567">
                                    </div>
                                </div>
                            </div>
                            <div class="form-section">
                                <div class="form-section-label">Account Details</div>
                                <div class="field-row">
                                    <div class="field">
                                        <label>Username <span style="font-weight:300;text-transform:none;letter-spacing:0">(read only)</span></label>
                                        <input type="text" value="<%=u.getUsername()%>" readonly>
                                    </div>
                                    <div class="field">
                                        <label>Email <span style="font-weight:300;text-transform:none;letter-spacing:0">(contact admin)</span></label>
                                        <input type="email" value="<%=u.getEmail()!=null?u.getEmail():""%>" readonly>
                                        <div class="field-hint"><i class="fas fa-info-circle"></i> Contact an administrator to change your email.</div>
                                    </div>
                                </div>
                            </div>
                            <div class="form-footer">
                                <button type="button" class="btn btn-ghost btn-sm" onclick="switchTab('info', this)">Cancel</button>
                                <button type="submit" class="btn btn-gold btn-sm"><i class="fas fa-check"></i> Save Changes</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- ── TAB: PASSWORD ── -->
                <div id="tab-password" class="tab-panel <%="password".equals(tab)?"active":""%>">
                    <% if (isSocial) { %>
                    <div class="section-eyebrow">Security</div>
                    <div class="section-title"><em>Managed</em> externally</div>
                    <div class="form-card">
                        <div class="empty-state">
                            <div class="empty-icon"><i class="fas fa-lock"></i></div>
                            <div class="empty-title">Password via <%=me.getAuthProvider()%></div>
                            <div class="empty-sub">
                                Your account is authenticated through <strong><%=me.getAuthProvider()%></strong>.
                                To update your password, visit your provider's security settings.
                            </div>
                            <% if ("GOOGLE".equals(me.getAuthProvider())) { %>
                            <a href="https://myaccount.google.com/security" target="_blank" class="btn btn-ghost">
                                <i class="fab fa-google" style="color:#ea4335"></i> Google Account Settings
                            </a>
                            <% } else { %>
                            <a href="https://www.facebook.com/settings?tab=security" target="_blank" class="btn btn-ghost">
                                <i class="fab fa-facebook" style="color:#1877f2"></i> Facebook Security Settings
                            </a>
                            <% } %>
                        </div>
                    </div>
                    <% } else { %>
                    <div class="section-eyebrow">Security</div>
                    <div class="section-title">Change your <em>password</em></div>
                    <div class="form-card">
                        <form method="post" action="<%=ctx%>/profile" id="passForm">
                            <input type="hidden" name="action" value="changePassword">
                            <div class="form-section">
                                <div class="form-section-label">Verification</div>
                                <div class="field">
                                    <label>Current Password *</label>
                                    <div class="pass-wrap">
                                        <input type="password" name="currentPassword" id="curPass" required placeholder="Enter current password">
                                        <button type="button" class="pass-eye" onclick="togglePass('curPass', this)"><i class="fas fa-eye"></i></button>
                                    </div>
                                </div>
                            </div>
                            <div class="form-section">
                                <div class="form-section-label">New Password</div>
                                <div class="field-row">
                                    <div class="field">
                                        <label>New Password *</label>
                                        <div class="pass-wrap">
                                            <input type="password" name="newPassword" id="newPass" required placeholder="Min. 6 characters" oninput="checkStrength(this.value)">
                                            <button type="button" class="pass-eye" onclick="togglePass('newPass', this)"><i class="fas fa-eye"></i></button>
                                        </div>
                                        <div class="strength-track"><div class="strength-fill" id="strengthFill"></div></div>
                                        <div class="strength-label" id="strengthText"></div>
                                    </div>
                                    <div class="field">
                                        <label>Confirm Password *</label>
                                        <div class="pass-wrap">
                                            <input type="password" name="confirmPassword" id="conPass" required placeholder="Re-enter new password" oninput="checkMatch()">
                                            <button type="button" class="pass-eye" onclick="togglePass('conPass', this)"><i class="fas fa-eye"></i></button>
                                        </div>
                                        <div class="field-hint" id="matchHint"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="form-footer">
                                <button type="button" class="btn btn-ghost btn-sm" onclick="switchTab('info', this)">Cancel</button>
                                <button type="submit" class="btn btn-gold btn-sm"><i class="fas fa-key"></i> Update Password</button>
                            </div>
                        </form>
                    </div>
                    <% } %>
                </div>

            </main>
        </div>

        <script>
            /* ── AURORA ── */
            (function () {
                const c = document.getElementById('aurora');
                const gl = c.getContext('2d');
                let W, H, t = 0;
                function resize() {
                    W = c.width = window.innerWidth;
                    H = c.height = window.innerHeight;
                }
                resize();
                window.addEventListener('resize', resize);
                const blobs = [
                    {x: .15, y: .3, r: .45, hue: 220, a: .22, spd: .0004},
                    {x: .8, y: .15, r: .55, hue: 260, a: .16, spd: .0003},
                    {x: .5, y: .75, r: .4, hue: 200, a: .14, spd: .0005},
                    {x: .9, y: .6, r: .35, hue: 280, a: .10, spd: .0006},
                ];
                function draw() {
                    gl.clearRect(0, 0, W, H);
                    blobs.forEach((b, i) => {
                        const x = (b.x + Math.sin(t * b.spd * 1000 + i) * 0.08) * W;
                        const y = (b.y + Math.cos(t * b.spd * 800 + i) * 0.06) * H;
                        const r = b.r * Math.min(W, H);
                        const g = gl.createRadialGradient(x, y, 0, x, y, r);
                        g.addColorStop(0, `hsla(${b.hue+Math.sin(t*.001)*15},70%,55%,${b.a})`);
                        g.addColorStop(1, `hsla(${b.hue},60%,40%,0)`);
                        gl.fillStyle = g;
                        gl.fillRect(0, 0, W, H);
                    });
                    t++;
                    requestAnimationFrame(draw);
                }
                draw();
            })();

            /* ── TAB SWITCHING ── */
            function switchTab(name, el) {
                document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
                document.querySelectorAll('.sb-tab').forEach(b => b.classList.remove('active'));
                document.getElementById('tab-' + name).classList.add('active');
                document.querySelectorAll('.sb-tab').forEach(b => {
                    if (b.getAttribute('onclick') && b.getAttribute('onclick').includes("'" + name + "'"))
                        b.classList.add('active');
                });
            }

            /* ── AVATAR UPLOAD ── */
            function uploadAvatar(input) {
                const file = input.files[0];
                if (!file)
                    return;
                const allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
                if (!allowed.includes(file.type)) {
                    alert('Only JPG, PNG, GIF, WEBP allowed!');
                    return;
                }
                if (file.size > 2 * 1024 * 1024) {
                    alert('Max 2MB.');
                    return;
                }
                const reader = new FileReader();
                reader.onload = e => {
                    const prev = document.getElementById('avatarPreview');
                    prev.innerHTML = '<img src="' + e.target.result + '" style="width:110px;height:110px;border-radius:50%;object-fit:cover">';
                };
                reader.readAsDataURL(file);
                const fd = new FormData();
                fd.append('avatar', file);
                const ov = document.querySelector('.sb-avatar-overlay');
                ov.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
                ov.style.opacity = '1';
                fetch('<%=ctx%>/avatar/upload', {method: 'POST', body: fd})
                        .then(r => r.json()).then(data => {
                    ov.innerHTML = '<i class="fas fa-camera"></i>';
                    ov.style.opacity = '0';
                    if (data.success) {
                        document.getElementById('avatarPreview').innerHTML =
                                '<img src="' + data.url + '?t=' + Date.now() + '" style="width:110px;height:110px;border-radius:50%;object-fit:cover">';
                        showToast('Avatar updated', 'ok');
                    } else {
                        showToast(data.error || 'Upload failed', 'err');
                    }
                }).catch(() => {
                    ov.innerHTML = '<i class="fas fa-camera"></i>';
                    ov.style.opacity = '0';
                    showToast('Upload failed', 'err');
                });
            }

            /* ── TOAST ── */
            function showToast(msg, type) {
                const t = document.createElement('div');
                const ok = type === 'ok';
                t.style.cssText = `position:fixed;bottom:32px;right:32px;padding:13px 20px;border-radius:12px;
                font-family:'DM Sans',sans-serif;font-size:.83rem;font-weight:500;z-index:9999;
                display:flex;align-items:center;gap:9px;
                backdrop-filter:blur(16px);
                animation:toastIn .35s cubic-bezier(.4,0,.2,1);
                box-shadow:0 16px 40px rgba(0,0,0,.4)`;
                t.style.background = ok ? 'rgba(86,207,170,.12)' : 'rgba(240,112,106,.12)';
                t.style.color = ok ? '#56cfaa' : '#f0706a';
                t.style.border = ok ? '1px solid rgba(86,207,170,.25)' : '1px solid rgba(240,112,106,.25)';
                t.innerHTML = `<i class="fas fa-${ok?'check-circle':'exclamation-circle'}"></i>${msg}`;
                document.body.appendChild(t);
                setTimeout(() => {
                    t.style.animation = 'toastOut .3s ease forwards';
                    setTimeout(() => t.remove(), 300);
                }, 3000);
            }
            const style = document.createElement('style');
            style.textContent = `@keyframes toastIn{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:none}}
        @keyframes toastOut{to{opacity:0;transform:translateY(8px)}}`;
            document.head.appendChild(style);

            /* ── PASSWORD ── */
            function togglePass(id, btn) {
                const inp = document.getElementById(id);
                const isPass = inp.type === 'password';
                inp.type = isPass ? 'text' : 'password';
                btn.querySelector('i').className = isPass ? 'fas fa-eye-slash' : 'fas fa-eye';
            }
            function checkStrength(val) {
                const fill = document.getElementById('strengthFill');
                const text = document.getElementById('strengthText');
                let s = 0;
                if (val.length >= 6)
                    s++;
                if (val.length >= 10)
                    s++;
                if (/[A-Z]/.test(val))
                    s++;
                if (/[0-9]/.test(val))
                    s++;
                if (/[^A-Za-z0-9]/.test(val))
                    s++;
                const lvls = [
                    {p: '20%', c: '#f0706a', l: 'Very Weak'},
                    {p: '40%', c: '#fb923c', l: 'Weak'},
                    {p: '60%', c: '#fbbf24', l: 'Fair'},
                    {p: '80%', c: '#56cfaa', l: 'Strong'},
                    {p: '100%', c: 'var(--gold)', l: 'Excellent'}
                ];
                const lv = lvls[Math.max(0, s - 1)] || lvls[0];
                fill.style.width = val.length ? lv.p : '0';
                fill.style.background = lv.c;
                text.textContent = val.length ? lv.l : '';
                text.style.color = lv.c;
            }
            function checkMatch() {
                const nv = document.getElementById('newPass').value;
                const cv = document.getElementById('conPass').value;
                const hint = document.getElementById('matchHint');
                if (!cv) {
                    hint.textContent = '';
                    return;
                }
                hint.innerHTML = nv === cv
                        ? '<span style="color:#56cfaa"><i class="fas fa-check"></i> Passwords match</span>'
                        : '<span style="color:#f0706a"><i class="fas fa-times"></i> Passwords do not match</span>';
            }
            const pf = document.getElementById('passForm');
            if (pf)
                pf.addEventListener('submit', function (e) {
                    const nv = document.getElementById('newPass').value;
                    const cv = document.getElementById('conPass').value;
                    if (nv !== cv) {
                        e.preventDefault();
                        alert('Passwords do not match!');
                    } else if (nv.length < 6) {
                        e.preventDefault();
                        alert('Minimum 6 characters!');
                    }
                });
        </script>
    </body>
</html>
