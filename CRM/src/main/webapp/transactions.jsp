<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.TransactionDAO.TransactionRow, java.util.*, java.text.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<TransactionRow> transactions = (List<TransactionRow>) request.getAttribute("transactions");
    Map<String, Integer> counts = (Map<String, Integer>) request.getAttribute("counts");
    if (transactions == null) transactions = new ArrayList<>();
    if (counts       == null) counts       = new HashMap<>();

    String activeType = (String) request.getAttribute("type");   if (activeType == null) activeType = "ALL";
    String itemType   = (String) request.getAttribute("itemType"); if (itemType == null) itemType = "";
    String keyword    = (String) request.getAttribute("keyword");  if (keyword == null) keyword = "";
    String fromDate   = (String) request.getAttribute("fromDate"); if (fromDate == null) fromDate = "";
    String toDate     = (String) request.getAttribute("toDate");   if (toDate   == null) toDate   = "";
    int currentPage   = request.getAttribute("currentPage") != null ? (int)request.getAttribute("currentPage") : 1;
    int totalPages    = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages") : 1;
    int total         = request.getAttribute("total")       != null ? (int)request.getAttribute("total") : 0;

    int cntAll      = counts.getOrDefault("ALL",      0);
    int cntPurchase = counts.getOrDefault("PURCHASE", 0);
    int cntRepair   = counts.getOrDefault("REPAIR",   0);
    int cntImport   = counts.getOrDefault("IMPORT",   0);

    String ctx = request.getContextPath();
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Transaction History - DRSMS System</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            body {
                font-family: 'Segoe UI', sans-serif;
                background: #f0f2f5;
                display: flex;
                min-height: 100vh;
            }

            /* SIDEBAR */
            .sidebar {
                width: 200px;
                min-height: 100vh;
                background: #1a1a2e;
                display: flex;
                flex-direction: column;
                position: fixed;
                top:0;
                left:0;
            }
            .sidebar-brand {
                padding: 20px 16px;
                color: white;
                font-size: 1rem;
                font-weight: 700;
                border-bottom: 1px solid rgba(255,255,255,0.1);
            }
            .sidebar-brand i {
                color: #4ade80;
                margin-right: 8px;
            }
            .sidebar-nav {
                flex: 1;
                padding: 12px 0;
            }
            .nav-item {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 11px 20px;
                color: rgba(255,255,255,0.7);
                text-decoration: none;
                font-size: 0.875rem;
                transition: all 0.2s;
                border-left: 3px solid transparent;
            }
            .nav-item:hover, .nav-item.active {
                color: white;
                background: rgba(255,255,255,0.08);
                border-left-color: #4ade80;
            }
            .nav-item i {
                width: 16px;
                text-align: center;
                font-size: 0.85rem;
            }
            .sidebar-footer {
                padding: 16px;
                border-top: 1px solid rgba(255,255,255,0.1);
            }
            .btn-logout {
                display: flex;
                align-items: center;
                gap: 8px;
                color: rgba(255,255,255,0.6);
                text-decoration: none;
                font-size: 0.85rem;
                padding: 8px 12px;
                border-radius: 6px;
            }
            .btn-logout:hover {
                color: #f87171;
                background: rgba(248,113,113,0.1);
            }

            /* MAIN */
            .main {
                margin-left: 200px;
                flex: 1;
                padding: 28px;
            }
            .topbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 24px;
            }
            .page-title {
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .page-title i {
                color: #6366f1;
                font-size: 1.3rem;
            }
            .page-title h1 {
                font-size: 1.4rem;
                font-weight: 700;
                color: #1e293b;
            }
            .user-badge {
                background: white;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 6px 14px;
                font-size: 0.82rem;
                color: #64748b;
                display: flex;
                align-items: center;
                gap: 6px;
            }
            .user-badge i {
                color: #6366f1;
            }

            /* TABS */
            .tabs {
                display: flex;
                gap: 4px;
                background: white;
                border-radius: 10px;
                padding: 5px;
                border: 1px solid #e2e8f0;
                margin-bottom: 20px;
                width: fit-content;
            }
            .tab {
                padding: 8px 18px;
                border-radius: 7px;
                font-size: 0.85rem;
                font-weight: 500;
                cursor: pointer;
                text-decoration: none;
                color: #64748b;
                display: flex;
                align-items: center;
                gap: 7px;
                transition: all 0.15s;
                white-space: nowrap;
            }
            .tab:hover {
                background: #f1f5f9;
                color: #374151;
            }
            .tab.active {
                background: #6366f1;
                color: white;
            }
            .tab .cnt {
                background: rgba(255,255,255,0.3);
                padding: 1px 7px;
                border-radius: 10px;
                font-size: 0.75rem;
            }
            .tab:not(.active) .cnt {
                background: #f1f5f9;
                color: #64748b;
            }

            /* FILTER BAR */
            .filter-bar {
                background: white;
                border: 1px solid #e2e8f0;
                border-radius: 10px;
                padding: 14px 16px;
                margin-bottom: 16px;
                display: flex;
                gap: 10px;
                align-items: center;
                flex-wrap: wrap;
            }
            .filter-bar input, .filter-bar select {
                padding: 8px 12px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                font-size: 0.85rem;
                outline: none;
                background: white;
                color: #374151;
            }
            .filter-bar input:focus, .filter-bar select:focus {
                border-color: #6366f1;
            }
            .filter-bar input[type="text"] {
                flex: 1;
                min-width: 180px;
            }
            .btn {
                padding: 8px 16px;
                border-radius: 8px;
                font-size: 0.85rem;
                font-weight: 500;
                border: none;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 6px;
            }
            .btn-search {
                background: #3b82f6;
                color: white;
            }
            .btn-reset  {
                background: #94a3b8;
                color: white;
            }

            /* TABLE */
            .card {
                background: white;
                border-radius: 12px;
                border: 1px solid #e2e8f0;
                overflow: hidden;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                font-size: 0.83rem;
            }
            thead tr {
                background: #f8fafc;
            }
            th {
                padding: 11px 14px;
                text-align: left;
                color: #64748b;
                font-weight: 600;
                font-size: 0.76rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                border-bottom: 1px solid #e2e8f0;
            }
            td {
                padding: 12px 14px;
                border-bottom: 1px solid #f1f5f9;
                color: #374151;
                vertical-align: middle;
            }
            tr:last-child td {
                border-bottom: none;
            }
            tr:hover td {
                background: #fafbff;
            }

            /* BADGES */
            .badge {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                padding: 3px 10px;
                border-radius: 20px;
                font-size: 0.75rem;
                font-weight: 600;
                white-space: nowrap;
            }
            .badge-purchase {
                background: #dbeafe;
                color: #1e40af;
            }
            .badge-repair   {
                background: #fef3c7;
                color: #92400e;
            }
            .badge-import   {
                background: #d1fae5;
                color: #065f46;
            }
            .badge-other    {
                background: #f3f4f6;
                color: #6b7280;
            }
            .badge-part      {
                background: #ede9fe;
                color: #6d28d9;
            }
            .badge-equipment {
                background: #fce7f3;
                color: #9d174d;
            }
            .badge-sale   {
                background: #dbeafe;
                color: #1e40af;
            }
            .badge-repair-action {
                background: #fef3c7;
                color: #92400e;
            }
            .badge-import-action {
                background: #d1fae5;
                color: #065f46;
            }

            .order-code {
                font-family: monospace;
                font-size: 0.8rem;
                color: #6366f1;
                font-weight: 600;
            }
            .customer-name {
                font-weight: 500;
                color: #1e293b;
            }
            .note-text {
                color: #94a3b8;
                font-size: 0.8rem;
                max-width: 180px;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }
            .time-text {
                color: #94a3b8;
                font-size: 0.8rem;
                white-space: nowrap;
            }

            /* PAGINATION */
            .pagination {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 14px 16px;
                border-top: 1px solid #f1f5f9;
            }
            .paging-info {
                color: #94a3b8;
                font-size: 0.82rem;
            }
            .page-btns {
                display: flex;
                gap: 4px;
            }
            .page-btn {
                padding: 5px 11px;
                border: 1px solid #e2e8f0;
                border-radius: 6px;
                background: white;
                font-size: 0.82rem;
                cursor: pointer;
                text-decoration: none;
                color: #374151;
            }
            .page-btn.active {
                background: #6366f1;
                color: white;
                border-color: #6366f1;
            }
            .page-btn.disabled {
                opacity: 0.4;
                pointer-events: none;
            }
            .page-btn:hover:not(.active):not(.disabled) {
                background: #f1f5f9;
            }

            .empty-state {
                text-align: center;
                padding: 50px 20px;
                color: #94a3b8;
            }
            .empty-state i {
                font-size: 2.5rem;
                margin-bottom: 12px;
                display: block;
            }
        </style>
    </head>
    <body>
        <aside class="sidebar">
            <div class="sidebar-brand"><i class="fas fa-warehouse"></i> DRSMS System</div>
            <nav class="sidebar-nav">
                <a href="<%= ctx %>/dashboard.jsp"    class="nav-item"><i class="fas fa-home"></i> Home</a>
                <a href="<%= ctx %>/profile.jsp"      class="nav-item"><i class="fas fa-user-circle"></i> Profile</a>
                <a href="<%= ctx %>/storekeeper"      class="nav-item"><i class="fas fa-chart-bar"></i> Statistics</a>
                <a href="<%= ctx %>/numberPart"       class="nav-item"><i class="fas fa-list-ul"></i> Parts List</a>
                <a href="<%= ctx %>/numberEquipment"  class="nav-item"><i class="fas fa-desktop"></i> Equipment List</a>
                <a href="<%= ctx %>/transactions"     class="nav-item active"><i class="fas fa-history"></i> Transaction History</a>
                
            </nav>
            <div class="sidebar-footer">
                <a href="<%= ctx %>/logout" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </aside>

        <main class="main">
            <div class="topbar">
                <div class="page-title">
                    <i class="fas fa-history"></i>
                    <h1>Transaction History</h1>
                </div>
                <div class="user-badge"><i class="fas fa-user-circle"></i> Hello, <%= currentUser.getUsername() %></div>
            </div>

            <!-- TABS -->
            <div class="tabs">
                <a href="<%= ctx %>/transactions?type=ALL" class="tab <%= "ALL".equals(activeType) ? "active" : "" %>">
                    <i class="fas fa-list"></i> All <span class="cnt"><%= cntAll %></span>
                </a>
                <a href="<%= ctx %>/transactions?type=PURCHASE" class="tab <%= "PURCHASE".equals(activeType) ? "active" : "" %>">
                    <i class="fas fa-shopping-cart"></i> Purchase <span class="cnt"><%= cntPurchase %></span>
                </a>
                <a href="<%= ctx %>/transactions?type=REPAIR" class="tab <%= "REPAIR".equals(activeType) ? "active" : "" %>">
                    <i class="fas fa-tools"></i> Repair <span class="cnt"><%= cntRepair %></span>
                </a>
                <a href="<%= ctx %>/transactions?type=IMPORT" class="tab <%= "IMPORT".equals(activeType) ? "active" : "" %>">
                    <i class="fas fa-box-open"></i> Stock In <span class="cnt"><%= cntImport %></span>
                </a>
            </div>

            <!-- FILTER -->
            <form method="get" action="<%= ctx %>/transactions">
                <input type="hidden" name="type" value="<%= activeType %>">
                <div class="filter-bar">
                    <input type="text" name="keyword" placeholder="Search by part name, equipment, customer..."
                           value="<%= keyword %>">
                    <select name="itemType">
                        <option value="">-- All Types --</option>
                        <option value="PART"      <%= "PART".equals(itemType)      ? "selected" : "" %>>Part</option>
                        <option value="EQUIPMENT" <%= "EQUIPMENT".equals(itemType) ? "selected" : "" %>>Equipment</option>
                    </select>
                    <input type="date" name="fromDate" value="<%= fromDate %>" title="From date">
                    <input type="date" name="toDate"   value="<%= toDate %>"   title="To date">
                    <button type="submit" class="btn btn-search"><i class="fas fa-search"></i> Search</button>
                    <a href="<%= ctx %>/transactions?type=<%= activeType %>" class="btn btn-reset"><i class="fas fa-undo"></i> Reset</a>
                </div>
            </form>

            <!-- TABLE -->
            <div class="card">
                <% if (transactions.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-inbox"></i>
                    No transactions found
                </div>
                <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Type</th>
                            <th>Item Type</th>
                            <th>Item Name</th>
                            <th>Unit / Serial</th>
                                <%
                                    boolean isPurchase = "PURCHASE".equals(activeType);
                                    boolean isRepair   = "REPAIR".equals(activeType);
                                %>
                                <% if (isPurchase || "ALL".equals(activeType)) { %><th>Customer</th><th>Order Code</th><% } %>
                            <% if (isRepair || "ALL".equals(activeType)) { %><th>Repair Order #</th><% } %>
                            <th>Performed By</th>
                            <th>Note</th>
                            <th>Time</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (TransactionRow t : transactions) {
                            String typeBadgeClass = "badge-other";
                            String typeLabel = t.transactionType;
                            if ("PURCHASE".equals(t.transactionType)) { typeBadgeClass = "badge-purchase"; typeLabel = "Purchase"; }
                            else if ("REPAIR".equals(t.transactionType)) { typeBadgeClass = "badge-repair"; typeLabel = "Repair"; }
                            else if ("IMPORT".equals(t.transactionType)) { typeBadgeClass = "badge-import"; typeLabel = "Stock In"; }
                            String itemBadgeClass = "PART".equals(t.itemType) ? "badge-part" : "badge-equipment";
                            String itemLabel      = "PART".equals(t.itemType) ? "Part" : "Equipment";
                        %>
                        <tr>
                            <td style="color:#94a3b8;font-size:0.8rem"><%= t.id %></td>
                            <td><span class="badge <%= typeBadgeClass %>"><%= typeLabel %></span></td>
                            <td><span class="badge <%= itemBadgeClass %>"><%= itemLabel %></span></td>
                            <td><strong><%= t.itemName != null ? t.itemName : "-" %></strong></td>
                            <td style="font-family:monospace;font-size:0.8rem;color:#6366f1">
                                <%= t.serialOrUnitId != null ? ("#" + t.serialOrUnitId) : "-" %>
                            </td>
                            <% if (isPurchase || "ALL".equals(activeType)) { %>
                            <td class="customer-name"><%= t.customerName != null ? t.customerName : "-" %></td>
                            <td><% if (t.orderCode != null) { %><span class="order-code"><%= t.orderCode %></span><% } else { %>-<% } %></td>
                            <% } %>
                            <% if (isRepair || "ALL".equals(activeType)) { %>
                            <td><% if (t.refOrderId != null) { %><span class="order-code">#<%= t.refOrderId %></span><% } else { %>-<% } %></td>
                            <% } %>
                            <td style="font-size:0.82rem;color:#374151"><%= t.performedBy != null ? t.performedBy : "-" %></td>
                            <td class="note-text" title="<%= t.note != null ? t.note : "" %>"><%= t.note != null ? t.note : "-" %></td>
                            <td class="time-text"><%= t.createdAt != null ? sdf.format(t.createdAt) : "-" %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>

                <!-- PAGINATION -->
                <div class="pagination">
                    <span class="paging-info">Showing <%= transactions.size() %> / <%= total %> transactions — Page <%= currentPage %>/<%= totalPages %></span>
                    <div class="page-btns">
                        <a href="<%= ctx %>/transactions?type=<%= activeType %>&keyword=<%= keyword %>&itemType=<%= itemType %>&fromDate=<%= fromDate %>&toDate=<%= toDate %>&page=1"
                           class="page-btn <%= currentPage==1?"disabled":"" %>">«</a>
                        <a href="<%= ctx %>/transactions?type=<%= activeType %>&keyword=<%= keyword %>&itemType=<%= itemType %>&fromDate=<%= fromDate %>&toDate=<%= toDate %>&page=<%= Math.max(1,currentPage-1) %>"
                           class="page-btn <%= currentPage==1?"disabled":"" %>">‹</a>
                        <% for (int p=Math.max(1,currentPage-2); p<=Math.min(totalPages,currentPage+2); p++) { %>
                        <a href="<%= ctx %>/transactions?type=<%= activeType %>&keyword=<%= keyword %>&itemType=<%= itemType %>&fromDate=<%= fromDate %>&toDate=<%= toDate %>&page=<%= p %>"
                           class="page-btn <%= p==currentPage?"active":"" %>"><%= p %></a>
                        <% } %>
                        <a href="<%= ctx %>/transactions?type=<%= activeType %>&keyword=<%= keyword %>&itemType=<%= itemType %>&fromDate=<%= fromDate %>&toDate=<%= toDate %>&page=<%= Math.min(totalPages,currentPage+1) %>"
                           class="page-btn <%= currentPage==totalPages?"disabled":"" %>">›</a>
                        <a href="<%= ctx %>/transactions?type=<%= activeType %>&keyword=<%= keyword %>&itemType=<%= itemType %>&fromDate=<%= fromDate %>&toDate=<%= toDate %>&page=<%= totalPages %>"
                           class="page-btn <%= currentPage==totalPages?"disabled":"" %>">»</a>
                    </div>
                </div>
                <% } %>
            </div>
        </main>
    </body>
</html>
