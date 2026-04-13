package controller;

import dao.RoleDAO;
import dao.UserDAO;
import model.Role;
import model.User;
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

public class UserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private static final int PAGE_SIZE = 10;

    // ─────────────────────────────────────────────────
    //  GET
    // ─────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "edit"   -> showEdit(req, resp);
                case "create" -> showCreate(req, resp);
                case "delete" -> handleDelete(req, resp);
                default       -> showList(req, resp);
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/user/list");
        }
    }

    // ─────────────────────────────────────────────────
    //  POST
    // ─────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "create"             -> doCreate(req, resp);
                case "update"             -> doUpdate(req, resp);
                case "updatePersonalInfo" -> doUpdatePersonalInfo(req, resp);
                case "changePassword"     -> doChangePassword(req, resp);
                default -> resp.sendRedirect(req.getContextPath() + "/user/list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/user/list");
        }
    }

    // ─────────────────────────────────────────────────
    //  SHOW pages
    // ─────────────────────────────────────────────────

    private void showList(HttpServletRequest req, HttpServletResponse resp)
        throws Exception {
    String keyword = req.getParameter("keyword");
    String status  = req.getParameter("status");
    String role    = req.getParameter("role");
    String pageStr = req.getParameter("page");
    int page = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;

    int total      = userDAO.countWithFilter(keyword, status, role);
    int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
    List<User> users = userDAO.findWithFilter(keyword, status, role, page, PAGE_SIZE);
    List<Role> roles = roleDAO.findAll();

    // ── CHECK JSON ──────────────────────────────────
    String accept = req.getHeader("Accept");
    if (accept != null && accept.contains("application/json")) {
        resp.setContentType("application/json;charset=UTF-8");

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"page\":").append(page).append(",");
        json.append("\"totalPages\":").append(totalPages).append(",");
        json.append("\"total\":").append(total).append(",");
        json.append("\"users\":[");
        if (users != null) {
            for (int i = 0; i < users.size(); i++) {
                User u = users.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(u.getId()).append(",");
                json.append("\"username\":\"").append(safe(u.getUsername())).append("\",");
                json.append("\"fullName\":\"").append(safe(u.getFullName())).append("\",");
                json.append("\"email\":\"").append(safe(u.getEmail())).append("\",");
                json.append("\"phone\":\"").append(safe(u.getPhone())).append("\",");
                json.append("\"role\":\"").append(safe(u.getRoleName())).append("\",");
                json.append("\"active\":").append(u.isActive());
                json.append("}");
            }
        }
        json.append("]}");

        resp.getWriter().print(json.toString());
        return; // ← quan trọng: không forward JSP nữa
    }
    // ── HẾT CHECK JSON ──────────────────────────────

    // Logic cũ giữ nguyên
    req.setAttribute("users",       users);
    req.setAttribute("roles",       roles);
    req.setAttribute("total",       total);
    req.setAttribute("currentPage", page);
    req.setAttribute("totalPages",  totalPages);
    req.setAttribute("keyword",     keyword != null ? keyword : "");
    req.setAttribute("status",      status  != null ? status  : "");
    req.setAttribute("role",        role    != null ? role    : "");
    req.getRequestDispatcher("/admin-users.jsp").forward(req, resp);
}

