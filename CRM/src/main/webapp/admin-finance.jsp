<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.UserDAO, dao.RoleDAO, dao.FinanceDAO, dao.FinanceDAO.FinanceRow, dao.FinanceDAO.MonthlyRevenue" %>
<%@ page import="java.math.BigDecimal, java.util.List, java.util.ArrayList" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";

    BigDecimal totalSale   = (BigDecimal) request.getAttribute("totalSale");
    BigDecimal totalRepair = (BigDecimal) request.getAttribute("totalRepair");
    BigDecimal totalAll    = (BigDecimal) request.getAttribute("totalAll");
    BigDecimal unpaidAmt   = (BigDecimal) request.getAttribute("unpaidAmt");
    int unpaidCount        = (Integer)    request.getAttribute("unpaidCount");

    List<FinanceRow> rows  = (List<FinanceRow>) request.getAttribute("rows");
    List<MonthlyRevenue> monthly = (List<MonthlyRevenue>) request.getAttribute("monthly");

    int currentPage = (Integer) request.getAttribute("page");
    int totalPages = (Integer) request.getAttribute("totalPages");
    int total      = (Integer) request.getAttribute("total");

    String filterType     = (String) request.getAttribute("type");
    String filterFromDate = (String) request.getAttribute("fromDate");
    String filterToDate   = (String) request.getAttribute("toDate");
    String filterKeyword  = (String) request.getAttribute("keyword");

    java.text.NumberFormat nf = java.text.NumberFormat.getInstance(new java.util.Locale("vi","VN"));
    if (totalSale   == null) totalSale   = BigDecimal.ZERO;
    if (totalRepair == null) totalRepair = BigDecimal.ZERO;
    if (totalAll    == null) totalAll    = BigDecimal.ZERO;
    if (unpaidAmt   == null) unpaidAmt   = BigDecimal.ZERO;

    // Build chart data arrays
    StringBuilder chartMonths = new StringBuilder("[");
    StringBuilder chartSale   = new StringBuilder("[");
    StringBuilder chartRepair = new StringBuilder("[");
    if (monthly != null) {
        for (int i = 0; i < monthly.size(); i++) {
            FinanceDAO.MonthlyRevenue mr = monthly.get(i);
            if (i > 0) { chartMonths.append(","); chartSale.append(","); chartRepair.append(","); }
            chartMonths.append("'").append(mr.month).append("'");
            chartSale.append(mr.sale.longValue());
            chartRepair.append(mr.repair.longValue());
        }
    }
    chartMonths.append("]"); chartSale.append("]"); chartRepair.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Finance Management – DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        :root {
            --sb-bg:        #1e1b4b;
            --sb-border:    rgba(255,255,255,0.08);
            --sb-text:      rgba(255,255,255,0.45);
            --sb-accent:    #818cf8;
            --sb-accent-2:  #a5b4fc;
            --sb-item-on:   rgba(129,140,248,0.2);
            --sb-width:     252px;
            --bg:           #f3f4f9;
            --bg-card:      #ffffff;
            --bg-topbar:    #ffffff;
            --border-light: #e8ecf5;
            --text-h:       #1e1b4b;
            --text-b:       #374151;
            --text-m:       #6b7280;
            --text-s:       #9ca3af;
            --primary:      #4f46e5;
            --primary-2:    #6366f1;
            --primary-light:#ede9fe;
            --green:        #16a34a;
            --red:          #dc2626;
            --amber:        #d97706;
            --blue:         #2563eb;
        }
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{scroll-behavior:smooth}
        body{font-family:'Sora',sans-serif;background:var(--bg);color:var(--text-b);min-height:100vh;display:flex;}
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-track{background:transparent}
        ::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px}

        /* ═══ SIDEBAR ═══ */
        .sb{width:var(--sb-width);min-height:100vh;background:var(--sb-bg);border-right:1px solid rgba(79,70,229,0.2);display:flex;flex-direction:column;position:fixed;top:0;left:0;z-index:100;box-shadow:4px 0 24px rgba(0,0,0,0.15);}
        .sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border);}
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#f59e0b,#f97316);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;box-shadow:0 4px 12px rgba(245,158,11,0.4);flex-shrink:0;}
        .sb-name{color:#fff;font-size:1.05rem;font-weight:800;letter-spacing:-.3px}
        .sb-role{display:inline-flex;align-items:center;background:rgba(217,119,6,0.2);border:1px solid rgba(217,119,6,0.35);color:#fbbf24;font-size:.6rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:2px 8px;border-radius:20px;margin-top:3px;}
        .sb-nav{flex:1;padding:12px 10px;overflow-y:auto}
        .sb-lbl{color:rgba(255,255,255,0.22);font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:1.6px;padding:0 8px;margin:14px 0 5px;}
        .sb-item{display:flex;align-items:center;gap:9px;padding:8px 10px;border-radius:9px;margin-bottom:1px;color:var(--sb-text);text-decoration:none;font-size:.81rem;font-weight:500;transition:all .18s;border-left:2px solid transparent;}
        .sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.78rem;border-radius:8px;background:rgba(255,255,255,0.06);flex-shrink:0;transition:all .18s;}
        .sb-item.on{color:#fff;background:var(--sb-item-on);border-left-color:var(--sb-accent);}
        .sb-item.on i{background:rgba(129,140,248,0.3);color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){color:rgba(255,255,255,0.78);background:rgba(255,255,255,0.06);}
        .sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border)}
        .sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);margin-bottom:5px;text-decoration:none;transition:all .18s;cursor:pointer;}
        .sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3)}
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#f59e0b,#f97316);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.8rem;font-weight:600}
        .sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem;margin-top:1px}
        .sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
        .sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1)}

        /* ═══ MAIN ═══ */
        .main{margin-left:var(--sb-width);flex:1;display:flex;flex-direction:column;min-height:100vh}
        .topbar{display:flex;justify-content:space-between;align-items:center;padding:18px 28px;background:var(--bg-topbar);border-bottom:1px solid var(--border-light);position:sticky;top:0;z-index:50;box-shadow:0 1px 6px rgba(0,0,0,0.06);}
        .topbar-greeting{font-size:1.2rem;font-weight:800;color:var(--text-h);letter-spacing:-.3px}
        .topbar-sub{color:var(--text-s);font-size:.78rem;margin-top:2px}
        .content{padding:24px 28px;flex:1}

        @keyframes cardIn{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:none}}
        .section-lbl{font-size:.63rem;font-weight:700;text-transform:uppercase;letter-spacing:2px;color:var(--primary-2);margin-bottom:13px;display:flex;align-items:center;gap:10px;}
        .section-lbl::after{content:'';flex:1;height:1px;background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)}

        /* ── Stat cards ── */
        .stats{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:26px;}
        .sc{border-radius:16px;padding:20px;position:relative;overflow:hidden;color:#fff;transition:all .22s;animation:cardIn .5s ease both;}
        .sc:hover{transform:translateY(-3px);}
        .sc::before{content:'';position:absolute;top:-20px;right:-20px;width:90px;height:90px;border-radius:50%;background:rgba(255,255,255,0.1);}
        .sc::after{content:'';position:absolute;bottom:-30px;right:20px;width:60px;height:60px;border-radius:50%;background:rgba(255,255,255,0.07);}
        .sc-icon{width:36px;height:36px;border-radius:10px;background:rgba(255,255,255,0.2);display:flex;align-items:center;justify-content:center;font-size:.9rem;margin-bottom:14px;}
        .sc-val{font-size:1.5rem;font-weight:800;letter-spacing:-.5px;margin-bottom:3px}
        .sc-lbl{font-size:.72rem;font-weight:500;opacity:.85;}
        .sc-blue{background:linear-gradient(135deg,#3b82f6,#2563eb);}
        .sc-green{background:linear-gradient(135deg,#22c55e,#16a34a);}
        .sc-amber{background:linear-gradient(135deg,#f59e0b,#d97706);}
        .sc-red{background:linear-gradient(135deg,#f87171,#dc2626);}

        /* ── Chart card ── */
        .chart-card{background:var(--bg-card);border-radius:16px;padding:24px;border:1px solid var(--border-light);margin-bottom:26px;animation:cardIn .6s ease both;}
        .chart-card h3{font-size:.9rem;font-weight:700;color:var(--text-h);margin-bottom:18px;display:flex;align-items:center;gap:8px;}
        .chart-card h3 i{color:var(--primary-2)}
        .chart-wrap{height:240px;position:relative;}

        /* ── Filter bar ── */
        .filter-bar{background:var(--bg-card);border-radius:14px;padding:16px 20px;border:1px solid var(--border-light);margin-bottom:18px;display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end;}
        .filter-bar label{font-size:.72rem;font-weight:600;color:var(--text-m);display:block;margin-bottom:4px}
        .filter-bar input,.filter-bar select{height:36px;padding:0 10px;border:1px solid var(--border-light);border-radius:8px;font-size:.78rem;font-family:'Sora',sans-serif;color:var(--text-b);background:#fff;outline:none;transition:border .18s;}
        .filter-bar input:focus,.filter-bar select:focus{border-color:var(--primary-2);}
        .filter-bar .fg{display:flex;flex-direction:column;}

        /* ── Buttons ── */
        .btn{display:inline-flex;align-items:center;gap:6px;height:36px;padding:0 14px;border-radius:8px;font-size:.78rem;font-weight:600;font-family:'Sora',sans-serif;cursor:pointer;border:none;text-decoration:none;transition:all .18s;white-space:nowrap;}
        .btn-primary{background:var(--primary);color:#fff;}
        .btn-primary:hover{background:#4338ca;}
        .btn-secondary{background:#f3f4f6;color:var(--text-b);border:1px solid var(--border-light);}
        .btn-secondary:hover{background:#e5e7eb;}
        .btn-green{background:linear-gradient(135deg,#22c55e,#16a34a);color:#fff;}
        .btn-green:hover{opacity:.9;}

        /* ── Table ── */
        .table-card{background:var(--bg-card);border-radius:16px;border:1px solid var(--border-light);overflow:hidden;animation:cardIn .7s ease both;}
        .table-header{display:flex;align-items:center;justify-content:space-between;padding:16px 20px;border-bottom:1px solid var(--border-light);}
        .table-header h3{font-size:.9rem;font-weight:700;color:var(--text-h);display:flex;align-items:center;gap:8px;}
        .table-header h3 i{color:var(--primary-2)}
        .table-actions{display:flex;gap:8px;}
        table{width:100%;border-collapse:collapse;}
        thead th{background:linear-gradient(135deg,rgba(79,70,229,0.05),rgba(99,102,241,0.03));padding:10px 14px;font-size:.7rem;font-weight:700;color:var(--primary-2);text-transform:uppercase;letter-spacing:.8px;text-align:left;border-bottom:1px solid var(--border-light);}
        tbody tr{border-bottom:1px solid rgba(232,236,245,0.7);transition:background .14s;}
        tbody tr:hover{background:rgba(79,70,229,0.03);}
        tbody td{padding:10px 14px;font-size:.8rem;color:var(--text-b);}
        .badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.67rem;font-weight:700;}
        .badge-green{background:#dcfce7;color:#16a34a;}
        .badge-amber{background:#fef3c7;color:#b45309;}
        .badge-red{background:#fee2e2;color:#dc2626;}
        .badge-blue{background:#dbeafe;color:#1d4ed8;}
        .badge-purchase{background:#e0e7ff;color:#4338ca;}
        .badge-repair{background:#d1fae5;color:#065f46;}
        .empty-row td{text-align:center;padding:40px;color:var(--text-s);font-size:.85rem;}

        /* ── Pagination ── */
        .pagination{display:flex;align-items:center;gap:6px;padding:14px 20px;border-top:1px solid var(--border-light);justify-content:space-between;}
        .pag-info{font-size:.75rem;color:var(--text-s)}
        .pag-btns{display:flex;gap:4px;}
        .pag-btn{width:32px;height:32px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:.78rem;font-weight:600;cursor:pointer;border:1px solid var(--border-light);background:#fff;color:var(--text-b);text-decoration:none;transition:all .18s;}
        .pag-btn.on{background:var(--primary);color:#fff;border-color:var(--primary);}
        .pag-btn:hover:not(.on):not(.disabled){background:var(--primary-light);color:var(--primary);}
        .pag-btn.disabled{opacity:.4;pointer-events:none;}

        /* Responsive */
        @media(max-width:1200px){.stats{grid-template-columns:repeat(2,1fr)}}
    </style>
</head>
<body>

<!-- ═══════════════════ SIDEBAR ═══════════════════ -->
<nav class="sb">
    <div class="sb-brand">
        <div class="sb-logo"><i class="fas fa-shield-halved"></i></div>
        <div>
            <div class="sb-name">DRSMS</div>
            <div class="sb-role">ADMIN</div>
        </div>
    </div>
    <div class="sb-nav">
        <div class="sb-lbl">Overview</div>
        <a href="<%=ctx%>/admin.jsp" class="sb-item">
            <i class="fas fa-gauge-high"></i> Dashboard
        </a>
        <div class="sb-lbl">Management</div>
        <a href="<%=ctx%>/user/list" class="sb-item">
            <i class="fas fa-users"></i> Users
        </a>
        <a href="<%=ctx%>/role/list" class="sb-item">
            <i class="fas fa-user-tag"></i> Roles
        </a>
        <a href="<%=ctx%>/admin/finance" class="sb-item on">
            <i class="fas fa-chart-line"></i> Finance
        </a>
    </div>
    <div class="sb-foot">
        <a href="<%=ctx%>/profile" class="sb-user">
           <div class="sb-ava">
    <% if (currentUser.getAvatarUrl() != null && !currentUser.getAvatarUrl().isEmpty()) { %>
        <img src="<%=ctx%><%=currentUser.getAvatarUrl()%>" alt="">
    <% } else { %> <%=initials%> <% } %>
</div>
            <div>
                <div class="sb-uname"><%=currentUser.getFullName() != null ? currentUser.getFullName() : currentUser.getUsername()%></div>
                <div class="sb-urole">Administrator</div>
            </div>
        </a>
        <a href="<%=ctx%>/logout" class="sb-logout">
            <i class="fas fa-sign-out-alt"></i> Sign Out
        </a>
    </div>
</nav>

<!-- ═══════════════════ MAIN ═══════════════════ -->
<div class="main">
    <!-- Topbar -->
    <div class="topbar">
        <div>
            <div class="topbar-greeting">Finance Management</div>
            <div class="topbar-sub">Sales &amp; repair revenue overview</div>
        </div>
        <a href="<%=ctx%>/admin/finance?export=excel&type=<%=filterType%>&fromDate=<%=filterFromDate%>&toDate=<%=filterToDate%>&keyword=<%=filterKeyword%>"
           class="btn btn-green">
            <i class="fas fa-file-excel"></i> Export Excel
        </a>
    </div>

    <div class="content">

        <!-- ── Stat Cards ── -->
        <div class="section-lbl">Overview</div>
        <div class="stats">
            <div class="sc sc-blue" style="animation-delay:.05s">
                <div class="sc-icon"><i class="fas fa-coins"></i></div>
                <div class="sc-val"><%=nf.format(totalAll.longValue())%>₫</div>
                <div class="sc-lbl">Total Revenue</div>
            </div>
            <div class="sc sc-green" style="animation-delay:.1s">
                <div class="sc-icon"><i class="fas fa-cart-shopping"></i></div>
                <div class="sc-val"><%=nf.format(totalSale.longValue())%>₫</div>
                <div class="sc-lbl">Sales Revenue</div>
            </div>
            <div class="sc sc-amber" style="animation-delay:.15s">
                <div class="sc-icon"><i class="fas fa-screwdriver-wrench"></i></div>
                <div class="sc-val"><%=nf.format(totalRepair.longValue())%>₫</div>
                <div class="sc-lbl">Repair Revenue</div>
            </div>
            <div class="sc sc-red" style="animation-delay:.2s">
                <div class="sc-icon"><i class="fas fa-clock-rotate-left"></i></div>
                <div class="sc-val"><%=unpaidCount%> invoices</div>
                <div class="sc-lbl">Unpaid · <%=nf.format(unpaidAmt.longValue())%>₫</div>
            </div>
        </div>

        <!-- ── Chart ── -->
        <div class="chart-card">
            <h3><i class="fas fa-chart-bar"></i> Monthly Revenue (Last 12 Months)</h3>
            <div class="chart-wrap">
                <canvas id="revenueChart"></canvas>
            </div>
        </div>

        <!-- ── Filter ── -->
        <div class="section-lbl">Transaction Details</div>
        <form class="filter-bar" method="get" action="<%=ctx%>/admin/finance">
            <div class="fg">
                <label>Type</label>
                <select name="type">
                    <option value="" <%="".equals(filterType)?"selected":""%>>All</option>
                    <option value="PURCHASE" >Sales</option>
                    <option value="REPAIR" >Repair</option>
                </select>
            </div>
            <div class="fg">
                <label>From Date</label>
                <input type="date" name="fromDate" value="<%=filterFromDate%>">
            </div>
            <div class="fg">
                <label>To Date</label>
                <input type="date" name="toDate" value="<%=filterToDate%>">
            </div>
            <div class="fg" style="flex:1;min-width:180px">
                <label>Search</label>
                <input type="text" name="keyword" value="<%=filterKeyword%>" placeholder="Customer name / invoice code / payment code...">
            </div>
            <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Filter</button>
            <a href="<%=ctx%>/admin/finance" class="btn btn-secondary"><i class="fas fa-rotate-left"></i> Reset</a>
        </form>

        <!-- ── Table ── -->
        <div class="table-card">
            <div class="table-header">
                <h3><i class="fas fa-list-ul"></i> Transaction List
                    <span style="font-weight:400;color:var(--text-s);font-size:.75rem">(<%=total%> results)</span>
                </h3>
                <div class="table-actions">
                    <a href="<%=ctx%>/admin/finance?export=excel&type=<%=filterType%>&fromDate=<%=filterFromDate%>&toDate=<%=filterToDate%>&keyword=<%=filterKeyword%>"
                       class="btn btn-green" title="Tải Excel">
                        <i class="fas fa-file-excel"></i> Excel
                    </a>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Payment Code</th>
                        <th>Invoice Code</th>
                        <th>Customer</th>
                        <th>Type</th>
                        <th>Method</th>
                        <th style="text-align:right">Amount</th>
                        <th>Status</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if (rows == null || rows.isEmpty()) {
                    %>
                    <tr class="empty-row">
                        <td colspan="9">
                            <i class="fas fa-inbox" style="font-size:2rem;display:block;margin-bottom:8px;opacity:.3"></i>
                            No transactions found
                        </td>
                    </tr>
                    <%
                    } else {
                        int stt = ((currentPage - 1) * 10) + 1;
                        java.time.format.DateTimeFormatter dtf = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                        for (FinanceRow r : rows) {
                            String statusBadge = "SUCCESS".equals(r.status) ? "badge-green"
                                              : "PENDING".equals(r.status) ? "badge-amber"
                                              : "FAILED".equals(r.status)  ? "badge-red"
                                              : "badge-amber";
                            String statusLabel = "SUCCESS".equals(r.status) ? "Successful"
                                              : "PENDING".equals(r.status) ? "Processing"
                                              : "FAILED".equals(r.status)  ? "Failed"
                                              : "Cancelled";
                            String typeBadge = "PURCHASE".equals(r.invoiceType) ? "badge-purchase" : "badge-repair";
                            String typeLabel = "PURCHASE".equals(r.invoiceType) ? "Sales" : "Repair";
                            String timeStr = r.createdAt != null
                                ? r.createdAt.toLocalDateTime().format(dtf) : "–";
                    %>
                    <tr>
                        <td style="color:var(--text-s)"><%=stt++%></td>
                        <td style="font-weight:600;color:var(--primary-2)"><%=r.paymentCode%></td>
                        <td style="color:var(--text-m)"><%=r.invoiceCode%></td>
                        <td><%=r.customerName%></td>
                        <td><span class="badge <%=typeBadge%>"><%=typeLabel%></span></td>
                        <td style="color:var(--text-m)">
                            <i class="fas <%="CASH".equals(r.paymentMethod) ? "fa-money-bill-wave" : "fa-credit-card"%>"
                               style="margin-right:4px;opacity:.6"></i>
                            <%="CASH".equals(r.paymentMethod) ? "Cash" : "VNPay"%>
                        </td>
                        <td style="text-align:right;font-weight:700;color:var(--text-h)">
                            <%=r.amount != null ? nf.format(r.amount.longValue()) + "₫" : "–"%>
                        </td>
                        <td><span class="badge <%=statusBadge%>"><%=statusLabel%></span></td>
                        <td style="color:var(--text-s);font-size:.75rem"><%=timeStr%></td>
                    </tr>
                    <%
                        }
                    }
                    %>
                </tbody>
            </table>

            <!-- Pagination -->
            <% if (totalPages > 1) { %>
            <div class="pagination">
                <div class="pag-info">
                    Page <%=currentPage%> / <%=totalPages%> &nbsp;·&nbsp; Total <%=total%> transactions
                </div>
                <div class="pag-btns">
                    <%
                    String baseUrl = ctx + "/admin/finance?type=" + filterType
                        + "&fromDate=" + filterFromDate + "&toDate=" + filterToDate
                        + "&keyword=" + filterKeyword + "&page=";
                    %>
                    <a href="<%=currentPage>1 ? baseUrl+(currentPage-1) : "#"%>"
                       class="pag-btn <%=currentPage<=1?"disabled":""%>">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                    <%
                    int start = Math.max(1, currentPage-2);
                    int end   = Math.min(totalPages, currentPage+2);
                    for (int p2 = start; p2 <= end; p2++) {
                    %>
                    <a href="<%=baseUrl+p2%>" class="pag-btn <%=p2==currentPage?"on":""%>"><%=p2%></a>
                    <% } %>
                    <a href="<%=currentPage<totalPages ? baseUrl+(currentPage+1) : "#"%>"
                       class="pag-btn <%=currentPage>=totalPages?"disabled":""%>">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </div>
            </div>
            <% } %>
        </div><!-- /table-card -->

    </div><!-- /content -->
</div><!-- /main -->

<!-- ═══ CHART SCRIPT ═══ -->
<script>
(function(){
    const months  = <%=chartMonths%>;
    const sale    = <%=chartSale%>;
    const repair  = <%=chartRepair%>;

    const ctx = document.getElementById('revenueChart').getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: months,
            datasets: [
                {
                    label: 'Sales',
                    data: sale,
                    backgroundColor: 'rgba(59,130,246,0.75)',
                    borderRadius: 6,
                    borderSkipped: false
                },
                {
                    label: 'Repair',
                    data: repair,
                    backgroundColor: 'rgba(34,197,94,0.75)',
                    borderRadius: 6,
                    borderSkipped: false
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'top', labels: { font:{ family:'Sora',size:11 }, usePointStyle:true } },
                tooltip: {
                    callbacks: {
                        label: ctx => {
                            const v = ctx.parsed.y;
                            return ' ' + ctx.dataset.label + ': ' + v.toLocaleString('vi-VN') + '₫';
                        }
                    }
                }
            },
            scales: {
                x: { grid:{display:false}, ticks:{font:{family:'Sora',size:11}} },
                y: {
                    grid:{color:'rgba(0,0,0,0.05)'},
                    ticks:{
                        font:{family:'Sora',size:11},
                        callback: v => v.toLocaleString('vi-VN') + '₫'
                    }
                }
            }
        }
    });
})();
</script>
</body>
</html>
