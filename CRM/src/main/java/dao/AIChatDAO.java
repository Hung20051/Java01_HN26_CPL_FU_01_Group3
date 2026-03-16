package dao;
 
import model.AIChatMessage;
import util.DBConnection;
 
import java.sql.*;
import java.util.*;
 
public class AIChatDAO {
 
    /**
     * Lấy lịch sử chat theo thứ tự ASC (cũ nhất → mới nhất),
     * giới hạn N tin gần nhất.
     */
    public List<AIChatMessage> getHistory(int userId, int limit) throws Exception {
        List<AIChatMessage> list = new ArrayList<>();
        String sql = """
            SELECT * FROM (
                SELECT id, user_id, role, content, created_at
                FROM ai_chat_messages
                WHERE user_id = ?
                ORDER BY created_at DESC
                LIMIT ?
            ) sub ORDER BY created_at ASC
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AIChatMessage m = new AIChatMessage();
                    m.setId(rs.getInt("id"));
                    m.setUserId(rs.getInt("user_id"));
                    m.setRole(rs.getString("role"));
                    m.setContent(rs.getString("content"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) m.setCreatedAt(ts.toLocalDateTime());
                    list.add(m);
                }
            }
        }
        return list;
    }
 
    /**
     * Lưu một tin nhắn vào DB.
     */
    public void save(int userId, String role, String content) throws Exception {
        String sql = "INSERT INTO ai_chat_messages (user_id, role, content) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, role);
            ps.setString(3, content);
            ps.executeUpdate();
        }
    }
 
    /**
     * Xóa toàn bộ lịch sử của một user.
     */
    public void clearHistory(int userId) throws Exception {
        String sql = "DELETE FROM ai_chat_messages WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
 
    /**
     * Đếm số tin nhắn (dùng để hiển thị badge nếu cần).
     */
    public int countMessages(int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM ai_chat_messages WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
 