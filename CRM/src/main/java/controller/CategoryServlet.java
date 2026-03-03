package controller;

import dao.CategoryDAO;
import model.Category;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class CategoryServlet extends HttpServlet {
    private final CategoryDAO dao = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("categories", dao.findAll());
            req.getRequestDispatcher("/categoryManage.jsp").forward(req, resp);
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
        try {
            switch (action != null ? action : "") {
                case "create": {
                    String name = req.getParameter("name");
                    String type = req.getParameter("type");
                    if (name == null || name.trim().isEmpty()) {
                        req.getSession().setAttribute("flashError", "Tên danh mục không được để trống!");
                        break;
                    }
                    Category cat = new Category();
                    cat.setName(name.trim());
                    cat.setType(type != null ? type : "BOTH");
                    dao.insert(cat);
                    req.getSession().setAttribute("flashSuccess", "Thêm danh mục thành công!");
                    break;
                }
                case "edit": {
                    int id      = Integer.parseInt(req.getParameter("id"));
                    String name = req.getParameter("name");
                    String type = req.getParameter("type");
                    if (name == null || name.trim().isEmpty()) {
                        req.getSession().setAttribute("flashError", "Tên danh mục không được để trống!");
                        break;
                    }
                    Category cat = new Category(id, name.trim(), type);
                    dao.update(cat);
                    req.getSession().setAttribute("flashSuccess", "Cập nhật danh mục thành công!");
                    break;
                }
                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.delete(id);
                    req.getSession().setAttribute("flashSuccess", "Xóa danh mục thành công!");
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flashError", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/categoryManage");
    }
}