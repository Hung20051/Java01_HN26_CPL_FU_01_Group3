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
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId1);
            ps.setInt(2, userId2);
            ps.setInt(3, userId2);
            ps.setInt(4, userId1);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
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
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId1);
            ps.setInt(2, userId2);
            ps.setInt(3, userId2);
            ps.setInt(4, userId1);
            ps.setInt(5, lastId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    public int send(int senderId, int receiverId, String message) throws Exception {
        String sql = "INSERT INTO chat_messages (sender_id, receiver_id, message) VALUES (?,?,?)";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.setString(3, message);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return -1;
    }

    public void markRead(int senderId, int receiverId) throws Exception {
        String sql = "UPDATE chat_messages SET is_read=1 WHERE sender_id=? AND receiver_id=? AND is_read=0";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.executeUpdate();
        }
    }

    public int countUnread(int receiverId) throws Exception {
        String sql = "SELECT COUNT(*) FROM chat_messages WHERE receiver_id=? AND is_read=0";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, receiverId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /**
     * Lấy customer_support đang active (dùng cho phía customer)
     */
    public User findSupportAgent() throws Exception {
        String sql = """
            SELECT u.*, r.name AS role_name FROM users u
            JOIN roles r ON r.id = u.role_id
            WHERE r.name='CUSTOMER_SUPPORT' AND u.active=1 LIMIT 1
            """;
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
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
        if (cat != null) {
            m.setCreatedAt(cat.toLocalDateTime());
        }
        return m;
    }
    // ── THÊM VÀO ChatDAO.java ──────────────────────────────────────────────

    /**
     * Lấy danh sách tất cả customer đã từng nhắn tin với support agent này, kèm
     * tin nhắn cuối và số unread. Sắp xếp theo tin nhắn mới nhất.
     */
    public List<Map<String, Object>> getCustomerConversationList(int agentId) throws Exception {
        String sql = """
            SELECT
                u.id           AS customer_id,
                u.full_name    AS customer_name,
                u.avatar_url   AS customer_avatar,
                u.phone        AS customer_phone,
                last_msg.message      AS last_message,
                last_msg.created_at   AS last_time,
                last_msg.sender_id    AS last_sender_id,
                COALESCE(unread.cnt, 0) AS unread_count
            FROM users u
            JOIN roles r ON r.id = u.role_id AND r.name = 'CUSTOMER'
            JOIN (
                SELECT
                    CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END AS cust_id,
                    message, created_at, sender_id,
                    ROW_NUMBER() OVER (
                        PARTITION BY CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END
                        ORDER BY created_at DESC
                    ) AS rn
                FROM chat_messages
                WHERE sender_id = ? OR receiver_id = ?
            ) last_msg ON last_msg.cust_id = u.id AND last_msg.rn = 1
            LEFT JOIN (
                SELECT sender_id, COUNT(*) AS cnt
                FROM chat_messages
                WHERE receiver_id = ? AND is_read = 0
                GROUP BY sender_id
            ) unread ON unread.sender_id = u.id
            WHERE u.active = 1
            ORDER BY last_msg.created_at DESC
            """;
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, agentId);
            ps.setInt(2, agentId);
            ps.setInt(3, agentId);
            ps.setInt(4, agentId);
            ps.setInt(5, agentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("customerId", rs.getInt("customer_id"));
                    row.put("customerName", rs.getString("customer_name"));
                    row.put("customerAvatar", rs.getString("customer_avatar"));
                    row.put("customerPhone", rs.getString("customer_phone"));
                    row.put("lastMessage", rs.getString("last_message"));
                    Timestamp t = rs.getTimestamp("last_time");
                    row.put("lastTime", t != null ? t.toLocalDateTime() : null);
                    row.put("lastSenderId", rs.getInt("last_sender_id"));
                    row.put("unreadCount", rs.getInt("unread_count"));
                    list.add(row);
                }
            }
        }
        return list;
    }

    /**
     * Lấy tổng số unread messages từ tất cả customer gửi đến agent này.
     */
    public int countTotalUnreadForAgent(int agentId) throws Exception {
        String sql = "SELECT COUNT(*) FROM chat_messages WHERE receiver_id=? AND is_read=0";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, agentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /**
     * Lấy User (customer) theo id, dùng để load thông tin khi mở chat.
     */
    public User getUserById(int userId) throws Exception {
        String sql = "SELECT u.*, r.name AS role_name FROM users u JOIN roles r ON r.id=u.role_id WHERE u.id=?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setFullName(rs.getString("full_name"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setPhone(rs.getString("phone"));
                    u.setAvatarUrl(rs.getString("avatar_url"));
                    u.setRoleName(rs.getString("role_name"));
                    return u;
                }
            }
        }
        return null;
    }
}
