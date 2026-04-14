package controller;

import dao.RoleDAO;
import model.Role;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class RoleServlet extends HttpServlet {

    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "edit":
                    showEdit(req, resp);
                    break;
                case "delete":
                    handleDelete(req, resp);
                    break;  // đổi ở đây
                default:
                    showList(req, resp);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/role/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            String name = req.getParameter("name");
            Role role = new Role(id, name);
            roleDAO.update(role);
            resp.sendRedirect(req.getContextPath() + "/role/list?success=updated");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/role/list");
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        List<Role> roles = roleDAO.findAll();
        req.setAttribute("roles", roles);
        req.getRequestDispatcher("/admin-roles.jsp").forward(req, resp);
    }

    private void showEdit(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        Role role = roleDAO.findById(id);
        req.setAttribute("role", role);
        req.getRequestDispatcher("/role-edit.jsp").forward(req, resp);
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            int id = Integer.parseInt(idStr);
            roleDAO.deleteAndReassign(id, 2);
        }
        resp.sendRedirect(req.getContextPath() + "/role/list?success=deleted");
    }
}
