/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class FinanceDAO {

    // ── Tổng quan tài chính ──────────────────────────────────────────────────
    /**
     * Tổng doanh thu bán hàng (PURCHASE, status=PAID)
     */
    public BigDecimal getTotalSaleRevenue() throws Exception {
        String sql = """
            SELECT COALESCE(SUM(p.amount), 0)
            FROM payments p
            JOIN invoices inv ON inv.id = p.invoice_id
            WHERE p.status = 'SUCCESS'
              AND inv.invoice_type = 'PURCHASE'
            """;
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        }
    }

    /**
     * Tổng doanh thu sửa chữa (REPAIR, status=PAID)
     */
    public BigDecimal getTotalRepairRevenue() throws Exception {
        String sql = """
            SELECT COALESCE(SUM(p.amount), 0)
            FROM payments p
            JOIN invoices inv ON inv.id = p.invoice_id
            WHERE p.status = 'SUCCESS'
              AND inv.invoice_type = 'REPAIR'
            """;
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        }
    }

    /**
     * Số hóa đơn chưa thanh toán
     */
    public int countUnpaidInvoices() throws Exception {
        String sql = "SELECT COUNT(*) FROM invoices WHERE status = 'UNPAID'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /**
     * Tổng tiền chưa thu (unpaid invoices)
     */
    public BigDecimal getTotalUnpaidAmount() throws Exception {
        String sql = "SELECT COALESCE(SUM(total_amount),0) FROM invoices WHERE status='UNPAID'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        }
    }

    // ── Doanh thu theo tháng (12 tháng gần nhất) ─────────────────────────────
    public static class MonthlyRevenue {

        public String month;       // "YYYY-MM"
        public BigDecimal sale;
        public BigDecimal repair;
    }

    public List<MonthlyRevenue> getMonthlyRevenue(int months) throws Exception {
        String sql = """
            SELECT
                DATE_FORMAT(p.created_at, '%Y-%m') AS month,
                COALESCE(SUM(CASE WHEN inv.invoice_type='PURCHASE' THEN p.amount ELSE 0 END),0) AS sale,
                COALESCE(SUM(CASE WHEN inv.invoice_type='REPAIR'   THEN p.amount ELSE 0 END),0) AS repair
            FROM payments p
            JOIN invoices inv ON inv.id = p.invoice_id
            WHERE p.status = 'SUCCESS'
              AND p.created_at >= DATE_SUB(NOW(), INTERVAL ? MONTH)
            GROUP BY month
            ORDER BY month ASC
            """;
        List<MonthlyRevenue> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, months);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MonthlyRevenue mr = new MonthlyRevenue();
                    mr.month = rs.getString("month");
                    mr.sale = rs.getBigDecimal("sale");
                    mr.repair = rs.getBigDecimal("repair");
                    list.add(mr);
                }
            }
        }
        return list;
    }

    // ── Danh sách chi tiết giao dịch (cho bảng + export Excel) ───────────────
    public static class FinanceRow {

        public int id;
        public String paymentCode;
        public String invoiceCode;
        public String customerName;
        public String invoiceType;   // PURCHASE | REPAIR
        public String paymentMethod; // CASH | VNPAY
        public BigDecimal amount;
        public String status;        // SUCCESS | PENDING | FAILED
        public Timestamp createdAt;
    }

    /**
     * Lấy danh sách giao dịch có lọc.
     *
     * @param type "PURCHASE" | "REPAIR" | "" (tất cả)
     * @param fromDate "yyyy-MM-dd" hoặc ""
     * @param toDate "yyyy-MM-dd" hoặc ""
     * @param keyword tên KH / mã hóa đơn
     * @param page 1-based
     * @param pageSize số dòng mỗi trang
     */
    public List<FinanceRow> getRows(String type, String fromDate, String toDate,
            String keyword, int page, int pageSize) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT p.id, p.payment_code, inv.invoice_code,
                   u.full_name AS customer_name,
                   inv.invoice_type, p.payment_method,
                   p.amount, p.status, p.created_at
            FROM payments p
            JOIN invoices inv ON inv.id = p.invoice_id
            JOIN users    u   ON u.id   = p.customer_id
            WHERE 1=1
            """);
        List<Object> params = new ArrayList<>();

        if (type != null && !type.isBlank()) {
            sql.append(" AND inv.invoice_type = ?");
            params.add(type);
        }
        if (fromDate != null && !fromDate.isBlank()) {
            sql.append(" AND DATE(p.created_at) >= ?");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isBlank()) {
            sql.append(" AND DATE(p.created_at) <= ?");
            params.add(toDate);
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (u.full_name LIKE ? OR inv.invoice_code LIKE ? OR p.payment_code LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        sql.append(" ORDER BY p.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<FinanceRow> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    /**
     * Đếm tổng số dòng (cho phân trang)
     */
    public int countRows(String type, String fromDate, String toDate, String keyword) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*)
            FROM payments p
            JOIN invoices inv ON inv.id = p.invoice_id
            JOIN users    u   ON u.id   = p.customer_id
            WHERE 1=1
            """);
        List<Object> params = new ArrayList<>();
        if (type != null && !type.isBlank()) {
            sql.append(" AND inv.invoice_type = ?");
            params.add(type);
        }
        if (fromDate != null && !fromDate.isBlank()) {
            sql.append(" AND DATE(p.created_at) >= ?");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isBlank()) {
            sql.append(" AND DATE(p.created_at) <= ?");
            params.add(toDate);
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (u.full_name LIKE ? OR inv.invoice_code LIKE ? OR p.payment_code LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /**
     * Lấy TOÀN BỘ giao dịch (không phân trang) — dùng khi export Excel
     */
    public List<FinanceRow> getAllRows(String type, String fromDate, String toDate, String keyword) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT p.id, p.payment_code, inv.invoice_code,
                   u.full_name AS customer_name,
                   inv.invoice_type, p.payment_method,
                   p.amount, p.status, p.created_at
            FROM payments p
            JOIN invoices inv ON inv.id = p.invoice_id
            JOIN users    u   ON u.id   = p.customer_id
            WHERE 1=1
            """);
        List<Object> params = new ArrayList<>();
        if (type != null && !type.isBlank()) {
            sql.append(" AND inv.invoice_type = ?");
            params.add(type);
        }
        if (fromDate != null && !fromDate.isBlank()) {
            sql.append(" AND DATE(p.created_at) >= ?");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isBlank()) {
            sql.append(" AND DATE(p.created_at) <= ?");
            params.add(toDate);
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (u.full_name LIKE ? OR inv.invoice_code LIKE ? OR p.payment_code LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        sql.append(" ORDER BY p.created_at DESC");

        List<FinanceRow> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    // ── private ──────────────────────────────────────────────────────────────
    private FinanceRow mapRow(ResultSet rs) throws SQLException {
        FinanceRow r = new FinanceRow();
        r.id = rs.getInt("id");
        r.paymentCode = rs.getString("payment_code");
        r.invoiceCode = rs.getString("invoice_code");
        r.customerName = rs.getString("customer_name");
        r.invoiceType = rs.getString("invoice_type");
        r.paymentMethod = rs.getString("payment_method");
        r.amount = rs.getBigDecimal("amount");
        r.status = rs.getString("status");
        r.createdAt = rs.getTimestamp("created_at");
        return r;
    }
}
