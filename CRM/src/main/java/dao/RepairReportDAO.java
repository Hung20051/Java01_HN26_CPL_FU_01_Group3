package dao;

import model.RepairReport;
import model.RepairReportPart;
import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RepairReportDAO {

    private static final String BASE_SELECT = """
    SELECT rr.*,
           u.full_name    AS technician_name,
           u.avatar_url   AS technician_avatar_url,
           sr.request_code, sr.title AS request_title,
           sr.status      AS request_status,
           sr.customer_id,
           cu.full_name   AS customer_name,
           c.contract_type,
           inv.status     AS invoice_status
    FROM repair_reports rr
    JOIN users u              ON u.id  = rr.technician_id
    JOIN service_requests sr  ON sr.id = rr.service_request_id
    JOIN users cu             ON cu.id = sr.customer_id
    JOIN contracts c          ON c.id  = sr.contract_id
    LEFT JOIN invoices inv    ON inv.id = rr.invoice_id
    """;
    // ── Tạo report mới (DRAFT) ─────────────────────────────────────────
    public int create(RepairReport rr) throws Exception {
        String sql = """
            INSERT INTO repair_reports
              (work_task_id, service_request_id, technician_id, report_code,
               diagnosis, work_done, labor_cost, status)
            VALUES (?,?,?,?,?,?,?,'DRAFT')
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, rr.getWorkTaskId());
            ps.setInt(2, rr.getServiceRequestId());
            ps.setInt(3, rr.getTechnicianId());
            ps.setString(4, generateCode(con));
            ps.setString(5, rr.getDiagnosis());
            ps.setString(6, rr.getWorkDone());
            ps.setBigDecimal(7, rr.getLaborCost() != null ? rr.getLaborCost() : BigDecimal.ZERO);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    // ── Update draft ───────────────────────────────────────────────────
    public boolean update(RepairReport rr) throws Exception {
        String sql = """
            UPDATE repair_reports
               SET diagnosis = ?, work_done = ?, labor_cost = ?
             WHERE id = ? AND technician_id = ? AND status = 'DRAFT'
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, rr.getDiagnosis());
            ps.setString(2, rr.getWorkDone());
            ps.setBigDecimal(3, rr.getLaborCost() != null ? rr.getLaborCost() : BigDecimal.ZERO);
            ps.setInt(4, rr.getId());
            ps.setInt(5, rr.getTechnicianId());
            return ps.executeUpdate() > 0;
        }
    }

    // ── Submit report ──────────────────────────────────────────────────
    public boolean submit(int reportId, int technicianId) throws Exception {
        String sql = """
            UPDATE repair_reports
               SET status = 'SUBMITTED', submitted_at = NOW()
             WHERE id = ? AND technician_id = ? AND status = 'DRAFT'
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reportId);
            ps.setInt(2, technicianId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── Set invoice_id sau khi tạo hóa đơn ────────────────────────────
    public boolean setInvoiceId(int reportId, int invoiceId) throws Exception {
        String sql = "UPDATE repair_reports SET invoice_id = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ps.setInt(2, reportId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── Kiểm tra technician đã có report cho task này chưa ────────────
    public boolean existsByWorkTaskId(int workTaskId) throws Exception {
        String sql = "SELECT COUNT(*) FROM repair_reports WHERE work_task_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, workTaskId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public RepairReport findByWorkTaskId(int workTaskId) throws Exception {
        String sql = BASE_SELECT + " WHERE rr.work_task_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, workTaskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RepairReport rr = mapRow(rs);
                    rr.setParts(getPartsByReportId(con, rr.getId()));
                    return rr;
                }
            }
        }
        return null;
    }

    public RepairReport findById(int id) throws Exception {
        String sql = BASE_SELECT + " WHERE rr.id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RepairReport rr = mapRow(rs);
                    rr.setParts(getPartsByReportId(con, rr.getId()));
                    return rr;
                }
            }
        }
        return null;
    }

    // ── Lấy tất cả reports của 1 technician ───────────────────────────
    public List<RepairReport> findByTechnicianId(int technicianId, String status,
                                                  int page, int pageSize) throws Exception {
        StringBuilder sql = new StringBuilder(BASE_SELECT + " WHERE rr.technician_id = ?");
        if (status != null && !status.isEmpty()) sql.append(" AND rr.status = ?");
        sql.append(" ORDER BY rr.created_at DESC LIMIT ? OFFSET ?");

        List<RepairReport> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, technicianId);
            if (status != null && !status.isEmpty()) ps.setString(idx++, status);
            ps.setInt(idx++, pageSize);
            ps.setInt(idx, (page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public int countByTechnicianId(int technicianId, String status) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM repair_reports rr WHERE rr.technician_id = ?");
        if (status != null && !status.isEmpty()) sql.append(" AND rr.status = ?");
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, technicianId);
            if (status != null && !status.isEmpty()) ps.setString(idx, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ── Lấy reports theo service_request ──────────────────────────────
    public List<RepairReport> findByServiceRequestId(int srId) throws Exception {
        String sql = BASE_SELECT + " WHERE rr.service_request_id = ? ORDER BY rr.created_at ASC";
        List<RepairReport> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, srId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RepairReport rr = mapRow(rs);
                    rr.setParts(getPartsByReportId(con, rr.getId()));
                    list.add(rr);
                }
            }
        }
        return list;
    }

    // ── Kiểm tra tất cả task trong SR đã SUBMITTED chưa ───────────────
    public boolean allTasksSubmitted(int serviceRequestId) throws Exception {
        String sql = """
            SELECT COUNT(*) AS total,
                   SUM(CASE WHEN rr.status='SUBMITTED' THEN 1 ELSE 0 END) AS submitted
            FROM work_tasks wt
            LEFT JOIN repair_reports rr ON rr.work_task_id = wt.id
            WHERE wt.request_id = ?
              AND wt.status NOT IN ('Cancelled')
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, serviceRequestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total     = rs.getInt("total");
                    int submitted = rs.getInt("submitted");
                    return total > 0 && total == submitted;
                }
            }
        }
        return false;
    }

    // ── Parts CRUD ─────────────────────────────────────────────────────
    public void saveParts(int reportId, List<RepairReportPart> parts) throws Exception {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // Xóa cũ
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM repair_report_parts WHERE report_id = ?")) {
                    ps.setInt(1, reportId);
                    ps.executeUpdate();
                }
                // Insert mới
                String ins = """
                    INSERT INTO repair_report_parts
                      (report_id, part_type_id, part_name, quantity, unit_price, total_price)
                    VALUES (?,?,?,?,?,?)
                    """;
                try (PreparedStatement ps = con.prepareStatement(ins)) {
                    for (RepairReportPart p : parts) {
                        ps.setInt(1, reportId);
                        ps.setInt(2, p.getPartTypeId());
                        ps.setString(3, p.getPartName());
                        ps.setInt(4, p.getQuantity());
                        ps.setBigDecimal(5, p.getUnitPrice());
                        ps.setBigDecimal(6, p.getTotalPrice());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                con.commit();
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public List<RepairReportPart> getPartsByReportId(Connection con, int reportId) throws SQLException {
        String sql = "SELECT rrp.*, pt.name AS part_name_db FROM repair_report_parts rrp "
                   + "JOIN part_types pt ON pt.id = rrp.part_type_id "
                   + "WHERE rrp.report_id = ? ORDER BY rrp.id";
        List<RepairReportPart> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reportId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RepairReportPart p = new RepairReportPart();
                    p.setId(rs.getInt("id"));
                    p.setReportId(rs.getInt("report_id"));
                    p.setPartTypeId(rs.getInt("part_type_id"));
                    p.setPartName(rs.getString("part_name"));
                    p.setQuantity(rs.getInt("quantity"));
                    p.setUnitPrice(rs.getBigDecimal("unit_price"));
                    p.setTotalPrice(rs.getBigDecimal("total_price"));
                    list.add(p);
                }
            }
        }
        return list;
    }

    // ── Stats cho dashboard ────────────────────────────────────────────
    public java.util.Map<String, Integer> getStatsByTechnician(int technicianId) throws Exception {
        java.util.Map<String, Integer> m = new java.util.LinkedHashMap<>();
        String sql = """
            SELECT
              COUNT(*) AS total,
              SUM(status='DRAFT')     AS draft,
              SUM(status='SUBMITTED') AS submitted
            FROM repair_reports WHERE technician_id = ?
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m.put("total",     rs.getInt("total"));
                    m.put("draft",     rs.getInt("draft"));
                    m.put("submitted", rs.getInt("submitted"));
                }
            }
        }
        return m;
    }

    // ── Helper ─────────────────────────────────────────────────────────
    private String generateCode(Connection con) throws SQLException {
        int year = java.time.Year.now().getValue();
        String sql = "SELECT COUNT(*) FROM repair_reports WHERE YEAR(created_at)=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                int seq = rs.next() ? rs.getInt(1) + 1 : 1;
                return String.format("RPT%d-%03d", year, seq);
            }
        }
    }

    private RepairReport mapRow(ResultSet rs) throws SQLException {
        RepairReport rr = new RepairReport();
        rr.setId(rs.getInt("id"));
        rr.setWorkTaskId(rs.getInt("work_task_id"));
        rr.setServiceRequestId(rs.getInt("service_request_id"));
        rr.setTechnicianId(rs.getInt("technician_id"));
        rr.setReportCode(rs.getString("report_code"));
        rr.setDiagnosis(rs.getString("diagnosis"));
        rr.setWorkDone(rs.getString("work_done"));
        rr.setLaborCost(rs.getBigDecimal("labor_cost"));
        rr.setStatus(rs.getString("status"));
        Timestamp sa = rs.getTimestamp("submitted_at");
        if (sa != null) rr.setSubmittedAt(sa.toLocalDateTime());
        int inv = rs.getInt("invoice_id");
        if (!rs.wasNull()) rr.setInvoiceId(inv);
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) rr.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) rr.setUpdatedAt(ua.toLocalDateTime());
        // Joined
        try { rr.setTechnicianName(rs.getString("technician_name")); }      catch (Exception ignored) {}
        try { rr.setTechnicianAvatarUrl(rs.getString("technician_avatar_url")); } catch (Exception ignored) {}
        try { rr.setRequestCode(rs.getString("request_code")); }            catch (Exception ignored) {}
        try { rr.setRequestTitle(rs.getString("request_title")); }          catch (Exception ignored) {}
        try { rr.setRequestStatus(rs.getString("request_status")); }        catch (Exception ignored) {}
        try { rr.setContractType(rs.getString("contract_type")); }          catch (Exception ignored) {}
        try { rr.setCustomerName(rs.getString("customer_name")); }          catch (Exception ignored) {}
        try { rr.setCustomerId(rs.getInt("customer_id")); }                 catch (Exception ignored) {}
        try { rr.setInvoiceStatus(rs.getString("invoice_status")); } catch (Exception ignored) {}
        return rr;
    }
}