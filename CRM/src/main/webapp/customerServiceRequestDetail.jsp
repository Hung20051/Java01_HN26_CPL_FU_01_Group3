<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    ServiceRequest sr=(ServiceRequest)request.getAttribute("sr");
    if(sr==null){response.sendRedirect(request.getContextPath()+"/customerServiceRequests");return;}
    String ctx=request.getContextPath();
    List<ServiceRequestEquipment> eqList=sr.getEquipmentList(); if(eqList==null)eqList=new ArrayList<>();
    String sc="b-pending";
    if("APPROVED".equals(sr.getStatus()))sc="b-approved";
    else if("REJECTED".equals(sr.getStatus()))sc="b-rejected";
    else if("IN_PROGRESS".equals(sr.getStatus()))sc="b-inprogress";
    else if("COMPLETED".equals(sr.getStatus()))sc="b-completed";
    else if("CANCELLED".equals(sr.getStatus()))sc="b-cancelled";
    String pc="b-medium";
    if("LOW".equals(sr.getPriority()))pc="b-low";
    else if("HIGH".equals(sr.getPriority()))pc="b-high";
    else if("URGENT".equals(sr.getPriority()))pc="b-urgent";
    boolean isW="WARRANTY".equals(sr.getContractType());
    boolean canCancel="PENDING".equals(sr.getStatus());
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
%>
<!DOCTYPE html><html lang="vi"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title><%=sr.getRequestCode()%> - CRM</title>
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
            .page-hd{
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                margin-bottom:20px
            }
            .page-hd-left h1{
                font-size:1.25rem;
                font-weight:800;
                color:var(--text);
                display:flex;
                align-items:center;
                gap:9px
            }
            .page-hd-left h1 span{
                font-family:monospace;
                color:var(--primary)
            }
            .page-hd-left p{
                color:var(--muted);
                font-size:.84rem;
                margin-top:4px
            }
            .actions{
                display:flex;
                gap:9px;
                align-items:center
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
                transition:.15s
            }
            .btn-back:hover{
                background:#f1f5f9
            }
            .btn-cancel-big{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:9px 16px;
                border-radius:9px;
                background:#fee2e2;
                color:var(--danger);
                border:none;
                font-size:.855rem;
                font-weight:600;
                cursor:pointer;
                font-family:inherit;
                transition:.15s
            }
            .btn-cancel-big:hover{
                background:#fecaca
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
                min-width:120px;
                padding-top:1px
            }
            .info-val{
                font-size:.855rem;
                color:var(--text);
                flex:1;
                line-height:1.5
            }
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.73rem;
                font-weight:600
            }
            .b-pending{
                background:#fef3c7;
                color:#92400e
            }
            .b-approved{
                background:#d1fae5;
                color:#065f46
            }
            .b-rejected{
                background:#fee2e2;
                color:#991b1b
            }
            .b-inprogress{
                background:#dbeafe;
                color:#1e40af
            }
            .b-completed{
                background:#e0e7ff;
                color:#3730a3
            }
            .b-cancelled{
                background:#f3f4f6;
                color:#6b7280
            }
            .b-low{
                background:#f0fdf4;
                color:#166534
            }
            .b-medium{
                background:#fef9c3;
                color:#854d0e
            }
            .b-high{
                background:#fff7ed;
                color:#9a3412
            }
            .b-urgent{
                background:#fef2f2;
                color:#991b1b
            }
            .desc-box{
                background:#f8fafc;
                border-radius:9px;
                padding:13px 16px;
                font-size:.855rem;
                color:var(--text);
                line-height:1.7;
                border:1px solid var(--border)
            }
            /* Equipment items */
            .eq-item{
                display:flex;
                align-items:flex-start;
                gap:12px;
                padding:13px 0;
                border-bottom:1px solid #f1f5f9
            }
            .eq-item:last-child{
                border-bottom:none
            }
            .eq-num{
                width:28px;
                height:28px;
                border-radius:50%;
                background:#e0e7ff;
                color:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.75rem;
                font-weight:700;
                flex-shrink:0
            }
            .eq-name{
                font-size:.875rem;
                font-weight:600;
                color:var(--text)
            }
            .eq-serial{
                font-size:.77rem;
                color:var(--muted);
                font-family:monospace;
                margin-top:2px
            }
            .eq-issue{
                font-size:.8rem;
                color:var(--muted);
                margin-top:6px;
                padding:6px 9px;
                background:#f8fafc;
                border-radius:6px;
                border-left:3px solid var(--primary)
            }
            /* Timeline */
            .timeline{
                padding:4px 0
            }
            .tl-item{
                display:flex;
                gap:12px;
                padding:10px 0;
                position:relative
            }
            .tl-dot{
                width:30px;
                height:30px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.8rem;
                flex-shrink:0;
                border:2px solid
            }
            .tl-dot.done{
                background:var(--primary);
                border-color:var(--primary);
                color:#fff
            }
            .tl-dot.current{
                background:#fff;
                border-color:var(--primary);
                color:var(--primary)
            }
            .tl-dot.wait{
                background:#f8fafc;
                border-color:var(--border);
                color:var(--muted)
            }
            .tl-content{
                flex:1;
                padding-top:4px
            }
            .tl-label{
                font-size:.845rem;
                font-weight:600;
                color:var(--text)
            }
            .tl-sub{
                font-size:.76rem;
                color:var(--muted);
                margin-top:2px
            }
            /* Reject box */
            .reject-box{
                background:#fef2f2;
                border:1px solid #fca5a5;
                border-radius:10px;
                padding:13px 16px;
                margin-bottom:16px;
                font-size:.855rem;
                color:#991b1b;
                display:flex;
                gap:10px;
                align-items:flex-start
            }
            .reject-box i{
                margin-top:2px;
                flex-shrink:0
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
                <a href="<%=ctx%>/customerServiceRequests" class="sb-item on"><i class="fas fa-clipboard-list"></i> Yêu cầu sửa chữa</a>
                <a href="<%=ctx%>/customerContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Hợp đồng</a>
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
                <a href="<%=ctx%>/customerServiceRequests">Yêu cầu sửa chữa</a>
                <span class="breadcrumb-sep">›</span>
                <span><%=sr.getRequestCode()%></span>
            </div>

            <div class="page-hd">
                <div class="page-hd-left">
                    <h1><i class="fas fa-clipboard-check"></i> Chi Tiết Yêu Cầu <span><%=sr.getRequestCode()%></span></h1>
                    <p><%=sr.getTitle()%></p>
                </div>
                <div class="actions">
                    <a href="<%=ctx%>/customerServiceRequests" class="btn-back"><i class="fas fa-arrow-left"></i> Quay lại</a>
                    <%if(canCancel){%>
                    <form method="post" action="<%=ctx%>/customerServiceRequests" onsubmit="return confirm('Bạn chắc chắn muốn hủy yêu cầu này?')">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="id" value="<%=sr.getId()%>">
                        <button type="submit" class="btn-cancel-big"><i class="fas fa-times-circle"></i> Hủy Yêu Cầu</button>
                    </form>
                    <%}%>
                </div>
            </div>

            <%if("REJECTED".equals(sr.getStatus())&&sr.getRejectReason()!=null){%>
            <div class="reject-box">
                <i class="fas fa-ban"></i>
                <div><strong>Yêu cầu bị từ chối:</strong> <%=sr.getRejectReason()%></div>
            </div>
            <%}%>

            <div class="grid-detail">
                <div>
                    <!-- Thông tin chung -->
                    <div class="card">
                        <div class="card-hd"><div class="card-hd-icon"><i class="fas fa-info"></i></div><div class="card-hd-title">Thông Tin Yêu Cầu</div></div>
                        <div class="card-body">
                            <div class="info-row"><div class="info-lbl">Mã yêu cầu</div><div class="info-val"><strong style="font-family:monospace;color:var(--primary)"><%=sr.getRequestCode()%></strong></div></div>
                            <div class="info-row"><div class="info-lbl">Tiêu đề</div><div class="info-val"><strong><%=sr.getTitle()%></strong></div></div>
                            <div class="info-row">
                                <div class="info-lbl">Hợp đồng</div>
                                <div class="info-val">
                                    <a href="<%=ctx%>/customerContracts?action=detail&id=<%=sr.getContractId()%>" style="color:var(--primary);font-weight:700;font-family:monospace"><%=sr.getContractCode()%></a>
                                    <span style="margin-left:7px;padding:3px 8px;border-radius:5px;font-size:.75rem;font-weight:700;background:<%=isW?"#d1fae5":"#dbeafe"%>;color:<%=isW?"#065f46":"#1e40af"%>">
                                        <%=isW?"Bảo hành":"Bảo trì"%>
                                    </span>
                                </div>
                            </div>
                            <div class="info-row"><div class="info-lbl">Ưu tiên</div><div class="info-val"><span class="b <%=pc%>"><%=sr.getPriorityLabel()%></span></div></div>
                            <div class="info-row"><div class="info-lbl">Trạng thái</div><div class="info-val"><span class="b <%=sc%>"><%=sr.getStatusLabel()%></span></div></div>
                            <div class="info-row"><div class="info-lbl">Ngày tạo</div><div class="info-val"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().replace("T"," ").substring(0,16):"—"%></div></div>
                                <%if(sr.getCompletedAt()!=null){%>
                            <div class="info-row"><div class="info-lbl">Hoàn thành</div><div class="info-val" style="color:var(--success);font-weight:600"><%=sr.getCompletedAt().toString().replace("T"," ").substring(0,16)%></div></div>
                                <%}%>
                        </div>
                    </div>

                    <!-- Mô tả -->
                    <div class="card">
                        <div class="card-hd"><div class="card-hd-icon" style="background:var(--muted)"><i class="fas fa-align-left"></i></div><div class="card-hd-title">Mô Tả Sự Cố</div></div>
                        <div class="card-body">
                            <div class="desc-box"><%=sr.getDescription().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>")%></div>
                        </div>
                    </div>

                    <!-- Thiết bị -->
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-icon" style="background:#7c3aed"><i class="fas fa-desktop"></i></div>
                            <div class="card-hd-title">Thiết Bị Cần Sửa (<%=eqList.size()%>)</div>
                        </div>
                        <div class="card-body" style="padding-top:4px;padding-bottom:4px">
                            <%if(eqList.isEmpty()){%>
                            <p style="color:var(--muted);font-size:.84rem;padding:10px 0">Chưa có thông tin thiết bị.</p>
                            <%}else{for(int i=0;i<eqList.size();i++){ServiceRequestEquipment eq=eqList.get(i);%>
                            <div class="eq-item">
                                <div class="eq-num"><%=i+1%></div>
                                <div style="flex:1">
                                    <div class="eq-name"><%=eq.getDisplayName()!=null?eq.getDisplayName():"Thiết bị #"+eq.getCustomerEquipmentId()%></div>
                                    <div class="eq-serial"><i class="fas fa-barcode" style="font-size:.7rem"></i> <%=eq.getDisplaySerial()!=null?eq.getDisplaySerial():"N/A"%>
                                        <span style="margin-left:6px;padding:1px 6px;border-radius:3px;background:<%="EXTERNAL".equals(eq.getSource())?"#fef9c3":"#e0e7ff"%>;color:<%="EXTERNAL".equals(eq.getSource())?"#854d0e":"#3730a3"%>;font-size:.7rem">
                                            <%="EXTERNAL".equals(eq.getSource())?"Ngoài HT":"Trong HT"%>
                                        </span>
                                    </div>
                                    <%if(eq.getIssueDescription()!=null&&!eq.getIssueDescription().isEmpty()){%>
                                    <div class="eq-issue"><i class="fas fa-exclamation-circle" style="color:var(--warning);margin-right:4px"></i><%=eq.getIssueDescription()%></div>
                                        <%}%>
                                </div>
                            </div>
                            <%}}%>
                        </div>
                    </div>
                </div>

                <!-- Right column -->
                <div>
                    <!-- Tiến độ -->
                    <div class="card">
                        <div class="card-hd"><div class="card-hd-icon" style="background:var(--success)"><i class="fas fa-tasks"></i></div><div class="card-hd-title">Tiến Độ Xử Lý</div></div>
                        <div class="card-body">
                            <div class="timeline">
                                <%
                                  boolean p1="PENDING".equals(sr.getStatus())||"APPROVED".equals(sr.getStatus())||"REJECTED".equals(sr.getStatus())||"IN_PROGRESS".equals(sr.getStatus())||"COMPLETED".equals(sr.getStatus());
                                  boolean p2="APPROVED".equals(sr.getStatus())||"IN_PROGRESS".equals(sr.getStatus())||"COMPLETED".equals(sr.getStatus());
                                  boolean p3="IN_PROGRESS".equals(sr.getStatus())||"COMPLETED".equals(sr.getStatus());
                                  boolean p4="COMPLETED".equals(sr.getStatus());
                                  boolean rejected="REJECTED".equals(sr.getStatus());
                                  boolean cancelled="CANCELLED".equals(sr.getStatus());
                                %>
                                <div class="tl-item">
                                    <div class="tl-dot done"><i class="fas fa-check"></i></div>
                                    <div class="tl-content">
                                        <div class="tl-label">Đã gửi yêu cầu</div>
                                        <div class="tl-sub"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toLocalDate():""%></div>
                                    </div>
                                </div>
                                <%if(cancelled){%>
                                <div class="tl-item">
                                    <div class="tl-dot" style="background:#f3f4f6;border-color:#d1d5db;color:#9ca3af"><i class="fas fa-ban"></i></div>
                                    <div class="tl-content"><div class="tl-label" style="color:var(--muted)">Đã hủy</div></div>
                                </div>
                                <%}else if(rejected){%>
                                <div class="tl-item">
                                    <div class="tl-dot" style="background:#fee2e2;border-color:var(--danger);color:var(--danger)"><i class="fas fa-times"></i></div>
                                    <div class="tl-content">
                                        <div class="tl-label" style="color:var(--danger)">Bị từ chối</div>
                                        <div class="tl-sub"><%=sr.getReviewedAt()!=null?sr.getReviewedAt().toLocalDate():""%></div>
                                    </div>
                                </div>
                                <%}else{%>
                                <div class="tl-item">
                                    <div class="tl-dot <%=p2?"done":("PENDING".equals(sr.getStatus())?"current":"wait")%>">
                                        <i class="fas fa-<%=p2?"check":"clock"%>"></i>
                                    </div>
                                    <div class="tl-content">
                                        <div class="tl-label"><%=p2?"Đã duyệt":"Chờ Technical Manager duyệt"%></div>
                                        <%if(p2&&sr.getReviewedByName()!=null){%><div class="tl-sub"><%=sr.getReviewedByName()%> · <%=sr.getReviewedAt()!=null?sr.getReviewedAt().toLocalDate():""%></div><%}%>
                                    </div>
                                </div>
                                <div class="tl-item">
                                    <div class="tl-dot <%=p3?"done":(p2?"current":"wait")%>">
                                        <i class="fas fa-<%=p3?"check":"spinner"%>"></i>
                                    </div>
                                    <div class="tl-content">
                                        <div class="tl-label"><%=p3?"Đang/Đã xử lý":"Chờ kỹ thuật viên"%></div>
                                        <%if(sr.getAssignedToName()!=null){%><div class="tl-sub">KTV: <%=sr.getAssignedToName()%></div><%}%>
                                    </div>
                                </div>
                                <div class="tl-item">
                                    <div class="tl-dot <%=p4?"done":"wait"%>">
                                        <i class="fas fa-<%=p4?"check-circle":"flag"%>"></i>
                                    </div>
                                    <div class="tl-content">
                                        <div class="tl-label"><%=p4?"Hoàn thành!":"Hoàn thành"%></div>
                                        <%if(p4&&sr.getCompletedAt()!=null){%><div class="tl-sub" style="color:var(--success)"><%=sr.getCompletedAt().toLocalDate()%></div><%}%>
                                    </div>
                                </div>
                                <%}%>
                            </div>
                        </div>
                    </div>

                    <!-- Kỹ thuật viên -->
                    <div class="card">
                        <div class="card-hd"><div class="card-hd-icon" style="background:#0891b2"><i class="fas fa-user-hard-hat"></i></div><div class="card-hd-title">Nhân Viên Phụ Trách</div></div>
                        <div class="card-body">
                            <%if(sr.getAssignedToName()!=null){%>
                            <div style="display:flex;align-items:center;gap:10px">
                                <div style="width:40px;height:40px;border-radius:50%;background:#e0f2fe;color:#0891b2;display:flex;align-items:center;justify-content:center;font-size:1rem;font-weight:700">
                                    <%=sr.getAssignedToName().substring(0,1).toUpperCase()%>
                                </div>
                                <div>
                                    <div style="font-size:.875rem;font-weight:600;color:var(--text)"><%=sr.getAssignedToName()%></div>
                                    <div style="font-size:.76rem;color:var(--muted)">Kỹ thuật viên</div>
                                </div>
                            </div>
                            <%}else{%>
                            <p style="color:var(--muted);font-size:.84rem;text-align:center;padding:10px 0"><i class="fas fa-user-clock" style="font-size:1.5rem;display:block;margin-bottom:6px;opacity:.3"></i>Chưa phân công</p>
                            <%}%>
                        </div>
                    </div>

                    <!-- Loại hợp đồng note -->
                    <div class="card" style="background:<%=isW?"#f0fdf4":"#eff6ff"%>;border-color:<%=isW?"#bbf7d0":"#bfdbfe"%>">
                        <div class="card-body">
                            <div style="display:flex;align-items:center;gap:9px">
                                <i class="fas fa-<%=isW?"shield-alt":"tools"%>" style="font-size:1.2rem;color:<%=isW?"var(--success)":"var(--info)"%>"></i>
                                <div>
                                    <div style="font-size:.84rem;font-weight:700;color:<%=isW?"#065f46":"#1e40af"%>"><%=isW?"Hợp đồng Bảo Hành":"Hợp đồng Bảo Trì"%></div>
                                    <div style="font-size:.77rem;color:<%=isW?"#047857":"#1d4ed8"%>;margin-top:2px">
                                        <%=isW?"Dịch vụ sửa chữa MIỄN PHÍ theo hợp đồng bảo hành":"Chi phí sửa chữa sẽ được tính và thông báo sau"%>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </body></html>
