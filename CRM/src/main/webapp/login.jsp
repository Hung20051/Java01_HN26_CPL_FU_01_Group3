<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Login - DRSMS System</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --navy:      #0b1437;
                --navy-2:    #0f1c4d;
                --navy-card: #111a42;
                --accent:    #4f7ef8;
                --accent-2:  #7c9ffa;
                --accent-glow: rgba(79,126,248,0.25);
                --text:      #ffffff;
                --text-2:    #c8d4f0;
                --muted:     #7a8ab8;
                --border:    rgba(255,255,255,0.08);
                --border-focus: rgba(79,126,248,0.5);
                --danger:    #f87171;
                --success:   #34d399;
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
                position: relative;
                z-index: 10;
            }
            .navbar-brand {
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 1.1rem;
                font-weight: 700;
                color: white;
                text-decoration: none;
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

            /* ── BACKGROUND SCENE ── */
            .page-wrap {
                flex: 1;
                display: flex;
                align-items: center;
                justify-content: center;
                position: relative;
                overflow: hidden;
                padding: 40px 20px;
            }

            /* Orbs */
            .orb {
                position: absolute;
                border-radius: 50%;
                filter: blur(100px);
                pointer-events: none;
            }
            .orb-1 {
                width: 600px; height: 600px;
                background: radial-gradient(circle, rgba(79,126,248,0.2) 0%, transparent 70%);
                top: -150px; left: -100px;
                animation: orbFloat 10s ease-in-out infinite;
            }
            .orb-2 {
                width: 400px; height: 400px;
                background: radial-gradient(circle, rgba(167,139,250,0.15) 0%, transparent 70%);
                bottom: -80px; right: 5%;
                animation: orbFloat 13s ease-in-out infinite reverse;
            }
            .orb-3 {
                width: 300px; height: 300px;
                background: radial-gradient(circle, rgba(52,211,153,0.08) 0%, transparent 70%);
                top: 40%; right: 20%;
                animation: orbFloat 16s ease-in-out infinite;
            }
            @keyframes orbFloat {
                0%,100% { transform: translate(0,0); }
                50%      { transform: translate(20px,-25px); }
            }

            /* ── TWO-COLUMN LAYOUT ── */
            .login-wrapper {
                display: flex;
                align-items: center;
                gap: 56px;
                width: 100%;
                max-width: 920px;
                position: relative;
                z-index: 1;
            }

            /* ── LOGIN CARD (LEFT, PROMINENT) ── */
            .login-card {
                flex-shrink: 0;
                width: 420px;
                background: rgba(17,26,66,0.75);
                border: 1px solid var(--border);
                border-radius: 28px;
                padding: 44px 40px;
                backdrop-filter: blur(24px);
                box-shadow:
                    0 0 0 1px rgba(79,126,248,0.08),
                    0 32px 80px rgba(0,0,0,0.45),
                    inset 0 1px 0 rgba(255,255,255,0.07);
                animation: cardIn 0.6s cubic-bezier(.4,0,.2,1) both;
            }
            @keyframes cardIn {
                from { opacity: 0; transform: translateY(28px) scale(0.97); }
                to   { opacity: 1; transform: translateY(0) scale(1); }
            }

            /* Card top badge */
            .card-badge {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                background: rgba(79,126,248,0.12);
                border: 1px solid rgba(79,126,248,0.25);
                color: var(--accent-2);
                font-size: 0.7rem;
                font-weight: 700;
                letter-spacing: 1.5px;
                text-transform: uppercase;
                padding: 5px 12px;
                border-radius: 100px;
                margin-bottom: 20px;
            }
            .card-title {
                font-size: 1.75rem;
                font-weight: 800;
                color: white;
                letter-spacing: -0.5px;
                margin-bottom: 6px;
                line-height: 1.15;
            }
            .card-sub {
                font-size: 0.83rem;
                color: var(--muted);
                font-weight: 300;
                margin-bottom: 28px;
            }

            /* Alert */
            .alert {
                display: flex; align-items: center; gap: 9px;
                padding: 11px 14px; border-radius: 10px;
                font-size: 0.82rem; font-weight: 500; margin-bottom: 18px;
            }
            .alert-error  { background: rgba(248,113,113,0.12); border: 1px solid rgba(248,113,113,0.25); color: var(--danger); }
            .alert-success { background: rgba(52,211,153,0.1); border: 1px solid rgba(52,211,153,0.25); color: var(--success); }

            /* Form */
            .form-group { margin-bottom: 18px; }
            .form-label {
                display: block; font-size: 0.74rem; font-weight: 600;
                color: var(--text-2); margin-bottom: 8px;
                letter-spacing: 0.5px; text-transform: uppercase;
            }
            .input-wrap { position: relative; }
            .input-icon {
                position: absolute; left: 14px; top: 50%;
                transform: translateY(-50%); color: var(--muted);
                font-size: 0.82rem; pointer-events: none; transition: color 0.25s;
            }
            .form-input {
                width: 100%;
                padding: 13px 14px 13px 42px;
                background: rgba(255,255,255,0.05);
                border: 1px solid var(--border);
                border-radius: 12px;
                color: white;
                font-family: 'Sora', sans-serif;
                font-size: 0.87rem;
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
                position: absolute; right: 14px; top: 50%;
                transform: translateY(-50%);
                color: var(--muted); cursor: pointer; font-size: 0.82rem; transition: color 0.25s;
            }
            .toggle-pass:hover { color: var(--accent-2); }

            .form-footer {
                display: flex; justify-content: space-between; align-items: center; margin-top: 8px;
            }
            .checkbox-label {
                display: flex; align-items: center; gap: 8px;
                font-size: 0.8rem; color: var(--muted); cursor: pointer;
            }
            .checkbox-label input[type=checkbox] { width: 15px; height: 15px; accent-color: var(--accent); }
            .forgot-link { font-size: 0.78rem; color: var(--accent-2); text-decoration: none; transition: color 0.2s; }
            .forgot-link:hover { color: white; }

            /* Buttons */
            .btn-primary {
                width: 100%; padding: 14px;
                background: linear-gradient(135deg, var(--accent), var(--accent-2));
                border: none; border-radius: 12px;
                color: white; font-family: 'Sora', sans-serif;
                font-size: 0.9rem; font-weight: 700; cursor: pointer;
                transition: all 0.3s cubic-bezier(.4,0,.2,1);
                box-shadow: 0 6px 24px var(--accent-glow);
                display: flex; align-items: center; justify-content: center; gap: 8px;
                margin-top: 24px;
            }
            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 14px 36px rgba(79,126,248,0.5);
            }
            .btn-primary:active { transform: translateY(0); }

            .btn-secondary {
                width: 100%; padding: 12px;
                background: rgba(255,255,255,0.04);
                border: 1px solid var(--border);
                border-radius: 12px; color: var(--text-2);
                font-family: 'Sora', sans-serif;
                font-size: 0.85rem; font-weight: 500; cursor: pointer;
                transition: all 0.25s;
                display: flex; align-items: center; justify-content: center; gap: 8px;
                margin-top: 10px;
            }
            .btn-secondary:hover {
                background: rgba(255,255,255,0.09);
                border-color: rgba(255,255,255,0.18);
                color: white;
            }

            .divider {
                display: flex; align-items: center; gap: 12px;
                margin: 20px 0; color: var(--muted); font-size: 0.75rem;
            }
            .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }

            .social-row { display: flex; gap: 10px; }
            .btn-social {
                flex: 1; padding: 11px 10px;
                border-radius: 12px; border: 1px solid var(--border);
                font-family: 'Sora', sans-serif;
                font-size: 0.82rem; font-weight: 500; cursor: pointer;
                transition: all 0.25s;
                display: flex; align-items: center; justify-content: center; gap: 7px;
                text-decoration: none; color: var(--text-2);
                background: rgba(255,255,255,0.04);
            }
            .btn-social:hover {
                background: rgba(255,255,255,0.09);
                color: white; transform: translateY(-1px);
            }
            .btn-social.google:hover  { border-color: rgba(234,67,53,0.4); }
            .btn-social.facebook:hover { border-color: rgba(24,119,242,0.4); }
            .btn-social i.fa-google   { color: #ea4335; }
            .btn-social i.fa-facebook-f { color: #1877f2; }

            /* ── RIGHT INFO PANEL ── */
            .info-panel {
                flex: 1;
                animation: fadeUp 0.8s 0.2s cubic-bezier(.4,0,.2,1) both;
            }
            @keyframes fadeUp {
                from { opacity: 0; transform: translateY(20px); }
                to   { opacity: 1; transform: translateY(0); }
            }
            .info-eyebrow {
                display: inline-flex; align-items: center; gap: 8px;
                font-size: 0.68rem; font-weight: 700;
                letter-spacing: 2px; text-transform: uppercase;
                color: var(--accent-2); margin-bottom: 16px;
            }
            .info-eyebrow::before {
                content: ''; display: inline-block;
                width: 18px; height: 2px;
                background: var(--accent); border-radius: 2px;
            }
            .info-title {
                font-size: clamp(1.6rem, 2.5vw, 2.4rem);
                font-weight: 800; line-height: 1.15;
                letter-spacing: -0.8px; color: white;
                margin-bottom: 14px;
            }
            .info-title .highlight {
                background: linear-gradient(135deg, #6ef0ff 0%, var(--accent-2) 50%, #a78bfa 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }
            .info-sub {
                font-size: 0.88rem; font-weight: 300;
                color: var(--muted); line-height: 1.8; margin-bottom: 32px;
            }
            .feature-list { display: flex; flex-direction: column; gap: 12px; }
            .feature-item {
                display: flex; align-items: center; gap: 12px;
                font-size: 0.84rem; color: var(--text-2); font-weight: 400;
                padding: 10px 14px;
                background: rgba(255,255,255,0.03);
                border: 1px solid var(--border);
                border-radius: 12px;
                transition: all 0.25s;
            }
            .feature-item:hover {
                background: rgba(79,126,248,0.06);
                border-color: rgba(79,126,248,0.2);
            }
            .feature-dot {
                width: 30px; height: 30px;
                border-radius: 8px; flex-shrink: 0;
                display: flex; align-items: center; justify-content: center;
                font-size: 0.78rem;
            }

            /* Responsive */
            @media (max-width: 780px) {
                .login-wrapper { flex-direction: column; gap: 32px; max-width: 420px; }
                .info-panel { order: -1; }
                .info-title { font-size: 1.5rem; }
                .login-card { width: 100%; }
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

            <div class="login-wrapper">

                <!-- ═══ LOGIN CARD (bên trái, nổi bật) ═══ -->
                <div class="login-card">
                    <div class="card-badge"><i class="fas fa-shield-alt"></i> Secure Login</div>
                    <div class="card-title">Sign In</div>
                    <div class="card-sub">Welcome back! Please enter your credentials.</div>

                    <%
                        String error   = (String) request.getAttribute("error");
                        String success = (String) request.getAttribute("success");
                        String resetOk = request.getParameter("resetSuccess");
                    %>
                    <% if (error != null) { %>
                    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
                    <% } %>
                    <% if (success != null) { %>
                    <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= success %></div>
                    <% } %>
                    <% if ("1".equals(resetOk)) { %>
                    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Password reset successful! Please log in.</div>
                    <% } %>

                    <form action="login" method="post">
                        <div class="form-group">
                            <label class="form-label">Username</label>
                            <div class="input-wrap">
                                <i class="fas fa-user input-icon"></i>
                                <input class="form-input" type="text" name="username" placeholder="Enter your username" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Password</label>
                            <div class="input-wrap">
                                <i class="fas fa-lock input-icon"></i>
                                <input class="form-input" type="password" name="password" id="password" placeholder="Enter your password" required>
                                <i class="fas fa-eye toggle-pass" onclick="togglePass()" id="eyeIcon"></i>
                            </div>
                        </div>
                        <div class="form-footer">
                            <label class="checkbox-label">
                                <input type="checkbox" name="rememberMe"> Remember me
                            </label>
                            <a href="forgot-password" class="forgot-link">Forgot password?</a>
                        </div>
                        <button type="submit" class="btn-primary">
                            <i class="fas fa-arrow-right"></i> Sign In
                        </button>
                    </form>

                    <button onclick="location.href='register.jsp'" class="btn-secondary">
                        <i class="fas fa-user-plus"></i> Create new account
                    </button>

                    <div class="divider">or continue with</div>

                    <div class="social-row">
                        <a href="auth/google" class="btn-social google">
                            <i class="fab fa-google"></i> Google
                        </a>
                        <a href="auth/facebook" class="btn-social facebook">
                            <i class="fab fa-facebook-f"></i> Facebook
                        </a>
                    </div>
                </div>

                <!-- ═══ INFO PANEL (bên phải, nhẹ hơn) ═══ -->
                <div class="info-panel">
                    <div class="info-eyebrow">Welcome back</div>
                    <h1 class="info-title">
                        Your Repairs,<br>
                        <span class="highlight">All in One Place</span>
                    </h1>
                    <p class="info-sub">Sign in to access your dashboard and manage your entire repair service operation from one powerful platform.</p>
                    <div class="feature-list">
                        <div class="feature-item">
                            <div class="feature-dot" style="background:rgba(79,126,248,0.15);color:#7c9ffa"><i class="fas fa-users"></i></div>
                            Full customer &amp; contract management
                        </div>
                        <div class="feature-item">
                            <div class="feature-dot" style="background:rgba(52,211,153,0.12);color:#34d399"><i class="fas fa-laptop"></i></div>
                            Real-time equipment tracking
                        </div>
                        <div class="feature-item">
                            <div class="feature-dot" style="background:rgba(251,191,36,0.12);color:#fbbf24"><i class="fas fa-chart-bar"></i></div>
                            Detailed reports &amp; analytics
                        </div>
                        <div class="feature-item">
                            <div class="feature-dot" style="background:rgba(167,139,250,0.12);color:#a78bfa"><i class="fas fa-headset"></i></div>
                            24/7 dedicated support
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <script>
            function togglePass() {
                const p = document.getElementById('password');
                const icon = document.getElementById('eyeIcon');
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
