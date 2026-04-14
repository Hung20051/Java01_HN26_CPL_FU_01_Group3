package controller;

import dao.ContractDAO;
import dao.UserDAO;
import model.Contract;
import model.CustomerEquipment;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

public class SupportContractServlet extends HttpServlet {

    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        boolean wantJson = isJson(req);

        // ── AJAX: load equipment — đã có JSON sẵn, giữ nguyên ───────────
        if ("loadEquipment".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int customerId = Integer.parseInt(req.getParameter("customerId"));
                String ctype = req.getParameter("contractType");
                List<CustomerEquipment> list = contractDAO.getEquipmentForContractType(customerId, ctype);
                resp.getWriter().write(equipmentToJson(list));
            } catch (Exception e) {
                resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            }
            return;
        }

        // ── DETAIL ───────────────────────────────────────────────────────
        if ("detail".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                Contract c = contractDAO.getById(id);
                if (c == null) {
                    if (wantJson) {
                        writeError(resp, 404, "Contract not found");
                        return;
                    }
                    resp.sendRedirect(req.getContextPath() + "/supportContracts");
                    return;
                }
                List<CustomerEquipment> equipList = contractDAO.getEquipmentByContractId(id);
                c.setEquipmentList(equipList);

                if (wantJson) {
                    resp.setContentType("application/json;charset=UTF-8");
                    StringBuilder json = new StringBuilder();
                    json.append("{");
                    json.append("\"id\":").append(c.getId()).append(",");
                    json.append("\"contractCode\":").append(jsonStr(c.getContractCode())).append(",");
                    json.append("\"customerId\":").append(c.getCustomerId()).append(",");
                    json.append("\"customerName\":").append(jsonStr(c.getCustomerName())).append(",");
                    json.append("\"contractType\":").append(jsonStr(c.getContractType())).append(",");
                    json.append("\"contractTypeLabel\":").append(jsonStr(c.getContractTypeLabel())).append(",");
                    json.append("\"status\":").append(jsonStr(c.getStatus())).append(",");
                    json.append("\"statusLabel\":").append(jsonStr(c.getStatusLabel())).append(",");
                    json.append("\"startDate\":\"").append(c.getStartDate() != null ? c.getStartDate() : "").append("\",");
                    json.append("\"endDate\":\"").append(c.getEndDate() != null ? c.getEndDate() : "").append("\",");
                    json.append("\"notes\":").append(jsonStr(c.getNotes())).append(",");
                    json.append("\"createdByName\":").append(jsonStr(c.getCreatedByName())).append(",");
                    json.append("\"equipmentCount\":").append(c.getEquipmentCount()).append(",");
                    json.append("\"serviceRequestCount\":").append(c.getServiceRequestCount()).append(",");
                    json.append("\"equipmentList\":").append(equipmentToJson(equipList));
                    json.append("}");
                    resp.getWriter().print(json.toString());
                    return;
                }

                req.setAttribute("contract", c);
                req.getRequestDispatcher("/supportContractDetail.jsp").forward(req, resp);
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/supportContracts");
            }
            return;
        }

        // ── LIST ─────────────────────────────────────────────────────────
        try {
            String keyword = req.getParameter("keyword");
            String type = req.getParameter("type");
            String status = req.getParameter("status");
            int page = 1;
            try {
                page = Integer.parseInt(req.getParameter("page"));
            } catch (Exception ignored) {
            }
            if (page < 1) {
                page = 1;
            }

            List<Contract> contracts = contractDAO.getAllFiltered(keyword, type, status, page, PAGE_SIZE);
            int total = contractDAO.countFiltered(keyword, type, status);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            if (wantJson) {
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"page\":").append(page).append(",");
                json.append("\"totalPages\":").append(totalPages).append(",");
                json.append("\"total\":").append(total).append(",");
                json.append("\"contracts\":[");
                for (int i = 0; i < contracts.size(); i++) {
                    Contract c = contracts.get(i);
                    if (i > 0) {
                        json.append(",");
                    }
                    json.append("{");
                    json.append("\"id\":").append(c.getId()).append(",");
                    json.append("\"contractCode\":").append(jsonStr(c.getContractCode())).append(",");
                    json.append("\"customerName\":").append(jsonStr(c.getCustomerName())).append(",");
                    json.append("\"contractType\":").append(jsonStr(c.getContractType())).append(",");
                    json.append("\"contractTypeLabel\":").append(jsonStr(c.getContractTypeLabel())).append(",");
                    json.append("\"status\":").append(jsonStr(c.getStatus())).append(",");
                    json.append("\"statusLabel\":").append(jsonStr(c.getStatusLabel())).append(",");
                    json.append("\"startDate\":\"").append(c.getStartDate() != null ? c.getStartDate() : "").append("\",");
                    json.append("\"endDate\":\"").append(c.getEndDate() != null ? c.getEndDate() : "").append("\",");
                    json.append("\"equipmentCount\":").append(c.getEquipmentCount()).append(",");
                    json.append("\"serviceRequestCount\":").append(c.getServiceRequestCount());
                    json.append("}");
                }
                json.append("]}");
                resp.getWriter().print(json.toString());
                return;
            }

            List<User> customers = userDAO.findWithFilter(null, "1", "CUSTOMER", 1, 200);
            req.setAttribute("contracts", contracts);
            req.setAttribute("total", total);
            req.setAttribute("page", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("keyword", keyword);
            req.setAttribute("type", type);
            req.setAttribute("filterStatus", status);
            req.setAttribute("customers", customers);
            req.getRequestDispatcher("/supportContracts.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/supportContracts");
        }
    }

    // ── POST giữ nguyên hoàn toàn ────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        try {
            if ("create".equals(action)) {
                int customerId = Integer.parseInt(req.getParameter("customerId"));
                String contractType = req.getParameter("contractType");
                String startDateStr = req.getParameter("startDate");
                String endDateStr = req.getParameter("endDate");
                String notes = req.getParameter("notes");
                String[] ceIds = req.getParameterValues("equipmentIds");

                if (ceIds == null || ceIds.length == 0) {
                    req.getSession().setAttribute("flash_error", "Please select at least one equipment.");
                    resp.sendRedirect(req.getContextPath() + "/supportContracts");
                    return;
                }

                Contract c = new Contract();
                c.setCustomerId(customerId);
                c.setCreatedBy(me.getId());
                c.setContractType(contractType);
                c.setStartDate(LocalDate.parse(startDateStr));
                c.setEndDate(LocalDate.parse(endDateStr));
                c.setNotes(notes);

                List<Integer> ids = new java.util.ArrayList<>();
                for (String id : ceIds) {
                    ids.add(Integer.parseInt(id));
                }

                int newId = contractDAO.create(c, ids);
                req.getSession().setAttribute("flash_success", "Contract created successfully.");
                resp.sendRedirect(req.getContextPath() + "/supportContracts?action=detail&id=" + newId);
                return;

            } else if ("cancel".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                contractDAO.cancel(id);
                req.getSession().setAttribute("flash_success", "Contract cancelled.");
                resp.sendRedirect(req.getContextPath() + "/supportContracts?action=detail&id=" + id);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flash_error", "Error: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/supportContracts");
    }

    // ── HELPERS ──────────────────────────────────────────────────────────
    private boolean isJson(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        return accept != null && accept.contains("application/json");
    }

    private void writeError(HttpServletResponse resp, int status, String msg) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setStatus(status);
        resp.getWriter().write("{\"error\":\"" + msg + "\"}");
    }

    private String equipmentToJson(List<CustomerEquipment> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            CustomerEquipment e = list.get(i);
            if (i > 0) {
                sb.append(",");
            }
            String warranty = e.getWarrantyExpires() != null ? e.getWarrantyExpires().toString() : "";
            sb.append("{")
                    .append("\"id\":").append(e.getId()).append(",")
                    .append("\"name\":").append(jsonStr(e.getDisplayName())).append(",")
                    .append("\"serial\":").append(jsonStr(e.getDisplaySerial())).append(",")
                    .append("\"category\":").append(jsonStr(e.getCategoryName() != null ? e.getCategoryName() : "")).append(",")
                    .append("\"source\":").append(jsonStr(e.getSource() != null ? e.getSource() : "")).append(",")
                    .append("\"warrantyExpires\":").append(jsonStr(warranty))
                    .append("}");
        }
        return sb.append("]").toString();
    }

    private String jsonStr(String s) {
        if (s == null) {
            return "null";
        }
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
    }
}
