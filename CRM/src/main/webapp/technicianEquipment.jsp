<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.EquipmentType, java.util.List, java.text.NumberFormat, java.util.Locale" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"TECHNICIAN".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<EquipmentType> equipTypes=(List<EquipmentType>)request.getAttribute("equipTypes");
    int total=request.getAttribute("total")!=null?(Integer)request.getAttribute("total"):0;
    int page=request.getAttribute("page")!=null?(Integer)request.getAttribute("page"):1;
    int totalPages=request.getAttribute("totalPages")!=null?(Integer)request.getAttribute("totalPages"):1;
    String keyword=request.getAttribute("keyword")!=null?(String)request.getAttribute("keyword"):"";
    String ctx=request.getContextPath();
    String initials=(me.getFullName()!=null&&!me.getFullName().isEmpty())?me.getFullName().substring(0,1).toUpperCase():"T";
    NumberFormat nf=NumberFormat.getNumberInstance(new Locale("vi","VN"));
    if(equipTypes==null)equipTypes=new java.util.ArrayList<>();
%>
<!DOCTYPE html><html lang="vi"><head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Equipment – DRSMS</title>
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
        .topbar{display:flex;justify-content:space-between;align-items:center;padding:18px 28px;background:#fff;border-bottom:1px solid var(--border-light);position:sticky;top:0;z-index:50;}
        .topbar-title{font-size:1rem;font-weight:700;color:var(--text-h)}.topbar-sub{font-size:.75rem;color:var(--text-s);margin-top:1px}.topbar-right{display:flex;gap:8px}
        .content{padding:24px 28px;flex:1}
        .card{background:var(--bg-card);border:1px solid var(--border-light);border-radius:16px;overflow:hidden;}
        .card-hd{display:flex;justify-content:space-between;align-items:center;padding:14px 18px;border-bottom:1px solid var(--border-light2);background:#fafbff;}
        .card-title{font-size:.87rem;font-weight:700;color:var(--text-h);display:flex;align-items:center;gap:8px;}
        .search-bar{padding:16px 18px;border-bottom:1px solid var(--border-light2);display:flex;gap:10px;flex-wrap:wrap;}
        .search-bar input{flex:1;min-width:200px;padding:8px 12px;border:1px solid var(--border-light);border-radius:9px;font-family:'Sora',sans-serif;font-size:.8rem;outline:none;}
        .btn{padding:8px 16px;border-radius:9px;font-family:'Sora',sans-serif;font-size:.8rem;font-weight:700;cursor:pointer;border:none;text-decoration:none;display:inline-flex;align-items:center;gap:6px;transition:all .18s;}
        .btn-primary{background:var(--primary);color:#fff}.btn-primary:hover{background:var(--primary-2)}
        .btn-outline{background:#fff;border:1px solid var(--border-light);color:var(--text-b)}.btn-outline:hover{border-color:var(--primary-2);color:var(--primary-2)}
        .btn-sm{padding:5px 11px;font-size:.74rem}
        .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px;padding:20px;}
        .eq-card{background:#fff;border:1px solid var(--border-light);border-radius:14px;overflow:hidden;transition:all .2s;text-decoration:none;color:inherit;display:block;}
        .eq-card:hover{transform:translateY(-3px);box-shadow:0 8px 28px rgba(79,70,229,0.1);border-color:rgba(99,102,241,0.3);}
        .eq-img{height:140px;background:linear-gradient(135deg,#f0f4ff,#e8ecf5);display:flex;align-items:center;justify-content:center;overflow:hidden;}
        .eq-img img{width:100%;height:100%;object-fit:cover}
        .eq-img-placeholder{font-size:2.5rem;color:var(--primary-2);opacity:.4}
        .eq-body{padding:14px}
        .eq-model{font-size:.9rem;font-weight:700;color:var(--text-h);margin-bottom:3px}
        .eq-cat{font-size:.73rem;color:var(--text-s);margin-bottom:10px}
        .eq-stats{display:flex;gap:8px;flex-wrap:wrap}
        .eq-stat{font-size:.7rem;padding:3px 8px;border-radius:6px;font-weight:600}
        .eq-stat.g{background:#d1fae5;color:#065f46}.eq-stat.b{background:#dbeafe;color:#1e40af}
        .eq-stat.r{background:#fee2e2;color:#991b1b}.eq-stat.y{background:#fef3c7;color:#92400e}
        .badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;}
        .badge-default{background:#e0e7ff;color:#3730a3}
        .pager{display:flex;align-items:center;justify-content:center;gap:6px;padding:16px;}
        .pager a,.pager span{width:32px;height:32px;display:flex;align-items:center;justify-content:center;border-radius:8px;font-size:.78rem;font-weight:600;text-decoration:none;color:var(--text-b);border:1px solid var(--border-light);}
        .pager a:hover{border-color:var(--primary-2);color:var(--primary-2)}.pager .active{background:var(--primary);color:#fff;border-color:var(--primary);}
        .empty{text-align:center;padding:40px;color:var(--text-s)}.empty i{font-size:2rem;display:block;margin-bottom:12px;opacity:.2}
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
        <div><div class="topbar-title">Equipment</div><div class="topbar-sub">Kho thiết bị trong hệ thống — chỉ xem</div></div>
        <div class="topbar-right"><a href="<%=ctx%>/technicianContracts" class="btn btn-outline btn-sm"><i class="fas fa-file-contract"></i> Contracts</a></div>
    </div>
    <div class="content">
        <div class="card">
            <form method="get" action="<%=ctx%>/technicianContracts">
                <input type="hidden" name="action" value="equipment">
                <div class="search-bar">
                    <input type="text" name="keyword" value="<%=keyword%>" placeholder="Tìm theo model, mô tả...">
                    <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Tìm</button>
                    <a href="<%=ctx%>/technicianContracts?action=equipment" class="btn btn-outline">Reset</a>
                </div>
            </form>
            <div class="card-hd"><span class="card-title"><i class="fas fa-desktop"></i> Danh sách thiết bị</span><span class="badge badge-default"><%=total%> loại</span></div>
            <%if(equipTypes.isEmpty()){%>
            <div class="empty"><i class="fas fa-desktop"></i>Không có thiết bị nào</div>
            <%}else{%>
            <div class="grid">
                <%for(EquipmentType et:equipTypes){%>
                <a href="<%=ctx%>/technicianContracts?action=equipmentDetail&id=<%=et.getId()%>" class="eq-card">
                    <div class="eq-img">
                        <%if(et.getImageUrl()!=null&&!et.getImageUrl().isEmpty()){%>
                        <img src="<%=ctx%><%=et.getImageUrl()%>" alt="<%=et.getModel()%>">
                        <%}else{%><div class="eq-img-placeholder"><i class="fas fa-desktop"></i></div><%}%>
                    </div>
                    <div class="eq-body">
                        <div class="eq-model"><%=et.getModel()%></div>
                        <div class="eq-cat"><%=et.getCategoryName()!=null?et.getCategoryName():""%> &nbsp;·&nbsp; <%=nf.format((long)et.getUnitPrice())%> ₫</div>
                        <div class="eq-stats">
                            <span class="eq-stat g"><i class="fas fa-check-circle" style="margin-right:3px"></i><%=et.getAvailableUnits()%> sẵn</span>
                            <span class="eq-stat b"><i class="fas fa-tools" style="margin-right:3px"></i><%=et.getInuseUnits()%> dùng</span>
                            <%if(et.getFaultyUnits()>0){%><span class="eq-stat r"><i class="fas fa-times-circle" style="margin-right:3px"></i><%=et.getFaultyUnits()%> lỗi</span><%}%>
                            <span class="eq-stat y">Tổng: <%=et.getTotalUnits()%></span>
                        </div>
                    </div>
                </a>
                <%}%>
            </div>
            <%}%>
            <%if(totalPages>1){%>
            <div class="pager">
                <%if(page>1){%><a href="?action=equipment&page=<%=page-1%>&keyword=<%=keyword%>"><i class="fas fa-chevron-left"></i></a><%}%>
                <%for(int p2=Math.max(1,page-2);p2<=Math.min(totalPages,page+2);p2++){%>
                <<%=p2==page?"span class=\"active\"":"a href=\"?action=equipment&page="+p2+"&keyword="+keyword+"\""%>><%=p2%></<%=p2==page?"span":"a"%>>
                <%}%>
                <%if(page<totalPages){%><a href="?action=equipment&page=<%=page+1%>&keyword=<%=keyword%>"><i class="fas fa-chevron-right"></i></a><%}%>
            </div>
            <%}%>
        </div>
    </div>
</main>
</body></html>
