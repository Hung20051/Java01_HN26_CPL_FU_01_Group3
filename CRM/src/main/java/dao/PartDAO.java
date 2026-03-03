package dao;

import model.PartType;
import model.PartUnit;
import util.DBConnection;
import java.sql.*;
import java.util.*;

public class PartDAO {

    // ============================
    // PART TYPES
    // ============================

    public List<PartType> findAllTypes(String keyword, String categoryId, String sortBy, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT pt.*, c.name as category_name, u.username as updated_by_username, " +
            "COUNT(pu.id) as total_units, " +
            "SUM(CASE WHEN pu.status='AVAILABLE' THEN 1 ELSE 0 END) as available_units, " +
            "SUM(CASE WHEN pu.status='INUSE'     THEN 1 ELSE 0 END) as inuse_units, " +
            "SUM(CASE WHEN pu.status='FAULTY'    THEN 1 ELSE 0 END) as faulty_units, " +
            "SUM(CASE WHEN pu.status='RETIRED'   THEN 1 ELSE 0 END) as retired_units " +
            "FROM part_types pt " +
            "JOIN categories c ON pt.category_id = c.id " +
            "LEFT JOIN users u ON pt.updated_by = u.id " +
            "LEFT JOIN part_units pu ON pu.part_type_id = pt.id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (pt.name LIKE ? OR pt.description LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (categoryId != null && !categoryId.isEmpty()) {
            sql.append(" AND pt.category_id = ?");
            params.add(Integer.parseInt(categoryId));
        }
        sql.append(" GROUP BY pt.id");

        if ("name_asc".equals(sortBy))       sql.append(" ORDER BY pt.name ASC");
        else if ("name_desc".equals(sortBy)) sql.append(" ORDER BY pt.name DESC");
        else if ("price_asc".equals(sortBy)) sql.append(" ORDER BY pt.unit_price ASC");
        else if ("price_desc".equals(sortBy))sql.append(" ORDER BY pt.unit_price DESC");
        else                                  sql.append(" ORDER BY pt.id ASC");

        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<PartType> list = new ArrayList<>();
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
            "SELECT COUNT(*) FROM part_types pt JOIN categories c ON pt.category_id = c.id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (pt.name LIKE ? OR pt.description LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (categoryId != null && !categoryId.isEmpty()) {
            sql.append(" AND pt.category_id = ?");
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

