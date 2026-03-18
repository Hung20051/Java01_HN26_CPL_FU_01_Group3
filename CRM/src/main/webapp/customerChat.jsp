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
    boolean agentOnlineInit = request.getAttribute("agentOnline") != null && (boolean)request.getAttribute("agentOnline");
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    String initials=me.getFullName()!=null&&!me.getFullName().isEmpty()?me.getFullName().substring(0,1).toUpperCase():"?";
    String myAvatarUrl    = me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty() ? ctx+me.getAvatarUrl() : "";
    String agentAvatarUrl = agent!=null&&agent.getAvatarUrl()!=null&&!agent.getAvatarUrl().isEmpty() ? ctx+agent.getAvatarUrl() : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Support Chat - DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
:root{--sb-bg:#1e1b4b;--sb-border:rgba(255,255,255,0.08);--sb-text:rgba(255,255,255,0.45);--sb-accent:#818cf8;--sb-accent-2:#a5b4fc;--sb-item-on:rgba(129,140,248,0.2);--sb-width:252px;--navy:#0b1437;--accent:#4f7ef8;--accent-2:#7c9ffa;--accent-glow:rgba(79,126,248,0.22);--green:#34d399;--amber:#fbbf24;--danger:#f87171;--danger-dim:rgba(248,113,113,0.12);--info:#38bdf8;--purple:#a78bfa;--text:#ffffff;--text-2:#c8d4f0;--muted:#7a8ab8;--border:rgba(255,255,255,0.07);}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}html{scroll-behavior:smooth;}
body{font-family:'Sora',sans-serif;background:var(--navy);color:var(--text);min-height:100vh;display:flex;}
::-webkit-scrollbar{width:4px;}::-webkit-scrollbar-track{background:transparent;}::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px;}
.sb{width:var(--sb-width);min-height:100vh;background:var(--sb-bg);border-right:1px solid rgba(79,70,229,0.2);display:flex;flex-direction:column;position:fixed;top:0;left:0;z-index:100;box-shadow:4px 0 24px rgba(0,0,0,0.15);}
.sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border);}
.sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#818cf8,#a78bfa);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;box-shadow:0 4px 12px rgba(129,140,248,0.4);flex-shrink:0;}
.sb-name{color:#fff;font-size:1.05rem;font-weight:800;letter-spacing:-.3px;}
.sb-role{display:inline-flex;align-items:center;background:rgba(129,140,248,0.2);border:1px solid rgba(129,140,248,0.3);color:var(--sb-accent-2);font-size:.6rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:2px 8px;border-radius:20px;margin-top:3px;}
.sb-nav{flex:1;padding:12px 10px;overflow-y:auto;}
.sb-lbl{color:rgba(255,255,255,0.22);font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:1.6px;padding:0 8px;margin:14px 0 5px;}
.sb-item{display:flex;align-items:center;gap:9px;padding:8px 10px;border-radius:9px;margin-bottom:1px;color:var(--sb-text);text-decoration:none;font-size:.81rem;font-weight:500;transition:all .18s;border-left:2px solid transparent;}
.sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.78rem;border-radius:8px;background:rgba(255,255,255,0.06);flex-shrink:0;}
.sb-item.on{color:#fff;background:var(--sb-item-on);border-left-color:var(--sb-accent);}
.sb-item.on i{background:rgba(129,140,248,0.3);color:var(--sb-accent-2);}
.sb-item:hover:not(.on){color:rgba(255,255,255,0.78);background:rgba(255,255,255,0.06);}
.sb-badge{margin-left:auto;background:#ef4444;color:#fff;font-size:.6rem;font-weight:700;padding:2px 7px;border-radius:20px;}
.sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border);}
.sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);margin-bottom:5px;text-decoration:none;transition:all .18s;}
.sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3);}
.sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
.sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%;}
.sb-uname{color:#fff;font-size:.8rem;font-weight:600;}.sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem;margin-top:1px;}
.sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
.sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1);}
.main{margin-left:var(--sb-width);flex:1;display:flex;flex-direction:column;height:100vh;overflow:hidden;}
.chat-hd{padding:0 24px;height:64px;display:flex;align-items:center;gap:14px;flex-shrink:0;background:rgba(11,20,55,0.7);backdrop-filter:blur(16px);border-bottom:1px solid var(--border);}
.chat-ava{width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,var(--green),#059669);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.95rem;font-weight:700;flex-shrink:0;position:relative;overflow:hidden;}
.chat-ava img{width:40px;height:40px;object-fit:cover;border-radius:50%;display:block;}
.online-dot{position:absolute;bottom:1px;right:1px;width:11px;height:11px;background:#4a5568;border-radius:50%;border:2px solid rgba(11,20,55,0.85);transition:background .4s,box-shadow .4s;}
.online-dot.online{background:var(--green);box-shadow:0 0 6px rgba(52,211,153,0.7);}
.chat-hd-info{flex:1;}.chat-hd-name{font-size:.93rem;font-weight:700;color:#fff;}
.online-status-text{font-size:.72rem;font-weight:600;margin-top:2px;transition:color .4s;}
.online-status-text.online{color:var(--green);}.online-status-text.offline{color:var(--muted);}
.pin-banner{display:none;align-items:center;gap:10px;padding:8px 20px;background:rgba(251,191,36,0.07);border-bottom:1px solid rgba(251,191,36,0.15);cursor:pointer;transition:background .2s;flex-shrink:0;}
.pin-banner.show{display:flex;}.pin-banner:hover{background:rgba(251,191,36,0.12);}
.pin-icon{color:var(--amber);font-size:.75rem;flex-shrink:0;}
.pin-text{font-size:.76rem;color:var(--text-2);flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.pin-label{font-size:.62rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;color:var(--amber);flex-shrink:0;}
.pin-close{width:20px;height:20px;border-radius:50%;border:none;background:rgba(255,255,255,0.06);color:var(--muted);cursor:pointer;font-size:.65rem;display:flex;align-items:center;justify-content:center;flex-shrink:0;transition:all .2s;}
.pin-close:hover{background:rgba(248,113,113,0.2);color:var(--danger);}
.chat-msgs{flex:1;overflow-y:auto;padding:20px 24px 12px;background:var(--navy);display:flex;flex-direction:column;gap:2px;}
.date-sep{text-align:center;margin:10px 0;}.date-sep span{background:rgba(255,255,255,0.06);border:1px solid var(--border);color:var(--muted);font-size:.68rem;font-weight:600;padding:3px 12px;border-radius:20px;}
.msg-row{display:flex;align-items:flex-end;gap:8px;max-width:72%;position:relative;margin-bottom:4px;}
.msg-row.mine{margin-left:auto;flex-direction:row-reverse;}.msg-row.other{margin-right:auto;}
.msg-ava{width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.75rem;font-weight:700;color:#fff;flex-shrink:0;overflow:hidden;}
.msg-ava img{width:30px;height:30px;object-fit:cover;border-radius:50%;display:block;}
.msg-ava.support{background:linear-gradient(135deg,var(--green),#059669);}.msg-ava.me{background:linear-gradient(135deg,var(--accent),var(--purple));}
.msg-content{display:flex;flex-direction:column;gap:3px;position:relative;}
.msg-row.mine .msg-content{align-items:flex-end;}.msg-row.other .msg-content{align-items:flex-start;}
.msg-name{font-size:.68rem;color:var(--muted);font-weight:600;margin-bottom:1px;}
.msg-bubble{padding:9px 14px;border-radius:18px;font-size:.855rem;line-height:1.55;word-wrap:break-word;max-width:380px;position:relative;cursor:default;transition:filter .15s;}
.msg-bubble:hover{filter:brightness(1.08);}
.msg-row.mine .msg-bubble{background:linear-gradient(135deg,var(--accent),#6366f1);color:#fff;border-bottom-right-radius:4px;}
.msg-row.other .msg-bubble{background:rgba(17,26,66,0.9);border:1px solid var(--border);color:var(--text-2);border-bottom-left-radius:4px;}
.msg-bubble.recalled{background:rgba(255,255,255,0.03)!important;border:1px dashed rgba(255,255,255,0.12)!important;color:var(--muted)!important;font-style:italic;font-size:.78rem;}
.attach-img{max-width:240px;max-height:180px;border-radius:10px;display:block;margin-top:6px;cursor:pointer;object-fit:cover;}
.attach-img:hover{opacity:.88;}
.attach-file{display:flex;align-items:center;gap:8px;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.12);border-radius:10px;padding:8px 12px;margin-top:6px;text-decoration:none;max-width:240px;}
.attach-file:hover{background:rgba(255,255,255,0.14);}
.attach-file-icon{font-size:1.2rem;flex-shrink:0;color:var(--accent-2);}
.attach-file-name{font-size:.75rem;font-weight:600;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.attach-file-size{font-size:.65rem;color:var(--muted);}
.msg-status{font-size:.68rem;color:var(--muted);display:flex;align-items:center;gap:3px;margin-top:1px;}
.msg-status i{font-size:.62rem;}.msg-status.delivered i{color:var(--text-2);}.msg-status.read i{color:var(--info);}
.msg-time-row{display:flex;align-items:center;gap:5px;}.msg-time{font-size:.64rem;color:var(--muted);padding:0 2px;}
.msg-reactions{display:flex;flex-wrap:wrap;gap:4px;margin-top:4px;}
.reaction-chip{display:inline-flex;align-items:center;gap:3px;padding:2px 7px;border-radius:20px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);font-size:.75rem;cursor:pointer;transition:all .15s;user-select:none;}
.reaction-chip:hover{background:rgba(79,126,248,0.15);border-color:rgba(79,126,248,0.3);}
.reaction-chip.mine{background:rgba(79,126,248,0.15);border-color:rgba(79,126,248,0.35);}
.reaction-chip .cnt{font-size:.68rem;color:var(--text-2);font-weight:600;}
.msg-actions{position:absolute;top:50%;transform:translateY(-50%);display:flex;gap:4px;opacity:0;pointer-events:none;transition:opacity .2s;z-index:10;padding:8px 6px;}
.msg-row.mine .msg-actions{right:calc(100% + 2px);}.msg-row.other .msg-actions{left:calc(100% + 2px);}
.msg-actions.visible{opacity:1;pointer-events:auto;}
.act-btn{width:34px;height:34px;border-radius:10px;border:1px solid rgba(255,255,255,0.12);background:rgba(17,26,66,0.97);color:var(--muted);cursor:pointer;font-size:.8rem;display:flex;align-items:center;justify-content:center;transition:all .15s;box-shadow:0 2px 8px rgba(0,0,0,0.35);}
.act-btn:hover{background:rgba(79,126,248,0.2);border-color:rgba(79,126,248,0.4);color:var(--accent-2);transform:scale(1.08);}
.act-btn.danger:hover{background:rgba(248,113,113,0.2);border-color:rgba(248,113,113,0.4);color:var(--danger);transform:scale(1.08);}
.act-btn.pin-act:hover{background:rgba(251,191,36,0.2);border-color:rgba(251,191,36,0.4);color:var(--amber);transform:scale(1.08);}
.act-btn.pinned-active{background:rgba(251,191,36,0.15);border-color:rgba(251,191,36,0.4);color:var(--amber);}
.react-popup{position:absolute;bottom:calc(100% + 6px);display:none;background:rgba(15,28,77,0.98);border:1px solid var(--border);border-radius:14px;padding:6px 8px;gap:4px;backdrop-filter:blur(20px);box-shadow:0 8px 32px rgba(0,0,0,0.5);z-index:100;animation:popIn .15s ease;}
.react-popup.show{display:flex;}.msg-row.mine .react-popup{right:0;}.msg-row.other .react-popup{left:0;}
@keyframes popIn{from{opacity:0;transform:scale(.85) translateY(4px)}to{opacity:1;transform:scale(1) translateY(0)}}
.react-emoji-btn{width:32px;height:32px;border-radius:8px;border:none;background:transparent;cursor:pointer;font-size:1.1rem;display:flex;align-items:center;justify-content:center;transition:all .15s;}
.react-emoji-btn:hover{background:rgba(79,126,248,0.2);transform:scale(1.2);}
.typing{display:none;margin-bottom:6px;}.typing.show{display:flex;}
.typing-bubble{background:rgba(17,26,66,0.9);border:1px solid var(--border);padding:10px 14px;border-radius:18px;border-bottom-left-radius:4px;display:flex;align-items:center;gap:4px;}
.t-dot{width:6px;height:6px;border-radius:50%;background:var(--muted);animation:taBounce 1.4s infinite ease-in-out;}
.t-dot:nth-child(2){animation-delay:.2s;}.t-dot:nth-child(3){animation-delay:.4s;}
@keyframes taBounce{0%,60%,100%{transform:translateY(0)}30%{transform:translateY(-5px);background:var(--accent-2)}}
.chat-input-area{background:rgba(11,20,55,0.7);backdrop-filter:blur(16px);border-top:1px solid var(--border);padding:12px 20px 14px;flex-shrink:0;position:relative;}
.attach-preview{display:none;align-items:center;gap:10px;padding:8px 14px;background:rgba(255,255,255,0.04);border:1px solid var(--border);border-radius:12px;margin-bottom:10px;}
.attach-preview.show{display:flex;}
.attach-preview-img{width:48px;height:48px;border-radius:8px;object-fit:cover;flex-shrink:0;}
.attach-preview-file{display:flex;align-items:center;gap:8px;flex:1;min-width:0;}
.attach-preview-file i{color:var(--accent-2);font-size:1.4rem;flex-shrink:0;}
.attach-preview-name{font-size:.78rem;font-weight:600;color:var(--text-2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;flex:1;}
.attach-preview-remove{width:26px;height:26px;border-radius:50%;border:none;background:rgba(248,113,113,0.15);color:var(--danger);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:.72rem;flex-shrink:0;}
.input-row{display:flex;gap:8px;align-items:flex-end;}
.input-wrap{flex:1;background:rgba(255,255,255,0.05);border:1.5px solid var(--border);border-radius:22px;padding:9px 14px;display:flex;align-items:center;gap:8px;transition:all .2s;}
.input-wrap:focus-within{border-color:rgba(79,126,248,0.5);background:rgba(79,126,248,0.06);box-shadow:0 0 0 3px rgba(79,126,248,0.1);}
.chat-input{flex:1;border:none;outline:none;background:transparent;font-size:.875rem;font-family:'Sora',sans-serif;color:var(--text);resize:none;max-height:100px;line-height:1.45;}
.chat-input::placeholder{color:var(--muted);}
.btn-emoji-toggle,.btn-attach{width:28px;height:28px;border:none;background:none;color:var(--muted);cursor:pointer;font-size:1.1rem;display:flex;align-items:center;justify-content:center;border-radius:8px;transition:all .15s;flex-shrink:0;}
.btn-emoji-toggle:hover{color:var(--amber);background:rgba(251,191,36,0.1);}
.btn-attach{font-size:1rem;}.btn-attach:hover{color:var(--accent-2);background:rgba(79,126,248,0.1);}
.btn-attach.has-file{color:var(--accent-2);}
.btn-send{width:44px;height:44px;border-radius:50%;border:none;background:linear-gradient(135deg,var(--accent),var(--purple));color:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:.9rem;flex-shrink:0;transition:all .2s;box-shadow:0 4px 14px var(--accent-glow);}
.btn-send:hover{transform:scale(1.08);box-shadow:0 6px 20px rgba(79,126,248,0.5);}
.btn-send:disabled{background:rgba(79,126,248,0.2);box-shadow:none;cursor:not-allowed;transform:none;}
.input-hint{text-align:center;font-size:.68rem;color:var(--muted);margin-top:6px;}.input-hint strong{color:var(--text-2);}
#fileInput{display:none;}
.upload-progress{position:absolute;bottom:0;left:0;right:0;height:3px;background:var(--accent);border-radius:0;transform-origin:left;transform:scaleX(0);transition:transform .3s ease;pointer-events:none;}
.upload-progress.active{animation:uploadAnim 1.2s ease infinite alternate;}
@keyframes uploadAnim{from{transform:scaleX(0.05)}to{transform:scaleX(0.85)}}
.upload-progress.done{transform:scaleX(1);}
.emoji-picker{position:absolute;bottom:80px;left:20px;right:20px;max-width:360px;background:rgba(15,28,77,0.98);border:1px solid var(--border);border-radius:16px;padding:12px;backdrop-filter:blur(20px);box-shadow:0 16px 48px rgba(0,0,0,0.6);z-index:200;display:none;animation:popIn .15s ease;}
.emoji-picker.show{display:block;}
.emoji-cats{display:flex;gap:4px;margin-bottom:10px;overflow-x:auto;padding-bottom:4px;}.emoji-cats::-webkit-scrollbar{height:2px;}
.emoji-cat-btn{padding:4px 10px;border-radius:8px;border:none;background:rgba(255,255,255,0.05);color:var(--muted);cursor:pointer;font-size:.75rem;font-weight:600;white-space:nowrap;transition:all .15s;}
.emoji-cat-btn.active{background:rgba(79,126,248,0.2);color:var(--accent-2);}
.emoji-search{width:100%;padding:6px 12px;background:rgba(255,255,255,0.05);border:1px solid var(--border);border-radius:10px;color:var(--text);font-family:'Sora',sans-serif;font-size:.78rem;outline:none;margin-bottom:10px;}
.emoji-search::placeholder{color:var(--muted);}
.emoji-grid{display:grid;grid-template-columns:repeat(8,1fr);gap:2px;max-height:180px;overflow-y:auto;}.emoji-grid::-webkit-scrollbar{width:3px;}
.eg-btn{border:none;background:none;cursor:pointer;font-size:1.2rem;padding:4px;border-radius:6px;transition:all .12s;text-align:center;}
.eg-btn:hover{background:rgba(79,126,248,0.2);transform:scale(1.15);}
.lightbox{position:fixed;inset:0;background:rgba(0,0,0,0.88);z-index:9000;display:none;align-items:center;justify-content:center;}
.lightbox.show{display:flex;}.lightbox img{max-width:90vw;max-height:88vh;border-radius:12px;}
.lightbox-close{position:absolute;top:18px;right:22px;width:36px;height:36px;border-radius:50%;border:none;background:rgba(255,255,255,0.1);color:#fff;cursor:pointer;font-size:1rem;display:flex;align-items:center;justify-content:center;}
.no-agent{flex:1;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:12px;color:var(--muted);}
.no-agent i{font-size:2.8rem;opacity:.18;}.no-agent p{font-weight:600;font-size:.9rem;color:var(--text-2);}
.toast{position:fixed;bottom:24px;left:50%;transform:translateX(-50%) translateY(20px);background:rgba(17,26,66,0.98);border:1px solid var(--border);color:var(--text-2);font-size:.78rem;font-weight:600;padding:8px 18px;border-radius:20px;box-shadow:0 8px 24px rgba(0,0,0,0.4);opacity:0;transition:all .3s;z-index:999;pointer-events:none;}
.toast.show{opacity:1;transform:translateX(-50%) translateY(0);}
.msg-sending{opacity:.55;}.msg-error .msg-bubble{background:var(--danger-dim)!important;border-color:rgba(248,113,113,0.25)!important;color:var(--danger)!important;}
.emoji-burst-particle{position:fixed;pointer-events:none;font-size:1.4rem;z-index:9999;user-select:none;animation:emojiBurst var(--dur,.9s) ease-out forwards;}
@keyframes emojiBurst{0%{opacity:1;transform:translate(0,0) scale(1.2) rotate(0deg);}15%{opacity:1;transform:translate(calc(var(--tx)*.15),calc(var(--ty)*.15)) scale(1.5);}60%{opacity:.85;}100%{opacity:0;transform:translate(var(--tx),var(--ty)) scale(.15) rotate(var(--rot));}}
    </style>
</head>
<body>
<aside class="sb">
    <div class="sb-brand"><div class="sb-logo"><i class="fas fa-bolt"></i></div><div><div class="sb-name">DRSMS</div><div class="sb-role">Customer</div></div></div>
    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div><a href="<%=ctx%>/customerDashboard" class="sb-item"><i class="fas fa-home"></i> Dashboard</a>
        <div class="sb-lbl">Services</div>
        <a href="<%=ctx%>/customerServiceRequests" class="sb-item"><i class="fas fa-clipboard-list"></i> Repair Requests</a>
        <a href="<%=ctx%>/customerContracts" class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
        <a href="<%=ctx%>/customerEquipment" class="sb-item"><i class="fas fa-desktop"></i> My Equipment</a>
        <div class="sb-lbl">Shop</div>
        <a href="<%=ctx%>/customerShop?action=parts" class="sb-item"><i class="fas fa-puzzle-piece"></i> Parts</a>
        <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Equipment</a>
        <a href="<%=ctx%>/customerShop?action=cart" class="sb-item"><i class="fas fa-shopping-cart"></i> Cart<%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%></a>
        <div class="sb-lbl">Finance</div><a href="<%=ctx%>/customerInvoices" class="sb-item"><i class="fas fa-receipt"></i> Invoices</a>
        <div class="sb-lbl">Support</div><a href="<%=ctx%>/customerChat" class="sb-item on"><i class="fas fa-comment-dots"></i> Support Chat</a>
    </nav>
    <div class="sb-foot">
        <a href="<%=ctx%>/profile" class="sb-user">
            <div class="sb-ava"><%if(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()){%><img src="<%=ctx%><%=me.getAvatarUrl()%>" alt="avatar"><%}else{%><%=initials%><%}%></div>
            <div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer Account</div></div>
        </a>
        <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
    </div>
</aside>

<main class="main">
<%if(agent==null){%>
    <div class="chat-hd"><div class="chat-hd-info"><div class="chat-hd-name">Support Chat</div><div class="online-status-text offline">No agent available</div></div></div>
    <div class="no-agent"><i class="fas fa-headset"></i><p>No support agent available</p><span>Please try again later</span></div>
<%}else{%>
    <div class="chat-hd">
        <div class="chat-ava">
            <%if(agent.getAvatarUrl()!=null&&!agent.getAvatarUrl().isEmpty()){%><img src="<%=ctx%><%=agent.getAvatarUrl()%>" alt="avatar"><%}else{%><%=agent.getFullName().substring(0,1).toUpperCase()%><%}%>
            <span class="online-dot <%=agentOnlineInit?"online":""%>" id="headerOnlineDot"></span>
        </div>
        <div class="chat-hd-info">
            <div class="chat-hd-name"><%=agent.getFullName()%></div>
            <span class="online-status-text <%=agentOnlineInit?"online":"offline"%>" id="onlineStatusText"><%=agentOnlineInit?"Online · Support Agent":"Offline"%></span>
        </div>
    </div>
    <div class="pin-banner <%=pinnedMessage!=null?"show":""%>" id="pinBanner" onclick="scrollToPin()">
        <i class="fas fa-thumbtack pin-icon"></i><span class="pin-label">Pinned</span>
        <span class="pin-text" id="pinText"><%=pinnedMessage!=null?pinnedMessage.getMessage().replace("<","&lt;").replace(">","&gt;"):""%></span>
        <button class="pin-close" onclick="event.stopPropagation();clearPin()"><i class="fas fa-times"></i></button>
    </div>
    <div class="chat-msgs" id="chatMsgs">
        <%if(msgs.isEmpty()){%>
        <div class="empty-chat" id="emptyChat" style="margin:auto;text-align:center;color:var(--muted);padding:40px 24px;">
            <span style="font-size:2.8rem;display:block;margin-bottom:12px">💬</span>
            <p style="font-weight:600;font-size:.88rem;color:var(--text-2);margin-bottom:5px;">Start a conversation</p>
            <span style="font-size:.78rem;">Send a message to get support</span>
        </div>
        <%}else{String prevDate="";for(ChatMessage m:msgs){boolean mine=m.getSenderId()==me.getId();String dateStr=m.getCreatedAt()!=null?m.getCreatedAt().toLocalDate().toString():"";if(!dateStr.equals(prevDate)){prevDate=dateStr;%>
        <div class="date-sep"><span><%=dateStr%></span></div>
        <%}List<Map<String,Object>> msgReactions=reactionsMap.getOrDefault(m.getId(),new ArrayList<>());
        String senderAvatar=mine?(me.getAvatarUrl()!=null&&!me.getAvatarUrl().isEmpty()?me.getAvatarUrl():null):(agent.getAvatarUrl()!=null&&!agent.getAvatarUrl().isEmpty()?agent.getAvatarUrl():null);
        String senderInitial=(m.getSenderName()!=null?m.getSenderName():"?").substring(0,1).toUpperCase();
        String attachHtml="";
        if(m.hasAttachment()&&!m.isRecalled()){if(m.isImage()){String au=m.getAttachmentUrl();String aurl=au.startsWith("http")||au.startsWith(ctx)?au:ctx+au;attachHtml="<img class='attach-img' src='"+aurl+"' alt='image' onclick='openLightbox(this.src)'>";}
else{String fname=m.getAttachmentName()!=null?m.getAttachmentName():"File";String au=m.getAttachmentUrl();String furl=au.startsWith("http")||au.startsWith(ctx)?au:ctx+au;attachHtml="<a class='attach-file' href='"+furl+"' download target='_blank'><i class='fas fa-file-arrow-down attach-file-icon'></i><div><div class='attach-file-name'>"+fname+"</div><div class='attach-file-size'>Download</div></div></a>";}}
        String statusHtml="";if(mine&&!m.isRecalled()){String sc=m.isRead()?"read":(m.isDelivered()?"delivered":"");String si=m.isRead()?"fa-check-double":(m.isDelivered()?"fa-check-double":"fa-check");statusHtml="<div class='msg-status "+sc+"'><i class='fas "+si+"'></i></div>";}%>
        <div class="msg-row <%=mine?"mine":"other"%>" data-id="<%=m.getId()%>" data-mine="<%=mine%>" <%=m.isPinned()?"data-pinned='true'":""%>>
            <div class="msg-ava <%=mine?"me":"support"%>"><%if(senderAvatar!=null){%><img src="<%=ctx%><%=senderAvatar%>" alt="avatar"><%}else{%><%=senderInitial%><%}%></div>
            <div class="msg-content">
                <%if(!mine){%><div class="msg-name"><%=m.getSenderName()%></div><%}%>
                <div class="msg-bubble <%=m.isRecalled()?"recalled":""%>">
                    <%if(m.isRecalled()){%><i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled
                    <%}else{%><%if(m.getMessage()!=null&&!m.getMessage().isEmpty()){%><%=m.getMessage().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>")%><%}%><%=attachHtml%><%}%>
                </div>
                <div class="msg-reactions">
                    <%for(Map<String,Object> rx:msgReactions){boolean rxMine=(Boolean)rx.get("mine");int rxCount=(Integer)rx.get("count");String rxEmoji=(String)rx.get("emoji");%>
                    <div class="reaction-chip <%=rxMine?"mine":""%>" data-emoji="<%=rxEmoji%>" onclick="toggleReactionChip(this,'<%=rxEmoji%>',<%=m.getId()%>)"><%=rxEmoji%> <span class="cnt"><%=rxCount%></span></div>
                    <%}%>
                </div>
                <div class="msg-time-row"><div class="msg-time"><%=m.getTimeFormatted()%></div><%=statusHtml%></div>
                <%if(!m.isRecalled()){%>
                <div class="msg-actions">
                    <div style="position:relative"><button class="act-btn" title="React" onclick="toggleReactPopup(this)"><i class="fas fa-face-smile"></i></button>
                    <div class="react-popup"><button class="react-emoji-btn" onclick="addReaction(this,'👍')">👍</button><button class="react-emoji-btn" onclick="addReaction(this,'❤️')">❤️</button><button class="react-emoji-btn" onclick="addReaction(this,'😂')">😂</button><button class="react-emoji-btn" onclick="addReaction(this,'😮')">😮</button><button class="react-emoji-btn" onclick="addReaction(this,'😢')">😢</button><button class="react-emoji-btn" onclick="addReaction(this,'🔥')">🔥</button></div></div>
                    <button class="act-btn pin-act <%=m.isPinned()?"pinned-active":""%>" title="<%=m.isPinned()?"Unpin":"Pin"%>" onclick="pinMsg(this)"><i class="fas fa-thumbtack"></i></button>
                    <%if(mine){%><button class="act-btn danger" title="Recall" onclick="recallMsg(this)"><i class="fas fa-rotate-left"></i></button><%}%>
                </div>
                <%}%>
            </div>
        </div>
        <%}}%>
        <div class="msg-row other typing" id="typing">
            <div class="msg-ava support"><%if(agent.getAvatarUrl()!=null&&!agent.getAvatarUrl().isEmpty()){%><img src="<%=ctx%><%=agent.getAvatarUrl()%>" alt="avatar"><%}else{%><%=agent.getFullName().substring(0,1).toUpperCase()%><%}%></div>
            <div class="msg-content"><div class="typing-bubble"><div class="t-dot"></div><div class="t-dot"></div><div class="t-dot"></div></div></div>
        </div>
    </div>
    <div class="chat-input-area">
        <div class="upload-progress" id="uploadProgress"></div>
        <div class="attach-preview" id="attachPreview">
            <img class="attach-preview-img" id="attachPreviewImg" src="" alt="" style="display:none">
            <div class="attach-preview-file" id="attachPreviewFile" style="display:none"><i class="fas fa-file"></i><span class="attach-preview-name" id="attachPreviewName"></span></div>
            <button class="attach-preview-remove" onclick="clearAttachment()"><i class="fas fa-times"></i></button>
        </div>
        <div class="emoji-picker" id="emojiPicker">
            <div class="emoji-cats" id="emojiCats"></div>
            <input class="emoji-search" id="emojiSearch" placeholder="Search emoji..." oninput="filterEmojis(this.value)">
            <div class="emoji-grid" id="emojiGrid"></div>
        </div>
        <div class="input-row">
            <div class="input-wrap">
                <button class="btn-emoji-toggle" id="emojiToggleBtn" onclick="toggleEmojiPicker()">😊</button>
                <button class="btn-attach" id="attachBtn" onclick="document.getElementById('fileInput').click()"><i class="fas fa-paperclip"></i></button>
                <input type="file" id="fileInput" accept="image/*,.pdf,.doc,.docx,.xls,.xlsx,.txt,.zip,.rar" onchange="handleFileSelect(this)">
                <textarea class="chat-input" id="msgInput" placeholder="Type a message..." rows="1" onkeydown="handleKey(event)" oninput="handleInput(this)" maxlength="2000"></textarea>
            </div>
            <button class="btn-send" id="sendBtn" onclick="sendMsg()"><i class="fas fa-paper-plane"></i></button>
        </div>
        <div class="input-hint"><strong>Enter</strong> to send · <strong>Shift+Enter</strong> for new line</div>
    </div>
<%}%>
</main>
<div class="lightbox" id="lightbox" onclick="closeLightbox()"><button class="lightbox-close"><i class="fas fa-times"></i></button><img id="lightboxImg" src="" alt="image"></div>
<div class="toast" id="toast"></div>

<script>
const CTX='<%=ctx%>',MY_ID=<%=me.getId()%>,MY_NAME='<%=me.getFullName().replace("\\","\\\\").replace("'","\\'")%>',AGENT_NAME='<%=agent!=null?agent.getFullName().replace("\\","\\\\").replace("'","\\'"):""%>';
const MY_AVATAR='<%=myAvatarUrl%>',AGENT_AVATAR='<%=agentAvatarUrl%>';
let lastId=<%=lastId%>,pollTimer=null,pollUpdatesTimer=null,statusTimer=null,heartbeatTimer=null;
const renderedIds=new Set();
let pinnedMsgEl=null,pinnedMsgId=<%=pinnedMessage!=null?pinnedMessage.getId():0%>;
const reactions={};
let pendingFile=null,pendingFileName=null,pendingFileType=null;
let typingTimer=null,isTypingSent=false;

document.querySelectorAll('#chatMsgs .msg-row[data-id]').forEach(el=>{
    const n=parseInt(el.dataset.id);if(!isNaN(n)&&n>0){renderedIds.add(n);if(el.dataset.pinned==='true')pinnedMsgEl=el;}
    const mid=el.dataset.id;if(mid){reactions[mid]={};el.querySelectorAll('.reaction-chip[data-emoji]').forEach(chip=>{const emoji=chip.dataset.emoji,count=parseInt(chip.querySelector('.cnt').textContent)||0,mine=chip.classList.contains('mine');if(emoji&&count>0)reactions[mid][emoji]={count,mine};});}
});

const scrollDown=s=>{const el=document.getElementById('chatMsgs');if(el)el.scrollTo({top:el.scrollHeight,behavior:s?'smooth':'instant'});};
const isAtBottom=()=>{const el=document.getElementById('chatMsgs');if(!el)return true;return el.scrollHeight-el.scrollTop-el.clientHeight<80;};
const autoResize=el=>{el.style.height='auto';el.style.height=Math.min(el.scrollHeight,100)+'px';};
const handleKey=e=>{if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();sendMsg();}};
const nowTime=()=>new Date().toLocaleTimeString('en-US',{hour:'2-digit',minute:'2-digit',hour12:false});
const showToast=(msg,dur=2200)=>{const t=document.getElementById('toast');t.textContent=msg;t.classList.add('show');setTimeout(()=>t.classList.remove('show'),dur);};
const openLightbox=src=>{document.getElementById('lightboxImg').src=src;document.getElementById('lightbox').classList.add('show');};
const closeLightbox=()=>document.getElementById('lightbox').classList.remove('show');

function setAgentOnline(online){
    const dot=document.getElementById('headerOnlineDot'),txt=document.getElementById('onlineStatusText');
    if(dot)dot.classList.toggle('online',online);
    if(txt){txt.textContent=online?'Online · Support Agent':'Offline';txt.className='online-status-text '+(online?'online':'offline');}
}
function pollStatus(){
    fetch(CTX+'/customerChat?action=pollStatus').then(r=>r.json()).then(d=>{
        setAgentOnline(!!d.agentOnline);
        const te=document.getElementById('typing');
        if(te){if(d.agentTyping){te.classList.add('show');if(isAtBottom())scrollDown(true);}else te.classList.remove('show');}
    }).catch(()=>{});
}
const sendHeartbeat=()=>fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({action:'heartbeat'})}).catch(()=>{});

/* FIX 2: Typing keepalive — dùng recursive setTimeout để giữ typing sống */
function handleInput(el){
    autoResize(el);
    if(!isTypingSent){
        isTypingSent=true;
        fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({action:'typing'})}).catch(()=>{});
    }
    clearTimeout(typingTimer);
    typingTimer=setTimeout(function keepTyping(){
        const inp=document.getElementById('msgInput');
        if(inp&&document.activeElement===inp&&inp.value.trim().length>0){
            fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({action:'typing'})}).catch(()=>{});
            typingTimer=setTimeout(keepTyping,2000);
        }else{
            isTypingSent=false;
            fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({action:'stopTyping'})}).catch(()=>{});
        }
    },2000);
}

function handleFileSelect(input){
    const file=input.files[0];if(!file)return;
    if(file.size>10*1024*1024){showToast('File too large (max 10MB)');input.value='';return;}
    pendingFile=file;pendingFileName=file.name;pendingFileType=file.type.startsWith('image/')?'IMAGE':'FILE';
    document.getElementById('attachPreview').classList.add('show');
    document.getElementById('attachBtn').classList.add('has-file');
    const img=document.getElementById('attachPreviewImg'),pf=document.getElementById('attachPreviewFile');
    if(pendingFileType==='IMAGE'){img.src=URL.createObjectURL(file);img.style.display='block';pf.style.display='none';}
    else{img.style.display='none';pf.style.display='flex';document.getElementById('attachPreviewName').textContent=file.name;}
    input.value='';
}
function clearAttachment(){pendingFile=null;pendingFileName=null;pendingFileType=null;document.getElementById('attachPreview').classList.remove('show');document.getElementById('attachBtn').classList.remove('has-file');document.getElementById('attachPreviewImg').src='';}
async function uploadFile(file){
    const prog=document.getElementById('uploadProgress');prog.classList.add('active');
    const fd=new FormData();fd.append('action','upload');fd.append('file',file);
    try{const resp=await fetch(CTX+'/customerChat',{method:'POST',body:fd});const d=await resp.json();prog.classList.remove('active');prog.classList.add('done');setTimeout(()=>prog.classList.remove('done'),400);if(d.success)return d;showToast('Upload failed');return null;}
    catch(e){prog.classList.remove('active');showToast('Upload error');return null;}
}

const buildAvatarHtml=isMine=>{const url=isMine?MY_AVATAR:AGENT_AVATAR,letter=(isMine?MY_NAME:AGENT_NAME).substring(0,1).toUpperCase();return url?'<img src="'+url+'" alt="avatar">':letter;};
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
const buildStatusHtml=(m,isMine)=>{if(!isMine||m.recalled)return '';const isRead=m.read===true,isDelivered=m.delivered===true;const cls=isRead?'read':(isDelivered?'delivered':''),icon=isRead?'fa-check-double':(isDelivered?'fa-check-double':'fa-check');return '<div class="msg-status '+cls+'"><i class="fas '+icon+'"></i></div>';};

function buildMsgRow(m,isMine){
    const row=document.createElement('div');row.className='msg-row '+(isMine?'mine':'other');
    if(m.id&&String(m.id).indexOf('temp')===-1)row.dataset.id=m.id;row.dataset.mine=isMine;
    const isRecalled=m.recalled===true;
    const safe=isRecalled?'':String(m.message||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\n/g,'<br>');
    const nameHtml=!isMine?'<div class="msg-name">'+AGENT_NAME+'</div>':'';
    let bubble=isRecalled?'<i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled':(safe+buildAttachHtml(m));
    const recallBtn=(!isRecalled&&isMine)?'<button class="act-btn danger" onclick="recallMsg(this)"><i class="fas fa-rotate-left"></i></button>':'';
    const acts=isRecalled?'':'<div class="msg-actions"><div style="position:relative"><button class="act-btn" onclick="toggleReactPopup(this)"><i class="fas fa-face-smile"></i></button><div class="react-popup">'+['👍','❤️','😂','😮','😢','🔥'].map(e=>'<button class="react-emoji-btn" onclick="addReaction(this,\''+e+'\')">'+e+'</button>').join('')+'</div></div><button class="act-btn pin-act" onclick="pinMsg(this)"><i class="fas fa-thumbtack"></i></button>'+recallBtn+'</div>';
    let rxHtml='<div class="msg-reactions">';if(m.reactions&&Array.isArray(m.reactions))m.reactions.forEach(rx=>{if(rx.count>0)rxHtml+='<div class="reaction-chip '+(rx.mine?'mine':'')+'" data-emoji="'+rx.emoji+'" onclick="toggleReactionChip(this,\''+rx.emoji+'\','+m.id+')">'+rx.emoji+' <span class="cnt">'+rx.count+'</span></div>';});rxHtml+='</div>';
    row.innerHTML='<div class="msg-ava '+(isMine?'me':'support')+'">'+buildAvatarHtml(isMine)+'</div><div class="msg-content">'+nameHtml+'<div class="msg-bubble'+(isRecalled?' recalled':'')+'">'+bubble+'</div>'+rxHtml+'<div class="msg-time-row"><div class="msg-time">'+(m.time||nowTime())+'</div>'+buildStatusHtml(m,isMine)+'</div>'+acts+'</div>';
    return row;
}
function appendMsg(m){
    const container=document.getElementById('chatMsgs');if(!container)return null;
    const emp=document.getElementById('emptyChat');if(emp)emp.remove();
    const typing=document.getElementById('typing');const isMine=m.senderId===MY_ID||m.mine===true;
    const row=buildMsgRow(m,isMine);
    if(typing)container.insertBefore(row,typing);else container.appendChild(row);
    if(!row.dataset.bound){bindRowHover(row);row.dataset.bound='1';}
    if(isAtBottom())scrollDown(true);return row;
}

async function sendMsg(){
    const inp=document.getElementById('msgInput'),btn=document.getElementById('sendBtn');
    const text=inp.value.trim();if(!text&&!pendingFile)return;
    clearTimeout(typingTimer);isTypingSent=false;
    fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({action:'stopTyping'})}).catch(()=>{});
    btn.disabled=true;inp.disabled=true;
    let uploadResult=null;if(pendingFile){uploadResult=await uploadFile(pendingFile);if(!uploadResult){btn.disabled=false;inp.disabled=false;return;}}
    const tempMsg={id:'temp_'+Date.now(),senderId:MY_ID,mine:true,message:text,time:nowTime(),recalled:false,attachmentUrl:uploadResult?.url,attachmentName:uploadResult?.name,attachmentType:uploadResult?.type};
    const tempEl=appendMsg(tempMsg);if(tempEl)tempEl.classList.add('msg-sending');
    inp.value='';inp.style.height='auto';clearAttachment();
    const params=new URLSearchParams();if(text)params.append('message',text);
    if(uploadResult){params.append('attachmentUrl',uploadResult.url);params.append('attachmentName',uploadResult.name);params.append('attachmentType',uploadResult.type);}
    fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},body:params})
    .then(r=>r.json()).then(d=>{
        if(d.success&&d.id){if(tempEl){tempEl.dataset.id=d.id;tempEl.classList.remove('msg-sending');renderedIds.add(d.id);}if(d.id>lastId)lastId=d.id;
            setTimeout(pollUpdates,300); /* FIX 3: trigger tick update ngay */
        }else if(tempEl)tempEl.classList.add('msg-error');
    }).catch(()=>{if(tempEl)tempEl.classList.add('msg-error');})
    .finally(()=>{btn.disabled=false;inp.disabled=false;inp.focus();});
}

