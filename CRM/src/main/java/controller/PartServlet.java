package controller;

import dao.CategoryDAO;
import dao.PartDAO;
import dao.ReviewDAO;
import model.PartType;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.*;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class PartServlet extends HttpServlet {

    private final PartDAO partDAO = new PartDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    private static final int PAGE_SIZE = 10;

    private String getUploadDir() {
        return getServletContext().getRealPath("") + File.separator
                + "uploads" + File.separator + "parts";
    }

    // =========================================================================
    //  GET
    // =========================================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        boolean wantJson = isJson(req);

        try {
            // ── DETAIL PAGE ─────────────────────────────────────────────────
            if ("detailPage".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                PartType pt = partDAO.findTypeById(id);
                if (pt == null) {
                    if (wantJson) {
                        writeError(resp, 404, "Part not found");
                        return;
                    }
                    resp.sendRedirect(req.getContextPath() + "/numberPart");
                    return;
                }

                List<model.PartUnit> units = partDAO.findUnitsByTypeId(id);

                if (wantJson) {
                    resp.setContentType("application/json;charset=UTF-8");
                    StringBuilder json = new StringBuilder();
                    json.append("{");
                    json.append("\"id\":").append(pt.getId()).append(",");
                    json.append("\"name\":").append(jsonStr(pt.getName())).append(",");
                    json.append("\"categoryId\":").append(pt.getCategoryId()).append(",");
                    json.append("\"categoryName\":").append(jsonStr(pt.getCategoryName())).append(",");
                    json.append("\"description\":").append(jsonStr(pt.getDescription())).append(",");
                    json.append("\"unitPrice\":").append(pt.getUnitPrice()).append(",");
                    json.append("\"totalUnits\":").append(pt.getTotalUnits()).append(",");
                    json.append("\"availableUnits\":").append(pt.getAvailableUnits()).append(",");
                    json.append("\"imageUrl\":").append(jsonStr(pt.getImageUrl())).append(",");
                    json.append("\"avgRating\":").append(reviewDAO.getAverageRating("PART", id)).append(",");
                    json.append("\"units\":[");
                    for (int i = 0; i < units.size(); i++) {
                        model.PartUnit u = units.get(i);
                        if (i > 0) {
                            json.append(",");
                        }
                        json.append("{");
                        json.append("\"id\":").append(u.getId()).append(",");
                        json.append("\"partTypeName\":").append(jsonStr(u.getPartTypeName())).append(",");
                        json.append("\"status\":").append(jsonStr(u.getStatus()));
                        json.append("}");
                    }
                    json.append("]}");
                    resp.getWriter().write(json.toString());
                    return;
                }

                req.setAttribute("part", pt);
                req.setAttribute("units", units);
                req.setAttribute("categories", categoryDAO.findByType("PART"));
                req.setAttribute("reviews", reviewDAO.getReviews("PART", id));
                req.setAttribute("avgRating", reviewDAO.getAverageRating("PART", id));
                req.setAttribute("ratingDist", reviewDAO.getRatingDistribution("PART", id));
                req.getRequestDispatcher("/storekeeperPartDetail.jsp").forward(req, resp);
                return;
            }

            // ── DETAIL inline panel — giữ nguyên, không thêm JSON ───────────
            if ("detail".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("detailPart", partDAO.findTypeById(id));
                req.setAttribute("units", partDAO.findUnitsByTypeId(id));
            }

            // ── LIST ─────────────────────────────────────────────────────────
            String keyword = req.getParameter("keyword");
            String categoryId = req.getParameter("categoryId");
            String sortBy = req.getParameter("sortBy");
            int page = 1;
            try {
                page = Integer.parseInt(req.getParameter("page"));
            } catch (Exception ignored) {
            }

            int total = partDAO.countTypes(keyword, categoryId);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
            if (totalPages < 1) {
                totalPages = 1;
            }

            List<PartType> parts = partDAO.findAllTypes(keyword, categoryId, sortBy, page, PAGE_SIZE);

            if (wantJson) {
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"page\":").append(page).append(",");
                json.append("\"totalPages\":").append(totalPages).append(",");
                json.append("\"total\":").append(total).append(",");
                json.append("\"parts\":[");
                for (int i = 0; i < parts.size(); i++) {
                    PartType pt = parts.get(i);
                    if (i > 0) {
                        json.append(",");
                    }
                    json.append("{");
                    json.append("\"id\":").append(pt.getId()).append(",");
                    json.append("\"name\":").append(jsonStr(pt.getName())).append(",");
                    json.append("\"categoryName\":").append(jsonStr(pt.getCategoryName())).append(",");
                    json.append("\"unitPrice\":").append(pt.getUnitPrice()).append(",");
                    json.append("\"totalUnits\":").append(pt.getTotalUnits()).append(",");
                    json.append("\"availableUnits\":").append(pt.getAvailableUnits()).append(",");
                    json.append("\"imageUrl\":").append(jsonStr(pt.getImageUrl()));
                    json.append("}");
                }
                json.append("]}");
                resp.getWriter().write(json.toString());
                return;
            }

            req.setAttribute("parts", parts);
            req.setAttribute("categories", categoryDAO.findByType("PART"));
            req.setAttribute("keyword", keyword != null ? keyword : "");
            req.setAttribute("categoryId", categoryId != null ? categoryId : "");
            req.setAttribute("sortBy", sortBy != null ? sortBy : "");
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("total", total);
            req.getRequestDispatcher("/numberPart.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMessage", "Lỗi tải dữ liệu: " + e.getMessage());
            try {
                req.setAttribute("parts", new ArrayList<>());
                req.setAttribute("categories", new ArrayList<>());
                req.setAttribute("keyword", "");
                req.setAttribute("categoryId", "");
                req.setAttribute("sortBy", "");
                req.setAttribute("currentPage", 1);
                req.setAttribute("totalPages", 1);
                req.setAttribute("total", 0);
                req.getRequestDispatcher("/numberPart.jsp").forward(req, resp);
            } catch (Exception ignored) {
            }
        }
    }

    // =========================================================================
    //  POST — giữ nguyên hoàn toàn
    // =========================================================================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        User currentUser = (User) req.getSession().getAttribute("user");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            switch (action != null ? action : "") {

                case "create": {
                    String name = req.getParameter("name");
                    int catId = Integer.parseInt(req.getParameter("categoryId"));
                    String desc = req.getParameter("description");
                    double price = Double.parseDouble(req.getParameter("unitPrice"));
                    int qty = Integer.parseInt(req.getParameter("quantity"));

                    if (name == null || name.trim().length() < 3) {
                        req.getSession().setAttribute("flashError", "Tên linh kiện phải có ít nhất 3 ký tự!");
                        break;
                    }
                    if (desc == null || desc.trim().length() < 10 || desc.trim().length() > 100) {
                        req.getSession().setAttribute("flashError", "Mô tả phải từ 10–100 ký tự!");
                        break;
                    }
                    if (qty < 1 || qty > 100) {
                        req.getSession().setAttribute("flashError", "Số lượng nhập phải từ 1–100!");
                        break;
                    }

                    String imageUrl = resolveImage(req, "create");

                    PartType pt = new PartType();
                    pt.setName(name.trim());
                    pt.setCategoryId(catId);
                    pt.setDescription(desc.trim());
                    pt.setUnitPrice(price);
                    pt.setImageUrl(imageUrl);
                    pt.setUpdatedBy(currentUser.getId());

                    int newId = partDAO.insertType(pt);
                    partDAO.insertUnits(newId, qty, currentUser.getId());
                    req.getSession().setAttribute("flashSuccess", "Thêm linh kiện thành công!");
                    break;
                }

                case "edit": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    String name = req.getParameter("name");
                    int catId = Integer.parseInt(req.getParameter("categoryId"));
                    String desc = req.getParameter("description");
                    double price = Double.parseDouble(req.getParameter("unitPrice"));

                    if (name == null || name.trim().length() < 3) {
                        req.getSession().setAttribute("flashError", "Tên linh kiện phải có ít nhất 3 ký tự!");
                        break;
                    }

                    String imageUrl = resolveImage(req, "edit");

                    PartType pt = new PartType();
                    pt.setId(id);
                    pt.setName(name.trim());
                    pt.setCategoryId(catId);
                    pt.setDescription(desc != null ? desc.trim() : "");
                    pt.setUnitPrice(price);
                    pt.setImageUrl(imageUrl);
                    pt.setUpdatedBy(currentUser.getId());

                    partDAO.updateType(pt);
                    req.getSession().setAttribute("flashSuccess", "Cập nhật linh kiện thành công!");

                    String referer = req.getParameter("referer");
                    if ("detailPage".equals(referer)) {
                        resp.sendRedirect(req.getContextPath() + "/numberPart?action=detailPage&id=" + id);
                        return;
                    }
                    break;
                }

                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    PartType existing = partDAO.findTypeById(id);
                    if (existing != null && existing.getImageUrl() != null
                            && existing.getImageUrl().startsWith("/uploads/parts/")) {
                        deleteImageFile(existing.getImageUrl());
                    }
                    partDAO.deleteType(id);
                    req.getSession().setAttribute("flashSuccess", "Xóa linh kiện thành công!");
                    break;
                }

                case "import": {
                    int partTypeId = Integer.parseInt(req.getParameter("partTypeId"));
                    int qty = Integer.parseInt(req.getParameter("quantity"));
                    if (qty < 1 || qty > 100) {
                        req.getSession().setAttribute("flashError", "Số lượng nhập phải từ 1–100!");
                        String referer = req.getParameter("referer");
                        if ("detailPage".equals(referer)) {
                            resp.sendRedirect(req.getContextPath() + "/numberPart?action=detailPage&id=" + partTypeId);
                            return;
                        }
                        break;
                    }
                    partDAO.insertUnits(partTypeId, qty, currentUser.getId());
                    req.getSession().setAttribute("flashSuccess", "Nhập kho thành công " + qty + " unit!");

                    String refImport = req.getParameter("referer");
                    if ("detailPage".equals(refImport)) {
                        resp.sendRedirect(req.getContextPath() + "/numberPart?action=detailPage&id=" + partTypeId);
                        return;
                    }
                    break;
                }

                case "reduceStock": {
                    int partTypeId = Integer.parseInt(req.getParameter("partTypeId"));
                    int qty = Integer.parseInt(req.getParameter("reduceQty"));

                    if (qty < 1) {
                        req.getSession().setAttribute("flashError", "Số lượng giảm phải ít nhất 1!");
                        resp.sendRedirect(req.getContextPath() + "/numberPart?action=detailPage&id=" + partTypeId);
                        return;
                    }

                    PartType current = partDAO.findTypeById(partTypeId);
                    if (current == null) {
                        req.getSession().setAttribute("flashError", "Không tìm thấy linh kiện!");
                        resp.sendRedirect(req.getContextPath() + "/numberPart");
                        return;
                    }
                    if (qty > current.getAvailableUnits()) {
                        req.getSession().setAttribute("flashError",
                                "Chỉ có " + current.getAvailableUnits() + " unit AVAILABLE, không thể xóa " + qty + "!");
                        resp.sendRedirect(req.getContextPath() + "/numberPart?action=detailPage&id=" + partTypeId);
                        return;
                    }

                    int deleted = partDAO.deleteAvailableUnits(partTypeId, qty);
                    req.getSession().setAttribute("flashSuccess",
                            "Đã xóa " + deleted + " unit AVAILABLE khỏi kho!");
                    resp.sendRedirect(req.getContextPath() + "/numberPart?action=detailPage&id=" + partTypeId);
                    return;
                }

                default:
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/numberPart");
    }

    // =========================================================================
    //  HELPERS
    // =========================================================================
    private boolean isJson(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        return accept != null && accept.contains("application/json");
    }

    private void writeError(HttpServletResponse resp, int status, String msg) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setStatus(status);
        resp.getWriter().write("{\"error\":\"" + msg + "\"}");
    }

    private String jsonStr(String s) {
        if (s == null) {
            return "null";
        }
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
    }

    private String resolveImage(HttpServletRequest req, String mode)
            throws IOException, ServletException {

        if ("edit".equals(mode) && "true".equals(req.getParameter("clearImage"))) {
            return null;
        }

        Part filePart = null;
        try {
            filePart = req.getPart("imageFile");
        } catch (Exception ignored) {
        }

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = sanitizeFileName(filePart.getSubmittedFileName());
            String extension = getExtension(fileName);

            if (!isImageExtension(extension)) {
                req.getSession().setAttribute("flashError",
                        "Chỉ chấp nhận file ảnh: jpg, png, webp, gif, avif");
                return null;
            }

            String uniqueName = UUID.randomUUID().toString() + "." + extension;
            String uploadDir = getUploadDir();
            Files.createDirectories(Paths.get(uploadDir));

            String filePath = uploadDir + File.separator + uniqueName;
            try (InputStream in = filePart.getInputStream()) {
                Files.copy(in, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
            }
            return "/uploads/parts/" + uniqueName;
        }

        String imageUrl = req.getParameter("imageUrl");
        if (imageUrl != null && !imageUrl.trim().isEmpty()) {
            return imageUrl.trim();
        }

        return null;
    }

    private void deleteImageFile(String imageUrl) {
        try {
            String relativePath = imageUrl.replace("/", File.separator);
            String fullPath = getServletContext().getRealPath("") + relativePath;
            Files.deleteIfExists(Paths.get(fullPath));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String sanitizeFileName(String name) {
        if (name == null) {
            return "image";
        }
        int idx = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
        return idx >= 0 ? name.substring(idx + 1) : name;
    }

    private String getExtension(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return dot >= 0 ? fileName.substring(dot + 1).toLowerCase() : "";
    }

    private boolean isImageExtension(String ext) {
        return ext.matches("jpg|jpeg|png|webp|gif|avif");
    }
}
