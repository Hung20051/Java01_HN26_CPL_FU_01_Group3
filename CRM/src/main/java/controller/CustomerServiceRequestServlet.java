package controller;

import dao.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

public class CustomerServiceRequestServlet extends HttpServlet {

    private final ServiceRequestDAO srDAO = new ServiceRequestDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final CustomerEquipmentDAO ceDAO = new CustomerEquipmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        int cid = me.getId();
        String action = req.getParameter("action");
        String ctx = req.getContextPath();
        boolean wantJson = isJson(req);

        try {
            // ── AJAX: equipment của 1 contract — đã có JSON sẵn, giữ nguyên ──
            if ("getEquipment".equals(action)) {
                int contractId = Integer.parseInt(req.getParameter("contractId"));
                Contract c = contractDAO.getById(contractId);
                if (c == null || c.getCustomerId() != cid) {
                    resp.setStatus(403);
                    return;
                }
                List<CustomerEquipment> list = contractDAO.getEquipmentByContractId(contractId);
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    CustomerEquipment e = list.get(i);
                    if (i > 0) {
                        json.append(",");
                    }
                    json.append(String.format(
                            "{\"id\":%d,\"name\":\"%s\",\"serial\":\"%s\",\"source\":\"%s\"}",
                            e.getId(),
                            e.getDisplayName().replace("\"", "\\\""),
                            e.getDisplaySerial().replace("\"", "\\\""),
                            e.getSource()));
                }
                json.append("]");
                resp.getWriter().write(json.toString());
                return;
            }

            // ── DETAIL ───────────────────────────────────────────────
            if ("detail".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                ServiceRequest sr = srDAO.getById(id);
                if (sr == null || sr.getCustomerId() != cid) {
                    if (wantJson) {
                        writeError(resp, 403, "Forbidden");
                        return;
                    }
                    resp.sendRedirect(ctx + "/customerServiceRequests");
                    return;
                }

                if (wantJson) {
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().print(srToJson(sr));
                    return;
                }

                req.setAttribute("sr", sr);
                req.getRequestDispatcher("/customerServiceRequestDetail.jsp").forward(req, resp);
                return;
            }

            // ── CREATE PAGE — không cần JSON ─────────────────────────
            if ("create".equals(action)) {
                List<Contract> contracts = contractDAO.getActiveByCustomerId(cid);
                req.setAttribute("contracts", contracts);
                req.getRequestDispatcher("/customerServiceRequestCreate.jsp").forward(req, resp);
                return;
            }

            // ── LIST ─────────────────────────────────────────────────
            String status = nvl(req.getParameter("status"));
            String priority = nvl(req.getParameter("priority"));
            String from = nvl(req.getParameter("fromDate"));
            String to = nvl(req.getParameter("toDate"));

            List<ServiceRequest> list = srDAO.getFiltered(cid, status, priority, from, to);
            Map<String, Integer> counts = srDAO.getCountsByStatus(cid);