function poll(){
    fetch(CTX+'/customerChat?action=poll&lastId='+lastId).then(r=>r.json()).then(newMsgs=>{
        if(!Array.isArray(newMsgs)||!newMsgs.length)return;
        newMsgs.forEach(m=>{if(!renderedIds.has(m.id)){renderedIds.add(m.id);if(m.id>lastId)lastId=m.id;appendMsg(m);}});
    }).catch(()=>{});
}

/* FIX 1: pollUpdates — KHÔNG rebuild bubble, chỉ update reactions/pin/tick */
function pollUpdates(){
    fetch(CTX+'/customerChat?action=pollUpdates').then(r=>r.json()).then(allMsgs=>{
        if(!Array.isArray(allMsgs))return;
        allMsgs.forEach(m=>{
            const mid=String(m.id);
            const row=document.querySelector('#chatMsgs .msg-row[data-id="'+mid+'"]');if(!row)return;
            const isMine=row.dataset.mine==='true';
            // Recall
            if(m.recalled){const b=row.querySelector('.msg-bubble');if(b&&!b.classList.contains('recalled')){b.classList.add('recalled');b.innerHTML='<i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled';const a=row.querySelector('.msg-actions');if(a)a.style.display='none';if(pinnedMsgEl===row){pinnedMsgEl=null;pinnedMsgId=0;document.getElementById('pinBanner')?.classList.remove('show');}}}
            // FIX 1: không đụng bubble nếu không recalled → ảnh giữ nguyên
            // Reactions
            if(m.reactions&&Array.isArray(m.reactions)){reactions[mid]={};m.reactions.forEach(rx=>{if(rx.count>0)reactions[mid][rx.emoji]={count:rx.count,mine:rx.mine};});renderReactions(row,mid);}
            // Pin
            const pb=document.getElementById('pinBanner'),pt=document.getElementById('pinText');
            if(m.pinned){
                if(String(pinnedMsgId)!==mid){if(pinnedMsgEl){const ob=pinnedMsgEl.querySelector('.pin-act');if(ob)ob.classList.remove('pinned-active');pinnedMsgEl.removeAttribute('data-pinned');}
                    pinnedMsgId=mid;pinnedMsgEl=row;row.dataset.pinned='true';const pb2=row.querySelector('.pin-act');if(pb2)pb2.classList.add('pinned-active');
                    if(pt){const b=row.querySelector('.msg-bubble');let txt='';if(b){b.childNodes.forEach(n=>{if(n.nodeType===Node.TEXT_NODE)txt+=n.textContent;else if(n.tagName==='BR')txt+=' ';});}pt.textContent=txt.trim()||'📎 Attachment';}
                    if(pb)pb.classList.add('show');}
            }else{if(pinnedMsgEl===row){pinnedMsgEl=null;pinnedMsgId=0;row.removeAttribute('data-pinned');const pb2=row.querySelector('.pin-act');if(pb2)pb2.classList.remove('pinned-active');if(pb)pb.classList.remove('show');}}
            // Tick
            if(isMine&&!m.recalled)updateMsgStatus(row,m.read,m.delivered);
        });
    }).catch(()=>{});
}
function updateMsgStatus(row,isRead,isDelivered){
    let s=row.querySelector('.msg-status');if(!s){const tr=row.querySelector('.msg-time-row');if(!tr)return;s=document.createElement('div');s.className='msg-status';tr.appendChild(s);}
    const cls=isRead?'read':(isDelivered?'delivered':''),icon=isRead?'fa-check-double':(isDelivered?'fa-check-double':'fa-check');
    s.className='msg-status '+cls;s.innerHTML='<i class="fas '+icon+'"></i>';
}

