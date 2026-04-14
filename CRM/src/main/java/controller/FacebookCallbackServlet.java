package controller;

import model.User;
import util.AppConfig;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

import org.json.JSONObject;

public class FacebookCallbackServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        String code = req.getParameter("code");
        String state = req.getParameter("state");
        String error = req.getParameter("error");

        if (error != null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String savedState = session != null ? (String) session.getAttribute("fb_oauth_state") : null;
        if (code == null || !state.equals(savedState)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=invalid_state");
            return;
        }

        try {
            String accessToken = exchangeCodeForToken(code);
            JSONObject userInfo = getUserInfo(accessToken);

            String fbId = userInfo.getString("id");
            String name = userInfo.optString("name", "Facebook User");
            String email = userInfo.optString("email", "");
            String avatar = "";
            if (userInfo.has("picture") && userInfo.getJSONObject("picture").has("data")) {
                avatar = userInfo.getJSONObject("picture").getJSONObject("data").optString("url", "");
            }

            User user = userDAO.findByProviderId("FACEBOOK", fbId);
            if (user == null) {
                if (!email.isEmpty()) {
                    user = userDAO.findByEmail(email);
                    if (user != null) {
                        session.setAttribute("error_msg", "Email " + email + " đã được đăng ký bằng phương thức khác!");
                        resp.sendRedirect(req.getContextPath() + "/login.jsp");
                        return;
                    }
                }
                user = new User();
                user.setFullName(name);
                user.setEmail(email);
                user.setUsername("fb_" + fbId.substring(0, Math.min(8, fbId.length())));
                user.setAuthProvider("FACEBOOK");
                user.setProviderId(fbId);
                user.setAvatarUrl(avatar);
                user.setActive(true);
                int newId = userDAO.insert(user);
                user.setId(newId);
            }

            // Reload lại từ DB để có roleName
            User savedUser = userDAO.findByProviderId("FACEBOOK", fbId);
            session.setAttribute("user", savedUser);
            session.removeAttribute("fb_oauth_state");

            String ctx = req.getContextPath();
            switch (savedUser.getRoleName() != null ? savedUser.getRoleName() : "") {
                case "ADMIN":
                    resp.sendRedirect(ctx + "/admin.jsp");
                    break;
                case "TECHNICAL_MANAGER":
                    resp.sendRedirect(ctx + "/technical-manager.jsp");
                    break;
                case "CUSTOMER_SUPPORT":
                    resp.sendRedirect(ctx + "/customer-support.jsp");
                    break;
                case "TECHNICIAN":
                    resp.sendRedirect(ctx + "/technician.jsp");
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
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=facebook_auth_failed");
        }
    }

    private String exchangeCodeForToken(String code) throws Exception {
        String tokenUrl = AppConfig.FACEBOOK_TOKEN_URL
                + "?client_id=" + URLEncoder.encode(AppConfig.FACEBOOK_APP_ID, StandardCharsets.UTF_8)
                + "&client_secret=" + URLEncoder.encode(AppConfig.FACEBOOK_APP_SECRET, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(AppConfig.FACEBOOK_REDIRECT_URI, StandardCharsets.UTF_8)
                + "&code=" + URLEncoder.encode(code, StandardCharsets.UTF_8);

        HttpURLConnection conn = (HttpURLConnection) new URL(tokenUrl).openConnection();
        String response = readResponse(conn);
        return new JSONObject(response).getString("access_token");
    }

    private JSONObject getUserInfo(String accessToken) throws Exception {
        String url = AppConfig.FACEBOOK_USERINFO_URL
                + "&access_token=" + URLEncoder.encode(accessToken, StandardCharsets.UTF_8);
        HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
        return new JSONObject(readResponse(conn));
    }

    private String readResponse(HttpURLConnection conn) throws Exception {
        try (Scanner sc = new Scanner(conn.getInputStream(), StandardCharsets.UTF_8)) {
            return sc.useDelimiter("\\A").next();
        }
    }
}
