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
    Map<Integer, List<Map<String, Object>>> reactionsMap =
        (Map<Integer, List<Map<String, Object>>>) request.getAttribute("reactionsMap");
    if (reactionsMap == null) reactionsMap = new HashMap<>();
    ChatMessage pinnedMessage = (ChatMessage) request.getAttribute("pinnedMessage");

    /* Online status từ servlet */
    boolean customerOnlineInit = request.getAttribute("customerOnline") != null
        && (boolean) request.getAttribute("customerOnline");

    String meInitials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("MM/dd");

    String meAvatarUrl  = me.getAvatarUrl() != null && !me.getAvatarUrl().isEmpty()
        ? ctx + me.getAvatarUrl() : "";
    String selAvatarUrl = selCustomer != null && selCustomer.getAvatarUrl() != null && !selCustomer.getAvatarUrl().isEmpty()
        ? ctx + selCustomer.getAvatarUrl() : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Live Chat – DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
/* ── DESIGN TOKENS ── */
:root{
    --sb-bg:        #1e1b4b;
    --sb-border:    rgba(255,255,255,0.08);
    --sb-text:      rgba(255,255,255,0.45);
    --sb-accent:    #818cf8;
    --sb-accent-2:  #a5b4fc;
    --sb-item-on:   rgba(129,140,248,0.2);
    --sb-width:     252px;
    --navy:         #0b1437;
    --navy-2:       #0f1c4d;
    --accent:       #4f7ef8;
    --accent-2:     #7c9ffa;
    --accent-glow:  rgba(79,126,248,0.22);
    --green:        #34d399;
    --green-dim:    rgba(52,211,153,0.12);
    --amber:        #fbbf24;
    --amber-dim:    rgba(251,191,36,0.12);
    --danger:       #f87171;
    --danger-dim:   rgba(248,113,113,0.12);
    --purple:       #a78bfa;
    --info:         #38bdf8;
    --pink:         #fb7185;
    --text:         #ffffff;
    --text-2:       #c8d4f0;
    --muted:        #7a8ab8;
    --border:       rgba(255,255,255,0.07);
    --border-2:     rgba(255,255,255,0.04);
    --conv-width:   280px;
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html{scroll-behavior:smooth;}
body{font-family:'Sora',sans-serif;background:var(--navy);color:var(--text);height:100vh;display:flex;overflow:hidden;}
::-webkit-scrollbar{width:4px;}
::-webkit-scrollbar-track{background:var(--navy);}
::-webkit-scrollbar-thumb{background:rgba(79,126,248,0.4);border-radius:4px;}

/* ═══ SIDEBAR ═══ */
.sb{width:var(--sb-width);height:100vh;background:var(--sb-bg);border-right:1px solid rgba(79,70,229,0.2);display:flex;flex-direction:column;flex-shrink:0;box-shadow:4px 0 24px rgba(0,0,0,0.15);}
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
.sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border);}
.sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);margin-bottom:5px;text-decoration:none;transition:all .18s;cursor:pointer;}
.sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3);}
.sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
.sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%;}
.sb-uname{color:#fff;font-size:.8rem;font-weight:600;}
.sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem;margin-top:1px;}
.sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
.sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1);}

