<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    User agent=(User)request.getAttribute("agent");
    List<ChatMessage> msgs=(List<ChatMessage>)request.getAttribute("messages"); if(msgs==null)msgs=new ArrayList<>();
    int lastId=request.getAttribute("lastId")!=null?(Integer)request.getAttribute("lastId"):0;
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
%>
%>
<!DOCTYPE html><html lang="vi"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Chat Hỗ Trợ - CRM</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            :root{
                --primary:#4f46e5;
                --sidebar:#0f172a;
                --bg:#f8fafc;
                --surface:#fff;
                --border:#e2e8f0;
                --text:#0f172a;
                --muted:#64748b;
                --success:#10b981
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
                min-height:100vh
            }
            .sb{
                width:240px;
                min-height:100vh;
                background:var(--sidebar);
                display:flex;
                flex-direction:column;
                position:fixed
            }
            .sb-brand{
                padding:22px 18px 18px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid rgba(255,255,255,.07)
            }
            .sb-logo{
                width:34px;
                height:34px;
                background:var(--primary);
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem
            }
            .sb-name{
                color:#fff;
                font-size:1rem;
                font-weight:700
            }
            .sb-sub{
                color:rgba(255,255,255,.35);
                font-size:.68rem
            }
            .sb-nav{
                flex:1;
                padding:14px 10px
            }
            .sb-lbl{
                color:rgba(255,255,255,.28);
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.2px;
                padding:0 8px;
                margin:14px 0 5px
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:8px;
                margin-bottom:2px;
                color:rgba(255,255,255,.58);
                text-decoration:none;
                font-size:.855rem;
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
                width:17px;
                text-align:center;
                font-size:.83rem
            }
            .sb-foot{
                padding:14px 10px 18px;
                border-top:1px solid rgba(255,255,255,.07)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:9px;
                background:rgba(255,255,255,.05);
                margin-bottom:7px
            }
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                font-weight:700
            }
            .sb-uname{
                color:#fff;
                font-size:.82rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,.38);
                font-size:.7rem
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:8px 10px;
                border-radius:8px;
                color:rgba(255,255,255,.45);
                text-decoration:none;
                font-size:.82rem;
                transition:.15s
            }
            .sb-logout:hover{
                color:#f87171;
                background:rgba(248,113,113,.1)
            }
            .main{
                margin-left:240px;
                flex:1;
                display:flex;
                flex-direction:column;
                height:100vh;
                overflow:hidden
            }
            .chat-hd{
                background:var(--surface);
                border-bottom:1px solid var(--border);
                padding:0 22px;
                height:62px;
                display:flex;
                align-items:center;
                gap:13px;
                flex-shrink:0
            }
            .chat-ava{
                width:40px;
                height:40px;
                border-radius:50%;
                background:linear-gradient(135deg,#10b981,#059669);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.95rem;
                font-weight:700;
                flex-shrink:0;
                position:relative
            }
            .online-dot{
                position:absolute;
                bottom:1px;
                right:1px;
                width:10px;
                height:10px;
                background:#10b981;
                border-radius:50%;
                border:2px solid var(--surface)
            }
            .chat-hd-info{
                flex:1
            }
            .chat-hd-name{
                font-size:.93rem;
                font-weight:700;
                color:var(--text)
            }
            .chat-hd-status{
                font-size:.73rem;
                color:#10b981;
                font-weight:500
            }
            .chat-msgs{
                flex:1;
                overflow-y:auto;
                padding:18px 22px;
                background:linear-gradient(180deg,#f8fafc,#f1f5f9);
                display:flex;
                flex-direction:column;
                gap:7px
            }
            .date-sep{
                text-align:center;
                margin:8px 0
            }
            .date-sep span{
                background:#e2e8f0;
                color:var(--muted);
                font-size:.7rem;
                padding:3px 11px;
                border-radius:20px;
                font-weight:500
            }
            .msg-row{
                display:flex;
                align-items:flex-end;
                gap:7px;
                max-width:70%
            }
            .msg-row.mine{
                margin-left:auto;
                flex-direction:row-reverse
            }
            .msg-row.other{
                margin-right:auto
            }
            .msg-ava{
                width:30px;
                height:30px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.78rem;
                font-weight:700;
                color:#fff;
                flex-shrink:0
            }
            .msg-ava.support{
                background:linear-gradient(135deg,#10b981,#059669)
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
                font-size:.7rem;
                color:var(--muted);
                font-weight:600;
                margin-bottom:1px
            }
            .msg-bubble{
                padding:9px 13px;
                border-radius:17px;
                font-size:.875rem;
                line-height:1.5;
                word-wrap:break-word;
                max-width:380px
            }
            .msg-row.mine .msg-bubble{
                background:var(--primary);
                color:#fff;
                border-bottom-right-radius:3px
            }
            .msg-row.other .msg-bubble{
                background:#fff;
                color:var(--text);
                box-shadow:0 1px 3px rgba(0,0,0,.07);
                border-bottom-left-radius:3px
            }
            .msg-time{
                font-size:.66rem;
                color:var(--muted);
                padding:0 2px
            }
            .msg-sending{
                opacity:.6
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
                padding:9px 14px;
                border-radius:17px;
                border-bottom-left-radius:3px;
                box-shadow:0 1px 3px rgba(0,0,0,.07);
                display:flex;
                align-items:center;
                gap:3px
            }
            .t-dot{
                width:6px;
                height:6px;
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
                padding:14px 22px;
                flex-shrink:0
            }
            .input-row{
                display:flex;
                gap:9px;
                align-items:flex-end
            }
            .input-wrap{
                flex:1;
                background:var(--bg);
                border:1.5px solid var(--border);
                border-radius:22px;
                padding:9px 16px;
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
                font-size:.88rem;
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
                width:44px;
                height:44px;
                border-radius:50%;
                border:none;
                background:var(--primary);
                color:#fff;
                cursor:pointer;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.95rem;
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
                font-size:.7rem;
                color:var(--muted);
                margin-top:6px
            }
            .chat-msgs::-webkit-scrollbar{
                width:4px
            }
            .chat-msgs::-webkit-scrollbar-thumb{
                background:#cbd5e1;
                border-radius:10px
            }
            .no-agent{
                flex:1;
                display:flex;
                align-items:center;
                justify-content:center;
                flex-direction:column;
                gap:10px;
                color:var(--muted)
            }
            .sb-badge{
                background:#ef4444;
                color:#fff;
                font-size:.62rem;
                font-weight:700;
                padding:1px 6px;
                border-radius:10px;
                margin-left:auto
            }
        </style>
    </head><body>
        <aside class="sb">
            <div class="sb-brand"><div class="sb-logo"><i class="fas fa-bolt"></i></div><div><div class="sb-name">CRM System</div><div class="sb-sub">Khách hàng</div></div></div>
            <nav class="sb-nav">
                <div class="sb-lbl">Tổng quan</div>
                <a href="<%=ctx%>/customerDashboard"       class="sb-item"><i class="fas fa-home"></i> Trang chủ</a>
                <div class="sb-lbl">Dịch vụ</div>
                <a href="<%=ctx%>/customerServiceRequests" class="sb-item"><i class="fas fa-clipboard-list"></i> Yêu cầu sửa chữa</a>
                <a href="<%=ctx%>/customerContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Hợp đồng</a>
                <a href="<%=ctx%>/customerEquipment"       class="sb-item"><i class="fas fa-desktop"></i> Thiết bị của tôi</a>
                <div class="sb-lbl">Mua hàng</div>
                <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item"><i class="fas fa-puzzle-piece"></i> Linh kiện</a>
                <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Thiết bị</a>
                <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item"><i class="fas fa-shopping-cart"></i> Giỏ hàng<%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%></a>
                <div class="sb-lbl">Tài chính</div>
                <a href="<%=ctx%>/customerInvoices"        class="sb-item"><i class="fas fa-receipt"></i> Hóa đơn</a>
                <div class="sb-lbl">Hỗ trợ</div>
                <a href="<%=ctx%>/customerChat"            class="sb-item on"><i class="fas fa-comment-dots"></i> Chat hỗ trợ</a>
            </nav>
            <div class="sb-foot">
                <div class="sb-user">
                    <div class="sb-ava"><%=me.getFullName().substring(0,1).toUpperCase()%></div>
                    <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Khách hàng</div></div>
                </div>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
            </div>
        </aside>

        <main class="main">
            <%if(agent==null){%>
            <div class="chat-hd">
                <div class="chat-hd-info">
                    <div class="chat-hd-name">Chat Hỗ Trợ</div>
                    <div class="chat-hd-status" style="color:var(--muted)">Không khả dụng</div>
                </div>
            </div>
            <div class="no-agent">
                <i class="fas fa-headset" style="font-size:2.5rem;opacity:.2"></i>
                <p style="font-weight:600">Hiện chưa có nhân viên hỗ trợ</p>
                <span style="font-size:.83rem">Vui lòng thử lại sau</span>
            </div>
            <%}else{%>
            <div class="chat-hd">
                <div class="chat-ava"><%=agent.getFullName().substring(0,1).toUpperCase()%><span class="online-dot"></span></div>
                <div class="chat-hd-info">
                    <div class="chat-hd-name"><%=agent.getFullName()%></div>
                    <div class="chat-hd-status"><i class="fas fa-circle" style="font-size:.45rem"></i> Đang trực tuyến · Nhân viên hỗ trợ</div>
                </div>
            </div>

            <div class="chat-msgs" id="chatMsgs">
                <%if(msgs.isEmpty()){%>
                <div id="emptyChat" style="text-align:center;margin:auto;color:var(--muted)">
                    <div style="font-size:2.8rem;margin-bottom:10px">💬</div>
                    <p style="font-weight:600;font-size:.88rem">Bắt đầu cuộc trò chuyện</p>
                    <span style="font-size:.78rem">Gửi tin nhắn để được hỗ trợ</span>
                </div>
                <%}else{
                  String prevDate="";
                  for(ChatMessage m:msgs){
                    boolean mine=m.getSenderId()==me.getId();
                    String dateStr=m.getCreatedAt()!=null?m.getCreatedAt().toLocalDate().toString():"";
                    if(!dateStr.equals(prevDate)){prevDate=dateStr;%>
                <div class="date-sep"><span><%=dateStr%></span></div>
                        <%}%>
                <div class="msg-row <%=mine?"mine":"other"%>" data-id="<%=m.getId()%>">
                    <div class="msg-ava <%=mine?"me":"support"%>"><%=(m.getSenderName()!=null?m.getSenderName():"?").substring(0,1).toUpperCase()%></div>
                    <div class="msg-content">
                        <%if(!mine){%><div class="msg-name"><%=m.getSenderName()%></div><%}%>
                        <div class="msg-bubble"><%=m.getMessage().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>")%></div>
                        <div class="msg-time"><%=m.getTimeFormatted()%></div>
                    </div>
                </div>
                <%}}%>
                <div class="msg-row other typing" id="typing">
                    <div class="msg-ava support"><%=agent.getFullName().substring(0,1).toUpperCase()%></div>
                    <div class="msg-content">
                        <div class="typing-bubble"><div class="t-dot"></div><div class="t-dot"></div><div class="t-dot"></div></div>
                    </div>
                </div>
            </div>

            <div class="chat-input-area">
                <div class="input-row">
                    <div class="input-wrap">
                        <textarea class="chat-input" id="msgInput" placeholder="Nhập tin nhắn..."
                                  rows="1" onkeydown="handleKey(event)" oninput="autoResize(this)" maxlength="2000"></textarea>
                    </div>
                    <button class="btn-send" id="sendBtn" onclick="sendMsg()" title="Gửi (Enter)">
                        <i class="fas fa-paper-plane"></i>
                    </button>
                </div>
                <div class="input-hint"><strong>Enter</strong> để gửi · <strong>Shift+Enter</strong> để xuống dòng</div>
            </div>
            <%}%>
        </main>

        <script>
            const CTX = '<%=ctx%>';
            const MY_ID = <%=me.getId()%>;
            const MY_NAME = <%-- JSON-safe name --%>
            '<%=me.getFullName().replace("\\","\\\\").replace("'","\\'")%>';

// lastId: ID của tin nhắn cuối cùng đã render từ server
            let lastId = <%=lastId%>;
            let pollTimer = null;

// Set theo dõi các message ID đã render (tránh duplicate)
            const renderedIds = new Set();
            document.querySelectorAll('#chatMsgs .msg-row[data-id]').forEach(el => {
                const n = parseInt(el.dataset.id);
                if (!isNaN(n) && n > 0)
                    renderedIds.add(n);
            });

// ── Utilities ──────────────────────────────────────────────────
            function scrollDown(smooth) {
                const el = document.getElementById('chatMsgs');
                if (!el)
                    return;
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
                return new Date().toLocaleTimeString('vi-VN', {hour: '2-digit', minute: '2-digit'});
            }

// ── Render một tin nhắn vào DOM ────────────────────────────────
            function appendMsg(m) {
                const container = document.getElementById('chatMsgs');
                if (!container)
                    return null;

                // Xóa empty state
                const emp = document.getElementById('emptyChat');
                if (emp)
                    emp.remove();

                const typing = document.getElementById('typing');
                const isMine = (m.senderId === MY_ID || m.mine === true);
                const initLetter = (m.senderName || '?').substring(0, 1).toUpperCase();

                const row = document.createElement('div');
                row.className = 'msg-row ' + (isMine ? 'mine' : 'other');
                if (m.id && String(m.id).indexOf('temp') === -1) {
                    row.dataset.id = m.id;
                }

                const safeText = String(m.message || '')
                        .replace(/&/g, '&amp;')
                        .replace(/</g, '&lt;')
                        .replace(/>/g, '&gt;')
                        .replace(/\n/g, '<br>');

                const nameHtml = !isMine
                        ? '<div class="msg-name">' + (m.senderName || '') + '</div>'
                        : '';

                row.innerHTML =
                        '<div class="msg-ava ' + (isMine ? 'me' : 'support') + '">' + initLetter + '</div>' +
                        '<div class="msg-content">' +
                        nameHtml +
                        '<div class="msg-bubble">' + safeText + '</div>' +
                        '<div class="msg-time">' + (m.time || nowTime()) + '</div>' +
                        '</div>';

                if (typing)
                    container.insertBefore(row, typing);
                else
                    container.appendChild(row);
                return row;
            }

// ── Gửi tin nhắn ──────────────────────────────────────────────
            function sendMsg() {
                const inp = document.getElementById('msgInput');
                const btn = document.getElementById('sendBtn');
                const text = inp.value.trim();
                if (!text)
                    return;

                // Disable UI
                btn.disabled = true;
                inp.disabled = true;

                // Hiển thị ngay (optimistic UI) với class sending
                const tempEl = appendMsg({
                    id: 'temp_' + Date.now(),
                    senderId: MY_ID,
                    senderName: MY_NAME,
                    message: text,
                    time: nowTime(),
                    mine: true
                });
                if (tempEl)
                    tempEl.classList.add('msg-sending');

                inp.value = '';
                inp.style.height = 'auto';
                scrollDown(true);

                // Gửi lên server - dùng URLSearchParams để servlet đọc được
                const params = new URLSearchParams();
                params.append('message', text);

                fetch(CTX + '/customerChat', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                    body: params
                })
                        .then(r => {
                            if (!r.ok)
                                throw new Error('HTTP ' + r.status);
                            return r.json();
                        })
                        .then(d => {
                            if (d.success && d.id) {
                                // Cập nhật element tạm thành element thật
                                if (tempEl) {
                                    tempEl.dataset.id = d.id;
                                    tempEl.classList.remove('msg-sending');
                                    renderedIds.add(d.id);
                                }
                                if (d.id > lastId)
                                    lastId = d.id;
                            } else {
                                // Server trả về lỗi
                                console.error('Send failed:', d);
                                if (tempEl)
                                    tempEl.classList.add('msg-error');
                            }
                        })
                        .catch(err => {
                            console.error('Fetch error:', err);
                            if (tempEl)
                                tempEl.classList.add('msg-error');
                        })
                        .finally(() => {
                            btn.disabled = false;
                            inp.disabled = false;
                            inp.focus();
                        });
            }

// ── Long polling nhận tin nhắn mới ────────────────────────────
            function poll() {
                fetch(CTX + '/customerChat?action=poll&lastId=' + lastId)
                        .then(r => {
                            if (!r.ok)
                                throw new Error('HTTP ' + r.status);
                            return r.json();
                        })
                        .then(newMsgs => {
                            if (!Array.isArray(newMsgs) || newMsgs.length === 0)
                                return;
                            let appended = false;
                            newMsgs.forEach(m => {
                                if (!renderedIds.has(m.id)) {
                                    renderedIds.add(m.id);
                                    if (m.id > lastId)
                                        lastId = m.id;
                                    // Chỉ render tin của agent (tin của mình đã render qua sendMsg)
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

// ── Init ──────────────────────────────────────────────────────
            document.addEventListener('DOMContentLoaded', () => {
                scrollDown(false);
                pollTimer = setInterval(poll, 3000);
                const inp = document.getElementById('msgInput');
                if (inp)
                    inp.focus();
            });
            window.addEventListener('beforeunload', () => clearInterval(pollTimer));
        </script>
    </body></html>
