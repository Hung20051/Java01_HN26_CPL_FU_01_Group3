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

public class FacebookAuthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String state = generateState();
        req.getSession(true).setAttribute("fb_oauth_state", state);

        String authUrl = AppConfig.FACEBOOK_AUTH_URL +
            "?client_id="     + URLEncoder.encode(AppConfig.FACEBOOK_APP_ID, StandardCharsets.UTF_8) +
            "&redirect_uri="  + URLEncoder.encode(AppConfig.FACEBOOK_REDIRECT_URI, StandardCharsets.UTF_8) +
            "&state="         + state +
            "&scope="         + URLEncoder.encode("email,public_profile", StandardCharsets.UTF_8) +
            "&response_type=code";

        resp.sendRedirect(authUrl);
    }

    private String generateState() {
        byte[] bytes = new byte[16];
        new SecureRandom().nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
