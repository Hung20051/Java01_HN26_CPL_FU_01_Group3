<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*,java.math.BigDecimal" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    Invoice inv=(Invoice)request.getAttribute("invoice");
    if(inv==null){response.sendRedirect(request.getContextPath()+"/customerInvoices");return;}
    String ctx=request.getContextPath();
    List<InvoiceItem> items=inv.getItems(); if(items==null)items=new ArrayList<>();
    java.text.NumberFormat nf=java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
    String isc="b-unpaid";
    if("PAID".equals(inv.getStatus()))isc="b-paid";
    else if("CANCELLED".equals(inv.getStatus()))isc="b-cancelled";
    boolean overdue="UNPAID".equals(inv.getStatus())&&inv.getDueDate()!=null&&inv.getDueDate().isBefore(java.time.LocalDate.now());
    // Check payment success notification
    String paySuccess=request.getParameter("paySuccess");
    String errorMsg=request.getParameter("error");
     int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title><%=inv.getInvoiceCode()%> - DRSMS</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root{
                --primary:#4f46e5;
                --sidebar:#0f172a;
                --bg:#f8fafc;
                --surface:#fff;
                --border:#e2e8f0;
                --text:#0f172a;
                --muted:#64748b;
                --success:#10b981;
                --warning:#f59e0b;
                --danger:#ef4444;
                --info:#3b82f6
            }
            *{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            body{
                font-family:'Inter',sans-serif;
                background:var(--bg);
                display:flex;
                min-height:100vh
            }
            .sb{
                width:240px;
                min-height:100vh;
                background:var(--sidebar);
                display:flex;
                flex-direction:column;
                position:fixed
            }
            .sb-brand{
                padding:22px 18px 18px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid rgba(255,255,255,.07)
            }
            .sb-logo{
                width:34px;
                height:34px;
                background:var(--primary);
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem
            }
            .sb-name{
                color:#fff;
                font-size:1rem;
                font-weight:700
            }
            .sb-sub{
                color:rgba(255,255,255,.35);
                font-size:.68rem
            }
            .sb-nav{
                flex:1;
                padding:14px 10px
            }
            .sb-lbl{
                color:rgba(255,255,255,.28);
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.2px;
                padding:0 8px;
                margin:14px 0 5px
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:8px;
                margin-bottom:2px;
                color:rgba(255,255,255,.58);
                text-decoration:none;
                font-size:.855rem;
                font-weight:500;
                transition:.15s
            }
            .sb-item:hover{
                color:#fff;
                background:rgba(255,255,255,.07)
            }
            .sb-item.on{
                color:#fff;
                background:var(--primary)
            }
            .sb-item i{
                width:17px;
                text-align:center;
                font-size:.83rem
            }
            .sb-foot{
                padding:14px 10px 18px;
                border-top:1px solid rgba(255,255,255,.07)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:9px;
                background:rgba(255,255,255,.05);
                margin-bottom:7px
            }
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                font-weight:700
            }
            .sb-uname{
                color:#fff;
                font-size:.82rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,.38);
                font-size:.7rem
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:8px 10px;
                border-radius:8px;
                color:rgba(255,255,255,.45);
                text-decoration:none;
                font-size:.82rem;
                transition:.15s
            }
            .sb-logout:hover{
                color:#f87171;
                background:rgba(248,113,113,.1)
            }
            .main{
                margin-left:240px;
                flex:1;
                padding:28px 32px
            }
            .breadcrumb{
                display:flex;
                align-items:center;
                gap:7px;
                font-size:.81rem;
                color:var(--muted);
                margin-bottom:18px
            }
            .breadcrumb a{
                color:var(--muted);
                text-decoration:none
            }
            .breadcrumb a:hover{
                color:var(--primary)
            }
            .breadcrumb-sep{
                color:#cbd5e1
            }
            .btn-back{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:9px 16px;
                border-radius:9px;
                background:var(--bg);
                color:var(--muted);
                border:1.5px solid var(--border);
                text-decoration:none;
                font-size:.855rem;
                font-weight:600;
                transition:.15s;
                margin-bottom:18px
            }
            .btn-back:hover{
                background:#f1f5f9
            }
            .grid-inv{
                display:grid;
                grid-template-columns:3fr 2fr;
                gap:18px;
                align-items:start
            }
            .card{
                background:var(--surface);
                border-radius:13px;
                border:1px solid var(--border);
                overflow:hidden;
                margin-bottom:16px
            }
            .card-hd{
                padding:15px 20px;
                border-bottom:1px solid #f1f5f9;
                display:flex;
                align-items:center;
                gap:8px
            }
            .card-hd-icon{
                width:30px;
                height:30px;
                border-radius:8px;
                background:var(--primary);
                color:#fff;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.8rem
            }
            .card-hd-title{
                font-size:.88rem;
                font-weight:700;
                color:var(--text)
            }
            .card-body{
                padding:20px
            }
            .inv-header{
                background:linear-gradient(135deg,#4f46e5,#7c3aed);
                color:#fff;
                border-radius:13px;
                padding:24px 28px;
                margin-bottom:18px;
                display:flex;
                justify-content:space-between;
                align-items:flex-start
            }
            .inv-title{
                font-size:1.5rem;
                font-weight:800;
                letter-spacing:-.5px;
                margin-bottom:4px
            }
            .inv-code{
                font-family:monospace;
                font-size:1rem;
                opacity:.8
            }
            .inv-date{
                opacity:.7;
                font-size:.82rem;
                margin-top:4px
            }
            .inv-company{
                text-align:right;
                font-size:.82rem;
                opacity:.85;
                line-height:1.7
            }
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.73rem;
                font-weight:600
            }
            .b-unpaid{
                background:#fef3c7;
                color:#92400e
            }
            .b-paid{
                background:#d1fae5;
                color:#065f46
            }
            .b-cancelled{
                background:#f3f4f6;
                color:#6b7280
            }
            table{
                width:100%;
                border-collapse:collapse;
                font-size:.84rem
            }
            thead tr{
                background:#f8fafc
            }
            th{
                padding:10px 14px;
                text-align:left;
                color:var(--muted);
                font-weight:600;
                font-size:.72rem;
                text-transform:uppercase;
                letter-spacing:.5px;
                border-bottom:1px solid var(--border)
            }
            td{
                padding:12px 14px;
                border-bottom:1px solid #f8fafc;
                vertical-align:middle
            }
            tr:last-child td{
                border-bottom:none
            }
            th:nth-child(3),th:nth-child(4),th:nth-child(5){
                text-align:right
            }
            td:nth-child(3),td:nth-child(4),td:nth-child(5){
                text-align:right
            }
            .sum-row{
                display:flex;
                justify-content:space-between;
                padding:8px 0;
                font-size:.88rem;
                border-bottom:1px solid #f8fafc
            }
            .sum-row:last-child{
                border-bottom:none;
                font-size:1.05rem;
                font-weight:800;
                color:var(--primary);
                padding-top:12px;
                margin-top:4px;
                border-top:2px solid var(--border)
            }
            .sum-row .lbl{
                color:var(--muted)
            }
            .sum-row.total .lbl{
                color:var(--text)
            }
            .info-grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:8px
            }
            .info-item .lbl{
                font-size:.74rem;
                color:var(--muted);
                font-weight:600;
                margin-bottom:3px
            }
            .info-item .val{
                font-size:.855rem;
                color:var(--text)
            }
            .overdue-box{
                background:#fef2f2;
                border:1px solid #fca5a5;
                border-radius:10px;
                padding:12px 14px;
                font-size:.84rem;
                color:#991b1b;
                margin-bottom:16px;
                display:flex;
                align-items:center;
                gap:9px
            }
            .paid-box{
                background:#f0fdf4;
                border:1px solid #bbf7d0;
                border-radius:10px;
                padding:12px 14px;
                font-size:.84rem;
                color:#065f46;
                display:flex;
                align-items:center;
                gap:9px;
                margin-bottom:16px
            }
            .success-toast{
                background:#f0fdf4;
                border:1px solid #86efac;
                border-radius:10px;
                padding:14px 16px;
                font-size:.855rem;
                color:#065f46;
                margin-bottom:16px;
                display:flex;
                align-items:center;
                gap:10px;
                animation:fadeIn .4s ease
            }
            .error-toast{
                background:#fef2f2;
                border:1px solid #fca5a5;
                border-radius:10px;
                padding:12px 14px;
                font-size:.84rem;
                color:#991b1b;
                margin-bottom:16px;
                display:flex;
                align-items:center;
                gap:9px
            }
            @keyframes fadeIn{
                from{
                    opacity:0;
                    transform:translateY(-8px)
                }
                to{
                    opacity:1;
                    transform:translateY(0)
                }
            }
            .item-type{
                padding:2px 7px;
                border-radius:4px;
                font-size:.7rem;
                font-weight:600
            }
            /* Payment buttons */
            .pay-section{
                margin-top:12px
            }
            .pay-title{
                font-size:.74rem;
                font-weight:700;
                color:var(--muted);
                text-transform:uppercase;
                letter-spacing:.5px;
                margin-bottom:9px
            }
            .pay-btns{
                display:flex;
                flex-direction:column;
                gap:8px
            }
            .btn-pay-cash{
                display:flex;
                align-items:center;
                justify-content:center;
                gap:8px;
                width:100%;
                padding:12px;
                background:linear-gradient(135deg,#10b981,#059669);
                color:#fff;
                border:none;
                border-radius:10px;
                font-size:.875rem;
                font-weight:700;
                cursor:pointer;
                transition:.2s
            }
            .btn-pay-cash:hover{
                transform:translateY(-1px);
                box-shadow:0 4px 15px rgba(16,185,129,.3)
            }
            .btn-pay-vnpay{
                display:flex;
                align-items:center;
                justify-content:center;
                gap:8px;
                width:100%;
                padding:12px;
                background:linear-gradient(135deg,#e30019,#b50014);
                color:#fff;
                border:none;
                border-radius:10px;
                font-size:.875rem;
                font-weight:700;
                cursor:pointer;
                transition:.2s
            }
            .btn-pay-vnpay:hover{
                transform:translateY(-1px);
                box-shadow:0 4px 15px rgba(227,0,25,.3)
            }
            /* Cash Modal */
            .modal-overlay{
                display:none;
                position:fixed;
                inset:0;
                background:rgba(0,0,0,.5);
                backdrop-filter:blur(3px);
                z-index:999;
                align-items:center;
                justify-content:center
            }
            .modal-overlay.show{
                display:flex
            }
            .modal{
                background:#fff;
                border-radius:18px;
                padding:0;
                width:420px;
                max-width:95vw;
                overflow:hidden;
                box-shadow:0 20px 60px rgba(0,0,0,.2);
                animation:modalIn .25s ease
            }
            @keyframes modalIn{
                from{
                    opacity:0;
                    transform:scale(.95)
                }
                to{
                    opacity:1;
                    transform:scale(1)
                }
            }
            .modal-header{
                padding:20px 24px;
                border-bottom:1px solid var(--border);
                display:flex;
                align-items:center;
                justify-content:space-between
            }
            .modal-title{
                font-size:1rem;
                font-weight:700;
                color:var(--text);
                display:flex;
                align-items:center;
                gap:8px
            }
            .modal-close{
                width:30px;
                height:30px;
                border-radius:8px;
                background:var(--bg);
                border:none;
                cursor:pointer;
                display:flex;
                align-items:center;
                justify-content:center;
                color:var(--muted);
                font-size:.95rem;
                transition:.15s
            }
            .modal-close:hover{
                background:#f1f5f9;
                color:var(--text)
            }
            .modal-body{
                padding:24px
            }
            .cash-amount-display{
                background:linear-gradient(135deg,#f0fdf4,#dcfce7);
                border-radius:12px;
                padding:18px;
                text-align:center;
                margin-bottom:18px
            }
            .cash-lbl{
                font-size:.78rem;
                color:var(--muted);
                font-weight:600;
                margin-bottom:4px
            }
            .cash-amount{
                font-size:2rem;
                font-weight:800;
                color:var(--success)
            }
            .cash-code{
                font-family:monospace;
                font-size:.82rem;
                color:var(--muted);
                margin-top:4px
            }
            .cash-steps{
                list-style:none;
                padding:0;
                margin-bottom:18px
            }
            .cash-steps li{
                display:flex;
                align-items:flex-start;
                gap:10px;
                padding:8px 0;
                border-bottom:1px solid var(--border);
                font-size:.84rem;
                color:var(--text)
            }
            .cash-steps li:last-child{
                border-bottom:none
            }
            .step-num{
                width:22px;
                height:22px;
                border-radius:50%;
                background:var(--primary);
                color:#fff;
                font-size:.7rem;
                font-weight:700;
                display:flex;
                align-items:center;
                justify-content:center;
                flex-shrink:0;
                margin-top:1px
            }
            .modal-footer{
                padding:16px 24px;
                border-top:1px solid var(--border);
                display:flex;
                gap:9px
            }
            .btn-confirm-cash{
                flex:1;
                padding:11px;
                background:var(--success);
                color:#fff;
                border:none;
                border-radius:10px;
                font-size:.875rem;
                font-weight:700;
                cursor:pointer;
                transition:.15s
            }
            .btn-confirm-cash:hover{
                background:#059669
            }
            .btn-modal-cancel{
                padding:11px 16px;
                background:var(--bg);
                color:var(--muted);
                border:1.5px solid var(--border);
                border-radius:10px;
                font-size:.875rem;
                font-weight:600;
                cursor:pointer;
                transition:.15s
            }
            .btn-modal-cancel:hover{
                background:#f1f5f9
            }
            .sb-badge{
                background:#ef4444;
                color:#fff;
                font-size:.62rem;
                font-weight:700;
                padding:1px 6px;
                border-radius:10px;
                margin-left:auto
            }
        </style>
    </head><body>
        <aside class="sb">
            <div class="sb-brand"><div class="sb-logo"><i class="fas fa-bolt"></i></div><div><div class="sb-name">DRSMS System</div><div class="sb-sub">Customer</div></div></div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/customerDashboard"       class="sb-item"><i class="fas fa-home"></i> Home</a>
                <div class="sb-lbl">Services</div>
                <a href="<%=ctx%>/customerServiceRequests" class="sb-item"><i class="fas fa-clipboard-list"></i> Repair Requests</a>
                <a href="<%=ctx%>/customerContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/customerEquipment"       class="sb-item"><i class="fas fa-desktop"></i> My Equipment</a>
                <div class="sb-lbl">Shop</div>
                <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item"><i class="fas fa-puzzle-piece"></i> Parts</a>
                <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Equipment</a>
                <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item"><i class="fas fa-shopping-cart"></i> Cart<%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%></a>
                <div class="sb-lbl">Finance</div>
                <a href="<%=ctx%>/customerInvoices"        class="sb-item on"><i class="fas fa-receipt"></i> Invoices</a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/customerChat"            class="sb-item"><i class="fas fa-comment-dots"></i> Support Chat</a>
            </nav>
            <div class="sb-foot">
                <div class="sb-user"><div class="sb-ava"><%=me.getFullName().substring(0,1).toUpperCase()%></div><div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer</div></div></div>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </aside>

        <main class="main">
            <div class="breadcrumb">
                <a href="<%=ctx%>/customerDashboard"><i class="fas fa-home"></i></a>
                <span class="breadcrumb-sep">›</span>
                <a href="<%=ctx%>/customerInvoices">Invoices</a>
                <span class="breadcrumb-sep">›</span>
                <span><%=inv.getInvoiceCode()%></span>
            </div>
            <a href="<%=ctx%>/customerInvoices" class="btn-back"><i class="fas fa-arrow-left"></i> Back</a>

            <%-- Notification toasts --%>
            <%if("cash".equals(paySuccess)){%>
            <div class="success-toast"><i class="fas fa-check-circle" style="font-size:1.2rem"></i>
                <div><strong>Cash payment successful!</strong> Invoice <%=inv.getInvoiceCode()%> has been recorded.</div>
            </div>
            <%}else if("vnpay".equals(paySuccess)){%>
            <div class="success-toast"><i class="fas fa-check-circle" style="font-size:1.2rem"></i>
                <div><strong>VNPay payment successful!</strong> Invoice <%=inv.getInvoiceCode()%> has been paid.</div>
            </div>
            <%}else if("invalid".equals(errorMsg)||"session_expired".equals(errorMsg)){%>
            <div class="error-toast"><i class="fas fa-exclamation-triangle"></i>
                <div>An error occurred during payment. Please try again.</div>
            </div>
            <%}%>

            <%if(overdue&&!"PAID".equals(inv.getStatus())){%>
            <div class="overdue-box"><i class="fas fa-exclamation-triangle"></i>
                <div>This invoice is <strong>overdue</strong> (<%=inv.getDueDate()%>). Please make payment as soon as possible.</div>
            </div>
            <%}else if("PAID".equals(inv.getStatus())){%>
            <div class="paid-box"><i class="fas fa-check-circle" style="font-size:1.1rem"></i>
                <div>This invoice has been <strong>fully paid</strong>. Thank you!</div>
            </div>
            <%}%>

            <div class="grid-inv">
                <div>
                    <!-- Invoice header -->
                    <div class="inv-header">
                        <div>
                            <div class="inv-title"><i class="fas fa-receipt"></i> INVOICE</div>
                            <div class="inv-code"><%=inv.getInvoiceCode()%></div>
                            <div class="inv-date">Created: <%=inv.getCreatedAt()!=null?inv.getCreatedAt().toLocalDate():"—"%></div>
                        </div>
                        <div class="inv-company">
                            <strong>DRSMS System</strong><br>
                            Technical & Maintenance Services<br>
                            In charge: <%=inv.getCreatedByName()%>
                        </div>
                    </div>

                    <!-- Items -->
                    <div class="card">
                        <div class="card-hd"><div class="card-hd-icon"><i class="fas fa-list"></i></div><div class="card-hd-title">Service Details</div></div>
                                <%if(items.isEmpty()){%>
                        <div class="card-body" style="color:var(--muted);text-align:center;padding:24px">No service details available</div>
                        <%}else{%>
                        <table>
                            <thead><tr><th>#</th><th>Description</th><th>Type</th><th>Qty</th><th>Unit Price</th><th>Total</th></tr></thead>
                            <tbody>
                                <%for(int i=0;i<items.size();i++){InvoiceItem it=items.get(i);
                                  String itBg="#e0e7ff";String itCl="#3730a3";
                                  if("PART".equals(it.getItemType())){itBg="#dbeafe";itCl="#1e40af";}
                                  else if("SERVICE".equals(it.getItemType())){itBg="#d1fae5";itCl="#065f46";}
                                  else if("EQUIPMENT".equals(it.getItemType())){itBg="#fef9c3";itCl="#854d0e";}
                                %>
                                <tr>
                                    <td style="color:var(--muted);font-size:.8rem"><%=i+1%></td>
                                    <td style="font-weight:500"><%=it.getItemName()%></td>
                                    <td><span class="item-type" style="background:<%=itBg%>;color:<%=itCl%>"><%=it.getItemType()%></span></td>
                                    <td><%=it.getQuantity()%></td>
                                    <td><%=it.getUnitPrice()!=null?nf.format(it.getUnitPrice()):"0"%> ₫</td>
                                    <td><strong><%=it.getTotalPrice()!=null?nf.format(it.getTotalPrice()):"0"%> ₫</strong></td>
                                </tr>
                                <%}%>
                            </tbody>
                        </table>
                        <%}%>
                        <div style="padding:16px 20px;border-top:1px solid var(--border)">
                            <div style="max-width:280px;margin-left:auto">
                                <div class="sum-row"><span class="lbl">Subtotal</span><span><%=inv.getSubtotal()!=null?nf.format(inv.getSubtotal()):"0"%> ₫</span></div>
                                <div class="sum-row"><span class="lbl">VAT Tax (<%=inv.getTaxPercent()!=null?inv.getTaxPercent().intValue():0%>%)</span><span><%=inv.getTaxAmount()!=null?nf.format(inv.getTaxAmount()):"0"%> ₫</span></div>
                                <div class="sum-row total"><span class="lbl">Total</span><span><%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫</span></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right panel -->
                <div>
                    <div class="card">
                        <div class="card-hd"><div class="card-hd-icon"><i class="fas fa-info"></i></div><div class="card-hd-title">Invoice Information</div></div>
                        <div class="card-body">
                            <div class="info-grid" style="margin-bottom:14px">
                                <div class="info-item"><div class="lbl">Invoice Code</div><div class="val" style="font-family:monospace;font-weight:700;color:var(--primary)"><%=inv.getInvoiceCode()%></div></div>
                                <div class="info-item"><div class="lbl">Status</div><div class="val"><span class="b <%=isc%>"><%=inv.getStatusLabel()%></span></div></div>
                                <div class="info-item"><div class="lbl">Type</div><div class="val"><%=inv.getInvoiceTypeLabel()%></div></div>
                                <div class="info-item"><div class="lbl">Created</div><div class="val"><%=inv.getCreatedAt()!=null?inv.getCreatedAt().toLocalDate():"—"%></div></div>
                                    <%if(inv.getDueDate()!=null){%>
                                <div class="info-item"><div class="lbl">Due Date</div>
                                    <div class="val" style="<%=overdue?"color:var(--danger);font-weight:700":""%>"><%=inv.getDueDate()%><%=overdue?" ⚠️":""%></div>
                                </div>
                                <%}%>
                                <%if(inv.getRequestCode()!=null){%>
                                <div class="info-item"><div class="lbl">Repair Request</div>
                                    <div class="val"><a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=inv.getServiceRequestId()%>" style="color:var(--primary);font-family:monospace;font-weight:600"><%=inv.getRequestCode()%></a></div>
                                </div>
                                <%}%>
                            </div>

                            <div style="background:#f8fafc;border-radius:9px;padding:13px;margin-bottom:12px">
                                <div style="font-size:.75rem;color:var(--muted);font-weight:600;margin-bottom:8px">TOTAL AMOUNT DUE</div>
                                <div style="font-size:1.8rem;font-weight:800;color:<%="UNPAID".equals(inv.getStatus())?"var(--danger)":"var(--success)"%>">
                                    <%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫
                                </div>
                                <div style="font-size:.77rem;color:var(--muted);margin-top:4px">
                                    <%if("PAID".equals(inv.getStatus())){%><i class="fas fa-check-circle" style="color:var(--success)"></i> Fully paid
                                    <%}else if("UNPAID".equals(inv.getStatus())){%><i class="fas fa-clock" style="color:var(--warning)"></i> Awaiting payment
                                    <%}else{%><i class="fas fa-ban" style="color:var(--muted)"></i> Invoice cancelled<%}%>
                                </div>
                            </div>

                            <%-- Payment buttons - only shown when UNPAID --%>
                            <%if("UNPAID".equals(inv.getStatus())){%>
                            <div class="pay-section">
                                <div class="pay-title"><i class="fas fa-credit-card"></i> Select payment method</div>
                                <div class="pay-btns">
                                    <button class="btn-pay-cash" onclick="openCashModal()">
                                        <i class="fas fa-money-bill-wave"></i> Pay with Cash
                                    </button>
                                    <form method="post" action="<%=ctx%>/customerPayment" id="vnpayForm">
                                        <input type="hidden" name="action" value="vnpay_simulate">
                                        <input type="hidden" name="invoiceId" value="<%=inv.getId()%>">
                                        <button type="submit" class="btn-pay-vnpay" style="width:100%">
                                            <i class="fas fa-qrcode"></i> Pay via VNPay
                                        </button>
                                    </form>
                                </div>
                            </div>
                            <%}%>
                        </div>
                    </div>

                    <%if(inv.getNotes()!=null&&!inv.getNotes().isEmpty()){%>
                    <div class="card">
                        <div class="card-hd"><div class="card-hd-icon" style="background:var(--warning)"><i class="fas fa-sticky-note"></i></div><div class="card-hd-title">Notes</div></div>
                        <div class="card-body" style="font-size:.855rem;color:var(--text);line-height:1.7"><%=inv.getNotes()%></div>
                    </div>
                    <%}%>
                </div>
            </div>
        </main>

        <!-- Cash Payment Modal -->
        <div class="modal-overlay" id="cashModal">
            <div class="modal">
                <div class="modal-header">
                    <div class="modal-title"><i class="fas fa-money-bill-wave" style="color:var(--success)"></i> Cash Payment</div>
                    <button class="modal-close" onclick="closeCashModal()"><i class="fas fa-times"></i></button>
                </div>
                <div class="modal-body">
                    <div class="cash-amount-display">
                        <div class="cash-lbl">Amount to pay</div>
                        <div class="cash-amount"><%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫</div>
                        <div class="cash-code">Invoice code: <%=inv.getInvoiceCode()%></div>
                    </div>
                    <ul class="cash-steps">
                        <li><span class="step-num">1</span><span>Prepare the exact amount of <strong><%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫</strong></span></li>
                        <li><span class="step-num">2</span><span>Visit the DRSMS System office in person or hand it to the on-site technician</span></li>
                        <li><span class="step-num">3</span><span>The staff will confirm and issue a payment receipt for you</span></li>
                        <li><span class="step-num">4</span><span>Click <strong>"Confirm Payment"</strong> to record it in the system</span></li>
                    </ul>
                </div>
                <div class="modal-footer">
                    <button class="btn-modal-cancel" onclick="closeCashModal()">Cancel</button>
                    <form method="post" action="<%=ctx%>/customerPayment" style="flex:1">
                        <input type="hidden" name="action" value="cash">
                        <input type="hidden" name="invoiceId" value="<%=inv.getId()%>">
                        <button type="submit" class="btn-confirm-cash" style="width:100%">
                            <i class="fas fa-check"></i> Confirm Payment
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <script>
            function openCashModal() {
                document.getElementById('cashModal').classList.add('show');
            }
            function closeCashModal() {
                document.getElementById('cashModal').classList.remove('show');
            }
            document.getElementById('cashModal').addEventListener('click', function (e) {
                if (e.target === this)
                    closeCashModal();
            });

            // Auto-hide toast after 5s
            document.addEventListener('DOMContentLoaded', () => {
                const toast = document.querySelector('.success-toast');
                if (toast)
                    setTimeout(() => {
                        toast.style.transition = 'opacity .5s';
                        toast.style.opacity = '0';
                        setTimeout(() => toast.remove(), 500);
                    }, 5000);
            });
        </script>
    </body></html>
