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
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

import org.json.JSONObject;

public class GoogleCallbackServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        String code = req.getParameter("code");
        String state = req.getParameter("state");
        String error = req.getParameter("error");

        // Người dùng từ chối
        if (error != null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Kiểm tra state chống CSRF
        String savedState = session != null ? (String) session.getAttribute("oauth_state") : null;
        if (code == null || !state.equals(savedState)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=invalid_state");
            return;
        }

        try {
            // 1. Đổi code lấy access_token
            String accessToken = exchangeCodeForToken(code);

            // 2. Lấy thông tin user từ Google
            JSONObject userInfo = getUserInfo(accessToken);

            String googleId = userInfo.getString("sub");
            String email = userInfo.optString("email", "");
            String name = userInfo.optString("name", "");
            String picture = userInfo.optString("picture", "");

            // 3. Tìm hoặc tạo user trong DB
            User user = userDAO.findByProviderId("GOOGLE", googleId);
            if (user == null) {
                // Kiểm tra email đã tồn tại chưa
                user = userDAO.findByEmail(email);
                if (user != null) {
                    // Email đã tồn tại với account khác
                    session.setAttribute("error_msg", "Email " + email + " đã được đăng ký bằng phương thức khác!");
                    resp.sendRedirect(req.getContextPath() + "/login.jsp");
                    return;
                }
                // Tạo user mới
                user = new User();
                user.setFullName(name);
                user.setEmail(email);
                user.setUsername("google_" + googleId.substring(0, 8));
                user.setAuthProvider("GOOGLE");
                user.setProviderId(googleId);
                user.setAvatarUrl(picture);
                user.setActive(true);
                int newId = userDAO.insert(user);
                user.setId(newId);
            }

            session.setAttribute("user", user);
            session.removeAttribute("oauth_state");

            // Reload lại user từ DB để có roleName
            User savedUser = userDAO.findByProviderId("GOOGLE", googleId);
            session.setAttribute("user", savedUser);
            session.removeAttribute("oauth_state");

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
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error="
                    + URLEncoder.encode(e.getMessage() != null ? e.getMessage() : e.getClass().getName(), StandardCharsets.UTF_8));
        }
    }

    private String exchangeCodeForToken(String code) throws Exception {
        String params = "code=" + URLEncoder.encode(code, StandardCharsets.UTF_8)
                + "&client_id=" + URLEncoder.encode(AppConfig.GOOGLE_CLIENT_ID, StandardCharsets.UTF_8)
                + "&client_secret=" + URLEncoder.encode(AppConfig.GOOGLE_CLIENT_SECRET, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(AppConfig.GOOGLE_REDIRECT_URI, StandardCharsets.UTF_8)
                + "&grant_type=authorization_code";

        HttpURLConnection conn = (HttpURLConnection) new URL(AppConfig.GOOGLE_TOKEN_URL).openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes(StandardCharsets.UTF_8));
        }

        String response = readResponse(conn);
        return new JSONObject(response).getString("access_token");
    }

    private JSONObject getUserInfo(String accessToken) throws Exception {
        HttpURLConnection conn = (HttpURLConnection) new URL(AppConfig.GOOGLE_USERINFO_URL).openConnection();
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        return new JSONObject(readResponse(conn));
    }

    private String readResponse(HttpURLConnection conn) throws Exception {
        int status = conn.getResponseCode();
        InputStream is = (status >= 400) ? conn.getErrorStream() : conn.getInputStream();
        try (Scanner sc = new Scanner(is, StandardCharsets.UTF_8)) {
            String response = sc.useDelimiter("\\A").next();
            System.out.println("=== HTTP " + status + " Response: " + response);
            if (status >= 400) {
                throw new Exception("HTTP " + status + ": " + response);
            }
            return response;
        }
    }
}
