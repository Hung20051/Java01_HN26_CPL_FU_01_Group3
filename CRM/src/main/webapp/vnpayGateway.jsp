<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer invoiceId   = (Integer) request.getAttribute("invoiceId");
    String  invoiceCode = (String)  request.getAttribute("invoiceCode");
    String  amount      = (String)  request.getAttribute("amount");
    // Phân biệt: từ shop (pendingFromShop=true) hay từ invoice page
    Boolean fromShop = (Boolean) session.getAttribute("pendingFromShop");
    boolean isFromShop = Boolean.TRUE.equals(fromShop);

    String ctx = request.getContextPath();
    // Servlet nhận confirm/cancel
    String confirmServlet = isFromShop ? (ctx + "/customerShop") : (ctx + "/customerPayment");
    String cancelUrl      = isFromShop
        ? (ctx + "/customerShop?action=cart")
        : (ctx + "/customerInvoices?action=detail&id=" + invoiceId);

    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
    String amountFormatted = "0";
    try { amountFormatted = nf.format(new java.math.BigDecimal(amount)); } catch(Exception e){}
%>
<!DOCTYPE html><html lang="vi"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Cổng Thanh Toán VNPay - Giả Lập</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            *{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            body{
                font-family:'Inter',sans-serif;
                background:linear-gradient(135deg,#e8f4fd 0%,#f0f7ee 100%);
                min-height:100vh;
                display:flex;
                align-items:center;
                justify-content:center;
                padding:20px
            }
            .gateway-card{
                background:#fff;
                border-radius:20px;
                box-shadow:0 20px 60px rgba(0,0,0,.12);
                width:100%;
                max-width:460px;
                overflow:hidden
            }
            .gw-header{
                background:linear-gradient(135deg,#e30019,#b50014);
                padding:24px 28px;
                color:#fff;
                position:relative
            }
            .gw-logo{
                display:flex;
                align-items:center;
                gap:12px;
                margin-bottom:16px
            }
            .gw-logo-icon{
                width:48px;
                height:48px;
                background:rgba(255,255,255,.2);
                border-radius:12px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.4rem;
                font-weight:900;
                color:#fff;
                border:2px solid rgba(255,255,255,.4)
            }
            .gw-logo-name{
                font-size:1.3rem;
                font-weight:800;
                letter-spacing:.5px
            }
            .gw-logo-sub{
                font-size:.72rem;
                opacity:.8;
                margin-top:2px
            }
            .gw-simulate-badge{
                position:absolute;
                top:14px;
                right:16px;
                background:rgba(255,255,255,.2);
                border:1px solid rgba(255,255,255,.4);
                color:#fff;
                font-size:.65rem;
                font-weight:700;
                padding:3px 9px;
                border-radius:20px;
                letter-spacing:.5px
            }
            .gw-order-info{
                background:rgba(255,255,255,.12);
                border-radius:10px;
                padding:12px 14px
            }
            .gw-order-row{
                display:flex;
                justify-content:space-between;
                align-items:center;
                font-size:.82rem;
                margin-bottom:4px
            }
            .gw-order-row:last-child{
                margin-bottom:0;
                font-size:.95rem;
                font-weight:700;
                margin-top:8px;
                padding-top:8px;
                border-top:1px solid rgba(255,255,255,.2)
            }
            .gw-order-lbl{
                opacity:.8
            }
            .gw-body{
                padding:28px
            }
            .gw-section-title{
                font-size:.78rem;
                font-weight:700;
                color:#64748b;
                text-transform:uppercase;
                letter-spacing:.8px;
                margin-bottom:14px
            }
            .payment-methods{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:10px;
                margin-bottom:20px
            }
            .pm-card{
                border:2px solid #e2e8f0;
                border-radius:12px;
                padding:14px;
                cursor:pointer;
                transition:.2s;
                text-align:center;
                position:relative
            }
            .pm-card:hover{
                border-color:#e30019;
                background:#fef2f2
            }
            .pm-card.selected{
                border-color:#e30019;
                background:#fef2f2
            }
            .pm-card.selected::after{
                content:'✓';
                position:absolute;
                top:6px;
                right:8px;
                color:#e30019;
                font-size:.8rem;
                font-weight:700
            }
            .pm-icon{
                font-size:1.6rem;
                margin-bottom:6px
            }
            .pm-name{
                font-size:.78rem;
                font-weight:600;
                color:#0f172a
            }
            .pm-sub{
                font-size:.68rem;
                color:#64748b;
                margin-top:2px
            }
            .card-form{
                background:#f8fafc;
                border-radius:12px;
                padding:16px;
                margin-bottom:20px
            }
            .form-group{
                margin-bottom:12px
            }
            .form-group:last-child{
                margin-bottom:0
            }
            .form-label{
                font-size:.74rem;
                font-weight:600;
                color:#64748b;
                margin-bottom:5px;
                display:block
            }
            .form-input{
                width:100%;
                padding:10px 13px;
                border:1.5px solid #e2e8f0;
                border-radius:9px;
                font-size:.875rem;
                font-family:inherit;
                color:#0f172a;
                outline:none;
                transition:.15s;
                background:#fff
            }
            .form-input:focus{
                border-color:#e30019
            }
            .form-row{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:10px
            }
            .otp-section{
                background:#fffbeb;
                border:1px solid #fde68a;
                border-radius:12px;
                padding:14px;
                margin-bottom:20px;
                display:none
            }
            .otp-section.show{
                display:block
            }
            .otp-title{
                font-size:.82rem;
                font-weight:600;
                color:#92400e;
                margin-bottom:4px
            }
            .otp-desc{
                font-size:.75rem;
                color:#78350f;
                margin-bottom:10px
            }
            .otp-input-row{
                display:flex;
                gap:8px;
                align-items:center
            }
            .otp-input{
                flex:1;
                padding:10px 13px;
                border:1.5px solid #fde68a;
                border-radius:9px;
                font-size:1rem;
                font-weight:700;
                letter-spacing:4px;
                text-align:center;
                font-family:monospace;
                background:#fff;
                outline:none
            }
            .btn-get-otp{
                padding:10px 14px;
                background:#f59e0b;
                color:#fff;
                border:none;
                border-radius:9px;
                font-size:.78rem;
                font-weight:700;
                cursor:pointer;
                white-space:nowrap
            }
            .btn-get-otp:disabled{
                background:#fde68a;
                color:#92400e;
                cursor:not-allowed
            }
            .btn-pay{
                width:100%;
                padding:14px;
                background:linear-gradient(135deg,#e30019,#b50014);
                color:#fff;
                border:none;
                border-radius:12px;
                font-size:1rem;
                font-weight:700;
                cursor:pointer;
                transition:.2s;
                display:flex;
                align-items:center;
                justify-content:center;
                gap:9px;
                margin-bottom:12px
            }
            .btn-pay:hover{
                transform:translateY(-1px);
                box-shadow:0 6px 20px rgba(227,0,25,.3)
            }
            .btn-pay:disabled{
                background:#94a3b8;
                transform:none;
                box-shadow:none;
                cursor:not-allowed
            }
            .btn-cancel{
                width:100%;
                padding:11px;
                background:#f8fafc;
                color:#64748b;
                border:1.5px solid #e2e8f0;
                border-radius:12px;
                font-size:.875rem;
                font-weight:600;
                cursor:pointer
            }
            .security-info{
                display:flex;
                align-items:center;
                justify-content:center;
                gap:6px;
                font-size:.72rem;
                color:#94a3b8;
                margin-top:14px
            }
            .processing-overlay{
                display:none;
                position:fixed;
                inset:0;
                background:rgba(0,0,0,.6);
                backdrop-filter:blur(4px);
                align-items:center;
                justify-content:center;
                z-index:999
            }
            .processing-overlay.show{
                display:flex
            }
            .processing-box{
                background:#fff;
                border-radius:18px;
                padding:36px 40px;
                text-align:center;
                max-width:300px
            }
            .proc-spinner{
                width:52px;
                height:52px;
                border:4px solid #f1f5f9;
                border-top:4px solid #e30019;
                border-radius:50%;
                animation:spin 1s linear infinite;
                margin:0 auto 16px
            }
            @keyframes spin{
                to{
                    transform:rotate(360deg)
                }
            }
            .proc-title{
                font-size:1rem;
                font-weight:700;
                color:#0f172a;
                margin-bottom:6px
            }
            .proc-sub{
                font-size:.82rem;
                color:#64748b
            }
        </style>
    </head><body>

        <div class="gateway-card">
            <div class="gw-header">
                <span class="gw-simulate-badge">🔬 SANDBOX</span>
                <div class="gw-logo">
                    <div class="gw-logo-icon">VN</div>
                    <div><div class="gw-logo-name">VNPay</div><div class="gw-logo-sub">Cổng thanh toán điện tử</div></div>
                </div>
                <div class="gw-order-info">
                    <div class="gw-order-row"><span class="gw-order-lbl">Mã hóa đơn</span><span style="font-family:monospace;font-weight:600"><%=invoiceCode%></span></div>
                    <div class="gw-order-row"><span class="gw-order-lbl">Đơn vị</span><span>CRM System</span></div>
                    <div class="gw-order-row"><span class="gw-order-lbl">Số tiền thanh toán</span><span><%=amountFormatted%> ₫</span></div>
                </div>
            </div>

            <div class="gw-body">
                <div class="gw-section-title">Chọn phương thức</div>
                <div class="payment-methods">
                    <div class="pm-card selected" onclick="selectMethod('atm')" id="pm-atm">
                        <div class="pm-icon">🏦</div><div class="pm-name">Thẻ ATM / NAPAS</div><div class="pm-sub">Nội địa</div>
                    </div>
                    <div class="pm-card" onclick="selectMethod('visa')" id="pm-visa">
                        <div class="pm-icon">💳</div><div class="pm-name">Thẻ Visa / MC</div><div class="pm-sub">Quốc tế</div>
                    </div>
                </div>

                <div id="form-atm" class="card-form">
                    <div class="form-group"><label class="form-label">Số thẻ ATM</label>
                        <input class="form-input" type="text" placeholder="9704 xxxx xxxx xxxx" maxlength="19" oninput="formatCardNum(this)" value="9704 1234 5678 9012"></div>
                    <div class="form-row">
                        <div class="form-group"><label class="form-label">Tên chủ thẻ</label>
                            <input class="form-input" type="text" value="PHAM THI KHACH HANG" style="text-transform:uppercase"></div>
                        <div class="form-group"><label class="form-label">Ngày phát hành</label>
                            <input class="form-input" type="text" placeholder="MM/YY" maxlength="5" value="01/25"></div>
                    </div>
                </div>

                <div id="form-visa" class="card-form" style="display:none">
                    <div class="form-group"><label class="form-label">Số thẻ</label>
                        <input class="form-input" type="text" placeholder="4111 xxxx xxxx xxxx" maxlength="19" oninput="formatCardNum(this)" value="4111 1111 1111 1111"></div>
                    <div class="form-row">
                        <div class="form-group"><label class="form-label">Ngày hết hạn</label>
                            <input class="form-input" type="text" placeholder="MM/YY" maxlength="5" value="12/27"></div>
                        <div class="form-group"><label class="form-label">CVV</label>
                            <input class="form-input" type="password" placeholder="***" maxlength="4" value="123"></div>
                    </div>
                    <div class="form-group"><label class="form-label">Tên chủ thẻ</label>
                        <input class="form-input" type="text" value="PHAM THI KHACH HANG" style="text-transform:uppercase"></div>
                </div>

                <div class="otp-section" id="otpSection">
                    <div class="otp-title">🔐 Xác thực OTP</div>
                    <div class="otp-desc">Mã OTP đã gửi đến SĐT <strong>09***4567</strong> (giả lập: nhập bất kỳ 6 số)</div>
                    <div class="otp-input-row">
                        <input class="otp-input" id="otpInput" type="text" maxlength="6" placeholder="------" inputmode="numeric">
                        <button class="btn-get-otp" id="otpBtn" onclick="requestOTP()">Gửi OTP</button>
                    </div>
                </div>

                <button class="btn-pay" id="payBtn" onclick="handlePay()">
                    <i>🔒</i> Thanh toán <%=amountFormatted%> ₫
                </button>
                <button class="btn-cancel" onclick="cancelPayment()">Hủy & Quay lại</button>
                <div class="security-info">🔒 Kết nối bảo mật SSL · Dữ liệu được mã hóa</div>
            </div>
        </div>

        <div class="processing-overlay" id="procOverlay">
            <div class="processing-box">
                <div class="proc-spinner"></div>
                <div class="proc-title">Đang xử lý thanh toán</div>
                <div class="proc-sub" id="procMsg">Vui lòng không tắt trang này...</div>
            </div>
        </div>

        <!-- Form confirm: gửi về đúng servlet tùy context -->
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
                document.getElementById('payBtn').innerHTML = '<i>🔒</i> Thanh toán <%=amountFormatted%> ₫';
            }

            function formatCardNum(el) {
                let v = el.value.replace(/\D/g, '').substring(0, 16);
                el.value = v.replace(/(.{4})/g, '$1 ').trim();
            }

            function handlePay() {
                if (step === 'form') {
                    document.getElementById('otpSection').classList.add('show');
                    document.getElementById('payBtn').innerHTML = '<i>✅</i> Xác nhận thanh toán';
                    step = 'otp';
                    requestOTP();
                    document.getElementById('otpSection').scrollIntoView({behavior: 'smooth'});
                } else if (step === 'otp') {
                    const otp = document.getElementById('otpInput').value.trim();
                    if (otp.length < 6) {
                        alert('Vui lòng nhập đủ 6 số OTP');
                        return;
                    }
                    step = 'processing';
                    document.getElementById('procOverlay').classList.add('show');
                    document.getElementById('payBtn').disabled = true;
                    let t = 2;
                    const iv = setInterval(() => {
                        document.getElementById('procMsg').textContent = 'Đang xác nhận... (' + t + 's)';
                        t--;
                        if (t < 0) {
                            clearInterval(iv);
                            document.getElementById('procMsg').textContent = 'Thành công! Đang chuyển hướng...';
                            setTimeout(() => document.getElementById('confirmForm').submit(), 800);
                        }
                    }, 1000);
                }
            }

            function requestOTP() {
                const btn = document.getElementById('otpBtn');
                btn.disabled = true;
                let count = 60;
                btn.textContent = 'Gửi lại (' + count + 's)';
                if (otpCountdown)
                    clearInterval(otpCountdown);
                otpCountdown = setInterval(() => {
                    count--;
                    btn.textContent = 'Gửi lại (' + count + 's)';
                    if (count <= 0) {
                        clearInterval(otpCountdown);
                        btn.disabled = false;
                        btn.textContent = 'Gửi OTP';
                    }
                }, 1000);
                setTimeout(() => {
                    let i = 0;
                    const d = '123456';
                    const f = setInterval(() => {
                        document.getElementById('otpInput').value = d.substring(0, i + 1);
                        i++;
                        if (i >= 6)
                            clearInterval(f);
                    }, 100);
                }, 1200);
            }

            function cancelPayment() {
                if (confirm('Bạn có chắc muốn hủy thanh toán?')) {
                    // POST cancel về đúng servlet
                    const f = document.createElement('form');
                    f.method = 'post';
                    f.action = '<%=confirmServlet%>';
                    const a1 = document.createElement('input');
                    a1.name = 'action';
                    a1.value = 'vnpay_cancel';
                    f.appendChild(a1);
                    const a2 = document.createElement('input');
                    a2.name = 'invoiceId';
                    a2.value = '<%=invoiceId%>';
                    f.appendChild(a2);
                    document.body.appendChild(f);
                    f.submit();
                }
            }
        </script>
    </body></html>
