package controller;

import dao.RoleDAO;
import dao.UserDAO;
import model.Role;
import model.User;
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class UserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        System.out.println(">>> doGet called, action=" + action + ", URI=" + req.getRequestURI());
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "edit":
                    showEdit(req, resp);
                    break;
                case "create":
                    showCreate(req, resp);
                    break;
                case "delete":
                    handleDelete(req, resp);
                    break;
                default:
                    showList(req, resp);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/user/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) {
            action = "";
        }

        try {
            switch (action) {
                case "create":
                    doCreate(req, resp);
                    break;
                case "update":
                    doUpdate(req, resp);
                    break;
                case "changePassword":
                    doChangePassword(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/user/list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/user/list");
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String keyword = req.getParameter("keyword");
        String status = req.getParameter("status");
        String role = req.getParameter("role");
        String pageStr = req.getParameter("page");
        int page = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;

        int total = userDAO.countWithFilter(keyword, status, role);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        System.out.println(">>> DEBUG: total=" + total + " totalPages=" + totalPages + " PAGE_SIZE=" + PAGE_SIZE);
        List<User> users = userDAO.findWithFilter(keyword, status, role, page, PAGE_SIZE);
        List<Role> roles = roleDAO.findAll();

        req.setAttribute("users", users);
        req.setAttribute("roles", roles);
        req.setAttribute("total", total);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("keyword", keyword != null ? keyword : "");
        req.setAttribute("status", status != null ? status : "");
        req.setAttribute("role", role != null ? role : "");
        req.getRequestDispatcher("/admin-users.jsp").forward(req, resp);
    }

    private void showEdit(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        User user = userDAO.findById(id);
        List<Role> roles = roleDAO.findAll();
        req.setAttribute("editUser", user);
        req.setAttribute("roles", roles);
        req.getRequestDispatcher("/user-edit.jsp").forward(req, resp);
    }

    private void showCreate(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        List<Role> roles = roleDAO.findAll();
        req.setAttribute("roles", roles);
        req.getRequestDispatcher("/user-create.jsp").forward(req, resp);
    }

    private void doCreate(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String username = req.getParameter("username");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirmPassword");
        int roleId = Integer.parseInt(req.getParameter("roleId"));
        boolean active = "1".equals(req.getParameter("active"));

        // Validate
        if (!password.equals(confirm)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            showCreate(req, resp);
            return;
        }
        if (userDAO.existsUsername(username)) {
            req.setAttribute("error", "Username đã tồn tại!");
            showCreate(req, resp);
            return;
        }
        if (email != null && !email.isEmpty() && userDAO.existsEmail(email)) {
            req.setAttribute("error", "Email đã tồn tại!");
            showCreate(req, resp);
            return;
        }

        User u = new User();
        u.setUsername(username);
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setPassword(PasswordUtil.hashPassword(password));
        u.setRoleId(roleId);
        u.setActive(active);
        u.setAuthProvider("LOCAL");
        userDAO.insert(u);

        resp.sendRedirect(req.getContextPath() + "/user/list?success=created");
    }

    private void doUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        int roleId = Integer.parseInt(req.getParameter("roleId"));
        boolean active = "1".equals(req.getParameter("active"));

        User u = userDAO.findById(id);
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setRoleId(roleId);
        u.setActive(active);
        userDAO.update(u);

        resp.sendRedirect(req.getContextPath() + "/user/edit?action=edit&id=" + id + "&success=updated");
    }

    private void doChangePassword(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String newPass = req.getParameter("newPassword");
        String confirm = req.getParameter("confirmPassword");

        if (!newPass.equals(confirm)) {
            resp.sendRedirect(req.getContextPath() + "/user/edit?action=edit&id=" + id + "&error=password_mismatch");
            return;
        }
        userDAO.updatePassword(id, PasswordUtil.hashPassword(newPass));
        resp.sendRedirect(req.getContextPath() + "/user/edit?action=edit&id=" + id + "&success=password_changed");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            int id = Integer.parseInt(idStr);
            userDAO.delete(id);
        }
        resp.sendRedirect(req.getContextPath() + "/user/list?success=deleted");
    }
}
