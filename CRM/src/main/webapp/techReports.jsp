<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"TECHNICIAN".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();

    @SuppressWarnings("unchecked")
    List<RepairReport> reports = (List<RepairReport>) request.getAttribute("reports");
    if (reports == null) reports = new ArrayList<>();

    int total      = request.getAttribute("total")      != null ? (int)request.getAttribute("total")      : 0;
    int currentPage= request.getAttribute("page")       != null ? (int)request.getAttribute("page")       : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (int)request.getAttribute("totalPages") : 1;
    String fStatus = request.getAttribute("filterStatus") != null ? (String)request.getAttribute("filterStatus") : "";

    @SuppressWarnings("unchecked")
    Map<String,Integer> stats = (Map<String,Integer>) request.getAttribute("stats");
    if (stats == null) stats = new HashMap<>();

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");

    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "T";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>My Reports – Technician</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root{
                --sb-bg:#1e1b4b;
                --sb-border:rgba(255,255,255,0.08);
                --sb-text:rgba(255,255,255,0.45);
                --sb-accent:#818cf8;
                --sb-accent-2:#a5b4fc;
                --sb-item-on:rgba(129,140,248,0.2);
                --sb-width:252px;
                --bg:#f3f4f9;
                --bg-card:#fff;
                --bg-topbar:#fff;
                --border-light:#e8ecf5;
                --border-light2:#f0f2fb;
                --text-h:#1e1b4b;
                --text-b:#374151;
                --text-m:#6b7280;
                --text-s:#9ca3af;
                --primary:#4f46e5;
                --primary-2:#6366f1;
                --primary-light:#ede9fe;
                --green:#16a34a;
                --red:#dc2626;
                --amber:#d97706;
                --blue:#2563eb;
                --purple:#7c3aed
            }
            *,*::before,*::after{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            body{
                font-family:'Sora',sans-serif;
                background:var(--bg);
                color:var(--text-b);
                min-height:100vh;
                display:flex
            }
            ::-webkit-scrollbar{
                width:4px
            }
            ::-webkit-scrollbar-thumb{
                background:rgba(79,70,229,.3);
                border-radius:4px
            }
            .sb{
                width:var(--sb-width);
                min-height:100vh;
                background:var(--sb-bg);
                border-right:1px solid rgba(79,70,229,.2);
                display:flex;
                flex-direction:column;
                position:fixed;
                top:0;
                left:0;
                z-index:100;
                box-shadow:4px 0 24px rgba(0,0,0,.15)
            }
            .sb-brand{
                padding:20px 16px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid var(--sb-border)
            }
            .sb-logo{
                width:36px;
                height:36px;
                background:linear-gradient(135deg,#818cf8,#a78bfa);
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem;
                flex-shrink:0
            }
            .sb-name{
                color:#fff;
                font-size:1.05rem;
                font-weight:800
            }
            .sb-role{
                display:inline-flex;
                background:rgba(13,148,136,.2);
                border:1px solid rgba(13,148,136,.35);
                color:#5eead4;
                font-size:.6rem;
                font-weight:700;
                letter-spacing:1px;
                text-transform:uppercase;
                padding:2px 8px;
                border-radius:20px;
                margin-top:3px
            }
            .sb-nav{
                flex:1;
                padding:12px 10px;
                overflow-y:auto
            }
            .sb-lbl{
                color:rgba(255,255,255,.22);
                font-size:.6rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.6px;
                padding:0 8px;
                margin:14px 0 5px
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:9px;
                padding:8px 10px;
                border-radius:9px;
                margin-bottom:1px;
                color:var(--sb-text);
                text-decoration:none;
                font-size:.81rem;
                font-weight:500;
                transition:all .18s;
                border-left:2px solid transparent
            }
            .sb-item i{
                width:28px;
                height:28px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.78rem;
                border-radius:8px;
                background:rgba(255,255,255,.06);
                flex-shrink:0
            }
            .sb-item.on{
                color:#fff;
                background:var(--sb-item-on);
                border-left-color:var(--sb-accent)
            }
            .sb-item.on i{
                background:rgba(129,140,248,.3);
                color:var(--sb-accent-2)
            }
            .sb-item:hover:not(.on){
                color:rgba(255,255,255,.78);
                background:rgba(255,255,255,.06)
            }
            .sb-foot{
                padding:12px 10px 14px;
                border-top:1px solid var(--sb-border)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:10px;
                background:rgba(255,255,255,.07);
                border:1px solid rgba(255,255,255,.1);
                margin-bottom:5px;
                text-decoration:none;
                transition:all .18s
            }
            .sb-user:hover{
                background:rgba(129,140,248,.18);
                border-color:rgba(129,140,248,.3)
            }
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:linear-gradient(135deg,#818cf8,#a78bfa);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                font-weight:700;
                flex-shrink:0;
                overflow:hidden
            }
            .sb-ava img{
                width:34px;
                height:34px;
                object-fit:cover;
                border-radius:50%
            }
            .sb-uname{
                color:#fff;
                font-size:.8rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,.35);
                font-size:.66rem;
                margin-top:1px
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:8px 10px;
                border-radius:9px;
                color:rgba(255,255,255,.3);
                text-decoration:none;
                font-size:.78rem;
                transition:all .18s
            }
            .sb-logout:hover{
                color:#fca5a5;
                background:rgba(239,68,68,.1)
            }
            .main{
                margin-left:var(--sb-width);
                flex:1;
                display:flex;
                flex-direction:column;
                min-height:100vh
            }
            .topbar{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:18px 28px;
                background:var(--bg-topbar);
                border-bottom:1px solid var(--border-light);
                position:sticky;
                top:0;
                z-index:50;
                box-shadow:0 1px 6px rgba(0,0,0,.06)
            }
            .topbar-title{
                font-size:1.2rem;
                font-weight:800;
                color:var(--text-h);
                letter-spacing:-.3px
            }
            .topbar-sub{
                color:var(--text-s);
                font-size:.78rem;
                margin-top:2px
            }
            .content{
                padding:24px 28px;
                flex:1
            }
            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(16px)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }
            .alert{
                display:flex;
                align-items:center;
                gap:12px;
                padding:12px 18px;
                border-radius:12px;
                margin-bottom:20px;
                font-size:.82rem
            }
            .alert-success{
                background:#d1fae5;
                border:1px solid #a7f3d0;
                color:#065f46
            }
            .alert-error  {
                background:#fee2e2;
                border:1px solid #fca5a5;
                color:#991b1b
            }
            .stats-grid{
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:14px;
                margin-bottom:24px
            }
            .sc{
                border-radius:16px;
                padding:18px 16px;
                position:relative;
                overflow:hidden;
                color:#fff;
                transition:all .22s;
                animation:cardIn .45s ease both
            }
            .sc:hover{
                transform:translateY(-3px);
                box-shadow:0 12px 32px rgba(0,0,0,.18)
            }
            .sc-total{
                background:var(--blue);
                box-shadow:0 4px 20px rgba(37,99,235,.3)
            }
            .sc-draft{
                background:var(--amber);
                box-shadow:0 4px 20px rgba(217,119,6,.3)
            }
            .sc-done {
                background:var(--green);
                box-shadow:0 4px 20px rgba(22,163,74,.3)
            }
            .sc::after{
                content:'';
                position:absolute;
                width:80px;
                height:80px;
                border-radius:50%;
                background:rgba(255,255,255,.12);
                top:-20px;
                right:-20px
            }
            .sc-icon{
                width:34px;
                height:34px;
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.82rem;
                margin-bottom:10px;
                background:rgba(255,255,255,.2);
                position:relative;
                z-index:1
            }
            .sc-val{
                font-size:1.75rem;
                font-weight:800;
                line-height:1;
                letter-spacing:-1px;
                position:relative;
                z-index:1
            }
            .sc-lbl{
                font-size:.72rem;
                font-weight:600;
                opacity:.88;
                margin-top:4px;
                position:relative;
                z-index:1
            }
            .filter-bar{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:14px;
                padding:14px 16px;
                display:flex;
                flex-wrap:wrap;
                gap:10px;
                align-items:center;
                margin-bottom:18px
            }
            .filter-bar select{
                padding:9px 13px;
                border:1.5px solid var(--border-light);
                border-radius:9px;
                font-size:.81rem;
                font-family:'Sora',sans-serif;
                color:var(--text-b);
                background:#fff;
                outline:none
            }
            .btn{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:9px 18px;
                border-radius:10px;
                font-size:.81rem;
                font-weight:600;
                font-family:'Sora',sans-serif;
                cursor:pointer;
                border:none;
                text-decoration:none;
                transition:all .2s
            }
            .btn-primary{
                background:var(--primary);
                color:#fff;
                box-shadow:0 3px 10px rgba(79,70,229,.28)
            }
            .btn-primary:hover{
                background:#4338ca;
                transform:translateY(-1px)
            }
            .btn-secondary{
                background:#fff;
                color:var(--text-m);
                border:1.5px solid var(--border-light)
            }
            .btn-secondary:hover{
                background:#f3f4f6;
                color:var(--text-b)
            }
            .btn-sm{
                padding:6px 13px;
                font-size:.75rem
            }
            .table-wrap{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 1px 6px rgba(0,0,0,.05)
            }
            table{
                width:100%;
                border-collapse:collapse;
                font-size:.8rem
            }
            thead tr{
                background:#fafbff
            }
            th{
                padding:10px 16px;
                text-align:left;
                color:var(--text-s);
                font-weight:700;
                font-size:.67rem;
                text-transform:uppercase;
                letter-spacing:.8px;
                border-bottom:1px solid var(--border-light2)
            }
            td{
                padding:12px 16px;
                border-bottom:1px solid var(--border-light2);
                vertical-align:middle;
                color:var(--text-b)
            }
            tr:last-child td{
                border-bottom:none
            }
            tbody tr:hover td{
                background:#f7f8ff
            }
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700
            }
            .b-draft    {
                background:#fef3c7;
                color:#92400e
            }
            .b-submitted{
                background:#d1fae5;
                color:#065f46
            }
            .b-warranty {
                background:#d1fae5;
                color:#065f46
            }
            .b-maintenance{
                background:#dbeafe;
                color:#1e40af
            }
            .td-muted{
                color:var(--text-s);
                font-size:.75rem
            }
            .td-empty{
                text-align:center;
                padding:40px 16px;
                color:var(--text-s);
                font-size:.82rem
            }
            .td-empty i{
                font-size:2rem;
                display:block;
                margin-bottom:10px;
                opacity:.2
            }
            .pagination{
                display:flex;
                justify-content:flex-end;
                align-items:center;
                gap:5px;
                padding:13px 16px;
                border-top:1px solid var(--border-light2)
            }
            .pagination a,.pagination span{
                padding:6px 12px;
                border-radius:8px;
                font-size:.77rem;
                font-weight:500;
                text-decoration:none;
                color:var(--text-m);
                border:1.5px solid var(--border-light);
                background:#fff;
                transition:all .15s
            }
            .pagination a:hover{
                background:var(--primary-light);
                color:var(--primary-2)
            }
            .pagination .active{
                background:var(--primary);
                color:#fff;
                border-color:transparent
            }
            .pagination .dots{
                border:none;
                background:none;
                color:var(--text-s)
            }
            .section-lbl{
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:2px;
                color:var(--primary-2);
                margin-bottom:13px;
                display:flex;
                align-items:center;
                gap:10px
            }
            .section-lbl::after{
                content:'';
                flex:1;
                height:1px;
                background:linear-gradient(to right,rgba(99,102,241,.2),transparent)
            }
        </style>
    </head>
    <body>

        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-bolt"></i></div>
                <div><div class="sb-name">DRSMS</div><div class="sb-role">Technician</div></div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Workspace</div>
                <a href="<%=ctx%>/techTasks"   class="sb-item"><i class="fas fa-tasks"></i> My Tasks</a>
                <a href="<%=ctx%>/techReports" class="sb-item on"><i class="fas fa-file-medical-alt"></i> My Reports</a>
            </nav>
            <div class="sb-foot">
                <a href="<%=ctx%>/profile" class="sb-user">
                    <div class="sb-ava"><%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%>
                        <img src="<%=ctx%><%=me.getAvatarUrl()%>" alt=""><%}else{%><%=initials%><%}%></div>
                    <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Technician</div></div>
                </a>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
            </div>
        </aside>

        <main class="main">
            <div class="topbar">
                <div>
                    <div class="topbar-title"><i class="fas fa-file-medical-alt" style="color:var(--primary-2);margin-right:8px;font-size:1rem"></i>My Reports</div>
                    <div class="topbar-sub">History of all repair reports you have created</div>
                </div>
            </div>

            <div class="content">
                <%if(flashOk!=null){%><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=flashOk%></div><%}%>
                <%if(flashErr!=null){%><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div><%}%>

                <div class="section-lbl">Overview</div>
                <div class="stats-grid">
                    <div class="sc sc-total">
                        <div class="sc-icon"><i class="fas fa-file-alt"></i></div>
                        <div class="sc-val"><%=stats.getOrDefault("total",0)%></div>
                        <div class="sc-lbl">Total Reports</div>
                    </div>
                    <div class="sc sc-draft">
                        <div class="sc-icon"><i class="fas fa-pencil-alt"></i></div>
                        <div class="sc-val"><%=stats.getOrDefault("draft",0)%></div>
                        <div class="sc-lbl">Draft</div>
                    </div>
                    <div class="sc sc-done">
                        <div class="sc-icon"><i class="fas fa-check-circle"></i></div>
                        <div class="sc-val"><%=stats.getOrDefault("submitted",0)%></div>
                        <div class="sc-lbl">Submitted</div>
                    </div>
                </div>

                <div class="section-lbl">Filter</div>
                <form method="get" action="<%=ctx%>/techReports">
                    <div class="filter-bar">
                        <select name="status">
                            <option value="">All Status</option>
                            <option value="DRAFT"     <%="DRAFT".equals(fStatus)?"selected":""%>>Draft</option>
                            <option value="SUBMITTED" <%="SUBMITTED".equals(fStatus)?"selected":""%>>Submitted</option>
                        </select>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Filter</button>
                        <a href="<%=ctx%>/techReports" class="btn btn-secondary"><i class="fas fa-times"></i> Reset</a>
                    </div>
                </form>

                <div class="section-lbl">Reports</div>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Report Code</th>
                                <th>Request</th>
                                <th>Customer</th>
                                <th>Contract Type</th>
                                <th>Labor Cost</th>
                                <th>Status</th>
                                <th>Created At</th>
                                <th>Invoice</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%if(reports.isEmpty()){%>
                            <tr><td colspan="9" class="td-empty">
                                    <i class="fas fa-file-medical-alt"></i>No reports found.
                                </td></tr>
                                <%}else{ for(RepairReport rr : reports){%>
                            <tr>
                                <td style="font-family:'Courier New',monospace;font-size:.78rem;font-weight:700;color:var(--primary-2)">
                                    <%=rr.getReportCode()%>
                                </td>
                                <td style="font-family:'Courier New',monospace;font-size:.78rem;color:var(--text-m)">
                                    <%=rr.getRequestCode()!=null?rr.getRequestCode():"—"%>
                                </td>
                                <td style="font-weight:600;color:var(--text-h)"><%=rr.getCustomerName()!=null?rr.getCustomerName():"—"%></td>
                                <td>
                                    <%if(rr.getContractType()!=null){%>
                                    <span class="b <%="WARRANTY".equals(rr.getContractType())?"b-warranty":"b-maintenance"%>">
                                        <%=rr.getContractType()%>
                                    </span>
                                    <%}else{%>—<%}%>
                                </td>
                                <td style="font-weight:600;color:var(--primary-2)">
                                    <%=rr.getLaborCost()!=null?String.format("%,.0f",rr.getLaborCost().doubleValue())+" VND":"—"%>
                                </td>
                                <td><span class="b <%="SUBMITTED".equals(rr.getStatus())?"b-submitted":"b-draft"%>"><%=rr.getStatusLabel()%></span></td>
                                <td class="td-muted"><%=rr.getCreatedAt()!=null?rr.getCreatedAt().toString().replace("T"," ").substring(0,16):"—"%></td>
                                <td>
                                    <%if(rr.getInvoiceId()!=null){%>
                                    <%if("PAID".equals(rr.getInvoiceStatus())){%>
                                    <span style="color:#0d9488;font-size:.75rem;font-weight:700;background:#d1fae5;padding:3px 8px;border-radius:20px">
                                        <i class="fas fa-check-double"></i> Paid
                                    </span>
                                    <%}else{%>
                                    <span style="color:var(--green);font-size:.75rem;font-weight:600">
                                        <i class="fas fa-check-circle"></i> Sent
                                    </span>
                                    <%}%>
                                    <%}else{%>
                                    <span class="td-muted">Pending</span>
                                    <%}%>
                                </td>
                                <td>
                                    <a class="btn btn-primary btn-sm" href="<%=ctx%>/techReports?action=detail&id=<%=rr.getId()%>">
                                        <i class="fas fa-eye"></i> View
                                    </a>
                                </td>
                            </tr>
                            <%}}%>
                        </tbody>
                    </table>
                    <%if(totalPages>1){String q="&status="+(fStatus!=null?fStatus:"");%>
                    <div class="pagination">
                        <%if(currentPage>1){%><a href="<%=ctx%>/techReports?page=<%=currentPage-1%><%=q%>"><i class="fas fa-chevron-left"></i></a><%}%>
                            <%for(int i=1;i<=totalPages;i++){
                    if(i==currentPage){%><span class="active"><%=i%></span>
                        <%}else if(i==1||i==totalPages||Math.abs(i-currentPage)<=2){%>
                        <a href="<%=ctx%>/techReports?page=<%=i%><%=q%>"><%=i%></a>
                        <%}else if(Math.abs(i-currentPage)==3){%><span class="dots">…</span><%}%>
                        <%}%>
                        <%if(currentPage<totalPages){%><a href="<%=ctx%>/techReports?page=<%=currentPage+1%><%=q%>"><i class="fas fa-chevron-right"></i></a><%}%>
                    </div>
                    <%}%>
                </div>
            </div>
        </main>
    </body>
</html>
