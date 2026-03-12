<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*,java.math.BigDecimal" %>
<%
    User me = (User) session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    long   activeContracts = request.getAttribute("activeContracts")!=null?(Long)request.getAttribute("activeContracts"):0;
    int    totalContracts  = request.getAttribute("totalContracts") !=null?(Integer)request.getAttribute("totalContracts"):0;
    int    totalSR         = request.getAttribute("totalSR")        !=null?(Integer)request.getAttribute("totalSR"):0;
    int    pendingSR       = request.getAttribute("pendingSR")      !=null?(Integer)request.getAttribute("pendingSR"):0;
    int    activeSR        = request.getAttribute("activeSR")       !=null?(Integer)request.getAttribute("activeSR"):0;
    int    completedSR     = request.getAttribute("completedSR")    !=null?(Integer)request.getAttribute("completedSR"):0;
    int    unreadChat      = request.getAttribute("unreadChat")     !=null?(Integer)request.getAttribute("unreadChat"):0;
    Map<String,Object> inv = (Map<String,Object>) request.getAttribute("invSummary");
    List<ServiceRequest> recent = (List<ServiceRequest>) request.getAttribute("recentSR");
    if(recent==null) recent=new ArrayList<>();
    int unpaidInv = inv!=null&&inv.get("unpaid")!=null?(Integer)inv.get("unpaid"):0;
    BigDecimal unpaidAmt = inv!=null?(BigDecimal)inv.get("unpaidAmt"):null;
    String ctx = request.getContextPath();
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
    Map<?,?> shopCart = (Map<?,?>) session.getAttribute("shopCart");
    int cartCount = shopCart != null ? shopCart.size() : 0;
    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Dashboard - DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --navy:        #0b1437;
            --navy-2:      #0f1c4d;
            --navy-card:   #111a42;
            --navy-light:  #162050;
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
            --border-2:    rgba(255,255,255,0.04);
            --sb-width:    248px;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; }
        body {
            font-family: 'Sora', sans-serif;
            background: var(--navy);
            color: var(--text);
            min-height: 100vh;
            display: flex;
        }
        ::-webkit-scrollbar { width: 4px; }
        ::-webkit-scrollbar-track { background: var(--navy); }
        ::-webkit-scrollbar-thumb { background: rgba(79,126,248,0.4); border-radius: 4px; }

        /* ════════════════════ SIDEBAR ════════════════════ */
        .sb {
            width: var(--sb-width);
            min-height: 100vh;
            background: rgba(9,15,40,0.95);
            backdrop-filter: blur(20px);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0; left: 0;
            z-index: 100;
        }
        .sb-brand {
            padding: 22px 18px 16px;
            display: flex; align-items: center; gap: 10px;
            border-bottom: 1px solid var(--border);
        }
        .sb-logo {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 0.88rem;
            box-shadow: 0 4px 14px var(--accent-glow);
            flex-shrink: 0;
        }
        .sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
        .sb-role {
            display: inline-flex; align-items: center;
            background: rgba(79,126,248,0.15);
            border: 1px solid rgba(79,126,248,0.25);
            color: var(--accent-2);
            font-size: 0.62rem; font-weight: 700;
            letter-spacing: 1px; text-transform: uppercase;
            padding: 2px 8px; border-radius: 20px;
            margin-top: 3px;
        }
        .sb-nav { flex: 1; padding: 12px 10px; overflow-y: auto; }
        .sb-lbl {
            color: rgba(255,255,255,0.22);
            font-size: 0.62rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.4px;
            padding: 0 8px; margin: 16px 0 5px;
        }
        .sb-item {
            display: flex; align-items: center; gap: 9px;
            padding: 9px 10px; border-radius: 9px;
            margin-bottom: 1px;
            color: rgba(255,255,255,0.45);
            text-decoration: none;
            font-size: 0.83rem; font-weight: 500;
            transition: all 0.2s;
            position: relative;
            border-left: 2px solid transparent;
        }
        .sb-item i {
            width: 28px; height: 28px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.8rem; border-radius: 8px;
            background: rgba(255,255,255,0.05);
            flex-shrink: 0;
            transition: all 0.2s;
        }
        .sb-item.on {
            color: #fff;
            background: linear-gradient(90deg, rgba(79,126,248,0.2), rgba(79,126,248,0.05));
            border-left: 2px solid var(--accent);
        }
        .sb-item.on i { background: rgba(79,126,248,0.25); color: var(--accent-2); }

        /* Dashboard - blue */
        .sb-item.si-home:hover       { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
        .sb-item.si-home:hover i     { background: rgba(79,126,248,0.2); color: var(--accent-2); }

        /* Repair Requests - amber */
        .sb-item.si-repair:hover     { color: #fff; background: rgba(251,191,36,0.08); border-left-color: var(--amber); }
        .sb-item.si-repair:hover i   { background: rgba(251,191,36,0.18); color: var(--amber); }

        /* Contracts - purple */
        .sb-item.si-contract:hover   { color: #fff; background: rgba(167,139,250,0.08); border-left-color: var(--purple); }
        .sb-item.si-contract:hover i { background: rgba(167,139,250,0.18); color: var(--purple); }

        /* Equipment - cyan */
        .sb-item.si-equip:hover      { color: #fff; background: rgba(56,189,248,0.08); border-left-color: var(--info); }
        .sb-item.si-equip:hover i    { background: rgba(56,189,248,0.18); color: var(--info); }

        /* Parts shop - green */
        .sb-item.si-parts:hover      { color: #fff; background: rgba(52,211,153,0.07); border-left-color: var(--green); }
        .sb-item.si-parts:hover i    { background: rgba(52,211,153,0.18); color: var(--green); }

        /* Shop equipment - cyan */
        .sb-item.si-shop:hover       { color: #fff; background: rgba(56,189,248,0.07); border-left-color: var(--info); }
        .sb-item.si-shop:hover i     { background: rgba(56,189,248,0.18); color: var(--info); }

        /* Cart - amber/orange */
        .sb-item.si-cart:hover       { color: #fff; background: rgba(251,146,60,0.08); border-left-color: #fb923c; }
        .sb-item.si-cart:hover i     { background: rgba(251,146,60,0.18); color: #fb923c; }

        /* Invoices - green */
        .sb-item.si-invoice:hover    { color: #fff; background: rgba(52,211,153,0.07); border-left-color: var(--green); }
        .sb-item.si-invoice:hover i  { background: rgba(52,211,153,0.18); color: var(--green); }

        /* Chat - pink/rose */
        .sb-item.si-chat:hover       { color: #fff; background: rgba(251,113,133,0.08); border-left-color: #fb7185; }
        .sb-item.si-chat:hover i     { background: rgba(251,113,133,0.18); color: #fb7185; }
        .sb-badge {
            margin-left: auto;
            background: var(--danger);
            color: #fff; font-size: 0.62rem; font-weight: 700;
            padding: 2px 6px; border-radius: 20px;
            animation: badgePop 2s ease-in-out infinite;
        }
        @keyframes badgePop {
            0%,100% { transform: scale(1); }
            50%      { transform: scale(1.1); }
        }
        .sb-foot {
            padding: 12px 10px 16px;
            border-top: 1px solid var(--border);
        }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px 10px;
            border-radius: 10px;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border);
            margin-bottom: 6px;
            text-decoration: none;
            transition: all 0.2s;
            cursor: pointer;
        }
        .sb-user:hover { background: rgba(79,126,248,0.1); border-color: rgba(79,126,248,0.25); }
        .sb-ava {
            width: 34px; height: 34px; border-radius: 50%;
            background: linear-gradient(135deg, var(--accent), var(--purple));
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 0.88rem; font-weight: 700;
            flex-shrink: 0; overflow: hidden;
        }
        .sb-ava img { width: 34px; height: 34px; object-fit: cover; border-radius: 50%; }
        .sb-uname { color: #fff; font-size: 0.82rem; font-weight: 600; }
        .sb-urole { color: var(--muted); font-size: 0.68rem; margin-top: 1px; }
        .sb-logout {
            display: flex; align-items: center; gap: 8px;
            width: 100%; padding: 8px 10px; border-radius: 8px;
            color: rgba(255,255,255,0.35); text-decoration: none;
            font-size: 0.8rem; transition: all 0.2s;
        }
        .sb-logout:hover { color: var(--danger); background: rgba(248,113,113,0.08); }

        /* ════════════════════ MAIN ════════════════════ */
        .main {
            margin-left: var(--sb-width);
            flex: 1;
            padding: 0;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Topbar */
        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 22px 32px;
            border-bottom: 1px solid var(--border);
            background: rgba(11,20,55,0.6);
            backdrop-filter: blur(16px);
            position: sticky; top: 0; z-index: 50;
        }
        .topbar-greeting { font-size: 1.25rem; font-weight: 800; color: #fff; letter-spacing: -0.3px; }
        .topbar-sub { color: var(--muted); font-size: 0.8rem; margin-top: 2px; font-weight: 300; }
        .btn-cta {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 11px 22px;
            background: linear-gradient(135deg, #4f7ef8, #a78bfa);
            color: #fff; text-decoration: none;
            font-size: 0.84rem; font-weight: 700;
            border-radius: 11px;
            box-shadow: 0 4px 20px rgba(79,126,248,0.4);
            transition: all 0.25s;
            animation: ctaPulse 3s ease-in-out infinite;
        }
        @keyframes ctaPulse {
            0%,100% { box-shadow: 0 4px 20px rgba(79,126,248,0.35); }
            50%      { box-shadow: 0 4px 32px rgba(79,126,248,0.65), 0 0 0 5px rgba(79,126,248,0.08); }
        }
        .btn-cta:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 32px rgba(79,126,248,0.55);
            animation: none;
        }

        /* Content */
        .content { padding: 28px 32px; flex: 1; }

        /* Alert unpaid */
        .alert-warn {
            display: flex; align-items: center; gap: 12px;
            padding: 13px 18px;
            background: rgba(251,191,36,0.08);
            border: 1px solid rgba(251,191,36,0.25);
            border-radius: 12px;
            margin-bottom: 22px;
            font-size: 0.84rem; color: var(--text-2);
            animation: cardIn 0.5s ease both;
        }
        .alert-warn i { color: var(--amber); font-size: 1rem; flex-shrink: 0; }
        .alert-warn a {
            color: var(--amber); font-weight: 700;
            text-decoration: none; margin-left: 6px;
        }
        .alert-warn a:hover { color: #fff; }

        /* Section label */
        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 12px;
        }

        /* ── STAT CARDS ── */
        .stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
            margin-bottom: 26px;
        }
        .sc {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px;
            position: relative; overflow: hidden;
            backdrop-filter: blur(12px);
            transition: all 0.25s;
            animation: cardIn 0.5s ease both;
        }
        .sc:nth-child(1){ animation-delay: 0.05s; }
        .sc:nth-child(2){ animation-delay: 0.10s; }
        .sc:nth-child(3){ animation-delay: 0.15s; }
        .sc:nth-child(4){ animation-delay: 0.20s; }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .sc:hover { transform: translateY(-3px); box-shadow: 0 12px 32px rgba(0,0,0,0.25); }
        .sc::before {
            content: ''; position: absolute;
            top: 0; left: 16px; right: 16px;
            height: 1px;
        }
        .sc-purple::before { background: linear-gradient(90deg, transparent, var(--purple), transparent); }
        .sc-blue::before   { background: linear-gradient(90deg, transparent, var(--accent-2), transparent); }
        .sc-green::before  { background: linear-gradient(90deg, transparent, var(--green), transparent); }
        .sc-red::before    { background: linear-gradient(90deg, transparent, var(--danger), transparent); }
        .sc-greenok::before{ background: linear-gradient(90deg, transparent, var(--green), transparent); }
        .sc::after {
            content: ''; position: absolute;
            top: 0; right: 0; bottom: 0;
            width: 3px; border-radius: 0 16px 16px 0;
        }
        .sc-purple::after { background: linear-gradient(180deg, var(--purple), transparent); }
        .sc-blue::after   { background: linear-gradient(180deg, var(--accent), transparent); }
        .sc-green::after  { background: linear-gradient(180deg, var(--green), transparent); }
        .sc-red::after    { background: linear-gradient(180deg, var(--danger), transparent); }
        .sc-greenok::after{ background: linear-gradient(180deg, var(--green), transparent); }

        .sc-icon {
            width: 40px; height: 40px; border-radius: 11px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.95rem; margin-bottom: 14px;
        }
        .sc-purple .sc-icon { background: var(--purple-dim); color: var(--purple); }
        .sc-blue   .sc-icon { background: rgba(79,126,248,0.12); color: var(--accent-2); }
        .sc-green  .sc-icon { background: var(--green-dim); color: var(--green); }
        .sc-red    .sc-icon { background: var(--danger-dim); color: var(--danger); }
        .sc-greenok .sc-icon { background: var(--green-dim); color: var(--green); }

        .sc-val {
            font-size: 2rem; font-weight: 800;
            color: #fff; line-height: 1;
            letter-spacing: -1px;
        }
        .sc-lbl { color: var(--text-2); font-size: 0.78rem; margin-top: 5px; font-weight: 500; }
        .sc-sub { font-size: 0.72rem; margin-top: 6px; color: var(--muted); }
        .sc-sub.warn { color: var(--amber); }
        .sc-sub.info { color: var(--info); }
        .sc-sub.ok   { color: var(--green); }

        /* ── GRID ── */
        .grid-2 {
            display: grid;
            grid-template-columns: 3fr 2fr;
            gap: 18px;
        }

        /* ── CARD ── */
        .card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s 0.25s ease both;
        }
        .card-hd {
            display: flex; justify-content: space-between; align-items: center;
            padding: 16px 20px;
            border-bottom: 1px solid var(--border);
        }
        .card-title {
            font-size: 0.87rem; font-weight: 700; color: #fff;
            display: flex; align-items: center; gap: 8px;
        }
        .card-title i { color: var(--accent-2); font-size: 0.82rem; }
        .card-link {
            font-size: 0.75rem; font-weight: 600;
            color: var(--accent-2); text-decoration: none;
            transition: color 0.2s;
        }
        .card-link:hover { color: #fff; }

        /* ── TABLE ── */
        table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
        thead tr { background: rgba(255,255,255,0.02); }
        th {
            padding: 10px 16px;
            text-align: left;
            color: var(--muted); font-weight: 600;
            font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.8px;
            border-bottom: 1px solid var(--border);
        }
        td {
            padding: 12px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.03);
            vertical-align: middle;
            color: var(--text-2);
        }
        tr:last-child td { border-bottom: none; }
        tbody tr { transition: background 0.15s; }
        tbody tr:hover td { background: rgba(79,126,248,0.05); }

        /* ── BADGES ── */
        .b {
            display: inline-flex; align-items: center;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
            white-space: nowrap; letter-spacing: 0.2px;
        }
        .b-pending    { background: rgba(251,191,36,0.12);  color: #fbbf24; border: 1px solid rgba(251,191,36,0.2); }
        .b-approved   { background: rgba(52,211,153,0.1);   color: #34d399; border: 1px solid rgba(52,211,153,0.2); }
        .b-rejected   { background: rgba(248,113,113,0.1);  color: #f87171; border: 1px solid rgba(248,113,113,0.2); }
        .b-inprogress { background: rgba(79,126,248,0.12);  color: #7c9ffa; border: 1px solid rgba(79,126,248,0.2); }
        .b-completed  { background: rgba(167,139,250,0.12); color: #a78bfa; border: 1px solid rgba(167,139,250,0.2); }
        .b-cancelled  { background: rgba(255,255,255,0.05); color: var(--muted); border: 1px solid var(--border); }
        .b-low        { background: rgba(52,211,153,0.08);  color: #6ee7b7; border: 1px solid rgba(52,211,153,0.15); }
        .b-medium     { background: rgba(251,191,36,0.1);   color: #fcd34d; border: 1px solid rgba(251,191,36,0.2); }
        .b-high       { background: rgba(251,146,60,0.1);   color: #fb923c; border: 1px solid rgba(251,146,60,0.2); }
        .b-urgent     { background: rgba(248,113,113,0.12); color: #fca5a5; border: 1px solid rgba(248,113,113,0.2); }

        /* Contract type mini badge */
        .ct-badge {
            display: inline-flex; align-items: center;
            padding: 2px 7px; border-radius: 5px;
            font-size: 0.68rem; font-weight: 700;
        }
        .ct-wr { background: rgba(52,211,153,0.12); color: #34d399; }
        .ct-mt { background: rgba(79,126,248,0.12); color: #7c9ffa; }

        /* ── QUICK ACTIONS ── */
        .qa-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            padding: 16px;
        }
        .qa {
            display: flex; flex-direction: column; gap: 6px;
            padding: 15px;
            border-radius: 13px;
            border: 1px solid var(--border);
            background: rgba(255,255,255,0.025);
            text-decoration: none;
            transition: all 0.25s cubic-bezier(.4,0,.2,1);
            position: relative; overflow: hidden;
        }
        .qa::before {
            content: '';
            position: absolute; inset: 0;
            opacity: 0;
            transition: opacity 0.25s;
            border-radius: 13px;
        }
        .qa:hover { transform: translateY(-2px); }
        .qa:hover::before { opacity: 1; }

        /* Each card unique color */
        .qa-repair {
            border-color: rgba(79,126,248,0.2);
        }
        .qa-repair::before { background: linear-gradient(135deg, rgba(79,126,248,0.12), rgba(79,126,248,0.04)); }
        .qa-repair:hover { border-color: rgba(79,126,248,0.5); box-shadow: 0 6px 24px rgba(79,126,248,0.2); }

        .qa-contract {
            border-color: rgba(167,139,250,0.2);
        }
        .qa-contract::before { background: linear-gradient(135deg, rgba(167,139,250,0.12), rgba(167,139,250,0.04)); }
        .qa-contract:hover { border-color: rgba(167,139,250,0.5); box-shadow: 0 6px 24px rgba(167,139,250,0.2); }

        .qa-equip {
            border-color: rgba(56,189,248,0.2);
        }
        .qa-equip::before { background: linear-gradient(135deg, rgba(56,189,248,0.12), rgba(56,189,248,0.04)); }
        .qa-equip:hover { border-color: rgba(56,189,248,0.5); box-shadow: 0 6px 24px rgba(56,189,248,0.2); }

        .qa-invoice {
            border-color: rgba(52,211,153,0.2);
        }
        .qa-invoice::before { background: linear-gradient(135deg, rgba(52,211,153,0.12), rgba(52,211,153,0.04)); }
        .qa-invoice:hover { border-color: rgba(52,211,153,0.5); box-shadow: 0 6px 24px rgba(52,211,153,0.2); }

        .qa-chat {
            border-color: rgba(251,191,36,0.2);
        }
        .qa-chat::before { background: linear-gradient(135deg, rgba(251,191,36,0.1), rgba(251,191,36,0.03)); }
        .qa-chat:hover { border-color: rgba(251,191,36,0.5); box-shadow: 0 6px 24px rgba(251,191,36,0.18); }

        .qa-icon {
            font-size: 1.4rem; line-height: 1;
            width: 38px; height: 38px;
            display: flex; align-items: center; justify-content: center;
            border-radius: 10px;
            margin-bottom: 2px;
            position: relative; z-index: 1;
        }
        .qa-repair  .qa-icon { background: rgba(79,126,248,0.15); }
        .qa-contract .qa-icon { background: rgba(167,139,250,0.15); }
        .qa-equip   .qa-icon { background: rgba(56,189,248,0.15); }
        .qa-invoice .qa-icon { background: rgba(52,211,153,0.15); }
        .qa-chat    .qa-icon { background: rgba(251,191,36,0.12); }

        .qa-name {
            font-size: 0.82rem; font-weight: 700;
            color: var(--text); position: relative; z-index: 1;
        }
        .qa-desc {
            font-size: 0.7rem; color: var(--muted);
            position: relative; z-index: 1;
        }
        .qa-span2 { grid-column: span 2; }

        /* ── EMPTY STATE ── */
        .empty {
            text-align: center; padding: 40px 24px;
            color: var(--muted); font-size: 0.82rem;
        }
        .empty i {
            font-size: 2rem; display: block;
            margin-bottom: 10px; opacity: 0.25;
        }
        .empty a {
            color: var(--accent-2); font-weight: 700;
            text-decoration: none; display: inline-block;
            margin-top: 8px;
        }
        .empty a:hover { color: #fff; }

        /* Code link */
        .code-link {
            color: var(--accent-2); font-weight: 700;
            font-size: 0.77rem; font-family: 'Courier New', monospace;
            text-decoration: none; letter-spacing: -0.3px;
        }
        .code-link:hover { color: #fff; }

        /* Muted text */
        .td-muted { color: var(--muted); font-size: 0.75rem; }
    </style>
</head>
<body>

    <%-- ═══════════ SIDEBAR ═══════════ --%>
    <aside class="sb">
        <div class="sb-brand">
            <div class="sb-logo"><i class="fas fa-bolt"></i></div>
            <div>
                <div class="sb-name">DRSMS</div>
                <div class="sb-role">Customer</div>
            </div>
        </div>

        <nav class="sb-nav">
            <div class="sb-lbl">Overview</div>
            <a href="<%=ctx%>/customerDashboard" class="sb-item on si-home">
                <i class="fas fa-home"></i> Dashboard
            </a>

            <div class="sb-lbl">Services</div>
            <a href="<%=ctx%>/customerServiceRequests" class="sb-item si-repair">
                <i class="fas fa-clipboard-list"></i> Repair Requests
                <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
            </a>
            <a href="<%=ctx%>/customerContracts" class="sb-item si-contract">
                <i class="fas fa-file-contract"></i> Contracts
            </a>
            <a href="<%=ctx%>/customerEquipment" class="sb-item si-equip">
                <i class="fas fa-desktop"></i> My Equipment
            </a>

            <div class="sb-lbl">Shop</div>
            <a href="<%=ctx%>/customerShop?action=parts" class="sb-item si-parts">
                <i class="fas fa-puzzle-piece"></i> Parts
            </a>
            <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item si-shop">
                <i class="fas fa-server"></i> Equipment
            </a>
            <a href="<%=ctx%>/customerShop?action=cart" class="sb-item si-cart">
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
                <div>
                    <div class="sb-uname"><%=me.getFullName()%></div>
                    <div class="sb-urole">Customer Account</div>
                </div>
            </a>
            <a href="<%=ctx%>/logout" class="sb-logout">
                <i class="fas fa-sign-out-alt"></i> Sign Out
            </a>
        </div>
    </aside>

    <%-- ═══════════ MAIN ═══════════ --%>
    <main class="main">

        <%-- Topbar --%>
        <div class="topbar">
            <div>
                <div class="topbar-greeting">Hello, <%=me.getFullName()%> 👋</div>
                <div class="topbar-sub">Here's an overview of your service account today.</div>
            </div>
            <a href="<%=ctx%>/customerServiceRequests?action=create" class="btn-cta">
                <i class="fas fa-plus"></i> New Repair Request
            </a>
        </div>

        <div class="content">

            <%-- Alert unpaid --%>
            <%if(unpaidInv>0){%>
            <div class="alert-warn">
                <i class="fas fa-triangle-exclamation"></i>
                <div>
                    You have <strong style="color:var(--amber)"><%=unpaidInv%> unpaid invoice(s)</strong>
                    <%if(unpaidAmt!=null&&unpaidAmt.compareTo(BigDecimal.ZERO)>0){%>
                    · Total: <strong style="color:var(--amber)"><%=nf.format(unpaidAmt)%> ₫</strong>
                    <%}%>
                    <a href="<%=ctx%>/customerInvoices?status=UNPAID">View invoices →</a>
                </div>
            </div>
            <%}%>

            <%-- Stats --%>
            <div class="section-lbl">Overview</div>
            <div class="stats">
                <div class="sc sc-purple">
                    <div class="sc-icon"><i class="fas fa-file-contract"></i></div>
                    <div class="sc-val"><%=activeContracts%></div>
                    <div class="sc-lbl">Active Contracts</div>
                    <div class="sc-sub"><%=totalContracts%> total contracts</div>
                </div>
                <div class="sc sc-blue">
                    <div class="sc-icon"><i class="fas fa-clipboard-list"></i></div>
                    <div class="sc-val"><%=totalSR%></div>
                    <div class="sc-lbl">Total Repair Requests</div>
                    <div class="sc-sub warn"><%=pendingSR%> pending approval</div>
                </div>
                <div class="sc sc-green">
                    <div class="sc-icon"><i class="fas fa-circle-check"></i></div>
                    <div class="sc-val"><%=completedSR%></div>
                    <div class="sc-lbl">Completed Requests</div>
                    <div class="sc-sub info"><%=activeSR%> in progress</div>
                </div>
                <%if(unpaidInv>0){%>
                <div class="sc sc-red">
                    <div class="sc-icon"><i class="fas fa-file-invoice-dollar"></i></div>
                    <div class="sc-val"><%=unpaidInv%></div>
                    <div class="sc-lbl">Unpaid Invoices</div>
                    <div class="sc-sub" style="color:var(--danger)">
                        <%=unpaidAmt!=null&&unpaidAmt.compareTo(BigDecimal.ZERO)>0?nf.format(unpaidAmt)+" ₫":"Outstanding balance"%>
                    </div>
                </div>
                <%}else{%>
                <div class="sc sc-greenok">
                    <div class="sc-icon"><i class="fas fa-file-invoice-dollar"></i></div>
                    <div class="sc-val">0</div>
                    <div class="sc-lbl">Unpaid Invoices</div>
                    <div class="sc-sub ok">All paid up ✓</div>
                </div>
                <%}%>
            </div>

            <%-- Main grid --%>
            <div class="section-lbl">Activity</div>
            <div class="grid-2">

                <%-- Recent Requests --%>
                <div class="card">
                    <div class="card-hd">
                        <div class="card-title">
                            <i class="fas fa-clock-rotate-left"></i> Recent Requests
                        </div>
                        <a href="<%=ctx%>/customerServiceRequests" class="card-link">View all →</a>
                    </div>
                    <%if(recent.isEmpty()){%>
                    <div class="empty">
                        <i class="fas fa-inbox"></i>
                        No requests yet.
                        <a href="<%=ctx%>/customerServiceRequests?action=create">+ Create your first request</a>
                    </div>
                    <%}else{%>
                    <table>
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Title</th>
                                <th>CT</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%for(ServiceRequest sr:recent){
                            String sc2="b-pending";
                            if("APPROVED".equals(sr.getStatus()))   sc2="b-approved";
                            else if("REJECTED".equals(sr.getStatus()))   sc2="b-rejected";
                            else if("IN_PROGRESS".equals(sr.getStatus())) sc2="b-inprogress";
                            else if("COMPLETED".equals(sr.getStatus()))   sc2="b-completed";
                            else if("CANCELLED".equals(sr.getStatus()))   sc2="b-cancelled";
                            String pc="b-medium";
                            if("LOW".equals(sr.getPriority()))    pc="b-low";
                            else if("HIGH".equals(sr.getPriority()))   pc="b-high";
                            else if("URGENT".equals(sr.getPriority())) pc="b-urgent";
                        %>
                        <tr>
                            <td>
                                <a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=sr.getId()%>"
                                   class="code-link"><%=sr.getRequestCode()%></a>
                            </td>
                            <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
                                <%=sr.getTitle()%>
                            </td>
                            <td>
                                <span class="ct-badge <%="WARRANTY".equals(sr.getContractType())?"ct-wr":"ct-mt"%>">
                                    <%="WARRANTY".equals(sr.getContractType())?"WR":"MT"%>
                                </span>
                            </td>
                            <td><span class="b <%=pc%>"><%=sr.getPriorityLabel()%></span></td>
                            <td><span class="b <%=sc2%>"><%=sr.getStatusLabel()%></span></td>
                            <td class="td-muted"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toLocalDate():"—"%></td>
                        </tr>
                        <%}%>
                        </tbody>
                    </table>
                    <%}%>
                </div>

                <%-- Quick Actions --%>
                <div class="card">
                    <div class="card-hd">
                        <div class="card-title"><i class="fas fa-bolt"></i> Quick Actions</div>
                    </div>
                    <div class="qa-grid">
                        <a href="<%=ctx%>/customerServiceRequests?action=create" class="qa qa-repair">
                            <div class="qa-icon">🔧</div>
                            <div class="qa-name">New Request</div>
                            <div class="qa-desc">Report an equipment issue</div>
                        </a>
                        <a href="<%=ctx%>/customerContracts" class="qa qa-contract">
                            <div class="qa-icon">📄</div>
                            <div class="qa-name">Contracts</div>
                            <div class="qa-desc">Warranty & maintenance</div>
                        </a>
                        <a href="<%=ctx%>/customerEquipment" class="qa qa-equip">
                            <div class="qa-icon">🖥️</div>
                            <div class="qa-name">Equipment</div>
                            <div class="qa-desc">Manage your devices</div>
                        </a>
                        <a href="<%=ctx%>/customerInvoices" class="qa qa-invoice">
                            <div class="qa-icon">💰</div>
                            <div class="qa-name">Invoices</div>
                            <div class="qa-desc">Payments & history</div>
                        </a>
                        <a href="<%=ctx%>/customerChat" class="qa qa-chat qa-span2">
                            <div class="qa-icon">💬</div>
                            <div class="qa-name">Support Chat</div>
                            <div class="qa-desc">
                                <%if(unreadChat>0){%>
                                <span style="color:var(--amber);font-weight:700"><%=unreadChat%> new message(s)</span>
                                <%}else{%>Contact a support agent<%}%>
                            </div>
                        </a>
                    </div>
                </div>

            </div>
        </div>
    </main>

</body>
</html>
