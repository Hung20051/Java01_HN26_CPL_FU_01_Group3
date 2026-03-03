package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class TransactionDAO {

    public static class TransactionRow {
        public int id;
        public String itemType;        // PART / EQUIPMENT
        public int itemUnitId;
        public String itemName;        // tên part/equipment
        public String serialOrUnitId;  // serial number (equip) hoặc unit id (part)
        public String action;          // IMPORT / EXPORT_SALE / EXPORT_REPAIR / RETURN / RETIRE
        public String transactionType; // PURCHASE / REPAIR / IMPORT / OTHER
        public String performedBy;     // username
        public String customerName;
        public String orderCode;
        public Integer refOrderId;
        public String note;
        public Timestamp createdAt;
    }

    public List<TransactionRow> findAll(String type, String itemType, String keyword,
                                        String fromDate, String toDate,
                                        int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT t.*, " +
            "  CASE WHEN t.item_type='PART' THEN pt.name ELSE et.model END AS item_name, " +
            "  CASE WHEN t.item_type='PART' THEN CAST(pu.id AS CHAR) ELSE eu.serial_number END AS serial_or_unit, " +
            "  u.username as performed_by_name " +
            "FROM inventory_transactions t " +
            "LEFT JOIN part_units  pu ON t.item_type='PART'      AND t.item_unit_id = pu.id " +
            "LEFT JOIN part_types  pt ON pu.part_type_id = pt.id " +
            "LEFT JOIN equipment_units eu ON t.item_type='EQUIPMENT' AND t.item_unit_id = eu.id " +
            "LEFT JOIN equipment_types et ON eu.equipment_type_id = et.id " +
            "LEFT JOIN users u ON t.performed_by = u.id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (type != null && !type.isEmpty()) {
            sql.append(" AND t.transaction_type = ?");
            params.add(type);
        }
        if (itemType != null && !itemType.isEmpty()) {
            sql.append(" AND t.item_type = ?");
            params.add(itemType);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (pt.name LIKE ? OR et.model LIKE ? OR t.customer_name LIKE ? OR t.order_code LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw); params.add(kw);
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND DATE(t.created_at) >= ?");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(t.created_at) <= ?");
            params.add(toDate);
        }

        sql.append(" ORDER BY t.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<TransactionRow> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public int countAll(String type, String itemType, String keyword,
                        String fromDate, String toDate) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM inventory_transactions t " +
            "LEFT JOIN part_units  pu ON t.item_type='PART'      AND t.item_unit_id = pu.id " +
            "LEFT JOIN part_types  pt ON pu.part_type_id = pt.id " +
            "LEFT JOIN equipment_units eu ON t.item_type='EQUIPMENT' AND t.item_unit_id = eu.id " +
            "LEFT JOIN equipment_types et ON eu.equipment_type_id = et.id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (type != null && !type.isEmpty()) {
            sql.append(" AND t.transaction_type = ?"); params.add(type);
        }
        if (itemType != null && !itemType.isEmpty()) {
            sql.append(" AND t.item_type = ?"); params.add(itemType);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (pt.name LIKE ? OR et.model LIKE ? OR t.customer_name LIKE ? OR t.order_code LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw); params.add(kw);
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND DATE(t.created_at) >= ?"); params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND DATE(t.created_at) <= ?"); params.add(toDate);
        }
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // Đếm theo từng loại cho tab counter
    public Map<String, Integer> countByType() throws SQLException {
        Map<String, Integer> map = new HashMap<>();
        String sql = "SELECT transaction_type, COUNT(*) as cnt FROM inventory_transactions GROUP BY transaction_type";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) map.put(rs.getString("transaction_type"), rs.getInt("cnt"));
        }
        // total
        map.put("ALL", map.values().stream().mapToInt(Integer::intValue).sum());
        return map;
    }

    private TransactionRow mapRow(ResultSet rs) throws SQLException {
        TransactionRow t = new TransactionRow();
        t.id              = rs.getInt("id");
        t.itemType        = rs.getString("item_type");
        t.itemUnitId      = rs.getInt("item_unit_id");
        t.itemName        = rs.getString("item_name");
        t.serialOrUnitId  = rs.getString("serial_or_unit");
        t.action          = rs.getString("action");
        t.transactionType = rs.getString("transaction_type");
        t.performedBy     = rs.getString("performed_by_name");
        t.customerName    = rs.getString("customer_name");
        t.orderCode       = rs.getString("order_code");
        t.refOrderId      = (Integer) rs.getObject("ref_order_id");
        t.note            = rs.getString("note");
        t.createdAt       = rs.getTimestamp("created_at");
        return t;
    }
}