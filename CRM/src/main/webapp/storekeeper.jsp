<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.PartType, java.util.*, java.text.NumberFormat, java.util.Locale" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Map<String, Integer> partStats = (Map<String, Integer>) request.getAttribute("partStats");
    Map<String, Integer> eqStats   = (Map<String, Integer>) request.getAttribute("eqStats");
    List<PartType> lowStockList    = (List<PartType>) request.getAttribute("lowStockList");
    List<PartType> mostUsedList    = (List<PartType>) request.getAttribute("mostUsedList");
    if (partStats == null) partStats = new HashMap<>();
    if (eqStats   == null) eqStats   = new HashMap<>();
    if (lowStockList  == null) lowStockList  = new ArrayList<>();
    if (mostUsedList  == null) mostUsedList  = new ArrayList<>();

    int totalPartTypes = partStats.getOrDefault("totalPartTypes", 0);
    int totalPartUnits = partStats.getOrDefault("totalPartUnits", 0);
    int availableUnits = partStats.getOrDefault("availableUnits", 0);
    int faultyUnits    = partStats.getOrDefault("faultyUnits", 0);
    int inuseUnits     = partStats.getOrDefault("inuseUnits", 0);
    int retiredUnits   = partStats.getOrDefault("retiredUnits", 0);
    int lowStock       = partStats.getOrDefault("lowStock", 0);
    int totalEqTypes   = eqStats.getOrDefault("totalEqTypes", 0);
    int totalEqUnits   = eqStats.getOrDefault("totalEqUnits", 0);
    int availableEq    = eqStats.getOrDefault("availableEq", 0);
    int faultyEq       = eqStats.getOrDefault("faultyEq", 0);
    int inuseEq        = eqStats.getOrDefault("inuseEq", 0);

    double pctAvailable = totalPartUnits > 0 ? (availableUnits * 100.0 / totalPartUnits) : 0;
    double pctRetired   = totalPartUnits > 0 ? (retiredUnits  * 100.0 / totalPartUnits) : 0;

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý kho - CRM System</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f2f5; display: flex; min-height: 100vh; }

        /* SIDEBAR */
        .sidebar {
            width: 200px; min-height: 100vh; background: #1a1a2e;
            display: flex; flex-direction: column; position: fixed; top: 0; left: 0;
        }
        .sidebar-brand {
            padding: 20px 16px; color: white; font-size: 1rem; font-weight: 700;
            border-bottom: 1px solid rgba(255,255,255,0.1); letter-spacing: 0.5px;
        }
        .sidebar-brand i { color: #4ade80; margin-right: 8px; }
        .sidebar-nav { flex: 1; padding: 12px 0; }
        .nav-item { display: block; padding: 11px 20px; color: rgba(255,255,255,0.7);
            text-decoration: none; font-size: 0.875rem; display: flex; align-items: center; gap: 10px;
            transition: all 0.2s; border-left: 3px solid transparent; }
        .nav-item:hover, .nav-item.active {
            color: white; background: rgba(255,255,255,0.08); border-left-color: #4ade80; }
        .nav-item i { width: 16px; text-align: center; font-size: 0.85rem; }
        .sidebar-footer { padding: 16px; border-top: 1px solid rgba(255,255,255,0.1); }
        .btn-logout { display: flex; align-items: center; gap: 8px; color: rgba(255,255,255,0.6);
            text-decoration: none; font-size: 0.85rem; padding: 8px 12px; border-radius: 6px;
            transition: all 0.2s; }
        .btn-logout:hover { color: #f87171; background: rgba(248,113,113,0.1); }

        /* MAIN */
        .main { margin-left: 200px; flex: 1; padding: 28px; }
        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 24px;
        }
        .page-title { display: flex; align-items: center; gap: 10px; }
        .page-title i { color: #6366f1; font-size: 1.4rem; }
        .page-title h1 { font-size: 1.4rem; font-weight: 700; color: #1e293b; }
        .user-badge {
            background: white; border: 1px solid #e2e8f0; border-radius: 20px;
            padding: 6px 14px; font-size: 0.82rem; color: #64748b; display: flex; align-items: center; gap: 6px;
        }
        .user-badge i { color: #6366f1; }

        /* STAT CARDS */
        .stat-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 20px; }
        .stat-card {
            background: white; border-radius: 12px; padding: 20px;
            border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }
        .stat-label { font-size: 0.78rem; color: #94a3b8; margin-bottom: 8px; line-height: 1.4; }
        .stat-value { font-size: 2rem; font-weight: 700; color: #1e293b; }
        .stat-card.highlight { border-left: 3px solid #f59e0b; }
        .stat-card.danger    { border-left: 3px solid #ef4444; }
        .stat-card.success   { border-left: 3px solid #10b981; }
        .stat-card.info      { border-left: 3px solid #6366f1; }

        /* CHARTS + TABLES ROW */
        .row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }
        .card {
            background: white; border-radius: 12px; padding: 20px;
            border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }
        .card-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9;
        }
        .card-title { font-size: 0.95rem; font-weight: 600; color: #1e293b; }
        .view-more { font-size: 0.8rem; color: #6366f1; text-decoration: none; }
        .view-more:hover { text-decoration: underline; }

        /* DONUT CHART */
        .donut-wrap { display: flex; align-items: center; justify-content: center; gap: 24px; padding: 8px 0; }
        .donut-svg { width: 130px; height: 130px; }
        .donut-legend { display: flex; flex-direction: column; gap: 8px; }
        .legend-item { display: flex; align-items: center; gap: 8px; font-size: 0.8rem; color: #64748b; }
        .legend-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
        .legend-count { font-weight: 600; color: #1e293b; margin-left: auto; padding-left: 16px; }

        /* TABLE */
        .data-table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
        .data-table th { padding: 8px 12px; text-align: left; color: #94a3b8; font-weight: 600;
            text-transform: uppercase; font-size: 0.72rem; letter-spacing: 0.5px; border-bottom: 1px solid #f1f5f9; }
        .data-table td { padding: 10px 12px; border-bottom: 1px solid #f8fafc; color: #374151; }
        .data-table tr:last-child td { border-bottom: none; }
        .data-table tr:hover td { background: #f8fafc; }
        .badge {
            display: inline-block; padding: 2px 8px; border-radius: 10px;
            font-size: 0.72rem; font-weight: 600;
        }
        .badge-available { background: #d1fae5; color: #065f46; }
        .badge-inuse     { background: #dbeafe; color: #1e40af; }
        .badge-faulty    { background: #fef3c7; color: #92400e; }
        .badge-retired   { background: #f3f4f6; color: #6b7280; }
        .badge-low       { background: #fee2e2; color: #991b1b; }

        /* EQ SECTION */
        .section-title { font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 14px;
            display: flex; align-items: center; gap: 8px; }
        .section-title i { color: #6366f1; }
    </style>
</head>
<body>
<!-- SIDEBAR -->
<aside class="sidebar">
    <div class="sidebar-brand"><i class="fas fa-warehouse"></i> CRM System</div>
    <nav class="sidebar-nav">
        <a href="<%= ctx %>/dashboard.jsp" class="nav-item "><i class="fas fa-home"></i> Trang chủ</a>
        <a href="<%= ctx %>/profile.jsp"      class="nav-item "><i class="fas fa-user-circle"></i> Hồ Sơ</a>
        <a href="<%= ctx %>/storekeeper"      class="nav-item active"><i class="fas fa-chart-bar"></i> Thống kê</a>
        <a href="<%= ctx %>/numberPart"       class="nav-item"><i class="fas fa-list-ul"></i> Danh sách linh kiện</a>
        <a href="<%= ctx %>/numberEquipment"  class="nav-item"><i class="fas fa-desktop"></i> Danh sách thiết bị</a>
        <a href="<%= ctx %>/transactions" class="nav-item"><i class="fas fa-history"></i> Lịch sử giao dịch</a>
       
        <a href="<%= ctx %>/categoryManage"   class="nav-item"><i class="fas fa-tags"></i> Quản lý danh mục</a>
    </nav>
    <div class="sidebar-footer">
        <a href="<%= ctx %>/logout" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
    </div>
</aside>

<!-- MAIN CONTENT -->
<main class="main">
    <div class="topbar">
        <div class="page-title">
            <i class="fas fa-cogs"></i>
            <h1>Chi số quản lý kho</h1>
        </div>
        <div class="user-badge">
            <i class="fas fa-user-circle"></i> Xin chào <%= currentUser.getUsername() %>
        </div>
    </div>

    <!-- PART STATS -->
    <div class="stat-grid">
        <div class="stat-card info">
            <div class="stat-label">Tổng số loại thiết bị trong kho</div>
            <div class="stat-value"><%= totalPartTypes %></div>
        </div>
        <div class="stat-card info">
            <div class="stat-label">Tổng số loại linh kiện trong kho</div>
            <div class="stat-value"><%= totalPartUnits %></div>
        </div>
        <div class="stat-card highlight">
            <div class="stat-label">Tổng số loại linh kiện sắp hết</div>
            <div class="stat-value"><%= lowStock %></div>
        </div>
        <div class="stat-card success">
            <div class="stat-label">Tổng số linh kiện sẵn sàng trong kho</div>
            <div class="stat-value"><%= availableUnits %></div>
        </div>
        <div class="stat-card danger">
            <div class="stat-label">Tổng số linh kiện bị hỏng trong kho</div>
            <div class="stat-value"><%= faultyUnits %></div>
        </div>
        <div class="stat-card info">
            <div class="stat-label">Tổng số linh kiện đang được sử dụng</div>
            <div class="stat-value"><%= inuseUnits %></div>
        </div>
        <div class="stat-card success">
            <div class="stat-label">% Tổng số linh kiện sẵn sàng</div>
            <div class="stat-value"><%= String.format("%.1f", pctAvailable) %>%</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">% Số lượng linh kiện ngừng dùng</div>
            <div class="stat-value"><%= String.format("%.1f", pctRetired) %>%</div>
        </div>
    </div>

    <!-- DONUT + TABLES -->
    <div class="row-2">
        <!-- Donut Chart -->
        <div class="card">
            <div class="card-header">
                <span class="card-title">Tình trạng linh kiện</span>
            </div>
            <div class="donut-wrap">
                <%
                    int total4 = availableUnits + inuseUnits + faultyUnits + retiredUnits;
                    if (total4 == 0) total4 = 1;
                    double r = 45; double cx2 = 65; double cy2 = 65;
                    double circumference = 2 * Math.PI * r;
                    double[] vals = { availableUnits, 0, faultyUnits, retiredUnits };
                    // hết hàng = totalPartTypes - available (simplified: 0 for now)
                    String[] colors = {"#10b981","#8b5cf6","#f59e0b","#ef4444"};
                    double offset = 0;
                    StringBuilder svgPaths = new StringBuilder();
                    for (int i = 0; i < vals.length; i++) {
                        double fraction = vals[i] / total4;
                        double dash = fraction * circumference;
                        svgPaths.append("<circle cx='").append(cx2).append("' cy='").append(cy2)
                            .append("' r='").append(r)
                            .append("' fill='none' stroke='").append(colors[i])
                            .append("' stroke-width='18' stroke-dasharray='")
                            .append(String.format("%.2f %.2f", dash, circumference - dash))
                            .append("' stroke-dashoffset='").append(String.format("%.2f", -offset))
                            .append("' transform='rotate(-90 ").append(cx2).append(" ").append(cy2).append(")'/>");
                        offset += dash;
                    }
                %>
                <svg class="donut-svg" viewBox="0 0 130 130">
                    <%= svgPaths.toString() %>
                </svg>
                <div class="donut-legend">
                    <div class="legend-item">
                        <span class="legend-dot" style="background:#10b981"></span>
                        Linh kiện có sẵn <span class="legend-count"><%= availableUnits %></span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-dot" style="background:#8b5cf6"></span>
                        Linh kiện hết hàng <span class="legend-count">0</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-dot" style="background:#f59e0b"></span>
                        Linh kiện sắp hết <span class="legend-count"><%= lowStock %></span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-dot" style="background:#ef4444"></span>
                        Linh kiện ngừng dùng <span class="legend-count"><%= retiredUnits %></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Equipment Summary -->
        <div class="card">
            <div class="card-header">
                <span class="card-title"><i class="fas fa-desktop" style="color:#6366f1;margin-right:6px"></i> Tình trạng thiết bị</span>
                <a href="<%= ctx %>/numberEquipment" class="view-more">Xem thêm →</a>
            </div>
            <div class="stat-grid" style="grid-template-columns:repeat(2,1fr);gap:10px;margin:0">
                <div class="stat-card success" style="padding:14px">
                    <div class="stat-label">Loại thiết bị</div>
                    <div class="stat-value" style="font-size:1.6rem"><%= totalEqTypes %></div>
                </div>
                <div class="stat-card info" style="padding:14px">
                    <div class="stat-label">Tổng units</div>
                    <div class="stat-value" style="font-size:1.6rem"><%= totalEqUnits %></div>
                </div>
                <div class="stat-card success" style="padding:14px">
                    <div class="stat-label">Sẵn sàng</div>
                    <div class="stat-value" style="font-size:1.6rem"><%= availableEq %></div>
                </div>
                <div class="stat-card danger" style="padding:14px">
                    <div class="stat-label">Đang dùng / Hỏng</div>
                    <div class="stat-value" style="font-size:1.6rem"><%= inuseEq %> / <%= faultyEq %></div>
                </div>
            </div>
        </div>
    </div>

    <!-- BOTTOM TABLES -->
    <div class="row-2">
        <!-- Low Stock -->
        <div class="card">
            <div class="card-header">
                <span class="card-title">Linh kiện sắp hết</span>
                <a href="<%= ctx %>/numberPart" class="view-more">Xem thêm →</a>
            </div>
            <% if (lowStockList.isEmpty()) { %>
                <p style="text-align:center;color:#94a3b8;padding:20px;font-size:0.85rem">Không có linh kiện sắp hết</p>
            <% } else { %>
            <table class="data-table">
                <thead><tr><th>Part ID</th><th>Tên linh kiện</th><th>Danh mục</th><th>Số lượng</th></tr></thead>
                <tbody>
                <% for (PartType pt : lowStockList) { %>
                <tr>
                    <td><%= pt.getId() %></td>
                    <td><%= pt.getName() %></td>
                    <td><%= pt.getCategoryName() %></td>
                    <td><span class="badge badge-low"><%= pt.getAvailableUnits() %></span></td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <% } %>
        </div>

        <!-- Most Used -->
        <div class="card">
            <div class="card-header">
                <span class="card-title">Những linh kiện được sử dụng nhiều</span>
                <a href="<%= ctx %>/numberPart" class="view-more">Xem thêm →</a>
            </div>
            <table class="data-table">
                <thead><tr><th>Part ID</th><th>Tên linh kiện</th><th>Danh mục</th><th>Đang dùng</th></tr></thead>
                <tbody>
                <% for (PartType pt : mostUsedList) { %>
                <tr>
                    <td><%= pt.getId() %></td>
                    <td><%= pt.getName() %></td>
                    <td><%= pt.getCategoryName() %></td>
                    <td><span class="badge badge-inuse"><%= pt.getInuseUnits() %></span></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</main>
</body>
</html>
