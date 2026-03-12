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
    --primary:     #4f7ef8;
    --success:     #34d399;
    --warning:     #fbbf24;
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
    width: var(--sb-w); height: 100vh;
    background: rgba(9,15,40,0.95);
    backdrop-filter: blur(20px);
    border-right: 1px solid var(--border);
    display: flex; flex-direction: column;
    flex-shrink: 0; position: sticky; top: 0;
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
    box-shadow: 0 4px 14px var(--accent-glow); flex-shrink: 0;
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
/* Active — Service Requests = amber */
.sb-item.on {
    color: #fff;
    background: linear-gradient(90deg, rgba(251,191,36,0.15), rgba(251,191,36,0.04));
    border-left: 2px solid var(--amber);
}
.sb-item.on i { background: rgba(251,191,36,0.2); color: var(--amber); }

.sb-item:hover { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
.sb-item:hover i { background: rgba(79,126,248,0.2); color: var(--accent-2); }
.sb-item:nth-of-type(1):hover { background: rgba(79,126,248,0.1);   border-left-color: var(--accent);  }
.sb-item:nth-of-type(1):hover i { background: rgba(79,126,248,0.2); color: var(--accent-2); }
.sb-item:nth-of-type(2):hover { background: rgba(52,211,153,0.07);  border-left-color: var(--green);   }
.sb-item:nth-of-type(2):hover i { background: rgba(52,211,153,0.18); color: var(--green); }
.sb-item:nth-of-type(3):hover { background: rgba(167,139,250,0.08); border-left-color: var(--purple);  }
.sb-item:nth-of-type(3):hover i { background: rgba(167,139,250,0.18); color: var(--purple); }
.sb-item:nth-of-type(4):hover { background: rgba(251,191,36,0.08);  border-left-color: var(--amber);   }
.sb-item:nth-of-type(4):hover i { background: rgba(251,191,36,0.18); color: var(--amber); }
.sb-item:nth-of-type(5):hover { background: rgba(251,113,133,0.08); border-left-color: #fb7185;        }
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
    background: rgba(11,20,55,0.7); backdrop-filter: blur(16px);
    border-bottom: 1px solid var(--border);
    padding: 0 28px; height: 64px;
    display: flex; align-items: center; justify-content: space-between;
    flex-shrink: 0; position: sticky; top: 0; z-index: 50;
}
.topbar h1 { font-size: 1.05rem; font-weight: 700; color: #fff; }
.content { padding: 28px 32px; flex: 1; }

/* ── TOOLBAR ── */
.toolbar { display: flex; gap: 10px; margin-bottom: 20px; align-items: center; flex-wrap: wrap; }
.search-box { position: relative; flex: 1; min-width: 180px; max-width: 280px; }
.search-box input {
    width: 100%; padding: 8px 12px 8px 34px;
    background: rgba(255,255,255,0.05);
    border: 1.5px solid var(--border); border-radius: 9px;
    font-size: 0.82rem; font-family: inherit;
    color: var(--text); outline: none; transition: all 0.2s;
}
.search-box input::placeholder { color: var(--muted); }
.search-box input:focus { border-color: rgba(79,126,248,0.5); background: rgba(79,126,248,0.06); box-shadow: 0 0 0 3px rgba(79,126,248,0.1); }
.search-box i { position: absolute; left: 11px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: 0.78rem; }

select {
    padding: 8px 12px;
    background: rgba(255,255,255,0.05);
    border: 1.5px solid var(--border); border-radius: 9px;
    font-size: 0.82rem; font-family: inherit;
    color: var(--text); outline: none; cursor: pointer; transition: all 0.2s;
}
select option { background: #111a42; color: var(--text); }
select:focus { border-color: rgba(79,126,248,0.5); }

/* ── BUTTONS ── */
.btn {
    padding: 8px 16px; border-radius: 9px; border: none;
    cursor: pointer; font-size: 0.82rem; font-weight: 600;
    font-family: inherit; display: inline-flex; align-items: center; gap: 6px;
    transition: all 0.2s; text-decoration: none;
}
.btn-primary {
    background: linear-gradient(135deg, var(--accent), #6366f1);
    color: #fff; box-shadow: 0 4px 14px var(--accent-glow);
}
.btn-primary:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(79,126,248,0.45); }
.btn-sm { padding: 5px 12px; font-size: 0.75rem; }
.btn-outline {
    background: rgba(255,255,255,0.05); color: var(--text-2);
    border: 1.5px solid var(--border);
}
.btn-outline:hover { border-color: rgba(79,126,248,0.4); color: var(--accent-2); background: rgba(79,126,248,0.08); }

/* ── CARD & TABLE ── */
.card {
    background: rgba(17,26,66,0.7); border: 1px solid var(--border);
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
    font-size: 0.68rem; font-weight: 700; color: var(--muted);
    text-transform: uppercase; letter-spacing: 0.8px;
    border-bottom: 1px solid var(--border); background: transparent;
}
td {
    padding: 12px 16px; font-size: 0.8rem; color: var(--text-2);
    border-bottom: 1px solid rgba(255,255,255,0.03); vertical-align: middle;
}
tr:last-child td { border-bottom: none; }
tr:hover td { background: rgba(79,126,248,0.05); }

/* ── BADGES ── */
.badge {
    display: inline-flex; align-items: center;
    padding: 2px 9px; border-radius: 20px;
    font-size: 0.7rem; font-weight: 700; white-space: nowrap;
}
/* SR status */
.badge-pending     { background: var(--amber-dim);   color: var(--amber);   border: 1px solid rgba(251,191,36,0.2); }
.badge-approved    { background: var(--green-dim);   color: var(--green);   border: 1px solid rgba(52,211,153,0.2); }
.badge-in-progress { background: rgba(79,126,248,0.12); color: var(--accent-2); border: 1px solid rgba(79,126,248,0.2); }
.badge-completed   { background: var(--purple-dim);  color: var(--purple);  border: 1px solid rgba(167,139,250,0.2); }
.badge-rejected    { background: var(--danger-dim);  color: var(--danger);  border: 1px solid rgba(248,113,113,0.2); }
.badge-cancelled   { background: rgba(255,255,255,0.05); color: var(--muted); border: 1px solid var(--border); }
/* Priority */
.badge-low    { background: rgba(52,211,153,0.08);  color: #6ee7b7; border: 1px solid rgba(52,211,153,0.15); }
.badge-medium { background: rgba(251,191,36,0.1);   color: #fcd34d; border: 1px solid rgba(251,191,36,0.2); }
.badge-high   { background: rgba(251,146,60,0.1);   color: #fb923c; border: 1px solid rgba(251,146,60,0.2); }
.badge-urgent { background: var(--danger-dim);      color: #fca5a5; border: 1px solid rgba(248,113,113,0.2); }
/* Contract type */
.badge-WARRANTY    { background: var(--info-dim);   color: var(--info);  border: 1px solid rgba(56,189,248,0.2); }
.badge-MAINTENANCE { background: var(--amber-dim);  color: var(--amber); border: 1px solid rgba(251,191,36,0.2); }

a.row-link { color: var(--accent-2); text-decoration: none; font-weight: 600; font-size: 0.77rem; }
a.row-link:hover { color: #fff; }

/* ── PAGINATION ── */
.pagination { display: flex; gap: 6px; margin-top: 18px; justify-content: center; }
.page-btn {
    width: 34px; height: 34px; border-radius: 9px;
    border: 1.5px solid var(--border);
    background: rgba(255,255,255,0.04);
    font-size: 0.8rem; display: flex; align-items: center; justify-content: center;
    text-decoration: none; color: var(--text-2); transition: all 0.15s;
}
.page-btn:hover { border-color: rgba(79,126,248,0.4); color: var(--accent-2); background: rgba(79,126,248,0.08); }
.page-btn.active { background: var(--accent); color: #fff; border-color: var(--accent); box-shadow: 0 4px 12px var(--accent-glow); }

/* ── FLASH ── */
.flash { padding: 12px 16px; border-radius: 10px; margin-bottom: 18px; font-size: 0.82rem; font-weight: 500; animation: cardIn 0.3s ease both; }
.flash-ok  { background: var(--green-dim);  color: var(--green);  border: 1px solid rgba(52,211,153,0.25); }
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
    border-radius: 18px; width: 100%; max-width: 620px;
    max-height: 92vh; overflow-y: auto; padding: 28px;
    position: relative;
    box-shadow: 0 24px 64px rgba(0,0,0,0.6);
    animation: modalIn 0.2s ease both;
}
.modal::-webkit-scrollbar { width: 3px; }
.modal::-webkit-scrollbar-thumb { background: rgba(79,126,248,0.3); border-radius: 4px; }
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
    display: flex; align-items: center; justify-content: center; transition: all 0.15s;
}
.modal-close:hover { background: var(--danger-dim); color: var(--danger); border-color: rgba(248,113,113,0.3); }

/* ── FORM ── */
.form-group { margin-bottom: 16px; }
.form-group label { display: block; font-size: 0.78rem; font-weight: 600; color: var(--text-2); margin-bottom: 5px; }
.form-group input,
.form-group select,
.form-group textarea {
    width: 100%; padding: 9px 12px;
    background: rgba(255,255,255,0.05);
    border: 1.5px solid var(--border); border-radius: 9px;
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
    margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--border);
}

/* ── EQUIPMENT IN MODAL ── */
.equip-section {
    border: 1.5px solid var(--border);
    border-radius: 10px; overflow: hidden;
}
.equip-section-hd {
    padding: 10px 14px;
    background: rgba(255,255,255,0.04);
    border-bottom: 1px solid var(--border);
    font-size: 0.78rem; font-weight: 600; color: var(--text-2);
}
.equip-row {
    display: flex; align-items: flex-start; gap: 10px;
    padding: 10px 14px;
    border-bottom: 1px solid rgba(255,255,255,0.04);
    transition: background 0.15s;
}
.equip-row:last-child { border-bottom: none; }
.equip-row:hover { background: rgba(79,126,248,0.05); }
.equip-row-info { flex: 1; }
.equip-row-name { font-size: 0.8rem; font-weight: 600; color: var(--text); }
.equip-row-serial { font-size: 0.72rem; color: var(--muted); }
.equip-row-issue { margin-top: 6px; }
.equip-row-issue input {
    padding: 6px 10px;
    background: rgba(255,255,255,0.05);
    border: 1.5px solid var(--border); border-radius: 7px;
    font-size: 0.78rem; width: 100%; font-family: inherit;
    color: var(--text); outline: none; transition: all 0.2s;
}
.equip-row-issue input::placeholder { color: var(--muted); }
.equip-row-issue input:focus { border-color: rgba(79,126,248,0.5); background: rgba(79,126,248,0.06); }
.equip-empty { padding: 20px; text-align: center; color: var(--muted); font-size: 0.82rem; }
.equip-loading { padding: 20px; text-align: center; color: var(--muted); font-size: 0.82rem; }
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
