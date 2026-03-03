package controller;

import dao.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

public class CustomerDashboardServlet extends HttpServlet {
    private final ContractDAO       contractDAO = new ContractDAO();
    private final ServiceRequestDAO srDAO       = new ServiceRequestDAO();
    private final InvoiceDAO        invoiceDAO  = new InvoiceDAO();
    private final ChatDAO           chatDAO     = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        int cid = me.getId();
        try {
            List<Contract> contracts = contractDAO.getByCustomerId(cid);
            long active = contracts.stream().filter(Contract::isActive).count();

            Map<String, Integer> srCounts  = srDAO.getCountsByStatus(cid);
            int totalSR     = srCounts.values().stream().mapToInt(i -> i).sum();
            int pendingSR   = srCounts.getOrDefault("PENDING", 0);
            int activeSR    = srCounts.getOrDefault("IN_PROGRESS", 0)
                            + srCounts.getOrDefault("APPROVED", 0);
            int completedSR = srCounts.getOrDefault("COMPLETED", 0);

            Map<String, Object> invSummary = invoiceDAO.getSummary(cid);
            int unreadChat  = chatDAO.countUnread(cid);

            List<ServiceRequest> recentSR = srDAO.getByCustomerId(cid);
            if (recentSR.size() > 5) recentSR = recentSR.subList(0, 5);

            req.setAttribute("activeContracts",  active);
            req.setAttribute("totalContracts",   contracts.size());
            req.setAttribute("totalSR",          totalSR);
            req.setAttribute("pendingSR",        pendingSR);
            req.setAttribute("activeSR",         activeSR);
            req.setAttribute("completedSR",      completedSR);
            req.setAttribute("invSummary",       invSummary);
            req.setAttribute("unreadChat",       unreadChat);
            req.setAttribute("recentSR",         recentSR);
        } catch (Exception e) { e.printStackTrace(); }
        req.getRequestDispatcher("/customerDashboard.jsp").forward(req, resp);
    }
}