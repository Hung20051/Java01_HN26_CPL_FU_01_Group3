package dao;

import model.Role;
import util.DBConnection;
import java.sql.*;
import java.util.*;

public class RoleDAO {

    public List<Role> findAll() throws SQLException {
        String sql = "SELECT * FROM roles ORDER BY id";
        List<Role> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Role(rs.getInt("id"), rs.getString("name")));
            }
        }
        return list;
    }

    public Role findById(int id) throws SQLException {
        String sql = "SELECT * FROM roles WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Role(rs.getInt("id"), rs.getString("name"));
            }
        }
        return null;
    }

    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM roles";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public void update(Role role) throws SQLException {
        String sql = "UPDATE roles SET name = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, role.getName());
            ps.setInt(2, role.getId());
            ps.executeUpdate();
        }
    }

    public void deleteAndReassign(int roleId, int customerRoleId) throws SQLException {
        // Chuyển user về CUSTOMER trước
        String reassign = "UPDATE users SET role_id = ? WHERE role_id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(reassign)) {
            ps.setInt(1, customerRoleId);
            ps.setInt(2, roleId);
            ps.executeUpdate();
        }
        // Xóa role
        String delete = "DELETE FROM roles WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(delete)) {
            ps.setInt(1, roleId);
            ps.executeUpdate();
        }
    }
}
