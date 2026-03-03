<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    Contract c=(Contract)request.getAttribute("contract");
    if(c==null){response.sendRedirect(request.getContextPath()+"/customerContracts");return;}
    String ctx=request.getContextPath();
     int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    List<CustomerEquipment> eqList=c.getEquipmentList(); if(eqList==null)eqList=new ArrayList<>();
    boolean isW="WARRANTY".equals(c.getContractType());
    String sc="b-active";
    if("EXPIRED".equals(c.getStatus()))sc="b-expired";
    else if("CANCELLED".equals(c.getStatus()))sc="b-cancelled";
%><%!
    String bstat(String s){if("EXPIRED".equals(s))return"b-expired";if("CANCELLED".equals(s))return"b-cancelled";return"b-active";}
%>
<!DOCTYPE html><html lang="vi"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title><%=c.getContractCode()%> - CRM</title>
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
            /* Hero banner */
            .hero{
                border-radius:16px;
                padding:26px 30px;
                margin-bottom:20px;
                display:flex;
                justify-content:space-between;
                align-items:center;
                background:linear-gradient(135deg,<%=isW?"#065f46,#059669":"#1e40af,#3b82f6"%>);
                color:#fff
            }
            .hero-left h2{
                font-size:1.5rem;
                font-weight:800;
                margin-bottom:6px
            }
            .hero-code{
                font-family:monospace;
                font-size:1rem;
                opacity:.8;
                margin-bottom:12px
            }
            .hero-meta{
                display:flex;
                gap:18px;
                font-size:.82rem;
                opacity:.85
            }
            .hero-meta span{
                display:flex;
                align-items:center;
                gap:5px
            }
            .hero-badge{
                padding:7px 16px;
                border-radius:20px;
                background:rgba(255,255,255,.2);
                font-size:.85rem;
                font-weight:700;
                backdrop-filter:blur(4px)
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
                margin-bottom:16px
            }
            .btn-back:hover{
                background:#f1f5f9
            }
            .btn-create{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:9px 16px;
                border-radius:9px;
                background:var(--primary);
                color:#fff;
                text-decoration:none;
                font-size:.855rem;
                font-weight:600;
                transition:.15s
            }
            .btn-create:hover{
                background:#4338ca
            }
            .grid-detail{
                display:grid;
                grid-template-columns:2fr 1fr;
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
                justify-content:space-between;
                align-items:center
            }
            .card-hd-left{
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
                padding:18px 20px
            }
            .info-row{
                display:flex;
                gap:10px;
                margin-bottom:13px;
                align-items:flex-start
            }
            .info-row:last-child{
                margin-bottom:0
            }
            .info-lbl{
                font-size:.78rem;
                color:var(--muted);
                font-weight:600;
                min-width:110px;
                padding-top:1px
            }
            .info-val{
                font-size:.855rem;
                color:var(--text);
                flex:1
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
            /* Equipment cards */
            .eq-grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:10px;
                padding:16px
            }
            .eq-card{
                border:1.5px solid var(--border);
                border-radius:10px;
                padding:14px;
                transition:.15s
            }
            .eq-card:hover{
                border-color:var(--primary);
                background:#fafbff
            }
            .eq-card-top{
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                margin-bottom:8px
            }
            .eq-icon{
                width:36px;
                height:36px;
                border-radius:9px;
                background:#e0e7ff;
                color:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.95rem
            }
            .eq-source{
                font-size:.69rem;
                font-weight:600;
                padding:2px 6px;
                border-radius:4px
            }
            .eq-model{
                font-size:.855rem;
                font-weight:700;
                color:var(--text);
                margin-bottom:3px
            }
            .eq-serial{
                font-size:.76rem;
                color:var(--muted);
                font-family:monospace
            }
            .eq-warranty{
                font-size:.75rem;
                margin-top:6px;
                padding:4px 8px;
                border-radius:5px;
                display:inline-flex;
                align-items:center;
                gap:4px
            }
            .eq-warranty.ok{
                background:#f0fdf4;
                color:#166534
            }
            .eq-warranty.exp{
                background:#fef2f2;
                color:#991b1b
            }
            /* Request summary in right col */
            .sr-item{
                padding:11px 0;
                border-bottom:1px solid #f8fafc;
                display:flex;
                justify-content:space-between;
                align-items:center;
                font-size:.83rem
            }
            .sr-item:last-child{
                border-bottom:none
            }
            .note-box{
                background:#fffbeb;
                border:1px solid #fde68a;
                border-radius:9px;
                padding:12px 14px;
                font-size:.84rem;
                color:#92400e;
                line-height:1.6
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
            <div class="breadcrumb">
                <a href="<%=ctx%>/customerDashboard"><i class="fas fa-home"></i></a>
                <span class="breadcrumb-sep">›</span>
                <a href="<%=ctx%>/customerContracts">Hợp đồng</a>
                <span class="breadcrumb-sep">›</span>
                <span><%=c.getContractCode()%></span>
            </div>

            <div class="hero">
                <div class="hero-left">
                    <div class="hero-code"><%=c.getContractCode()%></div>
                    <h2><i class="fas fa-<%=isW?"shield-alt":"tools"%>"></i> Hợp Đồng <%=c.getContractTypeLabel()%></h2>
                    <div class="hero-meta">
                        <span><i class="fas fa-calendar"></i> <%=c.getStartDate()%> → <%=c.getEndDate()%></span>
                        <span><i class="fas fa-desktop"></i> <%=eqList.size()%> thiết bị</span>
                        <span><i class="fas fa-user-tie"></i> <%=c.getCreatedByName()%></span>
                    </div>
                </div>
                <div>
                    <div class="hero-badge"><%=c.getStatusLabel()%></div>
                </div>
            </div>

            <div style="display:flex;justify-content:space-between;margin-bottom:18px">
                <a href="<%=ctx%>/customerContracts" class="btn-back"><i class="fas fa-arrow-left"></i> Quay lại</a>
                <%if(c.isActive()){%>
                <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-create"><i class="fas fa-plus"></i> Tạo Yêu Cầu Sửa Chữa</a>
                <%}%>
            </div>

            <div class="grid-detail">
                <div>
                    <!-- Thiết bị -->
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-left">
                                <div class="card-hd-icon" style="background:#7c3aed"><i class="fas fa-desktop"></i></div>
                                <div class="card-hd-title">Thiết Bị Trong Hợp Đồng (<%=eqList.size()%>)</div>
                            </div>
                        </div>
                        <%if(eqList.isEmpty()){%>
                        <div class="card-body" style="text-align:center;color:var(--muted);padding:28px">
                            <i class="fas fa-desktop" style="font-size:2rem;opacity:.2;display:block;margin-bottom:8px"></i>Chưa có thiết bị
                        </div>
                        <%}else{%>
                        <div class="eq-grid">
                            <%for(CustomerEquipment eq:eqList){
                              boolean underW=eq.isUnderWarranty();
                            %>
                            <div class="eq-card">
                                <div class="eq-card-top">
                                    <div class="eq-icon"><i class="fas fa-desktop"></i></div>
                                    <span class="eq-source" style="background:<%="EXTERNAL".equals(eq.getSource())?"#fef9c3":"#e0e7ff"%>;color:<%="EXTERNAL".equals(eq.getSource())?"#854d0e":"#3730a3"%>">
                                        <%="EXTERNAL".equals(eq.getSource())?"Ngoài HT":"Trong HT"%>
                                    </span>
                                </div>
                                <div class="eq-model"><%=eq.getDisplayName()%></div>
                                <div class="eq-serial"><i class="fas fa-barcode" style="font-size:.68rem"></i> <%=eq.getDisplaySerial()%></div>
                                <%if(eq.getWarrantyExpires()!=null){%>
                                <span class="eq-warranty <%=underW?"ok":"exp"%>">
                                    <i class="fas fa-<%=underW?"shield-alt":"clock"%>"></i>
                                    Bảo hành: <%=underW?"còn đến ":"hết từ "%><%=eq.getWarrantyExpires()%>
                                </span>
                                <%}%>
                            </div>
                            <%}%>
                        </div>
                        <%}%>
                    </div>

                    <%if(c.getNotes()!=null&&!c.getNotes().isEmpty()){%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-left"><div class="card-hd-icon" style="background:var(--warning)"><i class="fas fa-sticky-note"></i></div><div class="card-hd-title">Ghi Chú Hợp Đồng</div></div>
                        </div>
                        <div class="card-body"><div class="note-box"><%=c.getNotes()%></div></div>
                    </div>
                    <%}%>
                </div>

                <!-- Right -->
                <div>
                    <div class="card">
                        <div class="card-hd"><div class="card-hd-left"><div class="card-hd-icon"><i class="fas fa-info"></i></div><div class="card-hd-title">Thông Tin Hợp Đồng</div></div></div>
                        <div class="card-body">
                            <div class="info-row"><div class="info-lbl">Mã hợp đồng</div><div class="info-val"><strong style="font-family:monospace;color:var(--primary)"><%=c.getContractCode()%></strong></div></div>
                            <div class="info-row"><div class="info-lbl">Loại</div>
                                <div class="info-val">
                                    <span style="padding:4px 10px;border-radius:6px;font-size:.78rem;font-weight:700;background:<%=isW?"#d1fae5":"#dbeafe"%>;color:<%=isW?"#065f46":"#1e40af"%>">
                                        <i class="fas fa-<%=isW?"shield-alt":"tools"%>"></i> <%=c.getContractTypeLabel()%>
                                    </span>
                                </div>
                            </div>
                            <div class="info-row"><div class="info-lbl">Trạng thái</div><div class="info-val"><span class="b <%=sc%>"><%=c.getStatusLabel()%></span></div></div>
                            <div class="info-row"><div class="info-lbl">Bắt đầu</div><div class="info-val"><%=c.getStartDate()%></div></div>
                            <div class="info-row"><div class="info-lbl">Kết thúc</div><div class="info-val"><%=c.getEndDate()%></div></div>
                            <div class="info-row"><div class="info-lbl">Phụ trách</div><div class="info-val"><%=c.getCreatedByName()%></div></div>
                            <div class="info-row"><div class="info-lbl">Ngày tạo</div><div class="info-val"><%=c.getCreatedAt()!=null?c.getCreatedAt().toLocalDate():"—"%></div></div>
                        </div>
                    </div>

                    <div class="card" style="background:<%=isW?"#f0fdf4":"#eff6ff"%>;border-color:<%=isW?"#bbf7d0":"#bfdbfe"%>">
                        <div class="card-body">
                            <div style="font-size:.84rem;font-weight:700;color:<%=isW?"#065f46":"#1e40af"%>;margin-bottom:7px">
                                <i class="fas fa-<%=isW?"shield-check":"tools"%>"></i> Điều Khoản Dịch Vụ
                            </div>
                            <div style="font-size:.8rem;color:<%=isW?"#047857":"#1d4ed8"%>;line-height:1.7">
                                <%if(isW){%>
                                ✓ Sửa chữa miễn phí trong thời gian bảo hành<br>
                                ✓ Áp dụng cho thiết bị còn trong hạn bảo hành<br>
                                ✓ Không tính phí nhân công và linh kiện
                                <%}else{%>
                                ✓ Dịch vụ bảo trì định kỳ và sửa chữa<br>
                                ✓ Chi phí sẽ được thông báo sau khi kiểm tra<br>
                                ✓ Hóa đơn xuất sau khi hoàn thành công việc
                                <%}%>
                            </div>
                        </div>
                    </div>

                    <%if(c.isActive()){%>
                    <div style="text-align:center">
                        <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-create" style="width:100%;justify-content:center">
                            <i class="fas fa-plus"></i> Tạo Yêu Cầu Sửa Chữa
                        </a>
                    </div>
                    <%}%>
                </div>
            </div>
        </main>
    </body></html>