            if (wantJson) {
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"total\":").append(list.size()).append(",");
                json.append("\"pendingCount\":").append(counts.getOrDefault("PENDING", 0)).append(",");
                json.append("\"activeCount\":").append(counts.getOrDefault("IN_PROGRESS", 0) + counts.getOrDefault("APPROVED", 0)).append(",");
                json.append("\"completedCount\":").append(counts.getOrDefault("COMPLETED", 0)).append(",");
                json.append("\"serviceRequests\":[");
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) {
                        json.append(",");
                    }
                    json.append(srToJson(list.get(i)));
                }
                json.append("]}");
                resp.getWriter().print(json.toString());
                return;
            }

            req.setAttribute("serviceRequests", list);
            req.setAttribute("counts", counts);
            req.setAttribute("totalSR", counts.values().stream().mapToInt(i -> i).sum());
            req.setAttribute("pendingCount", counts.getOrDefault("PENDING", 0));
            req.setAttribute("activeCount", counts.getOrDefault("IN_PROGRESS", 0) + counts.getOrDefault("APPROVED", 0));
            req.setAttribute("completedCount", counts.getOrDefault("COMPLETED", 0));
            req.setAttribute("filterStatus", status);
            req.setAttribute("filterPriority", priority);
            req.setAttribute("filterFrom", from);
            req.setAttribute("filterTo", to);
            req.getRequestDispatcher("/customerServiceRequests.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(ctx + "/customerDashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User me = (User) req.getSession().getAttribute("user");
        int cid = me.getId();
        String action = req.getParameter("action");
        String ctx = req.getContextPath();
        try {
            if ("create".equals(action)) {
                ServiceRequest sr = new ServiceRequest();
                sr.setCustomerId(cid);
                sr.setContractId(Integer.parseInt(req.getParameter("contractId")));
                sr.setTitle(req.getParameter("title"));
                sr.setDescription(req.getParameter("description"));
                sr.setPriority(req.getParameter("priority"));

                String[] eqIds = req.getParameterValues("equipmentIds[]");
                String[] eqDescs = req.getParameterValues("issueDescs[]");
                List<Integer> ids = new ArrayList<>();
                List<String> descs = new ArrayList<>();
                if (eqIds != null) {
                    for (String id : eqIds) {
                        ids.add(Integer.parseInt(id));
                    }
                }
                if (eqDescs != null) {
                    Collections.addAll(descs, eqDescs);
                }

                if (ids.isEmpty()) {
                    req.getSession().setAttribute("flashError", "Vui lòng chọn ít nhất 1 thiết bị!");
                    resp.sendRedirect(ctx + "/customerServiceRequests?action=create");
                    return;
                }
                int newId = srDAO.create(sr, ids, descs);
                req.getSession().setAttribute("flashSuccess", "Tạo yêu cầu dịch vụ thành công!");
                resp.sendRedirect(ctx + "/customerServiceRequests?action=detail&id=" + newId);
                return;
            }
            if ("cancel".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean ok = srDAO.cancel(id, cid);
                req.getSession().setAttribute(ok ? "flashSuccess" : "flashError",
                        ok ? "Đã hủy yêu cầu thành công." : "Không thể hủy yêu cầu này.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flashError", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(ctx + "/customerServiceRequests");
    }

    // ── HELPERS ──────────────────────────────────────────────────────
    private String srToJson(ServiceRequest sr) {
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"id\":").append(sr.getId()).append(",");
        json.append("\"requestCode\":\"").append(safe(sr.getRequestCode())).append("\",");
        json.append("\"title\":\"").append(safe(sr.getTitle())).append("\",");
        json.append("\"description\":\"").append(safe(sr.getDescription())).append("\",");
        json.append("\"priority\":\"").append(safe(sr.getPriority())).append("\",");
        json.append("\"priorityLabel\":\"").append(safe(sr.getPriorityLabel())).append("\",");
        json.append("\"status\":\"").append(safe(sr.getStatus())).append("\",");
        json.append("\"statusLabel\":\"").append(safe(sr.getStatusLabel())).append("\",");
        json.append("\"contractCode\":\"").append(safe(sr.getContractCode())).append("\",");
        json.append("\"contractType\":\"").append(safe(sr.getContractType())).append("\",");
        json.append("\"assignedToName\":\"").append(safe(sr.getAssignedToName())).append("\",");
        json.append("\"createdAt\":\"").append(sr.getCreatedAt() != null ? sr.getCreatedAt() : "").append("\",");
        json.append("\"completedAt\":\"").append(sr.getCompletedAt() != null ? sr.getCompletedAt() : "").append("\",");
        // equipment list
        json.append("\"equipmentList\":[");
        List<ServiceRequestEquipment> eqList = sr.getEquipmentList();
        if (eqList != null) {
            for (int i = 0; i < eqList.size(); i++) {
                ServiceRequestEquipment e = eqList.get(i);
                if (i > 0) {
                    json.append(",");
                }
                json.append("{");
                json.append("\"id\":").append(e.getId()).append(",");
                json.append("\"displayName\":\"").append(safe(e.getDisplayName())).append("\",");
                json.append("\"displaySerial\":\"").append(safe(e.getDisplaySerial())).append("\",");
                json.append("\"issueDescription\":\"").append(safe(e.getIssueDescription())).append("\"");
                json.append("}");
            }
        }
        json.append("]}");
        return json.toString();
    }

    private boolean isJson(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        return accept != null && accept.contains("application/json");
    }

    private void writeError(HttpServletResponse resp, int status, String msg) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setStatus(status);
        resp.getWriter().write("{\"error\":\"" + msg + "\"}");
    }

    private String safe(String s) {
        return s != null ? s.replace("\\", "\\\\").replace("\"", "\\\"") : "";
    }

    private String nvl(String s) {
        return s == null ? "" : s.trim();
    }
}
