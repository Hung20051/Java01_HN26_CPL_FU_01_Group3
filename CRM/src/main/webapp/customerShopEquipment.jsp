<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, dao.ShopDAO.ShopItem, java.util.*, java.text.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<ShopItem> items = (List<ShopItem>) request.getAttribute("items");
    List<Map<String,Object>> categories = (List<Map<String,Object>>) request.getAttribute("categories");
    if (items == null) items = new ArrayList<>();
    if (categories == null) categories = new ArrayList<>();
    String keyword   = (String) request.getAttribute("keyword");   if (keyword == null) keyword = "";
    String catId     = (String) request.getAttribute("categoryId"); if (catId == null) catId = "";
    String sortBy    = (String) request.getAttribute("sortBy");     if (sortBy == null) sortBy = "";
    int currentPage  = request.getAttribute("currentPage") != null ? (int)request.getAttribute("currentPage") : 1;
    int totalPages   = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages") : 1;
    int total        = request.getAttribute("total")       != null ? (int)request.getAttribute("total") : 0;
    int cartCount    = request.getAttribute("cartCount")   != null ? (int)request.getAttribute("cartCount") : 0;

    String flashSuccess = (String) session.getAttribute("shopFlashSuccess");
    String flashError   = (String) session.getAttribute("shopFlashError");
    session.removeAttribute("shopFlashSuccess"); session.removeAttribute("shopFlashError");

    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Buy Equipment - DRSMS</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            *{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            body{
                font-family:'Segoe UI',sans-serif;
                background:#f0f2f5;
                display:flex;
                min-height:100vh
            }
            .sidebar{
                width:200px;
                min-height:100vh;
                background:#1e293b;
                display:flex;
                flex-direction:column;
                position:fixed;
                top:0;
                left:0
            }
            .sidebar-brand{
                padding:20px 16px;
                color:white;
                font-size:1rem;
                font-weight:700;
                border-bottom:1px solid rgba(255,255,255,.1);
                display:flex;
                align-items:center;
                gap:8px
            }
            .sidebar-brand i{
                color:#38bdf8
            }
            .sidebar-section{
                padding:12px 16px 4px;
                font-size:.65rem;
                font-weight:700;
                color:rgba(255,255,255,.35);
                text-transform:uppercase;
                letter-spacing:1px;
                margin-top:4px
            }
            .nav-item{
                display:flex;
                align-items:center;
                gap:10px;
                padding:9px 20px;
                color:rgba(255,255,255,.65);
                text-decoration:none;
                font-size:.845rem;
                transition:.15s;
                border-left:3px solid transparent
            }
            .nav-item:hover,.nav-item.active{
                color:white;
                background:rgba(255,255,255,.08);
                border-left-color:#38bdf8
            }
            .nav-item i{
                width:16px;
                text-align:center;
                font-size:.85rem
            }
            .nav-item .badge-cnt{
                background:#ef4444;
                color:white;
                font-size:.65rem;
                font-weight:700;
                padding:1px 6px;
                border-radius:10px;
                margin-left:auto
            }
            .sidebar-footer{
                padding:16px;
                border-top:1px solid rgba(255,255,255,.1);
                margin-top:auto
            }
            .user-info{
                display:flex;
                align-items:center;
                gap:8px;
                margin-bottom:10px
            }
            .user-avatar{
                width:32px;
                height:32px;
                background:#38bdf8;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-weight:700;
                font-size:.85rem;
                color:#0f172a
            }
            .user-name{
                font-size:.82rem;
                color:white;
                font-weight:600
            }
            .user-role{
                font-size:.7rem;
                color:rgba(255,255,255,.45)
            }
            .btn-logout-sm{
                display:flex;
                align-items:center;
                gap:6px;
                color:rgba(255,255,255,.5);
                text-decoration:none;
                font-size:.8rem;
                padding:6px 8px;
                border-radius:6px
            }
            .btn-logout-sm:hover{
                color:#f87171;
                background:rgba(248,113,113,.1)
            }
            .main{
                margin-left:200px;
                flex:1;
                padding:28px
            }
            .topbar{
                display:flex;
                justify-content:space-between;
                align-items:center;
                margin-bottom:20px
            }
            .page-title{
                font-size:1.3rem;
                font-weight:700;
                color:#1e293b;
                display:flex;
                align-items:center;
                gap:8px
            }
            .page-title i{
                color:#6366f1
            }
            .shop-tabs{
                display:flex;
                background:white;
                border-radius:10px;
                border:1px solid #e2e8f0;
                overflow:hidden;
                margin-bottom:20px;
                width:fit-content
            }
            .shop-tab{
                padding:10px 24px;
                font-size:.875rem;
                font-weight:600;
                text-decoration:none;
                color:#64748b;
                border-right:1px solid #e2e8f0;
                display:flex;
                align-items:center;
                gap:7px;
                transition:.15s
            }
            .shop-tab:last-child{
                border-right:none
            }
            .shop-tab:hover{
                background:#f8fafc;
                color:#374151
            }
            .shop-tab.active{
                background:#6366f1;
                color:white
            }
            .toolbar{
                display:flex;
                gap:10px;
                align-items:center;
                margin-bottom:20px;
                flex-wrap:wrap
            }
            .search-input{
                flex:1;
                min-width:220px;
                padding:9px 14px;
                border:1px solid #e2e8f0;
                border-radius:9px;
                font-size:.875rem;
                outline:none
            }
            .search-input:focus{
                border-color:#6366f1
            }
            .select-box{
                padding:9px 12px;
                border:1px solid #e2e8f0;
                border-radius:9px;
                font-size:.875rem;
                outline:none;
                background:white;
                color:#374151
            }
            .btn{
                padding:9px 18px;
                border-radius:9px;
                font-size:.875rem;
                font-weight:600;
                border:none;
                cursor:pointer;
                display:flex;
                align-items:center;
                gap:6px;
                text-decoration:none
            }
            .btn-primary{
                background:#6366f1;
                color:white
            }
            .btn-primary:hover{
                background:#4f46e5
            }
            .btn-cart{
                background:white;
                color:#374151;
                border:1px solid #e2e8f0;
                position:relative
            }
            .btn-cart:hover{
                background:#f8fafc
            }
            .cart-badge{
                position:absolute;
                top:-6px;
                right:-6px;
                background:#ef4444;
                color:white;
                font-size:.65rem;
                font-weight:700;
                padding:1px 5px;
                border-radius:10px
            }

            /* Equipment cards - list style for large equipment */
            .product-list{
                display:flex;
                flex-direction:column;
                gap:14px;
                margin-bottom:24px
            }
            .equip-card{
                background:white;
                border-radius:12px;
                border:1px solid #e2e8f0;
                padding:18px 20px;
                display:flex;
                align-items:center;
                gap:18px;
                transition:.2s
            }
            .equip-card:hover{
                box-shadow:0 4px 16px rgba(0,0,0,.08)
            }
            .equip-icon{
                width:64px;
                height:64px;
                background:linear-gradient(135deg,#fce7f3,#dbeafe);
                border-radius:12px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.8rem;
                flex-shrink:0
            }
            .equip-info{
                flex:1
            }
            .equip-cat{
                font-size:.7rem;
                font-weight:600;
                color:#6366f1;
                text-transform:uppercase;
                letter-spacing:.5px;
                margin-bottom:3px
            }
            .equip-name{
                font-size:1rem;
                font-weight:700;
                color:#1e293b;
                margin-bottom:4px
            }
            .equip-desc{
                font-size:.82rem;
                color:#94a3b8;
                margin-bottom:6px
            }
            .equip-stock{
                font-size:.76rem;
                color:#10b981;
                font-weight:600
            }
            .equip-stock.low{
                color:#f59e0b
            }
            .equip-right{
                text-align:right;
                flex-shrink:0
            }
            .equip-price{
                font-size:1.2rem;
                font-weight:800;
                color:#ef4444;
                margin-bottom:10px
            }
            .btn-add-equip{
                padding:10px 20px;
                background:#6366f1;
                color:white;
                border:none;
                border-radius:9px;
                font-size:.875rem;
                font-weight:600;
                cursor:pointer;
                transition:.15s;
                display:flex;
                align-items:center;
                gap:6px
            }
            .btn-add-equip:hover{
                background:#4f46e5
            }
            .equip-note{
                font-size:.72rem;
                color:#94a3b8;
                margin-top:6px
            }

            .pagination{
                display:flex;
                justify-content:center;
                align-items:center;
                gap:6px
            }
            .page-btn{
                padding:6px 12px;
                border:1px solid #e2e8f0;
                border-radius:7px;
                background:white;
                font-size:.82rem;
                cursor:pointer;
                text-decoration:none;
                color:#374151
            }
            .page-btn.active{
                background:#6366f1;
                color:white;
                border-color:#6366f1
            }
            .page-btn.disabled{
                opacity:.4;
                pointer-events:none
            }
            .alert{
                padding:10px 14px;
                border-radius:8px;
                margin-bottom:16px;
                font-size:.875rem;
                display:flex;
                align-items:center;
                gap:8px
            }
            .alert-success{
                background:#d1fae5;
                color:#065f46;
                border:1px solid #a7f3d0
            }
            .alert-error{
                background:#fee2e2;
                color:#991b1b;
                border:1px solid #fca5a5
            }
            .empty-state{
                text-align:center;
                padding:60px 20px;
                color:#94a3b8
            }
            .empty-state i{
                font-size:3rem;
                margin-bottom:12px;
                display:block
            }
            .result-info{
                font-size:.82rem;
                color:#94a3b8;
                margin-bottom:16px
            }
        </style>
    </head>
    <body>
        <aside class="sidebar">
            <div class="sidebar-brand"><i class="fas fa-building"></i> DRSMS System</div>
            <div class="sidebar-section">Overview</div>
            <a href="<%= ctx %>/customerDashboard" class="nav-item"><i class="fas fa-home"></i> Home</a>
            <div class="sidebar-section">Services</div>
            <a href="<%= ctx %>/customerServiceRequests" class="nav-item"><i class="fas fa-tools"></i> Repair Requests</a>
            <a href="<%= ctx %>/customerContracts"       class="nav-item"><i class="fas fa-file-contract"></i> Contracts</a>
            <a href="<%= ctx %>/customerEquipment"       class="nav-item"><i class="fas fa-desktop"></i> My Equipment</a>
            <div class="sidebar-section">Shop</div>
            <a href="<%= ctx %>/customerShop?action=parts"     class="nav-item"><i class="fas fa-puzzle-piece"></i> Parts</a>
            <a href="<%= ctx %>/customerShop?action=equipment" class="nav-item active"><i class="fas fa-server"></i> Equipment</a>
            <a href="<%= ctx %>/customerShop?action=cart"      class="nav-item"><i class="fas fa-shopping-cart"></i> Cart
                <% if (cartCount > 0) { %><span class="badge-cnt"><%= cartCount %></span><% } %>
            </a>
            <div class="sidebar-section">Finance</div>
            <a href="<%= ctx %>/customerInvoices" class="nav-item"><i class="fas fa-file-invoice"></i> Invoices</a>
            <div class="sidebar-section">Support</div>
            <a href="<%= ctx %>/customerChat"     class="nav-item"><i class="fas fa-comments"></i> Support Chat</a>
            <div class="sidebar-footer">
                <div class="user-info">
                    <div class="user-avatar"><%= me.getUsername().charAt(0) %></div>
                    <div><div class="user-name"><%= me.getFullName() != null ? me.getFullName() : me.getUsername() %></div><div class="user-role">Customer</div></div>
                </div>
                <a href="<%= ctx %>/logout" class="btn-logout-sm"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </aside>

        <main class="main">
            <div class="topbar">
                <div class="page-title"><i class="fas fa-store"></i> Shop</div>
                <a href="<%= ctx %>/customerShop?action=cart" class="btn btn-cart">
                    <i class="fas fa-shopping-cart"></i> Cart
                    <% if (cartCount > 0) { %><span class="cart-badge"><%= cartCount %></span><% } %>
                </a>
            </div>

            <% if (flashSuccess != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= flashSuccess %></div><% } %>
            <% if (flashError   != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= flashError %></div><% } %>

            <div class="shop-tabs">
                <a href="<%= ctx %>/customerShop?action=parts"     class="shop-tab"><i class="fas fa-puzzle-piece"></i> Parts</a>
                <a href="<%= ctx %>/customerShop?action=equipment" class="shop-tab active"><i class="fas fa-server"></i> Equipment</a>
            </div>

            <form method="get" action="<%= ctx %>/customerShop">
                <input type="hidden" name="action" value="equipment">
                <div class="toolbar">
                    <input class="search-input" type="text" name="keyword" placeholder="Search equipment..." value="<%= keyword %>">
                    <select class="select-box" name="categoryId" onchange="this.form.submit()">
                        <option value="">-- All Categories --</option>
                        <% for (Map<String,Object> cat : categories) { %>
                        <option value="<%= cat.get("id") %>" <%= String.valueOf(cat.get("id")).equals(catId) ? "selected" : "" %>><%= cat.get("name") %></option>
                        <% } %>
                    </select>
                    <select class="select-box" name="sortBy" onchange="this.form.submit()">
                        <option value="">-- Sort By --</option>
                        <option value="price_asc"  <%= "price_asc".equals(sortBy)  ? "selected":"" %>>Price: Low to High</option>
                        <option value="price_desc" <%= "price_desc".equals(sortBy) ? "selected":"" %>>Price: High to Low</option>
                        <option value="name_asc"   <%= "name_asc".equals(sortBy)   ? "selected":"" %>>Name A-Z</option>
                    </select>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Search</button>
                </div>
            </form>

            <div class="result-info">Found <strong><%= total %></strong> equipment type(s)</div>

            <% if (items.isEmpty()) { %>
            <div class="empty-state"><i class="fas fa-server"></i> No matching equipment found</div>
            <% } else { %>
            <div class="product-list">
                <% for (ShopItem item : items) { %>
                <div class="equip-card">
                    <div class="equip-icon">🖥️</div>
                    <div class="equip-info">
                        <div class="equip-cat"><%= item.categoryName %></div>
                        <div class="equip-name"><%= item.name %></div>
                        <div class="equip-desc"><%= item.description != null ? item.description : "" %></div>
                        <div class="equip-stock <%= item.availableQty <= 2 ? "low" : "" %>">
                            <i class="fas fa-check-circle"></i> <%= item.availableQty %> unit<%= item.availableQty > 1 ? "s" : "" %> available<%= item.availableQty <= 2 ? " (low stock)" : "" %>
                        </div>
                    </div>
                    <div class="equip-right">
                        <div class="equip-price"><%= nf.format((long)item.unitPrice) %> ₫</div>
                        <form method="post" action="<%= ctx %>/customerShop">
                            <input type="hidden" name="action"   value="addToCart">
                            <input type="hidden" name="itemType" value="EQUIPMENT">
                            <input type="hidden" name="typeId"   value="<%= item.id %>">
                            <input type="hidden" name="quantity" value="1">
                            <button type="submit" class="btn-add-equip"><i class="fas fa-cart-plus"></i> Add to Cart</button>
                        </form>
                        <div class="equip-note">Only 1 unit per order (each has a unique serial number)</div>
                    </div>
                </div>
                <% } %>
            </div>

            <% if (totalPages > 1) { %>
            <div class="pagination">
                <a href="?action=equipment&page=1&keyword=<%= keyword %>&categoryId=<%= catId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==1?"disabled":"" %>">«</a>
                <a href="?action=equipment&page=<%= Math.max(1,currentPage-1) %>&keyword=<%= keyword %>&categoryId=<%= catId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==1?"disabled":"" %>">‹</a>
                <% for (int p=Math.max(1,currentPage-2); p<=Math.min(totalPages,currentPage+2); p++) { %>
                <a href="?action=equipment&page=<%= p %>&keyword=<%= keyword %>&categoryId=<%= catId %>&sortBy=<%= sortBy %>" class="page-btn <%= p==currentPage?"active":"" %>"><%= p %></a>
                <% } %>
                <a href="?action=equipment&page=<%= Math.min(totalPages,currentPage+1) %>&keyword=<%= keyword %>&categoryId=<%= catId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==totalPages?"disabled":"" %>">›</a>
                <a href="?action=equipment&page=<%= totalPages %>&keyword=<%= keyword %>&categoryId=<%= catId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==totalPages?"disabled":"" %>">»</a>
            </div>
            <% } %>
            <% } %>
        </main>
    </body>
</html>
