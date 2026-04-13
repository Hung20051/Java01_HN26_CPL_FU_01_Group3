<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Register - DRSMS System</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --navy:        #0b1437;
                --navy-2:      #0f1c4d;
                --navy-card:   #111a42;
                --accent:      #4f7ef8;
                --accent-2:    #7c9ffa;
                --accent-glow: rgba(79,126,248,0.25);
                --green:       #34d399;
                --green-glow:  rgba(52,211,153,0.2);
                --text:        #ffffff;
                --text-2:      #c8d4f0;
                --muted:       #7a8ab8;
                --border:      rgba(255,255,255,0.08);
                --border-focus:rgba(79,126,248,0.5);
                --danger:      #f87171;
                --success:     #34d399;
                --amber:       #fbbf24;

                /* Modal light palette */
                --m-bg:        #ffffff;
                --m-bg-2:      #f8fafc;
                --m-bg-3:      #f1f5f9;
                --m-border:    #e2e8f0;
                --m-border-2:  #eef2f7;
                --m-text:      #0f172a;
                --m-text-2:    #334155;
                --m-text-3:    #64748b;
                --m-text-4:    #94a3b8;
                --m-primary:   #4f46e5;
                --m-primary-2: #6366f1;
                --m-green:     #16a34a;
                --m-amber:     #d97706;
                --m-red:       #dc2626;
                --m-blue:      #2563eb;
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
                background:var(--navy);
                color:var(--text);
                min-height:100vh;
                display:flex;
                flex-direction:column
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

            /* ── NAVBAR ── */
            .navbar{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:20px 64px;
                border-bottom:1px solid var(--border);
                background:rgba(11,20,55,0.8);
                backdrop-filter:blur(16px);
                position:sticky;
                top:0;
                z-index:10
            }
            .navbar-brand{
                display:flex;
                align-items:center;
                gap:10px;
                font-size:1.1rem;
                font-weight:700;
                color:white;
                text-decoration:none
            }
            .brand-icon{
                width:36px;
                height:36px;
                background:linear-gradient(135deg,var(--accent),var(--accent-2));
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:white;
                font-size:.85rem;
                box-shadow:0 4px 12px var(--accent-glow)
            }
            .navbar-links{
                display:flex;
                align-items:center;
                gap:20px
            }
            .nav-link{
                font-size:.82rem;
                font-weight:500;
                color:var(--muted);
                text-decoration:none;
                transition:color .25s
            }
            .nav-link:hover{
                color:white
            }
            .btn-nav{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:8px 18px;
                background:rgba(79,126,248,.15);
                border:1px solid rgba(79,126,248,.3);
                color:var(--accent-2);
                text-decoration:none;
                font-size:.82rem;
                font-weight:600;
                border-radius:100px;
                transition:all .25s
            }
            .btn-nav:hover{
                background:rgba(79,126,248,.25);
                color:white
            }

            /* ── PAGE WRAP ── */
            .page-wrap{
                flex:1;
                display:flex;
                align-items:center;
                justify-content:center;
                position:relative;
                overflow:hidden;
                padding:48px 20px
            }
            .orb{
                position:absolute;
                border-radius:50%;
                filter:blur(100px);
                pointer-events:none
            }
            .orb-1{
                width:550px;
                height:550px;
                background:radial-gradient(circle,rgba(79,126,248,.18) 0%,transparent 70%);
                top:-120px;
                right:5%;
                animation:orbFloat 10s ease-in-out infinite
            }
            .orb-2{
                width:380px;
                height:380px;
                background:radial-gradient(circle,rgba(52,211,153,.1) 0%,transparent 70%);
                bottom:-60px;
                left:5%;
                animation:orbFloat 14s ease-in-out infinite reverse
            }
            .orb-3{
                width:300px;
                height:300px;
                background:radial-gradient(circle,rgba(167,139,250,.1) 0%,transparent 70%);
                top:50%;
                left:30%;
                animation:orbFloat 18s ease-in-out infinite
            }
            @keyframes orbFloat{
                0%,100%{
                    transform:translate(0,0)
                }
                50%{
                    transform:translate(20px,-25px)
                }
            }

            /* ── WRAPPER ── */
            .register-wrapper{
                display:flex;
                align-items:center;
                gap:56px;
                width:100%;
                max-width:960px;
                position:relative;
                z-index:1
            }

            /* ── INFO PANEL ── */
            .info-panel{
                flex:1;
                animation:fadeUp .7s .2s cubic-bezier(.4,0,.2,1) both
            }
            @keyframes fadeUp{
                from{
                    opacity:0;
                    transform:translateY(20px)
                }
                to{
                    opacity:1;
                    transform:translateY(0)
                }
            }
            .info-eyebrow{
                display:inline-flex;
                align-items:center;
                gap:8px;
                font-size:.68rem;
                font-weight:700;
                letter-spacing:2px;
                text-transform:uppercase;
                color:var(--green);
                margin-bottom:16px
            }
            .info-eyebrow::before{
                content:'';
                display:inline-block;
                width:18px;
                height:2px;
                background:var(--green);
                border-radius:2px
            }
            .info-title{
                font-size:clamp(1.6rem,2.5vw,2.4rem);
                font-weight:800;
                line-height:1.15;
                letter-spacing:-.8px;
                color:white;
                margin-bottom:14px
            }
            .info-title .highlight{
                background:linear-gradient(135deg,#6ef0ff 0%,var(--green) 60%,#a78bfa 100%);
                -webkit-background-clip:text;
                -webkit-text-fill-color:transparent;
                background-clip:text
            }
            .info-sub{
                font-size:.88rem;
                font-weight:300;
                color:var(--muted);
                line-height:1.8;
                margin-bottom:32px
            }
            .step-list{
                display:flex;
                flex-direction:column;
                gap:14px
            }
            .step-item{
                display:flex;
                align-items:flex-start;
                gap:14px;
                padding:12px 16px;
                background:rgba(255,255,255,.03);
                border:1px solid var(--border);
                border-radius:14px;
                transition:all .25s
            }
            .step-item:hover{
                background:rgba(52,211,153,.06);
                border-color:rgba(52,211,153,.2)
            }
            .step-num{
                width:28px;
                height:28px;
                flex-shrink:0;
                border-radius:8px;
                background:rgba(52,211,153,.12);
                color:var(--green);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.75rem;
                font-weight:700
            }
            .step-text{
                font-size:.83rem;
                color:var(--text-2);
                line-height:1.5
            }
            .step-text strong{
                color:white;
                display:block;
                margin-bottom:2px;
                font-weight:600
            }

            /* ── REGISTER CARD ── */
            .register-card{
                flex-shrink:0;
                width:440px;
                background:rgba(17,26,66,.75);
                border:1px solid var(--border);
                border-radius:28px;
                padding:40px 38px;
                backdrop-filter:blur(24px);
                box-shadow:0 0 0 1px rgba(52,211,153,.06),0 32px 80px rgba(0,0,0,.45),inset 0 1px 0 rgba(255,255,255,.07);
                animation:cardIn .6s cubic-bezier(.4,0,.2,1) both
            }
            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(28px) scale(.97)
                }
                to{
                    opacity:1;
                    transform:translateY(0) scale(1)
                }
            }
            .card-badge{
                display:inline-flex;
                align-items:center;
                gap:6px;
                background:rgba(52,211,153,.1);
                border:1px solid rgba(52,211,153,.25);
                color:var(--green);
                font-size:.68rem;
                font-weight:700;
                letter-spacing:1.5px;
                text-transform:uppercase;
                padding:5px 12px;
                border-radius:100px;
                margin-bottom:18px
            }
            .card-title{
                font-size:1.65rem;
                font-weight:800;
                color:white;
                letter-spacing:-.5px;
                margin-bottom:4px;
                line-height:1.15
            }
            .card-sub{
                font-size:.82rem;
                color:var(--muted);
                font-weight:300;
                margin-bottom:24px
            }

            .alert{
                display:flex;
                align-items:center;
                gap:9px;
                padding:11px 14px;
                border-radius:10px;
                font-size:.82rem;
                font-weight:500;
                margin-bottom:16px
            }
            .alert-error{
                background:rgba(248,113,113,.12);
                border:1px solid rgba(248,113,113,.25);
                color:var(--danger)
            }

            .form-row{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:14px
            }
            .form-group{
                margin-bottom:15px
            }
            .form-label{
                display:block;
                font-size:.72rem;
                font-weight:600;
                color:var(--text-2);
                margin-bottom:7px;
                letter-spacing:.5px;
                text-transform:uppercase
            }
            .required{
                color:var(--danger);
                margin-left:2px
            }
            .input-wrap{
                position:relative
            }
            .input-icon{
                position:absolute;
                left:13px;
                top:50%;
                transform:translateY(-50%);
                color:var(--muted);
                font-size:.8rem;
                pointer-events:none;
                transition:color .25s
            }
            .form-input{
                width:100%;
                padding:11px 13px 11px 38px;
                background:rgba(255,255,255,.05);
                border:1px solid var(--border);
                border-radius:11px;
                color:white;
                font-family:'Sora',sans-serif;
                font-size:.85rem;
                outline:none;
                transition:all .25s
            }
            .form-input::placeholder{
                color:var(--muted)
            }
            .form-input:focus{
                border-color:var(--border-focus);
                background:rgba(79,126,248,.07);
                box-shadow:0 0 0 3px rgba(79,126,248,.12)
            }
            .input-wrap:focus-within .input-icon{
                color:var(--accent-2)
            }
            .toggle-pass{
                position:absolute;
                right:13px;
                top:50%;
                transform:translateY(-50%);
                color:var(--muted);
                cursor:pointer;
                font-size:.8rem;
                transition:color .25s
            }
            .toggle-pass:hover{
                color:var(--accent-2)
            }

            .checkbox-group{
                margin-top:4px;
                margin-bottom:6px
            }
            .checkbox-label{
                display:flex;
                align-items:flex-start;
                gap:10px;
                font-size:.78rem;
                color:var(--muted);
                cursor:pointer;
                line-height:1.5
            }
            .checkbox-label input[type=checkbox]{
                width:15px;
                height:15px;
                flex-shrink:0;
                margin-top:2px;
                accent-color:var(--green)
            }
            .terms-link{
                color:var(--green);
                text-decoration:none;
                font-weight:600;
                cursor:pointer;
                background:none;
                border:none;
                font-family:inherit;
                font-size:inherit;
                padding:0
            }
            .terms-link:hover{
                color:white;
                text-decoration:underline
            }

            .btn-primary{
                width:100%;
                padding:13px;
                background:linear-gradient(135deg,#22c97a,var(--green));
                border:none;
                border-radius:12px;
                color:white;
                font-family:'Sora',sans-serif;
                font-size:.88rem;
                font-weight:700;
                cursor:pointer;
                transition:all .3s cubic-bezier(.4,0,.2,1);
                box-shadow:0 6px 24px var(--green-glow);
                display:flex;
                align-items:center;
                justify-content:center;
                gap:8px;
                margin-top:18px
            }
            .btn-primary:hover{
                transform:translateY(-2px);
                box-shadow:0 14px 36px rgba(52,211,153,.4)
            }
            .btn-primary:active{
                transform:translateY(0)
            }

            .login-cta{
                text-align:center;
                margin-top:18px;
                font-size:.8rem;
                color:var(--muted)
            }
            .login-cta a{
                color:var(--accent-2);
                text-decoration:none;
                font-weight:600;
                transition:color .2s
            }
            .login-cta a:hover{
                color:white
            }

            @media(max-width:860px){
                .register-wrapper{
                    flex-direction:column;
                    gap:32px;
                    max-width:440px
                }
                .info-panel{
                    order:-1
                }
                .register-card{
                    width:100%
                }
                .form-row{
                    grid-template-columns:1fr;
                    gap:0
                }
            }

            /* ════════════════════════════════════════
               TERMS MODAL — LIGHT WHITE THEME
            ════════════════════════════════════════ */
            .t-overlay{
                display:none;
                position:fixed;
                inset:0;
                background:rgba(15,23,42,0.55);
                z-index:1000;
                align-items:center;
                justify-content:center;
                padding:16px;
                backdrop-filter:blur(6px)
            }
            .t-overlay.open{
                display:flex
            }

            .t-modal{
                background:var(--m-bg);
                border:1px solid var(--m-border);
                border-radius:20px;
                width:100%;
                max-width:680px;
                max-height:84vh;
                display:flex;
                flex-direction:column;
                overflow:hidden;
                box-shadow:0 24px 60px rgba(0,0,0,0.2), 0 4px 16px rgba(0,0,0,0.08);
                animation:modalIn .25s cubic-bezier(.4,0,.2,1)
            }
            @keyframes modalIn{
                from{
                    opacity:0;
                    transform:translateY(16px) scale(.97)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }

            /* Header */
            .t-head{
                padding:20px 24px 16px;
                border-bottom:1px solid var(--m-border);
                display:flex;
                align-items:flex-start;
                justify-content:space-between;
                gap:12px;
                flex-shrink:0;
                background:var(--m-bg);
            }
            .t-head-left{
                display:flex;
                align-items:center;
                gap:12px
            }
            .t-icon{
                width:40px;
                height:40px;
                border-radius:12px;
                background:#d1fae5;
                border:1px solid #a7f3d0;
                display:flex;
                align-items:center;
                justify-content:center;
                color:var(--m-green);
                font-size:1rem;
                flex-shrink:0;
            }
            .t-title{
                font-size:1.02rem;
                font-weight:800;
                color:var(--m-text);
                line-height:1.2
            }
            .t-version{
                font-size:.68rem;
                color:var(--m-text-4);
                margin-top:2px
            }
            .t-close{
                background:#f1f5f9;
                border:1px solid var(--m-border);
                border-radius:9px;
                width:32px;
                height:32px;
                cursor:pointer;
                display:flex;
                align-items:center;
                justify-content:center;
                color:var(--m-text-3);
                font-size:.8rem;
                transition:all .2s;
                flex-shrink:0;
            }
            .t-close:hover{
                background:#fee2e2;
                border-color:#fca5a5;
                color:var(--m-red)
            }

            /* Tabs */
            .t-tabs{
                display:flex;
                gap:0;
                padding:0 20px;
                border-bottom:1px solid var(--m-border);
                overflow-x:auto;
                flex-shrink:0;
                background:var(--m-bg-2);
            }
            .t-tabs::-webkit-scrollbar{
                height:0
            }
            .t-tab{
                font-size:.72rem;
                font-weight:600;
                color:var(--m-text-3);
                background:none;
                border:none;
                cursor:pointer;
                padding:10px 12px;
                border-bottom:2px solid transparent;
                white-space:nowrap;
                transition:all .15s;
                font-family:'Sora',sans-serif;
            }
            .t-tab:hover{
                color:var(--m-text-2)
            }
            .t-tab.on{
                color:var(--m-primary);
                border-bottom-color:var(--m-primary);
                font-weight:700
            }

            /* Body */
            .t-body{
                flex:1;
                overflow-y:auto;
                padding:22px 24px;
                min-height:0;
                background:var(--m-bg)
            }
            .t-body::-webkit-scrollbar{
                width:4px
            }
            .t-body::-webkit-scrollbar-track{
                background:transparent
            }
            .t-body::-webkit-scrollbar-thumb{
                background:rgba(79,70,229,0.2);
                border-radius:4px
            }

            .t-sec{
                display:none
            }
            .t-sec.on{
                display:block
            }

            .t-sec-title{
                font-size:.9rem;
                font-weight:700;
                color:var(--m-text);
                margin-bottom:14px;
                display:flex;
                align-items:center;
                gap:10px;
            }
            .t-sec-num{
                width:24px;
                height:24px;
                border-radius:7px;
                background:#ede9fe;
                color:var(--m-primary);
                font-size:.7rem;
                font-weight:700;
                display:flex;
                align-items:center;
                justify-content:center;
                flex-shrink:0;
            }

            .t-p{
                font-size:.82rem;
                color:var(--m-text-2);
                line-height:1.8;
                margin-bottom:12px
            }

            .t-clause{
                background:var(--m-bg-2);
                border:1px solid var(--m-border-2);
                border-radius:11px;
                padding:13px 15px;
                margin-bottom:8px;
                border-left:3px solid var(--m-primary);
            }
            .t-clause-h{
                font-size:.76rem;
                font-weight:700;
                color:var(--m-text);
                margin-bottom:6px;
                display:flex;
                align-items:center;
                gap:7px;
            }
            .t-clause-h::before{
                content:'';
                width:3px;
                height:12px;
                background:var(--m-primary);
                border-radius:2px;
                display:inline-block;
                flex-shrink:0
            }
            .t-clause-t{
                font-size:.78rem;
                color:var(--m-text-2);
                line-height:1.75
            }

            /* Tags */
            .t-tag{
                display:inline-block;
                font-size:.65rem;
                font-weight:700;
                padding:2px 8px;
                border-radius:100px;
                margin-right:4px
            }
            .t-tag-blue  {
                background:#dbeafe;
                color:var(--m-blue);
                border:1px solid #bfdbfe
            }
            .t-tag-amber {
                background:#fef3c7;
                color:var(--m-amber);
                border:1px solid #fde68a
            }
            .t-tag-red   {
                background:#fee2e2;
                color:var(--m-red);
                border:1px solid #fca5a5
            }
            .t-tag-green {
                background:#d1fae5;
                color:var(--m-green);
                border:1px solid #a7f3d0
            }

            .t-notice{
                background:#fffbeb;
                border:1px solid #fde68a;
                border-radius:10px;
                padding:12px 14px;
                margin-top:10px;
            }
            .t-notice p{
                font-size:.78rem;
                color:#92400e;
                margin:0;
                line-height:1.6
            }

            .t-contact{
                background:var(--m-bg-2);
                border:1px solid var(--m-border);
                border-radius:10px;
                padding:13px 15px;
                margin-top:14px;
            }
            .t-contact p{
                font-size:.76rem;
                color:var(--m-text-3);
                margin:0;
                line-height:1.75
            }
            .t-contact a{
                color:var(--m-primary);
                text-decoration:none;
                font-weight:600
            }
            .t-contact a:hover{
                color:var(--m-primary-2);
                text-decoration:underline
            }

            /* Footer */
            .t-foot{
                padding:14px 24px;
                border-top:1px solid var(--m-border);
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:12px;
                flex-shrink:0;
                background:var(--m-bg-2);
            }
            .t-progress{
                font-size:.72rem;
                color:var(--m-text-3);
                display:flex;
                align-items:center;
                gap:8px
            }
            .t-dots{
                display:flex;
                gap:4px
            }
            .t-dot{
                width:6px;
                height:6px;
                border-radius:50%;
                background:var(--m-border);
                transition:all .2s;
                cursor:pointer
            }
            .t-dot.on{
                background:var(--m-primary);
                width:18px;
                border-radius:3px
            }

            .t-foot-btns{
                display:flex;
                gap:8px
            }
            .t-btn-prev,.t-btn-next{
                padding:7px 14px;
                border-radius:9px;
                font-family:'Sora',sans-serif;
                font-size:.75rem;
                font-weight:600;
                cursor:pointer;
                transition:all .2s;
                border:1px solid var(--m-border);
                background:#fff;
                color:var(--m-text-2);
            }
            .t-btn-prev:hover,.t-btn-next:hover{
                background:var(--m-bg-3);
                color:var(--m-text);
                border-color:#cbd5e1
            }
            .t-btn-accept{
                padding:7px 20px;
                border-radius:9px;
                font-family:'Sora',sans-serif;
                font-size:.75rem;
                font-weight:700;
                cursor:pointer;
                transition:all .2s;
                border:none;
                background:var(--m-primary);
                color:#fff;
                display:none;
            }
            .t-btn-accept:hover{
                background:var(--m-primary-2);
                transform:translateY(-1px);
                box-shadow:0 4px 12px rgba(79,70,229,0.3)
            }
            .t-btn-accepted{
                padding:7px 20px;
                border-radius:9px;
                font-family:'Sora',sans-serif;
                font-size:.75rem;
                font-weight:700;
                border:1px solid #a7f3d0;
                background:#d1fae5;
                color:var(--m-green);
                display:none;
            }
        </style>
    </head>
    <body>

        <nav class="navbar">
            <a href="home.jsp" class="navbar-brand">
                <div class="brand-icon"><i class="fas fa-bolt"></i></div>
                DRSMS
            </a>
            <div class="navbar-links">
                <a href="home.jsp" class="nav-link">Home</a>
                <a href="login.jsp" class="btn-nav"><i class="fas fa-sign-in-alt"></i> Login</a>
            </div>
        </nav>

        <div class="page-wrap">
            <div class="orb orb-1"></div>
            <div class="orb orb-2"></div>
            <div class="orb orb-3"></div>

            <div class="register-wrapper">

                <!-- INFO PANEL -->
                <div class="info-panel">
                    <div class="info-eyebrow">Get started</div>
                    <h1 class="info-title">Join DRSMS<br><span class="highlight">in Minutes</span></h1>
                    <p class="info-sub">Create your free account and start managing your repair service operation from one powerful, unified platform.</p>
                    <div class="step-list">
                        <div class="step-item">
                            <div class="step-num">1</div>
                            <div class="step-text"><strong>Fill in your details</strong>Name, email, phone and username to identify your account.</div>
                        </div>
                        <div class="step-item">
                            <div class="step-num">2</div>
                            <div class="step-text"><strong>Set a secure password</strong>Minimum 6 characters to keep your account safe.</div>
                        </div>
                        <div class="step-item">
                            <div class="step-num">3</div>
                            <div class="step-text"><strong>Start managing repairs</strong>Access your full dashboard immediately after registration.</div>
                        </div>
                        <div class="step-item">
                            <div class="step-num">✓</div>
                            <div class="step-text"><strong>Free &amp; instant access</strong>No credit card required. Up and running in seconds.</div>
                        </div>
                    </div>
                </div>

                <!-- REGISTER CARD -->
                <div class="register-card">
                    <div class="card-badge"><i class="fas fa-user-plus"></i> New Account</div>
                    <div class="card-title">Create Account</div>
                    <div class="card-sub">Fill in the form below to get started.</div>

                    <% String error = (String) request.getAttribute("error"); %>
                    <% if (error != null) {%>
                    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error%></div>
                    <% }%>

                    <form action="register" method="post" id="registerForm">
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Full Name <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <i class="fas fa-id-card input-icon"></i>
                                    <input class="form-input" type="text" name="fullName" placeholder="Your full name" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Phone <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <i class="fas fa-phone input-icon"></i>
                                    <input class="form-input" type="tel" name="phone" placeholder="Phone number" required>
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Email <span class="required">*</span></label>
                            <div class="input-wrap">
                                <i class="fas fa-envelope input-icon"></i>
                                <input class="form-input" type="email" name="email" placeholder="example@domain.com" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Username <span class="required">*</span></label>
                            <div class="input-wrap">
                                <i class="fas fa-user input-icon"></i>
                                <input class="form-input" type="text" name="username" placeholder="Choose a username" required>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Password <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <i class="fas fa-lock input-icon"></i>
                                    <input class="form-input" type="password" name="password" id="regPass" placeholder="Min. 6 chars" required minlength="6">
                                    <i class="fas fa-eye toggle-pass" onclick="togglePass('regPass', this)"></i>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Confirm <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <i class="fas fa-lock input-icon"></i>
                                    <input class="form-input" type="password" name="confirmPassword" id="regPass2" placeholder="Repeat password" required minlength="6">
                                    <i class="fas fa-eye toggle-pass" onclick="togglePass('regPass2', this)"></i>
                                </div>
                            </div>
                        </div>

                        <div class="form-group checkbox-group">
                            <label class="checkbox-label">
                                <input type="checkbox" id="termsCheck" required>
                                I have read and agree to the
                                <button type="button" class="terms-link" onclick="openTerms()">Terms &amp; Conditions</button>.
                            </label>
                        </div>

                        <button type="submit" class="btn-primary">
                            <i class="fas fa-user-plus"></i> Create Account
                        </button>
                    </form>

                    <p class="login-cta">Already have an account? <a href="login.jsp">Sign in</a></p>
                </div>
            </div>
        </div>

        <!-- ═══════════════════════════════════
             TERMS & CONDITIONS MODAL — LIGHT
        ═══════════════════════════════════ -->
        <div class="t-overlay" id="termsOverlay" onclick="overlayClick(event)">
            <div class="t-modal" id="termsModal">

                <div class="t-head">
                    <div class="t-head-left">
                        <div class="t-icon"><i class="fas fa-file-contract"></i></div>
                        <div>
                            <div class="t-title">Terms &amp; Conditions</div>
                            <div class="t-version">DRSMS — Device Repair &amp; Service Management System · v2.1 · Effective Jan 2025</div>
                        </div>
                    </div>
                    <button class="t-close" onclick="closeTerms()"><i class="fas fa-times"></i></button>
                </div>

                <div class="t-tabs" id="termsTabs">
                    <button class="t-tab on" onclick="showSec(0)">1. Acceptance</button>
                    <button class="t-tab"   onclick="showSec(1)">2. Account</button>
                    <button class="t-tab"   onclick="showSec(2)">3. Services</button>
                    <button class="t-tab"   onclick="showSec(3)">4. Privacy</button>
                    <button class="t-tab"   onclick="showSec(4)">5. Payments</button>
                    <button class="t-tab"   onclick="showSec(5)">6. Liability</button>
                    <button class="t-tab"   onclick="showSec(6)">7. Termination</button>
                    <button class="t-tab"   onclick="showSec(7)">8. Governing Law</button>
                </div>

                <div class="t-body" id="termsBody">

                    <!-- ── SECTION 1 ── -->
                    <div class="t-sec on" id="ts0">
                        <div class="t-sec-title"><span class="t-sec-num">1</span> Acceptance of Terms</div>
                        <p class="t-p">By registering an account on DRSMS, you confirm that you have read, understood, and agree to be legally bound by these Terms &amp; Conditions in their entirety. If you do not agree to any part of these terms, you must not use the platform.</p>
                        <p class="t-p">These terms apply to all users of DRSMS, including customers, technicians, customer support staff, storekeepers, technical managers, and administrators. Each role may be subject to additional terms communicated at onboarding.</p>
                        <div class="t-clause">
                            <div class="t-clause-h">Age requirement</div>
                            <div class="t-clause-t">You must be at least 18 years of age to create an account. By registering, you represent and warrant that you meet this requirement and have full legal capacity to enter into a binding agreement.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Modifications to these terms</div>
                            <div class="t-clause-t">DRSMS reserves the right to update these terms at any time. Continued use of the platform after any modification constitutes acceptance of the revised terms. We will notify registered users via email for material changes at least 14 days in advance.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Entire agreement</div>
                            <div class="t-clause-t">These Terms &amp; Conditions, together with our Privacy Policy, constitute the entire agreement between you and DRSMS regarding your use of the platform and supersede all prior agreements, representations, and understandings.</div>
                        </div>
                    </div>

                    <!-- ── SECTION 2 ── -->
                    <div class="t-sec" id="ts1">
                        <div class="t-sec-title"><span class="t-sec-num">2</span> Account Registration &amp; Security</div>
                        <p class="t-p">Each user may register one account. You are responsible for maintaining the confidentiality of your login credentials and for all activities carried out under your account.</p>
                        <div class="t-clause">
                            <div class="t-clause-h">Accurate information</div>
                            <div class="t-clause-t">You agree to provide accurate, current, and complete information during registration and to update it promptly to keep it accurate. Providing false or misleading information may result in immediate account suspension without prior notice.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Password security</div>
                            <div class="t-clause-t">You must choose a strong password of at least 6 characters. You must notify DRSMS immediately upon becoming aware of any unauthorised access to your account by contacting customer support via the in-platform chat or at support@drsms.vn.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Account sharing prohibited</div>
                            <div class="t-clause-t">Sharing account credentials with other individuals is strictly prohibited. Each person accessing DRSMS must maintain their own unique account. Violations may result in permanent account termination and forfeiture of any outstanding service credits, without refund.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Social login (OAuth)</div>
                            <div class="t-clause-t">If you register or sign in via Google or Facebook OAuth, your authentication security is additionally governed by those providers' own terms and policies. DRSMS does not store your social provider password.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Account suspension and recovery</div>
                            <div class="t-clause-t">DRSMS may temporarily suspend accounts suspected of unauthorised activity pending investigation. To recover a suspended account, contact support with appropriate identity verification. Recovery timelines are typically 1–3 business days.</div>
                        </div>
                    </div>

                    <!-- ── SECTION 3 ── -->
                    <div class="t-sec" id="ts2">
                        <div class="t-sec-title"><span class="t-sec-num">3</span> Services &amp; Platform Usage</div>
                        <p class="t-p">DRSMS provides a digital platform for managing device repair requests, service contracts, spare-parts inventory, invoicing, and customer support communications. The platform is available 24/7 subject to scheduled maintenance windows.</p>
                        <div class="t-clause">
                            <div class="t-clause-h">Permitted use</div>
                            <div class="t-clause-t">You may use the platform solely for lawful purposes in accordance with these terms. You must not use DRSMS to harass other users, distribute malware, scrape data without authorisation, or engage in any fraudulent or misleading activity.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Repair requests</div>
                            <div class="t-clause-t">Repair requests follow the status flow: PENDING → APPROVED → IN_PROGRESS → COMPLETED, or may be REJECTED or CANCELLED. Priority levels (LOW / MEDIUM / HIGH / URGENT) affect scheduling and response times.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Service contracts</div>
                            <div class="t-clause-t">The platform supports two contract types: <span class="t-tag t-tag-blue">WARRANTY</span> contracts cover repairs at no additional charge within the validity period. <span class="t-tag t-tag-blue">MAINTENANCE</span> contracts cover scheduled inspections and may carry associated fees as defined in the individual contract.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Service availability</div>
                            <div class="t-clause-t">DRSMS targets 99% platform uptime but does not guarantee uninterrupted availability. Scheduled maintenance windows will be announced at least 24 hours in advance. DRSMS is not liable for losses arising from temporary platform unavailability.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Prohibited conduct</div>
                            <div class="t-clause-t">You must not attempt to reverse-engineer, decompile, or tamper with any part of the DRSMS platform. Automated access requires prior written permission. Any attempt to circumvent security measures will result in immediate account termination.</div>
                        </div>
                    </div>

                    <!-- ── SECTION 4 ── -->
                    <div class="t-sec" id="ts3">
                        <div class="t-sec-title"><span class="t-sec-num">4</span> Privacy &amp; Data Protection</div>
                        <p class="t-p">Your use of DRSMS is also governed by our Privacy Policy, which is incorporated into these terms by reference. By accepting these terms you explicitly consent to the collection, storage, and processing of your data as described in the Privacy Policy.</p>
                        <div class="t-clause">
                            <div class="t-clause-h">Data we collect</div>
                            <div class="t-clause-t">We collect: (a) personal information provided at registration — full name, email, phone number, physical address; (b) platform usage data — repair requests, messages, invoices, payment records; (c) technical data — IP address, browser type — used for security and analytics.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Service address &amp; location data</div>
                            <div class="t-clause-t">Your service address is shared with technicians assigned to your repair requests solely for the purpose of performing on-site service. It is not sold, rented, or shared with unrelated third parties.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Data retention &amp; deletion</div>
                            <div class="t-clause-t">Active account data is retained for the duration of the account. After account closure, data is retained for a minimum of 3 years to comply with financial and legal obligations. You may request deletion by contacting support@drsms.vn. We will respond within 30 calendar days.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Third-party data sharing</div>
                            <div class="t-clause-t">We do not sell your personal data. We may share data with trusted service providers under strict data processing agreements. We may disclose data to authorities if required by Vietnamese law or court order.</div>
                        </div>
                    </div>

                    <!-- ── SECTION 5 ── -->
                    <div class="t-sec" id="ts4">
                        <div class="t-sec-title"><span class="t-sec-num">5</span> Payments &amp; Invoices</div>
                        <p class="t-p">All fees for services rendered are set out in the invoice issued upon service completion or at defined contract billing intervals. Customers are responsible for settling invoices in full by the stated due date.</p>
                        <div class="t-clause">
                            <div class="t-clause-h">Accepted payment methods</div>
                            <div class="t-clause-t">DRSMS currently accepts: <span class="t-tag t-tag-blue">CASH</span> paid directly to the technician or at our offices, and <span class="t-tag t-tag-blue">VNPAY</span> electronic payments. VNPay transactions are subject to VNPay's own terms and any applicable processing fees.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Late payment</div>
                            <div class="t-clause-t">Invoices unpaid after the due date may incur a late fee of up to 2% per month on the outstanding balance. DRSMS reserves the right to suspend new service requests for accounts with overdue balances.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Refund policy</div>
                            <div class="t-clause-t">Refunds for completed repair services are not generally available once work has been carried out and accepted. Disputes regarding invoice accuracy must be raised in writing within 14 calendar days of invoice issuance. Approved refunds are processed within 7 business days.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Taxes</div>
                            <div class="t-clause-t">All prices displayed include applicable Vietnamese VAT (currently 10%) unless explicitly stated otherwise.</div>
                        </div>
                    </div>

                    <!-- ── SECTION 6 ── -->
                    <div class="t-sec" id="ts5">
                        <div class="t-sec-title"><span class="t-sec-num">6</span> Limitation of Liability</div>
                        <p class="t-p">DRSMS provides its platform and services on an "as-is" and "as-available" basis. To the fullest extent permitted by the laws of Vietnam, DRSMS expressly disclaims all warranties, express or implied.</p>
                        <div class="t-clause">
                            <div class="t-clause-h">Liability cap</div>
                            <div class="t-clause-t">In no event shall DRSMS's total aggregate liability exceed the total fees actually paid by you in the three (3) calendar months immediately preceding the event giving rise to the claim, or 1,000,000 VND, whichever is greater.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Exclusion of consequential damages</div>
                            <div class="t-clause-t">DRSMS shall not be liable for any indirect, incidental, special, or consequential damages, including loss of profits, loss of data, business interruption, or cost of substitute services.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Third-party services</div>
                            <div class="t-clause-t">DRSMS integrates with Google OAuth, Facebook OAuth, VNPay, and Google Maps. We are not responsible for the availability, accuracy, security, or performance of these external services.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Force majeure</div>
                            <div class="t-clause-t">DRSMS shall not be liable for delays or failures resulting from causes beyond its reasonable control, including natural disasters, government actions, power failures, or internet outages.</div>
                        </div>
                        <div class="t-notice">
                            <p><i class="fas fa-exclamation-triangle" style="color:var(--m-amber);margin-right:6px"></i> Some jurisdictions do not allow the exclusion of implied warranties or limitation of liability — the above limitations may not apply to you in full depending on your location.</p>
                        </div>
                    </div>

                    <!-- ── SECTION 7 ── -->
                    <div class="t-sec" id="ts6">
                        <div class="t-sec-title"><span class="t-sec-num">7</span> Termination</div>
                        <p class="t-p">Either party may terminate the user relationship at any time, subject to the provisions and obligations outlined below.</p>
                        <div class="t-clause">
                            <div class="t-clause-h">Termination by the user</div>
                            <div class="t-clause-t">You may close your account at any time by submitting a written request to customer support. All outstanding invoices must be settled in full before account closure is finalised. Active service requests in progress will be completed before the account is deactivated.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Termination by DRSMS</div>
                            <div class="t-clause-t">DRSMS may suspend or permanently terminate your account immediately and without prior notice if you: (a) materially violate these terms; (b) engage in fraudulent, abusive, or illegal activity; (c) repeatedly harass other users or platform staff.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Effect of termination</div>
                            <div class="t-clause-t">Upon termination, your right to access and use the platform ceases immediately. Any outstanding invoices remain due and payable. Sections 4, 5, 6, and 8 survive termination and remain in full force.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Appeals</div>
                            <div class="t-clause-t">If you believe your account was terminated in error, you may appeal within 14 days by emailing legal@drsms.vn. DRSMS will review appeals within 10 business days. The appeal decision is final.</div>
                        </div>
                    </div>

                    <!-- ── SECTION 8 ── -->
                    <div class="t-sec" id="ts7">
                        <div class="t-sec-title"><span class="t-sec-num">8</span> Governing Law &amp; Dispute Resolution</div>
                        <p class="t-p">These Terms &amp; Conditions are governed by and construed in accordance with the laws of the Socialist Republic of Vietnam, including the Civil Code 2015, the Law on Consumer Protection, and the Law on Electronic Transactions.</p>
                        <div class="t-clause">
                            <div class="t-clause-h">Amicable resolution</div>
                            <div class="t-clause-t">In the event of any dispute, both parties agree to first attempt to resolve the matter amicably through good-faith negotiation within thirty (30) calendar days of the dispute being raised in writing.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Binding arbitration / litigation</div>
                            <div class="t-clause-t">If a dispute cannot be resolved amicably within 30 days, it shall be submitted to the competent People's Court of Hanoi, Vietnam, which shall have exclusive jurisdiction over all such disputes.</div>
                        </div>
                        <div class="t-clause">
                            <div class="t-clause-h">Severability</div>
                            <div class="t-clause-t">If any provision of these terms is found to be invalid or unenforceable, that provision shall be modified to the minimum extent necessary to make it enforceable, and the remaining provisions shall continue in full force and effect.</div>
                        </div>
                        <div class="t-contact">
                            <p><strong style="color:var(--m-text-2)">Contact us</strong><br>
                                For questions about these Terms: <a href="mailto:legal@drsms.vn">legal@drsms.vn</a><br>
                                For support matters: <a href="mailto:support@drsms.vn">support@drsms.vn</a><br>
                                Last updated: January 2025 · Version 2.1</p>
                        </div>
                    </div>

                </div><!-- /t-body -->

                <div class="t-foot">
                    <div class="t-progress">
                        <div class="t-dots" id="termsDots"></div>
                        <span id="termsPageLabel" style="font-size:.7rem;color:var(--m-text-3)">1 of 8</span>
                    </div>
                    <div class="t-foot-btns">
                        <button class="t-btn-prev" id="tBtnPrev" onclick="navSec(-1)"><i class="fas fa-chevron-left"></i> Prev</button>
                        <button class="t-btn-next" id="tBtnNext" onclick="navSec(1)">Next <i class="fas fa-chevron-right"></i></button>
                        <button class="t-btn-accept" id="tBtnAccept" onclick="acceptTerms()"><i class="fas fa-check"></i> Accept &amp; Close</button>
                        <button class="t-btn-accepted" id="tBtnAccepted"><i class="fas fa-check-circle"></i> Accepted</button>
                    </div>
                </div>

            </div><!-- /t-modal -->
        </div><!-- /t-overlay -->

        <script>
            function togglePass(id, icon) {
                const p = document.getElementById(id);
                if (p.type === 'password') {
                    p.type = 'text';
                    icon.classList.replace('fa-eye', 'fa-eye-slash');
                } else {
                    p.type = 'password';
                    icon.classList.replace('fa-eye-slash', 'fa-eye');
                }
            }

            const TOTAL = 8;
            let curSec = 0, accepted = false;

            const dotsEl = document.getElementById('termsDots');
            for (let i = 0; i < TOTAL; i++) {
                const d = document.createElement('div');
                d.className = 't-dot' + (i === 0 ? ' on' : '');
                d.onclick = () => showSec(i);
                dotsEl.appendChild(d);
            }

            function openTerms() {
                document.getElementById('termsOverlay').classList.add('open');
                document.body.style.overflow = 'hidden';
                showSec(0);
            }
            function closeTerms() {
                document.getElementById('termsOverlay').classList.remove('open');
                document.body.style.overflow = '';
            }
            function overlayClick(e) {
                if (e.target === document.getElementById('termsOverlay'))
                    closeTerms();
            }
            function showSec(i) {
                document.querySelectorAll('.t-sec').forEach(s => s.classList.remove('on'));
                document.querySelectorAll('.t-tab').forEach(b => b.classList.remove('on'));
                document.getElementById('ts' + i).classList.add('on');
                document.querySelectorAll('.t-tab')[i].classList.add('on');
                document.querySelectorAll('.t-tab')[i].scrollIntoView({behavior: 'smooth', block: 'nearest', inline: 'center'});
                curSec = i;
                document.querySelectorAll('.t-dot').forEach((d, idx) => d.classList.toggle('on', idx === i));
                document.getElementById('termsPageLabel').textContent = (i + 1) + ' of ' + TOTAL;
                document.getElementById('tBtnPrev').style.opacity = i === 0 ? '0.35' : '1';
                document.getElementById('tBtnPrev').style.pointerEvents = i === 0 ? 'none' : 'auto';
                const isLast = i === TOTAL - 1;
                document.getElementById('tBtnNext').style.display = isLast ? 'none' : 'inline-flex';
                document.getElementById('tBtnAccept').style.display = (isLast && !accepted) ? 'inline-flex' : 'none';
                document.getElementById('tBtnAccepted').style.display = accepted ? 'inline-flex' : 'none';
                document.getElementById('termsBody').scrollTop = 0;
            }
            function navSec(dir) {
                const next = curSec + dir;
                if (next >= 0 && next < TOTAL)
                    showSec(next);
            }
            function acceptTerms() {
                accepted = true;
                document.getElementById('termsCheck').checked = true;
                document.getElementById('tBtnAccept').style.display = 'none';
                document.getElementById('tBtnAccepted').style.display = 'inline-flex';
                setTimeout(closeTerms, 900);
            }
            document.addEventListener('keydown', e => {
                if (!document.getElementById('termsOverlay').classList.contains('open'))
                    return;
                if (e.key === 'Escape')
                    closeTerms();
                if (e.key === 'ArrowRight')
                    navSec(1);
                if (e.key === 'ArrowLeft')
                    navSec(-1);
            });
        </script>
    </body>
</html>
