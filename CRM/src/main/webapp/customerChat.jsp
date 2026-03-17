<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    User agent=(User)request.getAttribute("agent");
    List<ChatMessage> msgs=(List<ChatMessage>)request.getAttribute("messages");
    if(msgs==null) msgs=new ArrayList<>();
    int lastId=request.getAttribute("lastId")!=null?(Integer)request.getAttribute("lastId"):0;
    Map<Integer,List<Map<String,Object>>> reactionsMap=
        (Map<Integer,List<Map<String,Object>>>)request.getAttribute("reactionsMap");
    if(reactionsMap==null) reactionsMap=new HashMap<>();
    ChatMessage pinnedMessage=(ChatMessage)request.getAttribute("pinnedMessage");
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    String initials=me.getFullName()!=null&&!me.getFullName().isEmpty()?me.getFullName().substring(0,1).toUpperCase():"?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Support Chat - DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
/* ══════════════════════════════════════════
   SIDEBAR — synced from customerDashboard
══════════════════════════════════════════ */
:root {
    --sb-bg:       #1e1b4b;
    --sb-border:   rgba(255,255,255,0.08);
    --sb-text:     rgba(255,255,255,0.45);
    --sb-accent:   #818cf8;
    --sb-accent-2: #a5b4fc;
    --sb-item-on:  rgba(129,140,248,0.2);
    --sb-width:    252px;

    /* Chat area — dark theme kept */
    --navy:        #0b1437;
    --navy-2:      #0f1c4d;
    --navy-card:   #111a42;
    --accent:      #4f7ef8;
    --accent-2:    #7c9ffa;
    --accent-glow: rgba(79,126,248,0.22);
    --green:       #34d399;
    --amber:       #fbbf24;
    --danger:      #f87171;
    --danger-dim:  rgba(248,113,113,0.12);
    --purple:      #a78bfa;
    --info:        #38bdf8;
    --text:        #ffffff;
    --text-2:      #c8d4f0;
    --muted:       #7a8ab8;
    --border:      rgba(255,255,255,0.07);
}

*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html{scroll-behavior:smooth;}
body{font-family:'Sora',sans-serif;background:var(--navy);color:var(--text);min-height:100vh;display:flex;}
::-webkit-scrollbar{width:4px;}
::-webkit-scrollbar-track{background:transparent;}
::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px;}

/* ══ SIDEBAR — Dashboard style ══ */
.sb{
    width:var(--sb-width);min-height:100vh;
    background:var(--sb-bg);
    border-right:1px solid rgba(79,70,229,0.2);
    display:flex;flex-direction:column;
    position:fixed;top:0;left:0;z-index:100;
    box-shadow:4px 0 24px rgba(0,0,0,0.15);
}
.sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border);}
.sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#818cf8,#a78bfa);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;box-shadow:0 4px 12px rgba(129,140,248,0.4);flex-shrink:0;}
.sb-name{color:#fff;font-size:1.05rem;font-weight:800;letter-spacing:-.3px;}
.sb-role{display:inline-flex;align-items:center;background:rgba(129,140,248,0.2);border:1px solid rgba(129,140,248,0.3);color:var(--sb-accent-2);font-size:.6rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:2px 8px;border-radius:20px;margin-top:3px;}
.sb-nav{flex:1;padding:12px 10px;overflow-y:auto;}
.sb-lbl{color:rgba(255,255,255,0.22);font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:1.6px;padding:0 8px;margin:14px 0 5px;}
.sb-item{display:flex;align-items:center;gap:9px;padding:8px 10px;border-radius:9px;margin-bottom:1px;color:var(--sb-text);text-decoration:none;font-size:.81rem;font-weight:500;transition:all .18s;border-left:2px solid transparent;}
.sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.78rem;border-radius:8px;background:rgba(255,255,255,0.06);flex-shrink:0;transition:all .18s;}
.sb-item.on{color:#fff;background:var(--sb-item-on);border-left-color:var(--sb-accent);}
.sb-item.on i{background:rgba(129,140,248,0.3);color:var(--sb-accent-2);}
.sb-item:hover:not(.on){color:rgba(255,255,255,0.78);background:rgba(255,255,255,0.06);}
.sb-badge{margin-left:auto;background:#ef4444;color:#fff;font-size:.6rem;font-weight:700;padding:2px 7px;border-radius:20px;box-shadow:0 2px 6px rgba(239,68,68,0.5);}
.sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border);}
.sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);margin-bottom:5px;text-decoration:none;transition:all .18s;}
.sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3);}
.sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
.sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%;}
.sb-uname{color:#fff;font-size:.8rem;font-weight:600;}
.sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem;margin-top:1px;}
.sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
.sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1);}

