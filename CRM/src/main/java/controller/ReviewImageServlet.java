package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;

/**
 * Phục vụ ảnh review từ C:/uploads/reviews/ ra trình duyệt.
 * URL pattern: /review-images/{filename}
 * Giống AvatarFileServlet nhưng dành cho ảnh đánh giá sản phẩm.
 */
public class ReviewImageServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "C:/uploads/reviews/";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy tên file từ URL: /review-images/review_5_abc123.jpg → review_5_abc123.jpg
        String pathInfo = req.getPathInfo(); // "/review_5_abc123.jpg"
        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Bảo mật: không cho phép path traversal (../)
        String filename = Paths.get(pathInfo.substring(1)).getFileName().toString();
        Path filePath = Paths.get(UPLOAD_DIR + filename);

        if (!Files.exists(filePath)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Xác định Content-Type theo đuôi file
        String lower = filename.toLowerCase();
        String contentType = lower.endsWith(".png")  ? "image/png"
                           : lower.endsWith(".webp") ? "image/webp"
                           : lower.endsWith(".gif")  ? "image/gif"
                           : "image/jpeg";

        resp.setContentType(contentType);
        resp.setContentLengthLong(Files.size(filePath));

        // Stream file ra response
        try (InputStream in = Files.newInputStream(filePath)) {
            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) != -1) {
                resp.getOutputStream().write(buf, 0, len);
            }
        }
    }
}