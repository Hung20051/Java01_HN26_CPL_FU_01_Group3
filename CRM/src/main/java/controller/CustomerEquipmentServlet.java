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
        if(me==null||!"CUSTOMER".equals(me.getRoleName())){resp.sendRedirect(req.getContextPath()+"/login.jsp");return;}
        try {
            req.setAttribute("equipmentList", dao.getByCustomerId(me.getId()));
            req.getRequestDispatcher("/customerEquipment.jsp").forward(req, resp);
        } catch(Exception e){e.printStackTrace();resp.sendRedirect(req.getContextPath()+"/customerDashboard");}
    }
}