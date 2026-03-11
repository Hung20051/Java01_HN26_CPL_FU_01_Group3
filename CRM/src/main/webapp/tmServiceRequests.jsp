<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"TECHNICAL_MANAGER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    List<ServiceRequest> requests = (List<ServiceRequest>) request.getAttribute("requests");
    if (requests == null) requests = new ArrayList<>();
    int total       = request.getAttribute("total")      != null ? (int) request.getAttribute("total")      : 0;
    int currentPage = request.getAttribute("page")       != null ? (int) request.getAttribute("page")       : 1;
    int totalPages  = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;
    String keyword  = request.getAttribute("keyword")    != null ? (String) request.getAttribute("keyword") : "";
    String fStatus  = request.getAttribute("filterStatus")   != null ? (String) request.getAttribute("filterStatus")    : "";
    String fPriority= request.getAttribute("filterPriority") != null ? (String) request.getAttribute("filterPriority")  : "";
    String fType    = request.getAttribute("filterType")     != null ? (String) request.getAttribute("filterType")      : "";
    Map<String,Integer> stats = (Map<String,Integer>) request.getAttribute("stats");
    if (stats == null) stats = new HashMap<>();

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");
%>
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Service Requests – Technical Manager</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
:root{--primary:#4f46e5;--sidebar:#0f172a;--bg:#f1f5f9;--surface:#fff;--border:#e2e8f0;
      --text:#0f172a;--muted:#64748b;--success:#10b981;--danger:#ef4444;--warning:#f59e0b;--sb-w:220px}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Inter',sans-serif;background:var(--bg);display:flex;min-height:100vh}
/* Sidebar */
.sb{width:var(--sb-w);height:100vh;background:var(--sidebar);display:flex;flex-direction:column;flex-shrink:0;position:sticky;top:0}
.sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid rgba(255,255,255,.07)}
.sb-logo{width:32px;height:32px;background:var(--primary);border-radius:8px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.85rem}
.sb-name{color:#fff;font-size:.95rem;font-weight:700}.sb-sub{color:rgba(255,255,255,.35);font-size:.65rem}
.sb-nav{flex:1;padding:12px 8px;overflow-y:auto}
.sb-nav a{display:flex;align-items:center;gap:10px;padding:9px 10px;border-radius:8px;color:rgba(255,255,255,.6);text-decoration:none;font-size:.83rem;font-weight:500;margin-bottom:2px;transition:.15s}
.sb-nav a:hover,.sb-nav a.active{background:rgba(255,255,255,.08);color:#fff}
.sb-nav .section{color:rgba(255,255,255,.25);font-size:.65rem;font-weight:600;letter-spacing:.08em;padding:12px 10px 4px;text-transform:uppercase}
.sb-user{padding:12px 16px;border-top:1px solid rgba(255,255,255,.07);display:flex;align-items:center;gap:10px}
.sb-user .av{width:32px;height:32px;border-radius:50%;background:var(--primary);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.8rem;font-weight:700}
.sb-user .info .name{color:#fff;font-size:.8rem;font-weight:600}.sb-user .info .role{color:rgba(255,255,255,.35);font-size:.65rem}
.sb-user a{margin-left:auto;color:rgba(255,255,255,.4);font-size:.8rem}
/* Main */
.main{flex:1;padding:28px;overflow-y:auto}
.page-title{font-size:1.4rem;font-weight:700;color:var(--text);margin-bottom:6px}
.page-sub{color:var(--muted);font-size:.85rem;margin-bottom:24px}
/* Stats cards */
.stats-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));gap:14px;margin-bottom:24px}
.stat-card{background:var(--surface);border-radius:12px;padding:16px;border:1px solid var(--border)}
.stat-card .label{font-size:.72rem;color:var(--muted);font-weight:600;text-transform:uppercase;letter-spacing:.05em;margin-bottom:6px}
.stat-card .value{font-size:1.6rem;font-weight:800;color:var(--text)}
.stat-card.pending .value{color:var(--warning)}
.stat-card.approved .value{color:#3b82f6}
.stat-card.progress .value{color:var(--primary)}
.stat-card.done .value{color:var(--success)}
.stat-card.rejected .value{color:var(--danger)}
/* Filters */
.filter-bar{background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:16px;display:flex;flex-wrap:wrap;gap:10px;align-items:center;margin-bottom:20px}
.filter-bar input,.filter-bar select{padding:8px 12px;border:1px solid var(--border);border-radius:8px;font-size:.83rem;color:var(--text);background:#fff;outline:none}
.filter-bar input:focus,.filter-bar select:focus{border-color:var(--primary)}
.btn{display:inline-flex;align-items:center;gap:6px;padding:8px 16px;border-radius:8px;font-size:.83rem;font-weight:600;cursor:pointer;border:none;text-decoration:none;transition:.15s}
.btn-primary{background:var(--primary);color:#fff}.btn-primary:hover{background:#4338ca}
.btn-secondary{background:#f1f5f9;color:var(--text)}.btn-secondary:hover{background:#e2e8f0}
/* Table */
.table-wrap{background:var(--surface);border:1px solid var(--border);border-radius:12px;overflow:hidden}
table{width:100%;border-collapse:collapse}
thead{background:#f8fafc}
th{padding:11px 14px;text-align:left;font-size:.75rem;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;border-bottom:1px solid var(--border)}
td{padding:12px 14px;font-size:.83rem;color:var(--text);border-bottom:1px solid var(--border)}
tr:last-child td{border-bottom:none}
tr:hover td{background:#f8fafc}
/* Badges */
.badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.72rem;font-weight:600}
.badge-pending{background:#fef3c7;color:#92400e}
.badge-approved{background:#dbeafe;color:#1e40af}
.badge-rejected{background:#fee2e2;color:#991b1b}
.badge-progress{background:#ede9fe;color:#5b21b6}
.badge-completed{background:#d1fae5;color:#065f46}
.badge-cancelled{background:#f1f5f9;color:#475569}
.badge-low{background:#f0fdf4;color:#166534}
.badge-medium{background:#fef9c3;color:#854d0e}
.badge-high{background:#ffedd5;color:#9a3412}
.badge-urgent{background:#fee2e2;color:#991b1b}
/* Pagination */
.pagination{display:flex;justify-content:flex-end;align-items:center;gap:6px;padding:14px 16px;border-top:1px solid var(--border)}
.pagination a,.pagination span{padding:6px 11px;border-radius:7px;font-size:.8rem;font-weight:500;text-decoration:none;color:var(--text);border:1px solid var(--border)}
.pagination a:hover{background:var(--primary);color:#fff;border-color:var(--primary)}
.pagination .active{background:var(--primary);color:#fff;border-color:var(--primary)}
/* Alert */
.alert{padding:12px 16px;border-radius:10px;font-size:.85rem;font-weight:500;margin-bottom:18px;display:flex;align-items:center;gap:10px}
.alert-success{background:#d1fae5;color:#065f46;border:1px solid #a7f3d0}
.alert-error{background:#fee2e2;color:#991b1b;border:1px solid #fca5a5}
a.row-link{color:var(--primary);font-weight:600;text-decoration:none}
a.row-link:hover{text-decoration:underline}
</style>
</head><body>

<!-- SIDEBAR -->
<nav class="sb">
  <div class="sb-brand">
    <div class="sb-logo"><i class="fas fa-tools"></i></div>
    <div><div class="sb-name">CRM System</div><div class="sb-sub">Technical Manager</div></div>
  </div>
  <div class="sb-nav">
    <div class="section">Menu</div>
    <a href="<%=ctx%>/tmServiceRequests" class="active"><i class="fas fa-clipboard-list"></i> Service Requests</a>
  </div>
  <div class="sb-user">
    <div class="av"><%=me.getFullName().substring(0,1).toUpperCase()%></div>
    <div class="info">
      <div class="name"><%=me.getFullName()%></div>
      <div class="role">Technical Manager</div>
    </div>
    <a href="<%=ctx%>/logout" title="Logout"><i class="fas fa-sign-out-alt"></i></a>
  </div>
</nav>

<!-- MAIN -->
<main class="main">
  <div class="page-title"><i class="fas fa-clipboard-list" style="color:var(--primary);margin-right:8px"></i>Service Requests</div>
  <div class="page-sub">Review, approve/reject and assign technicians to service requests</div>

  <%if(flashOk!=null){%><div class="alert alert-success"><i class="fas fa-check-circle"></i><%=flashOk%></div><%}%>
  <%if(flashErr!=null){%><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i><%=flashErr%></div><%}%>

  <!-- STATS -->
  <div class="stats-grid">
    <div class="stat-card"><div class="label">Total</div><div class="value"><%=stats.getOrDefault("total",0)%></div></div>
    <div class="stat-card pending"><div class="label">Pending</div><div class="value"><%=stats.getOrDefault("pending",0)%></div></div>
    <div class="stat-card approved"><div class="label">Approved</div><div class="value"><%=stats.getOrDefault("approved",0)%></div></div>
    <div class="stat-card progress"><div class="label">In Progress</div><div class="value"><%=stats.getOrDefault("in_progress",0)%></div></div>
    <div class="stat-card done"><div class="label">Completed</div><div class="value"><%=stats.getOrDefault("completed",0)%></div></div>
    <div class="stat-card rejected"><div class="label">Rejected</div><div class="value"><%=stats.getOrDefault("rejected",0)%></div></div>
  </div>

  <!-- FILTERS -->
  <form method="get" action="<%=ctx%>/tmServiceRequests">
  <div class="filter-bar">
    <input type="text" name="keyword" placeholder="🔍  Search code / customer / title..." value="<%=keyword!=null?keyword:""%>" style="flex:1;min-width:200px">
    <select name="status">
      <option value="">All Status</option>
      <%for(String s:new String[]{"PENDING","APPROVED","REJECTED","IN_PROGRESS","COMPLETED","CANCELLED"}){%>
      <option value="<%=s%>" <%=s.equals(fStatus)?"selected":""%>><%=s.replace("_"," ")%></option>
      <%}%>
    </select>
    <select name="priority">
      <option value="">All Priority</option>
      <%for(String p:new String[]{"LOW","MEDIUM","HIGH","URGENT"}){%>
      <option value="<%=p%>" <%=p.equals(fPriority)?"selected":""%>><%=p%></option>
      <%}%>
    </select>
    <select name="contractType">
      <option value="">All Types</option>
      <option value="WARRANTY" <%="WARRANTY".equals(fType)?"selected":""%>>WARRANTY</option>
      <option value="MAINTENANCE" <%="MAINTENANCE".equals(fType)?"selected":""%>>MAINTENANCE</option>
    </select>
    <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Filter</button>
    <a href="<%=ctx%>/tmServiceRequests" class="btn btn-secondary"><i class="fas fa-times"></i> Reset</a>
  </div>
  </form>

  <!-- TABLE -->
  <div class="table-wrap">
    <table>
      <thead><tr>
        <th>Code</th><th>Customer</th><th>Title</th><th>Contract</th>
        <th>Priority</th><th>Status</th><th>Created</th><th>Action</th>
      </tr></thead>
      <tbody>
      <%if(requests.isEmpty()){%>
      <tr><td colspan="8" style="text-align:center;color:var(--muted);padding:32px">No requests found.</td></tr>
      <%}else{for(ServiceRequest sr:requests){
          String badgeSt="badge-pending";
          if("APPROVED".equals(sr.getStatus())) badgeSt="badge-approved";
          else if("REJECTED".equals(sr.getStatus())) badgeSt="badge-rejected";
          else if("IN_PROGRESS".equals(sr.getStatus())) badgeSt="badge-progress";
          else if("COMPLETED".equals(sr.getStatus())) badgeSt="badge-completed";
          else if("CANCELLED".equals(sr.getStatus())) badgeSt="badge-cancelled";
          String badgePr="badge-low";
          if("MEDIUM".equals(sr.getPriority())) badgePr="badge-medium";
          else if("HIGH".equals(sr.getPriority())) badgePr="badge-high";
          else if("URGENT".equals(sr.getPriority())) badgePr="badge-urgent";
      %>
      <tr>
        <td><a class="row-link" href="<%=ctx%>/tmServiceRequests?action=detail&id=<%=sr.getId()%>"><%=sr.getRequestCode()%></a></td>
        <td><%=sr.getCustomerName()%></td>
        <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><%=sr.getTitle()%></td>
        <td><span style="font-size:.75rem"><%=sr.getContractCode()%></span><br><span style="font-size:.7rem;color:var(--muted)"><%=sr.getContractType()%></span></td>
        <td><span class="badge <%=badgePr%>"><%=sr.getPriority()%></span></td>
        <td><span class="badge <%=badgeSt%>"><%=sr.getStatusLabel()%></span></td>
        <td style="font-size:.78rem;color:var(--muted)"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toLocalDate():""%></td>
        <td><a class="btn btn-primary" style="padding:5px 12px;font-size:.78rem" href="<%=ctx%>/tmServiceRequests?action=detail&id=<%=sr.getId()%>"><i class="fas fa-eye"></i> View</a></td>
      </tr>
      <%}}%>
      </tbody>
    </table>

    <!-- PAGINATION -->
    <%if(totalPages>1){%>
    <div class="pagination">
      <%String q="&keyword="+keyword+"&status="+fStatus+"&priority="+fPriority+"&contractType="+fType;%>
      <%if(currentPage>1){%><a href="<%=ctx%>/tmServiceRequests?page=<%=currentPage-1%><%=q%>"><i class="fas fa-chevron-left"></i></a><%}%>
      <%for(int i=1;i<=totalPages;i++){%>
        <%if(i==currentPage){%><span class="active"><%=i%></span>
        <%}else if(i==1||i==totalPages||Math.abs(i-currentPage)<=2){%><a href="<%=ctx%>/tmServiceRequests?page=<%=i%><%=q%>"><%=i%></a>
        <%}else if(Math.abs(i-currentPage)==3){%><span>…</span><%}%>
      <%}%>
      <%if(currentPage<totalPages){%><a href="<%=ctx%>/tmServiceRequests?page=<%=currentPage+1%><%=q%>"><i class="fas fa-chevron-right"></i></a><%}%>
    </div>
    <%}%>
  </div>
</main>
</body></html>