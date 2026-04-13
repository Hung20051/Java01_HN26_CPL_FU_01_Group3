package controller;

import dao.InvoiceDAO;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

public class CustomerInvoiceServlet extends HttpServlet {
    private final InvoiceDAO dao = new InvoiceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        int cid = me.getId();
        String ctx = req.getContextPath();
        boolean wantJson = isJson(req);

        try {
            // ── DETAIL ───────────────────────────────────────────────
            if ("detail".equals(req.getParameter("action"))) {
                int id = Integer.parseInt(req.getParameter("id"));
                Invoice inv = dao.getById(id);
                if (inv == null || inv.getCustomerId() != cid) {
                    if (wantJson) { writeError(resp, 403, "Forbidden"); return; }
                    resp.sendRedirect(ctx + "/customerInvoices"); return;
                }

                if (wantJson) {
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().print(invoiceToJson(inv));
                    return;
                }

                req.setAttribute("invoice", inv);
                req.getRequestDispatcher("/customerInvoiceDetail.jsp").forward(req, resp);
                return;
            }

            // ── LIST ─────────────────────────────────────────────────
            String status = req.getParameter("status");
            if (status == null) status = "";
            List<Invoice> list = dao.getByCustomerId(cid, status);
            Map<String, Object> summary = dao.getSummary(cid);

            if (wantJson) {
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"total\":").append(list.size()).append(",");
                json.append("\"filterStatus\":\"").append(safe(status)).append("\",");
                // summary map — dump key/value thẳng
                json.append("\"summary\":{");
                if (summary != null) {
                    int si = 0;
                    for (Map.Entry<String, Object> e : summary.entrySet()) {
                        if (si++ > 0) json.append(",");
                        json.append("\"").append(safe(e.getKey())).append("\":");
                        Object v = e.getValue();
                        if (v == null) json.append("null");
                        else if (v instanceof Number) json.append(v);
                        else json.append("\"").append(safe(v.toString())).append("\"");
                    }
                }
                json.append("},");
                json.append("\"invoices\":[");
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) json.append(",");
                    json.append(invoiceToJson(list.get(i)));
                }
                json.append("]}");
                resp.getWriter().print(json.toString());
                return;
            }

            req.setAttribute("invoices",      list);
            req.setAttribute("summary",       summary);
            req.setAttribute("filterStatus",  status);
            req.getRequestDispatcher("/customerInvoices.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(ctx + "/customerDashboard");
        }
    }

    // ── HELPERS ──────────────────────────────────────────────────────

    private String invoiceToJson(Invoice inv) {
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"id\":").append(inv.getId()).append(",");
        json.append("\"invoiceCode\":\"").append(safe(inv.getInvoiceCode())).append("\",");
        json.append("\"invoiceType\":\"").append(safe(inv.getInvoiceType())).append("\",");
        json.append("\"invoiceTypeLabel\":\"").append(safe(inv.getInvoiceTypeLabel())).append("\",");
        json.append("\"status\":\"").append(safe(inv.getStatus())).append("\",");
        json.append("\"statusLabel\":\"").append(safe(inv.getStatusLabel())).append("\",");
        json.append("\"subtotal\":").append(inv.getSubtotal() != null ? inv.getSubtotal() : 0).append(",");
        json.append("\"taxPercent\":").append(inv.getTaxPercent() != null ? inv.getTaxPercent() : 0).append(",");
        json.append("\"taxAmount\":").append(inv.getTaxAmount() != null ? inv.getTaxAmount() : 0).append(",");
        json.append("\"totalAmount\":").append(inv.getTotalAmount() != null ? inv.getTotalAmount() : 0).append(",");
        json.append("\"dueDate\":\"").append(inv.getDueDate() != null ? inv.getDueDate() : "").append("\",");
        json.append("\"notes\":\"").append(safe(inv.getNotes())).append("\",");
        json.append("\"createdAt\":\"").append(inv.getCreatedAt() != null ? inv.getCreatedAt() : "").append("\",");
        json.append("\"requestCode\":\"").append(safe(inv.getRequestCode())).append("\",");
        // items
        json.append("\"items\":[");
        List<InvoiceItem> items = inv.getItems();
        if (items != null) {
            for (int i = 0; i < items.size(); i++) {
                InvoiceItem it = items.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(it.getId()).append(",");
                json.append("\"itemName\":\"").append(safe(it.getItemName())).append("\",");
                json.append("\"itemType\":\"").append(safe(it.getItemType())).append("\",");
                json.append("\"quantity\":").append(it.getQuantity()).append(",");
                json.append("\"unitPrice\":").append(it.getUnitPrice() != null ? it.getUnitPrice() : 0).append(",");
                json.append("\"totalPrice\":").append(it.getTotalPrice() != null ? it.getTotalPrice() : 0);
                json.append("}");
            }
        }
        json.append("]}");
        return json.toString();
    }

    private boolean isJson(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        return accept != null && accept.contains("application/json");
    }

    private void writeError(HttpServletResponse resp, int status, String msg) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setStatus(status);
        resp.getWriter().write("{\"error\":\"" + msg + "\"}");
    }

    private String safe(String s) {
        return s != null ? s.replace("\\", "\\\\").replace("\"", "\\\"") : "";
    }
}