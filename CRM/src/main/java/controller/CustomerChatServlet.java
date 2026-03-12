package controller;

import dao.ChatDAO;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

public class CustomerChatServlet extends HttpServlet {
    private final ChatDAO dao = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null) { resp.sendRedirect(req.getContextPath() + "/login.jsp"); return; }
        int cid = me.getId();

        try {
            String action = req.getParameter("action");

            // ── POLL: tin nhắn MỚI (id > lastId) ──────────────────────
            if ("poll".equals(action)) {
                int lastId = Integer.parseInt(req.getParameter("lastId"));
                User agent = dao.findSupportAgent();
                resp.setContentType("application/json;charset=UTF-8");
                resp.setCharacterEncoding("UTF-8");
                if (agent == null) { resp.getWriter().write("[]"); return; }
                List<ChatMessage> msgs = dao.getNewMessages(cid, agent.getId(), lastId);
                dao.markRead(agent.getId(), cid);
                List<Integer> ids = new ArrayList<>();
                for (ChatMessage m : msgs) ids.add(m.getId());
                Map<Integer, List<Map<String, Object>>> reactionsMap =
                        ids.isEmpty() ? new HashMap<>() : dao.getReactions(ids, cid);
                resp.getWriter().write(toJson(msgs, cid, reactionsMap));
                return;
            }

            // ── POLL UPDATES: sync recall/pin/reactions cho tin đã có ──
            if ("pollUpdates".equals(action)) {
                User agent = dao.findSupportAgent();
                resp.setContentType("application/json;charset=UTF-8");
                resp.setCharacterEncoding("UTF-8");
                if (agent == null) { resp.getWriter().write("[]"); return; }
                List<ChatMessage> allMsgs = dao.getAllMessages(cid, agent.getId());
                List<Integer> ids = new ArrayList<>();
                for (ChatMessage m : allMsgs) ids.add(m.getId());
                Map<Integer, List<Map<String, Object>>> reactionsMap =
                        ids.isEmpty() ? new HashMap<>() : dao.getReactions(ids, cid);
                resp.getWriter().write(toJson(allMsgs, cid, reactionsMap));
                return;
            }

            // ── LOAD PAGE ──────────────────────────────────────────────
            User agent = dao.findSupportAgent();
            List<ChatMessage> msgs = agent != null
                    ? dao.getConversation(cid, agent.getId())
                    : new ArrayList<>();
            if (agent != null) dao.markRead(agent.getId(), cid);
            int lastId = msgs.isEmpty() ? 0 : msgs.get(msgs.size() - 1).getId();

            List<Integer> ids = new ArrayList<>();
            for (ChatMessage m : msgs) ids.add(m.getId());
            Map<Integer, List<Map<String, Object>>> reactionsMap =
                    ids.isEmpty() ? new HashMap<>() : dao.getReactions(ids, cid);

            ChatMessage pinnedMessage = null;
            if (agent != null) {
                pinnedMessage = dao.getPinnedMessage(cid, agent.getId());
            }

            req.setAttribute("agent", agent);
            req.setAttribute("messages", msgs);
            req.setAttribute("lastId", lastId);
            req.setAttribute("reactionsMap", reactionsMap);
            req.setAttribute("pinnedMessage", pinnedMessage);
            req.getRequestDispatcher("/customerChat.jsp").forward(req, resp);
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
        resp.setCharacterEncoding("UTF-8");

        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            resp.getWriter().write("{\"success\":false,\"error\":\"not_logged_in\"}");
            return;
        }
        int cid = me.getId();

        try {
            String action = req.getParameter("action");

            if ("recall".equals(action)) {
                String msgIdParam = req.getParameter("messageId");
                if (msgIdParam == null) { resp.getWriter().write("{\"success\":false,\"error\":\"missing_id\"}"); return; }
                dao.recallMessage(Integer.parseInt(msgIdParam), cid);
                resp.getWriter().write("{\"success\":true}");
                return;
            }

            if ("react".equals(action)) {
                String msgIdParam = req.getParameter("messageId");
                String emoji = req.getParameter("emoji");
                if (msgIdParam == null || emoji == null || emoji.trim().isEmpty()) {
                    resp.getWriter().write("{\"success\":false,\"error\":\"invalid\"}"); return;
                }
                dao.toggleReaction(Integer.parseInt(msgIdParam), cid, emoji.trim());
                resp.getWriter().write("{\"success\":true}");
                return;
            }

            if ("pin".equals(action)) {
                String msgIdParam = req.getParameter("messageId");
                if (msgIdParam == null) { resp.getWriter().write("{\"success\":false,\"error\":\"missing_id\"}"); return; }
                User agent = dao.findSupportAgent();
                if (agent == null) { resp.getWriter().write("{\"success\":false,\"error\":\"no_agent\"}"); return; }
                dao.togglePin(Integer.parseInt(msgIdParam), cid, agent.getId());
                resp.getWriter().write("{\"success\":true}");
                return;
            }

            // ── SEND MESSAGE ──
            String msg = req.getParameter("message");
            if (msg == null || msg.trim().isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"error\":\"empty\"}"); return;
            }
            User agent = dao.findSupportAgent();
            if (agent == null) { resp.getWriter().write("{\"success\":false,\"error\":\"no_agent\"}"); return; }
            int msgId = dao.send(cid, agent.getId(), msg.trim());
            if (msgId < 0) { resp.getWriter().write("{\"success\":false,\"error\":\"db_error\"}"); return; }
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
        if (s == null) return "null";
        StringBuilder sb = new StringBuilder("\"");
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b");  break;
                case '\f': sb.append("\\f");  break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                default:
                    if (c < 0x20) sb.append(String.format("\\u%04x", (int) c));
                    else sb.append(c);
            }
        }
        return sb.append("\"").toString();
    }

    private String reactionsToJson(List<Map<String, Object>> reactions) {
        if (reactions == null || reactions.isEmpty()) return "[]";
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < reactions.size(); i++) {
            Map<String, Object> r = reactions.get(i);
            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"emoji\":").append(jsonString((String) r.get("emoji"))).append(",")
              .append("\"count\":").append(r.get("count")).append(",")
              .append("\"mine\":").append(r.get("mine"))
              .append("}");
        }
        return sb.append("]").toString();
    }

    private String toJson(List<ChatMessage> msgs, int myId,
                          Map<Integer, List<Map<String, Object>>> reactionsMap) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < msgs.size(); i++) {
            ChatMessage m = msgs.get(i);
            if (i > 0) sb.append(",");
            List<Map<String, Object>> reactions = reactionsMap.getOrDefault(m.getId(), new ArrayList<>());
            sb.append("{")
              .append("\"id\":").append(m.getId()).append(",")
              .append("\"senderId\":").append(m.getSenderId()).append(",")
              .append("\"senderName\":").append(jsonString(m.getSenderName())).append(",")
              .append("\"message\":").append(jsonString(m.getMessage())).append(",")
              .append("\"time\":").append(jsonString(m.getTimeFormatted())).append(",")
              .append("\"mine\":").append(m.getSenderId() == myId).append(",")
              .append("\"recalled\":").append(m.isRecalled()).append(",")
              .append("\"pinned\":").append(m.isPinned()).append(",")
              .append("\"reactions\":").append(reactionsToJson(reactions))
              .append("}");
        }
        return sb.append("]").toString();
    }
}