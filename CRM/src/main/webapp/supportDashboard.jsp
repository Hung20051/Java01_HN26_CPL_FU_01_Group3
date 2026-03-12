<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();

    Map<String,Integer> cs  = (Map<String,Integer>) request.getAttribute("contractStats");
    Map<String,Integer> ss  = (Map<String,Integer>) request.getAttribute("srStats");
    int totalCustomers      = request.getAttribute("totalCustomers") != null ? (int)request.getAttribute("totalCustomers") : 0;
    List<?> recentContracts = (List<?>) request.getAttribute("recentContracts");
    List<?> pendingSRs      = (List<?>) request.getAttribute("pendingSRs");
    if (cs == null) cs = new HashMap<>();
    if (ss == null) ss = new HashMap<>();
    if (recentContracts == null) recentContracts = new ArrayList<>();
    if (pendingSRs == null) pendingSRs = new ArrayList<>();

    int cTotal  = cs.getOrDefault("total", 0);
    int cActive = cs.getOrDefault("active", 0);
    int srTotal = ss.getOrDefault("total", 0);
    int srPend  = ss.getOrDefault("pending", 0);
    int srDone  = ss.getOrDefault("completed", 0);
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Dashboard - Customer Support</title>
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
    /* legacy aliases for supportDashboard HTML */
    --primary:     #4f7ef8;
    --sidebar:     rgba(9,15,40,0.95);
    --bg:          var(--navy);
    --surface:     rgba(17,26,66,0.7);
    --border-l:    rgba(255,255,255,0.07);
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
    width: var(--sb-w);
    height: 100vh;
    background: rgba(9,15,40,0.95);
    backdrop-filter: blur(20px);
    border-right: 1px solid var(--border);
    display: flex;
    flex-direction: column;
    flex-shrink: 0;
    position: sticky;
    top: 0;
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
    padding: 2px 8px; border-radius: 20px;
    margin-top: 3px;
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
    padding: 9px 10px; border-radius: 9px;
    margin-bottom: 1px;
    color: rgba(255,255,255,0.45);
    text-decoration: none;
    font-size: 0.83rem; font-weight: 500;
    transition: all 0.2s;
    border-left: 2px solid transparent;
}
.sb-item i {
    width: 28px; height: 28px;
    display: flex; align-items: center; justify-content: center;
    font-size: 0.8rem; border-radius: 8px;
    background: rgba(255,255,255,0.05);
    flex-shrink: 0;
    transition: all 0.2s;
}
/* Active state */
.sb-item.on {
    color: #fff;
    background: linear-gradient(90deg, rgba(79,126,248,0.2), rgba(79,126,248,0.05));
    border-left: 2px solid var(--accent);
}
.sb-item.on i { background: rgba(79,126,248,0.25); color: var(--accent-2); }

/* Hover per-item color (đồng bộ với customerDashboard) */
/* Dashboard - blue */
.sb-item:first-of-type:hover,
.sb-item:hover {
    color: #fff;
    background: rgba(79,126,248,0.1);
    border-left-color: var(--accent);
}
.sb-item:hover i { background: rgba(79,126,248,0.2); color: var(--accent-2); }

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

/* Sidebar footer */
.sb-foot {
    padding: 12px 10px 16px;
    border-top: 1px solid var(--border);
}
.sb-user {
    display: flex; align-items: center; gap: 9px;
    padding: 10px;
    border-radius: 10px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--border);
    margin-bottom: 6px;
    text-decoration: none;
    transition: all 0.2s;
    cursor: pointer;
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
    padding: 0 28px;
    height: 64px;
    display: flex; align-items: center; justify-content: space-between;
    flex-shrink: 0;
    position: sticky; top: 0; z-index: 50;
}
.topbar h1 { font-size: 1.05rem; font-weight: 700; color: #fff; }

.content { padding: 28px 32px; flex: 1; overflow-y: auto; }

/* ── STAT CARDS ── */
.stat-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    margin-bottom: 26px;
}
.stat-card {
    background: rgba(17,26,66,0.7);
    border: 1px solid var(--border);
    border-radius: 16px;
    padding: 20px;
    display: flex; align-items: center; gap: 16px;
    backdrop-filter: blur(12px);
    transition: all 0.25s;
    animation: cardIn 0.5s ease both;
    position: relative; overflow: hidden;
}
.stat-card:nth-child(1){ animation-delay: 0.05s; }
.stat-card:nth-child(2){ animation-delay: 0.10s; }
.stat-card:nth-child(3){ animation-delay: 0.15s; }
.stat-card:nth-child(4){ animation-delay: 0.20s; }
.stat-card:hover { transform: translateY(-3px); box-shadow: 0 12px 32px rgba(0,0,0,0.25); }

