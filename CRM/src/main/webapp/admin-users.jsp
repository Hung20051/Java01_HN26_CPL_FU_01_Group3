<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Role, java.util.List, java.net.URLEncoder" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (request.getAttribute("currentPage") == null) {
        response.sendRedirect(request.getContextPath() + "/user/list");
        return;
    }
    List<User> users = (List<User>) request.getAttribute("users");
    List<Role> roles  = (List<Role>) request.getAttribute("roles");
    int currentPage   = (Integer) request.getAttribute("currentPage");
    int totalPages    = (Integer) request.getAttribute("totalPages");
    int total         = (Integer) request.getAttribute("total");
    String keyword    = request.getAttribute("keyword") != null ? (String) request.getAttribute("keyword") : "";
    String status     = request.getAttribute("status")  != null ? (String) request.getAttribute("status")  : "";
    String role       = request.getAttribute("role")    != null ? (String) request.getAttribute("role")    : "";
    String success    = request.getParameter("success");
    String error      = request.getParameter("error");
    String ctx        = request.getContextPath();
    String kwEnc = URLEncoder.encode(keyword, "UTF-8");
    String stEnc = URLEncoder.encode(status, "UTF-8");
    String rlEnc = URLEncoder.encode(role, "UTF-8");
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>User Management – DRSMS</title>
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

            /* Status colors */
            --purple:  #7c3aed;
            --blue:    #2563eb;
            --green:   #16a34a;
            --red:     #dc2626;
            --amber:   #d97706;
            --info:    #0284c7;
        }

        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{scroll-behavior:smooth}
        body{font-family:'Sora',sans-serif;background:var(--bg);color:var(--text-b);min-height:100vh;display:flex;}
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-track{background:transparent}
        ::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px}

        /* ═══════════ SIDEBAR ═══════════ */
        .sb{width:var(--sb-width);min-height:100vh;background:var(--sb-bg);border-right:1px solid rgba(79,70,229,0.2);display:flex;flex-direction:column;position:fixed;top:0;left:0;z-index:100;box-shadow:4px 0 24px rgba(0,0,0,0.15);}
        .sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border);}
        /* Admin logo — amber exception */
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#f59e0b,#f97316);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;box-shadow:0 4px 12px rgba(245,158,11,0.4);flex-shrink:0;}
        .sb-name{color:#fff;font-size:1.05rem;font-weight:800;letter-spacing:-.3px}
        /* Admin role badge — amber exception */
        .sb-role{display:inline-flex;align-items:center;background:rgba(217,119,6,0.2);border:1px solid rgba(217,119,6,0.35);color:#fbbf24;font-size:.6rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:2px 8px;border-radius:20px;margin-top:3px;}
        .sb-nav{flex:1;padding:12px 10px;overflow-y:auto}
        .sb-lbl{color:rgba(255,255,255,0.22);font-size:.6rem;font-weight:700;text-transform:uppercase;letter-spacing:1.6px;padding:0 8px;margin:14px 0 5px;}
        .sb-item{display:flex;align-items:center;gap:9px;padding:8px 10px;border-radius:9px;margin-bottom:1px;color:var(--sb-text);text-decoration:none;font-size:.81rem;font-weight:500;transition:all .18s;border-left:2px solid transparent;}
        .sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.78rem;border-radius:8px;background:rgba(255,255,255,0.06);flex-shrink:0;transition:all .18s;}
        .sb-item.on{color:#fff;background:var(--sb-item-on);border-left-color:var(--sb-accent);}
        .sb-item.on i{background:rgba(129,140,248,0.3);color:var(--sb-accent-2)}
        .sb-item:hover:not(.on){color:rgba(255,255,255,0.78);background:rgba(255,255,255,0.06);}
        .sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border)}
        .sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);margin-bottom:5px;text-decoration:none;transition:all .18s;cursor:pointer;}
        .sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3)}
        /* Admin avatar — amber exception */
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#f59e0b,#f97316);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.8rem;font-weight:600}
        .sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem;margin-top:1px}
        .sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
        .sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1)}

        /* ═══════════ MAIN ═══════════ */
        .main{margin-left:var(--sb-width);flex:1;display:flex;flex-direction:column;min-height:100vh}
        .topbar{display:flex;justify-content:space-between;align-items:center;padding:18px 28px;background:var(--bg-topbar);border-bottom:1px solid var(--border-light);position:sticky;top:0;z-index:50;box-shadow:0 1px 6px rgba(0,0,0,0.06);}
        .topbar-title{font-size:1.2rem;font-weight:800;color:var(--text-h);letter-spacing:-.3px;display:flex;align-items:center;gap:8px}
        .topbar-title i{color:var(--primary-2);font-size:1rem}
        .topbar-sub{color:var(--text-s);font-size:.78rem;margin-top:2px}
        .btn-add{display:inline-flex;align-items:center;gap:8px;padding:9px 20px;background:var(--primary);color:#fff;text-decoration:none;font-size:.82rem;font-weight:700;border-radius:11px;box-shadow:0 3px 10px rgba(79,70,229,0.28);transition:all .2s;}
        .btn-add:hover{background:#4338ca;transform:translateY(-1px);box-shadow:0 6px 20px rgba(79,70,229,0.4)}
        .content{padding:24px 28px;flex:1}

        @keyframes cardIn{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:none}}

        /* Alerts */
        .alert{display:flex;align-items:center;gap:10px;padding:12px 16px;border-radius:12px;margin-bottom:18px;font-size:.84rem;animation:cardIn .4s ease both;}
        .alert i{flex-shrink:0}
        .alert-success{background:#d1fae5;border:1px solid #a7f3d0;color:#065f46}
        .alert-success i{color:var(--green)}
        .alert-error{background:#fee2e2;border:1px solid #fca5a5;color:#991b1b}
        .alert-error i{color:var(--red)}

        /* Filter bar */
        .filter-bar{background:var(--bg-card);border:1px solid var(--border-light);border-radius:14px;padding:14px 16px;margin-bottom:18px;display:flex;gap:10px;align-items:center;flex-wrap:wrap;box-shadow:0 1px 4px rgba(0,0,0,0.04);animation:cardIn .4s .05s ease both;}
        .filter-bar input,.filter-bar select{padding:9px 13px;background:#fff;border:1.5px solid var(--border-light);border-radius:9px;font-size:.82rem;font-family:'Sora',sans-serif;color:var(--text-b);outline:none;transition:all .2s;}
        .filter-bar input{flex:1;min-width:200px;}
        .filter-bar input::placeholder{color:var(--text-s)}
        .filter-bar select option{background:#fff;color:var(--text-b)}
        .filter-bar input:focus,.filter-bar select:focus{border-color:rgba(79,70,229,0.4);background:#faf9ff;box-shadow:0 0 0 3px rgba(79,70,229,0.07);}
        .btn-search{display:inline-flex;align-items:center;gap:7px;padding:9px 18px;background:var(--primary);color:#fff;border:none;border-radius:9px;font-size:.82rem;font-weight:700;font-family:'Sora',sans-serif;cursor:pointer;transition:all .2s;box-shadow:0 3px 8px rgba(79,70,229,0.25);}
        .btn-search:hover{background:#4338ca;transform:translateY(-1px)}
        .btn-reset{display:inline-flex;align-items:center;gap:7px;padding:9px 16px;background:#fff;color:var(--text-m);border:1.5px solid var(--border-light);border-radius:9px;font-size:.82rem;font-weight:600;font-family:'Sora',sans-serif;text-decoration:none;transition:all .2s;}
        .btn-reset:hover{background:#f3f4f6;color:var(--text-b)}

        /* Table */
        .table-wrap{background:var(--bg-card);border:1px solid var(--border-light);border-radius:16px;overflow:hidden;box-shadow:0 1px 6px rgba(0,0,0,0.05);animation:cardIn .5s .1s ease both;}
        table{width:100%;border-collapse:collapse;font-size:.8rem}
        thead tr{background:#fafbff}
        th{padding:11px 16px;text-align:left;color:var(--text-s);font-weight:700;font-size:.67rem;text-transform:uppercase;letter-spacing:.9px;border-bottom:1px solid var(--border-light2);}
        td{padding:12px 16px;border-bottom:1px solid var(--border-light2);vertical-align:middle;color:var(--text-b);}
        tr:last-child td{border-bottom:none}
        tbody tr{transition:background .12s}
        tbody tr:hover td{background:#f7f8ff}

        /* Role badges — light palette */
        .role-badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;}
        .role-ADMIN            {background:var(--primary-light);color:var(--primary-2);border:1px solid rgba(99,102,241,0.25)}
        .role-CUSTOMER         {background:#d1fae5;color:#065f46;border:1px solid #a7f3d0}
        .role-CUSTOMER_SUPPORT {background:#ede9fe;color:var(--purple);border:1px solid rgba(124,58,237,0.2)}
        .role-TECHNICAL_MANAGER{background:#fef3c7;color:var(--amber);border:1px solid #fde68a}
        .role-STOREKEEPER      {background:#e0f2fe;color:var(--info);border:1px solid #bae6fd}
        .role-TECHNICIAN       {background:#cffafe;color:#0e7490;border:1px solid #a5f3fc}

        /* Status badges */
        .status-active  {background:#d1fae5;color:#065f46;border:1px solid #a7f3d0;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;display:inline-flex;align-items:center;gap:5px}
        .status-inactive{background:#fee2e2;color:#991b1b;border:1px solid #fca5a5;padding:3px 9px;border-radius:20px;font-size:.68rem;font-weight:700;display:inline-flex;align-items:center;gap:5px}
        .status-active i,.status-inactive i{font-size:.42rem}

        /* Action buttons */
        .action-btns{display:flex;gap:5px}
        .btn-icon{width:30px;height:30px;border-radius:8px;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:.78rem;text-decoration:none;transition:all .2s;}
        .btn-edit  {background:var(--primary-light);color:var(--primary-2)}
        .btn-delete{background:#fee2e2;color:var(--red)}
        .btn-edit:hover  {background:var(--primary);color:#fff;transform:scale(1.08)}
        .btn-delete:hover{background:var(--red);color:#fff;transform:scale(1.08)}

        /* Pagination */
        .pagination{display:flex;justify-content:center;align-items:center;gap:6px;padding:16px 20px 14px;}
        .pagination a,.pagination span{padding:7px 13px;border-radius:8px;font-size:.8rem;font-weight:600;text-decoration:none;transition:all .2s;}
        .pagination a{background:#fff;border:1.5px solid var(--border-light);color:var(--text-m);}
        .pagination a:hover{background:var(--primary-light);border-color:rgba(99,102,241,0.3);color:var(--primary-2)}
        .pagination .active{background:var(--primary);color:#fff;border:none;box-shadow:0 3px 10px rgba(79,70,229,0.3)}
        .pagination .disabled{color:var(--text-s);font-size:.8rem}
        .total-info{text-align:center;color:var(--text-s);font-size:.75rem;padding-bottom:14px}
    </style>
</head>
<body>

    <!-- ═══════════ SIDEBAR ═══════════ -->
    <aside class="sb">
        <div class="sb-brand">
            <div class="sb-logo"><i class="fas fa-cog"></i></div>
            <div>
                <div class="sb-name">DRSMS</div>
                <div class="sb-role">Admin</div>
            </div>
        </div>
        <nav class="sb-nav">
            <div class="sb-lbl">Overview</div>
            <a href="<%=ctx%>/admin.jsp" class="sb-item">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
            <div class="sb-lbl">Management</div>
            <a href="<%=ctx%>/user/list" class="sb-item on">
                <i class="fas fa-users"></i> Users
            </a>
            <a href="<%=ctx%>/role/list" class="sb-item">
                <i class="fas fa-user-tag"></i> Roles
            </a>
            <a href="<%=ctx%>/admin/finance" class="sb-item">
                <i class="fas fa-chart-line"></i> Finance
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
                    <div class="sb-uname"><%=currentUser.getFullName()%></div>
                    <div class="sb-urole">Administrator</div>
                </div>
            </a>
            <a href="<%=ctx%>/logout" class="sb-logout">
                <i class="fas fa-sign-out-alt"></i> Sign Out
            </a>
        </div>
    </aside>

    <!-- ═══════════ MAIN ═══════════ -->
    <main class="main">

        <div class="topbar">
            <div>
                <div class="topbar-title"><i class="fas fa-users"></i> User Management</div>
                <div class="topbar-sub"><%=total%> total users in the system</div>
            </div>
            <a href="<%=ctx%>/user/create?action=create" class="btn-add">
                <i class="fas fa-plus"></i> Add User
            </a>
        </div>

        <div class="content">

            <%if("created".equals(success)){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> User created successfully!</div>
            <%}%>
            <%if("updated".equals(success)){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Updated successfully!</div>
            <%}%>
            <%if("deleted".equals(success)){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> Deleted successfully!</div>
            <%}%>
            <%if(error != null){%>
            <div class="alert alert-error"><i class="fas fa-triangle-exclamation"></i> An error occurred!</div>
            <%}%>

            <!-- Filter bar -->
            <form method="get" action="<%=ctx%>/user/list">
                <div class="filter-bar">
                    <input type="text" name="keyword" placeholder="Username, email, full name..."
                           value="<%=keyword%>">
                    <select name="status">
                        <option value="">All statuses</option>
                        <option value="1" <%="1".equals(status)?"selected":""%>>Active</option>
                        <option value="0" <%="0".equals(status)?"selected":""%>>Locked</option>
                    </select>
                    <select name="role">
                        <option value="">All roles</option>
                        <%if(roles!=null) for(Role r:roles){%>
                        <option value="<%=r.getName()%>" <%=r.getName().equals(role)?"selected":""%>>
                            <%=r.getName().replace("_"," ")%>
                        </option>
                        <%}%>
                    </select>
                    <button type="submit" class="btn-search"><i class="fas fa-search"></i> Search</button>
                    <a href="<%=ctx%>/user/list" class="btn-reset"><i class="fas fa-rotate"></i> Reset</a>
                </div>
            </form>

            <!-- Table -->
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Username</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%if(users!=null) for(User u:users){%>
                        <tr>
                            <td style="color:var(--primary-2);font-weight:700;font-family:'Courier New',monospace">#<%=u.getId()%></td>
                            <td style="font-weight:600;color:var(--text-h)"><%=u.getUsername()!=null?u.getUsername():"-"%></td>
                            <td><%=u.getFullName()%></td>
                            <td style="font-size:.77rem;color:var(--text-m)"><%=u.getEmail()!=null?u.getEmail():"-"%></td>
                            <td style="color:var(--text-m)"><%=u.getPhone()!=null?u.getPhone():"-"%></td>
                            <td>
                                <span class="role-badge role-<%=u.getRoleName()!=null?u.getRoleName():""%>">
                                    <%=u.getRoleName()!=null?u.getRoleName().replace("_"," "):"-"%>
                                </span>
                            </td>
                            <td>
                                <%if(u.isActive()){%>
                                <span class="status-active"><i class="fas fa-circle"></i> Active</span>
                                <%}else{%>
                                <span class="status-inactive"><i class="fas fa-circle"></i> Locked</span>
                                <%}%>
                            </td>
                            <td>
                                <div class="action-btns">
                                    <a href="<%=ctx%>/user/edit?action=edit&id=<%=u.getId()%>"
                                       class="btn-icon btn-edit" title="Edit">
                                        <i class="fas fa-pen"></i>
                                    </a>
                                    <a href="<%=ctx%>/user/delete?action=delete&id=<%=u.getId()%>"
                                       class="btn-icon btn-delete" title="Delete"
                                       onclick="return confirm('Are you sure you want to delete this user?')">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <%}%>
                    </tbody>
                </table>

                <%if(totalPages>1){%>
                <div class="pagination">
                    <%if(currentPage>1){%>
                    <a href="<%=ctx%>/user/list?page=<%=currentPage-1%>&keyword=<%=kwEnc%>&status=<%=stEnc%>&role=<%=rlEnc%>">‹ Prev</a>
                    <%}else{%><span class="disabled">‹ Prev</span><%}%>

                    <%for(int i=1;i<=totalPages;i++){%>
                    <%if(i==currentPage){%>
                    <span class="active"><%=i%></span>
                    <%}else{%>
                    <a href="<%=ctx%>/user/list?page=<%=i%>&keyword=<%=kwEnc%>&status=<%=stEnc%>&role=<%=rlEnc%>"><%=i%></a>
                    <%}}%>

                    <%if(currentPage<totalPages){%>
                    <a href="<%=ctx%>/user/list?page=<%=currentPage+1%>&keyword=<%=kwEnc%>&status=<%=stEnc%>&role=<%=rlEnc%>">Next ›</a>
                    <%}else{%><span class="disabled">Next ›</span><%}%>
                </div>
                <div class="total-info">Page <%=currentPage%> / <%=totalPages%> · Total: <%=total%> users</div>
                <%}%>
            </div>

        </div>
    </main>

</body>
</html>
