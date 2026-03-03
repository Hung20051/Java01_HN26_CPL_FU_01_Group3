package controller;

import dao.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

public class CustomerServiceRequestServlet extends HttpServlet {
    private final ServiceRequestDAO srDAO      = new ServiceRequestDAO();
    private final ContractDAO       contractDAO = new ContractDAO();
    private final CustomerEquipmentDAO ceDAO   = new CustomerEquipmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me  = (User) req.getSession().getAttribute("user");
        int  cid = me.getId();
        String action = req.getParameter("action");
        String ctx    = req.getContextPath();

        try {
            // AJAX: lấy equipment của 1 contract
            if ("getEquipment".equals(action)) {
                int contractId = Integer.parseInt(req.getParameter("contractId"));
                Contract c = contractDAO.getById(contractId);
                if (c == null || c.getCustomerId() != cid) { resp.setStatus(403); return; }
                List<CustomerEquipment> list = contractDAO.getEquipmentByContractId(contractId);
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    CustomerEquipment e = list.get(i);
                    if (i > 0) json.append(",");
                    json.append(String.format(
                        "{\"id\":%d,\"name\":\"%s\",\"serial\":\"%s\",\"source\":\"%s\"}",
                        e.getId(),
                        e.getDisplayName().replace("\"","\\\""),
                        e.getDisplaySerial().replace("\"","\\\""),
                        e.getSource()));
                }
                json.append("]");
                resp.getWriter().write(json.toString());
                return;
            }

            if ("detail".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                ServiceRequest sr = srDAO.getById(id);
                if (sr == null || sr.getCustomerId() != cid) {
                    resp.sendRedirect(ctx + "/customerServiceRequests"); return;
                }
                req.setAttribute("sr", sr);
                req.getRequestDispatcher("/customerServiceRequestDetail.jsp").forward(req, resp);
                return;
            }

            if ("create".equals(action)) {
                List<Contract> contracts = contractDAO.getActiveByCustomerId(cid);
                req.setAttribute("contracts", contracts);
                req.getRequestDispatcher("/customerServiceRequestCreate.jsp").forward(req, resp);
                return;
            }

            // List
            String status   = nvl(req.getParameter("status"));
            String priority = nvl(req.getParameter("priority"));
            String from     = nvl(req.getParameter("fromDate"));
            String to       = nvl(req.getParameter("toDate"));

            List<ServiceRequest> list = srDAO.getFiltered(cid, status, priority, from, to);
            Map<String, Integer> counts = srDAO.getCountsByStatus(cid);

            req.setAttribute("serviceRequests", list);
            req.setAttribute("counts",   counts);
            req.setAttribute("totalSR",  counts.values().stream().mapToInt(i -> i).sum());
            req.setAttribute("pendingCount",   counts.getOrDefault("PENDING", 0));
            req.setAttribute("activeCount",    counts.getOrDefault("IN_PROGRESS",0)+counts.getOrDefault("APPROVED",0));
            req.setAttribute("completedCount", counts.getOrDefault("COMPLETED", 0));
            req.setAttribute("filterStatus",   status);
            req.setAttribute("filterPriority", priority);
            req.setAttribute("filterFrom",     from);
            req.setAttribute("filterTo",       to);
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
        User me  = (User) req.getSession().getAttribute("user");
        int  cid = me.getId();
        String action = req.getParameter("action");
        String ctx    = req.getContextPath();
        try {
            if ("create".equals(action)) {
                ServiceRequest sr = new ServiceRequest();
                sr.setCustomerId(cid);
                sr.setContractId(Integer.parseInt(req.getParameter("contractId")));
                sr.setTitle(req.getParameter("title"));
                sr.setDescription(req.getParameter("description"));
                sr.setPriority(req.getParameter("priority"));

                String[] eqIds   = req.getParameterValues("equipmentIds[]");
                String[] eqDescs = req.getParameterValues("issueDescs[]");
                List<Integer> ids   = new ArrayList<>();
                List<String>  descs = new ArrayList<>();
                if (eqIds != null) for (String id : eqIds) ids.add(Integer.parseInt(id));
                if (eqDescs != null) Collections.addAll(descs, eqDescs);

                if (ids.isEmpty()) {
                    req.getSession().setAttribute("flashError", "Vui lòng chọn ít nhất 1 thiết bị!");
                    resp.sendRedirect(ctx + "/customerServiceRequests?action=create"); return;
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

    private String nvl(String s) { return s == null ? "" : s.trim(); }
}