package dao;

import model.WorkTask;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WorkTaskDAO {

    public int create(WorkTask task) throws Exception {
        String sql = "INSERT INTO work_tasks (request_id, technician_id, task_type, task_details, status) VALUES (?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (task.getRequestId() != null) ps.setInt(1, task.getRequestId());
            else ps.setNull(1, Types.INTEGER);
            ps.setInt(2, task.getTechnicianId());
            ps.setString(3, task.getTaskType() != null ? task.getTaskType() : "Request");
            ps.setString(4, task.getTaskDetails());
            ps.setString(5, task.getStatus() != null ? task.getStatus() : "Assigned");
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    public boolean hasActiveTaskForTechnician(int requestId, int technicianId) throws Exception {
        String sql = "SELECT COUNT(*) FROM work_tasks WHERE request_id=? AND technician_id=? AND status NOT IN ('Completed','Cancelled')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public List<WorkTask> findByRequestId(int requestId) throws Exception {
        String sql = "SELECT wt.*, u.full_name AS technician_name "
                   + "FROM work_tasks wt JOIN users u ON u.id=wt.technician_id "
                   + "WHERE wt.request_id=? ORDER BY wt.created_at DESC";
        List<WorkTask> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public boolean deleteById(int id) throws Exception {
        String sql = "DELETE FROM work_tasks WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private WorkTask mapRow(ResultSet rs) throws SQLException {
        WorkTask t = new WorkTask();
        t.setId(rs.getInt("id"));
        int reqId = rs.getInt("request_id");
        if (!rs.wasNull()) t.setRequestId(reqId);
        t.setTechnicianId(rs.getInt("technician_id"));
        t.setTaskType(rs.getString("task_type"));
        t.setTaskDetails(rs.getString("task_details"));
        t.setStatus(rs.getString("status"));
        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) t.setCreatedAt(cat.toLocalDateTime());
        try { t.setTechnicianName(rs.getString("technician_name")); } catch (Exception ignored) {}
        return t;
    }
}