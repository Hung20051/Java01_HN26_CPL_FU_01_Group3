<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>OTP Verification - DRSMS System</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --navy:        #0b1437;
                --accent:      #4f7ef8;
                --accent-2:    #7c9ffa;
                --accent-glow: rgba(79,126,248,0.25);
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
            .nav-link {
                font-size: 0.82rem;
                font-weight: 500;
                color: var(--muted);
                text-decoration: none;
                transition: color 0.25s;
            }
            .nav-link:hover {
                color: white;
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

            /* Orbs */
            .orb {
                position: absolute;
                border-radius: 50%;
                filter: blur(110px);
                pointer-events: none;
            }
            .orb-1 {
                width: 500px;
                height: 500px;
                background: radial-gradient(circle, rgba(79,126,248,0.2) 0%, transparent 70%);
                top: -120px;
                left: -80px;
                animation: orbFloat 11s ease-in-out infinite;
            }
            .orb-2 {
                width: 400px;
                height: 400px;
                background: radial-gradient(circle, rgba(167,139,250,0.14) 0%, transparent 70%);
                bottom: -80px;
                right: 5%;
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
            .otp-card {
                width: 100%;
                max-width: 420px;
                background: rgba(17,26,66,0.75);
                border: 1px solid var(--border);
                border-radius: 28px;
                padding: 44px 40px;
                backdrop-filter: blur(24px);
                box-shadow:
                    0 0 0 1px rgba(79,126,248,0.08),
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

            /* Icon circle */
            .icon-circle {
                width: 68px;
                height: 68px;
                border-radius: 20px;
                background: rgba(79,126,248,0.12);
                border: 1px solid rgba(79,126,248,0.25);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.6rem;
                color: var(--accent-2);
                margin: 0 auto 22px;
                box-shadow: 0 8px 24px rgba(79,126,248,0.15);
                animation: iconPulse 3s ease-in-out infinite;
            }
            @keyframes iconPulse {
                0%,100% {
                    box-shadow: 0 8px 24px rgba(79,126,248,0.15);
                }
                50%      {
                    box-shadow: 0 8px 36px rgba(79,126,248,0.35);
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
            .card-sub span {
                color: var(--accent-2);
                font-weight: 500;
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

            /* OTP input group */
            .form-label {
                display: block;
                font-size: 0.72rem;
                font-weight: 600;
                color: var(--text-2);
                margin-bottom: 10px;
                letter-spacing: 0.5px;
                text-transform: uppercase;
                text-align: center;
            }
            .required {
                color: var(--danger);
                margin-left: 2px;
            }

            /* 6-box OTP inputs */
            .otp-boxes {
                display: flex;
                gap: 10px;
                justify-content: center;
                margin-bottom: 6px;
            }
            .otp-box {
                width: 52px;
                height: 58px;
                background: rgba(255,255,255,0.05);
                border: 1px solid var(--border);
                border-radius: 14px;
                color: white;
                font-family: 'Sora', sans-serif;
                font-size: 1.4rem;
                font-weight: 700;
                text-align: center;
                outline: none;
                transition: all 0.25s;
                caret-color: var(--accent-2);
            }
            .otp-box::placeholder {
                color: rgba(255,255,255,0.15);
            }
            .otp-box:focus {
                border-color: var(--border-focus);
                background: rgba(79,126,248,0.1);
                box-shadow: 0 0 0 3px rgba(79,126,248,0.15);
                transform: translateY(-2px);
            }
            .otp-box.filled {
                border-color: rgba(79,126,248,0.4);
                background: rgba(79,126,248,0.08);
            }

            /* Hidden real input for form submit */
            #otpHidden {
                display: none;
            }

            /* Progress dots */
            .otp-progress {
                display: flex;
                justify-content: center;
                gap: 6px;
                margin: 14px 0 22px;
            }
            .prog-dot {
                width: 6px;
                height: 6px;
                border-radius: 50%;
                background: var(--border);
                transition: all 0.3s;
            }
            .prog-dot.active {
                background: var(--accent-2);
                transform: scale(1.3);
            }

            /* Submit button */
            .btn-primary {
                width: 100%;
                padding: 14px;
                background: linear-gradient(135deg, var(--accent), var(--accent-2));
                border: none;
                border-radius: 12px;
                color: white;
                font-family: 'Sora', sans-serif;
                font-size: 0.9rem;
                font-weight: 700;
                cursor: pointer;
                transition: all 0.3s cubic-bezier(.4,0,.2,1);
                box-shadow: 0 6px 24px var(--accent-glow);
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
            }
            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 14px 36px rgba(79,126,248,0.5);
            }
            .btn-primary:active {
                transform: translateY(0);
            }
            .btn-primary:disabled {
                opacity: 0.5;
                cursor: not-allowed;
                transform: none;
                box-shadow: none;
            }

            /* Divider */
            .divider {
                display: flex;
                align-items: center;
                gap: 12px;
                margin: 20px 0;
                color: var(--muted);
                font-size: 0.75rem;
            }
            .divider::before, .divider::after {
                content: '';
                flex: 1;
                height: 1px;
                background: var(--border);
            }

            /* Resend row */
            .resend-row {
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 12px;
            }
            .resend-text {
                font-size: 0.8rem;
                color: var(--muted);
            }

            .btn-resend {
                display: inline-flex;
                align-items: center;
                gap: 7px;
                padding: 10px 22px;
                background: rgba(255,255,255,0.05);
                border: 1px solid var(--border);
                border-radius: 10px;
                color: var(--text-2);
                font-family: 'Sora', sans-serif;
                font-size: 0.82rem;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.25s;
            }
            .btn-resend:not(:disabled):hover {
                background: rgba(79,126,248,0.12);
                border-color: rgba(79,126,248,0.3);
                color: var(--accent-2);
            }
            .btn-resend:disabled {
                opacity: 0.45;
                cursor: not-allowed;
            }

            /* Countdown ring */
            .countdown-wrap {
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 0.78rem;
                color: var(--muted);
            }
            .countdown-badge {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-width: 40px;
                padding: 3px 10px;
                background: rgba(79,126,248,0.1);
                border: 1px solid rgba(79,126,248,0.2);
                border-radius: 100px;
                color: var(--accent-2);
                font-weight: 700;
                font-size: 0.8rem;
            }

            .back-link {
                display: block;
                text-align: center;
                margin-top: 18px;
                font-size: 0.78rem;
                color: var(--muted);
                text-decoration: none;
                transition: color 0.2s;
            }
            .back-link:hover {
                color: var(--accent-2);
            }
            .back-link i {
                margin-right: 4px;
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

            <div class="otp-card">

                <div class="icon-circle">
                    <i class="fas fa-envelope-open-text"></i>
                </div>

                <div class="card-title">OTP Verification</div>
                <div class="card-sub">
                    An OTP code has been sent to your email.<br>
                    <span>Enter the 6-digit code below</span> to complete registration.
                </div>

                <% String error = (String) request.getAttribute("error"); %>
                <% if (error != null) {%>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= error%></div>
                <% }%>

                <form action="otp" method="post" id="otpForm">
                    <input type="hidden" name="action" value="verify">
                    <input type="hidden" name="otp" id="otpHidden">

                    <label class="form-label">Enter OTP Code <span class="required">*</span></label>

                    <div class="otp-boxes" id="otpBoxes">
                        <input class="otp-box" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" placeholder="·">
                        <input class="otp-box" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" placeholder="·">
                        <input class="otp-box" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" placeholder="·">
                        <input class="otp-box" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" placeholder="·">
                        <input class="otp-box" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" placeholder="·">
                        <input class="otp-box" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" placeholder="·">
                    </div>

                    <div class="otp-progress" id="otpProgress">
                        <div class="prog-dot" id="dot0"></div>
                        <div class="prog-dot" id="dot1"></div>
                        <div class="prog-dot" id="dot2"></div>
                        <div class="prog-dot" id="dot3"></div>
                        <div class="prog-dot" id="dot4"></div>
                        <div class="prog-dot" id="dot5"></div>
                    </div>

                    <button type="submit" class="btn-primary" id="verifyBtn" disabled>
                        <i class="fas fa-check-circle"></i> Verify OTP
                    </button>
                </form>

                <div class="divider">resend code</div>

                <div class="resend-row">
                    <div class="countdown-wrap" id="countdownWrap">
                        <span>Resend available in</span>
                        <span class="countdown-badge"><span id="countdown">60</span>s</span>
                    </div>
                    <button id="resendBtn" class="btn-resend" onclick="resendOtp()" disabled>
                        <i class="fas fa-rotate-right"></i> Resend OTP
                    </button>
                </div>

                <a href="register.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Register</a>
            </div>
        </div>

        <script>
            // ── OTP box navigation ──
            const boxes = document.querySelectorAll('.otp-box');
            const dots = document.querySelectorAll('.prog-dot');
            const verifyBtn = document.getElementById('verifyBtn');
            const hidden = document.getElementById('otpHidden');

            function updateState() {
                boxes.forEach((b, i) => {
                    b.classList.toggle('filled', b.value.length > 0);
                    dots[i].classList.toggle('active', b.value.length > 0);
                });
                const code = [...boxes].map(b => b.value).join('');
                hidden.value = code;
                verifyBtn.disabled = code.length < 6;
            }

            boxes.forEach((box, i) => {
                box.addEventListener('input', e => {
                    const val = e.target.value.replace(/\D/g, '');
                    e.target.value = val.slice(-1);
                    updateState();
                    if (val && i < 5)
                        boxes[i + 1].focus();
                });
                box.addEventListener('keydown', e => {
                    if (e.key === 'Backspace' && !box.value && i > 0) {
                        boxes[i - 1].focus();
                        boxes[i - 1].value = '';
                        updateState();
                    }
                });
                box.addEventListener('paste', e => {
                    e.preventDefault();
                    const paste = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g, '').slice(0, 6);
                    paste.split('').forEach((ch, j) => {
                        if (boxes[i + j])
                            boxes[i + j].value = ch;
                    });
                    updateState();
                    const next = Math.min(i + paste.length, 5);
                    boxes[next].focus();
                });
            });

            // Submit: assemble hidden input
            document.getElementById('otpForm').addEventListener('submit', () => {
                hidden.value = [...boxes].map(b => b.value).join('');
            });

            // ── Countdown timer ──
            let timeLeft = 60;
            const btn = document.getElementById('resendBtn');
            const cd = document.getElementById('countdown');
            const cdWrap = document.getElementById('countdownWrap');

            const timer = setInterval(() => {
                timeLeft--;
                cd.textContent = timeLeft;
                if (timeLeft <= 0) {
                    clearInterval(timer);
                    btn.disabled = false;
                    cdWrap.style.display = 'none';
                }
            }, 1000);

            function resendOtp() {
                fetch('otp?action=resend', {method: 'POST'})
                        .then(r => r.json())
                        .then(d => {
                            if (d.success) {
                                alert('A new OTP code has been sent!');
                                location.reload();
                            } else {
                                alert(d.message || 'An error occurred!');
                            }
                        });
            }
        </script>
    </body>
</html>
