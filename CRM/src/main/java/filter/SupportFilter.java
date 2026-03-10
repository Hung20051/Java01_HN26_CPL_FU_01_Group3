package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import model.User;
import java.io.IOException;

public class SupportFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user != null && "CUSTOMER_SUPPORT".equals(user.getRoleName())) {
            chain.doFilter(request, response);
        } else {
            // PHẢI dùng sendRedirect, không dùng forward
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    @Override
    public void init(FilterConfig fc) {
    }

    @Override
    public void destroy() {
    }
}