function recallMsg(btn){const row=btn.closest('.msg-row');if(!row)return;const msgId=row.dataset.id;if(!msgId||msgId.includes('temp')){showToast('Cannot recall unsent message');return;}if(!confirm('Recall this message?'))return;const b=row.querySelector('.msg-bubble');b.classList.add('recalled');b.innerHTML='<i class="fas fa-rotate-left" style="margin-right:5px;font-size:.7rem"></i>Message recalled';const a=row.querySelector('.msg-actions');if(a)a.style.display='none';if(pinnedMsgEl===row){pinnedMsgEl=null;pinnedMsgId=0;document.getElementById('pinBanner')?.classList.remove('show');}showToast('Message recalled ✓');fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},body:new URLSearchParams({action:'recall',messageId:msgId})}).catch(()=>{});}
function pinMsg(btn){const row=btn.closest('.msg-row');if(!row)return;const b=row.querySelector('.msg-bubble');if(b.classList.contains('recalled')){showToast('Cannot pin a recalled message');return;}const msgId=row.dataset.id;if(!msgId||msgId.includes('temp')){showToast('Cannot pin unsent message');return;}const isAlreadyPinned=String(pinnedMsgId)===String(msgId);if(pinnedMsgEl){const ob=pinnedMsgEl.querySelector('.pin-act');if(ob)ob.classList.remove('pinned-active');pinnedMsgEl.removeAttribute('data-pinned');}const pb=document.getElementById('pinBanner'),pt=document.getElementById('pinText');if(isAlreadyPinned){pinnedMsgEl=null;pinnedMsgId=0;if(pb)pb.classList.remove('show');showToast('Pin removed');}else{pinnedMsgEl=row;pinnedMsgId=msgId;row.dataset.pinned='true';btn.classList.add('pinned-active');if(pt){let txt='';b.childNodes.forEach(n=>{if(n.nodeType===Node.TEXT_NODE)txt+=n.textContent;else if(n.tagName==='BR')txt+=' ';});pt.textContent=txt.trim()||'📎 Attachment';}if(pb)pb.classList.add('show');b.style.outline='2px solid var(--amber)';setTimeout(()=>b.style.outline='',1500);showToast('Message pinned 📌');}fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},body:new URLSearchParams({action:'pin',messageId:msgId})}).catch(()=>{});}
function scrollToPin(){if(!pinnedMsgEl)return;pinnedMsgEl.scrollIntoView({behavior:'smooth',block:'center'});const b=pinnedMsgEl.querySelector('.msg-bubble');if(b){b.style.outline='2px solid var(--amber)';setTimeout(()=>b.style.outline='',1500);}}
function clearPin(){if(pinnedMsgEl){const ob=pinnedMsgEl.querySelector('.pin-act');if(ob)ob.classList.remove('pinned-active');pinnedMsgEl.removeAttribute('data-pinned');}const oldId=pinnedMsgId;pinnedMsgEl=null;pinnedMsgId=0;document.getElementById('pinBanner')?.classList.remove('show');showToast('Pin removed');if(oldId)fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},body:new URLSearchParams({action:'pin',messageId:oldId})}).catch(()=>{});}