/* Top shimmer line per card color */
.stat-card:nth-child(1)::before { content:''; position:absolute; top:0; left:16px; right:16px; height:1px; background: linear-gradient(90deg, transparent, var(--info), transparent); }
.stat-card:nth-child(2)::before { content:''; position:absolute; top:0; left:16px; right:16px; height:1px; background: linear-gradient(90deg, transparent, var(--green), transparent); }
.stat-card:nth-child(3)::before { content:''; position:absolute; top:0; left:16px; right:16px; height:1px; background: linear-gradient(90deg, transparent, var(--amber), transparent); }
.stat-card:nth-child(4)::before { content:''; position:absolute; top:0; left:16px; right:16px; height:1px; background: linear-gradient(90deg, transparent, var(--purple), transparent); }
/* Right accent bar */
.stat-card:nth-child(1)::after  { content:''; position:absolute; top:0; right:0; bottom:0; width:3px; border-radius:0 16px 16px 0; background: linear-gradient(180deg, var(--info), transparent); }
.stat-card:nth-child(2)::after  { content:''; position:absolute; top:0; right:0; bottom:0; width:3px; border-radius:0 16px 16px 0; background: linear-gradient(180deg, var(--green), transparent); }
.stat-card:nth-child(3)::after  { content:''; position:absolute; top:0; right:0; bottom:0; width:3px; border-radius:0 16px 16px 0; background: linear-gradient(180deg, var(--amber), transparent); }
.stat-card:nth-child(4)::after  { content:''; position:absolute; top:0; right:0; bottom:0; width:3px; border-radius:0 16px 16px 0; background: linear-gradient(180deg, var(--purple), transparent); }

@keyframes cardIn {
    from { opacity: 0; transform: translateY(16px); }
    to   { opacity: 1; transform: translateY(0); }
}

.stat-icon {
    width: 44px; height: 44px; border-radius: 11px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.05rem; flex-shrink: 0;
    position: relative; z-index: 1;
}
.stat-icon.blue   { background: var(--info-dim);   color: var(--info); }
.stat-icon.green  { background: var(--green-dim);  color: var(--green); }
.stat-icon.orange { background: var(--amber-dim);  color: var(--amber); }
.stat-icon.purple { background: var(--purple-dim); color: var(--purple); }

.stat-val {
    font-size: 1.85rem; font-weight: 800;
    color: #fff; line-height: 1;
    letter-spacing: -1px;
    position: relative; z-index: 1;
}
.stat-lbl {
    font-size: 0.75rem; color: var(--text-2);
    margin-top: 4px; font-weight: 500;
    position: relative; z-index: 1;
}

/* ── GRID 2 ── */
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }

