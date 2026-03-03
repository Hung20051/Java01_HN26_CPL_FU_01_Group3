<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*,java.math.BigDecimal" %>
<%
    User me = (User) session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    long   activeContracts = request.getAttribute("activeContracts")!=null?(Long)request.getAttribute("activeContracts"):0;
    int    totalContracts  = request.getAttribute("totalContracts") !=null?(Integer)request.getAttribute("totalContracts"):0;
    int    totalSR         = request.getAttribute("totalSR")        !=null?(Integer)request.getAttribute("totalSR"):0;
    int    pendingSR       = request.getAttribute("pendingSR")      !=null?(Integer)request.getAttribute("pendingSR"):0;
    int    activeSR        = request.getAttribute("activeSR")       !=null?(Integer)request.getAttribute("activeSR"):0;
    int    completedSR     = request.getAttribute("completedSR")    !=null?(Integer)request.getAttribute("completedSR"):0;
    int    unreadChat      = request.getAttribute("unreadChat")     !=null?(Integer)request.getAttribute("unreadChat"):0;
    Map<String,Object> inv = (Map<String,Object>) request.getAttribute("invSummary");
    List<ServiceRequest> recent = (List<ServiceRequest>) request.getAttribute("recentSR");
    if(recent==null) recent=new ArrayList<>();
    int unpaidInv = inv!=null&&inv.get("unpaid")!=null?(Integer)inv.get("unpaid"):0;
    BigDecimal unpaidAmt = inv!=null?(BigDecimal)inv.get("unpaidAmt"):null;
    String ctx = request.getContextPath();
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
    // Giỏ hàng - thêm vào cuối block này
    Map<?,?> shopCart = (Map<?,?>) session.getAttribute("shopCart");
    int cartCount = shopCart != null ? shopCart.size() : 0;
%>

