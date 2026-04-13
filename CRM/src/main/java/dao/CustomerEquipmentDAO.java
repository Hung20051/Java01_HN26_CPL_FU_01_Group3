package dao;

import model.CustomerEquipment;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerEquipmentDAO {

    private static final String BASE = """
        SELECT ce.*,
               eu.serial_number, eu.status AS unit_status,
               et.model AS equipment_model,
               et.image_url AS eq_image_url,
               cat.name AS category_name
        FROM customer_equipment ce
        LEFT JOIN equipment_units eu ON eu.id = ce.equipment_unit_id
        LEFT JOIN equipment_types et ON et.id = eu.equipment_type_id
        LEFT JOIN categories     cat ON cat.id = et.category_id
        """;

    public List<CustomerEquipment> getByCustomerId(int customerId) throws Exception {
        List<CustomerEquipment> list = new ArrayList<>();
        String sql = BASE + " WHERE ce.customer_id = ? ORDER BY ce.created_at DESC";
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

    public CustomerEquipment getById(int id) throws Exception {
        String sql = BASE + " WHERE ce.id = ?";
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

    public List<CustomerEquipment> getByContractId(int contractId) throws Exception {
        List<CustomerEquipment> list = new ArrayList<>();
        String sql = BASE + """
             JOIN contract_equipment cteq ON cteq.customer_equipment_id = ce.id
             WHERE cteq.contract_id = ?
             ORDER BY ce.id
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    private CustomerEquipment map(ResultSet rs) throws SQLException {
        CustomerEquipment e = new CustomerEquipment();
        e.setId(rs.getInt("id"));
        e.setCustomerId(rs.getInt("customer_id"));

        int euid = rs.getInt("equipment_unit_id");
        if (!rs.wasNull()) {
            e.setEquipmentUnitId(euid);
        }

        e.setSerialNumber(rs.getString("serial_number"));
        e.setEquipmentModel(rs.getString("equipment_model"));
        e.setImageUrl(rs.getString("eq_image_url"));         // INTERNAL image
        e.setCustomImageUrl(rs.getString("custom_image_url")); // EXTERNAL image
        e.setCategoryName(rs.getString("category_name"));
        e.setUnitStatus(rs.getString("unit_status"));
        e.setCustomName(rs.getString("custom_name"));
        e.setCustomSerial(rs.getString("custom_serial"));
        e.setSource(rs.getString("source"));

        java.sql.Date pd = rs.getDate("purchased_date");
        if (pd != null) {
            e.setPurchasedDate(pd.toLocalDate());
        }

        java.sql.Date we = rs.getDate("warranty_expires");
        if (we != null) {
            e.setWarrantyExpires(we.toLocalDate());
        }

        e.setNotes(rs.getString("notes"));

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) {
            e.setCreatedAt(cat.toLocalDateTime());
        }

        return e;
    }
}