    public PartType findTypeById(int id) throws SQLException {
        String sql = "SELECT pt.*, c.name as category_name, u.username as updated_by_username, " +
            "COUNT(pu.id) as total_units, " +
            "SUM(CASE WHEN pu.status='AVAILABLE' THEN 1 ELSE 0 END) as available_units, " +
            "SUM(CASE WHEN pu.status='INUSE'     THEN 1 ELSE 0 END) as inuse_units, " +
            "SUM(CASE WHEN pu.status='FAULTY'    THEN 1 ELSE 0 END) as faulty_units, " +
            "SUM(CASE WHEN pu.status='RETIRED'   THEN 1 ELSE 0 END) as retired_units " +
            "FROM part_types pt " +
            "JOIN categories c ON pt.category_id = c.id " +
            "LEFT JOIN users u ON pt.updated_by = u.id " +
            "LEFT JOIN part_units pu ON pu.part_type_id = pt.id " +
            "WHERE pt.id = ? GROUP BY pt.id";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapTypeRow(rs);
        }
        return null;
    }

    public int insertType(PartType pt) throws SQLException {
        String sql = "INSERT INTO part_types (name, category_id, description, unit_price, updated_by) VALUES (?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, pt.getName());
            ps.setInt(2, pt.getCategoryId());
            ps.setString(3, pt.getDescription());
            ps.setDouble(4, pt.getUnitPrice());
            ps.setInt(5, pt.getUpdatedBy());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        }
        return -1;
    }

    public void updateType(PartType pt) throws SQLException {
        String sql = "UPDATE part_types SET name=?, category_id=?, description=?, unit_price=?, updated_by=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, pt.getName());
            ps.setInt(2, pt.getCategoryId());
            ps.setString(3, pt.getDescription());
            ps.setDouble(4, pt.getUnitPrice());
            ps.setInt(5, pt.getUpdatedBy());
            ps.setInt(6, pt.getId());
            ps.executeUpdate();
        }
    }

    public void deleteType(int id) throws SQLException {
        // Xóa units trước rồi xóa type
        try (Connection c = DBConnection.getConnection()) {
            PreparedStatement ps1 = c.prepareStatement("DELETE FROM part_units WHERE part_type_id = ?");
            ps1.setInt(1, id); ps1.executeUpdate();
            PreparedStatement ps2 = c.prepareStatement("DELETE FROM part_types WHERE id = ?");
            ps2.setInt(1, id); ps2.executeUpdate();
        }
    }

    // ============================
    // PART UNITS (nhập kho)
    // ============================

    public void insertUnits(int partTypeId, int quantity, int performedBy) throws SQLException {
        String sqlUnit = "INSERT INTO part_units (part_type_id, status) VALUES (?, 'AVAILABLE')";
        String sqlTxn  = "INSERT INTO inventory_transactions (item_type, item_unit_id, action, performed_by, note) VALUES ('PART', ?, 'IMPORT', ?, 'Nhập kho mới')";
        try (Connection c = DBConnection.getConnection()) {
            for (int i = 0; i < quantity; i++) {
                PreparedStatement ps = c.prepareStatement(sqlUnit, Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, partTypeId);
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
    }

    public List<PartUnit> findUnitsByTypeId(int partTypeId) throws SQLException {
        String sql = "SELECT pu.*, pt.name as part_type_name FROM part_units pu " +
                     "JOIN part_types pt ON pu.part_type_id = pt.id WHERE pu.part_type_id = ? ORDER BY pu.id";
        List<PartUnit> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, partTypeId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapUnitRow(rs));
        }
        return list;
    }

    // ============================
    // DASHBOARD STATS
    // ============================

    public Map<String, Integer> getDashboardStats() throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT " +
            "(SELECT COUNT(*) FROM part_types) as total_part_types, " +
            "(SELECT COUNT(*) FROM part_units) as total_part_units, " +
            "(SELECT COUNT(*) FROM part_units WHERE status='AVAILABLE') as available_units, " +
            "(SELECT COUNT(*) FROM part_units WHERE status='FAULTY') as faulty_units, " +
            "(SELECT COUNT(*) FROM part_units WHERE status='INUSE') as inuse_units, " +
            "(SELECT COUNT(*) FROM part_units WHERE status='RETIRED') as retired_units, " +
            "(SELECT COUNT(DISTINCT pt.id) FROM part_types pt JOIN part_units pu ON pu.part_type_id = pt.id " +
            " WHERE (SELECT COUNT(*) FROM part_units pu2 WHERE pu2.part_type_id = pt.id AND pu2.status='AVAILABLE') <= 2 " +
            " AND (SELECT COUNT(*) FROM part_units pu2 WHERE pu2.part_type_id = pt.id AND pu2.status='AVAILABLE') > 0) as low_stock";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("totalPartTypes",  rs.getInt("total_part_types"));
                stats.put("totalPartUnits",  rs.getInt("total_part_units"));
                stats.put("availableUnits",  rs.getInt("available_units"));
                stats.put("faultyUnits",     rs.getInt("faulty_units"));
                stats.put("inuseUnits",      rs.getInt("inuse_units"));
                stats.put("retiredUnits",    rs.getInt("retired_units"));
                stats.put("lowStock",        rs.getInt("low_stock"));
            }
        }
        return stats;
    }

    public List<PartType> getMostUsedParts(int limit) throws SQLException {
        String sql = "SELECT pt.*, c.name as category_name, u.username as updated_by_username, " +
            "COUNT(pu.id) as total_units, " +
            "SUM(CASE WHEN pu.status='AVAILABLE' THEN 1 ELSE 0 END) as available_units, " +
            "SUM(CASE WHEN pu.status='INUSE'     THEN 1 ELSE 0 END) as inuse_units, " +
            "SUM(CASE WHEN pu.status='FAULTY'    THEN 1 ELSE 0 END) as faulty_units, " +
            "SUM(CASE WHEN pu.status='RETIRED'   THEN 1 ELSE 0 END) as retired_units " +
            "FROM part_types pt " +
            "JOIN categories c ON pt.category_id = c.id " +
            "LEFT JOIN users u ON pt.updated_by = u.id " +
            "LEFT JOIN part_units pu ON pu.part_type_id = pt.id " +
            "GROUP BY pt.id ORDER BY inuse_units DESC LIMIT ?";
        List<PartType> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapTypeRow(rs));
        }
        return list;
    }

    public List<PartType> getLowStockParts(int limit) throws SQLException {
        String sql = "SELECT pt.*, c.name as category_name, u.username as updated_by_username, " +
            "COUNT(pu.id) as total_units, " +
            "SUM(CASE WHEN pu.status='AVAILABLE' THEN 1 ELSE 0 END) as available_units, " +
            "SUM(CASE WHEN pu.status='INUSE'     THEN 1 ELSE 0 END) as inuse_units, " +
            "SUM(CASE WHEN pu.status='FAULTY'    THEN 1 ELSE 0 END) as faulty_units, " +
            "SUM(CASE WHEN pu.status='RETIRED'   THEN 1 ELSE 0 END) as retired_units " +
            "FROM part_types pt " +
            "JOIN categories c ON pt.category_id = c.id " +
            "LEFT JOIN users u ON pt.updated_by = u.id " +
            "LEFT JOIN part_units pu ON pu.part_type_id = pt.id " +
            "GROUP BY pt.id HAVING available_units <= 2 ORDER BY available_units ASC LIMIT ?";
        List<PartType> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapTypeRow(rs));
        }
        return list;
    }

    // ============================
    // MAPPERS
    // ============================

    private PartType mapTypeRow(ResultSet rs) throws SQLException {
        PartType pt = new PartType();
        pt.setId(rs.getInt("id"));
        pt.setName(rs.getString("name"));
        pt.setCategoryId(rs.getInt("category_id"));
        pt.setCategoryName(rs.getString("category_name"));
        pt.setDescription(rs.getString("description"));
        pt.setUnitPrice(rs.getDouble("unit_price"));
        pt.setUpdatedBy(rs.getInt("updated_by"));
        pt.setUpdatedByUsername(rs.getString("updated_by_username"));
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) pt.setUpdatedAt(ua.toLocalDateTime());
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) pt.setCreatedAt(ca.toLocalDateTime());
        pt.setTotalUnits(rs.getInt("total_units"));
        pt.setAvailableUnits(rs.getInt("available_units"));
        pt.setInuseUnits(rs.getInt("inuse_units"));
        pt.setFaultyUnits(rs.getInt("faulty_units"));
        pt.setRetiredUnits(rs.getInt("retired_units"));
        return pt;
    }

    private PartUnit mapUnitRow(ResultSet rs) throws SQLException {
        PartUnit pu = new PartUnit();
        pu.setId(rs.getInt("id"));
        pu.setPartTypeId(rs.getInt("part_type_id"));
        pu.setPartTypeName(rs.getString("part_type_name"));
        pu.setStatus(rs.getString("status"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) pu.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) pu.setUpdatedAt(ua.toLocalDateTime());
        return pu;
    }
    // Xuất kho bán hàng: đánh dấu N unit AVAILABLE → INUSE + ghi transaction
    public void insertUnitsExport(int partTypeId, int quantity, int performedBy, int invoiceId)
            throws SQLException {
        String sqlFind = "SELECT id FROM part_units WHERE part_type_id=? AND status='AVAILABLE' LIMIT ?";
        String sqlUpd  = "UPDATE part_units SET status='INUSE' WHERE id=?";
        String sqlTxn  = "INSERT INTO inventory_transactions " +
                         "(item_type,item_unit_id,action,transaction_type,performed_by,ref_order_id,note) " +
                         "VALUES ('PART',?,'EXPORT_SALE','PURCHASE',?,?,'Bán hàng - invoice')";
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                PreparedStatement psFind = c.prepareStatement(sqlFind);
                psFind.setInt(1, partTypeId);
                psFind.setInt(2, quantity);
                ResultSet rs = psFind.executeQuery();

                PreparedStatement psUpd = c.prepareStatement(sqlUpd);
                PreparedStatement psTxn = c.prepareStatement(sqlTxn);

                while (rs.next()) {
                    int unitId = rs.getInt("id");
                    psUpd.setInt(1, unitId);
                    psUpd.addBatch();

                    psTxn.setInt(1, unitId);
                    psTxn.setInt(2, performedBy);
                    psTxn.setInt(3, invoiceId);
                    psTxn.addBatch();
                }
                psUpd.executeBatch();
                psTxn.executeBatch();
                c.commit();
            } catch (Exception e) {
                c.rollback(); throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }


