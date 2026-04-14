package controller;

import dao.UserDAO;
import model.User;
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

public class SupportCustomerServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final int PAGE_SIZE = 10;

    // =========================================================================
    //  GET
    // =========================================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
            if (isJson(req)) {
                sendError(resp, 401, "Unauthorized");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        // ── GET single customer (cho modal edit + Postman) ──────────────────
        if ("get".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                User u = userDAO.findById(id);
                if (u != null && "CUSTOMER".equals(u.getRoleName())) {
                    resp.getWriter().write(
                            "{\"status\":\"success\","
                            + "\"id\":" + u.getId() + ","
                            + "\"fullName\":" + jsonStr(u.getFullName()) + ","
                            + "\"email\":" + jsonStr(u.getEmail()) + ","
                            + "\"phone\":" + jsonStr(u.getPhone()) + ","
                            + "\"username\":" + jsonStr(u.getUsername()) + ","
                            + "\"active\":" + u.isActive()
                            + "}"
                    );
                } else {
                    resp.setStatus(404);
                    resp.getWriter().write("{\"status\":\"error\",\"message\":\"Customer not found\"}");
                }
            } catch (NumberFormatException e) {
                resp.setStatus(400);
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"Invalid id\"}");
            } catch (Exception e) {
                resp.setStatus(500);
                resp.getWriter().write("{\"status\":\"error\",\"message\":\"" + safe(e.getMessage()) + "\"}");
            }
            return;
        }

        // ── LIST customers ──────────────────────────────────────────────────
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
            if (totalPages < 1) {
                totalPages = 1;
            }

            if (isJson(req)) {
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"status\":\"success\",");
                json.append("\"page\":").append(page).append(",");
                json.append("\"totalPages\":").append(totalPages).append(",");
                json.append("\"total\":").append(total).append(",");
                json.append("\"customers\":[");
                for (int i = 0; i < customers.size(); i++) {
                    User u = customers.get(i);
                    if (i > 0) {
                        json.append(",");
                    }
                    json.append("{");
                    json.append("\"id\":").append(u.getId()).append(",");
                    json.append("\"fullName\":").append(jsonStr(u.getFullName())).append(",");
                    json.append("\"email\":").append(jsonStr(u.getEmail())).append(",");
                    json.append("\"phone\":").append(jsonStr(u.getPhone())).append(",");
                    json.append("\"username\":").append(jsonStr(u.getUsername())).append(",");
                    json.append("\"active\":").append(u.isActive());
                    json.append("}");
                }
                json.append("]}");
                sendJson(resp, json.toString());
                return;
            }

            req.setAttribute("customers", customers);
            req.setAttribute("total", total);
            req.setAttribute("page", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("keyword", keyword);
            req.setAttribute("status", status);
            req.getRequestDispatcher("/supportCustomers.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            if (isJson(req)) {
                sendError(resp, 500, e.getMessage());
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/supportCustomers");
        }
    }

    // =========================================================================
    //  POST
    //  Postman: Content-Type: application/json  →  trả JSON
    //  Browser form                             →  redirect như cũ
    //
    //  Endpoints:
    //    POST /supportCustomers?action=create   Body: fullName, email, phone, username, password
    //    POST /supportCustomers?action=edit     Body: id, fullName, email, phone
    //    POST /supportCustomers?action=toggle   Body: id
    // =========================================================================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
            if (isJson(req)) {
                sendError(resp, 401, "Unauthorized");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        boolean wantJson = isJson(req);
        String action = req.getParameter("action");

        // Nếu Postman gửi JSON body thì parse ra, ngược lại dùng getParameter bình thường
        java.util.Map<String, String> body = wantJson ? parseJsonBody(req) : null;

        try {
            switch (action != null ? action : "") {

                // ── CREATE ──────────────────────────────────────────────────
                case "create": {
                    String fullName = param(body, req, "fullName");
                    String email = param(body, req, "email");
                    String phone = param(body, req, "phone");
                    String username = param(body, req, "username");
                    String password = param(body, req, "password");

                    // Validate
                    if (fullName == null || fullName.trim().isEmpty()) {
                        if (wantJson) {
                            sendError(resp, 400, "fullName is required");
                            return;
                        }
                        req.getSession().setAttribute("flash_error", "Full name is required.");
                        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                        return;
                    }
                    if (username == null || username.trim().isEmpty()) {
                        if (wantJson) {
                            sendError(resp, 400, "username is required");
                            return;
                        }
                        req.getSession().setAttribute("flash_error", "Username is required.");
                        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                        return;
                    }
                    if (password == null || password.trim().isEmpty()) {
                        if (wantJson) {
                            sendError(resp, 400, "password is required");
                            return;
                        }
                        req.getSession().setAttribute("flash_error", "Password is required.");
                        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                        return;
                    }
                    if (userDAO.existsUsername(username)) {
                        if (wantJson) {
                            sendError(resp, 409, "Username already exists");
                            return;
                        }
                        req.getSession().setAttribute("flash_error", "Username already exists.");
                        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                        return;
                    }
                    if (email != null && !email.isEmpty() && userDAO.existsEmail(email)) {
                        if (wantJson) {
                            sendError(resp, 409, "Email already exists");
                            return;
                        }
                        req.getSession().setAttribute("flash_error", "Email already exists.");
                        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                        return;
                    }

                    User u = new User();
                    u.setFullName(fullName.trim());
                    u.setEmail(email);
                    u.setPhone(phone);
                    u.setUsername(username.trim());
                    u.setPassword(PasswordUtil.hashPassword(password));
                    u.setAuthProvider("LOCAL");
                    u.setRoleId(2); // CUSTOMER
                    u.setActive(true);
                    userDAO.insert(u);

                    if (wantJson) {
                        sendJson(resp, "{\"status\":\"success\",\"message\":\"Customer created successfully\"}");
                        return;
                    }
                    req.getSession().setAttribute("flash_success", "Customer created successfully.");
                    break;
                }

                // ── EDIT ────────────────────────────────────────────────────
                case "edit": {
                    int id = parseInt(param(body, req, "id"), 0);
                    String fullName = param(body, req, "fullName");
                    String email = param(body, req, "email");
                    String phone = param(body, req, "phone");

                    if (id == 0) {
                        if (wantJson) {
                            sendError(resp, 400, "id is required");
                            return;
                        }
                        req.getSession().setAttribute("flash_error", "Invalid customer id.");
                        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                        return;
                    }

                    User u = userDAO.findById(id);
                    if (u == null || !"CUSTOMER".equals(u.getRoleName())) {
                        if (wantJson) {
                            sendError(resp, 404, "Customer not found");
                            return;
                        }
                        req.getSession().setAttribute("flash_error", "Customer not found.");
                        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                        return;
                    }

                    u.setFullName(fullName != null ? fullName.trim() : u.getFullName());
                    u.setEmail(email != null ? email : u.getEmail());
                    u.setPhone(phone != null ? phone : u.getPhone());
                    userDAO.update(u);

                    if (wantJson) {
                        sendJson(resp, "{\"status\":\"success\",\"message\":\"Customer updated successfully\",\"id\":" + id + "}");
                        return;
                    }
                    req.getSession().setAttribute("flash_success", "Customer updated successfully.");
                    break;
                }

                // ── TOGGLE active ────────────────────────────────────────────
                case "toggle": {
                    int id = parseInt(param(body, req, "id"), 0);

                    if (id == 0) {
                        if (wantJson) {
                            sendError(resp, 400, "id is required");
                            return;
                        }
                        req.getSession().setAttribute("flash_error", "Invalid customer id.");
                        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                        return;
                    }

                    User u = userDAO.findById(id);
                    if (u == null || !"CUSTOMER".equals(u.getRoleName())) {
                        if (wantJson) {
                            sendError(resp, 404, "Customer not found");
                            return;
                        }
                        req.getSession().setAttribute("flash_error", "Customer not found.");
                        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
                        return;
                    }

                    u.setActive(!u.isActive());
                    userDAO.update(u);
                    String msg = u.isActive() ? "Customer activated" : "Customer deactivated";

                    if (wantJson) {
                        sendJson(resp, "{\"status\":\"success\",\"message\":\"" + msg + "\","
                                + "\"id\":" + id + ",\"active\":" + u.isActive() + "}");
                        return;
                    }
                    req.getSession().setAttribute("flash_success", msg + ".");
                    break;
                }

                default:
                    if (wantJson) {
                        sendError(resp, 400, "Unknown action: " + action);
                        return;
                    }
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (wantJson) {
                sendError(resp, 500, "Internal server error: " + safe(e.getMessage()));
                return;
            }
            req.getSession().setAttribute("flash_error", "An error occurred: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/supportCustomers");
    }

    // =========================================================================
    //  HELPERS
    // =========================================================================
    private boolean isJson(HttpServletRequest req) {
        String ct = req.getContentType();
        String accept = req.getHeader("Accept");
        return (ct != null && ct.contains("application/json"))
                || (accept != null && accept.contains("application/json"));
    }

    private void sendJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        out.print(json);
        out.flush();
    }

    private void sendError(HttpServletResponse resp, int code, String message) throws IOException {
        resp.setStatus(code);
        sendJson(resp, "{\"status\":\"error\",\"code\":" + code + ",\"message\":\"" + safe(message) + "\"}");
    }

    private String jsonStr(String s) {
        if (s == null) {
            return "null";
        }
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
    }

    private String safe(String s) {
        return s != null ? s.replace("\\", "\\\\").replace("\"", "\\\"") : "";
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    /**
     * Lấy param: ưu tiên JSON body nếu có, fallback về request parameter
     */
    private String param(java.util.Map<String, String> body, HttpServletRequest req, String key) {
        if (body != null && body.containsKey(key)) {
            return body.get(key);
        }
        return req.getParameter(key);
    }

    /**
     * Parse flat JSON body: {"key":"value", "key2":123} Không hỗ trợ nested
     * object / array.
     */
    private java.util.Map<String, String> parseJsonBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        String line;
        try (var reader = req.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        java.util.Map<String, String> map = new java.util.LinkedHashMap<>();
        String raw = sb.toString().trim();
        if (raw.startsWith("{")) {
            raw = raw.substring(1);
        }
        if (raw.endsWith("}")) {
            raw = raw.substring(0, raw.length() - 1);
        }

        String[] pairs = raw.split(",(?=\\s*\"[^\"]+\"\\s*:)");
        for (String pair : pairs) {
            int colon = pair.indexOf(':');
            if (colon < 0) {
                continue;
            }
            String key = pair.substring(0, colon).trim().replaceAll("\"", "");
            String val = pair.substring(colon + 1).trim().replaceAll("^\"|\"$", "");
            val = val.replace("\\\"", "\"").replace("\\\\", "\\");
            map.put(key, "null".equals(val) ? null : val);
        }
        return map;
    }
}
