package controller;

import dao.PartDAO;
import dao.EquipmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

public class StorekeeperDashboardServlet extends HttpServlet {
    private final PartDAO      partDAO      = new PartDAO();
    private final EquipmentDAO equipmentDAO = new EquipmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            Map<String, Integer> partStats  = partDAO.getDashboardStats();
            Map<String, Integer> eqStats    = equipmentDAO.getDashboardStats();

            req.setAttribute("partStats",  partStats);
            req.setAttribute("eqStats",    eqStats);
            req.setAttribute("lowStockList",  partDAO.getLowStockParts(5));
            req.setAttribute("mostUsedList",  partDAO.getMostUsedParts(5));

            req.getRequestDispatcher("/storekeeper.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }
}