package dao;

import model.EquipmentType;
import model.EquipmentUnit;
import util.DBConnection;
import java.sql.*;
import java.util.*;

public class EquipmentDAO {

    // ============================
    // EQUIPMENT TYPES
    // ============================

    public List<EquipmentType> findAllTypes(String keyword, String categoryId, String sortBy, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT et.*, c.name as category_name, u.username as updated_by_username, " +
            "COUNT(eu.id) as total_units, " +
            "SUM(CASE WHEN eu.status='AVAILABLE' THEN 1 ELSE 0 END) as available_units, " +
            "SUM(CASE WHEN eu.status='INUSE'     THEN 1 ELSE 0 END) as inuse_units, " +
            "SUM(CASE WHEN eu.status='FAULTY'    THEN 1 ELSE 0 END) as faulty_units, " +
            "SUM(CASE WHEN eu.status='RETIRED'   THEN 1 ELSE 0 END) as retired_units " +
            "FROM equipment_types et " +
            "JOIN categories c ON et.category_id = c.id " +
            "LEFT JOIN users u ON et.updated_by = u.id " +
            "LEFT JOIN equipment_units eu ON eu.equipment_type_id = et.id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (et.model LIKE ? OR et.description LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (categoryId != null && !categoryId.isEmpty()) {
            sql.append(" AND et.category_id = ?");
            params.add(Integer.parseInt(categoryId));
        }
        sql.append(" GROUP BY et.id");

