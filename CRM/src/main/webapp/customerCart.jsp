<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.CartItem, java.util.*, java.text.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<CartItem> cartList = (List<CartItem>) request.getAttribute("cartList");
    if (cartList == null) cartList = new ArrayList<>();
    double grandTotal = request.getAttribute("grandTotal") != null ? (double)request.getAttribute("grandTotal") : 0;
    int    cartCount  = request.getAttribute("cartCount")  != null ? (int)request.getAttribute("cartCount") : 0;
    String flashSuccess = (String) request.getAttribute("flashSuccess");
    String flashError   = (String) request.getAttribute("flashError");
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Giỏ hàng - CRM</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Segoe UI',sans-serif;background:#f0f2f5;display:flex;min-height:100vh}
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
        .btn-logout-sm:hover{color:#f87171}
        .main{margin-left:200px;flex:1;padding:28px}
        .topbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:24px}
        .page-title{font-size:1.3rem;font-weight:700;color:#1e293b;display:flex;align-items:center;gap:8px}
        .page-title i{color:#6366f1}
        .alert{padding:10px 14px;border-radius:8px;margin-bottom:16px;font-size:.875rem;display:flex;align-items:center;gap:8px}
        .alert-success{background:#d1fae5;color:#065f46;border:1px solid #a7f3d0}
        .alert-error{background:#fee2e2;color:#991b1b;border:1px solid #fca5a5}

        .layout{display:grid;grid-template-columns:1fr 340px;gap:20px;align-items:start}

        /* CART TABLE */
        .cart-card{background:white;border-radius:12px;border:1px solid #e2e8f0;overflow:hidden}
        .cart-header{padding:14px 20px;border-bottom:1px solid #f1f5f9;display:flex;justify-content:space-between;align-items:center}
        .cart-header h2{font-size:1rem;font-weight:700;color:#1e293b}
        .btn-clear{background:none;border:none;color:#94a3b8;font-size:.8rem;cursor:pointer;display:flex;align-items:center;gap:4px}
        .btn-clear:hover{color:#ef4444}
        table{width:100%;border-collapse:collapse;font-size:.85rem}
        th{padding:10px 16px;text-align:left;color:#64748b;font-weight:600;font-size:.75rem;text-transform:uppercase;letter-spacing:.4px;border-bottom:1px solid #f1f5f9;background:#f8fafc}
        td{padding:14px 16px;border-bottom:1px solid #f8fafc;color:#374151;vertical-align:middle}
        tr:last-child td{border-bottom:none}
        .item-name{font-weight:600;color:#1e293b;margin-bottom:2px}
        .item-cat{font-size:.76rem;color:#94a3b8}
        .item-type-badge{display:inline-flex;align-items:center;gap:3px;padding:2px 8px;border-radius:10px;font-size:.7rem;font-weight:600;margin-left:6px}
        .badge-part{background:#ede9fe;color:#7c3aed}
        .badge-equip{background:#fce7f3;color:#be185d}
        .qty-form{display:flex;align-items:center;gap:6px}
        .qty-btn{width:28px;height:28px;background:#f1f5f9;border:1px solid #e2e8f0;border-radius:6px;cursor:pointer;font-size:1rem;display:flex;align-items:center;justify-content:center;font-weight:700;color:#374151}
        .qty-btn:hover{background:#e2e8f0}
        .qty-display{width:36px;text-align:center;font-weight:700;font-size:.9rem;color:#1e293b}
        .btn-remove{background:none;border:none;color:#94a3b8;cursor:pointer;padding:4px 8px;border-radius:6px}
        .btn-remove:hover{color:#ef4444;background:#fee2e2}
        .price-cell{font-weight:700;color:#1e293b;white-space:nowrap}
        .subtotal-cell{font-weight:800;color:#ef4444;white-space:nowrap}

        /* ORDER SUMMARY */
        .summary-card{background:white;border-radius:12px;border:1px solid #e2e8f0;padding:20px;position:sticky;top:20px}
        .summary-title{font-size:1rem;font-weight:700;color:#1e293b;margin-bottom:16px;display:flex;align-items:center;gap:6px}
        .summary-row{display:flex;justify-content:space-between;margin-bottom:10px;font-size:.875rem;color:#374151}
        .summary-divider{border:none;border-top:1px solid #f1f5f9;margin:14px 0}
        .summary-total{display:flex;justify-content:space-between;font-size:1.1rem;font-weight:800;color:#1e293b}
        .summary-tax{font-size:.78rem;color:#94a3b8;text-align:right;margin-top:4px;margin-bottom:16px}

        /* PAYMENT BUTTONS */
        .pay-title{font-size:.82rem;font-weight:600;color:#64748b;margin-bottom:10px}
        .btn-pay{width:100%;padding:12px;border:none;border-radius:10px;font-size:.95rem;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:8px;margin-bottom:8px;transition:.15s}
        .btn-cash{background:#10b981;color:white}
        .btn-cash:hover{background:#059669}
        .btn-vnpay{background:linear-gradient(135deg,#e30019,#b50014);color:white}
        .btn-vnpay:hover{opacity:.92}
        .btn-continue{width:100%;padding:10px;background:#f8fafc;color:#64748b;border:1.5px solid #e2e8f0;border-radius:10px;font-size:.875rem;font-weight:600;cursor:pointer;margin-top:4px;display:flex;align-items:center;justify-content:center;gap:6px;text-decoration:none}
        .btn-continue:hover{background:#f1f5f9}

        .empty-cart{text-align:center;padding:60px 20px;color:#94a3b8}
        .empty-cart i{font-size:3.5rem;margin-bottom:12px;display:block;opacity:.5}
        .empty-cart h3{font-size:1.1rem;font-weight:600;margin-bottom:8px;color:#64748b}
        .btn-shop{display:inline-flex;align-items:center;gap:6px;padding:10px 24px;background:#6366f1;color:white;border-radius:9px;text-decoration:none;font-size:.875rem;font-weight:600;margin-top:12px}
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
    <a href="<%= ctx %>/customerShop?action=parts"     class="nav-item"><i class="fas fa-puzzle-piece"></i> Linh kiện</a>
    <a href="<%= ctx %>/customerShop?action=equipment" class="nav-item"><i class="fas fa-server"></i> Thiết bị</a>
    <a href="<%= ctx %>/customerShop?action=cart"      class="nav-item active"><i class="fas fa-shopping-cart"></i> Giỏ hàng
        <% if (cartCount > 0) { %><span class="badge-cnt"><%= cartCount %></span><% } %>
    </a>
    <div class="sidebar-section">Tài chính</div>
    <a href="<%= ctx %>/customerInvoices" class="nav-item"><i class="fas fa-file-invoice"></i> Hóa đơn</a>
    <div class="sidebar-section">Hỗ trợ</div>
    <a href="<%= ctx %>/customerChat" class="nav-item"><i class="fas fa-comments"></i> Chat hỗ trợ</a>
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
        <div class="page-title"><i class="fas fa-shopping-cart"></i> Giỏ hàng (<%= cartCount %> sản phẩm)</div>
    </div>

    <% if (flashSuccess != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= flashSuccess %></div><% } %>
    <% if (flashError   != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= flashError %></div><% } %>

    <% if (cartList.isEmpty()) { %>
    <div style="background:white;border-radius:12px;border:1px solid #e2e8f0">
        <div class="empty-cart">
            <i class="fas fa-shopping-cart"></i>
            <h3>Giỏ hàng trống</h3>
            <p>Hãy thêm sản phẩm vào giỏ hàng</p>
            <a href="<%= ctx %>/customerShop?action=parts" class="btn-shop"><i class="fas fa-store"></i> Tiếp tục mua hàng</a>
        </div>
    </div>
    <% } else { %>
    <div class="layout">
        <!-- CART TABLE -->
        <div class="cart-card">
            <div class="cart-header">
                <h2><i class="fas fa-list" style="color:#6366f1"></i> Danh sách sản phẩm</h2>
                <form method="post" action="<%= ctx %>/customerShop" style="display:inline">
                    <input type="hidden" name="action" value="clearCart">
                    <button type="submit" class="btn-clear" onclick="return confirm('Xóa tất cả giỏ hàng?')">
                        <i class="fas fa-trash"></i> Xóa tất cả
                    </button>
                </form>
            </div>
            <table>
                <thead>
                    <tr><th>Sản phẩm</th><th>Đơn giá</th><th>Số lượng</th><th>Thành tiền</th><th></th></tr>
                </thead>
                <tbody>
                <% for (CartItem ci : cartList) { %>
                <tr>
                    <td>
                        <div class="item-name">
                            <%= ci.getName() %>
                            <span class="item-type-badge <%= "PART".equals(ci.getItemType()) ? "badge-part" : "badge-equip" %>">
                                <%= "PART".equals(ci.getItemType()) ? "Linh kiện" : "Thiết bị" %>
                            </span>
                        </div>
                        <div class="item-cat"><%= ci.getCategoryName() %></div>
                    </td>
                    <td class="price-cell"><%= nf.format((long)ci.getUnitPrice()) %> ₫</td>
                    <td>
                        <div class="qty-form">
                            <button type="button" class="qty-btn" onclick="changeQty('<%= ci.getKey() %>', <%= ci.getQuantity() - 1 %>)">−</button>
                            <span class="qty-display" id="qty-<%= ci.getKey().replace("_","-") %>"><%= ci.getQuantity() %></span>
                            <button type="button" class="qty-btn" onclick="changeQty('<%= ci.getKey() %>', <%= ci.getQuantity() + 1 %>)"
                                <%= ci.getQuantity() >= ci.getMaxQty() ? "disabled style='opacity:.4;cursor:not-allowed'" : "" %>>+</button>
                        </div>
                    </td>
                    <td class="subtotal-cell"><%= nf.format((long)ci.getSubtotal()) %> ₫</td>
                    <td>
                        <form method="post" action="<%= ctx %>/customerShop" style="display:inline">
                            <input type="hidden" name="action" value="removeCart">
                            <input type="hidden" name="key" value="<%= ci.getKey() %>">
                            <button type="submit" class="btn-remove"><i class="fas fa-times"></i></button>
                        </form>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <!-- ORDER SUMMARY -->
        <div class="summary-card">
            <div class="summary-title"><i class="fas fa-receipt" style="color:#6366f1"></i> Tóm tắt đơn hàng</div>
            <div class="summary-row"><span>Tạm tính</span><span><%= nf.format((long)grandTotal) %> ₫</span></div>
            <div class="summary-row"><span>Thuế VAT (10%)</span><span><%= nf.format((long)(grandTotal * 0.1)) %> ₫</span></div>
            <hr class="summary-divider">
            <div class="summary-total"><span>Tổng cộng</span><span style="color:#ef4444"><%= nf.format((long)(grandTotal * 1.1)) %> ₫</span></div>
            <div class="summary-tax">Đã bao gồm thuế VAT</div>

            <div class="pay-title"><i class="fas fa-credit-card"></i> Chọn phương thức thanh toán</div>

            <!-- CASH -->
            <form method="post" action="<%= ctx %>/customerShop">
                <input type="hidden" name="action"    value="checkout">
                <input type="hidden" name="payMethod" value="cash">
                <button type="submit" class="btn-pay btn-cash">
                    <i class="fas fa-money-bill-wave"></i> Thanh toán tiền mặt
                </button>
            </form>

            <!-- VNPAY -->
            <form method="post" action="<%= ctx %>/customerShop">
                <input type="hidden" name="action"    value="checkout">
                <input type="hidden" name="payMethod" value="vnpay">
                <button type="submit" class="btn-pay btn-vnpay">
                    <span style="font-weight:900;font-size:1rem">VN</span>Pay &nbsp;— Thanh toán online
                </button>
            </form>

            <a href="<%= ctx %>/customerShop?action=parts" class="btn-continue">
                <i class="fas fa-arrow-left"></i> Tiếp tục mua hàng
            </a>
        </div>
    </div>
    <% } %>
</main>

<!-- Hidden update form -->
<form method="post" action="<%= ctx %>/customerShop" id="updateForm" style="display:none">
    <input type="hidden" name="action" value="updateCart">
    <input type="hidden" name="key"      id="updateKey">
    <input type="hidden" name="quantity" id="updateQty">
</form>

<script>
function changeQty(key, newQty) {
    if (newQty < 0) return;
    document.getElementById('updateKey').value = key;
    document.getElementById('updateQty').value = newQty;
    document.getElementById('updateForm').submit();
}
</script>
</body>
</html>
