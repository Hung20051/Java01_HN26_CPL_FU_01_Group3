package controller;

import util.AppConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

public class GoogleAuthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Tạo state ngẫu nhiên để chống CSRF
        String state = generateState();
        req.getSession(true).setAttribute("oauth_state", state);

        String authUrl = AppConfig.GOOGLE_AUTH_URL +
            "?client_id="     + URLEncoder.encode(AppConfig.GOOGLE_CLIENT_ID, StandardCharsets.UTF_8) +
            "&redirect_uri="  + URLEncoder.encode(AppConfig.GOOGLE_REDIRECT_URI, StandardCharsets.UTF_8) +
            "&response_type=code" +
            "&scope="         + URLEncoder.encode("openid email profile", StandardCharsets.UTF_8) +
            "&state="         + state +
            "&access_type=online" +
            "&prompt=select_account";

        resp.sendRedirect(authUrl);
    }

    private String generateState() {
        byte[] bytes = new byte[16];
        new SecureRandom().nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
