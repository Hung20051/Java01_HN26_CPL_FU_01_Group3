<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Role" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (request.getAttribute("role") == null) {
        response.sendRedirect(request.getContextPath() + "/role/list");
        return;
    }
    Role role = (Role) request.getAttribute("role");
    String ctx = request.getContextPath();
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
            ? currentUser.getFullName().substring(0, 1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Edit Role - DRSMS</title>
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
            *, *::before, *::after {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            html {
                scroll-behavior: smooth;
            }
            body {
                font-family: 'Sora', sans-serif;
                background: var(--navy);
                color: var(--text);
                min-height: 100vh;
                display: flex;
            }
            ::-webkit-scrollbar {
                width: 4px;
            }
            ::-webkit-scrollbar-track {
                background: var(--navy);
            }
            ::-webkit-scrollbar-thumb {
                background: rgba(79,126,248,0.4);
                border-radius: 4px;
            }

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
                top: 0;
                left: 0;
                z-index: 100;
            }
            .sb-brand {
                padding: 22px 18px 16px;
                display: flex;
                align-items: center;
                gap: 10px;
                border-bottom: 1px solid var(--border);
            }
            .sb-logo {
                width: 36px;
                height: 36px;
                background: linear-gradient(135deg, var(--amber), #f97316);
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #fff;
                font-size: 0.88rem;
                box-shadow: 0 4px 14px rgba(251,191,36,0.3);
                flex-shrink: 0;
            }
            .sb-name {
                color: #fff;
                font-size: 1rem;
                font-weight: 700;
            }
            .sb-role {
                display: inline-flex;
                align-items: center;
                background: rgba(251,191,36,0.15);
                border: 1px solid rgba(251,191,36,0.3);
                color: var(--amber);
                font-size: 0.62rem;
                font-weight: 700;
                letter-spacing: 1px;
                text-transform: uppercase;
                padding: 2px 8px;
                border-radius: 20px;
                margin-top: 3px;
            }
            .sb-nav {
                flex: 1;
                padding: 12px 10px;
                overflow-y: auto;
            }
            .sb-lbl {
                color: rgba(255,255,255,0.22);
                font-size: 0.62rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1.4px;
                padding: 0 8px;
                margin: 16px 0 5px;
            }
            .sb-item {
                display: flex;
                align-items: center;
                gap: 9px;
                padding: 9px 10px;
                border-radius: 9px;
                margin-bottom: 1px;
                color: rgba(255,255,255,0.45);
                text-decoration: none;
                font-size: 0.83rem;
                font-weight: 500;
                transition: all 0.2s;
                border-left: 2px solid transparent;
            }
            .sb-item i {
                width: 28px;
                height: 28px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 0.8rem;
                border-radius: 8px;
                background: rgba(255,255,255,0.05);
                flex-shrink: 0;
                transition: all 0.2s;
            }
            .sb-item.on {
                color: #fff;
                background: linear-gradient(90deg, rgba(167,139,250,0.18), rgba(167,139,250,0.04));
                border-left: 2px solid var(--purple);
            }
            .sb-item.on i {
                background: rgba(167,139,250,0.2);
                color: var(--purple);
            }
            .sb-item.si-dash:hover   {
                color: #fff;
                background: rgba(251,191,36,0.08);
                border-left-color: var(--amber);
            }
            .sb-item.si-dash:hover i {
                background: rgba(251,191,36,0.18);
                color: var(--amber);
            }
            .sb-item.si-users:hover    {
                color: #fff;
                background: rgba(79,126,248,0.1);
                border-left-color: var(--accent);
            }
            .sb-item.si-users:hover i  {
                background: rgba(79,126,248,0.2);
                color: var(--accent-2);
            }
            .sb-item.si-roles:hover    {
                color: #fff;
                background: rgba(167,139,250,0.08);
                border-left-color: var(--purple);
            }
            .sb-item.si-roles:hover i  {
                background: rgba(167,139,250,0.18);
                color: var(--purple);
            }
            .sb-foot {
                padding: 12px 10px 16px;
                border-top: 1px solid var(--border);
            }
            .sb-user {
                display: flex;
                align-items: center;
                gap: 9px;
                padding: 10px;
                border-radius: 10px;
                background: rgba(255,255,255,0.04);
                border: 1px solid var(--border);
                margin-bottom: 6px;
                text-decoration: none;
                transition: all 0.2s;
            }
            .sb-user:hover {
                background: rgba(251,191,36,0.08);
                border-color: rgba(251,191,36,0.2);
            }
            .sb-ava {
                width: 34px;
                height: 34px;
                border-radius: 50%;
                background: linear-gradient(135deg, var(--amber), #f97316);
                display: flex;
                align-items: center;
                justify-content: center;
                color: #fff;
                font-size: 0.88rem;
                font-weight: 700;
                flex-shrink: 0;
                overflow: hidden;
            }
            .sb-ava img {
                width: 34px;
                height: 34px;
                object-fit: cover;
                border-radius: 50%;
            }
            .sb-uname {
                color: #fff;
                font-size: 0.82rem;
                font-weight: 600;
            }
            .sb-urole {
                color: var(--muted);
                font-size: 0.68rem;
                margin-top: 1px;
            }
            .sb-logout {
                display: flex;
                align-items: center;
                gap: 8px;
                width: 100%;
                padding: 8px 10px;
                border-radius: 8px;
                color: rgba(255,255,255,0.35);
                text-decoration: none;
                font-size: 0.8rem;
                transition: all 0.2s;
            }
            .sb-logout:hover {
                color: var(--danger);
                background: rgba(248,113,113,0.08);
            }

            /* ════════════════════ MAIN ════════════════════ */
            .main {
                margin-left: var(--sb-width);
                flex: 1;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }

            .topbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 18px 32px;
                border-bottom: 1px solid var(--border);
                background: rgba(11,20,55,0.6);
                backdrop-filter: blur(16px);
                position: sticky;
                top: 0;
                z-index: 50;
            }
            .topbar-title {
                font-size: 1.15rem;
                font-weight: 800;
                color: #fff;
                letter-spacing: -0.3px;
                display: flex;
                align-items: center;
                gap: 9px;
            }
            .topbar-title i {
                color: var(--purple);
                font-size: 0.95rem;
            }
            .topbar-sub {
                color: var(--muted);
                font-size: 0.78rem;
                margin-top: 2px;
            }
            .btn-back {
                display: inline-flex;
                align-items: center;
                gap: 7px;
                padding: 8px 16px;
                background: rgba(255,255,255,0.05);
                color: var(--text-2);
                border: 1px solid var(--border);
                text-decoration: none;
                font-size: 0.82rem;
                font-weight: 600;
                border-radius: 9px;
                transition: all 0.2s;
            }
            .btn-back:hover {
                background: rgba(79,126,248,0.1);
                border-color: rgba(79,126,248,0.3);
                color: #fff;
            }

            .content {
                padding: 28px 32px;
                flex: 1;
            }

            @keyframes cardIn {
                from {
                    opacity: 0;
                    transform: translateY(14px);
                }
                to   {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* ── CARDS ── */
            .card {
                background: rgba(17,26,66,0.7);
                border: 1px solid var(--border);
                border-radius: 16px;
                overflow: hidden;
                backdrop-filter: blur(12px);
                margin-bottom: 16px;
            }
            .card:nth-child(1) {
                animation: cardIn 0.5s 0.05s ease both;
            }
            .card:nth-child(2) {
                animation: cardIn 0.5s 0.12s ease both;
            }

            .card-header {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 14px 22px;
                border-bottom: 1px solid var(--border);
                font-size: 0.87rem;
                font-weight: 700;
                color: #fff;
            }
            .card-header i {
                color: var(--purple);
            }
            .card-body {
                padding: 24px 22px;
            }

            /* ── FORM ── */
            .form-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 18px;
            }
            .form-group {
                display: flex;
                flex-direction: column;
                gap: 6px;
            }
            .form-group label {
                font-size: 0.72rem;
                font-weight: 700;
                color: var(--muted);
                text-transform: uppercase;
                letter-spacing: 0.6px;
            }
            .form-group input {
                padding: 10px 13px;
                background: rgba(255,255,255,0.05);
                border: 1.5px solid var(--border);
                border-radius: 9px;
                font-size: 0.875rem;
                font-family: 'Sora', sans-serif;
                color: var(--text);
                outline: none;
                transition: all 0.2s;
            }
            .form-group input::placeholder {
                color: var(--muted);
            }
            .form-group input:focus {
                border-color: rgba(167,139,250,0.5);
                background: rgba(167,139,250,0.06);
                box-shadow: 0 0 0 3px rgba(167,139,250,0.1);
            }
            .form-group input:disabled {
                background: rgba(255,255,255,0.03);
                color: var(--muted);
                cursor: not-allowed;
                border-color: rgba(255,255,255,0.04);
            }
            .hint {
                font-size: 0.72rem;
                color: var(--muted);
                display: flex;
                align-items: center;
                gap: 5px;
            }

            /* ── FORM ACTIONS ── */
            .form-actions {
                display: flex;
                justify-content: flex-end;
                gap: 9px;
                margin-top: 22px;
                padding-top: 18px;
                border-top: 1px solid var(--border);
            }
            .btn {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 10px 22px;
                border-radius: 10px;
                font-size: 0.875rem;
                font-weight: 700;
                font-family: 'Sora', sans-serif;
                border: none;
                cursor: pointer;
                text-decoration: none;
                transition: all 0.2s;
            }
            .btn-cancel {
                background: rgba(255,255,255,0.04);
                color: var(--muted);
                border: 1.5px solid var(--border);
            }
            .btn-cancel:hover {
                background: rgba(255,255,255,0.07);
                color: var(--text-2);
            }
            .btn-update {
                background: linear-gradient(135deg, var(--purple), #8b5cf6);
                color: #fff;
                box-shadow: 0 4px 14px rgba(167,139,250,0.25);
            }
            .btn-update:hover {
                transform: translateY(-1px);
                box-shadow: 0 6px 20px rgba(167,139,250,0.4);
            }

            /* ── WARNING BOX ── */
            .warning-box {
                background: var(--amber-dim);
                border: 1px solid rgba(251,191,36,0.2);
                border-radius: 13px;
                padding: 18px 20px;
            }
            .warning-box h4 {
                color: var(--amber);
                font-size: 0.87rem;
                font-weight: 700;
                margin-bottom: 14px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .warning-box ul {
                list-style: none;
                display: flex;
                flex-direction: column;
                gap: 9px;
            }
            .warning-box ul li {
                display: flex;
                align-items: flex-start;
                gap: 10px;
                color: var(--text-2);
                font-size: 0.82rem;
                line-height: 1.55;
            }
            .warning-box ul li span.icon {
                flex-shrink: 0;
                font-size: 0.9rem;
            }
        </style>
    </head>
    <body>

        <%-- ═══════════ SIDEBAR ═══════════ --%>
        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-cog"></i></div>
                <div>
                    <div class="sb-name">DRSMS</div>
                    <div class="sb-role">Admin</div>
                </div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/admin.jsp" class="sb-item si-dash">
                    <i class="fas fa-tachometer-alt"></i> Dashboard
                </a>
                <div class="sb-lbl">Management</div>
                <a href="<%=ctx%>/user/list" class="sb-item si-users">
                    <i class="fas fa-users"></i> Users
                </a>
                <a href="<%=ctx%>/role/list" class="sb-item on si-roles">
                    <i class="fas fa-user-tag"></i> Roles
                </a>
            </nav>
            <div class="sb-foot">
                <a href="<%=ctx%>/profile" class="sb-user">
                    <div class="sb-ava">
                        <%if (currentUser.getAvatarUrl() != null && !currentUser.getAvatarUrl().isEmpty()) {%>
                        <img src="<%=ctx%><%=currentUser.getAvatarUrl()%>" alt="avatar">
                        <%} else {%><%=initials%><%}%>
                    </div>
                    <div>
                        <div class="sb-uname"><%=currentUser.getFullName()%></div>
                        <div class="sb-urole">Administrator</div>
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
                    <div class="topbar-title"><i class="fas fa-pen-to-square"></i> Edit Role</div>
                    <div class="topbar-sub">Editing: <strong style="color:var(--purple)"><%=role.getName().replace("_", " ")%></strong></div>
                </div>
                <a href="<%=ctx%>/role/list" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Back to List
                </a>
            </div>

            <div class="content">

                <%-- Edit form --%>
                <form method="post" action="<%=ctx%>/role/edit">
                    <input type="hidden" name="id" value="<%=role.getId()%>">
                    <div class="card">
                        <div class="card-header">
                            <i class="fas fa-pen-to-square"></i> Role Details
                        </div>
                        <div class="card-body">
                            <div class="form-grid">
                                <div class="form-group">
                                    <label>Role Name <span style="color:var(--danger)">*</span></label>
                                    <input type="text" name="name" value="<%=role.getName()%>"
                                           required placeholder="Enter role name">
                                    <span class="hint"><i class="fas fa-circle-info"></i> Enter a unique name for this role</span>
                                </div>
                                <div class="form-group">
                                    <label>Role ID</label>
                                    <input type="text" value="<%=role.getId()%>" disabled>
                                    <span class="hint"><i class="fas fa-lock"></i> Role ID cannot be changed</span>
                                </div>
                            </div>
                            <div class="form-actions">
                                <a href="<%=ctx%>/role/list" class="btn btn-cancel">
                                    <i class="fas fa-xmark"></i> Cancel
                                </a>
                                <button type="submit" class="btn btn-update">
                                    <i class="fas fa-floppy-disk"></i> Update Role
                                </button>
                            </div>
                        </div>
                    </div>
                </form>

                <%-- Warning card --%>
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-triangle-exclamation" style="color:var(--amber)"></i>
                        <span style="color:var(--amber)">Important Notes</span>
                    </div>
                    <div class="card-body">
                        <div class="warning-box">
                            <ul>
                                <li>
                                    <span class="icon">🔄</span>
                                    Changing the role name will affect all users currently assigned to this role.
                                </li>
                                <li>
                                    <span class="icon">✅</span>
                                    Ensure the new role name is clear and accurately describes its function.
                                </li>
                                <li>
                                    <span class="icon">⚠️</span>
                                    Consider the impact on system permissions and access control before saving.
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>

            </div>
        </main>

    </body>
</html>
