<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer invoiceId   = (Integer) request.getAttribute("invoiceId");
    String  invoiceCode = (String)  request.getAttribute("invoiceCode");
    String  amount      = (String)  request.getAttribute("amount");
    Boolean fromShop    = (Boolean) session.getAttribute("pendingFromShop");
    boolean isFromShop  = Boolean.TRUE.equals(fromShop);

    String ctx             = request.getContextPath();
    String confirmServlet  = isFromShop ? (ctx + "/customerShop") : (ctx + "/customerPayment");
    String cancelUrl       = isFromShop
        ? (ctx + "/customerShop?action=cart")
        : (ctx + "/customerInvoices?action=detail&id=" + invoiceId);

    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
    String amountFormatted = "0";
    try { amountFormatted = nf.format(new java.math.BigDecimal(amount)); } catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>VNPay Payment Gateway - Simulation</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --navy:        #0b1437;
            --navy-card:   #111a42;
            --navy-light:  #162050;
            --accent:      #4f7ef8;
            --accent-2:    #7c9ffa;
            --accent-glow: rgba(79,126,248,0.22);
            --green:       #34d399;
            --green-dim:   rgba(52,211,153,0.12);
            --amber:       #fbbf24;
            --amber-dim:   rgba(251,191,36,0.15);
            --danger:      #f87171;
            --purple:      #a78bfa;
            --text:        #ffffff;
            --text-2:      #c8d4f0;
            --muted:       #7a8ab8;
            --border:      rgba(255,255,255,0.07);
            /* VNPay brand */
            --vnpay:       #e30019;
            --vnpay-dark:  #b50014;
            --vnpay-glow:  rgba(227,0,25,0.35);
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Sora', sans-serif;
            background: var(--navy);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            /* Subtle radial glow behind card */
            background-image:
                radial-gradient(ellipse 60% 40% at 50% 30%, rgba(79,126,248,0.08) 0%, transparent 70%),
                radial-gradient(ellipse 40% 30% at 80% 80%, rgba(167,139,250,0.06) 0%, transparent 60%);
        }
        ::-webkit-scrollbar { width: 4px; }
        ::-webkit-scrollbar-track { background: var(--navy); }
        ::-webkit-scrollbar-thumb { background: rgba(79,126,248,0.4); border-radius: 4px; }

        /* ════════════════════ GATEWAY CARD ════════════════════ */
        .gateway-card {
            background: rgba(17,26,66,0.85);
            backdrop-filter: blur(20px);
            border: 1px solid var(--border);
            border-radius: 20px;
            box-shadow: 0 32px 80px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.04);
            width: 100%;
            max-width: 460px;
            overflow: hidden;
        }

        /* ── Header ── */
        .gw-header {
            background: linear-gradient(135deg, var(--vnpay), var(--vnpay-dark));
            padding: 24px 28px;
            color: #fff;
            position: relative;
        }
        .gw-header::after {
            content: '';
            position: absolute; bottom: 0; left: 0; right: 0; height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.15), transparent);
        }
        .gw-simulate-badge {
            position: absolute; top: 14px; right: 16px;
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.3);
            color: #fff; font-size: 0.62rem; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
            letter-spacing: 0.8px; text-transform: uppercase;
        }
        .gw-logo {
            display: flex; align-items: center; gap: 12px;
            margin-bottom: 18px;
        }
        .gw-logo-icon {
            width: 48px; height: 48px;
            background: rgba(255,255,255,0.18);
            border: 2px solid rgba(255,255,255,0.35);
            border-radius: 13px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.2rem; font-weight: 900; color: #fff;
            letter-spacing: -0.5px;
        }
        .gw-logo-name { font-size: 1.3rem; font-weight: 800; letter-spacing: 0.3px; }
        .gw-logo-sub  { font-size: 0.7rem; opacity: 0.75; margin-top: 2px; }

        .gw-order-info {
            background: rgba(0,0,0,0.2);
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 12px;
            padding: 13px 16px;
        }
        .gw-order-row {
            display: flex; justify-content: space-between; align-items: center;
            font-size: 0.82rem; margin-bottom: 5px;
        }
        .gw-order-row:last-child {
            margin-bottom: 0;
            font-size: 1rem; font-weight: 700;
            margin-top: 10px; padding-top: 10px;
            border-top: 1px solid rgba(255,255,255,0.15);
        }
        .gw-order-lbl { opacity: 0.72; }

        /* ── Body ── */
        .gw-body { padding: 26px 28px; }

        .gw-section-title {
            font-size: 0.65rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 1.4px; margin-bottom: 14px;
        }

        /* Payment method cards */
        .payment-methods {
            display: grid; grid-template-columns: 1fr 1fr;
            gap: 10px; margin-bottom: 20px;
        }
        .pm-card {
            border: 1.5px solid var(--border);
            border-radius: 13px;
            padding: 14px 10px;
            cursor: pointer; transition: all 0.2s;
            text-align: center; position: relative;
            background: rgba(255,255,255,0.03);
        }
        .pm-card:hover {
            border-color: rgba(227,0,25,0.4);
            background: rgba(227,0,25,0.06);
        }
        .pm-card.selected {
            border-color: var(--vnpay);
            background: rgba(227,0,25,0.1);
            box-shadow: 0 0 0 3px rgba(227,0,25,0.12);
        }
        .pm-card.selected::after {
            content: '✓';
            position: absolute; top: 7px; right: 10px;
            color: var(--vnpay); font-size: 0.78rem; font-weight: 700;
        }
        .pm-icon { font-size: 1.55rem; margin-bottom: 7px; }
        .pm-name { font-size: 0.77rem; font-weight: 700; color: var(--text); }
        .pm-sub  { font-size: 0.67rem; color: var(--muted); margin-top: 2px; }

        /* Card form */
        .card-form {
            background: rgba(255,255,255,0.03);
            border: 1px solid var(--border);
            border-radius: 13px;
            padding: 16px;
            margin-bottom: 18px;
        }
        .form-group { margin-bottom: 12px; }
        .form-group:last-child { margin-bottom: 0; }
        .form-label {
            font-size: 0.68rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 0.6px; margin-bottom: 6px; display: block;
        }
        .form-input {
            width: 100%; padding: 10px 13px;
            background: rgba(255,255,255,0.05);
            border: 1.5px solid var(--border);
            border-radius: 9px;
            font-size: 0.875rem; font-family: 'Sora', sans-serif;
            color: var(--text); outline: none; transition: all 0.2s;
        }
        .form-input:focus {
            border-color: rgba(227,0,25,0.5);
            background: rgba(227,0,25,0.05);
            box-shadow: 0 0 0 3px rgba(227,0,25,0.1);
        }
        .form-input::placeholder { color: var(--muted); }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }

        /* OTP section */
        .otp-section {
            background: var(--amber-dim);
            border: 1px solid rgba(251,191,36,0.25);
            border-radius: 13px;
            padding: 15px 16px;
            margin-bottom: 18px;
            display: none;
        }
        .otp-section.show { display: block; }
        .otp-title { font-size: 0.82rem; font-weight: 700; color: var(--amber); margin-bottom: 4px; }
        .otp-desc  { font-size: 0.74rem; color: var(--text-2); margin-bottom: 11px; line-height: 1.5; }
        .otp-input-row { display: flex; gap: 9px; align-items: center; }
        .otp-input {
            flex: 1; padding: 10px 13px;
            background: rgba(255,255,255,0.06);
            border: 1.5px solid rgba(251,191,36,0.3);
            border-radius: 9px;
            font-size: 1.05rem; font-weight: 700;
            letter-spacing: 6px; text-align: center;
            font-family: 'Courier New', monospace;
            color: var(--amber); outline: none; transition: all 0.2s;
        }
        .otp-input:focus {
            border-color: var(--amber);
            box-shadow: 0 0 0 3px rgba(251,191,36,0.12);
        }
        .btn-get-otp {
            padding: 10px 14px;
            background: linear-gradient(135deg, var(--amber), #d97706);
            color: #fff; border: none; border-radius: 9px;
            font-size: 0.75rem; font-weight: 700;
            cursor: pointer; white-space: nowrap;
            font-family: 'Sora', sans-serif;
            transition: all 0.2s;
        }
        .btn-get-otp:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(251,191,36,0.35); }
        .btn-get-otp:disabled {
            background: rgba(251,191,36,0.15);
            color: var(--amber); cursor: not-allowed; transform: none; box-shadow: none;
        }

        /* Pay button */
        .btn-pay {
            width: 100%; padding: 14px;
            background: linear-gradient(135deg, var(--vnpay), var(--vnpay-dark));
            color: #fff; border: none; border-radius: 12px;
            font-size: 1rem; font-weight: 700;
            font-family: 'Sora', sans-serif;
            cursor: pointer; transition: all 0.25s;
            display: flex; align-items: center; justify-content: center; gap: 9px;
            margin-bottom: 10px;
            box-shadow: 0 4px 20px var(--vnpay-glow);
        }
        .btn-pay:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 28px rgba(227,0,25,0.45);
        }
        .btn-pay:disabled {
            background: rgba(255,255,255,0.1);
            box-shadow: none; transform: none; cursor: not-allowed;
            color: var(--muted);
        }

        /* Cancel button */
        .btn-cancel {
            width: 100%; padding: 11px;
            background: rgba(255,255,255,0.04);
            color: var(--muted); border: 1.5px solid var(--border);
            border-radius: 12px; font-size: 0.875rem; font-weight: 600;
            font-family: 'Sora', sans-serif;
            cursor: pointer; transition: all 0.2s;
        }
        .btn-cancel:hover {
            background: rgba(248,113,113,0.08);
            border-color: rgba(248,113,113,0.25);
            color: var(--danger);
        }

        /* Security info */
        .security-info {
            display: flex; align-items: center; justify-content: center; gap: 6px;
            font-size: 0.68rem; color: var(--muted); margin-top: 14px;
        }

        /* ── Processing overlay ── */
        .processing-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.75);
            backdrop-filter: blur(8px);
            align-items: center; justify-content: center;
            z-index: 999;
        }
        .processing-overlay.show { display: flex; }
        .processing-box {
            background: rgba(17,26,66,0.95);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 38px 44px;
            text-align: center; max-width: 300px;
            box-shadow: 0 24px 60px rgba(0,0,0,0.6);
        }
        .proc-spinner {
            width: 52px; height: 52px;
            border: 3px solid rgba(255,255,255,0.08);
            border-top: 3px solid var(--vnpay);
            border-radius: 50%;
            animation: spin 0.9s linear infinite;
            margin: 0 auto 18px;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .proc-title { font-size: 1rem; font-weight: 700; color: var(--text); margin-bottom: 7px; }
        .proc-sub   { font-size: 0.8rem; color: var(--muted); }
    </style>
</head>
<body>

    <div class="gateway-card">
        <%-- Header --%>
        <div class="gw-header">
            <span class="gw-simulate-badge">🔬 Sandbox</span>
            <div class="gw-logo">
                <div class="gw-logo-icon">VN</div>
                <div>
                    <div class="gw-logo-name">VNPay</div>
                    <div class="gw-logo-sub">Electronic Payment Gateway</div>
                </div>
            </div>
            <div class="gw-order-info">
                <div class="gw-order-row">
                    <span class="gw-order-lbl">Invoice Code</span>
                    <span style="font-family:'Courier New',monospace;font-weight:700"><%=invoiceCode%></span>
                </div>
                <div class="gw-order-row">
                    <span class="gw-order-lbl">Merchant</span>
                    <span>DRSMS System</span>
                </div>
                <div class="gw-order-row">
                    <span class="gw-order-lbl">Amount</span>
                    <span><%=amountFormatted%> ₫</span>
                </div>
            </div>
        </div>

        <%-- Body --%>
        <div class="gw-body">
            <div class="gw-section-title">Select Payment Method</div>

            <div class="payment-methods">
                <div class="pm-card selected" onclick="selectMethod('atm')" id="pm-atm">
                    <div class="pm-icon">🏦</div>
                    <div class="pm-name">ATM / NAPAS</div>
                    <div class="pm-sub">Domestic card</div>
                </div>
                <div class="pm-card" onclick="selectMethod('visa')" id="pm-visa">
                    <div class="pm-icon">💳</div>
                    <div class="pm-name">Visa / MC</div>
                    <div class="pm-sub">International</div>
                </div>
            </div>

            <%-- ATM form --%>
            <div id="form-atm" class="card-form">
                <div class="form-group">
                    <label class="form-label">ATM Card Number</label>
                    <input class="form-input" type="text" placeholder="9704 xxxx xxxx xxxx"
                           maxlength="19" oninput="formatCardNum(this)" value="9704 1234 5678 9012">
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Cardholder Name</label>
                        <input class="form-input" type="text" value="PHAM THI KHACH HANG" style="text-transform:uppercase">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Issue Date</label>
                        <input class="form-input" type="text" placeholder="MM/YY" maxlength="5" value="01/25">
                    </div>
                </div>
            </div>

            <%-- Visa form --%>
            <div id="form-visa" class="card-form" style="display:none">
                <div class="form-group">
                    <label class="form-label">Card Number</label>
                    <input class="form-input" type="text" placeholder="4111 xxxx xxxx xxxx"
                           maxlength="19" oninput="formatCardNum(this)" value="4111 1111 1111 1111">
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Expiry Date</label>
                        <input class="form-input" type="text" placeholder="MM/YY" maxlength="5" value="12/27">
                    </div>
                    <div class="form-group">
                        <label class="form-label">CVV</label>
                        <input class="form-input" type="password" placeholder="•••" maxlength="4" value="123">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Cardholder Name</label>
                    <input class="form-input" type="text" value="PHAM THI KHACH HANG" style="text-transform:uppercase">
                </div>
            </div>

            <%-- OTP --%>
            <div class="otp-section" id="otpSection">
                <div class="otp-title">🔐 OTP Verification</div>
                <div class="otp-desc">OTP has been sent to phone <strong style="color:var(--amber)">09***4567</strong> (simulation: enter any 6 digits)</div>
                <div class="otp-input-row">
                    <input class="otp-input" id="otpInput" type="text"
                           maxlength="6" placeholder="——————" inputmode="numeric">
                    <button class="btn-get-otp" id="otpBtn" onclick="requestOTP()">Send OTP</button>
                </div>
            </div>

            <button class="btn-pay" id="payBtn" onclick="handlePay()">
                🔒 Pay <%=amountFormatted%> ₫
            </button>
            <button class="btn-cancel" onclick="cancelPayment()">Cancel &amp; Go Back</button>

            <div class="security-info">🔒 SSL Secured Connection · Data is Encrypted</div>
        </div>
    </div>

    <%-- Processing overlay --%>
    <div class="processing-overlay" id="procOverlay">
        <div class="processing-box">
            <div class="proc-spinner"></div>
            <div class="proc-title">Processing Payment</div>
            <div class="proc-sub" id="procMsg">Please do not close this page...</div>
        </div>
    </div>

    <%-- Confirm form --%>
    <form method="post" action="<%=confirmServlet%>" id="confirmForm">
        <input type="hidden" name="action"    value="vnpay_confirm">
        <input type="hidden" name="invoiceId" value="<%=invoiceId%>">
    </form>

    <script>
        let step = 'form', currentMethod = 'atm', otpCountdown = null;

        function selectMethod(m) {
            currentMethod = m;
            document.getElementById('pm-atm').classList.toggle('selected', m === 'atm');
            document.getElementById('pm-visa').classList.toggle('selected', m === 'visa');
            document.getElementById('form-atm').style.display = m === 'atm' ? 'block' : 'none';
            document.getElementById('form-visa').style.display = m === 'visa' ? 'block' : 'none';
            step = 'form';
            document.getElementById('otpSection').classList.remove('show');
            document.getElementById('payBtn').textContent = '🔒 Pay <%=amountFormatted%> ₫';
        }

        function formatCardNum(el) {
            let v = el.value.replace(/\D/g, '').substring(0, 16);
            el.value = v.replace(/(.{4})/g, '$1 ').trim();
        }

        function handlePay() {
            if (step === 'form') {
                document.getElementById('otpSection').classList.add('show');
                document.getElementById('payBtn').textContent = '✅ Confirm Payment';
                step = 'otp';
                requestOTP();
                document.getElementById('otpSection').scrollIntoView({ behavior: 'smooth' });
            } else if (step === 'otp') {
                const otp = document.getElementById('otpInput').value.trim();
                if (otp.length < 6) { alert('Please enter all 6 OTP digits'); return; }
                step = 'processing';
                document.getElementById('procOverlay').classList.add('show');
                document.getElementById('payBtn').disabled = true;
                let t = 2;
                const iv = setInterval(() => {
                    document.getElementById('procMsg').textContent = 'Confirming... (' + t + 's)';
                    t--;
                    if (t < 0) {
                        clearInterval(iv);
                        document.getElementById('procMsg').textContent = 'Success! Redirecting...';
                        setTimeout(() => document.getElementById('confirmForm').submit(), 800);
                    }
                }, 1000);
            }
        }

        function requestOTP() {
            const btn = document.getElementById('otpBtn');
            btn.disabled = true;
            let count = 60;
            btn.textContent = 'Resend (' + count + 's)';
            if (otpCountdown) clearInterval(otpCountdown);
            otpCountdown = setInterval(() => {
                count--;
                btn.textContent = 'Resend (' + count + 's)';
                if (count <= 0) { clearInterval(otpCountdown); btn.disabled = false; btn.textContent = 'Send OTP'; }
            }, 1000);
            setTimeout(() => {
                let i = 0; const d = '123456';
                const f = setInterval(() => {
                    document.getElementById('otpInput').value = d.substring(0, i + 1);
                    i++; if (i >= 6) clearInterval(f);
                }, 100);
            }, 1200);
        }

        function cancelPayment() {
            if (confirm('Are you sure you want to cancel the payment?')) {
                const f = document.createElement('form');
                f.method = 'post'; f.action = '<%=confirmServlet%>';
                const a1 = document.createElement('input'); a1.name = 'action'; a1.value = 'vnpay_cancel'; f.appendChild(a1);
                const a2 = document.createElement('input'); a2.name = 'invoiceId'; a2.value = '<%=invoiceId%>'; f.appendChild(a2);
                document.body.appendChild(f); f.submit();
            }
        }
    </script>
</body>
</html>
