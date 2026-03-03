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
%><%! Object nvl(Object v,Object d){return v!=null?v:d;} %>
<!DOCTYPE html><html lang="vi"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Hợp Đồng - CRM</title>
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
                margin-bottom:18px
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
            /* Contract Cards Grid */
            .ct-grid{
                display:grid;
                grid-template-columns:repeat(auto-fill,minmax(320px,1fr));
                gap:16px
            }
            .ct-card{
                background:var(--surface);
                border-radius:13px;
                border:1px solid var(--border);
                overflow:hidden;
                transition:.15s
            }
            .ct-card:hover{
                transform:translateY(-2px);
                box-shadow:0 8px 24px rgba(0,0,0,.07)
            }
            .ct-card-top{
                padding:18px 20px;
                border-bottom:1px solid #f1f5f9;
                display:flex;
                justify-content:space-between;
                align-items:flex-start
            }
            .ct-code{
                font-family:monospace;
                font-size:.95rem;
                font-weight:700;
                color:var(--text)
            }
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.73rem;
                font-weight:600
            }
            .b-active{
                background:#d1fae5;
                color:#065f46
            }
            .b-expired{
                background:#fee2e2;
                color:#991b1b
            }
            .b-cancelled{
                background:#f3f4f6;
                color:#6b7280
            }
            .b-warranty{
                background:#d1fae5;
                color:#065f46
            }
            .b-maint{
                background:#dbeafe;
                color:#1e40af
            }
            .ct-type{
                margin-top:5px;
                display:flex;
                align-items:center;
                gap:7px
            }
            .ct-type-badge{
                padding:4px 10px;
                border-radius:6px;
                font-size:.78rem;
                font-weight:700
            }
            .ct-card-body{
                padding:14px 20px;
                font-size:.83rem;
                color:var(--muted)
            }
            .ct-row{
                display:flex;
                align-items:center;
                gap:7px;
                margin-bottom:7px
            }
            .ct-row i{
                width:14px;
                font-size:.8rem;
                flex-shrink:0
            }
            .ct-card-foot{
                padding:12px 20px;
                border-top:1px solid #f8fafc;
                display:flex;
                justify-content:space-between;
                align-items:center
            }
            .ct-eq-count{
                font-size:.8rem;
                color:var(--muted);
                display:flex;
                align-items:center;
                gap:5px
            }
            .btn-detail{
                padding:6px 14px;
                border-radius:7px;
                background:var(--primary);
                color:#fff;
                text-decoration:none;
                font-size:.8rem;
                font-weight:600;
                transition:.15s
            }
            .btn-detail:hover{
                background:#4338ca
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
                opacity:.35
            }
            .info-bar{
                background:#eff6ff;
                border:1px solid #bfdbfe;
                border-radius:10px;
                padding:12px 16px;
                font-size:.845rem;
                color:#1d4ed8;
                margin-bottom:16px;
                display:flex;
                align-items:center;
                gap:9px
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
            <div class="sb-brand"><div class="sb-logo"><i class="fas fa-bolt"></i></div><div><div class="sb-name">CRM System</div><div class="sb-sub">Khách hàng</div></div></div>
            <nav class="sb-nav">
                <div class="sb-lbl">Tổng quan</div>
                <a href="<%=ctx%>/customerDashboard"       class="sb-item"><i class="fas fa-home"></i> Trang chủ</a>
                <div class="sb-lbl">Dịch vụ</div>
                <a href="<%=ctx%>/customerServiceRequests" class="sb-item"><i class="fas fa-clipboard-list"></i> Yêu cầu sửa chữa</a>
                <a href="<%=ctx%>/customerContracts"       class="sb-item on"><i class="fas fa-file-contract"></i> Hợp đồng</a>
                <a href="<%=ctx%>/customerEquipment"       class="sb-item"><i class="fas fa-desktop"></i> Thiết bị của tôi</a>
                <div class="sb-lbl">Mua hàng</div>
                <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item"><i class="fas fa-puzzle-piece"></i> Linh kiện</a>
                <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Thiết bị</a>
                <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item"><i class="fas fa-shopping-cart"></i> Giỏ hàng<%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%></a>
                <div class="sb-lbl">Tài chính</div>
                <a href="<%=ctx%>/customerInvoices"        class="sb-item"><i class="fas fa-receipt"></i> Hóa đơn</a>
                <div class="sb-lbl">Hỗ trợ</div>
                <a href="<%=ctx%>/customerChat"            class="sb-item"><i class="fas fa-comment-dots"></i> Chat hỗ trợ</a>
            </nav>
            <div class="sb-foot">
                <div class="sb-user"><div class="sb-ava"><%=me.getFullName().substring(0,1).toUpperCase()%></div><div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Khách hàng</div></div></div>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
            </div>
        </aside>

        <main class="main">
            <div class="pg-hd">
                <h1><i class="fas fa-file-contract"></i> Hợp Đồng Dịch Vụ</h1>
                <p>Hợp đồng bảo hành và bảo trì thiết bị của bạn</p>
            </div>

            <div class="info-bar">
                <i class="fas fa-info-circle"></i>
                <span>Để tạo hợp đồng mới, vui lòng liên hệ nhân viên hỗ trợ qua
                    <a href="<%=ctx%>/customerChat" style="color:var(--primary);font-weight:600">Chat hỗ trợ</a></span>
            </div>

            <div class="stats">
                <div class="sm"><div class="sm-icon" style="background:#e0e7ff;color:var(--primary)"><i class="fas fa-file-contract"></i></div><div><div class="sm-val"><%=contracts.size()%></div><div class="sm-lbl">Tổng hợp đồng</div></div></div>
                <div class="sm"><div class="sm-icon" style="background:#d1fae5;color:var(--success)"><i class="fas fa-shield-alt"></i></div><div><div class="sm-val"><%=warrantyCount%></div><div class="sm-lbl">Bảo hành (WARRANTY)</div></div></div>
                <div class="sm"><div class="sm-icon" style="background:#dbeafe;color:var(--info)"><i class="fas fa-tools"></i></div><div><div class="sm-val"><%=maintCount%></div><div class="sm-lbl">Bảo trì (MAINTENANCE)</div></div></div>
            </div>

            <%if(contracts.isEmpty()){%>
            <div class="empty"><i class="fas fa-file-contract"></i>Bạn chưa có hợp đồng nào.<br>
                <a href="<%=ctx%>/customerChat" style="color:var(--primary);font-weight:600;display:inline-block;margin-top:8px">Liên hệ nhân viên hỗ trợ →</a>
            </div>
            <%}else{%>
            <div class="ct-grid">
                <%for(Contract c:contracts){
                  String sc="b-active";
                  if("EXPIRED".equals(c.getStatus()))sc="b-expired";
                  else if("CANCELLED".equals(c.getStatus()))sc="b-cancelled";
                  boolean isW="WARRANTY".equals(c.getContractType());
                %>
                <div class="ct-card">
                    <div class="ct-card-top">
                        <div>
                            <div class="ct-code"><%=c.getContractCode()%></div>
                            <div class="ct-type">
                                <span class="ct-type-badge" style="background:<%=isW?"#d1fae5":"#dbeafe"%>;color:<%=isW?"#065f46":"#1e40af"%>">
                                    <i class="fas fa-<%=isW?"shield-alt":"tools"%>"></i> <%=c.getContractTypeLabel()%>
                                </span>
                            </div>
                        </div>
                        <span class="b <%=sc%>"><%=c.getStatusLabel()%></span>
                    </div>
                    <div class="ct-card-body">
                        <div class="ct-row"><i class="fas fa-calendar-alt"></i> Từ: <%=c.getStartDate()%> → <%=c.getEndDate()%></div>
                        <div class="ct-row"><i class="fas fa-user-tie"></i> Tạo bởi: <%=c.getCreatedByName()%></div>
                        <%if(c.getNotes()!=null&&!c.getNotes().isEmpty()){%>
                        <div class="ct-row"><i class="fas fa-sticky-note"></i> <%=c.getNotes()%></div>
                        <%}%>
                    </div>
                    <div class="ct-card-foot">
                        <div class="ct-eq-count">
                            <i class="fas fa-desktop" style="color:var(--primary)"></i>
                            <%=c.getEquipmentCount()%> thiết bị · <%=c.getServiceRequestCount()%> yêu cầu
                        </div>
                        <a href="<%=ctx%>/customerContracts?action=detail&id=<%=c.getId()%>" class="btn-detail">Chi tiết →</a>
                    </div>
                </div>
                <%}%>
            </div>
            <%}%>
        </main>
    </body></html>
