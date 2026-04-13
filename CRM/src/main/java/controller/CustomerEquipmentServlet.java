package controller;

import dao.CustomerEquipmentDAO;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

public class CustomerEquipmentServlet extends HttpServlet {

    private final CustomerEquipmentDAO dao = new CustomerEquipmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        try {
            List<CustomerEquipment> list = dao.getByCustomerId(me.getId());
            // ── JSON response ──────────────────────────────
            String accept = req.getHeader("Accept");
            if (accept != null && accept.contains("application/json")) {
                resp.setContentType("application/json;charset=UTF-8");
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"customerId\":").append(me.getId()).append(",");
                json.append("\"customerName\":\"").append(me.getFullName()).append("\",");
                json.append("\"total\":").append(list.size()).append(",");
                json.append("\"equipments\":[");
                for (int i = 0; i < list.size(); i++) {
                    CustomerEquipment eq = list.get(i);
                    if (i > 0) {
                        json.append(",");
                    }
                    json.append("{");
                    json.append("\"name\":\"").append(safe(eq.getDisplayName())).append("\",");
                    json.append("\"serial\":\"").append(safe(eq.getDisplaySerial())).append("\",");
                    json.append("\"source\":\"").append(safe(eq.getSource())).append("\",");
                    json.append("\"category\":\"").append(safe(eq.getCategoryName())).append("\",");
                    json.append("\"purchasedDate\":\"").append(eq.getPurchasedDate() != null ? eq.getPurchasedDate() : "").append("\",");
                    json.append("\"warrantyExpires\":\"").append(eq.getWarrantyExpires() != null ? eq.getWarrantyExpires() : "").append("\",");
                    json.append("\"underWarranty\":").append(eq.isUnderWarranty()).append(",");
                    json.append("\"notes\":\"").append(safe(eq.getNotes())).append("\"");
                    json.append("}");
                }
                json.append("]}");
                resp.getWriter().print(json.toString());
                return;
            }
            // ── hết JSON ───────────────────────────────────
            req.setAttribute("equipmentList", list);
            req.getRequestDispatcher("/customerEquipment.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/customerDashboard");
        }
    }

   private String safe(String s) {
    return s != null ? s.replace("\\", "\\\\").replace("\"", "\\\"") : "";
   
}
}
