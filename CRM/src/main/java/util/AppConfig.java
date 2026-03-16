package util;

import java.io.InputStream;
import java.util.Properties;

public class AppConfig {

    private static final Properties props = new Properties();

    static {
        try (InputStream is = AppConfig.class.getClassLoader()
                .getResourceAsStream("config.properties")) {
            if (is == null) {
                throw new RuntimeException("Không tìm thấy config.properties!");
            }
            props.load(is);
        } catch (Exception e) {
            throw new RuntimeException("Lỗi load config: " + e.getMessage());
        }
    }

    public static final String BASE_URL = "http://localhost:9999/DRSMS";

    // Google OAuth
    public static final String GOOGLE_CLIENT_ID = props.getProperty("google.client.id");
    public static final String GOOGLE_CLIENT_SECRET = props.getProperty("google.client.secret");
    public static final String GOOGLE_REDIRECT_URI = props.getProperty("google.redirect.uri");
    public static final String GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
    public static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
    public static final String GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";

    // Facebook OAuth
    public static final String FACEBOOK_APP_ID = props.getProperty("facebook.app.id");
    public static final String FACEBOOK_APP_SECRET = props.getProperty("facebook.app.secret");
    public static final String FACEBOOK_REDIRECT_URI = props.getProperty("facebook.redirect.uri");
    public static final String FACEBOOK_AUTH_URL = "https://www.facebook.com/v18.0/dialog/oauth";
    public static final String FACEBOOK_TOKEN_URL = "https://graph.facebook.com/v18.0/oauth/access_token";
    public static final String FACEBOOK_USERINFO_URL = "https://graph.facebook.com/v18.0/me?fields=id,name,email,picture";

    // Getters cho DB và Email
    public static String getDbUrl() {
        return props.getProperty("db.url");
    }

    public static String getDbUser() {
        return props.getProperty("db.user");
    }

    public static String getDbPassword() {
        return props.getProperty("db.password");
    }

    public static String getEmailSender() {
        return props.getProperty("email.sender");
    }

    public static String getEmailPassword() {
        return props.getProperty("email.password");
    }
     public static String getGeminiApiKey() {
        return props.getProperty("gemini.api.key");
    }
}
