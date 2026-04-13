<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<Contract> contracts=(List<Contract>)request.getAttribute("contracts"); if(contracts==null)contracts=new ArrayList<>();
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int pendingSR = request.getAttribute("pendingSR")!=null?(Integer)request.getAttribute("pendingSR"):0;
    int unpaidInv = request.getAttribute("unpaidInv")!=null?(Integer)request.getAttribute("unpaidInv"):0;
    int unreadChat = request.getAttribute("unreadChat")!=null?(Integer)request.getAttribute("unreadChat"):0;
    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Create Repair Request - DRSMS</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                /* Sidebar (dark indigo) */
                --sb-bg:        #1e1b4b;
                --sb-bg-2:      #17144a;
                --sb-border:    rgba(255,255,255,0.08);
                --sb-text:      rgba(255,255,255,0.45);
                --sb-text-on:   #ffffff;
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

            /* ═══════════ SIDEBAR (dark) ═══════════ */
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

            /* Topbar */
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

            /* Breadcrumb */
            .breadcrumb{
                display:flex;
                align-items:center;
                gap:7px;
                font-size:.76rem;
                color:var(--text-s);
            }
            .breadcrumb a{
                color:var(--text-s);
                text-decoration:none;
                transition:color .18s
            }
            .breadcrumb a:hover{
                color:var(--primary-2)
            }
            .breadcrumb-sep{
                color:var(--border-light)
            }
            .breadcrumb span:last-child{
                color:var(--text-m);
                font-weight:500
            }

            /* Content */
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

            /* ── FORM CARD ── */
            .form-card{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                max-width:820px;
                animation:cardIn .45s ease both;
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

            .form-hd{
                padding:18px 22px;
                border-bottom:1px solid var(--border-light2);
                background:#fafbff;
                display:flex;
                align-items:center;
                gap:9px;
            }
            .form-hd h2{
                font-size:.95rem;
                font-weight:700;
                color:var(--text-h);
                display:flex;
                align-items:center;
                gap:9px;
            }
            .form-hd h2 i{
                color:var(--primary-2);
                font-size:.88rem
            }
            .form-hd p{
                color:var(--text-m);
                font-size:.8rem;
                margin-top:4px;
                font-weight:400
            }

            .form-body{
                padding:22px 24px
            }

            /* Section title inside form */
            .sec-title{
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.8px;
                color:var(--primary-2);
                margin-bottom:13px;
                padding-bottom:8px;
                border-bottom:1px solid var(--border-light2);
            }

            .fg{
                margin-bottom:14px
            }

            .lbl{
                display:block;
                font-size:.78rem;
                font-weight:600;
                color:var(--text-b);
                margin-bottom:6px;
            }
            .lbl span{
                color:var(--red);
                margin-left:3px
            }

            .fc{
                width:100%;
                padding:10px 13px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:10px;
                font-family:'Sora',sans-serif;
                font-size:.84rem;
                color:var(--text-b);
                outline:none;
                transition:all .2s;
            }
            .fc::placeholder{
                color:var(--text-s)
            }
            .fc:focus{
                border-color:rgba(79,70,229,0.45);
                background:#faf9ff;
                box-shadow:0 0 0 3px rgba(79,70,229,0.08);
            }
            .fc option{
                background:#fff;
                color:var(--text-b)
            }
            textarea.fc{
                resize:vertical;
                min-height:88px
            }

            .row-2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:14px
            }

            /* Contract info box */
            .contract-info{
                display:none;
                background:#eff6ff;
                border:1px solid #bfdbfe;
                border-radius:10px;
                padding:10px 14px;
                font-size:.79rem;
                color:#1d4ed8;
                margin-top:8px;
            }
            .contract-info i{
                margin-right:6px
            }

            /* Equipment wrap */
            .eq-wrap{
                border:1.5px solid var(--border-light);
                border-radius:12px;
                overflow:hidden;
                min-height:52px;
                background:#fafbff;
            }
            .eq-empty,.eq-loading{
                padding:18px;
                text-align:center;
                color:var(--text-s);
                font-size:.81rem;
            }
            .eq-loading{
                display:none
            }

            .eq-item{
                display:flex;
                align-items:flex-start;
                gap:11px;
                padding:13px 16px;
                border-bottom:1px solid var(--border-light2);
                transition:background .12s;
            }
            .eq-item:last-child{
                border-bottom:none
            }
            .eq-item:hover{
                background:#f7f8ff
            }

            .eq-item input[type=checkbox]{
                width:16px;
                height:16px;
                margin-top:2px;
                accent-color:var(--primary);
                cursor:pointer;
                flex-shrink:0;
            }
            .eq-item-name{
                font-size:.84rem;
                font-weight:600;
                color:var(--text-h)
            }
            .eq-item-serial{
                font-size:.71rem;
                font-family:'Courier New',monospace;
                color:var(--text-s);
                margin-top:2px
            }

            .eq-item-desc{
                margin-top:8px;
                display:none
            }
            .eq-item-desc textarea{
                width:100%;
                padding:8px 11px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:8px;
                font-family:'Sora',sans-serif;
                font-size:.79rem;
                color:var(--text-b);
                resize:none;
                height:58px;
                outline:none;
                transition:border-color .2s;
            }
            .eq-item-desc textarea::placeholder{
                color:var(--text-s)
            }
            .eq-item-desc textarea:focus{
                border-color:rgba(79,70,229,0.4)
            }

            .hint-selected{
                margin-top:8px;
                font-size:.77rem;
                font-weight:600;
                color:var(--green);
                display:none;
            }

            /* Source badge */
            .src-badge{
                display:inline-flex;
                align-items:center;
                padding:1px 6px;
                border-radius:4px;
                font-size:.67rem;
                font-weight:700;
                margin-left:6px;
            }
            .src-external{
                background:#fef3c7;
                color:#92400e
            }
            .src-internal{
                background:var(--primary-light);
                color:var(--primary)
            }

            /* Priority grid */
            .prio-grid{
                display:grid;
                grid-template-columns:repeat(4,1fr);
                gap:10px;
            }
            .prio-card{
                border:1.5px solid var(--border-light);
                border-radius:12px;
                padding:14px 10px;
                cursor:pointer;
                text-align:center;
                transition:all .2s;
                background:#fff;
            }
            .prio-card:hover{
                border-color:rgba(79,70,229,0.3);
                background:var(--primary-light)
            }
            .prio-card.sel{
                border-color:var(--pc);
                background:var(--pb)
            }
            .prio-card input{
                display:none
            }
            .prio-card-ico{
                font-size:1.3rem;
                margin-bottom:5px
            }
            .prio-card-lbl{
                font-size:.74rem;
                font-weight:700;
                color:var(--text-m)
            }
            .prio-card.sel .prio-card-lbl{
                color:var(--pc)
            }

            .p-low {
                --pc:#16a34a;
                --pb:#dcfce7
            }
            .p-med {
                --pc:#d97706;
                --pb:#fef3c7
            }
            .p-high{
                --pc:#ea580c;
                --pb:#ffedd5
            }
            .p-urg {
                --pc:#dc2626;
                --pb:#fee2e2
            }

            /* Form footer */
            .form-ft{
                padding:16px 22px;
                border-top:1px solid var(--border-light2);
                display:flex;
                gap:10px;
                background:#fafbff;
            }

            .btn-sub{
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:10px 22px;
                background:var(--primary);
                color:#fff;
                border:none;
                cursor:pointer;
                font-family:'Sora',sans-serif;
                font-size:.82rem;
                font-weight:700;
                border-radius:11px;
                box-shadow:0 4px 14px rgba(79,70,229,0.35);
                transition:all .22s;
            }
            .btn-sub:hover{
                background:#4338ca;
                transform:translateY(-1px);
                box-shadow:0 8px 22px rgba(79,70,229,0.45);
            }

            .btn-back{
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:10px 20px;
                background:#fff;
                border:1.5px solid var(--border-light);
                color:var(--text-m);
                font-family:'Sora',sans-serif;
                font-size:.82rem;
                font-weight:600;
                border-radius:11px;
                text-decoration:none;
                transition:all .2s;
            }
            .btn-back:hover{
                background:#f3f4f6;
                border-color:#d1d5db;
                color:var(--text-b)
            }

            /* No contracts alert */
            .alert-warn{
                display:flex;
                align-items:center;
                gap:12px;
                padding:12px 18px;
                background:#fffbeb;
                border:1.5px solid #fcd34d;
                border-radius:12px;
                font-size:.82rem;
                color:#78350f;
                max-width:820px;
                animation:cardIn .45s ease both;
            }
            .alert-warn i{
                color:#f59e0b;
                font-size:1rem;
                flex-shrink:0
            }
            .alert-warn a{
                color:#d97706;
                font-weight:700;
                text-decoration:none;
                margin-left:4px
            }
            .alert-warn a:hover{
                color:#92400e
            }

            /* Section spacing */
            .sec-block{
                margin-bottom:24px
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
                <a href="<%=ctx%>/customerServiceRequests" class="sb-item on">
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
                        <i class="fas fa-plus-circle" style="color:var(--primary-2);margin-right:8px;font-size:1rem"></i>
                        Create Repair Request
                    </div>
                    <div class="topbar-sub">
                        <span class="breadcrumb">
                            <a href="<%=ctx%>/customerDashboard"><i class="fas fa-home"></i> Dashboard</a>
                            <span class="breadcrumb-sep">›</span>
                            <a href="<%=ctx%>/customerServiceRequests">Repair Requests</a>
                            <span class="breadcrumb-sep">›</span>
                            <span>Create New</span>
                        </span>
                    </div>
                </div>
            </div>

            <div class="content">

                <%if(contracts.isEmpty()){%>
                <div class="alert-warn">
                    <i class="fas fa-triangle-exclamation"></i>
                    <div>
                        You have <strong>no active service contracts.</strong>
                        Please <a href="<%=ctx%>/customerChat">contact a support agent</a> to create a contract before submitting a repair request.
                    </div>
                </div>
                <%}else{%>

                <div class="form-card">
                    <div class="form-hd">
                        <div>
                            <h2><i class="fas fa-plus-circle"></i> Create New Repair Request</h2>
                            <p>Select a contract and equipment to repair, then describe the issue to send to the technical team.</p>
                        </div>
                    </div>

                    <form method="post" action="<%=ctx%>/customerServiceRequests" onsubmit="return validate()">
                        <input type="hidden" name="action" value="create">

                        <div class="form-body">

                            <%-- Step 1 --%>
                            <div class="sec-block">
                                <div class="sec-title">1 · Select Contract</div>
                                <div class="fg">
                                    <label class="lbl">Your Contract <span>*</span></label>
                                    <select class="fc" name="contractId" id="contractSel" onchange="loadEquipment(this)" required>
                                        <option value="">— Select a contract —</option>
                                        <%for(Contract c:contracts){%>
                                        <option value="<%=c.getId()%>" data-type="<%=c.getContractType()%>">
                                            <%=c.getContractCode()%> — <%=c.getContractTypeLabel()%>
                                            (<%=c.getEquipmentCount()%> equipment · Expires: <%=c.getEndDate()%>)
                                        </option>
                                        <%}%>
                                    </select>
                                </div>
                                <div class="contract-info" id="contractInfo"></div>
                            </div>

                            <%-- Step 2 --%>
                            <div class="sec-block">
                                <div class="sec-title">2 · Select Equipment to Repair</div>
                                <div class="eq-wrap" id="eqWrap">
                                    <div class="eq-empty" id="eqEmpty">← Select a contract to view equipment list</div>
                                    <div class="eq-loading" id="eqLoad"><i class="fas fa-spinner fa-spin"></i> Loading...</div>
                                </div>
                                <div class="hint-selected" id="hintSelected"></div>
                            </div>

                            <%-- Step 3 --%>
                            <div class="sec-block">
                                <div class="sec-title">3 · Describe the General Issue</div>
                                <div class="fg">
                                    <label class="lbl">Request Title <span>*</span></label>
                                    <input type="text" class="fc" name="title" required minlength="10" maxlength="200"
                                           placeholder="E.g.: Pump making loud noise, air conditioner not reaching temperature...">
                                </div>
                                <div class="fg">
                                    <label class="lbl">Detailed Description <span>*</span></label>
                                    <textarea class="fc" name="description" required minlength="20"
                                              placeholder="Describe the condition in detail, when it occurred, specific symptoms..."></textarea>
                                </div>
                            </div>

                            <%-- Step 4 --%>
                            <div class="sec-block" style="margin-bottom:0">
                                <div class="sec-title">4 · Priority Level</div>
                                <div class="prio-grid">
                                    <label class="prio-card p-low" onclick="selPrio(this)">
                                        <input type="radio" name="priority" value="LOW">
                                        <div class="prio-card-ico">🟢</div>
                                        <div class="prio-card-lbl">Low</div>
                                    </label>
                                    <label class="prio-card p-med sel" onclick="selPrio(this)">
                                        <input type="radio" name="priority" value="MEDIUM" checked>
                                        <div class="prio-card-ico">🟡</div>
                                        <div class="prio-card-lbl">Medium</div>
                                    </label>
                                    <label class="prio-card p-high" onclick="selPrio(this)">
                                        <input type="radio" name="priority" value="HIGH">
                                        <div class="prio-card-ico">🟠</div>
                                        <div class="prio-card-lbl">High</div>
                                    </label>
                                    <label class="prio-card p-urg" onclick="selPrio(this)">
                                        <input type="radio" name="priority" value="URGENT">
                                        <div class="prio-card-ico">🔴</div>
                                        <div class="prio-card-lbl">Urgent</div>
                                    </label>
                                </div>
                            </div>

                        </div>

                        <div class="form-ft">
                            <button type="submit" class="btn-sub">
                                <i class="fas fa-paper-plane"></i> Submit Request
                            </button>
                            <a href="<%=ctx%>/customerServiceRequests" class="btn-back">
                                <i class="fas fa-arrow-left"></i> Back
                            </a>
                        </div>
                    </form>
                </div>

                <%}%>
            </div>
        </main>

        <script>
            const CTX = '<%=ctx%>';

            function selPrio(el) {
                document.querySelectorAll('.prio-card').forEach(c => c.classList.remove('sel'));
                el.classList.add('sel');
                el.querySelector('input').checked = true;
            }

            function loadEquipment(sel) {
                const cid = sel.value;
                const wrap = document.getElementById('eqWrap');
                const empty = document.getElementById('eqEmpty');
                const load = document.getElementById('eqLoad');
                const info = document.getElementById('contractInfo');
                const hint = document.getElementById('hintSelected');

                wrap.querySelectorAll('.eq-item').forEach(e => e.remove());
                hint.style.display = 'none';
                info.style.display = 'none';

                if (!cid) {
                    empty.style.display = 'block';
                    load.style.display = 'none';
                    return;
                }

                const opt = sel.options[sel.selectedIndex];
                const type = opt.dataset.type;
                info.style.display = 'block';
                info.innerHTML = '<i class="fas fa-info-circle"></i> <strong>'
                        + (type === 'WARRANTY' ? 'Warranty' : 'Maintenance')
                        + '</strong> contract — '
                        + (type === 'WARRANTY'
                                ? 'Repairs are free within the warranty period.'
                                : 'Repair costs will be charged based on actual work.');

                empty.style.display = 'none';
                load.style.display = 'block';

                fetch(CTX + '/customerServiceRequests?action=getEquipment&contractId=' + cid)
                        .then(r => r.json())
                        .then(data => {
                            load.style.display = 'none';
                            if (data.length === 0) {
                                empty.textContent = 'This contract has no equipment.';
                                empty.style.display = 'block';
                                return;
                            }
                            data.forEach(eq => {
                                const isExt = eq.source === 'EXTERNAL';
                                const div = document.createElement('div');
                                div.className = 'eq-item';
                                div.innerHTML =
                                        '<input type="checkbox" name="equipmentIds[]" value="' + eq.id + '" id="eq' + eq.id + '"'
                                        + ' onchange="toggleDesc(this,' + eq.id + ')">'
                                        + '<div class="eq-item-info" style="flex:1">'
                                        + '<label for="eq' + eq.id + '" style="cursor:pointer">'
                                        + '<div class="eq-item-name">' + eq.name + '</div>'
                                        + '<div class="eq-item-serial">'
                                        + '<i class="fas fa-barcode" style="font-size:.65rem;margin-right:4px"></i>' + eq.serial
                                        + '<span class="src-badge ' + (isExt ? 'src-external' : 'src-internal') + '">'
                                        + (isExt ? 'External' : 'In-System') + '</span>'
                                        + '</div>'
                                        + '</label>'
                                        + '<div class="eq-item-desc" id="desc-wrap-' + eq.id + '">'
                                        + '<textarea name="issueDescs[]" placeholder="Describe the specific issue for this equipment (optional)..." id="desc-' + eq.id + '"></textarea>'
                                        + '</div>'
                                        + '</div>';
                                wrap.appendChild(div);
                            });
                            updateHint();
                            wrap.querySelectorAll('input[type=checkbox]').forEach(cb => cb.addEventListener('change', updateHint));
                        })
                        .catch(() => {
                            load.style.display = 'none';
                            empty.textContent = 'Error loading equipment list.';
                            empty.style.display = 'block';
                        });
            }

            function toggleDesc(cb, id) {
                const dw = document.getElementById('desc-wrap-' + id);
                if (dw)
                    dw.style.display = cb.checked ? 'block' : 'none';
                updateHint();
            }

            function updateHint() {
                const checked = document.querySelectorAll('input[name="equipmentIds[]"]:checked').length;
                const h = document.getElementById('hintSelected');
                h.style.display = checked > 0 ? 'block' : 'none';
                if (checked > 0)
                    h.textContent = '✓ ' + checked + ' equipment selected';
            }

            function validate() {
                const cid = document.getElementById('contractSel').value;
                if (!cid) {
                    alert('Please select a contract!');
                    return false;
                }
                const checked = document.querySelectorAll('input[name="equipmentIds[]"]:checked').length;
                if (checked === 0) {
                    alert('Please select at least 1 piece of equipment to repair!');
                    return false;
                }
                return true;
            }
        </script>
        <%@ include file="customerAIBubble.jsp" %>
    </body>
</html>
