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
         <link rel="preconnect" href="https://fonts.googleapis.com">
       <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
/* ════════════════════ DESIGN SYSTEM ════════════════════ */
:root {
    --navy:        #0b1437;
    --navy-2:      #0f1c4d;
    --navy-card:   #111a42;
    --accent:      #4f7ef8;
    --accent-2:    #7c9ffa;
    --accent-glow: rgba(79,126,248,0.22);
    --green:       #34d399;
    --green-dim:   rgba(52,211,153,0.12);
    --amber:       #fbbf24;
    --amber-dim:   rgba(251,191,36,0.12);
    --danger:      #f87171;
    --danger-dim:  rgba(248,113,113,0.12);
    --purple:      #a78bfa;
    --purple-dim:  rgba(167,139,250,0.12);
    --info:        #38bdf8;
    --info-dim:    rgba(56,189,248,0.12);
    --text:        #ffffff;
    --text-2:      #c8d4f0;
    --muted:       #7a8ab8;
    --border:      rgba(255,255,255,0.07);
    --border-2:    rgba(255,255,255,0.04);
    --sb-w:        220px;
    /* legacy aliases */
    --primary:     #4f7ef8;
    --success:     #34d399;
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
body {
    font-family: 'Sora', sans-serif;
    background: var(--navy);
    color: var(--text);
    min-height: 100vh;
    display: flex;
}
::-webkit-scrollbar { width: 4px; }
::-webkit-scrollbar-track { background: var(--navy); }
::-webkit-scrollbar-thumb { background: rgba(79,126,248,0.4); border-radius: 4px; }

/* ════════════════════ SIDEBAR ════════════════════ */
.sb {
    width: var(--sb-w);
    height: 100vh;
    background: rgba(9,15,40,0.95);
    backdrop-filter: blur(20px);
    border-right: 1px solid var(--border);
    display: flex; flex-direction: column;
    flex-shrink: 0;
    position: sticky; top: 0;
}
.sb-brand {
    padding: 22px 18px 16px;
    display: flex; align-items: center; gap: 10px;
    border-bottom: 1px solid var(--border);
}
.sb-logo {
    width: 36px; height: 36px;
    background: linear-gradient(135deg, var(--accent), var(--accent-2));
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    color: #fff; font-size: 0.88rem;
    box-shadow: 0 4px 14px var(--accent-glow);
    flex-shrink: 0;
}
.sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
.sb-sub {
    display: inline-flex; align-items: center;
    background: rgba(79,126,248,0.15);
    border: 1px solid rgba(79,126,248,0.25);
    color: var(--accent-2);
    font-size: 0.62rem; font-weight: 700;
    letter-spacing: 1px; text-transform: uppercase;
    padding: 2px 8px; border-radius: 20px; margin-top: 3px;
}
.sb-nav { flex: 1; padding: 12px 10px; overflow-y: auto; }
.sb-lbl {
    color: rgba(255,255,255,0.22);
    font-size: 0.62rem; font-weight: 700;
    text-transform: uppercase; letter-spacing: 1.4px;
    padding: 0 8px; margin: 16px 0 5px;
}
.sb-item {
    display: flex; align-items: center; gap: 9px;
    padding: 9px 10px; border-radius: 9px; margin-bottom: 1px;
    color: rgba(255,255,255,0.45); text-decoration: none;
    font-size: 0.83rem; font-weight: 500;
    transition: all 0.2s; border-left: 2px solid transparent;
}
.sb-item i {
    width: 28px; height: 28px;
    display: flex; align-items: center; justify-content: center;
    font-size: 0.8rem; border-radius: 8px;
    background: rgba(255,255,255,0.05);
    flex-shrink: 0; transition: all 0.2s;
}
.sb-item.on {
    color: #fff;
    background: linear-gradient(90deg, rgba(52,211,153,0.18), rgba(52,211,153,0.05));
    border-left: 2px solid var(--green);
}
.sb-item.on i { background: rgba(52,211,153,0.22); color: var(--green); }

/* Hover per-item */
.sb-item:hover { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
.sb-item:hover i { background: rgba(79,126,248,0.2); color: var(--accent-2); }
/* Dashboard - blue */
.sb-item:nth-of-type(1):hover { background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
.sb-item:nth-of-type(1):hover i { background: rgba(79,126,248,0.2); color: var(--accent-2); }
/* Customers - green */
.sb-item:nth-of-type(2):hover { background: rgba(52,211,153,0.07); border-left-color: var(--green); }
.sb-item:nth-of-type(2):hover i { background: rgba(52,211,153,0.18); color: var(--green); }
/* Contracts - purple */
.sb-item:nth-of-type(3):hover { background: rgba(167,139,250,0.08); border-left-color: var(--purple); }
.sb-item:nth-of-type(3):hover i { background: rgba(167,139,250,0.18); color: var(--purple); }
/* Service Requests - amber */
.sb-item:nth-of-type(4):hover { background: rgba(251,191,36,0.08); border-left-color: var(--amber); }
.sb-item:nth-of-type(4):hover i { background: rgba(251,191,36,0.18); color: var(--amber); }
/* Live Chat - pink */
.sb-item:nth-of-type(5):hover { background: rgba(251,113,133,0.08); border-left-color: #fb7185; }
.sb-item:nth-of-type(5):hover i { background: rgba(251,113,133,0.18); color: #fb7185; }

.sb-foot { padding: 12px 10px 16px; border-top: 1px solid var(--border); }
.sb-user {
    display: flex; align-items: center; gap: 9px;
    padding: 10px; border-radius: 10px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--border);
    margin-bottom: 6px; text-decoration: none; transition: all 0.2s;
}
.sb-user:hover { background: rgba(79,126,248,0.1); border-color: rgba(79,126,248,0.25); }
.sb-ava {
    width: 34px; height: 34px; border-radius: 50%;
    background: linear-gradient(135deg, var(--accent), var(--purple));
    display: flex; align-items: center; justify-content: center;
    color: #fff; font-size: 0.88rem; font-weight: 700;
    flex-shrink: 0; overflow: hidden;
}
.sb-ava img { width: 34px; height: 34px; object-fit: cover; border-radius: 50%; }
.sb-uname { color: #fff; font-size: 0.82rem; font-weight: 600; }
.sb-urole { color: var(--muted); font-size: 0.68rem; margin-top: 1px; }
.sb-logout {
    display: flex; align-items: center; gap: 8px;
    width: 100%; padding: 8px 10px; border-radius: 8px;
    color: rgba(255,255,255,0.35); text-decoration: none;
    font-size: 0.8rem; transition: all 0.2s;
}
.sb-logout:hover { color: var(--danger); background: rgba(248,113,113,0.08); }

/* ════════════════════ MAIN ════════════════════ */
.main { flex: 1; display: flex; flex-direction: column; min-width: 0; }

.topbar {
    background: rgba(11,20,55,0.7);
    backdrop-filter: blur(16px);
    border-bottom: 1px solid var(--border);
    padding: 0 28px; height: 64px;
    display: flex; align-items: center; justify-content: space-between;
    flex-shrink: 0; position: sticky; top: 0; z-index: 50;
}
.topbar h1 { font-size: 1.05rem; font-weight: 700; color: #fff; }

.content { padding: 28px 32px; flex: 1; }

/* ── TOOLBAR ── */
.toolbar {
    display: flex; gap: 12px;
    margin-bottom: 20px;
    align-items: center; flex-wrap: wrap;
}
.search-box { position: relative; flex: 1; min-width: 200px; max-width: 320px; }
.search-box input {
    width: 100%;
    padding: 8px 12px 8px 34px;
    background: rgba(255,255,255,0.05);
    border: 1.5px solid var(--border);
    border-radius: 9px;
    font-size: 0.82rem; font-family: inherit;
    color: var(--text); outline: none; transition: all 0.2s;
}
.search-box input::placeholder { color: var(--muted); }
.search-box input:focus { border-color: rgba(79,126,248,0.5); background: rgba(79,126,248,0.06); box-shadow: 0 0 0 3px rgba(79,126,248,0.1); }
.search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: 0.78rem; }

select {
    padding: 8px 12px;
    background: rgba(255,255,255,0.05);
    border: 1.5px solid var(--border);
    border-radius: 9px;
    font-size: 0.82rem; font-family: inherit;
    color: var(--text); outline: none; cursor: pointer; transition: all 0.2s;
}
select option { background: #111a42; color: var(--text); }
select:focus { border-color: rgba(79,126,248,0.5); }

/* ── BUTTONS ── */
.btn {
    padding: 8px 16px; border-radius: 9px; border: none;
    cursor: pointer; font-size: 0.82rem; font-weight: 600;
    font-family: inherit;
    display: inline-flex; align-items: center; gap: 6px;
    transition: all 0.2s; text-decoration: none;
}
.btn-primary {
    background: linear-gradient(135deg, var(--accent), #6366f1);
    color: #fff; box-shadow: 0 4px 14px var(--accent-glow);
}
.btn-primary:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(79,126,248,0.45); }
.btn-sm { padding: 5px 12px; font-size: 0.75rem; }
.btn-outline {
    background: rgba(255,255,255,0.05);
    color: var(--text-2);
    border: 1.5px solid var(--border);
}
.btn-outline:hover { border-color: rgba(79,126,248,0.4); color: var(--accent-2); background: rgba(79,126,248,0.08); }
.btn-danger {
    background: var(--danger-dim);
    color: var(--danger);
    border: 1px solid rgba(248,113,113,0.2);
}
.btn-danger:hover { background: rgba(248,113,113,0.2); }
.btn-success {
    background: var(--green-dim);
    color: var(--green);
    border: 1px solid rgba(52,211,153,0.2);
}
.btn-success:hover { background: rgba(52,211,153,0.2); }

/* ── CARD & TABLE ── */
.card {
    background: rgba(17,26,66,0.7);
    border: 1px solid var(--border);
    border-radius: 16px; overflow: hidden;
    backdrop-filter: blur(12px);
    animation: cardIn 0.5s ease both;
}
@keyframes cardIn {
    from { opacity: 0; transform: translateY(14px); }
    to   { opacity: 1; transform: translateY(0); }
}
table { width: 100%; border-collapse: collapse; }
thead tr { background: rgba(255,255,255,0.02); }
th {
    padding: 10px 16px; text-align: left;
    font-size: 0.68rem; font-weight: 700;
    color: var(--muted); text-transform: uppercase; letter-spacing: 0.8px;
    border-bottom: 1px solid var(--border); background: transparent;
}
td {
    padding: 12px 16px; font-size: 0.8rem;
    color: var(--text-2);
    border-bottom: 1px solid rgba(255,255,255,0.03);
    vertical-align: middle;
}
tr:last-child td { border-bottom: none; }
tr:hover td { background: rgba(79,126,248,0.05); }

/* ── BADGES ── */
.badge {
    display: inline-flex; align-items: center;
    padding: 3px 9px; border-radius: 20px;
    font-size: 0.7rem; font-weight: 700; white-space: nowrap;
}
.badge-active   { background: var(--green-dim);  color: var(--green);  border: 1px solid rgba(52,211,153,0.2); }
.badge-inactive { background: rgba(255,255,255,0.05); color: var(--muted); border: 1px solid var(--border); }

/* ── AVATAR CIRCLE ── */
.ava-circle {
    width: 34px; height: 34px; border-radius: 50%;
    background: linear-gradient(135deg, var(--accent), var(--purple));
    color: #fff; display: inline-flex;
    align-items: center; justify-content: center;
    font-size: 0.82rem; font-weight: 700; flex-shrink: 0;
}

/* ── PAGINATION ── */
.pagination {
    display: flex; gap: 6px;
    margin-top: 18px; justify-content: center; align-items: center;
}
.page-btn {
    width: 34px; height: 34px; border-radius: 9px;
    border: 1.5px solid var(--border);
    background: rgba(255,255,255,0.04);
    cursor: pointer; font-size: 0.8rem;
    display: flex; align-items: center; justify-content: center;
    font-family: inherit; transition: all 0.15s;
    text-decoration: none; color: var(--text-2);
}
.page-btn:hover { border-color: rgba(79,126,248,0.4); color: var(--accent-2); background: rgba(79,126,248,0.08); }
.page-btn.active { background: var(--accent); color: #fff; border-color: var(--accent); box-shadow: 0 4px 12px var(--accent-glow); }

/* ── FLASH ── */
.flash {
    padding: 12px 16px; border-radius: 10px;
    margin-bottom: 18px; font-size: 0.82rem; font-weight: 500;
    animation: cardIn 0.3s ease both;
}
.flash-ok  { background: var(--green-dim); color: var(--green);  border: 1px solid rgba(52,211,153,0.25); }
.flash-err { background: var(--danger-dim); color: var(--danger); border: 1px solid rgba(248,113,113,0.25); }

/* ── MODAL ── */
.modal-bg {
    display: none; position: fixed; inset: 0;
    background: rgba(0,0,0,0.65); backdrop-filter: blur(6px);
    z-index: 1000; align-items: center; justify-content: center;
}
.modal-bg.open { display: flex; }
.modal {
    background: rgba(15,28,77,0.98);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 18px;
    width: 100%; max-width: 480px; max-height: 90vh;
    overflow-y: auto; padding: 28px;
    position: relative;
    box-shadow: 0 24px 64px rgba(0,0,0,0.6);
    animation: modalIn 0.2s ease both;
}
@keyframes modalIn {
    from { opacity: 0; transform: scale(0.94) translateY(10px); }
    to   { opacity: 1; transform: scale(1) translateY(0); }
}
.modal h2 { font-size: 1rem; font-weight: 700; margin-bottom: 20px; color: #fff; }
.modal-close {
    position: absolute; top: 16px; right: 18px;
    background: rgba(255,255,255,0.06); border: 1px solid var(--border);
    border-radius: 8px; width: 28px; height: 28px;
    font-size: 0.85rem; cursor: pointer; color: var(--muted);
    display: flex; align-items: center; justify-content: center;
    transition: all 0.15s;
}
.modal-close:hover { background: var(--danger-dim); color: var(--danger); border-color: rgba(248,113,113,0.3); }

/* ── FORM ── */
.form-group { margin-bottom: 16px; }
.form-group label {
    display: block; font-size: 0.78rem; font-weight: 600;
    color: var(--text-2); margin-bottom: 5px;
}
.form-group input,
.form-group select,
.form-group textarea {
    width: 100%; padding: 9px 12px;
    background: rgba(255,255,255,0.05);
    border: 1.5px solid var(--border);
    border-radius: 9px;
    font-size: 0.82rem; font-family: inherit;
    color: var(--text); outline: none; transition: all 0.2s;
}
.form-group input::placeholder,
.form-group textarea::placeholder { color: var(--muted); }
.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
    border-color: rgba(79,126,248,0.5);
    background: rgba(79,126,248,0.06);
    box-shadow: 0 0 0 3px rgba(79,126,248,0.1);
}
.form-group select option { background: #111a42; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.modal-footer {
    display: flex; gap: 10px; justify-content: flex-end;
    margin-top: 20px; padding-top: 16px;
    border-top: 1px solid var(--border);
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