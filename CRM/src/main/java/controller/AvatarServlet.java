package controller;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.util.UUID;

@MultipartConfig(maxFileSize = 2 * 1024 * 1024) // 2MB
public class AvatarServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final String UPLOAD_DIR = "C:/uploads/avatars/";
    private static final String[] ALLOWED_TYPES = {"image/jpeg", "image/png", "image/gif", "image/webp"};

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Not logged in\"}");
            return;
        }

        try {
            Part filePart = req.getPart("avatar");
            if (filePart == null || filePart.getSize() == 0) {
                resp.getWriter().write("{\"success\":false,\"error\":\"No file selected\"}");
                return;
            }

            // Validate type
            String contentType = filePart.getContentType();
            boolean allowed = false;
            for (String t : ALLOWED_TYPES) {
                if (t.equals(contentType)) { allowed = true; break; }
            }
            if (!allowed) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Only JPG, PNG, GIF, WEBP allowed\"}");
                return;
            }

            // Validate size
            if (filePart.getSize() > 2 * 1024 * 1024) {
                resp.getWriter().write("{\"success\":false,\"error\":\"File too large. Max 2MB\"}");
                return;
            }

            // Create dir if not exists
            Files.createDirectories(Paths.get(UPLOAD_DIR));

            // Delete old avatar if exists
            String oldUrl = me.getAvatarUrl();
            if (oldUrl != null && oldUrl.startsWith("/avatar/file/")) {
                String oldFile = oldUrl.replace("/avatar/file/", "");
                try { Files.deleteIfExists(Paths.get(UPLOAD_DIR + oldFile)); } catch (Exception ignored) {}
            }

            // Generate unique filename
            String ext = contentType.equals("image/png") ? ".png"
                       : contentType.equals("image/gif") ? ".gif"
                       : contentType.equals("image/webp") ? ".webp" : ".jpg";
            String filename = "avatar_" + me.getId() + "_" + UUID.randomUUID().toString().substring(0, 8) + ext;

            // Save file
            try (InputStream in = filePart.getInputStream()) {
                Files.copy(in, Paths.get(UPLOAD_DIR + filename), StandardCopyOption.REPLACE_EXISTING);
            }

            // Update DB
            String avatarUrl = "/avatar/file/" + filename;
            me.setAvatarUrl(avatarUrl);
            userDAO.updateAvatar(me.getId(), avatarUrl);

            // Refresh session
            User fresh = userDAO.findById(me.getId());
            req.getSession().setAttribute("user", fresh);

            resp.getWriter().write("{\"success\":true,\"url\":\"" + req.getContextPath() + avatarUrl + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}