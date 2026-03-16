package controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import dao.AIChatDAO;
import jakarta.servlet.http.*;
import model.AIChatMessage;
import model.User;
import util.AppConfig;

import java.io.*;
import java.net.URI;
import java.net.http.*;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.regex.*;

public class AIChatServlet extends HttpServlet {

    private static final String GEMINI_API_URL =
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";
    private static final int HISTORY_LIMIT = 20;

    private final ObjectMapper mapper = new ObjectMapper();
    private final AIChatDAO    dao    = new AIChatDAO();

    /* ═══════════════════════════════════════════════════════════
       QUICK-RESPONSE TABLE  (Vietnamese + English)
       Format: add(pattern, "vi", viReply1, viReply2, "en", enReply1, enReply2, ...)
       null array → handled dynamically in buildDynamicReply()
    ═══════════════════════════════════════════════════════════ */
    private static final List<QuickRule> QUICK_RULES = new ArrayList<>();

    static {

        // ── Greeting ──────────────────────────────────────────
        add("^(xin chào|chào|hello|hi|hey|alo|alô|helo|hii+|howdy|greetings|sup|what'?s up)[\\.!?\\s]*$",
            "vi", "Xin chào! 👋 Tôi có thể giúp gì cho bạn hôm nay?",
                  "Chào bạn! 😊 Bạn cần hỗ trợ gì không?",
                  "Hello! 👋 Tôi luôn sẵn sàng giúp bạn nhé!",
            "en", "Hello! 👋 How can I help you today?",
                  "Hi there! 😊 What can I do for you?",
                  "Hey! 👋 I'm here to help — what do you need?"
        );

        // ── How are you ────────────────────────────────────────
        add("(bạn có khỏe|bạn khỏe|khỏe không|có khỏe không|how are you|how('?re| are) you doing|you doing|are you (ok|okay|good|fine))",
            "vi", "Tôi khỏe, cảm ơn bạn đã hỏi! 😄 Bạn cần tôi hỗ trợ gì không?",
                  "Tôi luôn hoạt động tốt! 🤖✨ Bạn cần giúp gì nào?",
            "en", "I'm doing great, thanks for asking! 😄 How can I help you?",
                  "All systems running smoothly! 🤖✨ What do you need?"
        );

        // ── Thank you ──────────────────────────────────────────
        add("^(cảm ơn|cám ơn|cảm ơn bạn|cảm ơn nhiều|thanks?|thank you|thank you so much|ty|thx|tks|many thanks|much appreciated)[\\.!\\s]*$",
            "vi", "Không có gì! 😊 Nếu cần thêm gì cứ hỏi tôi nhé!",
                  "Rất vui được giúp bạn! 🙌 Bạn cần thêm gì không?",
                  "Bạn không cần khách khí! 😄 Cứ hỏi bất cứ lúc nào!",
            "en", "You're welcome! 😊 Let me know if you need anything else!",
                  "Happy to help! 🙌 Anything else I can do for you?",
                  "Anytime! 😄 Feel free to ask whenever you need!"
        );

        // ── Goodbye ────────────────────────────────────────────
        add("^(tạm biệt|bye|goodbye|good bye|chào nhé|thôi nhé|gotta go|see you|see ya|ttyl|take care|cya)[\\.!\\s]*$",
            "vi", "Tạm biệt! 👋 Chúc bạn một ngày tốt lành nhé!",
                  "Bye bye! 😊 Khi cần hỗ trợ cứ quay lại nhé!",
            "en", "Goodbye! 👋 Have a great day!",
                  "See you! 😊 Feel free to come back anytime!"
        );

        // ── What time is it (dynamic) ──────────────────────────
        add("(mấy giờ|bây giờ là|bao nhiêu giờ|what time|current time|what'?s the time|time (now|is it))",
            (String[]) null
        );

        // ── What day / date (dynamic) ──────────────────────────
        add("(hôm nay.*ngày|ngày.*hôm nay|thứ mấy|hôm nay thứ|today.*date|what.*date|what day|day (today|is it)|current date)",
            (String[]) null
        );

        // ── Who are you ────────────────────────────────────────
        add("(tên.*bạn|bạn.*tên|bạn là ai|who are you|your name|what('?s| is) your name|mày là ai)",
            "vi", "Tôi là **DRSMS Assistant** 🤖 — trợ lý AI hỗ trợ bạn về thiết bị, hợp đồng, sửa chữa và hóa đơn. Bạn cần gì không?",
                  "Tôi là trợ lý AI của DRSMS! 😊 Sẵn sàng giúp bạn mọi thắc mắc về hệ thống.",
            "en", "I'm **DRSMS Assistant** 🤖 — your AI helper for equipment, contracts, repair requests, and invoices. How can I help?",
                  "I'm the AI assistant for DRSMS! 😊 Here to help with system questions and more."
        );

        // ── What can you do ────────────────────────────────────
        add("(bạn.*làm được gì|bạn.*giúp.*gì|chức năng|tính năng|what can you do|how can you help|what do you (do|help)|your (features?|capabilities?))",
            "vi", "Tôi có thể giúp bạn:\n📄 Hỏi về hợp đồng, bảo hành, bảo trì\n🔧 Tạo & theo dõi Repair Request\n💰 Kiểm tra hóa đơn & thanh toán\n🛒 Tư vấn mua linh kiện/thiết bị\n🤖 Trả lời câu hỏi kỹ thuật & chung\n\nCứ hỏi thẳng vào vấn đề nhé! 😊",
            "en", "Here's what I can help with:\n📄 Contracts, warranty & maintenance info\n🔧 Creating & tracking Repair Requests\n💰 Invoices & payment status\n🛒 Parts & equipment purchasing advice\n🤖 Technical & general questions\n\nJust ask away! 😊"
        );

        // ── OK / Acknowledged ──────────────────────────────────
        add("^(ok|okay|oke|oki|được rồi|được|rồi|alright|got it|gotcha|noted|understood|hiểu rồi|hiểu|roger|copy that|sure)[\\.!\\s]*$",
            "vi", "👍 Nếu cần thêm gì cứ hỏi tôi nhé!",
                  "OK! 😊 Còn gì tôi có thể giúp không?",
                  "Tuyệt! 🙌 Bạn cần hỗ trợ thêm gì không?",
            "en", "👍 Let me know if you need anything else!",
                  "OK! 😊 Is there anything else I can help with?",
                  "Great! 🙌 Feel free to ask if you have more questions!"
        );

        // ── Test / Ping ────────────────────────────────────────
        add("^(test|testing|thử|thử tí|ping|check|hello bot|are you there|you there|anyone there)[\\.!?\\s]*$",
            "vi", "Tôi đang hoạt động tốt! 🟢 Bạn cần hỗ trợ gì không?",
                  "Pong! 🏓 Hệ thống bình thường nhé!",
            "en", "I'm here and running smoothly! 🟢 How can I help?",
                  "Pong! 🏓 All systems operational!"
        );

        // ── Sad / Tired ────────────────────────────────────────
        add("(tôi.*buồn|tôi.*mệt|tôi.*chán|i'?m (sad|tired|exhausted|stressed|bored)|feeling (down|bad|low|terrible|awful)|not (ok|okay|good|fine))",
            "vi", "Ôi, nghe vậy tôi cũng lo cho bạn đó! 😟 Hy vọng bạn sớm cảm thấy tốt hơn. Nếu có gì tôi giúp được thì cứ nói! 💪",
                  "Mệt thì nghỉ ngơi một chút nhé! ☕ Tôi luôn ở đây khi bạn cần.",
            "en", "Sorry to hear that! 😟 I hope you feel better soon. Let me know if I can help with anything! 💪",
                  "Take a break if you need one! ☕ I'll be here whenever you're ready."
        );

        // ── I'm fine ───────────────────────────────────────────
        add("^(i'?m (fine|good|great|doing well|doing good|alright)|tôi (ổn|khỏe|tốt|bình thường))[\\.!\\s]*$",
            "vi", "Vui vì bạn ổn! 😊 Bạn cần tôi giúp gì không?",
            "en", "Glad to hear that! 😊 How can I help you today?"
        );

        // ── System error ───────────────────────────────────────
        add("(hệ thống.*lỗi|bị lỗi|không.*hoạt động|system.*(down|error|broken|not working)|can'?t (access|login|log in))",
            "vi", "Bạn đang gặp lỗi gì vậy? 🤔 Hãy mô tả cụ thể để tôi hỗ trợ tốt hơn! Nếu cần gấp bạn có thể liên hệ Customer Support qua chat nhé.",
            "en", "Sorry to hear you're having trouble! 🤔 Could you describe the issue? You can also contact Customer Support via chat for urgent help."
        );

        // ── Sorry (from user) ──────────────────────────────────
        add("^(xin lỗi|xin lỗi bạn|sorry|i'?m sorry|pardon|my bad|apologies|oops)[\\.!\\s]*$",
            "vi", "Không có vấn đề gì đâu bạn! 😊 Bạn cần tôi giúp gì không?",
                  "Bạn không cần xin lỗi! 🙂 Cứ thoải mái hỏi nhé.",
            "en", "No worries at all! 😊 How can I help you?",
                  "Don't worry about it! 🙂 Feel free to ask anything."
        );

        // ── Nice / Cool / Wow ──────────────────────────────────
        add("^(nice|cool|wow|great|awesome|amazing|tuyệt|tuyệt vời|hay quá|giỏi quá|quá đỉnh|xuất sắc)[\\.!\\s]*$",
            "vi", "Cảm ơn bạn! 😄 Còn gì tôi có thể giúp không?",
            "en", "Thanks! 😄 Anything else I can do for you?"
        );

        // ── Help (generic) ─────────────────────────────────────
        add("^(help|giúp|giúp tôi|giúp với|cần giúp|i need help|need (some )?help|help me)[\\.!?\\s]*$",
            "vi", "Tôi ở đây để giúp bạn! 😊 Bạn đang gặp vấn đề gì — hệ thống, thiết bị, hay câu hỏi khác?",
            "en", "I'm here to help! 😊 What's the issue — system, equipment, or something else?"
        );
    }

