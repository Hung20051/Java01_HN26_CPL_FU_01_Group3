package controller;

import dao.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

public class TransactionServlet extends HttpServlet {
    private final TransactionDAO dao = new TransactionDAO();
    private static final int PAGE_SIZE = 15;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String type     = req.getParameter("type");      // PURCHASE / REPAIR / IMPORT / ALL
        String itemType = req.getParameter("itemType");  // PART / EQUIPMENT
        String keyword  = req.getParameter("keyword");
        String fromDate = req.getParameter("fromDate");
        String toDate   = req.getParameter("toDate");
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}

        // normalize "ALL" → null để không filter
        String typeFilter = ("ALL".equals(type) || type == null) ? null : type;

        try {
            int total      = dao.countAll(typeFilter, itemType, keyword, fromDate, toDate);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
            Map<String, Integer> counts = dao.countByType();

            req.setAttribute("transactions", dao.findAll(typeFilter, itemType, keyword, fromDate, toDate, page, PAGE_SIZE));
            req.setAttribute("counts",      counts);
            req.setAttribute("total",       total);
            req.setAttribute("totalPages",  totalPages);
            req.setAttribute("currentPage", page);
            req.setAttribute("type",        type != null ? type : "ALL");
            req.setAttribute("itemType",    itemType != null ? itemType : "");
            req.setAttribute("keyword",     keyword  != null ? keyword  : "");
            req.setAttribute("fromDate",    fromDate != null ? fromDate : "");
            req.setAttribute("toDate",      toDate   != null ? toDate   : "");

            req.getRequestDispatcher("/transactions.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/storekeeper");
        }
    }
}