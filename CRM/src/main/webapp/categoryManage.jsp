<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Category, java.util.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    if (categories == null) categories = new ArrayList<>();

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    String flashError   = (String) session.getAttribute("flashError");
    session.removeAttribute("flashSuccess");
    session.removeAttribute("flashError");

    String ctx = request.getContextPath();

    // Group by type
    List<Category> partCats  = new ArrayList<>();
    List<Category> eqCats    = new ArrayList<>();
    List<Category> bothCats  = new ArrayList<>();
    for (Category c : categories) {
        if ("PART".equals(c.getType()))      partCats.add(c);
        else if ("EQUIPMENT".equals(c.getType())) eqCats.add(c);
        else bothCats.add(c);
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Category Management - DRSMS System</title>
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

            /* LAYOUT: 3 columns */
            .cat-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 20px;
            }

            .cat-section {
                background: white;
                border-radius: 12px;
                border: 1px solid #e2e8f0;
                overflow: hidden;
                box-shadow: 0 1px 3px rgba(0,0,0,0.06);
            }
            .cat-header {
                padding: 14px 18px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-bottom: 1px solid #f1f5f9;
            }
            .cat-header-title {
                display: flex;
                align-items: center;
                gap: 8px;
                font-weight: 700;
                font-size: 0.95rem;
                color: #1e293b;
            }
            .cat-header-icon {
                width: 32px;
                height: 32px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 0.9rem;
            }
            .icon-part {
                background: #ede9fe;
                color: #7c3aed;
            }
            .icon-equip{
                background: #fce7f3;
                color: #be185d;
            }
            .icon-both {
                background: #d1fae5;
                color: #065f46;
            }
            .cnt-badge {
                background: #f1f5f9;
                color: #64748b;
                font-size: 0.75rem;
                font-weight: 600;
                padding: 2px 8px;
                border-radius: 10px;
            }

            .cat-body {
                padding: 6px 0;
                min-height: 100px;
            }
            .cat-item {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 9px 18px;
                border-bottom: 1px solid #f8fafc;
                transition: background 0.15s;
            }
            .cat-item:last-child {
                border-bottom: none;
            }
            .cat-item:hover {
                background: #fafbff;
            }
            .cat-item-name {
                font-size: 0.875rem;
                color: #374151;
                font-weight: 500;
            }
            .cat-item-id {
                font-size: 0.75rem;
                color: #94a3b8;
                margin-left: 6px;
            }
            .item-actions {
                display: flex;
                gap: 6px;
            }
            .btn-edit-sm   {
                background: #fef3c7;
                color: #92400e;
                border: none;
                cursor: pointer;
                padding: 4px 10px;
                border-radius: 6px;
                font-size: 0.76rem;
                font-weight: 600;
            }
            .btn-edit-sm:hover {
                background: #fde68a;
            }
            .btn-delete-sm {
                background: #fee2e2;
                color: #991b1b;
                border: none;
                cursor: pointer;
                padding: 4px 10px;
                border-radius: 6px;
                font-size: 0.76rem;
                font-weight: 600;
            }
            .btn-delete-sm:hover {
                background: #fca5a5;
            }

            .cat-footer {
                padding: 10px 18px;
                border-top: 1px solid #f1f5f9;
            }
            .btn-add-cat {
                width: 100%;
                padding: 8px;
                background: #f8fafc;
                border: 1px dashed #cbd5e1;
                border-radius: 8px;
                color: #64748b;
                font-size: 0.84rem;
                cursor: pointer;
                font-weight: 500;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                transition: all 0.15s;
            }
            .btn-add-cat:hover {
                background: #f1f5f9;
                border-color: #6366f1;
                color: #6366f1;
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
                border-radius: 14px;
                padding: 28px;
                width: 420px;
                max-width: 95vw;
                box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            }
            .modal h3 {
                font-size: 1.05rem;
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
            .btn-save   {
                background: #10b981;
                color: white;
            }
            .btn-cancel {
                background: #94a3b8;
                color: white;
            }
            .btn-danger {
                background: #ef4444;
                color: white;
            }

            .empty-cat {
                padding: 20px;
                text-align: center;
                color: #cbd5e1;
                font-size: 0.85rem;
            }
        </style>
    </head>
    <body>
        <aside class="sidebar">
            <div class="sidebar-brand"><i class="fas fa-warehouse"></i> DRSMS System</div>
            <nav class="sidebar-nav">
                <a href="<%= ctx %>/dashboard.jsp"      class="nav-item"><i class="fas fa-home"></i> Home</a>
                <a href="<%= ctx %>/profile.jsp"      class="nav-item"><i class="fas fa-user-circle"></i> Profile</a>
                <a href="<%= ctx %>/storekeeper"      class="nav-item"><i class="fas fa-chart-bar"></i> Statistics</a>
                <a href="<%= ctx %>/numberPart"       class="nav-item"><i class="fas fa-list-ul"></i> Parts List</a>
                <a href="<%= ctx %>/numberEquipment"  class="nav-item"><i class="fas fa-desktop"></i> Equipment List</a>
                <a href="<%= ctx %>/transactions"     class="nav-item"><i class="fas fa-history"></i> Transaction History</a>
                <a href="<%= ctx %>/categoryManage"   class="nav-item active"><i class="fas fa-tags"></i> Category Management</a>
            </nav>
            <div class="sidebar-footer">
                <a href="<%= ctx %>/logout" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </aside>

        <main class="main">
            <div class="topbar">
                <div class="page-title">
                    <i class="fas fa-tags"></i>
                    <h1>Category Management</h1>
                </div>
                <div class="user-badge"><i class="fas fa-user-circle"></i> Hello <%= currentUser.getUsername() %></div>
            </div>

            <% if (flashSuccess != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= flashSuccess %></div><% } %>
            <% if (flashError   != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= flashError %></div><% } %>

            <div class="cat-grid">

                <!-- PARTS (PART) -->
                <div class="cat-section">
                    <div class="cat-header">
                        <div class="cat-header-title">
                            <div class="cat-header-icon icon-part"><i class="fas fa-puzzle-piece"></i></div>
                            Parts Categories
                        </div>
                        <span class="cnt-badge"><%= partCats.size() %></span>
                    </div>
                    <div class="cat-body">
                        <% if (partCats.isEmpty()) { %>
                        <div class="empty-cat">No categories yet</div>
                        <% } else { for (Category cat : partCats) { %>
                        <div class="cat-item">
                            <span><span class="cat-item-name"><%= cat.getName() %></span><span class="cat-item-id">#<%= cat.getId() %></span></span>
                            <div class="item-actions">
                                <button class="btn-edit-sm" onclick="openEdit(<%= cat.getId() %>, '<%= cat.getName().replace("'","\\'") %>', '<%= cat.getType() %>')">
                                    <i class="fas fa-edit"></i> Edit
                                </button>
                                <button class="btn-delete-sm" onclick="openDelete(<%= cat.getId() %>, '<%= cat.getName().replace("'","\\'") %>')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                        <% } } %>
                    </div>
                    <div class="cat-footer">
                        <button class="btn-add-cat" onclick="openCreate('PART')">
                            <i class="fas fa-plus"></i> Add Parts Category
                        </button>
                    </div>
                </div>

                <!-- EQUIPMENT -->
                <div class="cat-section">
                    <div class="cat-header">
                        <div class="cat-header-title">
                            <div class="cat-header-icon icon-equip"><i class="fas fa-desktop"></i></div>
                            Equipment Categories
                        </div>
                        <span class="cnt-badge"><%= eqCats.size() %></span>
                    </div>
                    <div class="cat-body">
                        <% if (eqCats.isEmpty()) { %>
                        <div class="empty-cat">No categories yet</div>
                        <% } else { for (Category cat : eqCats) { %>
                        <div class="cat-item">
                            <span><span class="cat-item-name"><%= cat.getName() %></span><span class="cat-item-id">#<%= cat.getId() %></span></span>
                            <div class="item-actions">
                                <button class="btn-edit-sm" onclick="openEdit(<%= cat.getId() %>, '<%= cat.getName().replace("'","\\'") %>', '<%= cat.getType() %>')">
                                    <i class="fas fa-edit"></i> Edit
                                </button>
                                <button class="btn-delete-sm" onclick="openDelete(<%= cat.getId() %>, '<%= cat.getName().replace("'","\\'") %>')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                        <% } } %>
                    </div>
                    <div class="cat-footer">
                        <button class="btn-add-cat" onclick="openCreate('EQUIPMENT')">
                            <i class="fas fa-plus"></i> Add Equipment Category
                        </button>
                    </div>
                </div>

                <!-- SHARED (BOTH) -->
                <div class="cat-section">
                    <div class="cat-header">
                        <div class="cat-header-title">
                            <div class="cat-header-icon icon-both"><i class="fas fa-layer-group"></i></div>
                            Shared
                        </div>
                        <span class="cnt-badge"><%= bothCats.size() %></span>
                    </div>
                    <div class="cat-body">
                        <% if (bothCats.isEmpty()) { %>
                        <div class="empty-cat">No categories yet</div>
                        <% } else { for (Category cat : bothCats) { %>
                        <div class="cat-item">
                            <span><span class="cat-item-name"><%= cat.getName() %></span><span class="cat-item-id">#<%= cat.getId() %></span></span>
                            <div class="item-actions">
                                <button class="btn-edit-sm" onclick="openEdit(<%= cat.getId() %>, '<%= cat.getName().replace("'","\\'") %>', '<%= cat.getType() %>')">
                                    <i class="fas fa-edit"></i> Edit
                                </button>
                                <button class="btn-delete-sm" onclick="openDelete(<%= cat.getId() %>, '<%= cat.getName().replace("'","\\'") %>')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                        <% } } %>
                    </div>
                    <div class="cat-footer">
                        <button class="btn-add-cat" onclick="openCreate('BOTH')">
                            <i class="fas fa-plus"></i> Add Shared Category
                        </button>
                    </div>
                </div>

            </div>
        </main>

        <!-- CREATE MODAL -->
        <div class="modal-overlay" id="createModal">
            <div class="modal">
                <h3><i class="fas fa-plus-circle" style="color:#10b981;margin-right:6px"></i> Add New Category</h3>
                <form method="post" action="<%= ctx %>/categoryManage">
                    <input type="hidden" name="action" value="create">
                    <div class="form-group">
                        <label>Category Name *</label>
                        <input type="text" name="name" required placeholder="Enter category name...">
                    </div>
                    <div class="form-group">
                        <label>Type</label>
                        <select name="type" id="createType">
                            <option value="PART">Part</option>
                            <option value="EQUIPMENT">Equipment</option>
                            <option value="BOTH">Shared (Both)</option>
                        </select>
                    </div>
                    <div class="modal-btns">
                        <button type="submit" class="btn-save"><i class="fas fa-save"></i> Save</button>
                        <button type="button" class="btn-cancel" onclick="closeModal('createModal')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- EDIT MODAL -->
        <div class="modal-overlay" id="editModal">
            <div class="modal">
                <h3><i class="fas fa-edit" style="color:#f59e0b;margin-right:6px"></i> Edit Category</h3>
                <form method="post" action="<%= ctx %>/categoryManage">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="id" id="editId">
                    <div class="form-group">
                        <label>Category Name *</label>
                        <input type="text" name="name" id="editName" required>
                    </div>
                    <div class="form-group">
                        <label>Type</label>
                        <select name="type" id="editType">
                            <option value="PART">Part</option>
                            <option value="EQUIPMENT">Equipment</option>
                            <option value="BOTH">Shared (Both)</option>
                        </select>
                    </div>
                    <div class="modal-btns">
                        <button type="submit" class="btn-save"><i class="fas fa-save"></i> Save</button>
                        <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- DELETE MODAL -->
        <div class="modal-overlay" id="deleteModal">
            <div class="modal" style="text-align:center">
                <div style="font-size:3rem;color:#ef4444;margin-bottom:12px">⚠</div>
                <h3>Confirm Deletion</h3>
                <p style="color:#64748b;margin:10px 0 20px;font-size:0.9rem">
                    Are you sure you want to delete the category:<br>
                    <strong id="deleteCatName" style="color:#1e293b"></strong>?<br>
                    <span style="font-size:0.8rem;color:#ef4444">⚠ Parts/equipment belonging to this category may be affected!</span>
                </p>
                <form method="post" action="<%= ctx %>/categoryManage">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteId">
                    <div class="modal-btns">
                        <button type="submit" class="btn-danger"><i class="fas fa-trash"></i> Delete</button>
                        <button type="button" class="btn-cancel" onclick="closeModal('deleteModal')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function openCreate(type) {
                document.getElementById('createType').value = type;
                document.getElementById('createModal').classList.add('show');
            }
            function openEdit(id, name, type) {
                document.getElementById('editId').value = id;
                document.getElementById('editName').value = name;
                document.getElementById('editType').value = type;
                document.getElementById('editModal').classList.add('show');
            }
            function openDelete(id, name) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteCatName').textContent = name;
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
