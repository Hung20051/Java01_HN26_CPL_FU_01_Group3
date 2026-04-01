package dao;

import model.WorkTask;
import util.DBConnection;
import java.sql.*;
import java.util.*;

/**
 * DAO dành riêng cho Technician. Dùng đúng tên bảng/cột của project mới:
 * work_tasks : id, request_id, technician_id, task_type, task_details, status,
 * created_at work_assignments: id, task_id, assigned_by, assigned_to,
 * estimated_duration, required_skills, priority, created_at service_requests:
 * id, request_code, customer_id, contract_id, title, description, priority,
 * status, assigned_to, assigned_at contracts : id, contract_code,
 * contract_type, status users : id, full_name, address_full
 */
public class TechnicianTaskDAO {

    // ─────────────────────────────────────────────────────────────────────
    // Inner DTO — một dòng task đầy đủ thông tin để hiển thị
    // ─────────────────────────────────────────────────────────────────────
    public static class TaskRow {

        public WorkTask task;
        public String requestCode;
        public String requestTitle;
        public String requestStatus;
        public String priority;         // từ service_requests
        public String customerName;
        public String customerPhone;
        public String customerAddress;  // users.address_full
        public String contractCode;
        public String contractType;
        public Integer contractId;
        public String assignPriority;   // từ work_assignments.priority
        public String requiredSkills;
        public java.time.LocalDateTime assignedAt; // work_assignments.created_at
    }

