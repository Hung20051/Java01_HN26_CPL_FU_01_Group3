package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class ShopDAO {

    // ============================================================
    // SHOP ITEM - dùng chung cho Part và Equipment
    // ============================================================
    public static class ShopItem {
        public int    id;           // type id (part_type_id hoặc equipment_type_id)
        public String itemType;     // "PART" hoặc "EQUIPMENT"
        public String name;         // tên part / model equipment
        public String categoryName;
        public String description;
        public double unitPrice;
        public int    availableQty; // số unit AVAILABLE còn trong kho
    }

    // ============================================================
    // PARTS: lấy danh sách part_types còn hàng (available > 0)
    // ============================================================
    public List<ShopItem> getAvailableParts(String keyword, String categoryId,
                                             String sortBy, int page, int pageSize)
            throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT pt.id, pt.name, c.name AS category_name, pt.description, pt.unit_price, " +
            "SUM(CASE WHEN pu.status='AVAILABLE' THEN 1 ELSE 0 END) AS available_qty " +
            "FROM part_types pt " +
            "JOIN categories c ON pt.category_id = c.id " +
            "LEFT JOIN part_units pu ON pu.part_type_id = pt.id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (pt.name LIKE ? OR pt.description LIKE ? OR c.name LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (categoryId != null && !categoryId.isEmpty()) {
            sql.append(" AND pt.category_id = ?");
            params.add(Integer.parseInt(categoryId));
        }
        sql.append(" GROUP BY pt.id HAVING available_qty > 0");

        if ("price_asc".equals(sortBy))       sql.append(" ORDER BY pt.unit_price ASC");
        else if ("price_desc".equals(sortBy)) sql.append(" ORDER BY pt.unit_price DESC");
        else if ("name_asc".equals(sortBy))   sql.append(" ORDER BY pt.name ASC");
        else                                   sql.append(" ORDER BY pt.name ASC");

        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<ShopItem> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ShopItem item = new ShopItem();
                item.id           = rs.getInt("id");
                item.itemType     = "PART";
                item.name         = rs.getString("name");
                item.categoryName = rs.getString("category_name");
                item.description  = rs.getString("description");
                item.unitPrice    = rs.getDouble("unit_price");
                item.availableQty = rs.getInt("available_qty");
                list.add(item);
            }
        }
        return list;
    }

    public int countAvailableParts(String keyword, String categoryId) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM (" +
            "SELECT pt.id FROM part_types pt " +
            "JOIN categories c ON pt.category_id = c.id " +
            "LEFT JOIN part_units pu ON pu.part_type_id = pt.id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (pt.name LIKE ? OR pt.description LIKE ? OR c.name LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (categoryId != null && !categoryId.isEmpty()) {
            sql.append(" AND pt.category_id = ?");
            params.add(Integer.parseInt(categoryId));
        }
        sql.append(" GROUP BY pt.id HAVING SUM(CASE WHEN pu.status='AVAILABLE' THEN 1 ELSE 0 END) > 0) t");
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ============================================================
    // EQUIPMENT: lấy danh sách equipment_types còn hàng
    // ============================================================
    public List<ShopItem> getAvailableEquipment(String keyword, String categoryId,
                                                  String sortBy, int page, int pageSize)
            throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT et.id, et.model AS name, c.name AS category_name, et.description, et.unit_price, " +
            "SUM(CASE WHEN eu.status='AVAILABLE' THEN 1 ELSE 0 END) AS available_qty " +
            "FROM equipment_types et " +
            "JOIN categories c ON et.category_id = c.id " +
            "LEFT JOIN equipment_units eu ON eu.equipment_type_id = et.id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (et.model LIKE ? OR et.description LIKE ? OR c.name LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (categoryId != null && !categoryId.isEmpty()) {
            sql.append(" AND et.category_id = ?");
            params.add(Integer.parseInt(categoryId));
        }
        sql.append(" GROUP BY et.id HAVING available_qty > 0");

        if ("price_asc".equals(sortBy))       sql.append(" ORDER BY et.unit_price ASC");
        else if ("price_desc".equals(sortBy)) sql.append(" ORDER BY et.unit_price DESC");
        else if ("name_asc".equals(sortBy))   sql.append(" ORDER BY et.model ASC");
        else                                   sql.append(" ORDER BY et.model ASC");

        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<ShopItem> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ShopItem item = new ShopItem();
                item.id           = rs.getInt("id");
                item.itemType     = "EQUIPMENT";
                item.name         = rs.getString("name");
                item.categoryName = rs.getString("category_name");
                item.description  = rs.getString("description");
                item.unitPrice    = rs.getDouble("unit_price");
                item.availableQty = rs.getInt("available_qty");
                list.add(item);
            }
        }
        return list;
    }

    public int countAvailableEquipment(String keyword, String categoryId) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM (" +
            "SELECT et.id FROM equipment_types et " +
            "JOIN categories c ON et.category_id = c.id " +
            "LEFT JOIN equipment_units eu ON eu.equipment_type_id = et.id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (et.model LIKE ? OR et.description LIKE ? OR c.name LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (categoryId != null && !categoryId.isEmpty()) {
            sql.append(" AND et.category_id = ?");
            params.add(Integer.parseInt(categoryId));
        }
        sql.append(" GROUP BY et.id HAVING SUM(CASE WHEN eu.status='AVAILABLE' THEN 1 ELSE 0 END) > 0) t");
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ============================================================
    // Lấy 1 item theo type + id (cho trang detail / thêm giỏ)
    // ============================================================
    public ShopItem getPartById(int partTypeId) throws SQLException {
        String sql = "SELECT pt.id, pt.name, c.name AS category_name, pt.description, pt.unit_price, " +
            "SUM(CASE WHEN pu.status='AVAILABLE' THEN 1 ELSE 0 END) AS available_qty " +
            "FROM part_types pt JOIN categories c ON pt.category_id = c.id " +
            "LEFT JOIN part_units pu ON pu.part_type_id = pt.id " +
            "WHERE pt.id = ? GROUP BY pt.id";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, partTypeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ShopItem item = new ShopItem();
                item.id = rs.getInt("id"); item.itemType = "PART";
                item.name = rs.getString("name"); item.categoryName = rs.getString("category_name");
                item.description = rs.getString("description"); item.unitPrice = rs.getDouble("unit_price");
                item.availableQty = rs.getInt("available_qty");
                return item;
            }
        }
        return null;
    }

    public ShopItem getEquipmentById(int equipTypeId) throws SQLException {
        String sql = "SELECT et.id, et.model AS name, c.name AS category_name, et.description, et.unit_price, " +
            "SUM(CASE WHEN eu.status='AVAILABLE' THEN 1 ELSE 0 END) AS available_qty " +
            "FROM equipment_types et JOIN categories c ON et.category_id = c.id " +
            "LEFT JOIN equipment_units eu ON eu.equipment_type_id = et.id " +
            "WHERE et.id = ? GROUP BY et.id";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, equipTypeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ShopItem item = new ShopItem();
                item.id = rs.getInt("id"); item.itemType = "EQUIPMENT";
                item.name = rs.getString("name"); item.categoryName = rs.getString("category_name");
                item.description = rs.getString("description"); item.unitPrice = rs.getDouble("unit_price");
                item.availableQty = rs.getInt("available_qty");
                return item;
            }
        }
        return null;
    }

    // ============================================================
    // Lấy categories theo type để filter
    // ============================================================
    public List<Map<String, Object>> getPartCategories() throws SQLException {
        return getCategoriesByType("PART");
    }

    public List<Map<String, Object>> getEquipmentCategories() throws SQLException {
        return getCategoriesByType("EQUIPMENT");
    }

    private List<Map<String, Object>> getCategoriesByType(String type) throws SQLException {
        String sql = "SELECT id, name FROM categories WHERE type = ? OR type = 'BOTH' ORDER BY name";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, type);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("name", rs.getString("name"));
                list.add(m);
            }
        }
        return list;
    }
}