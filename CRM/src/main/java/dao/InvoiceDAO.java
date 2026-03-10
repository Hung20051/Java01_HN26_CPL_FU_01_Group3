package dao;

import model.Invoice;
import model.InvoiceItem;
import util.DBConnection;
import java.sql.*;
import java.util.*;

public class InvoiceDAO {

    public List<Invoice> getByCustomerId(int customerId, String status) throws Exception {
        List<Invoice> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT inv.*, u.full_name AS customer_name,
                   sr.request_code, cb.full_name AS created_by_name
            FROM invoices inv
            JOIN users u  ON u.id  = inv.customer_id
            LEFT JOIN service_requests sr ON sr.id = inv.service_request_id
            JOIN users cb ON cb.id = inv.created_by
            WHERE inv.customer_id = ?
            """);
        if (status != null && !status.isEmpty()) {
            sql.append(" AND inv.status = ?");
        }
        sql.append(" ORDER BY inv.created_at DESC");

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            ps.setInt(1, customerId);
            if (status != null && !status.isEmpty()) {
                ps.setString(2, status);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapInvoice(rs));
                }
            }
        }
        return list;
    }

    public Invoice getById(int id) throws Exception {
        String sql = """
            SELECT inv.*, u.full_name AS customer_name,
                   sr.request_code, cb.full_name AS created_by_name
            FROM invoices inv
            JOIN users u  ON u.id  = inv.customer_id
            LEFT JOIN service_requests sr ON sr.id = inv.service_request_id
            JOIN users cb ON cb.id = inv.created_by
            WHERE inv.id = ?
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Invoice inv = mapInvoice(rs);
                    inv.setItems(getItems(con, id));
                    return inv;
                }
            }
        }
        return null;
    }

    public Map<String, Object> getSummary(int customerId) throws Exception {
        Map<String, Object> m = new HashMap<>();
        String sql = """
            SELECT COUNT(*) total,
                   SUM(status='UNPAID') unpaid,
                   SUM(status='PAID') paid,
                   SUM(CASE WHEN status='UNPAID' THEN total_amount ELSE 0 END) unpaid_amt
            FROM invoices WHERE customer_id=?
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m.put("total", rs.getInt("total"));
                    m.put("unpaid", rs.getInt("unpaid"));
                    m.put("paid", rs.getInt("paid"));
                    m.put("unpaidAmt", rs.getBigDecimal("unpaid_amt"));
                }
            }
        }
        return m;
    }

    private List<InvoiceItem> getItems(Connection con, int invoiceId) throws SQLException {
        List<InvoiceItem> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM invoice_items WHERE invoice_id=? ORDER BY id")) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InvoiceItem it = new InvoiceItem();
                    it.setId(rs.getInt("id"));
                    it.setInvoiceId(rs.getInt("invoice_id"));
                    it.setItemName(rs.getString("item_name"));
                    it.setItemType(rs.getString("item_type"));
                    it.setQuantity(rs.getInt("quantity"));
                    it.setUnitPrice(rs.getBigDecimal("unit_price"));
                    it.setTotalPrice(rs.getBigDecimal("total_price"));
                    list.add(it);
                }
            }
        }
        return list;
    }

    private Invoice mapInvoice(ResultSet rs) throws SQLException {
        Invoice inv = new Invoice();
        inv.setId(rs.getInt("id"));
        inv.setInvoiceCode(rs.getString("invoice_code"));
        inv.setCustomerId(rs.getInt("customer_id"));
        inv.setCustomerName(rs.getString("customer_name"));
        int srid = rs.getInt("service_request_id");
        if (!rs.wasNull()) {
            inv.setServiceRequestId(srid);
        }
        inv.setRequestCode(rs.getString("request_code"));
        inv.setInvoiceType(rs.getString("invoice_type"));
        inv.setSubtotal(rs.getBigDecimal("subtotal"));
        inv.setTaxPercent(rs.getBigDecimal("tax_percent"));
        inv.setTaxAmount(rs.getBigDecimal("tax_amount"));
        inv.setTotalAmount(rs.getBigDecimal("total_amount"));
        inv.setStatus(rs.getString("status"));
        java.sql.Date dd = rs.getDate("due_date");
        if (dd != null) {
            inv.setDueDate(dd.toLocalDate());
        }
        inv.setNotes(rs.getString("notes"));
        inv.setCreatedBy(rs.getInt("created_by"));
        inv.setCreatedByName(rs.getString("created_by_name"));
        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) {
            inv.setCreatedAt(cat.toLocalDateTime());
        }
        return inv;
    }

    public boolean updateStatus(int invoiceId, String status) throws Exception {
        String sql = "UPDATE invoices SET status=? WHERE id=?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, invoiceId);
            return ps.executeUpdate() > 0;
        }
    }
}