    /* helper đăng ký rule */
    private static void add(String pattern, String... langAndReplies) {
        QUICK_RULES.add(new QuickRule(
                Pattern.compile(pattern, Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE),
                langAndReplies
        ));
    }

    private static class QuickRule {
        final Pattern  pattern;
        final String[] langAndReplies; // null → dynamic
        QuickRule(Pattern p, String[] r) { pattern = p; langAndReplies = r; }
    }

    /* ────────────────────────────────────────────────────────
       Detect language: ký tự có dấu tiếng Việt → "vi", còn lại → "en"
    ──────────────────────────────────────────────────────── */
    private static String detectLang(String msg) {
        return msg.matches(".*[àáâãèéêìíòóôõùúýăđơưạảấầẩẫậắằẳẵặẹẻẽếềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ].*")
               ? "vi" : "en";
    }

    /* ────────────────────────────────────────────────────────
       Pick random reply for given language from langAndReplies
       Format: ["vi", r1, r2, "en", r1, r2, ...]
    ──────────────────────────────────────────────────────── */
    private static String pickReply(String[] arr, String lang) {
        if (arr == null) return null;
        List<String> pool = new ArrayList<>();
        boolean inLang = false;
        for (String s : arr) {
            if ("vi".equals(s) || "en".equals(s)) { inLang = lang.equals(s); }
            else if (inLang)                       { pool.add(s); }
        }
        // fallback: all non-label entries
        if (pool.isEmpty()) {
            for (String s : arr) { if (!"vi".equals(s) && !"en".equals(s)) pool.add(s); }
        }
        if (pool.isEmpty()) return null;
        return pool.get(new Random().nextInt(pool.size()));
    }

