<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"TECHNICIAN".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    RepairReport report = (RepairReport) request.getAttribute("report");
    if (report == null) { response.sendRedirect(ctx + "/techReports"); return; }

    boolean isWarranty = "WARRANTY".equals(report.getContractType());
    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "T";

    // Calculate totals
    double partsTotal = 0;
    if (report.getParts() != null) {
        for (RepairReportPart p : report.getParts()) {
            if (p.getTotalPrice() != null) partsTotal += p.getTotalPrice().doubleValue();
        }
    }
    double laborCost = report.getLaborCost() != null ? report.getLaborCost().doubleValue() : 0;
    double billableParts = isWarranty ? 0 : partsTotal;
    double subtotal = billableParts + laborCost;
    double vat      = subtotal * 0.10;
    double grandTotal = subtotal + vat;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%=report.getReportCode()%> – Report Detail</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root{--sb-bg:#1e1b4b;--sb-border:rgba(255,255,255,0.08);--sb-text:rgba(255,255,255,0.45);
            --sb-accent:#818cf8;--sb-accent-2:#a5b4fc;--sb-item-on:rgba(129,140,248,0.2);--sb-width:252px;
            --bg:#f3f4f9;--bg-card:#fff;--bg-topbar:#fff;--border-light:#e8ecf5;--border-light2:#f0f2fb;
            --text-h:#1e1b4b;--text-b:#374151;--text-m:#6b7280;--text-s:#9ca3af;
            --primary:#4f46e5;--primary-2:#6366f1;--primary-light:#ede9fe;
            --green:#16a34a;--red:#dc2626;--amber:#d97706;--blue:#2563eb;--teal:#0d9488}
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Sora',sans-serif;background:var(--bg);color:var(--text-b);min-height:100vh;display:flex}
        ::-webkit-scrollbar{width:4px}::-webkit-scrollbar-thumb{background:rgba(79,70,229,.3);border-radius:4px}
        .sb{width:var(--sb-width);min-height:100vh;background:var(--sb-bg);border-right:1px solid rgba(79,70,229,.2);
            display:flex;flex-direction:column;position:fixed;top:0;left:0;z-index:100;box-shadow:4px 0 24px rgba(0,0,0,.15)}
        .sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border)}
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#818cf8,#a78bfa);border-radius:10px;
            display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;flex-shrink:0}
        .sb-name{color:#fff;font-size:1.05rem;font-weight:800}
        .sb-role{display:inline-flex;background:rgba(13,148,136,.2);border:1px solid rgba(13,148,136,.35);
            color:#5eead4;font-size:.6rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;
            padding:2px 8px;border-radius:20px;margin-top:3px}
        .sb-nav{flex:1;padding:12px 10px;overflow-y:auto}
        .sb-lbl{color:rgba(255,255,255,.22);font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:1.6px;padding:0 8px;margin:14px 0 5px}
        .sb-item{display:flex;align-items:center;gap:9px;padding:8px 10px;border-radius:9px;margin-bottom:1px;
            color:var(--sb-text);text-decoration:none;font-size:.81rem;font-weight:500;transition:all .18s;border-left:2px solid transparent}
        .sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.78rem;border-radius:8px;background:rgba(255,255,255,.06);flex-shrink:0}
        .sb-item.on{color:#fff;background:var(--sb-item-on);border-left-color:var(--sb-accent)}
        .sb-item.on i{background:rgba(129,140,248,.3);color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){color:rgba(255,255,255,.78);background:rgba(255,255,255,.06)}
        .sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border)}
        .sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,.07);
            border:1px solid rgba(255,255,255,.1);margin-bottom:5px;text-decoration:none;transition:all .18s}
        .sb-user:hover{background:rgba(129,140,248,.18);border-color:rgba(129,140,248,.3)}
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);
            display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.8rem;font-weight:600}
        .sb-urole{color:rgba(255,255,255,.35);font-size:.66rem;margin-top:1px}
        .sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;
            color:rgba(255,255,255,.3);text-decoration:none;font-size:.78rem;transition:all .18s}
        .sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,.1)}
        .main{margin-left:var(--sb-width);flex:1;display:flex;flex-direction:column;min-height:100vh}
        .topbar{display:flex;justify-content:space-between;align-items:center;padding:18px 28px;background:var(--bg-topbar);
            border-bottom:1px solid var(--border-light);position:sticky;top:0;z-index:50;box-shadow:0 1px 6px rgba(0,0,0,.06)}
        .topbar-title{font-size:1.2rem;font-weight:800;color:var(--text-h);letter-spacing:-.3px;display:flex;align-items:center;gap:9px}
        .topbar-sub{color:var(--text-s);font-size:.78rem;margin-top:2px}
        .content{padding:24px 28px;flex:1}
        @keyframes cardIn{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}
        .layout-grid{display:grid;grid-template-columns:7fr 5fr;gap:20px;align-items:start}
        .col-right{position:sticky;top:88px}
        @media(max-width:900px){.layout-grid{grid-template-columns:1fr}.col-right{position:static}}
        .card{background:var(--bg-card);border:1px solid var(--border-light);border-radius:16px;overflow:hidden;
            margin-bottom:18px;box-shadow:0 1px 6px rgba(0,0,0,.05);animation:cardIn .45s ease both}
        .card-hd{display:flex;align-items:center;gap:10px;padding:14px 18px;border-bottom:1px solid var(--border-light2);background:#fafbff}
        .card-hd-icon{width:30px;height:30px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.8rem;flex-shrink:0}
        .card-hd-title{font-size:.88rem;font-weight:700;color:var(--text-h)}
        .card-hd-badge{margin-left:auto;display:flex;align-items:center;gap:6px}
        .card-body{padding:20px}
        .info-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}
        .info-item label{font-size:.67rem;font-weight:700;color:var(--text-s);text-transform:uppercase;letter-spacing:1px;display:block;margin-bottom:5px}
        .info-item .val{font-size:.85rem;color:var(--text-b);font-weight:500;line-height:1.5}
        .info-item .val.mono{font-family:'Courier New',monospace;color:var(--primary-2);font-weight:700}
        .desc-box{background:#fafbff;border:1px solid var(--border-light);border-left:3px solid var(--primary-2);
            border-radius:12px;padding:14px 16px;font-size:.83rem;color:var(--text-b);line-height:1.7;white-space:pre-wrap}
        .b{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700}
        .b-draft    {background:#fef3c7;color:#92400e}
        .b-submitted{background:#d1fae5;color:#065f46}
        .b-warranty {background:#d1fae5;color:#065f46}
        .b-maintenance{background:#dbeafe;color:#1e40af}
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 18px;border-radius:10px;font-size:.81rem;
            font-weight:600;font-family:'Sora',sans-serif;cursor:pointer;border:none;text-decoration:none;transition:all .2s}
        .btn-secondary{background:#fff;color:var(--text-m);border:1.5px solid var(--border-light)}
        .btn-secondary:hover{background:#f3f4f6;color:var(--text-b)}
        table{width:100%;border-collapse:collapse;font-size:.8rem}
        thead tr{background:#fafbff}
        th{padding:10px 16px;text-align:left;color:var(--text-s);font-weight:700;font-size:.67rem;
            text-transform:uppercase;letter-spacing:.8px;border-bottom:1px solid var(--border-light2)}
        td{padding:10px 16px;border-bottom:1px solid var(--border-light2);vertical-align:middle}
        tr:last-child td{border-bottom:none}
        .td-muted{color:var(--text-s);font-size:.75rem}
        .cost-box{background:#fafbff;border:1px solid var(--border-light);border-radius:12px;padding:16px}
        .cost-row{display:flex;justify-content:space-between;align-items:center;padding:5px 0;font-size:.82rem;color:var(--text-m)}
        .cost-row.total{border-top:2px solid var(--border-light);margin-top:8px;padding-top:10px;font-size:.92rem;font-weight:700;color:var(--text-h)}
        .cost-row.free{color:var(--green)}
        .invoice-sent{background:linear-gradient(135deg,#d1fae5,#ecfdf5);border:1.5px solid #a7f3d0;
            border-radius:12px;padding:14px 16px;display:flex;align-items:center;gap:10px}
        .invoice-sent i{color:var(--green);font-size:1.3rem;flex-shrink:0}
        .invoice-sent-text{font-size:.82rem;color:#065f46;line-height:1.6}
        .sub-lbl{font-size:.67rem;font-weight:700;color:var(--text-s);text-transform:uppercase;letter-spacing:1px;margin-bottom:7px;margin-top:16px}
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
            <div class="topbar-title"><i class="fas fa-file-medical-alt"></i> Report Detail</div>
            <div class="topbar-sub"><%=report.getReportCode()%> · <%=report.getRequestCode()%></div>
        </div>
        <a href="<%=ctx%>/techReports" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> Back</a>
    </div>

    <div class="content">
        <div class="layout-grid">

            <%-- LEFT --%>
            <div class="col-left">

                <%-- Report Header --%>
                <div class="card">
                    <div class="card-hd">
                        <div class="card-hd-icon" style="background:var(--primary-light);color:var(--primary-2)">
                            <i class="fas fa-file-medical-alt"></i>
                        </div>
                        <div class="card-hd-title"><%=report.getReportCode()%></div>
                        <div class="card-hd-badge">
                            <span class="b <%="SUBMITTED".equals(report.getStatus())?"b-submitted":"b-draft"%>">
                                <%=report.getStatusLabel()%>
                            </span>
                            <%if(report.getContractType()!=null){%>
                            <span class="b <%="WARRANTY".equals(report.getContractType())?"b-warranty":"b-maintenance"%>">
                                <%=report.getContractType()%>
                            </span>
                            <%}%>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="info-grid">
                            <div class="info-item">
                                <label>Request Code</label>
                                <div class="val mono"><%=report.getRequestCode()!=null?report.getRequestCode():"—"%></div>
                            </div>
                            <div class="info-item">
                                <label>Customer</label>
                                <div class="val"><%=report.getCustomerName()!=null?report.getCustomerName():"—"%></div>
                            </div>
                            <div class="info-item">
                                <label>Request Title</label>
                                <div class="val"><%=report.getRequestTitle()!=null?report.getRequestTitle():"—"%></div>
                            </div>
                            <div class="info-item">
                                <label>Created At</label>
                                <div class="val td-muted"><%=report.getCreatedAt()!=null?report.getCreatedAt().toString().replace("T"," ").substring(0,16):"—"%></div>
                            </div>
                        </div>

                        <div class="sub-lbl">Diagnosis</div>
                        <div class="desc-box"><%=report.getDiagnosis()!=null?report.getDiagnosis():"—"%></div>

                        <div class="sub-lbl">Work Done</div>
                        <div class="desc-box"><%=report.getWorkDone()!=null?report.getWorkDone():"—"%></div>
                    </div>
                </div>

                <%-- Parts Used --%>
                <%if(report.getParts()!=null&&!report.getParts().isEmpty()){%>
                <div class="card">
                    <div class="card-hd">
                        <div class="card-hd-icon" style="background:#e0f2fe;color:#0284c7">
                            <i class="fas fa-cogs"></i>
                        </div>
                        <div class="card-hd-title">Parts Used
                            <span style="color:var(--text-s);font-weight:400"> (<%=report.getParts().size()%>)</span>
                        </div>
                        <%if(isWarranty){%>
                        <div class="card-hd-badge">
                            <span style="font-size:.67rem;color:var(--green);font-weight:700">
                                <i class="fas fa-shield-alt"></i> FREE under WARRANTY
                            </span>
                        </div>
                        <%}%>
                    </div>
                    <table>
                        <thead><tr><th>#</th><th>Part Name</th><th>Qty</th><th>Unit Price</th><th>Total</th></tr></thead>
                        <tbody>
                        <%int pi=1;for(RepairReportPart p:report.getParts()){%>
                        <tr>
                            <td class="td-muted"><%=pi++%></td>
                            <td style="font-weight:600;color:var(--text-h)"><%=p.getPartName()%></td>
                            <td class="td-muted"><%=p.getQuantity()%></td>
                            <td class="td-muted">
                                <%if(isWarranty){%><span style="color:var(--green);font-weight:600">FREE</span>
                                <%}else{%><%=String.format("%,.0f",p.getUnitPrice().doubleValue())%> VND<%}%>
                            </td>
                            <td style="font-weight:700;color:<%=isWarranty?"var(--green)":"var(--primary-2)"%>">
                                <%if(isWarranty){%>—<%}else{%><%=String.format("%,.0f",p.getTotalPrice().doubleValue())%> VND<%}%>
                            </td>
                        </tr>
                        <%}%>
                        </tbody>
                    </table>
                </div>
                <%}%>

            </div><%-- end col-left --%>

            <%-- RIGHT --%>
            <div class="col-right">

                <%-- Invoice Status --%>
                <%if(report.getInvoiceId()!=null){%>
                <div class="card">
                    <div class="card-body">
                        <div class="invoice-sent">
                            <i class="fas fa-file-invoice-dollar"></i>
                            <div class="invoice-sent-text">
                                <strong>Invoice has been sent</strong> to the customer.<br>
                                Invoice ID: #<%=report.getInvoiceId()%>
                            </div>
                        </div>
                    </div>
                </div>
                <%}else if("SUBMITTED".equals(report.getStatus())){%>
                <div class="card">
                    <div class="card-body">
                        <div style="background:#fef3c7;border:1.5px solid #fcd34d;border-radius:12px;
                            padding:14px 16px;display:flex;align-items:center;gap:10px">
                            <i class="fas fa-hourglass-half" style="color:var(--amber);font-size:1.1rem;flex-shrink:0"></i>
                            <div style="font-size:.82rem;color:#92400e;line-height:1.6">
                                <strong>Report submitted.</strong><br>
                                Waiting for other team members to submit — invoice will be created automatically.
                            </div>
                        </div>
                    </div>
                </div>
                <%}%>

                <%-- Cost Summary --%>
                <div class="card">
                    <div class="card-hd">
                        <div class="card-hd-icon" style="background:#d1fae5;color:var(--green)">
                            <i class="fas fa-calculator"></i>
                        </div>
                        <div class="card-hd-title">Cost Summary</div>
                    </div>
                    <div class="card-body">
                        <div class="cost-box">
                            <%if(isWarranty){%>
                            <div class="cost-row free">
                                <span>Parts cost</span>
                                <span style="font-weight:600">FREE (WARRANTY)</span>
                            </div>
                            <div class="cost-row" style="font-size:.7rem;color:var(--green);padding-bottom:6px">
                                <span><i class="fas fa-info-circle"></i> Parts: <%=String.format("%,.0f",partsTotal)%> VND waived</span>
                            </div>
                            <%}else{%>
                            <div class="cost-row">
                                <span>Parts subtotal</span>
                                <span class="cost-val"><%=String.format("%,.0f",partsTotal)%> VND</span>
                            </div>
                            <%}%>
                            <div class="cost-row">
                                <span>Labor cost</span>
                                <span class="cost-val"><%=String.format("%,.0f",laborCost)%> VND</span>
                            </div>
                            <div class="cost-row">
                                <span>VAT (10%)</span>
                                <span class="cost-val"><%=String.format("%,.0f",vat)%> VND</span>
                            </div>
                            <div class="cost-row total">
                                <span>Total</span>
                                <span style="color:var(--primary-2)"><%=String.format("%,.0f",grandTotal)%> VND</span>
                            </div>
                        </div>
                        <%if(isWarranty){%>
                        <p style="font-size:.7rem;color:var(--green);margin-top:10px;text-align:center">
                            <i class="fas fa-shield-alt"></i> Parts cost covered by warranty
                        </p>
                        <%}%>
                    </div>
                </div>

                <%-- Quick Info --%>
                <div class="card">
                    <div class="card-hd">
                        <div class="card-hd-icon" style="background:#fef3c7;color:var(--amber)">
                            <i class="fas fa-info-circle"></i>
                        </div>
                        <div class="card-hd-title">Timeline</div>
                    </div>
                    <div class="card-body">
                        <div class="info-grid">
                            <div class="info-item">
                                <label>Created</label>
                                <div class="val td-muted"><%=report.getCreatedAt()!=null?report.getCreatedAt().toString().replace("T"," ").substring(0,16):"—"%></div>
                            </div>
                            <div class="info-item">
                                <label>Submitted</label>
                                <div class="val td-muted"><%=report.getSubmittedAt()!=null?report.getSubmittedAt().toString().replace("T"," ").substring(0,16):"—"%></div>
                            </div>
                        </div>

                        <%if("DRAFT".equals(report.getStatus())){%>
                        <a href="<%=ctx%>/techTasks?action=detail&id=<%=report.getWorkTaskId()%>"
                            class="btn btn-secondary" style="width:100%;justify-content:center;margin-top:12px">
                            <i class="fas fa-edit"></i> Edit Report
                        </a>
                        <%}%>
                    </div>
                </div>

            </div><%-- end col-right --%>
        </div>
    </div>
</main>
</body>
</html>
