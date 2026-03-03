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
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Mua linh kiện - CRM</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Segoe UI',sans-serif;background:#f0f2f5;display:flex;min-height:100vh}

        /* SIDEBAR - kế thừa từ customerDashboard */
        .sidebar{width:200px;min-height:100vh;background:#1e293b;display:flex;flex-direction:column;position:fixed;top:0;left:0}
        .sidebar-brand{padding:20px 16px;color:white;font-size:1rem;font-weight:700;border-bottom:1px solid rgba(255,255,255,.1);display:flex;align-items:center;gap:8px}
        .sidebar-brand i{color:#38bdf8}
        .sidebar-section{padding:12px 16px 4px;font-size:.65rem;font-weight:700;color:rgba(255,255,255,.35);text-transform:uppercase;letter-spacing:1px;margin-top:4px}
        .nav-item{display:flex;align-items:center;gap:10px;padding:9px 20px;color:rgba(255,255,255,.65);text-decoration:none;font-size:.845rem;transition:.15s;border-left:3px solid transparent}
        .nav-item:hover,.nav-item.active{color:white;background:rgba(255,255,255,.08);border-left-color:#38bdf8}
        .nav-item i{width:16px;text-align:center;font-size:.85rem}
        .nav-item .badge-cnt{background:#ef4444;color:white;font-size:.65rem;font-weight:700;padding:1px 6px;border-radius:10px;margin-left:auto}
        .sidebar-footer{padding:16px;border-top:1px solid rgba(255,255,255,.1);margin-top:auto}
        .user-info{display:flex;align-items:center;gap:8px;margin-bottom:10px}
        .user-avatar{width:32px;height:32px;background:#38bdf8;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:.85rem;color:#0f172a}
        .user-name{font-size:.82rem;color:white;font-weight:600}
        .user-role{font-size:.7rem;color:rgba(255,255,255,.45)}
        .btn-logout-sm{display:flex;align-items:center;gap:6px;color:rgba(255,255,255,.5);text-decoration:none;font-size:.8rem;padding:6px 8px;border-radius:6px}
        .btn-logout-sm:hover{color:#f87171;background:rgba(248,113,113,.1)}

        /* MAIN */
        .main{margin-left:200px;flex:1;padding:28px}
        .topbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px}
        .page-title{font-size:1.3rem;font-weight:700;color:#1e293b;display:flex;align-items:center;gap:8px}
        .page-title i{color:#6366f1}

        /* SHOP TABS */
        .shop-tabs{display:flex;gap:0;background:white;border-radius:10px;border:1px solid #e2e8f0;overflow:hidden;margin-bottom:20px;width:fit-content}
        .shop-tab{padding:10px 24px;font-size:.875rem;font-weight:600;text-decoration:none;color:#64748b;border-right:1px solid #e2e8f0;display:flex;align-items:center;gap:7px;transition:.15s}
        .shop-tab:last-child{border-right:none}
        .shop-tab:hover{background:#f8fafc;color:#374151}
        .shop-tab.active{background:#6366f1;color:white}

        /* TOOLBAR */
        .toolbar{display:flex;gap:10px;align-items:center;margin-bottom:20px;flex-wrap:wrap}
        .search-input{flex:1;min-width:220px;padding:9px 14px;border:1px solid #e2e8f0;border-radius:9px;font-size:.875rem;outline:none}
        .search-input:focus{border-color:#6366f1}
        .select-box{padding:9px 12px;border:1px solid #e2e8f0;border-radius:9px;font-size:.875rem;outline:none;background:white;color:#374151}
        .btn{padding:9px 18px;border-radius:9px;font-size:.875rem;font-weight:600;border:none;cursor:pointer;display:flex;align-items:center;gap:6px;text-decoration:none}
        .btn-primary{background:#6366f1;color:white}
        .btn-primary:hover{background:#4f46e5}
        .btn-cart{background:white;color:#374151;border:1px solid #e2e8f0;position:relative}
        .btn-cart:hover{background:#f8fafc}
        .cart-badge{position:absolute;top:-6px;right:-6px;background:#ef4444;color:white;font-size:.65rem;font-weight:700;padding:1px 5px;border-radius:10px}

        /* PRODUCT GRID */
        .product-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:16px;margin-bottom:24px}
        .product-card{background:white;border-radius:12px;border:1px solid #e2e8f0;overflow:hidden;transition:.2s;display:flex;flex-direction:column}
        .product-card:hover{box-shadow:0 4px 16px rgba(0,0,0,.08);transform:translateY(-2px)}
        .product-img{height:100px;background:linear-gradient(135deg,#ede9fe,#dbeafe);display:flex;align-items:center;justify-content:center;font-size:2.5rem}
        .product-body{padding:14px;flex:1;display:flex;flex-direction:column}
        .product-cat{font-size:.7rem;font-weight:600;color:#6366f1;text-transform:uppercase;letter-spacing:.5px;margin-bottom:5px}
        .product-name{font-size:.9rem;font-weight:700;color:#1e293b;margin-bottom:6px;line-height:1.3}
        .product-desc{font-size:.78rem;color:#94a3b8;margin-bottom:10px;flex:1;line-height:1.4;overflow:hidden;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical}
        .product-price{font-size:1.1rem;font-weight:800;color:#ef4444;margin-bottom:6px}
        .product-stock{font-size:.74rem;color:#10b981;font-weight:600;margin-bottom:12px}
        .product-stock.low{color:#f59e0b}
        .add-to-cart-form{display:flex;gap:6px}
        .qty-input{width:52px;padding:6px 8px;border:1px solid #e2e8f0;border-radius:7px;font-size:.82rem;text-align:center}
        .btn-add{flex:1;padding:8px;background:#6366f1;color:white;border:none;border-radius:7px;font-size:.8rem;font-weight:600;cursor:pointer;transition:.15s}
        .btn-add:hover{background:#4f46e5}

        /* PAGINATION */
        .pagination{display:flex;justify-content:center;align-items:center;gap:6px}
        .page-btn{padding:6px 12px;border:1px solid #e2e8f0;border-radius:7px;background:white;font-size:.82rem;cursor:pointer;text-decoration:none;color:#374151}
        .page-btn.active{background:#6366f1;color:white;border-color:#6366f1}
        .page-btn.disabled{opacity:.4;pointer-events:none}

        /* FLASH */
        .alert{padding:10px 14px;border-radius:8px;margin-bottom:16px;font-size:.875rem;display:flex;align-items:center;gap:8px}
        .alert-success{background:#d1fae5;color:#065f46;border:1px solid #a7f3d0}
        .alert-error{background:#fee2e2;color:#991b1b;border:1px solid #fca5a5}

        .empty-state{text-align:center;padding:60px 20px;color:#94a3b8}
        .empty-state i{font-size:3rem;margin-bottom:12px;display:block}
        .result-info{font-size:.82rem;color:#94a3b8;margin-bottom:16px}
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="sidebar-brand"><i class="fas fa-building"></i> CRM System</div>
    <div class="sidebar-section">Tổng quan</div>
    <a href="<%= ctx %>/customerDashboard" class="nav-item"><i class="fas fa-home"></i> Trang chủ</a>
    <div class="sidebar-section">Dịch vụ</div>
    <a href="<%= ctx %>/customerServiceRequests" class="nav-item"><i class="fas fa-tools"></i> Yêu cầu sửa chữa</a>
    <a href="<%= ctx %>/customerContracts"       class="nav-item"><i class="fas fa-file-contract"></i> Hợp đồng</a>
    <a href="<%= ctx %>/customerEquipment"       class="nav-item"><i class="fas fa-desktop"></i> Thiết bị của tôi</a>
    <div class="sidebar-section">Mua hàng</div>
    <a href="<%= ctx %>/customerShop?action=parts"     class="nav-item active"><i class="fas fa-puzzle-piece"></i> Linh kiện</a>
    <a href="<%= ctx %>/customerShop?action=equipment" class="nav-item"><i class="fas fa-server"></i> Thiết bị</a>
    <a href="<%= ctx %>/customerShop?action=cart"      class="nav-item"><i class="fas fa-shopping-cart"></i> Giỏ hàng
        <% if (cartCount > 0) { %><span class="badge-cnt"><%= cartCount %></span><% } %>
    </a>
    <div class="sidebar-section">Tài chính</div>
    <a href="<%= ctx %>/customerInvoices" class="nav-item"><i class="fas fa-file-invoice"></i> Hóa đơn</a>
    <div class="sidebar-section">Hỗ trợ</div>
    <a href="<%= ctx %>/customerChat"     class="nav-item"><i class="fas fa-comments"></i> Chat hỗ trợ</a>
    <div class="sidebar-footer">
        <div class="user-info">
            <div class="user-avatar"><%= me.getUsername().charAt(0) %></div>
            <div><div class="user-name"><%= me.getFullName() != null ? me.getFullName() : me.getUsername() %></div><div class="user-role">Khách hàng</div></div>
        </div>
        <a href="<%= ctx %>/logout" class="btn-logout-sm"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
    </div>
</aside>

<main class="main">
    <div class="topbar">
        <div class="page-title"><i class="fas fa-store"></i> Mua hàng</div>
        <a href="<%= ctx %>/customerShop?action=cart" class="btn btn-cart">
            <i class="fas fa-shopping-cart"></i> Giỏ hàng
            <% if (cartCount > 0) { %><span class="cart-badge"><%= cartCount %></span><% } %>
        </a>
    </div>

    <% if (flashSuccess != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= flashSuccess %></div><% } %>
    <% if (flashError   != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= flashError %></div><% } %>

    <!-- TABS -->
    <div class="shop-tabs">
        <a href="<%= ctx %>/customerShop?action=parts"     class="shop-tab active"><i class="fas fa-puzzle-piece"></i> Linh kiện</a>
        <a href="<%= ctx %>/customerShop?action=equipment" class="shop-tab"><i class="fas fa-server"></i> Thiết bị</a>
    </div>

    <!-- TOOLBAR -->
    <form method="get" action="<%= ctx %>/customerShop">
        <input type="hidden" name="action" value="parts">
        <div class="toolbar">
            <input class="search-input" type="text" name="keyword" placeholder="Tìm kiếm linh kiện..." value="<%= keyword %>">
            <select class="select-box" name="categoryId" onchange="this.form.submit()">
                <option value="">-- Tất cả danh mục --</option>
                <% for (Map<String,Object> cat : categories) { %>
                <option value="<%= cat.get("id") %>" <%= String.valueOf(cat.get("id")).equals(catId) ? "selected" : "" %>><%= cat.get("name") %></option>
                <% } %>
            </select>
            <select class="select-box" name="sortBy" onchange="this.form.submit()">
                <option value="">-- Sắp xếp --</option>
                <option value="price_asc"  <%= "price_asc".equals(sortBy)  ? "selected":"" %>>Giá tăng dần</option>
                <option value="price_desc" <%= "price_desc".equals(sortBy) ? "selected":"" %>>Giá giảm dần</option>
                <option value="name_asc"   <%= "name_asc".equals(sortBy)   ? "selected":"" %>>Tên A-Z</option>
            </select>
            <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Tìm</button>
        </div>
    </form>

    <div class="result-info">Tìm thấy <strong><%= total %></strong> linh kiện</div>

    <% if (items.isEmpty()) { %>
    <div class="empty-state">
        <i class="fas fa-box-open"></i>
        Không có linh kiện nào phù hợp
    </div>
    <% } else { %>
    <div class="product-grid">
        <% for (ShopItem item : items) { %>
        <div class="product-card">
            <div class="product-img">🔧</div>
            <div class="product-body">
                <div class="product-cat"><%= item.categoryName %></div>
                <div class="product-name"><%= item.name %></div>
                <div class="product-desc"><%= item.description != null ? item.description : "" %></div>
                <div class="product-price"><%= nf.format((long)item.unitPrice) %> ₫</div>
                <div class="product-stock <%= item.availableQty <= 3 ? "low" : "" %>">
                    <i class="fas fa-check-circle"></i>
                    <%= item.availableQty <= 3 ? "Sắp hết - " : "" %>Còn <%= item.availableQty %> units
                </div>
                <form method="post" action="<%= ctx %>/customerShop" class="add-to-cart-form">
                    <input type="hidden" name="action"   value="addToCart">
                    <input type="hidden" name="itemType" value="PART">
                    <input type="hidden" name="typeId"   value="<%= item.id %>">
                    <input class="qty-input" type="number" name="quantity" value="1" min="1" max="<%= item.availableQty %>">
                    <button type="submit" class="btn-add"><i class="fas fa-cart-plus"></i> Thêm giỏ</button>
                </form>
            </div>
        </div>
        <% } %>
    </div>

    <!-- PAGINATION -->
    <% if (totalPages > 1) { %>
    <div class="pagination">
        <a href="?action=parts&page=1&keyword=<%= keyword %>&categoryId=<%= catId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==1?"disabled":"" %>">«</a>
        <a href="?action=parts&page=<%= Math.max(1,currentPage-1) %>&keyword=<%= keyword %>&categoryId=<%= catId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==1?"disabled":"" %>">‹</a>
        <% for (int p=Math.max(1,currentPage-2); p<=Math.min(totalPages,currentPage+2); p++) { %>
        <a href="?action=parts&page=<%= p %>&keyword=<%= keyword %>&categoryId=<%= catId %>&sortBy=<%= sortBy %>" class="page-btn <%= p==currentPage?"active":"" %>"><%= p %></a>
        <% } %>
        <a href="?action=parts&page=<%= Math.min(totalPages,currentPage+1) %>&keyword=<%= keyword %>&categoryId=<%= catId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==totalPages?"disabled":"" %>">›</a>
        <a href="?action=parts&page=<%= totalPages %>&keyword=<%= keyword %>&categoryId=<%= catId %>&sortBy=<%= sortBy %>" class="page-btn <%= currentPage==totalPages?"disabled":"" %>">»</a>
    </div>
    <% } %>
    <% } %>
</main>
</body>
</html>
