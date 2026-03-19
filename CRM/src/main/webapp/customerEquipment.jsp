<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<CustomerEquipment> equipmentList=(List<CustomerEquipment>)request.getAttribute("equipmentList");
    if(equipmentList==null)equipmentList=new ArrayList<>();
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int pendingSR  = request.getAttribute("pendingSR") !=null?(Integer)request.getAttribute("pendingSR"):0;
    int unpaidInv  = request.getAttribute("unpaidInv") !=null?(Integer)request.getAttribute("unpaidInv"):0;
    int unreadChat = request.getAttribute("unreadChat")!=null?(Integer)request.getAttribute("unreadChat"):0;
    long totalEq      = equipmentList.size();
    long internalEq   = equipmentList.stream().filter(e->"INTERNAL".equals(e.getSource())).count();
    long externalEq   = equipmentList.stream().filter(e->"EXTERNAL".equals(e.getSource())).count();
    long underWarranty= equipmentList.stream().filter(CustomerEquipment::isUnderWarranty).count();
    String initials = me.getFullName()!=null&&!me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>My Equipment - DRSMS</title>
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

        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{scroll-behavior:smooth}
        body{
            font-family:'Sora',sans-serif;
            background:var(--bg);
            color:var(--text-b);
            min-height:100vh;
            display:flex;
        }
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-track{background:transparent}
        ::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px}

        /* ═══════════ SIDEBAR ═══════════ */
        .sb{
            width:var(--sb-width);
            min-height:100vh;
            background:var(--sb-bg);
            border-right:1px solid rgba(79,70,229,0.2);
            display:flex; flex-direction:column;
            position:fixed; top:0; left:0; z-index:100;
            box-shadow:4px 0 24px rgba(0,0,0,0.15);
        }
        .sb-brand{
            padding:20px 16px 16px;
            display:flex; align-items:center; gap:10px;
            border-bottom:1px solid var(--sb-border);
        }
        .sb-logo{
            width:36px; height:36px;
            background:linear-gradient(135deg,#818cf8,#a78bfa);
            border-radius:10px;
            display:flex; align-items:center; justify-content:center;
            color:#fff; font-size:.9rem;
            box-shadow:0 4px 12px rgba(129,140,248,0.4);
            flex-shrink:0;
        }
        .sb-name{color:#fff; font-size:1.05rem; font-weight:800; letter-spacing:-.3px}
        .sb-role{
            display:inline-flex; align-items:center;
            background:rgba(129,140,248,0.2);
            border:1px solid rgba(129,140,248,0.3);
            color:var(--sb-accent-2);
            font-size:.6rem; font-weight:700;
            letter-spacing:1px; text-transform:uppercase;
            padding:2px 8px; border-radius:20px; margin-top:3px;
        }
        .sb-nav{flex:1; padding:12px 10px; overflow-y:auto}
        .sb-lbl{
            color:rgba(255,255,255,0.22);
            font-size:.6rem; font-weight:700;
            text-transform:uppercase; letter-spacing:1.6px;
            padding:0 8px; margin:14px 0 5px;
        }
        .sb-item{
            display:flex; align-items:center; gap:9px;
            padding:8px 10px; border-radius:9px;
            margin-bottom:1px;
            color:var(--sb-text);
            text-decoration:none;
            font-size:.81rem; font-weight:500;
            transition:all .18s;
            border-left:2px solid transparent;
        }
        .sb-item i{
            width:28px; height:28px;
            display:flex; align-items:center; justify-content:center;
            font-size:.78rem; border-radius:8px;
            background:rgba(255,255,255,0.06);
            flex-shrink:0; transition:all .18s;
        }
        .sb-item.on{
            color:#fff;
            background:var(--sb-item-on);
            border-left-color:var(--sb-accent);
        }
        .sb-item.on i{background:rgba(129,140,248,0.3); color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){
            color:rgba(255,255,255,0.78);
            background:rgba(255,255,255,0.06);
        }
        .sb-badge{
            margin-left:auto;
            background:#ef4444;
            color:#fff; font-size:.6rem; font-weight:700;
            padding:2px 7px; border-radius:20px;
            box-shadow:0 2px 6px rgba(239,68,68,0.5);
        }
        .sb-foot{padding:12px 10px 14px; border-top:1px solid var(--sb-border)}
        .sb-user{
            display:flex; align-items:center; gap:9px;
            padding:9px 10px; border-radius:10px;
            background:rgba(255,255,255,0.07);
            border:1px solid rgba(255,255,255,0.1);
            margin-bottom:5px; text-decoration:none; transition:all .18s;
        }
        .sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3)}
        .sb-ava{
            width:34px; height:34px; border-radius:50%;
            background:linear-gradient(135deg,#818cf8,#a78bfa);
            display:flex; align-items:center; justify-content:center;
            color:#fff; font-size:.88rem; font-weight:700;
            flex-shrink:0; overflow:hidden;
        }
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff; font-size:.8rem; font-weight:600}
        .sb-urole{color:rgba(255,255,255,0.35); font-size:.66rem; margin-top:1px}
        .sb-logout{
            display:flex; align-items:center; gap:8px;
            width:100%; padding:8px 10px; border-radius:9px;
            color:rgba(255,255,255,0.3); text-decoration:none;
            font-size:.78rem; transition:all .18s;
        }
        .sb-logout:hover{color:#fca5a5; background:rgba(239,68,68,0.1)}

        /* ═══════════ MAIN (light) ═══════════ */
        .main{margin-left:var(--sb-width);flex:1;min-height:100vh;display:flex;flex-direction:column}

        .topbar{
            display:flex; justify-content:space-between; align-items:center;
            padding:18px 28px;
            background:var(--bg-topbar);
            border-bottom:1px solid var(--border-light);
            position:sticky; top:0; z-index:50;
            box-shadow:0 1px 6px rgba(0,0,0,0.06);
        }
        .topbar-title{font-size:1.2rem; font-weight:800; color:var(--text-h); letter-spacing:-.3px}
        .topbar-sub{color:var(--text-s); font-size:.78rem; margin-top:2px}

        .content{padding:24px 28px; flex:1}

        /* Section label */
        .section-lbl{
            font-size:.63rem; font-weight:700;
            text-transform:uppercase; letter-spacing:2px;
            color:var(--primary-2); margin-bottom:13px;
            display:flex; align-items:center; gap:10px;
        }
        .section-lbl::after{content:'';flex:1;height:1px;background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)}

        /* ── INFO BAR ── */
        .info-bar{
            display:flex; align-items:center; gap:10px;
            padding:12px 16px;
            background:#eff6ff;
            border:1px solid #bfdbfe;
            border-radius:12px;
            font-size:.81rem; color:#1d4ed8;
            margin-bottom:22px;
            animation:cardIn .4s ease both;
        }
        .info-bar i{flex-shrink:0}
        .info-bar a{color:var(--primary-2); font-weight:700; text-decoration:none}
        .info-bar a:hover{color:var(--primary)}

        /* ── STAT CARDS ── */
        .stats{
            display:grid;
            grid-template-columns:repeat(4,1fr);
            gap:14px;
            margin-bottom:24px;
        }
        .sc{
            border-radius:16px; padding:20px;
            position:relative; overflow:hidden;
            color:#fff;
            transition:all .22s;
            animation:cardIn .45s ease both;
            display:flex; align-items:center; gap:14px;
        }
        .sc:nth-child(1){animation-delay:.05s}
        .sc:nth-child(2){animation-delay:.10s}
        .sc:nth-child(3){animation-delay:.15s}
        .sc:nth-child(4){animation-delay:.20s}
        @keyframes cardIn{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}
        .sc:hover{transform:translateY(-3px); box-shadow:0 12px 32px rgba(0,0,0,0.18)}

        .sc-blue  {background:var(--blue);   box-shadow:0 4px 20px rgba(37,99,235,0.3)}
        .sc-info  {background:var(--info);   box-shadow:0 4px 20px rgba(2,132,199,0.3)}
        .sc-amber {background:var(--amber);  box-shadow:0 4px 20px rgba(217,119,6,0.3)}
        .sc-green {background:var(--green);  box-shadow:0 4px 20px rgba(22,163,74,0.3)}

        /* decorative circles */
        .sc::after{
            content:''; position:absolute;
            width:100px; height:100px; border-radius:50%;
            background:rgba(255,255,255,0.12);
            top:-28px; right:-28px;
        }
        .sc::before{
            content:''; position:absolute;
            width:60px; height:60px; border-radius:50%;
            background:rgba(255,255,255,0.07);
            bottom:-14px; right:28px;
        }
        .sc-icon{
            width:42px; height:42px; border-radius:12px;
            display:flex; align-items:center; justify-content:center;
            font-size:1rem; flex-shrink:0;
            background:rgba(255,255,255,0.2);
            position:relative; z-index:1;
        }
        .sc-val{font-size:2rem; font-weight:800; line-height:1; letter-spacing:-1px; position:relative; z-index:1}
        .sc-lbl{font-size:.76rem; font-weight:600; opacity:.88; margin-top:4px; position:relative; z-index:1}

        /* ── EQUIPMENT GRID ── */
        .eq-grid{
            display:grid;
            grid-template-columns:repeat(auto-fill,minmax(290px,1fr));
            gap:16px;
        }
        .eq-card{
    background:var(--bg-card);
    border:1.5px solid var(--border-light);
    border-radius:16px;
    padding:0;                          /* bỏ padding chung */
    box-shadow:0 1px 6px rgba(0,0,0,0.05);
    transition:all .22s;
    position:relative; overflow:hidden;
    animation:cardIn .45s ease both;
    display:flex; flex-direction:column;
}
        .eq-card:hover{
    transform:translateY(-3px);
    box-shadow:0 10px 28px rgba(79,70,229,0.12);
    border-color:rgba(99,102,241,0.3);
}
        /* Left accent bar on hover */
        .eq-card::before{
    content:''; position:absolute;
    left:0; top:0; bottom:0; width:3px;
    background:linear-gradient(180deg,var(--primary),var(--purple));
    opacity:0; transition:opacity .22s;
    border-radius:16px 0 0 16px;
    z-index:2;
}
        .eq-card:hover::before{opacity:1}

        .eq-card-top{
            display:flex; justify-content:space-between; align-items:flex-start;
            margin-bottom:13px;
        }
       .eq-icon-wrap{
    width:56px; height:56px; border-radius:13px;
    display:flex; align-items:center; justify-content:center;
    font-size:1.2rem; flex-shrink:0;
    overflow:hidden;
    padding:5px;
    border:1px solid var(--border-light);
}
.eq-icon-wrap img{
    width:100%; height:100%;
    object-fit:contain;
    border-radius:8px;
}
.eq-icon-int{ background:var(--primary-light); color:var(--primary-2); }
.eq-icon-ext{ background:#fef3c7; color:var(--amber); }
        .eq-icon-int{background:var(--primary-light); color:var(--primary-2)}
        .eq-icon-ext{background:#fef3c7; color:var(--amber)}

        .eq-tags{display:flex; flex-direction:column; align-items:flex-end; gap:5px}
        .tag{
            padding:2px 8px; border-radius:5px;
            font-size:.67rem; font-weight:700;
        }
        .tag-int {background:var(--primary-light); color:var(--primary)}
        .tag-ext {background:#fef3c7;              color:#92400e}
        .tag-wok {background:#d1fae5;              color:#065f46}
        .tag-wexp{background:#fee2e2;              color:#991b1b}

        .eq-model{
            font-size:.92rem; font-weight:700;
            color:var(--text-h); margin-bottom:4px; line-height:1.3;
        }
        .eq-cat{
            font-size:.73rem; color:var(--primary-2);
            font-weight:600; margin-bottom:11px;
            display:flex; align-items:center; gap:4px;
        }
        .eq-details{display:flex; flex-direction:column; gap:6px}
        .eq-detail-row{
            display:flex; align-items:center; gap:7px;
            font-size:.78rem; color:var(--text-m);
        }
        .eq-detail-row i{width:13px; font-size:.73rem; color:var(--text-s); flex-shrink:0}
        .eq-serial{font-family:'Courier New',monospace; color:var(--text-b); font-size:.79rem}

        /* Card footer */
        .eq-card-foot{
            margin-top:14px; padding-top:13px;
            border-top:1px solid var(--border-light2);
            display:flex; gap:8px;
        }
        .btn-fix{
            display:inline-flex; align-items:center; justify-content:center; gap:6px;
            padding:8px 14px; border-radius:9px;
            background:var(--primary);
            color:#fff; text-decoration:none;
            font-size:.77rem; font-weight:700;
            flex:1; transition:all .2s;
            box-shadow:0 3px 12px rgba(79,70,229,0.28);
        }
        .btn-fix:hover{background:#4338ca;transform:translateY(-1px);box-shadow:0 6px 20px rgba(79,70,229,0.42)}

        .btn-fix-icon{
            display:inline-flex; align-items:center; justify-content:center;
            padding:8px 12px; border-radius:9px;
            background:#fff;
            border:1.5px solid var(--border-light);
            color:var(--text-m); text-decoration:none;
            font-size:.82rem; transition:all .2s; flex-shrink:0;
        }
        .btn-fix-icon:hover{background:var(--primary-light);border-color:rgba(99,102,241,0.3);color:var(--primary-2)}

        /* ── EMPTY STATE ── */
        .empty{
            text-align:center; padding:56px 24px;
            color:var(--text-s); font-size:.83rem;
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:16px;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
            animation:cardIn .45s ease both;
        }
        .empty i{font-size:2.5rem; display:block; margin-bottom:14px; opacity:.2; color:var(--text-m)}
        .empty a{
            color:var(--primary-2); font-weight:700;
            text-decoration:none; display:inline-block; margin-top:10px;
        }
        .empty a:hover{color:var(--primary)}
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
            <a href="<%=ctx%>/customerEquipment" class="sb-item on">
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
                    <i class="fas fa-desktop" style="color:var(--info);margin-right:8px;font-size:1rem"></i>
                    My Equipment
                </div>
                <div class="topbar-sub">
                    List of equipment you currently own — both purchased within the system and from outside
                </div>
            </div>
        </div>

        <div class="content">

            <%-- Info bar --%>
            <div class="info-bar">
                <i class="fas fa-info-circle"></i>
                <span>To add equipment to your profile, please contact a support agent via
                    <a href="<%=ctx%>/customerChat">Support Chat</a>.</span>
            </div>

            <%-- Stats --%>
            <div class="section-lbl">Overview</div>
            <div class="stats">
                <div class="sc sc-blue">
                    <div class="sc-icon"><i class="fas fa-desktop"></i></div>
                    <div>
                        <div class="sc-val"><%=totalEq%></div>
                        <div class="sc-lbl">Total Equipment</div>
                    </div>
                </div>
                <div class="sc sc-info">
                    <div class="sc-icon"><i class="fas fa-database"></i></div>
                    <div>
                        <div class="sc-val"><%=internalEq%></div>
                        <div class="sc-lbl">Purchased In-System</div>
                    </div>
                </div>
                <div class="sc sc-amber">
                    <div class="sc-icon"><i class="fas fa-store"></i></div>
                    <div>
                        <div class="sc-val"><%=externalEq%></div>
                        <div class="sc-lbl">Purchased Externally</div>
                    </div>
                </div>
                <div class="sc sc-green">
                    <div class="sc-icon"><i class="fas fa-shield-alt"></i></div>
                    <div>
                        <div class="sc-val"><%=underWarranty%></div>
                        <div class="sc-lbl">Under Warranty</div>
                    </div>
                </div>
            </div>

            <%-- Equipment list --%>
            <div class="section-lbl">Equipment</div>

            <%if(equipmentList.isEmpty()){%>
            <div class="empty">
                <i class="fas fa-desktop"></i>
                You have no equipment in your profile yet.
                <a href="<%=ctx%>/customerChat">Contact support to add equipment →</a>
            </div>
            <%}else{%>
            <div class="eq-grid">
                <%for(CustomerEquipment eq:equipmentList){
                    boolean isInternal="INTERNAL".equals(eq.getSource());
                    boolean underW=eq.isUnderWarranty();
                %>
                <div class="eq-card">
                    <div class="eq-card-top">
                       <% String imgUrl = eq.getImageUrl(); %>
<div class="eq-icon-wrap <%=isInternal?"eq-icon-int":"eq-icon-ext"%>">
    <%if(imgUrl != null && !imgUrl.isEmpty()){%>
    <img src="<%=ctx%><%=imgUrl%>" alt="<%=eq.getDisplayName()%>">
    <%}else{%>
    <i class="fas fa-desktop"></i>
    <%}%>
</div>
                        <div class="eq-tags">
                            <span class="tag <%=isInternal?"tag-int":"tag-ext"%>">
                                <%=isInternal?"In-System":"External"%>
                            </span>
                            <%if(eq.getWarrantyExpires()!=null){%>
                            <span class="tag <%=underW?"tag-wok":"tag-wexp"%>">
                                <%=underW?"In Warranty":"Expired"%>
                            </span>
                            <%}%>
                        </div>
                    </div>

                    <div class="eq-model"><%=eq.getDisplayName()%></div>
                    <%if(eq.getCategoryName()!=null){%>
                    <div class="eq-cat">
                        <i class="fas fa-tag" style="font-size:.68rem"></i> <%=eq.getCategoryName()%>
                    </div>
                    <%}%>

                    <div class="eq-details">
                        <div class="eq-detail-row">
                            <i class="fas fa-barcode"></i>
                            <span class="eq-serial"><%=eq.getDisplaySerial()%></span>
                        </div>
                        <%if(eq.getPurchasedDate()!=null){%>
                        <div class="eq-detail-row">
                            <i class="fas fa-shopping-cart"></i>
                            <span>Purchased: <%=eq.getPurchasedDate()%></span>
                        </div>
                        <%}%>
                        <%if(eq.getWarrantyExpires()!=null){%>
                        <div class="eq-detail-row">
                            <i class="fas fa-shield-alt" style="color:<%=underW?"var(--green)":"var(--red)"%>"></i>
                            <span style="color:<%=underW?"var(--green)":"var(--red)"%>;font-weight:<%=underW?"500":"600"%>">
                                Warranty <%=underW?"until":"expired on"%>: <%=eq.getWarrantyExpires()%>
                            </span>
                        </div>
                        <%}%>
                        <%if(eq.getNotes()!=null&&!eq.getNotes().isEmpty()){%>
                        <div class="eq-detail-row">
                            <i class="fas fa-sticky-note"></i>
                            <span style="color:var(--text-s)"><%=eq.getNotes()%></span>
                        </div>
                        <%}%>
                    </div>

                    <div class="eq-card-foot">
                        <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-fix">
                            <i class="fas fa-tools"></i> Create Repair Request
                        </a>
                        <a href="<%=ctx%>/customerContracts" class="btn-fix-icon" title="View Contracts">
                            <i class="fas fa-file-contract"></i>
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
