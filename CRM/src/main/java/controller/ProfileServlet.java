package controller;

import dao.UserDAO;
import model.User;
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    // ─────────────────────────────────────────────────
    //  GET
    // ─────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
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

    // ─────────────────────────────────────────────────
    //  POST — dispatch
    // ─────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action) {
                case "updateInfo" ->
                    doUpdateBasicInfo(req, resp, me);
                case "updatePersonalInfo" ->
                    doUpdatePersonalInfo(req, resp, me);
                case "changePassword" ->
                    doChangePassword(req, resp, me);
                default ->
                    resp.sendRedirect(req.getContextPath() + "/profile");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flash_error", "An error occurred: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/profile");
        }
    }

    // ─────────────────────────────────────────────────
    //  ACTION: update basic info (name + phone)
    // ─────────────────────────────────────────────────
    private void doUpdateBasicInfo(HttpServletRequest req, HttpServletResponse resp, User me)
            throws Exception {
        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");

        if (fullName == null || fullName.trim().isEmpty()) {
            req.getSession().setAttribute("flash_error", "Full name cannot be empty.");
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        me.setFullName(fullName.trim());
        me.setPhone(phone != null ? phone.trim() : "");
        userDAO.updateBasicInfo(me);

        refreshSession(req, me.getId());
        req.getSession().setAttribute("flash_success", "Profile updated successfully!");
        resp.sendRedirect(req.getContextPath() + "/profile?tab=edit");
    }

    // ─────────────────────────────────────────────────
    //  ACTION: update extended personal info
    // ─────────────────────────────────────────────────
    private void doUpdatePersonalInfo(HttpServletRequest req, HttpServletResponse resp, User me)
            throws Exception {

        // Basic
        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        if (fullName == null || fullName.trim().isEmpty()) {
            req.getSession().setAttribute("flash_error", "Full name cannot be empty.");
            resp.sendRedirect(req.getContextPath() + "/profile?tab=personal");
            return;
        }
        me.setFullName(fullName.trim());
        me.setPhone(trim(req, "phone"));

        // Address
        me.setAddressStreet(trim(req, "addressStreet"));
        me.setAddressWard(trim(req, "addressWard"));
        me.setAddressDistrict(trim(req, "addressDistrict"));
        me.setAddressCity(trim(req, "addressCity"));

        // Personal
        me.setHometown(trim(req, "hometown"));
        me.setGender(trim(req, "gender"));
        me.setNationalId(trim(req, "nationalId"));

        String dobStr = req.getParameter("dateOfBirth");
        if (dobStr != null && !dobStr.isBlank()) {
            try {
                me.setDateOfBirth(LocalDate.parse(dobStr));
            } catch (DateTimeParseException e) {
                req.getSession().setAttribute("flash_error", "Invalid date of birth format (YYYY-MM-DD).");
                resp.sendRedirect(req.getContextPath() + "/profile?tab=personal");
                return;
            }
        } else {
            me.setDateOfBirth(null);
        }

        // Emergency contact
        me.setEmergencyName(trim(req, "emergencyName"));
        me.setEmergencyPhone(trim(req, "emergencyPhone"));
        me.setEmergencyRelation(trim(req, "emergencyRelation"));

        // Professional
        me.setCompanyName(trim(req, "companyName"));
        me.setBio(trim(req, "bio"));

        userDAO.updatePersonalInfo(me);

        refreshSession(req, me.getId());
        req.getSession().setAttribute("flash_success", "Personal information saved successfully!");
        resp.sendRedirect(req.getContextPath() + "/profile?tab=personal");
    }

    // ─────────────────────────────────────────────────
    //  ACTION: change password
    // ─────────────────────────────────────────────────
    private void doChangePassword(HttpServletRequest req, HttpServletResponse resp, User me)
            throws Exception {
        String newPass = req.getParameter("newPassword");
        String confirmPass = req.getParameter("confirmPassword");

        boolean isSocialAccount = me.getPassword() == null || me.getPassword().isEmpty();

        if (!isSocialAccount) {
            String currentPass = req.getParameter("currentPassword");
            if (!PasswordUtil.checkPassword(currentPass, me.getPassword())) {
                req.getSession().setAttribute("flash_error", "Current password is incorrect.");
                resp.sendRedirect(req.getContextPath() + "/profile?tab=password");
                return;
            }
        }

        if (newPass == null || newPass.length() < 6) {
            req.getSession().setAttribute("flash_error", "New password must be at least 6 characters.");
            resp.sendRedirect(req.getContextPath() + "/profile?tab=password");
            return;
        }

        if (!newPass.equals(confirmPass)) {
            req.getSession().setAttribute("flash_error", "Passwords do not match.");
            resp.sendRedirect(req.getContextPath() + "/profile?tab=password");
            return;
        }

        userDAO.updatePassword(me.getId(), PasswordUtil.hashPassword(newPass));
        refreshSession(req, me.getId());

        String msg = isSocialAccount
                ? "Password set successfully! You can now sign in with this password."
                : "Password changed successfully!";
        req.getSession().setAttribute("flash_success", msg);
        resp.sendRedirect(req.getContextPath() + "/profile?tab=password");
    }

    // ─────────────────────────────────────────────────
    //  HELPERS
    // ─────────────────────────────────────────────────
    private void refreshSession(HttpServletRequest req, int userId) throws Exception {
        User fresh = userDAO.findById(userId);
        if (fresh != null) {
            req.getSession().setAttribute("user", fresh);
        }
    }

    private String trim(HttpServletRequest req, String param) {
        String v = req.getParameter(param);
        return (v != null && !v.isBlank()) ? v.trim() : null;
    }
}
