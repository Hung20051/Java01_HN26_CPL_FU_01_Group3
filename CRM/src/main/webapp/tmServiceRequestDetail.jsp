<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"TECHNICAL_MANAGER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    ServiceRequest sr = (ServiceRequest) request.getAttribute("sr");
    if (sr == null) { response.sendRedirect(ctx + "/tmServiceRequests"); return; }
    List<ServiceRequestEquipment> equips = sr.getEquipmentList();
    if (equips == null) equips = new ArrayList<>();
    List<User> technicians = (List<User>) request.getAttribute("technicians");
    if (technicians == null) technicians = new ArrayList<>();

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");

    boolean isPending  = "PENDING".equals(sr.getStatus());
    boolean isApproved = "APPROVED".equals(sr.getStatus());
%>
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title><%=sr.getRequestCode()%> – TM Detail</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
:root{--primary:#4f46e5;--sidebar:#0f172a;--bg:#f1f5f9;--surface:#fff;--border:#e2e8f0;
      --text:#0f172a;--muted:#64748b;--success:#10b981;--danger:#ef4444;--warning:#f59e0b;--sb-w:220px}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Inter',sans-serif;background:var(--bg);display:flex;min-height:100vh}
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
.main{flex:1;padding:28px;overflow-y:auto;max-width:900px}
.back-link{display:inline-flex;align-items:center;gap:6px;color:var(--primary);text-decoration:none;font-size:.85rem;font-weight:600;margin-bottom:18px}
.back-link:hover{text-decoration:underline}
.card{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:22px;margin-bottom:20px}
.card-title{font-size:1rem;font-weight:700;color:var(--text);margin-bottom:16px;display:flex;align-items:center;gap:8px}
.info-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.info-item label{font-size:.72rem;color:var(--muted);font-weight:600;text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:4px}
.info-item .val{font-size:.88rem;color:var(--text);font-weight:500}
.badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.72rem;font-weight:600}
.badge-pending{background:#fef3c7;color:#92400e}.badge-approved{background:#dbeafe;color:#1e40af}
.badge-rejected{background:#fee2e2;color:#991b1b}.badge-progress{background:#ede9fe;color:#5b21b6}
.badge-completed{background:#d1fae5;color:#065f46}.badge-cancelled{background:#f1f5f9;color:#475569}
.badge-low{background:#f0fdf4;color:#166634}.badge-medium{background:#fef9c3;color:#854d0e}
.badge-high{background:#ffedd5;color:#9a3412}.badge-urgent{background:#fee2e2;color:#991b1b}
.equip-table{width:100%;border-collapse:collapse;font-size:.83rem}
.equip-table th{padding:9px 12px;background:#f8fafc;text-align:left;font-size:.72rem;font-weight:600;color:var(--muted);border-bottom:1px solid var(--border)}
.equip-table td{padding:10px 12px;border-bottom:1px solid var(--border);color:var(--text)}
.equip-table tr:last-child td{border-bottom:none}
.action-bar{display:flex;gap:10px;flex-wrap:wrap;margin-top:4px}
.btn{display:inline-flex;align-items:center;gap:7px;padding:9px 18px;border-radius:9px;font-size:.85rem;font-weight:600;cursor:pointer;border:none;text-decoration:none;transition:.15s}
.btn-success{background:var(--success);color:#fff}.btn-success:hover{background:#059669}
.btn-danger{background:var(--danger);color:#fff}.btn-danger:hover{background:#dc2626}
.btn-primary{background:var(--primary);color:#fff}.btn-primary:hover{background:#4338ca}
.btn-secondary{background:#f1f5f9;color:var(--text);border:1px solid var(--border)}.btn-secondary:hover{background:#e2e8f0}
.alert{padding:12px 16px;border-radius:10px;font-size:.85rem;font-weight:500;margin-bottom:18px;display:flex;align-items:center;gap:10px}
.alert-success{background:#d1fae5;color:#065f46;border:1px solid #a7f3d0}
.alert-error{background:#fee2e2;color:#991b1b;border:1px solid #fca5a5}
/* Modal */
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center}
.modal-overlay.show{display:flex}
.modal{background:#fff;border-radius:16px;padding:28px;width:100%;max-width:440px;box-shadow:0 20px 60px rgba(0,0,0,.2)}
.modal h3{font-size:1rem;font-weight:700;margin-bottom:16px;color:var(--text)}
.modal label{font-size:.8rem;font-weight:600;color:var(--muted);display:block;margin-bottom:6px}
.modal textarea,.modal select{width:100%;padding:10px 12px;border:1px solid var(--border);border-radius:9px;font-size:.85rem;font-family:inherit;outline:none;resize:vertical}
.modal textarea:focus,.modal select:focus{border-color:var(--primary)}
.modal-footer{display:flex;gap:10px;justify-content:flex-end;margin-top:20px}
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
  <a class="back-link" href="<%=ctx%>/tmServiceRequests"><i class="fas fa-arrow-left"></i> Back to list</a>

  <%if(flashOk!=null){%><div class="alert alert-success"><i class="fas fa-check-circle"></i><%=flashOk%></div><%}%>
  <%if(flashErr!=null){%><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i><%=flashErr%></div><%}%>

  <%
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

  <!-- INFO CARD -->
  <div class="card">
    <div class="card-title"><i class="fas fa-file-alt" style="color:var(--primary)"></i>Request Info
      <span class="badge <%=badgeSt%>" style="margin-left:auto"><%=sr.getStatusLabel()%></span>
    </div>
    <div class="info-grid">
      <div class="info-item"><label>Request Code</label><div class="val"><%=sr.getRequestCode()%></div></div>
      <div class="info-item"><label>Customer</label><div class="val"><%=sr.getCustomerName()%></div></div>
      <div class="info-item"><label>Contract</label><div class="val"><%=sr.getContractCode()%> <span style="color:var(--muted);font-size:.78rem">(<%=sr.getContractType()%>)</span></div></div>
      <div class="info-item"><label>Priority</label><div class="val"><span class="badge <%=badgePr%>"><%=sr.getPriority()%></span></div></div>
      <div class="info-item"><label>Title</label><div class="val"><%=sr.getTitle()%></div></div>
      <div class="info-item"><label>Created At</label><div class="val"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().replace("T"," ").substring(0,16):""%></div></div>
      <div class="info-item" style="grid-column:1/-1"><label>Description</label><div class="val" style="white-space:pre-wrap"><%=sr.getDescription()%></div></div>
    </div>
  </div>

  <!-- EQUIPMENT LIST -->
  <%if(!equips.isEmpty()){%>
  <div class="card">
    <div class="card-title"><i class="fas fa-cogs" style="color:var(--primary)"></i>Equipment (<%=equips.size()%>)</div>
    <table class="equip-table">
      <thead><tr><th>#</th><th>Name</th><th>Serial</th><th>Source</th><th>Issue</th></tr></thead>
      <tbody>
      <%int idx=1;for(ServiceRequestEquipment e:equips){%>
      <tr>
        <td><%=idx++%></td>
        <td><%=e.getDisplayName()!=null?e.getDisplayName():"-"%></td>
        <td><code style="font-size:.78rem"><%=e.getDisplaySerial()!=null?e.getDisplaySerial():"-"%></code></td>
        <td><%=e.getSource()!=null?e.getSource():"-"%></td>
        <td style="color:var(--muted)"><%=e.getIssueDescription()!=null?e.getIssueDescription():"-"%></td>
      </tr>
      <%}%>
      </tbody>
    </table>
  </div>
  <%}%>

  <!-- REVIEW INFO (if reviewed) -->
  <%if(sr.getReviewedBy()!=null){%>
  <div class="card">
    <div class="card-title"><i class="fas fa-user-check" style="color:var(--primary)"></i>Review Info</div>
    <div class="info-grid">
      <div class="info-item"><label>Reviewed By</label><div class="val"><%=sr.getReviewedByName()!=null?sr.getReviewedByName():"-"%></div></div>
      <div class="info-item"><label>Reviewed At</label><div class="val"><%=sr.getReviewedAt()!=null?sr.getReviewedAt().toString().replace("T"," ").substring(0,16):""%></div></div>
      <%if(sr.getRejectReason()!=null&&!sr.getRejectReason().isEmpty()){%>
      <div class="info-item" style="grid-column:1/-1"><label>Reject Reason</label><div class="val" style="color:var(--danger)"><%=sr.getRejectReason()%></div></div>
      <%}%>
    </div>
  </div>
  <%}%>

  <!-- ASSIGNED TECHNICIAN (if assigned) -->
  <%if(sr.getAssignedTo()!=null){%>
  <div class="card">
    <div class="card-title"><i class="fas fa-hard-hat" style="color:var(--primary)"></i>Assignment</div>
    <div class="info-grid">
      <div class="info-item"><label>Assigned To</label><div class="val"><%=sr.getAssignedToName()!=null?sr.getAssignedToName():"-"%></div></div>
      <div class="info-item"><label>Assigned At</label><div class="val"><%=sr.getAssignedAt()!=null?sr.getAssignedAt().toString().replace("T"," ").substring(0,16):""%></div></div>
    </div>
  </div>
  <%}%>

  <!-- ACTION BUTTONS -->
  <%if(isPending||isApproved){%>
  <div class="card">
    <div class="card-title"><i class="fas fa-tasks" style="color:var(--primary)"></i>Actions</div>
    <div class="action-bar">
      <%if(isPending){%>
        <button class="btn btn-success" onclick="document.getElementById('modalApprove').classList.add('show')">
          <i class="fas fa-check"></i> Approve
        </button>
        <button class="btn btn-danger" onclick="document.getElementById('modalReject').classList.add('show')">
          <i class="fas fa-times"></i> Reject
        </button>
      <%}%>
      <%if(isApproved&&!technicians.isEmpty()){%>
        <button class="btn btn-primary" onclick="document.getElementById('modalAssign').classList.add('show')">
          <i class="fas fa-user-plus"></i> Assign Technician
        </button>
      <%}%>
    </div>
  </div>
  <%}%>
</main>

<!-- MODAL: APPROVE -->
<div class="modal-overlay" id="modalApprove">
  <div class="modal">
    <h3><i class="fas fa-check-circle" style="color:var(--success);margin-right:8px"></i>Approve Request</h3>
    <p style="font-size:.85rem;color:var(--muted);margin-bottom:20px">
      Are you sure you want to approve <strong><%=sr.getRequestCode()%></strong>?<br>
      After approval, you can assign a technician.
    </p>
    <form method="post" action="<%=ctx%>/tmServiceRequests">
      <input type="hidden" name="action" value="approve">
      <input type="hidden" name="id" value="<%=sr.getId()%>">
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" onclick="document.getElementById('modalApprove').classList.remove('show')">Cancel</button>
        <button type="submit" class="btn btn-success"><i class="fas fa-check"></i> Yes, Approve</button>
      </div>
    </form>
  </div>
</div>

<!-- MODAL: REJECT -->
<div class="modal-overlay" id="modalReject">
  <div class="modal">
    <h3><i class="fas fa-times-circle" style="color:var(--danger);margin-right:8px"></i>Reject Request</h3>
    <form method="post" action="<%=ctx%>/tmServiceRequests">
      <input type="hidden" name="action" value="reject">
      <input type="hidden" name="id" value="<%=sr.getId()%>">
      <label>Reason for rejection <span style="color:var(--danger)">*</span></label>
      <textarea name="rejectReason" rows="4" placeholder="Explain why this request is rejected..." required></textarea>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" onclick="document.getElementById('modalReject').classList.remove('show')">Cancel</button>
        <button type="submit" class="btn btn-danger"><i class="fas fa-times"></i> Reject</button>
      </div>
    </form>
  </div>
</div>

<!-- MODAL: ASSIGN TECHNICIAN -->
<div class="modal-overlay" id="modalAssign">
  <div class="modal">
    <h3><i class="fas fa-user-plus" style="color:var(--primary);margin-right:8px"></i>Assign Technician</h3>
    <form method="post" action="<%=ctx%>/tmServiceRequests">
      <input type="hidden" name="action" value="assign">
      <input type="hidden" name="id" value="<%=sr.getId()%>">
      <label>Select Technician <span style="color:var(--danger)">*</span></label>
      <select name="technicianId" required>
        <option value="">-- Choose technician --</option>
        <%for(User t:technicians){%>
        <option value="<%=t.getId()%>"><%=t.getFullName()%><%=t.getEmail()!=null?" ("+t.getEmail()+")":""%></option>
        <%}%>
      </select>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" onclick="document.getElementById('modalAssign').classList.remove('show')">Cancel</button>
        <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> Assign</button>
      </div>
    </form>
  </div>
</div>

<script>
// Close modal when clicking outside
document.querySelectorAll('.modal-overlay').forEach(function(overlay){
    overlay.addEventListener('click', function(e){
        if(e.target === overlay) overlay.classList.remove('show');
    });
});
</script>
</body></html>