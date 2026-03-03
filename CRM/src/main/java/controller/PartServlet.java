package controller;

import dao.CategoryDAO;
import dao.PartDAO;
import model.PartType;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class PartServlet extends HttpServlet {
    private final PartDAO     partDAO     = new PartDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        try {
            if ("detail".equals(action)) {
                // Xem chi tiết trạng thái của 1 part type
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("detailPart",  partDAO.findTypeById(id));
                req.setAttribute("units",        partDAO.findUnitsByTypeId(id));
            }

            // Luôn load danh sách
            String keyword    = req.getParameter("keyword");
            String categoryId = req.getParameter("categoryId");
            String sortBy     = req.getParameter("sortBy");
            int page = 1;
            try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}

            int total     = partDAO.countTypes(keyword, categoryId);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            req.setAttribute("parts",       partDAO.findAllTypes(keyword, categoryId, sortBy, page, PAGE_SIZE));
            req.setAttribute("categories",  categoryDAO.findByType("PART"));
            req.setAttribute("keyword",     keyword);
            req.setAttribute("categoryId",  categoryId);
            req.setAttribute("sortBy",      sortBy);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages",  totalPages);
            req.setAttribute("total",       total);

            req.getRequestDispatcher("/numberPart.jsp").forward(req, resp);
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
                    String name     = req.getParameter("name");
                    int catId       = Integer.parseInt(req.getParameter("categoryId"));
                    String desc     = req.getParameter("description");
                    double price    = Double.parseDouble(req.getParameter("unitPrice"));
                    int qty         = Integer.parseInt(req.getParameter("quantity"));

                    // Validate
                    if (name == null || name.trim().length() < 3) {
                        req.getSession().setAttribute("flashError", "Tên linh kiện phải có ít nhất 3 ký tự!");
                        break;
                    }
                    if (desc == null || desc.trim().length() < 10 || desc.trim().length() > 100) {
                        req.getSession().setAttribute("flashError", "Mô tả phải từ 10-100 ký tự!");
                        break;
                    }
                    if (qty < 1 || qty > 100) {
                        req.getSession().setAttribute("flashError", "Số lượng nhập phải từ 1-100!");
                        break;
                    }

                    PartType pt = new PartType();
                    pt.setName(name.trim());
                    pt.setCategoryId(catId);
                    pt.setDescription(desc.trim());
                    pt.setUnitPrice(price);
                    pt.setUpdatedBy(currentUser.getId());

                    int newId = partDAO.insertType(pt);
                    partDAO.insertUnits(newId, qty, currentUser.getId());
                    req.getSession().setAttribute("flashSuccess", "Thêm linh kiện thành công!");
                    break;
                }
                case "edit": {
                    int id       = Integer.parseInt(req.getParameter("id"));
                    String name  = req.getParameter("name");
                    int catId    = Integer.parseInt(req.getParameter("categoryId"));
                    String desc  = req.getParameter("description");
                    double price = Double.parseDouble(req.getParameter("unitPrice"));

                    if (name == null || name.trim().length() < 3) {
                        req.getSession().setAttribute("flashError", "Tên linh kiện phải có ít nhất 3 ký tự!");
                        break;
                    }

                    PartType pt = new PartType();
                    pt.setId(id);
                    pt.setName(name.trim());
                    pt.setCategoryId(catId);
                    pt.setDescription(desc != null ? desc.trim() : "");
                    pt.setUnitPrice(price);
                    pt.setUpdatedBy(currentUser.getId());
                    partDAO.updateType(pt);
                    req.getSession().setAttribute("flashSuccess", "Cập nhật linh kiện thành công!");
                    break;
                }
                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    partDAO.deleteType(id);
                    req.getSession().setAttribute("flashSuccess", "Xóa linh kiện thành công!");
                    break;
                }
                case "import": {
                    // Nhập thêm units cho part đã có
                    int partTypeId = Integer.parseInt(req.getParameter("partTypeId"));
                    int qty        = Integer.parseInt(req.getParameter("quantity"));
                    if (qty < 1 || qty > 100) {
                        req.getSession().setAttribute("flashError", "Số lượng nhập phải từ 1-100!");
                        break;
                    }
                    partDAO.insertUnits(partTypeId, qty, currentUser.getId());
                    req.getSession().setAttribute("flashSuccess", "Nhập kho thành công " + qty + " unit!");
                    break;
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
}