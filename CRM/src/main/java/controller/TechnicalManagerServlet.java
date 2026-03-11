package controller;

import dao.ServiceRequestDAO;
import dao.UserDAO;
import model.ServiceRequest;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class TechnicalManagerServlet extends HttpServlet {

    private final ServiceRequestDAO srDAO  = new ServiceRequestDAO();
    private final UserDAO            userDAO = new UserDAO();
    private static final int PAGE_SIZE = 10;

    // ── GET ──────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"TECHNICAL_MANAGER".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        // ── detail view ──────────────────────────────────────────────────
        if ("detail".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                ServiceRequest sr = srDAO.getById(id);
                if (sr == null) {
                    resp.sendRedirect(req.getContextPath() + "/tmServiceRequests");
                    return;
                }
                // Load list of technicians for assign dropdown
                List<User> technicians = userDAO.findWithFilter(null, "1", "TECHNICIAN", 1, 200);
                req.setAttribute("sr", sr);
                req.setAttribute("technicians", technicians);
                req.getRequestDispatcher("/tmServiceRequestDetail.jsp").forward(req, resp);
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/tmServiceRequests");
            }
            return;
        }

        // ── AJAX: get technicians JSON ───────────────────────────────────
        if ("getTechnicians".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                List<User> technicians = userDAO.findWithFilter(null, "1", "TECHNICIAN", 1, 200);
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < technicians.size(); i++) {
                    User t = technicians.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{")
                      .append("\"id\":").append(t.getId()).append(",")
                      .append("\"name\":").append(jsonStr(t.getFullName())).append(",")
                      .append("\"email\":").append(jsonStr(t.getEmail()))
                      .append("}");
                }
                sb.append("]");
                resp.getWriter().write(sb.toString());
            } catch (Exception e) {
                resp.getWriter().write("[]");
            }
            return;
        }

        // ── list page ────────────────────────────────────────────────────
        try {
            String keyword      = req.getParameter("keyword");
            String status       = req.getParameter("status");
            String priority     = req.getParameter("priority");
            String contractType = req.getParameter("contractType");
            int page = 1;
            try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
            if (page < 1) page = 1;

            List<ServiceRequest> requests = srDAO.getTMFiltered(keyword, status, priority, contractType, page, PAGE_SIZE);
            int total      = srDAO.countTMFiltered(keyword, status, priority, contractType);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            // stats for dashboard cards
            java.util.Map<String, Integer> stats = srDAO.getSRDashboardStats();

            req.setAttribute("requests",      requests);
            req.setAttribute("total",         total);
            req.setAttribute("page",          page);
            req.setAttribute("totalPages",    totalPages);
            req.setAttribute("keyword",       keyword);
            req.setAttribute("filterStatus",  status);
            req.setAttribute("filterPriority",priority);
            req.setAttribute("filterType",    contractType);
            req.setAttribute("stats",         stats);

            req.getRequestDispatcher("/tmServiceRequests.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/tmServiceRequests");
        }
    }

    // ── POST ─────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"TECHNICAL_MANAGER".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        try {
            // ── APPROVE ──────────────────────────────────────────────────
            if ("approve".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean ok = srDAO.approve(id, me.getId());
                if (ok) {
                    req.getSession().setAttribute("flash_success", "Request approved successfully.");
                } else {
                    req.getSession().setAttribute("flash_error", "Cannot approve: request may not be PENDING.");
                }
                resp.sendRedirect(req.getContextPath() + "/tmServiceRequests?action=detail&id=" + id);
                return;
            }

            // ── REJECT ───────────────────────────────────────────────────
            if ("reject".equals(action)) {
                int    id     = Integer.parseInt(req.getParameter("id"));
                String reason = req.getParameter("rejectReason");
                if (reason == null || reason.trim().isEmpty()) {
                    req.getSession().setAttribute("flash_error", "Please provide a rejection reason.");
                    resp.sendRedirect(req.getContextPath() + "/tmServiceRequests?action=detail&id=" + id);
                    return;
                }
                boolean ok = srDAO.reject(id, me.getId(), reason.trim());
                if (ok) {
                    req.getSession().setAttribute("flash_success", "Request rejected.");
                } else {
                    req.getSession().setAttribute("flash_error", "Cannot reject: request may not be PENDING.");
                }
                resp.sendRedirect(req.getContextPath() + "/tmServiceRequests?action=detail&id=" + id);
                return;
            }

            // ── ASSIGN TECHNICIAN ────────────────────────────────────────
            if ("assign".equals(action)) {
                int id           = Integer.parseInt(req.getParameter("id"));
                int technicianId = Integer.parseInt(req.getParameter("technicianId"));
                boolean ok = srDAO.assignTechnician(id, technicianId, me.getId());
                if (ok) {
                    req.getSession().setAttribute("flash_success", "Technician assigned successfully.");
                } else {
                    req.getSession().setAttribute("flash_error", "Cannot assign: request must be APPROVED first.");
                }
                resp.sendRedirect(req.getContextPath() + "/tmServiceRequests?action=detail&id=" + id);
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flash_error", "Error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/tmServiceRequests");
    }

    private String jsonStr(String s) {
        if (s == null) return "null";
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
    }
}