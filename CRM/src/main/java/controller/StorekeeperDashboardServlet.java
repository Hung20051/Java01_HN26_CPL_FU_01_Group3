package controller;

import dao.PartDAO;
import dao.EquipmentDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import model.PartType;

public class StorekeeperDashboardServlet extends HttpServlet {

    private final PartDAO      partDAO      = new PartDAO();
    private final EquipmentDAO equipmentDAO = new EquipmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            Map<String, Integer> partStats   = partDAO.getDashboardStats();
            Map<String, Integer> eqStats     = equipmentDAO.getDashboardStats();
            List<?>              lowStockList = partDAO.getLowStockParts(5);
            List<?>              mostUsedList = partDAO.getMostUsedParts(5);

            // ── JSON response ────────────────────────────────────────
            String accept = req.getHeader("Accept");
            if (accept != null && accept.contains("application/json")) {
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder();
                json.append("{");

                // partStats
                json.append("\"partStats\":{");
                boolean firstP = true;
                for (Map.Entry<String, Integer> e : partStats.entrySet()) {
                    if (!firstP) json.append(",");
                    json.append("\"").append(safe(e.getKey())).append("\":")
                        .append(e.getValue() != null ? e.getValue() : 0);
                    firstP = false;
                }
                json.append("},");

                // eqStats
                json.append("\"eqStats\":{");
                boolean firstE = true;
                for (Map.Entry<String, Integer> e : eqStats.entrySet()) {
                    if (!firstE) json.append(",");
                    json.append("\"").append(safe(e.getKey())).append("\":")
                        .append(e.getValue() != null ? e.getValue() : 0);
                    firstE = false;
                }
                json.append("},");

                // lowStockList
                json.append("\"lowStockList\":").append(partTypeListToJson(lowStockList)).append(",");

                // mostUsedList
                json.append("\"mostUsedList\":").append(partTypeListToJson(mostUsedList));

                json.append("}");
                resp.getWriter().print(json.toString());
                return;
            }
            // ── hết JSON ─────────────────────────────────────────────

            req.setAttribute("partStats",    partStats);
            req.setAttribute("eqStats",      eqStats);
            req.setAttribute("lowStockList", lowStockList);
            req.setAttribute("mostUsedList", mostUsedList);
            req.getRequestDispatcher("/storekeeper.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    // ── HELPERS ──────────────────────────────────────────────────────

    private String safe(String s) {
        return s != null ? s.replace("\"", "\\\"") : "";
    }

    private String partTypeListToJson(List<?> list) {
        if (list == null || list.isEmpty()) return "[]";
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(",");
            PartType pt = (PartType) list.get(i);
            sb.append("{");
            sb.append("\"id\":").append(pt.getId()).append(",");
            sb.append("\"name\":\"").append(safe(pt.getName())).append("\",");
            sb.append("\"categoryName\":\"").append(safe(pt.getCategoryName())).append("\",");
            sb.append("\"unitPrice\":").append(pt.getUnitPrice()).append(",");
            sb.append("\"totalUnits\":").append(pt.getTotalUnits()).append(",");
            sb.append("\"availableUnits\":").append(pt.getAvailableUnits()).append(",");
            sb.append("\"inuseUnits\":").append(pt.getInuseUnits()).append(",");
            sb.append("\"faultyUnits\":").append(pt.getFaultyUnits());
            sb.append("}");
        }
        sb.append("]");
        return sb.toString();
    }
}