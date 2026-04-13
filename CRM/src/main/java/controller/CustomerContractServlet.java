package controller;

import dao.ContractDAO;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

public class CustomerContractServlet extends HttpServlet {
    private final ContractDAO dao = new ContractDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        int cid = me.getId();
        String ctx = req.getContextPath();
        boolean wantJson = isJson(req);

        try {
            // ── DETAIL ───────────────────────────────────────────────
            if ("detail".equals(req.getParameter("action"))) {
                int id = Integer.parseInt(req.getParameter("id"));
                Contract c = dao.getById(id);
                if (c == null || c.getCustomerId() != cid) {
                    if (wantJson) { writeError(resp, 403, "Forbidden"); return; }
                    resp.sendRedirect(ctx + "/customerContracts"); return;
                }
                c.setEquipmentList(dao.getEquipmentByContractId(id));

                if (wantJson) {
                    resp.setContentType("application/json;charset=UTF-8");
                    StringBuilder json = new StringBuilder();
                    json.append("{");
                    json.append("\"id\":").append(c.getId()).append(",");
                    json.append("\"contractCode\":\"").append(safe(c.getContractCode())).append("\",");
                    json.append("\"contractType\":\"").append(safe(c.getContractType())).append("\",");
                    json.append("\"contractTypeLabel\":\"").append(safe(c.getContractTypeLabel())).append("\",");
                    json.append("\"status\":\"").append(safe(c.getStatus())).append("\",");
                    json.append("\"statusLabel\":\"").append(safe(c.getStatusLabel())).append("\",");
                    json.append("\"startDate\":\"").append(c.getStartDate() != null ? c.getStartDate() : "").append("\",");
                    json.append("\"endDate\":\"").append(c.getEndDate() != null ? c.getEndDate() : "").append("\",");
                    json.append("\"notes\":\"").append(safe(c.getNotes())).append("\",");
                    json.append("\"equipmentCount\":").append(c.getEquipmentCount()).append(",");
                    json.append("\"serviceRequestCount\":").append(c.getServiceRequestCount()).append(",");
                    json.append("\"equipmentList\":[");
                    List<CustomerEquipment> eqList = c.getEquipmentList();
                    if (eqList != null) {
                        for (int i = 0; i < eqList.size(); i++) {
                            CustomerEquipment eq = eqList.get(i);
                            if (i > 0) json.append(",");
                            json.append("{");
                            json.append("\"id\":").append(eq.getId()).append(",");
                            json.append("\"name\":\"").append(safe(eq.getDisplayName())).append("\",");
                            json.append("\"serial\":\"").append(safe(eq.getDisplaySerial())).append("\",");
                            json.append("\"source\":\"").append(safe(eq.getSource())).append("\",");
                            json.append("\"underWarranty\":").append(eq.isUnderWarranty());
                            json.append("}");
                        }
                    }
                    json.append("]}");
                    resp.getWriter().print(json.toString());
                    return;
                }

                req.setAttribute("contract", c);
                req.getRequestDispatcher("/customerContractDetail.jsp").forward(req, resp);
                return;
            }

            // ── LIST ─────────────────────────────────────────────────
            List<Contract> list = dao.getByCustomerId(cid);
            long active   = list.stream().filter(c -> "ACTIVE".equals(c.getStatus())).count();
            long warranty = list.stream().filter(c -> "WARRANTY".equals(c.getContractType())).count();
            long maint    = list.stream().filter(c -> "MAINTENANCE".equals(c.getContractType())).count();

            if (wantJson) {
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"total\":").append(list.size()).append(",");
                json.append("\"activeCount\":").append(active).append(",");
                json.append("\"warrantyCount\":").append(warranty).append(",");
                json.append("\"maintCount\":").append(maint).append(",");
                json.append("\"contracts\":[");
                for (int i = 0; i < list.size(); i++) {
                    Contract c = list.get(i);
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"id\":").append(c.getId()).append(",");
                    json.append("\"contractCode\":\"").append(safe(c.getContractCode())).append("\",");
                    json.append("\"contractType\":\"").append(safe(c.getContractType())).append("\",");
                    json.append("\"contractTypeLabel\":\"").append(safe(c.getContractTypeLabel())).append("\",");
                    json.append("\"status\":\"").append(safe(c.getStatus())).append("\",");
                    json.append("\"statusLabel\":\"").append(safe(c.getStatusLabel())).append("\",");
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

            req.setAttribute("contracts",     list);
            req.setAttribute("activeCount",   active);
            req.setAttribute("warrantyCount", warranty);
            req.setAttribute("maintCount",    maint);
            req.getRequestDispatcher("/customerContracts.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(ctx + "/customerDashboard");
        }
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
}