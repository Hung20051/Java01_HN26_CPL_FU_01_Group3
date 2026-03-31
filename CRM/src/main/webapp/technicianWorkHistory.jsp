<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.TechnicianTaskDAO.TaskRow, java.util.List, java.time.format.DateTimeFormatter" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"TECHNICIAN".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    @SuppressWarnings("unchecked")
    List<TaskRow> history=(List<TaskRow>)request.getAttribute("history");
    int total=request.getAttribute("total")!=null?(Integer)request.getAttribute("total"):0;
    int page=request.getAttribute("page")!=null?(Integer)request.getAttribute("page"):1;
    int totalPages=request.getAttribute("totalPages")!=null?(Integer)request.getAttribute("totalPages"):1;
    String ctx=request.getContextPath();
    String initials=(me.getFullName()!=null&&!me.getFullName().isEmpty())?me.getFullName().substring(0,1).toUpperCase():"T";
    DateTimeFormatter dtf=DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    if(history==null)history=new java.util.ArrayList<>();
%>
<!DOCTYPE html><html lang="vi"><head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Work History – DRSMS</title>
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
        .topbar{display:flex;justify-content:space-between;align-items:center;padding:18px 28px;background:#fff;border-bottom:1px solid var(--border-light);position:sticky;top:0;z-index:50;}
        .topbar-title{font-size:1rem;font-weight:700;color:var(--text-h)}.topbar-sub{font-size:.75rem;color:var(--text-s);margin-top:1px}.topbar-right{display:flex;gap:8px}
        .content{padding:24px 28px;flex:1}
        /* INFO STRIP */
        .info-strip{background:linear-gradient(135deg,#1e1b4b,#3730a3);border-radius:14px;padding:18px 22px;color:#fff;display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;}
        .info-strip-text{font-size:.82rem;opacity:.8}
        .info-strip-num{font-size:2rem;font-weight:800;letter-spacing:-1px}
        .card{background:var(--bg-card);border:1px solid var(--border-light);border-radius:16px;overflow:hidden;}
        .card-hd{display:flex;justify-content:space-between;align-items:center;padding:14px 18px;border-bottom:1px solid var(--border-light2);background:#fafbff;}
        .card-title{font-size:.87rem;font-weight:700;color:var(--text-h);display:flex;align-items:center;gap:8px;}
        .btn{padding:8px 16px;border-radius:9px;font-family:'Sora',sans-serif;font-size:.8rem;font-weight:700;cursor:pointer;border:none;text-decoration:none;display:inline-flex;align-items:center;gap:6px;transition:all .18s;}
        .btn-primary{background:var(--primary);color:#fff}.btn-outline{background:#fff;border:1px solid var(--border-light);color:var(--text-b)}.btn-outline:hover{border-color:var(--primary-2);color:var(--primary-2)}
        .btn-sm{padding:5px 11px;font-size:.74rem}
        table{width:100%;border-collapse:collapse;font-size:.8rem}
        thead tr{background:#fafbff}
        th{padding:10px 14px;text-align:left;color:var(--text-s);font-weight:700;font-size:.67rem;text-transform:uppercase;letter-spacing:.8px;border-bottom:1px solid var(--border-light2);}
        td{padding:11px 14px;border-bottom:1px solid var(--border-light2);vertical-align:middle;}
        tr:last-child td{border-bottom:none}
        tbody tr:hover td{background:#f7f8ff}
        .badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;}
        .badge-completed{background:#d1fae5;color:#065f46}.badge-cancelled{background:#f3f4f6;color:#6b7280}
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
        <a href="<%=ctx%>/technicianReports" class="sb-item"><i class="fas fa-clipboard-list"></i> Repair Reports</a>
        <a href="<%=ctx%>/technicianWorkHistory" class="sb-item on"><i class="fas fa-history"></i> Work History</a>
        <div class="sb-lbl">Reference</div>
        <a href="<%=ctx%>/technicianContracts" class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
        <a href="<%=ctx%>/technicianContracts?action=equipment" class="sb-item"><i class="fas fa-desktop"></i> Equipment</a>
    </nav>
    <div class="sb-foot">
        <a href="<%=ctx%>/profile" class="sb-user"><div class="sb-ava"><%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%><img src="<%=ctx%><%=me.getAvatarUrl()%>" alt=""><%}else{%><%=initials%><%}%></div><div><div class="sb-uname"><%=me.getFullName()!=null?me.getFullName():me.getUsername()%></div><div class="sb-urole">Technician</div></div></a>
        <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
    </div>
</aside>
<main class="main">
    <div class="topbar">
        <div><div class="topbar-title">Work History</div><div class="topbar-sub">Lịch sử các công việc đã hoàn thành và đã hủy</div></div>
        <div class="topbar-right"><a href="<%=ctx%>/technicianTasks" class="btn btn-primary"><i class="fas fa-tasks"></i> Active Tasks</a></div>
    </div>
    <div class="content">
        <!-- Summary strip -->
        <div class="info-strip">
            <div>
                <div class="info-strip-text">Tổng số bản ghi lịch sử</div>
                <div class="info-strip-num"><%=total%></div>
            </div>
            <i class="fas fa-history" style="font-size:2.5rem;opacity:.3"></i>
        </div>

        <div class="card">
            <div class="card-hd">
                <span class="card-title"><i class="fas fa-history"></i> Lịch sử công việc</span>
                <span class="badge badge-default"><%=total%> bản ghi</span>
            </div>
            <div style="overflow-x:auto">
                <table>
                    <thead><tr>
                        <th>#</th><th>Mã SR</th><th>Tiêu đề</th><th>Khách hàng</th>
                        <th>Loại</th><th>Trạng thái</th><th>Ngày giao</th><th>Ngày tạo</th>
                    </tr></thead>
                    <tbody>
                    <%if(history.isEmpty()){%>
                    <tr><td colspan="8">
                        <div class="empty">
                            <i class="fas fa-archive"></i>
                            Chưa có lịch sử công việc<br>
                            <small style="font-size:.73rem">Công việc đã hoàn thành hoặc đã hủy sẽ hiển thị tại đây</small>
                        </div>
                    </td></tr>
                    <%}else{
                        int idx=(page-1)*15;
                        for(TaskRow r:history){ idx++;
                            String s=r.task.getStatus()!=null?r.task.getStatus():"";
                            String bc="Completed".equals(s)?"badge-completed":"badge-cancelled";
                            String sl="Completed".equals(s)?"Hoàn thành":"Đã hủy";
                    %>
                    <tr>
                        <td style="color:var(--text-s);font-size:.74rem"><%=idx%></td>
                        <td><strong style="color:var(--primary-2)"><%=r.requestCode!=null?r.requestCode:"#"+r.task.getId()%></strong></td>
                        <td style="max-width:200px">
                            <div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:180px;font-weight:500" title="<%=r.requestTitle!=null?r.requestTitle:r.task.getTaskDetails()!=null?r.task.getTaskDetails():""%>">
                                <%=r.requestTitle!=null?r.requestTitle:r.task.getTaskDetails()!=null?r.task.getTaskDetails():"—"%>
                            </div>
                        </td>
                        <td style="font-size:.8rem"><%=r.customerName!=null?r.customerName:"—"%></td>
                        <td style="font-size:.76rem;color:var(--text-m)"><%=r.task.getTaskType()!=null?r.task.getTaskType():"Request"%></td>
                        <td><span class="badge <%=bc%>"><%=sl%></span></td>
                        <td style="font-size:.74rem;color:var(--text-s)"><%=r.assignedAt!=null?r.assignedAt.format(dtf):"—"%></td>
                        <td style="font-size:.74rem;color:var(--text-s)"><%=r.task.getCreatedAt()!=null?r.task.getCreatedAt().format(dtf):"—"%></td>
                    </tr>
                    <%}}%>
                    </tbody>
                </table>
            </div>
            <%if(totalPages>1){%>
            <div class="pager">
                <%if(page>1){%><a href="?page=<%=page-1%>"><i class="fas fa-chevron-left"></i></a><%}%>
                <%for(int p2=Math.max(1,page-2);p2<=Math.min(totalPages,page+2);p2++){%>
                <<%=p2==page?"span class=\"active\"":"a href=\"?page="+p2+"\""%>><%=p2%></<%=p2==page?"span":"a"%>>
                <%}%>
                <%if(page<totalPages){%><a href="?page=<%=page+1%>"><i class="fas fa-chevron-right"></i></a><%}%>
            </div>
            <%}%>
        </div>
    </div>
</main>
</body></html>
