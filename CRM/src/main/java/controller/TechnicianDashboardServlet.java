package controller;

import dao.TechnicianTaskDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Map;

public class TechnicianDashboardServlet extends HttpServlet {

    private final TechnicianTaskDAO taskDAO = new TechnicianTaskDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        User me = (User) req.getSession(false).getAttribute("user");
        if (me == null || !"TECHNICIAN".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        try {
            Map<String, Integer> stats = taskDAO.getStatsForTechnician(me.getId());
            req.setAttribute("stats", stats);
            req.getRequestDispatcher("/technicianDashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }
}
