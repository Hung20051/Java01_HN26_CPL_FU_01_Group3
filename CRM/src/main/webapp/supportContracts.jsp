<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    List<model.Contract> contracts = (List<model.Contract>) request.getAttribute("contracts");
    if (contracts == null) contracts = new ArrayList<>();
    List<User> customers   = (List<User>) request.getAttribute("customers");
    if (customers == null) customers = new ArrayList<>();
    int total       = request.getAttribute("total")       != null ? (int)request.getAttribute("total")       : 0;
    int currentPage = request.getAttribute("page")        != null ? (int)request.getAttribute("page")        : 1;
    int totalPages  = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages")  : 1;
    String keyword  = request.getAttribute("keyword")     != null ? (String)request.getAttribute("keyword")  : "";
    String type     = request.getAttribute("type")        != null ? (String)request.getAttribute("type")     : "";
    String fStatus  = request.getAttribute("filterStatus")!= null ? (String)request.getAttribute("filterStatus") : "";

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Contracts - Customer Support</title>
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
                gap:12px;
                margin-bottom:20px;
                align-items:center;
                flex-wrap:wrap
            }
            .search-box{
                position:relative;
                flex:1;
                min-width:200px;
                max-width:320px
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
            select,input[type=text]{
                padding:8px 12px;
                border:1.5px solid var(--border);
                border-radius:8px;
                font-size:.82rem;
                font-family:inherit;
                outline:none;
                background:#fff
            }
            select:focus,input[type=text]:focus{
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
            .badge-active{
                background:#f0fdf4;
                color:#15803d
            }
            .badge-expired{
                background:#fef9c3;
                color:#854d0e
            }
            .badge-cancelled{
                background:#fef2f2;
                color:#991b1b
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
                justify-content:center;
                align-items:center
            }
            .page-btn{
                width:34px;
                height:34px;
                border-radius:8px;
                border:1.5px solid var(--border);
                background:#fff;
                cursor:pointer;
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
                max-width:580px;
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
            /* Equipment list in modal */
            .equip-loading{
                text-align:center;
                padding:20px;
                color:var(--muted);
                font-size:.82rem
            }
            .equip-list{
                display:flex;
                flex-direction:column;
                gap:8px;
                max-height:260px;
                overflow-y:auto
            }
            .equip-item{
                display:flex;
                align-items:center;
                gap:10px;
                padding:10px 12px;
                border:1.5px solid var(--border);
                border-radius:8px;
                cursor:pointer;
                transition:.15s
            }
            .equip-item:hover{
                border-color:var(--primary);
                background:#f5f3ff
            }
            .equip-item.selected{
                border-color:var(--primary);
                background:#eef2ff
            }
            .equip-item input[type=checkbox]{
                accent-color:var(--primary);
                width:16px;
                height:16px;
                flex-shrink:0
            }
            .equip-info{
                flex:1
            }
            .equip-name{
                font-size:.82rem;
                font-weight:600;
                color:var(--text)
            }
            .equip-meta{
                font-size:.72rem;
                color:var(--muted);
                margin-top:1px
            }
            .equip-badge{
                font-size:.67rem;
                padding:1px 7px;
                border-radius:10px;
                font-weight:600
            }
            .equip-warranty{
                background:#f0fdf4;
                color:#15803d
            }
            .equip-expired{
                background:#fef2f2;
                color:#991b1b
            }
            .equip-external{
                background:#eff6ff;
                color:#1d4ed8
            }
            .type-hint{
                padding:10px 14px;
                border-radius:8px;
                font-size:.78rem;
                margin-bottom:14px;
                display:none
            }
            .type-hint.show{
                display:flex;
                align-items:center;
                gap:8px
            }
            .hint-warranty{
                background:#eff6ff;
                color:#1d4ed8;
                border:1px solid #bfdbfe
            }
            .hint-maintenance{
                background:#fff7ed;
                color:#c2410c;
                border:1px solid #fed7aa
            }
            .equip-empty{
                text-align:center;
                padding:20px;
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
                <a href="<%=ctx%>/supportContracts"       class="sb-item on"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/supportServiceRequests" class="sb-item"><i class="fas fa-clipboard-list"></i> Service Requests</a>
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
                <h1><i class="fas fa-file-contract" style="color:var(--primary);margin-right:8px"></i>Contracts</h1>
                <button class="btn btn-primary" onclick="openCreate()"><i class="fas fa-plus"></i> New Contract</button>
            </div>
            <div class="content">

                <%if(flashOk!=null){%><div class="flash flash-ok"><i class="fas fa-check-circle"></i> <%=flashOk%></div><%}%>
                <%if(flashErr!=null){%><div class="flash flash-err"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div><%}%>

                <form method="get" action="<%=ctx%>/supportContracts">
                    <div class="toolbar">
                        <div class="search-box">
                            <i class="fas fa-search"></i>
                            <input type="text" name="keyword" value="<%=keyword%>" placeholder="Search code, customer...">
                        </div>
                        <select name="type">
                            <option value="">All Types</option>
                            <option value="WARRANTY"    <%="WARRANTY".equals(type)?"selected":""%>>Warranty</option>
                            <option value="MAINTENANCE" <%="MAINTENANCE".equals(type)?"selected":""%>>Maintenance</option>
                        </select>
                        <select name="status">
                            <option value="">All Status</option>
                            <option value="ACTIVE"    <%="ACTIVE".equals(fStatus)?"selected":""%>>Active</option>
                            <option value="EXPIRED"   <%="EXPIRED".equals(fStatus)?"selected":""%>>Expired</option>
                            <option value="CANCELLED" <%="CANCELLED".equals(fStatus)?"selected":""%>>Cancelled</option>
                        </select>
                        <button type="submit" class="btn btn-outline"><i class="fas fa-search"></i> Search</button>
                        <a href="<%=ctx%>/supportContracts" class="btn btn-outline"><i class="fas fa-times"></i> Clear</a>
                        <span style="margin-left:auto;font-size:.8rem;color:var(--muted)"><%=total%> contract(s)</span>
                    </div>
                </form>

                <div class="card">
                    <table>
                        <thead>
                            <tr><th>Code</th><th>Customer</th><th>Type</th><th>Start Date</th><th>End Date</th><th>Equipment</th><th>Status</th><th>Actions</th></tr>
                        </thead>
                        <tbody>
                            <% if (contracts.isEmpty()) { %>
                            <tr><td colspan="8" style="text-align:center;padding:30px;color:var(--muted)">No contracts found</td></tr>
                            <% } else { for (model.Contract c : contracts) { %>
                            <tr>
                                <td><a class="row-link" href="<%=ctx%>/supportContracts?action=detail&id=<%=c.getId()%>"><%=c.getContractCode()%></a></td>
                                <td><%=c.getCustomerName()%></td>
                                <td><span class="badge badge-<%=c.getContractType()%>"><%=c.getContractType()%></span></td>
                                <td style="color:var(--muted)"><%=c.getStartDate()%></td>
                                <td style="color:var(--muted)"><%=c.getEndDate()%></td>
                                <td style="text-align:center">
                                    <span style="background:#f1f5f9;padding:2px 10px;border-radius:20px;font-size:.75rem;font-weight:600"><%=c.getEquipmentCount()%></span>
                                </td>
                                <td><span class="badge badge-<%=c.getStatus().toLowerCase()%>"><%=c.getStatus()%></span></td>
                                <td>
                                    <a class="btn btn-sm btn-outline" href="<%=ctx%>/supportContracts?action=detail&id=<%=c.getId()%>">
                                        <i class="fas fa-eye"></i> View
                                    </a>
                                </td>
                            </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>

                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <% String qp="?keyword="+keyword+"&type="+type+"&status="+fStatus; %>
                    <a href="<%=ctx%>/supportContracts<%=qp%>&page=<%=currentPage-1%>" class="page-btn" <%=currentPage<=1?"style='pointer-events:none;opacity:.4'":""%>>‹</a>
                    <% for (int p=Math.max(1,currentPage-2); p<=Math.min(totalPages,currentPage+2); p++) { %>
                    <a href="<%=ctx%>/supportContracts<%=qp%>&page=<%=p%>" class="page-btn <%=p==currentPage?"active":""%>"><%=p%></a>
                    <% } %>
                    <a href="<%=ctx%>/supportContracts<%=qp%>&page=<%=currentPage+1%>" class="page-btn" <%=currentPage>=totalPages?"style='pointer-events:none;opacity:.4'":""%>>›</a>
                </div>
                <% } %>
            </div>
        </div>

        <%-- CREATE CONTRACT MODAL --%>
        <div class="modal-bg" id="createModal">
            <div class="modal">
                <button class="modal-close" onclick="closeModal('createModal')"><i class="fas fa-times"></i></button>
                <h2><i class="fas fa-file-contract" style="color:var(--primary);margin-right:8px"></i>Create New Contract</h2>
                <form method="post" action="<%=ctx%>/supportContracts" id="createForm">
                    <input type="hidden" name="action" value="create">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Customer *</label>
                            <select name="customerId" id="cModalCustomer" required onchange="onCustomerChange()">
                                <option value="">-- Select customer --</option>
                                <% for (User u : customers) { %>
                                <option value="<%=u.getId()%>"><%=u.getFullName()%> (<%=u.getUsername()%>)</option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Contract Type *</label>
                            <select name="contractType" id="cModalType" required onchange="onTypeChange()">
                                <option value="">-- Select type --</option>
                                <option value="WARRANTY">WARRANTY — Under Warranty</option>
                                <option value="MAINTENANCE">MAINTENANCE — Out of Warranty</option>
                            </select>
                        </div>
                    </div>

                    <%-- Type hint --%>
                    <div class="type-hint hint-warranty" id="hintWarranty">
                        <i class="fas fa-shield-alt"></i>
                        <span><strong>WARRANTY:</strong> Only equipment with active warranty (expires date &gt; today) will be shown.</span>
                    </div>
                    <div class="type-hint hint-maintenance" id="hintMaintenance">
                        <i class="fas fa-wrench"></i>
                        <span><strong>MAINTENANCE:</strong> Only equipment with expired or no warranty will be shown.</span>
                    </div>

                    <%-- Equipment selection --%>
                    <div class="form-group">
                        <label>Select Equipment * <span id="equipCountLabel" style="color:var(--muted);font-weight:400"></span></label>
                        <div id="equipContainer">
                            <div class="equip-empty">Please select a customer and contract type first.</div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Start Date *</label>
                            <input type="date" name="startDate" required>
                        </div>
                        <div class="form-group">
                            <label>End Date *</label>
                            <input type="date" name="endDate" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Notes</label>
                        <textarea name="notes" rows="2" placeholder="Additional notes..."></textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline" onclick="closeModal('createModal')">Cancel</button>
                        <button type="submit" class="btn btn-primary" id="createSubmitBtn"><i class="fas fa-save"></i> Create Contract</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            const CTX = '<%=ctx%>';
            let loadedEquipment = [];

            function openCreate() {
                document.getElementById('createModal').classList.add('open');
            }
            function closeModal(id) {
                document.getElementById(id).classList.remove('open');
            }
            document.querySelectorAll('.modal-bg').forEach(el => {
                el.addEventListener('click', e => {
                    if (e.target === el)
                        el.classList.remove('open');
                });
            });

            function onCustomerChange() {
                loadEquipment();
            }
            function onTypeChange() {
                const t = document.getElementById('cModalType').value;
                document.getElementById('hintWarranty').className = 'type-hint hint-warranty' + (t === 'WARRANTY' ? ' show' : '');
                document.getElementById('hintMaintenance').className = 'type-hint hint-maintenance' + (t === 'MAINTENANCE' ? ' show' : '');
                loadEquipment();
            }

            function loadEquipment() {
                const cid = document.getElementById('cModalCustomer').value;
                const type = document.getElementById('cModalType').value;
                const container = document.getElementById('equipContainer');

                if (!cid || !type) {
                    container.innerHTML = '<div class="equip-empty">Please select a customer and contract type first.</div>';
                    return;
                }

                container.innerHTML = '<div class="equip-loading"><i class="fas fa-spinner fa-spin"></i> Loading equipment...</div>';

                fetch(CTX + '/supportContracts?action=loadEquipment&customerId=' + cid + '&contractType=' + type)
                        .then(r => r.json())
                        .then(data => {
                            console.log('Equipment data:', JSON.stringify(data));
                            loadedEquipment = data;
                            renderEquipment(data, type);
                        })
                        .catch(() => {
                            container.innerHTML = '<div class="equip-empty" style="color:#991b1b">Failed to load equipment.</div>';
                        });
            }

            function renderEquipment(list, type) {
                const container = document.getElementById('equipContainer');
                if (!list || list.length === 0) {
                    const msg = type === 'WARRANTY'
                            ? 'No equipment with active warranty found for this customer.'
                            : 'No equipment with expired/no warranty found for this customer.';
                    container.innerHTML = '<div class="equip-empty">' + msg + '</div>';
                    document.getElementById('equipCountLabel').textContent = '';
                    return;
                }

                document.getElementById('equipCountLabel').textContent = '(' + list.length + ' available)';
                let html = '<div class="equip-list">';
                list.forEach(function (e) {
                    const isExternal = e.source === 'EXTERNAL';
                    let warrantyBadge = '';
                    if (e.warrantyExpires) {
                        if (new Date(e.warrantyExpires) >= new Date()) {
                            warrantyBadge = '<span class="equip-badge equip-warranty">Under Warranty</span>';
                        } else {
                            warrantyBadge = '<span class="equip-badge equip-expired">Expired</span>';
                        }
                    } else {
                        warrantyBadge = '<span class="equip-badge equip-expired">No Warranty</span>';
                    }
                    const srcBadge = isExternal
                            ? '<span class="equip-badge equip-external" style="margin-left:4px">External</span>'
                            : '';
                    const catText = e.category ? ' &middot; ' + e.category : '';
                    const warText = e.warrantyExpires ? ' &middot; Warranty expires: ' + e.warrantyExpires : '';

                    html += '<label class="equip-item" id="eitem-' + e.id + '">';
                    html += '<input type="checkbox" name="equipmentIds" value="' + e.id + '" onchange="toggleEquipItem(' + e.id + ', this.checked)">';
                    html += '<div class="equip-info">';
                    html += '<div class="equip-name">' + e.name + ' ' + warrantyBadge + srcBadge + '</div>';
                    html += '<div class="equip-meta">Serial: ' + e.serial + catText + warText + '</div>';
                    html += '</div>';
                    html += '</label>';
                });
                html += '</div>';
                container.innerHTML = html;
            }

            function toggleEquipItem(id, checked) {
                const el = document.getElementById('eitem-' + id);
                if (el)
                    el.classList.toggle('selected', checked);
            }

// Validate at least 1 equipment selected
            document.getElementById('createForm').addEventListener('submit', function (e) {
                const checked = this.querySelectorAll('input[name="equipmentIds"]:checked');
                if (checked.length === 0) {
                    e.preventDefault();
                    alert('Please select at least one equipment.');
                }
            });
        </script>
    </body></html>