/* ══════════════════════════════════════════
   CHAT AREA — original dark theme kept
══════════════════════════════════════════ */
.main{margin-left:var(--sb-width);flex:1;display:flex;flex-direction:column;height:100vh;overflow:hidden;}
.chat-hd{padding:0 24px;height:64px;display:flex;align-items:center;gap:14px;flex-shrink:0;background:rgba(11,20,55,0.7);backdrop-filter:blur(16px);border-bottom:1px solid var(--border);}
.chat-ava{width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,var(--green),#059669);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.95rem;font-weight:700;flex-shrink:0;position:relative;}
.online-dot{position:absolute;bottom:1px;right:1px;width:11px;height:11px;background:var(--green);border-radius:50%;border:2px solid var(--navy);box-shadow:0 0 6px rgba(52,211,153,0.6);}
.chat-hd-info{flex:1;}
.chat-hd-name{font-size:.93rem;font-weight:700;color:#fff;}
.chat-hd-status{font-size:.72rem;color:var(--green);font-weight:500;margin-top:2px;display:flex;align-items:center;gap:5px;}
.chat-hd-status i{font-size:.42rem;}
.pin-banner{display:none;align-items:center;gap:10px;padding:8px 20px;background:rgba(251,191,36,0.07);border-bottom:1px solid rgba(251,191,36,0.15);cursor:pointer;transition:background .2s;flex-shrink:0;}
.pin-banner.show{display:flex;}
.pin-banner:hover{background:rgba(251,191,36,0.12);}
.pin-icon{color:var(--amber);font-size:.75rem;flex-shrink:0;}
.pin-text{font-size:.76rem;color:var(--text-2);flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.pin-label{font-size:.62rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:var(--amber);flex-shrink:0;}
.pin-close{width:20px;height:20px;border-radius:50%;border:none;background:rgba(255,255,255,0.06);color:var(--muted);cursor:pointer;font-size:.65rem;display:flex;align-items:center;justify-content:center;flex-shrink:0;transition:all .2s;}
.pin-close:hover{background:rgba(248,113,113,0.2);color:var(--danger);}
.chat-msgs{flex:1;overflow-y:auto;padding:20px 24px;background:var(--navy);display:flex;flex-direction:column;gap:2px;}
.chat-msgs::-webkit-scrollbar{width:4px;}
.chat-msgs::-webkit-scrollbar-track{background:transparent;}
.chat-msgs::-webkit-scrollbar-thumb{background:rgba(79,126,248,0.3);border-radius:4px;}
.date-sep{text-align:center;margin:10px 0;}
.date-sep span{background:rgba(255,255,255,0.06);border:1px solid var(--border);color:var(--muted);font-size:.68rem;font-weight:600;padding:3px 12px;border-radius:20px;}
.msg-row{display:flex;align-items:flex-end;gap:8px;max-width:72%;position:relative;margin-bottom:4px;}
.msg-row.mine{margin-left:auto;flex-direction:row-reverse;}
.msg-row.other{margin-right:auto;}
.msg-ava{width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.75rem;font-weight:700;color:#fff;flex-shrink:0;}
.msg-ava.support{background:linear-gradient(135deg,var(--green),#059669);}
.msg-ava.me{background:linear-gradient(135deg,var(--accent),var(--purple));}
.msg-content{display:flex;flex-direction:column;gap:3px;position:relative;}
.msg-row.mine .msg-content{align-items:flex-end;}
.msg-row.other .msg-content{align-items:flex-start;}
.msg-name{font-size:.68rem;color:var(--muted);font-weight:600;margin-bottom:1px;}
.msg-bubble{padding:9px 14px;border-radius:18px;font-size:.855rem;line-height:1.55;word-wrap:break-word;max-width:380px;position:relative;cursor:default;transition:filter .15s;}
.msg-bubble:hover{filter:brightness(1.08);}
.msg-row.mine .msg-bubble{background:linear-gradient(135deg,var(--accent),#6366f1);color:#fff;border-bottom-right-radius:4px;}
.msg-row.other .msg-bubble{background:rgba(17,26,66,0.9);border:1px solid var(--border);color:var(--text-2);border-bottom-left-radius:4px;}
.msg-bubble.recalled{background:rgba(255,255,255,0.03)!important;border:1px dashed rgba(255,255,255,0.12)!important;color:var(--muted)!important;font-style:italic;font-size:.78rem;}
.msg-time{font-size:.64rem;color:var(--muted);padding:0 2px;}
.msg-reactions{display:flex;flex-wrap:wrap;gap:4px;margin-top:4px;}
.reaction-chip{display:inline-flex;align-items:center;gap:3px;padding:2px 7px;border-radius:20px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);font-size:.75rem;cursor:pointer;transition:all .15s;user-select:none;}
.reaction-chip:hover{background:rgba(79,126,248,0.15);border-color:rgba(79,126,248,0.3);}
.reaction-chip.mine{background:rgba(79,126,248,0.15);border-color:rgba(79,126,248,0.35);}
.reaction-chip .cnt{font-size:.68rem;color:var(--text-2);font-weight:600;}
.msg-actions{position:absolute;top:50%;transform:translateY(-50%);display:flex;gap:4px;opacity:0;pointer-events:none;transition:opacity .2s;z-index:10;padding:8px 6px;}
.msg-row.mine .msg-actions{right:calc(100% + 2px);}
.msg-row.other .msg-actions{left:calc(100% + 2px);}
.msg-actions.visible{opacity:1;pointer-events:auto;}
.act-btn{width:34px;height:34px;border-radius:10px;border:1px solid rgba(255,255,255,0.12);background:rgba(17,26,66,0.97);color:var(--muted);cursor:pointer;font-size:.8rem;display:flex;align-items:center;justify-content:center;transition:all .15s;box-shadow:0 2px 8px rgba(0,0,0,0.35);}
.act-btn:hover{background:rgba(79,126,248,0.2);border-color:rgba(79,126,248,0.4);color:var(--accent-2);transform:scale(1.08);}
.act-btn.danger:hover{background:rgba(248,113,113,0.2);border-color:rgba(248,113,113,0.4);color:var(--danger);transform:scale(1.08);}
.act-btn.pin-act:hover{background:rgba(251,191,36,0.2);border-color:rgba(251,191,36,0.4);color:var(--amber);transform:scale(1.08);}
.act-btn.pinned-active{background:rgba(251,191,36,0.15);border-color:rgba(251,191,36,0.4);color:var(--amber);}
.react-popup{position:absolute;bottom:calc(100% + 6px);display:none;background:rgba(15,28,77,0.98);border:1px solid var(--border);border-radius:14px;padding:6px 8px;gap:4px;backdrop-filter:blur(20px);box-shadow:0 8px 32px rgba(0,0,0,0.5);z-index:100;animation:popIn .15s ease;}
.react-popup.show{display:flex;}
.msg-row.mine .react-popup{right:0;}
.msg-row.other .react-popup{left:0;}
@keyframes popIn{from{opacity:0;transform:scale(.85) translateY(4px)}to{opacity:1;transform:scale(1) translateY(0)}}
.react-emoji-btn{width:32px;height:32px;border-radius:8px;border:none;background:transparent;cursor:pointer;font-size:1.1rem;display:flex;align-items:center;justify-content:center;transition:all .15s;}
.react-emoji-btn:hover{background:rgba(79,126,248,0.2);transform:scale(1.2);}
.typing{display:none;}
.typing.show{display:flex;}
.typing-bubble{background:rgba(17,26,66,0.9);border:1px solid var(--border);padding:10px 14px;border-radius:18px;border-bottom-left-radius:4px;display:flex;align-items:center;gap:4px;}
.t-dot{width:6px;height:6px;border-radius:50%;background:var(--muted);animation:taBounce 1.4s infinite ease-in-out;}
.t-dot:nth-child(2){animation-delay:.2s;}
.t-dot:nth-child(3){animation-delay:.4s;}
@keyframes taBounce{0%,60%,100%{transform:translateY(0)}30%{transform:translateY(-5px);background:var(--accent-2)}}
.chat-input-area{background:rgba(11,20,55,0.7);backdrop-filter:blur(16px);border-top:1px solid var(--border);padding:12px 20px 14px;flex-shrink:0;position:relative;}
.input-row{display:flex;gap:8px;align-items:flex-end;}
.input-wrap{flex:1;background:rgba(255,255,255,0.05);border:1.5px solid var(--border);border-radius:22px;padding:9px 14px;display:flex;align-items:center;gap:8px;transition:all .2s;}
.input-wrap:focus-within{border-color:rgba(79,126,248,0.5);background:rgba(79,126,248,0.06);box-shadow:0 0 0 3px rgba(79,126,248,0.1);}
.chat-input{flex:1;border:none;outline:none;background:transparent;font-size:.875rem;font-family:'Sora',sans-serif;color:var(--text);resize:none;max-height:100px;line-height:1.45;}
.chat-input::placeholder{color:var(--muted);}
.btn-emoji-toggle{width:28px;height:28px;border:none;background:none;color:var(--muted);cursor:pointer;font-size:1.1rem;display:flex;align-items:center;justify-content:center;border-radius:8px;transition:all .15s;flex-shrink:0;}
.btn-emoji-toggle:hover{color:var(--amber);background:rgba(251,191,36,0.1);}
.btn-send{width:44px;height:44px;border-radius:50%;border:none;background:linear-gradient(135deg,var(--accent),var(--purple));color:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:.9rem;flex-shrink:0;transition:all .2s;box-shadow:0 4px 14px var(--accent-glow);}
.btn-send:hover{transform:scale(1.08);box-shadow:0 6px 20px rgba(79,126,248,0.5);}
.btn-send:disabled{background:rgba(79,126,248,0.2);box-shadow:none;cursor:not-allowed;transform:none;}
.input-hint{text-align:center;font-size:.68rem;color:var(--muted);margin-top:6px;}
.input-hint strong{color:var(--text-2);}
.emoji-picker{position:absolute;bottom:80px;left:20px;right:20px;max-width:360px;background:rgba(15,28,77,0.98);border:1px solid var(--border);border-radius:16px;padding:12px;backdrop-filter:blur(20px);box-shadow:0 16px 48px rgba(0,0,0,0.6);z-index:200;display:none;animation:popIn .15s ease;}
.emoji-picker.show{display:block;}
.emoji-cats{display:flex;gap:4px;margin-bottom:10px;overflow-x:auto;padding-bottom:4px;}
.emoji-cats::-webkit-scrollbar{height:2px;}
.emoji-cat-btn{padding:4px 10px;border-radius:8px;border:none;background:rgba(255,255,255,0.05);color:var(--muted);cursor:pointer;font-size:.75rem;font-weight:600;white-space:nowrap;transition:all .15s;}
.emoji-cat-btn.active{background:rgba(79,126,248,0.2);color:var(--accent-2);}
.emoji-search{width:100%;padding:6px 12px;background:rgba(255,255,255,0.05);border:1px solid var(--border);border-radius:10px;color:var(--text);font-family:'Sora',sans-serif;font-size:.78rem;outline:none;margin-bottom:10px;}
.emoji-search::placeholder{color:var(--muted);}
.emoji-grid{display:grid;grid-template-columns:repeat(8,1fr);gap:2px;max-height:180px;overflow-y:auto;}
.emoji-grid::-webkit-scrollbar{width:3px;}
.eg-btn{border:none;background:none;cursor:pointer;font-size:1.2rem;padding:4px;border-radius:6px;transition:all .12s;text-align:center;}
.eg-btn:hover{background:rgba(79,126,248,0.2);transform:scale(1.15);}
.no-agent{flex:1;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:12px;color:var(--muted);}
.no-agent i{font-size:2.8rem;opacity:.18;}
.no-agent p{font-weight:600;font-size:.9rem;color:var(--text-2);}
.no-agent span{font-size:.8rem;}
.toast{position:fixed;bottom:24px;left:50%;transform:translateX(-50%) translateY(20px);background:rgba(17,26,66,0.98);border:1px solid var(--border);color:var(--text-2);font-size:.78rem;font-weight:600;padding:8px 18px;border-radius:20px;box-shadow:0 8px 24px rgba(0,0,0,0.4);opacity:0;transition:all .3s;z-index:999;pointer-events:none;}
.toast.show{opacity:1;transform:translateX(-50%) translateY(0);}
.msg-sending{opacity:.55;}
.msg-error .msg-bubble{background:var(--danger-dim)!important;border-color:rgba(248,113,113,0.25)!important;color:var(--danger)!important;}
.emoji-burst-particle{position:fixed;pointer-events:none;font-size:1.4rem;z-index:9999;user-select:none;animation:emojiBurst var(--dur,.9s) ease-out forwards;}
@keyframes emojiBurst{0%{opacity:1;transform:translate(0,0) scale(1.2) rotate(0deg);}15%{opacity:1;transform:translate(calc(var(--tx)*.15),calc(var(--ty)*.15)) scale(1.5);}60%{opacity:.85;}100%{opacity:0;transform:translate(var(--tx),var(--ty)) scale(.15) rotate(var(--rot));}}
    </style>
</head>
<body>

<!-- ═══ SIDEBAR ═══ -->
<aside class="sb">
    <div class="sb-brand">
        <div class="sb-logo"><i class="fas fa-bolt"></i></div>
        <div><div class="sb-name">DRSMS</div><div class="sb-role">Customer</div></div>
    </div>
    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div>
        <a href="<%=ctx%>/customerDashboard" class="sb-item"><i class="fas fa-home"></i> Dashboard</a>
        <div class="sb-lbl">Services</div>
        <a href="<%=ctx%>/customerServiceRequests" class="sb-item"><i class="fas fa-clipboard-list"></i> Repair Requests</a>
        <a href="<%=ctx%>/customerContracts" class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
        <a href="<%=ctx%>/customerEquipment" class="sb-item"><i class="fas fa-desktop"></i> My Equipment</a>
        <div class="sb-lbl">Shop</div>
        <a href="<%=ctx%>/customerShop?action=parts" class="sb-item"><i class="fas fa-puzzle-piece"></i> Parts</a>
        <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Equipment</a>
        <a href="<%=ctx%>/customerShop?action=cart" class="sb-item">
            <i class="fas fa-shopping-cart"></i> Cart
            <%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%>
        </a>
        <div class="sb-lbl">Finance</div>
        <a href="<%=ctx%>/customerInvoices" class="sb-item"><i class="fas fa-receipt"></i> Invoices</a>
        <div class="sb-lbl">Support</div>
        <a href="<%=ctx%>/customerChat" class="sb-item on"><i class="fas fa-comment-dots"></i> Support Chat</a>
    </nav>
    <div class="sb-foot">
        <a href="<%=ctx%>/profile" class="sb-user">
            <div class="sb-ava">
                <%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%>
                <img src="<%=ctx%><%=me.getAvatarUrl()%>" alt="avatar">
                <%}else{%><%=initials%><%}%>
            </div>
            <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer Account</div></div>
        </a>
        <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
    </div>
</aside>

<!-- ═══ MAIN ═══ -->
<main class="main">
<%if(agent==null){%>
    <div class="chat-hd">
        <div class="chat-hd-info">
            <div class="chat-hd-name">Support Chat</div>
            <div class="chat-hd-status" style="color:var(--muted)"><i class="fas fa-circle"></i> Unavailable</div>
        </div>
    </div>
    <div class="no-agent">
        <i class="fas fa-headset"></i>
        <p>No support agent available at the moment</p>
        <span>Please try again later</span>
    </div>
<%}else{%>

    <!-- Chat header -->
    <div class="chat-hd">
        <div class="chat-ava"><%=agent.getFullName().substring(0,1).toUpperCase()%><span class="online-dot"></span></div>
        <div class="chat-hd-info">
            <div class="chat-hd-name"><%=agent.getFullName()%></div>
            <div class="chat-hd-status"><i class="fas fa-circle"></i> Online · Support Agent</div>
        </div>
    </div>

    <!-- Pin banner -->
    <div class="pin-banner <%=pinnedMessage!=null?"show":""%>" id="pinBanner" onclick="scrollToPin()">
        <i class="fas fa-thumbtack pin-icon"></i>
        <span class="pin-label">Pinned</span>
        <span class="pin-text" id="pinText"><%=pinnedMessage!=null?pinnedMessage.getMessage().replace("<","&lt;").replace(">","&gt;"):""%></span>
        <button class="pin-close" onclick="event.stopPropagation();clearPin()"><i class="fas fa-times"></i></button>
    </div>

    <!-- Messages -->
    <div class="chat-msgs" id="chatMsgs">
        <%if(msgs.isEmpty()){%>
        <div class="empty-chat" id="emptyChat" style="margin:auto;text-align:center;color:var(--muted);padding:40px 24px;">
            <span style="font-size:2.8rem;display:block;margin-bottom:12px">💬</span>
            <p style="font-weight:600;font-size:.88rem;color:var(--text-2);margin-bottom:5px;">Start a conversation</p>
            <span style="font-size:.78rem;">Send a message to get support</span>
        </div>
        <%}else{
            String prevDate="";
            for(ChatMessage m:msgs){
                boolean mine=m.getSenderId()==me.getId();
                String dateStr=m.getCreatedAt()!=null?m.getCreatedAt().toLocalDate().toString():"";
                if(!dateStr.equals(prevDate)){prevDate=dateStr;%>
        <div class="date-sep"><span><%=dateStr%></span></div>
        <%}
            List<Map<String,Object>> msgReactions=reactionsMap.getOrDefault(m.getId(),new ArrayList<>());
        %>
        <div class="msg-row <%=mine?"mine":"other"%>" data-id="<%=m.getId()%>" data-mine="<%=mine%>"
             <%=m.isPinned()?"data-pinned='true'":""%>>
            <div class="msg-ava <%=mine?"me":"support"%>"><%=(m.getSenderName()!=null?m.getSenderName():"?").substring(0,1).toUpperCase()%></div>
            <div class="msg-content">
                <%if(!mine){%><div class="msg-name"><%=m.getSenderName()%></div><%}%>
                <div class="msg-bubble <%=m.isRecalled()?"recalled":""%>">
                    <%if(m.isRecalled()){%>
                        <i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled
                    <%}else{%>
                        <%=m.getMessage().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>")%>
                    <%}%>
                </div>
                <div class="msg-reactions">
                    <%for(Map<String,Object> rx:msgReactions){
                        boolean rxMine=(Boolean)rx.get("mine");
                        int rxCount=(Integer)rx.get("count");
                        String rxEmoji=(String)rx.get("emoji");
                    %>
                    <div class="reaction-chip <%=rxMine?"mine":""%>"
                         onclick="toggleReactionChip(this,'<%=rxEmoji%>',<%=m.getId()%>)">
                        <%=rxEmoji%> <span class="cnt"><%=rxCount%></span>
                    </div>
                    <%}%>
                </div>
                <div class="msg-time"><%=m.getTimeFormatted()%></div>
                <%if(!m.isRecalled()){%>
                <div class="msg-actions">
                    <div style="position:relative">
                        <button class="act-btn" title="React" onclick="toggleReactPopup(this)"><i class="fas fa-face-smile"></i></button>
                        <div class="react-popup">
                            <button class="react-emoji-btn" onclick="addReaction(this,'👍')">👍</button>
                            <button class="react-emoji-btn" onclick="addReaction(this,'❤️')">❤️</button>
                            <button class="react-emoji-btn" onclick="addReaction(this,'😂')">😂</button>
                            <button class="react-emoji-btn" onclick="addReaction(this,'😮')">😮</button>
                            <button class="react-emoji-btn" onclick="addReaction(this,'😢')">😢</button>
                            <button class="react-emoji-btn" onclick="addReaction(this,'🔥')">🔥</button>
                        </div>
                    </div>
                    <button class="act-btn pin-act <%=m.isPinned()?"pinned-active":""%>" title="<%=m.isPinned()?"Unpin":"Pin"%> message" onclick="pinMsg(this)">
                        <i class="fas fa-thumbtack"></i>
                    </button>
                    <%if(mine){%>
                    <button class="act-btn danger" title="Recall message" onclick="recallMsg(this)"><i class="fas fa-rotate-left"></i></button>
                    <%}%>
                </div>
                <%}%>
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

    <!-- Input area -->
    <div class="chat-input-area">
        <div class="emoji-picker" id="emojiPicker">
            <div class="emoji-cats" id="emojiCats"></div>
            <input class="emoji-search" id="emojiSearch" placeholder="Search emoji..." oninput="filterEmojis(this.value)">
            <div class="emoji-grid" id="emojiGrid"></div>
        </div>
        <div class="input-row">
            <div class="input-wrap">
                <button class="btn-emoji-toggle" id="emojiToggleBtn" title="Emoji" onclick="toggleEmojiPicker()">😊</button>
                <textarea class="chat-input" id="msgInput" placeholder="Type a message..."
                          rows="1" onkeydown="handleKey(event)" oninput="autoResize(this)" maxlength="2000"></textarea>
            </div>
            <button class="btn-send" id="sendBtn" onclick="sendMsg()" title="Send (Enter)">
                <i class="fas fa-paper-plane"></i>
            </button>
        </div>
        <div class="input-hint"><strong>Enter</strong> to send · <strong>Shift+Enter</strong> for new line</div>
    </div>
<%}%>
</main>

<div class="toast" id="toast"></div>

<script>
const CTX = '<%=ctx%>';
const MY_ID = <%=me.getId()%>;
const MY_NAME = '<%=me.getFullName().replace("\\","\\\\").replace("'","\\'")%>';
const AGENT_NAME = '<%=agent!=null?agent.getFullName().replace("\\","\\\\").replace("'","\\'"):""%>';
let lastId = <%=lastId%>;
let pollTimer = null;
let pollUpdatesTimer = null;
const renderedIds = new Set();

let pinnedMsgEl = null;
let pinnedMsgId = <%=pinnedMessage!=null?pinnedMessage.getId():0%>;

const reactions = {};

document.querySelectorAll('#chatMsgs .msg-row[data-id]').forEach(el => {
    const n = parseInt(el.dataset.id);
    if (!isNaN(n) && n > 0) {
        renderedIds.add(n);
        if (el.dataset.pinned === 'true') pinnedMsgEl = el;
    }
    const mid = el.dataset.id;
    if (mid) {
        reactions[mid] = {};
        el.querySelectorAll('.reaction-chip[data-emoji]').forEach(chip => {
            const emoji = chip.dataset.emoji;
            const count = parseInt(chip.querySelector('.cnt').textContent) || 0;
            const mine  = chip.classList.contains('mine');
            if (emoji && count > 0) reactions[mid][emoji] = {count, mine};
        });
    }
});

function scrollDown(smooth) {
    const el = document.getElementById('chatMsgs');
    if (el) el.scrollTo({top: el.scrollHeight, behavior: smooth ? 'smooth' : 'instant'});
}
function autoResize(el) {
    el.style.height = 'auto';
    el.style.height = Math.min(el.scrollHeight, 100) + 'px';
}
function handleKey(e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMsg(); }
}
function nowTime() {
    return new Date().toLocaleTimeString('en-US', {hour:'2-digit', minute:'2-digit', hour12:false});
}
function showToast(msg, duration) {
    const t = document.getElementById('toast');
    t.textContent = msg;
    t.classList.add('show');
    setTimeout(() => t.classList.remove('show'), duration || 2000);
}

function buildMsgRow(m, isMine) {
    const row = document.createElement('div');
    row.className = 'msg-row ' + (isMine ? 'mine' : 'other');
    if (m.id && String(m.id).indexOf('temp') === -1) row.dataset.id = m.id;
    row.dataset.mine = isMine;

    const isRecalled = m.recalled === true;
    const safe = isRecalled ? '' : String(m.message || '')
        .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\n/g,'<br>');
    const initLetter = (isMine ? MY_NAME : AGENT_NAME).substring(0,1).toUpperCase();
    const nameHtml = !isMine ? '<div class="msg-name">' + AGENT_NAME + '</div>' : '';
    const bubbleContent = isRecalled
        ? '<i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled'
        : safe;
    const recallBtn = (!isRecalled && isMine)
        ? '<button class="act-btn danger" title="Recall" onclick="recallMsg(this)"><i class="fas fa-rotate-left"></i></button>' : '';
    const actionsHtml = isRecalled ? '' :
        '<div class="msg-actions">' +
        '<div style="position:relative">' +
        '<button class="act-btn" title="React" onclick="toggleReactPopup(this)"><i class="fas fa-face-smile"></i></button>' +
        '<div class="react-popup">' +
        ['👍','❤️','😂','😮','😢','🔥'].map(e =>
            '<button class="react-emoji-btn" onclick="addReaction(this,\'' + e + '\')">' + e + '</button>'
        ).join('') +
        '</div></div>' +
        '<button class="act-btn pin-act" title="Pin" onclick="pinMsg(this)"><i class="fas fa-thumbtack"></i></button>' +
        recallBtn + '</div>';

    let reactHtml = '<div class="msg-reactions">';
    if (m.reactions && Array.isArray(m.reactions)) {
        m.reactions.forEach(rx => {
            if (rx.count > 0) {
                reactHtml += '<div class="reaction-chip ' + (rx.mine?'mine':'') + '" ' +
                    'data-emoji="' + rx.emoji + '" ' +
                    'onclick="toggleReactionChip(this,\'' + rx.emoji + '\',' + m.id + ')">' +
                    rx.emoji + ' <span class="cnt">' + rx.count + '</span></div>';
            }
        });
    }
    reactHtml += '</div>';

    row.innerHTML =
        '<div class="msg-ava ' + (isMine?'me':'support') + '">' + initLetter + '</div>' +
        '<div class="msg-content">' + nameHtml +
        '<div class="msg-bubble' + (isRecalled?' recalled':'') + '">' + bubbleContent + '</div>' +
        reactHtml +
        '<div class="msg-time">' + (m.time||nowTime()) + '</div>' +
        actionsHtml + '</div>';
    return row;
}

function appendMsg(m) {
    const container = document.getElementById('chatMsgs');
    if (!container) return null;
    const emp = document.getElementById('emptyChat');
    if (emp) emp.remove();
    const typing = document.getElementById('typing');
    const isMine = (m.senderId === MY_ID || m.mine === true);
    const row = buildMsgRow(m, isMine);
    if (typing) container.insertBefore(row, typing);
    else container.appendChild(row);
    if (!row.dataset.bound) { bindRowHover(row); row.dataset.bound = '1'; }
    return row;
}

function sendMsg() {
    const inp = document.getElementById('msgInput');
    const btn = document.getElementById('sendBtn');
    const text = inp.value.trim();
    if (!text) return;
    btn.disabled = true; inp.disabled = true;
    const tempEl = appendMsg({id:'temp_'+Date.now(), senderId:MY_ID, senderName:MY_NAME, message:text, time:nowTime(), mine:true});
    if (tempEl) tempEl.classList.add('msg-sending');
    inp.value = ''; inp.style.height = 'auto';
    scrollDown(true);
    fetch(CTX + '/customerChat', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
        body: new URLSearchParams({message: text})
    })
    .then(r => r.json())
    .then(d => {
        if (d.success && d.id) {
            if (tempEl) { tempEl.dataset.id = d.id; tempEl.classList.remove('msg-sending'); renderedIds.add(d.id); }
            if (d.id > lastId) lastId = d.id;
        } else { if (tempEl) tempEl.classList.add('msg-error'); }
    })
    .catch(() => { if (tempEl) tempEl.classList.add('msg-error'); })
    .finally(() => { btn.disabled = false; inp.disabled = false; inp.focus(); });
}

function poll() {
    fetch(CTX + '/customerChat?action=poll&lastId=' + lastId)
    .then(r => r.json())
    .then(newMsgs => {
        if (!Array.isArray(newMsgs) || !newMsgs.length) return;
        let appended = false;
        newMsgs.forEach(m => {
            if (!renderedIds.has(m.id)) {
                renderedIds.add(m.id);
                if (m.id > lastId) lastId = m.id;
                appendMsg(m);
                appended = true;
            }
        });
        if (appended) scrollDown(true);
    })
    .catch(() => {});
}

function pollUpdates() {
    fetch(CTX + '/customerChat?action=pollUpdates')
    .then(r => r.json())
    .then(allMsgs => {
        if (!Array.isArray(allMsgs)) return;
        allMsgs.forEach(m => {
            const mid = String(m.id);
            const existingRow = document.querySelector('#chatMsgs .msg-row[data-id="' + mid + '"]');
            if (!existingRow) return;
            if (m.recalled) {
                const bubble = existingRow.querySelector('.msg-bubble');
                if (bubble && !bubble.classList.contains('recalled')) {
                    bubble.classList.add('recalled');
                    bubble.innerHTML = '<i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled';
                    const acts = existingRow.querySelector('.msg-actions');
                    if (acts) acts.style.display = 'none';
                    if (pinnedMsgEl === existingRow) {
                        pinnedMsgEl = null; pinnedMsgId = 0;
                        document.getElementById('pinBanner').classList.remove('show');
                    }
                }
            }
            if (m.reactions && Array.isArray(m.reactions)) {
                reactions[mid] = {};
                m.reactions.forEach(rx => {
                    if (rx.count > 0) reactions[mid][rx.emoji] = {count: rx.count, mine: rx.mine};
                });
                renderReactions(existingRow, mid);
            }
            if (m.pinned) {
                if (String(pinnedMsgId) !== mid) {
                    if (pinnedMsgEl) {
                        const oldBtn = pinnedMsgEl.querySelector('.pin-act');
                        if (oldBtn) oldBtn.classList.remove('pinned-active');
                        pinnedMsgEl.removeAttribute('data-pinned');
                    }
                    pinnedMsgId = mid; pinnedMsgEl = existingRow;
                    existingRow.dataset.pinned = 'true';
                    const pinBtn = existingRow.querySelector('.pin-act');
                    if (pinBtn) pinBtn.classList.add('pinned-active');
                    const bubble = existingRow.querySelector('.msg-bubble');
                    document.getElementById('pinText').textContent = bubble ? bubble.innerText.trim() : '';
                    document.getElementById('pinBanner').classList.add('show');
                }
            } else {
                if (pinnedMsgEl === existingRow) {
                    pinnedMsgEl = null; pinnedMsgId = 0;
                    existingRow.removeAttribute('data-pinned');
                    const pinBtn = existingRow.querySelector('.pin-act');
                    if (pinBtn) pinBtn.classList.remove('pinned-active');
                    document.getElementById('pinBanner').classList.remove('show');
                }
            }
        });
    })
    .catch(() => {});
}

function recallMsg(btn) {
    const row = btn.closest('.msg-row');
    if (!row) return;
    const msgId = row.dataset.id;
    if (!msgId || msgId.indexOf('temp') !== -1) { showToast('Cannot recall unsent message'); return; }
    if (!confirm('Recall this message?')) return;
    const bubble = row.querySelector('.msg-bubble');
    bubble.classList.add('recalled');
    bubble.innerHTML = '<i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled';
    const acts = row.querySelector('.msg-actions');
    if (acts) acts.style.display = 'none';
    if (pinnedMsgEl === row) { pinnedMsgEl = null; pinnedMsgId = 0; document.getElementById('pinBanner').classList.remove('show'); }
    showToast('Message recalled ✓');
    fetch(CTX + '/customerChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body: new URLSearchParams({action:'recall', messageId:msgId}) }).catch(() => {});
}

function pinMsg(btn) {
    const row = btn.closest('.msg-row');
    if (!row) return;
    const bubble = row.querySelector('.msg-bubble');
    if (bubble.classList.contains('recalled')) { showToast('Cannot pin a recalled message'); return; }
    const msgId = row.dataset.id;
    if (!msgId || msgId.indexOf('temp') !== -1) { showToast('Cannot pin unsent message'); return; }
    const isAlreadyPinned = (String(pinnedMsgId) === String(msgId));
    if (pinnedMsgEl) { const ob = pinnedMsgEl.querySelector('.pin-act'); if (ob) ob.classList.remove('pinned-active'); pinnedMsgEl.removeAttribute('data-pinned'); }
    if (isAlreadyPinned) {
        pinnedMsgEl = null; pinnedMsgId = 0;
        document.getElementById('pinBanner').classList.remove('show');
        showToast('Pin removed');
    } else {
        pinnedMsgEl = row; pinnedMsgId = msgId;
        row.dataset.pinned = 'true'; btn.classList.add('pinned-active');
        document.getElementById('pinText').textContent = bubble.innerText.trim();
        document.getElementById('pinBanner').classList.add('show');
        bubble.style.outline = '2px solid var(--amber)';
        setTimeout(() => bubble.style.outline = '', 1500);
        showToast('Message pinned 📌');
    }
    fetch(CTX + '/customerChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body: new URLSearchParams({action:'pin', messageId:msgId}) }).catch(() => {});
}

function scrollToPin() {
    if (!pinnedMsgEl) return;
    pinnedMsgEl.scrollIntoView({behavior:'smooth', block:'center'});
    const bubble = pinnedMsgEl.querySelector('.msg-bubble');
    if (bubble) { bubble.style.outline = '2px solid var(--amber)'; setTimeout(() => bubble.style.outline = '', 1500); }
}

function clearPin() {
    if (pinnedMsgEl) { const ob = pinnedMsgEl.querySelector('.pin-act'); if (ob) ob.classList.remove('pinned-active'); pinnedMsgEl.removeAttribute('data-pinned'); }
    const oldId = pinnedMsgId;
    pinnedMsgEl = null; pinnedMsgId = 0;
    document.getElementById('pinBanner').classList.remove('show');
    showToast('Pin removed');
    if (oldId) { fetch(CTX + '/customerChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body: new URLSearchParams({action:'pin', messageId:oldId}) }).catch(() => {}); }
}

function toggleReactPopup(btn) {
    document.querySelectorAll('.react-popup.show').forEach(p => { if (p !== btn.nextElementSibling) p.classList.remove('show'); });
    btn.nextElementSibling.classList.toggle('show');
}
function addReaction(btn, emoji) {
    const popup = btn.closest('.react-popup');
    const row   = btn.closest('.msg-row');
    const msgId = row ? row.dataset.id : null;
    if (!msgId || msgId.indexOf('temp') !== -1) return;
    triggerEmojiBurst(emoji, btn);
    popup.classList.remove('show');
    _toggleReactionLocal(row, msgId, emoji);
    fetch(CTX + '/customerChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body: new URLSearchParams({action:'react', messageId:msgId, emoji:emoji}) }).catch(() => {});
}
function toggleReactionChip(chip, emoji, msgId) {
    const row = chip.closest('.msg-row');
    if (!row) return;
    const mid = String(msgId);
    triggerEmojiBurst(emoji, chip);
    _toggleReactionLocal(row, mid, emoji);
    fetch(CTX + '/customerChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body: new URLSearchParams({action:'react', messageId:mid, emoji:emoji}) }).catch(() => {});
}
function _toggleReactionLocal(row, mid, emoji) {
    if (!reactions[mid]) reactions[mid] = {};
    if (!reactions[mid][emoji]) reactions[mid][emoji] = {count:0, mine:false};
    const r = reactions[mid][emoji];
    r.mine = !r.mine; r.count += r.mine ? 1 : -1;
    if (r.count <= 0) delete reactions[mid][emoji];
    renderReactions(row, mid);
}
function renderReactions(row, msgId) {
    const container = row.querySelector('.msg-reactions');
    if (!container) return;
    container.innerHTML = '';
    const data = reactions[msgId] || {};
    Object.entries(data).forEach(([emoji, r]) => {
        if (r.count <= 0) return;
        const chip = document.createElement('div');
        chip.className = 'reaction-chip' + (r.mine ? ' mine' : '');
        chip.dataset.emoji = emoji;
        chip.innerHTML = emoji + ' <span class="cnt">' + r.count + '</span>';
        chip.onclick = () => toggleReactionChip(chip, emoji, msgId);
        container.appendChild(chip);
    });
}
document.addEventListener('click', e => {
    if (!e.target.closest('.act-btn') && !e.target.closest('.react-popup'))
        document.querySelectorAll('.react-popup.show').forEach(p => p.classList.remove('show'));
});

function triggerEmojiBurst(emoji, originEl) {
    const rect = originEl ? originEl.getBoundingClientRect() : {left:window.innerWidth/2, top:window.innerHeight/2, width:0, height:0};
    const cx = rect.left + rect.width/2, cy = rect.top + rect.height/2;
    for (let i = 0; i < 10; i++) {
        const el = document.createElement('span');
        el.className = 'emoji-burst-particle'; el.textContent = emoji;
        const angle = Math.random()*360*(Math.PI/180), dist = 120*(.4+Math.random()*.6);
        el.style.cssText = 'left:'+cx+'px;top:'+cy+'px;margin:-12px 0 0 -12px;'
            +'--tx:'+(Math.cos(angle)*dist)+'px;--ty:'+(Math.sin(angle)*dist-25)+'px;'
            +'--rot:'+((Math.random()-.5)*420)+'deg;--dur:'+(.55+Math.random()*.55)+'s;animation-delay:'+(Math.random()*.12)+'s';
        document.body.appendChild(el);
        el.addEventListener('animationend', () => el.remove());
    }
}

const EMOJI_DATA = {
    'Smileys': ['😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃','😉','😊','😇','🥰','😍','🤩','😘','😗','☺️','😚','😙','🥲','😋','😛','😜','🤪','😝','🤑','🤗','🤭','🤫','🤔','🤐','🤨','😐','😑','😶','😏','😒','🙄','😬','🤥','😌','😔','😪','🤤','😴','😷','🤒','🤕','🤢','🤧','🥵','🥶','🥴','😵','🤯','🤠','🥳','😎','🤓','🧐','😕','😟','🙁','☹️','😮','😯','😲','😳','🥺','😦','😧','😨','😰','😥','😢','😭','😱','😖','😣','😞','😓','😩','😫','🥱','😤','😡','😠','🤬','😈','👿'],
    'Gestures': ['👍','👎','👌','🤌','✌️','🤞','🤟','🤘','🤙','👈','👉','👆','🖕','👇','☝️','👋','🤚','🖐️','✋','🖖','👏','🙌','🤲','🤝','🙏','✍️','💅','🤳','💪','🦵','🦶','👂','👃'],
    'Hearts': ['❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔','❣️','💕','💞','💓','💗','💖','💘','💝','💟'],
    'Nature': ['🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮','🐷','🐸','🐵','🙈','🙉','🙊','🐔','🐧','🐦','🐤','🦆','🦅','🦉','🦇','🐺','🐗','🐴','🦄','🐝','🐛','🦋','🐌','🐞','🐜'],
    'Food': ['🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐','🍈','🍒','🍑','🥭','🍍','🥥','🥝','🍅','🍆','🥑','🥦','🍔','🍟','🍕','🌮','🌯','🍜','🍝','🍣','🍱','🧁','🍰','🎂','🍩','🍪','☕','🍺','🍷'],
    'Objects': ['📱','💻','🖥️','⌨️','🖱️','📷','📸','📹','🎥','📞','☎️','📺','📻','🔋','🔌','💡','🔦','💰','💳','💎','🔧','🔨','🛠️','🔩','🧲','✈️','🚀','🛸'],
    'Symbols': ['❤️','🔥','⭐','✨','💫','🌟','💥','🎉','🎊','🎈','🎁','🏆','🥇','🎯','🎮','🎲','⚽','🏀','🏈','⚾','🎾','🏐']
};
let currentCat = 'Smileys';

function initEmojiPicker() {
    const catsEl = document.getElementById('emojiCats'); if (!catsEl) return;
    Object.keys(EMOJI_DATA).forEach(cat => {
        const btn = document.createElement('button');
        btn.className = 'emoji-cat-btn' + (cat === currentCat ? ' active' : '');
        btn.textContent = cat;
        btn.onclick = () => { currentCat = cat; setActiveCat(cat); renderEmojis(EMOJI_DATA[cat]); };
        catsEl.appendChild(btn);
    });
    renderEmojis(EMOJI_DATA[currentCat]);
}
function setActiveCat(cat) { document.querySelectorAll('.emoji-cat-btn').forEach(b => b.classList.toggle('active', b.textContent === cat)); }
function renderEmojis(list) {
    const grid = document.getElementById('emojiGrid'); if (!grid) return;
    grid.innerHTML = '';
    list.forEach(e => { const btn = document.createElement('button'); btn.className = 'eg-btn'; btn.textContent = e; btn.onclick = () => insertEmoji(e); grid.appendChild(btn); });
}
function filterEmojis(q) { if (!q.trim()) { renderEmojis(EMOJI_DATA[currentCat]); return; } renderEmojis(Object.values(EMOJI_DATA).flat().filter(e => e.includes(q))); }
function toggleEmojiPicker() { const picker = document.getElementById('emojiPicker'); if (!picker) return; picker.classList.toggle('show'); if (picker.classList.contains('show')) document.getElementById('emojiSearch').focus(); }
function insertEmoji(e) { const inp = document.getElementById('msgInput'); if (!inp) return; const start = inp.selectionStart, end = inp.selectionEnd; inp.value = inp.value.slice(0,start) + e + inp.value.slice(end); inp.selectionStart = inp.selectionEnd = start + e.length; inp.focus(); autoResize(inp); }
document.addEventListener('click', e => { const picker = document.getElementById('emojiPicker'); const toggle = document.getElementById('emojiToggleBtn'); if (picker && toggle && !picker.contains(e.target) && e.target !== toggle) picker.classList.remove('show'); });

const hideTimers = new WeakMap();
function showActions(row) { if (hideTimers.has(row)) { clearTimeout(hideTimers.get(row)); hideTimers.delete(row); } const a = row.querySelector('.msg-actions'); if (a) a.classList.add('visible'); }
function scheduleHideActions(row) { const t = setTimeout(() => { const a = row.querySelector('.msg-actions'); if (a) a.classList.remove('visible'); hideTimers.delete(row); }, 450); hideTimers.set(row, t); }
function bindRowHover(row) { row.addEventListener('mouseenter', () => showActions(row)); row.addEventListener('mouseleave', () => scheduleHideActions(row)); const actions = row.querySelector('.msg-actions'); if (actions) { actions.addEventListener('mouseenter', () => showActions(row)); actions.addEventListener('mouseleave', () => scheduleHideActions(row)); } }
function bindAllRows() { document.querySelectorAll('#chatMsgs .msg-row').forEach(row => { if (!row.dataset.bound) { bindRowHover(row); row.dataset.bound = '1'; } }); }

document.addEventListener('DOMContentLoaded', () => {
    scrollDown(false); initEmojiPicker(); bindAllRows();
    pollTimer = setInterval(poll, 3000);
    pollUpdatesTimer = setInterval(pollUpdates, 3000);
    const inp = document.getElementById('msgInput'); if (inp) inp.focus();
});
window.addEventListener('beforeunload', () => { clearInterval(pollTimer); clearInterval(pollUpdatesTimer); });
</script>
<%@ include file="customerAIBubble.jsp" %>
</body>
</html>
