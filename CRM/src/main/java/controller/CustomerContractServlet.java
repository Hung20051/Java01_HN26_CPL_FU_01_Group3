// ── CustomerContractServlet.java ────────────────────────────────
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
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        int cid = me.getId();
        String ctx = req.getContextPath();
        try {
            if ("detail".equals(req.getParameter("action"))) {
                int id = Integer.parseInt(req.getParameter("id"));
                Contract c = dao.getById(id);
                if (c == null || c.getCustomerId() != cid) { resp.sendRedirect(ctx+"/customerContracts"); return; }
                c.setEquipmentList(dao.getEquipmentByContractId(id));
                req.setAttribute("contract", c);
                req.getRequestDispatcher("/customerContractDetail.jsp").forward(req, resp);
                return;
            }
            List<Contract> list = dao.getByCustomerId(cid);
            long active    = list.stream().filter(c -> "ACTIVE".equals(c.getStatus())).count();
            long warranty  = list.stream().filter(c -> "WARRANTY".equals(c.getContractType())).count();
            long maint     = list.stream().filter(c -> "MAINTENANCE".equals(c.getContractType())).count();
            req.setAttribute("contracts", list);
            req.setAttribute("activeCount", active);
            req.setAttribute("warrantyCount", warranty);
            req.setAttribute("maintCount", maint);
            req.getRequestDispatcher("/customerContracts.jsp").forward(req, resp);
        } catch (Exception e) { e.printStackTrace(); resp.sendRedirect(ctx+"/customerDashboard"); }
    }
}