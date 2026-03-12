package controller;

import dao.*;
import dao.ShopDAO.ShopItem;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class CustomerShopServlet extends HttpServlet {

    private final ShopDAO shopDAO = new ShopDAO();
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    private static final int PAGE_SIZE = 12;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String action = nvl(req.getParameter("action"));
        if (action.isEmpty()) {
            action = "parts";
        }
        try {
            switch (action) {
                case "parts":
                    showParts(req, resp);
                    break;
                case "equipment":
                    showEquipment(req, resp);
                    break;
                case "cart":
                    showCart(req, resp);
                    break;
                case "checkout":
                    showCheckout(req, resp);
                    break;
                case "orderSuccess":
                    showOrderSuccess(req, resp);
                    break;
                case "detail":                          // ← THÊM
                    showDetail(req, resp);              // ← THÊM
                    break;   
                case "vnpay_gateway":
                    Integer invId = (Integer) req.getSession().getAttribute("pendingInvoiceId");
                    String invCode = (String) req.getSession().getAttribute("pendingInvoiceCode");
                    String amt = (String) req.getSession().getAttribute("pendingAmount");
                    if (invId == null) {
                        resp.sendRedirect(req.getContextPath() + "/customerShop?action=cart");
                        return;
                    }
                    req.setAttribute("invoiceId", invId);
                    req.setAttribute("invoiceCode", invCode);
                    req.setAttribute("amount", amt);
                    req.getRequestDispatcher("/vnpayGateway.jsp").forward(req, resp);
                    break;
                default:
                    showParts(req, resp);
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/customerShop?action=parts");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String action = nvl(req.getParameter("action"));
        try {
            switch (action) {
                case "addToCart":
                    handleAddToCart(req, resp, me);
                    break;
                case "updateCart":
                    handleUpdateCart(req, resp);
                    break;
                case "removeCart":
                    handleRemoveCart(req, resp);
                    break;
                case "clearCart":
                    handleClearCart(req, resp);
                    break;
                case "checkout":
                    handleCheckout(req, resp, me);
                    break;
                case "vnpay_confirm":
                    handleVnpayConfirm(req, resp);
                    break;
                case "vnpay_cancel":
                    handleVnpayCancel(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/customerShop?action=cart");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("shopFlashError", "Có lỗi xảy ra: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/customerShop?action=cart");
        }
    }

    // ── PAGES ────────────────────────────────────────────────────────
    private void showParts(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String kw = nvl(req.getParameter("keyword")), catId = nvl(req.getParameter("categoryId")), sort = nvl(req.getParameter("sortBy"));
        int page = parseInt(req.getParameter("page"), 1);
        int total = shopDAO.countAvailableParts(kw, catId);
        req.setAttribute("items", shopDAO.getAvailableParts(kw, catId, sort, page, PAGE_SIZE));
        req.setAttribute("categories", shopDAO.getPartCategories());
        req.setAttribute("keyword", kw);
        req.setAttribute("categoryId", catId);
        req.setAttribute("sortBy", sort);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.setAttribute("total", total);
        req.setAttribute("cartCount", getCartCount(req));
        req.getRequestDispatcher("/customerShopParts.jsp").forward(req, resp);
    }

    private void showEquipment(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String kw = nvl(req.getParameter("keyword")), catId = nvl(req.getParameter("categoryId")), sort = nvl(req.getParameter("sortBy"));
        int page = parseInt(req.getParameter("page"), 1);
        int total = shopDAO.countAvailableEquipment(kw, catId);
        req.setAttribute("items", shopDAO.getAvailableEquipment(kw, catId, sort, page, PAGE_SIZE));
        req.setAttribute("categories", shopDAO.getEquipmentCategories());
        req.setAttribute("keyword", kw);
        req.setAttribute("categoryId", catId);
        req.setAttribute("sortBy", sort);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.setAttribute("total", total);
        req.setAttribute("cartCount", getCartCount(req));
        req.getRequestDispatcher("/customerShopEquipment.jsp").forward(req, resp);
    }

    private void showCart(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Map<String, CartItem> cart = getCart(req);
        double grand = cart.values().stream().mapToDouble(CartItem::getSubtotal).sum();
        String fs = (String) req.getSession().getAttribute("shopFlashSuccess");
        String fe = (String) req.getSession().getAttribute("shopFlashError");
        req.getSession().removeAttribute("shopFlashSuccess");
        req.getSession().removeAttribute("shopFlashError");
        req.setAttribute("cartList", new ArrayList<>(cart.values()));
        req.setAttribute("grandTotal", grand);
        req.setAttribute("cartCount", cart.size());
        req.setAttribute("flashSuccess", fs);
        req.setAttribute("flashError", fe);
        req.getRequestDispatcher("/customerCart.jsp").forward(req, resp);
    }

    private void showCheckout(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Map<String, CartItem> cart = getCart(req);
        if (cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customerShop?action=cart");
            return;
        }
        double sub = cart.values().stream().mapToDouble(CartItem::getSubtotal).sum();
        double tax = sub * 0.10;
        req.setAttribute("cartList", new ArrayList<>(cart.values()));
        req.setAttribute("subtotal", sub);
        req.setAttribute("tax", tax);
        req.setAttribute("grandTotal", sub + tax);
        req.setAttribute("cartCount", cart.size());
        req.getRequestDispatcher("/customerCheckout.jsp").forward(req, resp);
    }

    private void showOrderSuccess(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        req.setAttribute("invoiceCode", req.getSession().getAttribute("lastOrderCode"));
        req.setAttribute("payMethod", req.getSession().getAttribute("lastPayMethod"));
        req.getSession().removeAttribute("lastOrderCode");
        req.getSession().removeAttribute("lastPayMethod");
        req.getRequestDispatcher("/customerOrderSuccess.jsp").forward(req, resp);
    }
    
        private void showDetail(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String itemType = nvl(req.getParameter("itemType")); // "PART" hoặc "EQUIPMENT"
        int id = parseInt(req.getParameter("id"), 0);

        if (id == 0 || (!itemType.equals("PART") && !itemType.equals("EQUIPMENT"))) {
            resp.sendRedirect(req.getContextPath() + "/customerShop?action=parts");
            return;
        }

        ShopItem item = "PART".equals(itemType)
                ? shopDAO.getPartById(id)
                : shopDAO.getEquipmentById(id);

        if (item == null) {
            resp.sendRedirect(req.getContextPath() + "/customerShop?action="
                    + ("PART".equals(itemType) ? "parts" : "equipment"));
            return;
        }

        req.setAttribute("item", item);
        req.setAttribute("itemType", itemType);
        req.setAttribute("cartCount", getCartCount(req));
        req.getRequestDispatcher("/customerShopDetail.jsp").forward(req, resp);
    }
    // ── CART HANDLERS ────────────────────────────────────────────────
   private void handleAddToCart(HttpServletRequest req, HttpServletResponse resp, User me) throws Exception {
    String itemType = nvl(req.getParameter("itemType"));
    int typeId = parseInt(req.getParameter("typeId"), 0);
    int qty = parseInt(req.getParameter("quantity"), 1);
    
    // EQUIPMENT chỉ cho phép 1 unit per order
    if ("EQUIPMENT".equals(itemType)) {
        qty = 1;
    }
    
    String backAction = "PART".equals(itemType) ? "parts" : "equipment";

    ShopItem si = "PART".equals(itemType) ? shopDAO.getPartById(typeId) : shopDAO.getEquipmentById(typeId);
    if (si == null || si.availableQty <= 0) {
        req.getSession().setAttribute("shopFlashError", "Sản phẩm không còn hàng!");
        resp.sendRedirect(req.getContextPath() + "/customerShop?action=" + backAction);
        return;
    }

    Map<String, CartItem> cart = getCart(req);
    String key = itemType + "_" + typeId;
    
    if ("EQUIPMENT".equals(itemType)) {
        // Equipment: không cộng dồn, luôn set = 1
        if (!cart.containsKey(key)) {
            cart.put(key, new CartItem(typeId, itemType, si.name, si.categoryName,
                    si.unitPrice, 1, 1));
        } else {
            req.getSession().setAttribute("shopFlashError", 
                "\"" + si.name + "\" đã có trong giỏ hàng!");
            resp.sendRedirect(req.getContextPath() + "/customerShop?action=" + backAction);
            return;
        }
    } else {
        // PART: giữ nguyên logic cũ
        if (cart.containsKey(key)) {
            CartItem ex = cart.get(key);
            ex.setQuantity(Math.min(ex.getQuantity() + qty, si.availableQty));
            ex.setMaxQty(si.availableQty);
        } else {
            cart.put(key, new CartItem(typeId, itemType, si.name, si.categoryName,
                    si.unitPrice, Math.min(qty, si.availableQty), si.availableQty));
        }
    }
    
    saveCart(req, cart);
    req.getSession().setAttribute("shopFlashSuccess", "Đã thêm \"" + si.name + "\" vào giỏ hàng!");
    resp.sendRedirect(req.getContextPath() + "/customerShop?action=" + backAction);
}

    private void handleUpdateCart(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String key = nvl(req.getParameter("key"));
        int qty = parseInt(req.getParameter("quantity"), 1);
        Map<String, CartItem> cart = getCart(req);
        if (cart.containsKey(key)) {
            if (qty <= 0) {
                cart.remove(key);
            } else {
                cart.get(key).setQuantity(Math.min(qty, cart.get(key).getMaxQty()));
            }
            saveCart(req, cart);
        }
        resp.sendRedirect(req.getContextPath() + "/customerShop?action=cart");
    }

    private void handleRemoveCart(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Map<String, CartItem> cart = getCart(req);
        cart.remove(nvl(req.getParameter("key")));
        saveCart(req, cart);
        resp.sendRedirect(req.getContextPath() + "/customerShop?action=cart");
    }

    private void handleClearCart(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        saveCart(req, new LinkedHashMap<>());
        resp.sendRedirect(req.getContextPath() + "/customerShop?action=cart");
    }

    // ── CHECKOUT ─────────────────────────────────────────────────────
    private void handleCheckout(HttpServletRequest req, HttpServletResponse resp, User me) throws Exception {
        String payMethod = nvl(req.getParameter("payMethod"));
        Map<String, CartItem> cart = getCart(req);
        if (cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customerShop?action=cart");
            return;
        }

        // Build items
        List<InvoiceItem> items = new ArrayList<>();
        for (CartItem ci : cart.values()) {
            InvoiceItem ii = new InvoiceItem();
            ii.setItemName(ci.getName() + (ci.getQuantity() > 1 ? " x" + ci.getQuantity() : ""));
            ii.setItemType(ci.getItemType());
            ii.setQuantity(ci.getQuantity());
            ii.setUnitPrice(BigDecimal.valueOf(ci.getUnitPrice()));
            ii.setTotalPrice(BigDecimal.valueOf(ci.getSubtotal()));
            items.add(ii);
        }

        // Tạo invoice trực tiếp
        Invoice inv = createShopInvoice(me.getId(), items, me.getId());

        // Deduct stock
        deductInventory(cart, me.getId(), inv.getId());

        if ("cash".equals(payMethod)) {
            paymentDAO.createPayment(inv.getId(), me.getId(), inv.getTotalAmount(),
                    "CASH", "SUCCESS", null, "Thanh toán tiền mặt");
            saveCart(req, new LinkedHashMap<>());
            req.getSession().setAttribute("lastOrderCode", inv.getInvoiceCode());
            req.getSession().setAttribute("lastPayMethod", "cash");
            resp.sendRedirect(req.getContextPath() + "/customerShop?action=orderSuccess");
        } else {
            Payment pay = paymentDAO.createPayment(inv.getId(), me.getId(), inv.getTotalAmount(),
                    "VNPAY", "PENDING", null, "Khởi tạo VNPay");
            req.getSession().setAttribute("pendingPaymentId", pay.getId());
            req.getSession().setAttribute("pendingInvoiceId", inv.getId());
            req.getSession().setAttribute("pendingInvoiceCode", inv.getInvoiceCode());
            req.getSession().setAttribute("pendingAmount",
                    inv.getTotalAmount() != null ? inv.getTotalAmount().toPlainString() : "0");
            req.getSession().setAttribute("pendingFromShop", Boolean.TRUE);
            saveCart(req, new LinkedHashMap<>());
            resp.sendRedirect(req.getContextPath() + "/customerShop?action=vnpay_gateway");
        }
    }

    private void handleVnpayConfirm(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Integer payId = (Integer) req.getSession().getAttribute("pendingPaymentId");
        String code = (String) req.getSession().getAttribute("pendingInvoiceCode");
        if (payId == null) {
            resp.sendRedirect(req.getContextPath() + "/customerShop?action=parts");
            return;
        }
        paymentDAO.updateStatus(payId, "SUCCESS", "VNPAY" + System.currentTimeMillis());
        clearVnpaySession(req);
        req.getSession().setAttribute("lastOrderCode", code);
        req.getSession().setAttribute("lastPayMethod", "vnpay");
        resp.sendRedirect(req.getContextPath() + "/customerShop?action=orderSuccess");
    }

    private void handleVnpayCancel(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Integer payId = (Integer) req.getSession().getAttribute("pendingPaymentId");
        if (payId != null) {
            paymentDAO.updateStatus(payId, "CANCELLED", null);
        }
        clearVnpaySession(req);
        resp.sendRedirect(req.getContextPath() + "/customerShop?action=cart");
    }

    // ── INTERNAL HELPERS ─────────────────────────────────────────────
    private Invoice createShopInvoice(int customerId, List<InvoiceItem> items, int createdBy) throws Exception {
        BigDecimal sub = BigDecimal.ZERO;
        for (InvoiceItem it : items) {
            sub = sub.add(it.getTotalPrice());
        }
        BigDecimal taxPct = new BigDecimal("10");
        BigDecimal taxAmt = sub.multiply(taxPct).divide(new BigDecimal("100"));
        BigDecimal total = sub.add(taxAmt);
        java.sql.Date due = new java.sql.Date(System.currentTimeMillis() + 7L * 86400 * 1000);

        // Generate code
        String prefix = "INV" + new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date()) + "-";
        String code;
        try (Connection cx = util.DBConnection.getConnection(); PreparedStatement ps = cx.prepareStatement("SELECT COUNT(*) FROM invoices WHERE invoice_code LIKE ?")) {
            ps.setString(1, prefix + "%");
            ResultSet rs = ps.executeQuery();
            code = prefix + String.format("%04d", (rs.next() ? rs.getInt(1) : 0) + 1);
        }

        try (Connection c = util.DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                PreparedStatement ps = c.prepareStatement(
                        "INSERT INTO invoices (invoice_code,customer_id,invoice_type,subtotal,tax_percent,"
                        + "tax_amount,total_amount,status,due_date,notes,created_by) VALUES (?,?,'PURCHASE',?,?,?,?,'UNPAID',?,?,?)",
                        Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, code);
                ps.setInt(2, customerId);
                ps.setBigDecimal(3, sub);
                ps.setBigDecimal(4, taxPct);
                ps.setBigDecimal(5, taxAmt);
                ps.setBigDecimal(6, total);
                ps.setDate(7, due);
                ps.setString(8, "Đơn mua hàng online");
                ps.setInt(9, createdBy);
                ps.executeUpdate();
                int invId = -1;
                try (ResultSet k = ps.getGeneratedKeys()) {
                    if (k.next()) {
                        invId = k.getInt(1);
                    }
                }

                PreparedStatement psi = c.prepareStatement(
                        "INSERT INTO invoice_items (invoice_id,item_name,item_type,quantity,unit_price,total_price) VALUES (?,?,?,?,?,?)");
                for (InvoiceItem it : items) {
                    psi.setInt(1, invId);
                    psi.setString(2, it.getItemName());
                    psi.setString(3, it.getItemType());
                    psi.setInt(4, it.getQuantity());
                    psi.setBigDecimal(5, it.getUnitPrice());
                    psi.setBigDecimal(6, it.getTotalPrice());
                    psi.addBatch();
                }
                psi.executeBatch();
                c.commit();
                return invoiceDAO.getById(invId);
            } catch (Exception e) {
                c.rollback();
                throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    private void deductInventory(Map<String, CartItem> cart, int customerId, int invoiceId) throws Exception {
    try (Connection c = util.DBConnection.getConnection()) {
        c.setAutoCommit(false);
        try {
            for (CartItem ci : cart.values()) {
                boolean isPart = "PART".equals(ci.getItemType());
                String sqlFind = isPart
                        ? "SELECT id FROM part_units WHERE part_type_id=? AND status='AVAILABLE' LIMIT ?"
                        : "SELECT id FROM equipment_units WHERE equipment_type_id=? AND status='AVAILABLE' LIMIT ?"; // fix LIMIT ?
                PreparedStatement psF = c.prepareStatement(sqlFind);
                psF.setInt(1, ci.getTypeId());
                psF.setInt(2, ci.getQuantity()); // cả PART lẫn EQUIPMENT đều dùng quantity
                ResultSet rs = psF.executeQuery();

                while (rs.next()) {
                    int uid = rs.getInt("id");
                    String tbl = isPart ? "part_units" : "equipment_units";
                    c.prepareStatement("UPDATE " + tbl + " SET status='INUSE' WHERE id=" + uid).executeUpdate();

                    PreparedStatement psTxn = c.prepareStatement(
                            "INSERT INTO inventory_transactions "
                            + "(item_type,item_unit_id,action,transaction_type,performed_by,ref_order_id,note) "
                            + "VALUES (?,?,'EXPORT_SALE','PURCHASE',?,?,'Bán hàng online')");
                    psTxn.setString(1, ci.getItemType());
                    psTxn.setInt(2, uid);
                    psTxn.setInt(3, customerId);
                    psTxn.setInt(4, invoiceId);
                    psTxn.executeUpdate();

                    if (!isPart) {
                        java.sql.Date purchasedDate = new java.sql.Date(System.currentTimeMillis());
                        java.time.LocalDate warrantyExpires = java.time.LocalDate.now().plusMonths(12);
                        PreparedStatement psCe = c.prepareStatement(
                                "INSERT INTO customer_equipment "
                                + "(customer_id, equipment_unit_id, source, purchased_date, warranty_expires, notes) "
                                + "VALUES (?, ?, 'INTERNAL', ?, ?, ?)");
                        psCe.setInt(1, customerId);
                        psCe.setInt(2, uid);
                        psCe.setDate(3, purchasedDate);
                        psCe.setDate(4, java.sql.Date.valueOf(warrantyExpires));
                        psCe.setString(5, "Mua qua shop online - Invoice " + invoiceId);
                        psCe.executeUpdate();
                    }
                }
            }
            c.commit();
        } catch (Exception e) {
            c.rollback();
            throw e;
        } finally {
            c.setAutoCommit(true);
        }
    }
}

    private void clearVnpaySession(HttpServletRequest req) {
        req.getSession().removeAttribute("pendingPaymentId");
        req.getSession().removeAttribute("pendingInvoiceId");
        req.getSession().removeAttribute("pendingInvoiceCode");
        req.getSession().removeAttribute("pendingAmount");
        req.getSession().removeAttribute("pendingFromShop");
    }

    @SuppressWarnings("unchecked")
    private Map<String, CartItem> getCart(HttpServletRequest req) {
        Object o = req.getSession().getAttribute("shopCart");
        return (o instanceof Map) ? (Map<String, CartItem>) o : new LinkedHashMap<>();
    }

    private void saveCart(HttpServletRequest req, Map<String, CartItem> cart) {
        req.getSession().setAttribute("shopCart", cart);
    }

    private int getCartCount(HttpServletRequest req) {
        return getCart(req).size();
    }

    private String nvl(String s) {
        return s != null ? s.trim() : "";
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }
}
