<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*,java.math.BigDecimal" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<Invoice> invoices=(List<Invoice>)request.getAttribute("invoices"); if(invoices==null)invoices=new ArrayList<>();
    Map<String,Object> sum=(Map<String,Object>)request.getAttribute("summary"); if(sum==null)sum=new HashMap<>();
    String filterStatus=(String)request.getAttribute("filterStatus"); if(filterStatus==null)filterStatus="";
    String ctx=request.getContextPath();
     int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int total=(Integer)nvl(sum.get("total"),0);
    int unpaid=(Integer)nvl(sum.get("unpaid"),0);
    int paid=(Integer)nvl(sum.get("paid"),0);
    BigDecimal unpaidAmt=(BigDecimal)sum.get("unpaidAmt");
    java.text.NumberFormat nf=java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
%><%! Object nvl(Object v,Object d){return v!=null?v:d;} %>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Invoices - DRSMS</title>
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
            .pg-hd{
                margin-bottom:20px
            }
            .pg-hd h1{
                font-size:1.3rem;
                font-weight:800;
                color:var(--text);
                display:flex;
                align-items:center;
                gap:9px
            }
            .pg-hd h1 i{
                color:var(--primary)
            }
            .pg-hd p{
                color:var(--muted);
                font-size:.85rem;
                margin-top:3px
            }
            .stats{
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:12px;
                margin-bottom:16px
            }
            .sm{
                background:var(--surface);
                border-radius:11px;
                padding:16px;
                border:1px solid var(--border);
                display:flex;
                align-items:center;
                gap:12px
            }
            .sm-icon{
                width:42px;
                height:42px;
                border-radius:11px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1rem;
                flex-shrink:0
            }
            .sm-val{
                font-size:1.55rem;
                font-weight:800;
                color:var(--text);
                line-height:1
            }
            .sm-lbl{
                font-size:.74rem;
                color:var(--muted);
                margin-top:2px
            }
            .filter-row{
                display:flex;
                gap:8px;
                margin-bottom:14px;
                flex-wrap:wrap
            }
            .f-btn{
                padding:7px 15px;
                border-radius:20px;
                font-size:.82rem;
                font-weight:600;
                border:1.5px solid var(--border);
                background:var(--surface);
                color:var(--muted);
                cursor:pointer;
                text-decoration:none;
                transition:.15s;
                font-family:inherit
            }
            .f-btn:hover,.f-btn.on{
                background:var(--primary);
                border-color:var(--primary);
                color:#fff
            }
            .tbl-card{
                background:var(--surface);
                border-radius:13px;
                border:1px solid var(--border);
                overflow:hidden
            }
            table{
                width:100%;
                border-collapse:collapse;
                font-size:.83rem
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
            tr:hover td{
                background:#fafbff
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
            .amount{
                font-weight:700;
                font-size:.9rem
            }
            .due-overdue{
                color:var(--danger);
                font-weight:700
            }
            .btn-view{
                padding:5px 12px;
                border-radius:7px;
                font-size:.78rem;
                font-weight:600;
                background:#e0e7ff;
                color:var(--primary);
                text-decoration:none;
                display:inline-flex;
                align-items:center;
                gap:4px
            }
            .btn-view:hover{
                background:#c7d2fe
            }
            .empty{
                text-align:center;
                padding:48px;
                color:var(--muted);
                font-size:.84rem
            }
            .empty i{
                font-size:2.2rem;
                display:block;
                margin-bottom:10px;
                opacity:.35
            }
            .alert-warn{
                display:flex;
                align-items:center;
                gap:12px;
                padding:13px 16px;
                background:#fff7ed;
                border:1px solid #fed7aa;
                border-radius:11px;
                margin-bottom:16px;
                font-size:.875rem;
                color:#9a3412
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
            <div class="pg-hd">
                <h1><i class="fas fa-receipt"></i> Invoices</h1>
                <p>Payment history and unpaid invoices</p>
            </div>

            <%if(unpaid>0&&unpaidAmt!=null&&unpaidAmt.compareTo(BigDecimal.ZERO)>0){%>
            <div class="alert-warn">
                <i class="fas fa-exclamation-triangle" style="font-size:1.1rem;color:var(--warning)"></i>
                <div>You have <strong><%=unpaid%> unpaid invoice(s)</strong> with a total amount of <strong><%=nf.format(unpaidAmt)%> ₫</strong>.
                    Please contact <a href="<%=ctx%>/customerChat" style="color:var(--primary);font-weight:700">a support agent</a> for payment assistance.</div>
            </div>
            <%}%>

            <div class="stats">
                <div class="sm"><div class="sm-icon" style="background:#e0e7ff;color:var(--primary)"><i class="fas fa-file-invoice"></i></div><div><div class="sm-val"><%=total%></div><div class="sm-lbl">Total Invoices</div></div></div>
                <div class="sm"><div class="sm-icon" style="background:#fef3c7;color:var(--warning)"><i class="fas fa-clock"></i></div><div><div class="sm-val"><%=unpaid%></div><div class="sm-lbl">Unpaid</div></div></div>
                <div class="sm"><div class="sm-icon" style="background:#d1fae5;color:var(--success)"><i class="fas fa-check-circle"></i></div><div><div class="sm-val"><%=paid%></div><div class="sm-lbl">Paid</div></div></div>
            </div>

            <div class="filter-row">
                <a href="<%=ctx%>/customerInvoices" class="f-btn <%=filterStatus.isEmpty()?"on":""%>">All</a>
                <a href="<%=ctx%>/customerInvoices?status=UNPAID"    class="f-btn <%="UNPAID".equals(filterStatus)?"on":""%>">Unpaid</a>
                <a href="<%=ctx%>/customerInvoices?status=PAID"      class="f-btn <%="PAID".equals(filterStatus)?"on":""%>">Paid</a>
                <a href="<%=ctx%>/customerInvoices?status=CANCELLED" class="f-btn <%="CANCELLED".equals(filterStatus)?"on":""%>">Cancelled</a>
            </div>

            <div class="tbl-card">
                <%if(invoices.isEmpty()){%>
                <div class="empty"><i class="fas fa-receipt"></i>No invoices found.</div>
                <%}else{%>
                <table>
                    <thead><tr><th>Invoice #</th><th>Type</th><th>Reference</th><th>Total</th><th>Status</th><th>Created</th><th>Due Date</th><th>Action</th></tr></thead>
                    <tbody>
                        <%for(Invoice inv:invoices){
                          String isc="b-unpaid";
                          if("PAID".equals(inv.getStatus()))isc="b-paid";
                          else if("CANCELLED".equals(inv.getStatus()))isc="b-cancelled";
                          boolean overdue="UNPAID".equals(inv.getStatus())&&inv.getDueDate()!=null&&inv.getDueDate().isBefore(java.time.LocalDate.now());
                        %>
                        <tr>
                            <td><a href="<%=ctx%>/customerInvoices?action=detail&id=<%=inv.getId()%>" style="color:var(--primary);font-weight:700;font-family:monospace;font-size:.8rem"><%=inv.getInvoiceCode()%></a></td>
                            <td>
                                <span style="padding:2px 8px;border-radius:5px;font-size:.75rem;font-weight:600;background:<%="REPAIR".equals(inv.getInvoiceType())?"#e0e7ff":"#fef9c3"%>;color:<%="REPAIR".equals(inv.getInvoiceType())?"#3730a3":"#854d0e"%>">
                                    <i class="fas fa-<%="REPAIR".equals(inv.getInvoiceType())?"tools":"shopping-bag"%>"></i> <%=inv.getInvoiceTypeLabel()%>
                                </span>
                            </td>
                            <td style="font-size:.79rem;color:var(--muted)">
                                <%=inv.getRequestCode()!=null?"<a href='"+ctx+"/customerServiceRequests?action=detail&id="+inv.getServiceRequestId()+"' style='color:var(--primary);font-family:monospace;font-weight:600'>"+inv.getRequestCode()+"</a>":"—"%>
                            </td>
                            <td><span class="amount" style="color:<%="UNPAID".equals(inv.getStatus())?"var(--danger)":"var(--text)"%>"><%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫</span></td>
                            <td><span class="b <%=isc%>"><%=inv.getStatusLabel()%></span></td>
                            <td style="font-size:.79rem;color:var(--muted)"><%=inv.getCreatedAt()!=null?inv.getCreatedAt().toLocalDate():"—"%></td>
                            <td style="font-size:.79rem" class="<%=overdue?"due-overdue":""%>"><%=inv.getDueDate()!=null?inv.getDueDate()+(overdue?" ⚠️":""):"—"%></td>
                            <td><a href="<%=ctx%>/customerInvoices?action=detail&id=<%=inv.getId()%>" class="btn-view"><i class="fas fa-eye"></i> Details</a></td>
                        </tr>
                        <%}%>
                    </tbody>
                </table>
                <%}%>
            </div>
        </main>
    </body></html>
