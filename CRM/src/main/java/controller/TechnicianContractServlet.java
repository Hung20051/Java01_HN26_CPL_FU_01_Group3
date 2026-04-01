package controller;

import dao.ContractDAO;
import dao.CustomerEquipmentDAO;
import dao.EquipmentDAO;
import model.Contract;
import model.CustomerEquipment;
import model.EquipmentType;
import model.EquipmentUnit;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class TechnicianContractServlet extends HttpServlet {

    private final ContractDAO          contractDAO  = new ContractDAO();
    private final CustomerEquipmentDAO ceDAO        = new CustomerEquipmentDAO();
    private final EquipmentDAO         equipmentDAO = new EquipmentDAO();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        User me = getUser(req);
        if (me == null) { resp.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        String action = req.getParameter("action");
        try {
            if ("detail".equals(action)) {
                showContractDetail(req, resp);
            } else if ("equipment".equals(action)) {
                showEquipmentList(req, resp);
            } else if ("equipmentDetail".equals(action)) {
                showEquipmentDetail(req, resp);
            } else {
                showContractList(req, resp);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/technicianContracts");
        }
    }

    private void showContractList(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String keyword = req.getParameter("keyword");
        String type    = req.getParameter("type");
        String status  = req.getParameter("status");
        int page = parsePage(req);

        List<Contract> contracts = contractDAO.getAllFiltered(keyword, type, status, page, PAGE_SIZE);
        int total      = contractDAO.countFiltered(keyword, type, status);
        int totalPages = Math.max(1, (int) Math.ceil((double) total / PAGE_SIZE));

        req.setAttribute("contracts",    contracts);
        req.setAttribute("total",        total);
        req.setAttribute("page",         page);
        req.setAttribute("totalPages",   totalPages);
        req.setAttribute("keyword",      keyword != null ? keyword : "");
        req.setAttribute("filterType",   type    != null ? type    : "");
        req.setAttribute("filterStatus", status  != null ? status  : "");
        req.getRequestDispatcher("/technicianContracts.jsp").forward(req, resp);
    }

    private void showContractDetail(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String idParam = req.getParameter("id");
        if (idParam == null) { resp.sendRedirect(req.getContextPath() + "/technicianContracts"); return; }

        Contract contract = contractDAO.getById(Integer.parseInt(idParam));
        if (contract == null) { resp.sendRedirect(req.getContextPath() + "/technicianContracts"); return; }

        List<CustomerEquipment> equipList = ceDAO.getByContractId(contract.getId());
        contract.setEquipmentList(equipList);

        req.setAttribute("contract", contract);
        req.getRequestDispatcher("/technicianContractDetail.jsp").forward(req, resp);
    }

    private void showEquipmentList(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String keyword    = req.getParameter("keyword");
        String categoryId = req.getParameter("categoryId");
        String status     = req.getParameter("status"); // AVAILABLE, INUSE, FAULTY, RETIRED
        int page = parsePage(req);

        List<EquipmentType> types = equipmentDAO.findAllTypes(keyword, categoryId, null, page, PAGE_SIZE);
        int total      = equipmentDAO.countTypes(keyword, categoryId);
        int totalPages = Math.max(1, (int) Math.ceil((double) total / PAGE_SIZE));

        req.setAttribute("equipTypes",   types);
        req.setAttribute("total",        total);
        req.setAttribute("page",         page);
        req.setAttribute("totalPages",   totalPages);
        req.setAttribute("keyword",      keyword    != null ? keyword    : "");
        req.setAttribute("filterStatus", status     != null ? status     : "");
        req.getRequestDispatcher("/technicianEquipmentList.jsp").forward(req, resp);
    }

    private void showEquipmentDetail(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String idParam = req.getParameter("id");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/technicianContracts?action=equipment"); return;
        }
        int typeId = Integer.parseInt(idParam);
        EquipmentType type  = equipmentDAO.findTypeById(typeId);
        if (type == null) {
            resp.sendRedirect(req.getContextPath() + "/technicianContracts?action=equipment"); return;
        }
        List<EquipmentUnit> units = equipmentDAO.findUnitsByTypeId(typeId);

        req.setAttribute("equipType", type);
        req.setAttribute("units",     units);
        req.getRequestDispatcher("/technicianEquipmentDetail.jsp").forward(req, resp);
    }

    private User getUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return null;
        User u = (User) s.getAttribute("user");
        return (u != null && "TECHNICIAN".equals(u.getRoleName())) ? u : null;
    }

    private int parsePage(HttpServletRequest req) {
        try { int p = Integer.parseInt(req.getParameter("page")); return Math.max(p, 1); }
        catch (Exception e) { return 1; }
    }
}