    /* ────────────────────────────────────────────────────────
       Build quick reply — null nếu không khớp
    ──────────────────────────────────────────────────────── */
    private String buildQuickReply(String msg, User me) {
        String normalized = msg.trim().toLowerCase();
        String lang       = detectLang(msg);

        for (QuickRule rule : QUICK_RULES) {
            if (!rule.pattern.matcher(normalized).find()) continue;
            if (rule.langAndReplies == null) return buildDynamicReply(normalized, lang);
            String reply = pickReply(rule.langAndReplies, lang);
            return reply != null ? reply.replace("{name}", me.getFullName()) : null;
        }
        return null;
    }

    /* ────────────────────────────────────────────────────────
       Dynamic replies: time / date
    ──────────────────────────────────────────────────────── */
    private String buildDynamicReply(String normalized, String lang) {
        ZoneId vnZone = ZoneId.of("Asia/Ho_Chi_Minh");
        boolean isTime = normalized.contains("giờ") || normalized.contains("time");
        boolean isDate = normalized.contains("ngày") || normalized.contains("date")
                      || normalized.contains("thứ")  || normalized.contains("day")
                      || normalized.contains("hôm nay");

        if (isTime) {
            String time = LocalTime.now(vnZone).format(DateTimeFormatter.ofPattern("HH:mm"));
            return "en".equals(lang)
                ? "It's currently **" + time + "** (Vietnam time 🇻🇳) 🕐"
                : "Bây giờ là **" + time + "** (giờ Việt Nam) 🕐";
        }
        if (isDate) {
            LocalDate today  = LocalDate.now(vnZone);
            String    dateStr = today.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
            if ("en".equals(lang)) {
                String dow = today.getDayOfWeek().name();
                return "Today is **" + dow.charAt(0) + dow.substring(1).toLowerCase()
                       + ", " + dateStr + "** 📅";
            } else {
                String[] thuVN = {"", "Chủ Nhật", "Thứ Hai", "Thứ Ba",
                                  "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"};
                int dow = today.getDayOfWeek().getValue() % 7 + 1;
                return "Hôm nay là **" + thuVN[dow] + ", ngày " + dateStr + "** 📅";
            }
        }
        return null;
    }

