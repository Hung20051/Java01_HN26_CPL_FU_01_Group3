<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    List<ServiceRequest> requests = (List<ServiceRequest>) request.getAttribute("requests");
    if (requests == null) requests = new ArrayList<>();
    List<User> customers = (List<User>) request.getAttribute("customers");
    if (customers == null) customers = new ArrayList<>();
    int total       = request.getAttribute("total")       != null ? (int)request.getAttribute("total")       : 0;
    int currentPage = request.getAttribute("page")        != null ? (int)request.getAttribute("page")        : 1;
    int totalPages  = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages")  : 1;
    String keyword  = request.getAttribute("keyword")     != null ? (String)request.getAttribute("keyword")  : "";
    String fStatus  = request.getAttribute("filterStatus")!= null ? (String)request.getAttribute("filterStatus") : "";
    String fPriority= request.getAttribute("filterPriority")!=null?(String)request.getAttribute("filterPriority"):"";
    String fType    = request.getAttribute("filterType")  != null ? (String)request.getAttribute("filterType")   : "";

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Service Requests - Customer Support</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root{
                --primary:#4f46e5;
                --sidebar:#0f172a;
                --bg:#f1f5f9;
                --surface:#fff;
                --border:#e2e8f0;
                --text:#0f172a;
                --muted:#64748b;
                --success:#10b981;
                --danger:#ef4444;
                --warning:#f59e0b;
                --sb-w:220px
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
                width:var(--sb-w);
                height:100vh;
                background:var(--sidebar);
                display:flex;
                flex-direction:column;
                flex-shrink:0;
                position:sticky;
                top:0
            }
            .sb-brand{
                padding:20px 16px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid rgba(255,255,255,.07)
            }
            .sb-logo{
                width:32px;
                height:32px;
                background:var(--primary);
                border-radius:8px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.85rem
            }
            .sb-name{
                color:#fff;
                font-size:.95rem;
                font-weight:700
            }
            .sb-sub{
                color:rgba(255,255,255,.35);
                font-size:.65rem
            }
            .sb-nav{
                flex:1;
                padding:12px 8px;
                overflow-y:auto
            }
            .sb-lbl{
                color:rgba(255,255,255,.28);
                font-size:.6rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.2px;
                padding:0 8px;
                margin:12px 0 4px
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:8px;
                padding:8px 10px;
                border-radius:7px;
                margin-bottom:2px;
                color:rgba(255,255,255,.55);
                text-decoration:none;
                font-size:.82rem;
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
                width:16px;
                text-align:center;
                font-size:.8rem
            }
            .sb-foot{
                padding:12px 8px 16px;
                border-top:1px solid rgba(255,255,255,.07)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:8px;
                padding:8px 10px;
                border-radius:8px;
                background:rgba(255,255,255,.05);
                margin-bottom:6px
            }
            .sb-ava{
                width:32px;
                height:32px;
                border-radius:50%;
                background:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.82rem;
                font-weight:700
            }
            .sb-uname{
                color:#fff;
                font-size:.78rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,.38);
                font-size:.67rem
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:7px 10px;
                border-radius:7px;
                color:rgba(255,255,255,.45);
                text-decoration:none;
                font-size:.78rem;
                transition:.15s
            }
            .sb-logout:hover{
                color:#f87171;
                background:rgba(248,113,113,.1)
            }
            .main{
                flex:1;
                display:flex;
                flex-direction:column;
                min-width:0
            }
            .topbar{
                background:var(--surface);
                border-bottom:1px solid var(--border);
                padding:0 28px;
                height:58px;
                display:flex;
                align-items:center;
                justify-content:space-between;
                flex-shrink:0
            }
            .topbar h1{
                font-size:1.05rem;
                font-weight:700;
                color:var(--text)
            }
            .content{
                padding:28px;
                flex:1
            }
            .toolbar{
                display:flex;
                gap:10px;
                margin-bottom:20px;
                align-items:center;
                flex-wrap:wrap
            }
            .search-box{
                position:relative;
                flex:1;
                min-width:180px;
                max-width:280px
            }
            .search-box input{
                width:100%;
                padding:8px 12px 8px 34px;
                border:1.5px solid var(--border);
                border-radius:8px;
                font-size:.82rem;
                font-family:inherit;
                outline:none;
                background:#fff;
                transition:.15s
            }
            .search-box input:focus{
                border-color:var(--primary)
            }
            .search-box i{
                position:absolute;
                left:11px;
                top:50%;
                transform:translateY(-50%);
                color:var(--muted);
                font-size:.78rem
            }
            select{
                padding:8px 12px;
                border:1.5px solid var(--border);
                border-radius:8px;
                font-size:.82rem;
                font-family:inherit;
                outline:none;
                background:#fff;
                cursor:pointer
            }
            select:focus{
                border-color:var(--primary)
            }
            .btn{
                padding:8px 16px;
                border-radius:8px;
                border:none;
                cursor:pointer;
                font-size:.82rem;
                font-weight:600;
                font-family:inherit;
                display:inline-flex;
                align-items:center;
                gap:6px;
                transition:.15s;
                text-decoration:none
            }
            .btn-primary{
                background:var(--primary);
                color:#fff
            }
            .btn-primary:hover{
                background:#4338ca
            }
            .btn-sm{
                padding:5px 11px;
                font-size:.75rem
            }
            .btn-outline{
                background:#fff;
                color:var(--text);
                border:1.5px solid var(--border)
            }
            .btn-outline:hover{
                border-color:var(--primary);
                color:var(--primary)
            }
            .card{
                background:var(--surface);
                border-radius:12px;
                border:1px solid var(--border);
                overflow:hidden
            }
            table{
                width:100%;
                border-collapse:collapse
            }
            th{
                padding:10px 16px;
                text-align:left;
                font-size:.72rem;
                font-weight:700;
                color:var(--muted);
                text-transform:uppercase;
                letter-spacing:.5px;
                background:#f8fafc;
                border-bottom:1px solid var(--border)
            }
            td{
                padding:11px 16px;
                font-size:.8rem;
                color:var(--text);
                border-bottom:1px solid #f8fafc;
                vertical-align:middle
            }
            tr:last-child td{
                border-bottom:none
            }
            tr:hover td{
                background:#fafafa
            }
            .badge{
                display:inline-flex;
                align-items:center;
                padding:2px 9px;
                border-radius:20px;
                font-size:.7rem;
                font-weight:600
            }
            .badge-pending{
                background:#fef3c7;
                color:#92400e
            }
            .badge-approved{
                background:#d1fae5;
                color:#065f46
            }
            .badge-in_progress{
                background:#dbeafe;
                color:#1e40af
            }
            .badge-completed{
                background:#f0fdf4;
                color:#166534
            }
            .badge-rejected{
                background:#fee2e2;
                color:#991b1b
            }
            .badge-cancelled{
                background:#f1f5f9;
                color:#475569
            }
            .badge-high{
                background:#fee2e2;
                color:#991b1b
            }
            .badge-medium{
                background:#fef3c7;
                color:#92400e
            }
            .badge-low{
                background:#f0fdf4;
                color:#166534
            }
            .badge-urgent{
                background:#fce7f3;
                color:#9d174d
            }
            .badge-WARRANTY{
                background:#eff6ff;
                color:#1d4ed8
            }
            .badge-MAINTENANCE{
                background:#fff7ed;
                color:#c2410c
            }
            a.row-link{
                color:var(--primary);
                text-decoration:none;
                font-weight:600
            }
            a.row-link:hover{
                text-decoration:underline
            }
            .pagination{
                display:flex;
                gap:6px;
                margin-top:18px;
                justify-content:center
            }
            .page-btn{
                width:34px;
                height:34px;
                border-radius:8px;
                border:1.5px solid var(--border);
                background:#fff;
                font-size:.8rem;
                display:flex;
                align-items:center;
                justify-content:center;
                text-decoration:none;
                color:var(--text);
                transition:.15s
            }
            .page-btn:hover{
                border-color:var(--primary);
                color:var(--primary)
            }
            .page-btn.active{
                background:var(--primary);
                color:#fff;
                border-color:var(--primary)
            }
            .flash{
                padding:12px 16px;
                border-radius:8px;
                margin-bottom:18px;
                font-size:.82rem;
                font-weight:500
            }
            .flash-ok{
                background:#f0fdf4;
                color:#166534;
                border:1px solid #bbf7d0
            }
            .flash-err{
                background:#fef2f2;
                color:#991b1b;
                border:1px solid #fecaca
            }
            /* Modal */
            .modal-bg{
                display:none;
                position:fixed;
                inset:0;
                background:rgba(0,0,0,.45);
                z-index:1000;
                align-items:center;
                justify-content:center
            }
            .modal-bg.open{
                display:flex
            }
            .modal{
                background:#fff;
                border-radius:14px;
                width:100%;
                max-width:620px;
                max-height:92vh;
                overflow-y:auto;
                padding:28px;
                position:relative
            }
            .modal h2{
                font-size:1rem;
                font-weight:700;
                margin-bottom:20px;
                color:var(--text)
            }
            .modal-close{
                position:absolute;
                top:16px;
                right:18px;
                background:none;
                border:none;
                font-size:1.1rem;
                cursor:pointer;
                color:var(--muted)
            }
            .modal-close:hover{
                color:var(--danger)
            }
            .form-group{
                margin-bottom:16px
            }
            .form-group label{
                display:block;
                font-size:.78rem;
                font-weight:600;
                color:var(--text);
                margin-bottom:5px
            }
            .form-group input,.form-group select,.form-group textarea{
                width:100%;
                padding:9px 12px;
                border:1.5px solid var(--border);
                border-radius:8px;
                font-size:.82rem;
                font-family:inherit;
                outline:none;
                transition:.15s
            }
            .form-group input:focus,.form-group select:focus,.form-group textarea:focus{
                border-color:var(--primary)
            }
            .form-row{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:12px
            }
            .modal-footer{
                display:flex;
                gap:10px;
                justify-content:flex-end;
                margin-top:20px;
                padding-top:16px;
                border-top:1px solid var(--border)
            }
            /* Equipment in modal */
            .equip-section{
                border:1.5px solid var(--border);
                border-radius:8px;
                overflow:hidden
            }
            .equip-section-hd{
                padding:10px 14px;
                background:#f8fafc;
                border-bottom:1px solid var(--border);
                font-size:.78rem;
                font-weight:600;
                color:var(--text)
            }
            .equip-row{
                display:flex;
                align-items:flex-start;
                gap:10px;
                padding:10px 14px;
                border-bottom:1px solid #f8fafc
            }
            .equip-row:last-child{
                border-bottom:none
            }
            .equip-row-info{
                flex:1
            }
            .equip-row-name{
                font-size:.8rem;
                font-weight:600
            }
            .equip-row-serial{
                font-size:.72rem;
                color:var(--muted)
            }
            .equip-row-issue{
                margin-top:6px
            }
            .equip-row-issue input{
                padding:6px 10px;
                border:1.5px solid var(--border);
                border-radius:6px;
                font-size:.78rem;
                width:100%;
                font-family:inherit;
                outline:none
            }
            .equip-row-issue input:focus{
                border-color:var(--primary)
            }
            .equip-empty{
                padding:20px;
                text-align:center;
                color:var(--muted);
                font-size:.82rem
            }
            .equip-loading{
                padding:20px;
                text-align:center;
                color:var(--muted);
                font-size:.82rem
            }
        </style>
    </head><body>

        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-bolt"></i></div>
                <div><div class="sb-name">DRSMS System</div><div class="sb-sub">Customer Support</div></div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/supportDashboard"      class="sb-item"><i class="fas fa-home"></i> Dashboard</a>
                <div class="sb-lbl">Management</div>
                <a href="<%=ctx%>/supportCustomers"       class="sb-item"><i class="fas fa-users"></i> Customers</a>
                <a href="<%=ctx%>/supportContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/supportServiceRequests" class="sb-item on"><i class="fas fa-clipboard-list"></i> Service Requests</a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/supportChat"            class="sb-item"><i class="fas fa-comment-dots"></i> Live Chat</a>
            </nav>
            <div class="sb-foot">
                <div class="sb-user">
                    <div class="sb-ava"><%=me.getFullName().substring(0,1).toUpperCase()%></div>
                    <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer Support</div></div>
                </div>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Log out</a>
            </div>
        </aside>

        <div class="main">
            <div class="topbar">
                <h1><i class="fas fa-clipboard-list" style="color:var(--primary);margin-right:8px"></i>Service Requests</h1>
                <button class="btn btn-primary" onclick="openCreate()"><i class="fas fa-plus"></i> Create on Behalf</button>
            </div>
            <div class="content">
                <%if(flashOk!=null){%><div class="flash flash-ok"><i class="fas fa-check-circle"></i> <%=flashOk%></div><%}%>
                <%if(flashErr!=null){%><div class="flash flash-err"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div><%}%>

                <form method="get" action="<%=ctx%>/supportServiceRequests">
                    <div class="toolbar">
                        <div class="search-box">
                            <i class="fas fa-search"></i>
                            <input type="text" name="keyword" value="<%=keyword%>" placeholder="Code, customer, title...">
                        </div>
                        <select name="status">
                            <option value="">All Status</option>
                            <option value="PENDING"     <%="PENDING".equals(fStatus)?"selected":""%>>Pending</option>
                            <option value="APPROVED"    <%="APPROVED".equals(fStatus)?"selected":""%>>Approved</option>
                            <option value="IN_PROGRESS" <%="IN_PROGRESS".equals(fStatus)?"selected":""%>>In Progress</option>
                            <option value="COMPLETED"   <%="COMPLETED".equals(fStatus)?"selected":""%>>Completed</option>
                            <option value="REJECTED"    <%="REJECTED".equals(fStatus)?"selected":""%>>Rejected</option>
                            <option value="CANCELLED"   <%="CANCELLED".equals(fStatus)?"selected":""%>>Cancelled</option>
                        </select>
                        <select name="priority">
                            <option value="">All Priority</option>
                            <option value="LOW"    <%="LOW".equals(fPriority)?"selected":""%>>Low</option>
                            <option value="MEDIUM" <%="MEDIUM".equals(fPriority)?"selected":""%>>Medium</option>
                            <option value="HIGH"   <%="HIGH".equals(fPriority)?"selected":""%>>High</option>
                            <option value="URGENT" <%="URGENT".equals(fPriority)?"selected":""%>>Urgent</option>
                        </select>
                        <select name="contractType">
                            <option value="">All Types</option>
                            <option value="WARRANTY"    <%="WARRANTY".equals(fType)?"selected":""%>>Warranty</option>
                            <option value="MAINTENANCE" <%="MAINTENANCE".equals(fType)?"selected":""%>>Maintenance</option>
                        </select>
                        <button type="submit" class="btn btn-outline"><i class="fas fa-search"></i></button>
                        <a href="<%=ctx%>/supportServiceRequests" class="btn btn-outline"><i class="fas fa-times"></i></a>
                        <span style="margin-left:auto;font-size:.8rem;color:var(--muted)"><%=total%> request(s)</span>
                    </div>
                </form>

                <div class="card">
                    <table>
                        <thead><tr><th>Code</th><th>Customer</th><th>Contract</th><th>Title</th><th>Priority</th><th>Status</th><th>Created</th><th></th></tr></thead>
                        <tbody>
                            <%if(requests.isEmpty()){%>
                            <tr><td colspan="8" style="text-align:center;padding:30px;color:var(--muted)">No service requests found</td></tr>
                            <%}else{for(ServiceRequest sr:requests){
                                String st  = sr.getStatus()  != null ? sr.getStatus().toLowerCase().replace("_","-")  : "";
                                String pri = sr.getPriority() != null ? sr.getPriority().toLowerCase() : "medium";
                            %>
                            <tr>
                                <td><a class="row-link" href="<%=ctx%>/supportServiceRequests?action=detail&id=<%=sr.getId()%>"><%=sr.getRequestCode()%></a></td>
                                <td><%=sr.getCustomerName()%></td>
                                <td>
                                    <div style="font-size:.75rem"><%=sr.getContractCode()%></div>
                                    <span class="badge badge-<%=sr.getContractType()%>" style="font-size:.65rem;margin-top:2px"><%=sr.getContractType()%></span>
                                </td>
                                <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="<%=sr.getTitle()%>"><%=sr.getTitle()%></td>
                                <td><span class="badge badge-<%=pri%>"><%=sr.getPriority()%></span></td>
                                <td><span class="badge badge-<%=st%>"><%=sr.getStatus()%></span></td>
                                <td style="color:var(--muted);font-size:.75rem"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().substring(0,10):""%></td>
                                <td><a class="btn btn-sm btn-outline" href="<%=ctx%>/supportServiceRequests?action=detail&id=<%=sr.getId()%>"><i class="fas fa-eye"></i></a></td>
                            </tr>
                            <%}}%>
                        </tbody>
                    </table>
                </div>

                <%if(totalPages>1){%>
                <div class="pagination">
                    <%String qp="?keyword="+keyword+"&status="+fStatus+"&priority="+fPriority+"&contractType="+fType;%>
                    <a href="<%=ctx%>/supportServiceRequests<%=qp%>&page=<%=currentPage-1%>" class="page-btn" <%=currentPage<=1?"style='pointer-events:none;opacity:.4'":""%>>‹</a>
                    <%for(int p=Math.max(1,currentPage-2);p<=Math.min(totalPages,currentPage+2);p++){%>
                    <a href="<%=ctx%>/supportServiceRequests<%=qp%>&page=<%=p%>" class="page-btn <%=p==currentPage?"active":""%>"><%=p%></a>
                    <%}%>
                    <a href="<%=ctx%>/supportServiceRequests<%=qp%>&page=<%=currentPage+1%>" class="page-btn" <%=currentPage>=totalPages?"style='pointer-events:none;opacity:.4'":""%>>›</a>
                </div>
                <%}%>
            </div>
        </div>

        <%-- CREATE SR MODAL --%>
        <div class="modal-bg" id="createModal">
            <div class="modal">
                <button class="modal-close" onclick="closeModal()"><i class="fas fa-times"></i></button>
                <h2><i class="fas fa-plus-circle" style="color:var(--primary);margin-right:8px"></i>Create Service Request on Behalf</h2>
                <form method="post" action="<%=ctx%>/supportServiceRequests" id="srForm">
                    <input type="hidden" name="action" value="create">

                    <%-- Step 1: Customer --%>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Customer *</label>
                            <select name="customerId" id="srCustomer" required onchange="loadContracts()">
                                <option value="">-- Select customer --</option>
                                <%for(User u:customers){%>
                                <option value="<%=u.getId()%>"><%=u.getFullName()%></option>
                                <%}%>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Contract *</label>
                            <select name="contractId" id="srContract" required onchange="loadEquipment()" disabled>
                                <option value="">-- Select contract first --</option>
                            </select>
                        </div>
                    </div>

                    <%-- Step 2: Equipment --%>
                    <div class="form-group">
                        <label>Equipment & Issue Description *</label>
                        <div id="srEquipContainer">
                            <div class="equip-empty">Select a customer and contract to load equipment.</div>
                        </div>
                    </div>

                    <%-- Step 3: Request info --%>
                    <div class="form-group">
                        <label>Title *</label>
                        <input type="text" name="title" required placeholder="Brief description of the issue">
                    </div>
                    <div class="form-group">
                        <label>Description *</label>
                        <textarea name="description" rows="3" required placeholder="Detailed description..."></textarea>
                    </div>
                    <div class="form-group">
                        <label>Priority *</label>
                        <select name="priority" required>
                            <option value="LOW">Low</option>
                            <option value="MEDIUM" selected>Medium</option>
                            <option value="HIGH">High</option>
                            <option value="URGENT">Urgent</option>
                        </select>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline" onclick="closeModal()">Cancel</button>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> Submit Request</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            const CTX = '<%=ctx%>';

            function openCreate() {
                document.getElementById('createModal').classList.add('open');
            }
            function closeModal() {
                document.getElementById('createModal').classList.remove('open');
            }
            document.getElementById('createModal').addEventListener('click', e => {
                if (e.target === document.getElementById('createModal'))
                    closeModal();
            });

            function loadContracts() {
                const cid = document.getElementById('srCustomer').value;
                const sel = document.getElementById('srContract');
                sel.innerHTML = '<option value="">Loading...</option>';
                sel.disabled = true;
                document.getElementById('srEquipContainer').innerHTML = '<div class="equip-empty">Select a contract to load equipment.</div>';

                if (!cid) {
                    sel.innerHTML = '<option value="">-- Select contract first --</option>';
                    return;
                }

                fetch(CTX + '/supportServiceRequests?action=getContracts&customerId=' + cid)
                        .then(r => r.json())
                        .then(list => {
                            if (list.length === 0) {
                                sel.innerHTML = '<option value="">No active contracts</option>';
                                return;
                            }
                            sel.innerHTML = '<option value="">-- Select contract --</option>';
                            list.forEach(c => {
                                sel.innerHTML += '<option value="' + c.id + '">[' + c.type + '] ' + c.code + ' \u00b7 ends ' + c.endDate + '</option>';
                            });
                            sel.disabled = false;
                        })
                        .catch(() => {
                            sel.innerHTML = '<option value="">Failed to load</option>';
                        });
            }

            function loadEquipment() {
                const contractId = document.getElementById('srContract').value;
                const container = document.getElementById('srEquipContainer');
                if (!contractId) {
                    container.innerHTML = '<div class="equip-empty">Select a contract to load equipment.</div>';
                    return;
                }
                container.innerHTML = '<div class="equip-loading"><i class="fas fa-spinner fa-spin"></i> Loading equipment...</div>';
                fetch(CTX + '/supportServiceRequests?action=getEquipment&contractId=' + contractId)
                        .then(function (r) {
                            return r.json();
                        })
                        .then(function (list) {
                            if (!list || list.length === 0) {
                                container.innerHTML = '<div class="equip-empty">No equipment found for this contract.</div>';
                                return;
                            }
                            let html = '<div class="equip-section"><div class="equip-section-hd">Select equipment and describe the issue</div>';
                            list.forEach(function (e) {
                                html += '<div class="equip-row" id="erow-' + e.id + '">';
                                html += '<input type="checkbox" value="' + e.id + '" id="echeck-' + e.id + '"';
                                html += ' style="accent-color:var(--primary);width:16px;height:16px;flex-shrink:0;margin-top:3px"';
                                html += ' onchange="toggleEquipRow(' + e.id + ', this.checked)">';
                                html += '<div class="equip-row-info">';
                                html += '<label for="echeck-' + e.id + '" style="cursor:pointer">';
                                html += '<div class="equip-row-name">' + e.name + '</div>';
                                html += '<div class="equip-row-serial">Serial: ' + e.serial + '</div>';
                                html += '</label>';
                                html += '<div class="equip-row-issue" id="eissue-' + e.id + '" style="display:none;margin-top:6px">';
                                html += '<input type="text" id="edesc-' + e.id + '"';
                                html += ' placeholder="Describe the issue with this equipment (optional)"';
                                html += ' style="padding:6px 10px;border:1.5px solid var(--border);border-radius:6px;font-size:.78rem;width:100%;font-family:inherit;outline:none">';
                                html += '</div>';
                                html += '</div>';
                                html += '</div>';
                            });
                            html += '</div>';
                            container.innerHTML = html;
                        })
                        .catch(function () {
                            container.innerHTML = '<div class="equip-empty" style="color:#991b1b">Failed to load equipment.</div>';
                        });
            }

            function toggleEquipRow(id, checked) {
                document.getElementById('eissue-' + id).style.display = checked ? 'block' : 'none';
            }

            document.getElementById('srForm').addEventListener('submit', function (e) {
                this.querySelectorAll('input.injected').forEach(el => el.remove());

                const rows = document.querySelectorAll('[id^="erow-"]');
                let checkedCount = 0;
                rows.forEach(row => {
                    const id = row.id.replace('erow-', '');
                    const cb = document.getElementById('echeck-' + id);
                    if (cb && cb.checked) {
                        checkedCount++;
                        const descVal = (document.getElementById('edesc-' + id) || {}).value || '';
                        const hidId = document.createElement('input');
                        hidId.type = 'hidden';
                        hidId.name = 'equipmentIds';
                        hidId.value = id;
                        hidId.className = 'injected';
                        this.appendChild(hidId);

                        const hidDesc = document.createElement('input');
                        hidDesc.type = 'hidden';
                        hidDesc.name = 'issueDescriptions';
                        hidDesc.value = descVal;
                        hidDesc.className = 'injected';
                        this.appendChild(hidDesc);
                    }
                });

                if (checkedCount === 0) {
                    e.preventDefault();
                    alert('Please select at least one equipment.');
                }
            });
        </script>
    </body></html>
