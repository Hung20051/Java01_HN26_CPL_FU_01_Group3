<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || !Boolean.TRUE.equals(sess.getAttribute("resetOtpVerified"))) {
        response.sendRedirect(request.getContextPath() + "/forgot-password.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reset Password - DRSMS System</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --navy:        #0b1437;
                --accent:      #4f7ef8;
                --accent-2:    #7c9ffa;
                --accent-glow: rgba(79,126,248,0.25);
                --purple:      #a78bfa;
                --purple-glow: rgba(167,139,250,0.2);
                --text:        #ffffff;
                --text-2:      #c8d4f0;
                --muted:       #7a8ab8;
                --border:      rgba(255,255,255,0.08);
                --border-focus:rgba(79,126,248,0.5);
                --danger:      #f87171;
                --success:     #34d399;
            }
            *, *::before, *::after {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            body {
                font-family: 'Sora', sans-serif;
                background: var(--navy);
                color: var(--text);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }
            ::-webkit-scrollbar {
                width: 5px;
            }
            ::-webkit-scrollbar-track {
                background: var(--navy);
            }
            ::-webkit-scrollbar-thumb {
                background: var(--accent);
                border-radius: 4px;
            }

            /* ── NAVBAR ── */
            .navbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 20px 64px;
                border-bottom: 1px solid var(--border);
                background: rgba(11,20,55,0.8);
                backdrop-filter: blur(16px);
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
                width: 36px;
                height: 36px;
                background: linear-gradient(135deg, var(--accent), var(--accent-2));
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 0.85rem;
                box-shadow: 0 4px 12px var(--accent-glow);
            }
            .navbar-links {
                display: flex;
                align-items: center;
                gap: 20px;
            }
            .btn-nav {
                display: inline-flex;
                align-items: center;
                gap: 7px;
                padding: 8px 18px;
                background: rgba(79,126,248,0.15);
                border: 1px solid rgba(79,126,248,0.3);
                color: var(--accent-2);
                text-decoration: none;
                font-size: 0.82rem;
                font-weight: 600;
                border-radius: 100px;
                transition: all 0.25s;
            }
            .btn-nav:hover {
                background: rgba(79,126,248,0.25);
                color: white;
            }

            /* ── PAGE WRAP ── */
            .page-wrap {
                flex: 1;
                display: flex;
                align-items: center;
                justify-content: center;
                position: relative;
                overflow: hidden;
                padding: 40px 20px;
            }
            .orb {
                position: absolute;
                border-radius: 50%;
                filter: blur(110px);
                pointer-events: none;
            }
            .orb-1 {
                width: 500px;
                height: 500px;
                background: radial-gradient(circle, rgba(167,139,250,0.18) 0%, transparent 70%);
                top: -120px;
                right: 8%;
                animation: orbFloat 11s ease-in-out infinite;
            }
            .orb-2 {
                width: 380px;
                height: 380px;
                background: radial-gradient(circle, rgba(79,126,248,0.15) 0%, transparent 70%);
                bottom: -80px;
                left: 5%;
                animation: orbFloat 14s ease-in-out infinite reverse;
            }
            @keyframes orbFloat {
                0%,100% {
                    transform: translate(0,0);
                }
                50%      {
                    transform: translate(22px,-28px);
                }
            }

            /* ── CARD ── */
            .rp-card {
                width: 100%;
                max-width: 420px;
                background: rgba(17,26,66,0.75);
                border: 1px solid var(--border);
                border-radius: 28px;
                padding: 44px 40px;
                backdrop-filter: blur(24px);
                box-shadow:
                    0 0 0 1px rgba(167,139,250,0.08),
                    0 32px 80px rgba(0,0,0,0.45),
                    inset 0 1px 0 rgba(255,255,255,0.07);
                position: relative;
                z-index: 1;
                animation: cardIn 0.6s cubic-bezier(.4,0,.2,1) both;
            }
            @keyframes cardIn {
                from {
                    opacity: 0;
                    transform: translateY(28px) scale(0.97);
                }
                to   {
                    opacity: 1;
                    transform: translateY(0) scale(1);
                }
            }

            /* Step indicator */
            .step-bar {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 0;
                margin-bottom: 28px;
            }
            .step-node {
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 6px;
            }
            .step-circle {
                width: 34px;
                height: 34px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 0.78rem;
                font-weight: 700;
                border: 2px solid var(--border);
                color: var(--muted);
                background: rgba(255,255,255,0.04);
                transition: all 0.4s;
            }
            .step-circle.done {
                border-color: var(--success);
                background: rgba(52,211,153,0.12);
                color: var(--success);
            }
            .step-circle.active {
                border-color: var(--purple);
                background: rgba(167,139,250,0.15);
                color: var(--purple);
                box-shadow: 0 0 0 4px rgba(167,139,250,0.12);
            }
            .step-label {
                font-size: 0.62rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                color: var(--muted);
            }
            .step-label.active {
                color: var(--purple);
            }
            .step-label.done-label {
                color: var(--success);
            }
            .step-line {
                width: 60px;
                height: 2px;
                background: rgba(52,211,153,0.4);
                margin: 0 4px;
                margin-bottom: 22px;
            }
            .step-line.partial {
                background: var(--border);
            }

            /* Icon */
            .icon-circle {
                width: 68px;
                height: 68px;
                border-radius: 20px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.6rem;
                background: rgba(167,139,250,0.1);
                border: 1px solid rgba(167,139,250,0.25);
                color: var(--purple);
                box-shadow: 0 8px 24px var(--purple-glow);
                margin: 0 auto 22px;
                animation: iconPulse 3s ease-in-out infinite;
            }
            @keyframes iconPulse {
                0%,100% {
                    box-shadow: 0 8px 24px var(--purple-glow);
                }
                50%      {
                    box-shadow: 0 8px 36px rgba(167,139,250,0.4);
                }
            }

            .card-title {
                font-size: 1.65rem;
                font-weight: 800;
                color: white;
                letter-spacing: -0.5px;
                text-align: center;
                margin-bottom: 8px;
            }
            .card-sub {
                font-size: 0.83rem;
                color: var(--muted);
                font-weight: 300;
                line-height: 1.7;
                text-align: center;
                margin-bottom: 28px;
            }

            /* Alert */
            .alert {
                display: flex;
                align-items: center;
                gap: 9px;
                padding: 11px 14px;
                border-radius: 10px;
                font-size: 0.82rem;
                font-weight: 500;
                margin-bottom: 18px;
            }
            .alert-error {
                background: rgba(248,113,113,0.12);
                border: 1px solid rgba(248,113,113,0.25);
                color: var(--danger);
            }

            /* Password strength bar */
            .strength-wrap {
                margin-top: 8px;
            }
            .strength-bars {
                display: flex;
                gap: 4px;
                margin-bottom: 4px;
            }
            .strength-bar {
                flex: 1;
                height: 3px;
                border-radius: 4px;
                background: rgba(255,255,255,0.08);
                transition: background 0.3s;
            }
            .strength-bar.weak   {
                background: var(--danger);
            }
            .strength-bar.medium {
                background: #fbbf24;
            }
            .strength-bar.strong {
                background: var(--success);
            }
            .strength-label {
                font-size: 0.7rem;
                color: var(--muted);
                transition: color 0.3s;
            }

            /* Match message */
            .match-msg {
                display: none;
                margin-top: 6px;
                font-size: 0.75rem;
                align-items: center;
                gap: 5px;
            }
            .match-msg.error {
                display: flex;
                color: var(--danger);
            }
            .match-msg.ok    {
                display: flex;
                color: var(--success);
            }

            /* Form */
            .form-group {
                margin-bottom: 18px;
            }
            .form-label {
                display: block;
                font-size: 0.72rem;
                font-weight: 600;
                color: var(--text-2);
                margin-bottom: 8px;
                letter-spacing: 0.5px;
                text-transform: uppercase;
            }
            .required {
                color: var(--danger);
                margin-left: 2px;
            }
            .input-wrap {
                position: relative;
            }
            .input-icon {
                position: absolute;
                left: 13px;
                top: 50%;
                transform: translateY(-50%);
                color: var(--muted);
                font-size: 0.8rem;
                pointer-events: none;
                transition: color 0.25s;
            }
            .form-input {
                width: 100%;
                padding: 13px 42px 13px 40px;
                background: rgba(255,255,255,0.05);
                border: 1px solid var(--border);
                border-radius: 12px;
                color: white;
                font-family: 'Sora', sans-serif;
                font-size: 0.87rem;
                outline: none;
                transition: all 0.25s;
            }
            .form-input::placeholder {
                color: var(--muted);
            }
            .form-input:focus {
                border-color: var(--border-focus);
                background: rgba(79,126,248,0.07);
                box-shadow: 0 0 0 3px rgba(79,126,248,0.12);
            }
            .input-wrap:focus-within .input-icon {
                color: var(--accent-2);
            }
            .toggle-pass {
                position: absolute;
                right: 13px;
                top: 50%;
                transform: translateY(-50%);
                color: var(--muted);
                cursor: pointer;
                font-size: 0.8rem;
                transition: color 0.25s;
            }
            .toggle-pass:hover {
                color: var(--accent-2);
            }

            /* Button */
            .btn-primary {
                width: 100%;
                padding: 14px;
                background: linear-gradient(135deg, #9b72f5, var(--purple));
                border: none;
                border-radius: 12px;
                color: white;
                font-family: 'Sora', sans-serif;
                font-size: 0.9rem;
                font-weight: 700;
                cursor: pointer;
                transition: all 0.3s cubic-bezier(.4,0,.2,1);
                box-shadow: 0 6px 24px var(--purple-glow);
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
                margin-top: 6px;
            }
            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 14px 36px rgba(167,139,250,0.45);
            }
            .btn-primary:active {
                transform: translateY(0);
            }
            .btn-primary:disabled {
                opacity: 0.45;
                cursor: not-allowed;
                transform: none;
                box-shadow: none;
            }

            .back-link {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                margin-top: 20px;
                font-size: 0.78rem;
                color: var(--muted);
                text-decoration: none;
                transition: color 0.2s;
            }
            .back-link:hover {
                color: var(--accent-2);
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
                <a href="login.jsp" class="btn-nav"><i class="fas fa-sign-in-alt"></i> Login</a>
            </div>
        </nav>

        <div class="page-wrap">
            <div class="orb orb-1"></div>
            <div class="orb orb-2"></div>

            <div class="rp-card">

                <!-- Step indicator: bước 1,2 đã xong, bước 3 active -->
                <div class="step-bar">
                    <div class="step-node">
                        <div class="step-circle done"><i class="fas fa-check"></i></div>
                        <span class="step-label done-label">Email</span>
                    </div>
                    <div class="step-line"></div>
                    <div class="step-node">
                        <div class="step-circle done"><i class="fas fa-check"></i></div>
                        <span class="step-label done-label">Verify</span>
                    </div>
                    <div class="step-line partial"></div>
                    <div class="step-node">
                        <div class="step-circle active">3</div>
                        <span class="step-label active">Reset</span>
                    </div>
                </div>

                <% String error = (String) request.getAttribute("error"); %>
                <% if (error != null) {%>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error%></div>
                <% }%>

                <div class="icon-circle">
                    <i class="fas fa-shield-halved"></i>
                </div>
                <div class="card-title">Reset Password</div>
                <div class="card-sub">Almost done! Set a strong new password for your account.</div>

                <form action="reset-password" method="post" id="resetForm">
                    <div class="form-group">
                        <label class="form-label">New Password <span class="required">*</span></label>
                        <div class="input-wrap">
                            <i class="fas fa-lock input-icon"></i>
                            <input class="form-input" type="password" name="newPassword" id="newPassword"
                                   placeholder="Minimum 6 characters" required minlength="6" autofocus>
                            <i class="fas fa-eye toggle-pass" onclick="togglePass('newPassword', this)"></i>
                        </div>
                        <div class="strength-wrap">
                            <div class="strength-bars">
                                <div class="strength-bar" id="sb1"></div>
                                <div class="strength-bar" id="sb2"></div>
                                <div class="strength-bar" id="sb3"></div>
                                <div class="strength-bar" id="sb4"></div>
                            </div>
                            <span class="strength-label" id="strengthLabel">Enter a password</span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Confirm Password <span class="required">*</span></label>
                        <div class="input-wrap">
                            <i class="fas fa-lock input-icon"></i>
                            <input class="form-input" type="password" name="confirmPassword" id="confirmPassword"
                                   placeholder="Re-enter your new password" required minlength="6">
                            <i class="fas fa-eye toggle-pass" onclick="togglePass('confirmPassword', this)"></i>
                        </div>
                        <div class="match-msg" id="matchMsg"></div>
                    </div>

                    <button type="submit" class="btn-primary" id="submitBtn" disabled>
                        <i class="fas fa-check-circle"></i> Save New Password
                    </button>
                </form>

                <a href="login.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Login</a>
            </div>
        </div>

        <script>
            function togglePass(id, icon) {
                const inp = document.getElementById(id);
                inp.type = inp.type === 'password' ? 'text' : 'password';
                icon.classList.toggle('fa-eye');
                icon.classList.toggle('fa-eye-slash');
            }

            // ── Password strength ──
            function getStrength(pw) {
                let score = 0;
                if (pw.length >= 6)
                    score++;
                if (pw.length >= 10)
                    score++;
                if (/[A-Z]/.test(pw) && /[a-z]/.test(pw))
                    score++;
                if (/[0-9]/.test(pw) && /[^A-Za-z0-9]/.test(pw))
                    score++;
                return score;
            }

            const bars = [document.getElementById('sb1'), document.getElementById('sb2'),
                document.getElementById('sb3'), document.getElementById('sb4')];
            const label = document.getElementById('strengthLabel');
            const levels = [
                {cls: '', text: 'Enter a password', color: ''},
                {cls: 'weak', text: 'Weak', color: '#f87171'},
                {cls: 'medium', text: 'Fair', color: '#fbbf24'},
                {cls: 'strong', text: 'Good', color: '#7c9ffa'},
                {cls: 'strong', text: 'Strong', color: '#34d399'},
            ];

            document.getElementById('newPassword').addEventListener('input', function () {
                const score = this.value ? getStrength(this.value) : 0;
                const lv = levels[score];
                bars.forEach((b, i) => {
                    b.className = 'strength-bar';
                    if (i < score)
                        b.classList.add(lv.cls);
                });
                label.textContent = lv.text;
                label.style.color = lv.color || 'var(--muted)';
                validateMatch();
            });

            // ── Match check ──
            function validateMatch() {
                const np = document.getElementById('newPassword').value;
                const cp = document.getElementById('confirmPassword').value;
                const msg = document.getElementById('matchMsg');
                const btn = document.getElementById('submitBtn');

                if (!cp) {
                    msg.className = 'match-msg';
                    btn.disabled = true;
                    return;
                }
                if (cp !== np) {
                    msg.className = 'match-msg error';
                    msg.innerHTML = '<i class="fas fa-times-circle"></i> Passwords do not match';
                    btn.disabled = true;
                } else {
                    msg.className = 'match-msg ok';
                    msg.innerHTML = '<i class="fas fa-check-circle"></i> Passwords match';
                    btn.disabled = np.length < 6;
                }
            }

            document.getElementById('confirmPassword').addEventListener('input', validateMatch);
        </script>
    </body>
</html>
