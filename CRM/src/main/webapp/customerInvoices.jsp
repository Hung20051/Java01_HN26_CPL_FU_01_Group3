<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*,java.math.BigDecimal" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<Invoice> invoices=(List<Invoice>)request.getAttribute("invoices"); if(invoices==null)invoices=new ArrayList<>();
    Map<String,Object> sum=(Map<String,Object>)request.getAttribute("summary"); if(sum==null)sum=new HashMap<>();
    String filterStatus=(String)request.getAttribute("filterStatus"); if(filterStatus==null)filterStatus="";
    String ctx=request.getContextPath();
    int cartCount   = session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int pendingSR   = request.getAttribute("pendingSR")  !=null?(int)request.getAttribute("pendingSR")  :0;
    int unreadChat  = request.getAttribute("unreadChat") !=null?(int)request.getAttribute("unreadChat") :0;
    int total  =(Integer)nvl(sum.get("total"),0);
    int unpaid =(Integer)nvl(sum.get("unpaid"),0);
    int paid   =(Integer)nvl(sum.get("paid"),0);
    BigDecimal unpaidAmt=(BigDecimal)sum.get("unpaidAmt");
    java.text.NumberFormat nf=java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
    String initials = me.getFullName()!=null&&!me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%><%! Object nvl(Object v,Object d){return v!=null?v:d;} %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Invoices - DRSMS</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                /* Sidebar (dark indigo) */
                --sb-bg:        #1e1b4b;
                --sb-border:    rgba(255,255,255,0.08);
                --sb-text:      rgba(255,255,255,0.45);
                --sb-accent:    #818cf8;
                --sb-accent-2:  #a5b4fc;
                --sb-item-on:   rgba(129,140,248,0.2);
                --sb-width:     252px;

                /* Content (light) */
                --bg:           #f3f4f9;
                --bg-card:      #ffffff;
                --bg-topbar:    #ffffff;
                --border-light: #e8ecf5;
                --border-light2:#f0f2fb;
                --text-h:       #1e1b4b;
                --text-b:       #374151;
                --text-m:       #6b7280;
                --text-s:       #9ca3af;

                /* Brand */
                --primary:      #4f46e5;
                --primary-2:    #6366f1;
                --primary-light:#ede9fe;

                /* Status colors */
                --purple:  #7c3aed;
                --blue:    #2563eb;
                --teal:    #0d9488;
                --green:   #16a34a;
                --red:     #dc2626;
                --amber:   #d97706;
                --orange:  #ea580c;
                --info:    #0284c7;
            }

            *,*::before,*::after{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            html{
                scroll-behavior:smooth
            }
            body{
                font-family:'Sora',sans-serif;
                background:var(--bg);
                color:var(--text-b);
                min-height:100vh;
                display:flex;
            }
            ::-webkit-scrollbar{
                width:4px
            }
            ::-webkit-scrollbar-track{
                background:transparent
            }
            ::-webkit-scrollbar-thumb{
                background:rgba(79,70,229,0.3);
                border-radius:4px
            }

            /* ═══════════ SIDEBAR ═══════════ */
            .sb{
                width:var(--sb-width);
                min-height:100vh;
                background:var(--sb-bg);
                border-right:1px solid rgba(79,70,229,0.2);
                display:flex;
                flex-direction:column;
                position:fixed;
                top:0;
                left:0;
                z-index:100;
                box-shadow:4px 0 24px rgba(0,0,0,0.15);
            }
            .sb-brand{
                padding:20px 16px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid var(--sb-border);
            }
            .sb-logo{
                width:36px;
                height:36px;
                background:linear-gradient(135deg,#818cf8,#a78bfa);
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem;
                box-shadow:0 4px 12px rgba(129,140,248,0.4);
                flex-shrink:0;
            }
            .sb-name{
                color:#fff;
                font-size:1.05rem;
                font-weight:800;
                letter-spacing:-.3px
            }
            .sb-role{
                display:inline-flex;
                align-items:center;
                background:rgba(129,140,248,0.2);
                border:1px solid rgba(129,140,248,0.3);
                color:var(--sb-accent-2);
                font-size:.6rem;
                font-weight:700;
                letter-spacing:1px;
                text-transform:uppercase;
                padding:2px 8px;
                border-radius:20px;
                margin-top:3px;
            }
            .sb-nav{
                flex:1;
                padding:12px 10px;
                overflow-y:auto
            }
            .sb-lbl{
                color:rgba(255,255,255,0.22);
                font-size:.6rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.6px;
                padding:0 8px;
                margin:14px 0 5px;
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:9px;
                padding:8px 10px;
                border-radius:9px;
                margin-bottom:1px;
                color:var(--sb-text);
                text-decoration:none;
                font-size:.81rem;
                font-weight:500;
                transition:all .18s;
                border-left:2px solid transparent;
            }
            .sb-item i{
                width:28px;
                height:28px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.78rem;
                border-radius:8px;
                background:rgba(255,255,255,0.06);
                flex-shrink:0;
                transition:all .18s;
            }
            .sb-item.on{
                color:#fff;
                background:var(--sb-item-on);
                border-left-color:var(--sb-accent);
            }
            .sb-item.on i{
                background:rgba(129,140,248,0.3);
                color:var(--sb-accent-2)
            }
            .sb-item:hover:not(.on){
                color:rgba(255,255,255,0.78);
                background:rgba(255,255,255,0.06);
            }
            .sb-badge{
                margin-left:auto;
                background:#ef4444;
                color:#fff;
                font-size:.6rem;
                font-weight:700;
                padding:2px 7px;
                border-radius:20px;
                box-shadow:0 2px 6px rgba(239,68,68,0.5);
            }
            .sb-foot{
                padding:12px 10px 14px;
                border-top:1px solid var(--sb-border)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:10px;
                background:rgba(255,255,255,0.07);
                border:1px solid rgba(255,255,255,0.1);
                margin-bottom:5px;
                text-decoration:none;
                transition:all .18s;
            }
            .sb-user:hover{
                background:rgba(129,140,248,0.18);
                border-color:rgba(129,140,248,0.3)
            }
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:linear-gradient(135deg,#818cf8,#a78bfa);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                font-weight:700;
                flex-shrink:0;
                overflow:hidden;
            }
            .sb-ava img{
                width:34px;
                height:34px;
                object-fit:cover;
                border-radius:50%
            }
            .sb-uname{
                color:#fff;
                font-size:.8rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,0.35);
                font-size:.66rem;
                margin-top:1px
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:8px 10px;
                border-radius:9px;
                color:rgba(255,255,255,0.3);
                text-decoration:none;
                font-size:.78rem;
                transition:all .18s;
            }
            .sb-logout:hover{
                color:#fca5a5;
                background:rgba(239,68,68,0.1)
            }

            /* ═══════════ MAIN (light) ═══════════ */
            .main{
                margin-left:var(--sb-width);
                flex:1;
                min-height:100vh;
                display:flex;
                flex-direction:column
            }

            .topbar{
                display:flex;
                align-items:center;
                padding:18px 28px;
                background:var(--bg-topbar);
                border-bottom:1px solid var(--border-light);
                position:sticky;
                top:0;
                z-index:50;
                box-shadow:0 1px 6px rgba(0,0,0,0.06);
            }
            .topbar-title{
                font-size:1.2rem;
                font-weight:800;
                color:var(--text-h);
                letter-spacing:-.3px
            }
            .topbar-sub{
                color:var(--text-s);
                font-size:.78rem;
                margin-top:2px
            }

            .content{
                padding:24px 28px;
                flex:1
            }

            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(16px)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }

            /* ── ALERT WARN ── */
            .alert-warn{
                display:flex;
                align-items:flex-start;
                gap:12px;
                padding:12px 18px;
                background:#fffbeb;
                border:1.5px solid #fcd34d;
                border-radius:13px;
                margin-bottom:20px;
                font-size:.82rem;
                color:#78350f;
                animation:cardIn .4s ease both;
            }
            .alert-warn a{
                color:var(--amber);
                font-weight:700;
                text-decoration:none
            }
            .alert-warn a:hover{
                color:#92400e
            }
            .alert-warn strong{
                color:var(--text-h)
            }

            /* ── STAT CARDS ── */
            .stats{
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:14px;
                margin-bottom:20px;
            }
            .sm{
                border-radius:16px;
                padding:20px;
                position:relative;
                overflow:hidden;
                color:#fff;
                transition:all .22s;
                animation:cardIn .45s ease both;
                display:flex;
                align-items:center;
                gap:14px;
            }
            .sm:nth-child(1){
                animation-delay:.05s
            }
            .sm:nth-child(2){
                animation-delay:.10s
            }
            .sm:nth-child(3){
                animation-delay:.15s
            }
            .sm:hover{
                transform:translateY(-3px);
                box-shadow:0 12px 32px rgba(0,0,0,0.18)
            }

            .sm-blue {
                background:var(--info);
                box-shadow:0 4px 20px rgba(2,132,199,0.3)
            }
            .sm-amber{
                background:var(--amber);
                box-shadow:0 4px 20px rgba(217,119,6,0.3)
            }
            .sm-green{
                background:var(--green);
                box-shadow:0 4px 20px rgba(22,163,74,0.3)
            }

            /* decorative circles */
            .sm::after{
                content:'';
                position:absolute;
                width:100px;
                height:100px;
                border-radius:50%;
                background:rgba(255,255,255,0.12);
                top:-28px;
                right:-28px;
            }
            .sm::before{
                content:'';
                position:absolute;
                width:60px;
                height:60px;
                border-radius:50%;
                background:rgba(255,255,255,0.07);
                bottom:-14px;
                right:28px;
            }

            .sm-icon{
                width:42px;
                height:42px;
                border-radius:12px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1rem;
                flex-shrink:0;
                background:rgba(255,255,255,0.2);
                position:relative;
                z-index:1;
            }
            .sm-val{
                font-size:1.9rem;
                font-weight:800;
                line-height:1;
                letter-spacing:-1px;
                position:relative;
                z-index:1
            }
            .sm-lbl{
                font-size:.74rem;
                font-weight:600;
                opacity:.88;
                margin-top:4px;
                position:relative;
                z-index:1
            }

            /* ── FILTER ROW ── */
            .filter-row{
                display:flex;
                gap:8px;
                margin-bottom:16px;
                flex-wrap:wrap;
            }
            .f-btn{
                padding:7px 16px;
                border-radius:20px;
                font-size:.79rem;
                font-weight:600;
                border:1.5px solid var(--border-light);
                background:#fff;
                color:var(--text-m);
                cursor:pointer;
                text-decoration:none;
                transition:all .2s;
                font-family:'Sora',sans-serif;
            }
            .f-btn:hover{
                background:var(--primary-light);
                border-color:rgba(99,102,241,0.3);
                color:var(--primary-2)
            }
            .f-btn.on{
                background:var(--primary);
                border-color:transparent;
                color:#fff;
                box-shadow:0 3px 10px rgba(79,70,229,0.28);
            }

            /* ── TABLE CARD ── */
            .tbl-card{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                animation:cardIn .5s .1s ease both;
            }
            table{
                width:100%;
                border-collapse:collapse;
                font-size:.81rem
            }
            thead tr{
                background:#fafbff
            }
            th{
                padding:10px 14px;
                text-align:left;
                color:var(--text-s);
                font-weight:700;
                font-size:.67rem;
                text-transform:uppercase;
                letter-spacing:.8px;
                border-bottom:1px solid var(--border-light2);
            }
            td{
                padding:12px 14px;
                border-bottom:1px solid var(--border-light2);
                vertical-align:middle;
                color:var(--text-b);
            }
            tr:last-child td{
                border-bottom:none
            }
            tbody tr{
                transition:background .12s
            }
            tbody tr:hover td{
                background:#f7f8ff
            }

            /* Invoice code link */
            .inv-code{
                color:var(--primary-2);
                font-weight:700;
                font-family:monospace;
                font-size:.79rem;
                text-decoration:none;
            }
            .inv-code:hover{
                color:var(--primary);
                text-decoration:underline
            }

            /* Type badge */
            .type-badge{
                padding:3px 9px;
                border-radius:7px;
                font-size:.72rem;
                font-weight:700;
                display:inline-flex;
                align-items:center;
                gap:4px;
            }
            .type-repair{
                background:var(--primary-light);
                color:var(--purple)
            }
            .type-shop  {
                background:#fef3c7;
                color:#92400e
            }

            /* Status badges */
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700
            }
            .b-unpaid   {
                background:#fef3c7;
                color:#92400e
            }
            .b-paid     {
                background:#d1fae5;
                color:#065f46
            }
            .b-cancelled{
                background:#f3f4f6;
                color:#6b7280
            }

            .amount{
                font-weight:700;
                font-size:.87rem
            }
            .amount-unpaid{
                color:var(--red)
            }
            .amount-paid  {
                color:var(--text-m)
            }

            .due-overdue{
                color:var(--red);
                font-weight:700
            }

            .ref-link{
                color:var(--primary-2);
                font-family:monospace;
                font-weight:600;
                font-size:.77rem;
                text-decoration:none;
            }
            .ref-link:hover{
                color:var(--primary);
                text-decoration:underline
            }

            .btn-view{
                padding:5px 13px;
                border-radius:8px;
                font-size:.75rem;
                font-weight:600;
                background:var(--primary-light);
                color:var(--primary-2);
                text-decoration:none;
                display:inline-flex;
                align-items:center;
                gap:5px;
                border:1px solid rgba(99,102,241,0.2);
                transition:all .2s;
            }
            .btn-view:hover{
                background:var(--primary);
                color:#fff;
                border-color:transparent
            }

            /* Empty */
            .empty{
                text-align:center;
                padding:52px 24px;
                color:var(--text-s);
                font-size:.83rem
            }
            .empty i{
                font-size:2.4rem;
                display:block;
                margin-bottom:12px;
                opacity:.2;
                color:var(--text-m)
            }
        </style>
    </head>
    <body>

        <%-- ═══════════ SIDEBAR ═══════════ --%>
        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-bolt"></i></div>
                <div>
                    <div class="sb-name">DRSMS</div>
                    <div class="sb-role">Customer</div>
                </div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/customerDashboard" class="sb-item">
                    <i class="fas fa-home"></i> Dashboard
                </a>
                <div class="sb-lbl">Services</div>
                <a href="<%=ctx%>/customerServiceRequests" class="sb-item">
                    <i class="fas fa-clipboard-list"></i> Repair Requests
                    <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
                </a>
                <a href="<%=ctx%>/customerContracts" class="sb-item">
                    <i class="fas fa-file-contract"></i> Contracts
                </a>
                <a href="<%=ctx%>/customerEquipment" class="sb-item">
                    <i class="fas fa-desktop"></i> My Equipment
                </a>
                <div class="sb-lbl">Shop</div>
                <a href="<%=ctx%>/customerShop?action=parts" class="sb-item">
                    <i class="fas fa-puzzle-piece"></i> Parts
                </a>
                <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item">
                    <i class="fas fa-server"></i> Equipment
                </a>
                <a href="<%=ctx%>/customerShop?action=cart" class="sb-item">
                    <i class="fas fa-shopping-cart"></i> Cart
                    <%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%>
                </a>
                <div class="sb-lbl">Finance</div>
                <a href="<%=ctx%>/customerInvoices" class="sb-item on">
                    <i class="fas fa-receipt"></i> Invoices
                    <%if(unpaid>0){%><span class="sb-badge"><%=unpaid%></span><%}%>
                </a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/customerChat" class="sb-item">
                    <i class="fas fa-comment-dots"></i> Support Chat
                    <%if(unreadChat>0){%><span class="sb-badge"><%=unreadChat%></span><%}%>
                </a>
            </nav>
            <div class="sb-foot">
                <a href="<%=ctx%>/profile" class="sb-user">
                    <div class="sb-ava">
                        <%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%>
                        <img src="<%=ctx%><%=me.getAvatarUrl()%>" alt="avatar">
                        <%}else{%><%=initials%><%}%>
                    </div>
                    <div>
                        <div class="sb-uname"><%=me.getFullName()%></div>
                        <div class="sb-urole">Customer Account</div>
                    </div>
                </a>
                <a href="<%=ctx%>/logout" class="sb-logout">
                    <i class="fas fa-sign-out-alt"></i> Sign Out
                </a>
            </div>
        </aside>

        <%-- ═══════════ MAIN ═══════════ --%>
        <main class="main">

            <div class="topbar">
                <div>
                    <div class="topbar-title">
                        <i class="fas fa-receipt" style="color:var(--green);margin-right:8px;font-size:1rem"></i>
                        Invoices
                    </div>
                    <div class="topbar-sub">Payment history and unpaid invoices</div>
                </div>
            </div>

            <div class="content">

                <%if(unpaid>0&&unpaidAmt!=null&&unpaidAmt.compareTo(BigDecimal.ZERO)>0){%>
                <div class="alert-warn">
                    <i class="fas fa-exclamation-triangle" style="font-size:1rem;flex-shrink:0;margin-top:1px"></i>
                    <div>You have <strong><%=unpaid%> unpaid invoice(s)</strong> totalling
                        <strong><%=nf.format(unpaidAmt)%> ₫</strong>.
                        Please contact <a href="<%=ctx%>/customerChat">a support agent</a> for payment assistance.
                    </div>
                </div>
                <%}%>

                <%-- Stat cards --%>
                <div class="stats">
                    <div class="sm sm-blue">
                        <div class="sm-icon"><i class="fas fa-file-invoice"></i></div>
                        <div><div class="sm-val"><%=total%></div><div class="sm-lbl">Total Invoices</div></div>
                    </div>
                    <div class="sm sm-amber">
                        <div class="sm-icon"><i class="fas fa-clock"></i></div>
                        <div><div class="sm-val"><%=unpaid%></div><div class="sm-lbl">Unpaid</div></div>
                    </div>
                    <div class="sm sm-green">
                        <div class="sm-icon"><i class="fas fa-check-circle"></i></div>
                        <div><div class="sm-val"><%=paid%></div><div class="sm-lbl">Paid</div></div>
                    </div>
                </div>

                <%-- Filter row --%>
                <div class="filter-row">
                    <a href="<%=ctx%>/customerInvoices"                  class="f-btn <%=filterStatus.isEmpty()?"on":""%>">All</a>
                    <a href="<%=ctx%>/customerInvoices?status=UNPAID"    class="f-btn <%="UNPAID".equals(filterStatus)?"on":""%>">Unpaid</a>
                    <a href="<%=ctx%>/customerInvoices?status=PAID"      class="f-btn <%="PAID".equals(filterStatus)?"on":""%>">Paid</a>
                    <a href="<%=ctx%>/customerInvoices?status=CANCELLED" class="f-btn <%="CANCELLED".equals(filterStatus)?"on":""%>">Cancelled</a>
                </div>

                <%-- Table --%>
                <div class="tbl-card">
                    <%if(invoices.isEmpty()){%>
                    <div class="empty"><i class="fas fa-receipt"></i>No invoices found.</div>
                    <%}else{%>
                    <table>
                        <thead>
                            <tr>
                                <th>Invoice #</th>
                                <th>Type</th>
                                <th>Reference</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Due Date</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%for(Invoice inv:invoices){
                                String isc="b-unpaid";
                                if("PAID".equals(inv.getStatus()))           isc="b-paid";
                                else if("CANCELLED".equals(inv.getStatus())) isc="b-cancelled";
                                boolean overdue="UNPAID".equals(inv.getStatus())
                                    &&inv.getDueDate()!=null
                                    &&inv.getDueDate().isBefore(java.time.LocalDate.now());
                                boolean isRepair="REPAIR".equals(inv.getInvoiceType());
                            %>
                            <tr>
                                <td>
                                    <a href="<%=ctx%>/customerInvoices?action=detail&id=<%=inv.getId()%>"
                                       class="inv-code"><%=inv.getInvoiceCode()%></a>
                                </td>
                                <td>
                                    <span class="type-badge <%=isRepair?"type-repair":"type-shop"%>">
                                        <i class="fas fa-<%=isRepair?"tools":"shopping-bag"%>"></i>
                                        <%=inv.getInvoiceTypeLabel()%>
                                    </span>
                                </td>
                                <td>
                                    <%if(inv.getRequestCode()!=null){%>
                                    <a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=inv.getServiceRequestId()%>"
                                       class="ref-link"><%=inv.getRequestCode()%></a>
                                    <%}else{%>
                                    <span style="color:var(--text-s)">—</span>
                                    <%}%>
                                </td>
                                <td>
                                    <span class="amount <%="UNPAID".equals(inv.getStatus())?"amount-unpaid":"amount-paid"%>">
                                        <%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫
                                    </span>
                                </td>
                                <td><span class="b <%=isc%>"><%=inv.getStatusLabel()%></span></td>
                                <td style="font-size:.77rem;color:var(--text-s)">
                                    <%=inv.getCreatedAt()!=null?inv.getCreatedAt().toLocalDate():"—"%>
                                </td>
                                <td style="font-size:.77rem" class="<%=overdue?"due-overdue":""%>">
                                    <%=inv.getDueDate()!=null?inv.getDueDate()+(overdue?" ⚠️":""):"—"%>
                                </td>
                                <td>
                                    <a href="<%=ctx%>/customerInvoices?action=detail&id=<%=inv.getId()%>"
                                       class="btn-view"><i class="fas fa-eye"></i> Details</a>
                                </td>
                            </tr>
                            <%}%>
                        </tbody>
                    </table>
                    <%}%>
                </div>

            </div>
        </main>
        <%@ include file="customerAIBubble.jsp" %>
    </body>
</html>
