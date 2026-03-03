package dao;

import model.Contract;
import model.CustomerEquipment;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<Contract> getActiveByCustomerId(int customerId) throws Exception {
        List<Contract> list = new ArrayList<>();
        String sql = BASE + " WHERE c.customer_id = ? AND c.status = 'ACTIVE' ORDER BY c.created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public Contract getById(int id) throws Exception {
        String sql = BASE + " WHERE c.id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    /** Lấy equipment list cho contract (dùng cho detail page) */
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
        if (sd != null) c.setStartDate(sd.toLocalDate());
        java.sql.Date ed = rs.getDate("end_date");
        if (ed != null) c.setEndDate(ed.toLocalDate());
        c.setStatus(rs.getString("status"));
        c.setNotes(rs.getString("notes"));
        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) c.setCreatedAt(cat.toLocalDateTime());
        Timestamp uat = rs.getTimestamp("updated_at");
        if (uat != null) c.setUpdatedAt(uat.toLocalDateTime());
        try { c.setEquipmentCount(rs.getInt("equipment_count")); } catch (Exception ignored) {}
        try { c.setServiceRequestCount(rs.getInt("sr_count")); }   catch (Exception ignored) {}
        return c;
    }
}