/* ── CARDS ── */
.card {
    background: rgba(17,26,66,0.7);
    border: 1px solid var(--border);
    border-radius: 16px;
    overflow: hidden;
    backdrop-filter: blur(12px);
    animation: cardIn 0.5s 0.25s ease both;
}
.card-hd {
    padding: 16px 20px;
    border-bottom: 1px solid var(--border);
    display: flex; align-items: center; justify-content: space-between;
}
.card-hd h3 { font-size: 0.88rem; font-weight: 700; color: #fff; }

.view-all {
    font-size: 0.75rem; font-weight: 600;
    color: var(--accent-2); text-decoration: none;
    transition: color 0.2s;
}
.view-all:hover { color: #fff; }

/* ── TABLE ── */
table { width: 100%; border-collapse: collapse; }
thead tr { background: rgba(255,255,255,0.02); }
th {
    padding: 10px 16px;
    text-align: left;
    font-size: 0.68rem; font-weight: 700;
    color: var(--muted);
    text-transform: uppercase; letter-spacing: 0.8px;
    border-bottom: 1px solid var(--border);
    background: transparent;
}
td {
    padding: 12px 16px;
    font-size: 0.8rem;
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
    font-size: 0.7rem; font-weight: 700;
    white-space: nowrap;
}
/* contract status */
.badge-active      { background: var(--green-dim);   color: var(--green);   border: 1px solid rgba(52,211,153,0.2); }
.badge-expired     { background: var(--amber-dim);   color: var(--amber);   border: 1px solid rgba(251,191,36,0.2); }
.badge-cancelled   { background: rgba(255,255,255,0.05); color: var(--muted); border: 1px solid var(--border); }
/* contract type */
.badge-warranty    { background: var(--info-dim);    color: var(--info);    border: 1px solid rgba(56,189,248,0.2); }
.badge-maintenance { background: var(--amber-dim);   color: var(--amber);   border: 1px solid rgba(251,191,36,0.2); }
/* SR status */
.badge-pending     { background: var(--amber-dim);   color: var(--amber);   border: 1px solid rgba(251,191,36,0.2); }
.badge-approved    { background: var(--green-dim);   color: var(--green);   border: 1px solid rgba(52,211,153,0.2); }
.badge-in_progress { background: rgba(79,126,248,0.12); color: var(--accent-2); border: 1px solid rgba(79,126,248,0.2); }
.badge-completed   { background: var(--purple-dim);  color: var(--purple);  border: 1px solid rgba(167,139,250,0.2); }
.badge-rejected    { background: var(--danger-dim);  color: var(--danger);  border: 1px solid rgba(248,113,113,0.2); }
/* SR priority */
.badge-low         { background: rgba(52,211,153,0.08);  color: #6ee7b7; border: 1px solid rgba(52,211,153,0.15); }
.badge-medium      { background: rgba(251,191,36,0.1);   color: #fcd34d; border: 1px solid rgba(251,191,36,0.2); }
.badge-high        { background: rgba(251,146,60,0.1);   color: #fb923c; border: 1px solid rgba(251,146,60,0.2); }
.badge-urgent      { background: var(--danger-dim);      color: #fca5a5; border: 1px solid rgba(248,113,113,0.2); }

/* Row link */
a.row-link {
    color: var(--accent-2); text-decoration: none; font-weight: 600;
    font-size: 0.77rem; letter-spacing: -0.3px;
}
a.row-link:hover { color: #fff; }
</style>
    </head><body>

        <%-- SIDEBAR --%>
        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-bolt"></i></div>
                <div><div class="sb-name">DRSMS System</div><div class="sb-sub">Customer Support</div></div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/supportDashboard"      class="sb-item on"><i class="fas fa-home"></i> Dashboard</a>
                <div class="sb-lbl">Management</div>
                <a href="<%=ctx%>/supportCustomers"       class="sb-item"><i class="fas fa-users"></i> Customers</a>
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
                <h1><i class="fas fa-home" style="color:var(--primary);margin-right:8px"></i>Dashboard</h1>
                <span style="font-size:.8rem;color:var(--muted)">Welcome back, <%=me.getFullName()%></span>
            </div>
            <div class="content">

                <%-- STAT CARDS --%>
                <div class="stat-grid">
                    <div class="stat-card">
                        <div class="stat-icon blue"><i class="fas fa-users"></i></div>
                        <div><div class="stat-val"><%=totalCustomers%></div><div class="stat-lbl">Total Customers</div></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon green"><i class="fas fa-file-contract"></i></div>
                        <div><div class="stat-val"><%=cActive%></div><div class="stat-lbl">Active Contracts (<%=cTotal%> total)</div></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon orange"><i class="fas fa-clock"></i></div>
                        <div><div class="stat-val"><%=srPend%></div><div class="stat-lbl">Pending Requests</div></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon purple"><i class="fas fa-check-circle"></i></div>
                        <div><div class="stat-val"><%=srDone%></div><div class="stat-lbl">Completed Requests (<%=srTotal%> total)</div></div>
                    </div>
                </div>

                <div class="grid-2">
                    <%-- Recent Active Contracts --%>
                    <div class="card">
                        <div class="card-hd">
                            <h3><i class="fas fa-file-contract" style="color:var(--primary);margin-right:6px"></i>Active Contracts</h3>
                            <a href="<%=ctx%>/supportContracts" class="view-all">View all →</a>
                        </div>
                        <table>
                            <thead><tr><th>Code</th><th>Customer</th><th>Type</th><th>Expires</th></tr></thead>
                            <tbody>
                                <%  if (recentContracts.isEmpty()) { %>
                                <tr><td colspan="4" style="text-align:center;color:var(--muted);padding:20px">No active contracts</td></tr>
                                <% } else {
                                    for (Object obj : recentContracts) {
                                        model.Contract c = (model.Contract) obj;
                                %>
                                <tr>
                                    <td><a class="row-link" href="<%=ctx%>/supportContracts?action=detail&id=<%=c.getId()%>"><%=c.getContractCode()%></a></td>
                                    <td><%=c.getCustomerName()%></td>
                                    <td><span class="badge <%="WARRANTY".equals(c.getContractType())?"badge-warranty":"badge-maintenance"%>"><%=c.getContractType()%></span></td>
                                    <td style="color:var(--muted)"><%=c.getEndDate()%></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>

                    <%-- Pending Service Requests --%>
                    <div class="card">
                        <div class="card-hd">
                            <h3><i class="fas fa-clock" style="color:var(--warning);margin-right:6px"></i>Pending Requests</h3>
                            <a href="<%=ctx%>/supportServiceRequests?status=PENDING" class="view-all">View all →</a>
                        </div>
                        <table>
                            <thead><tr><th>Code</th><th>Customer</th><th>Title</th><th>Priority</th></tr></thead>
                            <tbody>
                                <% if (pendingSRs.isEmpty()) { %>
                                <tr><td colspan="4" style="text-align:center;color:var(--muted);padding:20px">No pending requests</td></tr>
                                <% } else {
                                    for (Object obj : pendingSRs) {
                                        model.ServiceRequest sr = (model.ServiceRequest) obj;
                                        String pri = sr.getPriority() != null ? sr.getPriority().toLowerCase() : "medium";
                                %>
                                <tr>
                                    <td><a class="row-link" href="<%=ctx%>/supportServiceRequests?action=detail&id=<%=sr.getId()%>"><%=sr.getRequestCode()%></a></td>
                                    <td><%=sr.getCustomerName()%></td>
                                    <td style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><%=sr.getTitle()%></td>
                                    <td><span class="badge badge-<%=pri%>"><%=sr.getPriority()%></span></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
    </body></html>