function toggleReactPopup(btn){document.querySelectorAll('.react-popup.show').forEach(p=>{if(p!==btn.nextElementSibling)p.classList.remove('show');});btn.nextElementSibling.classList.toggle('show');}
function addReaction(btn,emoji){const popup=btn.closest('.react-popup'),row=btn.closest('.msg-row'),msgId=row?.dataset.id;if(!msgId||msgId.includes('temp'))return;triggerEmojiBurst(emoji,btn);popup.classList.remove('show');_toggleReactionLocal(row,msgId,emoji);fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},body:new URLSearchParams({action:'react',messageId:msgId,emoji})}).catch(()=>{});}
function toggleReactionChip(chip,emoji,msgId){const row=chip.closest('.msg-row');if(!row)return;const mid=String(msgId);triggerEmojiBurst(emoji,chip);_toggleReactionLocal(row,mid,emoji);fetch(CTX+'/customerChat',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},body:new URLSearchParams({action:'react',messageId:mid,emoji})}).catch(()=>{});}
function _toggleReactionLocal(row,mid,emoji){if(!reactions[mid])reactions[mid]={};if(!reactions[mid][emoji])reactions[mid][emoji]={count:0,mine:false};const r=reactions[mid][emoji];r.mine=!r.mine;r.count+=r.mine?1:-1;if(r.count<=0)delete reactions[mid][emoji];renderReactions(row,mid);}
function renderReactions(row,msgId){const c=row.querySelector('.msg-reactions');if(!c)return;c.innerHTML='';Object.entries(reactions[msgId]||{}).forEach(([emoji,r])=>{if(r.count<=0)return;const chip=document.createElement('div');chip.className='reaction-chip'+(r.mine?' mine':'');chip.dataset.emoji=emoji;chip.innerHTML=emoji+' <span class="cnt">'+r.count+'</span>';chip.onclick=()=>toggleReactionChip(chip,emoji,msgId);c.appendChild(chip);});}
document.addEventListener('click',e=>{if(!e.target.closest('.act-btn')&&!e.target.closest('.react-popup'))document.querySelectorAll('.react-popup.show').forEach(p=>p.classList.remove('show'));});

