package controller;

import dao.ContractDAO;
import dao.CustomerEquipmentDAO;
import dao.ServiceRequestDAO;
import dao.UserDAO;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class SupportServiceRequestServlet extends HttpServlet {

    private final ServiceRequestDAO srDAO = new ServiceRequestDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final CustomerEquipmentDAO ceDAO = new CustomerEquipmentDAO();
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

        // ── AJAX: get contracts for a customer (for create modal) ─────────
        if ("getContracts".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int cid = Integer.parseInt(req.getParameter("customerId"));
                List<Contract> contracts = contractDAO.getActiveByCustomerId(cid);
                resp.getWriter().write(contractsToJson(contracts));
            } catch (Exception e) {
                resp.getWriter().write("[]");
            }
            return;
        }

        // ── AJAX: get equipment for a contract (for create modal) ─────────
        if ("getEquipment".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int contractId = Integer.parseInt(req.getParameter("contractId"));
                List<CustomerEquipment> list = ceDAO.getByContractId(contractId);
                resp.getWriter().write(equipmentToJson(list));
            } catch (Exception e) {
                resp.getWriter().write("[]");
            }
            return;
        }

        // ── Detail view ───────────────────────────────────────────────────
        if ("detail".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                ServiceRequest sr = srDAO.getById(id);
                if (sr == null) {
                    resp.sendRedirect(req.getContextPath() + "/supportServiceRequests");
                    return;
                }
                req.setAttribute("sr", sr);
                req.getRequestDispatcher("/supportServiceRequestDetail.jsp").forward(req, resp);
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/supportServiceRequests");
            }
            return;
        }

        // ── List page ─────────────────────────────────────────────────────
        try {
            contractDAO.autoExpireContracts();

            String keyword = req.getParameter("keyword");
            String status = req.getParameter("status");
            String priority = req.getParameter("priority");
            String contractType = req.getParameter("contractType");
            int page = 1;
            try {
                page = Integer.parseInt(req.getParameter("page"));
            } catch (Exception ignored) {
            }
            if (page < 1) {
                page = 1;
            }

            List<ServiceRequest> requests = srDAO.getAllFiltered(keyword, status, priority, contractType, page, PAGE_SIZE);
            int total = srDAO.countAllFiltered(keyword, status, priority, contractType);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            // For create modal
            List<User> customers = userDAO.findWithFilter(null, "1", "CUSTOMER", 1, 200);

            req.setAttribute("requests", requests);
            req.setAttribute("total", total);
            req.setAttribute("page", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("keyword", keyword);
            req.setAttribute("filterStatus", status);
            req.setAttribute("filterPriority", priority);
            req.setAttribute("filterType", contractType);
            req.setAttribute("customers", customers);

            req.getRequestDispatcher("/supportServiceRequests.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/supportServiceRequests");
        }
    }

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
                int contractId = Integer.parseInt(req.getParameter("contractId"));

                // ── Validate contract ──────────────────────────────────────
                Contract contract = contractDAO.getById(contractId);
                if (contract == null || !"ACTIVE".equals(contract.getStatus())) {
                    req.getSession().setAttribute("flash_error", "Cannot create: contract is not active.");
                    resp.sendRedirect(req.getContextPath() + "/supportServiceRequests");
                    return;
                }
                if (contract.getEndDate() == null || contract.getEndDate().isBefore(java.time.LocalDate.now())) {
                    req.getSession().setAttribute("flash_error", "Cannot create: contract has expired.");
                    resp.sendRedirect(req.getContextPath() + "/supportServiceRequests");
                    return;
                }

                String title = req.getParameter("title");
                String description = req.getParameter("description");
                String priority = req.getParameter("priority");
                String[] ceIds = req.getParameterValues("equipmentIds");
                String[] descs = req.getParameterValues("issueDescriptions");

                if (ceIds == null || ceIds.length == 0) {
                    req.getSession().setAttribute("flash_error", "Please select at least one equipment.");
                    resp.sendRedirect(req.getContextPath() + "/supportServiceRequests");
                    return;
                }

                ServiceRequest sr = new ServiceRequest();
                sr.setCustomerId(customerId);
                sr.setContractId(contractId);
                sr.setTitle(title);
                sr.setDescription(description);
                sr.setPriority(priority);

                List<Integer> equipIds = new ArrayList<>();
                List<String> issueDescs = new ArrayList<>();
                for (int i = 0; i < ceIds.length; i++) {
                    equipIds.add(Integer.parseInt(ceIds[i]));
                    issueDescs.add((descs != null && i < descs.length) ? descs[i] : null);
                }

                int newId = srDAO.create(sr, equipIds, issueDescs);
                req.getSession().setAttribute("flash_success", "Service request created successfully.");
                resp.sendRedirect(req.getContextPath() + "/supportServiceRequests?action=detail&id=" + newId);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flash_error", "Error: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/supportServiceRequests");
    }

    private String contractsToJson(List<Contract> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            Contract c = list.get(i);
            if (i > 0) {
                sb.append(",");
            }
            sb.append("{")
                    .append("\"id\":").append(c.getId()).append(",")
                    .append("\"code\":").append(jsonStr(c.getContractCode())).append(",")
                    .append("\"type\":").append(jsonStr(c.getContractType())).append(",")
                    .append("\"endDate\":").append(jsonStr(c.getEndDate() != null ? c.getEndDate().toString() : ""))
                    .append("}");
        }
        return sb.append("]").toString();
    }

    private String equipmentToJson(List<CustomerEquipment> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            CustomerEquipment e = list.get(i);
            if (i > 0) {
                sb.append(",");
            }
            sb.append("{")
                    .append("\"id\":").append(e.getId()).append(",")
                    .append("\"name\":").append(jsonStr(e.getDisplayName())).append(",")
                    .append("\"serial\":").append(jsonStr(e.getDisplaySerial()))
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
