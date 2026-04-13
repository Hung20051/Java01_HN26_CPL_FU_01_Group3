<%@ page pageEncoding="UTF-8"%>
<style>
    /* ════════════════════ AI BUBBLE ════════════════════ */
    :root {
        --ai-purple:  #a78bfa;
        --ai-blue:    #4f7ef8;
        --ai-glow:    rgba(167,139,250,0.45);
        --ai-bg:      rgba(10,14,40,0.97);
        --ai-border:  rgba(167,139,250,0.2);
    }

    #ai-ball {
        position: fixed;
        width: 58px;
        height: 58px;
        border-radius: 50%;
        background: linear-gradient(135deg, #4f7ef8, #a78bfa, #7c3aed);
        box-shadow: 0 0 0 3px rgba(167,139,250,0.25),
            0 8px 32px rgba(79,126,248,0.5),
            0 0 60px rgba(167,139,250,0.2);
        cursor: grab;
        z-index: 9999;
        display: flex;
        align-items: center;
        justify-content: center;
        user-select: none;
        transition: box-shadow 0.3s, transform 0.2s;
        bottom: 32px;
        right: 32px;
    }
    #ai-ball:active {
        cursor: grabbing;
    }
    #ai-ball:hover {
        box-shadow: 0 0 0 4px rgba(167,139,250,0.4),
            0 12px 40px rgba(79,126,248,0.65),
            0 0 80px rgba(167,139,250,0.35);
        transform: scale(1.08);
    }
    #ai-ball.pulse {
        animation: ballPulse 1.8s ease-in-out infinite;
    }
    @keyframes ballPulse {
        0%,100% {
            box-shadow: 0 0 0 3px rgba(167,139,250,0.25), 0 8px 32px rgba(79,126,248,0.5), 0 0 0 0 rgba(167,139,250,0.4);
        }
        50%      {
            box-shadow: 0 0 0 3px rgba(167,139,250,0.4),  0 8px 32px rgba(79,126,248,0.65), 0 0 0 14px rgba(167,139,250,0);
        }
    }
    #ai-ball svg {
        width: 30px;
        height: 30px;
        pointer-events: none;
    }

    #ai-notif-dot {
        position: absolute;
        top: 2px;
        right: 2px;
        width: 12px;
        height: 12px;
        background: #f87171;
        border-radius: 50%;
        border: 2px solid #0b1437;
        display: none;
        animation: dotBlink 1.2s ease-in-out infinite;
    }
    @keyframes dotBlink {
        0%,100% {
            opacity: 1;
            transform: scale(1);
        }
        50%      {
            opacity: 0.5;
            transform: scale(0.8);
        }
    }

    #ai-teaser {
        position: fixed;
        z-index: 9998;
        background: rgba(15,22,60,0.97);
        border: 1px solid rgba(167,139,250,0.3);
        border-radius: 16px 16px 4px 16px;
        padding: 12px 16px 12px 14px;
        max-width: 230px;
        box-shadow: 0 8px 32px rgba(79,126,248,0.25);
        display: none;
        backdrop-filter: blur(16px);
        animation: teaserIn 0.4s cubic-bezier(.4,0,.2,1) both;
        pointer-events: none;
    }
    #ai-teaser.show {
        display: block;
    }
    @keyframes teaserIn {
        from {
            opacity: 0;
            transform: scale(0.85) translateY(8px);
        }
        to {
            opacity: 1;
            transform: scale(1) translateY(0);
        }
    }
    #ai-teaser.hide {
        animation: teaserOut 0.3s ease forwards;
    }
    @keyframes teaserOut {
        to {
            opacity: 0;
            transform: scale(0.9) translateY(6px);
        }
    }
    .teaser-row {
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .teaser-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: var(--ai-purple);
        flex-shrink: 0;
        box-shadow: 0 0 8px var(--ai-purple);
        animation: ballPulse 1.5s ease infinite;
    }
    .teaser-text {
        font-family: 'Sora', sans-serif;
        font-size: 0.78rem;
        font-weight: 500;
        color: #c8d4f0;
        line-height: 1.45;
    }
    .teaser-text strong {
        color: #fff;
    }

    #ai-chat-window {
        position: fixed;
        z-index: 9998;
        width: 370px;
        height: 520px;
        min-width: 320px;
        min-height: 400px;
        background: var(--ai-bg);
        border: 1px solid var(--ai-border);
        border-radius: 20px;
        display: flex;
        flex-direction: column;
        overflow: hidden;
        box-shadow: 0 24px 64px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.04), inset 0 1px 0 rgba(255,255,255,0.06);
        backdrop-filter: blur(24px);
        bottom: 104px;
        right: 32px;
        transform-origin: bottom right;
        transform: scale(0) translateY(10px);
        opacity: 0;
        pointer-events: none;
        transition: transform 0.35s cubic-bezier(.4,0,.2,1), opacity 0.35s ease;
    }
    #ai-chat-window.open {
        transform: scale(1) translateY(0);
        opacity: 1;
        pointer-events: all;
    }
    #ai-chat-window.resizing {
        transition: transform 0.35s cubic-bezier(.4,0,.2,1), opacity 0.35s ease, width 0.3s ease, height 0.3s ease;
    }

    .ai-chat-hd {
        padding: 14px 16px;
        background: linear-gradient(135deg, rgba(79,126,248,0.15), rgba(167,139,250,0.12));
        border-bottom: 1px solid var(--ai-border);
        display: flex;
        align-items: center;
        gap: 8px;
        flex-shrink: 0;
    }
    .ai-hd-avatar {
        width: 38px;
        height: 38px;
        border-radius: 50%;
        background: linear-gradient(135deg, #4f7ef8, #a78bfa);
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 0 16px rgba(167,139,250,0.4);
        flex-shrink: 0;
    }
    .ai-hd-avatar svg {
        width: 22px;
        height: 22px;
    }
    .ai-hd-info {
        flex: 1;
    }
    .ai-hd-name {
        font-family: 'Sora', sans-serif;
        font-size: 0.88rem;
        font-weight: 700;
        color: #fff;
    }
    .ai-hd-status {
        display: flex;
        align-items: center;
        gap: 5px;
        font-size: 0.68rem;
        color: #6ee7b7;
        margin-top: 2px;
    }
    .ai-hd-status-dot {
        width: 6px;
        height: 6px;
        border-radius: 50%;
        background: #34d399;
        box-shadow: 0 0 6px #34d399;
        animation: dotBlink 2s ease infinite;
    }

    .ai-hd-btn {
        width: 28px;
        height: 28px;
        border-radius: 8px;
        background: rgba(255,255,255,0.06);
        border: 1px solid rgba(255,255,255,0.08);
        color: #7a8ab8;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.72rem;
        transition: all 0.2s;
        flex-shrink: 0;
        position: relative;
    }
    .ai-hd-btn::after {
        content: attr(data-tip);
        position: absolute;
        bottom: -26px;
        left: 50%;
        transform: translateX(-50%);
        background: rgba(0,0,0,0.85);
        color: #ccc;
        font-size: 0.62rem;
        padding: 2px 7px;
        border-radius: 5px;
        white-space: nowrap;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.15s;
        z-index: 10;
    }
    .ai-hd-btn:hover::after {
        opacity: 1;
    }
    #ai-resize-btn:hover {
        background: rgba(167,139,250,0.15);
        color: #a78bfa;
        border-color: rgba(167,139,250,0.4);
    }
    #ai-clear-btn:hover  {
        background: rgba(251,191,36,0.12);
        color: #fbbf24;
        border-color: rgba(251,191,36,0.3);
    }
    #ai-close-btn:hover  {
        background: rgba(248,113,113,0.15);
        color: #f87171;
        border-color: rgba(248,113,113,0.3);
    }

    .ai-messages {
        flex: 1;
        overflow-y: auto;
        padding: 16px 14px;
        display: flex;
        flex-direction: column;
        gap: 12px;
        scroll-behavior: smooth;
    }
    .ai-messages::-webkit-scrollbar {
        width: 3px;
    }
    .ai-messages::-webkit-scrollbar-thumb {
        background: rgba(167,139,250,0.3);
        border-radius: 3px;
    }

    .ai-msg {
        display: flex;
        gap: 8px;
        align-items: flex-end;
        animation: msgIn 0.3s cubic-bezier(.4,0,.2,1) both;
    }
    @keyframes msgIn {
        from {
            opacity: 0;
            transform: translateY(8px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    .ai-msg.user {
        flex-direction: row-reverse;
    }

    /* Bot avatar */
    .ai-msg-ava {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        background: linear-gradient(135deg, #4f7ef8, #a78bfa);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        font-size: 0.75rem;
        box-shadow: 0 0 10px rgba(167,139,250,0.3);
        overflow: hidden;
    }
    .ai-msg-ava svg {
        width: 16px;
        height: 16px;
    }

    /* FIX: user avatar supports img */
    .ai-msg-ava.user-ava {
        background: linear-gradient(135deg, #0f1c4d, #162050);
        border: 1px solid rgba(79,126,248,0.3);
        color: #7c9ffa;
        font-size: 0.72rem;
        font-weight: 700;
    }
    .ai-msg-ava.user-ava img {
        width: 28px;
        height: 28px;
        object-fit: cover;
        border-radius: 50%;
        display: block;
    }

    .ai-msg-bubble {
        max-width: 78%;
        padding: 10px 13px;
        border-radius: 14px;
        font-family: 'Sora', sans-serif;
        font-size: 0.8rem;
        line-height: 1.6;
        position: relative;
    }
    .ai-msg.bot .ai-msg-bubble  {
        background: rgba(167,139,250,0.1);
        border: 1px solid rgba(167,139,250,0.18);
        color: #c8d4f0;
        border-bottom-left-radius: 4px;
    }
    .ai-msg.user .ai-msg-bubble {
        background: linear-gradient(135deg, rgba(79,126,248,0.25), rgba(79,126,248,0.15));
        border: 1px solid rgba(79,126,248,0.3);
        color: #e8f0ff;
        border-bottom-right-radius: 4px;
    }
    .ai-msg-time {
        font-size: 0.62rem;
        color: #4a5a8a;
        margin-top: 4px;
        text-align: right;
    }
    .ai-msg.bot .ai-msg-time {
        text-align: left;
    }

    .ai-typing-dots {
        display: flex;
        gap: 4px;
        background: rgba(167,139,250,0.1);
        border: 1px solid rgba(167,139,250,0.18);
        padding: 10px 14px;
        border-radius: 14px 14px 14px 4px;
    }
    .ai-typing-dots span {
        width: 6px;
        height: 6px;
        border-radius: 50%;
        background: var(--ai-purple);
        opacity: 0.6;
    }
    .ai-typing-dots span:nth-child(1) {
        animation: typeDot 1.2s 0.0s ease-in-out infinite;
    }
    .ai-typing-dots span:nth-child(2) {
        animation: typeDot 1.2s 0.2s ease-in-out infinite;
    }
    .ai-typing-dots span:nth-child(3) {
        animation: typeDot 1.2s 0.4s ease-in-out infinite;
    }
    @keyframes typeDot {
        0%,80%,100% {
            transform: scale(0.7);
            opacity: 0.4;
        }
        40% {
            transform: scale(1.1);
            opacity: 1;
        }
    }

    .thread-divider {
        display: flex;
        align-items: center;
        gap: 8px;
        margin: 4px 0;
    }
    .thread-divider-line {
        flex: 1;
        height: 1px;
        background: rgba(167,139,250,0.15);
    }
    .thread-divider-label {
        font-size: 0.65rem;
        color: #4a5a8a;
        background: rgba(167,139,250,0.08);
        padding: 2px 10px;
        border-radius: 20px;
        border: 1px solid rgba(167,139,250,0.12);
        white-space: nowrap;
    }

    .ai-suggestions {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        padding: 0 14px 10px;
    }
    .ai-sug-btn {
        padding: 5px 11px;
        border-radius: 20px;
        border: 1px solid rgba(167,139,250,0.25);
        background: rgba(167,139,250,0.07);
        color: #a78bfa;
        font-family: 'Sora', sans-serif;
        font-size: 0.72rem;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        white-space: nowrap;
    }
    .ai-sug-btn:hover {
        background: rgba(167,139,248,0.18);
        border-color: rgba(167,139,250,0.5);
        color: #fff;
        transform: translateY(-1px);
    }

    .ai-input-area {
        padding: 12px 14px;
        border-top: 1px solid var(--ai-border);
        display: flex;
        gap: 8px;
        align-items: flex-end;
        background: rgba(255,255,255,0.02);
        flex-shrink: 0;
    }
    #ai-input {
        flex: 1;
        background: rgba(255,255,255,0.05);
        border: 1px solid rgba(255,255,255,0.08);
        border-radius: 12px;
        padding: 10px 13px;
        color: #fff;
        font-family: 'Sora', sans-serif;
        font-size: 0.8rem;
        line-height: 1.4;
        outline: none;
        resize: none;
        max-height: 100px;
        min-height: 40px;
        transition: border-color 0.2s, background 0.2s;
        overflow-y: auto;
    }
    #ai-input::placeholder {
        color: #4a5a8a;
    }
    #ai-input:focus {
        border-color: rgba(167,139,250,0.4);
        background: rgba(167,139,250,0.05);
    }
    #ai-send-btn {
        width: 40px;
        height: 40px;
        border-radius: 11px;
        background: linear-gradient(135deg, var(--ai-blue), var(--ai-purple));
        border: none;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #fff;
        font-size: 0.85rem;
        box-shadow: 0 4px 14px rgba(79,126,248,0.4);
        transition: all 0.2s;
        flex-shrink: 0;
    }
    #ai-send-btn:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 20px rgba(79,126,248,0.6);
    }
    #ai-send-btn:disabled {
        opacity: 0.4;
        cursor: not-allowed;
        transform: none;
    }

    .ai-disclaimer {
        text-align: center;
        font-size: 0.62rem;
        color: #3a4a6a;
        padding: 6px 14px 2px;
    }

    #ai-resize-drag {
        position: absolute;
        bottom: 0;
        right: 0;
        width: 20px;
        height: 20px;
        cursor: se-resize;
        display: flex;
        align-items: flex-end;
        justify-content: flex-end;
        padding: 3px;
        opacity: 0.35;
        transition: opacity 0.2s;
        z-index: 5;
    }
    #ai-resize-drag:hover {
        opacity: 1;
    }
    #ai-resize-drag svg {
        width: 12px;
        height: 12px;
    }
