<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String invoiceCode = (String) request.getAttribute("invoiceCode");
    String payMethod   = (String) request.getAttribute("payMethod");
    if (invoiceCode == null) invoiceCode = "---";
    boolean isVnpay = "vnpay".equals(payMethod);
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Order Successful - DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bg:           #f3f4f9;
            --bg-card:      #ffffff;
            --border-light: #e8ecf5;
            --border-light2:#f0f2fb;
            --text-h:       #1e1b4b;
            --text-b:       #374151;
            --text-m:       #6b7280;
            --text-s:       #9ca3af;
            --primary:      #4f46e5;
            --primary-2:    #6366f1;
            --primary-light:#ede9fe;
            --purple:       #7c3aed;
            --green:        #16a34a;
            --amber:        #d97706;
            --orange:       #ea580c;
            --info:         #0284c7;
        }

        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        body{
            font-family:'Sora',sans-serif;
            background:var(--bg);
            min-height:100vh;
            display:flex;
            align-items:center;
            justify-content:center;
            padding:24px;
            background-image:
                radial-gradient(ellipse 55% 45% at 50% 25%,rgba(22,163,74,0.06) 0%,transparent 65%),
                radial-gradient(ellipse 40% 30% at 75% 75%,rgba(79,70,229,0.05) 0%,transparent 60%);
        }

        @keyframes cardIn{
            from{opacity:0;transform:translateY(24px) scale(0.98)}
            to  {opacity:1;transform:translateY(0) scale(1)}
        }
        @keyframes checkPop{
            0%  {transform:scale(0) rotate(-15deg);opacity:0}
            60% {transform:scale(1.15) rotate(5deg);opacity:1}
            100%{transform:scale(1) rotate(0deg)}
        }
        @keyframes ringPulse{
            0%,100%{box-shadow:0 0 0 0 rgba(22,163,74,0.25)}
            50%    {box-shadow:0 0 0 14px rgba(22,163,74,0)}
        }

        .success-card{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:22px;
            padding:48px 44px;
            max-width:460px;
            width:100%;
            text-align:center;
            box-shadow:0 8px 40px rgba(79,70,229,0.1), 0 1px 0 rgba(255,255,255,0.8);
            animation:cardIn .5s cubic-bezier(.4,0,.2,1) both;
            position:relative; overflow:hidden;
        }
        /* Top accent line */
        .success-card::before{
            content:'';
            position:absolute;top:0;left:20%;right:20%;height:2px;
            background:linear-gradient(90deg,transparent,var(--green),transparent);
        }

        /* Icon */
        .icon-wrap{
            width:82px;height:82px;
            background:#d1fae5;
            border:2px solid #a7f3d0;
            border-radius:50%;
            display:flex;align-items:center;justify-content:center;
            margin:0 auto 22px;
            font-size:2.2rem;
            animation:checkPop .55s .25s cubic-bezier(.4,0,.2,1) both,
                      ringPulse 2.5s .8s ease-in-out infinite;
        }

        h1{
            font-size:1.42rem;font-weight:800;
            color:var(--text-h);margin-bottom:10px;
            letter-spacing:-.4px;
        }
        .sub{
            font-size:.83rem;color:var(--text-m);
            margin-bottom:26px;line-height:1.65;
        }

        /* Info box */
        .info-box{
            background:#fafbff;
            border:1px solid var(--border-light);
            border-radius:14px;
            padding:6px 18px;
            margin-bottom:24px;
            text-align:left;
        }
        .info-row{
            display:flex;justify-content:space-between;align-items:center;
            padding:12px 0;font-size:.83rem;
            border-bottom:1px solid var(--border-light2);
        }
        .info-row:last-child{border-bottom:none}
        .info-label{color:var(--text-s);font-weight:500}
        .info-value{
            font-weight:700;color:var(--text-b);
            display:flex;align-items:center;gap:6px;
        }
        .info-value.code{
            font-family:'Courier New',monospace;
            color:var(--primary-2);font-size:.91rem;
        }
        .info-value.paid{color:var(--green)}
        .info-value.cash{color:var(--amber)}

        /* Actions */
        .actions{display:flex;flex-direction:column;gap:9px}
        .btn{
            padding:12px 24px;border-radius:11px;
            font-size:.875rem;font-weight:700;
            font-family:'Sora',sans-serif;
            border:none;cursor:pointer;
            text-decoration:none;
            display:flex;align-items:center;justify-content:center;gap:9px;
            transition:all .22s;
        }
        .btn-primary{
            background:var(--primary);
            color:#fff;
            box-shadow:0 4px 14px rgba(79,70,229,0.3);
        }
        .btn-primary:hover{
            background:#4338ca;
            transform:translateY(-2px);
            box-shadow:0 8px 24px rgba(79,70,229,0.42);
        }
        .btn-secondary{
            background:#fff;
            color:var(--text-m);
            border:1.5px solid var(--border-light);
        }
        .btn-secondary:hover{
            background:var(--primary-light);
            border-color:rgba(99,102,241,0.3);
            color:var(--primary-2);
        }
    </style>
</head>
<body>
    <div class="success-card">
        <div class="icon-wrap">✅</div>

        <h1>Order Placed Successfully!</h1>
        <p class="sub">
            Thank you for your purchase. Your order has been recorded.<br>
            An invoice will be sent to your email within a few minutes.
        </p>

        <div class="info-box">
            <div class="info-row">
                <span class="info-label">Invoice Code</span>
                <span class="info-value code"><%=invoiceCode%></span>
            </div>
            <div class="info-row">
                <span class="info-label">Payment Method</span>
                <span class="info-value"><%=isVnpay ? "VNPay" : "Cash"%></span>
            </div>
            <div class="info-row">
                <span class="info-label">Status</span>
                <%if(isVnpay){%>
                <span class="info-value paid">
                    <i class="fas fa-check-circle"></i> Paid
                </span>
                <%}else{%>
                <span class="info-value cash">
                    <i class="fas fa-clock"></i> Awaiting cash collection
                </span>
                <%}%>
            </div>
        </div>

        <div class="actions">
            <a href="<%=ctx%>/customerInvoices" class="btn btn-primary">
                <i class="fas fa-file-invoice"></i> View My Invoices
            </a>
            <a href="<%=ctx%>/customerShop?action=parts" class="btn btn-secondary">
                <i class="fas fa-store"></i> Continue Shopping
            </a>
            <a href="<%=ctx%>/customerDashboard" class="btn btn-secondary">
                <i class="fas fa-home"></i> Back to Home
            </a>
        </div>
    </div>
</body>
</html>
