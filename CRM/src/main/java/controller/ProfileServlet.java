package controller;

import dao.UserDAO;
import model.User;
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }

        // Reload fresh data from DB
        try {
            User fresh = userDAO.findById(me.getId());
            if (fresh != null) {
                req.getSession().setAttribute("user", fresh);
                me = fresh;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        req.setAttribute("profileUser", me);
        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }

        String action = req.getParameter("action");

        try {
            if ("updateInfo".equals(action)) {
                doUpdateInfo(req, resp, me);
            } else if ("changePassword".equals(action)) {
                doChangePassword(req, resp, me);
            } else {
                resp.sendRedirect(req.getContextPath() + "/profile");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flash_error", "Đã xảy ra lỗi: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/profile");
        }
    }

    private void doUpdateInfo(HttpServletRequest req, HttpServletResponse resp, User me)
            throws Exception {
        String fullName = req.getParameter("fullName");
        String phone    = req.getParameter("phone");

        if (fullName == null || fullName.trim().isEmpty()) {
            req.getSession().setAttribute("flash_error", "Họ tên không được để trống.");
            resp.sendRedirect(req.getContextPath() + "/profile"); return;
        }

        me.setFullName(fullName.trim());
        me.setPhone(phone != null ? phone.trim() : "");
        userDAO.update(me);

        // Update session
        User fresh = userDAO.findById(me.getId());
        req.getSession().setAttribute("user", fresh);

        req.getSession().setAttribute("flash_success", "Cập nhật thông tin thành công!");
        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private void doChangePassword(HttpServletRequest req, HttpServletResponse resp, User me)
            throws Exception {
        String newPass     = req.getParameter("newPassword");
        String confirmPass = req.getParameter("confirmPassword");

        boolean isSocialAccount = me.getPassword() == null || me.getPassword().isEmpty();

        // Chỉ kiểm tra mật khẩu cũ với LOCAL account
        if (!isSocialAccount) {
            String currentPass = req.getParameter("currentPassword");
            if (!PasswordUtil.checkPassword(currentPass, me.getPassword())) {
                req.getSession().setAttribute("flash_error", "Mật khẩu hiện tại không đúng.");
                resp.sendRedirect(req.getContextPath() + "/profile"); return;
            }
        }

        if (newPass == null || newPass.length() < 6) {
            req.getSession().setAttribute("flash_error", "Mật khẩu mới phải có ít nhất 6 ký tự.");
            resp.sendRedirect(req.getContextPath() + "/profile"); return;
        }

        if (!newPass.equals(confirmPass)) {
            req.getSession().setAttribute("flash_error", "Xác nhận mật khẩu không khớp.");
            resp.sendRedirect(req.getContextPath() + "/profile"); return;
        }

        userDAO.updatePassword(me.getId(), PasswordUtil.hashPassword(newPass));

        // Refresh session
        User fresh = userDAO.findById(me.getId());
        req.getSession().setAttribute("user", fresh);

        String msg = isSocialAccount
            ? "Đặt mật khẩu thành công! Bạn có thể đăng nhập bằng mật khẩu này."
            : "Đổi mật khẩu thành công!";
        req.getSession().setAttribute("flash_success", msg);
        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}