</style>

<%-- ── AI BALL ── --%>
<div id="ai-ball" class="pulse" title="AI Assistant">
    <div id="ai-notif-dot"></div>
    <svg viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect x="6" y="9" width="20" height="16" rx="4" fill="rgba(255,255,255,0.9)"/>
        <line x1="16" y1="9" x2="16" y2="5" stroke="rgba(255,255,255,0.8)" stroke-width="1.5" stroke-linecap="round"/>
        <circle cx="16" cy="4" r="1.8" fill="#a78bfa"/>
        <rect x="10" y="13" width="4" height="4" rx="1.5" fill="#4f7ef8"/>
        <rect x="18" y="13" width="4" height="4" rx="1.5" fill="#4f7ef8"/>
        <rect x="11" y="14" width="1.5" height="1.5" rx="0.5" fill="white" opacity="0.8"/>
        <rect x="19" y="14" width="1.5" height="1.5" rx="0.5" fill="white" opacity="0.8"/>
        <path d="M11 20 Q16 23 21 20" stroke="#4f7ef8" stroke-width="1.5" stroke-linecap="round" fill="none"/>
        <rect x="3" y="14" width="3" height="5" rx="1.5" fill="rgba(255,255,255,0.6)"/>
        <rect x="26" y="14" width="3" height="5" rx="1.5" fill="rgba(255,255,255,0.6)"/>
    </svg>
