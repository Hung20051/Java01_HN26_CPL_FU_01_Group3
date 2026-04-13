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
import java.io.PrintWriter;
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

    // =========================================================================
    //  GET
    // =========================================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"TECHNICAL_MANAGER".equals(me.getRoleName())) {
            if (isJson(req)) { sendError(resp, 401, "Unauthorized"); return; }
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        // ── Detail ───────────────────────────────────────────────────────
        if ("detail".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                ServiceRequest sr = srDAO.getById(id);
                if (sr == null) {
                    if (isJson(req)) { sendError(resp, 404, "Service request not found"); return; }
                    resp.sendRedirect(req.getContextPath() + "/tmServiceRequests");
                    return;
                }

                List<User>               technicians    = userDAO.findWithFilter(null, "1", "TECHNICIAN", 1, 200);
                List<TechnicianWorkload> workloads      = twDAO.findAllTechnicians();
                List<WorkTask>           assignedTasks  = wtDAO.findByRequestId(id);

                if (isJson(req)) {
                    StringBuilder json = new StringBuilder();
                    json.append("{\"status\":\"success\",");
                    json.append("\"sr\":").append(srToJson(sr)).append(",");

                    // technicians
                    json.append("\"technicians\":[");
                    for (int i = 0; i < technicians.size(); i++) {
                        if (i > 0) json.append(",");
                        User t = technicians.get(i);
                        json.append("{")
                            .append("\"id\":").append(t.getId()).append(",")
                            .append("\"fullName\":").append(jsonStr(t.getFullName())).append(",")
                            .append("\"email\":").append(jsonStr(t.getEmail()))
                            .append("}");
                    }
                    json.append("],");

                    // workloads
                    json.append("\"workloads\":[");
                    for (int i = 0; i < workloads.size(); i++) {
                        if (i > 0) json.append(",");
                        TechnicianWorkload w = workloads.get(i);
                        json.append("{")
                            .append("\"technicianId\":").append(w.getTechnicianId()).append(",")
                            .append("\"technicianName\":").append(jsonStr(w.getTechnicianName())).append(",")
                            .append("\"currentActiveTasks\":").append(w.getCurrentActiveTasks()).append(",")
                            .append("\"maxConcurrentTasks\":").append(w.getMaxConcurrentTasks()).append(",")
                            .append("\"loadPercent\":").append(w.getLoadPercent()).append(",")
                            .append("\"available\":").append(w.isAvailable())
                            .append("}");
                    }
                    json.append("],");

                    // assignedTasks
                    json.append("\"assignedTasks\":[");
                    for (int i = 0; i < assignedTasks.size(); i++) {
                        if (i > 0) json.append(",");
                        WorkTask t = assignedTasks.get(i);
                        json.append("{")
                            .append("\"id\":").append(t.getId()).append(",")
                            .append("\"technicianId\":").append(t.getTechnicianId()).append(",")
                            .append("\"technicianName\":").append(jsonStr(t.getTechnicianName())).append(",")
                            .append("\"taskType\":").append(jsonStr(t.getTaskType())).append(",")
                            .append("\"status\":").append(jsonStr(t.getStatus())).append(",")
                            .append("\"createdAt\":").append(jsonStr(t.getCreatedAt() != null ? t.getCreatedAt().toString() : ""))
                            .append("}");
                    }
                    json.append("]}");
                    sendJson(resp, json.toString());
                    return;
                }

                req.setAttribute("sr",            sr);
                req.setAttribute("technicians",   technicians);
                req.setAttribute("workloads",     workloads);
                req.setAttribute("assignedTasks", assignedTasks);
                req.getRequestDispatcher("/tmServiceRequestDetail.jsp").forward(req, resp);
            } catch (Exception e) {
                e.printStackTrace();
                if (isJson(req)) { sendError(resp, 500, e.getMessage()); return; }
                resp.sendRedirect(req.getContextPath() + "/tmServiceRequests");
            }
            return;
        }

        // ── List ─────────────────────────────────────────────────────────
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
            if (totalPages < 1) totalPages = 1;
            Map<String, Integer> stats = srDAO.getSRDashboardStats();

            if (isJson(req)) {
                StringBuilder json = new StringBuilder();
                json.append("{\"status\":\"success\",");
                json.append("\"page\":").append(page).append(",");
                json.append("\"totalPages\":").append(totalPages).append(",");
                json.append("\"total\":").append(total).append(",");
                json.append("\"stats\":{");
                if (stats != null) {
                    boolean first = true;
                    for (Map.Entry<String, Integer> e : stats.entrySet()) {
                        if (!first) json.append(",");
                        json.append(jsonStr(e.getKey())).append(":").append(e.getValue());
                        first = false;
                    }
                }
                json.append("},\"requests\":[");
                for (int i = 0; i < requests.size(); i++) {
                    if (i > 0) json.append(",");
                    json.append(srToJson(requests.get(i)));
                }
                json.append("]}");
                sendJson(resp, json.toString());
                return;
            }

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
            if (isJson(req)) { sendError(resp, 500, e.getMessage()); return; }
            resp.sendRedirect(req.getContextPath() + "/tmServiceRequests");
        }
    }

    // =========================================================================
    //  POST
    // =========================================================================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"TECHNICAL_MANAGER".equals(me.getRoleName())) {
            if (isJson(req)) { sendError(resp, 401, "Unauthorized"); return; }
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        boolean wantJson = isJson(req);
        String action    = req.getParameter("action");
        String ctx       = req.getContextPath();

        try {
            // ── APPROVE ──────────────────────────────────────────────────
            if ("approve".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean ok = srDAO.approve(id, me.getId());

                if (ok) {
                    ServiceRequest sr = srDAO.getById(id);
                    User customer     = userDAO.findById(sr.getCustomerId());
                    if (customer != null && customer.getEmail() != null) {
                        sendMailAsync(() -> EmailUtil.sendSRApproved(
                            customer.getEmail(), customer.getFullName(),
                            sr.getRequestCode(), sr.getTitle(),
                            sr.getContractType(), me.getFullName()
                        ));
                    }
                    if (wantJson) {
                        sendJson(resp, "{\"status\":\"success\",\"message\":\"Request approved successfully\",\"id\":" + id + "}");
                        return;
                    }
                    req.getSession().setAttribute("flash_success", "Request approved successfully.");
                } else {
                    if (wantJson) { sendError(resp, 400, "Cannot approve: request may not be PENDING"); return; }
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
                    if (wantJson) { sendError(resp, 400, "Please provide a rejection reason"); return; }
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
                            customer.getEmail(), customer.getFullName(),
                            sr.getRequestCode(), sr.getTitle(),
                            finalReason, me.getFullName()
                        ));
                    }
                    if (wantJson) {
                        sendJson(resp, "{\"status\":\"success\",\"message\":\"Request rejected\",\"id\":" + id + "}");
                        return;
                    }
                    req.getSession().setAttribute("flash_success", "Request rejected.");
                } else {
                    if (wantJson) { sendError(resp, 400, "Cannot reject: request may not be PENDING"); return; }
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
                    if (wantJson) { sendError(resp, 400, "Please select at least one technician"); return; }
                    req.getSession().setAttribute("flash_error", "Please select at least one technician.");
                    resp.sendRedirect(ctx + "/tmServiceRequests?action=detail&id=" + id);
                    return;
                }

                String durationStr = req.getParameter("estimatedDuration");
                String reqSkills   = req.getParameter("requiredSkills");
                String priority    = req.getParameter("priority");
                if (priority == null || priority.isEmpty()) priority = "MEDIUM";

                int           successCount       = 0;
                int           firstSuccessTechId = -1;
                StringBuilder errors             = new StringBuilder();

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
                    final int finalSuccessCount = successCount;
                    ServiceRequest sr = srDAO.getById(id);
                    User customer     = userDAO.findById(sr.getCustomerId());
                    if (customer != null && customer.getEmail() != null) {
                        sendMailAsync(() -> EmailUtil.sendSRInProgress(
                            customer.getEmail(), customer.getFullName(),
                            sr.getRequestCode(), sr.getTitle(),
                            finalSuccessCount, me.getFullName()
                        ));
                    }
                }

                if (wantJson) {
                    if (successCount > 0) {
                        String msg = successCount + " technician(s) assigned successfully."
                                   + (errors.length() > 0 ? " Warnings: " + errors.toString().trim() : "");
                        sendJson(resp, "{\"status\":\"success\",\"message\":\"" + safe(msg) + "\","
                                + "\"assigned\":" + successCount + ",\"requestId\":" + id + "}");
                    } else {
                        sendError(resp, 400, errors.toString().trim());
                    }
                    return;
                }

                if (successCount > 0)
                    req.getSession().setAttribute("flash_success", successCount + " technician(s) assigned successfully.");
                if (errors.length() > 0)
                    req.getSession().setAttribute("flash_error", errors.toString().trim());

                resp.sendRedirect(ctx + "/tmServiceRequests?action=detail&id=" + id);
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (wantJson) { sendError(resp, 500, "Error: " + safe(e.getMessage())); return; }
            req.getSession().setAttribute("flash_error", "Error: " + e.getMessage());
        }

        resp.sendRedirect(ctx + "/tmServiceRequests");
    }

    // =========================================================================
    //  Helpers
    // =========================================================================

    private String srToJson(ServiceRequest sr) {
        StringBuilder j = new StringBuilder();
        j.append("{");
        j.append("\"id\":").append(sr.getId()).append(",");
        j.append("\"requestCode\":").append(jsonStr(sr.getRequestCode())).append(",");
        j.append("\"customerId\":").append(sr.getCustomerId()).append(",");
        j.append("\"customerName\":").append(jsonStr(sr.getCustomerName())).append(",");
        j.append("\"contractId\":").append(sr.getContractId()).append(",");
        j.append("\"contractCode\":").append(jsonStr(sr.getContractCode())).append(",");
        j.append("\"contractType\":").append(jsonStr(sr.getContractType())).append(",");
        j.append("\"title\":").append(jsonStr(sr.getTitle())).append(",");
        j.append("\"priority\":").append(jsonStr(sr.getPriority())).append(",");
        j.append("\"priorityLabel\":").append(jsonStr(sr.getPriorityLabel())).append(",");
        j.append("\"status\":").append(jsonStr(sr.getStatus())).append(",");
        j.append("\"statusLabel\":").append(jsonStr(sr.getStatusLabel())).append(",");
        j.append("\"assignedTo\":").append(sr.getAssignedTo() != null ? sr.getAssignedTo() : "null").append(",");
        j.append("\"assignedToName\":").append(jsonStr(sr.getAssignedToName())).append(",");
        j.append("\"createdAt\":").append(jsonStr(sr.getCreatedAt() != null ? sr.getCreatedAt().toString() : "")).append(",");
        j.append("\"completedAt\":").append(jsonStr(sr.getCompletedAt() != null ? sr.getCompletedAt().toString() : ""));
        j.append("}");
        return j.toString();
    }

    private boolean isJson(HttpServletRequest req) {
        String ct     = req.getContentType();
        String accept = req.getHeader("Accept");
        return (ct     != null && ct.contains("application/json"))
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
        if (s == null) return "null";
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
    }

    private String safe(String s) {
        return s != null ? s.replace("\\", "\\\\").replace("\"", "\\\"") : "";
    }

    private void sendMailAsync(MailTask task) {
        new Thread(() -> {
            try { task.run(); }
            catch (Exception e) { System.err.println("[EmailUtil] Failed to send email: " + e.getMessage()); }
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