<!DOCTYPE html><html lang="vi"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Trang Chủ - CRM</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root{
                --primary:#4f46e5;
                --primary-light:#e0e7ff;
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
            /* SIDEBAR */
            .sb{
                width:240px;
                min-height:100vh;
                background:var(--sidebar);
                display:flex;
                flex-direction:column;
                position:fixed;
                top:0;
                left:0;
                z-index:100
            }
            .sb-brand{
                padding:22px 18px 18px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid rgba(255,255,255,0.07)
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
                font-size:.68rem;
                margin-top:1px
            }
            .sb-nav{
                flex:1;
                padding:14px 10px;
                overflow-y:auto
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
            .sb-badge{
                margin-left:auto;
                background:var(--danger);
                color:#fff;
                font-size:.63rem;
                font-weight:700;
                padding:2px 6px;
                border-radius:10px
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
                font-weight:700;
                flex-shrink:0
            }
            .sb-uname{
                color:#fff;
                font-size:.82rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,.38);
                font-size:.7rem;
                margin-top:1px
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
            /* MAIN */
            .main{
                margin-left:240px;
                flex:1;
                padding:28px 32px
            }
            .topbar{
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                margin-bottom:22px
            }
            .topbar-title{
                font-size:1.4rem;
                font-weight:800;
                color:var(--text)
            }
            .topbar-sub{
                color:var(--muted);
                font-size:.85rem;
                margin-top:3px
            }
            .btn-cta{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:10px 20px;
                border-radius:10px;
                background:var(--primary);
                color:#fff;
                text-decoration:none;
                font-size:.875rem;
                font-weight:600;
                transition:.15s
            }
            .btn-cta:hover{
                background:#4338ca
            }
            /* Alert */
            .alert-warn{
                display:flex;
                align-items:center;
                gap:12px;
                padding:13px 16px;
                background:#fff7ed;
                border:1px solid #fed7aa;
                border-radius:11px;
                margin-bottom:18px;
                font-size:.875rem;
                color:#9a3412
            }
            .alert-warn a{
                color:var(--warning);
                font-weight:600;
                text-decoration:none;
                margin-left:6px
            }
            /* Stats */
            .stats{
                display:grid;
                grid-template-columns:repeat(4,1fr);
                gap:14px;
                margin-bottom:20px
            }
            .sc{
                background:var(--surface);
                border-radius:13px;
                padding:20px;
                border:1px solid var(--border);
                transition:.15s;
                position:relative;
                overflow:hidden
            }
            .sc:hover{
                transform:translateY(-2px);
                box-shadow:0 8px 24px rgba(0,0,0,.07)
            }
            .sc-icon{
                width:42px;
                height:42px;
                border-radius:11px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1rem;
                margin-bottom:12px
            }
            .sc-val{
                font-size:1.9rem;
                font-weight:800;
                color:var(--text);
                line-height:1
            }
            .sc-lbl{
                color:var(--muted);
                font-size:.8rem;
                margin-top:5px
            }
            .sc-sub{
                font-size:.76rem;
                margin-top:7px;
                color:var(--muted)
            }
            .i-blue .sc-icon{
                background:#dbeafe;
                color:var(--info)
            }
            .i-green .sc-icon{
                background:#d1fae5;
                color:var(--success)
            }
            .i-amber .sc-icon{
                background:#fef3c7;
                color:var(--warning)
            }
            .i-purple .sc-icon{
                background:#ede9fe;
                color:var(--primary)
            }
            .i-red   .sc-icon{
                background:#fee2e2;
                color:var(--danger)
            }
            /* Grid */
            .grid-2{
                display:grid;
                grid-template-columns:3fr 2fr;
                gap:18px
            }
            .card{
                background:var(--surface);
                border-radius:13px;
                border:1px solid var(--border);
                overflow:hidden
            }
            .card-hd{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:16px 20px;
                border-bottom:1px solid #f1f5f9
            }
            .card-title{
                font-size:.9rem;
                font-weight:700;
                color:var(--text);
                display:flex;
                align-items:center;
                gap:7px
            }
            .card-title i{
                color:var(--primary)
            }
            .card-link{
                color:var(--primary);
                text-decoration:none;
                font-size:.8rem;
                font-weight:600
            }
            .card-link:hover{
                text-decoration:underline
            }
            /* Table */
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
                font-size:.73rem;
                text-transform:uppercase;
                letter-spacing:.5px;
                border-bottom:1px solid var(--border)
            }
            td{
                padding:11px 14px;
                border-bottom:1px solid #f8fafc;
                vertical-align:middle
            }
            tr:last-child td{
                border-bottom:none
            }
            tr:hover td{
                background:#fafbff
            }
            /* Badges */
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.73rem;
                font-weight:600;
                white-space:nowrap
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
            /* Quick actions */
            .qa-grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:9px;
                padding:16px 18px
            }
            .qa{
                display:flex;
                flex-direction:column;
                gap:6px;
                padding:14px;
                border-radius:11px;
                border:1.5px solid var(--border);
                text-decoration:none;
                transition:.15s;
                background:var(--surface)
            }
            .qa:hover{
                border-color:var(--primary);
                background:#fafbff;
                transform:translateY(-1px)
            }
            .qa-icon{
                font-size:1.25rem
            }
            .qa-name{
                font-size:.8rem;
                font-weight:600;
                color:var(--text)
            }
            .qa-desc{
                font-size:.72rem;
                color:var(--muted)
            }
            /* Empty */
            .empty{
                text-align:center;
                padding:36px;
                color:var(--muted);
                font-size:.84rem
            }
            .empty i{
                font-size:2.2rem;
                display:block;
                margin-bottom:8px;
                opacity:.35
            }
        </style>
    </head><body>
        <%-- SIDEBAR --%>
        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-bolt"></i></div>
                <div><div class="sb-name">CRM System</div><div class="sb-sub">Khách hàng</div></div>
            </div>
            <nav class="sb-nav">
    <div class="sb-lbl">Tổng quan</div>
    <a href="<%=ctx%>/customerDashboard"        class="sb-item on"><i class="fas fa-home"></i> Trang chủ</a>
    <div class="sb-lbl">Dịch vụ</div>
    <a href="<%=ctx%>/customerServiceRequests"  class="sb-item"><i class="fas fa-clipboard-list"></i> Yêu cầu sửa chữa<%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%></a>
    <a href="<%=ctx%>/customerContracts"        class="sb-item"><i class="fas fa-file-contract"></i> Hợp đồng</a>
    <a href="<%=ctx%>/customerEquipment"        class="sb-item"><i class="fas fa-desktop"></i> Thiết bị của tôi</a>
    <div class="sb-lbl">Mua hàng</div>
    <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item"><i class="fas fa-puzzle-piece"></i> Linh kiện</a>
    <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Thiết bị</a>
    <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item">
        <i class="fas fa-shopping-cart"></i> Giỏ hàng
        <%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%>
    </a>
    <div class="sb-lbl">Tài chính</div>
    <a href="<%=ctx%>/customerInvoices"         class="sb-item"><i class="fas fa-receipt"></i> Hóa đơn<%if(unpaidInv>0){%><span class="sb-badge"><%=unpaidInv%></span><%}%></a>
    <div class="sb-lbl">Hỗ trợ</div>
    <a href="<%=ctx%>/customerChat"             class="sb-item"><i class="fas fa-comment-dots"></i> Chat hỗ trợ<%if(unreadChat>0){%><span class="sb-badge"><%=unreadChat%></span><%}%></a>