        if ("name_asc".equals(sortBy))       sql.append(" ORDER BY et.model ASC");
        else if ("name_desc".equals(sortBy)) sql.append(" ORDER BY et.model DESC");
        else if ("price_asc".equals(sortBy)) sql.append(" ORDER BY et.unit_price ASC");
        else if ("price_desc".equals(sortBy))sql.append(" ORDER BY et.unit_price DESC");
        else                                  sql.append(" ORDER BY et.id ASC");

        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<EquipmentType> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapTypeRow(rs));
        }
        return list;
    }

    public int countTypes(String keyword, String categoryId) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM equipment_types et JOIN categories c ON et.category_id = c.id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (et.model LIKE ? OR et.description LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (categoryId != null && !categoryId.isEmpty()) {
            sql.append(" AND et.category_id = ?");
            params.add(Integer.parseInt(categoryId));
        }
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public EquipmentType findTypeById(int id) throws SQLException {
        String sql = "SELECT et.*, c.name as category_name, u.username as updated_by_username, " +
            "COUNT(eu.id) as total_units, " +
            "SUM(CASE WHEN eu.status='AVAILABLE' THEN 1 ELSE 0 END) as available_units, " +
            "SUM(CASE WHEN eu.status='INUSE'     THEN 1 ELSE 0 END) as inuse_units, " +
            "SUM(CASE WHEN eu.status='FAULTY'    THEN 1 ELSE 0 END) as faulty_units, " +
            "SUM(CASE WHEN eu.status='RETIRED'   THEN 1 ELSE 0 END) as retired_units " +
            "FROM equipment_types et " +
            "JOIN categories c ON et.category_id = c.id " +
            "LEFT JOIN users u ON et.updated_by = u.id " +
            "LEFT JOIN equipment_units eu ON eu.equipment_type_id = et.id " +
            "WHERE et.id = ? GROUP BY et.id";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapTypeRow(rs);
        }
        return null;
    }

    public int insertType(EquipmentType et) throws SQLException {
        String sql = "INSERT INTO equipment_types (model, category_id, description, unit_price, updated_by) VALUES (?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, et.getModel());
            ps.setInt(2, et.getCategoryId());
            ps.setString(3, et.getDescription());
            ps.setDouble(4, et.getUnitPrice());
            ps.setInt(5, et.getUpdatedBy());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        }
        return -1;
    }

    public void updateType(EquipmentType et) throws SQLException {
        String sql = "UPDATE equipment_types SET model=?, category_id=?, description=?, unit_price=?, updated_by=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, et.getModel());
            ps.setInt(2, et.getCategoryId());
            ps.setString(3, et.getDescription());
            ps.setDouble(4, et.getUnitPrice());
            ps.setInt(5, et.getUpdatedBy());
            ps.setInt(6, et.getId());
            ps.executeUpdate();
        }
    }

    public void deleteType(int id) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            PreparedStatement ps1 = c.prepareStatement("DELETE FROM equipment_units WHERE equipment_type_id = ?");
            ps1.setInt(1, id); ps1.executeUpdate();
            PreparedStatement ps2 = c.prepareStatement("DELETE FROM equipment_types WHERE id = ?");
            ps2.setInt(1, id); ps2.executeUpdate();
        }
    }

    // ============================
    // EQUIPMENT UNITS (nhập kho)
    // ============================

    public void insertUnit(int equipmentTypeId, String serialNumber, int performedBy) throws SQLException {
        String sqlUnit = "INSERT INTO equipment_units (equipment_type_id, serial_number, status) VALUES (?, ?, 'AVAILABLE')";
        String sqlTxn  = "INSERT INTO inventory_transactions (item_type, item_unit_id, action, performed_by, note) VALUES ('EQUIPMENT', ?, 'IMPORT', ?, 'Nhập kho mới')";
        try (Connection c = DBConnection.getConnection()) {
            PreparedStatement ps = c.prepareStatement(sqlUnit, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, equipmentTypeId);
            ps.setString(2, serialNumber);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                int unitId = keys.getInt(1);
                PreparedStatement psTxn = c.prepareStatement(sqlTxn);
                psTxn.setInt(1, unitId);
                psTxn.setInt(2, performedBy);
                psTxn.executeUpdate();
            }
        }
    }

    public List<EquipmentUnit> findUnitsByTypeId(int typeId) throws SQLException {
        String sql = "SELECT eu.*, et.model as equipment_model FROM equipment_units eu " +
                     "JOIN equipment_types et ON eu.equipment_type_id = et.id WHERE eu.equipment_type_id = ? ORDER BY eu.id";
        List<EquipmentUnit> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapUnitRow(rs));
        }
        return list;
    }

    public boolean existsSerialNumber(String serialNumber) throws SQLException {
        String sql = "SELECT 1 FROM equipment_units WHERE serial_number = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, serialNumber);
            return ps.executeQuery().next();
        }
    }

    // Dashboard stats for equipment
    public Map<String, Integer> getDashboardStats() throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT " +
            "(SELECT COUNT(*) FROM equipment_types) as total_eq_types, " +
            "(SELECT COUNT(*) FROM equipment_units) as total_eq_units, " +
            "(SELECT COUNT(*) FROM equipment_units WHERE status='AVAILABLE') as available_eq, " +
            "(SELECT COUNT(*) FROM equipment_units WHERE status='FAULTY') as faulty_eq, " +
            "(SELECT COUNT(*) FROM equipment_units WHERE status='INUSE') as inuse_eq, " +
            "(SELECT COUNT(*) FROM equipment_units WHERE status='RETIRED') as retired_eq";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("totalEqTypes",  rs.getInt("total_eq_types"));
                stats.put("totalEqUnits",  rs.getInt("total_eq_units"));
                stats.put("availableEq",   rs.getInt("available_eq"));
                stats.put("faultyEq",      rs.getInt("faulty_eq"));
                stats.put("inuseEq",       rs.getInt("inuse_eq"));
                stats.put("retiredEq",     rs.getInt("retired_eq"));
            }
        }
        return stats;
    }

    // ============================
    // MAPPERS
    // ============================

    private EquipmentType mapTypeRow(ResultSet rs) throws SQLException {
        EquipmentType et = new EquipmentType();
        et.setId(rs.getInt("id"));
        et.setModel(rs.getString("model"));
        et.setCategoryId(rs.getInt("category_id"));
        et.setCategoryName(rs.getString("category_name"));
        et.setDescription(rs.getString("description"));
        et.setUnitPrice(rs.getDouble("unit_price"));
        et.setUpdatedBy(rs.getInt("updated_by"));
        et.setUpdatedByUsername(rs.getString("updated_by_username"));
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) et.setUpdatedAt(ua.toLocalDateTime());
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) et.setCreatedAt(ca.toLocalDateTime());
        et.setTotalUnits(rs.getInt("total_units"));
        et.setAvailableUnits(rs.getInt("available_units"));
        et.setInuseUnits(rs.getInt("inuse_units"));
        et.setFaultyUnits(rs.getInt("faulty_units"));
        et.setRetiredUnits(rs.getInt("retired_units"));
        return et;
    }

    private EquipmentUnit mapUnitRow(ResultSet rs) throws SQLException {
        EquipmentUnit eu = new EquipmentUnit();
        eu.setId(rs.getInt("id"));
        eu.setEquipmentTypeId(rs.getInt("equipment_type_id"));
        eu.setEquipmentModel(rs.getString("equipment_model"));
        eu.setSerialNumber(rs.getString("serial_number"));
        eu.setStatus(rs.getString("status"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) eu.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) eu.setUpdatedAt(ua.toLocalDateTime());
        return eu;
    }
}