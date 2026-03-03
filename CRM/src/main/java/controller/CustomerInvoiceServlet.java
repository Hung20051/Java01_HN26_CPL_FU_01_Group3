package controller;
import dao.InvoiceDAO;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
public class CustomerInvoiceServlet extends HttpServlet {
    private final InvoiceDAO dao = new InvoiceDAO();
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        int cid = me.getId();
        String ctx = req.getContextPath();
        try {
            if ("detail".equals(req.getParameter("action"))) {
                int id = Integer.parseInt(req.getParameter("id"));
                Invoice inv = dao.getById(id);
                if (inv == null || inv.getCustomerId() != cid) { resp.sendRedirect(ctx+"/customerInvoices"); return; }
                req.setAttribute("invoice", inv);
                req.getRequestDispatcher("/customerInvoiceDetail.jsp").forward(req, resp);
                return;
            }
            String status = req.getParameter("status");
            if (status == null) status = "";
            List<Invoice> list = dao.getByCustomerId(cid, status);
            Map<String,Object> summary = dao.getSummary(cid);
            req.setAttribute("invoices", list);
            req.setAttribute("summary", summary);
            req.setAttribute("filterStatus", status);
            req.getRequestDispatcher("/customerInvoices.jsp").forward(req, resp);
        } catch (Exception e) { e.printStackTrace(); resp.sendRedirect(ctx+"/customerDashboard"); }
    }
}