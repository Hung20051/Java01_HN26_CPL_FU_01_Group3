<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.EquipmentType, model.EquipmentUnit, model.Category, java.util.*, java.text.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<EquipmentType> equipments = (List<EquipmentType>) request.getAttribute("equipments");
    List<Category> categories      = (List<Category>) request.getAttribute("categories");
    EquipmentType detailEq         = (EquipmentType) request.getAttribute("detailEquipment");
    List<EquipmentUnit> units      = (List<EquipmentUnit>) request.getAttribute("units");
    String keyword    = request.getAttribute("keyword")    != null ? (String)request.getAttribute("keyword") : "";
    String categoryId = request.getAttribute("categoryId") != null ? (String)request.getAttribute("categoryId") : "";
    String sortBy     = request.getAttribute("sortBy")     != null ? (String)request.getAttribute("sortBy") : "";
    int currentPage   = request.getAttribute("currentPage") != null ? (int)request.getAttribute("currentPage") : 1;
    int totalPages    = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages") : 1;
    int total         = request.getAttribute("total")       != null ? (int)request.getAttribute("total") : 0;
    if (equipments == null) equipments = new ArrayList<>();
    if (categories == null) categories = new ArrayList<>();
    if (units      == null) units      = new ArrayList<>();

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
        <title>Equipment List - DRSMS System</title>
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
            .btn-search  {
                background: #3b82f6;
                color: white;
            }
            .btn-success {
                background: #10b981;
                color: white;
            }

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

            .expand-btn {
                background: none;
                border: none;
                cursor: pointer;
                color: #6366f1;
                font-size: 1rem;
                padding: 4px;
            }
            .action-btns {
                display: flex;
                gap: 6px;
            }
            .btn-edit   {
                background: #f59e0b;
                color: white;
                padding: 5px 10px;
                font-size: 0.78rem;
                border-radius: 6px;
                border: none;
                cursor: pointer;
            }
            .btn-delete {
                background: #ef4444;
                color: white;
                padding: 5px 10px;
                font-size: 0.78rem;
                border-radius: 6px;
                border: none;
                cursor: pointer;
            }
            .btn-add-unit {
                background: #0891b2;
                color: white;
                padding: 5px 10px;
                font-size: 0.78rem;
                border-radius: 6px;
                border: none;
                cursor: pointer;
            }

            /* Expand row for serial numbers */
            .expand-row {
                display: none;
            }
            .expand-row.show {
                display: table-row;
            }
            .expand-content {
                background: #f8fafc;
                padding: 12px 20px;
            }
            .serial-list {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                margin-top: 8px;
            }
            .serial-badge {
                padding: 4px 10px;
                border-radius: 6px;
                font-size: 0.78rem;
                font-weight: 500;
            }
            .s-available {
                background: #d1fae5;
                color: #065f46;
            }
            .s-inuse     {
                background: #dbeafe;
                color: #1e40af;
            }
            .s-faulty    {
                background: #fef3c7;
                color: #92400e;
            }
            .s-retired   {
                background: #f3f4f6;
                color: #6b7280;
            }

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
            .page-btn.disabled {
                opacity: 0.4;
                pointer-events: none;
            }
            .paging-info {
                color: #94a3b8;
                font-size: 0.82rem;
            }

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
            .form-group input, .form-group select {
                width: 100%;
                padding: 9px 12px;
                border: 1px solid #d1d5db;
                border-radius: 8px;
                font-size: 0.875rem;
                outline: none;
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
            .btn-save {
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
                <a href="<%= ctx %>/numberPart"       class="nav-item"><i class="fas fa-list-ul"></i> Parts List</a>
                <a href="<%= ctx %>/numberEquipment"  class="nav-item active"><i class="fas fa-desktop"></i> Equipment List</a>
                <a href="<%= ctx %>/transactions"     class="nav-item"><i class="fas fa-history"></i> Transaction History</a>
                
            </nav>
            <div class="sidebar-footer">
                <a href="<%= ctx %>/logout" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </aside>

        <main class="main">
            <div class="topbar">
                <div class="page-title">Equipment List</div>
                <div class="user-badge"><i class="fas fa-user-circle"></i> Hello, <%= currentUser.getUsername() %></div>
            </div>

            <% if (flashSuccess != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= flashSuccess %></div><% } %>
            <% if (flashError   != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= flashError %></div><% } %>

            <form method="get" action="<%= ctx %>/numberEquipment">
                <div class="toolbar">
                    <input class="search-box" type="text" name="keyword" placeholder="Enter search keyword..." value="<%= keyword != null ? keyword : "" %>">
                    <select class="select-box" name="categoryId" onchange="this.form.submit()">
                        <option value="">-- All Categories --</option>
                        <% for (Category cat : categories) { %>
                        <option value="<%= cat.getId() %>" <%= String.valueOf(cat.getId()).equals(categoryId) ? "selected" : "" %>><%= cat.getName() %></option>
                        <% } %>
                    </select>
                    <select class="select-box" name="sortBy" onchange="this.form.submit()">
                        <option value="">-- Default --</option>
                        <option value="name_asc"   <%= "name_asc".equals(sortBy)   ? "selected" : "" %>>Sort by Name ↑</option>
                        <option value="name_desc"  <%= "name_desc".equals(sortBy)  ? "selected" : "" %>>Sort by Name ↓</option>
                        <option value="price_asc"  <%= "price_asc".equals(sortBy)  ? "selected" : "" %>>Price ↑</option>
                        <option value="price_desc" <%= "price_desc".equals(sortBy) ? "selected" : "" %>>Price ↓</option>
                    </select>
                    <button type="submit" class="btn btn-search"><i class="fas fa-search"></i> Apply</button>
                    <button type="button" onclick="this.form.reset();location.href = '<%= ctx %>/numberEquipment'" class="btn" style="background:#94a3b8;color:white"><i class="fas fa-undo"></i> Reset</button>
                    <button type="button" class="btn btn-success" onclick="openCreateModal()"><i class="fas fa-plus"></i> New</button>
                </div>
            </form>

            <div class="card">
                <table>
                    <thead>
                        <tr>
                            <th style="width:40px"></th>
                            <th>Model</th><th>Category</th><th>Description</th>
                            <th>Unit Price</th><th>Units</th><th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (equipments.isEmpty()) { %>
                        <tr><td colspan="7" style="text-align:center;color:#94a3b8;padding:30px">No equipment found</td></tr>
                        <% } else { for (EquipmentType et : equipments) { %>
                        <tr>
                            <td><button class="expand-btn" onclick="toggleRow(<%= et.getId() %>)"><i class="fas fa-chevron-right" id="icon-<%= et.getId() %>"></i></button></td>
                            <td><strong><%= et.getModel() %></strong></td>
                            <td><%= et.getCategoryName() %></td>
                            <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><%= et.getDescription() != null ? et.getDescription() : "" %></td>
                            <td><%= nf.format((long)et.getUnitPrice()) %> ₫</td>
                            <td>
                                <span style="color:#10b981;font-weight:600"><%= et.getAvailableUnits() %></span>/<%= et.getTotalUnits() %>
                                <span style="font-size:0.75rem;color:#94a3b8"> available/total</span>
                            </td>
                            <td>
                                <div class="action-btns">
                                    <button class="btn-add-unit" onclick="openAddUnitModal(<%= et.getId() %>, '<%= et.getModel().replace("'","\\'") %>')">
                                        <i class="fas fa-plus"></i> Stock In
                                    </button>
                                    <button class="btn-edit" onclick="openEditModal(<%= et.getId() %>, '<%= et.getModel().replace("'","\\'") %>',<%= et.getCategoryId() %>, '<%= et.getDescription()!=null?et.getDescription().replace("'","\\'"):"" %>',<%= et.getUnitPrice() %>)">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                    <button class="btn-delete" onclick="confirmDelete(<%= et.getId() %>, '<%= et.getModel().replace("'","\\'") %>')">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <!-- Expand Row for Serial Numbers -->
                        <tr class="expand-row" id="expand-<%= et.getId() %>">
                            <td colspan="7">
                                <div class="expand-content">
                                    <strong style="font-size:0.82rem;color:#64748b">Serial Numbers:</strong>
                                    <div class="serial-list">
                                        <%
                                            if (detailEq != null && detailEq.getId() == et.getId()) {
                                                for (EquipmentUnit eu : units) {
                                        %>
                                        <span class="serial-badge s-<%= eu.getStatus().toLowerCase() %>"><%= eu.getSerialNumber() %> (<%= eu.getStatus() %>)</span>
                                        <%      }
                                            }
                                        %>
                                    </div>
                                    <a href="<%= ctx %>/numberEquipment?action=detail&id=<%= et.getId() %>" style="font-size:0.8rem;color:#6366f1;margin-top:6px;display:inline-block">
                                        View details →
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>

                <div class="pagination">
                    <span class="paging-info">Page <%= currentPage %> / <%= totalPages %> (Total <%= total %> models)</span>
                    &nbsp;
                    <a href="<%= ctx %>/numberEquipment?page=1&keyword=<%= keyword %>&categoryId=<%= categoryId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==1?"disabled":"" %>">«</a>
                    <a href="<%= ctx %>/numberEquipment?page=<%= Math.max(1,currentPage-1) %>&keyword=<%= keyword %>&categoryId=<%= categoryId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==1?"disabled":"" %>">‹</a>
                    <% for (int p=Math.max(1,currentPage-2); p<=Math.min(totalPages,currentPage+2); p++) { %>
                    <a href="<%= ctx %>/numberEquipment?page=<%= p %>&keyword=<%= keyword %>&categoryId=<%= categoryId %>&sortBy=<%= sortBy %>" class="page-btn <%= p==currentPage?"active":"" %>"><%= p %></a>
                    <% } %>
                    <a href="<%= ctx %>/numberEquipment?page=<%= Math.min(totalPages,currentPage+1) %>&keyword=<%= keyword %>&categoryId=<%= categoryId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==totalPages?"disabled":"" %>">›</a>
                    <a href="<%= ctx %>/numberEquipment?page=<%= totalPages %>&keyword=<%= keyword %>&categoryId=<%= categoryId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==totalPages?"disabled":"" %>">»</a>
                </div>
            </div>
        </main>

        <!-- CREATE MODAL -->
        <div class="modal-overlay" id="createModal">
            <div class="modal">
                <h3>New Equipment</h3>
                <form method="post" action="<%= ctx %>/numberEquipment">
                    <input type="hidden" name="action" value="create">
                    <div class="form-group">
                        <label>Model Name * (Minimum 3 characters)</label>
                        <input type="text" name="model" required minlength="3">
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
                        <label>Description</label>
                        <input type="text" name="description" maxlength="255">
                    </div>
                    <div class="form-group">
                        <label>Unit Price *</label>
                        <input type="number" name="unitPrice" required min="0" step="1000" value="0">
                    </div>
                    <div class="form-group">
                        <label>Serial Number * (first unit)</label>
                        <input type="text" name="serialNumber" required placeholder="e.g. DAI-VRV4-003">
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
                <h3>Edit Equipment</h3>
                <form method="post" action="<%= ctx %>/numberEquipment">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="id" id="editId">
                    <div class="form-group">
                        <label>Model Name *</label>
                        <input type="text" name="model" id="editModel" required minlength="3">
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
                        <label>Description</label>
                        <input type="text" name="description" id="editDesc">
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

        <!-- ADD UNIT MODAL -->
        <div class="modal-overlay" id="addUnitModal">
            <div class="modal">
                <h3>Stock In Equipment</h3>
                <p id="addUnitModelName" style="text-align:center;color:#64748b;margin-bottom:16px;font-size:0.9rem"></p>
                <form method="post" action="<%= ctx %>/numberEquipment">
                    <input type="hidden" name="action" value="addUnit">
                    <input type="hidden" name="equipmentTypeId" id="addUnitTypeId">
                    <div class="form-group">
                        <label>Serial Number *</label>
                        <input type="text" name="serialNumber" required placeholder="e.g. DAI-VRV4-004">
                    </div>
                    <div class="modal-btns">
                        <button type="submit" class="btn-save"><i class="fas fa-plus"></i> Stock In</button>
                        <button type="button" class="btn-cancel" onclick="closeModal('addUnitModal')">✕ Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- DELETE MODAL -->
        <div class="modal-overlay" id="deleteModal">
            <div class="modal" style="text-align:center">
                <div style="font-size:3rem;color:#ef4444;margin-bottom:12px">⚠</div>
                <h3>Confirm Delete</h3>
                <p style="color:#64748b;margin:10px 0 20px">Are you sure you want to delete:<br><strong id="deleteEqName"></strong>?</p>
                <form method="post" action="<%= ctx %>/numberEquipment">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteId">
                    <div class="modal-btns">
                        <button type="submit" style="background:#ef4444;color:white;flex:1;padding:10px;border-radius:8px;border:none;cursor:pointer;font-weight:600">✓ Confirm</button>
                        <button type="button" onclick="closeModal('deleteModal')" style="background:#94a3b8;color:white;flex:1;padding:10px;border-radius:8px;border:none;cursor:pointer;font-weight:600">✕ Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function toggleRow(id) {
                var row = document.getElementById('expand-' + id);
                var icon = document.getElementById('icon-' + id);
                if (row.classList.contains('show')) {
                    row.classList.remove('show');
                    icon.style.transform = '';
                } else {
                    row.classList.add('show');
                    icon.style.transform = 'rotate(90deg)';
                }
            }
            function openCreateModal() {
                document.getElementById('createModal').classList.add('show');
            }
            function openEditModal(id, model, catId, desc, price) {
                document.getElementById('editId').value = id;
                document.getElementById('editModel').value = model;
                document.getElementById('editCategoryId').value = catId;
                document.getElementById('editDesc').value = desc;
                document.getElementById('editPrice').value = price;
                document.getElementById('editModal').classList.add('show');
            }
            function openAddUnitModal(typeId, model) {
                document.getElementById('addUnitTypeId').value = typeId;
                document.getElementById('addUnitModelName').textContent = 'Model: ' + model;
                document.getElementById('addUnitModal').classList.add('show');
            }
            function confirmDelete(id, name) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteEqName').textContent = name;
                document.getElementById('deleteModal').classList.add('show');
            }
            function closeModal(id) {
                document.getElementById(id).classList.remove('show');
            }
            window.addEventListener('click', function (e) {
                ['createModal', 'editModal', 'addUnitModal', 'deleteModal'].forEach(function (id) {
                    var m = document.getElementById(id);
                    if (e.target === m)
                        m.classList.remove('show');
                });
            });
        </script>
    </body>
</html>
