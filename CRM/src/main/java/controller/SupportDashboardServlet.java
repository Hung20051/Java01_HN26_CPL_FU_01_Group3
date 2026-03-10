package controller;

import dao.ContractDAO;
import dao.ServiceRequestDAO;
import dao.UserDAO;
import model.Contract;
import model.ServiceRequest;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

public class SupportDashboardServlet extends HttpServlet {

    private final ContractDAO contractDAO = new ContractDAO();
    private final ServiceRequestDAO srDAO = new ServiceRequestDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            Map<String, Integer> contractStats = contractDAO.getDashboardStats();
            Map<String, Integer> srStats = srDAO.getSRDashboardStats();
            int totalCustomers = userDAO.countWithFilter(null, "1", "CUSTOMER");
            List<Contract> recentContracts = contractDAO.getAllFiltered(null, null, "ACTIVE", 1, 5);
            List<ServiceRequest> pendingSRs = srDAO.getAllFiltered(null, "PENDING", null, null, 1, 5);
            req.setAttribute("contractStats", contractStats);
            req.setAttribute("srStats", srStats);
            req.setAttribute("totalCustomers", totalCustomers);
            req.setAttribute("recentContracts", recentContracts);
            req.setAttribute("pendingSRs", pendingSRs);
            req.getRequestDispatcher("/supportDashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            // Hiển thị lỗi thay vì redirect về chính nó
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            req.getRequestDispatcher("/supportDashboard.jsp").forward(req, resp);
        }
    }
}
