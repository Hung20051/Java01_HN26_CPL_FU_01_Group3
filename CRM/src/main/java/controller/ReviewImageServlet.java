package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;

/**
 * Phục vụ ảnh review từ thư mục uploads/reviews/ ra trình duyệt.
 * URL pattern: /review-images/{filename}
 */
public class ReviewImageServlet extends HttpServlet {

    private String uploadDir; // ✅ instance variable thay vì static final

    @Override
    public void init() throws ServletException {
        uploadDir = getServletContext().getRealPath("/uploads/reviews/");
        try {
            Files.createDirectories(Paths.get(uploadDir));
        } catch (IOException e) {
            throw new ServletException("Cannot create review upload directory", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Lấy tên file từ URL: /review-images/review_5_abc123.jpg → review_5_abc123.jpg
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        // Security: không cho phép path traversal (../)
        String filename = Paths.get(pathInfo.substring(1)).getFileName().toString();
        Path filePath = Paths.get(uploadDir, filename);
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