    /* ═══════════════════════════════════════════
       GET — load history
    ═══════════════════════════════════════════ */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User me = getUser(req, resp); if (me == null) return;

        if ("clear".equals(req.getParameter("action"))) {
            resp.getWriter().write("{\"ok\":true}"); return;
        }
        try {
            List<AIChatMessage> list = dao.getHistory(me.getId(), HISTORY_LIMIT);
            ArrayNode arr = mapper.createArrayNode();
            for (AIChatMessage m : list) {
                ObjectNode n = mapper.createObjectNode();
                n.put("role", m.getRole()); n.put("content", m.getContent()); arr.add(n);
            }
            ObjectNode out = mapper.createObjectNode(); out.set("history", arr);
            resp.getWriter().write(out.toString());
        } catch (Exception e) { resp.getWriter().write("{\"history\":[]}"); }
    }

    /* ═══════════════════════════════════════════
       POST — send message / clear
    ═══════════════════════════════════════════ */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User me = getUser(req, resp); if (me == null) return;

        if ("clear".equals(req.getParameter("action"))) {
            try { dao.clearHistory(me.getId()); } catch (Exception ignored) {}
            resp.getWriter().write("{\"ok\":true}"); return;
        }

        JsonNode body;
        try { body = mapper.readTree(req.getReader()); }
        catch (Exception e) { jsonError(resp, "Invalid request body"); return; }

        String userMessage = body.has("message") ? body.get("message").asText("").trim() : "";
        if (userMessage.isEmpty()) { jsonError(resp, "Empty message"); return; }

        // ── Quick reply — no API call ──────────────────────────
        String quickReply = buildQuickReply(userMessage, me);
        if (quickReply != null) {
            try { dao.save(me.getId(), "user", userMessage); dao.save(me.getId(), "assistant", quickReply); }
            catch (Exception ignored) {}
            ObjectNode out = mapper.createObjectNode(); out.put("reply", quickReply);
            resp.getWriter().write(out.toString()); return;
        }

        // ── Call Gemini ────────────────────────────────────────
        List<Map<String, String>> messages = new ArrayList<>();
        try {
            for (AIChatMessage m : dao.getHistory(me.getId(), HISTORY_LIMIT - 1)) {
                Map<String, String> msg = new LinkedHashMap<>();
                msg.put("role", m.getRole()); msg.put("content", m.getContent()); messages.add(msg);
            }
        } catch (Exception ignored) {}
        Map<String, String> userMsg = new LinkedHashMap<>();
        userMsg.put("role", "user"); userMsg.put("content", userMessage); messages.add(userMsg);

        String reply;
        try { reply = callGeminiAPI(AppConfig.getGeminiApiKey(), buildSystemPrompt(me), messages); }
        catch (Exception e) { getServletContext().log("Gemini error", e); jsonError(resp, "API call failed"); return; }

        try { dao.save(me.getId(), "user", userMessage); dao.save(me.getId(), "assistant", reply); }
        catch (Exception ignored) {}

        ObjectNode out = mapper.createObjectNode(); out.put("reply", reply);
        resp.getWriter().write(out.toString());
    }

    /* ═══════════════════════════════════════════
       GEMINI API CALL
    ═══════════════════════════════════════════ */
    private String callGeminiAPI(String apiKey, String systemPrompt,
                                  List<Map<String, String>> messages) throws Exception {
        ObjectNode req = mapper.createObjectNode();

        ObjectNode sys = mapper.createObjectNode();
        ArrayNode  sp  = mapper.createArrayNode(); ObjectNode spp = mapper.createObjectNode();
        spp.put("text", systemPrompt); sp.add(spp); sys.set("parts", sp);
        req.set("system_instruction", sys);

        ArrayNode contents = mapper.createArrayNode();
        for (Map<String, String> m : messages) {
            ObjectNode t = mapper.createObjectNode();
            t.put("role", "assistant".equals(m.get("role")) ? "model" : "user");
            ArrayNode ps = mapper.createArrayNode(); ObjectNode p = mapper.createObjectNode();
            p.put("text", m.get("content")); ps.add(p); t.set("parts", ps); contents.add(t);
        }
        req.set("contents", contents);

        ObjectNode gc = mapper.createObjectNode();
        gc.put("maxOutputTokens", 1024); gc.put("temperature", 0.7);
        req.set("generationConfig", gc);

        HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(15)).build();
        HttpRequest httpReq = HttpRequest.newBuilder()
                .uri(URI.create(GEMINI_API_URL + "?key=" + apiKey))
                .timeout(Duration.ofSeconds(30))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(req)))
                .build();

        HttpResponse<String> resp = client.send(httpReq, HttpResponse.BodyHandlers.ofString());
        if (resp.statusCode() != 200)
            throw new Exception("Gemini API status " + resp.statusCode() + ": " + resp.body());

        JsonNode text = mapper.readTree(resp.body())
                .path("candidates").path(0).path("content").path("parts").path(0).path("text");
        if (!text.isMissingNode()) return text.asText("");
        throw new Exception("Unexpected Gemini response: " + resp.body());
    }

    /* ═══════════════════════════════════════════
       SYSTEM PROMPT
    ═══════════════════════════════════════════ */
    private String buildSystemPrompt(User me) {
        return "Bạn là trợ lý AI thông minh của hệ thống DRSMS (Device Repair & Service Management System).\n"
            + "Bạn đang hỗ trợ khách hàng tên: " + me.getFullName() + " (username: " + me.getUsername() + ").\n\n"
            + "## Về DRSMS:\n"
            + "Hệ thống quản lý dịch vụ sửa chữa và bảo trì thiết bị công nghiệp.\n"
            + "Khách hàng có thể: xem thiết bị, tạo Repair Request, xem hợp đồng WARRANTY/MAINTENANCE,\n"
            + "mua Parts/Equipment qua Shop, xem và thanh toán Invoice (CASH hoặc VNPAY), chat Customer Support.\n\n"
            + "## Trạng thái Repair Request: PENDING → APPROVED → IN_PROGRESS → COMPLETED | REJECTED | CANCELLED\n"
            + "## Priority: LOW → MEDIUM → HIGH → URGENT\n"
            + "## Contract: WARRANTY (miễn phí sửa trong hạn) | MAINTENANCE (bảo trì định kỳ, có phí)\n\n"
            + "## Hướng dẫn:\n"
            + "1. Trả lời tiếng Việt nếu user viết tiếng Việt; tiếng Anh nếu user viết tiếng Anh\n"
            + "2. Thân thiện, ngắn gọn, rõ ràng — dùng emoji phù hợp\n"
            + "3. Câu hỏi hệ thống: hướng dẫn thao tác cụ thể\n"
            + "4. Câu hỏi kỹ thuật/chung: trả lời theo kiến thức thực tế\n"
            + "5. Thao tác phức tạp: hướng liên hệ Customer Support\n"
            + "6. KHÔNG bịa số liệu cụ thể (contract ID, invoice...) vì không có dữ liệu real-time\n";
    }

    /* ═══════════════════════════════════════════
       HELPERS
    ═══════════════════════════════════════════ */
    private User getUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User me = session != null ? (User) session.getAttribute("user") : null;
        if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\":\"Unauthorized\"}"); return null;
        }
        return me;
    }

    private void jsonError(HttpServletResponse resp, String msg) throws IOException {
        ObjectNode err = mapper.createObjectNode(); err.put("error", msg);
        resp.getWriter().write(err.toString());
    }
}