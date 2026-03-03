package dao;

import model.ChatMessage;
import model.User;
import util.DBConnection;
import java.sql.*;
import java.util.*;

public class ChatDAO {

    public List<ChatMessage> getConversation(int userId1, int userId2) throws Exception {
        List<ChatMessage> list = new ArrayList<>();
        String sql = """
            SELECT cm.*, s.full_name AS sender_name, s.avatar_url AS sender_avatar
            FROM chat_messages cm
            JOIN users s ON s.id = cm.sender_id
            WHERE (cm.sender_id=? AND cm.receiver_id=?)
               OR (cm.sender_id=? AND cm.receiver_id=?)
            ORDER BY cm.created_at ASC
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId1); ps.setInt(2, userId2);
            ps.setInt(3, userId2); ps.setInt(4, userId1);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<ChatMessage> getNewMessages(int userId1, int userId2, int lastId) throws Exception {
        List<ChatMessage> list = new ArrayList<>();
        String sql = """
            SELECT cm.*, s.full_name AS sender_name, s.avatar_url AS sender_avatar
            FROM chat_messages cm JOIN users s ON s.id = cm.sender_id
            WHERE ((cm.sender_id=? AND cm.receiver_id=?) OR (cm.sender_id=? AND cm.receiver_id=?))
              AND cm.id > ?
            ORDER BY cm.created_at ASC
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId1); ps.setInt(2, userId2);
            ps.setInt(3, userId2); ps.setInt(4, userId1);
            ps.setInt(5, lastId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public int send(int senderId, int receiverId, String message) throws Exception {
        String sql = "INSERT INTO chat_messages (sender_id, receiver_id, message) VALUES (?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, senderId); ps.setInt(2, receiverId); ps.setString(3, message);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public void markRead(int senderId, int receiverId) throws Exception {
        String sql = "UPDATE chat_messages SET is_read=1 WHERE sender_id=? AND receiver_id=? AND is_read=0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, senderId); ps.setInt(2, receiverId); ps.executeUpdate();
        }
    }

    public int countUnread(int receiverId) throws Exception {
        String sql = "SELECT COUNT(*) FROM chat_messages WHERE receiver_id=? AND is_read=0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, receiverId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Lấy customer_support đang active (dùng cho phía customer) */
    public User findSupportAgent() throws Exception {
        String sql = """
            SELECT u.*, r.name AS role_name FROM users u
            JOIN roles r ON r.id = u.role_id
            WHERE r.name='CUSTOMER_SUPPORT' AND u.active=1 LIMIT 1
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setFullName(rs.getString("full_name"));
                u.setUsername(rs.getString("username"));
                u.setAvatarUrl(rs.getString("avatar_url"));
                u.setRoleName(rs.getString("role_name"));
                return u;
            }
        }
        return null;
    }

    private ChatMessage map(ResultSet rs) throws SQLException {
        ChatMessage m = new ChatMessage();
        m.setId(rs.getInt("id"));
        m.setSenderId(rs.getInt("sender_id"));
        m.setSenderName(rs.getString("sender_name"));
        m.setSenderAvatar(rs.getString("sender_avatar"));
        m.setReceiverId(rs.getInt("receiver_id"));
        m.setMessage(rs.getString("message"));
        m.setRead(rs.getInt("is_read") == 1);
        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) m.setCreatedAt(cat.toLocalDateTime());
        return m;
    }
}