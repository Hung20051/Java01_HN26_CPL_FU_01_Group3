package controller;

import dao.ServiceRequestDAO;
import dao.TechnicianWorkloadDAO;
import dao.UserDAO;
import dao.WorkAssignmentDAO;
import dao.WorkTaskDAO;
import model.ServiceRequest;
import model.TechnicianWorkload;
import model.User;
import model.WorkAssignment;
import model.WorkTask;
import util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class TechnicalManagerServlet extends HttpServlet {

    private final ServiceRequestDAO     srDAO   = new ServiceRequestDAO();
    private final UserDAO               userDAO = new UserDAO();
    private final WorkTaskDAO           wtDAO   = new WorkTaskDAO();
    private final WorkAssignmentDAO     waDAO   = new WorkAssignmentDAO();
    private final TechnicianWorkloadDAO twDAO   = new TechnicianWorkloadDAO();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"TECHNICAL_MANAGER".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        // ── Detail view ──────────────────────────────────────────────────
        if ("detail".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                ServiceRequest sr = srDAO.getById(id);
                if (sr == null) {
                    resp.sendRedirect(req.getContextPath() + "/tmServiceRequests");
                    return;
                }
                List<User> technicians         = userDAO.findWithFilter(null, "1", "TECHNICIAN", 1, 200);
                List<TechnicianWorkload> workloads = twDAO.findAllTechnicians();
                List<WorkTask> assignedTasks   = wtDAO.findByRequestId(id);

                req.setAttribute("sr",            sr);
                req.setAttribute("technicians",   technicians);
                req.setAttribute("workloads",     workloads);
                req.setAttribute("assignedTasks", assignedTasks);
                req.getRequestDispatcher("/tmServiceRequestDetail.jsp").forward(req, resp);
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/tmServiceRequests");
            }
            return;
        }

        // ── List view (default) ──────────────────────────────────────────
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
            Map<String, Integer> stats = srDAO.getSRDashboardStats();

            req.setAttribute("requests",       requests);
            req.setAttribute("total",          total);
            req.setAttribute("page",           page);
            req.setAttribute("totalPages",     totalPages);
            req.setAttribute("keyword",        keyword);
            req.setAttribute("filterStatus",   status);
            req.setAttribute("filterPriority", priority);
            req.setAttribute("filterType",     contractType);
            req.setAttribute("stats",          stats);
            req.getRequestDispatcher("/tmServiceRequests.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/tmServiceRequests");
        }
    }

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
        String ctx    = req.getContextPath();

        try {
            // ── APPROVE ──────────────────────────────────────────────────
            if ("approve".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean ok = srDAO.approve(id, me.getId());

                if (ok) {
                    // Lấy thông tin SR + customer để gửi email
                    ServiceRequest sr = srDAO.getById(id);
                    User customer     = userDAO.findById(sr.getCustomerId());
                    if (customer != null && customer.getEmail() != null) {
                        sendMailAsync(() -> EmailUtil.sendSRApproved(
                            customer.getEmail(),
                            customer.getFullName(),
                            sr.getRequestCode(),
                            sr.getTitle(),
                            sr.getContractType(),
                            me.getFullName()
                        ));
                    }
                    req.getSession().setAttribute("flash_success", "Request approved successfully.");
                } else {
                    req.getSession().setAttribute("flash_error", "Cannot approve: request may not be PENDING.");
                }

                resp.sendRedirect(ctx + "/tmServiceRequests?action=detail&id=" + id);
                return;
            }

            // ── REJECT ───────────────────────────────────────────────────
            if ("reject".equals(action)) {
                int    id     = Integer.parseInt(req.getParameter("id"));
                String reason = req.getParameter("rejectReason");
                if (reason == null || reason.trim().isEmpty()) {
                    req.getSession().setAttribute("flash_error", "Please provide a rejection reason.");
                    resp.sendRedirect(ctx + "/tmServiceRequests?action=detail&id=" + id);
                    return;
                }
                boolean ok = srDAO.reject(id, me.getId(), reason.trim());

                if (ok) {
                    ServiceRequest sr = srDAO.getById(id);
                    User customer     = userDAO.findById(sr.getCustomerId());
                    if (customer != null && customer.getEmail() != null) {
                        final String finalReason = reason.trim();
                        sendMailAsync(() -> EmailUtil.sendSRRejected(
                            customer.getEmail(),
                            customer.getFullName(),
                            sr.getRequestCode(),
                            sr.getTitle(),
                            finalReason,
                            me.getFullName()
                        ));
                    }
                    req.getSession().setAttribute("flash_success", "Request rejected.");
                } else {
                    req.getSession().setAttribute("flash_error", "Cannot reject: request may not be PENDING.");
                }

                resp.sendRedirect(ctx + "/tmServiceRequests?action=detail&id=" + id);
                return;
            }

            // ── ASSIGN TECHNICIAN ─────────────────────────────────────────
            if ("assign".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));

                String[] techIds = req.getParameterValues("technicianIds");
                if (techIds == null || techIds.length == 0) {
                    String single = req.getParameter("technicianId");
                    if (single != null && !single.trim().isEmpty()) {
                        techIds = new String[]{single.trim()};
                    }
                }

                if (techIds == null || techIds.length == 0) {
                    req.getSession().setAttribute("flash_error", "Please select at least one technician.");
                    resp.sendRedirect(ctx + "/tmServiceRequests?action=detail&id=" + id);
                    return;
                }

                String durationStr = req.getParameter("estimatedDuration");
                String reqSkills   = req.getParameter("requiredSkills");
                String priority    = req.getParameter("priority");
                if (priority == null || priority.isEmpty()) priority = "MEDIUM";

                int    successCount       = 0;
                int    firstSuccessTechId = -1;
                StringBuilder errors      = new StringBuilder();

                for (String techIdStr : techIds) {
                    int technicianId;
                    try { technicianId = Integer.parseInt(techIdStr.trim()); }
                    catch (NumberFormatException e) { continue; }

                    if (wtDAO.hasActiveTaskForTechnician(id, technicianId)) {
                        errors.append("Technician #").append(technicianId)
                              .append(" already has an active task for this request. ");
                        continue;
                    }

                    twDAO.ensureExists(technicianId);
                    TechnicianWorkload wl = twDAO.findByTechnicianId(technicianId);
                    int points = calcPoints(priority);
                    if (wl != null && wl.getCurrentActiveTasks() + points > wl.getMaxConcurrentTasks()) {
                        errors.append("Technician ")
                              .append(wl.getTechnicianName() != null ? wl.getTechnicianName() : "#" + technicianId)
                              .append(" is overloaded (")
                              .append(wl.getCurrentActiveTasks()).append("/")
                              .append(wl.getMaxConcurrentTasks()).append(" tasks). ");
                        continue;
                    }

                    WorkTask task = new WorkTask();
                    task.setRequestId(id);
                    task.setTechnicianId(technicianId);
                    task.setTaskType("Request");
                    task.setTaskDetails("Assigned to service request #" + id);
                    task.setStatus("Assigned");
                    int taskId = wtDAO.create(task);

                    if (taskId <= 0) {
                        errors.append("Failed to create task for technician #").append(technicianId).append(". ");
                        continue;
                    }

                    WorkAssignment wa = new WorkAssignment();
                    wa.setTaskId(taskId);
                    wa.setAssignedBy(me.getId());
                    wa.setAssignedTo(technicianId);
                    if (durationStr != null && !durationStr.trim().isEmpty()) {
                        try { wa.setEstimatedDuration(new BigDecimal(durationStr.trim())); }
                        catch (NumberFormatException ignored) {}
                    }
                    wa.setRequiredSkills(reqSkills);
                    wa.setPriority(priority);
                    waDAO.create(wa);

                    twDAO.increment(technicianId, points);

                    if (firstSuccessTechId < 0) firstSuccessTechId = technicianId;
                    successCount++;
                }

                if (successCount > 0) {
                    srDAO.assignTechnician(id, firstSuccessTechId, me.getId());

                    // Gửi email IN_PROGRESS cho customer
                    final int finalSuccessCount = successCount;
                    ServiceRequest sr = srDAO.getById(id);
                    User customer     = userDAO.findById(sr.getCustomerId());
                    if (customer != null && customer.getEmail() != null) {
                        sendMailAsync(() -> EmailUtil.sendSRInProgress(
                            customer.getEmail(),
                            customer.getFullName(),
                            sr.getRequestCode(),
                            sr.getTitle(),
                            finalSuccessCount,
                            me.getFullName()
                        ));
                    }

                    req.getSession().setAttribute("flash_success",
                        successCount + " technician(s) assigned successfully.");
                }
                if (errors.length() > 0) {
                    req.getSession().setAttribute("flash_error", errors.toString().trim());
                }

                resp.sendRedirect(ctx + "/tmServiceRequests?action=detail&id=" + id);
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flash_error", "Error: " + e.getMessage());
        }

        resp.sendRedirect(ctx + "/tmServiceRequests");
    }

    // ── Helper: chạy email trên thread riêng để không block response ──────────
    private void sendMailAsync(MailTask task) {
        new Thread(() -> {
            try {
                task.run();
            } catch (Exception e) {
                System.err.println("[EmailUtil] Failed to send email: " + e.getMessage());
            }
        }, "mail-sender").start();
    }

    @FunctionalInterface
    interface MailTask {
        void run() throws Exception;
    }

    private int calcPoints(String priority) {
        if (priority == null) return 1;
        return switch (priority.toUpperCase()) {
            case "URGENT" -> 3;
            case "HIGH"   -> 2;
            default       -> 1;
        };
    }
}