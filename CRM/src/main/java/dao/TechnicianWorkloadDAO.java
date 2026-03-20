package dao;

import model.TechnicianWorkload;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TechnicianWorkloadDAO {

    public TechnicianWorkload findByTechnicianId(int technicianId) throws Exception {
        String sql = "SELECT tw.*, u.full_name AS technician_name, u.email AS technician_email "
                   + "FROM technician_workload tw JOIN users u ON u.id=tw.technician_id "
                   + "WHERE tw.technician_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public List<TechnicianWorkload> findAllTechnicians() throws Exception {
        String sql = "SELECT tw.*, u.full_name AS technician_name, u.email AS technician_email "
                   + "FROM technician_workload tw "
                   + "JOIN users u ON u.id = tw.technician_id "
                   + "JOIN roles r ON r.id = u.role_id "
                   + "WHERE r.name = 'TECHNICIAN' AND u.active = 1 "
                   + "ORDER BY (tw.max_concurrent_tasks - tw.current_active_tasks) DESC";
        List<TechnicianWorkload> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public void ensureExists(int technicianId) throws Exception {
        String sql = "INSERT IGNORE INTO technician_workload "
                   + "(technician_id, current_active_tasks, max_concurrent_tasks) VALUES (?,0,5)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.executeUpdate();
        }
    }

    public boolean increment(int technicianId, int points) throws Exception {
        String sql = "UPDATE technician_workload SET current_active_tasks = current_active_tasks + ?, "
                   + "last_assigned_date = NOW() WHERE technician_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, points);
            ps.setInt(2, technicianId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean decrement(int technicianId, int points) throws Exception {
        String sql = "UPDATE technician_workload SET current_active_tasks = GREATEST(0, current_active_tasks - ?) "
                   + "WHERE technician_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, points);
            ps.setInt(2, technicianId);
            return ps.executeUpdate() > 0;
        }
    }

    private TechnicianWorkload mapRow(ResultSet rs) throws SQLException {
        TechnicianWorkload tw = new TechnicianWorkload();
        tw.setId(rs.getInt("id"));
        tw.setTechnicianId(rs.getInt("technician_id"));
        tw.setCurrentActiveTasks(rs.getInt("current_active_tasks"));
        tw.setMaxConcurrentTasks(rs.getInt("max_concurrent_tasks"));
        Timestamp la = rs.getTimestamp("last_assigned_date");
        if (la != null) tw.setLastAssignedDate(la.toLocalDateTime());
        try { tw.setTechnicianName(rs.getString("technician_name")); }  catch (Exception ignored) {}
        try { tw.setTechnicianEmail(rs.getString("technician_email")); } catch (Exception ignored) {}
        return tw;
    }
}