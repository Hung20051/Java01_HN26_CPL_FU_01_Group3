<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.TechnicianTaskDAO.TaskRow, java.util.List, java.time.format.DateTimeFormatter" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"TECHNICIAN".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    @SuppressWarnings("unchecked")
    List<TaskRow> tasks   = (List<TaskRow>) request.getAttribute("tasks");
    int total      = request.getAttribute("total")      != null ? (Integer)request.getAttribute("total")      : 0;
    int page       = request.getAttribute("page")       != null ? (Integer)request.getAttribute("page")       : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (Integer)request.getAttribute("totalPages") : 1;
    String keyword      = request.getAttribute("keyword")      != null ? (String)request.getAttribute("keyword")      : "";
    String filterStatus = request.getAttribute("filterStatus") != null ? (String)request.getAttribute("filterStatus") : "";
    String successMsg = (String) request.getAttribute("success");
    String errorMsg   = (String) request.getAttribute("error");
    String ctx = request.getContextPath();
    String initials = (me.getFullName()!=null&&!me.getFullName().isEmpty()) ? me.getFullName().substring(0,1).toUpperCase():"T";
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    if (tasks == null) tasks = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>My Tasks – DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root{--sb-bg:#1e1b4b;--sb-border:rgba(255,255,255,0.08);--sb-text:rgba(255,255,255,0.45);--sb-accent:#818cf8;--sb-accent-2:#a5b4fc;--sb-item-on:rgba(129,140,248,0.2);--sb-width:252px;--bg:#f3f4f9;--bg-card:#fff;--border-light:#e8ecf5;--border-light2:#f0f2fb;--text-h:#1e1b4b;--text-b:#374151;--text-m:#6b7280;--text-s:#9ca3af;--primary:#4f46e5;--primary-2:#6366f1;--primary-light:#ede9fe;--blue:#2563eb;--green:#16a34a;--red:#dc2626;--amber:#d97706;--info:#0284c7;}
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
        .search-bar{padding:16px 18px;border-bottom:1px solid var(--border-light2);display:flex;gap:10px;flex-wrap:wrap;align-items:center;}
        .search-bar input,.search-bar select{padding:8px 12px;border:1px solid var(--border-light);border-radius:9px;font-family:'Sora',sans-serif;font-size:.8rem;outline:none;transition:border .18s;}
        .search-bar input{flex:1;min-width:200px}.search-bar input:focus,.search-bar select:focus{border-color:var(--primary-2)}
        .btn{padding:8px 16px;border-radius:9px;font-family:'Sora',sans-serif;font-size:.8rem;font-weight:700;cursor:pointer;border:none;text-decoration:none;display:inline-flex;align-items:center;gap:6px;transition:all .18s;}
        .btn-primary{background:var(--primary);color:#fff}.btn-primary:hover{background:var(--primary-2)}
        .btn-outline{background:#fff;border:1px solid var(--border-light);color:var(--text-b)}.btn-outline:hover{border-color:var(--primary-2);color:var(--primary-2)}
        .btn-sm{padding:5px 11px;font-size:.74rem}
        table{width:100%;border-collapse:collapse;font-size:.8rem}
        thead tr{background:#fafbff}
        th{padding:10px 14px;text-align:left;color:var(--text-s);font-weight:700;font-size:.67rem;text-transform:uppercase;letter-spacing:.8px;border-bottom:1px solid var(--border-light2);}
        td{padding:11px 14px;border-bottom:1px solid var(--border-light2);vertical-align:middle;}
        tr:last-child td{border-bottom:none}
        tbody tr:hover td{background:#f7f8ff}
        .badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;white-space:nowrap;}
        .badge-assigned{background:#dbeafe;color:#1e40af}.badge-progress{background:#fef3c7;color:#92400e}
        .badge-completed{background:#d1fae5;color:#065f46}.badge-cancelled{background:#f3f4f6;color:#6b7280}
        .badge-default{background:#e0e7ff;color:#3730a3}
        .pager{display:flex;align-items:center;justify-content:center;gap:6px;padding:16px;}
        .pager a,.pager span{width:32px;height:32px;display:flex;align-items:center;justify-content:center;border-radius:8px;font-size:.78rem;font-weight:600;text-decoration:none;color:var(--text-b);border:1px solid var(--border-light);}
        .pager a:hover{border-color:var(--primary-2);color:var(--primary-2)}.pager .active{background:var(--primary);color:#fff;border-color:var(--primary);}
        .empty{text-align:center;padding:40px;color:var(--text-s)}.empty i{font-size:2rem;display:block;margin-bottom:12px;opacity:.2}
        .alert{padding:12px 16px;border-radius:10px;font-size:.82rem;margin-bottom:16px;display:flex;align-items:center;gap:10px;}
        .alert-success{background:#d1fae5;color:#065f46;border:1px solid #a7f3d0}
        .alert-error{background:#fee2e2;color:#991b1b;border:1px solid #fca5a5}
        /* Modal */
        .overlay{position:fixed;inset:0;background:rgba(0,0,0,0.45);z-index:200;display:flex;align-items:center;justify-content:center;opacity:0;pointer-events:none;transition:opacity .2s;}
        .overlay.show{opacity:1;pointer-events:all}
        .modal{background:#fff;border-radius:18px;padding:28px;width:420px;max-width:95vw;box-shadow:0 20px 60px rgba(0,0,0,0.2);transform:translateY(20px);transition:transform .2s;}
        .overlay.show .modal{transform:none}
        .modal h3{font-size:1rem;font-weight:700;color:var(--text-h);margin-bottom:18px}
        .form-group{margin-bottom:16px}
        .form-group label{font-size:.78rem;font-weight:600;color:var(--text-m);display:block;margin-bottom:6px}
        .form-group select{width:100%;padding:9px 12px;border:1px solid var(--border-light);border-radius:9px;font-family:'Sora',sans-serif;font-size:.82rem;outline:none;}
        .modal-foot{display:flex;gap:10px;justify-content:flex-end;margin-top:20px}
    </style>
</head>
<body>
<aside class="sb">
    <div class="sb-brand"><div class="sb-logo"><i class="fas fa-tools"></i></div><div><div class="sb-name">DRSMS</div><div class="sb-role">Technician</div></div></div>
    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div>
        <a href="<%=ctx%>/technicianDashboard" class="sb-item"><i class="fas fa-th-large"></i> Dashboard</a>
        <div class="sb-lbl">Work</div>
        <a href="<%=ctx%>/technicianTasks" class="sb-item on"><i class="fas fa-tasks"></i> My Tasks</a>
        <a href="<%=ctx%>/technicianReports" class="sb-item"><i class="fas fa-clipboard-list"></i> Repair Reports</a>
        <a href="<%=ctx%>/technicianWorkHistory" class="sb-item"><i class="fas fa-history"></i> Work History</a>
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
        <div><div class="topbar-title">My Tasks</div><div class="topbar-sub">Công việc được Technical Manager giao cho bạn</div></div>
        <div class="topbar-right"><a href="<%=ctx%>/technicianDashboard" class="btn btn-outline btn-sm"><i class="fas fa-th-large"></i> Dashboard</a></div>
    </div>
    <div class="content">
        <%if(successMsg!=null){%><div class="alert alert-success"><i class="fas fa-check-circle"></i><%=successMsg%></div><%}%>
        <%if(errorMsg  !=null){%><div class="alert alert-error"  ><i class="fas fa-exclamation-circle"></i><%=errorMsg%></div><%}%>

        <div class="card">
            <form method="get" action="<%=ctx%>/technicianTasks">
                <div class="search-bar">
                    <input type="text" name="keyword" value="<%=keyword%>" placeholder="Tìm theo mã SR, tiêu đề, chi tiết...">
                    <select name="status">
                        <option value="">Tất cả trạng thái</option>
                        <option value="Assigned"    <%="Assigned".equals(filterStatus)?"selected":""%>>Đã giao</option>
                        <option value="In Progress" <%="In Progress".equals(filterStatus)?"selected":""%>>Đang thực hiện</option>
                        <option value="Completed"   <%="Completed".equals(filterStatus)?"selected":""%>>Hoàn thành</option>
                        <option value="Cancelled"   <%="Cancelled".equals(filterStatus)?"selected":""%>>Đã hủy</option>
                    </select>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Tìm</button>
                    <a href="<%=ctx%>/technicianTasks" class="btn btn-outline">Reset</a>
                </div>
            </form>

            <div class="card-hd">
                <span class="card-title"><i class="fas fa-list-ul"></i> Danh sách công việc</span>
                <span class="badge badge-default"><%=total%> công việc</span>
            </div>

            <div style="overflow-x:auto">
                <table>
                    <thead><tr>
                        <th>#</th><th>Mã SR</th><th>Tiêu đề công việc</th><th>Khách hàng</th>
                        <th>Loại</th><th>Trạng thái</th><th>Ngày tạo</th><th>Thao tác</th>
                    </tr></thead>
                    <tbody>
                    <%if(tasks.isEmpty()){%>
                    <tr><td colspan="8">
                        <div class="empty"><i class="fas fa-inbox"></i>
                            Không có công việc nào<br>
                            <small style="font-size:.72rem">Các công việc được Technical Manager giao sẽ hiển thị tại đây</small>
                        </div>
                    </td></tr>
                    <%}else{
                        int idx=(page-1)*10;
                        for(TaskRow r:tasks){ idx++;
                            String s = r.task.getStatus()!=null?r.task.getStatus():"";
                            String badgeCls = "Assigned".equals(s)?"badge-assigned":"In Progress".equals(s)?"badge-progress":"Completed".equals(s)?"badge-completed":"Cancelled".equals(s)?"badge-cancelled":"badge-default";
                            String sLabel = "Assigned".equals(s)?"Đã giao":"In Progress".equals(s)?"Đang thực hiện":"Completed".equals(s)?"Hoàn thành":"Cancelled".equals(s)?"Đã hủy":s;
                    %>
                    <tr>
                        <td style="color:var(--text-s);font-size:.74rem"><%=idx%></td>
                        <td><strong style="color:var(--primary-2)"><%=r.requestCode!=null?r.requestCode:"#"+r.task.getId()%></strong></td>
                        <td style="max-width:220px">
                            <div style="font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:200px" title="<%=r.requestTitle!=null?r.requestTitle:r.task.getTaskDetails()!=null?r.task.getTaskDetails():""%>">
                                <%=r.requestTitle!=null?r.requestTitle:r.task.getTaskDetails()!=null?r.task.getTaskDetails():"(Chưa có tiêu đề)"%>
                            </div>
                            <%if(r.priority!=null){
                                String pc="HIGH".equals(r.priority)||"URGENT".equals(r.priority)?"#dc2626":"MEDIUM".equals(r.priority)?"#d97706":"#9ca3af";%>
                            <small style="font-size:.7rem;color:<%=pc%>"><%=r.priority%></small>
                            <%}%>
                        </td>
                        <td style="font-size:.8rem"><%=r.customerName!=null?r.customerName:"—"%></td>
                        <td style="font-size:.76rem;color:var(--text-m)"><%=r.task.getTaskType()!=null?r.task.getTaskType():"Request"%></td>
                        <td><span class="badge <%=badgeCls%>"><%=sLabel%></span></td>
                        <td style="font-size:.74rem;color:var(--text-s)"><%=r.task.getCreatedAt()!=null?r.task.getCreatedAt().format(dtf):"—"%></td>
                        <td>
                            <div style="display:flex;gap:5px">
                                <a href="<%=ctx%>/technicianTasks?action=detail&id=<%=r.task.getId()%>" class="btn btn-outline btn-sm" title="Xem chi tiết"><i class="fas fa-eye"></i></a>
                                <button onclick="openModal(<%=r.task.getId()%>,'<%=s%>','<%=keyword%>','<%=filterStatus%>',<%=page%>)" class="btn btn-primary btn-sm" title="Cập nhật trạng thái"><i class="fas fa-edit"></i></button>
                            </div>
                        </td>
                    </tr>
                    <%}}%>
                    </tbody>
                </table>
            </div>

            <%if(totalPages>1){%>
            <div class="pager">
                <%String kw_enc=java.net.URLEncoder.encode(keyword,"UTF-8"); String st_enc=java.net.URLEncoder.encode(filterStatus,"UTF-8");%>
                <%if(page>1){%><a href="<%=ctx%>/technicianTasks?page=<%=page-1%>&keyword=<%=kw_enc%>&status=<%=st_enc%>"><i class="fas fa-chevron-left"></i></a><%}%>
                <%for(int p2=Math.max(1,page-2);p2<=Math.min(totalPages,page+2);p2++){%>
                <<%=p2==page?"span class=\"active\"":"a href=\""+ctx+"/technicianTasks?page="+p2+"&keyword="+kw_enc+"&status="+st_enc+"\""%>><%=p2%></<%=p2==page?"span":"a"%>>
                <%}%>
                <%if(page<totalPages){%><a href="<%=ctx%>/technicianTasks?page=<%=page+1%>&keyword=<%=kw_enc%>&status=<%=st_enc%>"><i class="fas fa-chevron-right"></i></a><%}%>
            </div>
            <%}%>
        </div>
    </div>
</main>

<!-- Status Update Modal -->
<div class="overlay" id="statusModal">
    <div class="modal">
        <h3><i class="fas fa-edit" style="color:var(--primary-2);margin-right:8px"></i>Cập nhật trạng thái công việc</h3>
        <form method="post" action="<%=ctx%>/technicianTasks">
            <input type="hidden" name="action"       value="updateStatus">
            <input type="hidden" name="taskId"       id="modalTaskId">
            <input type="hidden" name="keyword"      id="modalKeyword">
            <input type="hidden" name="filterStatus" id="modalFilterStatus">
            <input type="hidden" name="page"         id="modalPage">
            <div class="form-group">
                <label>Trạng thái mới</label>
                <select name="newStatus" id="modalStatus" required>
                    <option value="">-- Chọn trạng thái --</option>
                    <option value="Assigned">Đã giao</option>
                    <option value="In Progress">Đang thực hiện</option>
                    <option value="Completed">Hoàn thành</option>
                    <option value="Cancelled">Đã hủy</option>
                </select>
            </div>
            <div class="modal-foot">
                <button type="button" onclick="closeModal()" class="btn btn-outline">Hủy</button>
                <button type="submit" class="btn btn-primary">Cập nhật</button>
            </div>
        </form>
    </div>
</div>
<script>
function openModal(id, cur, kw, st, pg) {
    document.getElementById('modalTaskId').value = id;
    document.getElementById('modalStatus').value = cur;
    document.getElementById('modalKeyword').value = kw;
    document.getElementById('modalFilterStatus').value = st;
    document.getElementById('modalPage').value = pg;
    document.getElementById('statusModal').classList.add('show');
}
function closeModal() { document.getElementById('statusModal').classList.remove('show'); }
document.getElementById('statusModal').addEventListener('click', function(e) { if(e.target===this) closeModal(); });
</script>
</body>
</html>