// ================================================================
// THÊM VÀO CUỐI EquipmentDAO.java (trong class EquipmentDAO, trước dấu })
// ================================================================

    // Xuất kho bán hàng: lấy 1 unit AVAILABLE đầu tiên → INUSE + ghi transaction
    public void exportUnit(int equipTypeId, int performedBy, int invoiceId) throws SQLException {
        String sqlFind = "SELECT id FROM equipment_units WHERE equipment_type_id=? AND status='AVAILABLE' LIMIT 1";
        String sqlUpd  = "UPDATE equipment_units SET status='INUSE' WHERE id=?";
        String sqlTxn  = "INSERT INTO inventory_transactions " +
                         "(item_type,item_unit_id,action,transaction_type,performed_by,ref_order_id,note) " +
                         "VALUES ('EQUIPMENT',?,'EXPORT_SALE','PURCHASE',?,?,'Bán hàng - invoice')";
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                PreparedStatement psFind = c.prepareStatement(sqlFind);
                psFind.setInt(1, equipTypeId);
                ResultSet rs = psFind.executeQuery();
                if (rs.next()) {
                    int unitId = rs.getInt("id");
                    PreparedStatement psUpd = c.prepareStatement(sqlUpd);
                    psUpd.setInt(1, unitId); psUpd.executeUpdate();

                    PreparedStatement psTxn = c.prepareStatement(sqlTxn);
                    psTxn.setInt(1, unitId);
                    psTxn.setInt(2, performedBy);
                    psTxn.setInt(3, invoiceId);
                    psTxn.executeUpdate();
                }
                c.commit();
            } catch (Exception e) {
                c.rollback(); throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }
}