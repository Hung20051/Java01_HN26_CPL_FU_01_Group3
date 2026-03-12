<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    ServiceRequest sr=(ServiceRequest)request.getAttribute("sr");
    if(sr==null){response.sendRedirect(request.getContextPath()+"/customerServiceRequests");return;}
    String ctx=request.getContextPath();
    List<ServiceRequestEquipment> eqList=sr.getEquipmentList(); if(eqList==null)eqList=new ArrayList<>();
    String sc="b-pending";
    if("APPROVED".equals(sr.getStatus()))sc="b-approved";
    else if("REJECTED".equals(sr.getStatus()))sc="b-rejected";
    else if("IN_PROGRESS".equals(sr.getStatus()))sc="b-inprogress";
    else if("COMPLETED".equals(sr.getStatus()))sc="b-completed";
    else if("CANCELLED".equals(sr.getStatus()))sc="b-cancelled";
    String pc="b-medium";
    if("LOW".equals(sr.getPriority()))pc="b-low";
    else if("HIGH".equals(sr.getPriority()))pc="b-high";
    else if("URGENT".equals(sr.getPriority()))pc="b-urgent";
    boolean isW="WARRANTY".equals(sr.getContractType());
    boolean canCancel="PENDING".equals(sr.getStatus());
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    int unpaidInv=0; int unreadChat=0; int pendingSR=0;
    String initials=me.getFullName()!=null&&!me.getFullName().isEmpty()?me.getFullName().substring(0,1).toUpperCase():"?";
    boolean p2="APPROVED".equals(sr.getStatus())||"IN_PROGRESS".equals(sr.getStatus())||"COMPLETED".equals(sr.getStatus());
    boolean p3="IN_PROGRESS".equals(sr.getStatus())||"COMPLETED".equals(sr.getStatus());
    boolean p4="COMPLETED".equals(sr.getStatus());
    boolean rejected="REJECTED".equals(sr.getStatus());
    boolean cancelled="CANCELLED".equals(sr.getStatus());
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title><%=sr.getRequestCode()%> - DRSMS</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --navy:        #0b1437;
                --navy-card:   #111a42;
                --accent:      #4f7ef8;
                --accent-2:    #7c9ffa;
                --accent-glow: rgba(79,126,248,0.22);
                --green:       #34d399;
                --green-dim:   rgba(52,211,153,0.12);
                --amber:       #fbbf24;
                --amber-dim:   rgba(251,191,36,0.12);
                --danger:      #f87171;
                --danger-dim:  rgba(248,113,113,0.12);
                --purple:      #a78bfa;
                --purple-dim:  rgba(167,139,250,0.12);
                --info:        #38bdf8;
                --info-dim:    rgba(56,189,248,0.12);
                --text:        #ffffff;
                --text-2:      #c8d4f0;
                --muted:       #7a8ab8;
                --border:      rgba(255,255,255,0.07);
                --sb-width:    248px;
            }
            *,*::before,*::after{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            body{
                font-family:'Sora',sans-serif;
                background:var(--navy);
                color:var(--text);
                min-height:100vh;
                display:flex;
            }
            ::-webkit-scrollbar{
                width:4px
            }
            ::-webkit-scrollbar-track{
                background:var(--navy)
            }
            ::-webkit-scrollbar-thumb{
                background:rgba(79,126,248,0.4);
                border-radius:4px
            }

            /* ════ SIDEBAR ════ */
            .sb{
                width:var(--sb-width);
                min-height:100vh;
                background:rgba(9,15,40,0.95);
                backdrop-filter:blur(20px);
                border-right:1px solid var(--border);
                display:flex;
                flex-direction:column;
                position:fixed;
                top:0;
                left:0;
                z-index:100
            }
            .sb-brand{
                padding:22px 18px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid var(--border)
            }
            .sb-logo{
                width:36px;
                height:36px;
                background:linear-gradient(135deg,var(--accent),var(--accent-2));
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                box-shadow:0 4px 14px var(--accent-glow);
                flex-shrink:0
            }
            .sb-name{
                color:#fff;
                font-size:1rem;
                font-weight:700
            }
            .sb-role{
                display:inline-flex;
                align-items:center;
                background:rgba(79,126,248,0.15);
                border:1px solid rgba(79,126,248,0.25);
                color:var(--accent-2);
                font-size:.62rem;
                font-weight:700;
                letter-spacing:1px;
                text-transform:uppercase;
                padding:2px 8px;
                border-radius:20px;
                margin-top:3px
            }
            .sb-nav{
                flex:1;
                padding:12px 10px;
                overflow-y:auto
            }
            .sb-lbl{
                color:rgba(255,255,255,0.22);
                font-size:.62rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.4px;
                padding:0 8px;
                margin:16px 0 5px
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:9px;
                margin-bottom:1px;
                color:rgba(255,255,255,0.45);
                text-decoration:none;
                font-size:.83rem;
                font-weight:500;
                transition:all .2s;
                border-left:2px solid transparent
            }
            .sb-item i{
                width:28px;
                height:28px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.8rem;
                border-radius:8px;
                background:rgba(255,255,255,0.05);
                flex-shrink:0;
                transition:all .2s
            }
            .sb-item.on{
                color:#fff;
                background:linear-gradient(90deg,rgba(79,126,248,0.2),rgba(79,126,248,0.05));
                border-left:2px solid var(--accent)
            }
            .sb-item.on i{
                background:rgba(79,126,248,0.25);
                color:var(--accent-2)
            }
            .sb-item.si-home:hover{
                color:#fff;
                background:rgba(79,126,248,0.1);
                border-left-color:var(--accent)
            }
            .sb-item.si-home:hover i{
                background:rgba(79,126,248,0.2);
                color:var(--accent-2)
            }
            .sb-item.si-repair:hover{
                color:#fff;
                background:rgba(251,191,36,0.08);
                border-left-color:var(--amber)
            }
            .sb-item.si-repair:hover i{
                background:rgba(251,191,36,0.18);
                color:var(--amber)
            }
            .sb-item.si-contract:hover{
                color:#fff;
                background:rgba(167,139,250,0.08);
                border-left-color:var(--purple)
            }
            .sb-item.si-contract:hover i{
                background:rgba(167,139,250,0.18);
                color:var(--purple)
            }
            .sb-item.si-equip:hover{
                color:#fff;
                background:rgba(56,189,248,0.08);
                border-left-color:var(--info)
            }
            .sb-item.si-equip:hover i{
                background:rgba(56,189,248,0.18);
                color:var(--info)
            }
            .sb-item.si-parts:hover{
                color:#fff;
                background:rgba(52,211,153,0.07);
                border-left-color:var(--green)
            }
            .sb-item.si-parts:hover i{
                background:rgba(52,211,153,0.18);
                color:var(--green)
            }
            .sb-item.si-shop:hover{
                color:#fff;
                background:rgba(56,189,248,0.07);
                border-left-color:var(--info)
            }
            .sb-item.si-shop:hover i{
                background:rgba(56,189,248,0.18);
                color:var(--info)
            }
            .sb-item.si-cart:hover{
                color:#fff;
                background:rgba(251,146,60,0.08);
                border-left-color:#fb923c
            }
            .sb-item.si-cart:hover i{
                background:rgba(251,146,60,0.18);
                color:#fb923c
            }
            .sb-item.si-invoice:hover{
                color:#fff;
                background:rgba(52,211,153,0.07);
                border-left-color:var(--green)
            }
            .sb-item.si-invoice:hover i{
                background:rgba(52,211,153,0.18);
                color:var(--green)
            }
            .sb-item.si-chat:hover{
                color:#fff;
                background:rgba(251,113,133,0.08);
                border-left-color:#fb7185
            }
            .sb-item.si-chat:hover i{
                background:rgba(251,113,133,0.18);
                color:#fb7185
            }
            .sb-badge{
                margin-left:auto;
                background:var(--danger);
                color:#fff;
                font-size:.62rem;
                font-weight:700;
                padding:2px 6px;
                border-radius:20px;
                animation:badgePop 2s ease-in-out infinite
            }
            @keyframes badgePop{
                0%,100%{
                    transform:scale(1)
                }
                50%{
                    transform:scale(1.1)
                }
            }
            .sb-foot{
                padding:12px 10px 16px;
                border-top:1px solid var(--border)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:9px;
                padding:10px;
                border-radius:10px;
                background:rgba(255,255,255,0.04);
                border:1px solid var(--border);
                margin-bottom:6px;
                text-decoration:none;
                transition:all .2s
            }
            .sb-user:hover{
                background:rgba(79,126,248,0.1);
                border-color:rgba(79,126,248,0.25)
            }
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:linear-gradient(135deg,var(--accent),var(--purple));
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                font-weight:700;
                flex-shrink:0;
                overflow:hidden
            }
            .sb-ava img{
                width:34px;
                height:34px;
                object-fit:cover;
                border-radius:50%
            }
            .sb-uname{
                color:#fff;
                font-size:.82rem;
                font-weight:600
            }
            .sb-urole{
                color:var(--muted);
                font-size:.68rem;
                margin-top:1px
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:8px 10px;
                border-radius:8px;
                color:rgba(255,255,255,0.35);
                text-decoration:none;
                font-size:.8rem;
                transition:all .2s
            }
            .sb-logout:hover{
                color:var(--danger);
                background:rgba(248,113,113,0.08)
            }

            /* ════ MAIN ════ */
            .main{
                margin-left:var(--sb-width);
                flex:1;
                min-height:100vh;
                display:flex;
                flex-direction:column
            }
            .topbar{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:18px 32px;
                border-bottom:1px solid var(--border);
                background:rgba(11,20,55,0.6);
                backdrop-filter:blur(16px);
                position:sticky;
                top:0;
                z-index:50
            }
            .content{
                padding:26px 32px;
                flex:1
            }

            /* Breadcrumb */
            .breadcrumb{
                display:flex;
                align-items:center;
                gap:6px;
                font-size:.78rem;
                color:var(--muted);
                margin-bottom:18px
            }
            .breadcrumb a{
                color:var(--muted);
                text-decoration:none;
                transition:color .2s
            }
            .breadcrumb a:hover{
                color:var(--accent-2)
            }
            .bc-sep{
                color:rgba(255,255,255,0.2);
                font-size:.9rem
            }
            .bc-cur{
                color:var(--accent-2);
                font-weight:600;
                font-family:'Courier New',monospace
            }

            /* Page header */
            .page-hd{
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                margin-bottom:20px
            }
            .page-title{
                font-size:1.2rem;
                font-weight:800;
                color:#fff;
                display:flex;
                align-items:center;
                gap:9px;
                letter-spacing:-.3px
            }
            .page-title i{
                color:var(--amber)
            }
            .page-code{
                font-family:'Courier New',monospace;
                color:var(--accent-2);
                font-size:1rem
            }
            .page-sub{
                color:var(--muted);
                font-size:.82rem;
                margin-top:4px;
                font-weight:300
            }
            .actions{
                display:flex;
                gap:9px;
                align-items:center
            }

            .btn-back{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:9px 16px;
                border-radius:10px;
                background:rgba(255,255,255,0.05);
                color:var(--text-2);
                border:1px solid var(--border);
                text-decoration:none;
                font-size:.82rem;
                font-weight:600;
                transition:all .2s
            }
            .btn-back:hover{
                background:rgba(255,255,255,0.1);
                color:#fff
            }
            .btn-cancel-big{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:9px 16px;
                border-radius:10px;
                background:var(--danger-dim);
                color:var(--danger);
                border:1px solid rgba(248,113,113,0.25);
                font-size:.82rem;
                font-weight:600;
                cursor:pointer;
                font-family:'Sora',sans-serif;
                transition:all .2s
            }
            .btn-cancel-big:hover{
                background:rgba(248,113,113,0.22);
                transform:translateY(-1px)
            }

            /* Reject banner */
            .reject-box{
                display:flex;
                align-items:flex-start;
                gap:12px;
                padding:14px 18px;
                background:var(--danger-dim);
                border:1px solid rgba(248,113,113,0.25);
                border-radius:13px;
                margin-bottom:18px;
                font-size:.84rem;
                color:var(--danger);
                animation:cardIn .4s ease both
            }
            .reject-box i{
                margin-top:2px;
                flex-shrink:0
            }

            /* Grid */
            .grid-detail{
                display:grid;
                grid-template-columns:2fr 1fr;
                gap:18px;
                align-items:start
            }

            /* Cards */
            .card{
                background:rgba(17,26,66,0.7);
                border:1px solid var(--border);
                border-radius:16px;
                overflow:hidden;
                margin-bottom:16px;
                backdrop-filter:blur(12px);
                animation:cardIn .5s ease both
            }
            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(14px)
                }
                to{
                    opacity:1;
                    transform:translateY(0)
                }
            }
            .card:nth-child(1){
                animation-delay:.05s
            }
            .card:nth-child(2){
                animation-delay:.1s
            }
            .card:nth-child(3){
                animation-delay:.15s
            }
            .card-hd{
                padding:14px 20px;
                border-bottom:1px solid var(--border);
                display:flex;
                align-items:center;
                gap:10px
            }
            .card-hd-icon{
                width:30px;
                height:30px;
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.8rem;
                flex-shrink:0
            }
            .card-hd-title{
                font-size:.87rem;
                font-weight:700;
                color:#fff
            }
            .card-body{
                padding:18px 20px
            }

            /* Info rows */
            .info-row{
                display:flex;
                gap:10px;
                margin-bottom:13px;
                align-items:flex-start
            }
            .info-row:last-child{
                margin-bottom:0
            }
            .info-lbl{
                font-size:.72rem;
                color:var(--muted);
                font-weight:600;
                min-width:120px;
                padding-top:2px;
                text-transform:uppercase;
                letter-spacing:.4px
            }
            .info-val{
                font-size:.84rem;
                color:var(--text-2);
                flex:1;
                line-height:1.5
            }

            /* Badges */
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.7rem;
                font-weight:700;
                white-space:nowrap;
                letter-spacing:.2px
            }
            .b-pending   {
                background:rgba(251,191,36,0.12);
                color:#fbbf24;
                border:1px solid rgba(251,191,36,0.2)
            }
            .b-approved  {
                background:rgba(52,211,153,0.1);
                color:#34d399;
                border:1px solid rgba(52,211,153,0.2)
            }
            .b-rejected  {
                background:rgba(248,113,113,0.1);
                color:#f87171;
                border:1px solid rgba(248,113,113,0.2)
            }
            .b-inprogress{
                background:rgba(79,126,248,0.12);
                color:#7c9ffa;
                border:1px solid rgba(79,126,248,0.2)
            }
            .b-completed {
                background:rgba(167,139,250,0.12);
                color:#a78bfa;
                border:1px solid rgba(167,139,250,0.2)
            }
            .b-cancelled {
                background:rgba(255,255,255,0.05);
                color:var(--muted);
                border:1px solid var(--border)
            }
            .b-low       {
                background:rgba(52,211,153,0.08);
                color:#6ee7b7;
                border:1px solid rgba(52,211,153,0.15)
            }
            .b-medium    {
                background:rgba(251,191,36,0.1);
                color:#fcd34d;
                border:1px solid rgba(251,191,36,0.2)
            }
            .b-high      {
                background:rgba(251,146,60,0.1);
                color:#fb923c;
                border:1px solid rgba(251,146,60,0.2)
            }
            .b-urgent    {
                background:rgba(248,113,113,0.12);
                color:#fca5a5;
                border:1px solid rgba(248,113,113,0.2)
            }

            /* Contract tag */
            .ct-tag{
                display:inline-block;
                padding:3px 9px;
                border-radius:6px;
                font-size:.7rem;
                font-weight:700;
                margin-left:8px
            }
            .ct-wr{
                background:rgba(52,211,153,0.12);
                color:#34d399
            }
            .ct-mt{
                background:rgba(79,126,248,0.12);
                color:#7c9ffa
            }

            /* Description box */
            .desc-box{
                background:rgba(255,255,255,0.03);
                border:1px solid var(--border);
                border-radius:12px;
                padding:14px 16px;
                font-size:.84rem;
                color:var(--text-2);
                line-height:1.8;
                border-left:3px solid var(--accent)
            }

            /* Equipment items */
            .eq-item{
                display:flex;
                align-items:flex-start;
                gap:12px;
                padding:14px 0;
                border-bottom:1px solid rgba(255,255,255,0.04)
            }
            .eq-item:last-child{
                border-bottom:none
            }
            .eq-num{
                width:30px;
                height:30px;
                border-radius:50%;
                background:rgba(79,126,248,0.15);
                color:var(--accent-2);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.75rem;
                font-weight:700;
                flex-shrink:0;
                border:1px solid rgba(79,126,248,0.25)
            }
            .eq-name{
                font-size:.875rem;
                font-weight:600;
                color:var(--text)
            }
            .eq-serial{
                font-size:.75rem;
                color:var(--muted);
                font-family:'Courier New',monospace;
                margin-top:3px;
                display:flex;
                align-items:center;
                gap:6px
            }
            .eq-src{
                padding:1px 7px;
                border-radius:4px;
                font-size:.68rem;
                font-weight:700
            }
            .eq-src-ext{
                background:rgba(251,191,36,0.12);
                color:var(--amber)
            }
            .eq-src-sys{
                background:rgba(79,126,248,0.12);
                color:var(--accent-2)
            }
            .eq-issue{
                font-size:.8rem;
                color:var(--text-2);
                margin-top:8px;
                padding:8px 10px;
                background:rgba(251,191,36,0.06);
                border-radius:8px;
                border-left:3px solid var(--amber);
                display:flex;
                gap:6px;
                align-items:flex-start
            }

            /* Timeline */
            .timeline{
                padding:4px 0;
                position:relative
            }
            .tl-item{
                display:flex;
                gap:14px;
                padding:10px 0;
                position:relative
            }
            .tl-item:not(:last-child)::after{
                content:'';
                position:absolute;
                left:14px;
                top:40px;
                bottom:-2px;
                width:2px;
                background:var(--border);
                z-index:0
            }
            .tl-dot{
                width:30px;
                height:30px;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.78rem;
                flex-shrink:0;
                border:2px solid;
                position:relative;
                z-index:1
            }
            .tl-dot.done{
                background:linear-gradient(135deg,var(--green),#22c97a);
                border-color:var(--green);
                color:#fff;
                box-shadow:0 0 12px rgba(52,211,153,0.3)
            }
            .tl-dot.current{
                background:rgba(79,126,248,0.15);
                border-color:var(--accent);
                color:var(--accent-2);
                box-shadow:0 0 12px var(--accent-glow)
            }
            .tl-dot.wait{
                background:rgba(255,255,255,0.03);
                border-color:var(--border);
                color:var(--muted)
            }
            .tl-dot.fail{
                background:var(--danger-dim);
                border-color:var(--danger);
                color:var(--danger)
            }
            .tl-dot.skip{
                background:rgba(255,255,255,0.03);
                border-color:rgba(255,255,255,0.1);
                color:rgba(255,255,255,0.2)
            }
            .tl-content{
                flex:1;
                padding-top:4px
            }
            .tl-label{
                font-size:.84rem;
                font-weight:600;
                color:var(--text)
            }
            .tl-label.dim{
                color:var(--muted)
            }
            .tl-sub{
                font-size:.74rem;
                color:var(--muted);
                margin-top:3px
            }

            /* Technician card */
            .tech-avatar{
                width:44px;
                height:44px;
                border-radius:50%;
                background:linear-gradient(135deg,var(--info),#0ea5e9);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.1rem;
                font-weight:700;
                color:#fff;
                flex-shrink:0;
                box-shadow:0 4px 12px rgba(56,189,248,0.25)
            }
            .tech-name{
                font-size:.875rem;
                font-weight:600;
                color:var(--text)
            }
            .tech-role{
                font-size:.74rem;
                color:var(--muted);
                margin-top:2px
            }

            /* Contract note card */
            .note-card-w{
                background:rgba(52,211,153,0.06);
                border:1px solid rgba(52,211,153,0.2);
                border-radius:14px;
                padding:16px
            }
            .note-card-m{
                background:rgba(79,126,248,0.06);
                border:1px solid rgba(79,126,248,0.2);
                border-radius:14px;
                padding:16px
            }
            .note-icon{
                font-size:1.3rem;
                flex-shrink:0
            }
            .note-title-w{
                font-size:.84rem;
                font-weight:700;
                color:var(--green)
            }
            .note-title-m{
                font-size:.84rem;
                font-weight:700;
                color:var(--accent-2)
            }
            .note-desc{
                font-size:.77rem;
                margin-top:3px;
                line-height:1.5
            }
            .note-desc-w{
                color:rgba(52,211,153,0.8)
            }
            .note-desc-m{
                color:rgba(124,159,250,0.8)
            }

            /* Code link */
            .code-link{
                color:var(--accent-2);
                font-weight:700;
                font-family:'Courier New',monospace;
                font-size:.84rem;
                text-decoration:none
            }
            .code-link:hover{
                color:#fff
            }
        </style>
    </head>
    <body>

        <%-- ═══ SIDEBAR ═══ --%>
        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-bolt"></i></div>
                <div><div class="sb-name">DRSMS</div><div class="sb-role">Customer</div></div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/customerDashboard" class="sb-item si-home"><i class="fas fa-home"></i> Dashboard</a>
                <div class="sb-lbl">Services</div>
                <a href="<%=ctx%>/customerServiceRequests" class="sb-item on si-repair">
                    <i class="fas fa-clipboard-list"></i> Repair Requests
                    <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
                </a>
                <a href="<%=ctx%>/customerContracts"   class="sb-item si-contract"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/customerEquipment"   class="sb-item si-equip"><i class="fas fa-desktop"></i> My Equipment</a>
                <div class="sb-lbl">Shop</div>
                <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item si-parts"><i class="fas fa-puzzle-piece"></i> Parts</a>
                <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item si-shop"><i class="fas fa-server"></i> Equipment</a>
                <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item si-cart">
                    <i class="fas fa-shopping-cart"></i> Cart
                    <%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%>
                </a>
                <div class="sb-lbl">Finance</div>
                <a href="<%=ctx%>/customerInvoices" class="sb-item si-invoice">
                    <i class="fas fa-receipt"></i> Invoices
                    <%if(unpaidInv>0){%><span class="sb-badge"><%=unpaidInv%></span><%}%>
                </a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/customerChat" class="sb-item si-chat">
                    <i class="fas fa-comment-dots"></i> Support Chat
                    <%if(unreadChat>0){%><span class="sb-badge"><%=unreadChat%></span><%}%>
                </a>
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

        <%-- ═══ MAIN ═══ --%>
        <main class="main">

            <%-- Topbar --%>
            <div class="topbar">
                <div class="breadcrumb" style="margin:0">
                    <a href="<%=ctx%>/customerDashboard"><i class="fas fa-home"></i></a>
                    <span class="bc-sep">›</span>
                    <a href="<%=ctx%>/customerServiceRequests">Repair Requests</a>
                    <span class="bc-sep">›</span>
                    <span class="bc-cur"><%=sr.getRequestCode()%></span>
                </div>
                <div class="actions">
                    <a href="<%=ctx%>/customerServiceRequests" class="btn-back">
                        <i class="fas fa-arrow-left"></i> Back
                    </a>
                    <%if(canCancel){%>
                    <form method="post" action="<%=ctx%>/customerServiceRequests" style="display:inline"
                          onsubmit="return confirm('Are you sure you want to cancel this request?')">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="id" value="<%=sr.getId()%>">
                        <button type="submit" class="btn-cancel-big">
                            <i class="fas fa-times-circle"></i> Cancel Request
                        </button>
                    </form>
                    <%}%>
                </div>
            </div>

            <div class="content">

                <%-- Page header --%>
                <div class="page-hd">
                    <div>
                        <div class="page-title">
                            <i class="fas fa-clipboard-check"></i>
                            Request Detail &nbsp;<span class="page-code"><%=sr.getRequestCode()%></span>
                        </div>
                        <div class="page-sub"><%=sr.getTitle()%></div>
                    </div>
                </div>

                <%-- Reject banner --%>
                <%if(rejected && sr.getRejectReason()!=null){%>
                <div class="reject-box">
                    <i class="fas fa-ban"></i>
                    <div><strong>Request rejected:</strong> <%=sr.getRejectReason()%></div>
                </div>
                <%}%>

                <div class="grid-detail">

                    <%-- LEFT COLUMN --%>
                    <div>

                        <%-- Request info --%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:rgba(79,126,248,0.2);color:var(--accent-2)">
                                    <i class="fas fa-info"></i>
                                </div>
                                <div class="card-hd-title">Request Information</div>
                            </div>
                            <div class="card-body">
                                <div class="info-row">
                                    <div class="info-lbl">Request Code</div>
                                    <div class="info-val">
                                        <span style="font-family:'Courier New',monospace;font-weight:700;color:var(--accent-2);font-size:.9rem"><%=sr.getRequestCode()%></span>
                                    </div>
                                </div>
                                <div class="info-row">
                                    <div class="info-lbl">Title</div>
                                    <div class="info-val" style="color:#fff;font-weight:600"><%=sr.getTitle()%></div>
                                </div>
                                <div class="info-row">
                                    <div class="info-lbl">Contract</div>
                                    <div class="info-val">
                                        <a href="<%=ctx%>/customerContracts?action=detail&id=<%=sr.getContractId()%>" class="code-link"><%=sr.getContractCode()%></a>
                                        <span class="ct-tag <%=isW?"ct-wr":"ct-mt"%>"><%=isW?"Warranty":"Maintenance"%></span>
                                    </div>
                                </div>
                                <div class="info-row">
                                    <div class="info-lbl">Priority</div>
                                    <div class="info-val"><span class="b <%=pc%>"><%=sr.getPriorityLabel()%></span></div>
                                </div>
                                <div class="info-row">
                                    <div class="info-lbl">Status</div>
                                    <div class="info-val"><span class="b <%=sc%>"><%=sr.getStatusLabel()%></span></div>
                                </div>
                                <div class="info-row">
                                    <div class="info-lbl">Created</div>
                                    <div class="info-val td-muted"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().replace("T"," ").substring(0,16):"—"%></div>
                                </div>
                                <%if(sr.getCompletedAt()!=null){%>
                                <div class="info-row">
                                    <div class="info-lbl">Completed</div>
                                    <div class="info-val" style="color:var(--green);font-weight:600">
                                        <i class="fas fa-check-circle" style="margin-right:4px"></i><%=sr.getCompletedAt().toString().replace("T"," ").substring(0,16)%>
                                    </div>
                                </div>
                                <%}%>
                            </div>
                        </div>

                        <%-- Description --%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:rgba(167,139,250,0.2);color:var(--purple)">
                                    <i class="fas fa-align-left"></i>
                                </div>
                                <div class="card-hd-title">Issue Description</div>
                            </div>
                            <div class="card-body">
                                <div class="desc-box"><%=sr.getDescription().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\n","<br>")%></div>
                            </div>
                        </div>

                        <%-- Equipment --%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:rgba(56,189,248,0.2);color:var(--info)">
                                    <i class="fas fa-desktop"></i>
                                </div>
                                <div class="card-hd-title">Equipment to Repair <span style="color:var(--muted);font-weight:400">(<%=eqList.size()%>)</span></div>
                            </div>
                            <div class="card-body" style="padding-top:4px;padding-bottom:4px">
                                <%if(eqList.isEmpty()){%>
                                <p style="color:var(--muted);font-size:.84rem;padding:14px 0;text-align:center">
                                    <i class="fas fa-desktop" style="font-size:1.5rem;display:block;margin-bottom:6px;opacity:.2"></i>
                                    No equipment information available.
                                </p>
                                <%}else{for(int i=0;i<eqList.size();i++){ServiceRequestEquipment eq=eqList.get(i);%>
                                <div class="eq-item">
                                    <div class="eq-num"><%=i+1%></div>
                                    <div style="flex:1">
                                        <div class="eq-name"><%=eq.getDisplayName()!=null?eq.getDisplayName():"Equipment #"+eq.getCustomerEquipmentId()%></div>
                                        <div class="eq-serial">
                                            <i class="fas fa-barcode" style="font-size:.68rem"></i>
                                            <%=eq.getDisplaySerial()!=null?eq.getDisplaySerial():"N/A"%>
                                            <span class="eq-src <%="EXTERNAL".equals(eq.getSource())?"eq-src-ext":"eq-src-sys"%>">
                                                <%="EXTERNAL".equals(eq.getSource())?"External":"In-System"%>
                                            </span>
                                        </div>
                                        <%if(eq.getIssueDescription()!=null&&!eq.getIssueDescription().isEmpty()){%>
                                        <div class="eq-issue">
                                            <i class="fas fa-exclamation-circle" style="color:var(--amber);margin-top:1px;flex-shrink:0"></i>
                                            <span><%=eq.getIssueDescription()%></span>
                                        </div>
                                        <%}%>
                                    </div>
                                </div>
                                <%}}%>
                            </div>
                        </div>
                    </div>

                    <%-- RIGHT COLUMN --%>
                    <div>

                        <%-- Progress timeline --%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:rgba(52,211,153,0.2);color:var(--green)">
                                    <i class="fas fa-tasks"></i>
                                </div>
                                <div class="card-hd-title">Processing Progress</div>
                            </div>
                            <div class="card-body">
                                <div class="timeline">
                                    <%-- Step 1: Submitted (always done) --%>
                                    <div class="tl-item">
                                        <div class="tl-dot done"><i class="fas fa-check"></i></div>
                                        <div class="tl-content">
                                            <div class="tl-label">Request Submitted</div>
                                            <div class="tl-sub"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toLocalDate():""%></div>
                                        </div>
                                    </div>

                                    <%if(cancelled){%>
                                    <div class="tl-item">
                                        <div class="tl-dot skip"><i class="fas fa-ban"></i></div>
                                        <div class="tl-content">
                                            <div class="tl-label dim">Cancelled</div>
                                            <div class="tl-sub">Request was cancelled</div>
                                        </div>
                                    </div>
                                    <%}else if(rejected){%>
                                    <div class="tl-item">
                                        <div class="tl-dot fail"><i class="fas fa-times"></i></div>
                                        <div class="tl-content">
                                            <div class="tl-label" style="color:var(--danger)">Rejected</div>
                                            <div class="tl-sub"><%=sr.getReviewedAt()!=null?sr.getReviewedAt().toLocalDate():""%></div>
                                        </div>
                                    </div>
                                    <%}else{%>
                                    <%-- Step 2: Approval --%>
                                    <div class="tl-item">
                                        <div class="tl-dot <%=p2?"done":("PENDING".equals(sr.getStatus())?"current":"wait")%>">
                                            <i class="fas fa-<%=p2?"check":"clock"%>"></i>
                                        </div>
                                        <div class="tl-content">
                                            <div class="tl-label <%=p2?"":"dim"%>"><%=p2?"Approved":"Awaiting Approval"%></div>
                                            <%if(p2&&sr.getReviewedByName()!=null){%>
                                            <div class="tl-sub"><%=sr.getReviewedByName()%><%=sr.getReviewedAt()!=null?" · "+sr.getReviewedAt().toLocalDate():""%></div>
                                            <%}%>
                                        </div>
                                    </div>
                                    <%-- Step 3: In Progress --%>
                                    <div class="tl-item">
                                        <div class="tl-dot <%=p3?"done":(p2?"current":"wait")%>">
                                            <i class="fas fa-<%=p3?"check":"spinner"%>"></i>
                                        </div>
                                        <div class="tl-content">
                                            <div class="tl-label <%=p3||p2?"":"dim"%>"><%=p3?"In Progress":"Awaiting Technician"%></div>
                                            <%if(sr.getAssignedToName()!=null){%>
                                            <div class="tl-sub">Technician: <%=sr.getAssignedToName()%></div>
                                            <%}%>
                                        </div>
                                    </div>
                                    <%-- Step 4: Completed --%>
                                    <div class="tl-item">
                                        <div class="tl-dot <%=p4?"done":"wait"%>">
                                            <i class="fas fa-<%=p4?"check-circle":"flag"%>"></i>
                                        </div>
                                        <div class="tl-content">
                                            <div class="tl-label <%=p4?"":"dim"%>" <%=p4?"style='color:var(--green)'":""%>><%=p4?"Completed!":"Completion"%></div>
                                            <%if(p4&&sr.getCompletedAt()!=null){%>
                                            <div class="tl-sub" style="color:var(--green)"><%=sr.getCompletedAt().toLocalDate()%></div>
                                            <%}%>
                                        </div>
                                    </div>
                                    <%}%>
                                </div>
                            </div>
                        </div>

                        <%-- Assigned technician --%>
                        <div class="card">
                            <div class="card-hd">
                                <div class="card-hd-icon" style="background:rgba(56,189,248,0.2);color:var(--info)">
                                    <i class="fas fa-user-hard-hat"></i>
                                </div>
                                <div class="card-hd-title">Assigned Staff</div>
                            </div>
                            <div class="card-body">
                                <%if(sr.getAssignedToName()!=null){%>
                                <div style="display:flex;align-items:center;gap:12px">
                                    <div class="tech-avatar"><%=sr.getAssignedToName().substring(0,1).toUpperCase()%></div>
                                    <div>
                                        <div class="tech-name"><%=sr.getAssignedToName()%></div>
                                        <div class="tech-role"><i class="fas fa-wrench" style="margin-right:4px;color:var(--info)"></i>Technician</div>
                                    </div>
                                </div>
                                <%}else{%>
                                <div style="text-align:center;padding:14px 0;color:var(--muted);font-size:.83rem">
                                    <i class="fas fa-user-clock" style="font-size:1.8rem;display:block;margin-bottom:8px;opacity:.2"></i>
                                    Not yet assigned
                                </div>
                                <%}%>
                            </div>
                        </div>

                        <%-- Contract type note --%>
                        <div class="<%=isW?"note-card-w":"note-card-m"%>">
                            <div style="display:flex;align-items:flex-start;gap:12px">
                                <i class="fas fa-<%=isW?"shield-alt":"tools"%> note-icon" style="color:<%=isW?"var(--green)":"var(--accent-2)"%>;margin-top:2px"></i>
                                <div>
                                    <div class="<%=isW?"note-title-w":"note-title-m"%>">
                                        <%=isW?"Warranty Contract":"Maintenance Contract"%>
                                    </div>
                                    <div class="note-desc <%=isW?"note-desc-w":"note-desc-m"%>">
                                        <%=isW?"Repair service is FREE under the warranty contract.":"Repair costs will be calculated and notified later."%>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </main>
    </body>
</html>
