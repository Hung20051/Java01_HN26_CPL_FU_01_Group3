package controller;

import dao.TechnicianTaskDAO;
import dao.TechnicianTaskDAO.TaskRow;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class TechnicianWorkHistoryServlet extends HttpServlet {

    private final TechnicianTaskDAO taskDAO = new TechnicianTaskDAO();
    private static final int PAGE_SIZE = 15;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User me = (session != null) ? (User) session.getAttribute("user") : null;
        if (me == null || !"TECHNICIAN".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int page = 1;
        try { page = Math.max(1, Integer.parseInt(req.getParameter("page"))); }
        catch (Exception ignored) {}

        try {
            List<TaskRow> history = taskDAO.getWorkHistory(me.getId(), page, PAGE_SIZE);
            int total      = taskDAO.countWorkHistory(me.getId());
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            req.setAttribute("history",    history);
            req.setAttribute("total",      total);
            req.setAttribute("page",       page);
            req.setAttribute("totalPages", totalPages);
            req.getRequestDispatcher("/technicianWorkHistory.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/technicianDashboard");
        }
    }
}
