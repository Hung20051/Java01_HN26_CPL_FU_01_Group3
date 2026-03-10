package controller;

import dao.ChatDAO;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

public class CustomerSupportChatServlet extends HttpServlet {

    private final ChatDAO dao = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        int agentId = me.getId();

        try {
            String action = req.getParameter("action");

            // ── POLL: trả JSON tin nhắn mới ──────────────────────────────
            if ("poll".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                String cidParam = req.getParameter("customerId");
                String lastIdParam = req.getParameter("lastId");
                if (cidParam == null || lastIdParam == null) {
                    resp.getWriter().write("[]");
                    return;
                }
                int customerId = Integer.parseInt(cidParam);
                int lastId = Integer.parseInt(lastIdParam);
                List<ChatMessage> msgs = dao.getNewMessages(agentId, customerId, lastId);
                dao.markRead(customerId, agentId); // đánh dấu đã đọc
                resp.getWriter().write(toJson(msgs, agentId));
                return;
            }

            // ── POLL SIDEBAR: trả JSON danh sách customer + unread ───────
            if ("pollSidebar".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                List<Map<String, Object>> list = dao.getCustomerConversationList(agentId);
                resp.getWriter().write(sidebarToJson(list, agentId));
                return;
            }

            // ── LOAD PAGE ─────────────────────────────────────────────────
            int selectedCustomerId = 0;
            String cidParam = req.getParameter("customerId");
            if (cidParam != null) {
                try {
                    selectedCustomerId = Integer.parseInt(cidParam);
                } catch (Exception ignored) {
                }
            }

            List<Map<String, Object>> conversationList = dao.getCustomerConversationList(agentId);

            // Nếu chưa chọn customer, mặc định chọn người đầu tiên
            if (selectedCustomerId == 0 && !conversationList.isEmpty()) {
                selectedCustomerId = (int) conversationList.get(0).get("customerId");
            }

            List<ChatMessage> messages = new ArrayList<>();
            User selectedCustomer = null;
            int lastId = 0;

            if (selectedCustomerId > 0) {
                selectedCustomer = dao.getUserById(selectedCustomerId);
                messages = dao.getConversation(agentId, selectedCustomerId);
                dao.markRead(selectedCustomerId, agentId);
                lastId = messages.isEmpty() ? 0 : messages.get(messages.size() - 1).getId();
            }

            req.setAttribute("conversationList", conversationList);
            req.setAttribute("selectedCustomer", selectedCustomer);
            req.setAttribute("selectedCustomerId", selectedCustomerId);
            req.setAttribute("messages", messages);
            req.setAttribute("lastId", lastId);
            req.getRequestDispatcher("/supportChat.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/customerDashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
            resp.getWriter().write("{\"success\":false,\"error\":\"unauthorized\"}");
            return;
        }

        try {
            String cidParam = req.getParameter("customerId");
            String msg = req.getParameter("message");
            if (cidParam == null || msg == null || msg.trim().isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"error\":\"invalid\"}");
                return;
            }
            int customerId = Integer.parseInt(cidParam);
            int msgId = dao.send(me.getId(), customerId, msg.trim());
            if (msgId < 0) {
                resp.getWriter().write("{\"success\":false,\"error\":\"db_error\"}");
                return;
            }
            resp.getWriter().write(
                    "{\"success\":true,\"id\":" + msgId
                    + ",\"senderName\":" + jsonString(me.getFullName()) + "}"
            );
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"error\":\"exception\"}");
        }
    }

    private String jsonString(String s) {
        if (s == null) {
            return "null";
        }
        StringBuilder sb = new StringBuilder("\"");
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"':
                    sb.append("\\\"");
                    break;
                case '\\':
                    sb.append("\\\\");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                default:
                    if (c < 0x20) {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.append("\"").toString();
    }

    private String toJson(List<ChatMessage> msgs, int myId) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < msgs.size(); i++) {
            ChatMessage m = msgs.get(i);
            if (i > 0) {
                sb.append(",");
            }
            sb.append("{")
                    .append("\"id\":").append(m.getId()).append(",")
                    .append("\"senderId\":").append(m.getSenderId()).append(",")
                    .append("\"senderName\":").append(jsonString(m.getSenderName())).append(",")
                    .append("\"message\":").append(jsonString(m.getMessage())).append(",")
                    .append("\"time\":").append(jsonString(m.getTimeFormatted())).append(",")
                    .append("\"mine\":").append(m.getSenderId() == myId)
                    .append("}");
        }
        return sb.append("]").toString();
    }

    private String sidebarToJson(List<Map<String, Object>> list, int agentId) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            Map<String, Object> r = list.get(i);
            if (i > 0) {
                sb.append(",");
            }
            String lastMsg = (String) r.get("lastMessage");
            Object lastTime = r.get("lastTime");
            sb.append("{")
                    .append("\"customerId\":").append(r.get("customerId")).append(",")
                    .append("\"customerName\":").append(jsonString((String) r.get("customerName"))).append(",")
                    .append("\"lastMessage\":").append(jsonString(lastMsg != null && lastMsg.length() > 50 ? lastMsg.substring(0, 50) + "…" : lastMsg)).append(",")
                    .append("\"lastTime\":").append(jsonString(lastTime != null ? lastTime.toString().substring(0, 16) : "")).append(",")
                    .append("\"lastSenderId\":").append(r.get("lastSenderId")).append(",")
                    .append("\"unreadCount\":").append(r.get("unreadCount"))
                    .append("}");
        }
        return sb.append("]").toString();
    }
}