</div>

<%-- ── TEASER POPUP ── --%>
<div id="ai-teaser">
    <div class="teaser-row">
        <div class="teaser-dot"></div>
        <div class="teaser-text" id="ai-teaser-text">
            <strong>Xin chào! 👋</strong><br>Bạn cần giúp gì thì cứ hỏi tôi nhé!
        </div>
    </div>
</div>

<%-- ── CHAT WINDOW ── --%>
<div id="ai-chat-window">

    <%-- Header — đã XÓA nút Chat mới --%>
    <div class="ai-chat-hd">
        <div class="ai-hd-avatar">
            <svg viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="6" y="9" width="20" height="16" rx="4" fill="rgba(255,255,255,0.9)"/>
                <line x1="16" y1="9" x2="16" y2="5" stroke="rgba(255,255,255,0.8)" stroke-width="1.5" stroke-linecap="round"/>
                <circle cx="16" cy="4" r="1.8" fill="#c4b5fd"/>
                <rect x="10" y="13" width="4" height="4" rx="1.5" fill="#4f7ef8"/>
                <rect x="18" y="13" width="4" height="4" rx="1.5" fill="#4f7ef8"/>
                <rect x="11" y="14" width="1.5" height="1.5" rx="0.5" fill="white" opacity="0.9"/>
                <rect x="19" y="14" width="1.5" height="1.5" rx="0.5" fill="white" opacity="0.9"/>
                <path d="M11 20 Q16 23 21 20" stroke="#4f7ef8" stroke-width="1.5" stroke-linecap="round" fill="none"/>
                <rect x="3" y="14" width="3" height="5" rx="1.5" fill="rgba(255,255,255,0.6)"/>
                <rect x="26" y="14" width="3" height="5" rx="1.5" fill="rgba(255,255,255,0.6)"/>
            </svg>
        </div>
        <div class="ai-hd-info">
            <div class="ai-hd-name">DRSMS Assistant</div>
            <div class="ai-hd-status">
                <div class="ai-hd-status-dot"></div>
                Online · AI powered
            </div>
        </div>
        <button class="ai-hd-btn" id="ai-resize-btn" data-tip="Phóng to">
            <i class="fas fa-expand" id="ai-resize-icon"></i>
        </button>
        <button class="ai-hd-btn" id="ai-clear-btn" data-tip="Xóa lịch sử">
            <i class="fas fa-trash-alt"></i>
        </button>
        <button class="ai-hd-btn" id="ai-close-btn" data-tip="Đóng">
            <i class="fas fa-times"></i>
        </button>
    </div>

    <div class="ai-messages" id="ai-messages"></div>

    <div class="ai-suggestions" id="ai-suggestions">
        <button class="ai-sug-btn" onclick="aiSuggest('Hợp đồng của tôi gồm những gì?')">📄 Hợp đồng của tôi</button>
        <button class="ai-sug-btn" onclick="aiSuggest('Làm sao tạo repair request?')">🔧 Tạo repair request</button>
        <button class="ai-sug-btn" onclick="aiSuggest('Tôi có hóa đơn chưa thanh toán không?')">💰 Hóa đơn của tôi</button>
        <button class="ai-sug-btn" onclick="aiSuggest('Bảo hành thiết bị còn bao lâu?')">🛡️ Bảo hành</button>
    </div>

    <div class="ai-disclaimer">AI có thể mắc lỗi. Hãy xác nhận thông tin quan trọng với nhân viên hỗ trợ.</div>

    <div class="ai-input-area">
        <textarea id="ai-input" placeholder="Nhập câu hỏi..." rows="1"></textarea>
        <button id="ai-send-btn" onclick="aiSend()">
            <i class="fas fa-paper-plane"></i>
        </button>
    </div>

    <div id="ai-resize-drag">
        <svg viewBox="0 0 12 12" fill="none">
            <path d="M2 10L10 2M5 10L10 5M8 10L10 8" stroke="rgba(167,139,250,0.7)" stroke-width="1.3" stroke-linecap="round"/>
        </svg>
    </div>
