package controller;

import util.EmailUtil;
import util.PasswordUtil;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String confirmPass = req.getParameter("confirmPassword");

        // Validation
        if (fullName == null || email == null || phone == null
                || username == null || password == null || confirmPass == null
                || fullName.isBlank() || email.isBlank() || username.isBlank() || password.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin!");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPass)) {
            req.setAttribute("error", "Mật khẩu nhập lại không khớp!");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 6) {
            req.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự!");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        try {
            if (userDAO.existsUsername(username.trim())) {
                req.setAttribute("error", "Tên đăng nhập đã tồn tại!");
                req.getRequestDispatcher("register.jsp").forward(req, resp);
                return;
            }
            if (userDAO.existsEmail(email.trim())) {
                req.setAttribute("error", "Email đã được sử dụng!");
                req.getRequestDispatcher("register.jsp").forward(req, resp);
                return;
            }

            // Tạo OTP và lưu dữ liệu vào session (chưa lưu DB)
            String otp = EmailUtil.generateOTP();
            long otpExpiry = System.currentTimeMillis() + 10 * 60 * 1000; // 10 phút

            HttpSession session = req.getSession(true);

            // Lưu thông tin đăng ký tạm thời vào session
            Map<String, String> pendingUser = new HashMap<>();
            pendingUser.put("fullName", fullName.trim());
            pendingUser.put("email", email.trim());
            pendingUser.put("phone", phone.trim());
            pendingUser.put("username", username.trim());
            pendingUser.put("password", PasswordUtil.hashPassword(password)); // hash ngay

            session.setAttribute("pendingUser", pendingUser);
            session.setAttribute("otp", otp);
            session.setAttribute("otpExpiry", otpExpiry);
            session.setAttribute("otpSentAt", System.currentTimeMillis());

            // Gửi OTP qua email
            EmailUtil.sendOTP(email.trim(), otp);

            resp.sendRedirect(req.getContextPath() + "/otp.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Có lỗi xảy ra khi gửi OTP: " + e.getMessage());
            req.getRequestDispatcher("register.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/register.jsp");
    }
}