function triggerEmojiBurst(emoji,el){const rect=el?el.getBoundingClientRect():{left:window.innerWidth/2,top:window.innerHeight/2,width:0,height:0};const cx=rect.left+rect.width/2,cy=rect.top+rect.height/2;for(let i=0;i<10;i++){const span=document.createElement('span');span.className='emoji-burst-particle';span.textContent=emoji;const angle=Math.random()*360*(Math.PI/180),dist=120*(.4+Math.random()*.6);span.style.cssText='left:'+cx+'px;top:'+cy+'px;margin:-12px 0 0 -12px;--tx:'+(Math.cos(angle)*dist)+'px;--ty:'+(Math.sin(angle)*dist-25)+'px;--rot:'+((Math.random()-.5)*420)+'deg;--dur:'+(.55+Math.random()*.55)+'s;animation-delay:'+(Math.random()*.12)+'s';document.body.appendChild(span);span.addEventListener('animationend',()=>span.remove());}}

const EMOJI_DATA={'Smileys':['😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃','😉','😊','😇','🥰','😍','🤩','😘','😗','☺️','😚','😙','🥲','😋','😛','😜','🤪','😝','🤑','🤗','🤭','🤫','🤔','🤐','🤨','😐','😑','😶','😏','😒','🙄','😬','🤥','😌','😔','😪','🤤','😴','😷','🤒','🤕','🤢','🤧','🥵','🥶','🥴','😵','🤯','🤠','🥳','😎','🤓','🧐','😕','😟','🙁','☹️','😮','😯','😲','😳','🥺','😦','😧','😨','😰','😥','😢','😭','😱','😖','😣','😞','😓','😩','😫','🥱','😤','😡','😠','🤬','😈','👿'],'Gestures':['👍','👎','👌','🤌','✌️','🤞','🤟','🤘','🤙','👈','👉','👆','🖕','👇','☝️','👋','🤚','🖐️','✋','🖖','👏','🙌','🤲','🤝','🙏','✍️','💅','🤳','💪','🦵','🦶','👂','👃'],'Hearts':['❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔','❣️','💕','💞','💓','💗','💖','💘','💝','💟'],'Nature':['🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮','🐷','🐸','🐵','🙈','🙉','🙊','🐔','🐧','🐦','🐤','🦆','🦅','🦉','🦇','🐺','🐗','🐴','🦄','🐝','🐛','🦋','🐌','🐞','🐜'],'Food':['🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐','🍈','🍒','🍑','🥭','🍍','🥥','🥝','🍅','🍆','🥑','🥦','🍔','🍟','🍕','🌮','🌯','🍜','🍝','🍣','🍱','🧁','🍰','🎂','🍩','🍪','☕','🍺','🍷'],'Objects':['📱','💻','🖥️','⌨️','🖱️','📷','📸','📹','🎥','📞','☎️','📺','📻','🔋','🔌','💡','🔦','💰','💳','💎','🔧','🔨','🛠️','🔩','🧲','✈️','🚀','🛸'],'Symbols':['❤️','🔥','⭐','✨','💫','🌟','💥','🎉','🎊','🎈','🎁','🏆','🥇','🎯','🎮','🎲','⚽','🏀','🏈','⚾','🎾','🏐']};
let currentCat='Smileys';
function initEmojiPicker(){const el=document.getElementById('emojiCats');if(!el)return;Object.keys(EMOJI_DATA).forEach(cat=>{const btn=document.createElement('button');btn.className='emoji-cat-btn'+(cat===currentCat?' active':'');btn.textContent=cat;btn.onclick=()=>{currentCat=cat;setActiveCat(cat);renderEmojis(EMOJI_DATA[cat]);};el.appendChild(btn);});renderEmojis(EMOJI_DATA[currentCat]);}
function setActiveCat(cat){document.querySelectorAll('.emoji-cat-btn').forEach(b=>b.classList.toggle('active',b.textContent===cat));}
function renderEmojis(list){const grid=document.getElementById('emojiGrid');if(!grid)return;grid.innerHTML='';list.forEach(e=>{const btn=document.createElement('button');btn.className='eg-btn';btn.textContent=e;btn.onclick=()=>insertEmoji(e);grid.appendChild(btn);});}
function filterEmojis(q){if(!q.trim()){renderEmojis(EMOJI_DATA[currentCat]);return;}renderEmojis(Object.values(EMOJI_DATA).flat().filter(e=>e.includes(q)));}
function toggleEmojiPicker(){const p=document.getElementById('emojiPicker');if(!p)return;p.classList.toggle('show');if(p.classList.contains('show'))document.getElementById('emojiSearch').focus();}
function insertEmoji(e){const inp=document.getElementById('msgInput');if(!inp)return;const s=inp.selectionStart,end=inp.selectionEnd;inp.value=inp.value.slice(0,s)+e+inp.value.slice(end);inp.selectionStart=inp.selectionEnd=s+e.length;inp.focus();autoResize(inp);}
document.addEventListener('click',e=>{const p=document.getElementById('emojiPicker'),t=document.getElementById('emojiToggleBtn');if(p&&t&&!p.contains(e.target)&&e.target!==t)p.classList.remove('show');});

