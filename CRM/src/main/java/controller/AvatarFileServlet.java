package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;

public class AvatarFileServlet extends HttpServlet {

    private String uploadDir; // ✅ instance variable thay vì static final

    @Override
    public void init() throws ServletException {
        uploadDir = getServletContext().getRealPath("/uploads/avatars/");
        try {
            Files.createDirectories(Paths.get(uploadDir));
        } catch (IOException e) {
            throw new ServletException("Cannot create avatar upload directory", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String filename = req.getPathInfo();
        if (filename == null || filename.equals("/")) {
            resp.sendError(404);
            return;
        }
        filename = filename.substring(1); // remove leading /
        // Security: no path traversal
        if (filename.contains("..") || filename.contains("/") || filename.contains("\\")) {
            resp.sendError(400);
            return;
        }
        Path filePath = Paths.get(uploadDir, filename);
        if (!Files.exists(filePath)) {
            resp.sendError(404);
            return;
        }
        // Set content type
        String ct = filename.endsWith(".png") ? "image/png"
                : filename.endsWith(".gif") ? "image/gif"
                : filename.endsWith(".webp") ? "image/webp" : "image/jpeg";
        resp.setContentType(ct);
        resp.setHeader("Cache-Control", "max-age=86400"); // cache 1 day
        Files.copy(filePath, resp.getOutputStream());
    }
}
