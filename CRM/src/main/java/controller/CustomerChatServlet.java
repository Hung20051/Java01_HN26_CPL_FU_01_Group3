package controller;

import dao.ChatDAO;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize       = 10 * 1024 * 1024,
    maxRequestSize    = 11 * 1024 * 1024
)
public class CustomerChatServlet extends HttpServlet {
    private final ChatDAO dao = new ChatDAO();

    private static final String UPLOAD_DIR = "uploads/chat";
    private static final Set<String> IMAGE_TYPES = Set.of(
        "image/jpeg", "image/png", "image/gif", "image/webp"
    );

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null) { resp.sendRedirect(req.getContextPath() + "/login.jsp"); return; }
        int cid = me.getId();

        try {
            String action = req.getParameter("action");

            // ── HEARTBEAT ──────────────────────────────────────────────
            if ("heartbeat".equals(action)) {
                dao.updatePresence(cid);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"ok\":true}");
                return;
            }

            // ── POLL: tin nhắn MỚI ────────────────────────────────────
            if ("poll".equals(action)) {
                int lastId = Integer.parseInt(req.getParameter("lastId"));
                User agent = dao.findSupportAgent();
                resp.setContentType("application/json;charset=UTF-8");
                if (agent == null) { resp.getWriter().write("[]"); return; }
                dao.markDelivered(agent.getId(), cid);
                dao.markRead(agent.getId(), cid);
                List<ChatMessage> msgs = dao.getNewMessages(cid, agent.getId(), lastId);
                List<Integer> ids = new ArrayList<>();
                for (ChatMessage m : msgs) ids.add(m.getId());
                Map<Integer, List<Map<String, Object>>> reactionsMap =
                        ids.isEmpty() ? new HashMap<>() : dao.getReactions(ids, cid);
                resp.getWriter().write(toJson(msgs, cid, reactionsMap));
                return;
            }

            // ── POLL STATUS: agent online + typing ─────────────────────
            if ("pollStatus".equals(action)) {
                User agent = dao.findSupportAgent();
                resp.setContentType("application/json;charset=UTF-8");
                if (agent == null) {
                    resp.getWriter().write("{\"agentOnline\":false,\"agentTyping\":false}");
                    return;
                }
                boolean agentOnline = dao.isOnline(agent.getId());
                boolean agentTyping = dao.isTyping(agent.getId(), cid);
                resp.getWriter().write(
                    "{\"agentOnline\":" + agentOnline +
                    ",\"agentTyping\":" + agentTyping + "}"
                );
                return;
            }

            // ── POLL UPDATES: sync recall/pin/reactions/status ─────────
            if ("pollUpdates".equals(action)) {
                User agent = dao.findSupportAgent();
                resp.setContentType("application/json;charset=UTF-8");
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
            dao.updatePresence(cid);
            User agent = dao.findSupportAgent();
            List<ChatMessage> msgs = agent != null
                    ? dao.getConversation(cid, agent.getId())
                    : new ArrayList<>();
            if (agent != null) {
                dao.markRead(agent.getId(), cid);
                dao.markDelivered(agent.getId(), cid);
            }
            int lastId = msgs.isEmpty() ? 0 : msgs.get(msgs.size() - 1).getId();

            List<Integer> ids = new ArrayList<>();
            for (ChatMessage m : msgs) ids.add(m.getId());
            Map<Integer, List<Map<String, Object>>> reactionsMap =
                    ids.isEmpty() ? new HashMap<>() : dao.getReactions(ids, cid);

            ChatMessage pinnedMessage = agent != null ? dao.getPinnedMessage(cid, agent.getId()) : null;
            boolean agentOnlineInit = agent != null && dao.isOnline(agent.getId());

            req.setAttribute("agent",         agent);
            req.setAttribute("messages",      msgs);
            req.setAttribute("lastId",        lastId);
            req.setAttribute("reactionsMap",  reactionsMap);
            req.setAttribute("pinnedMessage", pinnedMessage);
            req.setAttribute("agentOnline",   agentOnlineInit);
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

        User me = (User) req.getSession().getAttribute("user");
        if (me == null) {
            resp.getWriter().write("{\"success\":false,\"error\":\"not_logged_in\"}");
            return;
        }
        int cid = me.getId();

        try {
            String action = req.getParameter("action");

            if ("heartbeat".equals(action)) {
                dao.updatePresence(cid);
                resp.getWriter().write("{\"ok\":true}");
                return;
            }

            if ("offline".equals(action)) {
                dao.setOffline(cid);
                resp.getWriter().write("{\"ok\":true}");
                return;
            }

            if ("typing".equals(action)) {
                User agent = dao.findSupportAgent();
                if (agent != null) dao.setTyping(cid, agent.getId());
                resp.getWriter().write("{\"ok\":true}");
                return;
            }

            if ("stopTyping".equals(action)) {
                User agent = dao.findSupportAgent();
                if (agent != null) dao.clearTyping(cid, agent.getId());
                resp.getWriter().write("{\"ok\":true}");
                return;
            }

            if ("recall".equals(action)) {
                String msgIdParam = req.getParameter("messageId");
                if (msgIdParam == null) { resp.getWriter().write("{\"success\":false}"); return; }
                dao.recallMessage(Integer.parseInt(msgIdParam), cid);
                resp.getWriter().write("{\"success\":true}");
                return;
            }

            if ("react".equals(action)) {
                String msgIdParam = req.getParameter("messageId");
                String emoji = req.getParameter("emoji");
                if (msgIdParam == null || emoji == null || emoji.trim().isEmpty()) {
                    resp.getWriter().write("{\"success\":false}"); return;
                }
                dao.toggleReaction(Integer.parseInt(msgIdParam), cid, emoji.trim());
                resp.getWriter().write("{\"success\":true}");
                return;
            }

            if ("pin".equals(action)) {
                String msgIdParam = req.getParameter("messageId");
                if (msgIdParam == null) { resp.getWriter().write("{\"success\":false}"); return; }
                User agent = dao.findSupportAgent();
                if (agent == null) { resp.getWriter().write("{\"success\":false}"); return; }
                dao.togglePin(Integer.parseInt(msgIdParam), cid, agent.getId());
                resp.getWriter().write("{\"success\":true}");
                return;
            }

            if ("upload".equals(action)) {
                Part filePart = req.getPart("file");
                if (filePart == null || filePart.getSize() == 0) {
                    resp.getWriter().write("{\"success\":false,\"error\":\"no_file\"}"); return;
                }
                String contentType  = filePart.getContentType();
                String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String attachType   = IMAGE_TYPES.contains(contentType) ? "IMAGE" : "FILE";

                String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                Files.createDirectories(Paths.get(uploadPath));

                String ext      = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf('.')) : "";
                String saveName = "chat_" + cid + "_" + System.currentTimeMillis() + ext;
                filePart.write(uploadPath + File.separator + saveName);

                String fileUrl = "/" + UPLOAD_DIR + "/" + saveName;
                resp.getWriter().write(
                    "{\"success\":true,\"url\":"  + jsonString(fileUrl) +
                    ",\"name\":"                  + jsonString(originalName) +
                    ",\"type\":"                  + jsonString(attachType) + "}"
                );
                return;
            }

            // ── SEND MESSAGE ───────────────────────────────────────────
            String msg            = req.getParameter("message");
            String attachmentUrl  = req.getParameter("attachmentUrl");
            String attachmentName = req.getParameter("attachmentName");
            String attachmentType = req.getParameter("attachmentType");

            if ((msg == null || msg.trim().isEmpty()) && (attachmentUrl == null || attachmentUrl.isEmpty())) {
                resp.getWriter().write("{\"success\":false,\"error\":\"empty\"}"); return;
            }
            User agent = dao.findSupportAgent();
            if (agent == null) { resp.getWriter().write("{\"success\":false,\"error\":\"no_agent\"}"); return; }

            int msgId;
            if (attachmentUrl != null && !attachmentUrl.isEmpty()) {
                msgId = dao.sendWithAttachment(cid, agent.getId(),
                        msg != null ? msg.trim() : "",
                        attachmentUrl, attachmentName, attachmentType);
            } else {
                msgId = dao.send(cid, agent.getId(), msg.trim());
            }

            dao.clearTyping(cid, agent.getId());

            if (msgId < 0) { resp.getWriter().write("{\"success\":false,\"error\":\"db_error\"}"); return; }
            resp.getWriter().write(
                "{\"success\":true,\"id\":" + msgId +
                ",\"senderName\":" + jsonString(me.getFullName()) + "}"
            );
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"error\":\"exception\"}");
        }
    }

    // ── JSON HELPERS ──────────────────────────────────────────────────────────

    private String jsonString(String s) {
        if (s == null) return "null";
        StringBuilder sb = new StringBuilder("\"");
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
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
              .append("\"read\":").append(m.isRead()).append(",")
              .append("\"delivered\":").append(m.isDelivered()).append(",")
              .append("\"attachmentUrl\":").append(jsonString(m.getAttachmentUrl())).append(",")
              .append("\"attachmentName\":").append(jsonString(m.getAttachmentName())).append(",")
              .append("\"attachmentType\":").append(jsonString(m.getAttachmentType())).append(",")
              .append("\"reactions\":").append(reactionsToJson(reactions))
              .append("}");
        }
        return sb.append("]").toString();
    }
}