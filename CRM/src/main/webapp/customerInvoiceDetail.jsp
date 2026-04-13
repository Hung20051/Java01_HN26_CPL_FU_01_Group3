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
                /* Sidebar (dark indigo) */
                --sb-bg:        #1e1b4b;
                --sb-border:    rgba(255,255,255,0.08);
                --sb-text:      rgba(255,255,255,0.45);
                --sb-accent:    #818cf8;
                --sb-accent-2:  #a5b4fc;
                --sb-item-on:   rgba(129,140,248,0.2);
                --sb-width:     252px;

                /* Content (light) */
                --bg:           #f3f4f9;
                --bg-card:      #ffffff;
                --bg-topbar:    #ffffff;
                --border-light: #e8ecf5;
                --border-light2:#f0f2fb;
                --text-h:       #1e1b4b;
                --text-b:       #374151;
                --text-m:       #6b7280;
                --text-s:       #9ca3af;

                /* Brand */
                --primary:      #4f46e5;
                --primary-2:    #6366f1;
                --primary-light:#ede9fe;

                /* Status / accent colors */
                --purple:  #7c3aed;
                --blue:    #2563eb;
                --teal:    #0d9488;
                --green:   #16a34a;
                --red:     #dc2626;
                --amber:   #d97706;
                --orange:  #ea580c;
                --info:    #0284c7;
            }

            *,*::before,*::after{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            html{
                scroll-behavior:smooth
            }
            body{
                font-family:'Sora',sans-serif;
                background:var(--bg);
                color:var(--text-b);
                min-height:100vh;
                display:flex;
            }
            ::-webkit-scrollbar{
                width:4px
            }
            ::-webkit-scrollbar-track{
                background:transparent
            }
            ::-webkit-scrollbar-thumb{
                background:rgba(79,70,229,0.3);
                border-radius:4px
            }

            /* ═══════════ SIDEBAR ═══════════ */
            .sb{
                width:var(--sb-width);
                min-height:100vh;
                background:var(--sb-bg);
                border-right:1px solid rgba(79,70,229,0.2);
                display:flex;
                flex-direction:column;
                position:fixed;
                top:0;
                left:0;
                z-index:100;
                box-shadow:4px 0 24px rgba(0,0,0,0.15);
            }
            .sb-brand{
                padding:20px 16px 16px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid var(--sb-border);
            }
            .sb-logo{
                width:36px;
                height:36px;
                background:linear-gradient(135deg,#818cf8,#a78bfa);
                border-radius:10px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem;
                box-shadow:0 4px 12px rgba(129,140,248,0.4);
                flex-shrink:0;
            }
            .sb-name{
                color:#fff;
                font-size:1.05rem;
                font-weight:800;
                letter-spacing:-.3px
            }
            .sb-role{
                display:inline-flex;
                align-items:center;
                background:rgba(129,140,248,0.2);
                border:1px solid rgba(129,140,248,0.3);
                color:var(--sb-accent-2);
                font-size:.6rem;
                font-weight:700;
                letter-spacing:1px;
                text-transform:uppercase;
                padding:2px 8px;
                border-radius:20px;
                margin-top:3px;
            }
            .sb-nav{
                flex:1;
                padding:12px 10px;
                overflow-y:auto
            }
            .sb-lbl{
                color:rgba(255,255,255,0.22);
                font-size:.6rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.6px;
                padding:0 8px;
                margin:14px 0 5px;
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:9px;
                padding:8px 10px;
                border-radius:9px;
                margin-bottom:1px;
                color:var(--sb-text);
                text-decoration:none;
                font-size:.81rem;
                font-weight:500;
                transition:all .18s;
                border-left:2px solid transparent;
            }
            .sb-item i{
                width:28px;
                height:28px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.78rem;
                border-radius:8px;
                background:rgba(255,255,255,0.06);
                flex-shrink:0;
                transition:all .18s;
            }
            .sb-item.on{
                color:#fff;
                background:var(--sb-item-on);
                border-left-color:var(--sb-accent);
            }
            .sb-item.on i{
                background:rgba(129,140,248,0.3);
                color:var(--sb-accent-2)
            }
            .sb-item:hover:not(.on){
                color:rgba(255,255,255,0.78);
                background:rgba(255,255,255,0.06);
            }
            .sb-badge{
                margin-left:auto;
                background:#ef4444;
                color:#fff;
                font-size:.6rem;
                font-weight:700;
                padding:2px 7px;
                border-radius:20px;
                box-shadow:0 2px 6px rgba(239,68,68,0.5);
            }
            .sb-foot{
                padding:12px 10px 14px;
                border-top:1px solid var(--sb-border)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:10px;
                background:rgba(255,255,255,0.07);
                border:1px solid rgba(255,255,255,0.1);
                margin-bottom:5px;
                text-decoration:none;
                transition:all .18s;
                cursor:pointer;
            }
            .sb-user:hover{
                background:rgba(129,140,248,0.18);
                border-color:rgba(129,140,248,0.3)
            }
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:linear-gradient(135deg,#818cf8,#a78bfa);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                font-weight:700;
                flex-shrink:0;
                overflow:hidden;
            }
            .sb-ava img{
                width:34px;
                height:34px;
                object-fit:cover;
                border-radius:50%
            }
            .sb-uname{
                color:#fff;
                font-size:.8rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,0.35);
                font-size:.66rem;
                margin-top:1px
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:8px 10px;
                border-radius:9px;
                color:rgba(255,255,255,0.3);
                text-decoration:none;
                font-size:.78rem;
                transition:all .18s;
            }
            .sb-logout:hover{
                color:#fca5a5;
                background:rgba(239,68,68,0.1)
            }

            /* ═══════════ MAIN (light) ═══════════ */
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
                padding:14px 28px;
                background:var(--bg-topbar);
                border-bottom:1px solid var(--border-light);
                position:sticky;
                top:0;
                z-index:50;
                box-shadow:0 1px 6px rgba(0,0,0,0.06);
            }
            .breadcrumb{
                display:flex;
                align-items:center;
                gap:7px;
                font-size:.76rem;
                color:var(--text-s);
            }
            .breadcrumb a{
                color:var(--text-s);
                text-decoration:none;
                transition:color .18s
            }
            .breadcrumb a:hover{
                color:var(--primary-2)
            }
            .breadcrumb-sep{
                color:var(--border-light)
            }
            .breadcrumb-cur{
                color:var(--text-m);
                font-weight:600;
                font-family:'Courier New',monospace
            }
            .btn-back{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:8px 16px;
                background:#fff;
                color:var(--text-m);
                border:1.5px solid var(--border-light);
                text-decoration:none;
                font-size:.81rem;
                font-weight:600;
                border-radius:9px;
                transition:all .2s;
            }
            .btn-back:hover{
                background:#f3f4f6;
                border-color:#d1d5db;
                color:var(--text-b)
            }

            .content{
                padding:24px 28px;
                flex:1
            }

            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(16px)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }
            @keyframes fadeSlideIn{
                from{
                    opacity:0;
                    transform:translateY(-8px)
                }
                to{
                    opacity:1;
                    transform:none
                }
            }

            /* ── ALERTS ── */
            .alert-box{
                display:flex;
                align-items:flex-start;
                gap:12px;
                padding:12px 18px;
                border-radius:12px;
                margin-bottom:18px;
                font-size:.82rem;
                animation:fadeSlideIn .4s ease both;
            }
            .alert-box i{
                font-size:1rem;
                flex-shrink:0;
                margin-top:1px
            }
            .alert-danger {
                background:#fee2e2;
                border:1px solid #fca5a5;
                color:#991b1b
            }
            .alert-danger i{
                color:var(--red)
            }
            .alert-success{
                background:#d1fae5;
                border:1px solid #a7f3d0;
                color:#065f46
            }
            .alert-success i{
                color:var(--green)
            }
            .alert-warn   {
                background:#fffbeb;
                border:1px solid #fcd34d;
                color:#78350f
            }
            .alert-warn i {
                color:var(--amber)
            }

            /* ── LAYOUT ── */
            .grid-inv{
                display:grid;
                grid-template-columns:3fr 2fr;
                gap:18px;
                align-items:start;
            }

            /* ── INVOICE HEADER CARD ── */
            .inv-header{
                background:linear-gradient(135deg,var(--primary),var(--purple));
                border:1px solid rgba(99,102,241,0.3);
                border-radius:16px;
                padding:22px 26px;
                margin-bottom:16px;
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                box-shadow:0 4px 20px rgba(79,70,229,0.2);
                animation:cardIn .5s ease both;
                position:relative;
                overflow:hidden;
            }
            .inv-header::after{
                content:'';
                position:absolute;
                width:120px;
                height:120px;
                border-radius:50%;
                background:rgba(255,255,255,0.1);
                top:-30px;
                right:-30px;
            }
            .inv-header::before{
                content:'';
                position:absolute;
                width:70px;
                height:70px;
                border-radius:50%;
                background:rgba(255,255,255,0.07);
                bottom:-15px;
                right:50px;
            }
            .inv-title{
                font-size:1.35rem;
                font-weight:800;
                color:#fff;
                letter-spacing:-.5px;
                margin-bottom:4px;
                display:flex;
                align-items:center;
                gap:10px;
                position:relative;
                z-index:1;
            }
            .inv-title i{
                color:rgba(255,255,255,0.8)
            }
            .inv-code-hd{
                font-family:'Courier New',monospace;
                font-size:.94rem;
                color:rgba(255,255,255,0.9);
                font-weight:700;
                letter-spacing:.5px;
                position:relative;
                z-index:1;
            }
            .inv-date{
                color:rgba(255,255,255,0.65);
                font-size:.77rem;
                margin-top:5px;
                position:relative;
                z-index:1;
            }
            .inv-company{
                text-align:right;
                font-size:.79rem;
                color:rgba(255,255,255,0.8);
                line-height:1.8;
                position:relative;
                z-index:1;
            }
            .inv-company strong{
                color:#fff
            }

            /* ── CARDS ── */
            .card{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                margin-bottom:16px;
                animation:cardIn .5s ease both;
            }
            .card:nth-child(1){
                animation-delay:.1s
            }
            .card:nth-child(2){
                animation-delay:.15s
            }
            .card-hd{
                display:flex;
                align-items:center;
                gap:10px;
                padding:13px 18px;
                border-bottom:1px solid var(--border-light2);
                background:#fafbff;
            }
            .card-hd-icon{
                width:30px;
                height:30px;
                border-radius:8px;
                background:var(--primary-light);
                color:var(--primary-2);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:.78rem;
                flex-shrink:0;
            }
            .card-hd-title{
                font-size:.86rem;
                font-weight:700;
                color:var(--text-h)
            }
            .card-body{
                padding:18px
            }

            /* ── TABLE ── */
            table{
                width:100%;
                border-collapse:collapse;
                font-size:.8rem
            }
            thead tr{
                background:#fafbff
            }
            th{
                padding:10px 16px;
                text-align:left;
                color:var(--text-s);
                font-weight:700;
                font-size:.67rem;
                text-transform:uppercase;
                letter-spacing:.8px;
                border-bottom:1px solid var(--border-light2);
            }
            td{
                padding:12px 16px;
                border-bottom:1px solid var(--border-light2);
                vertical-align:middle;
                color:var(--text-b);
            }
            tr:last-child td{
                border-bottom:none
            }
            tbody tr{
                transition:background .12s
            }
            tbody tr:hover td{
                background:#f7f8ff
            }
            th:nth-child(n+3),td:nth-child(n+3){
                text-align:right
            }

            /* Item type badge */
            .item-type{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.67rem;
                font-weight:700;
            }
            .it-part   {
                background:#e0f2fe;
                color:var(--info);
                border:1px solid #bae6fd
            }
            .it-service{
                background:#d1fae5;
                color:var(--green);
                border:1px solid #a7f3d0
            }
            .it-equip  {
                background:#fef3c7;
                color:#92400e;
                border:1px solid #fde68a
            }
            .it-other  {
                background:var(--primary-light);
                color:var(--purple);
                border:1px solid rgba(124,58,237,0.2)
            }

            /* Summary rows */
            .sum-wrap{
                padding:14px 18px;
                border-top:1px solid var(--border-light2);
                background:#fafbff
            }
            .sum-inner{
                max-width:280px;
                margin-left:auto
            }
            .sum-row{
                display:flex;
                justify-content:space-between;
                padding:7px 0;
                font-size:.83rem;
                border-bottom:1px solid var(--border-light2);
                color:var(--text-b);
            }
            .sum-row .lbl{
                color:var(--text-s)
            }
            .sum-row:last-child{
                border:none;
                border-top:1px solid var(--border-light);
                font-size:1.02rem;
                font-weight:800;
                color:var(--primary-2);
                padding-top:11px;
                margin-top:3px;
            }
            .sum-row:last-child .lbl{
                color:var(--text-h)
            }

            /* ── BADGES ── */
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700
            }
            .b-unpaid   {
                background:#fef3c7;
                color:#92400e
            }
            .b-paid     {
                background:#d1fae5;
                color:#065f46
            }
            .b-cancelled{
                background:#f3f4f6;
                color:#6b7280
            }

            /* ── INFO GRID (right panel) ── */
            .info-grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:12px;
                margin-bottom:16px;
            }
            .info-item .lbl{
                font-size:.67rem;
                color:var(--text-s);
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:.5px;
                margin-bottom:4px;
            }
            .info-item .val{
                font-size:.83rem;
                color:var(--text-b);
                font-weight:500
            }
            .info-item .val a{
                color:var(--primary-2);
                text-decoration:none;
                font-weight:700;
                font-family:'Courier New',monospace
            }
            .info-item .val a:hover{
                color:var(--primary);
                text-decoration:underline
            }

            /* Amount display */
            .amount-box{
                background:#fafbff;
                border:1px solid var(--border-light);
                border-radius:12px;
                padding:16px;
                margin-bottom:14px;
            }
            .amount-lbl{
                font-size:.67rem;
                color:var(--text-s);
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:.8px;
                margin-bottom:6px;
            }
            .amount-val{
                font-size:1.75rem;
                font-weight:800;
                line-height:1;
                letter-spacing:-1px;
            }
            .amount-val.unpaid{
                color:var(--red)
            }
            .amount-val.paid  {
                color:var(--green)
            }
            .amount-sub{
                font-size:.72rem;
                color:var(--text-s);
                margin-top:6px;
                display:flex;
                align-items:center;
                gap:5px
            }

            /* ── PAYMENT SECTION ── */
            .pay-section{
                margin-top:14px
            }
            .pay-title{
                font-size:.67rem;
                font-weight:700;
                color:var(--text-s);
                text-transform:uppercase;
                letter-spacing:.8px;
                margin-bottom:10px;
                display:flex;
                align-items:center;
                gap:6px
            }
            .pay-btns{
                display:flex;
                flex-direction:column;
                gap:9px
            }
            .btn-pay{
                display:flex;
                align-items:center;
                justify-content:center;
                gap:9px;
                width:100%;
                padding:12px;
                color:#fff;
                border:none;
                border-radius:11px;
                font-size:.875rem;
                font-weight:700;
                cursor:pointer;
                transition:all .25s;
                font-family:'Sora',sans-serif;
            }
            .btn-pay-cash {
                background:var(--green);
                box-shadow:0 3px 12px rgba(22,163,74,0.25)
            }
            .btn-pay-vnpay{
                background:linear-gradient(135deg,#f43f5e,#be123c);
                box-shadow:0 3px 12px rgba(244,63,94,0.25)
            }
            .btn-pay-cash:hover {
                background:#15803d;
                transform:translateY(-2px);
                box-shadow:0 6px 18px rgba(22,163,74,0.38)
            }
            .btn-pay-vnpay:hover{
                transform:translateY(-2px);
                box-shadow:0 6px 18px rgba(244,63,94,0.38)
            }

            /* ── MODAL ── */
            .modal-overlay{
                display:none;
                position:fixed;
                inset:0;
                background:rgba(243,244,249,0.7);
                backdrop-filter:blur(6px);
                z-index:999;
                align-items:center;
                justify-content:center;
            }
            .modal-overlay.show{
                display:flex
            }
            .modal{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:18px;
                width:440px;
                max-width:95vw;
                overflow:hidden;
                box-shadow:0 16px 50px rgba(79,70,229,0.15);
                animation:modalIn .25s ease;
            }
            @keyframes modalIn{
                from{
                    opacity:0;
                    transform:scale(0.95) translateY(10px)
                }
                to{
                    opacity:1;
                    transform:scale(1) translateY(0)
                }
            }
            .modal-header{
                padding:16px 22px;
                border-bottom:1px solid var(--border-light);
                display:flex;
                align-items:center;
                justify-content:space-between;
                background:#fafbff;
            }
            .modal-title{
                font-size:.93rem;
                font-weight:700;
                color:var(--text-h);
                display:flex;
                align-items:center;
                gap:9px
            }
            .modal-title i{
                color:var(--green)
            }
            .modal-close{
                width:30px;
                height:30px;
                border-radius:8px;
                background:#fff;
                border:1.5px solid var(--border-light);
                cursor:pointer;
                display:flex;
                align-items:center;
                justify-content:center;
                color:var(--text-m);
                font-size:.9rem;
                transition:all .2s;
            }
            .modal-close:hover{
                background:#fee2e2;
                color:var(--red);
                border-color:#fca5a5
            }
            .modal-body{
                padding:22px
            }
            .modal-footer{
                padding:14px 22px;
                border-top:1px solid var(--border-light);
                display:flex;
                gap:9px;
                background:#fafbff
            }

            /* Cash modal */
            .cash-amount-box{
                background:#d1fae5;
                border:1px solid #a7f3d0;
                border-radius:12px;
                padding:18px;
                text-align:center;
                margin-bottom:18px;
            }
            .cash-amount-lbl{
                font-size:.71rem;
                color:#065f46;
                font-weight:600;
                margin-bottom:5px
            }
            .cash-amount-val{
                font-size:1.85rem;
                font-weight:800;
                color:var(--green);
                letter-spacing:-1px
            }
            .cash-amount-code{
                font-family:'Courier New',monospace;
                font-size:.77rem;
                color:var(--text-m);
                margin-top:5px
            }

            /* Cash steps */
            .cash-steps{
                list-style:none;
                margin-bottom:18px
            }
            .cash-steps li{
                display:flex;
                gap:11px;
                padding:9px 0;
                border-bottom:1px solid var(--border-light2);
                font-size:.81rem;
                color:var(--text-b);
            }
            .cash-steps li:last-child{
                border:none
            }
            .step-num{
                width:22px;
                height:22px;
                border-radius:50%;
                background:var(--primary);
                color:#fff;
                font-size:.67rem;
                font-weight:700;
                display:flex;
                align-items:center;
                justify-content:center;
                flex-shrink:0;
            }

            .btn-confirm-cash{
                flex:1;
                padding:11px;
                background:var(--green);
                color:#fff;
                border:none;
                border-radius:10px;
                font-size:.875rem;
                font-weight:700;
                cursor:pointer;
                transition:all .2s;
                font-family:'Sora',sans-serif;
            }
            .btn-confirm-cash:hover{
                background:#15803d;
                transform:translateY(-1px);
                box-shadow:0 4px 14px rgba(22,163,74,0.3)
            }
            .btn-modal-cancel{
                padding:11px 16px;
                background:#fff;
                color:var(--text-m);
                border:1.5px solid var(--border-light);
                border-radius:10px;
                font-size:.875rem;
                font-weight:600;
                cursor:pointer;
                transition:all .2s;
                font-family:'Sora',sans-serif;
            }
            .btn-modal-cancel:hover{
                background:#f3f4f6;
                border-color:#d1d5db;
                color:var(--text-b)
            }
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
                <a href="<%=ctx%>/customerDashboard" class="sb-item"><i class="fas fa-home"></i> Dashboard</a>
                <div class="sb-lbl">Services</div>
                <a href="<%=ctx%>/customerServiceRequests" class="sb-item"><i class="fas fa-clipboard-list"></i> Repair Requests</a>
                <a href="<%=ctx%>/customerContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/customerEquipment"       class="sb-item"><i class="fas fa-desktop"></i> My Equipment</a>
                <div class="sb-lbl">Shop</div>
                <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item"><i class="fas fa-puzzle-piece"></i> Parts</a>
                <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Equipment</a>
                <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item">
                    <i class="fas fa-shopping-cart"></i> Cart
                    <%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%>
                </a>
                <div class="sb-lbl">Finance</div>
                <a href="<%=ctx%>/customerInvoices" class="sb-item on"><i class="fas fa-receipt"></i> Invoices</a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/customerChat" class="sb-item"><i class="fas fa-comment-dots"></i> Support Chat</a>
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
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
            </div>
        </aside>

        <%-- ═══════════ MAIN ═══════════ --%>
        <main class="main">

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
                                <div class="inv-code-hd"><%=inv.getInvoiceCode()%></div>
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
                            <div class="card-body" style="text-align:center;color:var(--text-s);padding:32px 24px">
                                <i class="fas fa-inbox" style="font-size:1.8rem;opacity:.2;display:block;margin-bottom:10px;color:var(--text-m)"></i>
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
                                        if("PART".equals(it.getItemType()))          itCls="it-part";
                                        else if("SERVICE".equals(it.getItemType())) itCls="it-service";
                                        else if("EQUIPMENT".equals(it.getItemType())) itCls="it-equip";
                                    %>
                                    <tr>
                                        <td style="color:var(--text-s);font-size:.78rem"><%=i+1%></td>
                                        <td style="font-weight:600;color:var(--text-h)"><%=it.getItemName()%></td>
                                        <td><span class="item-type <%=itCls%>"><%=it.getItemType()%></span></td>
                                        <td><%=it.getQuantity()%></td>
                                        <td><%=it.getUnitPrice()!=null?nf.format(it.getUnitPrice()):"0"%> ₫</td>
                                        <td><strong style="color:var(--text-h)"><%=it.getTotalPrice()!=null?nf.format(it.getTotalPrice()):"0"%> ₫</strong></td>
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
                                        <div class="val" style="font-family:'Courier New',monospace;font-weight:700;color:var(--primary-2)"><%=inv.getInvoiceCode()%></div>
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
                                        <div class="val" style="<%=overdue?"color:var(--red);font-weight:700":""%>">
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
                                        <i class="fas fa-ban" style="color:var(--text-s)"></i> Invoice cancelled
                                        <%}%>
                                    </div>
                                </div>

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
                                <div class="card-hd-icon" style="background:#fef3c7;color:var(--amber)"><i class="fas fa-note-sticky"></i></div>
                                <div class="card-hd-title">Notes</div>
                            </div>
                            <div class="card-body" style="font-size:.83rem;color:var(--text-m);line-height:1.75">
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
                        <li><span class="step-num">1</span><span>Prepare the exact amount of <strong style="color:var(--text-h)"><%=inv.getTotalAmount()!=null?nf.format(inv.getTotalAmount()):"0"%> ₫</strong></span></li>
                        <li><span class="step-num">2</span><span>Visit the DRSMS System office or hand it to the on-site technician</span></li>
                        <li><span class="step-num">3</span><span>Staff will confirm and issue a payment receipt for you</span></li>
                        <li><span class="step-num">4</span><span>Click <strong style="color:var(--text-h)">"Confirm Payment"</strong> to record it in the system</span></li>
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
            document.getElementById('cashModal').addEventListener('click', function (e) {
                if (e.target === this)
                    closeCashModal();
            });

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
        <%@ include file="customerAIBubble.jsp" %>
    </body>
</html>
