<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.PartType, model.PartUnit, model.Category, java.util.*, java.text.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<PartType> parts    = (List<PartType>) request.getAttribute("parts");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    PartType detailPart     = (PartType) request.getAttribute("detailPart");
    List<PartUnit> units    = (List<PartUnit>) request.getAttribute("units");
    String keyword    = request.getAttribute("keyword")    != null ? (String)request.getAttribute("keyword") : "";
    String categoryId = request.getAttribute("categoryId") != null ? (String)request.getAttribute("categoryId") : "";
    String sortBy     = request.getAttribute("sortBy")     != null ? (String)request.getAttribute("sortBy") : "";
    int currentPage   = request.getAttribute("currentPage") != null ? (int)request.getAttribute("currentPage") : 1;
    int totalPages    = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages") : 1;
    int total         = request.getAttribute("total")       != null ? (int)request.getAttribute("total") : 0;
    if (parts == null) parts = new ArrayList<>();
    if (categories == null) categories = new ArrayList<>();

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    String flashError   = (String) session.getAttribute("flashError");
    session.removeAttribute("flashSuccess");
    session.removeAttribute("flashError");

    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Parts List - DRSMS System</title>
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
            .sidebar {
                width: 200px;
                min-height: 100vh;
                background: #1a1a2e;
                display: flex;
                flex-direction: column;
                position: fixed;
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

            /* DETAIL PANEL */
            .detail-panel {
                background: #f0f7ff;
                border: 1px solid #bfdbfe;
                border-radius: 10px;
                padding: 16px 20px;
                margin-bottom: 20px;
            }
            .detail-title {
                font-size: 0.95rem;
                font-weight: 600;
                color: #1e40af;
                margin-bottom: 12px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .detail-stats {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 10px;
            }
            .detail-stat {
                background: white;
                border-radius: 8px;
                padding: 12px;
                border-left: 3px solid #e2e8f0;
            }
            .detail-stat.av  {
                border-left-color: #10b981;
            }
            .detail-stat.fa  {
                border-left-color: #f59e0b;
            }
            .detail-stat.iu  {
                border-left-color: #6366f1;
            }
            .detail-stat.rt  {
                border-left-color: #94a3b8;
            }
            .detail-stat-label {
                font-size: 0.7rem;
                color: #64748b;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .detail-stat-value {
                font-size: 1.8rem;
                font-weight: 700;
                margin-top: 4px;
            }
            .detail-close {
                float: right;
                background: #ef4444;
                color: white;
                border: none;
                padding: 5px 12px;
                border-radius: 6px;
                cursor: pointer;
                font-size: 0.8rem;
            }

            /* TOOLBAR */
            .toolbar {
                display: flex;
                gap: 10px;
                align-items: center;
                margin-bottom: 16px;
                flex-wrap: wrap;
            }
            .search-box {
                flex: 1;
                min-width: 200px;
                padding: 8px 14px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                font-size: 0.875rem;
                outline: none;
            }
            .search-box:focus {
                border-color: #6366f1;
            }
            .select-box {
                padding: 8px 12px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                font-size: 0.875rem;
                outline: none;
                background: white;
            }
            .btn {
                padding: 8px 16px;
                border-radius: 8px;
                font-size: 0.875rem;
                font-weight: 500;
                border: none;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 6px;
                text-decoration: none;
            }
            .btn-primary {
                background: #6366f1;
                color: white;
            }
            .btn-primary:hover {
                background: #4f46e5;
            }
            .btn-search  {
                background: #3b82f6;
                color: white;
            }
            .btn-search:hover {
                background: #2563eb;
            }
            .btn-success {
                background: #10b981;
                color: white;
            }
            .btn-success:hover {
                background: #059669;
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
                font-size: 0.85rem;
            }
            thead tr {
                background: #f8fafc;
            }
            th {
                padding: 12px 14px;
                text-align: left;
                color: #64748b;
                font-weight: 600;
                font-size: 0.8rem;
                text-transform: uppercase;
                letter-spacing: 0.4px;
                border-bottom: 1px solid #e2e8f0;
            }
            td {
                padding: 12px 14px;
                border-bottom: 1px solid #f1f5f9;
                color: #374151;
            }
            tr:last-child td {
                border-bottom: none;
            }
            tr:hover td {
                background: #fafbff;
            }
            .link-username {
                color: #6366f1;
                text-decoration: none;
                font-weight: 500;
            }

            .action-btns {
                display: flex;
                gap: 6px;
            }
            .btn-detail  {
                background: #0891b2;
                color: white;
                padding: 5px 10px;
                font-size: 0.78rem;
            }
            .btn-edit    {
                background: #f59e0b;
                color: white;
                padding: 5px 10px;
                font-size: 0.78rem;
            }
            .btn-delete  {
                background: #ef4444;
                color: white;
                padding: 5px 10px;
                font-size: 0.78rem;
            }
            .btn-detail:hover {
                background: #0e7490;
            }
            .btn-edit:hover   {
                background: #d97706;
            }
            .btn-delete:hover {
                background: #dc2626;
            }

            /* PAGINATION */
            .pagination {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 6px;
                padding: 16px;
            }
            .page-btn {
                padding: 6px 12px;
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
            .page-btn:hover:not(.active) {
                background: #f1f5f9;
            }
            .page-btn.disabled {
                opacity: 0.4;
                pointer-events: none;
            }

            /* MODAL */
            .modal-overlay {
                display: none;
                position: fixed;
                inset: 0;
                background: rgba(0,0,0,0.5);
                z-index: 1000;
                align-items: center;
                justify-content: center;
            }
            .modal-overlay.show {
                display: flex;
            }
            .modal {
                background: white;
                border-radius: 12px;
                padding: 28px;
                width: 460px;
                max-width: 95vw;
                box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            }
            .modal h3 {
                font-size: 1.1rem;
                font-weight: 700;
                margin-bottom: 20px;
                color: #1e293b;
                text-align: center;
            }
            .form-group {
                margin-bottom: 14px;
            }
            .form-group label {
                display: block;
                font-size: 0.82rem;
                font-weight: 600;
                color: #374151;
                margin-bottom: 5px;
            }
            .form-group input, .form-group select, .form-group textarea {
                width: 100%;
                padding: 9px 12px;
                border: 1px solid #d1d5db;
                border-radius: 8px;
                font-size: 0.875rem;
                outline: none;
                font-family: inherit;
            }
            .form-group input:focus, .form-group select:focus {
                border-color: #6366f1;
            }
            .modal-btns {
                display: flex;
                gap: 10px;
                margin-top: 20px;
            }
            .modal-btns button {
                flex: 1;
                padding: 10px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                font-size: 0.9rem;
                font-weight: 600;
            }
            .btn-save   {
                background: #10b981;
                color: white;
            }
            .btn-cancel {
                background: #94a3b8;
                color: white;
            }
            .alert {
                padding: 10px 14px;
                border-radius: 8px;
                margin-bottom: 16px;
                font-size: 0.875rem;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .alert-success {
                background: #d1fae5;
                color: #065f46;
                border: 1px solid #a7f3d0;
            }
            .alert-error   {
                background: #fee2e2;
                color: #991b1b;
                border: 1px solid #fca5a5;
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
                <a href="<%= ctx %>/numberPart"       class="nav-item active"><i class="fas fa-list-ul"></i> Parts List</a>
                <a href="<%= ctx %>/numberEquipment"  class="nav-item"><i class="fas fa-desktop"></i> Equipment List</a>
                <a href="<%= ctx %>/transactions"     class="nav-item"><i class="fas fa-history"></i> Transaction History</a>
                
            </nav>
            <div class="sidebar-footer">
                <a href="<%= ctx %>/logout" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </aside>

        <main class="main">
            <div class="topbar">
                <div class="page-title">Parts List</div>
                <div class="user-badge"><i class="fas fa-user-circle"></i> Hello, <%= currentUser.getUsername() %></div>
            </div>

            <% if (flashSuccess != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= flashSuccess %></div><% } %>
            <% if (flashError   != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= flashError %></div><% } %>

            <!-- DETAIL PANEL -->
            <% if (detailPart != null) { %>
            <div class="detail-panel">
                <div class="detail-title">
                    <i class="fas fa-chart-pie"></i> Status Detail: <%= detailPart.getName() %>
                    <button class="detail-close" onclick="location.href = '<%= ctx %>/numberPart'">✕ Close</button>
                </div>
                <div class="detail-stats">
                    <div class="detail-stat av">
                        <div class="detail-stat-label">✓ AVAILABLE</div>
                        <div class="detail-stat-value" style="color:#10b981"><%= detailPart.getAvailableUnits() %></div>
                    </div>
                    <div class="detail-stat fa">
                        <div class="detail-stat-label">⚠ FAULTY</div>
                        <div class="detail-stat-value" style="color:#f59e0b"><%= detailPart.getFaultyUnits() %></div>
                    </div>
                    <div class="detail-stat iu">
                        <div class="detail-stat-label">✕ IN USE</div>
                        <div class="detail-stat-value" style="color:#6366f1"><%= detailPart.getInuseUnits() %></div>
                    </div>
                    <div class="detail-stat rt">
                        <div class="detail-stat-label">▣ RETIRED</div>
                        <div class="detail-stat-value" style="color:#94a3b8"><%= detailPart.getRetiredUnits() %></div>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- TOOLBAR -->
            <form method="get" action="<%= ctx %>/numberPart">
                <div class="toolbar">
                    <input class="search-box" type="text" name="keyword" placeholder="Enter keyword..." value="<%= keyword != null ? keyword : "" %>">
                    <button type="submit" class="btn btn-search"><i class="fas fa-search"></i> Search</button>
                    <select class="select-box" name="categoryId" onchange="this.form.submit()">
                        <option value="">-- All Categories --</option>
                        <% for (Category cat : categories) { %>
                        <option value="<%= cat.getId() %>" <%= String.valueOf(cat.getId()).equals(categoryId) ? "selected" : "" %>><%= cat.getName() %></option>
                        <% } %>
                    </select>
                    <select class="select-box" name="sortBy" onchange="this.form.submit()">
                        <option value="">-- Sort by --</option>
                        <option value="name_asc"   <%= "name_asc".equals(sortBy)   ? "selected" : "" %>>Name A-Z</option>
                        <option value="name_desc"  <%= "name_desc".equals(sortBy)  ? "selected" : "" %>>Name Z-A</option>
                        <option value="price_asc"  <%= "price_asc".equals(sortBy)  ? "selected" : "" %>>Price ↑</option>
                        <option value="price_desc" <%= "price_desc".equals(sortBy) ? "selected" : "" %>>Price ↓</option>
                    </select>
                    <button type="button" class="btn btn-success" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> New Part
                    </button>
                </div>
            </form>

            <!-- TABLE -->
            <div class="card">
                <table>
                    <thead>
                        <tr>
                            <th>Part ID</th><th>Part Name</th><th>Category</th>
                            <th>Description</th><th>Unit Price</th>
                            <th>Last Updated By</th><th>Last Update Time</th><th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (parts.isEmpty()) { %>
                        <tr><td colspan="8" style="text-align:center;color:#94a3b8;padding:30px">No parts found</td></tr>
                        <% } else { for (PartType pt : parts) { %>
                        <tr>
                            <td><%= pt.getId() %></td>
                            <td><strong><%= pt.getName() %></strong></td>
                            <td><%= pt.getCategoryName() %></td>
                            <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><%= pt.getDescription() != null ? pt.getDescription() : "" %></td>
                            <td><%= nf.format((long)pt.getUnitPrice()) %> ₫</td>
                            <td><a href="#" class="link-username"><%= pt.getUpdatedByUsername() != null ? pt.getUpdatedByUsername() : "-" %></a></td>
                            <td><%= pt.getUpdatedAt() != null ? pt.getUpdatedAt().toLocalDate().toString() : "-" %></td>
                            <td>
                                <div class="action-btns">
                                    <a href="<%= ctx %>/numberPart?action=detail&id=<%= pt.getId() %>" class="btn btn-detail"><i class="fas fa-info-circle"></i> Detail</a>
                                    <button class="btn btn-edit" onclick="openEditModal(<%= pt.getId() %>, '<%= pt.getName().replace("'","\\'") %>',<%= pt.getCategoryId() %>, '<%= pt.getDescription() != null ? pt.getDescription().replace("'","\\'") : "" %>',<%= pt.getUnitPrice() %>)">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                    <button class="btn btn-delete" onclick="confirmDelete(<%= pt.getId() %>, '<%= pt.getName().replace("'","\\'") %>')">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>

                <!-- PAGINATION -->
                <div class="pagination">
                    <a href="<%= ctx %>/numberPart?page=1&keyword=<%= keyword %>&categoryId=<%= categoryId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==1 ? "disabled" : "" %>">« First</a>
                    <a href="<%= ctx %>/numberPart?page=<%= Math.max(1,currentPage-1) %>&keyword=<%= keyword %>&categoryId=<%= categoryId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==1 ? "disabled" : "" %>">‹ Prev</a>
                    <% for (int p = Math.max(1, currentPage-2); p <= Math.min(totalPages, currentPage+2); p++) { %>
                    <a href="<%= ctx %>/numberPart?page=<%= p %>&keyword=<%= keyword %>&categoryId=<%= categoryId %>&sortBy=<%= sortBy %>" class="page-btn <%= p==currentPage ? "active" : "" %>"><%= p %></a>
                    <% } %>
                    <a href="<%= ctx %>/numberPart?page=<%= Math.min(totalPages,currentPage+1) %>&keyword=<%= keyword %>&categoryId=<%= categoryId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==totalPages ? "disabled" : "" %>">Next ›</a>
                    <a href="<%= ctx %>/numberPart?page=<%= totalPages %>&keyword=<%= keyword %>&categoryId=<%= categoryId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==totalPages ? "disabled" : "" %>">Last »</a>
                </div>
            </div>
        </main>

        <!-- CREATE MODAL -->
        <div class="modal-overlay" id="createModal">
            <div class="modal">
                <h3>New Part</h3>
                <form method="post" action="<%= ctx %>/numberPart">
                    <input type="hidden" name="action" value="create">
                    <div class="form-group">
                        <label>Part Name * (Minimum 3 characters)</label>
                        <input type="text" name="name" required minlength="3">
                    </div>
                    <div class="form-group">
                        <label>Category</label>
                        <select name="categoryId">
                            <% for (Category cat : categories) { %>
                            <option value="<%= cat.getId() %>"><%= cat.getName() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Description * (10-100 characters)</label>
                        <input type="text" name="description" required minlength="10" maxlength="100">
                    </div>
                    <div class="form-group">
                        <label>Unit Price *</label>
                        <input type="number" name="unitPrice" required min="0" step="1000" value="0">
                    </div>
                    <div class="form-group">
                        <label>Stock Quantity (1-100)</label>
                        <input type="number" name="quantity" required min="1" max="100" value="1">
                    </div>
                    <div class="modal-btns">
                        <button type="submit" class="btn-save"><i class="fas fa-save"></i> Save</button>
                        <button type="button" class="btn-cancel" onclick="closeModal('createModal')">✕ Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- EDIT MODAL -->
        <div class="modal-overlay" id="editModal">
            <div class="modal">
                <h3>Edit Part</h3>
                <form method="post" action="<%= ctx %>/numberPart">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="id" id="editId">
                    <div class="form-group">
                        <label>Part Name * (Minimum 3 characters)</label>
                        <input type="text" name="name" id="editName" required minlength="3">
                    </div>
                    <div class="form-group">
                        <label>Category</label>
                        <select name="categoryId" id="editCategoryId">
                            <% for (Category cat : categories) { %>
                            <option value="<%= cat.getId() %>"><%= cat.getName() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Description * (10-100 characters)</label>
                        <input type="text" name="description" id="editDesc" required minlength="10" maxlength="100">
                    </div>
                    <div class="form-group">
                        <label>Unit Price *</label>
                        <input type="number" name="unitPrice" id="editPrice" required min="0" step="1000">
                    </div>
                    <div class="modal-btns">
                        <button type="submit" class="btn-save"><i class="fas fa-save"></i> Save</button>
                        <button type="button" class="btn-cancel" onclick="closeModal('editModal')">✕ Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- DELETE MODAL -->
        <div class="modal-overlay" id="deleteModal">
            <div class="modal" style="text-align:center">
                <div style="font-size:3rem;color:#ef4444;margin-bottom:12px">⚠</div>
                <h3>Confirm Delete</h3>
                <p style="color:#64748b;margin:10px 0 20px">Are you sure you want to delete Part:<br><strong id="deletePartName"></strong> (ID: <span id="deletePartId"></span>)?</p>
                <form method="post" action="<%= ctx %>/numberPart">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteId">
                    <div class="modal-btns">
                        <button type="submit" style="background:#ef4444;color:white;flex:1;padding:10px;border-radius:8px;border:none;cursor:pointer;font-weight:600">✓ Confirm</button>
                        <button type="button" class="btn-cancel" onclick="closeModal('deleteModal')" style="flex:1;padding:10px;border-radius:8px;border:none;cursor:pointer;font-weight:600">✕ Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function openCreateModal() {
                document.getElementById('createModal').classList.add('show');
            }
            function openEditModal(id, name, catId, desc, price) {
                document.getElementById('editId').value = id;
                document.getElementById('editName').value = name;
                document.getElementById('editCategoryId').value = catId;
                document.getElementById('editDesc').value = desc;
                document.getElementById('editPrice').value = price;
                document.getElementById('editModal').classList.add('show');
            }
            function confirmDelete(id, name) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deletePartId').textContent = id;
                document.getElementById('deletePartName').textContent = name;
                document.getElementById('deleteModal').classList.add('show');
            }
            function closeModal(id) {
                document.getElementById(id).classList.remove('show');
            }
            window.addEventListener('click', function (e) {
                ['createModal', 'editModal', 'deleteModal'].forEach(function (id) {
                    var m = document.getElementById(id);
                    if (e.target === m)
                        m.classList.remove('show');
                });
            });
        </script>
    </body>
</html>
