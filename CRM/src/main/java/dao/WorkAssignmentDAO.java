package dao;

import model.WorkAssignment;
import util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WorkAssignmentDAO {

    public int create(WorkAssignment wa) throws Exception {
        String sql = "INSERT INTO work_assignments "
                + "(task_id, assigned_by, assigned_to, assignment_date, estimated_duration, required_skills, priority) "
                + "VALUES (?,?,?,NOW(),?,?,?)";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, wa.getTaskId());
            ps.setInt(2, wa.getAssignedBy());
            ps.setInt(3, wa.getAssignedTo());
            if (wa.getEstimatedDuration() != null) {
                ps.setBigDecimal(4, wa.getEstimatedDuration());
            } else {
                ps.setNull(4, Types.DECIMAL);
            }
            ps.setString(5, wa.getRequiredSkills());
            ps.setString(6, wa.getPriority() != null ? wa.getPriority() : "MEDIUM");
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    public List<WorkAssignment> findByManager(int managerId) throws Exception {
        String sql = "SELECT wa.*, wt.request_id, wt.status AS task_status, "
                + "sr.request_code, sr.title AS request_title, "
                + "u.full_name AS technician_name "
                + "FROM work_assignments wa "
                + "JOIN work_tasks wt ON wt.id = wa.task_id "
                + "LEFT JOIN service_requests sr ON sr.id = wt.request_id "
                + "JOIN users u ON u.id = wa.assigned_to "
                + "WHERE wa.assigned_by = ? "
                + "ORDER BY wa.assignment_date DESC";
        List<WorkAssignment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public WorkAssignment findById(int id) throws Exception {
        String sql = "SELECT wa.*, wt.request_id, wt.status AS task_status, "
                + "sr.request_code, sr.title AS request_title, "
                + "u.full_name AS technician_name "
                + "FROM work_assignments wa "
                + "JOIN work_tasks wt ON wt.id = wa.task_id "
                + "LEFT JOIN service_requests sr ON sr.id = wt.request_id "
                + "JOIN users u ON u.id = wa.assigned_to "
                + "WHERE wa.id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public boolean deleteById(int id) throws Exception {
        String sql = "DELETE FROM work_assignments WHERE id=?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private WorkAssignment mapRow(ResultSet rs) throws SQLException {
        WorkAssignment wa = new WorkAssignment();
        wa.setId(rs.getInt("id"));
        wa.setTaskId(rs.getInt("task_id"));
        wa.setAssignedBy(rs.getInt("assigned_by"));
        wa.setAssignedTo(rs.getInt("assigned_to"));
        Timestamp ad = rs.getTimestamp("assignment_date");
        if (ad != null) {
            wa.setAssignmentDate(ad.toLocalDateTime());
        }
        wa.setEstimatedDuration(rs.getBigDecimal("estimated_duration"));
        wa.setRequiredSkills(rs.getString("required_skills"));
        wa.setPriority(rs.getString("priority"));
        try {
            int rid = rs.getInt("request_id");
            if (!rs.wasNull()) {
                wa.setRequestId(rid);
            }
        } catch (Exception ignored) {
        }
        try {
            wa.setTaskStatus(rs.getString("task_status"));
        } catch (Exception ignored) {
        }
        try {
            wa.setRequestCode(rs.getString("request_code"));
        } catch (Exception ignored) {
        }
        try {
            wa.setRequestTitle(rs.getString("request_title"));
        } catch (Exception ignored) {
        }
        try {
            wa.setTechnicianName(rs.getString("technician_name"));
        } catch (Exception ignored) {
        }
        return wa;
    }
}