</div>

<script>
    (function () {
        const CTX = '<%=request.getContextPath()%>';
        const USER_NAME = '<%=me.getFullName()%>';
        const USER_INIT = '<%=initials%>';
        /* FIX: inject avatar URL from server */
        const USER_AVATAR = '<%=me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()?request.getContextPath()+me.getAvatarUrl():""%>';

        const TEASER_INTERVAL = 60000;
        const TEASER_MESSAGES = [
            '👋 Bạn cần giúp gì không? Tôi luôn sẵn sàng!',
            '🔧 Thiết bị gặp sự cố? Hãy để tôi hỗ trợ bạn.',
            '📄 Thắc mắc về hợp đồng? Cứ hỏi tôi nhé!',
            '💰 Kiểm tra hóa đơn hay thanh toán? Tôi giúp được!',
            '🤖 Có câu hỏi gì cứ hỏi — trong hệ thống hay bên ngoài!',
        ];

        const ball = document.getElementById('ai-ball');
        const teaser = document.getElementById('ai-teaser');
        const chatWin = document.getElementById('ai-chat-window');
        const msgs = document.getElementById('ai-messages');
        const input = document.getElementById('ai-input');
        const sendBtn = document.getElementById('ai-send-btn');
        const notifDot = document.getElementById('ai-notif-dot');
        let history = [];
        let isOpen = false;
        let isDragging = false;
        let teaserTimer, teaserHideTimer;
        let hasShownWelcome = false;
        let teaserIdx = 0;

        /* ── Dragging ── */
        let dragOffX = 0, dragOffY = 0, startX = 0, startY = 0, moved = false;
        ball.addEventListener('mousedown', function (e) {
            isDragging = true;
            moved = false;
            startX = e.clientX;
            startY = e.clientY;
            const rect = ball.getBoundingClientRect();
            dragOffX = e.clientX - rect.left;
            dragOffY = e.clientY - rect.top;
            ball.style.transition = 'none';
            e.preventDefault();
        });
        document.addEventListener('mousemove', function (e) {
            if (!isDragging)
                return;
            if (Math.abs(e.clientX - startX) > 4 || Math.abs(e.clientY - startY) > 4)
                moved = true;
            let nx = Math.max(0, Math.min(window.innerWidth - ball.offsetWidth, e.clientX - dragOffX));
            let ny = Math.max(0, Math.min(window.innerHeight - ball.offsetHeight, e.clientY - dragOffY));
            ball.style.left = nx + 'px';
            ball.style.top = ny + 'px';
            ball.style.right = 'auto';
            ball.style.bottom = 'auto';
            positionChat();
            positionTeaser();
        });
        document.addEventListener('mouseup', function () {
            if (isDragging) {
                isDragging = false;
                ball.style.transition = '';
                if (!moved)
                    toggleChat();
            }
        });
        ball.addEventListener('touchstart', function (e) {
            const t = e.touches[0];
            isDragging = true;
            moved = false;
            startX = t.clientX;
            startY = t.clientY;
            const rect = ball.getBoundingClientRect();
            dragOffX = t.clientX - rect.left;
            dragOffY = t.clientY - rect.top;
            e.preventDefault();
        }, {passive: false});
        document.addEventListener('touchmove', function (e) {
            if (!isDragging)
                return;
            const t = e.touches[0];
            if (Math.abs(t.clientX - startX) > 4 || Math.abs(t.clientY - startY) > 4)
                moved = true;
            let nx = Math.max(0, Math.min(window.innerWidth - ball.offsetWidth, t.clientX - dragOffX));
            let ny = Math.max(0, Math.min(window.innerHeight - ball.offsetHeight, t.clientY - dragOffY));
            ball.style.left = nx + 'px';
            ball.style.top = ny + 'px';
            ball.style.right = 'auto';
            ball.style.bottom = 'auto';
            positionChat();
            positionTeaser();
            e.preventDefault();
        }, {passive: false});
        document.addEventListener('touchend', function () {
            if (isDragging) {
                isDragging = false;
                if (!moved)
                    toggleChat();
            }
        });

        /* ── Position helpers ── */
        function positionChat() {
            const br = ball.getBoundingClientRect(), cw = chatWin.offsetWidth || 370, ch = chatWin.offsetHeight || 520, margin = 10;
            let left = br.left + br.width / 2 - cw / 2, top = br.top - ch - margin;
            if (left + cw > window.innerWidth)
                left = window.innerWidth - cw - margin;
            if (left < margin)
                left = margin;
            if (top < margin)
                top = br.bottom + margin;
            chatWin.style.left = left + 'px';
            chatWin.style.top = top + 'px';
            chatWin.style.right = 'auto';
            chatWin.style.bottom = 'auto';
            chatWin.style.transformOrigin = 'bottom center';
        }
        function positionTeaser() {
            const br = ball.getBoundingClientRect(), tw = teaser.offsetWidth || 230;
            let left = br.left + br.width / 2 - tw / 2, top = br.top - (teaser.offsetHeight || 60) - 10;
            if (left + tw > window.innerWidth - 10)
                left = window.innerWidth - tw - 10;
            if (left < 10)
                left = 10;
            if (top < 10)
                top = br.bottom + 10;
            teaser.style.left = left + 'px';
            teaser.style.top = top + 'px';
            teaser.style.right = 'auto';
            teaser.style.bottom = 'auto';
        }

        /* ── Toggle ── */
        function toggleChat() {
            hideTeaser();
            isOpen ? closeChat() : openChat();
        }
        function openChat() {
            isOpen = true;
            positionChat();
            chatWin.classList.add('open');
            ball.classList.remove('pulse');
            notifDot.style.display = 'none';
            if (!hasShownWelcome) {
                hasShownWelcome = true;
                setTimeout(function () {
                    addBotMsg('Xin chào <strong>' + USER_NAME + '</strong>! 👋 Tôi là trợ lý AI của DRSMS. Tôi có thể giúp bạn về hệ thống (hợp đồng, thiết bị, hóa đơn, repair request...) và cả các câu hỏi chung bên ngoài. Bạn cần gì?');
                }, 400);
            }
            setTimeout(function () {
                input.focus();
            }, 400);
        }
        function closeChat() {
            isOpen = false;
            chatWin.classList.remove('open');
            ball.classList.add('pulse');
        }
        document.getElementById('ai-close-btn').addEventListener('click', function (e) {
            e.stopPropagation();
            closeChat();
        });

        /* ── Clear history ── */
        document.getElementById('ai-clear-btn').addEventListener('click', function (e) {
            e.stopPropagation();
            history = [];
            msgs.innerHTML = '';
            hasShownWelcome = false;
            fetch(CTX + '/customerAIChat?action=clear', {method: 'POST'});
            setTimeout(function () {
                addBotMsg('Lịch sử đã được xóa. Tôi có thể giúp gì cho bạn? 😊');
            }, 200);
        });

        /* ── Resize ── */
        let isMaximized = false, savedW = '370px', savedH = '520px';
        document.getElementById('ai-resize-btn').addEventListener('click', function (e) {
            e.stopPropagation();
            chatWin.classList.add('resizing');
            const icon = document.getElementById('ai-resize-icon'), btn = document.getElementById('ai-resize-btn');
            if (!isMaximized) {
                savedW = chatWin.style.width || '370px';
                savedH = chatWin.style.height || '520px';
                chatWin.style.width = Math.min(680, window.innerWidth - 20) + 'px';
                chatWin.style.height = Math.min(Math.floor(window.innerHeight * 0.82), window.innerHeight - 20) + 'px';
                icon.className = 'fas fa-compress';
                btn.setAttribute('data-tip', 'Thu nhỏ');
                isMaximized = true;
            } else {
                chatWin.style.width = savedW;
                chatWin.style.height = savedH;
                icon.className = 'fas fa-expand';
                btn.setAttribute('data-tip', 'Phóng to');
                isMaximized = false;
            }
            setTimeout(function () {
                positionChat();
                chatWin.classList.remove('resizing');
            }, 320);
        });

        /* ── Drag-to-resize ── */
        const rHandle = document.getElementById('ai-resize-drag');
        let isResizeDrag = false, resStartX, resStartY, resStartW, resStartH;
        rHandle.addEventListener('mousedown', function (e) {
            isResizeDrag = true;
            resStartX = e.clientX;
            resStartY = e.clientY;
            const r = chatWin.getBoundingClientRect();
            resStartW = r.width;
            resStartH = r.height;
            e.preventDefault();
            e.stopPropagation();
        });
        document.addEventListener('mousemove', function (e) {
            if (!isResizeDrag)
                return;
            const nw = Math.max(320, Math.min(window.innerWidth - 20, resStartW + (e.clientX - resStartX)));
            const nh = Math.max(400, Math.min(window.innerHeight - 20, resStartH + (e.clientY - resStartY)));
            chatWin.style.width = nw + 'px';
            chatWin.style.height = nh + 'px';
            isMaximized = false;
            document.getElementById('ai-resize-icon').className = 'fas fa-expand';
            document.getElementById('ai-resize-btn').setAttribute('data-tip', 'Phóng to');
            positionChat();
        });
        document.addEventListener('mouseup', function () {
            isResizeDrag = false;
        });

        /* ── Teaser ── */
        function showTeaser() {
            if (isOpen)
                return;
            document.getElementById('ai-teaser-text').innerHTML = TEASER_MESSAGES[teaserIdx % TEASER_MESSAGES.length];
            teaserIdx++;
            positionTeaser();
            teaser.classList.remove('hide');
            teaser.classList.add('show');
            notifDot.style.display = 'block';
            teaserHideTimer = setTimeout(hideTeaser, 5000);
        }
        function hideTeaser() {
            clearTimeout(teaserHideTimer);
            if (!teaser.classList.contains('show'))
                return;
            teaser.classList.add('hide');
            setTimeout(function () {
                teaser.classList.remove('show', 'hide');
            }, 300);
        }
        setTimeout(function () {
            showTeaser();
            teaserTimer = setInterval(showTeaser, TEASER_INTERVAL);
        }, 8000);

        /* ── FIX: build user avatar HTML ── */
        function buildUserAvatarHtml() {
            if (USER_AVATAR) {
                return '<div class="ai-msg-ava user-ava"><img src="' + USER_AVATAR + '" alt="avatar"></div>';
            }
            return '<div class="ai-msg-ava user-ava">' + USER_INIT + '</div>';
        }

        /* ── Messages ── */
        function addBotMsg(html) {
            const now = new Date().toLocaleTimeString('vi-VN', {hour: '2-digit', minute: '2-digit'});
            const el = document.createElement('div');
            el.className = 'ai-msg bot';
            el.innerHTML = '<div class="ai-msg-ava"><svg viewBox="0 0 32 32" fill="none"><rect x="6" y="9" width="20" height="16" rx="4" fill="rgba(255,255,255,0.9)"/><rect x="10" y="13" width="4" height="4" rx="1.5" fill="#4f7ef8"/><rect x="18" y="13" width="4" height="4" rx="1.5" fill="#4f7ef8"/><path d="M11 20 Q16 23 21 20" stroke="#4f7ef8" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg></div><div><div class="ai-msg-bubble">' + html + '</div><div class="ai-msg-time">' + now + '</div></div>';
            msgs.appendChild(el);
            msgs.scrollTop = msgs.scrollHeight;
        }
        function addUserMsg(text) {
            const now = new Date().toLocaleTimeString('vi-VN', {hour: '2-digit', minute: '2-digit'});
            const el = document.createElement('div');
            el.className = 'ai-msg user';
            /* FIX: use buildUserAvatarHtml() instead of plain letter */
            el.innerHTML = buildUserAvatarHtml() + '<div><div class="ai-msg-bubble">' + escHtml(text) + '</div><div class="ai-msg-time">' + now + '</div></div>';
            msgs.appendChild(el);
            msgs.scrollTop = msgs.scrollHeight;
        }
        function showTyping() {
            const el = document.createElement('div');
            el.className = 'ai-msg bot';
            el.id = 'ai-typing';
            el.innerHTML = '<div class="ai-msg-ava"><svg viewBox="0 0 32 32" fill="none"><rect x="6" y="9" width="20" height="16" rx="4" fill="rgba(255,255,255,0.9)"/><rect x="10" y="13" width="4" height="4" rx="1.5" fill="#4f7ef8"/><rect x="18" y="13" width="4" height="4" rx="1.5" fill="#4f7ef8"/><path d="M11 20 Q16 23 21 20" stroke="#4f7ef8" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg></div><div class="ai-typing-dots"><span></span><span></span><span></span></div>';
            msgs.appendChild(el);
            msgs.scrollTop = msgs.scrollHeight;
            return el;
        }
        function escHtml(s) {
            return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        }

        /* ── Send ── */
        window.aiSuggest = function (text) {
            input.value = text;
            document.getElementById('ai-suggestions').style.display = 'none';
            aiSend();
        };
        window.aiSend = function () {
            const text = input.value.trim();
            if (!text)
                return;
            input.value = '';
            input.style.height = 'auto';
            sendBtn.disabled = true;
            document.getElementById('ai-suggestions').style.display = 'none';
            addUserMsg(text);
            history.push({role: 'user', content: text});
            const typingEl = showTyping();
            fetch(CTX + '/customerAIChat', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({message: text, history: history.slice(-20)})})
                    .then(r => r.json()).then(data => {
                typingEl.remove();
                const reply = data.reply || 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại!';
                addBotMsg(reply.replace(/\n/g, '<br>'));
                history.push({role: 'assistant', content: reply});
                sendBtn.disabled = false;
            }).catch(function () {
                typingEl.remove();
                addBotMsg('⚠️ Không thể kết nối. Vui lòng kiểm tra lại kết nối mạng.');
                sendBtn.disabled = false;
            });
        };
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                aiSend();
            }
        });
        input.addEventListener('input', function () {
            this.style.height = 'auto';
            this.style.height = Math.min(this.scrollHeight, 100) + 'px';
        });

        /* ── Load history ── */
        fetch(CTX + '/customerAIChat?action=history').then(r => r.json()).then(data => {
            if (data.history && data.history.length > 0) {
                hasShownWelcome = true;
                data.history.forEach(function (m) {
                    if (m.role === 'user')
                        addUserMsg(m.content);
                    else
                        addBotMsg(m.content.replace(/\n/g, '<br>'));
                    history.push(m);
                });
                notifDot.style.display = 'block';
            }
        }).catch(function () {});
    })();
</script>
