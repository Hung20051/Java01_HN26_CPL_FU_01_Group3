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
            if ("poll".equals(req.getParameter("action"))) {
                int lastId = Integer.parseInt(req.getParameter("lastId"));
                User agent = dao.findSupportAgent();
                resp.setContentType("application/json;charset=UTF-8");
                resp.setCharacterEncoding("UTF-8");
                if (agent == null) { resp.getWriter().write("[]"); return; }
                List<ChatMessage> msgs = dao.getNewMessages(cid, agent.getId(), lastId);
                dao.markRead(agent.getId(), cid);
                resp.getWriter().write(toJson(msgs, cid));
                return;
            }
            User agent = dao.findSupportAgent();
            List<ChatMessage> msgs = agent != null
                    ? dao.getConversation(cid, agent.getId())
                    : new ArrayList<>();
            if (agent != null) dao.markRead(agent.getId(), cid);
            int lastId = msgs.isEmpty() ? 0 : msgs.get(msgs.size() - 1).getId();
            req.setAttribute("agent", agent);
            req.setAttribute("messages", msgs);
            req.setAttribute("lastId", lastId);
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
            String msg = req.getParameter("message");
            if (msg == null || msg.trim().isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"error\":\"empty\"}");
                return;
            }
            User agent = dao.findSupportAgent();
            if (agent == null) {
                resp.getWriter().write("{\"success\":false,\"error\":\"no_agent\"}");
                return;
            }
            int msgId = dao.send(cid, agent.getId(), msg.trim());
            if (msgId < 0) {
                resp.getWriter().write("{\"success\":false,\"error\":\"db_error\"}");
                return;
            }
            // Dùng jsonString() để escape an toàn
            resp.getWriter().write(
                "{\"success\":true,\"id\":" + msgId
                + ",\"senderName\":" + jsonString(me.getFullName()) + "}"
            );
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"error\":\"exception\"}");
        }
    }

    /**
     * Escape JSON string an toàn - xử lý được tiếng Việt, ký tự đặc biệt, emoji.
     */
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
            if (i > 0) sb.append(",");
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
}