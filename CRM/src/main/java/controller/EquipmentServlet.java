package controller;

import dao.CategoryDAO;
import dao.EquipmentDAO;
import model.EquipmentType;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.*;
import java.nio.file.*;
import java.util.*;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize       = 5 * 1024 * 1024,
    maxRequestSize    = 10 * 1024 * 1024
)
public class EquipmentServlet extends HttpServlet {

    private final EquipmentDAO equipmentDAO = new EquipmentDAO();
    private final CategoryDAO  categoryDAO  = new CategoryDAO();

    private static final int PAGE_SIZE = 10;

    private String getUploadDir() {
        return getServletContext().getRealPath("") + File.separator
             + "uploads" + File.separator + "equipment";
    }

    // =========================================================================
    //  GET
    // =========================================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");

        try {
            // ── DETAIL PAGE ─────────────────────────────────────────────────
            if ("detailPage".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                EquipmentType et = equipmentDAO.findTypeById(id);
                if (et == null) { resp.sendRedirect(req.getContextPath() + "/numberEquipment"); return; }
                req.setAttribute("equipment",   et);
                req.setAttribute("units",       equipmentDAO.findUnitsByTypeId(id));
                req.setAttribute("categories",  categoryDAO.findByType("EQUIPMENT"));
                req.getRequestDispatcher("/storekeeperEquipmentDetail.jsp").forward(req, resp);
                return;
            }

            // ── LIST PAGE ────────────────────────────────────────────────────
            String keyword    = req.getParameter("keyword");
            String categoryId = req.getParameter("categoryId");
            String sortBy     = req.getParameter("sortBy");
            int page = 1;
            try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}

            int total      = equipmentDAO.countTypes(keyword, categoryId);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
            if (totalPages < 1) totalPages = 1;

            List<model.EquipmentType> equipments = equipmentDAO.findAllTypes(keyword, categoryId, sortBy, page, PAGE_SIZE);
            Map<Integer, List<model.EquipmentUnit>> unitsMap = new HashMap<>();
            for (EquipmentType et : equipments) {
                unitsMap.put(et.getId(), equipmentDAO.findUnitsByTypeId(et.getId()));
            }

            req.setAttribute("equipments",  equipments);
            req.setAttribute("unitsMap",    unitsMap);
            req.setAttribute("categories",  categoryDAO.findByType("EQUIPMENT"));
            req.setAttribute("keyword",     keyword    != null ? keyword    : "");
            req.setAttribute("categoryId",  categoryId != null ? categoryId : "");
            req.setAttribute("sortBy",      sortBy     != null ? sortBy     : "");
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages",  totalPages);
            req.setAttribute("total",       total);

