<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<Contract> contracts=(List<Contract>)request.getAttribute("contracts"); if(contracts==null)contracts=new ArrayList<>();
    long activeCount=(Long)nvl(request.getAttribute("activeCount"),0L);
    long warrantyCount=(Long)nvl(request.getAttribute("warrantyCount"),0L);
    long maintCount=(Long)nvl(request.getAttribute("maintCount"),0L);
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int pendingSR  = request.getAttribute("pendingSR") !=null?(Integer)request.getAttribute("pendingSR"):0;
    int unpaidInv  = request.getAttribute("unpaidInv") !=null?(Integer)request.getAttribute("unpaidInv"):0;
    int unreadChat = request.getAttribute("unreadChat")!=null?(Integer)request.getAttribute("unreadChat"):0;
    String initials = me.getFullName()!=null&&!me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%><%! Object nvl(Object v,Object d){return v!=null?v:d;} %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Contracts - DRSMS</title>
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
                justify-content:space-between;
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

            /* Section label */
            .section-lbl{
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:2px;
                color:var(--primary-2);
                margin-bottom:13px;
                display:flex;
                align-items:center;
                gap:10px;
            }
            .section-lbl::after{
                content:'';
                flex:1;
                height:1px;
                background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)
            }

            /* ── INFO BAR ── */
            .info-bar{
                display:flex;
                align-items:center;
                gap:10px;
                padding:12px 16px;
                background:#eff6ff;
                border:1px solid #bfdbfe;
                border-radius:12px;
                font-size:.81rem;
                color:#1d4ed8;
                margin-bottom:22px;
                animation:cardIn .4s ease both;
            }
            .info-bar i{
                flex-shrink:0
            }
            .info-bar a{
                color:var(--primary-2);
                font-weight:700;
                text-decoration:none
            }
            .info-bar a:hover{
                color:var(--primary)
            }

            /* ── STAT CARDS ── */
            .stats{
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:14px;
                margin-bottom:24px;
            }
            .sc{
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
            .sc:nth-child(1){
                animation-delay:.05s
            }
            .sc:nth-child(2){
                animation-delay:.10s
            }
            .sc:nth-child(3){
                animation-delay:.15s
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
            .sc:hover{
                transform:translateY(-3px);
                box-shadow:0 12px 32px rgba(0,0,0,0.18)
            }

            .sc-purple{
                background:var(--purple);
                box-shadow:0 4px 20px rgba(124,58,237,0.3)
            }
            .sc-green {
                background:var(--green);
                box-shadow:0 4px 20px rgba(22,163,74,0.3)
            }
            .sc-blue  {
                background:var(--blue);
                box-shadow:0 4px 20px rgba(37,99,235,0.3)
            }

            .sc::after{
                content:'';
                position:absolute;
                width:100px;
                height:100px;
                border-radius:50%;
                background:rgba(255,255,255,0.12);
                top:-28px;
                right:-28px;
            }
            .sc::before{
                content:'';
                position:absolute;
                width:60px;
                height:60px;
                border-radius:50%;
                background:rgba(255,255,255,0.07);
                bottom:-14px;
                right:28px;
            }
            .sc-icon{
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
            .sc-val{
                font-size:2rem;
                font-weight:800;
                line-height:1;
                letter-spacing:-1px;
                position:relative;
                z-index:1
            }
            .sc-lbl{
                font-size:.76rem;
                font-weight:600;
                opacity:.88;
                margin-top:4px;
                position:relative;
                z-index:1
            }

            /* ── CONTRACT GRID ── */
            .ct-grid{
                display:grid;
                grid-template-columns:repeat(auto-fill,minmax(330px,1fr));
                gap:16px;
            }
            .ct-card{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                transition:all .22s;
                animation:cardIn .45s ease both;
                display:flex;
                flex-direction:column;
            }
            .ct-card:hover{
                transform:translateY(-3px);
                box-shadow:0 10px 28px rgba(79,70,229,0.12);
                border-color:rgba(99,102,241,0.25);
            }
            .ct-card-top{
                padding:16px 18px;
                border-bottom:1px solid var(--border-light2);
                background:#fafbff;
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
            }
            .ct-code{
                font-family:'Courier New',monospace;
                font-size:.94rem;
                font-weight:700;
                color:var(--text-h);
                letter-spacing:-.3px;
            }
            .ct-type{
                margin-top:7px;
                display:flex;
                align-items:center;
                gap:7px
            }
            .ct-type-badge{
                display:inline-flex;
                align-items:center;
                gap:5px;
                padding:4px 10px;
                border-radius:7px;
                font-size:.73rem;
                font-weight:700;
            }
            .ct-type-warranty{
                background:#d1fae5;
                color:#065f46
            }
            .ct-type-maint   {
                background:#dbeafe;
                color:#1e40af
            }

            /* Status badges */
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700;
                white-space:nowrap;
            }
            .b-active   {
                background:#d1fae5;
                color:#065f46
            }
            .b-expired  {
                background:#fee2e2;
                color:#991b1b
            }
            .b-cancelled{
                background:#f3f4f6;
                color:#6b7280
            }

            .ct-card-body{
                padding:14px 18px;
                font-size:.8rem;
                color:var(--text-m);
                flex:1;
            }
            .ct-row{
                display:flex;
                align-items:flex-start;
                gap:8px;
                margin-bottom:8px;
                line-height:1.4;
            }
            .ct-row:last-child{
                margin-bottom:0
            }
            .ct-row i{
                width:14px;
                font-size:.76rem;
                color:var(--text-s);
                flex-shrink:0;
                margin-top:2px;
            }
            .ct-card-foot{
                padding:12px 18px;
                border-top:1px solid var(--border-light2);
                display:flex;
                justify-content:space-between;
                align-items:center;
                background:#fafbff;
            }
            .ct-eq-count{
                font-size:.76rem;
                color:var(--text-s);
                display:flex;
                align-items:center;
                gap:6px;
            }
            .ct-eq-count i{
                color:var(--primary-2)
            }

            .btn-detail{
                display:inline-flex;
                align-items:center;
                gap:6px;
                padding:7px 16px;
                background:var(--primary);
                color:#fff;
                text-decoration:none;
                font-size:.76rem;
                font-weight:700;
                border-radius:9px;
                box-shadow:0 3px 12px rgba(79,70,229,0.3);
                transition:all .2s;
            }
            .btn-detail:hover{
                background:#4338ca;
                transform:translateY(-1px);
                box-shadow:0 6px 20px rgba(79,70,229,0.45);
            }

            /* ── EMPTY STATE ── */
            .empty{
                text-align:center;
                padding:56px 24px;
                color:var(--text-s);
                font-size:.83rem;
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                animation:cardIn .45s ease both;
            }
            .empty i{
                font-size:2.5rem;
                display:block;
                margin-bottom:14px;
                opacity:.2;
                color:var(--text-m);
            }
            .empty a{
                color:var(--primary-2);
                font-weight:700;
                text-decoration:none;
                display:inline-block;
                margin-top:10px;
            }
            .empty a:hover{
                color:var(--primary)
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
                <a href="<%=ctx%>/customerContracts" class="sb-item on">
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
                <a href="<%=ctx%>/customerInvoices" class="sb-item">
                    <i class="fas fa-receipt"></i> Invoices
                    <%if(unpaidInv>0){%><span class="sb-badge"><%=unpaidInv%></span><%}%>
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

            <%-- Topbar --%>
            <div class="topbar">
                <div>
                    <div class="topbar-title">
                        <i class="fas fa-file-contract" style="color:var(--purple);margin-right:8px;font-size:1rem"></i>
                        Service Contracts
                    </div>
                    <div class="topbar-sub">Your equipment warranty and maintenance contracts</div>
                </div>
            </div>

            <div class="content">

                <%-- Info bar --%>
                <div class="info-bar">
                    <i class="fas fa-info-circle"></i>
                    <span>To create a new contract, please contact a support agent via
                        <a href="<%=ctx%>/customerChat">Support Chat</a>.</span>
                </div>

                <%-- Stats --%>
                <div class="section-lbl">Overview</div>
                <div class="stats">
                    <div class="sc sc-purple">
                        <div class="sc-icon"><i class="fas fa-file-contract"></i></div>
                        <div>
                            <div class="sc-val"><%=contracts.size()%></div>
                            <div class="sc-lbl">Total Contracts</div>
                        </div>
                    </div>
                    <div class="sc sc-green">
                        <div class="sc-icon"><i class="fas fa-shield-alt"></i></div>
                        <div>
                            <div class="sc-val"><%=warrantyCount%></div>
                            <div class="sc-lbl">Warranty Contracts</div>
                        </div>
                    </div>
                    <div class="sc sc-blue">
                        <div class="sc-icon"><i class="fas fa-tools"></i></div>
                        <div>
                            <div class="sc-val"><%=maintCount%></div>
                            <div class="sc-lbl">Maintenance Contracts</div>
                        </div>
                    </div>
                </div>

                <%-- Contract list --%>
                <div class="section-lbl">Contracts</div>

                <%if(contracts.isEmpty()){%>
                <div class="empty">
                    <i class="fas fa-file-contract"></i>
                    You have no contracts yet.
                    <a href="<%=ctx%>/customerChat">Contact a support agent →</a>
                </div>
                <%}else{%>
                <div class="ct-grid">
                    <%for(Contract c:contracts){
                        String sc2="b-active";
                        if("EXPIRED".equals(c.getStatus()))    sc2="b-expired";
                        else if("CANCELLED".equals(c.getStatus())) sc2="b-cancelled";
                        boolean isW="WARRANTY".equals(c.getContractType());
                    %>
                    <div class="ct-card">
                        <div class="ct-card-top">
                            <div>
                                <div class="ct-code"><%=c.getContractCode()%></div>
                                <div class="ct-type">
                                    <span class="ct-type-badge <%=isW?"ct-type-warranty":"ct-type-maint"%>">
                                        <i class="fas fa-<%=isW?"shield-alt":"tools"%>"></i>
                                        <%=c.getContractTypeLabel()%>
                                    </span>
                                </div>
                            </div>
                            <span class="b <%=sc2%>"><%=c.getStatusLabel()%></span>
                        </div>

                        <div class="ct-card-body">
                            <div class="ct-row">
                                <i class="fas fa-calendar-alt"></i>
                                <span><%=c.getStartDate()%> → <%=c.getEndDate()%></span>
                            </div>
                            <div class="ct-row">
                                <i class="fas fa-user-tie"></i>
                                <span>Created by: <%=c.getCreatedByName()%></span>
                            </div>
                            <%if(c.getNotes()!=null&&!c.getNotes().isEmpty()){%>
                            <div class="ct-row">
                                <i class="fas fa-sticky-note"></i>
                                <span><%=c.getNotes()%></span>
                            </div>
                            <%}%>
                        </div>

                        <div class="ct-card-foot">
                            <div class="ct-eq-count">
                                <i class="fas fa-desktop"></i>
                                <%=c.getEquipmentCount()%> equipment · <%=c.getServiceRequestCount()%> requests
                            </div>
                            <a href="<%=ctx%>/customerContracts?action=detail&id=<%=c.getId()%>" class="btn-detail">
                                Details <i class="fas fa-arrow-right" style="font-size:.7rem"></i>
                            </a>
                        </div>
                    </div>
                    <%}%>
                </div>
                <%}%>

            </div>
        </main>
        <%@ include file="customerAIBubble.jsp" %>
    </body>
</html>
