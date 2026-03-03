package dao;

import model.Payment;
import util.DBConnection;
import java.sql.*;
import java.util.*;

public class PaymentDAO {

    /**
     * Tạo payment mới, đồng thời cập nhật trạng thái invoice nếu SUCCESS.
     * Dùng transaction để đảm bảo tính nhất quán.
     */
    public Payment createPayment(int invoiceId, int customerId,
                                  java.math.BigDecimal amount,
                                  String method, String status,
                                  String transactionRef, String note) throws Exception {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // Sinh payment_code: PAY + năm + số thứ tự
            String code = generateCode(con);

            String sql = """
                INSERT INTO payments
                    (payment_code, invoice_id, customer_id, amount, payment_method, status, transaction_ref, note)
                VALUES (?,?,?,?,?,?,?,?)
                """;
            int newId;
            try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, code);
                ps.setInt(2, invoiceId);
                ps.setInt(3, customerId);
                ps.setBigDecimal(4, amount);
                ps.setString(5, method);
                ps.setString(6, status);
                ps.setString(7, transactionRef);
                ps.setString(8, note);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) throw new Exception("Cannot get generated key");
                    newId = keys.getInt(1);
                }
            }

            // Nếu SUCCESS => cập nhật invoice thành PAID
            if ("SUCCESS".equals(status)) {
                try (PreparedStatement ps2 = con.prepareStatement(
                        "UPDATE invoices SET status='PAID' WHERE id=? AND status='UNPAID'")) {
                    ps2.setInt(1, invoiceId);
                    ps2.executeUpdate();
                }
            }

            con.commit();

            // Trả về object vừa tạo
            Payment p = new Payment();
            p.setId(newId);
            p.setPaymentCode(code);
            p.setInvoiceId(invoiceId);
            p.setCustomerId(customerId);
            p.setAmount(amount);
            p.setPaymentMethod(method);
            p.setStatus(status);
            p.setTransactionRef(transactionRef);
            p.setNote(note);
            return p;

        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (SQLException ignored) {}
            throw e;
        } finally {
            if (con != null) try { con.setAutoCommit(true); con.close(); } catch (SQLException ignored) {}
        }
    }

    /**
     * Cập nhật trạng thái payment (dùng khi VNPay callback).
     * Nếu chuyển sang SUCCESS thì đồng thời update invoice.
     */
    public void updateStatus(int paymentId, String status, String transactionRef) throws Exception {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // Lấy invoice_id trước
            int invoiceId = -1;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT invoice_id FROM payments WHERE id=?")) {
                ps.setInt(1, paymentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) invoiceId = rs.getInt("invoice_id");
                }
            }

            // Update payment
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE payments SET status=?, transaction_ref=? WHERE id=?")) {
                ps.setString(1, status);
                ps.setString(2, transactionRef);
                ps.setInt(3, paymentId);
                ps.executeUpdate();
            }

            // Update invoice nếu SUCCESS
            if ("SUCCESS".equals(status) && invoiceId > 0) {
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE invoices SET status='PAID' WHERE id=? AND status='UNPAID'")) {
                    ps.setInt(1, invoiceId);
                    ps.executeUpdate();
                }
            }

            con.commit();
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (SQLException ignored) {}
            throw e;
        } finally {
            if (con != null) try { con.setAutoCommit(true); con.close(); } catch (SQLException ignored) {}
        }
    }

    /** Lấy payment theo ID */
    public Payment getById(int id) throws Exception {
        String sql = """
            SELECT p.*, inv.invoice_code, u.full_name AS customer_name
            FROM payments p
            JOIN invoices inv ON inv.id = p.invoice_id
            JOIN users u      ON u.id  = p.customer_id
            WHERE p.id = ?
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    /** Lấy danh sách payment theo invoice */
    public List<Payment> getByInvoiceId(int invoiceId) throws Exception {
        List<Payment> list = new ArrayList<>();
        String sql = """
            SELECT p.*, inv.invoice_code, u.full_name AS customer_name
            FROM payments p
            JOIN invoices inv ON inv.id = p.invoice_id
            JOIN users u      ON u.id  = p.customer_id
            WHERE p.invoice_id = ?
            ORDER BY p.created_at DESC
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    /** Lấy payment PENDING mới nhất theo invoice (dùng cho VNPay callback) */
    public Payment getPendingByInvoice(int invoiceId) throws Exception {
        String sql = """
            SELECT p.*, inv.invoice_code, u.full_name AS customer_name
            FROM payments p
            JOIN invoices inv ON inv.id = p.invoice_id
            JOIN users u      ON u.id  = p.customer_id
            WHERE p.invoice_id = ? AND p.status = 'PENDING'
            ORDER BY p.created_at DESC LIMIT 1
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    // ── private helpers ──

    private String generateCode(Connection con) throws SQLException {
        int year = java.time.LocalDate.now().getYear();
        String prefix = "PAY" + year + "-";
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT COUNT(*) FROM payments WHERE payment_code LIKE ?")) {
            ps.setString(1, prefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                int count = rs.next() ? rs.getInt(1) : 0;
                return String.format("%s%03d", prefix, count + 1);
            }
        }
    }

    private Payment map(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setId(rs.getInt("id"));
        p.setPaymentCode(rs.getString("payment_code"));
        p.setInvoiceId(rs.getInt("invoice_id"));
        p.setInvoiceCode(rs.getString("invoice_code"));
        p.setCustomerId(rs.getInt("customer_id"));
        p.setCustomerName(rs.getString("customer_name"));
        p.setAmount(rs.getBigDecimal("amount"));
        p.setPaymentMethod(rs.getString("payment_method"));
        p.setStatus(rs.getString("status"));
        p.setTransactionRef(rs.getString("transaction_ref"));
        p.setNote(rs.getString("note"));
        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) p.setCreatedAt(cat.toLocalDateTime());
        Timestamp uat = rs.getTimestamp("updated_at");
        if (uat != null) p.setUpdatedAt(uat.toLocalDateTime());
        return p;
    }
}