            req.getRequestDispatcher("/numberEquipment.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/numberEquipment");
        }
    }

    // =========================================================================
    //  POST
    // =========================================================================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        try {
            switch (action != null ? action : "") {

                // ── CREATE ────────────────────────────────────────────────────
                case "create": {
                    String model  = req.getParameter("model");
                    int    catId  = Integer.parseInt(req.getParameter("categoryId"));
                    String desc   = req.getParameter("description");
                    double price  = Double.parseDouble(req.getParameter("unitPrice"));

                    if (model == null || model.trim().length() < 3) {
                        req.getSession().setAttribute("flashError", "Tên model phải có ít nhất 3 ký tự!");
                        break;
                    }

                    String imageUrl = resolveImage(req, "create");

                    EquipmentType et = new EquipmentType();
                    et.setModel(model.trim());
                    et.setCategoryId(catId);
                    et.setDescription(desc != null ? desc.trim() : "");
                    et.setUnitPrice(price);
                    et.setImageUrl(imageUrl);
                    et.setUpdatedBy(currentUser.getId());

                    int newId = equipmentDAO.insertType(et);

                    // Auto-generate first unit with UUID serial
                    String serial = generateSerial(model.trim());
                    if (equipmentDAO.existsSerialNumber(serial)) {
                        serial = generateSerial(model.trim()); // retry
                    }
                    equipmentDAO.insertUnit(newId, serial, currentUser.getId());

                    req.getSession().setAttribute("flashSuccess", "Thêm thiết bị thành công! Serial: " + serial);
                    break;
                }

                // ── EDIT ──────────────────────────────────────────────────────
                case "edit": {
                    int    id    = Integer.parseInt(req.getParameter("id"));
                    String model = req.getParameter("model");
                    int    catId = Integer.parseInt(req.getParameter("categoryId"));
                    String desc  = req.getParameter("description");
                    double price = Double.parseDouble(req.getParameter("unitPrice"));

                    if (model == null || model.trim().length() < 3) {
                        req.getSession().setAttribute("flashError", "Tên model phải có ít nhất 3 ký tự!");
                        String referer = req.getParameter("referer");
                        if ("detailPage".equals(referer)) {
                            resp.sendRedirect(req.getContextPath() + "/numberEquipment?action=detailPage&id=" + id);
                            return;
                        }
                        break;
                    }

                    String imageUrl = resolveImage(req, "edit");

                    EquipmentType et = new EquipmentType();
                    et.setId(id);
                    et.setModel(model.trim());
                    et.setCategoryId(catId);
                    et.setDescription(desc != null ? desc.trim() : "");
                    et.setUnitPrice(price);
                    et.setImageUrl(imageUrl);
                    et.setUpdatedBy(currentUser.getId());

                    equipmentDAO.updateType(et);
                    req.getSession().setAttribute("flashSuccess", "Cập nhật thiết bị thành công!");

                    String referer = req.getParameter("referer");
                    if ("detailPage".equals(referer)) {
                        resp.sendRedirect(req.getContextPath() + "/numberEquipment?action=detailPage&id=" + id);
                        return;
                    }
                    break;
                }

                // ── DELETE ────────────────────────────────────────────────────
                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    EquipmentType existing = equipmentDAO.findTypeById(id);
                    if (existing != null && existing.getImageUrl() != null
                            && existing.getImageUrl().startsWith("/uploads/equipment/")) {
                        deleteImageFile(existing.getImageUrl());
                    }
                    equipmentDAO.deleteType(id);
                    req.getSession().setAttribute("flashSuccess", "Xóa thiết bị thành công!");
                    break;
                }

                // ── STOCK IN (add units with UUID serial) ─────────────────────
                case "stockIn": {
                    int    typeId = Integer.parseInt(req.getParameter("equipmentTypeId"));
                    int    qty    = Integer.parseInt(req.getParameter("quantity"));
                    String referer = req.getParameter("referer");

                    if (qty < 1 || qty > 100) {
                        req.getSession().setAttribute("flashError", "Số lượng nhập phải từ 1–100!");
                        if ("detailPage".equals(referer)) {
                            resp.sendRedirect(req.getContextPath() + "/numberEquipment?action=detailPage&id=" + typeId);
                            return;
                        }
                        break;
                    }

                    EquipmentType et = equipmentDAO.findTypeById(typeId);
                    List<String> added = new ArrayList<>();
                    for (int i = 0; i < qty; i++) {
                        String serial = generateSerial(et != null ? et.getModel() : "EQ");
                        int tries = 0;
                        while (equipmentDAO.existsSerialNumber(serial) && tries < 10) {
                            serial = generateSerial(et != null ? et.getModel() : "EQ");
                            tries++;
                        }
                        equipmentDAO.insertUnit(typeId, serial, currentUser.getId());
                        added.add(serial);
                    }

                    req.getSession().setAttribute("flashSuccess",
                        "Nhập kho thành công " + added.size() + " thiết bị!");

                    if ("detailPage".equals(referer)) {
                        resp.sendRedirect(req.getContextPath() + "/numberEquipment?action=detailPage&id=" + typeId);
                        return;
                    }
                    break;
                }

                // ── REDUCE STOCK (xóa N units AVAILABLE) ─────────────────────
                case "reduceStock": {
                    int typeId = Integer.parseInt(req.getParameter("equipmentTypeId"));
                    int qty    = Integer.parseInt(req.getParameter("reduceQty"));

                    if (qty < 1) {
                        req.getSession().setAttribute("flashError", "Số lượng giảm phải ít nhất 1!");
                        resp.sendRedirect(req.getContextPath() + "/numberEquipment?action=detailPage&id=" + typeId);
                        return;
                    }

                    EquipmentType current = equipmentDAO.findTypeById(typeId);
                    if (current == null) {
                        req.getSession().setAttribute("flashError", "Không tìm thấy thiết bị!");
                        resp.sendRedirect(req.getContextPath() + "/numberEquipment");
                        return;
                    }
                    if (qty > current.getAvailableUnits()) {
                        req.getSession().setAttribute("flashError",
                            "Chỉ có " + current.getAvailableUnits() + " unit AVAILABLE, không thể xóa " + qty + "!");
                        resp.sendRedirect(req.getContextPath() + "/numberEquipment?action=detailPage&id=" + typeId);
                        return;
                    }

                    int deleted = equipmentDAO.deleteAvailableUnits(typeId, qty);
                    req.getSession().setAttribute("flashSuccess",
                        "Đã xóa " + deleted + " unit AVAILABLE khỏi kho!");
                    resp.sendRedirect(req.getContextPath() + "/numberEquipment?action=detailPage&id=" + typeId);
                    return;
                }

                // ── LEGACY addUnit (keep backward compat) ─────────────────────
                case "addUnit": {
                    int    typeId     = Integer.parseInt(req.getParameter("equipmentTypeId"));
                    String serialsRaw = req.getParameter("serialNumbers");
                    if (serialsRaw == null || serialsRaw.trim().isEmpty()) {
                        req.getSession().setAttribute("flashError", "Không có serial number nào được tạo!");
                        break;
                    }
                    String[] parts     = serialsRaw.split(",");
                    List<String> toInsert  = new ArrayList<>();
                    List<String> duplicates = new ArrayList<>();
                    for (String raw : parts) {
                        String s = raw.trim();
                        if (s.isEmpty()) continue;
                        if (equipmentDAO.existsSerialNumber(s)) duplicates.add(s);
                        else toInsert.add(s);
                    }
                    if (toInsert.isEmpty()) {
                        req.getSession().setAttribute("flashError",
                            "Tất cả serial đã tồn tại: " + String.join(", ", duplicates));
                        break;
                    }
                    for (String s : toInsert) equipmentDAO.insertUnit(typeId, s, currentUser.getId());
                    if (duplicates.isEmpty()) {
                        req.getSession().setAttribute("flashSuccess", "Nhập kho thành công " + toInsert.size() + " thiết bị!");
                    } else {
                        req.getSession().setAttribute("flashSuccess",
                            "Nhập kho " + toInsert.size() + " thành công. Bỏ qua " + duplicates.size() + " serial trùng.");
                    }
                    break;
                }

                default: break;
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/numberEquipment");
    }

    // =========================================================================
    //  HELPERS
    // =========================================================================
    /** Generate serial: EQ-{PREFIX3}-{UUID8} e.g. EQ-DAI-a3f9b21c */
    private String generateSerial(String modelName) {
        String prefix = modelName.replaceAll("[^A-Za-z0-9]", "")
                                 .toUpperCase()
                                 .substring(0, Math.min(4, modelName.replaceAll("[^A-Za-z0-9]","").length()));
        if (prefix.isEmpty()) prefix = "EQ";
        String uuid8 = UUID.randomUUID().toString().replace("-","").substring(0, 8).toUpperCase();
        return "EQ-" + prefix + "-" + uuid8;
    }

    private String resolveImage(HttpServletRequest req, String mode)
            throws IOException, ServletException {
        if ("edit".equals(mode) && "true".equals(req.getParameter("clearImage"))) return null;

        Part filePart = null;
        try { filePart = req.getPart("imageFile"); } catch (Exception ignored) {}

        if (filePart != null && filePart.getSize() > 0) {
            String fileName  = sanitizeFileName(filePart.getSubmittedFileName());
            String extension = getExtension(fileName);
            if (!isImageExtension(extension)) {
                req.getSession().setAttribute("flashError", "Chỉ chấp nhận file ảnh: jpg, png, webp, gif, avif");
                return null;
            }
            String uniqueName = UUID.randomUUID() + "." + extension;
            String uploadDir  = getUploadDir();
            Files.createDirectories(Paths.get(uploadDir));
            try (InputStream in = filePart.getInputStream()) {
                Files.copy(in, Paths.get(uploadDir + File.separator + uniqueName), StandardCopyOption.REPLACE_EXISTING);
            }
            return "/uploads/equipment/" + uniqueName;
        }

        String imageUrl = req.getParameter("imageUrl");
        if (imageUrl != null && !imageUrl.trim().isEmpty()) return imageUrl.trim();

        // edit mode: keep existing
        if ("edit".equals(mode)) {
            String existing = req.getParameter("existingImageUrl");
            if (existing != null && !existing.trim().isEmpty()) return existing.trim();
        }

        return null;
    }

    private void deleteImageFile(String imageUrl) {
        try {
            String relativePath = imageUrl.replace("/", File.separator);
            String fullPath = getServletContext().getRealPath("") + relativePath;
            Files.deleteIfExists(Paths.get(fullPath));
        } catch (Exception e) { e.printStackTrace(); }
    }

    private String sanitizeFileName(String name) {
        if (name == null) return "image";
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