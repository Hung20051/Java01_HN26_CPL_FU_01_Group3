<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    Contract c = (Contract) request.getAttribute("contract");
    if (c == null) { response.sendRedirect(ctx + "/supportContracts"); return; }
    List<CustomerEquipment> equips = c.getEquipmentList();
    if (equips == null) equips = new ArrayList<>();

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title><%=c.getContractCode()%> - Contract Detail</title>
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
.sb-item.on {
    color: #fff;
    background: linear-gradient(90deg, rgba(167,139,250,0.18), rgba(167,139,250,0.05));
    border-left: 2px solid var(--purple);
}
.sb-item.on i { background: rgba(167,139,250,0.22); color: var(--purple); }

.sb-item:hover { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
.sb-item:hover i { background: rgba(79,126,248,0.2); color: var(--accent-2); }
.sb-item:nth-of-type(1):hover { background: rgba(79,126,248,0.1);   border-left-color: var(--accent); }
.sb-item:nth-of-type(1):hover i { background: rgba(79,126,248,0.2); color: var(--accent-2); }
.sb-item:nth-of-type(2):hover { background: rgba(52,211,153,0.07);  border-left-color: var(--green); }
.sb-item:nth-of-type(2):hover i { background: rgba(52,211,153,0.18); color: var(--green); }
.sb-item:nth-of-type(3):hover { background: rgba(167,139,250,0.08); border-left-color: var(--purple); }
.sb-item:nth-of-type(3):hover i { background: rgba(167,139,250,0.18); color: var(--purple); }
.sb-item:nth-of-type(4):hover { background: rgba(251,191,36,0.08);  border-left-color: var(--amber); }
.sb-item:nth-of-type(4):hover i { background: rgba(251,191,36,0.18); color: var(--amber); }
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
    background: rgba(11,20,55,0.7); backdrop-filter: blur(16px);
    border-bottom: 1px solid var(--border);
    padding: 0 28px; height: 64px;
    display: flex; align-items: center; justify-content: space-between;
    flex-shrink: 0; position: sticky; top: 0; z-index: 50;
}
.topbar h1 { font-size: 1.05rem; font-weight: 700; color: #fff; }
.content { padding: 28px 32px; flex: 1; }

/* ── BREADCRUMB ── */
.breadcrumb { font-size: 0.78rem; color: var(--muted); margin-bottom: 20px; }
.breadcrumb a { color: var(--accent-2); text-decoration: none; }
.breadcrumb a:hover { color: #fff; }

/* ── STATUS BANNER ── */
.status-banner {
    padding: 14px 20px; border-radius: 12px;
    margin-bottom: 20px;
    display: flex; align-items: center; gap: 12px;
    font-size: 0.85rem; font-weight: 500;
    animation: cardIn 0.4s ease both;
}
.status-banner.active   { background: var(--green-dim); color: var(--green); border: 1px solid rgba(52,211,153,0.25); }
.status-banner.expired  { background: var(--amber-dim); color: var(--amber); border: 1px solid rgba(251,191,36,0.25); }
.status-banner.cancelled{ background: var(--danger-dim); color: var(--danger); border: 1px solid rgba(248,113,113,0.25); }

/* ── DETAIL GRID ── */
.detail-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; }

/* ── CARDS ── */
.card {
    background: rgba(17,26,66,0.7);
    border: 1px solid var(--border);
    border-radius: 16px; overflow: hidden;
    backdrop-filter: blur(12px);
    margin-bottom: 20px;
    animation: cardIn 0.5s ease both;
}
@keyframes cardIn {
    from { opacity: 0; transform: translateY(14px); }
    to   { opacity: 1; transform: translateY(0); }
}
.card-hd {
    padding: 16px 20px; border-bottom: 1px solid var(--border);
    display: flex; align-items: center; justify-content: space-between;
}
.card-hd h3 { font-size: 0.88rem; font-weight: 700; color: #fff; }
.card-body { padding: 20px; }

/* ── INFO ROWS ── */
.info-row {
    display: flex; justify-content: space-between;
    padding: 9px 0;
    border-bottom: 1px solid rgba(255,255,255,0.04);
    font-size: 0.82rem;
}
.info-row:last-child { border-bottom: none; }
.info-label { color: var(--muted); font-weight: 500; }
.info-value { color: var(--text-2); font-weight: 600; text-align: right; }

/* Notes box */
.card-body div[style*="background:#f8fafc"] {
    background: rgba(255,255,255,0.04) !important;
    border: 1px solid var(--border);
    border-radius: 10px !important;
    color: var(--muted) !important;
    padding: 12px !important;
    font-size: 0.8rem;
    margin-top: 12px;
}

/* ── TABLE ── */
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
    padding: 3px 10px; border-radius: 20px;
    font-size: 0.72rem; font-weight: 700; white-space: nowrap;
}
.badge-active       { background: var(--green-dim);   color: var(--green);   border: 1px solid rgba(52,211,153,0.2); }
.badge-expired      { background: var(--amber-dim);   color: var(--amber);   border: 1px solid rgba(251,191,36,0.2); }
.badge-cancelled    { background: rgba(255,255,255,0.05); color: var(--muted); border: 1px solid var(--border); }
.badge-WARRANTY     { background: var(--info-dim);    color: var(--info);    border: 1px solid rgba(56,189,248,0.2); }
.badge-MAINTENANCE  { background: var(--amber-dim);   color: var(--amber);   border: 1px solid rgba(251,191,36,0.2); }
.badge-warranty-ok  { background: var(--green-dim);   color: var(--green);   border: 1px solid rgba(52,211,153,0.2); }
.badge-warranty-exp { background: var(--danger-dim);  color: var(--danger);  border: 1px solid rgba(248,113,113,0.2); }
.badge-external     { background: var(--info-dim);    color: var(--info);    border: 1px solid rgba(56,189,248,0.2); }

/* Source badge — override inline style */
td .badge[style*="background:#f1f5f9"] {
    background: rgba(255,255,255,0.07) !important;
    color: var(--text-2) !important;
    border: 1px solid var(--border) !important;
}

/* ── BUTTONS ── */
.btn {
    padding: 8px 16px; border-radius: 9px; border: none;
    cursor: pointer; font-size: 0.82rem; font-weight: 600;
    font-family: inherit; display: inline-flex; align-items: center; gap: 6px;
    transition: all 0.2s; text-decoration: none;
}
.btn-outline {
    background: rgba(255,255,255,0.05); color: var(--text-2);
    border: 1.5px solid var(--border);
}
.btn-outline:hover { border-color: rgba(79,126,248,0.4); color: var(--accent-2); background: rgba(79,126,248,0.08); }
.btn-danger-soft {
    background: var(--danger-dim); color: var(--danger);
    border: 1px solid rgba(248,113,113,0.2);
}
.btn-danger-soft:hover { background: rgba(248,113,113,0.22); }

/* ── FLASH ── */
.flash { padding: 12px 16px; border-radius: 10px; margin-bottom: 18px; font-size: 0.82rem; font-weight: 500; animation: cardIn 0.3s ease both; }
.flash-ok  { background: var(--green-dim);  color: var(--green);  border: 1px solid rgba(52,211,153,0.25); }
.flash-err { background: var(--danger-dim); color: var(--danger); border: 1px solid rgba(248,113,113,0.25); }
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
                <h1><i class="fas fa-file-contract" style="color:var(--primary);margin-right:8px"></i>Contract Detail</h1>
                <a href="<%=ctx%>/supportContracts" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Back to Contracts</a>
            </div>
            <div class="content">
                <%if(flashOk!=null){%><div class="flash flash-ok"><i class="fas fa-check-circle"></i> <%=flashOk%></div><%}%>
                <%if(flashErr!=null){%><div class="flash flash-err"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div><%}%>

                <div class="breadcrumb">
                    <a href="<%=ctx%>/supportContracts">Contracts</a> › <%=c.getContractCode()%>
                </div>

                <%-- Status banner --%>
                <div class="status-banner <%=c.getStatus().toLowerCase()%>">
                    <i class="fas fa-<%="ACTIVE".equals(c.getStatus())?"check-circle":"EXPIRED".equals(c.getStatus())?"clock":"ban"%>"></i>
                    <span>
                        Contract is <strong><%=c.getStatus()%></strong>
                        <%if("ACTIVE".equals(c.getStatus())){%>· Valid until <strong><%=c.getEndDate()%></strong><%}%>
                    </span>
                    <%if("ACTIVE".equals(c.getStatus())){%>
                    <form method="post" action="<%=ctx%>/supportContracts" style="margin-left:auto"
                          onsubmit="return confirm('Cancel this contract? This cannot be undone.')">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="id" value="<%=c.getId()%>">
                        <button type="submit" class="btn btn-danger-soft"><i class="fas fa-ban"></i> Cancel Contract</button>
                    </form>
                    <%}%>
                </div>

                <div class="detail-grid">
                    <div>
                        <%-- Contract Info --%>
                        <div class="card">
                            <div class="card-hd">
                                <h3><i class="fas fa-info-circle" style="color:var(--primary);margin-right:6px"></i>Contract Information</h3>
                                <span class="badge badge-<%=c.getContractType()%>"><%=c.getContractType()%></span>
                            </div>
                            <div class="card-body">
                                <div class="info-row"><span class="info-label">Contract Code</span><span class="info-value"><%=c.getContractCode()%></span></div>
                                <div class="info-row"><span class="info-label">Customer</span><span class="info-value"><%=c.getCustomerName()%></span></div>
                                <div class="info-row"><span class="info-label">Type</span><span class="info-value"><%=c.getContractType()%></span></div>
                                <div class="info-row"><span class="info-label">Start Date</span><span class="info-value"><%=c.getStartDate()%></span></div>
                                <div class="info-row"><span class="info-label">End Date</span><span class="info-value"><%=c.getEndDate()%></span></div>
                                <div class="info-row"><span class="info-label">Created By</span><span class="info-value"><%=c.getCreatedByName()%></span></div>
                                <div class="info-row"><span class="info-label">Created At</span><span class="info-value" style="color:var(--muted)"><%=c.getCreatedAt()!=null?c.getCreatedAt().toString().substring(0,16):""%></span></div>
                                    <%if(c.getNotes()!=null&&!c.getNotes().isEmpty()){%>
                                <div style="margin-top:12px;padding:12px;background:#f8fafc;border-radius:8px;font-size:.8rem;color:var(--muted)">
                                    <i class="fas fa-sticky-note" style="margin-right:6px"></i><%=c.getNotes()%>
                                </div>
                                <%}%>
                            </div>
                        </div>

                        <%-- Equipment List --%>
                        <div class="card">
                            <div class="card-hd">
                                <h3><i class="fas fa-cogs" style="color:var(--primary);margin-right:6px"></i>Equipment (<%=equips.size()%>)</h3>
                            </div>
                            <table>
                                <thead><tr><th>#</th><th>Equipment</th><th>Serial</th><th>Category</th><th>Source</th><th>Warranty</th></tr></thead>
                                <tbody>
                                    <%if(equips.isEmpty()){%>
                                    <tr><td colspan="6" style="text-align:center;padding:20px;color:var(--muted)">No equipment</td></tr>
                                    <%}else{int idx=1;for(CustomerEquipment e:equips){%>
                                    <tr>
                                        <td style="color:var(--muted)"><%=idx++%></td>
                                        <td style="font-weight:600"><%=e.getDisplayName()%></td>
                                        <td style="color:var(--muted);font-size:.75rem"><%=e.getDisplaySerial()%></td>
                                        <td><%=e.getCategoryName()!=null?e.getCategoryName():"-"%></td>
                                        <td><span class="badge <%="EXTERNAL".equals(e.getSource())?"badge-external":""%>" style="background:#f1f5f9;color:#475569"><%=e.getSource()%></span></td>
                                        <td>
                                            <%if(e.getWarrantyExpires()!=null){%>
                                            <span class="badge <%=e.isUnderWarranty()?"badge-warranty-ok":"badge-warranty-exp"%>">
                                                <%=e.isUnderWarranty()?"Valid":"Expired"%> (<%=e.getWarrantyExpires()%>)
                                            </span>
                                            <%}else{%><span style="color:var(--muted)">N/A</span><%}%>
                                        </td>
                                    </tr>
                                    <%}}%>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <%-- Right column: quick stats --%>
                    <div>
                        <div class="card">
                            <div class="card-hd"><h3><i class="fas fa-chart-bar" style="color:var(--primary);margin-right:6px"></i>Summary</h3></div>
                            <div class="card-body">
                                <div class="info-row"><span class="info-label">Equipment</span><span class="info-value"><%=equips.size()%></span></div>
                                <div class="info-row"><span class="info-label">Service Requests</span><span class="info-value"><%=c.getServiceRequestCount()%></span></div>
                                <div class="info-row"><span class="info-label">Status</span>
                                    <span class="info-value"><span class="badge badge-<%=c.getStatus().toLowerCase()%>"><%=c.getStatus()%></span></span>
                                </div>
                            </div>
                        </div>
                        <div style="margin-top:12px">
                            <a href="<%=ctx%>/supportServiceRequests?status=PENDING&contractType=<%="WARRANTY".equals(c.getContractType())?"WARRANTY":"MAINTENANCE"%>"
                               class="btn btn-outline" style="width:100%;justify-content:center">
                                <i class="fas fa-clipboard-list"></i> View Service Requests
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body></html>
