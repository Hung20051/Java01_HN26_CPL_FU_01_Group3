package dao;

import model.ServiceRequest;
import model.ServiceRequestEquipment;
import util.DBConnection;
import java.sql.*;
import java.util.*;

public class ServiceRequestDAO {

    private static final String BASE = """
        SELECT sr.*,
               u.full_name    AS customer_name,
               c.contract_code, c.contract_type,
               rv.full_name   AS reviewed_by_name,
               tech.full_name AS assigned_to_name
        FROM service_requests sr
        JOIN users     u    ON u.id    = sr.customer_id
        JOIN contracts c    ON c.id    = sr.contract_id
        LEFT JOIN users rv   ON rv.id  = sr.reviewed_by
        LEFT JOIN users tech ON tech.id= sr.assigned_to
        """;

    public List<ServiceRequest> getByCustomerId(int customerId) throws Exception {
        return getFiltered(customerId, null, null, null, null);
    }

    public List<ServiceRequest> getFiltered(int customerId, String status, String priority,
                                             String fromDate, String toDate) throws Exception {
        List<ServiceRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE + " WHERE sr.customer_id = ?");
        if (status   != null && !status.isEmpty())   sql.append(" AND sr.status = ?");
        if (priority != null && !priority.isEmpty()) sql.append(" AND sr.priority = ?");
        if (fromDate != null && !fromDate.isEmpty()) sql.append(" AND DATE(sr.created_at) >= ?");
        if (toDate   != null && !toDate.isEmpty())   sql.append(" AND DATE(sr.created_at) <= ?");
        sql.append(" ORDER BY sr.created_at DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, customerId);
            if (status   != null && !status.isEmpty())   ps.setString(idx++, status);
            if (priority != null && !priority.isEmpty()) ps.setString(idx++, priority);
            if (fromDate != null && !fromDate.isEmpty()) ps.setString(idx++, fromDate);
            if (toDate   != null && !toDate.isEmpty())   ps.setString(idx++, toDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapSR(rs));
            }
        }
        return list;
    }

    public ServiceRequest getById(int id) throws Exception {
        String sql = BASE + " WHERE sr.id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ServiceRequest sr = mapSR(rs);
                    sr.setEquipmentList(getEquipmentBySR(con, id));
                    return sr;
                }
            }
        }
        return null;
    }

    /** Tạo service request mới với danh sách equipment */
    public int create(ServiceRequest sr, List<Integer> customerEquipmentIds,
                      List<String> issueDescriptions) throws Exception {
        Connection con = DBConnection.getConnection();
        con.setAutoCommit(false);
        try {
            // 1. Insert service_request
            String sql1 = """
                INSERT INTO service_requests
                  (request_code, customer_id, contract_id, title, description, priority)
                VALUES (?, ?, ?, ?, ?, ?)
                """;
            int newId;
            try (PreparedStatement ps = con.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, generateCode(con));
                ps.setInt(2, sr.getCustomerId());
                ps.setInt(3, sr.getContractId());
                ps.setString(4, sr.getTitle());
                ps.setString(5, sr.getDescription());
                ps.setString(6, sr.getPriority());
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) throw new Exception("Failed to get generated key");
                    newId = keys.getInt(1);
                }
            }

            // 2. Insert service_request_equipment rows
            String sql2 = "INSERT INTO service_request_equipment (service_request_id, customer_equipment_id, issue_description) VALUES (?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(sql2)) {
                for (int i = 0; i < customerEquipmentIds.size(); i++) {
                    ps.setInt(1, newId);
                    ps.setInt(2, customerEquipmentIds.get(i));
                    String desc = (issueDescriptions != null && i < issueDescriptions.size())
                                  ? issueDescriptions.get(i) : null;
                    if (desc != null) ps.setString(3, desc); else ps.setNull(3, Types.VARCHAR);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            con.commit();
            return newId;

        } catch (Exception e) {
            con.rollback();
            throw e;
        } finally {
            con.setAutoCommit(true);
            con.close();
        }
    }

    public boolean cancel(int id, int customerId) throws Exception {
        String sql = "UPDATE service_requests SET status='CANCELLED' WHERE id=? AND customer_id=? AND status='PENDING'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id); ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        }
    }

    public Map<String, Integer> getCountsByStatus(int customerId) throws Exception {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) cnt FROM service_requests WHERE customer_id=? GROUP BY status";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) map.put(rs.getString("status"), rs.getInt("cnt"));
            }
        }
        return map;
    }

    private List<ServiceRequestEquipment> getEquipmentBySR(Connection con, int srId) throws SQLException {
        List<ServiceRequestEquipment> list = new ArrayList<>();
        String sql = """
            SELECT sre.*,
                   COALESCE(eu.serial_number, ce.custom_serial) AS display_serial,
                   COALESCE(et.model, ce.custom_name)           AS display_name,
                   ce.source
            FROM service_request_equipment sre
            JOIN customer_equipment ce ON ce.id = sre.customer_equipment_id
            LEFT JOIN equipment_units eu ON eu.id = ce.equipment_unit_id
            LEFT JOIN equipment_types et ON et.id = eu.equipment_type_id
            WHERE sre.service_request_id = ?
            """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, srId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ServiceRequestEquipment e = new ServiceRequestEquipment();
                    e.setId(rs.getInt("id"));
                    e.setServiceRequestId(rs.getInt("service_request_id"));
                    e.setCustomerEquipmentId(rs.getInt("customer_equipment_id"));
                    e.setIssueDescription(rs.getString("issue_description"));
                    e.setDisplaySerial(rs.getString("display_serial"));
                    e.setDisplayName(rs.getString("display_name"));
                    e.setSource(rs.getString("source"));
                    list.add(e);
                }
            }
        }
        return list;
    }

    private String generateCode(Connection con) throws SQLException {
        int year = java.time.Year.now().getValue();
        String sql = "SELECT COUNT(*) FROM service_requests WHERE YEAR(created_at)=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                int seq = rs.next() ? rs.getInt(1) + 1 : 1;
                return String.format("SR%d-%03d", year, seq);
            }
        }
    }

    private ServiceRequest mapSR(ResultSet rs) throws SQLException {
        ServiceRequest sr = new ServiceRequest();
        sr.setId(rs.getInt("id"));
        sr.setRequestCode(rs.getString("request_code"));
        sr.setCustomerId(rs.getInt("customer_id"));
        sr.setCustomerName(rs.getString("customer_name"));
        sr.setContractId(rs.getInt("contract_id"));
        sr.setContractCode(rs.getString("contract_code"));
        sr.setContractType(rs.getString("contract_type"));
        sr.setTitle(rs.getString("title"));
        sr.setDescription(rs.getString("description"));
        sr.setPriority(rs.getString("priority"));
        sr.setStatus(rs.getString("status"));
        int rb = rs.getInt("reviewed_by"); if (!rs.wasNull()) sr.setReviewedBy(rb);
        sr.setReviewedByName(rs.getString("reviewed_by_name"));
        Timestamp rat = rs.getTimestamp("reviewed_at");
        if (rat != null) sr.setReviewedAt(rat.toLocalDateTime());
        sr.setRejectReason(rs.getString("reject_reason"));
        int at = rs.getInt("assigned_to"); if (!rs.wasNull()) sr.setAssignedTo(at);
        sr.setAssignedToName(rs.getString("assigned_to_name"));
        Timestamp aat = rs.getTimestamp("assigned_at");
        if (aat != null) sr.setAssignedAt(aat.toLocalDateTime());
        Timestamp cat2 = rs.getTimestamp("completed_at");
        if (cat2 != null) sr.setCompletedAt(cat2.toLocalDateTime());
        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) sr.setCreatedAt(cat.toLocalDateTime());
        Timestamp uat = rs.getTimestamp("updated_at");
        if (uat != null) sr.setUpdatedAt(uat.toLocalDateTime());
        return sr;
    }
}