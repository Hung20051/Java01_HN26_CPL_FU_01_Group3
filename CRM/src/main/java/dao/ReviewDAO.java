package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class ReviewDAO {

    public static class Review {
        public int id;
        public int customerId;
        public String customerName;
        public String itemType;
        public int itemId;
        public int rating;
        public String comment;
        public String imageUrl;   // đường dẫn ảnh, ví dụ: /review-images/abc123.jpg
        public Timestamp createdAt;
        public String storekeeperReply;  // reply của storekeeper
        public Timestamp repliedAt;      // thời gian reply
    }

    // Lấy danh sách review của 1 sản phẩm (mới nhất trước)
    public List<Review> getReviews(String itemType, int itemId) throws SQLException {
        String sql = "SELECT r.*, u.full_name AS customer_name "
                   + "FROM product_reviews r "
                   + "JOIN users u ON r.customer_id = u.id "
                   + "WHERE r.item_type = ? AND r.item_id = ? "
                   + "ORDER BY r.created_at DESC";
        List<Review> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, itemType);
            ps.setInt(2, itemId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Review rv           = new Review();
                rv.id               = rs.getInt("id");
                rv.customerId       = rs.getInt("customer_id");
                rv.customerName     = rs.getString("customer_name");
                rv.itemType         = rs.getString("item_type");
                rv.itemId           = rs.getInt("item_id");
                rv.rating           = rs.getInt("rating");
                rv.comment          = rs.getString("comment");
                rv.imageUrl         = rs.getString("image_url");
                rv.createdAt        = rs.getTimestamp("created_at");
                rv.storekeeperReply = rs.getString("storekeeper_reply");
                rv.repliedAt        = rs.getTimestamp("replied_at");
                list.add(rv);
            }
        }
        return list;
    }

    // Storekeeper reply vào một review
    public void replyToReview(int reviewId, String replyText) throws SQLException {
        String sql = "UPDATE product_reviews SET storekeeper_reply=?, replied_at=NOW() WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, replyText);
            ps.setInt(2, reviewId);
            ps.executeUpdate();
        }
    }

    // Xóa reply của storekeeper
    public void deleteReply(int reviewId) throws SQLException {
        String sql = "UPDATE product_reviews SET storekeeper_reply=NULL, replied_at=NULL WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.executeUpdate();
        }
    }

    // Điểm trung bình (0.0 nếu chưa có review)
    public double getAverageRating(String itemType, int itemId) throws SQLException {
        String sql = "SELECT AVG(rating) FROM product_reviews WHERE item_type=? AND item_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, itemType);
            ps.setInt(2, itemId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        }
        return 0;
    }

    // Phân phối số lượng theo từng mức sao (key=1..5, value=số lượng)
    public Map<Integer, Integer> getRatingDistribution(String itemType, int itemId) throws SQLException {
        String sql = "SELECT rating, COUNT(*) AS cnt FROM product_reviews "
                   + "WHERE item_type=? AND item_id=? GROUP BY rating";
        Map<Integer, Integer> dist = new HashMap<>();
        for (int i = 1; i <= 5; i++) dist.put(i, 0);
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, itemType);
            ps.setInt(2, itemId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) dist.put(rs.getInt("rating"), rs.getInt("cnt"));
        }
        return dist;
    }

    // Thêm review mới (imageUrl có thể null nếu không upload ảnh)
    public void addReview(int customerId, String itemType, int itemId,
                          int rating, String comment, String imageUrl) throws SQLException {
        String sql = "INSERT INTO product_reviews "
                   + "(customer_id, item_type, item_id, rating, comment, image_url) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setString(2, itemType);
            ps.setInt(3, itemId);
            ps.setInt(4, rating);
            ps.setString(5, comment);
            ps.setString(6, (imageUrl != null && !imageUrl.isEmpty()) ? imageUrl : null);
            ps.executeUpdate();
        }
    }

    // Kiểm tra customer đã review chưa (mỗi người chỉ review 1 lần)
    public boolean hasReviewed(int customerId, String itemType, int itemId) throws SQLException {
        String sql = "SELECT 1 FROM product_reviews "
                   + "WHERE customer_id=? AND item_type=? AND item_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setString(2, itemType);
            ps.setInt(3, itemId);
            return ps.executeQuery().next();
        }
    }

    // ── [THÊM MỚI] Kiểm tra customer đã mua sản phẩm này chưa (dựa vào invoice_items) ──
    /**
     * Trả về true nếu customer có ít nhất 1 invoice PURCHASE thành công
     * chứa sản phẩm với ref_item_id = itemId và item_type = itemType.
     * Chỉ tính invoice có payment SUCCESS (đã thanh toán) hoặc UNPAID (COD chờ giao).
     */
    public boolean hasPurchased(int customerId, String itemType, int itemId) throws SQLException {
        String sql = "SELECT 1 FROM invoices i "
                   + "JOIN invoice_items ii ON ii.invoice_id = i.id "
                   + "WHERE i.customer_id = ? "
                   + "  AND i.invoice_type = 'PURCHASE' "
                   + "  AND i.status IN ('UNPAID','PAID') "
                   + "  AND ii.item_type = ? "
                   + "  AND ii.ref_item_id = ? "
                   + "LIMIT 1";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setString(2, itemType);
            ps.setInt(3, itemId);
            return ps.executeQuery().next();
        }
    }
    
// ── [KẾT THÚC THÊM MỚI] ────────────────────────────────────────────────────────
}