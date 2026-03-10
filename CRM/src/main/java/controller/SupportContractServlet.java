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

        // ── AJAX: load equipment for selected customer + contract type ────
        if ("loadEquipment".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int customerId = Integer.parseInt(req.getParameter("customerId"));
                String ctype = req.getParameter("contractType");
                List<CustomerEquipment> list
                        = contractDAO.getEquipmentForContractType(customerId, ctype);
                resp.getWriter().write(equipmentToJson(list));
            } catch (Exception e) {
                resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            }
            return;
        }

        // ── Detail view ───────────────────────────────────────────────────
        if ("detail".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                Contract c = contractDAO.getById(id);
                if (c == null) {
                    resp.sendRedirect(req.getContextPath() + "/supportContracts");
                    return;
                }
                List<CustomerEquipment> equipList = contractDAO.getEquipmentByContractId(id);
                c.setEquipmentList(equipList);
                req.setAttribute("contract", c);
                req.getRequestDispatcher("/supportContractDetail.jsp").forward(req, resp);
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/supportContracts");
            }
            return;
        }

        // ── List page ─────────────────────────────────────────────────────
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

            // For create modal: load all active customers
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

    private String equipmentToJson(List<CustomerEquipment> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            CustomerEquipment e = list.get(i);
            if (i > 0) {
                sb.append(",");
            }
            String name = e.getDisplayName();
            String serial = e.getDisplaySerial();
            String cat = e.getCategoryName() != null ? e.getCategoryName() : "";
            String src = e.getSource() != null ? e.getSource() : "";
            String warranty = e.getWarrantyExpires() != null ? e.getWarrantyExpires().toString() : "";
            sb.append("{")
                    .append("\"id\":").append(e.getId()).append(",")
                    .append("\"name\":").append(jsonStr(name)).append(",")
                    .append("\"serial\":").append(jsonStr(serial)).append(",")
                    .append("\"category\":").append(jsonStr(cat)).append(",")
                    .append("\"source\":").append(jsonStr(src)).append(",")
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
