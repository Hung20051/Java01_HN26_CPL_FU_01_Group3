package controller;

import model.User;
import util.PasswordUtil;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin!");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userDAO.findByUsername(username.trim());
            System.out.println("=== DEBUG ===");
            System.out.println("Username: " + username);
            System.out.println("User found: " + (user != null ? user.getUsername() : "NULL"));
            if (user != null) {
                System.out.println("Password hash in DB: " + user.getPassword());
                System.out.println("Check result: " + PasswordUtil.checkPassword(password, user.getPassword()));
            }
            if (user == null || !PasswordUtil.checkPassword(password, user.getPassword())) {
                req.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng!");
                req.getRequestDispatcher("login.jsp").forward(req, resp);
                return;
            }

            if (!user.isActive()) {
                req.setAttribute("error", "Tài khoản của bạn đã bị khóa!");
                req.getRequestDispatcher("login.jsp").forward(req, resp);
                return;
            }

            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60);

            // Redirect theo role
            String ctx = req.getContextPath();
            switch (user.getRoleName()) {
                case "ADMIN":
                    resp.sendRedirect(ctx + "/admin.jsp");
                    break;
                case "TECHNICAL_MANAGER":
                    resp.sendRedirect(ctx + "/tmServiceRequests");
                    break;
                case "CUSTOMER_SUPPORT":
                    resp.sendRedirect(ctx + "/supportDashboard");
                    break;
                case "TECHNICIAN":
                    resp.sendRedirect(ctx + "/techTasks");
                    break;
                case "STOREKEEPER":
                    resp.sendRedirect(ctx + "/dashboard.jsp");
                    break;
                case "CUSTOMER":
                    resp.sendRedirect(ctx + "/customerDashboard");
                    break;
                default:
                    resp.sendRedirect(ctx + "/dashboard.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Có lỗi xảy ra, vui lòng thử lại!");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }
}
