package controller;

import dao.UserDAO;
import model.User;
import util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    // ── BƯỚC 1: Hiển thị trang nhập email ──
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String step = req.getParameter("step");
        if ("reset".equals(step)) {
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("sendOtp".equals(action)) {
            handleSendOtp(req, resp);
        } else if ("verifyOtp".equals(action)) {
            handleVerifyOtp(req, resp);
        } else if ("resend".equals(action)) {
            handleResend(req, resp);
        }
    }

    // ── BƯỚC 1: Gửi OTP về email ──
    private void handleSendOtp(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        HttpSession session = req.getSession();

        try {
            User user = userDAO.findByEmail(email);
            if (user == null) {
                req.setAttribute("error", "Email không tồn tại trong hệ thống!");
                req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
                return;
            }

            // Chỉ cho phép tài khoản LOCAL (không phải Google/Facebook)
            if (!"LOCAL".equals(user.getAuthProvider())) {
                req.setAttribute("error", "Tài khoản này đăng nhập bằng " + user.getAuthProvider() + ", không thể đặt lại mật khẩu!");
                req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
                return;
            }

            String otp = EmailUtil.generateOTP();
            long expiry = System.currentTimeMillis() + 10 * 60 * 1000; // 10 phút

            session.setAttribute("resetEmail", email);
            session.setAttribute("resetUserId", user.getId());
            session.setAttribute("resetOtp", otp);
            session.setAttribute("resetOtpExpiry", expiry);
            session.setAttribute("resetOtpSentAt", System.currentTimeMillis());
            session.setAttribute("resetOtpVerified", false);

            EmailUtil.sendOTP(email, otp);

            resp.sendRedirect(req.getContextPath() + "/forgot-password.jsp?step=otp");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
        }
    }

    // ── BƯỚC 2: Xác nhận OTP ──
    private void handleVerifyOtp(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("resetOtp") == null) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password.jsp");
            return;
        }

        String inputOtp   = req.getParameter("otp");
        String storedOtp  = (String) session.getAttribute("resetOtp");
        Long   expiry     = (Long) session.getAttribute("resetOtpExpiry");

        if (expiry == null || System.currentTimeMillis() > expiry) {
            req.setAttribute("error", "Mã OTP đã hết hạn! Vui lòng yêu cầu gửi lại.");
            req.setAttribute("step", "otp");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        if (!storedOtp.equals(inputOtp)) {
            req.setAttribute("error", "Mã OTP không đúng!");
            req.setAttribute("step", "otp");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        // OTP đúng → cho phép đặt lại mật khẩu
        session.setAttribute("resetOtpVerified", true);
        resp.sendRedirect(req.getContextPath() + "/reset-password.jsp");
    }

    // ── RESEND OTP (AJAX) ──
    private void handleResend(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("resetEmail") == null) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Phiên đã hết hạn!\"}");
            return;
        }

        Long sentAt = (Long) session.getAttribute("resetOtpSentAt");
        if (sentAt != null && System.currentTimeMillis() - sentAt < 60_000) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đợi 60 giây trước khi gửi lại!\"}");
            return;
        }

        try {
            String email = (String) session.getAttribute("resetEmail");
            String newOtp = EmailUtil.generateOTP();
            long newExpiry = System.currentTimeMillis() + 10 * 60 * 1000;

            session.setAttribute("resetOtp", newOtp);
            session.setAttribute("resetOtpExpiry", newExpiry);
            session.setAttribute("resetOtpSentAt", System.currentTimeMillis());

            EmailUtil.sendOTP(email, newOtp);
            resp.getWriter().write("{\"success\":true}");
        } catch (Exception e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Gửi OTP thất bại!\"}");
        }
    }
}