/* ═══ CONVERSATION PANEL ═══ */
.conv-panel{width:var(--conv-width);height:100vh;background:rgba(11,18,47,0.9);border-right:1px solid var(--border);display:flex;flex-direction:column;flex-shrink:0;}
.conv-hd{padding:18px 14px 12px;border-bottom:1px solid var(--border);}
.conv-hd h2{font-size:.88rem;font-weight:700;color:#fff;margin-bottom:10px;display:flex;align-items:center;gap:7px;}
.conv-hd h2 i{color:var(--pink);}
.search-box{position:relative;}
.search-box input{width:100%;padding:7px 12px 7px 32px;background:rgba(255,255,255,0.05);border:1.5px solid var(--border);border-radius:20px;font-size:.8rem;font-family:'Sora',sans-serif;color:var(--text);outline:none;transition:.2s;}
.search-box input::placeholder{color:var(--muted);}
.search-box input:focus{border-color:rgba(79,126,248,0.5);background:rgba(79,126,248,0.06);}
.search-box i{position:absolute;left:11px;top:50%;transform:translateY(-50%);color:var(--muted);font-size:.75rem;}
.conv-list{flex:1;overflow-y:auto;}
.conv-list::-webkit-scrollbar{width:3px;}
.conv-list::-webkit-scrollbar-thumb{background:rgba(79,126,248,0.3);border-radius:4px;}
.conv-item{display:flex;align-items:center;gap:10px;padding:11px 14px;cursor:pointer;transition:.15s;border-bottom:1px solid var(--border-2);position:relative;}
.conv-item:hover{background:rgba(255,255,255,0.04);}
.conv-item.active{background:rgba(79,126,248,0.1);border-left:2px solid var(--accent);}
.conv-item.active .conv-name{color:var(--accent-2);}
.c-ava{width:40px;height:40px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.88rem;font-weight:700;color:#fff;flex-shrink:0;position:relative;}
.c-ava-inner{width:40px;height:40px;border-radius:50%;display:flex;align-items:center;justify-content:center;overflow:hidden;font-size:.88rem;font-weight:700;color:#fff;}
.c-ava img{width:40px;height:40px;object-fit:cover;border-radius:50%;display:block;}
.unread-badge{position:absolute;top:-2px;right:-2px;background:var(--danger);color:#fff;font-size:.58rem;font-weight:700;padding:1px 5px;border-radius:10px;min-width:16px;text-align:center;border:2px solid rgba(11,18,47,0.9);}
.conv-info{flex:1;min-width:0;}
.conv-name{font-size:.82rem;font-weight:600;color:var(--text-2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.conv-preview{font-size:.73rem;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-top:2px;}
.conv-preview.unread{color:var(--text-2);font-weight:600;}
.conv-time{font-size:.67rem;color:var(--muted);white-space:nowrap;margin-left:4px;flex-shrink:0;}
.conv-empty{padding:30px 14px;text-align:center;color:var(--muted);}
.conv-empty i{font-size:2rem;opacity:.2;display:block;margin-bottom:8px;}
.conv-empty p{font-size:.82rem;}

/* ── SIDEBAR online dot on conv avatar ── */
.conv-online-dot{position:absolute;bottom:0px;right:0px;width:11px;height:11px;background:var(--green);border-radius:50%;border:2px solid rgba(11,18,47,0.9);box-shadow:0 0 5px rgba(52,211,153,0.7);display:none;}
.conv-online-dot.show{display:block;}

.ava-0{background:linear-gradient(135deg,#4f46e5,#7c3aed);}
.ava-1{background:linear-gradient(135deg,#0891b2,#0284c7);}
.ava-2{background:linear-gradient(135deg,#059669,#10b981);}
.ava-3{background:linear-gradient(135deg,#d97706,#f59e0b);}
.ava-4{background:linear-gradient(135deg,#dc2626,#ef4444);}
.ava-5{background:linear-gradient(135deg,#7c3aed,#a78bfa);}
.ava-6{background:linear-gradient(135deg,#db2777,#ec4899);}
.ava-7{background:linear-gradient(135deg,#0284c7,#38bdf8);}

/* ═══ CHAT AREA ═══ */
.chat-area{flex:1;display:flex;flex-direction:column;min-width:0;height:100vh;position:relative;}
.chat-empty{flex:1;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:12px;color:var(--muted);}
.chat-empty i{font-size:3rem;opacity:.12;}
.chat-empty p{font-weight:700;font-size:.92rem;color:var(--text-2);}
.chat-empty span{font-size:.8rem;}

/* ── HEADER ── */
.chat-hd{padding:0 24px;height:64px;display:flex;align-items:center;gap:14px;flex-shrink:0;background:rgba(11,20,55,0.7);backdrop-filter:blur(16px);border-bottom:1px solid var(--border);}
.chat-ava{width:40px;height:40px;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.95rem;font-weight:700;flex-shrink:0;position:relative;overflow:hidden;}
.chat-ava img{width:40px;height:40px;object-fit:cover;border-radius:50%;display:block;}
.online-dot{position:absolute;bottom:1px;right:1px;width:11px;height:11px;background:#4a5568;border-radius:50%;border:2px solid rgba(11,20,55,0.85);transition:background .4s, box-shadow .4s;}
.online-dot.online{background:var(--green);box-shadow:0 0 6px rgba(52,211,153,0.7);}
.chat-hd-info{flex:1;}
.chat-hd-name{font-size:.93rem;font-weight:700;color:#fff;}
.chat-hd-sub{font-size:.72rem;color:var(--muted);margin-top:2px;}

/* ── ONLINE STATUS TEXT ── */
.online-status-text{font-size:.7rem;font-weight:600;margin-top:2px;transition:color .4s;}
.online-status-text.online{color:var(--green);}
.online-status-text.offline{color:var(--muted);}

/* ── PIN BANNER ── */
.pin-banner{display:none;align-items:center;gap:10px;padding:8px 20px;background:rgba(251,191,36,0.07);border-bottom:1px solid rgba(251,191,36,0.15);cursor:pointer;transition:background .2s;flex-shrink:0;}
.pin-banner.show{display:flex;}
.pin-banner:hover{background:rgba(251,191,36,0.12);}
.pin-icon{color:var(--amber);font-size:.75rem;flex-shrink:0;}
.pin-text{font-size:.76rem;color:var(--text-2);flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.pin-label{font-size:.62rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:var(--amber);flex-shrink:0;}
.pin-close{width:20px;height:20px;border-radius:50%;border:none;background:rgba(255,255,255,0.06);color:var(--muted);cursor:pointer;font-size:.65rem;display:flex;align-items:center;justify-content:center;flex-shrink:0;transition:all .2s;}
.pin-close:hover{background:rgba(248,113,113,0.2);color:var(--danger);}

/* ── MESSAGES ── */
.chat-msgs{flex:1;overflow-y:auto;padding:20px 24px 12px;background:var(--navy);display:flex;flex-direction:column;gap:2px;}
.chat-msgs::-webkit-scrollbar{width:4px;}
.chat-msgs::-webkit-scrollbar-track{background:transparent;}
.chat-msgs::-webkit-scrollbar-thumb{background:rgba(79,126,248,0.3);border-radius:4px;}
.date-sep{text-align:center;margin:10px 0;}
.date-sep span{background:rgba(255,255,255,0.06);border:1px solid var(--border);color:var(--muted);font-size:.68rem;font-weight:600;padding:3px 12px;border-radius:20px;}
.msg-row{display:flex;align-items:flex-end;gap:8px;max-width:72%;position:relative;margin-bottom:4px;}
.msg-row.mine{margin-left:auto;flex-direction:row-reverse;}
.msg-row.other{margin-right:auto;}
.msg-ava{width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.75rem;font-weight:700;color:#fff;flex-shrink:0;overflow:hidden;}
.msg-ava img{width:30px;height:30px;object-fit:cover;border-radius:50%;display:block;}
.msg-ava.me{background:linear-gradient(135deg,var(--pink),#e11d48);}
.msg-content{display:flex;flex-direction:column;gap:3px;position:relative;}
.msg-row.mine .msg-content{align-items:flex-end;}
.msg-row.other .msg-content{align-items:flex-start;}
.msg-name{font-size:.68rem;color:var(--muted);font-weight:600;margin-bottom:1px;}
.msg-bubble{padding:9px 14px;border-radius:18px;font-size:.855rem;line-height:1.55;word-wrap:break-word;max-width:380px;position:relative;cursor:default;transition:filter .15s;}
.msg-bubble:hover{filter:brightness(1.08);}
.msg-row.mine .msg-bubble{background:linear-gradient(135deg,var(--pink),#e11d48);color:#fff;border-bottom-right-radius:4px;}
.msg-row.other .msg-bubble{background:rgba(17,26,66,0.9);border:1px solid var(--border);color:var(--text-2);border-bottom-left-radius:4px;}
.msg-bubble.recalled{background:rgba(255,255,255,0.03)!important;border:1px dashed rgba(255,255,255,0.12)!important;color:var(--muted)!important;font-style:italic;font-size:.78rem;}

/* ── MESSAGE STATUS (sent/delivered/read) ── */
.msg-status{font-size:.68rem;color:var(--muted);display:flex;align-items:center;gap:3px;margin-top:1px;}
.msg-status i{font-size:.62rem;}
.msg-status.delivered i{color:var(--text-2);}
.msg-status.read i{color:var(--info);}
.msg-time-row{display:flex;align-items:center;gap:5px;}
.msg-time{font-size:.64rem;color:var(--muted);padding:0 2px;}

/* ── ATTACHMENT in bubble ── */
.attach-img{max-width:240px;max-height:180px;border-radius:10px;display:block;margin-top:6px;cursor:pointer;object-fit:cover;transition:opacity .2s;}
.attach-img:hover{opacity:.88;}
.attach-file{display:flex;align-items:center;gap:8px;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.12);border-radius:10px;padding:8px 12px;margin-top:6px;text-decoration:none;transition:background .2s;max-width:240px;}
.attach-file:hover{background:rgba(255,255,255,0.14);}
.attach-file-icon{font-size:1.2rem;flex-shrink:0;color:var(--accent-2);}
.attach-file-info{min-width:0;}
.attach-file-name{font-size:.75rem;font-weight:600;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.attach-file-size{font-size:.65rem;color:var(--muted);}

/* ── REACTIONS ── */
.msg-reactions{display:flex;flex-wrap:wrap;gap:4px;margin-top:4px;}
.reaction-chip{display:inline-flex;align-items:center;gap:3px;padding:2px 7px;border-radius:20px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);font-size:.75rem;cursor:pointer;transition:all .15s;user-select:none;}
.reaction-chip:hover{background:rgba(79,126,248,0.15);border-color:rgba(79,126,248,0.3);}
.reaction-chip.mine{background:rgba(79,126,248,0.15);border-color:rgba(79,126,248,0.35);}
.reaction-chip .cnt{font-size:.68rem;color:var(--text-2);font-weight:600;}

/* ── MSG ACTIONS ── */
.msg-actions{position:absolute;top:50%;transform:translateY(-50%);display:flex;gap:4px;opacity:0;pointer-events:none;transition:opacity .2s;z-index:10;padding:8px 6px;}
.msg-row.mine .msg-actions{right:calc(100% + 2px);}
.msg-row.other .msg-actions{left:calc(100% + 2px);}
.msg-actions.visible{opacity:1;pointer-events:auto;}
.act-btn{width:34px;height:34px;border-radius:10px;border:1px solid rgba(255,255,255,0.12);background:rgba(17,26,66,0.97);color:var(--muted);cursor:pointer;font-size:.8rem;display:flex;align-items:center;justify-content:center;transition:all .15s;box-shadow:0 2px 8px rgba(0,0,0,0.35);}
.act-btn:hover{background:rgba(79,126,248,0.2);border-color:rgba(79,126,248,0.4);color:var(--accent-2);transform:scale(1.08);}
.act-btn.danger:hover{background:rgba(248,113,113,0.2);border-color:rgba(248,113,113,0.4);color:var(--danger);transform:scale(1.08);}
.act-btn.pin-act:hover{background:rgba(251,191,36,0.2);border-color:rgba(251,191,36,0.4);color:var(--amber);transform:scale(1.08);}
.act-btn.pinned-active{background:rgba(251,191,36,0.15);border-color:rgba(251,191,36,0.4);color:var(--amber);}

/* ── REACT POPUP ── */
.react-popup{position:absolute;bottom:calc(100% + 6px);display:none;background:rgba(15,28,77,0.98);border:1px solid var(--border);border-radius:14px;padding:6px 8px;gap:4px;backdrop-filter:blur(20px);box-shadow:0 8px 32px rgba(0,0,0,0.5);z-index:100;animation:popIn .15s ease;}
.react-popup.show{display:flex;}
.msg-row.mine .react-popup{right:0;}
.msg-row.other .react-popup{left:0;}
@keyframes popIn{from{opacity:0;transform:scale(.85) translateY(4px)}to{opacity:1;transform:scale(1) translateY(0)}}
.react-emoji-btn{width:32px;height:32px;border-radius:8px;border:none;background:transparent;cursor:pointer;font-size:1.1rem;display:flex;align-items:center;justify-content:center;transition:all .15s;}
.react-emoji-btn:hover{background:rgba(79,126,248,0.2);transform:scale(1.2);}

/* ── TYPING INDICATOR ── */
.typing{display:none;margin-bottom:6px;}
.typing.show{display:flex;}
.typing-bubble{background:rgba(17,26,66,0.9);border:1px solid var(--border);padding:10px 14px;border-radius:18px;border-bottom-left-radius:4px;display:flex;align-items:center;gap:4px;}
.t-dot{width:6px;height:6px;border-radius:50%;background:var(--muted);animation:taBounce 1.4s infinite ease-in-out;}
.t-dot:nth-child(2){animation-delay:.2s;}
.t-dot:nth-child(3){animation-delay:.4s;}
@keyframes taBounce{0%,60%,100%{transform:translateY(0)}30%{transform:translateY(-5px);background:var(--accent-2)}}
.typing-label{font-size:.7rem;color:var(--muted);font-style:italic;margin-left:4px;}

/* ── SCROLL TO BOTTOM BUTTON ── */
.scroll-btn{position:absolute;bottom:80px;right:24px;width:40px;height:40px;border-radius:50%;border:none;background:rgba(79,126,248,0.9);color:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:.9rem;box-shadow:0 4px 16px rgba(79,126,248,0.4);z-index:50;opacity:0;pointer-events:none;transition:all .25s;transform:translateY(8px);}
.scroll-btn.show{opacity:1;pointer-events:auto;transform:translateY(0);}
.scroll-btn:hover{background:var(--accent);box-shadow:0 6px 20px rgba(79,126,248,0.6);transform:scale(1.08);}
.scroll-btn .unread-scroll-badge{position:absolute;top:-4px;right:-4px;background:var(--danger);color:#fff;font-size:.55rem;font-weight:700;padding:1px 4px;border-radius:10px;min-width:16px;text-align:center;border:2px solid var(--navy);}

/* ── INPUT AREA ── */
.chat-input-area{background:rgba(11,20,55,0.7);backdrop-filter:blur(16px);border-top:1px solid var(--border);padding:12px 20px 14px;flex-shrink:0;position:relative;}

/* ── ATTACH PREVIEW (before send) ── */
.attach-preview{display:none;align-items:center;gap:10px;padding:8px 14px;background:rgba(255,255,255,0.04);border:1px solid var(--border);border-radius:12px;margin-bottom:10px;}
.attach-preview.show{display:flex;}
.attach-preview-img{width:48px;height:48px;border-radius:8px;object-fit:cover;flex-shrink:0;}
.attach-preview-file{display:flex;align-items:center;gap:8px;flex:1;min-width:0;}
.attach-preview-file i{color:var(--accent-2);font-size:1.4rem;flex-shrink:0;}
.attach-preview-name{font-size:.78rem;font-weight:600;color:var(--text-2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;flex:1;}
.attach-preview-remove{width:26px;height:26px;border-radius:50%;border:none;background:rgba(248,113,113,0.15);color:var(--danger);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:.72rem;flex-shrink:0;transition:all .15s;}
.attach-preview-remove:hover{background:rgba(248,113,113,0.3);}

.input-row{display:flex;gap:8px;align-items:flex-end;}
.input-wrap{flex:1;background:rgba(255,255,255,0.05);border:1.5px solid var(--border);border-radius:22px;padding:9px 14px;display:flex;align-items:center;gap:8px;transition:all .2s;}
.input-wrap:focus-within{border-color:rgba(79,126,248,0.5);background:rgba(79,126,248,0.06);box-shadow:0 0 0 3px rgba(79,126,248,0.1);}
.chat-input{flex:1;border:none;outline:none;background:transparent;font-size:.855rem;font-family:'Sora',sans-serif;color:var(--text);resize:none;max-height:100px;line-height:1.4;}
.chat-input::placeholder{color:var(--muted);}
.btn-emoji-toggle{width:28px;height:28px;border:none;background:none;color:var(--muted);cursor:pointer;font-size:1.1rem;display:flex;align-items:center;justify-content:center;border-radius:8px;transition:all .15s;flex-shrink:0;}
.btn-emoji-toggle:hover{color:var(--amber);background:rgba(251,191,36,0.1);}

/* ── ATTACH BUTTON ── */
.btn-attach{width:28px;height:28px;border:none;background:none;color:var(--muted);cursor:pointer;font-size:1rem;display:flex;align-items:center;justify-content:center;border-radius:8px;transition:all .15s;flex-shrink:0;}
.btn-attach:hover{color:var(--accent-2);background:rgba(79,126,248,0.1);}
.btn-attach.has-file{color:var(--accent-2);}

.btn-send{width:44px;height:44px;border-radius:50%;border:none;background:linear-gradient(135deg,var(--pink),#e11d48);color:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:.9rem;flex-shrink:0;transition:all .2s;box-shadow:0 4px 14px rgba(251,113,133,0.35);}
.btn-send:hover{transform:scale(1.08);box-shadow:0 6px 20px rgba(251,113,133,0.5);}
.btn-send:disabled{background:rgba(251,113,133,0.2);box-shadow:none;cursor:not-allowed;transform:none;}
.input-hint{text-align:center;font-size:.68rem;color:var(--muted);margin-top:6px;}
.input-hint strong{color:var(--text-2);}
/* hidden file input */
#fileInput{display:none;}

/* ── EMOJI PICKER ── */
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

/* ── IMAGE LIGHTBOX ── */
.lightbox{position:fixed;inset:0;background:rgba(0,0,0,0.88);z-index:9000;display:none;align-items:center;justify-content:center;animation:fadeIn .18s ease;}
.lightbox.show{display:flex;}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
.lightbox img{max-width:90vw;max-height:88vh;border-radius:12px;box-shadow:0 20px 60px rgba(0,0,0,0.6);}
.lightbox-close{position:absolute;top:18px;right:22px;width:36px;height:36px;border-radius:50%;border:none;background:rgba(255,255,255,0.1);color:#fff;cursor:pointer;font-size:1rem;display:flex;align-items:center;justify-content:center;transition:all .15s;}
.lightbox-close:hover{background:rgba(248,113,113,0.3);}

/* ── TOAST ── */
.toast{position:fixed;bottom:24px;left:50%;transform:translateX(-50%) translateY(20px);background:rgba(17,26,66,0.98);border:1px solid var(--border);color:var(--text-2);font-size:.78rem;font-weight:600;padding:8px 18px;border-radius:20px;box-shadow:0 8px 24px rgba(0,0,0,0.4);opacity:0;transition:all .3s;z-index:999;pointer-events:none;}
.toast.show{opacity:1;transform:translateX(-50%) translateY(0);}
.msg-sending{opacity:.55;}
.msg-error .msg-bubble{background:var(--danger-dim)!important;border-color:rgba(248,113,113,0.25)!important;color:var(--danger)!important;}
.emoji-burst-particle{position:fixed;pointer-events:none;font-size:1.4rem;z-index:9999;user-select:none;animation:emojiBurst var(--dur,.9s) ease-out forwards;}
@keyframes emojiBurst{0%{opacity:1;transform:translate(0,0) scale(1.2) rotate(0deg);}15%{opacity:1;transform:translate(calc(var(--tx)*.15),calc(var(--ty)*.15)) scale(1.5);}60%{opacity:.85;}100%{opacity:0;transform:translate(var(--tx),var(--ty)) scale(.15) rotate(var(--rot));}}

/* ── UPLOAD PROGRESS ── */
.upload-progress{position:absolute;bottom:0;left:0;right:0;height:3px;background:var(--accent);border-radius:0;transform-origin:left;transform:scaleX(0);transition:transform .3s ease;pointer-events:none;}
.upload-progress.active{transform:scaleX(0.6);animation:uploadAnim 1.2s ease infinite alternate;}
@keyframes uploadAnim{from{transform:scaleX(0.05)}to{transform:scaleX(0.85)}}
.upload-progress.done{transform:scaleX(1);transition:transform .15s ease;}
    </style>
</head>
<body>

<!-- ═══ LEFT NAV SIDEBAR ═══ -->
<aside class="sb">
    <div class="sb-brand">
        <div class="sb-logo"><i class="fas fa-bolt"></i></div>
        <div><div class="sb-name">DRSMS</div><div class="sb-role">Customer Support</div></div>
    </div>
    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div>
        <a href="<%=ctx%>/supportDashboard"      class="sb-item"><i class="fas fa-home"></i> Dashboard</a>
        <div class="sb-lbl">Management</div>
        <a href="<%=ctx%>/supportCustomers"       class="sb-item"><i class="fas fa-users"></i> Customers</a>
        <a href="<%=ctx%>/supportContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
        <a href="<%=ctx%>/supportServiceRequests" class="sb-item"><i class="fas fa-clipboard-list"></i> Service Requests</a>
        <div class="sb-lbl">Support</div>
        <a href="<%=ctx%>/supportChat"            class="sb-item on"><i class="fas fa-comment-dots"></i> Live Chat</a>
    </nav>
    <div class="sb-foot">
        <a href="<%=ctx%>/profile" class="sb-user">
            <div class="sb-ava">
                <%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%>
                <img src="<%=ctx%><%=me.getAvatarUrl()%>" alt="avatar">
                <%}else{%><%=meInitials%><%}%>
            </div>
            <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer Support</div></div>
        </a>
        <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
    </div>
</aside>

<!-- ═══ CONVERSATION PANEL ═══ -->
<div class="conv-panel">
    <div class="conv-hd">
        <h2><i class="fas fa-comments"></i>Live Chat</h2>
        <div class="search-box">
            <i class="fas fa-search"></i>
            <input type="text" id="searchInput" placeholder="Search customers..." oninput="filterConv(this.value)">
        </div>
    </div>
    <div class="conv-list" id="convList">
        <%
        int colorIdx = 0;
        for (Map<String, Object> conv : convList) {
            int cid        = (int) conv.get("customerId");
            String cname   = (String) conv.get("customerName");
            String cavatar = (String) conv.get("customerAvatar");
            String lastMsg = (String) conv.get("lastMessage");
            if (lastMsg != null && lastMsg.length() > 42) lastMsg = lastMsg.substring(0,42) + "…";
            int unread     = (int) conv.get("unreadCount");
            int lastSender = (int) conv.get("lastSenderId");
            Object ltObj   = conv.get("lastTime");
            String lastTime = "";
            if (ltObj != null) {
                LocalDateTime ldt = (LocalDateTime) ltObj;
                LocalDate today = LocalDate.now();
                lastTime = ldt.toLocalDate().equals(today) ? ldt.format(timeFmt) : ldt.format(dateFmt);
            }
            boolean active = (cid == selCid);
            String initL = cname != null && !cname.isEmpty() ? cname.substring(0,1).toUpperCase() : "?";
            String prefix = (lastSender == me.getId()) ? "You: " : "";
            boolean hasCAvatar = cavatar != null && !cavatar.isEmpty();
        %>
        <div class="conv-item <%=active?"active":""%>" onclick="openChat(<%=cid%>)"
             data-name="<%=cname!=null?cname.toLowerCase():""%>" id="conv-<%=cid%>">
            <div class="c-ava" style="position:relative">
                <div class="c-ava-inner <%=hasCAvatar?"":"ava-"+colorIdx%8%>">
                    <%if(hasCAvatar){%>
                    <img src="<%=ctx%><%=cavatar%>" alt="avatar">
                    <%}else{%><%=initL%><%}%>
                </div>
                <span class="unread-badge" id="badge-<%=cid%>" <%=unread>0?"":"style='display:none'"%>><%=unread>0?unread:""%></span>
                
                <span class="conv-online-dot" id="conv-dot-<%=cid%>"></span>
            </div>
            <div class="conv-info">
                <div class="conv-name"><%=cname%></div>
                <div class="conv-preview <%=unread>0?"unread":""%>" id="preview-<%=cid%>"><%=prefix%><%=lastMsg!=null?lastMsg:""%></div>
            </div>
            <div class="conv-time" id="time-<%=cid%>"><%=lastTime%></div>
        </div>
        <% colorIdx++; } %>
        <%if(convList.isEmpty()){%>
        <div class="conv-empty">
            <i class="fas fa-inbox"></i>
            <p>No conversations yet</p>
        </div>
        <%}%>
    </div>
</div>

<!-- ═══ CHAT AREA ═══ -->
<div class="chat-area">
    <%if(selCustomer == null){%>
    <div class="chat-empty">
        <i class="fas fa-comments"></i>
        <p>Select a conversation</p>
        <span>Choose a customer on the left to start chatting</span>
    </div>
    <%}else{
        String selName = selCustomer.getFullName();
        String selInit = selName != null && !selName.isEmpty() ? selName.substring(0,1).toUpperCase() : "?";
        int selColor   = selCid % 8;
        boolean hasSelAvatar = selCustomer.getAvatarUrl() != null && !selCustomer.getAvatarUrl().isEmpty();
    %>

    <!-- HEADER -->
    <div class="chat-hd">
        <div class="chat-ava <%=hasSelAvatar?"":"ava-"+selColor%>">
            <%if(hasSelAvatar){%>
            <img src="<%=ctx%><%=selCustomer.getAvatarUrl()%>" alt="avatar">
            <%}else{%><%=selInit%><%}%>
            <span class="online-dot <%=customerOnlineInit?"online":""%>" id="headerOnlineDot"></span>
        </div>
        <div class="chat-hd-info">
            <div class="chat-hd-name"><%=selName%></div>
            <div class="chat-hd-sub">
                <span class="online-status-text <%=customerOnlineInit?"online":"offline"%>" id="onlineStatusText">
                    <%=customerOnlineInit?"Online":"Offline"%>
                </span>
                <%if(selCustomer.getPhone()!=null&&!selCustomer.getPhone().isEmpty()){%>
                · <%=selCustomer.getPhone()%>
                <%}%>
                <%if(selCustomer.getEmail()!=null&&!selCustomer.getEmail().isEmpty()){%>
                · <%=selCustomer.getEmail()%>
                <%}%>
            </div>
        </div>
    </div>

    <!-- PIN BANNER -->
    <div class="pin-banner <%=pinnedMessage!=null?"show":""%>" id="pinBanner" onclick="scrollToPin()">
        <i class="fas fa-thumbtack pin-icon"></i>
        <span class="pin-label">Pinned</span>
        <span class="pin-text" id="pinText"><%=pinnedMessage!=null?pinnedMessage.getMessage().replace("<","&lt;").replace(">","&gt;"):""%></span>
        <button class="pin-close" onclick="event.stopPropagation();clearPin()"><i class="fas fa-times"></i></button>
    </div>

    <!-- MESSAGES -->
    <div class="chat-msgs" id="chatMsgs">
        <%if(messages.isEmpty()){%>
        <div class="empty-chat" id="emptyChat" style="margin:auto;text-align:center;color:var(--muted);padding:40px 24px;">
            <span style="font-size:2.8rem;display:block;margin-bottom:12px">💬</span>
            <p style="font-weight:600;font-size:.88rem;color:var(--text-2);margin-bottom:5px;">Start a conversation</p>
            <span style="font-size:.78rem;">Send a message to <%=selName%></span>
        </div>
        <%}else{
            String prevDate = "";
            for(ChatMessage m : messages){
                boolean mine = m.getSenderId() == me.getId();
                String dateStr = m.getCreatedAt()!=null ? m.getCreatedAt().toLocalDate().toString() : "";
                if(!dateStr.equals(prevDate)){prevDate=dateStr;%>
        <div class="date-sep"><span><%=dateStr%></span></div>
        <%}
            List<Map<String,Object>> msgReactions = reactionsMap.getOrDefault(m.getId(), new ArrayList<>());
            // Build attachment HTML
            String attachHtml = "";
            if(m.hasAttachment() && !m.isRecalled()){
                if(m.isImage()){
                    String au = m.getAttachmentUrl();
                    String aurl = au.startsWith("http") || au.startsWith(ctx) ? au : ctx + au;
                    attachHtml = "<img class='attach-img' src='" + aurl + "' alt='image' onclick='openLightbox(this.src)'>";
                } else {
                    String fname = m.getAttachmentName() != null ? m.getAttachmentName() : "File";
                    String au = m.getAttachmentUrl();
                    String furl = au.startsWith("http") || au.startsWith(ctx) ? au : ctx + au;
                    attachHtml = "<a class='attach-file' href='" + furl + "' download target='_blank'>" +
                        "<i class='fas fa-file-arrow-down attach-file-icon'></i>" +
                        "<div class='attach-file-info'><div class='attach-file-name'>" + fname + "</div><div class='attach-file-size'>Download</div></div>" +
                        "</a>";
                }
            }
            // Status icon for agent's messages
            String statusHtml = "";
            if(mine && !m.isRecalled()){
                String statusCls = m.isRead() ? "read" : (m.isDelivered() ? "delivered" : "");
                String statusIcon = m.isRead() ? "fa-check-double" : (m.isDelivered() ? "fa-check-double" : "fa-check");
                statusHtml = "<div class='msg-status " + statusCls + "'><i class='fas " + statusIcon + "'></i></div>";
            }
        %>
        <div class="msg-row <%=mine?"mine":"other"%>" data-id="<%=m.getId()%>" data-mine="<%=mine%>"
             <%=m.isPinned()?"data-pinned='true'":""%>>
            <div class="msg-ava <%=mine?"me":"ava-"+selColor%>">
                <%if(mine && me.getAvatarUrl()!=null && !me.getAvatarUrl().isEmpty()){%>
                <img src="<%=ctx%><%=me.getAvatarUrl()%>" alt="avatar">
                <%}else if(!mine && hasSelAvatar){%>
                <img src="<%=ctx%><%=selCustomer.getAvatarUrl()%>" alt="avatar">
                <%}else{%>
                <%=(mine?me.getFullName():selName).substring(0,1).toUpperCase()%>
                <%}%>
            </div>
            <div class="msg-content">
                <%if(!mine){%><div class="msg-name"><%=selName%></div><%}%>
                <div class="msg-bubble <%=m.isRecalled()?"recalled":""%>">
                    <%if(m.isRecalled()){%>
                        <i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled
                    <%}else{%>
                        <%if(m.getMessage() != null && !m.getMessage().isEmpty()){%>
                        <%=m.getMessage().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>")%>
                        <%}%>
                        <%=attachHtml%>
                    <%}%>
                </div>
                <div class="msg-reactions">
                    <%for(Map<String,Object> rx : msgReactions){
                        boolean rxMine = (Boolean) rx.get("mine");
                        int rxCount = (Integer) rx.get("count");
                        String rxEmoji = (String) rx.get("emoji");
                    %>
                    <div class="reaction-chip <%=rxMine?"mine":""%>" data-emoji="<%=rxEmoji%>"
                         onclick="toggleReactionChip(this,'<%=rxEmoji%>',<%=m.getId()%>)">
                        <%=rxEmoji%> <span class="cnt"><%=rxCount%></span>
                    </div>
                    <%}%>
                </div>
                <div class="msg-time-row">
                    <div class="msg-time"><%=m.getTimeFormatted()%></div>
                    <%=statusHtml%>
                </div>
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
                    <button class="act-btn pin-act <%=m.isPinned()?"pinned-active":""%>" title="<%=m.isPinned()?"Unpin":"Pin"%>" onclick="pinMsg(this)">
                        <i class="fas fa-thumbtack"></i>
                    </button>
                    <%if(mine){%>
                    <button class="act-btn danger" title="Recall" onclick="recallMsg(this)"><i class="fas fa-rotate-left"></i></button>
                    <%}%>
                </div>
                <%}%>
            </div>
        </div>
        <%}}%>

        <!-- TYPING INDICATOR -->
        <div class="msg-row other typing" id="typing">
            <div class="msg-ava <%=hasSelAvatar?"":"ava-"+selColor%>">
                <%if(hasSelAvatar){%>
                <img src="<%=ctx%><%=selCustomer.getAvatarUrl()%>" alt="avatar">
                <%}else{%><%=selInit%><%}%>
            </div>
            <div class="msg-content">
                <div class="typing-bubble">
                    <div class="t-dot"></div><div class="t-dot"></div><div class="t-dot"></div>
                </div>
            </div>
        </div>
    </div>

    <!-- SCROLL TO BOTTOM BUTTON -->
    <button class="scroll-btn" id="scrollBtn" onclick="scrollDown(true)" title="Scroll to bottom">
        <i class="fas fa-chevron-down"></i>
        <span class="unread-scroll-badge" id="scrollBadge" style="display:none"></span>
    </button>

    <!-- INPUT AREA -->
    <div class="chat-input-area">
        <div class="upload-progress" id="uploadProgress"></div>

        <!-- Attachment preview strip (before send) -->
        <div class="attach-preview" id="attachPreview">
            <img class="attach-preview-img" id="attachPreviewImg" src="" alt="" style="display:none">
            <div class="attach-preview-file" id="attachPreviewFile" style="display:none">
                <i class="fas fa-file"></i>
                <span class="attach-preview-name" id="attachPreviewName"></span>
            </div>
            <button class="attach-preview-remove" onclick="clearAttachment()" title="Remove"><i class="fas fa-times"></i></button>
        </div>

        <div class="emoji-picker" id="emojiPicker">
            <div class="emoji-cats" id="emojiCats"></div>
            <input class="emoji-search" id="emojiSearch" placeholder="Search emoji..." oninput="filterEmojis(this.value)">
            <div class="emoji-grid" id="emojiGrid"></div>
        </div>

        <div class="input-row">
            <div class="input-wrap">
                <button class="btn-emoji-toggle" id="emojiToggleBtn" title="Emoji" onclick="toggleEmojiPicker()">😊</button>
                <button class="btn-attach" id="attachBtn" title="Attach file or image" onclick="document.getElementById('fileInput').click()">
                    <i class="fas fa-paperclip"></i>
                </button>
                <input type="file" id="fileInput" accept="image/*,.pdf,.doc,.docx,.xls,.xlsx,.txt,.zip,.rar" onchange="handleFileSelect(this)">
                <textarea class="chat-input" id="msgInput"
                          placeholder="Message <%=selName%>..."
                          rows="1" onkeydown="handleKey(event)" oninput="handleInput(this)" maxlength="2000"></textarea>
            </div>
            <button class="btn-send" id="sendBtn" onclick="sendMsg()" title="Send (Enter)">
                <i class="fas fa-paper-plane"></i>
            </button>
        </div>
        <div class="input-hint"><strong>Enter</strong> to send · <strong>Shift+Enter</strong> for new line</div>
    </div>
    <%}%>
</div>

<!-- IMAGE LIGHTBOX -->
<div class="lightbox" id="lightbox" onclick="closeLightbox()">
    <button class="lightbox-close" onclick="closeLightbox()"><i class="fas fa-times"></i></button>
    <img id="lightboxImg" src="" alt="image">
</div>

<div class="toast" id="toast"></div>

<script>
 
const CTX       = '<%=ctx%>';
const MY_ID     = <%=me.getId()%>;
const MY_NAME   = '<%=me.getFullName().replace("\\","\\\\").replace("'","\\'")%>';
const SEL_CID   = <%=selCid%>;
const SEL_NAME  = '<%=selCustomer!=null?selCustomer.getFullName().replace("\\","\\\\").replace("'","\\'"):""%>';
const SEL_COLOR = <%=selCid%8%>;
const MY_AVATAR  = '<%=meAvatarUrl%>';
const SEL_AVATAR = '<%=selAvatarUrl%>';
 
let lastId = <%=lastId%>;
let pollTimer = null, pollUpdatesTimer = null, sidebarTimer = null, statusTimer = null, heartbeatTimer = null;
const renderedIds = new Set();
let pinnedMsgEl = null;
let pinnedMsgId = <%=pinnedMessage!=null?pinnedMessage.getId():0%>;
const reactions = {};
 
// ── Attachment state ──
let pendingFile = null;
let pendingFileUrl = null;
let pendingFileName = null;
let pendingFileType = null;
 
// ── Scroll badge counter ──
let unreadScrollCount = 0;
 
// ── Typing state ──
let typingTimer = null;
let isTypingSent = false;
 
document.querySelectorAll('#chatMsgs .msg-row[data-id]').forEach(el => {
    const n = parseInt(el.dataset.id);
    if (!isNaN(n) && n > 0) { renderedIds.add(n); if (el.dataset.pinned === 'true') pinnedMsgEl = el; }
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
 
/* ══════════════════════════════════════════
   SCROLL TO BOTTOM BUTTON
══════════════════════════════════════════ */
function initScrollBtn() {
    const msgs = document.getElementById('chatMsgs');
    const btn  = document.getElementById('scrollBtn');
    if (!msgs || !btn) return;
    msgs.addEventListener('scroll', () => {
        const atBottom = msgs.scrollHeight - msgs.scrollTop - msgs.clientHeight < 60;
        if (atBottom) {
            btn.classList.remove('show');
            unreadScrollCount = 0;
            updateScrollBadge();
        } else {
            btn.classList.add('show');
        }
    });
}
function isAtBottom() {
    const msgs = document.getElementById('chatMsgs');
    if (!msgs) return true;
    return msgs.scrollHeight - msgs.scrollTop - msgs.clientHeight < 80;
}
function updateScrollBadge() {
    const badge = document.getElementById('scrollBadge');
    if (!badge) return;
    if (unreadScrollCount > 0) { badge.textContent = unreadScrollCount; badge.style.display = ''; }
    else badge.style.display = 'none';
}
function scrollDown(smooth) {
    const el = document.getElementById('chatMsgs');
    if (el) el.scrollTo({top: el.scrollHeight, behavior: smooth ? 'smooth' : 'instant'});
    unreadScrollCount = 0;
    updateScrollBadge();
}
 
/* ══════════════════════════════════════════
   CUSTOMER ONLINE / OFFLINE STATUS
══════════════════════════════════════════ */
function setCustomerOnline(online) {
    const dot  = document.getElementById('headerOnlineDot');
    const txt  = document.getElementById('onlineStatusText');
    const cdot = document.getElementById('conv-dot-' + SEL_CID);
    if (dot) dot.classList.toggle('online', online);
    if (txt) {
        txt.textContent = online ? 'Online' : 'Offline';
        txt.className = 'online-status-text ' + (online ? 'online' : 'offline');
    }
    if (cdot) cdot.classList.toggle('show', online);
}
 
// FIX: pollStatus giờ đã có handler trong servlet
function pollStatus() {
    if (SEL_CID === 0) return;
    fetch(CTX + '/supportChat?action=pollStatus&customerId=' + SEL_CID)
    .then(r => r.json()).then(d => {
        setCustomerOnline(!!d.customerOnline);
        const typingEl = document.getElementById('typing');
        if (typingEl) {
            if (d.customerTyping) {
                typingEl.classList.add('show');
                if (isAtBottom()) scrollDown(true);
            } else {
                typingEl.classList.remove('show');
            }
        }
    }).catch(() => {});
}
 
/* ══════════════════════════════════════════
   HEARTBEAT — agent phải gửi presence
   để customer thấy agent là Online
══════════════════════════════════════════ */
function sendHeartbeat() {
    fetch(CTX + '/supportChat', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({action: 'heartbeat'})
    }).catch(() => {});
}
 
/* ══════════════════════════════════════════
   FILE / IMAGE ATTACHMENT
   FIX: upload endpoint đổi thành /supportChat
══════════════════════════════════════════ */
function handleFileSelect(input) {
    const file = input.files[0];
    if (!file) return;
    if (file.size > 10 * 1024 * 1024) { showToast('File too large (max 10MB)'); input.value = ''; return; }
    pendingFile = file;
    pendingFileName = file.name;
    pendingFileType = file.type.startsWith('image/') ? 'IMAGE' : 'FILE';
 
    const preview     = document.getElementById('attachPreview');
    const previewImg  = document.getElementById('attachPreviewImg');
    const previewFile = document.getElementById('attachPreviewFile');
    const previewName = document.getElementById('attachPreviewName');
    preview.classList.add('show');
    document.getElementById('attachBtn').classList.add('has-file');
 
    if (pendingFileType === 'IMAGE') {
        previewImg.src = URL.createObjectURL(file);
        previewImg.style.display = 'block';
        previewFile.style.display = 'none';
    } else {
        previewImg.style.display = 'none';
        previewFile.style.display = 'flex';
        previewName.textContent = file.name;
    }
    input.value = '';
}
 
function clearAttachment() {
    pendingFile = null; pendingFileUrl = null; pendingFileName = null; pendingFileType = null;
    document.getElementById('attachPreview').classList.remove('show');
    document.getElementById('attachBtn').classList.remove('has-file');
    document.getElementById('attachPreviewImg').src = '';
}
 
async function uploadFile(file) {
    const prog = document.getElementById('uploadProgress');
    prog.classList.add('active');
    const fd = new FormData();
    fd.append('action', 'upload');
    fd.append('file', file);
    try {
        // FIX: đổi từ /customerChat → /supportChat
        const resp = await fetch(CTX + '/supportChat', { method: 'POST', body: fd });
        const d = await resp.json();
        prog.classList.remove('active');
        prog.classList.add('done');
        setTimeout(() => prog.classList.remove('done'), 400);
        if (d.success) return d;
        showToast('Upload failed'); return null;
    } catch(e) {
        prog.classList.remove('active');
        showToast('Upload error'); return null;
    }
}
 
/* ══════════════════════════════════════════
   TYPING — gửi signal với customerId
══════════════════════════════════════════ */
function handleInput(el) {
    el.style.height = 'auto';
    el.style.height = Math.min(el.scrollHeight, 100) + 'px';
    if (SEL_CID === 0) return;
    if (!isTypingSent) {
        isTypingSent = true;
        fetch(CTX + '/supportChat', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: new URLSearchParams({action: 'typing', customerId: SEL_CID}) }).catch(() => {});
    }
    clearTimeout(typingTimer);
    // FIX 2: keepalive — gửi lại mỗi 2s để server không timeout (server timeout = 4s)
    typingTimer = setTimeout(function keepTyping() {
        const inp = document.getElementById('msgInput');
        if (inp && document.activeElement === inp && inp.value.trim().length > 0) {
            fetch(CTX + '/supportChat', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'},
                body: new URLSearchParams({action: 'typing', customerId: SEL_CID}) }).catch(() => {});
            typingTimer = setTimeout(keepTyping, 2000);
        } else {
            isTypingSent = false;
            fetch(CTX + '/supportChat', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'},
                body: new URLSearchParams({action: 'stopTyping', customerId: SEL_CID}) }).catch(() => {});
        }
    }, 2000);
}
 
/* ══════════════════════════════════════════
   LIGHTBOX
══════════════════════════════════════════ */
function openLightbox(src) {
    document.getElementById('lightboxImg').src = src;
    document.getElementById('lightbox').classList.add('show');
}
function closeLightbox() {
    document.getElementById('lightbox').classList.remove('show');
}
 
/* ══════════════════════════════════════════
   MISC HELPERS
══════════════════════════════════════════ */
function autoResize(el) { el.style.height = 'auto'; el.style.height = Math.min(el.scrollHeight, 100) + 'px'; }
function handleKey(e) { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMsg(); } }
function nowTime() { return new Date().toLocaleTimeString('en-US',{hour:'2-digit',minute:'2-digit',hour12:false}); }
function showToast(msg, duration) {
    const t = document.getElementById('toast'); t.textContent = msg; t.classList.add('show');
    setTimeout(() => t.classList.remove('show'), duration || 2200);
}
function openChat(cid) {
    const badge   = document.getElementById('badge-' + cid);
    const preview = document.getElementById('preview-' + cid);
    if (badge)   { badge.textContent = ''; badge.style.display = 'none'; }
    if (preview) { preview.classList.remove('unread'); }
    window.location.href = CTX + '/supportChat?customerId=' + cid;
}
function filterConv(q) {
    q = q.toLowerCase().trim();
    document.querySelectorAll('#convList .conv-item').forEach(el => {
        el.style.display = (!q || (el.dataset.name||'').includes(q)) ? '' : 'none';
    });
}
 
/* ══════════════════════════════════════════
   BUILD MSG ROW HTML
══════════════════════════════════════════ */
function buildAvatarHtml(isMine) {
    const url    = isMine ? MY_AVATAR : SEL_AVATAR;
    const letter = (isMine ? MY_NAME : SEL_NAME).substring(0,1).toUpperCase();
    const cls    = isMine ? 'me' : 'ava-' + SEL_COLOR;
    if (url) return '<div class="msg-ava ' + cls + '"><img src="' + url + '" alt="avatar"></div>';
    return '<div class="msg-ava ' + cls + '">' + letter + '</div>';
}
 
// customerChat.jsp và supportChat.jsp — thêm CTX check:
const buildAttachHtml=m=>{
    if(!m.attachmentUrl)return '';
    const url=m.attachmentUrl.startsWith('http')||m.attachmentUrl.startsWith(CTX)
        ? m.attachmentUrl : CTX+m.attachmentUrl;
    if(m.attachmentType==='IMAGE')
        return '<img class="attach-img" src="'+url+'" alt="image" onclick="openLightbox(this.src)">';
    const fname=m.attachmentName||'File';
    return '<a class="attach-file" href="'+url+'" download target="_blank"><i class="fas fa-file-arrow-down attach-file-icon"></i><div><div class="attach-file-name">'+fname+'</div><div class="attach-file-size">Download</div></div></a>';
};
 
function buildStatusHtml(m, isMine) {
    if (!isMine || m.recalled) return '';
    const isRead      = m.read === true;
    const isDelivered = m.delivered === true;
    const cls  = isRead ? 'read' : (isDelivered ? 'delivered' : '');
    const icon = isRead ? 'fa-check-double' : (isDelivered ? 'fa-check-double' : 'fa-check');
    return '<div class="msg-status ' + cls + '"><i class="fas ' + icon + '"></i></div>';
}
 
function buildMsgRow(m, isMine) {
    const row = document.createElement('div');
    row.className = 'msg-row ' + (isMine ? 'mine' : 'other');
    if (m.id && String(m.id).indexOf('temp') === -1) row.dataset.id = m.id;
    row.dataset.mine = isMine;
 
    const isRecalled = m.recalled === true;
    const safe = isRecalled ? '' : String(m.message || '')
        .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\n/g,'<br>');
    const nameHtml = !isMine ? '<div class="msg-name">' + SEL_NAME + '</div>' : '';
 
    let bubbleContent = '';
    if (isRecalled) {
        bubbleContent = '<i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled';
    } else {
        if (safe) bubbleContent += safe;
        bubbleContent += buildAttachHtml(m);
    }
 
    const recallBtn = (!isRecalled && isMine)
        ? '<button class="act-btn danger" title="Recall" onclick="recallMsg(this)"><i class="fas fa-rotate-left"></i></button>' : '';
    const actionsHtml = isRecalled ? '' :
        '<div class="msg-actions"><div style="position:relative">' +
        '<button class="act-btn" title="React" onclick="toggleReactPopup(this)"><i class="fas fa-face-smile"></i></button>' +
        '<div class="react-popup">' +
        ['👍','❤️','😂','😮','😢','🔥'].map(e =>
            '<button class="react-emoji-btn" onclick="addReaction(this,\'' + e + '\')">' + e + '</button>'
        ).join('') + '</div></div>' +
        '<button class="act-btn pin-act" title="Pin" onclick="pinMsg(this)"><i class="fas fa-thumbtack"></i></button>' +
        recallBtn + '</div>';
 
    let reactionsHtml = '<div class="msg-reactions">';
    if (m.reactions && Array.isArray(m.reactions)) {
        m.reactions.forEach(rx => {
            if (rx.count > 0)
                reactionsHtml += '<div class="reaction-chip ' + (rx.mine?'mine':'') + '" data-emoji="' + rx.emoji + '" onclick="toggleReactionChip(this,\'' + rx.emoji + '\',' + m.id + ')">' + rx.emoji + ' <span class="cnt">' + rx.count + '</span></div>';
        });
    }
    reactionsHtml += '</div>';
 
    row.innerHTML =
        buildAvatarHtml(isMine) +
        '<div class="msg-content">' + nameHtml +
        '<div class="msg-bubble' + (isRecalled?' recalled':'') + '">' + bubbleContent + '</div>' +
        reactionsHtml +
        '<div class="msg-time-row"><div class="msg-time">' + (m.time||nowTime()) + '</div>' + buildStatusHtml(m, isMine) + '</div>' +
        actionsHtml + '</div>';
    return row;
}
 
function appendMsg(m) {
    const container = document.getElementById('chatMsgs'); if (!container) return null;
    const emp = document.getElementById('emptyChat'); if (emp) emp.remove();
    const typing = document.getElementById('typing');
    const isMine = (m.senderId === MY_ID || m.mine === true);
    const row = buildMsgRow(m, isMine);
    if (typing) container.insertBefore(row, typing); else container.appendChild(row);
    if (!row.dataset.bound) { bindRowHover(row); row.dataset.bound = '1'; }
 
    if (isAtBottom()) {
        scrollDown(true);
    } else if (!isMine) {
        unreadScrollCount++;
        updateScrollBadge();
        document.getElementById('scrollBtn').classList.add('show');
    }
    return row;
}
 
/* ══════════════════════════════════════════
   SEND MESSAGE
══════════════════════════════════════════ */
async function sendMsg() {
    if (SEL_CID === 0) return;
    const inp  = document.getElementById('msgInput');
    const btn  = document.getElementById('sendBtn');
    const text = inp.value.trim();
    if (!text && !pendingFile) return;
 
    clearTimeout(typingTimer); isTypingSent = false;
    fetch(CTX + '/supportChat', { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: new URLSearchParams({action: 'stopTyping', customerId: SEL_CID}) }).catch(() => {});
 
    btn.disabled = true; inp.disabled = true;
 
    let uploadResult = null;
    if (pendingFile) {
        uploadResult = await uploadFile(pendingFile);
        if (!uploadResult) { btn.disabled = false; inp.disabled = false; return; }
    }
 
    const tempMsg = {
        id: 'temp_' + Date.now(), senderId: MY_ID, senderName: MY_NAME, mine: true,
        message: text, time: nowTime(), recalled: false,
        attachmentUrl:  uploadResult ? uploadResult.url  : null,
        attachmentName: uploadResult ? uploadResult.name : null,
        attachmentType: uploadResult ? uploadResult.type : null
    };
    const tempEl = appendMsg(tempMsg);
    if (tempEl) tempEl.classList.add('msg-sending');
 
    inp.value = ''; inp.style.height = 'auto';
    const hadFile = !!pendingFile;
    clearAttachment();
 
    const params = new URLSearchParams();
    params.append('customerId', SEL_CID);
    if (text) params.append('message', text);
    if (uploadResult) {
        params.append('attachmentUrl',  uploadResult.url);
        params.append('attachmentName', uploadResult.name);
        params.append('attachmentType', uploadResult.type);
    }
 
    fetch(CTX + '/supportChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body: params })
    .then(r => r.json()).then(d => {
        if (d.success && d.id) {
            if (tempEl) { tempEl.dataset.id = d.id; tempEl.classList.remove('msg-sending'); renderedIds.add(d.id);
    setTimeout(pollUpdates, 300);
                }
            if (d.id > lastId) lastId = d.id;
            const preview = document.getElementById('preview-' + SEL_CID);
            const timeel  = document.getElementById('time-' + SEL_CID);
            if (preview) { preview.textContent = 'You: ' + (text || (hadFile ? '📎 Attachment' : '')); preview.classList.remove('unread'); }
            if (timeel)  { const now = new Date(); timeel.textContent = now.getHours().toString().padStart(2,'0') + ':' + now.getMinutes().toString().padStart(2,'0'); }
            const convListEl = document.getElementById('convList');
            const convEl = document.getElementById('conv-' + SEL_CID);
            if (convListEl && convEl) convListEl.prepend(convEl);
        } else { if (tempEl) tempEl.classList.add('msg-error'); }
    }).catch(() => { if (tempEl) tempEl.classList.add('msg-error'); })
    .finally(() => { btn.disabled = false; inp.disabled = false; inp.focus(); });
}
 
/* ══════════════════════════════════════════
   POLL — new messages
══════════════════════════════════════════ */
function poll() {
    if (SEL_CID === 0) return;
    fetch(CTX + '/supportChat?action=poll&customerId=' + SEL_CID + '&lastId=' + lastId)
    .then(r => r.json()).then(newMsgs => {
        if (!Array.isArray(newMsgs) || !newMsgs.length) return;
        newMsgs.forEach(m => {
            if (!renderedIds.has(m.id)) {
                renderedIds.add(m.id);
                if (m.id > lastId) lastId = m.id;
                if (m.senderId !== MY_ID) {
                    appendMsg(m);
                    const preview = document.getElementById('preview-' + SEL_CID);
                    const timeel  = document.getElementById('time-' + SEL_CID);
                    const msg = m.message || (m.attachmentUrl ? '📎 Attachment' : '');
                    if (preview) { preview.textContent = msg.length > 42 ? msg.substring(0,42) + '…' : msg; preview.classList.remove('unread'); }
                    if (timeel)  { const t = m.time || ''; timeel.textContent = t ? t.substring(0,5) : ''; }
                }
            }
        });
    }).catch(() => {});
}
 
/* ══════════════════════════════════════════
   POLL UPDATES — recall / pin / reactions / status ticks
══════════════════════════════════════════ */
function pollUpdates() {
    if (SEL_CID === 0) return;
    fetch(CTX + '/supportChat?action=pollUpdates&customerId=' + SEL_CID)
    .then(r => r.json()).then(allMsgs => {
        if (!Array.isArray(allMsgs)) return;
        allMsgs.forEach(m => {
            const mid = String(m.id);
            const existingRow = document.querySelector('#chatMsgs .msg-row[data-id="' + mid + '"]');
            if (!existingRow) return;
            const isMine = existingRow.dataset.mine === 'true';
 
            // Recall
            if (m.recalled) {
                const bubble = existingRow.querySelector('.msg-bubble');
                if (bubble && !bubble.classList.contains('recalled')) {
                    bubble.classList.add('recalled');
                    bubble.innerHTML = '<i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled';
                    const acts = existingRow.querySelector('.msg-actions'); if (acts) acts.style.display = 'none';
                    const pb = document.getElementById('pinBanner');
                    if (pinnedMsgEl === existingRow && pb) { pinnedMsgEl = null; pinnedMsgId = 0; pb.classList.remove('show'); }
                }
            }
 
           // Reactions
            if (m.reactions && Array.isArray(m.reactions)) {
                reactions[mid] = {};
                m.reactions.forEach(rx => { if (rx.count > 0) reactions[mid][rx.emoji] = {count: rx.count, mine: rx.mine}; });
                renderReactions(existingRow, mid);
            }
 
            // Pin
            const pb = document.getElementById('pinBanner'), pt = document.getElementById('pinText');
            if (m.pinned) {
                if (String(pinnedMsgId) !== mid) {
                    if (pinnedMsgEl) { const ob = pinnedMsgEl.querySelector('.pin-act'); if(ob) ob.classList.remove('pinned-active'); pinnedMsgEl.removeAttribute('data-pinned'); }
                    pinnedMsgId = mid; pinnedMsgEl = existingRow; existingRow.dataset.pinned = 'true';
                    const pinBtn = existingRow.querySelector('.pin-act'); if (pinBtn) pinBtn.classList.add('pinned-active');
                    // FIX 1: lấy text nodes, bỏ qua img/a → pin text không bị lỗi
                    if (pt) {
                        const bubble = existingRow.querySelector('.msg-bubble');
                        let txt = '';
                        if (bubble) { bubble.childNodes.forEach(node => { if (node.nodeType === Node.TEXT_NODE) txt += node.textContent; else if (node.tagName === 'BR') txt += ' '; }); }
                        pt.textContent = txt.trim() || '📎 Attachment';
                    }
                    if (pb) pb.classList.add('show');
                }
            } else {
                if (pinnedMsgEl === existingRow) {
                    pinnedMsgEl = null; pinnedMsgId = 0; existingRow.removeAttribute('data-pinned');
                    const pinBtn = existingRow.querySelector('.pin-act'); if (pinBtn) pinBtn.classList.remove('pinned-active');
                    if (pb) pb.classList.remove('show');
                }
            }
 
            // Read/Delivered tick
            if (isMine && !m.recalled) { updateMsgStatus(existingRow, m.read, m.delivered); }
        });
    }).catch(() => {});
}
 
function updateMsgStatus(row, isRead, isDelivered) {
    let statusEl = row.querySelector('.msg-status');
    if (!statusEl) {
        const timeRow = row.querySelector('.msg-time-row');
        if (!timeRow) return;
        statusEl = document.createElement('div');
        statusEl.className = 'msg-status';
        timeRow.appendChild(statusEl);
    }
    const cls  = isRead ? 'read' : (isDelivered ? 'delivered' : '');
    const icon = isRead ? 'fa-check-double' : (isDelivered ? 'fa-check-double' : 'fa-check');
    statusEl.className = 'msg-status ' + cls;
    statusEl.innerHTML = '<i class="fas ' + icon + '"></i>';
}
 
/* ══════════════════════════════════════════
   POLL SIDEBAR
══════════════════════════════════════════ */
function pollSidebar() {
    fetch(CTX + '/supportChat?action=pollSidebar')
    .then(r => r.json()).then(list => {
        if (!Array.isArray(list)) return;
        list.forEach(item => {
            const badge   = document.getElementById('badge-'   + item.customerId);
            const preview = document.getElementById('preview-' + item.customerId);
            const timeel  = document.getElementById('time-'    + item.customerId);
            const cdot    = document.getElementById('conv-dot-'+ item.customerId);
 
            if (badge) {
                if (item.unreadCount > 0 && item.customerId !== SEL_CID) { badge.textContent = item.unreadCount; badge.style.display = ''; }
                else badge.style.display = 'none';
            }
            if (item.customerId === SEL_CID) { const p = document.getElementById('preview-' + item.customerId); if (p) p.classList.remove('unread'); }
            if (preview && item.customerId !== SEL_CID) {
                preview.textContent = (item.lastSenderId === MY_ID ? 'You: ' : '') + (item.lastMessage || '');
                preview.className = 'conv-preview' + (item.unreadCount > 0 ? ' unread' : '');
            }
            if (timeel) timeel.textContent = item.lastTime ? item.lastTime.substring(11, 16) : '';
            if (cdot && item.isOnline !== undefined) cdot.classList.toggle('show', !!item.isOnline);
        });
        const convListEl = document.getElementById('convList');
        if (!convListEl) return;
        for (let i = list.length - 1; i >= 0; i--) {
            const el = document.getElementById('conv-' + list[i].customerId);
            if (el) convListEl.prepend(el);
        }
    }).catch(() => {});
}
 
/* ══════════════════════════════════════════
   RECALL / PIN
══════════════════════════════════════════ */
function recallMsg(btn) {
    const row = btn.closest('.msg-row'); if (!row) return;
    const msgId = row.dataset.id;
    if (!msgId || msgId.indexOf('temp') !== -1) { showToast('Cannot recall unsent message'); return; }
    if (!confirm('Recall this message?')) return;
    const bubble = row.querySelector('.msg-bubble');
    bubble.classList.add('recalled');
    bubble.innerHTML = '<i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled';
    const actions = row.querySelector('.msg-actions'); if (actions) actions.style.display = 'none';
    if (pinnedMsgEl === row) { pinnedMsgEl = null; pinnedMsgId = 0; document.getElementById('pinBanner').classList.remove('show'); }
    showToast('Message recalled ✓');
    fetch(CTX + '/supportChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
        body: new URLSearchParams({action:'recall', messageId: msgId}) }).catch(() => {});
}
 
function pinMsg(btn) {
    const row = btn.closest('.msg-row'); if (!row) return;
    const bubble = row.querySelector('.msg-bubble');
    if (bubble.classList.contains('recalled')) { showToast('Cannot pin a recalled message'); return; }
    const msgId = row.dataset.id;
    if (!msgId || msgId.indexOf('temp') !== -1) { showToast('Cannot pin unsent message'); return; }
    const isAlreadyPinned = (String(pinnedMsgId) === String(msgId));
    if (pinnedMsgEl) { const ob = pinnedMsgEl.querySelector('.pin-act'); if(ob) ob.classList.remove('pinned-active'); pinnedMsgEl.removeAttribute('data-pinned'); }
    if (isAlreadyPinned) { pinnedMsgEl = null; pinnedMsgId = 0; document.getElementById('pinBanner').classList.remove('show'); showToast('Pin removed'); }
    else {
        pinnedMsgEl = row; pinnedMsgId = msgId; row.dataset.pinned = 'true'; btn.classList.add('pinned-active');
        document.getElementById('pinText').textContent = bubble.innerText.trim();
        document.getElementById('pinBanner').classList.add('show');
        bubble.style.outline = '2px solid var(--amber)'; setTimeout(() => bubble.style.outline = '', 1500);
        showToast('Message pinned 📌');
    }
    fetch(CTX + '/supportChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
        body: new URLSearchParams({action:'pin', messageId: msgId, customerId: SEL_CID}) }).catch(() => {});
}
 
function scrollToPin() {
    if (!pinnedMsgEl) return;
    pinnedMsgEl.scrollIntoView({behavior:'smooth', block:'center'});
    const bubble = pinnedMsgEl.querySelector('.msg-bubble');
    if (bubble) { bubble.style.outline = '2px solid var(--amber)'; setTimeout(() => bubble.style.outline = '', 1500); }
}
 
function clearPin() {
    if (pinnedMsgEl) { const ob = pinnedMsgEl.querySelector('.pin-act'); if(ob) ob.classList.remove('pinned-active'); pinnedMsgEl.removeAttribute('data-pinned'); }
    const oldId = pinnedMsgId; pinnedMsgEl = null; pinnedMsgId = 0;
    document.getElementById('pinBanner').classList.remove('show');
    showToast('Pin removed');
    if (oldId) { fetch(CTX + '/supportChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
        body: new URLSearchParams({action:'pin', messageId: oldId, customerId: SEL_CID}) }).catch(() => {}); }
}
 
/* ══════════════════════════════════════════
   REACTIONS
══════════════════════════════════════════ */
function toggleReactPopup(btn) {
    document.querySelectorAll('.react-popup.show').forEach(p => { if (p !== btn.nextElementSibling) p.classList.remove('show'); });
    btn.nextElementSibling.classList.toggle('show');
}
function addReaction(btn, emoji) {
    const popup = btn.closest('.react-popup'), row = btn.closest('.msg-row'), msgId = row ? row.dataset.id : null;
    if (!msgId || msgId.indexOf('temp') !== -1) return;
    triggerEmojiBurst(emoji, btn); popup.classList.remove('show'); _toggleReactionLocal(row, msgId, emoji);
    fetch(CTX + '/supportChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
        body: new URLSearchParams({action:'react', messageId: msgId, emoji: emoji, customerId: SEL_CID}) }).catch(() => {});
}
function toggleReactionChip(chip, emoji, msgId) {
    const row = chip.closest('.msg-row'); if (!row) return;
    const mid = String(msgId); triggerEmojiBurst(emoji, chip); _toggleReactionLocal(row, mid, emoji);
    fetch(CTX + '/supportChat', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
        body: new URLSearchParams({action:'react', messageId: mid, emoji: emoji, customerId: SEL_CID}) }).catch(() => {});
}
function _toggleReactionLocal(row, mid, emoji) {
    if (!reactions[mid]) reactions[mid] = {};
    if (!reactions[mid][emoji]) reactions[mid][emoji] = {count:0, mine:false};
    const r = reactions[mid][emoji]; r.mine = !r.mine; r.count += r.mine ? 1 : -1;
    if (r.count <= 0) delete reactions[mid][emoji]; renderReactions(row, mid);
}
function renderReactions(row, msgId) {
    const container = row.querySelector('.msg-reactions'); if (!container) return;
    container.innerHTML = ''; const data = reactions[msgId] || {};
    Object.entries(data).forEach(([emoji, r]) => {
        if (r.count <= 0) return;
        const chip = document.createElement('div');
        chip.className = 'reaction-chip' + (r.mine ? ' mine' : ''); chip.dataset.emoji = emoji;
        chip.innerHTML = emoji + ' <span class="cnt">' + r.count + '</span>';
        chip.onclick = () => toggleReactionChip(chip, emoji, msgId);
        container.appendChild(chip);
    });
}
document.addEventListener('click', e => {
    if (!e.target.closest('.act-btn') && !e.target.closest('.react-popup'))
        document.querySelectorAll('.react-popup.show').forEach(p => p.classList.remove('show'));
});
 
/* ══════════════════════════════════════════
   EMOJI BURST
══════════════════════════════════════════ */
function triggerEmojiBurst(emoji, originEl) {
    const rect = originEl ? originEl.getBoundingClientRect() : {left:window.innerWidth/2,top:window.innerHeight/2,width:0,height:0};
    const cx = rect.left + rect.width/2, cy = rect.top + rect.height/2;
    for (let i = 0; i < 10; i++) {
        const el = document.createElement('span'); el.className = 'emoji-burst-particle'; el.textContent = emoji;
        const angle = Math.random()*360*(Math.PI/180), dist = 120*(.4+Math.random()*.6);
        el.style.cssText = 'left:'+cx+'px;top:'+cy+'px;margin:-12px 0 0 -12px;--tx:'+(Math.cos(angle)*dist)+'px;--ty:'+(Math.sin(angle)*dist-25)+'px;--rot:'+((Math.random()-.5)*420)+'deg;--dur:'+(.55+Math.random()*.55)+'s;animation-delay:'+(Math.random()*.12)+'s';
        document.body.appendChild(el); el.addEventListener('animationend', () => el.remove());
    }
}
 
/* ══════════════════════════════════════════
   EMOJI PICKER
══════════════════════════════════════════ */
const EMOJI_DATA={'Smileys':['😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃','😉','😊','😇','🥰','😍','🤩','😘','😗','☺️','😚','😙','🥲','😋','😛','😜','🤪','😝','🤑','🤗','🤭','🤫','🤔','🤐','🤨','😐','😑','😶','😏','😒','🙄','😬','🤥','😌','😔','😪','🤤','😴','😷','🤒','🤕','🤢','🤧','🥵','🥶','🥴','😵','🤯','🤠','🥳','😎','🤓','🧐','😕','😟','🙁','☹️','😮','😯','😲','😳','🥺','😦','😧','😨','😰','😥','😢','😭','😱','😖','😣','😞','😓','😩','😫','🥱','😤','😡','😠','🤬','😈','👿'],'Gestures':['👍','👎','👌','🤌','✌️','🤞','🤟','🤘','🤙','👈','👉','👆','🖕','👇','☝️','👋','🤚','🖐️','✋','🖖','👏','🙌','🤲','🤝','🙏','✍️','💅','🤳','💪','🦵','🦶','👂','👃'],'Hearts':['❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔','❣️','💕','💞','💓','💗','💖','💘','💝','💟'],'Nature':['🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮','🐷','🐸','🐵','🙈','🙉','🙊','🐔','🐧','🐦','🐤','🦆','🦅','🦉','🦇','🐺','🐗','🐴','🦄','🐝','🐛','🦋','🐌','🐞','🐜'],'Food':['🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐','🍈','🍒','🍑','🥭','🍍','🥥','🥝','🍅','🍆','🥑','🥦','🍔','🍟','🍕','🌮','🌯','🍜','🍝','🍣','🍱','🧁','🍰','🎂','🍩','🍪','☕','🍺','🍷'],'Objects':['📱','💻','🖥️','⌨️','🖱️','📷','📸','📹','🎥','📞','☎️','📺','📻','🔋','🔌','💡','🔦','💰','💳','💎','🔧','🔨','🛠️','🔩','🧲','✈️','🚀','🛸'],'Symbols':['❤️','🔥','⭐','✨','💫','🌟','💥','🎉','🎊','🎈','🎁','🏆','🥇','🎯','🎮','🎲','⚽','🏀','🏈','⚾','🎾','🏐']};
let currentCat = 'Smileys';
function initEmojiPicker(){
    const catsEl = document.getElementById('emojiCats'); if (!catsEl) return;
    Object.keys(EMOJI_DATA).forEach(cat => {
        const btn = document.createElement('button'); btn.className = 'emoji-cat-btn' + (cat===currentCat?' active':'');
        btn.textContent = cat; btn.onclick = () => { currentCat = cat; setActiveCat(cat); renderEmojis(EMOJI_DATA[cat]); };
        catsEl.appendChild(btn);
    });
    renderEmojis(EMOJI_DATA[currentCat]);
}
function setActiveCat(cat){ document.querySelectorAll('.emoji-cat-btn').forEach(b => b.classList.toggle('active', b.textContent===cat)); }
function renderEmojis(list){
    const grid = document.getElementById('emojiGrid'); if (!grid) return; grid.innerHTML = '';
    list.forEach(e => { const btn = document.createElement('button'); btn.className = 'eg-btn'; btn.textContent = e; btn.onclick = () => insertEmoji(e); grid.appendChild(btn); });
}
function filterEmojis(q){
    if (!q.trim()) { renderEmojis(EMOJI_DATA[currentCat]); return; }
    renderEmojis(Object.values(EMOJI_DATA).flat().filter(e => e.includes(q)));
}
function toggleEmojiPicker(){
    const picker = document.getElementById('emojiPicker'); if (!picker) return;
    picker.classList.toggle('show');
    if (picker.classList.contains('show')) document.getElementById('emojiSearch').focus();
}
function insertEmoji(e){
    const inp = document.getElementById('msgInput'); if (!inp) return;
    const start = inp.selectionStart, end = inp.selectionEnd;
    inp.value = inp.value.slice(0,start) + e + inp.value.slice(end);
    inp.selectionStart = inp.selectionEnd = start + e.length;
    inp.focus(); autoResize(inp);
}
document.addEventListener('click', e => {
    const picker = document.getElementById('emojiPicker'), toggle = document.getElementById('emojiToggleBtn');
    if (picker && toggle && !picker.contains(e.target) && e.target !== toggle) picker.classList.remove('show');
});
 
/* ══════════════════════════════════════════
   ROW HOVER — show/hide action buttons
══════════════════════════════════════════ */
const hideTimers = new WeakMap();
function showActions(row){ if (hideTimers.has(row)){ clearTimeout(hideTimers.get(row)); hideTimers.delete(row); } const a = row.querySelector('.msg-actions'); if (a) a.classList.add('visible'); }
function scheduleHideActions(row){ const t = setTimeout(() => { const a = row.querySelector('.msg-actions'); if (a) a.classList.remove('visible'); hideTimers.delete(row); }, 450); hideTimers.set(row,t); }
function bindRowHover(row){ row.addEventListener('mouseenter', () => showActions(row)); row.addEventListener('mouseleave', () => scheduleHideActions(row)); const actions = row.querySelector('.msg-actions'); if (actions){ actions.addEventListener('mouseenter', () => showActions(row)); actions.addEventListener('mouseleave', () => scheduleHideActions(row)); } }
function bindAllRows(){ document.querySelectorAll('#chatMsgs .msg-row').forEach(row => { if (!row.dataset.bound){ bindRowHover(row); row.dataset.bound = '1'; } }); }
 
/* ══════════════════════════════════════════
   INIT
══════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', () => {
    scrollDown(false);
    initEmojiPicker();
    bindAllRows();
    initScrollBtn();
 
    if (SEL_CID > 0) {
        pollTimer        = setInterval(poll,        3000);
        pollUpdatesTimer = setInterval(pollUpdates, 1500);
        statusTimer      = setInterval(pollStatus,  5000);
        pollStatus(); // immediate first call
 
        const badge   = document.getElementById('badge-'   + SEL_CID);
        const preview = document.getElementById('preview-' + SEL_CID);
        if (badge)   { badge.textContent = ''; badge.style.display = 'none'; }
        if (preview) { preview.classList.remove('unread'); }
    }
    sidebarTimer = setInterval(pollSidebar, 5000);
 
    // FIX: heartbeat cho agent — để customer thấy agent online
    sendHeartbeat();
    heartbeatTimer = setInterval(sendHeartbeat, 20000);
 
    const inp = document.getElementById('msgInput'); if (inp) inp.focus();
});
 
window.addEventListener('beforeunload', () => {
    clearInterval(pollTimer); clearInterval(pollUpdatesTimer);
    clearInterval(sidebarTimer); clearInterval(statusTimer);
    clearInterval(heartbeatTimer);
    clearTimeout(typingTimer);
    // Mark agent offline
    navigator.sendBeacon(CTX + '/supportChat',
        new URLSearchParams({action: 'offline'}));
    if (isTypingSent && SEL_CID > 0) {
        navigator.sendBeacon(CTX + '/supportChat',
            new URLSearchParams({action: 'stopTyping', customerId: SEL_CID}));
    }
});

</script>
</body>
</html>