    // ─────────────────────────────────────────────────────────────────────
    // DASHBOARD STATS
    // ─────────────────────────────────────────────────────────────────────
    public Map<String, Integer> getStatsForTechnician(int technicianId) throws Exception {
        String sql = """
            SELECT
              COUNT(*)                                       AS total,
              SUM(status = 'Assigned')                       AS assigned,
              SUM(status = 'In Progress')                    AS in_progress,
              SUM(status = 'Completed')                      AS completed,
              SUM(status = 'Cancelled')                      AS cancelled
            FROM work_tasks
            WHERE technician_id = ?
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                Map<String, Integer> m = new LinkedHashMap<>();
                if (rs.next()) {
                    m.put("total", rs.getInt("total"));
                    m.put("assigned", rs.getInt("assigned"));
                    m.put("inProgress", rs.getInt("in_progress"));
                    m.put("completed", rs.getInt("completed"));
                    m.put("cancelled", rs.getInt("cancelled"));
                }
                return m;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // TASK LIST (paginated + filter)
    // ─────────────────────────────────────────────────────────────────────
    public List<TaskRow> findByTechnician(int technicianId, String keyword,
            String status, int page, int pageSize) throws Exception {

        StringBuilder sql = new StringBuilder("""
        SELECT
            wt.id, wt.request_id, wt.technician_id, wt.task_type,
            wt.task_details, wt.status, wt.created_at,
            sr.request_code, sr.title AS request_title,
            sr.status      AS request_status,
            sr.priority,
            sr.contract_id,
            uc.full_name   AS customer_name,
            uc.phone       AS customer_phone,
            uc.address_full AS customer_address,
            c.contract_code, c.contract_type,
            wa.priority    AS assign_priority,
            wa.required_skills,
            wa.created_at  AS assigned_at
        FROM work_tasks wt
        JOIN work_assignments wa ON wa.task_id = wt.id
        LEFT JOIN service_requests sr ON sr.id = wt.request_id
        LEFT JOIN users uc            ON uc.id = sr.customer_id
        LEFT JOIN contracts c         ON c.id  = sr.contract_id
        WHERE wa.assigned_to = ?
    """);

        List<Object> params = new ArrayList<>();
        params.add(technicianId);

        if (status != null && !status.isEmpty()) {
            sql.append(" AND wt.status = ?");
            params.add(status);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (sr.request_code LIKE ? OR sr.title LIKE ? OR wt.task_details LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        sql.append(" ORDER BY wt.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<TaskRow> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }

        return list;
    }

    public int countByTechnician(int technicianId, String keyword, String status) throws Exception {
        StringBuilder sql = new StringBuilder("""
    SELECT COUNT(DISTINCT wt.id)
    FROM work_tasks wt
    JOIN work_assignments wa ON wa.task_id = wt.id
    LEFT JOIN service_requests sr ON sr.id = wt.request_id
    WHERE wa.assigned_to = ?
""");
        List<Object> params = new ArrayList<>();
        params.add(technicianId);

        if (status != null && !status.isEmpty()) {
            sql.append(" AND wt.status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (sr.request_code LIKE ? OR sr.title LIKE ? OR wt.task_details LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // TASK DETAIL (theo id + technician_id để bảo mật)
    // ─────────────────────────────────────────────────────────────────────
    public TaskRow findByIdAndTechnician(int taskId, int technicianId) throws Exception {
        String sql = """
            SELECT
                wt.id, wt.request_id, wt.technician_id, wt.task_type,
                wt.task_details, wt.status, wt.created_at,
                sr.request_code, sr.title AS request_title,
                sr.description AS request_description,
                sr.status      AS request_status,
                sr.priority,
                sr.contract_id,
                uc.full_name   AS customer_name,
                uc.phone       AS customer_phone,
                uc.address_full AS customer_address,
                c.contract_code, c.contract_type,
                wa.priority    AS assign_priority,
                wa.required_skills,
                wa.estimated_duration,
                wa.created_at  AS assigned_at
            FROM work_tasks wt
            LEFT JOIN service_requests sr ON sr.id = wt.request_id
            LEFT JOIN users uc            ON uc.id = sr.customer_id
            LEFT JOIN contracts c         ON c.id  = sr.contract_id
            LEFT JOIN work_assignments wa ON wa.task_id = wt.id
            WHERE wt.id = ? AND wa.assigned_to = ?
            LIMIT 1
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.setInt(2, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // UPDATE STATUS
    // ─────────────────────────────────────────────────────────────────────
    public boolean updateStatus(int taskId, int technicianId, String newStatus) throws Exception {
        String sql = "UPDATE work_tasks\n"
                + "SET status = ?\n"
                + "WHERE id = ?\n"
                + "AND id IN (\n"
                + "    SELECT task_id FROM work_assignments WHERE assigned_to = ?\n"
                + ")";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, taskId);
            ps.setInt(3, technicianId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // WORK HISTORY (tất cả task, không filter status)
    // ─────────────────────────────────────────────────────────────────────
    public List<TaskRow> getWorkHistory(int technicianId, int page, int pageSize) throws Exception {
        String sql = """
    SELECT
        wt.id, wt.request_id, wt.technician_id, wt.task_type,
        wt.task_details, wt.status, wt.created_at,
        sr.request_code, sr.title AS request_title,
        sr.description AS request_description,
        sr.status      AS request_status,
        sr.priority,
        sr.contract_id,
        uc.full_name   AS customer_name,
        uc.phone       AS customer_phone,
        uc.address_full AS customer_address,
        c.contract_code, c.contract_type,
        wa.priority    AS assign_priority,
        wa.required_skills,
        wa.estimated_duration,
        wa.created_at  AS assigned_at
    FROM work_tasks wt
    LEFT JOIN service_requests sr ON sr.id = wt.request_id
    LEFT JOIN users uc            ON uc.id = sr.customer_id
    LEFT JOIN contracts c         ON c.id  = sr.contract_id
    LEFT JOIN work_assignments wa ON wa.task_id = wt.id
    WHERE wt.id = ? AND wt.technician_id = ?
    LIMIT 1
""";

        List<TaskRow> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, pageSize);
            ps.setInt(3, (page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public int countWorkHistory(int technicianId) throws Exception {
        String sql = "SELECT COUNT(*) FROM work_tasks WHERE technician_id = ? AND status IN ('Completed','Cancelled')";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // MAPPER
    // ─────────────────────────────────────────────────────────────────────
    private TaskRow mapRow(ResultSet rs) throws SQLException {
        TaskRow row = new TaskRow();

        WorkTask t = new WorkTask();
        t.setId(rs.getInt("id"));
        int reqId = rs.getInt("request_id");
        if (!rs.wasNull()) {
            t.setRequestId(reqId);
        }
        t.setTechnicianId(rs.getInt("technician_id"));
        t.setTaskType(rs.getString("task_type"));
        t.setTaskDetails(rs.getString("task_details"));
        t.setStatus(rs.getString("status"));
        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) {
            t.setCreatedAt(cat.toLocalDateTime());
        }
        row.task = t;

        try {
            row.requestCode = rs.getString("request_code");
        } catch (Exception ignored) {
        }
        try {
            row.requestTitle = rs.getString("request_title");
        } catch (Exception ignored) {
        }
        try {
            row.requestStatus = rs.getString("request_status");
        } catch (Exception ignored) {
        }
        try {
            row.priority = rs.getString("priority");
        } catch (Exception ignored) {
        }
        try {
            row.customerName = rs.getString("customer_name");
        } catch (Exception ignored) {
        }
        try {
            row.customerPhone = rs.getString("customer_phone");
        } catch (Exception ignored) {
        }
        try {
            row.customerAddress = rs.getString("customer_address");
        } catch (Exception ignored) {
        }
        try {
            row.contractCode = rs.getString("contract_code");
        } catch (Exception ignored) {
        }
        try {
            row.contractType = rs.getString("contract_type");
        } catch (Exception ignored) {
        }
        try {
            int cid = rs.getInt("contract_id");
            if (!rs.wasNull()) {
                row.contractId = cid;
            }
        } catch (Exception ignored) {
        }
        try {
            row.assignPriority = rs.getString("assign_priority");
        } catch (Exception ignored) {
        }
        try {
            row.requiredSkills = rs.getString("required_skills");
        } catch (Exception ignored) {
        }
        try {
            Timestamp at = rs.getTimestamp("assigned_at");
            if (at != null) {
                row.assignedAt = at.toLocalDateTime();
            }
        } catch (Exception ignored) {
        }

        return row;
    }
}
