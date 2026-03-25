<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Contract, model.CustomerEquipment, java.util.List" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"TECHNICIAN".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    Contract c=(Contract)request.getAttribute("contract");
    if(c==null){response.sendRedirect(request.getContextPath()+"/technicianContracts");return;}
    List<CustomerEquipment> equipList=c.getEquipmentList();
    if(equipList==null)equipList=new java.util.ArrayList<>();
    String ctx=request.getContextPath();
    String initials=(me.getFullName()!=null&&!me.getFullName().isEmpty())?me.getFullName().substring(0,1).toUpperCase():"T";
    String st=c.getStatus()!=null?c.getStatus():"";
    String bc="ACTIVE".equals(st)?"badge-active":"EXPIRED".equals(st)?"badge-expired":"badge-cancelled";
    String sl="ACTIVE".equals(st)?"Đang hiệu lực":"EXPIRED".equals(st)?"Hết hạn":"Đã hủy";
%>
<!DOCTYPE html><html lang="vi"><head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Contract Detail – DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root{--sb-bg:#1e1b4b;--sb-border:rgba(255,255,255,0.08);--sb-text:rgba(255,255,255,0.45);--sb-accent:#818cf8;--sb-accent-2:#a5b4fc;--sb-item-on:rgba(129,140,248,0.2);--sb-width:252px;--bg:#f3f4f9;--bg-card:#fff;--border-light:#e8ecf5;--border-light2:#f0f2fb;--text-h:#1e1b4b;--text-b:#374151;--text-m:#6b7280;--text-s:#9ca3af;--primary:#4f46e5;--primary-2:#6366f1;--green:#16a34a;--red:#dc2626;--amber:#d97706;}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Sora',sans-serif;background:var(--bg);color:var(--text-b);min-height:100vh;display:flex;}
        .sb{width:var(--sb-width);min-height:100vh;background:var(--sb-bg);display:flex;flex-direction:column;position:fixed;top:0;left:0;z-index:100;box-shadow:4px 0 24px rgba(0,0,0,0.15);}
        .sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border);}
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#818cf8,#a78bfa);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;flex-shrink:0;}
        .sb-name{color:#fff;font-size:1.05rem;font-weight:800}.sb-role{display:inline-flex;background:rgba(129,140,248,0.2);border:1px solid rgba(129,140,248,0.3);color:var(--sb-accent-2);font-size:.6rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:2px 8px;border-radius:20px;margin-top:3px;}
        .sb-nav{flex:1;padding:12px 10px;overflow-y:auto}.sb-lbl{color:rgba(255,255,255,0.22);font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:1.6px;padding:0 8px;margin:14px 0 5px;}
        .sb-item{display:flex;align-items:center;gap:9px;padding:8px 10px;border-radius:9px;margin-bottom:1px;color:var(--sb-text);text-decoration:none;font-size:.81rem;font-weight:500;transition:all .18s;border-left:2px solid transparent;}
        .sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.78rem;border-radius:8px;background:rgba(255,255,255,0.06);flex-shrink:0;}
        .sb-item.on{color:#fff;background:var(--sb-item-on);border-left-color:var(--sb-accent);}.sb-item.on i{background:rgba(129,140,248,0.3);color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){color:rgba(255,255,255,0.78);background:rgba(255,255,255,0.06);}
        .sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border)}
        .sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);margin-bottom:5px;text-decoration:none;}
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.8rem;font-weight:600}.sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem}
        .sb-logout{display:flex;align-items:center;gap:8px;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
        .sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1)}
        .main{margin-left:var(--sb-width);flex:1;display:flex;flex-direction:column;}
        .topbar{display:flex;justify-content:space-between;align-items:center;padding:16px 28px;background:#fff;border-bottom:1px solid var(--border-light);position:sticky;top:0;z-index:50;}
        .breadcrumb{display:flex;align-items:center;gap:6px;font-size:.78rem;color:var(--text-s);}
        .breadcrumb a{color:var(--primary-2);text-decoration:none}.breadcrumb a:hover{text-decoration:underline}
        .topbar-right{display:flex;gap:8px}
        .content{padding:24px 28px;display:grid;grid-template-columns:1fr 300px;gap:20px;align-items:start;}
        .card{background:var(--bg-card);border:1px solid var(--border-light);border-radius:16px;overflow:hidden;margin-bottom:16px;}
        .card-hd{display:flex;justify-content:space-between;align-items:center;padding:14px 18px;border-bottom:1px solid var(--border-light2);background:#fafbff;}
        .card-title{font-size:.87rem;font-weight:700;color:var(--text-h);display:flex;align-items:center;gap:8px;}
        .card-body{padding:18px}
        .two-col{display:grid;grid-template-columns:1fr 1fr;gap:14px}
        .field{margin-bottom:14px}.field label{font-size:.72rem;font-weight:700;color:var(--text-s);text-transform:uppercase;letter-spacing:.6px;display:block;margin-bottom:4px}
        .field-val{font-size:.87rem;color:var(--text-b);font-weight:500}
        .badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;}
        .badge-active{background:#d1fae5;color:#065f46}.badge-expired{background:#fef3c7;color:#92400e}.badge-cancelled{background:#f3f4f6;color:#6b7280}
        .badge-warranty{background:#ede9fe;color:#5b21b6}.badge-maintenance{background:#fce7f3;color:#9d174d}
        .badge-inuse{background:#dbeafe;color:#1e40af}.badge-avail{background:#d1fae5;color:#065f46}
        .badge-faulty{background:#fef3c7;color:#92400e}.badge-retired{background:#f3f4f6;color:#6b7280}
        .badge-warranty-ok{background:#d1fae5;color:#065f46}.badge-warranty-exp{background:#fee2e2;color:#991b1b}
        .badge-default{background:#e0e7ff;color:#3730a3}
        .btn{padding:8px 16px;border-radius:9px;font-family:'Sora',sans-serif;font-size:.8rem;font-weight:700;cursor:pointer;border:none;text-decoration:none;display:inline-flex;align-items:center;gap:6px;transition:all .18s;}
        .btn-outline{background:#fff;border:1px solid var(--border-light);color:var(--text-b)}.btn-outline:hover{border-color:var(--primary-2);color:var(--primary-2)}
        .btn-full{width:100%;justify-content:center;margin-bottom:8px}
        table{width:100%;border-collapse:collapse;font-size:.8rem}
        th{padding:9px 14px;text-align:left;color:var(--text-s);font-weight:700;font-size:.66rem;text-transform:uppercase;letter-spacing:.7px;border-bottom:1px solid var(--border-light2);background:#fafbff;}
        td{padding:11px 14px;border-bottom:1px solid var(--border-light2);vertical-align:middle;}
        tr:last-child td{border-bottom:none}
        tbody tr:hover td{background:#f7f8ff}
        .equip-icon{width:36px;height:36px;border-radius:9px;background:var(--primary-light);display:flex;align-items:center;justify-content:center;color:var(--primary-2);font-size:.85rem;flex-shrink:0;}
    </style>
</head><body>
<aside class="sb">
    <div class="sb-brand"><div class="sb-logo"><i class="fas fa-tools"></i></div><div><div class="sb-name">DRSMS</div><div class="sb-role">Technician</div></div></div>
    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div><a href="<%=ctx%>/technicianDashboard" class="sb-item"><i class="fas fa-th-large"></i> Dashboard</a>
        <div class="sb-lbl">Work</div>
        <a href="<%=ctx%>/technicianTasks" class="sb-item"><i class="fas fa-tasks"></i> My Tasks</a>
        <a href="<%=ctx%>/technicianWorkHistory" class="sb-item"><i class="fas fa-history"></i> Work History</a>
        <div class="sb-lbl">Reference</div>
        <a href="<%=ctx%>/technicianContracts" class="sb-item on"><i class="fas fa-file-contract"></i> Contracts</a>
        <a href="<%=ctx%>/technicianContracts?action=equipment" class="sb-item"><i class="fas fa-desktop"></i> Equipment</a>
    </nav>
    <div class="sb-foot">
        <a href="<%=ctx%>/profile" class="sb-user"><div class="sb-ava"><%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%><img src="<%=ctx%><%=me.getAvatarUrl()%>" alt=""><%}else{%><%=initials%><%}%></div><div><div class="sb-uname"><%=me.getFullName()!=null?me.getFullName():me.getUsername()%></div><div class="sb-urole">Technician</div></div></a>
        <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
    </div>
</aside>
<main class="main">
    <div class="topbar">
        <div>
            <div class="breadcrumb"><a href="<%=ctx%>/technicianContracts">Contracts</a> <i class="fas fa-chevron-right" style="font-size:.6rem"></i> <span><%=c.getContractCode()%></span></div>
            <div style="font-size:1rem;font-weight:700;color:var(--text-h);margin-top:4px">Chi tiết hợp đồng</div>
        </div>
        <div class="topbar-right"><a href="<%=ctx%>/technicianContracts" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Quay lại</a></div>
    </div>
    <div class="content">
        <div>
            <!-- Contract Info -->
            <div class="card">
                <div class="card-hd"><span class="card-title"><i class="fas fa-file-contract"></i> Thông tin hợp đồng</span><span class="badge <%=bc%>"><%=sl%></span></div>
                <div class="card-body">
                    <div class="two-col">
                        <div class="field"><label>Mã hợp đồng</label><div class="field-val" style="font-weight:700;color:var(--primary-2)"><%=c.getContractCode()%></div></div>
                        <div class="field"><label>Loại hợp đồng</label>
                            <span class="badge <%="WARRANTY".equals(c.getContractType())?"badge-warranty":"badge-maintenance"%>">
                                <%="WARRANTY".equals(c.getContractType())?"Bảo hành":"Bảo trì"%>
                            </span>
                        </div>
                        <div class="field"><label>Khách hàng</label><div class="field-val" style="font-weight:600"><%=c.getCustomerName()!=null?c.getCustomerName():"—"%></div></div>
                        <div class="field"><label>Người tạo</label><div class="field-val"><%=c.getCreatedByName()!=null?c.getCreatedByName():"—"%></div></div>
                        <div class="field"><label>Ngày bắt đầu</label><div class="field-val"><%=c.getStartDate()!=null?c.getStartDate().toString():"—"%></div></div>
                        <div class="field"><label>Ngày kết thúc</label><div class="field-val"><%=c.getEndDate()!=null?c.getEndDate().toString():"—"%></div></div>
                    </div>
                    <%if(c.getNotes()!=null&&!c.getNotes().isEmpty()){%>
                    <div class="field"><label>Ghi chú</label>
                        <div style="background:#f8f9ff;border:1px solid var(--border-light2);border-radius:10px;padding:12px;font-size:.84rem;line-height:1.6"><%=c.getNotes()%></div>
                    </div>
                    <%}%>
                </div>
            </div>

            <!-- Equipment List -->
            <div class="card">
                <div class="card-hd"><span class="card-title"><i class="fas fa-desktop"></i> Thiết bị trong hợp đồng</span><span class="badge badge-default"><%=equipList.size()%> thiết bị</span></div>
                <%if(equipList.isEmpty()){%>
                <div style="text-align:center;padding:30px;color:var(--text-s)"><i class="fas fa-desktop" style="font-size:1.8rem;opacity:.2;display:block;margin-bottom:10px"></i>Không có thiết bị</div>
                <%}else{%>
                <table>
                    <thead><tr><th>Thiết bị</th><th>Serial</th><th>Loại</th><th>Trạng thái kho</th><th>Bảo hành</th><th>Nguồn gốc</th></tr></thead>
                    <tbody>
                    <%for(CustomerEquipment eq:equipList){
                        String us=eq.getUnitStatus()!=null?eq.getUnitStatus():"";
                        String ub="AVAILABLE".equals(us)?"badge-avail":"INUSE".equals(us)?"badge-inuse":"FAULTY".equals(us)?"badge-faulty":"badge-retired";
                        String ul="AVAILABLE".equals(us)?"Có sẵn":"INUSE".equals(us)?"Đang dùng":"FAULTY".equals(us)?"Lỗi":"Ngừng dùng";
                    %>
                    <tr>
                        <td>
                            <div style="display:flex;align-items:center;gap:10px">
                                <div class="equip-icon"><i class="fas fa-desktop"></i></div>
                                <div>
                                    <div style="font-weight:600;font-size:.83rem"><%=eq.getDisplayName()%></div>
                                    <%if(eq.getCategoryName()!=null){%><div style="font-size:.72rem;color:var(--text-s)"><%=eq.getCategoryName()%></div><%}%>
                                </div>
                            </div>
                        </td>
                        <td style="font-size:.78rem;font-family:monospace;color:var(--text-m)"><%=eq.getDisplaySerial()%></td>
                        <td style="font-size:.78rem"><span class="badge <%="EXTERNAL".equals(eq.getSource())?"badge-default":"badge-maintenance"%>"><%="EXTERNAL".equals(eq.getSource())?"Ngoài hệ thống":"Trong hệ thống"%></span></td>
                        <td><%if(!"EXTERNAL".equals(eq.getSource())&&eq.getUnitStatus()!=null){%><span class="badge <%=ub%>"><%=ul%></span><%}else{%><span style="color:var(--text-s);font-size:.78rem">—</span><%}%></td>
                        <td>
                            <%if(eq.getWarrantyExpires()!=null){%>
                            <span class="badge <%=eq.isUnderWarranty()?"badge-warranty-ok":"badge-warranty-exp"%>">
                                <%=eq.isUnderWarranty()?"Còn hạn":"Hết hạn"%> (<%=eq.getWarrantyExpires()%>)
                            </span>
                            <%}else{%><span style="color:var(--text-s);font-size:.78rem">—</span><%}%>
                        </td>
                        <td style="font-size:.76rem;color:var(--text-s)"><%=eq.getPurchasedDate()!=null?eq.getPurchasedDate().toString():"—"%></td>
                    </tr>
                    <%}%>
                    </tbody>
                </table>
                <%}%>
            </div>
        </div>

        <!-- Right sidebar -->
        <div>
            <div class="card">
                <div class="card-hd"><span class="card-title"><i class="fas fa-chart-bar"></i> Tóm tắt</span></div>
                <div class="card-body">
                    <div style="display:flex;flex-direction:column;gap:14px">
                        <div style="display:flex;justify-content:space-between;align-items:center;padding:10px;background:#f8f9ff;border-radius:10px">
                            <span style="font-size:.8rem;color:var(--text-m)"><i class="fas fa-desktop" style="margin-right:6px;color:var(--primary-2)"></i>Thiết bị</span>
                            <strong style="color:var(--text-h)"><%=equipList.size()%></strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;align-items:center;padding:10px;background:#f8f9ff;border-radius:10px">
                            <span style="font-size:.8rem;color:var(--text-m)"><i class="fas fa-ticket-alt" style="margin-right:6px;color:var(--primary-2)"></i>Service Request</span>
                            <strong style="color:var(--text-h)"><%=c.getServiceRequestCount()%></strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;align-items:center;padding:10px;background:#f8f9ff;border-radius:10px">
                            <span style="font-size:.8rem;color:var(--text-m)"><i class="fas fa-calendar-alt" style="margin-right:6px;color:var(--primary-2)"></i>Còn lại</span>
                            <strong style="color:<%=c.isActive()?"var(--green)":"var(--red)"%>">
                                <%if(c.isActive()&&c.getEndDate()!=null){
                                    long days=java.time.temporal.ChronoUnit.DAYS.between(java.time.LocalDate.now(),c.getEndDate());
                                    out.print(days+" ngày");
                                }else{out.print("—");}%>
                            </strong>
                        </div>
                    </div>
                    <div style="margin-top:16px">
                        <a href="<%=ctx%>/technicianContracts" class="btn btn-outline btn-full"><i class="fas fa-arrow-left"></i> Về danh sách</a>
                        <a href="<%=ctx%>/technicianTasks" class="btn btn-outline btn-full" style="margin-top:8px;margin-bottom:0"><i class="fas fa-tasks"></i> My Tasks</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
</body></html>
