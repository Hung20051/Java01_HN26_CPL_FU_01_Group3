package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;

public class AvatarFileServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "C:/uploads/avatars/";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String filename = req.getPathInfo();
        if (filename == null || filename.equals("/")) {
            resp.sendError(404); return;
        }
        filename = filename.substring(1); // remove leading /

        // Security: no path traversal
        if (filename.contains("..") || filename.contains("/") || filename.contains("\\")) {
            resp.sendError(400); return;
        }

        Path filePath = Paths.get(UPLOAD_DIR + filename);
        if (!Files.exists(filePath)) {
            resp.sendError(404); return;
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