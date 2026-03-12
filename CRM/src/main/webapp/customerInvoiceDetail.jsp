<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*,java.math.BigDecimal" %>
<%
    User me=(User)session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    Invoice inv=(Invoice)request.getAttribute("invoice");
    if(inv==null){response.sendRedirect(request.getContextPath()+"/customerInvoices");return;}
    String ctx=request.getContextPath();
    List<InvoiceItem> items=inv.getItems(); if(items==null)items=new ArrayList<>();
    java.text.NumberFormat nf=java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi","VN"));
    String isc="b-unpaid";
    if("PAID".equals(inv.getStatus()))isc="b-paid";
    else if("CANCELLED".equals(inv.getStatus()))isc="b-cancelled";
    boolean overdue="UNPAID".equals(inv.getStatus())&&inv.getDueDate()!=null&&inv.getDueDate().isBefore(java.time.LocalDate.now());
    String paySuccess=request.getParameter("paySuccess");
    String errorMsg=request.getParameter("error");
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%=inv.getInvoiceCode()%> - DRSMS</title>
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
        .sb-item.si-home:hover       { color: #fff; background: rgba(79,126,248,0.1); border-left-color: var(--accent); }
        .sb-item.si-home:hover i     { background: rgba(79,126,248,0.2); color: var(--accent-2); }
        .sb-item.si-repair:hover     { color: #fff; background: rgba(251,191,36,0.08); border-left-color: var(--amber); }
        .sb-item.si-repair:hover i   { background: rgba(251,191,36,0.18); color: var(--amber); }
        .sb-item.si-contract:hover   { color: #fff; background: rgba(167,139,250,0.08); border-left-color: var(--purple); }
        .sb-item.si-contract:hover i { background: rgba(167,139,250,0.18); color: var(--purple); }
        .sb-item.si-equip:hover      { color: #fff; background: rgba(56,189,248,0.08); border-left-color: var(--info); }
        .sb-item.si-equip:hover i    { background: rgba(56,189,248,0.18); color: var(--info); }
        .sb-item.si-parts:hover      { color: #fff; background: rgba(52,211,153,0.07); border-left-color: var(--green); }
        .sb-item.si-parts:hover i    { background: rgba(52,211,153,0.18); color: var(--green); }
        .sb-item.si-shop:hover       { color: #fff; background: rgba(56,189,248,0.07); border-left-color: var(--info); }
        .sb-item.si-shop:hover i     { background: rgba(56,189,248,0.18); color: var(--info); }
        .sb-item.si-cart:hover       { color: #fff; background: rgba(251,146,60,0.08); border-left-color: #fb923c; }
        .sb-item.si-cart:hover i     { background: rgba(251,146,60,0.18); color: #fb923c; }
        .sb-item.si-invoice:hover    { color: #fff; background: rgba(52,211,153,0.07); border-left-color: var(--green); }
        .sb-item.si-invoice:hover i  { background: rgba(52,211,153,0.18); color: var(--green); }
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
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Topbar */
        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 18px 32px;
            border-bottom: 1px solid var(--border);
            background: rgba(11,20,55,0.6);
            backdrop-filter: blur(16px);
            position: sticky; top: 0; z-index: 50;
        }
        .breadcrumb {
            display: flex; align-items: center; gap: 7px;
            font-size: 0.78rem; color: var(--muted);
        }
        .breadcrumb a { color: var(--muted); text-decoration: none; transition: color 0.2s; }
        .breadcrumb a:hover { color: var(--accent-2); }
        .breadcrumb-sep { color: rgba(255,255,255,0.2); }
        .breadcrumb-cur { color: var(--text-2); font-weight: 600; }

        .btn-back {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 8px 16px;
            background: rgba(255,255,255,0.05);
            color: var(--text-2); border: 1px solid var(--border);
            text-decoration: none; font-size: 0.82rem; font-weight: 600;
            border-radius: 9px; transition: all 0.2s;
        }
        .btn-back:hover { background: rgba(79,126,248,0.1); border-color: rgba(79,126,248,0.3); color: #fff; }

        /* Content */
        .content { padding: 28px 32px; flex: 1; }

        /* Animations */
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeSlideIn {
            from { opacity: 0; transform: translateY(-8px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── ALERTS ── */
        .alert-box {
            display: flex; align-items: flex-start; gap: 12px;
            padding: 13px 18px;
            border-radius: 12px;
            margin-bottom: 20px;
            font-size: 0.84rem;
            animation: fadeSlideIn 0.4s ease both;
        }
        .alert-box i { font-size: 1rem; flex-shrink: 0; margin-top: 1px; }
        .alert-danger {
            background: var(--danger-dim);
            border: 1px solid rgba(248,113,113,0.25);
            color: var(--text-2);
        }
        .alert-danger i { color: var(--danger); }
        .alert-success {
            background: var(--green-dim);
            border: 1px solid rgba(52,211,153,0.25);
            color: var(--text-2);
        }
        .alert-success i { color: var(--green); }
        .alert-warn {
            background: var(--amber-dim);
            border: 1px solid rgba(251,191,36,0.25);
            color: var(--text-2);
        }
        .alert-warn i { color: var(--amber); }

        /* ── LAYOUT ── */
        .grid-inv {
            display: grid;
            grid-template-columns: 3fr 2fr;
            gap: 18px;
            align-items: start;
        }

        /* ── INVOICE HEADER CARD ── */
        .inv-header {
            background: linear-gradient(135deg, rgba(79,126,248,0.25), rgba(167,139,250,0.2));
            border: 1px solid rgba(79,126,248,0.25);
            border-radius: 16px;
            padding: 24px 28px;
            margin-bottom: 16px;
            display: flex; justify-content: space-between; align-items: flex-start;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s ease both;
            position: relative; overflow: hidden;
        }
        .inv-header::before {
            content: '';
            position: absolute; top: 0; left: 20px; right: 20px; height: 1px;
            background: linear-gradient(90deg, transparent, var(--accent-2), transparent);
        }
        .inv-title {
            font-size: 1.4rem; font-weight: 800;
            color: #fff; letter-spacing: -0.5px;
            margin-bottom: 4px;
            display: flex; align-items: center; gap: 10px;
        }
        .inv-title i { color: var(--accent-2); }
        .inv-code {
            font-family: 'Courier New', monospace;
            font-size: 0.95rem; color: var(--accent-2);
            font-weight: 700; letter-spacing: 0.5px;
        }
        .inv-date { color: var(--muted); font-size: 0.78rem; margin-top: 5px; }
        .inv-company {
            text-align: right; font-size: 0.8rem;
            color: var(--text-2); line-height: 1.8;
        }
        .inv-company strong { color: #fff; }

        /* ── CARDS ── */
        .card {
            background: rgba(17,26,66,0.7);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            backdrop-filter: blur(12px);
            margin-bottom: 16px;
            animation: cardIn 0.5s ease both;
        }
        .card:nth-child(1) { animation-delay: 0.1s; }
        .card:nth-child(2) { animation-delay: 0.15s; }
        .card-hd {
            display: flex; align-items: center; gap: 10px;
            padding: 14px 20px;
            border-bottom: 1px solid var(--border);
        }
        .card-hd-icon {
            width: 30px; height: 30px; border-radius: 8px;
            background: rgba(79,126,248,0.2);
            color: var(--accent-2);
            display: flex; align-items: center; justify-content: center;
            font-size: 0.78rem; flex-shrink: 0;
        }
        .card-hd-title { font-size: 0.87rem; font-weight: 700; color: #fff; }
        .card-body { padding: 20px; }

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
        th:nth-child(n+3), td:nth-child(n+3) { text-align: right; }

        /* Item type badge */
        .item-type {
            display: inline-flex; align-items: center;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.68rem; font-weight: 700;
        }
        .it-part    { background: rgba(56,189,248,0.12); color: var(--info); border: 1px solid rgba(56,189,248,0.2); }
        .it-service { background: var(--green-dim); color: var(--green); border: 1px solid rgba(52,211,153,0.2); }
        .it-equip   { background: var(--amber-dim); color: var(--amber); border: 1px solid rgba(251,191,36,0.2); }
        .it-other   { background: var(--purple-dim); color: var(--purple); border: 1px solid rgba(167,139,250,0.2); }

        /* Summary rows */
        .sum-wrap { padding: 16px 20px; border-top: 1px solid var(--border); }
        .sum-inner { max-width: 280px; margin-left: auto; }
        .sum-row {
            display: flex; justify-content: space-between;
            padding: 7px 0; font-size: 0.84rem;
            border-bottom: 1px solid rgba(255,255,255,0.04);
            color: var(--text-2);
        }
        .sum-row .lbl { color: var(--muted); }
        .sum-row:last-child {
            border: none; border-top: 1px solid var(--border);
            font-size: 1.05rem; font-weight: 800;
            color: var(--accent-2); padding-top: 12px; margin-top: 4px;
        }
        .sum-row:last-child .lbl { color: var(--text); }

        /* ── BADGES ── */
        .b {
            display: inline-flex; align-items: center;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 700;
        }
        .b-unpaid    { background: var(--amber-dim); color: var(--amber); border: 1px solid rgba(251,191,36,0.25); }
        .b-paid      { background: var(--green-dim); color: var(--green); border: 1px solid rgba(52,211,153,0.25); }
        .b-cancelled { background: rgba(255,255,255,0.05); color: var(--muted); border: 1px solid var(--border); }

        /* ── INFO GRID (right panel) ── */
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; }
        .info-item .lbl {
            font-size: 0.68rem; color: var(--muted);
            font-weight: 600; text-transform: uppercase;
            letter-spacing: 0.5px; margin-bottom: 4px;
        }
        .info-item .val { font-size: 0.84rem; color: var(--text-2); font-weight: 500; }
        .info-item .val a { color: var(--accent-2); text-decoration: none; font-weight: 700; font-family: 'Courier New', monospace; }
        .info-item .val a:hover { color: #fff; }

        /* Amount display */
        .amount-box {
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 14px;
        }
        .amount-lbl {
            font-size: 0.68rem; color: var(--muted);
            font-weight: 700; text-transform: uppercase;
            letter-spacing: 0.8px; margin-bottom: 6px;
        }
        .amount-val {
            font-size: 1.8rem; font-weight: 800;
            line-height: 1; letter-spacing: -1px;
        }
        .amount-val.unpaid { color: var(--danger); }
        .amount-val.paid   { color: var(--green); }
        .amount-sub {
            font-size: 0.73rem; color: var(--muted); margin-top: 6px;
            display: flex; align-items: center; gap: 5px;
        }

        /* ── PAYMENT SECTION ── */
        .pay-section { margin-top: 14px; }
        .pay-title {
            font-size: 0.68rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase;
            letter-spacing: 0.8px; margin-bottom: 10px;
            display: flex; align-items: center; gap: 6px;
        }
        .pay-btns { display: flex; flex-direction: column; gap: 9px; }

        .btn-pay {
            display: flex; align-items: center; justify-content: center; gap: 9px;
            width: 100%; padding: 12px;
            color: #fff; border: none;
            border-radius: 11px; font-size: 0.875rem; font-weight: 700;
            cursor: pointer; transition: all 0.25s;
            font-family: 'Sora', sans-serif;
        }
        .btn-pay-cash  { background: linear-gradient(135deg, #34d399, #059669); }
        .btn-pay-vnpay { background: linear-gradient(135deg, #f43f5e, #be123c); }
        .btn-pay-cash:hover  { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(52,211,153,0.35); }
        .btn-pay-vnpay:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(244,63,94,0.35); }

        /* ── MODAL ── */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.65);
            backdrop-filter: blur(6px);
            z-index: 999; align-items: center; justify-content: center;
        }
        .modal-overlay.show { display: flex; }
        .modal {
            background: var(--navy-card);
            border: 1px solid var(--border);
            border-radius: 18px; width: 440px;
            max-width: 95vw; overflow: hidden;
            box-shadow: 0 24px 60px rgba(0,0,0,0.5);
            animation: modalIn 0.25s ease;
        }
        @keyframes modalIn {
            from { opacity: 0; transform: scale(0.95) translateY(10px); }
            to   { opacity: 1; transform: scale(1) translateY(0); }
        }
        .modal-header {
            padding: 18px 24px;
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
        }
        .modal-title {
            font-size: 0.95rem; font-weight: 700; color: #fff;
            display: flex; align-items: center; gap: 9px;
        }
        .modal-title i { color: var(--green); }
        .modal-close {
            width: 30px; height: 30px; border-radius: 8px;
            background: rgba(255,255,255,0.06);
            border: 1px solid var(--border);
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            color: var(--muted); font-size: 0.9rem; transition: all 0.2s;
        }
        .modal-close:hover { background: rgba(248,113,113,0.12); color: var(--danger); border-color: rgba(248,113,113,0.2); }
        .modal-body { padding: 24px; }
        .modal-footer {
            padding: 16px 24px; border-top: 1px solid var(--border);
            display: flex; gap: 9px;
        }

        /* Cash modal amount display */
        .cash-amount-box {
            background: var(--green-dim);
            border: 1px solid rgba(52,211,153,0.2);
            border-radius: 12px; padding: 18px;
            text-align: center; margin-bottom: 18px;
        }
        .cash-amount-lbl { font-size: 0.72rem; color: var(--muted); font-weight: 600; margin-bottom: 5px; }
        .cash-amount-val { font-size: 1.9rem; font-weight: 800; color: var(--green); letter-spacing: -1px; }
        .cash-amount-code { font-family: 'Courier New', monospace; font-size: 0.78rem; color: var(--muted); margin-top: 5px; }

        /* Cash steps */
        .cash-steps { list-style: none; margin-bottom: 18px; }
        .cash-steps li {
            display: flex; gap: 11px; padding: 9px 0;
            border-bottom: 1px solid var(--border);
            font-size: 0.82rem; color: var(--text-2);
        }
        .cash-steps li:last-child { border: none; }
        .step-num {
            width: 22px; height: 22px; border-radius: 50%;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            color: #fff; font-size: 0.68rem; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }

        .btn-confirm-cash {
            flex: 1; padding: 11px;
            background: linear-gradient(135deg, var(--green), #059669);
            color: #fff; border: none; border-radius: 10px;
            font-size: 0.875rem; font-weight: 700;
            cursor: pointer; transition: all 0.2s;
            font-family: 'Sora', sans-serif;
        }
        .btn-confirm-cash:hover { transform: translateY(-1px); box-shadow: 0 4px 16px rgba(52,211,153,0.35); }
        .btn-modal-cancel {
            padding: 11px 16px;
            background: rgba(255,255,255,0.05);
            color: var(--muted); border: 1px solid var(--border);
            border-radius: 10px; font-size: 0.875rem; font-weight: 600;
            cursor: pointer; transition: all 0.2s;
            font-family: 'Sora', sans-serif;
        }
        .btn-modal-cancel:hover { background: rgba(255,255,255,0.08); color: var(--text-2); }
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
            <a href="<%=ctx%>/customerDashboard" class="sb-item si-home">
                <i class="fas fa-home"></i> Dashboard
            </a>

            <div class="sb-lbl">Services</div>
            <a href="<%=ctx%>/customerServiceRequests" class="sb-item si-repair">
                <i class="fas fa-clipboard-list"></i> Repair Requests
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
            <a href="<%=ctx%>/customerInvoices" class="sb-item on si-invoice">
                <i class="fas fa-receipt"></i> Invoices
            </a>

            <div class="sb-lbl">Support</div>
            <a href="<%=ctx%>/customerChat" class="sb-item si-chat">
                <i class="fas fa-comment-dots"></i> Support Chat
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

        <%-- Topbar / Breadcrumb --%>
        <div class="topbar">
            <div class="breadcrumb">
                <a href="<%=ctx%>/customerDashboard"><i class="fas fa-home"></i></a>
                <span class="breadcrumb-sep">›</span>
                <a href="<%=ctx%>/customerInvoices">Invoices</a>
                <span class="breadcrumb-sep">›</span>
                <span class="breadcrumb-cur"><%=inv.getInvoiceCode()%></span>
            </div>
            <a href="<%=ctx%>/customerInvoices" class="btn-back">
                <i class="fas fa-arrow-left"></i> Back
            </a>
        </div>

        <div class="content">

            <%-- Toast notifications --%>
            <%if("cash".equals(paySuccess)){%>
            <div class="alert-box alert-success">
                <i class="fas fa-check-circle"></i>
                <div><strong>Cash payment successful!</strong> Invoice <%=inv.getInvoiceCode()%> has been recorded.</div>
            </div>
            <%}else if("vnpay".equals(paySuccess)){%>
            <div class="alert-box alert-success">
                <i class="fas fa-check-circle"></i>
                <div><strong>VNPay payment successful!</strong> Invoice <%=inv.getInvoiceCode()%> has been paid.</div>
            </div>
            <%}else if("invalid".equals(errorMsg)||"session_expired".equals(errorMsg)){%>
            <div class="alert-box alert-danger">
                <i class="fas fa-triangle-exclamation"></i>
                <div>An error occurred during payment. Please try again.</div>
            </div>
            <%}%>

            <%-- Overdue / Paid alerts --%>
            <%if(overdue&&!"PAID".equals(inv.getStatus())){%>
            <div class="alert-box alert-warn">
                <i class="fas fa-triangle-exclamation"></i>
                <div>This invoice is <strong style="color:var(--amber)">overdue</strong> (due: <%=inv.getDueDate()%>). Please make payment as soon as possible.</div>
            </div>
            <%}else if("PAID".equals(inv.getStatus())){%>
            <div class="alert-box alert-success">
                <i class="fas fa-circle-check"></i>
                <div>This invoice has been <strong style="color:var(--green)">fully paid</strong>. Thank you!</div>
            </div>
            <%}%>

            <div class="grid-inv">
                <div>
                    <%-- Invoice Header --%>
                    <div class="inv-header">
                        <div>
                            <div class="inv-title"><i class="fas fa-receipt"></i> INVOICE</div>
                            <div class="inv-code"><%=inv.getInvoiceCode()%></div>
                            <div class="inv-date">Created: <%=inv.getCreatedAt()!=null?inv.getCreatedAt().toLocalDate():"—"%></div>
                        </div>
                        <div class="inv-company">
                            <strong>DRSMS System</strong><br>
                            Technical &amp; Maintenance Services<br>
                            In charge: <%=inv.getCreatedByName()%>
                        </div>
                    </div>

                    <%-- Items table --%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-icon"><i class="fas fa-list"></i></div>
                            <div class="card-hd-title">Service Details</div>
                        </div>
                        <%if(items.isEmpty()){%>
                        <div class="card-body" style="text-align:center;color:var(--muted);padding:32px 24px">
                            <i class="fas fa-inbox" style="font-size:1.8rem;opacity:0.25;display:block;margin-bottom:10px"></i>
                            No service details available
                        </div>
                        <%}else{%>
                        <table>
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Description</th>
                                    <th>Type</th>
                                    <th>Qty</th>
                                    <th>Unit Price</th>
                                    <th>Total</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%for(int i=0;i<items.size();i++){
                                InvoiceItem it=items.get(i);
                                String itCls="it-other";
                                if("PART".equals(it.getItemType()))      itCls="it-part";
                                else if("SERVICE".equals(it.getItemType())) itCls="it-service";
                                else if("EQUIPMENT".equals(it.getItemType())) itCls="it-equip";
                            %>
                            <tr>
                                <td style="color:var(--muted);font-size:0.78rem"><%=i+1%></td>
                                <td style="font-weight:500;color:var(--text)"><%=it.getItemName()%></td>
                                <td><span class="item-type <%=itCls%>"><%=it.getItemType()%></span></td>
                                <td><%=it.getQuantity()%></td>
                                <td><%=it.getUnitPrice()!=null?nf.format(it.getUnitPrice()):"0"%> ₫</td>
                                <td><strong style="color:var(--text)"><%=it.getTotalPrice()!=null?nf.format(it.getTotalPrice()):"0"%> ₫</strong></td>
                            </tr>
                            <%}%>
                            </tbody>
                        </table>
                        <%}%>
                        <div class="sum-wrap">
                            <div class="sum-inner">
                                <div class="sum-row">
                                    <span class="lbl">Subtotal</span>
                                    <span><%=inv.getSubtotal()!=null?nf.format(inv.getSubtotal()):"0"%> ₫</span>
                                </div>
                                <div class="sum-row">
                                    <span class="lbl">VAT Tax (<%=inv.getTaxPercent()!=null?inv.getTaxPercent().intValue():0%>%)</span>
                                    <span><%=inv.getTaxAmount()!=null?nf.format(inv.getTaxAmount()):"0"%> ₫</span>
                                </div>
                                <div class="sum-row">
                                    <span class="lbl">Total</span>
                                    <span><%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Right panel --%>
                <div>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-icon"><i class="fas fa-circle-info"></i></div>
                            <div class="card-hd-title">Invoice Information</div>
                        </div>
                        <div class="card-body">
                            <div class="info-grid">
                                <div class="info-item">
                                    <div class="lbl">Invoice Code</div>
                                    <div class="val" style="font-family:'Courier New',monospace;font-weight:700;color:var(--accent-2)"><%=inv.getInvoiceCode()%></div>
                                </div>
                                <div class="info-item">
                                    <div class="lbl">Status</div>
                                    <div class="val"><span class="b <%=isc%>"><%=inv.getStatusLabel()%></span></div>
                                </div>
                                <div class="info-item">
                                    <div class="lbl">Type</div>
                                    <div class="val"><%=inv.getInvoiceTypeLabel()%></div>
                                </div>
                                <div class="info-item">
                                    <div class="lbl">Created</div>
                                    <div class="val"><%=inv.getCreatedAt()!=null?inv.getCreatedAt().toLocalDate():"—"%></div>
                                </div>
                                <%if(inv.getDueDate()!=null){%>
                                <div class="info-item">
                                    <div class="lbl">Due Date</div>
                                    <div class="val" style="<%=overdue?"color:var(--danger);font-weight:700":""%>">
                                        <%=inv.getDueDate()%><%=overdue?" ⚠️":""%>
                                    </div>
                                </div>
                                <%}%>
                                <%if(inv.getRequestCode()!=null){%>
                                <div class="info-item">
                                    <div class="lbl">Repair Request</div>
                                    <div class="val">
                                        <a href="<%=ctx%>/customerServiceRequests?action=detail&id=<%=inv.getServiceRequestId()%>"><%=inv.getRequestCode()%></a>
                                    </div>
                                </div>
                                <%}%>
                            </div>

                            <%-- Amount box --%>
                            <div class="amount-box">
                                <div class="amount-lbl">Total Amount Due</div>
                                <div class="amount-val <%="UNPAID".equals(inv.getStatus())?"unpaid":"paid"%>">
                                    <%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫
                                </div>
                                <div class="amount-sub">
                                    <%if("PAID".equals(inv.getStatus())){%>
                                    <i class="fas fa-check-circle" style="color:var(--green)"></i> Fully paid
                                    <%}else if("UNPAID".equals(inv.getStatus())){%>
                                    <i class="fas fa-clock" style="color:var(--amber)"></i> Awaiting payment
                                    <%}else{%>
                                    <i class="fas fa-ban"></i> Invoice cancelled
                                    <%}%>
                                </div>
                            </div>

                            <%-- Payment buttons --%>
                            <%if("UNPAID".equals(inv.getStatus())){%>
                            <div class="pay-section">
                                <div class="pay-title"><i class="fas fa-credit-card"></i> Select payment method</div>
                                <div class="pay-btns">
                                    <button class="btn-pay btn-pay-cash" onclick="openCashModal()">
                                        <i class="fas fa-money-bill-wave"></i> Pay with Cash
                                    </button>
                                    <form method="post" action="<%=ctx%>/customerPayment">
                                        <input type="hidden" name="action" value="vnpay_simulate">
                                        <input type="hidden" name="invoiceId" value="<%=inv.getId()%>">
                                        <button type="submit" class="btn-pay btn-pay-vnpay" style="width:100%">
                                            <i class="fas fa-qrcode"></i> Pay via VNPay
                                        </button>
                                    </form>
                                </div>
                            </div>
                            <%}%>
                        </div>
                    </div>

                    <%if(inv.getNotes()!=null&&!inv.getNotes().isEmpty()){%>
                    <div class="card">
                        <div class="card-hd">
                            <div class="card-hd-icon" style="background:var(--amber-dim);color:var(--amber)"><i class="fas fa-note-sticky"></i></div>
                            <div class="card-hd-title">Notes</div>
                        </div>
                        <div class="card-body" style="font-size:0.84rem;color:var(--text-2);line-height:1.75">
                            <%=inv.getNotes()%>
                        </div>
                    </div>
                    <%}%>
                </div>
            </div>
        </div>
    </main>

    <%-- Cash Payment Modal --%>
    <div class="modal-overlay" id="cashModal">
        <div class="modal">
            <div class="modal-header">
                <div class="modal-title"><i class="fas fa-money-bill-wave"></i> Cash Payment</div>
                <button class="modal-close" onclick="closeCashModal()"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="cash-amount-box">
                    <div class="cash-amount-lbl">Amount to pay</div>
                    <div class="cash-amount-val"><%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫</div>
                    <div class="cash-amount-code">Invoice: <%=inv.getInvoiceCode()%></div>
                </div>
                <ul class="cash-steps">
                    <li><span class="step-num">1</span><span>Prepare the exact amount of <strong style="color:var(--text)"><%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫</strong></span></li>
                    <li><span class="step-num">2</span><span>Visit the DRSMS System office or hand it to the on-site technician</span></li>
                    <li><span class="step-num">3</span><span>Staff will confirm and issue a payment receipt for you</span></li>
                    <li><span class="step-num">4</span><span>Click <strong style="color:var(--text)">"Confirm Payment"</strong> to record it in the system</span></li>
                </ul>
            </div>
            <div class="modal-footer">
                <button class="btn-modal-cancel" onclick="closeCashModal()">Cancel</button>
                <form method="post" action="<%=ctx%>/customerPayment" style="flex:1">
                    <input type="hidden" name="action" value="cash">
                    <input type="hidden" name="invoiceId" value="<%=inv.getId()%>">
                    <button type="submit" class="btn-confirm-cash">
                        <i class="fas fa-check"></i> Confirm Payment
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
        function openCashModal() {
            document.getElementById('cashModal').classList.add('show');
        }
        function closeCashModal() {
            document.getElementById('cashModal').classList.remove('show');
        }
        document.getElementById('cashModal').addEventListener('click', function(e) {
            if (e.target === this) closeCashModal();
        });

        // Auto-hide success toast after 5s
        document.addEventListener('DOMContentLoaded', () => {
            const toast = document.querySelector('.alert-success');
            if (toast) {
                setTimeout(() => {
                    toast.style.transition = 'opacity 0.5s';
                    toast.style.opacity = '0';
                    setTimeout(() => toast.remove(), 500);
                }, 5000);
            }
        });
    </script>
</body>
</html>
