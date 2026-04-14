<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER_SUPPORT".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    List<ServiceRequest> requests = (List<ServiceRequest>) request.getAttribute("requests");
    if (requests == null) requests = new ArrayList<>();
    List<User> customers = (List<User>) request.getAttribute("customers");
    if (customers == null) customers = new ArrayList<>();
    int total       = request.getAttribute("total")       != null ? (int)request.getAttribute("total")       : 0;
    int currentPage = request.getAttribute("page")        != null ? (int)request.getAttribute("page")        : 1;
    int totalPages  = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages")  : 1;
    String keyword  = request.getAttribute("keyword")     != null ? (String)request.getAttribute("keyword")  : "";
    String fStatus  = request.getAttribute("filterStatus")!= null ? (String)request.getAttribute("filterStatus") : "";
    String fPriority= request.getAttribute("filterPriority")!=null?(String)request.getAttribute("filterPriority"):"";
    String fType    = request.getAttribute("filterType")  != null ? (String)request.getAttribute("filterType")   : "";

    String flashOk  = (String) session.getAttribute("flash_success");
    String flashErr = (String) session.getAttribute("flash_error");
    session.removeAttribute("flash_success");
    session.removeAttribute("flash_error");

    String initials = me.getFullName() != null && !me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Service Requests – Customer Support</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --sb-bg:        #1e1b4b;
                --sb-border:    rgba(255,255,255,0.08);
                --sb-text:      rgba(255,255,255,0.45);
                --sb-accent:    #818cf8;
                --sb-accent-2:  #a5b4fc;
                --sb-item-on:   rgba(129,140,248,0.2);
                --sb-width:     252px;

                --bg:           #f3f4f9;
                --bg-card:      #ffffff;
                --bg-topbar:    #ffffff;
                --border-light: #e8ecf5;
                --border-light2:#f0f2fb;
                --text-h:       #1e1b4b;
                --text-b:       #374151;
                --text-m:       #6b7280;
                --text-s:       #9ca3af;

                --primary:      #4f46e5;
                --primary-2:    #6366f1;
                --primary-light:#ede9fe;

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

            /* ═══════════ MAIN ═══════════ */
            .main{
                margin-left:var(--sb-width);
                flex:1;
                display:flex;
                flex-direction:column;
                min-height:100vh
            }
            .topbar{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:18px 28px;
                background:var(--bg-topbar);
                border-bottom:1px solid var(--border-light);
                position:sticky;
                top:0;
                z-index:50;
                box-shadow:0 1px 6px rgba(0,0,0,0.06);
            }
            .topbar-greeting{
                font-size:1.2rem;
                font-weight:800;
                color:var(--text-h);
                letter-spacing:-.3px;
                display:flex;
                align-items:center;
                gap:8px;
            }
            .topbar-greeting i{
                color:var(--primary-2);
                font-size:1rem
            }
            .topbar-sub{
                color:var(--text-s);
                font-size:.78rem;
                margin-top:2px
            }
            .content{
                padding:24px 28px;
                flex:1
            }

            /* Alert */
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
            .alert{
                display:flex;
                align-items:center;
                gap:12px;
                padding:12px 18px;
                border-radius:12px;
                margin-bottom:20px;
                font-size:.82rem;
                animation:cardIn .5s ease both;
            }
            .alert-success{
                background:#d1fae5;
                border:1px solid #a7f3d0;
                color:#065f46
            }
            .alert-success i{
                color:var(--green)
            }
            .alert-error{
                background:#fee2e2;
                border:1px solid #fca5a5;
                color:#991b1b
            }
            .alert-error i{
                color:var(--red)
            }

            /* Filter bar */
            .filter-bar{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:14px;
                padding:14px 16px;
                display:flex;
                flex-wrap:wrap;
                gap:10px;
                align-items:center;
                margin-bottom:18px;
                box-shadow:0 1px 4px rgba(0,0,0,0.04);
                animation:cardIn .5s .1s ease both;
            }
            .filter-bar input,.filter-bar select{
                padding:9px 13px;
                border:1.5px solid var(--border-light);
                border-radius:9px;
                font-size:.81rem;
                font-family:'Sora',sans-serif;
                color:var(--text-b);
                background:#fff;
                outline:none;
                transition:all .2s;
            }
            .filter-bar input::placeholder{
                color:var(--text-s)
            }
            .filter-bar input:focus,.filter-bar select:focus{
                border-color:rgba(79,70,229,0.4);
                background:#faf9ff;
                box-shadow:0 0 0 3px rgba(79,70,229,0.07);
            }
            .filter-bar select option{
                background:#fff;
                color:var(--text-b)
            }
            .filter-total{
                margin-left:auto;
                font-size:.8rem;
                color:var(--text-s);
                font-weight:500
            }

            /* Buttons */
            .btn{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:9px 18px;
                border-radius:10px;
                font-size:.81rem;
                font-weight:600;
                font-family:'Sora',sans-serif;
                cursor:pointer;
                border:none;
                text-decoration:none;
                transition:all .2s;
            }
            .btn-primary{
                background:var(--primary);
                color:#fff;
                box-shadow:0 3px 10px rgba(79,70,229,0.28);
            }
            .btn-primary:hover{
                background:#4338ca;
                transform:translateY(-1px);
                box-shadow:0 6px 18px rgba(79,70,229,0.4)
            }
            .btn-secondary{
                background:#fff;
                color:var(--text-m);
                border:1.5px solid var(--border-light);
            }
            .btn-secondary:hover{
                background:#f3f4f6;
                border-color:#d1d5db;
                color:var(--text-b)
            }
            .btn-sm{
                padding:6px 13px;
                font-size:.75rem;
            }

            /* Table wrap */
            .table-wrap{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                animation:cardIn .5s .2s ease both;
            }
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
            .td-muted{
                color:var(--text-s);
                font-size:.75rem
            }
            .td-empty{
                text-align:center;
                padding:36px 16px;
                color:var(--text-s);
                font-size:.82rem
            }

            /* Code link */
            .code-link{
                color:var(--primary-2);
                font-weight:700;
                font-size:.77rem;
                font-family:'Courier New',monospace;
                text-decoration:none;
                letter-spacing:-.3px;
            }
            .code-link:hover{
                color:var(--primary);
                text-decoration:underline
            }

            /* Contract type mini */
            .ct-badge{
                display:inline-block;
                padding:2px 7px;
                border-radius:5px;
                font-size:.67rem;
                font-weight:700;
                margin-top:3px;
            }
            .ct-wr{
                background:#dbeafe;
                color:#1e40af
            }
            .ct-mt{
                background:#fef3c7;
                color:#92400e
            }

            /* Badges */
            .b{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:20px;
                font-size:.68rem;
                font-weight:700;
                white-space:nowrap;
            }
            .b-pending    {
                background:#fef3c7;
                color:#92400e
            }
            .b-approved   {
                background:#d1fae5;
                color:#065f46
            }
            .b-rejected   {
                background:#fee2e2;
                color:#991b1b
            }
            .b-in-progress,.b-in_progress{
                background:#dbeafe;
                color:#1e40af
            }
            .b-completed  {
                background:#ede9fe;
                color:#5b21b6
            }
            .b-cancelled  {
                background:#f3f4f6;
                color:#6b7280
            }
            .b-low        {
                background:#dcfce7;
                color:#166534
            }
            .b-medium     {
                background:#fef3c7;
                color:#92400e
            }
            .b-high       {
                background:#ffedd5;
                color:#9a3412
            }
            .b-urgent     {
                background:#fee2e2;
                color:#991b1b
            }

            /* Pagination */
            .pagination{
                display:flex;
                justify-content:flex-end;
                align-items:center;
                gap:5px;
                padding:13px 16px;
                border-top:1px solid var(--border-light2);
            }
            .pagination a,.pagination span{
                padding:6px 12px;
                border-radius:8px;
                font-size:.77rem;
                font-weight:500;
                text-decoration:none;
                color:var(--text-m);
                border:1.5px solid var(--border-light);
                background:#fff;
                transition:all .15s;
            }
            .pagination a:hover{
                background:var(--primary-light);
                border-color:rgba(99,102,241,0.3);
                color:var(--primary-2)
            }
            .pagination .active{
                background:var(--primary);
                color:#fff;
                border-color:transparent;
                box-shadow:0 3px 8px rgba(79,70,229,0.3);
            }
            .pagination .disabled{
                opacity:.4;
                pointer-events:none
            }

            /* ════════ MODAL ════════ */
            .modal-overlay{
                display:none;
                position:fixed;
                inset:0;
                background:rgba(0,0,0,0.45);
                backdrop-filter:blur(4px);
                z-index:1000;
                align-items:center;
                justify-content:center;
            }
            .modal-overlay.open{
                display:flex;
            }
            .modal{
                background:#fff;
                border:1px solid var(--border-light);
                border-radius:18px;
                padding:28px;
                width:100%;
                max-width:620px;
                max-height:92vh;
                overflow-y:auto;
                position:relative;
                box-shadow:0 24px 60px rgba(0,0,0,0.15),0 0 0 1px rgba(79,70,229,0.08);
                animation:modalIn .25s cubic-bezier(.4,0,.2,1) both;
            }
            .modal::-webkit-scrollbar{
                width:3px
            }
            .modal::-webkit-scrollbar-thumb{
                background:rgba(79,70,229,0.2);
                border-radius:4px
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
            .modal h2{
                font-size:1rem;
                font-weight:700;
                color:var(--text-h);
                margin-bottom:20px;
                display:flex;
                align-items:center;
                gap:9px;
            }
            .modal h2 i{
                color:var(--primary-2)
            }
            .modal-close{
                position:absolute;
                top:16px;
                right:18px;
                background:#f3f4f6;
                border:1px solid var(--border-light);
                border-radius:8px;
                width:28px;
                height:28px;
                font-size:.82rem;
                cursor:pointer;
                color:var(--text-m);
                display:flex;
                align-items:center;
                justify-content:center;
                transition:all .15s;
            }
            .modal-close:hover{
                background:#fee2e2;
                color:var(--red);
                border-color:#fca5a5;
            }

            /* Form */
            .form-group{
                margin-bottom:16px;
            }
            .form-group label{
                display:block;
                font-size:.72rem;
                font-weight:700;
                color:var(--text-s);
                text-transform:uppercase;
                letter-spacing:.6px;
                margin-bottom:6px;
            }
            .form-group input,.form-group select,.form-group textarea{
                width:100%;
                padding:9px 13px;
                border:1.5px solid var(--border-light);
                border-radius:9px;
                font-size:.83rem;
                font-family:'Sora',sans-serif;
                color:var(--text-b);
                background:#fff;
                outline:none;
                transition:all .2s;
            }
            .form-group input::placeholder,.form-group textarea::placeholder{
                color:var(--text-s)
            }
            .form-group input:focus,.form-group select:focus,.form-group textarea:focus{
                border-color:rgba(79,70,229,0.4);
                background:#faf9ff;
                box-shadow:0 0 0 3px rgba(79,70,229,0.07);
            }
            .form-row{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:12px;
            }
            .modal-footer{
                display:flex;
                gap:10px;
                justify-content:flex-end;
                margin-top:20px;
                padding-top:16px;
                border-top:1px solid var(--border-light);
            }

            /* Equipment in modal */
            .equip-section{
                border:1.5px solid var(--border-light);
                border-radius:10px;
                overflow:hidden;
            }
            .equip-section-hd{
                padding:10px 14px;
                background:#fafbff;
                border-bottom:1px solid var(--border-light2);
                font-size:.78rem;
                font-weight:600;
                color:var(--text-m);
            }
            .equip-row{
                display:flex;
                align-items:flex-start;
                gap:10px;
                padding:10px 14px;
                border-bottom:1px solid var(--border-light2);
                transition:background .15s;
            }
            .equip-row:last-child{
                border-bottom:none
            }
            .equip-row:hover{
                background:#f7f8ff
            }
            .equip-row-info{
                flex:1
            }
            .equip-row-name{
                font-size:.82rem;
                font-weight:600;
                color:var(--text-h)
            }
            .equip-row-serial{
                font-size:.72rem;
                color:var(--text-s)
            }
            .equip-row-issue{
                margin-top:6px;
            }
            .equip-row-issue input{
                padding:7px 10px;
                border:1.5px solid var(--border-light);
                border-radius:7px;
                font-size:.78rem;
                width:100%;
                font-family:'Sora',sans-serif;
                color:var(--text-b);
                background:#fff;
                outline:none;
                transition:all .2s;
            }
            .equip-row-issue input::placeholder{
                color:var(--text-s)
            }
            .equip-row-issue input:focus{
                border-color:rgba(79,70,229,0.4);
                background:#faf9ff;
                box-shadow:0 0 0 3px rgba(79,70,229,0.07);
            }
            .equip-empty{
                padding:20px;
                text-align:center;
                color:var(--text-s);
                font-size:.82rem
            }
            .equip-loading{
                padding:20px;
                text-align:center;
                color:var(--text-s);
                font-size:.82rem
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
                    <div class="sb-role">Customer Support</div>
                </div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/supportDashboard"      class="sb-item"><i class="fas fa-home"></i> Dashboard</a>
                <div class="sb-lbl">Management</div>
                <a href="<%=ctx%>/supportCustomers"       class="sb-item"><i class="fas fa-users"></i> Customers</a>
                <a href="<%=ctx%>/supportContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/supportServiceRequests" class="sb-item on"><i class="fas fa-clipboard-list"></i> Service Requests</a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/supportChat"            class="sb-item"><i class="fas fa-comment-dots"></i> Live Chat</a>
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
                        <div class="sb-urole">Customer Support</div>
                    </div>
                </a>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
            </div>
        </aside>

        <%-- ═══════════ MAIN ═══════════ --%>
        <main class="main">

            <div class="topbar">
                <div>
                    <div class="topbar-greeting">
                        <i class="fas fa-clipboard-list"></i> Service Requests
                    </div>
                    <div class="topbar-sub">View and create service requests on behalf of customers</div>
                </div>
                <button class="btn btn-primary" onclick="openCreate()">
                    <i class="fas fa-plus"></i> Create on Behalf
                </button>
            </div>

            <div class="content">

                <%if(flashOk!=null){%>
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=flashOk%></div>
                <%}%>
                <%if(flashErr!=null){%>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=flashErr%></div>
                <%}%>

                <%-- Filter bar --%>
                <form method="get" action="<%=ctx%>/supportServiceRequests">
                    <div class="filter-bar">
                        <input type="text" name="keyword" value="<%=keyword%>"
                               placeholder="🔍  Code, customer, title..."
                               style="flex:1;min-width:180px">
                        <select name="status">
                            <option value="">All Status</option>
                            <%for(String s:new String[]{"PENDING","APPROVED","IN_PROGRESS","COMPLETED","REJECTED","CANCELLED"}){%>
                            <option value="<%=s%>" <%=s.equals(fStatus)?"selected":""%>><%=s.replace("_"," ")%></option>
                            <%}%>
                        </select>
                        <select name="priority">
                            <option value="">All Priority</option>
                            <%for(String p:new String[]{"LOW","MEDIUM","HIGH","URGENT"}){%>
                            <option value="<%=p%>" <%=p.equals(fPriority)?"selected":""%>><%=p%></option>
                            <%}%>
                        </select>
                        <select name="contractType">
                            <option value="">All Types</option>
                            <option value="WARRANTY"    <%="WARRANTY".equals(fType)?"selected":""%>>Warranty</option>
                            <option value="MAINTENANCE" <%="MAINTENANCE".equals(fType)?"selected":""%>>Maintenance</option>
                        </select>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-search"></i> Filter
                        </button>
                        <a href="<%=ctx%>/supportServiceRequests" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Reset
                        </a>
                        <span class="filter-total"><%=total%> request(s)</span>
                    </div>
                </form>

                <%-- Table --%>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Code</th><th>Customer</th><th>Contract</th>
                                <th>Title</th><th>Priority</th><th>Status</th>
                                <th>Created</th><th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%if(requests.isEmpty()){%>
                            <tr><td colspan="8" class="td-empty">No service requests found.</td></tr>
                            <%}else{ for(ServiceRequest sr:requests){
                                String st  = sr.getStatus()  != null ? sr.getStatus().toLowerCase().replace("_","-") : "";
                                String pri = sr.getPriority()!= null ? sr.getPriority().toLowerCase() : "medium";
                            %>
                            <tr>
                                <td>
                                    <a class="code-link" href="<%=ctx%>/supportServiceRequests?action=detail&id=<%=sr.getId()%>">
                                        <%=sr.getRequestCode()%>
                                    </a>
                                </td>
                                <td style="font-weight:600;color:var(--text-h)"><%=sr.getCustomerName()%></td>
                                <td>
                                    <div style="font-size:.75rem;font-weight:600;color:var(--text-h)"><%=sr.getContractCode()%></div>
                                    <span class="ct-badge <%="WARRANTY".equals(sr.getContractType())?"ct-wr":"ct-mt"%>">
                                        <%="WARRANTY".equals(sr.getContractType())?"WR":"MT"%>
                                    </span>
                                </td>
                                <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--text-m)" title="<%=sr.getTitle()%>">
                                    <%=sr.getTitle()%>
                                </td>
                                <td><span class="b b-<%=pri%>"><%=sr.getPriority()%></span></td>
                                <td><span class="b b-<%=st%>"><%=sr.getStatus()%></span></td>
                                <td class="td-muted"><%=sr.getCreatedAt()!=null?sr.getCreatedAt().toString().substring(0,10):""%></td>
                                <td>
                                    <a class="btn btn-sm btn-secondary"
                                       href="<%=ctx%>/supportServiceRequests?action=detail&id=<%=sr.getId()%>">
                                        <i class="fas fa-eye"></i> View
                                    </a>
                                </td>
                            </tr>
                            <%}}%>
                        </tbody>
                    </table>

                    <%-- Pagination --%>
                    <%if(totalPages>1){
                        String qp="&keyword="+keyword+"&status="+fStatus+"&priority="+fPriority+"&contractType="+fType;
                    %>
                    <div class="pagination">
                        <a href="<%=ctx%>/supportServiceRequests?page=<%=currentPage-1%><%=qp%>"
                           class="<%=currentPage<=1?"disabled":""%>">
                            <i class="fas fa-chevron-left"></i>
                        </a>
                        <%for(int p=Math.max(1,currentPage-2);p<=Math.min(totalPages,currentPage+2);p++){
                        if(p==currentPage){%>
                        <span class="active"><%=p%></span>
                        <%}else{%>
                        <a href="<%=ctx%>/supportServiceRequests?page=<%=p%><%=qp%>"><%=p%></a>
                        <%}%>
                        <%}%>
                        <a href="<%=ctx%>/supportServiceRequests?page=<%=currentPage+1%><%=qp%>"
                           class="<%=currentPage>=totalPages?"disabled":""%>">
                            <i class="fas fa-chevron-right"></i>
                        </a>
                    </div>
                    <%}%>
                </div>

            </div>
        </main>

        <%-- ════════ MODAL: CREATE SR ════════ --%>
        <div class="modal-overlay" id="createModal">
            <div class="modal">
                <button class="modal-close" onclick="closeModal()"><i class="fas fa-times"></i></button>
                <h2><i class="fas fa-plus-circle"></i> Create Service Request on Behalf</h2>
                <form method="post" action="<%=ctx%>/supportServiceRequests" id="srForm">
                    <input type="hidden" name="action" value="create">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Customer *</label>
                            <select name="customerId" id="srCustomer" required onchange="loadContracts()">
                                <option value="">-- Select customer --</option>
                                <%for(User u:customers){%>
                                <option value="<%=u.getId()%>"><%=u.getFullName()%></option>
                                <%}%>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Contract *</label>
                            <select name="contractId" id="srContract" required onchange="loadEquipment()" disabled>
                                <option value="">-- Select contract first --</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Equipment & Issue Description *</label>
                        <div id="srEquipContainer">
                            <div class="equip-empty">Select a customer and contract to load equipment.</div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Title *</label>
                        <input type="text" name="title" required placeholder="Brief description of the issue">
                    </div>
                    <div class="form-group">
                        <label>Description *</label>
                        <textarea name="description" rows="3" required placeholder="Detailed description..."></textarea>
                    </div>
                    <div class="form-group">
                        <label>Priority *</label>
                        <select name="priority" required>
                            <option value="LOW">Low</option>
                            <option value="MEDIUM" selected>Medium</option>
                            <option value="HIGH">High</option>
                            <option value="URGENT">Urgent</option>
                        </select>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" onclick="closeModal()">Cancel</button>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> Submit Request</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
        const CTX = '<%=ctx%>';

        function openCreate() {
            document.getElementById('createModal').classList.add('open');
        }
        function closeModal() {
            document.getElementById('createModal').classList.remove('open');
        }
        document.getElementById('createModal').addEventListener('click', e => {
            if (e.target === document.getElementById('createModal'))
                closeModal();
        });

        function loadContracts() {
            const cid = document.getElementById('srCustomer').value;
            const sel = document.getElementById('srContract');
            sel.innerHTML = '<option value="">Loading...</option>';
            sel.disabled = true;
            document.getElementById('srEquipContainer').innerHTML = '<div class="equip-empty">Select a contract to load equipment.</div>';
            if (!cid) {
                sel.innerHTML = '<option value="">-- Select contract first --</option>';
                return;
            }
            fetch(CTX + '/supportServiceRequests?action=getContracts&customerId=' + cid)
                    .then(r => r.json())
                    .then(list => {
                        if (list.length === 0) {
                            sel.innerHTML = '<option value="">No active contracts</option>';
                            return;
                        }
                        sel.innerHTML = '<option value="">-- Select contract --</option>';
                        list.forEach(c => {
                            sel.innerHTML += '<option value="' + c.id + '">[' + c.type + '] ' + c.code + ' \u00b7 ends ' + c.endDate + '</option>';
                        });
                        sel.disabled = false;
                    })
                    .catch(() => {
                        sel.innerHTML = '<option value="">Failed to load</option>';
                    });
        }

        function loadEquipment() {
            const contractId = document.getElementById('srContract').value;
            const container = document.getElementById('srEquipContainer');
            if (!contractId) {
                container.innerHTML = '<div class="equip-empty">Select a contract to load equipment.</div>';
                return;
            }
            container.innerHTML = '<div class="equip-loading"><i class="fas fa-spinner fa-spin"></i> Loading equipment...</div>';
            fetch(CTX + '/supportServiceRequests?action=getEquipment&contractId=' + contractId)
                    .then(r => r.json())
                    .then(list => {
                        if (!list || list.length === 0) {
                            container.innerHTML = '<div class="equip-empty">No equipment found for this contract.</div>';
                            return;
                        }
                        let html = '<div class="equip-section"><div class="equip-section-hd">Select equipment and describe the issue</div>';
                        list.forEach(e => {
                            html += '<div class="equip-row" id="erow-' + e.id + '">';
                            html += '<input type="checkbox" value="' + e.id + '" id="echeck-' + e.id + '"';
                            html += ' style="accent-color:var(--primary);width:16px;height:16px;flex-shrink:0;margin-top:3px"';
                            html += ' onchange="toggleEquipRow(' + e.id + ', this.checked)">';
                            html += '<div class="equip-row-info">';
                            html += '<label for="echeck-' + e.id + '" style="cursor:pointer">';
                            html += '<div class="equip-row-name">' + e.name + '</div>';
                            html += '<div class="equip-row-serial">Serial: ' + e.serial + '</div>';
                            html += '</label>';
                            html += '<div class="equip-row-issue" id="eissue-' + e.id + '" style="display:none;margin-top:6px">';
                            html += '<input type="text" id="edesc-' + e.id + '" placeholder="Describe the issue with this equipment (optional)">';
                            html += '</div></div></div>';
                        });
                        html += '</div>';
                        container.innerHTML = html;
                    })
                    .catch(() => {
                        container.innerHTML = '<div class="equip-empty" style="color:var(--red)">Failed to load equipment.</div>';
                    });
        }

        function toggleEquipRow(id, checked) {
            document.getElementById('eissue-' + id).style.display = checked ? 'block' : 'none';
        }

        document.getElementById('srForm').addEventListener('submit', function (e) {
            this.querySelectorAll('input.injected').forEach(el => el.remove());
            const rows = document.querySelectorAll('[id^="erow-"]');
            let checkedCount = 0;
            rows.forEach(row => {
                const id = row.id.replace('erow-', '');
                const cb = document.getElementById('echeck-' + id);
                if (cb && cb.checked) {
                    checkedCount++;
                    const descVal = (document.getElementById('edesc-' + id) || {}).value || '';
                    const hidId = document.createElement('input');
                    hidId.type = 'hidden';
                    hidId.name = 'equipmentIds';
                    hidId.value = id;
                    hidId.className = 'injected';
                    this.appendChild(hidId);
                    const hidDesc = document.createElement('input');
                    hidDesc.type = 'hidden';
                    hidDesc.name = 'issueDescriptions';
                    hidDesc.value = descVal;
                    hidDesc.className = 'injected';
                    this.appendChild(hidDesc);
                }
            });
            if (checkedCount === 0) {
                e.preventDefault();
                alert('Please select at least one equipment.');
            }
        });
        </script>
    </body>
</html>
