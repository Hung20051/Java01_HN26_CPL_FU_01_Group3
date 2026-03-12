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
            }
            *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
            html { scroll-behavior: smooth; }
            body {
                font-family: 'Sora', sans-serif;
                background: var(--navy);
                color: var(--text);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }
            ::-webkit-scrollbar { width: 5px; }
            ::-webkit-scrollbar-track { background: var(--navy); }
            ::-webkit-scrollbar-thumb { background: var(--accent); border-radius: 4px; }

            /* ── NAVBAR ── */
            .navbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 20px 64px;
                border-bottom: 1px solid var(--border);
                background: rgba(11,20,55,0.8);
                backdrop-filter: blur(16px);
                position: sticky;
                top: 0;
                z-index: 10;
            }
            .navbar-brand {
                display: flex; align-items: center; gap: 10px;
                font-size: 1.1rem; font-weight: 700;
                color: white; text-decoration: none;
            }
            .brand-icon {
                width: 36px; height: 36px;
                background: linear-gradient(135deg, var(--accent), var(--accent-2));
                border-radius: 10px;
                display: flex; align-items: center; justify-content: center;
                color: white; font-size: 0.85rem;
                box-shadow: 0 4px 12px var(--accent-glow);
            }
            .navbar-links { display: flex; align-items: center; gap: 20px; }
            .nav-link { font-size: 0.82rem; font-weight: 500; color: var(--muted); text-decoration: none; transition: color 0.25s; }
            .nav-link:hover { color: white; }
            .btn-nav {
                display: inline-flex; align-items: center; gap: 7px;
                padding: 8px 18px;
                background: rgba(79,126,248,0.15);
                border: 1px solid rgba(79,126,248,0.3);
                color: var(--accent-2); text-decoration: none;
                font-size: 0.82rem; font-weight: 600;
                border-radius: 100px; transition: all 0.25s;
            }
            .btn-nav:hover { background: rgba(79,126,248,0.25); color: white; }

            /* ── PAGE WRAP ── */
            .page-wrap {
                flex: 1;
                display: flex;
                align-items: center;
                justify-content: center;
                position: relative;
                overflow: hidden;
                padding: 48px 20px;
            }

            /* Orbs */
            .orb {
                position: absolute; border-radius: 50%;
                filter: blur(100px); pointer-events: none;
            }
            .orb-1 {
                width: 550px; height: 550px;
                background: radial-gradient(circle, rgba(79,126,248,0.18) 0%, transparent 70%);
                top: -120px; right: 5%;
                animation: orbFloat 10s ease-in-out infinite;
            }
            .orb-2 {
                width: 380px; height: 380px;
                background: radial-gradient(circle, rgba(52,211,153,0.1) 0%, transparent 70%);
                bottom: -60px; left: 5%;
                animation: orbFloat 14s ease-in-out infinite reverse;
            }
            .orb-3 {
                width: 300px; height: 300px;
                background: radial-gradient(circle, rgba(167,139,250,0.1) 0%, transparent 70%);
                top: 50%; left: 30%;
                animation: orbFloat 18s ease-in-out infinite;
            }
            @keyframes orbFloat {
                0%,100% { transform: translate(0,0); }
                50%      { transform: translate(20px,-25px); }
            }

            /* ── WRAPPER ── */
            .register-wrapper {
                display: flex;
                align-items: center;
                gap: 56px;
                width: 100%;
                max-width: 960px;
                position: relative;
                z-index: 1;
            }

            /* ── INFO PANEL (left) ── */
            .info-panel {
                flex: 1;
                animation: fadeUp 0.7s 0.2s cubic-bezier(.4,0,.2,1) both;
            }
            @keyframes fadeUp {
                from { opacity: 0; transform: translateY(20px); }
                to   { opacity: 1; transform: translateY(0); }
            }
            .info-eyebrow {
                display: inline-flex; align-items: center; gap: 8px;
                font-size: 0.68rem; font-weight: 700;
                letter-spacing: 2px; text-transform: uppercase;
                color: var(--green); margin-bottom: 16px;
            }
            .info-eyebrow::before {
                content: ''; display: inline-block;
                width: 18px; height: 2px;
                background: var(--green); border-radius: 2px;
            }
            .info-title {
                font-size: clamp(1.6rem, 2.5vw, 2.4rem);
                font-weight: 800; line-height: 1.15;
                letter-spacing: -0.8px; color: white;
                margin-bottom: 14px;
            }
            .info-title .highlight {
                background: linear-gradient(135deg, #6ef0ff 0%, var(--green) 60%, #a78bfa 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }
            .info-sub {
                font-size: 0.88rem; font-weight: 300;
                color: var(--muted); line-height: 1.8; margin-bottom: 32px;
            }
            .step-list { display: flex; flex-direction: column; gap: 14px; }
            .step-item {
                display: flex; align-items: flex-start; gap: 14px;
                padding: 12px 16px;
                background: rgba(255,255,255,0.03);
                border: 1px solid var(--border);
                border-radius: 14px;
                transition: all 0.25s;
            }
            .step-item:hover {
                background: rgba(52,211,153,0.06);
                border-color: rgba(52,211,153,0.2);
            }
            .step-num {
                width: 28px; height: 28px; flex-shrink: 0;
                border-radius: 8px;
                background: rgba(52,211,153,0.12);
                color: var(--green);
                display: flex; align-items: center; justify-content: center;
                font-size: 0.75rem; font-weight: 700;
            }
            .step-text { font-size: 0.83rem; color: var(--text-2); line-height: 1.5; }
            .step-text strong { color: white; display: block; margin-bottom: 2px; font-weight: 600; }

            /* ── REGISTER CARD (right) ── */
            .register-card {
                flex-shrink: 0;
                width: 440px;
                background: rgba(17,26,66,0.75);
                border: 1px solid var(--border);
                border-radius: 28px;
                padding: 40px 38px;
                backdrop-filter: blur(24px);
                box-shadow:
                    0 0 0 1px rgba(52,211,153,0.06),
                    0 32px 80px rgba(0,0,0,0.45),
                    inset 0 1px 0 rgba(255,255,255,0.07);
                animation: cardIn 0.6s cubic-bezier(.4,0,.2,1) both;
            }
            @keyframes cardIn {
                from { opacity: 0; transform: translateY(28px) scale(0.97); }
                to   { opacity: 1; transform: translateY(0) scale(1); }
            }

            .card-badge {
                display: inline-flex; align-items: center; gap: 6px;
                background: rgba(52,211,153,0.1);
                border: 1px solid rgba(52,211,153,0.25);
                color: var(--green);
                font-size: 0.68rem; font-weight: 700;
                letter-spacing: 1.5px; text-transform: uppercase;
                padding: 5px 12px; border-radius: 100px;
                margin-bottom: 18px;
            }
            .card-title {
                font-size: 1.65rem; font-weight: 800;
                color: white; letter-spacing: -0.5px;
                margin-bottom: 4px; line-height: 1.15;
            }
            .card-sub {
                font-size: 0.82rem; color: var(--muted);
                font-weight: 300; margin-bottom: 24px;
            }

            /* Alert */
            .alert {
                display: flex; align-items: center; gap: 9px;
                padding: 11px 14px; border-radius: 10px;
                font-size: 0.82rem; font-weight: 500; margin-bottom: 16px;
            }
            .alert-error  { background: rgba(248,113,113,0.12); border: 1px solid rgba(248,113,113,0.25); color: var(--danger); }
            .alert-success { background: rgba(52,211,153,0.1); border: 1px solid rgba(52,211,153,0.25); color: var(--success); }

            /* Two-column form row */
            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 14px;
            }

            /* Form */
            .form-group { margin-bottom: 15px; }
            .form-label {
                display: block; font-size: 0.72rem; font-weight: 600;
                color: var(--text-2); margin-bottom: 7px;
                letter-spacing: 0.5px; text-transform: uppercase;
            }
            .required { color: var(--danger); margin-left: 2px; }
            .input-wrap { position: relative; }
            .input-icon {
                position: absolute; left: 13px; top: 50%;
                transform: translateY(-50%); color: var(--muted);
                font-size: 0.8rem; pointer-events: none; transition: color 0.25s;
            }
            .form-input {
                width: 100%;
                padding: 11px 13px 11px 38px;
                background: rgba(255,255,255,0.05);
                border: 1px solid var(--border);
                border-radius: 11px;
                color: white;
                font-family: 'Sora', sans-serif;
                font-size: 0.85rem;
                outline: none;
                transition: all 0.25s;
            }
            .form-input::placeholder { color: var(--muted); }
            .form-input:focus {
                border-color: var(--border-focus);
                background: rgba(79,126,248,0.07);
                box-shadow: 0 0 0 3px rgba(79,126,248,0.12);
            }
            .input-wrap:focus-within .input-icon { color: var(--accent-2); }
            .toggle-pass {
                position: absolute; right: 13px; top: 50%;
                transform: translateY(-50%);
                color: var(--muted); cursor: pointer; font-size: 0.8rem;
                transition: color 0.25s;
            }
            .toggle-pass:hover { color: var(--accent-2); }

            /* Checkbox */
            .checkbox-group { margin-top: 4px; margin-bottom: 6px; }
            .checkbox-label {
                display: flex; align-items: flex-start; gap: 10px;
                font-size: 0.78rem; color: var(--muted);
                cursor: pointer; line-height: 1.5;
            }
            .checkbox-label input[type=checkbox] {
                width: 15px; height: 15px; flex-shrink: 0;
                margin-top: 2px; accent-color: var(--green);
            }
            .checkbox-label a { color: var(--green); text-decoration: none; font-weight: 600; }
            .checkbox-label a:hover { color: white; }

            /* Buttons */
            .btn-primary {
                width: 100%; padding: 13px;
                background: linear-gradient(135deg, #22c97a, var(--green));
                border: none; border-radius: 12px;
                color: white; font-family: 'Sora', sans-serif;
                font-size: 0.88rem; font-weight: 700; cursor: pointer;
                transition: all 0.3s cubic-bezier(.4,0,.2,1);
                box-shadow: 0 6px 24px var(--green-glow);
                display: flex; align-items: center; justify-content: center; gap: 8px;
                margin-top: 18px;
            }
            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 14px 36px rgba(52,211,153,0.4);
            }
            .btn-primary:active { transform: translateY(0); }

            .login-cta {
                text-align: center;
                margin-top: 18px;
                font-size: 0.8rem;
                color: var(--muted);
            }
            .login-cta a {
                color: var(--accent-2);
                text-decoration: none;
                font-weight: 600;
                transition: color 0.2s;
            }
            .login-cta a:hover { color: white; }

            /* Responsive */
            @media (max-width: 860px) {
                .register-wrapper { flex-direction: column; gap: 32px; max-width: 440px; }
                .info-panel { order: -1; }
                .register-card { width: 100%; }
                .form-row { grid-template-columns: 1fr; gap: 0; }
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

                <!-- ═══ INFO PANEL (bên trái) ═══ -->
                <div class="info-panel">
                    <div class="info-eyebrow">Get started</div>
                    <h1 class="info-title">
                        Join DRSMS<br>
                        <span class="highlight">in Minutes</span>
                    </h1>
                    <p class="info-sub">Create your free account and start managing your repair service operation from one powerful, unified platform.</p>
                    <div class="step-list">
                        <div class="step-item">
                            <div class="step-num">1</div>
                            <div class="step-text">
                                <strong>Fill in your details</strong>
                                Name, email, phone and username to identify your account.
                            </div>
                        </div>
                        <div class="step-item">
                            <div class="step-num">2</div>
                            <div class="step-text">
                                <strong>Set a secure password</strong>
                                Minimum 6 characters to keep your account safe.
                            </div>
                        </div>
                        <div class="step-item">
                            <div class="step-num">3</div>
                            <div class="step-text">
                                <strong>Start managing repairs</strong>
                                Access your full dashboard immediately after registration.
                            </div>
                        </div>
                        <div class="step-item">
                            <div class="step-num">✓</div>
                            <div class="step-text">
                                <strong>Free &amp; instant access</strong>
                                No credit card required. Up and running in seconds.
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ═══ REGISTER CARD (bên phải) ═══ -->
                <div class="register-card">
                    <div class="card-badge"><i class="fas fa-user-plus"></i> New Account</div>
                    <div class="card-title">Create Account</div>
                    <div class="card-sub">Fill in the form below to get started.</div>

                    <% String error = (String) request.getAttribute("error"); %>
                    <% if (error != null) { %>
                    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
                    <% } %>

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
                                    <i class="fas fa-eye toggle-pass" onclick="toggleRegPass('regPass', this)"></i>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Confirm <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <i class="fas fa-lock input-icon"></i>
                                    <input class="form-input" type="password" name="confirmPassword" id="regPass2" placeholder="Repeat password" required minlength="6">
                                    <i class="fas fa-eye toggle-pass" onclick="toggleRegPass('regPass2', this)"></i>
                                </div>
                            </div>
                        </div>

                        <div class="form-group checkbox-group">
                            <label class="checkbox-label">
                                <input type="checkbox" required>
                                I have read and agree to the <a href="#">Terms &amp; Conditions</a>.
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

        <script>
            function toggleRegPass(id, icon) {
                const p = document.getElementById(id);
                if (p.type === 'password') {
                    p.type = 'text';
                    icon.classList.replace('fa-eye', 'fa-eye-slash');
                } else {
                    p.type = 'password';
                    icon.classList.replace('fa-eye-slash', 'fa-eye');
                }
            }
        </script>
    </body>
</html>
