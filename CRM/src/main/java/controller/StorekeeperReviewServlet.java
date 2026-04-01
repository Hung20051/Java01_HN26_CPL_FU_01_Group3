package controller;

import dao.ReviewDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class StorekeeperReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User user = (User) req.getSession().getAttribute("user");
        if (user == null || !"STOREKEEPER".equals(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        String redirectUrl = req.getParameter("redirectUrl");
        if (redirectUrl == null || redirectUrl.isEmpty()) {
            redirectUrl = req.getContextPath() + "/numberPart";
        }

        try {
            if ("reply".equals(action)) {
                int reviewId = Integer.parseInt(req.getParameter("reviewId"));
                String replyText = req.getParameter("replyText");

                if (replyText == null || replyText.trim().isEmpty()) {
                    req.getSession().setAttribute("flashError", "Nội dung reply không được để trống!");
                } else if (replyText.trim().length() > 1000) {
                    req.getSession().setAttribute("flashError", "Reply không được vượt quá 1000 ký tự!");
                } else {
                    reviewDAO.replyToReview(reviewId, replyText.trim());
                    req.getSession().setAttribute("flashSuccess", "Đã gửi phản hồi thành công!");
                }

            } else if ("deleteReply".equals(action)) {
                int reviewId = Integer.parseInt(req.getParameter("reviewId"));
                reviewDAO.deleteReply(reviewId);
                req.getSession().setAttribute("flashSuccess", "Đã xóa phản hồi!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(redirectUrl);
    }
}