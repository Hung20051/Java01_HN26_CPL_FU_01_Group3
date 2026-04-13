<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    User u = (User) request.getAttribute("profileUser");
    if (u == null) {
        u = me;
    }
    String ctx = request.getContextPath();

    String flashOk = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");

    String dashLink = "/customerDashboard";
    String roleLabel = "Customer";
    String roleIcon = "fas fa-user";
    if ("CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        dashLink = "/supportDashboard";
        roleLabel = "Customer Support";
        roleIcon = "fas fa-headset";
    } else if ("STOREKEEPER".equals(me.getRoleName())) {
        dashLink = "/dashboard.jsp";
        roleLabel = "Store Keeper";
        roleIcon = "fas fa-store";
    } else if ("ADMIN".equals(me.getRoleName())) {
        dashLink = "/admin.jsp";
        roleLabel = "Admin";
        roleIcon = "fas fa-crown";
    } else if ("TECHNICAL_MANAGER".equals(me.getRoleName())) {
        dashLink = "/tmServiceRequests";
        roleLabel = "Technical Manager";
        roleIcon = "fas fa-tools";
    } else if ("TECHNICIAN".equals(me.getRoleName())) {
        dashLink = "/technicianDashboard";
        roleLabel = "Technician";
        roleIcon = "fas fa-wrench";
    }

    String avatarLetter = u.getFullName() != null && !u.getFullName().isEmpty()
            ? u.getFullName().substring(0, 1).toUpperCase() : "?";

    String tab = request.getParameter("tab");
    if (tab == null) {
        tab = "info";
    }
    boolean isSocial = me.getPassword() == null || me.getPassword().isEmpty();

    java.util.function.Function<String, String> val = s
            -> (s != null && !s.trim().isEmpty()) ? s : "<span class='empty'>—</span>";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>My Profile — DRSMS</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
        <style>
            :root {
                /* Background layers — lifted to a warm deep indigo-slate */
                --bg-root:   #0f1035;
                --bg-layer:  #131638;
                --bg-card:   rgba(255,255,255,0.055);
                --bg-card-2: rgba(255,255,255,0.09);
                --rim:       rgba(255,255,255,0.11);
                --rim-2:     rgba(255,255,255,0.22);

                /* Gold — warmer, brighter */
                --gold:      #e2b95a;
                --gold-2:    #f7dc8a;
                --gold-dim:  rgba(226,185,90,0.15);
                --gold-glow: rgba(226,185,90,0.35);

                /* Accent blue */
                --blue:      #5b8ff8;
                --blue-2:    #93b8fd;
                --blue-dim:  rgba(91,143,248,0.14);

                /* Text */
                --text:      #f5f2ec;
                --text-2:    #c2bdb4;
                --muted:     #7a7694;

                /* Status */
                --success:   #5ed9b0;
                --danger:    #f47b74;
                --warn:      #fbbf24;

                --sidebar-w: 300px;
            }

            *,*::before,*::after{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            html{
                height:100%
            }
            body{
                font-family:'DM Sans',sans-serif;
                background:var(--bg-root);
                color:var(--text);
                min-height:100vh;
                overflow-x:hidden
            }
            ::-webkit-scrollbar{
                width:4px
            }
            ::-webkit-scrollbar-thumb{
                background:rgba(226,185,90,.35);
                border-radius:4px
            }

            /* ── AURORA (brighter, warmer blobs) ── */
            #aurora{
                position:fixed;
                inset:0;
                z-index:0;
                pointer-events:none
            }

            .layout{
                display:flex;
                min-height:100vh;
                position:relative;
                z-index:1
            }

            /* ══════════════ SIDEBAR ══════════════ */
            .sidebar{
                width:var(--sidebar-w);
                flex-shrink:0;
                position:sticky;
                top:0;
                height:100vh;
                overflow-y:auto;
                display:flex;
                flex-direction:column;
                padding:28px 22px;
                border-right:1px solid var(--rim);
                background:rgba(13,14,45,0.72);
                backdrop-filter:blur(28px);
            }

            .sb-back{
                display:inline-flex;
                align-items:center;
                gap:8px;
                color:var(--muted);
                text-decoration:none;
                font-size:.76rem;
                font-weight:500;
                letter-spacing:.6px;
                text-transform:uppercase;
                padding:6px 0;
                margin-bottom:32px;
                transition:color .2s;
                border:none;
                background:none;
                cursor:pointer;
                font-family:inherit
            }
            .sb-back:hover{
                color:var(--text-2)
            }
            .sb-back i{
                font-size:.7rem
            }

            /* Avatar */
            .sb-avatar-wrap{
                position:relative;
                width:96px;
                height:96px;
                margin:0 auto 18px;
                cursor:pointer
            }
            .sb-avatar-wrap:hover .sb-avatar-overlay{
                opacity:1
            }
            .sb-avatar{
                width:96px;
                height:96px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-family:'Cormorant Garamond',serif;
                font-size:2.6rem;
                font-weight:600;
                color:var(--gold);
                background:radial-gradient(circle at 35% 35%, rgba(226,185,90,.18), rgba(91,143,248,.12));
                border:2px solid transparent;
                background-clip:padding-box;
                box-shadow:0 0 0 1.5px var(--gold), 0 0 28px rgba(226,185,90,.25), 0 0 60px rgba(91,143,248,.1);
                position:relative;
                overflow:hidden;
            }
            .sb-avatar img{
                width:96px;
                height:96px;
                border-radius:50%;
                object-fit:cover
            }
            /* Spinning ring */
            .sb-avatar::before{
                content:'';
                position:absolute;
                inset:-3px;
                border-radius:50%;
                background:conic-gradient(from 0deg, transparent 55%, rgba(226,185,90,.7) 75%, rgba(247,220,138,.9) 82%, transparent 100%);
                animation:avatarSpin 5s linear infinite;
                -webkit-mask:radial-gradient(farthest-side,#0000 calc(100% - 3px),#000 calc(100% - 3px));
            }
            @keyframes avatarSpin{
                to{
                    transform:rotate(360deg)
                }
            }
            .sb-avatar-overlay{
                position:absolute;
                inset:0;
                border-radius:50%;
                background:rgba(13,14,45,.7);
                display:flex;
                align-items:center;
                justify-content:center;
                color:var(--gold);
                font-size:1.3rem;
                opacity:0;
                transition:.25s;
                backdrop-filter:blur(4px)
            }

            .sb-name{
                text-align:center;
                font-family:'Cormorant Garamond',serif;
                font-size:1.4rem;
                font-weight:600;
                color:var(--text);
                line-height:1.25;
                margin-bottom:6px
            }
            .sb-role{
                display:flex;
                align-items:center;
                justify-content:center;
                gap:6px;
                font-size:.68rem;
                font-weight:500;
                letter-spacing:1.8px;
                text-transform:uppercase;
                color:var(--gold);
                margin-bottom:20px
            }
            .sb-status{
                display:flex;
                align-items:center;
                justify-content:center;
                gap:6px;
                font-size:.74rem;
                color:var(--text-2);
                margin-bottom:24px
            }
            .sb-dot{
                width:7px;
                height:7px;
                border-radius:50%;
                background:var(--success);
                box-shadow:0 0 10px var(--success);
                animation:dotPulse 2.5s ease-in-out infinite
            }
            @keyframes dotPulse{
                0%,100%{
                    box-shadow:0 0 6px var(--success)
                }
                50%{
                    box-shadow:0 0 18px var(--success),0 0 30px rgba(94,217,176,.3)
                }
            }

            .sb-divider{
                border:none;
                border-top:1px solid var(--rim);
                margin:0 0 20px
            }

            .sb-nav{
                display:flex;
                flex-direction:column;
                gap:3px
            }
            .sb-tab{
                display:flex;
                align-items:center;
                gap:11px;
                padding:10px 13px;
                border-radius:10px;
                border:1px solid transparent;
                background:none;
                color:var(--muted);
                font-family:'DM Sans',sans-serif;
                font-size:.82rem;
                font-weight:500;
                cursor:pointer;
                transition:all .2s;
                text-align:left;
                width:100%;
            }
            .sb-tab i{
                width:15px;
                text-align:center;
                font-size:.78rem;
                flex-shrink:0
            }
            .sb-tab:hover{
                color:var(--text-2);
                background:rgba(255,255,255,.06);
                border-color:var(--rim)
            }
            .sb-tab.active{
                color:var(--gold);
                background:linear-gradient(90deg, rgba(226,185,90,.12), rgba(226,185,90,.04));
                border-color:rgba(226,185,90,.3);
            }
            .sb-tab.active i{
                filter:drop-shadow(0 0 6px var(--gold-glow))
            }

            .sb-username{
                margin-top:auto;
                padding:11px 13px;
                background:rgba(255,255,255,.04);
                border:1px solid var(--rim);
                border-radius:10px;
                display:flex;
                align-items:center;
                gap:9px;
                font-size:.76rem;
                color:var(--text-2);
            }
            .sb-username i{
                color:var(--muted);
                font-size:.72rem
            }

            /* ══════════════ MAIN ══════════════ */
            .main{
                flex:1;
                padding:44px 48px 80px;
                min-width:0
            }

            .flash{
                display:flex;
                align-items:center;
                gap:10px;
                padding:12px 16px;
                border-radius:12px;
                font-size:.83rem;
                font-weight:500;
                margin-bottom:26px;
                animation:slideDown .3s ease
            }
            @keyframes slideDown{
                from{
                    opacity:0;
                    transform:translateY(-8px)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }
            .flash-ok {
                background:rgba(94,217,176,.1);
                color:var(--success);
                border:1px solid rgba(94,217,176,.25)
            }
            .flash-err{
                background:rgba(244,123,116,.1);
                color:var(--danger);
                border:1px solid rgba(244,123,116,.25)
            }

            .section-eyebrow{
                font-size:.63rem;
                letter-spacing:2.8px;
                text-transform:uppercase;
                color:var(--gold);
                font-weight:600;
                margin-bottom:7px;
                display:flex;
                align-items:center;
                gap:10px
            }
            .section-eyebrow::after{
                content:'';
                flex:1;
                height:1px;
                background:linear-gradient(to right,rgba(226,185,90,.35),transparent)
            }
            .section-title{
                font-family:'Cormorant Garamond',serif;
                font-size:1.9rem;
                font-weight:300;
                letter-spacing:-.4px;
                color:var(--text);
                margin-bottom:28px;
                line-height:1.15
            }
            .section-title em{
                font-style:italic;
                color:var(--gold-2)
            }

            .tab-panel{
                display:none;
                animation:fadeIn .3s ease
            }
            .tab-panel.active{
                display:block
            }
            @keyframes fadeIn{
                from{
                    opacity:0;
                    transform:translateY(10px)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }

            /* ── Completion bar ── */
            .completion-wrap{
                margin-bottom:28px;
                background:var(--bg-card);
                border:1px solid var(--rim);
                border-radius:14px;
                padding:18px 22px
            }
            .completion-header{
                display:flex;
                justify-content:space-between;
                align-items:center;
                margin-bottom:10px;
                font-size:.78rem;
                color:var(--text-2)
            }
            .completion-header strong{
                color:var(--gold);
                font-size:.92rem
            }
            .completion-track{
                height:6px;
                background:rgba(255,255,255,.08);
                border-radius:4px;
                overflow:hidden
            }
            .completion-fill{
                height:100%;
                border-radius:4px;
                background:linear-gradient(90deg,var(--blue),var(--gold));
                transition:width .9s cubic-bezier(.4,0,.2,1)
            }
            .completion-tip{
                font-size:.72rem;
                color:var(--muted);
                margin-top:8px
            }
            .completion-tip a{
                color:var(--gold);
                text-decoration:none;
                font-weight:600
            }

            /* ── Address banner ── */
            .address-banner{
                background:linear-gradient(135deg,rgba(91,143,248,.1),rgba(226,185,90,.06));
                border:1px solid rgba(91,143,248,.25);
                border-radius:16px;
                padding:20px 24px;
                display:flex;
                align-items:flex-start;
                gap:16px;
                margin-bottom:24px;
            }
            .address-banner-icon{
                font-size:1.5rem;
                color:var(--blue-2);
                margin-top:2px;
                flex-shrink:0;
                filter:drop-shadow(0 0 8px rgba(91,143,248,.5))
            }
            .address-banner-label{
                font-size:.62rem;
                letter-spacing:1.5px;
                text-transform:uppercase;
                color:var(--muted);
                font-weight:600;
                margin-bottom:5px
            }
            .address-banner-value{
                font-size:.94rem;
                color:var(--text);
                font-weight:500;
                line-height:1.55
            }
            .address-banner-value.empty{
                color:var(--muted);
                font-style:italic
            }
            .map-link{
                display:inline-flex;
                align-items:center;
                gap:6px;
                margin-top:10px;
                font-size:.74rem;
                color:var(--blue-2);
                text-decoration:none;
                font-weight:500;
                transition:all .2s;
                padding:5px 12px;
                background:rgba(91,143,248,.12);
                border:1px solid rgba(91,143,248,.25);
                border-radius:8px
            }
            .map-link:hover{
                background:rgba(91,143,248,.22);
                color:#fff
            }

            /* ── Info grid ── */
            .info-grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:1px;
                background:rgba(255,255,255,.07);
                border:1px solid var(--rim);
                border-radius:16px;
                overflow:hidden;
                margin-bottom:24px;
            }
            .info-cell{
                background:var(--bg-layer);
                padding:20px 22px;
                transition:background .2s
            }
            .info-cell:hover{
                background:rgba(226,185,90,.04)
            }
            .info-cell.full-width{
                grid-column:1/-1
            }
            .info-cell-label{
                font-size:.6rem;
                letter-spacing:1.5px;
                text-transform:uppercase;
                color:var(--muted);
                font-weight:600;
                margin-bottom:7px;
                display:flex;
                align-items:center;
                gap:6px
            }
            .info-cell-label i{
                color:var(--gold);
                font-size:.58rem
            }
            .info-cell-value{
                font-size:.9rem;
                font-weight:500;
                color:var(--text)
            }
            .info-cell-value .empty{
                color:var(--muted);
                font-style:italic;
                font-weight:300
            }

            .action-row{
                display:flex;
                gap:10px;
                flex-wrap:wrap;
                padding-top:4px
            }

            /* ── Form card ── */
            .form-card{
                background:rgba(255,255,255,.05);
                border:1px solid var(--rim);
                border-radius:16px;
                overflow:hidden;
                backdrop-filter:blur(12px)
            }
            .form-section{
                padding:26px 30px;
                border-bottom:1px solid var(--rim)
            }
            .form-section:last-child{
                border-bottom:none
            }
            .form-section-label{
                font-size:.62rem;
                letter-spacing:1.5px;
                text-transform:uppercase;
                color:var(--muted);
                font-weight:600;
                margin-bottom:18px;
                display:flex;
                align-items:center;
                gap:8px
            }
            .form-section-label::after{
                content:'';
                flex:1;
                height:1px;
                background:var(--rim)
            }
            .form-section-label i{
                color:var(--gold)
            }

            .field-row  {
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:14px
            }
            .field-row-3{
                display:grid;
                grid-template-columns:1fr 1fr 1fr;
                gap:14px
            }
            .field{
                margin-bottom:14px
            }
            .field:last-child{
                margin-bottom:0
            }
            .field label{
                display:block;
                font-size:.68rem;
                font-weight:600;
                letter-spacing:.6px;
                text-transform:uppercase;
                color:var(--text-2);
                margin-bottom:8px
            }
            .field input,.field select,.field textarea{
                width:100%;
                padding:11px 15px;
                background:rgba(255,255,255,.06);
                border:1px solid rgba(255,255,255,.13);
                border-radius:10px;
                color:var(--text);
                font-family:'DM Sans',sans-serif;
                font-size:.87rem;
                outline:none;
                transition:all .25s;
            }
            .field textarea{
                resize:vertical;
                min-height:88px;
                line-height:1.6
            }
            .field select option{
                background:#131638
            }
            .field input::placeholder,.field textarea::placeholder{
                color:var(--muted)
            }
            .field input:focus,.field select:focus,.field textarea:focus{
                border-color:rgba(226,185,90,.55);
                background:rgba(226,185,90,.06);
                box-shadow:0 0 0 3px rgba(226,185,90,.1);
            }
            .field input[readonly]{
                color:var(--muted);
                opacity:.55;
                cursor:not-allowed
            }
            .field-hint{
                font-size:.71rem;
                color:var(--muted);
                margin-top:6px;
                display:flex;
                align-items:center;
                gap:5px
            }

            .pass-wrap{
                position:relative
            }
            .pass-wrap input{
                padding-right:44px
            }
            .pass-eye{
                position:absolute;
                right:13px;
                top:50%;
                transform:translateY(-50%);
                background:none;
                border:none;
                color:var(--muted);
                cursor:pointer;
                font-size:.84rem;
                transition:color .2s
            }
            .pass-eye:hover{
                color:var(--gold)
            }
            .strength-track{
                height:3px;
                border-radius:2px;
                margin-top:8px;
                background:rgba(255,255,255,.08);
                overflow:hidden
            }
            .strength-fill{
                height:100%;
                border-radius:2px;
                transition:all .35s;
                width:0
            }
            .strength-label{
                font-size:.7rem;
                margin-top:5px
            }

            /* ── Buttons ── */
            .btn{
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:10px 20px;
                border-radius:10px;
                border:none;
                font-family:'DM Sans',sans-serif;
                font-size:.83rem;
                font-weight:600;
                cursor:pointer;
                transition:all .25s;
                text-decoration:none;
                letter-spacing:.2px;
                white-space:nowrap
            }
            .btn-gold{
                background:linear-gradient(135deg, var(--gold), var(--gold-2));
                color:#0f1035;
                box-shadow:0 4px 18px var(--gold-glow);
            }
            .btn-gold:hover{
                transform:translateY(-2px);
                box-shadow:0 8px 30px rgba(226,185,90,.5)
            }
            .btn-ghost{
                background:rgba(255,255,255,.07);
                color:var(--text-2);
                border:1px solid var(--rim)
            }
            .btn-ghost:hover{
                border-color:var(--rim-2);
                color:var(--text);
                background:rgba(255,255,255,.11)
            }
            .btn-blue{
                background:rgba(91,143,248,.15);
                color:var(--blue-2);
                border:1px solid rgba(91,143,248,.3)
            }
            .btn-blue:hover{
                background:rgba(91,143,248,.28);
                color:#fff
            }
            .btn-sm{
                padding:8px 15px;
                font-size:.77rem
            }

            .form-footer{
                padding:18px 30px;
                display:flex;
                align-items:center;
                justify-content:flex-end;
                gap:10px;
                border-top:1px solid var(--rim);
                background:rgba(13,14,45,.45)
            }

            /* ── Badges ── */
            .badge{
                display:inline-flex;
                align-items:center;
                gap:5px;
                padding:3px 10px;
                border-radius:20px;
                font-size:.69rem;
                font-weight:600;
                letter-spacing:.4px
            }
            .badge-gold {
                background:rgba(226,185,90,.14);
                color:var(--gold);
                border:1px solid rgba(226,185,90,.32)
            }
            .badge-blue {
                background:rgba(91,143,248,.13);
                color:var(--blue-2);
                border:1px solid rgba(91,143,248,.32)
            }
            .badge-green{
                background:rgba(94,217,176,.12);
                color:var(--success);
                border:1px solid rgba(94,217,176,.32)
            }
            .badge-red  {
                background:rgba(244,123,116,.12);
                color:var(--danger);
                border:1px solid rgba(244,123,116,.32)
            }

            /* Map preview */
            .map-preview{
                border:1px solid rgba(91,143,248,.22);
                border-radius:12px;
                margin-top:14px;
                background:rgba(91,143,248,.06);
                display:flex;
                align-items:center;
                min-height:56px;
                padding:12px 16px;
                gap:12px
            }
            .map-preview i{
                font-size:1.1rem;
                color:var(--blue-2)
            }
            .map-preview span{
                font-size:.81rem;
                color:var(--text-2)
            }

            .social-tag{
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:9px 14px;
                background:rgba(255,255,255,.05);
                border:1px solid var(--rim);
                border-radius:10px;
                font-size:.79rem;
                color:var(--text-2)
            }
            .social-tag a{
                color:var(--blue-2);
                font-weight:600;
                text-decoration:none
            }
            .social-tag a:hover{
                color:#fff
            }

            .empty-state{
                text-align:center;
                padding:60px 32px
            }
            .empty-icon{
                width:70px;
                height:70px;
                border-radius:50%;
                background:rgba(226,185,90,.1);
                border:1px solid rgba(226,185,90,.25);
                display:flex;
                align-items:center;
                justify-content:center;
                margin:0 auto 18px;
                font-size:1.7rem;
                color:var(--gold)
            }
            .empty-title{
                font-family:'Cormorant Garamond',serif;
                font-size:1.35rem;
                font-weight:300;
                margin-bottom:8px
            }
            .empty-sub{
                color:var(--muted);
                font-size:.84rem;
                max-width:340px;
                margin:0 auto 24px;
                line-height:1.65
            }

            .empty{
                color:var(--muted);
                font-style:italic;
                font-weight:300
            }
        </style>
    </head>
    <body>

        <canvas id="aurora"></canvas>

        <div class="layout">

            <!-- ══ SIDEBAR ══ -->
            <aside class="sidebar">
                <a href="<%=ctx%><%=dashLink%>" class="sb-back">
                    <i class="fas fa-arrow-left"></i> Back to dashboard
                </a>

                <div class="sb-avatar-wrap" onclick="document.getElementById('avatarInput').click()" title="Change photo">
                    <div class="sb-avatar" id="avatarPreview">
                        <%if (u.getAvatarUrl() != null && !u.getAvatarUrl().isEmpty()) {%>
                        <img src="<%=ctx%><%=u.getAvatarUrl()%>" alt="avatar">
                        <%} else {%>
                        <span><%=avatarLetter%></span>
                        <%}%>
                    </div>
                    <div class="sb-avatar-overlay"><i class="fas fa-camera"></i></div>
                </div>
                <input type="file" id="avatarInput" accept="image/jpeg,image/png,image/gif,image/webp" style="display:none" onchange="uploadAvatar(this)">

                <div class="sb-name"><%=u.getFullName()%></div>
                <div class="sb-role"><i class="<%=roleIcon%>"></i> <%=roleLabel%></div>
                <%if (u.isActive()) {%>
                <div class="sb-status"><div class="sb-dot"></div> Account active</div>
                <%}%>

                <hr class="sb-divider">

                <nav class="sb-nav">
                    <button class="sb-tab <%="info".equals(tab) ? "active" : ""%>"     onclick="switchTab('info', this)">
                        <i class="fas fa-id-card"></i> Account Overview
                    </button>
                    <button class="sb-tab <%="personal".equals(tab) ? "active" : ""%>" onclick="switchTab('personal', this)">
                        <i class="fas fa-map-location-dot"></i> Personal Info
                    </button>
                    <button class="sb-tab <%="edit".equals(tab) ? "active" : ""%>"     onclick="switchTab('edit', this)">
                        <i class="fas fa-pen-nib"></i> Edit Profile
                    </button>
                    <%if (!isSocial) {%>
                    <button class="sb-tab <%="password".equals(tab) ? "active" : ""%>" onclick="switchTab('password', this)">
                        <i class="fas fa-key"></i> Security
                    </button>
                    <%}%>
                </nav>

                <div class="sb-username">
                    <i class="fas fa-at"></i>
                    <span><%=u.getUsername()%></span>
                </div>
            </aside>

            <!-- ══ MAIN ══ -->
            <main class="main">

                <%if (flashOk != null) {%>
                <div class="flash flash-ok"><i class="fas fa-check-circle"></i> <%=flashOk%></div>
                <%}%>
                <%if (flashErr != null) {%>
                <div class="flash flash-err"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div>
                <%}%>

                <!-- TAB: OVERVIEW -->
                <div id="tab-info" class="tab-panel <%="info".equals(tab) ? "active" : ""%>">
                    <div class="section-eyebrow">Account</div>
                    <div class="section-title">Your <em>profile</em> overview</div>

                    <%
                        int filled = 0, total = 10;
                        if (u.getFullName() != null && !u.getFullName().isEmpty()) {
                            filled++;
                        }
                        if (u.getPhone() != null && !u.getPhone().isEmpty()) {
                            filled++;
                        }
                        if (u.getEmail() != null && !u.getEmail().isEmpty()) {
                            filled++;
                        }
                        if (u.getAddressCity() != null && !u.getAddressCity().isEmpty()) {
                            filled++;
                        }
                        if (u.getAddressDistrict() != null && !u.getAddressDistrict().isEmpty()) {
                            filled++;
                        }
                        if (u.getAddressStreet() != null && !u.getAddressStreet().isEmpty()) {
                            filled++;
                        }
                        if (u.getDateOfBirth() != null) {
                            filled++;
                        }
                        if (u.getGender() != null && !u.getGender().isEmpty()) {
                            filled++;
                        }
                        if (u.getEmergencyPhone() != null && !u.getEmergencyPhone().isEmpty()) {
                            filled++;
                        }
                        if (u.getAvatarUrl() != null && !u.getAvatarUrl().isEmpty()) {
                            filled++;
                        }
                        int pct = (int) Math.round(filled * 100.0 / total);
                    %>
                    <div class="completion-wrap">
                        <div class="completion-header">
                            <span>Profile completion</span>
                            <strong><%=pct%>%</strong>
                        </div>
                        <div class="completion-track">
                            <div class="completion-fill" id="completionBar" style="width:0"></div>
                        </div>
                        <%if (pct < 100) {%>
                        <div class="completion-tip"><i class="fas fa-info-circle"></i>
                            A complete profile helps technicians reach you faster.
                            <a href="javascript:switchTab('personal',null)">Update now →</a>
                        </div>
                        <%}%>
                    </div>

                    <%
                        String fullAddr = u.getAddressFull();
                        if (fullAddr == null || fullAddr.isEmpty())
                            fullAddr = u.buildFullAddress();
                    %>
                    <div class="address-banner">
                        <div class="address-banner-icon"><i class="fas fa-location-dot"></i></div>
                        <div>
                            <div class="address-banner-label">Service address (technician will come here)</div>
                            <div class="address-banner-value <%=fullAddr.isEmpty() ? "empty" : ""%>">
                                <%=fullAddr.isEmpty() ? "No address on file — please update so technicians can navigate to you." : fullAddr%>
                            </div>
                            <%if (!fullAddr.isEmpty()) {%>
                            <a class="map-link" href="https://www.google.com/maps/search/<%=java.net.URLEncoder.encode(fullAddr, "UTF-8")%>" target="_blank">
                                <i class="fab fa-google"></i> Open Google Maps
                            </a>
                            <%}%>
                        </div>
                    </div>

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
                            <div class="info-cell-value"><%=val.apply(u.getEmail())%></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-phone"></i> Phone</div>
                            <div class="info-cell-value"><%=val.apply(u.getPhone())%></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-cake-candles"></i> Date of Birth</div>
                            <div class="info-cell-value">
                                <%=u.getDateOfBirth() != null ? u.getDateOfBirthFormatted() + " (" + u.getAge() + " yrs)" : "<span class='empty'>—</span>"%>
                            </div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-venus-mars"></i> Gender</div>
                            <div class="info-cell-value"><%=val.apply(u.getGenderLabel())%></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-map-pin"></i> Hometown</div>
                            <div class="info-cell-value"><%=val.apply(u.getHometown())%></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-building"></i> Company / Organization</div>
                            <div class="info-cell-value"><%=val.apply(u.getCompanyName())%></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-shield-halved"></i> Role</div>
                            <div class="info-cell-value"><span class="badge badge-gold"><%=roleLabel%></span></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label"><i class="fas fa-circle-check"></i> Status</div>
                            <div class="info-cell-value">
                                <span class="badge <%=u.isActive() ? "badge-green" : "badge-red"%>">
                                    <%=u.isActive() ? "Active" : "Inactive"%>
                                </span>
                            </div>
                        </div>
                        <%if (u.getEmergencyName() != null && !u.getEmergencyName().isEmpty()) {%>
                        <div class="info-cell full-width">
                            <div class="info-cell-label"><i class="fas fa-phone-volume"></i> Emergency Contact</div>
                            <div class="info-cell-value">
                                <%=u.getEmergencyName()%>
                                <%if (u.getEmergencyRelation() != null) {%> (<%=u.getEmergencyRelation()%>) <%}%>
                                — <%=val.apply(u.getEmergencyPhone())%>
                            </div>
                        </div>
                        <%}%>
                        <%if (u.getBio() != null && !u.getBio().isEmpty()) {%>
                        <div class="info-cell full-width">
                            <div class="info-cell-label"><i class="fas fa-quote-left"></i> Bio</div>
                            <div class="info-cell-value" style="color:var(--text-2);font-weight:300;line-height:1.65"><%=u.getBio()%></div>
                        </div>
                        <%}%>
                    </div>

                    <div class="action-row">
                        <button class="btn btn-gold"  onclick="switchTab('personal', this)"><i class="fas fa-map-location-dot"></i> Update Address</button>
                        <button class="btn btn-ghost" onclick="switchTab('edit', this)"><i class="fas fa-pen-nib"></i> Edit Profile</button>
                        <%if (!isSocial) {%>
                        <button class="btn btn-ghost" onclick="switchTab('password', this)"><i class="fas fa-key"></i> Change Password</button>
                        <%} else {%>
                        <div class="social-tag">
                            <i class="<%="GOOGLE".equals(me.getAuthProvider()) ? "fab fa-google" : "fab fa-facebook"%>"
                               style="color:<%="GOOGLE".equals(me.getAuthProvider()) ? "#ea4335" : "#1877f2"%>"></i>
                            Signed in via <%=me.getAuthProvider()%> —
                            <a href="<%="GOOGLE".equals(me.getAuthProvider()) ? "https://myaccount.google.com/security" : "https://www.facebook.com/settings?tab=security"%>" target="_blank">manage here</a>
                        </div>
                        <%}%>
                    </div>
                </div>

                <!-- TAB: PERSONAL INFO -->
                <div id="tab-personal" class="tab-panel <%="personal".equals(tab) ? "active" : ""%>">
                    <div class="section-eyebrow">Personal Info</div>
                    <div class="section-title">Address &amp; <em>detailed information</em></div>

                    <div class="form-card">
                        <form method="post" action="<%=ctx%>/profile">
                            <input type="hidden" name="action" value="updatePersonalInfo">

                            <div class="form-section">
                                <div class="form-section-label"><i class="fas fa-location-dot"></i> Residential Address</div>
                                <div class="field">
                                    <label>Street / House Number</label>
                                    <input type="text" name="addressStreet" value="<%=u.getAddressStreet() != null ? u.getAddressStreet() : ""%>" placeholder="e.g. 12 Nguyen Trai" id="addrStreet" oninput="previewAddress()">
                                </div>
                                <div class="field-row-3">
                                    <div class="field">
                                        <label>Ward / Commune</label>
                                        <input type="text" name="addressWard" value="<%=u.getAddressWard() != null ? u.getAddressWard() : ""%>" placeholder="e.g. Thuong Dinh Ward" id="addrWard" oninput="previewAddress()">
                                    </div>
                                    <div class="field">
                                        <label>District</label>
                                        <input type="text" name="addressDistrict" value="<%=u.getAddressDistrict() != null ? u.getAddressDistrict() : ""%>" placeholder="e.g. Thanh Xuan" id="addrDistrict" oninput="previewAddress()">
                                    </div>
                                    <div class="field">
                                        <label>City / Province</label>
                                        <input type="text" name="addressCity" value="<%=u.getAddressCity() != null ? u.getAddressCity() : ""%>" placeholder="e.g. Ha Noi" id="addrCity" oninput="previewAddress()">
                                    </div>
                                </div>
                                <div class="map-preview" id="mapPreview" style="display:none">
                                    <i class="fas fa-location-dot"></i>
                                    <span id="mapPreviewText"></span>
                                    <a id="mapPreviewLink" href="#" target="_blank" class="btn btn-blue btn-sm" style="margin-left:auto">
                                        <i class="fab fa-google"></i> Google Maps
                                    </a>
                                </div>
                            </div>

                            <div class="form-section">
                                <div class="form-section-label"><i class="fas fa-user"></i> Personal Details</div>
                                <div class="field-row">
                                    <div class="field">
                                        <label>Full Name *</label>
                                        <input type="text" name="fullName" value="<%=u.getFullName() != null ? u.getFullName() : ""%>" required placeholder="Your full name">
                                    </div>
                                    <div class="field">
                                        <label>Phone Number</label>
                                        <input type="tel" name="phone" value="<%=u.getPhone() != null ? u.getPhone() : ""%>" placeholder="e.g. 0901 234 567">
                                    </div>
                                </div>
                                <div class="field-row-3">
                                    <div class="field">
                                        <label>Date of Birth</label>
                                        <input type="date" name="dateOfBirth" value="<%=u.getDateOfBirthIso()%>" max="<%=java.time.LocalDate.now().toString()%>">
                                    </div>
                                    <div class="field">
                                        <label>Gender</label>
                                        <select name="gender">
                                            <option value="">— Select —</option>
                                            <option value="MALE"   <%="MALE".equals(u.getGender()) ? "selected" : ""%>>Male</option>
                                            <option value="FEMALE" <%="FEMALE".equals(u.getGender()) ? "selected" : ""%>>Female</option>
                                            <option value="OTHER"  <%="OTHER".equals(u.getGender()) ? "selected" : ""%>>Other</option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>Hometown</label>
                                        <input type="text" name="hometown" value="<%=u.getHometown() != null ? u.getHometown() : ""%>" placeholder="e.g. Nam Dinh">
                                    </div>
                                </div>
                                <div class="field-row">
                                    <div class="field">
                                        <label>National ID (CCCD)</label>
                                        <input type="text" name="nationalId" value="<%=u.getNationalId() != null ? u.getNationalId() : ""%>" placeholder="12-digit ID number" maxlength="20">
                                        <div class="field-hint"><i class="fas fa-lock"></i> Confidential — internal use only.</div>
                                    </div>
                                    <div class="field">
                                        <label>Company / Organization</label>
                                        <input type="text" name="companyName" value="<%=u.getCompanyName() != null ? u.getCompanyName() : ""%>" placeholder="Company name (if applicable)">
                                    </div>
                                </div>
                                <div class="field">
                                    <label>Bio</label>
                                    <textarea name="bio" placeholder="Short description about yourself..."><%=u.getBio() != null ? u.getBio() : ""%></textarea>
                                </div>
                            </div>

                            <div class="form-section">
                                <div class="form-section-label"><i class="fas fa-phone-volume"></i> Emergency Contact</div>
                                <div class="field-hint" style="margin-bottom:14px;font-size:.79rem"><i class="fas fa-circle-info"></i> Used when a technician cannot reach you directly on-site.</div>
                                <div class="field-row-3">
                                    <div class="field">
                                        <label>Contact Name</label>
                                        <input type="text" name="emergencyName" value="<%=u.getEmergencyName() != null ? u.getEmergencyName() : ""%>" placeholder="e.g. Nguyen Van A">
                                    </div>
                                    <div class="field">
                                        <label>Phone Number</label>
                                        <input type="tel" name="emergencyPhone" value="<%=u.getEmergencyPhone() != null ? u.getEmergencyPhone() : ""%>" placeholder="e.g. 0912 345 678">
                                    </div>
                                    <div class="field">
                                        <label>Relationship</label>
                                        <select name="emergencyRelation">
                                            <option value="">— Select —</option>
                                            <%
                                                String er = u.getEmergencyRelation();
                                                String[] relations = {"Spouse", "Parent", "Child", "Sibling", "Friend", "Colleague", "Other"};
                                                for (String r : relations) {
                                                    boolean sel = r.equals(er);
                                            %><option value="<%=r%>" <%=sel ? "selected" : ""%>><%=r%></option><%}%>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="form-footer">
                                <button type="button" class="btn btn-ghost btn-sm" onclick="switchTab('info', this)">Cancel</button>
                                <button type="submit" class="btn btn-gold btn-sm"><i class="fas fa-check"></i> Save Information</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- TAB: EDIT PROFILE -->
                <div id="tab-edit" class="tab-panel <%="edit".equals(tab) ? "active" : ""%>">
                    <div class="section-eyebrow">Edit</div>
                    <div class="section-title">Update your <em>basic information</em></div>

                    <div class="form-card">
                        <form method="post" action="<%=ctx%>/profile">
                            <input type="hidden" name="action" value="updateInfo">
                            <div class="form-section">
                                <div class="form-section-label">Personal Information</div>
                                <div class="field-row">
                                    <div class="field">
                                        <label>Full Name *</label>
                                        <input type="text" name="fullName" value="<%=u.getFullName() != null ? u.getFullName() : ""%>" required placeholder="Your full name">
                                    </div>
                                    <div class="field">
                                        <label>Phone Number</label>
                                        <input type="text" name="phone" value="<%=u.getPhone() != null ? u.getPhone() : ""%>" placeholder="e.g. 0901 234 567">
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
                                        <input type="email" value="<%=u.getEmail() != null ? u.getEmail() : ""%>" readonly>
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

                <!-- TAB: SECURITY -->
                <div id="tab-password" class="tab-panel <%="password".equals(tab) ? "active" : ""%>">
                    <%if (isSocial) {%>
                    <div class="section-eyebrow">Security</div>
                    <div class="section-title"><em>Managed</em> externally</div>
                    <div class="form-card">
                        <div class="empty-state">
                            <div class="empty-icon"><i class="fas fa-lock"></i></div>
                            <div class="empty-title">Password managed via <%=me.getAuthProvider()%></div>
                            <div class="empty-sub">Your account is authenticated through <strong><%=me.getAuthProvider()%></strong>. To change your password, visit your provider's security settings.</div>
                            <%if ("GOOGLE".equals(me.getAuthProvider())) {%>
                            <a href="https://myaccount.google.com/security" target="_blank" class="btn btn-ghost"><i class="fab fa-google" style="color:#ea4335"></i> Google Account Settings</a>
                            <%} else {%>
                            <a href="https://www.facebook.com/settings?tab=security" target="_blank" class="btn btn-ghost"><i class="fab fa-facebook" style="color:#1877f2"></i> Facebook Security Settings</a>
                            <%}%>
                        </div>
                    </div>
                    <%} else {%>
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
                    <%}%>
                </div>

            </main>
        </div>

        <script>
            /* ── AURORA (brighter, warmer) ── */
            (function () {
                const c = document.getElementById('aurora'), gl = c.getContext('2d');
                let W, H, t = 0;
                function resize() {
                    W = c.width = window.innerWidth;
                    H = c.height = window.innerHeight;
                }
                resize();
                window.addEventListener('resize', resize);
                const blobs = [
                    {x: .12, y: .25, r: .50, hue: 230, sat: 80, bri: 65, a: .28, spd: .00035},
                    {x: .78, y: .12, r: .58, hue: 260, sat: 70, bri: 60, a: .20, spd: .00028},
                    {x: .50, y: .72, r: .42, hue: 210, sat: 75, bri: 65, a: .18, spd: .00045},
                    {x: .88, y: .58, r: .38, hue: 280, sat: 65, bri: 58, a: .13, spd: .00055},
                    {x: .25, y: .85, r: .32, hue: 195, sat: 80, bri: 68, a: .14, spd: .00040},
                ];
                function draw() {
                    gl.clearRect(0, 0, W, H);
                    blobs.forEach((b, i) => {
                        const x = (b.x + Math.sin(t * b.spd * 1000 + i) * 0.09) * W;
                        const y = (b.y + Math.cos(t * b.spd * 800 + i) * 0.07) * H;
                        const r = b.r * Math.min(W, H);
                        const g = gl.createRadialGradient(x, y, 0, x, y, r);
                        const hShift = Math.sin(t * .0008) * 20;
                        g.addColorStop(0, `hsla(${b.hue+hShift},${b.sat}%,${b.bri}%,${b.a})`);
                        g.addColorStop(.5, `hsla(${b.hue+hShift+15},${b.sat-10}%,${b.bri-8}%,${b.a*.4})`);
                        g.addColorStop(1, `hsla(${b.hue},${b.sat-20}%,${b.bri-15}%,0)`);
                        gl.fillStyle = g;
                        gl.fillRect(0, 0, W, H);
                    });
                    t++;
                    requestAnimationFrame(draw);
                }
                draw();
            })();

            /* COMPLETION */
            window.addEventListener('load', () => {
                const bar = document.getElementById('completionBar');
                if (bar)
                    setTimeout(() => {
                        bar.style.width = '<%=pct%>%';
                    }, 400);
            });

            /* TAB SWITCHING */
            function switchTab(name, el) {
                document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
                document.querySelectorAll('.sb-tab').forEach(b => b.classList.remove('active'));
                document.getElementById('tab-' + name).classList.add('active');
                document.querySelectorAll('.sb-tab').forEach(b => {
                    if (b.getAttribute('onclick') && b.getAttribute('onclick').includes("'" + name + "'"))
                        b.classList.add('active');
                });
                if (name === 'info') {
                    const bar = document.getElementById('completionBar');
                    if (bar) {
                        bar.style.width = '0';
                        setTimeout(() => {
                            bar.style.width = '<%=pct%>%';
                        }, 100);
                    }
                }
            }

            /* ADDRESS PREVIEW */
            function previewAddress() {
                const s = document.getElementById('addrStreet')?.value.trim() || '';
                const w = document.getElementById('addrWard')?.value.trim() || '';
                const d = document.getElementById('addrDistrict')?.value.trim() || '';
                const c = document.getElementById('addrCity')?.value.trim() || '';
                const parts = [s, w, d, c].filter(Boolean);
                const box = document.getElementById('mapPreview');
                const txt = document.getElementById('mapPreviewText');
                const lnk = document.getElementById('mapPreviewLink');
                if (parts.length >= 2) {
                    const full = parts.join(', ');
                    txt.textContent = full;
                    lnk.href = 'https://www.google.com/maps/search/' + encodeURIComponent(full);
                    box.style.display = 'flex';
                } else {
                    box.style.display = 'none';
                }
            }
            window.addEventListener('DOMContentLoaded', previewAddress);

            /* AVATAR UPLOAD */
            function uploadAvatar(input) {
                const file = input.files[0];
                if (!file)
                    return;
                if (!['image/jpeg', 'image/png', 'image/gif', 'image/webp'].includes(file.type)) {
                    alert('Only JPG, PNG, GIF, WEBP allowed!');
                    return;
                }
                if (file.size > 2 * 1024 * 1024) {
                    alert('Max file size: 2MB.');
                    return;
                }
                const reader = new FileReader();
                reader.onload = e => {
                    document.getElementById('avatarPreview').innerHTML = '<img src="' + e.target.result + '" style="width:96px;height:96px;border-radius:50%;object-fit:cover">';
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
                        document.getElementById('avatarPreview').innerHTML = '<img src="' + data.url + '?t=' + Date.now() + '" style="width:96px;height:96px;border-radius:50%;object-fit:cover">';
                        showToast('Avatar updated successfully', 'ok');
                    } else {
                        showToast(data.error || 'Upload failed', 'err');
                    }
                }).catch(() => {
                    ov.innerHTML = '<i class="fas fa-camera"></i>';
                    ov.style.opacity = '0';
                    showToast('Upload failed', 'err');
                });
            }

            /* TOAST */
            function showToast(msg, type) {
                const t = document.createElement('div');
                const ok = type === 'ok';
                t.style.cssText = `position:fixed;bottom:32px;right:32px;padding:13px 20px;border-radius:12px;font-family:'DM Sans',sans-serif;font-size:.83rem;font-weight:500;z-index:9999;display:flex;align-items:center;gap:9px;backdrop-filter:blur(20px);animation:toastIn .35s cubic-bezier(.4,0,.2,1);box-shadow:0 16px 40px rgba(0,0,0,.5)`;
                t.style.background = ok ? 'rgba(94,217,176,.14)' : 'rgba(244,123,116,.14)';
                t.style.color = ok ? '#5ed9b0' : '#f47b74';
                t.style.border = ok ? '1px solid rgba(94,217,176,.3)' : '1px solid rgba(244,123,116,.3)';
                t.innerHTML = `<i class="fas fa-${ok?'check-circle':'exclamation-circle'}"></i>${msg}`;
                document.body.appendChild(t);
                setTimeout(() => {
                    t.style.animation = 'toastOut .3s ease forwards';
                    setTimeout(() => t.remove(), 300);
                }, 3000);
            }
            const style = document.createElement('style');
            style.textContent = `@keyframes toastIn{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:none}}@keyframes toastOut{to{opacity:0;transform:translateY(8px)}}`;
            document.head.appendChild(style);

            /* PASSWORD */
            function togglePass(id, btn) {
                const inp = document.getElementById(id);
                const isPass = inp.type === 'password';
                inp.type = isPass ? 'text' : 'password';
                btn.querySelector('i').className = isPass ? 'fas fa-eye-slash' : 'fas fa-eye';
            }
            function checkStrength(val) {
                const fill = document.getElementById('strengthFill'), text = document.getElementById('strengthText');
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
                    {p: '20%', c: '#f47b74', l: 'Very Weak'}, {p: '40%', c: '#fb923c', l: 'Weak'},
                    {p: '60%', c: '#fbbf24', l: 'Fair'}, {p: '80%', c: '#5ed9b0', l: 'Strong'}, {p: '100%', c: '#e2b95a', l: 'Excellent'}
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
                        ? '<span style="color:#5ed9b0"><i class="fas fa-check"></i> Passwords match</span>'
                        : '<span style="color:#f47b74"><i class="fas fa-times"></i> Passwords do not match</span>';
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
                        alert('Minimum 6 characters required!');
                    }
                });
        </script>
    </body>
</html>