// Thêm helper này vào cuối class
private String safe(String s) {
    return s != null ? s.replace("\"", "\\\"") : "";
}

    private void showEdit(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        User user      = userDAO.findById(id);
        List<Role> roles = roleDAO.findAll();
        req.setAttribute("editUser", user);
        req.setAttribute("roles",    roles);
        req.getRequestDispatcher("/user-edit.jsp").forward(req, resp);
    }

    private void showCreate(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        List<Role> roles = roleDAO.findAll();
        req.setAttribute("roles", roles);
        req.getRequestDispatcher("/user-create.jsp").forward(req, resp);
    }

    // ─────────────────────────────────────────────────
    //  ACTION: create user
    // ─────────────────────────────────────────────────

    private void doCreate(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String username = req.getParameter("username");
        String fullName = req.getParameter("fullName");
        String email    = req.getParameter("email");
        String phone    = req.getParameter("phone");
        String password = req.getParameter("password");
        String confirm  = req.getParameter("confirmPassword");
        int    roleId   = Integer.parseInt(req.getParameter("roleId"));
        boolean active  = "1".equals(req.getParameter("active"));

        if (!password.equals(confirm)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            showCreate(req, resp); return;
        }
        if (userDAO.existsUsername(username)) {
            req.setAttribute("error", "Username đã tồn tại!");
            showCreate(req, resp); return;
        }
        if (email != null && !email.isEmpty() && userDAO.existsEmail(email)) {
            req.setAttribute("error", "Email đã tồn tại!");
            showCreate(req, resp); return;
        }

        // Build user object
        User u = new User();
        u.setUsername(username);
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setPassword(PasswordUtil.hashPassword(password));
        u.setRoleId(roleId);
        u.setActive(active);
        u.setAuthProvider("LOCAL");

        // Address (optional)
        u.setAddressStreet(trim(req, "addressStreet"));
        u.setAddressWard(trim(req, "addressWard"));
        u.setAddressDistrict(trim(req, "addressDistrict"));
        u.setAddressCity(trim(req, "addressCity"));

        // Personal info (optional)
        u.setHometown(trim(req, "hometown"));
        u.setGender(trim(req, "gender"));
        u.setNationalId(trim(req, "nationalId"));
        String dobStr = req.getParameter("dateOfBirth");
        if (dobStr != null && !dobStr.isBlank()) {
            try { u.setDateOfBirth(LocalDate.parse(dobStr)); }
            catch (DateTimeParseException ignored) { /* skip invalid date silently on create */ }
        }

        // Emergency contact (optional)
        u.setEmergencyName(trim(req, "emergencyName"));
        u.setEmergencyPhone(trim(req, "emergencyPhone"));
        u.setEmergencyRelation(trim(req, "emergencyRelation"));

        // Professional (optional)
        u.setCompanyName(trim(req, "companyName"));
        u.setBio(trim(req, "bio"));

        // Insert core row, then save personal info
        int newId = userDAO.insert(u);
        if (newId > 0) {
            u.setId(newId);
            userDAO.updatePersonalInfo(u);
        }

        resp.sendRedirect(req.getContextPath() + "/user/list?success=created");
    }

    // ─────────────────────────────────────────────────
    //  ACTION: update account info + role
    // ─────────────────────────────────────────────────

    private void doUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int     id      = Integer.parseInt(req.getParameter("id"));
        String  fullName = req.getParameter("fullName");
        String  email    = req.getParameter("email");
        String  phone    = req.getParameter("phone");
        int     roleId   = Integer.parseInt(req.getParameter("roleId"));
        boolean active   = "1".equals(req.getParameter("active"));

        User u = userDAO.findById(id);
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setRoleId(roleId);
        u.setActive(active);
        userDAO.update(u);

        resp.sendRedirect(req.getContextPath() + "/user/edit?action=edit&id=" + id + "&success=updated");
    }

    // ─────────────────────────────────────────────────
    //  ACTION: update personal info + address (NEW)
    // ─────────────────────────────────────────────────

    private void doUpdatePersonalInfo(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));

        User u = userDAO.findById(id);
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/user/list");
            return;
        }

        // Basic (admin có thể sửa cả fullName + phone từ tab này)
        String fullName = req.getParameter("fullName");
        if (fullName != null && !fullName.isBlank()) u.setFullName(fullName.trim());
        u.setPhone(trim(req, "phone"));

        // Address
        u.setAddressStreet(trim(req, "addressStreet"));
        u.setAddressWard(trim(req, "addressWard"));
        u.setAddressDistrict(trim(req, "addressDistrict"));
        u.setAddressCity(trim(req, "addressCity"));

        // Personal
        u.setHometown(trim(req, "hometown"));
        u.setGender(trim(req, "gender"));
        u.setNationalId(trim(req, "nationalId"));

        String dobStr = req.getParameter("dateOfBirth");
        if (dobStr != null && !dobStr.isBlank()) {
            try {
                u.setDateOfBirth(LocalDate.parse(dobStr));
            } catch (DateTimeParseException e) {
                // invalid date — redirect with error
                resp.sendRedirect(req.getContextPath()
                    + "/user/edit?action=edit&id=" + id + "&error=invalid_date&tab=personal");
                return;
            }
        } else {
            u.setDateOfBirth(null);
        }

        // Emergency contact
        u.setEmergencyName(trim(req, "emergencyName"));
        u.setEmergencyPhone(trim(req, "emergencyPhone"));
        u.setEmergencyRelation(trim(req, "emergencyRelation"));

        // Professional
        u.setCompanyName(trim(req, "companyName"));
        u.setBio(trim(req, "bio"));

        userDAO.updatePersonalInfo(u);

        resp.sendRedirect(req.getContextPath()
            + "/user/edit?action=edit&id=" + id + "&success=personal_updated&tab=personal");
    }

    // ─────────────────────────────────────────────────
    //  ACTION: change password
    // ─────────────────────────────────────────────────

    private void doChangePassword(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int    id      = Integer.parseInt(req.getParameter("id"));
        String newPass = req.getParameter("newPassword");
        String confirm = req.getParameter("confirmPassword");

        if (!newPass.equals(confirm)) {
            resp.sendRedirect(req.getContextPath()
                + "/user/edit?action=edit&id=" + id + "&error=password_mismatch");
            return;
        }
        userDAO.updatePassword(id, PasswordUtil.hashPassword(newPass));
        resp.sendRedirect(req.getContextPath()
            + "/user/edit?action=edit&id=" + id + "&success=password_changed");
    }

    // ─────────────────────────────────────────────────
    //  ACTION: delete user
    // ─────────────────────────────────────────────────

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            userDAO.delete(Integer.parseInt(idStr));
        }
        resp.sendRedirect(req.getContextPath() + "/user/list?success=deleted");
    }

    // ─────────────────────────────────────────────────
    //  HELPER
    // ─────────────────────────────────────────────────

    private String trim(HttpServletRequest req, String param) {
        String v = req.getParameter(param);
        return (v != null && !v.isBlank()) ? v.trim() : null;
    }
}