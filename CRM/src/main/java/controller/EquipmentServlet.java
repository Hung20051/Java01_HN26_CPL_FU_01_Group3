package controller;

import dao.CategoryDAO;
import dao.EquipmentDAO;
import model.EquipmentType;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class EquipmentServlet extends HttpServlet {
    private final EquipmentDAO equipmentDAO = new EquipmentDAO();
    private final CategoryDAO  categoryDAO  = new CategoryDAO();

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        try {
            if ("detail".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("detailEquipment", equipmentDAO.findTypeById(id));
                req.setAttribute("units",            equipmentDAO.findUnitsByTypeId(id));
            }

            String keyword    = req.getParameter("keyword");
            String categoryId = req.getParameter("categoryId");
            String sortBy     = req.getParameter("sortBy");
            int page = 1;
            try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}

            int total      = equipmentDAO.countTypes(keyword, categoryId);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            req.setAttribute("equipments",  equipmentDAO.findAllTypes(keyword, categoryId, sortBy, page, PAGE_SIZE));
            req.setAttribute("categories",  categoryDAO.findByType("EQUIPMENT"));
            req.setAttribute("keyword",     keyword);
            req.setAttribute("categoryId",  categoryId);
            req.setAttribute("sortBy",      sortBy);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages",  totalPages);
            req.setAttribute("total",       total);

            req.getRequestDispatcher("/numberEquipment.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/storekeeper");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        User currentUser = (User) req.getSession().getAttribute("user");

        try {
            switch (action != null ? action : "") {
                case "create": {
                    String model    = req.getParameter("model");
                    int catId       = Integer.parseInt(req.getParameter("categoryId"));
                    String desc     = req.getParameter("description");
                    double price    = Double.parseDouble(req.getParameter("unitPrice"));
                    String serial   = req.getParameter("serialNumber");

                    if (model == null || model.trim().length() < 3) {
                        req.getSession().setAttribute("flashError", "Tên model phải có ít nhất 3 ký tự!");
                        break;
                    }
                    if (serial == null || serial.trim().isEmpty()) {
                        req.getSession().setAttribute("flashError", "Serial number không được để trống!");
                        break;
                    }
                    if (equipmentDAO.existsSerialNumber(serial.trim())) {
                        req.getSession().setAttribute("flashError", "Serial number đã tồn tại!");
                        break;
                    }

                    EquipmentType et = new EquipmentType();
                    et.setModel(model.trim());
                    et.setCategoryId(catId);
                    et.setDescription(desc != null ? desc.trim() : "");
                    et.setUnitPrice(price);
                    et.setUpdatedBy(currentUser.getId());

                    int newId = equipmentDAO.insertType(et);
                    equipmentDAO.insertUnit(newId, serial.trim(), currentUser.getId());
                    req.getSession().setAttribute("flashSuccess", "Thêm thiết bị thành công!");
                    break;
                }
                case "edit": {
                    int id       = Integer.parseInt(req.getParameter("id"));
                    String model = req.getParameter("model");
                    int catId    = Integer.parseInt(req.getParameter("categoryId"));
                    String desc  = req.getParameter("description");
                    double price = Double.parseDouble(req.getParameter("unitPrice"));

                    if (model == null || model.trim().length() < 3) {
                        req.getSession().setAttribute("flashError", "Tên model phải có ít nhất 3 ký tự!");
                        break;
                    }

                    EquipmentType et = new EquipmentType();
                    et.setId(id);
                    et.setModel(model.trim());
                    et.setCategoryId(catId);
                    et.setDescription(desc != null ? desc.trim() : "");
                    et.setUnitPrice(price);
                    et.setUpdatedBy(currentUser.getId());
                    equipmentDAO.updateType(et);
                    req.getSession().setAttribute("flashSuccess", "Cập nhật thiết bị thành công!");
                    break;
                }
                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    equipmentDAO.deleteType(id);
                    req.getSession().setAttribute("flashSuccess", "Xóa thiết bị thành công!");
                    break;
                }
                case "addUnit": {
                    // Thêm serial number mới cho equipment type đã có
                    int typeId  = Integer.parseInt(req.getParameter("equipmentTypeId"));
                    String serial = req.getParameter("serialNumber");
                    if (serial == null || serial.trim().isEmpty()) {
                        req.getSession().setAttribute("flashError", "Serial number không được để trống!");
                        break;
                    }
                    if (equipmentDAO.existsSerialNumber(serial.trim())) {
                        req.getSession().setAttribute("flashError", "Serial number đã tồn tại!");
                        break;
                    }
                    equipmentDAO.insertUnit(typeId, serial.trim(), currentUser.getId());
                    req.getSession().setAttribute("flashSuccess", "Nhập kho thiết bị thành công!");
                    break;
                }
                default:
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/numberEquipment");
    }
}