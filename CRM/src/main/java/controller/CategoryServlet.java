package controller;

import dao.CategoryDAO;
import model.Category;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class CategoryServlet extends HttpServlet {
    private final CategoryDAO dao = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Category> categories = dao.findAll();

            // ── JSON response ────────────────────────────────────────
            String accept = req.getHeader("Accept");
            if (accept != null && accept.contains("application/json")) {
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder();
                json.append("{\"total\":").append(categories.size()).append(",\"categories\":[");
                for (int i = 0; i < categories.size(); i++) {
                    Category c = categories.get(i);
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"id\":").append(c.getId()).append(",");
                    json.append("\"name\":\"").append(safe(c.getName())).append("\",");
                    json.append("\"type\":\"").append(safe(c.getType())).append("\"");
                    json.append("}");
                }
                json.append("]}");
                resp.getWriter().print(json.toString());
                return;
            }
            // ── hết JSON ─────────────────────────────────────────────

            req.setAttribute("categories", categories);
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

    private String safe(String s) {
        return s != null ? s.replace("\\", "\\\\").replace("\"", "\\\"") : "";
    }
}