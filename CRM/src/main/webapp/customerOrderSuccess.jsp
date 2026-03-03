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
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Đặt hàng thành công - CRM</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Segoe UI',sans-serif;background:#f0f2f5;min-height:100vh;display:flex;align-items:center;justify-content:center}
        .success-card{background:white;border-radius:20px;padding:48px 44px;max-width:480px;width:100%;text-align:center;box-shadow:0 8px 32px rgba(0,0,0,.08)}
        .icon-wrap{width:80px;height:80px;background:#d1fae5;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 20px;font-size:2.5rem}
        h1{font-size:1.5rem;font-weight:800;color:#1e293b;margin-bottom:8px}
        .sub{font-size:.92rem;color:#64748b;margin-bottom:28px;line-height:1.5}
        .info-box{background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:18px;margin-bottom:24px;text-align:left}
        .info-row{display:flex;justify-content:space-between;align-items:center;padding:6px 0;font-size:.875rem;border-bottom:1px solid #f1f5f9}
        .info-row:last-child{border-bottom:none;padding-bottom:0}
        .info-label{color:#64748b}
        .info-value{font-weight:700;color:#1e293b}
        .info-value.code{font-family:monospace;color:#6366f1;font-size:.95rem}
        .info-value.paid{color:#10b981}
        .actions{display:flex;flex-direction:column;gap:10px}
        .btn{padding:12px 24px;border-radius:10px;font-size:.9rem;font-weight:700;border:none;cursor:pointer;text-decoration:none;display:flex;align-items:center;justify-content:center;gap:8px;transition:.15s}
        .btn-primary{background:#6366f1;color:white}
        .btn-primary:hover{background:#4f46e5}
        .btn-secondary{background:#f8fafc;color:#374151;border:1.5px solid #e2e8f0}
        .btn-secondary:hover{background:#f1f5f9}
    </style>
</head>
<body>
<div class="success-card">
    <div class="icon-wrap">✅</div>
    <h1>Đặt hàng thành công!</h1>
    <p class="sub">
        Cảm ơn bạn đã mua hàng. Đơn hàng của bạn đã được ghi nhận.<br>
        Hóa đơn sẽ được gửi qua email trong vài phút.
    </p>

    <div class="info-box">
        <div class="info-row">
            <span class="info-label">Mã hóa đơn</span>
            <span class="info-value code"><%= invoiceCode %></span>
        </div>
        <div class="info-row">
            <span class="info-label">Phương thức</span>
            <span class="info-value"><%= isVnpay ? "VNPay" : "Tiền mặt" %></span>
        </div>
        <div class="info-row">
            <span class="info-label">Trạng thái</span>
            <span class="info-value paid">
                <i class="fas fa-check-circle"></i>
                <%= isVnpay ? "Đã thanh toán" : "Chờ thu tiền mặt" %>
            </span>
        </div>
    </div>

    <div class="actions">
        <a href="<%= ctx %>/customerInvoices" class="btn btn-primary">
            <i class="fas fa-file-invoice"></i> Xem hóa đơn của tôi
        </a>
        <a href="<%= ctx %>/customerShop?action=parts" class="btn btn-secondary">
            <i class="fas fa-store"></i> Tiếp tục mua hàng
        </a>
        <a href="<%= ctx %>/customerDashboard" class="btn btn-secondary">
            <i class="fas fa-home"></i> Về trang chủ
        </a>
    </div>
</div>
</body>
</html>