const hideTimers=new WeakMap();
function showActions(row){if(hideTimers.has(row)){clearTimeout(hideTimers.get(row));hideTimers.delete(row);}const a=row.querySelector('.msg-actions');if(a)a.classList.add('visible');}
function scheduleHideActions(row){const t=setTimeout(()=>{const a=row.querySelector('.msg-actions');if(a)a.classList.remove('visible');hideTimers.delete(row);},450);hideTimers.set(row,t);}
function bindRowHover(row){row.addEventListener('mouseenter',()=>showActions(row));row.addEventListener('mouseleave',()=>scheduleHideActions(row));const a=row.querySelector('.msg-actions');if(a){a.addEventListener('mouseenter',()=>showActions(row));a.addEventListener('mouseleave',()=>scheduleHideActions(row));}}
function bindAllRows(){document.querySelectorAll('#chatMsgs .msg-row').forEach(row=>{if(!row.dataset.bound){bindRowHover(row);row.dataset.bound='1';}});}

document.addEventListener('DOMContentLoaded',()=>{
    scrollDown(false);initEmojiPicker();bindAllRows();
    pollTimer        = setInterval(poll,       3000);
    pollUpdatesTimer = setInterval(pollUpdates,1500); /* FIX 3: 4000→1500 */
    statusTimer      = setInterval(pollStatus, 5000);
    pollStatus();sendHeartbeat();heartbeatTimer=setInterval(sendHeartbeat,20000);
    document.getElementById('msgInput')?.focus();
});
window.addEventListener('beforeunload',()=>{
    clearInterval(pollTimer);clearInterval(pollUpdatesTimer);clearInterval(statusTimer);clearInterval(heartbeatTimer);clearTimeout(typingTimer);
    navigator.sendBeacon(CTX+'/customerChat',new URLSearchParams({action:'offline'}));
    if(isTypingSent)navigator.sendBeacon(CTX+'/customerChat',new URLSearchParams({action:'stopTyping'}));
});
</script>
<%@ include file="customerAIBubble.jsp" %>
</body>
</html>
