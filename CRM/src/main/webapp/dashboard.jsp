<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String ctx = request.getContextPath();
    String displayName = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName() : currentUser.getUsername();
    String initials = displayName.substring(0,1).toUpperCase();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Dashboard – Storekeeper</title>
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
                letter-spacing:-.3px
            }
            .topbar-sub{
                color:var(--text-s);
                font-size:.78rem;
                margin-top:2px
            }
            .user-badge{
                display:flex;
                align-items:center;
                gap:8px;
                padding:8px 16px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:24px;
                font-size:.8rem;
                color:var(--text-m);
            }
            .user-badge i{
                color:var(--primary-2);
                font-size:1rem
            }
            .user-badge strong{
                color:var(--text-h)
            }

            .content{
                padding:24px 28px;
                flex:1
            }

            /* Section label */
            .section-lbl{
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:2px;
                color:var(--primary-2);
                margin-bottom:13px;
                display:flex;
                align-items:center;
                gap:10px;
            }
            .section-lbl::after{
                content:'';
                flex:1;
                height:1px;
                background:linear-gradient(to right,rgba(99,102,241,0.2),transparent)
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

            /* Welcome banner */
            .welcome-banner{
                background:linear-gradient(135deg,var(--primary) 0%,var(--purple) 60%,#6366f1 100%);
                border-radius:18px;
                padding:28px 32px;
                margin-bottom:28px;
                display:flex;
                align-items:center;
                justify-content:space-between;
                position:relative;
                overflow:hidden;
                color:#fff;
                box-shadow:0 8px 32px rgba(79,70,229,0.3);
                animation:cardIn .45s .05s ease both;
            }
            .welcome-banner::before{
                content:'';
                position:absolute;
                top:-40px;
                right:-40px;
                width:200px;
                height:200px;
                background:radial-gradient(circle,rgba(255,255,255,0.15) 0%,transparent 70%);
                border-radius:50%;
            }
            .welcome-banner::after{
                content:'';
                position:absolute;
                bottom:-50px;
                right:130px;
                width:150px;
                height:150px;
                background:radial-gradient(circle,rgba(255,255,255,0.08) 0%,transparent 70%);
                border-radius:50%;
            }
            .welcome-text{
                position:relative;
                z-index:1;
            }
            .welcome-text h2{
                font-size:1.3rem;
                font-weight:800;
                color:#fff;
                margin-bottom:5px;
            }
            .welcome-text h2 span{
                color:#c7d2fe;
            }
            .welcome-text p{
                color:rgba(255,255,255,0.75);
                font-size:.86rem;
            }
            .welcome-icon{
                font-size:3.8rem;
                color:rgba(255,255,255,0.12);
                position:absolute;
                right:36px;
                z-index:0;
            }

            /* Nav grid */
            .nav-grid{
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:14px;
            }
            .nav-card{
                background:var(--bg-card);
                border:1.5px solid var(--border-light);
                border-radius:16px;
                padding:22px 20px;
                text-decoration:none;
                display:flex;
                flex-direction:column;
                gap:13px;
                position:relative;
                overflow:hidden;
                transition:all .22s ease;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
            }
            .nav-card::before{
                content:'';
                position:absolute;
                top:0;
                left:0;
                right:0;
                height:3px;
                background:var(--c,var(--primary));
                transform:scaleX(0);
                transform-origin:left;
                transition:transform .22s ease;
                border-radius:16px 16px 0 0;
            }
            .nav-card:hover{
                transform:translateY(-3px);
                border-color:rgba(99,102,241,0.2);
                box-shadow:0 12px 32px rgba(0,0,0,0.1);
            }
            .nav-card:hover::before{
                transform:scaleX(1);
            }
            .nav-card:hover .nav-card-icon{
                transform:scale(1.1) rotate(-4deg);
            }
            .nav-card:hover .nav-arrow-icon{
                transform:translateX(4px);
            }

            .nav-card-icon{
                width:46px;
                height:46px;
                border-radius:12px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.15rem;
                background:var(--cb,var(--primary-light));
                color:var(--c,var(--primary));
                transition:transform .2s;
            }
            .nav-card-content h3{
                font-size:.9rem;
                font-weight:700;
                color:var(--text-h);
                margin-bottom:4px;
            }
            .nav-card-content p{
                font-size:.77rem;
                color:var(--text-m);
                line-height:1.55;
            }
            .nav-card-arrow{
                display:flex;
                align-items:center;
                justify-content:space-between;
                margin-top:auto;
            }
            .nav-card-arrow span{
                font-size:.75rem;
                font-weight:600;
                color:var(--c,var(--primary));
            }
            .nav-arrow-icon{
                font-size:.72rem;
                color:var(--c,var(--primary));
                transition:transform .2s;
            }

            /* Color helpers — light palette */
            .cc-primary{
                --c:var(--primary);
                --cb:var(--primary-light);
            }
            .cc-green  {
                --c:var(--green);
                --cb:#dcfce7;
            }
            .cc-info   {
                --c:var(--info);
                --cb:#e0f2fe;
            }
            .cc-amber  {
                --c:var(--amber);
                --cb:#fef3c7;
            }
            .cc-rose   {
                --c:#e11d48;
                --cb:#fee2e2;
            }
            .cc-purple {
                --c:var(--purple);
                --cb:#ede9fe;
            }

            /* Stagger */
            .nav-card:nth-child(1){
                animation:cardIn .45s .08s ease both;
            }
            .nav-card:nth-child(2){
                animation:cardIn .45s .13s ease both;
            }
            .nav-card:nth-child(3){
                animation:cardIn .45s .18s ease both;
            }
            .nav-card:nth-child(4){
                animation:cardIn .45s .23s ease both;
            }
            .nav-card:nth-child(5){
                animation:cardIn .45s .28s ease both;
            }
        </style>
    </head>
    <body>

        <%-- ═══════════ SIDEBAR ═══════════ --%>
        <aside class="sb">
            <div class="sb-brand">
                <div class="sb-logo"><i class="fas fa-warehouse"></i></div>
                <div>
                    <div class="sb-name">DRSMS</div>
                    <div class="sb-role">Storekeeper</div>
                </div>
            </div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/dashboard.jsp" class="sb-item on">
                    <i class="fas fa-house"></i> Home
                </a>
                <a href="<%=ctx%>/storekeeper" class="sb-item">
                    <i class="fas fa-chart-bar"></i> Statistics
                </a>
                <div class="sb-lbl">Inventory</div>
                <a href="<%=ctx%>/numberPart" class="sb-item">
                    <i class="fas fa-puzzle-piece"></i> Parts List
                </a>
                <a href="<%=ctx%>/numberEquipment" class="sb-item">
                    <i class="fas fa-desktop"></i> Equipment List
                </a>
                <div class="sb-lbl">Records</div>
                <a href="<%=ctx%>/transactions" class="sb-item">
                    <i class="fas fa-clock-rotate-left"></i> Transaction History
                </a>
            </nav>
            <div class="sb-foot">
                <a href="<%=ctx%>/profile" class="sb-user">
                    <div class="sb-ava">
                        <%if(currentUser.getAvatarUrl()!=null&&!currentUser.getAvatarUrl().isEmpty()){%>
                        <img src="<%=ctx%><%=currentUser.getAvatarUrl()%>" alt="avatar">
                        <%}else{%><%=initials%><%}%>
                    </div>
                    <div>
                        <div class="sb-uname"><%=displayName%></div>
                        <div class="sb-urole">Storekeeper</div>
                    </div>
                </a>
                <a href="<%=ctx%>/logout" class="sb-logout">
                    <i class="fas fa-sign-out-alt"></i> Sign Out
                </a>
            </div>
        </aside>

        <%-- ═══════════ MAIN ═══════════ --%>
        <main class="main">

            <div class="topbar">
                <div>
                    <div class="topbar-greeting">
                        <i class="fas fa-house" style="color:var(--primary-2);margin-right:8px;font-size:1rem"></i>Dashboard
                    </div>
                    <div class="topbar-sub">Welcome back! Select a function below to get started.</div>
                </div>
                <div class="user-badge">
                    <i class="fas fa-user-circle"></i>
                    <strong><%=currentUser.getUsername()%></strong>
                    &nbsp;·&nbsp; Storekeeper
                </div>
            </div>

            <div class="content">

                <%-- Welcome Banner --%>
                <div class="welcome-banner">
                    <div class="welcome-text">
                        <h2>Hello, <span><%=displayName%>!</span></h2>
                        <p>Manage your warehouse, parts, and equipment from here.</p>
                    </div>
                    <i class="fas fa-warehouse welcome-icon"></i>
                </div>

                <%-- Nav Cards --%>
                <div class="section-lbl">Main Functions</div>
                <div class="nav-grid">

                    <a href="<%=ctx%>/storekeeper" class="nav-card cc-primary">
                        <div class="nav-card-icon"><i class="fas fa-chart-bar"></i></div>
                        <div class="nav-card-content">
                            <h3>Warehouse Statistics</h3>
                            <p>Overview of parts and equipment stock status.</p>
                        </div>
                        <div class="nav-card-arrow">
                            <span>View statistics</span>
                            <i class="fas fa-arrow-right nav-arrow-icon"></i>
                        </div>
                    </a>

                    <a href="<%=ctx%>/numberPart" class="nav-card cc-green">
                        <div class="nav-card-icon"><i class="fas fa-list-ul"></i></div>
                        <div class="nav-card-content">
                            <h3>Parts List</h3>
                            <p>Manage, add, edit, and delete part types.</p>
                        </div>
                        <div class="nav-card-arrow">
                            <span>Manage parts</span>
                            <i class="fas fa-arrow-right nav-arrow-icon"></i>
                        </div>
                    </a>

                    <a href="<%=ctx%>/numberEquipment" class="nav-card cc-info">
                        <div class="nav-card-icon"><i class="fas fa-desktop"></i></div>
                        <div class="nav-card-content">
                            <h3>Equipment List</h3>
                            <p>Manage equipment models and serial number stock.</p>
                        </div>
                        <div class="nav-card-arrow">
                            <span>Manage equipment</span>
                            <i class="fas fa-arrow-right nav-arrow-icon"></i>
                        </div>
                    </a>

                    <a href="<%=ctx%>/transactions" class="nav-card cc-amber">
                        <div class="nav-card-icon"><i class="fas fa-clock-rotate-left"></i></div>
                        <div class="nav-card-content">
                            <h3>Transaction History</h3>
                            <p>Browse purchase, repair, and stock-in history.</p>
                        </div>
                        <div class="nav-card-arrow">
                            <span>View history</span>
                            <i class="fas fa-arrow-right nav-arrow-icon"></i>
                        </div>
                    </a>

                    <a href="<%=ctx%>/profile" class="nav-card cc-rose">
                        <div class="nav-card-icon"><i class="fas fa-circle-user"></i></div>
                        <div class="nav-card-content">
                            <h3>Personal Profile</h3>
                            <p>View and update your account information.</p>
                        </div>
                        <div class="nav-card-arrow">
                            <span>View profile</span>
                            <i class="fas fa-arrow-right nav-arrow-icon"></i>
                        </div>
                    </a>

                </div>
            </div>
        </main>
    </body>
</html>