</nav>
            <div class="sb-foot">
                <div class="sb-user">
                    <div class="sb-ava"><%=me.getFullName().substring(0,1).toUpperCase()%></div>
                    <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Khách hàng</div></div>
                </div>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
            </div>
        </aside>

        <%-- MAIN --%>
        <main class="main">
            <div class="topbar">
                <div>
                    <div class="topbar-title">Xin chào, <%=me.getFullName()%>! 👋</div>
                    <div class="topbar-sub">Đây là tổng quan tài khoản dịch vụ của bạn.</div>
                </div>
                <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-cta"><i class="fas fa-plus"></i> Tạo yêu cầu sửa chữa</a>
            </div>

            <%if(unpaidInv>0){%>
            <div class="alert-warn">
                <i class="fas fa-exclamation-triangle" style="color:var(--warning);font-size:1.1rem"></i>
                <div>Bạn có <strong><%=unpaidInv%> hóa đơn chưa thanh toán</strong>
                    <%if(unpaidAmt!=null&&unpaidAmt.compareTo(BigDecimal.ZERO)>0){%> · Tổng: <strong><%=nf.format(unpaidAmt)%> ₫</strong><%}%>
                    <a href="<%=ctx%>/customerInvoices?status=UNPAID">Xem ngay →</a>
                </div>
            </div>
            <%}%>

            <div class="stats">
                <div class="sc i-purple">
                    <div class="sc-icon"><i class="fas fa-file-contract"></i></div>
                    <div class="sc-val"><%=activeContracts%></div>
                    <div class="sc-lbl">Hợp đồng đang hoạt động</div>
                    <div class="sc-sub">Tổng <%=totalContracts%> hợp đồng</div>
                </div>
                <div class="sc i-blue">
                    <div class="sc-icon"><i class="fas fa-clipboard-list"></i></div>
                    <div class="sc-val"><%=totalSR%></div>
                    <div class="sc-lbl">Tổng yêu cầu sửa chữa</div>
                    <div class="sc-sub" style="color:var(--warning)"><%=pendingSR%> đang chờ duyệt</div>
                </div>
                <div class="sc i-green">
                    <div class="sc-icon"><i class="fas fa-check-circle"></i></div>
                    <div class="sc-val"><%=completedSR%></div>
                    <div class="sc-lbl">Yêu cầu hoàn thành</div>
                    <div class="sc-sub" style="color:var(--info)"><%=activeSR%> đang xử lý</div>
                </div>
                <div class="sc i-<%=unpaidInv>0?"red":"green"%>">
                    <div class="sc-icon"><i class="fas fa-file-invoice-dollar"></i></div>
                    <div class="sc-val"><%=unpaidInv%></div>
                    <div class="sc-lbl">Hóa đơn chưa thanh toán</div>
                    <div class="sc-sub"><%=unpaidAmt!=null&&unpaidAmt.compareTo(BigDecimal.ZERO)>0?nf.format(unpaidAmt)+" ₫":"Không có nợ"%></div>
                </div>
            </div>

            <div class="grid-2">
                <div class="card">
                    <div class="card-hd">
                        <div class="card-title"><i class="fas fa-history"></i> Yêu cầu gần đây</div>
                        <a href="<%=ctx%>/customerServiceRequests" class="card-link">Xem tất cả →</a>
                    </div>
                    <%if(recent.isEmpty()){%>
                    <div class="empty"><i class="fas fa-inbox"></i>Chưa có yêu cầu nào.<br>
                        <a href="<%=ctx%>/customerServiceRequests?action=create" style="color:var(--primary);font-weight:600;display:inline-block;margin-top:6px">+ Tạo yêu cầu đầu tiên</a>
                    </div>
                    <%}else{%>
                    <table><thead><tr><th>Mã</th><th>Tiêu đề</th><th>HĐ</th><th>Ưu tiên</th><th>Trạng thái</th><th>Ngày tạo</th></tr></thead>
                        <tbody><%for(ServiceRequest sr:recent){
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
                            %>
                            <tr>
                                <td><a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=sr.getId()%>" style="color:var(--primary);font-weight:700;font-family:monospace;font-size:.8rem"><%=sr.getRequestCode()%></a></td>
                                <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><%=sr.getTitle()%></td>
                                <td style="font-size:.78rem"><span style="background:<%="WARRANTY".equals(sr.getContractType())?"#d1fae5":"#dbeafe"%>;color:<%="WARRANTY".equals(sr.getContractType())?"#065f46":"#1e40af"%>;padding:2px 7px;border-radius:4px;font-weight:600"><%="WARRANTY".equals(sr.getContractType())?"BH":"BT"%></span></td>
                                <td><span class="b <%=pc%>"><%=sr.getPriorityLabel()%></span></td>
                                <td><span class="b <%=sc%>"><%=sr.getStatusLabel()%></span></td>
                                <td style="color:var(--muted);font-size:.78rem"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toLocalDate():"—"%></td>
                            </tr><%}%></tbody></table>
                            <%}%>
                </div>

                <div class="card">
                    <div class="card-hd"><div class="card-title"><i class="fas fa-bolt"></i> Thao tác nhanh</div></div>
                    <div class="qa-grid">
                        <a href="<%=ctx%>/customerServiceRequests?action=create" class="qa">
                            <div class="qa-icon">🔧</div><div class="qa-name">Tạo yêu cầu sửa</div><div class="qa-desc">Báo sự cố thiết bị</div>
                        </a>
                        <a href="<%=ctx%>/customerContracts" class="qa">
                            <div class="qa-icon">📄</div><div class="qa-name">Hợp đồng</div><div class="qa-desc">Bảo hành & bảo trì</div>
                        </a>
                        <a href="<%=ctx%>/customerEquipment" class="qa">
                            <div class="qa-icon">🖥️</div><div class="qa-name">Thiết bị</div><div class="qa-desc">Thiết bị của tôi</div>
                        </a>
                        <a href="<%=ctx%>/customerInvoices" class="qa">
                            <div class="qa-icon">💰</div><div class="qa-name">Hóa đơn</div><div class="qa-desc">Thanh toán & lịch sử</div>
                        </a>
                        <a href="<%=ctx%>/customerChat" class="qa" style="grid-column:span 2">
                            <div class="qa-icon">💬</div><div class="qa-name">Chat hỗ trợ</div>
                            <div class="qa-desc"><%=unreadChat>0?"<span style='color:var(--danger);font-weight:700'>"+unreadChat+" tin nhắn mới</span>":"Liên hệ nhân viên hỗ trợ"%></div>
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </body></html>
