<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    List<User> customers  = (List<User>) request.getAttribute("customers");
    if (customers == null) customers = new ArrayList<>();
    int total       = request.getAttribute("total")      != null ? (int)request.getAttribute("total")      : 0;
    int currentPage = request.getAttribute("page")       != null ? (int)request.getAttribute("page")       : 1;
    int totalPages  = request.getAttribute("totalPages") != null ? (int)request.getAttribute("totalPages") : 1;
    String keyword  = request.getAttribute("keyword") != null ? (String)request.getAttribute("keyword") : "";
    String status   = request.getAttribute("status")  != null ? (String)request.getAttribute("status")  : "";

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Customers - Customer Support</title>
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
                transition:.15s;
                background:#fff
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
            .btn-danger{
                background:#fee2e2;
                color:#991b1b;
                border:none
            }
            .btn-danger:hover{
                background:#fecaca
            }
            .btn-success{
                background:#dcfce7;
                color:#166534;
                border:none
            }
            .btn-success:hover{
                background:#bbf7d0
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
            .badge-inactive{
                background:#f1f5f9;
                color:#64748b
            }
            .ava-circle{
                width:32px;
                height:32px;
                border-radius:50%;
                background:var(--primary);
                color:#fff;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                font-size:.8rem;
                font-weight:700;
                flex-shrink:0
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
                font-family:inherit;
                transition:.15s;
                text-decoration:none;
                color:var(--text)
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
                max-width:480px;
                max-height:90vh;
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
            .form-group input:focus,.form-group select:focus{
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
                <a href="<%=ctx%>/supportCustomers"       class="sb-item on"><i class="fas fa-users"></i> Customers</a>
                <a href="<%=ctx%>/supportContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/supportServiceRequests" class="sb-item"><i class="fas fa-clipboard-list"></i> Service Requests</a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/supportChat"            class="sb-item"><i class="fas fa-comment-dots"></i> Live Chat</a>
            </nav>
             <div class="sb-foot">
    <a href="<%=ctx%>/profile" class="sb-user" style="text-decoration:none;cursor:pointer">
        <div class="sb-ava" style="overflow:hidden;padding:0">
            <%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%>
            <img src="<%=ctx%><%=me.getAvatarUrl()%>" style="width:34px;height:34px;object-fit:cover;border-radius:50%">
            <%}else{%>
            <%=me.getFullName().substring(0,1).toUpperCase()%>
            <%}%>
        </div>
        <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer Support</div></div>
    </a>
    <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
</div>
        </aside>

        <div class="main">
            <div class="topbar">
                <h1><i class="fas fa-users" style="color:var(--primary);margin-right:8px"></i>Customers</h1>
                <button class="btn btn-primary" onclick="openCreate()"><i class="fas fa-plus"></i> Add Customer</button>
            </div>
            <div class="content">

                <%if(flashOk!=null){%><div class="flash flash-ok"><i class="fas fa-check-circle"></i> <%=flashOk%></div><%}%>
                <%if(flashErr!=null){%><div class="flash flash-err"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div><%}%>

                <form method="get" action="<%=ctx%>/supportCustomers">
                    <div class="toolbar">
                        <div class="search-box">
                            <i class="fas fa-search"></i>
                            <input type="text" name="keyword" value="<%=keyword%>" placeholder="Search name, email, username...">
                        </div>
                        <select name="status">
                            <option value="">All Status</option>
                            <option value="1" <%="1".equals(status)?"selected":""%>>Active</option>
                            <option value="0" <%="0".equals(status)?"selected":""%>>Inactive</option>
                        </select>
                        <button type="submit" class="btn btn-outline"><i class="fas fa-search"></i> Search</button>
                        <a href="<%=ctx%>/supportCustomers" class="btn btn-outline"><i class="fas fa-times"></i> Clear</a>
                        <span style="margin-left:auto;font-size:.8rem;color:var(--muted)"><%=total%> customer(s)</span>
                    </div>
                </form>

                <div class="card">
                    <table>
                        <thead>
                            <tr><th>#</th><th>Customer</th><th>Username</th><th>Phone</th><th>Email</th><th>Status</th><th>Actions</th></tr>
                        </thead>
                        <tbody>
                            <% if (customers.isEmpty()) { %>
                            <tr><td colspan="7" style="text-align:center;padding:30px;color:var(--muted)">No customers found</td></tr>
                            <% } else { int idx = (currentPage-1)*10+1; for (User u : customers) { %>
                            <tr>
                                <td style="color:var(--muted)"><%=idx++%></td>
                                <td>
                                    <div style="display:flex;align-items:center;gap:10px">
                                        <div class="ava-circle"><%=u.getFullName().substring(0,1).toUpperCase()%></div>
                                        <div>
                                            <div style="font-weight:600"><%=u.getFullName()%></div>
                                            <div style="font-size:.72rem;color:var(--muted)">ID #<%=u.getId()%></div>
                                        </div>
                                    </div>
                                </td>
                                <td style="color:var(--muted)"><%=u.getUsername()%></td>
                                <td><%=u.getPhone()!=null?u.getPhone():"-"%></td>
                                <td><%=u.getEmail()!=null?u.getEmail():"-"%></td>
                                <td><span class="badge <%=u.isActive()?"badge-active":"badge-inactive"%>"><%=u.isActive()?"Active":"Inactive"%></span></td>
                                <td>
                                    <div style="display:flex;gap:6px">
                                        <button class="btn btn-sm btn-outline"
                                                onclick="openEdit(<%=u.getId()%>, '<%=u.getFullName().replace("'","\\'")%>', '<%=u.getEmail()!=null?u.getEmail().replace("'","\\'"):""%>', '<%=u.getPhone()!=null?u.getPhone():""%>')">
                                            <i class="fas fa-edit"></i> Edit
                                        </button>
                                        <form method="post" action="<%=ctx%>/supportCustomers" style="display:inline"
                                              onsubmit="return confirm('<%=u.isActive()?"Deactivate":"Activate"%> this customer?')">
                                            <input type="hidden" name="action" value="toggle">
                                            <input type="hidden" name="id" value="<%=u.getId()%>">
                                            <button type="submit" class="btn btn-sm <%=u.isActive()?"btn-danger":"btn-success"%>">
                                                <i class="fas fa-<%=u.isActive()?"ban":"check"%>"></i> <%=u.isActive()?"Deactivate":"Activate"%>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>

                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <% String qp = "?keyword=" + keyword + "&status=" + status; %>
                    <a href="<%=ctx%>/supportCustomers<%=qp%>&page=<%=currentPage-1%>" class="page-btn" <%=currentPage<=1?"style='pointer-events:none;opacity:.4'":""%>>‹</a>
                    <% for (int pg = Math.max(1,currentPage-2); pg <= Math.min(totalPages,currentPage+2); pg++) { %>
                    <a href="<%=ctx%>/supportCustomers<%=qp%>&page=<%=pg%>" class="page-btn <%=pg==currentPage?"active":""%>"><%=pg%></a>
                    <% } %>
                    <a href="<%=ctx%>/supportCustomers<%=qp%>&page=<%=currentPage+1%>" class="page-btn" <%=currentPage>=totalPages?"style='pointer-events:none;opacity:.4'":""%>>›</a>
                </div>
                <% } %>

            </div>
        </div>

        <%-- CREATE MODAL --%>
        <div class="modal-bg" id="createModal">
            <div class="modal">
                <button class="modal-close" onclick="closeModal('createModal')"><i class="fas fa-times"></i></button>
                <h2><i class="fas fa-user-plus" style="color:var(--primary);margin-right:8px"></i>Add New Customer</h2>
                <form method="post" action="<%=ctx%>/supportCustomers">
                    <input type="hidden" name="action" value="create">
                    <div class="form-row">
                        <div class="form-group">
                            <label>Full Name *</label>
                            <input type="text" name="fullName" required placeholder="Nguyen Van A">
                        </div>
                        <div class="form-group">
                            <label>Phone</label>
                            <input type="text" name="phone" placeholder="0901234567">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Email *</label>
                        <input type="email" name="email" required placeholder="customer@email.com">
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Username *</label>
                            <input type="text" name="username" required placeholder="customer_abc">
                        </div>
                        <div class="form-group">
                            <label>Password *</label>
                            <input type="password" name="password" required placeholder="Min 6 characters">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline" onclick="closeModal('createModal')">Cancel</button>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Create Customer</button>
                    </div>
                </form>
            </div>
        </div>

        <%-- EDIT MODAL --%>
        <div class="modal-bg" id="editModal">
            <div class="modal">
                <button class="modal-close" onclick="closeModal('editModal')"><i class="fas fa-times"></i></button>
                <h2><i class="fas fa-user-edit" style="color:var(--primary);margin-right:8px"></i>Edit Customer</h2>
                <form method="post" action="<%=ctx%>/supportCustomers">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="id" id="editId">
                    <div class="form-row">
                        <div class="form-group">
                            <label>Full Name *</label>
                            <input type="text" name="fullName" id="editFullName" required>
                        </div>
                        <div class="form-group">
                            <label>Phone</label>
                            <input type="text" name="phone" id="editPhone">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Email *</label>
                        <input type="email" name="email" id="editEmail" required>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline" onclick="closeModal('editModal')">Cancel</button>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Save Changes</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function openCreate() {
                document.getElementById('createModal').classList.add('open');
            }
            function openEdit(id, name, email, phone) {
                document.getElementById('editId').value = id;
                document.getElementById('editFullName').value = name;
                document.getElementById('editEmail').value = email;
                document.getElementById('editPhone').value = phone;
                document.getElementById('editModal').classList.add('open');
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
        </script>
    </body></html>