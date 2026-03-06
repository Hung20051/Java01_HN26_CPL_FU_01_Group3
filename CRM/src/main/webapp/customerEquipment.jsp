<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<CustomerEquipment> equipmentList=(List<CustomerEquipment>)request.getAttribute("equipmentList");
    if(equipmentList==null)equipmentList=new ArrayList<>();
    String ctx=request.getContextPath();
     int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    long totalEq=equipmentList.size();
    long internalEq=equipmentList.stream().filter(e->"INTERNAL".equals(e.getSource())).count();
    long externalEq=equipmentList.stream().filter(e->"EXTERNAL".equals(e.getSource())).count();
    long underWarranty=equipmentList.stream().filter(CustomerEquipment::isUnderWarranty).count();
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>My Equipment - DRSMS</title>
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
                grid-template-columns:repeat(4,1fr);
                gap:12px;
                margin-bottom:20px
            }
            .sm{
                background:var(--surface);
                border-radius:11px;
                padding:14px 16px;
                border:1px solid var(--border);
                display:flex;
                align-items:center;
                gap:10px
            }
            .sm-icon{
                width:38px;
                height:38px;
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.95rem;
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
            /* Equipment grid */
            .eq-grid{
                display:grid;
                grid-template-columns:repeat(auto-fill,minmax(280px,1fr));
                gap:15px
            }
            .eq-card{
                background:var(--surface);
                border-radius:13px;
                border:1.5px solid var(--border);
                padding:20px;
                transition:.15s;
                position:relative;
                overflow:hidden
            }
            .eq-card:hover{
                transform:translateY(-2px);
                box-shadow:0 8px 24px rgba(0,0,0,.07);
                border-color:var(--primary)
            }
            .eq-card-top{
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                margin-bottom:14px
            }
            .eq-icon-wrap{
                width:46px;
                height:46px;
                border-radius:12px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.25rem
            }
            .eq-tags{
                display:flex;
                flex-direction:column;
                align-items:flex-end;
                gap:4px
            }
            .tag{
                padding:2px 8px;
                border-radius:4px;
                font-size:.69rem;
                font-weight:700
            }
            .tag-int{
                background:#e0e7ff;
                color:#3730a3
            }
            .tag-ext{
                background:#fef9c3;
                color:#854d0e
            }
            .tag-wok{
                background:#d1fae5;
                color:#065f46
            }
            .tag-wexp{
                background:#fee2e2;
                color:#991b1b
            }
            .eq-model{
                font-size:.95rem;
                font-weight:700;
                color:var(--text);
                margin-bottom:4px;
                line-height:1.3
            }
            .eq-cat{
                font-size:.76rem;
                color:var(--primary);
                font-weight:600;
                margin-bottom:10px
            }
            .eq-details{
                display:flex;
                flex-direction:column;
                gap:5px
            }
            .eq-detail-row{
                display:flex;
                align-items:center;
                gap:6px;
                font-size:.8rem;
                color:var(--muted)
            }
            .eq-detail-row i{
                width:13px;
                font-size:.75rem;
                flex-shrink:0
            }
            .eq-serial{
                font-family:monospace;
                color:var(--text);
                font-size:.82rem
            }
            .eq-card-foot{
                margin-top:14px;
                padding-top:12px;
                border-top:1px solid #f1f5f9;
                display:flex;
                gap:7px
            }
            .btn-fix{
                display:inline-flex;
                align-items:center;
                gap:5px;
                padding:6px 12px;
                border-radius:7px;
                background:var(--primary);
                color:#fff;
                text-decoration:none;
                font-size:.78rem;
                font-weight:600;
                transition:.15s;
                flex:1;
                justify-content:center
            }
            .btn-fix:hover{
                background:#4338ca
            }
            .btn-fix-gray{
                background:#f1f5f9;
                color:var(--muted);
                font-size:.78rem;
                font-weight:600;
                padding:6px 12px;
                border-radius:7px;
                border:none;
                cursor:not-allowed;
                display:flex;
                align-items:center;
                gap:5px;
                flex:1;
                justify-content:center
            }
            .empty{
                text-align:center;
                padding:52px;
                color:var(--muted);
                font-size:.85rem;
                background:var(--surface);
                border-radius:13px;
                border:1px solid var(--border)
            }
            .empty i{
                font-size:2.5rem;
                display:block;
                margin-bottom:12px;
                opacity:.3
            }
            .info-bar{
                background:#eff6ff;
                border:1px solid #bfdbfe;
                border-radius:10px;
                padding:12px 16px;
                font-size:.845rem;
                color:#1d4ed8;
                margin-bottom:18px;
                display:flex;
                align-items:center;
                gap:9px
            }
            /* Decorative line */
            .eq-card::before{
                content:'';
                position:absolute;
                left:0;
                top:0;
                bottom:0;
                width:4px;
                background:var(--primary);
                opacity:0;
                transition:.15s
            }
            .eq-card:hover::before{
                opacity:1
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
                <a href="<%=ctx%>/customerEquipment"       class="sb-item on"><i class="fas fa-desktop"></i> My Equipment</a>
                <div class="sb-lbl">Shop</div>
                <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item"><i class="fas fa-puzzle-piece"></i> Parts</a>
                <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Equipment</a>
                <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item"><i class="fas fa-shopping-cart"></i> Cart<%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%></a>
                <div class="sb-lbl">Finance</div>
                <a href="<%=ctx%>/customerInvoices"        class="sb-item"><i class="fas fa-receipt"></i> Invoices</a>
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
                <h1><i class="fas fa-desktop"></i> My Equipment</h1>
                <p>List of equipment you currently own — both purchased within the system and from outside</p>
            </div>

            <div class="info-bar">
                <i class="fas fa-info-circle"></i>
                <span>To add equipment to your profile, please contact a support agent via
                    <a href="<%=ctx%>/customerChat" style="color:var(--primary);font-weight:700">Support Chat</a></span>
            </div>

            <div class="stats">
                <div class="sm"><div class="sm-icon" style="background:#e0e7ff;color:var(--primary)"><i class="fas fa-desktop"></i></div><div><div class="sm-val"><%=totalEq%></div><div class="sm-lbl">Total Equipment</div></div></div>
                <div class="sm"><div class="sm-icon" style="background:#dbeafe;color:var(--info)"><i class="fas fa-database"></i></div><div><div class="sm-val"><%=internalEq%></div><div class="sm-lbl">Purchased In-System</div></div></div>
                <div class="sm"><div class="sm-icon" style="background:#fef9c3;color:#854d0e"><i class="fas fa-store"></i></div><div><div class="sm-val"><%=externalEq%></div><div class="sm-lbl">Purchased Externally</div></div></div>
                <div class="sm"><div class="sm-icon" style="background:#d1fae5;color:var(--success)"><i class="fas fa-shield-alt"></i></div><div><div class="sm-val"><%=underWarranty%></div><div class="sm-lbl">Under Warranty</div></div></div>
            </div>

            <%if(equipmentList.isEmpty()){%>
            <div class="empty">
                <i class="fas fa-desktop"></i>
                You have no equipment in your profile yet.<br>
                <a href="<%=ctx%>/customerChat" style="color:var(--primary);font-weight:600;display:inline-block;margin-top:8px">Contact support to add equipment →</a>
            </div>
            <%}else{%>
            <div class="eq-grid">
                <%for(CustomerEquipment eq:equipmentList){
                  boolean isInternal="INTERNAL".equals(eq.getSource());
                  boolean underW=eq.isUnderWarranty();
                  String iconColor=isInternal?"#e0e7ff":"#fef9c3";
                  String iconTxtColor=isInternal?"#3730a3":"#854d0e";
                %>
                <div class="eq-card">
                    <div class="eq-card-top">
                        <div class="eq-icon-wrap" style="background:<%=iconColor%>;color:<%=iconTxtColor%>">
                            <i class="fas fa-desktop"></i>
                        </div>
                        <div class="eq-tags">
                            <span class="tag <%=isInternal?"tag-int":"tag-ext"%>"><%=isInternal?"In-System":"External"%></span>
                            <%if(eq.getWarrantyExpires()!=null){%>
                            <span class="tag <%=underW?"tag-wok":"tag-wexp"%>"><%=underW?"In Warranty":"Expired"%></span>
                            <%}%>
                        </div>
                    </div>
                    <div class="eq-model"><%=eq.getDisplayName()%></div>
                    <%if(eq.getCategoryName()!=null){%>
                    <div class="eq-cat"><i class="fas fa-tag" style="font-size:.7rem"></i> <%=eq.getCategoryName()%></div>
                    <%}%>
                    <div class="eq-details">
                        <div class="eq-detail-row"><i class="fas fa-barcode"></i><span class="eq-serial"><%=eq.getDisplaySerial()%></span></div>
                                <%if(eq.getPurchasedDate()!=null){%>
                        <div class="eq-detail-row"><i class="fas fa-shopping-cart"></i><span>Purchased: <%=eq.getPurchasedDate()%></span></div>
                                <%}%>
                                <%if(eq.getWarrantyExpires()!=null){%>
                        <div class="eq-detail-row">
                            <i class="fas fa-shield-alt" style="color:<%=underW?"var(--success)":"var(--danger)"%>"></i>
                            <span style="color:<%=underW?"var(--success)":"var(--danger)"%>;font-weight:<%=underW?"500":"600"%>">
                                Warranty <%=underW?"until":"expired on"%>: <%=eq.getWarrantyExpires()%>
                            </span>
                        </div>
                        <%}%>
                        <%if(eq.getNotes()!=null&&!eq.getNotes().isEmpty()){%>
                        <div class="eq-detail-row"><i class="fas fa-sticky-note"></i><span style="color:var(--muted)"><%=eq.getNotes()%></span></div>
                                <%}%>
                    </div>
                    <div class="eq-card-foot">
                        <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-fix">
                            <i class="fas fa-tools"></i> Create Repair Request
                        </a>
                        <a href="<%=ctx%>/customerContracts" class="btn-fix" style="background:#f1f5f9;color:var(--muted);flex:0">
                            <i class="fas fa-file-contract"></i>
                        </a>
                    </div>
                </div>
                <%}%>
            </div>
            <%}%>
        </main>
    </body></html>
