<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.TechnicianTaskDAO.TaskRow, java.time.format.DateTimeFormatter" %>
<%
    User me = (User) session.getAttribute("user");
    if(me==null||!"TECHNICIAN".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    TaskRow row = (TaskRow) request.getAttribute("row");
    if(row==null){response.sendRedirect(request.getContextPath()+"/technicianTasks");return;}
    String ctx = request.getContextPath();
    String initials = (me.getFullName()!=null&&!me.getFullName().isEmpty())?me.getFullName().substring(0,1).toUpperCase():"T";
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String status = row.task.getStatus()!=null?row.task.getStatus():"";
    String badgeCls = "Assigned".equals(status)?"badge-assigned":"In Progress".equals(status)?"badge-progress":"Completed".equals(status)?"badge-completed":"Cancelled".equals(status)?"badge-cancelled":"badge-default";
    String sLabel = "Assigned".equals(status)?"Đã giao":"In Progress".equals(status)?"Đang thực hiện":"Completed".equals(status)?"Hoàn thành":"Cancelled".equals(status)?"Đã hủy":status;
    // Google Maps — lấy từ row.customerAddress (đã join trong DAO)
    String addr = row.customerAddress;
    String encodedAddr = "";
    if(addr!=null&&!addr.trim().isEmpty()){
        try{ encodedAddr = java.net.URLEncoder.encode(addr.trim(),"UTF-8"); }catch(Exception e2){}
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Task Detail – DRSMS</title>
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
        .breadcrumb a{color:var(--primary-2);text-decoration:none}.breadcrumb a:hover{text-decoration:underline}
        .topbar-right{display:flex;gap:8px}
        .content{padding:24px 28px;flex:1;display:grid;grid-template-columns:1fr 320px;gap:20px;align-items:start;}
        .card{background:var(--bg-card);border:1px solid var(--border-light);border-radius:16px;overflow:hidden;margin-bottom:16px;}
        .card-hd{display:flex;justify-content:space-between;align-items:center;padding:14px 18px;border-bottom:1px solid var(--border-light2);background:#fafbff;}
        .card-title{font-size:.87rem;font-weight:700;color:var(--text-h);display:flex;align-items:center;gap:8px;}
        .card-body{padding:18px}
        .field{margin-bottom:14px}.field label{font-size:.72rem;font-weight:700;color:var(--text-s);text-transform:uppercase;letter-spacing:.6px;display:block;margin-bottom:4px}
        .field-val{font-size:.87rem;color:var(--text-b);font-weight:500}
        .field-box{background:#f8f9ff;border:1px solid var(--border-light2);border-radius:10px;padding:12px;font-size:.84rem;line-height:1.6}
        .two-col{display:grid;grid-template-columns:1fr 1fr;gap:14px}
        .badge{display:inline-flex;align-items:center;padding:4px 10px;border-radius:20px;font-size:.72rem;font-weight:700;}
        .badge-assigned{background:#dbeafe;color:#1e40af}.badge-progress{background:#fef3c7;color:#92400e}
        .badge-completed{background:#d1fae5;color:#065f46}.badge-cancelled{background:#f3f4f6;color:#6b7280}
        .badge-default{background:#e0e7ff;color:#3730a3}
        .badge-warranty{background:#ede9fe;color:#5b21b6}.badge-maintenance{background:#fce7f3;color:#9d174d}
        .btn{padding:8px 16px;border-radius:9px;font-family:'Sora',sans-serif;font-size:.8rem;font-weight:700;cursor:pointer;border:none;text-decoration:none;display:inline-flex;align-items:center;gap:6px;transition:all .18s;}
        .btn-primary{background:var(--primary);color:#fff}.btn-primary:hover{background:var(--primary-2)}
        .btn-outline{background:#fff;border:1px solid var(--border-light);color:var(--text-b)}.btn-outline:hover{border-color:var(--primary-2);color:var(--primary-2)}
        .btn-full{width:100%;justify-content:center;margin-bottom:8px}
        .tl-item{display:flex;align-items:flex-start;gap:10px;padding:8px 0;border-bottom:1px solid var(--border-light2);}
        .tl-item:last-child{border-bottom:none}
        .tl-dot{width:8px;height:8px;border-radius:50%;background:var(--primary-2);margin-top:5px;flex-shrink:0}
        .tl-label{font-size:.7rem;color:var(--text-s);font-weight:700;text-transform:uppercase;letter-spacing:.5px}
        .tl-val{font-size:.82rem;color:var(--text-b);margin-top:2px;font-weight:500}
        /* Modal */
        .overlay{position:fixed;inset:0;background:rgba(0,0,0,0.45);z-index:200;display:flex;align-items:center;justify-content:center;opacity:0;pointer-events:none;transition:opacity .2s;}
        .overlay.show{opacity:1;pointer-events:all}
        .modal{background:#fff;border-radius:18px;padding:28px;width:420px;max-width:95vw;box-shadow:0 20px 60px rgba(0,0,0,0.2);transform:translateY(20px);transition:transform .2s;}
        .overlay.show .modal{transform:none}
        .modal h3{font-size:1rem;font-weight:700;color:var(--text-h);margin-bottom:18px}
        .form-group{margin-bottom:14px}
        .form-group label{font-size:.78rem;font-weight:600;color:var(--text-m);display:block;margin-bottom:6px}
        .form-group select{width:100%;padding:9px 12px;border:1px solid var(--border-light);border-radius:9px;font-family:'Sora',sans-serif;font-size:.82rem;outline:none;}
        .modal-foot{display:flex;gap:10px;justify-content:flex-end;margin-top:20px}
    </style>
</head>
<body>
<aside class="sb">
    <div class="sb-brand"><div class="sb-logo"><i class="fas fa-tools"></i></div><div><div class="sb-name">DRSMS</div><div class="sb-role">Technician</div></div></div>
    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div><a href="<%=ctx%>/technicianDashboard" class="sb-item"><i class="fas fa-th-large"></i> Dashboard</a>
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
        <div>
            <div class="breadcrumb">
                <a href="<%=ctx%>/technicianTasks">My Tasks</a>
                <i class="fas fa-chevron-right" style="font-size:.6rem"></i>
                <span>Task #<%=row.task.getId()%></span>
            </div>
            <div style="font-size:1rem;font-weight:700;color:var(--text-h);margin-top:4px">Chi tiết công việc</div>
        </div>
        <div class="topbar-right">
            <a href="<%=ctx%>/technicianTasks" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Quay lại</a>
            <button onclick="document.getElementById('statusModal').classList.add('show')" class="btn btn-primary"><i class="fas fa-edit"></i> Cập nhật trạng thái</button>
        </div>
    </div>

    <div class="content">
        <!-- LEFT -->
        <div>
            <div class="card">
                <div class="card-hd"><span class="card-title"><i class="fas fa-info-circle"></i> Thông tin công việc</span><span class="badge <%=badgeCls%>"><%=sLabel%></span></div>
                <div class="card-body">
                    <div class="two-col">
                        <div class="field"><label>Task ID</label><div class="field-val" style="font-weight:700">#<%=row.task.getId()%></div></div>
                        <div class="field"><label>Loại task</label><div class="field-val"><%=row.task.getTaskType()!=null?row.task.getTaskType():"Request"%></div></div>
                        <div class="field"><label>Mã Service Request</label><div class="field-val" style="color:var(--primary-2);font-weight:700"><%=row.requestCode!=null?row.requestCode:"—"%></div></div>
                        <div class="field"><label>Mức độ ưu tiên</label>
                            <%if(row.priority!=null){
                                String pc="HIGH".equals(row.priority)||"URGENT".equals(row.priority)?"background:#fee2e2;color:#991b1b":"MEDIUM".equals(row.priority)?"background:#fef3c7;color:#92400e":"background:#d1fae5;color:#065f46";%>
                            <span class="badge" style="<%=pc%>"><%=row.priority%></span>
                            <%}else{%><span style="color:var(--text-s)">—</span><%}%>
                        </div>
                    </div>
                    <div class="field"><label>Tiêu đề yêu cầu</label><div class="field-val" style="font-weight:600"><%=row.requestTitle!=null?row.requestTitle:"(Chưa có)"%></div></div>
                    <div class="field"><label>Chi tiết công việc</label>
                        <div class="field-box"><%=row.task.getTaskDetails()!=null&&!row.task.getTaskDetails().isEmpty()?row.task.getTaskDetails():"(Không có chi tiết)"%></div>
                    </div>
                    <div class="two-col">
                        <div class="field"><label>Khách hàng</label><div class="field-val" style="font-weight:600"><%=row.customerName!=null?row.customerName:"—"%></div></div>
                        <div class="field"><label>Hợp đồng</label><div class="field-val">
                            <%if(row.contractCode!=null){%>
                            <span style="color:var(--primary-2);font-weight:600"><%=row.contractCode%></span>
                            <%if(row.contractType!=null){%>&nbsp;<span class="badge <%="WARRANTY".equals(row.contractType)?"badge-warranty":"badge-maintenance"%>" style="font-size:.65rem"><%=row.contractType%></span><%}%>
                            <%}else{%>—<%}%>
                        </div></div>
                    </div>
                </div>
            </div>

            <%if(addr!=null&&!addr.trim().isEmpty()){%>
            <div class="card">
                <div class="card-hd">
                    <span class="card-title"><i class="fas fa-map-marker-alt"></i> Địa chỉ khách hàng</span>
                    <span style="font-size:.73rem;color:var(--text-s)"><%=addr%></span>
                </div>
                <div style="padding:0">
                    <iframe src="https://www.google.com/maps?q=<%=encodedAddr%>&output=embed" width="100%" height="250" style="display:block;border:none" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
                </div>
                <div style="padding:12px 18px">
                    <a href="https://www.google.com/maps/dir/?api=1&destination=<%=encodedAddr%>" target="_blank" rel="noopener" class="btn btn-outline btn-full"><i class="fas fa-directions"></i> Mở Google Maps – Chỉ đường</a>
                </div>
            </div>
            <%}%>
        </div>

        <!-- RIGHT -->
        <div>
            <div class="card">
                <div class="card-hd"><span class="card-title"><i class="fas fa-clock"></i> Timeline</span></div>
                <div class="card-body" style="padding:12px 18px">
                    <div class="tl-item"><div class="tl-dot"></div><div><div class="tl-label">Ngày tạo task</div><div class="tl-val"><%=row.task.getCreatedAt()!=null?row.task.getCreatedAt().format(dtf):"—"%></div></div></div>
                    <div class="tl-item"><div class="tl-dot" style="background:var(--amber)"></div><div><div class="tl-label">Ngày giao việc</div><div class="tl-val"><%=row.assignedAt!=null?row.assignedAt.format(dtf):"Chưa giao"%></div></div></div>
                    <%if(row.assignPriority!=null){%>
                    <div class="tl-item"><div class="tl-dot" style="background:var(--info,#0284c7)"></div><div><div class="tl-label">Độ ưu tiên giao việc</div><div class="tl-val"><%=row.assignPriority%></div></div></div>
                    <%}%>
                    <div class="tl-item"><div class="tl-dot" style="background:var(--green)"></div><div><div class="tl-label">Trạng thái hiện tại</div><div class="tl-val"><span class="badge <%=badgeCls%>"><%=sLabel%></span></div></div></div>
                </div>
            </div>

            <%if(row.requiredSkills!=null&&!row.requiredSkills.isEmpty()){%>
            <div class="card">
                <div class="card-hd"><span class="card-title"><i class="fas fa-star"></i> Kỹ năng yêu cầu</span></div>
                <div class="card-body"><div class="field-box" style="font-size:.82rem"><%=row.requiredSkills%></div></div>
            </div>
            <%}%>

            <div class="card">
                <div class="card-hd"><span class="card-title"><i class="fas fa-bolt"></i> Thao tác nhanh</span></div>
                <div class="card-body">
                    <button onclick="document.getElementById('statusModal').classList.add('show')" class="btn btn-primary btn-full"><i class="fas fa-edit"></i> Cập nhật trạng thái</button>
                    <%if(row.contractId!=null){%>
                    <a href="<%=ctx%>/technicianContracts?action=detail&id=<%=row.contractId%>" class="btn btn-outline btn-full"><i class="fas fa-file-contract"></i> Xem hợp đồng</a>
                    <%}else{%>
                    <a href="<%=ctx%>/technicianContracts" class="btn btn-outline btn-full"><i class="fas fa-file-contract"></i> Danh sách hợp đồng</a>
                    <%}%>
                    <a href="<%=ctx%>/technicianTasks" class="btn btn-outline btn-full" style="margin-bottom:0"><i class="fas fa-arrow-left"></i> Quay lại danh sách</a>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Status Modal -->
<div class="overlay" id="statusModal">
    <div class="modal">
        <h3><i class="fas fa-edit" style="color:var(--primary-2);margin-right:8px"></i>Cập nhật trạng thái</h3>
        <form method="post" action="<%=ctx%>/technicianTasks">
            <input type="hidden" name="action"  value="updateStatus">
            <input type="hidden" name="taskId"  value="<%=row.task.getId()%>">
            <div class="form-group">
                <label>Trạng thái mới</label>
                <select name="newStatus" required>
                    <option value="">-- Chọn trạng thái --</option>
                    <option value="Assigned"    <%="Assigned".equals(status)?"selected":""%>>Đã giao</option>
                    <option value="In Progress" <%="In Progress".equals(status)?"selected":""%>>Đang thực hiện</option>
                    <option value="Completed"   <%="Completed".equals(status)?"selected":""%>>Hoàn thành</option>
                    <option value="Cancelled"   <%="Cancelled".equals(status)?"selected":""%>>Đã hủy</option>
                </select>
            </div>
            <div class="modal-foot">
                <button type="button" onclick="document.getElementById('statusModal').classList.remove('show')" class="btn btn-outline">Hủy</button>
                <button type="submit" class="btn btn-primary">Cập nhật</button>
            </div>
        </form>
    </div>
</div>
<script>
document.getElementById('statusModal').addEventListener('click',function(e){if(e.target===this)this.classList.remove('show');});
</script>
</body>
</html>
