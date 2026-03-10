package dao;

import model.Contract;
import model.CustomerEquipment;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ContractDAO {

    private static final String BASE = """
        SELECT c.*,
               u.full_name  AS customer_name,
               cb.full_name AS created_by_name,
               (SELECT COUNT(*) FROM contract_equipment ce WHERE ce.contract_id = c.id) AS equipment_count,
               (SELECT COUNT(*) FROM service_requests  sr WHERE sr.contract_id = c.id) AS sr_count
        FROM contracts c
        JOIN users u  ON u.id  = c.customer_id
        JOIN users cb ON cb.id = c.created_by
        """;

    public List<Contract> getByCustomerId(int customerId) throws Exception {
        List<Contract> list = new ArrayList<>();
        String sql = BASE + " WHERE c.customer_id = ? ORDER BY c.created_at DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    public List<Contract> getActiveByCustomerId(int customerId) throws Exception {
        List<Contract> list = new ArrayList<>();
        String sql = BASE + " WHERE c.customer_id = ? AND c.status = 'ACTIVE' ORDER BY c.created_at DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    public Contract getById(int id) throws Exception {
        String sql = BASE + " WHERE c.id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }
        return null;
    }

    /**
     * Lấy equipment list cho contract (dùng cho detail page)
     */
    public List<CustomerEquipment> getEquipmentByContractId(int contractId) throws Exception {
        return new CustomerEquipmentDAO().getByContractId(contractId);
    }

    private Contract map(ResultSet rs) throws SQLException {
        Contract c = new Contract();
        c.setId(rs.getInt("id"));
        c.setContractCode(rs.getString("contract_code"));
        c.setCustomerId(rs.getInt("customer_id"));
        c.setCustomerName(rs.getString("customer_name"));
        c.setCreatedBy(rs.getInt("created_by"));
        c.setCreatedByName(rs.getString("created_by_name"));
        c.setContractType(rs.getString("contract_type"));
        java.sql.Date sd = rs.getDate("start_date");
        if (sd != null) {
            c.setStartDate(sd.toLocalDate());
        }
        java.sql.Date ed = rs.getDate("end_date");
        if (ed != null) {
            c.setEndDate(ed.toLocalDate());
        }
        c.setStatus(rs.getString("status"));
        c.setNotes(rs.getString("notes"));
        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) {
            c.setCreatedAt(cat.toLocalDateTime());
        }
        Timestamp uat = rs.getTimestamp("updated_at");
        if (uat != null) {
            c.setUpdatedAt(uat.toLocalDateTime());
        }
        try {
            c.setEquipmentCount(rs.getInt("equipment_count"));
        } catch (Exception ignored) {
        }
        try {
            c.setServiceRequestCount(rs.getInt("sr_count"));
        } catch (Exception ignored) {
        }
        return c;
    }

    public List<Contract> getAllFiltered(String keyword, String type, String status,
            int page, int pageSize) throws Exception {
        List<Contract> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE + " WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (c.contract_code LIKE ? OR u.full_name LIKE ? OR u.email LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (type != null && !type.isEmpty()) {
            sql.append(" AND c.contract_type = ?");
            params.add(type);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND c.status = ?");
            params.add(status);
        }
        sql.append(" ORDER BY c.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    public int countFiltered(String keyword, String type, String status) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM contracts c JOIN users u ON u.id = c.customer_id WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (c.contract_code LIKE ? OR u.full_name LIKE ? OR u.email LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (type != null && !type.isEmpty()) {
            sql.append(" AND c.contract_type = ?");
            params.add(type);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND c.status = ?");
            params.add(status);
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

    // ── Create contract with equipment list ───────────────────────────────
    public int create(Contract contract, List<Integer> customerEquipmentIds) throws Exception {
        Connection con = DBConnection.getConnection();
        con.setAutoCommit(false);
        try {
            String sql1 = """
                INSERT INTO contracts
                  (contract_code, customer_id, created_by, contract_type,
                   start_date, end_date, status, notes)
                VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE', ?)
                """;
            int newId;
            try (PreparedStatement ps = con.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, generateCode(con));
                ps.setInt(2, contract.getCustomerId());
                ps.setInt(3, contract.getCreatedBy());
                ps.setString(4, contract.getContractType());
                ps.setDate(5, Date.valueOf(contract.getStartDate()));
                ps.setDate(6, Date.valueOf(contract.getEndDate()));
                ps.setString(7, contract.getNotes());
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new Exception("Failed to get generated key");
                    }
                    newId = keys.getInt(1);
                }
            }

            // Insert contract_equipment
            if (customerEquipmentIds != null && !customerEquipmentIds.isEmpty()) {
                String sql2 = "INSERT INTO contract_equipment (contract_id, customer_equipment_id) VALUES (?,?)";
                try (PreparedStatement ps = con.prepareStatement(sql2)) {
                    for (int ceId : customerEquipmentIds) {
                        ps.setInt(1, newId);
                        ps.setInt(2, ceId);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
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

    // ── Cancel contract ───────────────────────────────────────────────────
    public boolean cancel(int id) throws Exception {
        String sql = "UPDATE contracts SET status='CANCELLED' WHERE id=? AND status='ACTIVE'";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ── Dashboard stats ───────────────────────────────────────────────────
    public Map<String, Integer> getDashboardStats() throws Exception {
        Map<String, Integer> stats = new LinkedHashMap<>();
        String sql = """
            SELECT
              COUNT(*) AS total,
              SUM(CASE WHEN status='ACTIVE'    THEN 1 ELSE 0 END) AS active,
              SUM(CASE WHEN status='EXPIRED'   THEN 1 ELSE 0 END) AS expired,
              SUM(CASE WHEN status='CANCELLED' THEN 1 ELSE 0 END) AS cancelled,
              SUM(CASE WHEN contract_type='WARRANTY'    THEN 1 ELSE 0 END) AS warranty,
              SUM(CASE WHEN contract_type='MAINTENANCE' THEN 1 ELSE 0 END) AS maintenance
            FROM contracts
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("total", rs.getInt("total"));
                stats.put("active", rs.getInt("active"));
                stats.put("expired", rs.getInt("expired"));
                stats.put("cancelled", rs.getInt("cancelled"));
                stats.put("warranty", rs.getInt("warranty"));
                stats.put("maintenance", rs.getInt("maintenance"));
            }
        }
        return stats;
    }

    // ── Get customer_equipment filtered by contract type ──────────────────
    // WARRANTY  → warranty_expires >= today  (still under warranty)
    // MAINTENANCE → warranty_expires < today OR warranty_expires IS NULL (expired/none)
    public List<CustomerEquipment> getEquipmentForContractType(int customerId,
            String contractType) throws Exception {
        List<CustomerEquipment> list = new ArrayList<>();
        String condition;
        if ("WARRANTY".equals(contractType)) {
            condition = " AND ce.warranty_expires >= CURDATE()";
        } else {
            // MAINTENANCE: expired or no warranty
            condition = " AND (ce.warranty_expires IS NULL OR ce.warranty_expires < CURDATE())";
        }
        String sql = """
            SELECT ce.*,
                   eu.serial_number, eu.status AS unit_status,
                   et.model AS equipment_model,
                   cat.name AS category_name
            FROM customer_equipment ce
            LEFT JOIN equipment_units eu  ON eu.id  = ce.equipment_unit_id
            LEFT JOIN equipment_types et  ON et.id  = eu.equipment_type_id
            LEFT JOIN categories     cat  ON cat.id = et.category_id
            WHERE ce.customer_id = ?
            """ + condition + " ORDER BY ce.id";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEquipment(rs));
                }
            }
        }
        return list;
    }

    private String generateCode(Connection con) throws SQLException {
        int year = java.time.Year.now().getValue();
        String sql = "SELECT COUNT(*) FROM contracts WHERE YEAR(created_at)=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                int seq = rs.next() ? rs.getInt(1) + 1 : 1;
                return String.format("CT%d-%03d", year, seq);
            }
        }
    }

    private CustomerEquipment mapEquipment(ResultSet rs) throws SQLException {
        CustomerEquipment e = new CustomerEquipment();
        e.setId(rs.getInt("id"));
        e.setCustomerId(rs.getInt("customer_id"));
        int euid = rs.getInt("equipment_unit_id");
        if (!rs.wasNull()) {
            e.setEquipmentUnitId(euid);
        }
        e.setSerialNumber(rs.getString("serial_number"));
        e.setEquipmentModel(rs.getString("equipment_model"));
        e.setCategoryName(rs.getString("category_name"));
        e.setUnitStatus(rs.getString("unit_status"));
        e.setCustomName(rs.getString("custom_name"));
        e.setCustomSerial(rs.getString("custom_serial"));
        e.setSource(rs.getString("source"));
        Date pd = rs.getDate("purchased_date");
        if (pd != null) {
            e.setPurchasedDate(pd.toLocalDate());
        }
        Date we = rs.getDate("warranty_expires");
        if (we != null) {
            e.setWarrantyExpires(we.toLocalDate());
        }
        e.setNotes(rs.getString("notes"));
        return e;
    }

    public void autoExpireContracts() throws Exception {
        String sql = "UPDATE contracts SET status='EXPIRED' WHERE status='ACTIVE' AND end_date < CURDATE()";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }
}
