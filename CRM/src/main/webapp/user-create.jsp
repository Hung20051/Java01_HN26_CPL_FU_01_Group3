<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Role, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (request.getAttribute("roles") == null) {
        response.sendRedirect(request.getContextPath() + "/user/create");
        return;
    }
    List<Role> roles = (List<Role>) request.getAttribute("roles");
    String error     = (String) request.getAttribute("error");
    String ctx       = request.getContextPath();
    String initials  = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Create New User — DRSMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --navy:       #0b1437; --navy-card: #111a42;
            --accent:     #4f7ef8; --accent-2: #7c9ffa; --accent-glow: rgba(79,126,248,0.22);
            --green:      #34d399; --green-dim: rgba(52,211,153,0.12);
            --amber:      #fbbf24; --amber-dim: rgba(251,191,36,0.12);
            --danger:     #f87171; --danger-dim: rgba(248,113,113,0.12);
            --purple:     #a78bfa; --info: #38bdf8;
            --text:       #ffffff; --text-2: #c8d4f0; --muted: #7a8ab8;
            --border:     rgba(255,255,255,0.07);
            --sb-width:   248px;
        }
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{scroll-behavior:smooth}
        body{font-family:'Sora',sans-serif;background:var(--navy);color:var(--text);min-height:100vh;display:flex}
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-thumb{background:rgba(79,126,248,0.4);border-radius:4px}

        /* ════ SIDEBAR ════ */
        .sb{width:var(--sb-width);min-height:100vh;background:rgba(9,15,40,.95);backdrop-filter:blur(20px);border-right:1px solid var(--border);display:flex;flex-direction:column;position:fixed;top:0;left:0;z-index:100}
        .sb-brand{padding:22px 18px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--border)}
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,var(--amber),#f97316);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;box-shadow:0 4px 14px rgba(251,191,36,.3);flex-shrink:0}
        .sb-name{color:#fff;font-size:1rem;font-weight:700}
        .sb-badge{display:inline-flex;align-items:center;background:rgba(251,191,36,.15);border:1px solid rgba(251,191,36,.3);color:var(--amber);font-size:.62rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:2px 8px;border-radius:20px;margin-top:3px}
        .sb-nav{flex:1;padding:12px 10px;overflow-y:auto}
        .sb-lbl{color:rgba(255,255,255,.22);font-size:.62rem;font-weight:700;text-transform:uppercase;letter-spacing:1.4px;padding:0 8px;margin:16px 0 5px}
        .sb-item{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:9px;margin-bottom:1px;color:rgba(255,255,255,.45);text-decoration:none;font-size:.83rem;font-weight:500;transition:all .2s;border-left:2px solid transparent}
        .sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.8rem;border-radius:8px;background:rgba(255,255,255,.05);flex-shrink:0;transition:all .2s}
        .sb-item.on{color:#fff;background:linear-gradient(90deg,rgba(79,126,248,.2),rgba(79,126,248,.05));border-left:2px solid var(--accent)}
        .sb-item.on i{background:rgba(79,126,248,.25);color:var(--accent-2)}
        .sb-item:hover{color:#fff;background:rgba(79,126,248,.1);border-left-color:var(--accent)}
        .sb-item:hover i{background:rgba(79,126,248,.2);color:var(--accent-2)}
        .sb-foot{padding:12px 10px 16px;border-top:1px solid var(--border)}
        .sb-user{display:flex;align-items:center;gap:9px;padding:10px;border-radius:10px;background:rgba(255,255,255,.04);border:1px solid var(--border);margin-bottom:6px;text-decoration:none;transition:all .2s}
        .sb-user:hover{background:rgba(251,191,36,.08);border-color:rgba(251,191,36,.2)}
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,var(--amber),#f97316);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.82rem;font-weight:600}
        .sb-urole{color:var(--muted);font-size:.68rem;margin-top:1px}
        .sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:8px;color:rgba(255,255,255,.35);text-decoration:none;font-size:.8rem;transition:all .2s}
        .sb-logout:hover{color:var(--danger);background:rgba(248,113,113,.08)}

        /* ════ MAIN ════ */
        .main{margin-left:var(--sb-width);flex:1;min-height:100vh;display:flex;flex-direction:column}
        .topbar{display:flex;justify-content:space-between;align-items:center;padding:18px 32px;border-bottom:1px solid var(--border);background:rgba(11,20,55,.6);backdrop-filter:blur(16px);position:sticky;top:0;z-index:50}
        .topbar-title{font-size:1.15rem;font-weight:800;color:#fff;letter-spacing:-.3px;display:flex;align-items:center;gap:9px}
        .topbar-title i{color:var(--green);font-size:.95rem}
        .topbar-sub{color:var(--muted);font-size:.78rem;margin-top:2px}
        .btn-back{display:inline-flex;align-items:center;gap:7px;padding:8px 16px;background:rgba(255,255,255,.05);color:var(--text-2);border:1px solid var(--border);text-decoration:none;font-size:.82rem;font-weight:600;border-radius:9px;transition:all .2s}
        .btn-back:hover{background:rgba(79,126,248,.1);border-color:rgba(79,126,248,.3);color:#fff}
        .content{padding:28px 32px 60px;flex:1}

        @keyframes cardIn{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:none}}

        /* ── ALERT ── */
        .alert-error{display:flex;align-items:center;gap:10px;padding:12px 16px;border-radius:11px;margin-bottom:18px;font-size:.84rem;background:var(--danger-dim);border:1px solid rgba(248,113,113,.25);color:var(--danger);animation:cardIn .4s ease both}

        /* ── STEP INDICATOR ── */
        .steps{display:flex;align-items:center;gap:0;margin-bottom:24px;animation:cardIn .3s ease both}
        .step{display:flex;align-items:center;gap:8px;padding:10px 18px;font-size:.8rem;font-weight:600;color:var(--muted);border-bottom:2px solid transparent;cursor:pointer;transition:all .2s;white-space:nowrap}
        .step i{font-size:.75rem}
        .step.active{color:var(--green);border-bottom-color:var(--green)}
        .step.done{color:var(--accent-2);border-bottom-color:var(--accent-2)}
        .step-sep{flex:1;height:1px;background:var(--border)}

        /* ── CARD ── */
        .card{background:rgba(17,26,66,.7);border:1px solid var(--border);border-radius:16px;overflow:hidden;backdrop-filter:blur(12px);margin-bottom:16px;animation:cardIn .45s ease both}
        .card-header{display:flex;align-items:center;gap:10px;padding:14px 22px;border-bottom:1px solid var(--border);font-size:.87rem;font-weight:700;color:#fff}
        .card-header i{color:var(--green)}
        .card-header.blue  i{color:var(--accent-2)}
        .card-header.amber i{color:var(--amber)}
        .card-header.info  i{color:var(--info)}
        .card-header.danger i{color:var(--danger)}
        .card-body{padding:22px}

        /* ── FORM ── */
        .fg-1{display:grid;grid-template-columns:1fr;gap:16px}
        .fg-2{display:grid;grid-template-columns:1fr 1fr;gap:16px}
        .fg-3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px}
        .mt{margin-top:14px}
        .form-group{display:flex;flex-direction:column;gap:6px}
        .form-group label{font-size:.72rem;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;display:flex;align-items:center;gap:6px}
        .form-group label i{font-size:.65rem}
        .required{color:var(--danger)}
        .form-group input,
        .form-group select,
        .form-group textarea{padding:10px 13px;background:rgba(255,255,255,.05);border:1.5px solid var(--border);border-radius:9px;font-size:.875rem;font-family:'Sora',sans-serif;color:var(--text);outline:none;transition:all .2s}
        .form-group textarea{resize:vertical;min-height:80px;line-height:1.6}
        .form-group input::placeholder,.form-group textarea::placeholder{color:var(--muted)}
        .form-group select option{background:var(--navy-card);color:var(--text)}
        .form-group input:focus,.form-group select:focus,.form-group textarea:focus{border-color:rgba(79,126,248,.5);background:rgba(79,126,248,.06);box-shadow:0 0 0 3px rgba(79,126,248,.1)}
        .hint{font-size:.72rem;color:var(--muted);display:flex;align-items:center;gap:5px}

        /* section label */
        .section-lbl{font-size:.68rem;font-weight:700;text-transform:uppercase;letter-spacing:1.2px;color:var(--muted);margin:20px 0 12px;display:flex;align-items:center;gap:8px}
        .section-lbl::after{content:'';flex:1;height:1px;background:var(--border)}
        .section-lbl i{color:var(--accent-2);font-size:.65rem}
        .section-lbl.opt::before{content:'Optional';font-size:.6rem;color:var(--muted);background:rgba(255,255,255,.06);border:1px solid var(--border);border-radius:4px;padding:1px 6px;margin-right:4px;text-transform:uppercase;letter-spacing:.5px}

        /* address preview */
        .addr-bar{display:none;align-items:center;gap:10px;margin-top:10px;padding:11px 14px;background:rgba(56,189,248,.06);border:1px solid rgba(56,189,248,.2);border-radius:10px;font-size:.8rem}
        .addr-bar i{color:var(--info);flex-shrink:0}
        .addr-bar span{color:var(--text-2);flex:1}
        .addr-bar a{color:var(--info);text-decoration:none;font-weight:600;font-size:.75rem;white-space:nowrap}
        .addr-bar a:hover{color:#fff}

        /* password */
        .pass-wrap{position:relative}
        .pass-wrap input{width:100%;padding-right:42px}
        .pass-eye{position:absolute;right:12px;top:50%;transform:translateY(-50%);cursor:pointer;color:var(--muted);background:none;border:none;font-size:.85rem;transition:color .2s}
        .pass-eye:hover{color:var(--accent-2)}

        /* roles */
        .roles-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}
        .role-option{display:flex;align-items:center;gap:9px;padding:10px 13px;border:1.5px solid var(--border);border-radius:10px;cursor:pointer;font-size:.8rem;color:var(--text-2);background:rgba(255,255,255,.03);transition:all .2s}
        .role-option:hover{border-color:rgba(79,126,248,.35);background:rgba(79,126,248,.08);color:var(--text)}
        .role-option input[type="radio"]{accent-color:var(--accent);width:14px;height:14px;flex-shrink:0}

        /* form actions */
        .form-actions{display:flex;justify-content:flex-end;gap:9px;margin-top:22px;padding-top:18px;border-top:1px solid var(--border)}
        .btn{display:inline-flex;align-items:center;gap:8px;padding:10px 22px;border-radius:10px;font-size:.875rem;font-weight:700;font-family:'Sora',sans-serif;border:none;cursor:pointer;text-decoration:none;transition:all .2s}
        .btn-cancel{background:rgba(255,255,255,.04);color:var(--muted);border:1.5px solid var(--border)}
        .btn-cancel:hover{background:rgba(255,255,255,.07);color:var(--text-2)}
        .btn-submit{background:linear-gradient(135deg,var(--green),#059669);color:#fff;box-shadow:0 4px 14px rgba(52,211,153,.25)}
        .btn-submit:hover{transform:translateY(-1px);box-shadow:0 6px 20px rgba(52,211,153,.4)}

        /* optional badge on card header */
        .opt-badge{font-size:.62rem;font-weight:600;background:rgba(255,255,255,.07);border:1px solid var(--border);color:var(--muted);padding:2px 8px;border-radius:6px;margin-left:auto;text-transform:uppercase;letter-spacing:.5px}
    </style>
</head>
<body>

<%-- ═══ SIDEBAR ═══ --%>
<aside class="sb">
    <div class="sb-brand">
        <div class="sb-logo"><i class="fas fa-cog"></i></div>
        <div><div class="sb-name">DRSMS</div><div class="sb-badge">Admin</div></div>
    </div>
    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div>
        <a href="<%=ctx%>/admin.jsp" class="sb-item"><i class="fas fa-tachometer-alt"></i> Dashboard</a>
        <div class="sb-lbl">Management</div>
        <a href="<%=ctx%>/user/list" class="sb-item on"><i class="fas fa-users"></i> Users</a>
        <a href="<%=ctx%>/role/list" class="sb-item"><i class="fas fa-user-tag"></i> Roles</a>
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
        <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
    </div>
</aside>

<%-- ═══ MAIN ═══ --%>
<main class="main">

    <div class="topbar">
        <div>
            <div class="topbar-title"><i class="fas fa-user-plus"></i> Create New User</div>
            <div class="topbar-sub">Fill in the details to add a new system account</div>
        </div>
        <a href="<%=ctx%>/user/list" class="btn-back"><i class="fas fa-arrow-left"></i> Back</a>
    </div>

    <div class="content">

        <%if(error!=null){%>
        <div class="alert-error"><i class="fas fa-triangle-exclamation"></i> <%=error%></div>
        <%}%>

        <form method="post" action="<%=ctx%>/user/create">
            <input type="hidden" name="action" value="create">

            <%-- ══ CARD 1: Account (required) ══ --%>
            <div class="card">
                <div class="card-header">
                    <i class="fas fa-user-plus"></i> Account Information
                    <span style="margin-left:auto;font-size:.7rem;color:var(--muted);font-weight:400">* Required fields</span>
                </div>
                <div class="card-body">
                    <div class="fg-2">
                        <div class="form-group">
                            <label><i class="fas fa-user"></i> Username <span class="required">*</span></label>
                            <input type="text" name="username" required placeholder="Enter username">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-id-card"></i> Full Name</label>
                            <input type="text" name="fullName" placeholder="Enter full name">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-envelope"></i> Email <span class="required">*</span></label>
                            <input type="email" name="email" required placeholder="Enter email">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-phone"></i> Phone Number</label>
                            <input type="tel" name="phone" placeholder="e.g. 0901 234 567">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-lock"></i> Password <span class="required">*</span></label>
                            <div class="pass-wrap">
                                <input type="password" name="password" id="pass1" required placeholder="Enter password">
                                <button type="button" class="pass-eye" onclick="togglePass('pass1',this)"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-lock"></i> Confirm Password <span class="required">*</span></label>
                            <div class="pass-wrap">
                                <input type="password" name="confirmPassword" id="pass2" required placeholder="Re-enter password" oninput="checkMatch()">
                                <button type="button" class="pass-eye" onclick="togglePass('pass2',this)"><i class="fas fa-eye"></i></button>
                            </div>
                            <span class="hint" id="matchHint"></span>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-toggle-on"></i> Status</label>
                            <select name="active">
                                <option value="1">Active</option>
                                <option value="0">Inactive (cannot log in)</option>
                            </select>
                        </div>
                    </div>

                    <div class="section-lbl"><i class="fas fa-user-tag"></i> Role Assignment</div>
                    <div class="roles-grid">
                        <%if(roles!=null) for(Role r:roles){%>
                        <label class="role-option">
                            <input type="radio" name="roleId" value="<%=r.getId()%>"
                                   <%=r.getName().equals("CUSTOMER")?"checked":""%>>
                            <%=r.getName().replace("_"," ")%>
                        </label>
                        <%}%>
                    </div>
                </div>
            </div>

            <%-- ══ CARD 2: Address (optional) ══ --%>
            <div class="card">
                <div class="card-header info">
                    <i class="fas fa-location-dot"></i> Service Address
                    <span class="opt-badge">Optional</span>
                </div>
                <div class="card-body">
                    <span class="hint" style="margin-bottom:14px;display:flex">
                        <i class="fas fa-circle-info"></i>
                        Used by technicians for navigation to the customer's site.
                    </span>
                    <div class="fg-1">
                        <div class="form-group">
                            <label><i class="fas fa-road"></i> Street / House Number</label>
                            <input type="text" name="addressStreet" id="addrStreet"
                                   placeholder="e.g. 12 Nguyen Trai" oninput="previewAddr()">
                        </div>
                    </div>
                    <div class="fg-3 mt">
                        <div class="form-group">
                            <label><i class="fas fa-map"></i> Ward / Commune</label>
                            <input type="text" name="addressWard" id="addrWard"
                                   placeholder="e.g. Thuong Dinh Ward" oninput="previewAddr()">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-map"></i> District</label>
                            <input type="text" name="addressDistrict" id="addrDistrict"
                                   placeholder="e.g. Thanh Xuan" oninput="previewAddr()">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-city"></i> City / Province</label>
                            <input type="text" name="addressCity" id="addrCity"
                                   placeholder="e.g. Ha Noi" oninput="previewAddr()">
                        </div>
                    </div>
                    <div class="addr-bar" id="addrBar">
                        <i class="fas fa-location-dot"></i>
                        <span id="addrText"></span>
                        <a id="addrLink" href="#" target="_blank"><i class="fab fa-google"></i> Google Maps</a>
                    </div>
                </div>
            </div>

            <%-- ══ CARD 3: Personal Details (optional) ══ --%>
            <div class="card">
                <div class="card-header blue">
                    <i class="fas fa-user"></i> Personal Details
                    <span class="opt-badge">Optional</span>
                </div>
                <div class="card-body">
                    <div class="fg-3">
                        <div class="form-group">
                            <label><i class="fas fa-cake-candles"></i> Date of Birth</label>
                            <input type="date" name="dateOfBirth"
                                   max="<%=java.time.LocalDate.now().toString()%>">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-venus-mars"></i> Gender</label>
                            <select name="gender">
                                <option value="">— Select —</option>
                                <option value="MALE">Male</option>
                                <option value="FEMALE">Female</option>
                                <option value="OTHER">Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-map-pin"></i> Hometown</label>
                            <input type="text" name="hometown" placeholder="e.g. Nam Dinh">
                        </div>
                    </div>
                    <div class="fg-2 mt">
                        <div class="form-group">
                            <label><i class="fas fa-id-badge"></i> National ID (CCCD)</label>
                            <input type="text" name="nationalId" placeholder="12-digit ID number" maxlength="20">
                            <span class="hint"><i class="fas fa-lock"></i> Confidential — internal use only</span>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-building"></i> Company / Organization</label>
                            <input type="text" name="companyName" placeholder="Company name (if applicable)">
                        </div>
                    </div>
                    <div class="fg-1 mt">
                        <div class="form-group">
                            <label><i class="fas fa-quote-left"></i> Bio / Notes</label>
                            <textarea name="bio" placeholder="Short description, role in facility, equipment managed..."></textarea>
                        </div>
                    </div>
                </div>
            </div>

            <%-- ══ CARD 4: Emergency Contact (optional) ══ --%>
            <div class="card">
                <div class="card-header danger">
                    <i class="fas fa-phone-volume"></i> Emergency Contact
                    <span class="opt-badge">Optional</span>
                </div>
                <div class="card-body">
                    <span class="hint" style="margin-bottom:14px;display:flex">
                        <i class="fas fa-circle-info"></i>
                        Used when technician cannot reach the user directly on-site.
                    </span>
                    <div class="fg-3">
                        <div class="form-group">
                            <label><i class="fas fa-user"></i> Contact Name</label>
                            <input type="text" name="emergencyName" placeholder="e.g. Nguyen Van A">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-phone"></i> Phone Number</label>
                            <input type="tel" name="emergencyPhone" placeholder="e.g. 0912 345 678">
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-people-arrows"></i> Relationship</label>
                            <select name="emergencyRelation">
                                <option value="">— Select —</option>
                                <option value="Spouse">Spouse</option>
                                <option value="Parent">Parent</option>
                                <option value="Child">Child</option>
                                <option value="Sibling">Sibling</option>
                                <option value="Friend">Friend</option>
                                <option value="Colleague">Colleague</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <%-- ══ FORM ACTIONS ══ --%>
            <div class="form-actions">
                <a href="<%=ctx%>/user/list" class="btn btn-cancel"><i class="fas fa-xmark"></i> Cancel</a>
                <button type="submit" class="btn btn-submit"><i class="fas fa-user-plus"></i> Create User</button>
            </div>

        </form>
    </div>
</main>

<script>
/* ── PASSWORD TOGGLE ── */
function togglePass(id, btn) {
    const inp = document.getElementById(id);
    inp.type = inp.type === 'password' ? 'text' : 'password';
    btn.innerHTML = inp.type === 'text'
        ? '<i class="fas fa-eye-slash"></i>'
        : '<i class="fas fa-eye"></i>';
}

/* ── PASSWORD MATCH ── */
function checkMatch() {
    const nv = document.getElementById('pass1').value;
    const cv = document.getElementById('pass2').value;
    const hint = document.getElementById('matchHint');
    if (!cv) { hint.textContent = ''; return; }
    hint.innerHTML = nv === cv
        ? '<span style="color:var(--green)"><i class="fas fa-check"></i> Passwords match</span>'
        : '<span style="color:var(--danger)"><i class="fas fa-times"></i> Passwords do not match</span>';
}

/* ── ADDRESS PREVIEW ── */
function previewAddr() {
    const s = (document.getElementById('addrStreet')?.value   || '').trim();
    const w = (document.getElementById('addrWard')?.value     || '').trim();
    const d = (document.getElementById('addrDistrict')?.value || '').trim();
    const c = (document.getElementById('addrCity')?.value     || '').trim();
    const parts = [s,w,d,c].filter(Boolean);
    const bar = document.getElementById('addrBar');
    if (parts.length >= 2) {
        const full = parts.join(', ');
        document.getElementById('addrText').textContent = full;
        document.getElementById('addrLink').href = 'https://www.google.com/maps/search/' + encodeURIComponent(full);
        bar.style.display = 'flex';
    } else {
        bar.style.display = 'none';
    }
}
</script>
</body>
</html>
