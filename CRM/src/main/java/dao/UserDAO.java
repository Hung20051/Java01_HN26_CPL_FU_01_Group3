package dao;

import model.User;
import util.DBConnection;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;

public class UserDAO {

    // ─────────────────────────────────────────────────
    //  FIND methods
    // ─────────────────────────────────────────────────
    public User findByUsername(String username) throws SQLException {
        String sql = "SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.username = ? AND u.auth_provider = 'LOCAL'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        }
        return null;
    }

    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.email = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        }
        return null;
    }

    public User findByProviderId(String provider, String providerId) throws SQLException {
        String sql = "SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.auth_provider = ? AND u.provider_id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, provider);
            ps.setString(2, providerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        }
        return null;
    }

    public User findById(int id) throws SQLException {
        String sql = "SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        }
        return null;
    }

    public List<User> findAll() throws SQLException {
        String sql = "SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id ORDER BY u.id";
        List<User> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public boolean existsUsername(String username) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE username = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            return ps.executeQuery().next();
        }
    }

    public boolean existsEmail(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeQuery().next();
        }
    }

    // ─────────────────────────────────────────────────
    //  INSERT
    // ─────────────────────────────────────────────────
    public int insert(User u) throws SQLException {
        String sql = "INSERT INTO users (full_name, email, phone, username, password, auth_provider, provider_id, avatar_url, role_id, active) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPhone());
            ps.setString(4, u.getUsername());
            ps.setString(5, u.getPassword());
            ps.setString(6, u.getAuthProvider() != null ? u.getAuthProvider() : "LOCAL");
            ps.setString(7, u.getProviderId());
            ps.setString(8, u.getAvatarUrl());
            ps.setInt(9, u.getRoleId() > 0 ? u.getRoleId() : 2);
            ps.setBoolean(10, u.isActive());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        }
        return -1;
    }

    // ─────────────────────────────────────────────────
    //  UPDATE — core (admin: role, active, email)
    // ─────────────────────────────────────────────────
    public void update(User u) throws SQLException {
        String sql = "UPDATE users SET full_name=?, email=?, phone=?, role_id=?, active=? WHERE id=?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPhone());
            ps.setInt(4, u.getRoleId());
            ps.setBoolean(5, u.isActive());
            ps.setInt(6, u.getId());
            ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────
    //  UPDATE — basic profile (name, phone)
    // ─────────────────────────────────────────────────
    public void updateBasicInfo(User u) throws SQLException {
        String sql = "UPDATE users SET full_name=?, phone=? WHERE id=?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getPhone());
            ps.setInt(3, u.getId());
            ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────
    //  UPDATE — extended personal info (profile page)
    // ─────────────────────────────────────────────────
    public void updatePersonalInfo(User u) throws SQLException {
        // Auto-build address_full from components
        String addressFull = buildAddressFull(u);

        String sql = """
            UPDATE users SET
                full_name          = ?,
                phone              = ?,
                address_street     = ?,
                address_ward       = ?,
                address_district   = ?,
                address_city       = ?,
                address_full       = ?,
                hometown           = ?,
                date_of_birth      = ?,
                gender             = ?,
                national_id        = ?,
                emergency_name     = ?,
                emergency_phone    = ?,
                emergency_relation = ?,
                company_name       = ?,
                bio                = ?
            WHERE id = ?
            """;

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getPhone());
            ps.setString(3, u.getAddressStreet());
            ps.setString(4, u.getAddressWard());
            ps.setString(5, u.getAddressDistrict());
            ps.setString(6, u.getAddressCity());
            ps.setString(7, addressFull);
            ps.setString(8, u.getHometown());

            if (u.getDateOfBirth() != null) {
                ps.setDate(9, java.sql.Date.valueOf(u.getDateOfBirth()));
            } else {
                ps.setNull(9, Types.DATE);
            }

            ps.setString(10, u.getGender());
            ps.setString(11, u.getNationalId());
            ps.setString(12, u.getEmergencyName());
            ps.setString(13, u.getEmergencyPhone());
            ps.setString(14, u.getEmergencyRelation());
            ps.setString(15, u.getCompanyName());
            ps.setString(16, u.getBio());
            ps.setInt(17, u.getId());
            ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────
    //  UPDATE — password & avatar
    // ─────────────────────────────────────────────────
    public void updatePassword(int userId, String hashedPassword) throws SQLException {
        String sql = "UPDATE users SET password = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public void updateAvatar(int userId, String avatarUrl) throws SQLException {
        String sql = "UPDATE users SET avatar_url = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, avatarUrl);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────
    //  DELETE
    // ─────────────────────────────────────────────────
    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────
    //  COUNT
    // ─────────────────────────────────────────────────
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // ─────────────────────────────────────────────────
    //  FILTER / PAGINATE
    // ─────────────────────────────────────────────────
    public List<User> findWithFilter(String keyword, String status, String roleName, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.username LIKE ? OR u.email LIKE ? OR u.full_name LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND u.active = ?");
            params.add(status.equals("1"));
        }
        if (roleName != null && !roleName.isEmpty()) {
            sql.append(" AND r.name = ?");
            params.add(roleName);
        }
        sql.append(" ORDER BY u.id LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<User> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public int countWithFilter(String keyword, String status, String roleName) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM users u JOIN roles r ON u.role_id = r.id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.username LIKE ? OR u.email LIKE ? OR u.full_name LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND u.active = ?");
            params.add(status.equals("1"));
        }
        if (roleName != null && !roleName.isEmpty()) {
            sql.append(" AND r.name = ?");
            params.add(roleName);
        }

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // ─────────────────────────────────────────────────
    //  INTERNAL HELPERS
    // ─────────────────────────────────────────────────
    private String buildAddressFull(User u) {
        StringBuilder sb = new StringBuilder();
        append(sb, u.getAddressStreet());
        append(sb, u.getAddressWard());
        append(sb, u.getAddressDistrict());
        append(sb, u.getAddressCity());
        return sb.toString();
    }

    private void append(StringBuilder sb, String part) {
        if (part != null && !part.isBlank()) {
            if (sb.length() > 0) {
                sb.append(", ");
            }
            sb.append(part.trim());
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();

        // Core
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setAuthProvider(rs.getString("auth_provider"));
        u.setProviderId(rs.getString("provider_id"));
        u.setAvatarUrl(rs.getString("avatar_url"));
        u.setRoleId(rs.getInt("role_id"));
        u.setRoleName(rs.getString("role_name"));
        u.setActive(rs.getBoolean("active"));

        // Address — gracefully handle columns not yet present (migration not yet run)
        u.setAddressStreet(safeGetString(rs, "address_street"));
        u.setAddressWard(safeGetString(rs, "address_ward"));
        u.setAddressDistrict(safeGetString(rs, "address_district"));
        u.setAddressCity(safeGetString(rs, "address_city"));
        u.setAddressFull(safeGetString(rs, "address_full"));

        // Personal info
        u.setHometown(safeGetString(rs, "hometown"));
        java.sql.Date dob = safeGetDate(rs, "date_of_birth");
        if (dob != null) {
            u.setDateOfBirth(dob.toLocalDate());
        }
        u.setGender(safeGetString(rs, "gender"));
        u.setNationalId(safeGetString(rs, "national_id"));

        // Emergency contact
        u.setEmergencyName(safeGetString(rs, "emergency_name"));
        u.setEmergencyPhone(safeGetString(rs, "emergency_phone"));
        u.setEmergencyRelation(safeGetString(rs, "emergency_relation"));

        // Professional
        u.setCompanyName(safeGetString(rs, "company_name"));
        u.setBio(safeGetString(rs, "bio"));

        return u;
    }

    /**
     * Returns null instead of throwing if column doesn't exist yet
     */
    private String safeGetString(ResultSet rs, String col) {
        try {
            return rs.getString(col);
        } catch (SQLException e) {
            return null;
        }
    }

    private java.sql.Date safeGetDate(ResultSet rs, String col) {
        try {
            return rs.getDate(col);
        } catch (SQLException e) {
            return null;
        }
    }
}
