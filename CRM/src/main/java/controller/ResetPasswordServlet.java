package controller;

import dao.UserDAO;
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        // Chưa verify OTP → quay về
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("resetOtpVerified"))) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password.jsp");
            return;
        }
        req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        if (session == null || !Boolean.TRUE.equals(session.getAttribute("resetOtpVerified"))) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password.jsp");
            return;
        }

        String newPassword     = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (newPassword == null || newPassword.length() < 6) {
            req.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự!");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        try {
            int userId = (int) session.getAttribute("resetUserId");
            String hashed = PasswordUtil.hashPassword(newPassword);
            userDAO.updatePassword(userId, hashed);

            // Xóa toàn bộ session reset
            session.removeAttribute("resetEmail");
            session.removeAttribute("resetUserId");
            session.removeAttribute("resetOtp");
            session.removeAttribute("resetOtpExpiry");
            session.removeAttribute("resetOtpSentAt");
            session.removeAttribute("resetOtpVerified");

            // Chuyển về login với thông báo thành công
            resp.sendRedirect(req.getContextPath() + "/login?resetSuccess=1");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
        }
    }
}