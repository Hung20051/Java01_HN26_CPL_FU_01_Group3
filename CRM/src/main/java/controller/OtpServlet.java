package controller;

import model.User;
import util.EmailUtil;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

public class OtpServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/register.jsp");
            return;
        }

        String action = req.getParameter("action");

        // ── RESEND OTP (AJAX) ──
        if ("resend".equals(action)) {
            handleResend(req, resp, session);
            return;
        }

        // ── VERIFY OTP ──
        String inputOtp   = req.getParameter("otp");
        String storedOtp  = (String) session.getAttribute("otp");
        Long   otpExpiry  = (Long) session.getAttribute("otpExpiry");
        Long   otpSentAt  = (Long) session.getAttribute("otpSentAt");
        Map<String, String> pendingUser = (Map<String, String>) session.getAttribute("pendingUser");

        if (pendingUser == null || storedOtp == null) {
            resp.sendRedirect(req.getContextPath() + "/register.jsp");
            return;
        }

        // Kiểm tra OTP hết hạn
        if (otpExpiry == null || System.currentTimeMillis() > otpExpiry) {
            req.setAttribute("error", "Mã OTP đã hết hạn! Vui lòng yêu cầu gửi lại.");
            req.getRequestDispatcher("otp.jsp").forward(req, resp);
            return;
        }

        // Kiểm tra OTP đúng
        if (!storedOtp.equals(inputOtp)) {
            req.setAttribute("error", "Mã OTP không đúng! Vui lòng kiểm tra lại email.");
            req.getRequestDispatcher("otp.jsp").forward(req, resp);
            return;
        }

        // OTP hợp lệ → lưu user vào DB
        try {
            User user = new User();
            user.setFullName(pendingUser.get("fullName"));
            user.setEmail(pendingUser.get("email"));
            user.setPhone(pendingUser.get("phone"));
            user.setUsername(pendingUser.get("username"));
            user.setPassword(pendingUser.get("password")); // đã hash
            user.setAuthProvider("LOCAL");
            user.setActive(true);

            int newId = userDAO.insert(user);
            user.setId(newId);

            // Xóa dữ liệu tạm
            session.removeAttribute("pendingUser");
            session.removeAttribute("otp");
            session.removeAttribute("otpExpiry");
            session.removeAttribute("otpSentAt");

            // Tự động đăng nhập sau khi đăng ký thành công
            session.setAttribute("user", user);

            resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Có lỗi khi tạo tài khoản: " + e.getMessage());
            req.getRequestDispatcher("otp.jsp").forward(req, resp);
        }
    }

    @SuppressWarnings("unchecked")
    private void handleResend(HttpServletRequest req, HttpServletResponse resp, HttpSession session)
            throws IOException {

        resp.setContentType("application/json;charset=UTF-8");

        Map<String, String> pendingUser = (Map<String, String>) session.getAttribute("pendingUser");
        Long otpSentAt = (Long) session.getAttribute("otpSentAt");

        if (pendingUser == null) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Phiên đăng ký đã hết hạn!\"}");
            return;
        }

        // Kiểm tra 60 giây cooldown
        if (otpSentAt != null && System.currentTimeMillis() - otpSentAt < 60_000) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đợi 60 giây trước khi gửi lại!\"}");
            return;
        }

        try {
            String newOtp = EmailUtil.generateOTP();
            long newExpiry = System.currentTimeMillis() + 10 * 60 * 1000;

            session.setAttribute("otp",       newOtp);
            session.setAttribute("otpExpiry", newExpiry);
            session.setAttribute("otpSentAt", System.currentTimeMillis());

            EmailUtil.sendOTP(pendingUser.get("email"), newOtp);

            resp.getWriter().write("{\"success\":true}");
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Gửi OTP thất bại: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/otp.jsp");
    }
}
