<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.EquipmentType, model.EquipmentUnit, java.util.List, java.text.NumberFormat, java.util.Locale, java.time.format.DateTimeFormatter" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"TECHNICIAN".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    EquipmentType et=(EquipmentType)request.getAttribute("equipType");
    if(et==null){response.sendRedirect(request.getContextPath()+"/technicianContracts?action=equipment");return;}
    List<EquipmentUnit> units=(List<EquipmentUnit>)request.getAttribute("units");
    if(units==null)units=new java.util.ArrayList<>();
    String ctx=request.getContextPath();
    String initials=(me.getFullName()!=null&&!me.getFullName().isEmpty())?me.getFullName().substring(0,1).toUpperCase():"T";
    NumberFormat nf=NumberFormat.getNumberInstance(new Locale("vi","VN"));
    DateTimeFormatter dtf=DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html><html lang="vi"><head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Equipment Detail – DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root{--sb-bg:#1e1b4b;--sb-border:rgba(255,255,255,0.08);--sb-text:rgba(255,255,255,0.45);--sb-accent:#818cf8;--sb-accent-2:#a5b4fc;--sb-item-on:rgba(129,140,248,0.2);--sb-width:252px;--bg:#f3f4f9;--bg-card:#fff;--border-light:#e8ecf5;--border-light2:#f0f2fb;--text-h:#1e1b4b;--text-b:#374151;--text-m:#6b7280;--text-s:#9ca3af;--primary:#4f46e5;--primary-2:#6366f1;--primary-light:#ede9fe;--green:#16a34a;--red:#dc2626;--amber:#d97706;}
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
        .breadcrumb a{color:var(--primary-2);text-decoration:none}
        .content{padding:24px 28px;display:grid;grid-template-columns:1fr 300px;gap:20px;align-items:start;}
        .card{background:var(--bg-card);border:1px solid var(--border-light);border-radius:16px;overflow:hidden;margin-bottom:16px;}
        .card-hd{display:flex;justify-content:space-between;align-items:center;padding:14px 18px;border-bottom:1px solid var(--border-light2);background:#fafbff;}
        .card-title{font-size:.87rem;font-weight:700;color:var(--text-h);display:flex;align-items:center;gap:8px;}
        .card-body{padding:18px}
        .field{margin-bottom:14px}.field label{font-size:.72rem;font-weight:700;color:var(--text-s);text-transform:uppercase;letter-spacing:.6px;display:block;margin-bottom:4px}
        .field-val{font-size:.87rem;color:var(--text-b);font-weight:500}
        .two-col{display:grid;grid-template-columns:1fr 1fr;gap:14px}
        .badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;}
        .badge-avail{background:#d1fae5;color:#065f46}.badge-inuse{background:#dbeafe;color:#1e40af}
        .badge-faulty{background:#fef3c7;color:#92400e}.badge-retired{background:#f3f4f6;color:#6b7280}
        .badge-default{background:#e0e7ff;color:#3730a3}
        .btn{padding:8px 16px;border-radius:9px;font-family:'Sora',sans-serif;font-size:.8rem;font-weight:700;cursor:pointer;border:none;text-decoration:none;display:inline-flex;align-items:center;gap:6px;transition:all .18s;}
        .btn-outline{background:#fff;border:1px solid var(--border-light);color:var(--text-b)}.btn-outline:hover{border-color:var(--primary-2);color:var(--primary-2)}
        .btn-full{width:100%;justify-content:center;margin-bottom:8px}
        table{width:100%;border-collapse:collapse;font-size:.8rem}
        th{padding:9px 14px;text-align:left;color:var(--text-s);font-weight:700;font-size:.66rem;text-transform:uppercase;letter-spacing:.7px;border-bottom:1px solid var(--border-light2);background:#fafbff;}
        td{padding:11px 14px;border-bottom:1px solid var(--border-light2);vertical-align:middle;}
        tr:last-child td{border-bottom:none}
        tbody tr:hover td{background:#f7f8ff}
        .stat-mini{display:flex;align-items:center;justify-content:space-between;padding:10px 14px;border-radius:10px;background:#f8f9ff;border:1px solid var(--border-light2);margin-bottom:8px;}
        .stat-mini:last-child{margin-bottom:0}
        .eq-hero{height:200px;background:linear-gradient(135deg,#f0f4ff,#e8ecf5);display:flex;align-items:center;justify-content:center;overflow:hidden;}
        .eq-hero img{width:100%;height:100%;object-fit:cover}
        .eq-hero-placeholder{font-size:4rem;color:var(--primary-2);opacity:.25}
    </style>
</head><body>
<aside class="sb">
    <div class="sb-brand"><div class="sb-logo"><i class="fas fa-tools"></i></div><div><div class="sb-name">DRSMS</div><div class="sb-role">Technician</div></div></div>
    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div><a href="<%=ctx%>/technicianDashboard" class="sb-item"><i class="fas fa-th-large"></i> Dashboard</a>
        <div class="sb-lbl">Work</div>
        <a href="<%=ctx%>/technicianTasks" class="sb-item"><i class="fas fa-tasks"></i> My Tasks</a>
        <a href="<%=ctx%>/technicianReports" class="sb-item"><i class="fas fa-clipboard-list"></i> Repair Reports</a>
        <a href="<%=ctx%>/technicianWorkHistory" class="sb-item"><i class="fas fa-history"></i> Work History</a>
        <div class="sb-lbl">Reference</div>
        <a href="<%=ctx%>/technicianContracts" class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
        <a href="<%=ctx%>/technicianContracts?action=equipment" class="sb-item on"><i class="fas fa-desktop"></i> Equipment</a>
    </nav>
    <div class="sb-foot">
        <a href="<%=ctx%>/profile" class="sb-user"><div class="sb-ava"><%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%><img src="<%=ctx%><%=me.getAvatarUrl()%>" alt=""><%}else{%><%=initials%><%}%></div><div><div class="sb-uname"><%=me.getFullName()!=null?me.getFullName():me.getUsername()%></div><div class="sb-urole">Technician</div></div></a>
        <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
    </div>
</aside>
<main class="main">
    <div class="topbar">
        <div>
            <div class="breadcrumb"><a href="<%=ctx%>/technicianContracts?action=equipment">Equipment</a> <i class="fas fa-chevron-right" style="font-size:.6rem"></i> <span><%=et.getModel()%></span></div>
            <div style="font-size:1rem;font-weight:700;color:var(--text-h);margin-top:4px">Chi tiết thiết bị</div>
        </div>
        <a href="<%=ctx%>/technicianContracts?action=equipment" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Quay lại</a>
    </div>
    <div class="content">
        <div>
            <!-- Hero image + info -->
            <div class="card">
                <%if(et.getImageUrl()!=null&&!et.getImageUrl().isEmpty()){%>
                <div class="eq-hero"><img src="<%=ctx%><%=et.getImageUrl()%>" alt="<%=et.getModel()%>"></div>
                <%}else{%>
                <div class="eq-hero"><div class="eq-hero-placeholder"><i class="fas fa-desktop"></i></div></div>
                <%}%>
                <div class="card-body">
                    <div class="two-col">
                        <div class="field"><label>Model</label><div class="field-val" style="font-size:1.1rem;font-weight:800;color:var(--text-h)"><%=et.getModel()%></div></div>
                        <div class="field"><label>Danh mục</label><div class="field-val"><%=et.getCategoryName()!=null?et.getCategoryName():"—"%></div></div>
                        <div class="field"><label>Giá đơn vị</label><div class="field-val" style="color:var(--primary-2);font-weight:700"><%=nf.format((long)et.getUnitPrice())%> ₫</div></div>
                        <div class="field"><label>Cập nhật bởi</label><div class="field-val"><%=et.getUpdatedByUsername()!=null?et.getUpdatedByUsername():"—"%></div></div>
                    </div>
                    <%if(et.getDescription()!=null&&!et.getDescription().isEmpty()){%>
                    <div class="field"><label>Mô tả</label>
                        <div style="background:#f8f9ff;border:1px solid var(--border-light2);border-radius:10px;padding:12px;font-size:.84rem;line-height:1.6"><%=et.getDescription()%></div>
                    </div>
                    <%}%>
                </div>
            </div>

            <!-- Units table -->
            <div class="card">
                <div class="card-hd"><span class="card-title"><i class="fas fa-barcode"></i> Danh sách đơn vị (Serial)</span><span class="badge badge-default"><%=units.size()%> units</span></div>
                <%if(units.isEmpty()){%>
                <div style="text-align:center;padding:30px;color:var(--text-s)"><i class="fas fa-barcode" style="font-size:1.8rem;opacity:.2;display:block;margin-bottom:10px"></i>Không có unit nào</div>
                <%}else{%>
                <table>
                    <thead><tr><th>#</th><th>Serial Number</th><th>Trạng thái</th><th>Ngày nhập</th></tr></thead>
                    <tbody>
                    <%int ui=0;for(EquipmentUnit u:units){ui++;
                        String us=u.getStatus()!=null?u.getStatus():"";
                        String ub="AVAILABLE".equals(us)?"badge-avail":"INUSE".equals(us)?"badge-inuse":"FAULTY".equals(us)?"badge-faulty":"badge-retired";
                        String ul="AVAILABLE".equals(us)?"Có sẵn":"INUSE".equals(us)?"Đang dùng":"FAULTY".equals(us)?"Lỗi":"Ngừng dùng";
                    %>
                    <tr>
                        <td style="color:var(--text-s);font-size:.75rem"><%=ui%></td>
                        <td style="font-family:monospace;font-weight:600;color:var(--text-h)"><%=u.getSerialNumber()!=null?u.getSerialNumber():"—"%></td>
                        <td><span class="badge <%=ub%>"><%=ul%></span></td>
                        <td style="font-size:.76rem;color:var(--text-s)"><%=u.getCreatedAt()!=null?u.getCreatedAt().format(dtf):"—"%></td>
                    </tr>
                    <%}%>
                    </tbody>
                </table>
                <%}%>
            </div>
        </div>

        <!-- Right sidebar stats -->
        <div>
            <div class="card">
                <div class="card-hd"><span class="card-title"><i class="fas fa-chart-bar"></i> Thống kê tồn kho</span></div>
                <div class="card-body">
                    <div class="stat-mini"><span style="font-size:.8rem;color:var(--text-m)">Tổng units</span><strong><%=et.getTotalUnits()%></strong></div>
                    <div class="stat-mini"><span style="font-size:.8rem;color:var(--green)"><i class="fas fa-check-circle" style="margin-right:5px"></i>Có sẵn</span><strong style="color:var(--green)"><%=et.getAvailableUnits()%></strong></div>
                    <div class="stat-mini"><span style="font-size:.8rem;color:var(--amber)"><i class="fas fa-tools" style="margin-right:5px"></i>Đang dùng</span><strong style="color:var(--amber)"><%=et.getInuseUnits()%></strong></div>
                    <div class="stat-mini"><span style="font-size:.8rem;color:var(--red)"><i class="fas fa-times-circle" style="margin-right:5px"></i>Lỗi</span><strong style="color:var(--red)"><%=et.getFaultyUnits()%></strong></div>
                    <div class="stat-mini" style="margin-bottom:0"><span style="font-size:.8rem;color:var(--text-s)"><i class="fas fa-archive" style="margin-right:5px"></i>Ngừng dùng</span><strong><%=et.getRetiredUnits()%></strong></div>
                    <div style="margin-top:16px">
                        <a href="<%=ctx%>/technicianContracts?action=equipment" class="btn btn-outline btn-full"><i class="fas fa-arrow-left"></i> Về danh sách</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
</body></html>
