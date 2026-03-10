package controller;

import dao.UserDAO;
import model.User;
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class SupportCustomerServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        // AJAX: get single customer for edit modal
        if ("get".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                User u = userDAO.findById(id);
                if (u != null && "CUSTOMER".equals(u.getRoleName())) {
                    resp.getWriter().write(
                            "{\"id\":" + u.getId()
                            + ",\"fullName\":" + jsonStr(u.getFullName())
                            + ",\"email\":" + jsonStr(u.getEmail())
                            + ",\"phone\":" + jsonStr(u.getPhone())
                            + ",\"active\":" + u.isActive()
                            + "}"
                    );
                } else {
                    resp.getWriter().write("{\"error\":\"not found\"}");
                }
            } catch (Exception e) {
                resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            }
            return;
        }

        // Normal page load
        try {
            String keyword = req.getParameter("keyword");
            String status = req.getParameter("status");
            int page = 1;
            try {
                page = Integer.parseInt(req.getParameter("page"));
            } catch (Exception ignored) {
            }
            if (page < 1) {
                page = 1;
            }

            List<User> customers = userDAO.findWithFilter(keyword, status, "CUSTOMER", page, PAGE_SIZE);
            int total = userDAO.countWithFilter(keyword, status, "CUSTOMER");
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            req.setAttribute("customers", customers);
            req.setAttribute("total", total);
            req.setAttribute("page", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("keyword", keyword);
            req.setAttribute("status", status);

            req.getRequestDispatcher("/supportCustomers.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/supportCustomers");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        try {
            if ("create".equals(action)) {
                String fullName = req.getParameter("fullName");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");
                String username = req.getParameter("username");
                String password = req.getParameter("password");

                // Validate
                if (userDAO.existsUsername(username)) {
                    req.getSession().setAttribute("flash_error", "Username already exists.");
                    resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                    return;
                }
                if (userDAO.existsEmail(email)) {
                    req.getSession().setAttribute("flash_error", "Email already exists.");
                    resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                    return;
                }

                User u = new User();
                u.setFullName(fullName);
                u.setEmail(email);
                u.setPhone(phone);
                u.setUsername(username);
                u.setPassword(PasswordUtil.hashPassword(password));
                u.setAuthProvider("LOCAL");
                u.setRoleId(2); // CUSTOMER
                u.setActive(true);
                userDAO.insert(u);
                req.getSession().setAttribute("flash_success", "Customer created successfully.");

            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String fullName = req.getParameter("fullName");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");

                User u = userDAO.findById(id);
                if (u != null && "CUSTOMER".equals(u.getRoleName())) {
                    u.setFullName(fullName);
                    u.setEmail(email);
                    u.setPhone(phone);
                    userDAO.update(u);
                    req.getSession().setAttribute("flash_success", "Customer updated successfully.");
                }

            } else if ("toggle".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                User u = userDAO.findById(id);
                if (u != null && "CUSTOMER".equals(u.getRoleName())) {
                    u.setActive(!u.isActive());
                    userDAO.update(u);
                    req.getSession().setAttribute("flash_success",
                            u.isActive() ? "Customer activated." : "Customer deactivated.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flash_error", "An error occurred: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
    }

    private String jsonStr(String s) {
        if (s == null) {
            return "null";
        }
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
    }
}
