package controller;

import dao.TechnicianTaskDAO;
import dao.TechnicianTaskDAO.TaskRow;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class TechnicianTaskServlet extends HttpServlet {

    private final TechnicianTaskDAO taskDAO = new TechnicianTaskDAO();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        User me = getUser(req);
        if (me == null) { resp.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        String action  = req.getParameter("action");
        String taskIdP = req.getParameter("id");

        // Flash messages từ redirect POST
        flashFromSession(req);

        try {
            if ("detail".equals(action) && taskIdP != null) {
                int taskId = Integer.parseInt(taskIdP);
                TaskRow row = taskDAO.findByIdAndTechnician(taskId, me.getId());
                if (row == null) {
                    req.getSession().setAttribute("error", "Không tìm thấy công việc hoặc bạn không có quyền xem.");
                    resp.sendRedirect(req.getContextPath() + "/technicianTasks");
                    return;
                }
                req.setAttribute("row", row);
                req.getRequestDispatcher("/technicianTaskDetail.jsp").forward(req, resp);
                return;
            }

            // ── danh sách tasks ────────────────────────────────────────
            String keyword = req.getParameter("keyword");
            String status  = req.getParameter("status");
            int page = parsePage(req);

            List<TaskRow> tasks = taskDAO.findByTechnician(me.getId(), keyword, status, page, PAGE_SIZE);
            int total      = taskDAO.countByTechnician(me.getId(), keyword, status);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
            if (totalPages < 1) totalPages = 1;

            req.setAttribute("tasks",        tasks);
            req.setAttribute("total",        total);
            req.setAttribute("page",         page);
            req.setAttribute("totalPages",   totalPages);
            req.setAttribute("keyword",      keyword != null ? keyword : "");
            req.setAttribute("filterStatus", status  != null ? status  : "");
            req.getRequestDispatcher("/technicianTasks.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/technicianTasks");
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            try {
                req.setAttribute("tasks", new java.util.ArrayList<>());
                req.setAttribute("total", 0); req.setAttribute("page", 1);
                req.setAttribute("totalPages", 1); req.setAttribute("keyword", ""); req.setAttribute("filterStatus", "");
                req.getRequestDispatcher("/technicianTasks.jsp").forward(req, resp);
            } catch (Exception ex) {
                resp.sendRedirect(req.getContextPath() + "/technicianDashboard");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        User me = getUser(req);
        if (me == null) { resp.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        String action    = req.getParameter("action");
        String taskIdP   = req.getParameter("taskId");
        String newStatus = req.getParameter("newStatus");

        if ("updateStatus".equals(action) && taskIdP != null && newStatus != null && !newStatus.isBlank()) {
            try {
                int taskId = Integer.parseInt(taskIdP);
                boolean ok = taskDAO.updateStatus(taskId, me.getId(), newStatus.trim());
                req.getSession().setAttribute(ok ? "success" : "error",
                    ok ? "Cập nhật trạng thái thành công." : "Không thể cập nhật — task không tồn tại hoặc không thuộc về bạn.");
            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            }
        }

        // Preserve filters khi redirect
        String keyword = req.getParameter("keyword");
        String status  = req.getParameter("filterStatus");
        String page    = req.getParameter("page");
        StringBuilder url = new StringBuilder(req.getContextPath() + "/technicianTasks");
        String sep = "?";
        if (keyword != null && !keyword.isBlank()) { url.append(sep).append("keyword=").append(keyword); sep = "&"; }
        if (status  != null && !status.isBlank())  { url.append(sep).append("status=").append(status);  sep = "&"; }
        if (page    != null && !page.isBlank())    { url.append(sep).append("page=").append(page); }
        resp.sendRedirect(url.toString());
    }

    // ── Helpers ──────────────────────────────────────────────────────────
    private User getUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return null;
        User u = (User) s.getAttribute("user");
        return (u != null && "TECHNICIAN".equals(u.getRoleName())) ? u : null;
    }

    private int parsePage(HttpServletRequest req) {
        try { int p = Integer.parseInt(req.getParameter("page")); return Math.max(p, 1); }
        catch (Exception e) { return 1; }
    }

    private void flashFromSession(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return;
        for (String key : new String[]{"success", "error", "info"}) {
            Object v = s.getAttribute(key);
            if (v != null) { req.setAttribute(key, v); s.removeAttribute(key); }
        }
    }
}
