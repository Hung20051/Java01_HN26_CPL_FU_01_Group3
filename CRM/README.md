# 🏢 CRM System - Hướng dẫn cài đặt

## 📋 Yêu cầu
- JDK 17
- Apache Tomcat 10.1
- MySQL 8.0 (MySQL Workbench)
- NetBeans IDE
- Maven (thường có sẵn trong NetBeans)

---

## 🗄️ BƯỚC 1 - Tạo Database MySQL

1. Mở **MySQL Workbench 8.0**
2. Kết nối vào MySQL server
3. Mở file `database.sql` và chạy toàn bộ (⚡ Execute All)
4. Sau khi chạy xong, sẽ có database `crm_db` với bảng `users` và tài khoản admin mẫu

---

## ⚙️ BƯỚC 2 - Cấu hình Database

Mở file: `src/main/java/com/crm/util/DBConnection.java`

```java
private static final String DB_URL      = "jdbc:mysql://localhost:3306/crm_db?...";
private static final String DB_USER     = "root";
private static final String DB_PASSWORD = "YOUR_MYSQL_PASSWORD"; // ← SỬA MẬT KHẨU MYSQL CỦA BẠN
```

---

## 📧 BƯỚC 3 - Cấu hình Gmail để gửi OTP

Mở file: `src/main/java/com/crm/util/EmailUtil.java`

```java
private static final String SENDER_EMAIL    = "hung091305@gmail.com";
private static final String SENDER_PASSWORD = "xxxx xxxx xxxx xxxx"; // ← App Password 16 ký tự
```

### Cách tạo Google App Password:
1. Vào https://myaccount.google.com/security
2. Bật **2-Step Verification** (Xác minh 2 bước)
3. Vào https://myaccount.google.com/apppasswords
4. Chọn app: "Mail", device: "Windows Computer"
5. Copy mã 16 ký tự và dán vào `SENDER_PASSWORD`

---

## 🔑 BƯỚC 4 - Cấu hình Google OAuth

Mở file: `src/main/java/com/crm/util/AppConfig.java`

### Tạo Google Client ID/Secret:
1. Vào https://console.cloud.google.com/
2. Tạo project mới (hoặc chọn project hiện có)
3. **APIs & Services → OAuth consent screen** → Điền thông tin app
4. **Credentials → Create Credentials → OAuth 2.0 Client IDs**
5. Application type: **Web application**
6. Authorized redirect URIs: thêm `http://localhost:9999/CRM/auth/google/callback`
7. Copy **Client ID** và **Client Secret** vào AppConfig.java

```java
public static final String GOOGLE_CLIENT_ID     = "YOUR_CLIENT_ID.apps.googleusercontent.com";
public static final String GOOGLE_CLIENT_SECRET = "GOCSPX-...";
```

---

## 👤 BƯỚC 5 - Cấu hình Facebook OAuth

### Tạo Facebook App ID/Secret:
1. Vào https://developers.facebook.com/
2. **My Apps → Create App → Authenticate and request data**
3. **App Settings → Basic**: Copy App ID và App Secret
4. **Add Product → Facebook Login → Web**
5. Valid OAuth Redirect URIs: `http://localhost:9999/CRM/auth/facebook/callback`

```java
public static final String FACEBOOK_APP_ID     = "YOUR_FACEBOOK_APP_ID";
public static final String FACEBOOK_APP_SECRET = "YOUR_FACEBOOK_APP_SECRET";
```

---

## 🚀 BƯỚC 6 - Chạy dự án trong NetBeans

1. **File → Open Project** → Chọn thư mục CRM
2. Chuột phải vào project → **Properties → Run**
3. Server: chọn **Apache Tomcat 10.1** (nếu chưa có, thêm vào: Tools → Servers)
4. Context Path: `/CRM`
5. **Chuột phải → Run** (F6)
6. Trình duyệt sẽ tự mở: `http://localhost:9999/CRM/home.jsp`

---

## 🔐 Tài khoản admin mẫu

| Trường | Giá trị |
|--------|---------|
| Username | `admin` |
| Password | `admin123` |

---

## 📁 Cấu trúc project

```
CRM/
├── src/main/
│   ├── java/com/crm/
│   │   ├── controller/         Servlets (Login, Register, OTP, Google, Facebook, Logout)
│   │   ├── model/              User.java
│   │   └── util/               DBConnection, UserDAO, PasswordUtil, EmailUtil, AppConfig
│   └── webapp/
│       ├── WEB-INF/web.xml
│       ├── css/style.css
│       ├── home.jsp            Trang chủ (có navbar)
│       ├── login.jsp           Đăng nhập (username/pass + Google + Facebook)
│       ├── register.jsp        Đăng ký
│       ├── otp.jsp             Xác nhận OTP
│       └── dashboard.jsp       Sau khi đăng nhập
├── database.sql                Schema MySQL
└── pom.xml                     Maven dependencies
```

---

## ⚠️ Lưu ý quan trọng

- **App Password Gmail**: Dùng App Password 16 ký tự, KHÔNG dùng mật khẩu Gmail thông thường
- **Facebook**: App phải ở chế độ **Live** để người dùng khác ngoài bạn có thể đăng nhập
- **HTTPS**: Facebook OAuth yêu cầu HTTPS khi deploy lên server thật (localhost thì OK)
- **MySQL password**: Hash bằng BCrypt, không bao giờ lưu plaintext
