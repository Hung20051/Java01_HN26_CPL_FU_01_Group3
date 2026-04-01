package filter;

import model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class TechnicianFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest  request  = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        User user = (User) request.getSession().getAttribute("user");
        if (user != null && "TECHNICIAN".equals(user.getRoleName())) {
            chain.doFilter(req, res);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }
}