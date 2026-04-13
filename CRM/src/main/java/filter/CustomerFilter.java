// ── FILE: filter/CustomerFilter.java ────────────────────────────
package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import model.User;
import java.io.IOException;

public class CustomerFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest hreq = (HttpServletRequest) req;
        HttpServletResponse hresp = (HttpServletResponse) res;
        HttpSession session = hreq.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null || !"CUSTOMER".equals(user.getRoleName())) {
            hresp.sendRedirect(hreq.getContextPath() + "/login.jsp");
            return;
        }
        chain.doFilter(req, res);
    }
}
