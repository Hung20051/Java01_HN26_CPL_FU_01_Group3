<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*,java.time.*,java.time.format.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    List<Map<String, Object>> convList = (List<Map<String, Object>>) request.getAttribute("conversationList");
    if (convList == null) convList = new ArrayList<>();
    User selCustomer = (User) request.getAttribute("selectedCustomer");
    int selCid = request.getAttribute("selectedCustomerId") != null ? (int) request.getAttribute("selectedCustomerId") : 0;
    List<ChatMessage> messages = (List<ChatMessage>) request.getAttribute("messages");
    if (messages == null) messages = new ArrayList<>();
    int lastId = request.getAttribute("lastId") != null ? (int) request.getAttribute("lastId") : 0;

    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("MM/dd");
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Support Chat - DRSMS</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root{
                --primary:#4f46e5;
                --sidebar:#0f172a;
                --bg:#f1f5f9;
                --surface:#fff;
                --border:#e2e8f0;
                --text:#0f172a;
                --muted:#64748b;
                --success:#10b981;
                --danger:#ef4444;
                --chat-sidebar:#fff;
                --chat-sidebar-w:300px;
                --sb-w:220px
            }
            *{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            body{
                font-family:'Inter',sans-serif;
                background:var(--bg);
                display:flex;
                height:100vh;
                overflow:hidden
            }
            .sb{
                width:var(--sb-w);
                height:100vh;
                background:var(--sidebar);
                display:flex;
                flex-direction:column;
                flex-shrink:0
            }
            .sb-brand{
                padding:20px 16px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid rgba(255,255,255,.07)
            }
            .sb-logo{
                width:32px;
                height:32px;
                background:var(--primary);
                border-radius:8px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.85rem
            }
            .sb-name{
                color:#fff;
                font-size:.95rem;
                font-weight:700
            }
            .sb-sub{
                color:rgba(255,255,255,.35);
                font-size:.65rem
            }
            .sb-nav{
                flex:1;
                padding:12px 8px;
                overflow-y:auto
            }
            .sb-lbl{
                color:rgba(255,255,255,.28);
                font-size:.6rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.2px;
                padding:0 8px;
                margin:12px 0 4px
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:8px;
                padding:8px 10px;
                border-radius:7px;
                margin-bottom:2px;
                color:rgba(255,255,255,.55);
                text-decoration:none;
                font-size:.82rem;
                font-weight:500;
                transition:.15s
            }
            .sb-item:hover{
                color:#fff;
                background:rgba(255,255,255,.07)
            }
            .sb-item.on{
                color:#fff;
                background:var(--primary)
            }
            .sb-item i{
                width:16px;
                text-align:center;
                font-size:.8rem
            }
            .sb-foot{
                padding:12px 8px 16px;
                border-top:1px solid rgba(255,255,255,.07)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:8px;
                padding:8px 10px;
                border-radius:8px;
                background:rgba(255,255,255,.05);
                margin-bottom:6px
            }
            .sb-ava{
                width:32px;
                height:32px;
                border-radius:50%;
                background:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.82rem;
                font-weight:700
            }
            .sb-uname{
                color:#fff;
                font-size:.78rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,.38);
                font-size:.67rem
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:7px 10px;
                border-radius:7px;
                color:rgba(255,255,255,.45);
                text-decoration:none;
                font-size:.78rem;
                transition:.15s
            }
            .sb-logout:hover{
                color:#f87171;
                background:rgba(248,113,113,.1)
            }
            .chat-wrap{
                flex:1;
                display:flex;
                min-width:0
            }
            .conv-panel{
                width:var(--chat-sidebar-w);
                background:var(--chat-sidebar);
                border-right:1px solid var(--border);
                display:flex;
                flex-direction:column;
                flex-shrink:0
            }
            .conv-hd{
                padding:14px 14px 10px;
                border-bottom:1px solid var(--border)
            }
            .conv-hd h2{
                font-size:.9rem;
                font-weight:700;
                color:var(--text);
                margin-bottom:10px
            }
            .search-box{
                position:relative
            }
            .search-box input{
                width:100%;
                padding:7px 12px 7px 32px;
                border:1.5px solid var(--border);
                border-radius:20px;
                font-size:.8rem;
                font-family:inherit;
                color:var(--text);
                background:var(--bg);
                outline:none;
                transition:.15s
            }
            .search-box input:focus{
                border-color:var(--primary);
                background:#fff
            }
            .search-box i{
                position:absolute;
                left:11px;
                top:50%;
                transform:translateY(-50%);
                color:var(--muted);
                font-size:.75rem
            }
            .conv-list{
                flex:1;
                overflow-y:auto
            }
            .conv-item{
                display:flex;
                align-items:center;
                gap:10px;
                padding:11px 14px;
                cursor:pointer;
                transition:.12s;
                border-bottom:1px solid #f8fafc;
                position:relative
            }
            .conv-item:hover{
                background:#f8fafc
            }
            .conv-item.active{
                background:#eef2ff
            }
            .conv-item.active .conv-name{
                color:var(--primary)
            }
            .c-ava{
                width:40px;
                height:40px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.9rem;
                font-weight:700;
                color:#fff;
                flex-shrink:0;
                position:relative
            }
            .c-ava-inner{
                width:40px;
                height:40px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.88rem;
                font-weight:700;
                color:#fff
            }
            .unread-badge{
                position:absolute;
                top:-2px;
                right:-2px;
                background:var(--danger);
                color:#fff;
                font-size:.58rem;
                font-weight:700;
                padding:1px 5px;
                border-radius:10px;
                min-width:16px;
                text-align:center;
                border:2px solid var(--chat-sidebar)
            }
            .conv-info{
                flex:1;
                min-width:0
            }
            .conv-name{
                font-size:.82rem;
                font-weight:600;
                color:var(--text);
                white-space:nowrap;
                overflow:hidden;
                text-overflow:ellipsis
            }
            .conv-preview{
                font-size:.74rem;
                color:var(--muted);
                white-space:nowrap;
                overflow:hidden;
                text-overflow:ellipsis;
                margin-top:1px
            }
            .conv-preview.unread{
                color:var(--text);
                font-weight:600
            }
            .conv-time{
                font-size:.68rem;
                color:var(--muted);
                white-space:nowrap;
                margin-left:4px;
                flex-shrink:0
            }
            .conv-list::-webkit-scrollbar{
                width:3px
            }
            .conv-list::-webkit-scrollbar-thumb{
                background:#e2e8f0;
                border-radius:10px
            }
            .chat-area{
                flex:1;
                display:flex;
                flex-direction:column;
                min-width:0;
                background:#f8fafc
            }
            .chat-empty{
                flex:1;
                display:flex;
                align-items:center;
                justify-content:center;
                flex-direction:column;
                gap:12px;
                color:var(--muted)
            }
            .chat-empty i{
                font-size:3rem;
                opacity:.15
            }
            .chat-hd{
                background:var(--surface);
                border-bottom:1px solid var(--border);
                padding:0 20px;
                height:58px;
                display:flex;
                align-items:center;
                gap:12px;
                flex-shrink:0;
                box-shadow:0 1px 3px rgba(0,0,0,.04)
            }
            .chat-hd-ava{
                width:38px;
                height:38px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.88rem;
                font-weight:700;
                color:#fff;
                flex-shrink:0;
                position:relative
            }
            .online-dot{
                position:absolute;
                bottom:1px;
                right:1px;
                width:9px;
                height:9px;
                background:var(--success);
                border-radius:50%;
                border:2px solid var(--surface)
            }
            .chat-hd-name{
                font-size:.9rem;
                font-weight:700;
                color:var(--text)
            }
            .chat-hd-sub{
                font-size:.72rem;
                color:var(--muted)
            }
            .chat-msgs{
                flex:1;
                overflow-y:auto;
                padding:16px 20px;
                display:flex;
                flex-direction:column;
                gap:6px
            }
            .chat-msgs::-webkit-scrollbar{
                width:4px
            }
            .chat-msgs::-webkit-scrollbar-thumb{
                background:#cbd5e1;
                border-radius:10px
            }
            .date-sep{
                text-align:center;
                margin:8px 0
            }
            .date-sep span{
                background:#e2e8f0;
                color:var(--muted);
                font-size:.68rem;
                padding:3px 10px;
                border-radius:20px;
                font-weight:500
            }
            .msg-row{
                display:flex;
                align-items:flex-end;
                gap:7px;
                max-width:68%
            }
            .msg-row.mine{
                margin-left:auto;
                flex-direction:row-reverse
            }
            .msg-row.other{
                margin-right:auto
            }
            .msg-ava{
                width:28px;
                height:28px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.72rem;
                font-weight:700;
                color:#fff;
                flex-shrink:0
            }
            .msg-ava.me{
                background:var(--primary)
            }
            .msg-content{
                display:flex;
                flex-direction:column;
                gap:2px
            }
            .msg-row.mine .msg-content{
                align-items:flex-end
            }
            .msg-row.other .msg-content{
                align-items:flex-start
            }
            .msg-name{
                font-size:.68rem;
                color:var(--muted);
                font-weight:600;
                margin-bottom:1px
            }
            .msg-bubble{
                padding:8px 12px;
                border-radius:16px;
                font-size:.855rem;
                line-height:1.5;
                word-wrap:break-word;
                max-width:340px
            }
            .msg-row.mine .msg-bubble{
                background:var(--primary);
                color:#fff;
                border-bottom-right-radius:3px
            }
            .msg-row.other .msg-bubble{
                background:#fff;
                color:var(--text);
                box-shadow:0 1px 3px rgba(0,0,0,.08);
                border-bottom-left-radius:3px
            }
            .msg-time{
                font-size:.64rem;
                color:var(--muted);
                padding:0 2px
            }
            .msg-sending{
                opacity:.55
            }
            .msg-error .msg-bubble{
                background:#fee2e2 !important;
                color:#991b1b !important
            }
            .typing{
                display:none
            }
            .typing.show{
                display:flex
            }
            .typing-bubble{
                background:#fff;
                padding:8px 13px;
                border-radius:16px;
                border-bottom-left-radius:3px;
                box-shadow:0 1px 3px rgba(0,0,0,.08);
                display:flex;
                align-items:center;
                gap:3px
            }
            .t-dot{
                width:5px;
                height:5px;
                border-radius:50%;
                background:#94a3b8;
                animation:ta 1.4s infinite ease-in-out
            }
            .t-dot:nth-child(2){
                animation-delay:.2s
            }
            .t-dot:nth-child(3){
                animation-delay:.4s
            }
            @keyframes ta{
                0%,60%,100%{
                    transform:translateY(0)
                }
                30%{
                    transform:translateY(-5px)
                }
            }
            .chat-input-area{
                background:var(--surface);
                border-top:1px solid var(--border);
                padding:12px 20px;
                flex-shrink:0
            }
            .input-row{
                display:flex;
                gap:8px;
                align-items:flex-end
            }
            .input-wrap{
                flex:1;
                background:var(--bg);
                border:1.5px solid var(--border);
                border-radius:20px;
                padding:8px 15px;
                display:flex;
                align-items:center;
                transition:.15s
            }
            .input-wrap:focus-within{
                border-color:var(--primary);
                background:#fff
            }
            .chat-input{
                flex:1;
                border:none;
                outline:none;
                background:transparent;
                font-size:.855rem;
                font-family:inherit;
                color:var(--text);
                resize:none;
                max-height:100px;
                line-height:1.4
            }
            .chat-input::placeholder{
                color:#94a3b8
            }
            .btn-send{
                width:42px;
                height:42px;
                border-radius:50%;
                border:none;
                background:var(--primary);
                color:#fff;
                cursor:pointer;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.9rem;
                transition:.15s;
                flex-shrink:0
            }
            .btn-send:hover{
                background:#4338ca;
                transform:scale(1.05)
            }
            .btn-send:disabled{
                background:#c7d2fe;
                cursor:not-allowed;
                transform:none
            }
            .input-hint{
                text-align:center;
                font-size:.68rem;
                color:var(--muted);
                margin-top:5px
            }
            .ava-0{
                background:#4f46e5
            }
            .ava-1{
                background:#0891b2
            }
            .ava-2{
                background:#059669
            }
            .ava-3{
                background:#d97706
            }
            .ava-4{
                background:#dc2626
            }
            .ava-5{
                background:#7c3aed
            }
            .ava-6{
                background:#db2777
            }
            .ava-7{
                background:#0284c7
            }
        </style>
    </head><body>

        <!-- LEFT NAV SIDEBAR -->
        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-bolt"></i></div>
                <div><div class="sb-name">DRSMS System</div><div class="sb-sub">Customer Support</div></div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/supportDashboard"       class="sb-item"><i class="fas fa-home"></i> Dashboard</a>
                <div class="sb-lbl">Management</div>
                <a href="<%=ctx%>/supportCustomers"        class="sb-item"><i class="fas fa-users"></i> Customers</a>
                <a href="<%=ctx%>/supportContracts"        class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/supportServiceRequests"  class="sb-item"><i class="fas fa-clipboard-list"></i> Service Requests</a>
                <div class="sb-lbl">Finance</div>
                <a href="<%=ctx%>/supportInvoices"         class="sb-item"><i class="fas fa-receipt"></i> Invoices</a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/supportChat"             class="sb-item on"><i class="fas fa-comment-dots"></i> Live Chat</a>
            </nav>
            <div class="sb-foot">
                <div class="sb-user">
                    <div class="sb-ava"><%=me.getFullName().substring(0,1).toUpperCase()%></div>
                    <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer Support</div></div>
                </div>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Log out</a>
            </div>
        </aside>

        <!-- CHAT LAYOUT -->
        <div class="chat-wrap">

            <!-- CONVERSATIONS PANEL -->
            <div class="conv-panel">
                <div class="conv-hd">
                    <h2><i class="fas fa-comments" style="color:var(--primary);margin-right:6px"></i>Live Chat</h2>
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Search customers..." oninput="filterConv(this.value)">
                    </div>
                </div>
                <div class="conv-list" id="convList">
                    <%
                    int colorIdx = 0;
                    for (Map<String, Object> conv : convList) {
                        int cid      = (int) conv.get("customerId");
                        String name  = (String) conv.get("customerName");
                        String lastMsg = (String) conv.get("lastMessage");
                        if (lastMsg != null && lastMsg.length() > 45) lastMsg = lastMsg.substring(0, 45) + "…";
                        int unread   = (int) conv.get("unreadCount");
                        int lastSender = (int) conv.get("lastSenderId");
                        Object lastTimeObj = conv.get("lastTime");
                        String lastTime = "";
                        if (lastTimeObj != null) {
                            java.time.LocalDateTime ldt = (java.time.LocalDateTime) lastTimeObj;
                            java.time.LocalDate today = java.time.LocalDate.now();
                            if (ldt.toLocalDate().equals(today)) {
                                lastTime = ldt.format(timeFmt);
                            } else {
                                lastTime = ldt.format(dateFmt);
                            }
                        }
                        boolean active = (cid == selCid);
                        String initLetter = name != null && !name.isEmpty() ? name.substring(0,1).toUpperCase() : "?";
                        String previewPrefix = (lastSender == me.getId()) ? "You: " : "";
                    %>
                    <div class="conv-item <%=active?"active":""%>" onclick="openChat(<%=cid%>)"
                         data-name="<%=name!=null?name.toLowerCase():""%>" data-cid="<%=cid%>" id="conv-<%=cid%>">
                        <div class="c-ava">
                            <div class="c-ava-inner ava-<%=colorIdx%7%>"><%=initLetter%></div>
                            <%if(unread > 0){%><span class="unread-badge" id="badge-<%=cid%>"><%=unread%></span><%}else{%><span class="unread-badge" id="badge-<%=cid%>" style="display:none"></span><%}%>
                        </div>
                        <div class="conv-info">
                            <div class="conv-name"><%=name%></div>
                            <div class="conv-preview <%=unread>0?"unread":""%>" id="preview-<%=cid%>"><%=previewPrefix%><%=lastMsg!=null?lastMsg:""%></div>
                        </div>
                        <div class="conv-time" id="time-<%=cid%>"><%=lastTime%></div>
                    </div>
                    <% colorIdx++; } %>
                    <%if(convList.isEmpty()){%>
                    <div id="noConv" style="padding:30px 14px;text-align:center;color:var(--muted)">
                        <i class="fas fa-inbox" style="font-size:2rem;opacity:.2;display:block;margin-bottom:8px"></i>
                        <p style="font-size:.82rem">No conversations yet</p>
                    </div>
                    <%}%>
                </div>
            </div>

            <!-- CHAT AREA -->
            <div class="chat-area">
                <%if(selCustomer == null){%>
                <div class="chat-empty">
                    <i class="fas fa-comments"></i>
                    <p style="font-weight:700;font-size:.92rem">Select a conversation</p>
                    <span style="font-size:.8rem">Choose a customer on the left to start chatting</span>
                </div>
                <%}else{%>
                <div class="chat-hd">
                    <%
                    String selName = selCustomer.getFullName();
                    String selInit = selName != null && !selName.isEmpty() ? selName.substring(0,1).toUpperCase() : "?";
                    int selColor   = (selCid % 8);
                    %>
                    <div class="chat-hd-ava ava-<%=selColor%>"><%=selInit%><span class="online-dot"></span></div>
                    <div style="flex:1">
                        <div class="chat-hd-name"><%=selName%></div>
                        <div class="chat-hd-sub">
                            <%=selCustomer.getPhone()!=null?selCustomer.getPhone():""%>
                            <%=selCustomer.getEmail()!=null?" · "+selCustomer.getEmail():""%>
                        </div>
                    </div>
                </div>

                <div class="chat-msgs" id="chatMsgs">
                    <%
            if (messages.isEmpty()) { %>
                    <div id="emptyChat" style="text-align:center;margin:auto;color:var(--muted)">
                        <div style="font-size:2.5rem;margin-bottom:8px">💬</div>
                        <p style="font-weight:600;font-size:.85rem">Start a conversation with <%=selName%></p>
                    </div>
                    <%} else {
                        String prevDate = "";
                        for (ChatMessage m : messages) {
                            boolean mine = m.getSenderId() == me.getId();
                            String dateStr = m.getCreatedAt() != null ? m.getCreatedAt().toLocalDate().toString() : "";
                            if (!dateStr.equals(prevDate)) { prevDate = dateStr; %>
                    <div class="date-sep"><span><%=dateStr%></span></div>
                            <%      } %>
                    <div class="msg-row <%=mine?"mine":"other"%>" data-id="<%=m.getId()%>">
                        <div class="msg-ava <%=mine?"me":"ava-"+(selCid%8)%>">
                            <%=(mine?me.getFullName():selName).substring(0,1).toUpperCase()%>
                        </div>
                        <div class="msg-content">
                            <%if(!mine){%><div class="msg-name"><%=selName%></div><%}%>
                            <div class="msg-bubble"><%=m.getMessage().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>")%></div>
                            <div class="msg-time"><%=m.getTimeFormatted()%></div>
                        </div>
                    </div>
                    <%  }
            }%>
                    <div class="msg-row other typing" id="typing">
                        <div class="msg-ava ava-<%=selColor%>"><%=selInit%></div>
                        <div class="msg-content">
                            <div class="typing-bubble"><div class="t-dot"></div><div class="t-dot"></div><div class="t-dot"></div></div>
                        </div>
                    </div>
                </div>

                <div class="chat-input-area">
                    <div class="input-row">
                        <div class="input-wrap">
                            <textarea class="chat-input" id="msgInput" placeholder="Message <%=selName%>..."
                                      rows="1" onkeydown="handleKey(event)" oninput="autoResize(this)" maxlength="2000"></textarea>
                        </div>
                        <button class="btn-send" id="sendBtn" onclick="sendMsg()" title="Send (Enter)">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </div>
                    <div class="input-hint"><strong>Enter</strong> to send &nbsp;&middot;&nbsp; <strong>Shift+Enter</strong> for new line</div>
                </div>
                <%}%>
            </div>
        </div>

        <script>
            const CTX = '<%=ctx%>';
            const MY_ID = <%=me.getId()%>;
            const MY_NAME = '<%=me.getFullName().replace("\\","\\\\").replace("'","\\'")%>';
            const SEL_CID = <%=selCid%>;
            const SEL_NAME = '<%=selCustomer!=null?selCustomer.getFullName().replace("\\","\\\\").replace("'","\\'"):""%>';
            const SEL_COLOR = <%=selCid%8%>;
            let lastId = <%=lastId%>;
            let pollTimer = null;
            let sidebarTimer = null;
            const renderedIds = new Set();

            document.querySelectorAll('#chatMsgs .msg-row[data-id]').forEach(el => {
                const n = parseInt(el.dataset.id);
                if (!isNaN(n) && n > 0)
                    renderedIds.add(n);
            });

            function scrollDown(smooth) {
                const el = document.getElementById('chatMsgs');
                if (el)
                    el.scrollTo({top: el.scrollHeight, behavior: smooth ? 'smooth' : 'instant'});
            }
            function autoResize(el) {
                el.style.height = 'auto';
                el.style.height = Math.min(el.scrollHeight, 100) + 'px';
            }
            function handleKey(e) {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    sendMsg();
                }
            }
            function nowTime() {
                return new Date().toLocaleTimeString('en-US', {hour: '2-digit', minute: '2-digit', hour12: false});
            }
            function openChat(cid) {
                window.location.href = CTX + '/supportChat?customerId=' + cid;
            }
            function filterConv(q) {
                q = q.toLowerCase().trim();
                document.querySelectorAll('#convList .conv-item').forEach(el => {
                    const name = el.dataset.name || '';
                    el.style.display = (!q || name.includes(q)) ? '' : 'none';
                });
            }
            function appendMsg(m) {
                const container = document.getElementById('chatMsgs');
                if (!container)
                    return null;
                const emp = document.getElementById('emptyChat');
                if (emp)
                    emp.remove();
                const typing = document.getElementById('typing');
                const isMine = (m.senderId === MY_ID || m.mine === true);
                const initLetter = (isMine ? MY_NAME : SEL_NAME).substring(0, 1).toUpperCase();
                const row = document.createElement('div');
                row.className = 'msg-row ' + (isMine ? 'mine' : 'other');
                if (m.id && String(m.id).indexOf('temp') === -1)
                    row.dataset.id = m.id;
                const safeText = String(m.message || '')
                        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\n/g, '<br>');
                const nameHtml = !isMine ? '<div class="msg-name">' + SEL_NAME + '</div>' : '';
                row.innerHTML =
                        '<div class="msg-ava ' + (isMine ? 'me' : 'ava-' + SEL_COLOR) + '">' + initLetter + '</div>' +
                        '<div class="msg-content">' + nameHtml +
                        '<div class="msg-bubble">' + safeText + '</div>' +
                        '<div class="msg-time">' + (m.time || nowTime()) + '</div>' +
                        '</div>';
                if (typing)
                    container.insertBefore(row, typing);
                else
                    container.appendChild(row);
                return row;
            }
            function sendMsg() {
                if (SEL_CID === 0)
                    return;
                const inp = document.getElementById('msgInput');
                const btn = document.getElementById('sendBtn');
                const text = inp.value.trim();
                if (!text)
                    return;
                btn.disabled = true;
                inp.disabled = true;
                const tempEl = appendMsg({id: 'temp_' + Date.now(), senderId: MY_ID, senderName: MY_NAME, message: text, time: nowTime(), mine: true});
                if (tempEl)
                    tempEl.classList.add('msg-sending');
                inp.value = '';
                inp.style.height = 'auto';
                scrollDown(true);
                const params = new URLSearchParams();
                params.append('customerId', SEL_CID);
                params.append('message', text);
                fetch(CTX + '/supportChat', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                    body: params
                })
                        .then(r => r.json())
                        .then(d => {
                            if (d.success && d.id) {
                                if (tempEl) {
                                    tempEl.dataset.id = d.id;
                                    tempEl.classList.remove('msg-sending');
                                    renderedIds.add(d.id);
                                }
                                if (d.id > lastId)
                                    lastId = d.id;
                            } else {
                                if (tempEl)
                                    tempEl.classList.add('msg-error');
                            }
                        })
                        .catch(() => {
                            if (tempEl)
                                tempEl.classList.add('msg-error');
                        })
                        .finally(() => {
                            btn.disabled = false;
                            inp.disabled = false;
                            inp.focus();
                        });
            }
            function poll() {
                if (SEL_CID === 0)
                    return;
                fetch(CTX + '/supportChat?action=poll&customerId=' + SEL_CID + '&lastId=' + lastId)
                        .then(r => r.json())
                        .then(newMsgs => {
                            if (!Array.isArray(newMsgs) || newMsgs.length === 0)
                                return;
                            let appended = false;
                            newMsgs.forEach(m => {
                                if (!renderedIds.has(m.id)) {
                                    renderedIds.add(m.id);
                                    if (m.id > lastId)
                                        lastId = m.id;
                                    if (m.senderId !== MY_ID) {
                                        appendMsg(m);
                                        appended = true;
                                    }
                                }
                            });
                            if (appended)
                                scrollDown(true);
                        })
                        .catch(err => console.warn('Poll error:', err));
            }
            function pollSidebar() {
                fetch(CTX + '/supportChat?action=pollSidebar')
                        .then(r => r.json())
                        .then(list => {
                            if (!Array.isArray(list))
                                return;
                            list.forEach(item => {
                                const badge = document.getElementById('badge-' + item.customerId);
                                const preview = document.getElementById('preview-' + item.customerId);
                                const timeel = document.getElementById('time-' + item.customerId);
                                if (badge) {
                                    if (item.unreadCount > 0 && item.customerId !== SEL_CID) {
                                        badge.textContent = item.unreadCount;
                                        badge.style.display = '';
                                    } else {
                                        badge.style.display = 'none';
                                    }
                                }
                                if (preview && item.customerId !== SEL_CID) {
                                    preview.textContent = (item.lastSenderId === MY_ID ? 'You: ' : '') + (item.lastMessage || '');
                                    preview.className = 'conv-preview' + (item.unreadCount > 0 ? ' unread' : '');
                                }
                                if (timeel)
                                    timeel.textContent = item.lastTime ? item.lastTime.substring(11, 16) : '';
                            });
                        })
                        .catch(err => console.warn('Sidebar poll error:', err));
            }
            document.addEventListener('DOMContentLoaded', () => {
                scrollDown(false);
                if (SEL_CID > 0)
                    pollTimer = setInterval(poll, 3000);
                sidebarTimer = setInterval(pollSidebar, 5000);
                const inp = document.getElementById('msgInput');
                if (inp)
                    inp.focus();
            });
            window.addEventListener('beforeunload', () => {
                clearInterval(pollTimer);
                clearInterval(sidebarTimer);
            });
        </script>
    </body></html>
