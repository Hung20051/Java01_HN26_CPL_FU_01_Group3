<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.EquipmentType, model.EquipmentUnit, model.Category, java.util.*, java.text.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    EquipmentType et  = (EquipmentType) request.getAttribute("equipment");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<EquipmentUnit> units = (List<EquipmentUnit>) request.getAttribute("units");
    if (et == null) { response.sendRedirect(request.getContextPath() + "/numberEquipment"); return; }
    if (categories == null) categories = new ArrayList<>();
    if (units == null)      units      = new ArrayList<>();

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    String flashError   = (String) session.getAttribute("flashError");
    session.removeAttribute("flashSuccess");
    session.removeAttribute("flashError");

    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
    String ctx = request.getContextPath();
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";

    String imgSrc = (et.getImageUrl() != null && !et.getImageUrl().isEmpty())
        ? (et.getImageUrl().startsWith("http") ? et.getImageUrl() : ctx + et.getImageUrl())
        : null;

    boolean lowStock = et.getAvailableUnits() > 0 && et.getAvailableUnits() <= 2;
    boolean outStock = et.getAvailableUnits() == 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%=et.getModel()%> — DRSMS Storekeeper</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --navy:#0b1437; --navy-2:#0f1c4d; --navy-card:#111a42;
            --accent:#4f7ef8; --accent-2:#7c9ffa;
            --green:#34d399; --green-dim:rgba(52,211,153,0.12);
            --amber:#fbbf24; --amber-dim:rgba(251,191,36,0.12);
            --danger:#f87171; --danger-dim:rgba(248,113,113,0.12);
            --purple:#a78bfa; --purple-dim:rgba(167,139,250,0.12);
            --info:#38bdf8; --info-dim:rgba(56,189,248,0.12);
            --text:#ffffff; --text-2:#c8d4f0; --muted:#7a8ab8;
            --border:rgba(255,255,255,0.07); --sb-width:248px;
        }
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Sora',sans-serif;background:var(--navy);color:var(--text);min-height:100vh;display:flex}
        ::-webkit-scrollbar{width:4px}::-webkit-scrollbar-track{background:var(--navy)}
        ::-webkit-scrollbar-thumb{background:rgba(79,126,248,0.4);border-radius:4px}

        /* SIDEBAR */
        .sb{width:var(--sb-width);min-height:100vh;background:rgba(9,15,40,0.95);backdrop-filter:blur(20px);border-right:1px solid var(--border);display:flex;flex-direction:column;position:fixed;top:0;left:0;z-index:100}
        .sb-brand{padding:22px 18px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--border)}
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,var(--green),var(--info));border-radius:10px;display:flex;align-items:center;justify-content:center;color:var(--navy);font-size:.88rem;box-shadow:0 4px 14px rgba(52,211,153,0.3);flex-shrink:0}
        .sb-name{color:#fff;font-size:1rem;font-weight:700}
        .sb-role{display:inline-flex;background:rgba(52,211,153,0.12);border:1px solid rgba(52,211,153,0.25);color:var(--green);font-size:.62rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:2px 8px;border-radius:20px;margin-top:3px}
        .sb-nav{flex:1;padding:12px 10px;overflow-y:auto}
        .sb-lbl{color:rgba(255,255,255,0.22);font-size:.62rem;font-weight:700;text-transform:uppercase;letter-spacing:1.4px;padding:0 8px;margin:16px 0 5px}
        .sb-item{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:9px;margin-bottom:1px;color:rgba(255,255,255,0.45);text-decoration:none;font-size:.83rem;font-weight:500;transition:all .2s;border-left:2px solid transparent}
        .sb-item i{width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-size:.8rem;border-radius:8px;background:rgba(255,255,255,0.05);flex-shrink:0;transition:all .2s}
        .sb-item.on{color:#fff;background:linear-gradient(90deg,rgba(56,189,248,0.15),rgba(56,189,248,0.04));border-left:2px solid var(--info)}
        .sb-item.on i{background:rgba(56,189,248,0.2);color:var(--info)}
        .sb-item:hover{color:#fff;background:rgba(79,126,248,0.08);border-left-color:var(--accent)}
        .sb-item:hover i{background:rgba(79,126,248,0.18);color:var(--accent-2)}
        .sb-foot{padding:12px 10px 16px;border-top:1px solid var(--border)}
        .sb-user{display:flex;align-items:center;gap:9px;padding:10px;border-radius:10px;background:rgba(255,255,255,0.04);border:1px solid var(--border);margin-bottom:6px;text-decoration:none;transition:all .2s}
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,var(--green),var(--info));display:flex;align-items:center;justify-content:center;color:var(--navy);font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.82rem;font-weight:600}
        .sb-urole{color:var(--muted);font-size:.68rem;margin-top:1px}
        .sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:8px;color:rgba(255,255,255,0.35);text-decoration:none;font-size:.8rem;transition:all .2s}
        .sb-logout:hover{color:var(--danger);background:rgba(248,113,113,0.08)}

        /* MAIN */
        .main{margin-left:var(--sb-width);flex:1;min-height:100vh;display:flex;flex-direction:column}
        .topbar{display:flex;justify-content:space-between;align-items:center;padding:18px 32px;border-bottom:1px solid var(--border);background:rgba(11,20,55,0.6);backdrop-filter:blur(16px);position:sticky;top:0;z-index:50}
        .breadcrumb{display:flex;align-items:center;gap:7px;font-size:.78rem;color:var(--muted)}
        .breadcrumb a{color:var(--muted);text-decoration:none;transition:color .2s}
        .breadcrumb a:hover{color:var(--accent-2)}
        .bc-sep{color:rgba(255,255,255,0.18)}
        .bc-cur{color:var(--text-2);font-weight:600}
        .content{padding:28px 32px;flex:1}

        @keyframes cardIn{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:translateY(0)}}

        .alert{display:flex;align-items:center;gap:12px;padding:13px 18px;border-radius:12px;margin-bottom:18px;font-size:.84rem;animation:cardIn .4s ease both}
        .alert-success{background:var(--green-dim);border:1px solid rgba(52,211,153,0.25);color:var(--green)}
        .alert-error{background:var(--danger-dim);border:1px solid rgba(248,113,113,0.25);color:var(--danger)}

        /* BUTTONS */
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 18px;border-radius:10px;border:none;font-size:.82rem;font-weight:600;font-family:inherit;cursor:pointer;text-decoration:none;transition:all .2s;white-space:nowrap}
        .btn-back{background:rgba(255,255,255,0.05);color:var(--text-2);border:1px solid var(--border)}
        .btn-back:hover{background:rgba(255,255,255,0.1);color:#fff}
        .btn-edit{background:var(--amber-dim);color:var(--amber);border:1px solid rgba(251,191,36,0.3)}
        .btn-edit:hover{background:rgba(251,191,36,0.2)}
        .btn-delete{background:var(--danger-dim);color:var(--danger);border:1px solid rgba(248,113,113,0.3)}
        .btn-delete:hover{background:rgba(248,113,113,0.2)}
        .btn-import{background:linear-gradient(135deg,var(--green),#059669);color:#fff;box-shadow:0 4px 14px rgba(52,211,153,0.3)}
        .btn-import:hover{transform:translateY(-1px);box-shadow:0 6px 20px rgba(52,211,153,0.4)}
        .btn-reduce{background:var(--amber-dim);color:var(--amber);border:1px solid rgba(251,191,36,0.3)}
        .btn-reduce:hover{background:rgba(251,191,36,0.2)}

        /* TOP GRID */
        .detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:24px;margin-bottom:24px}

        /* Image panel */
        .img-panel{background:rgba(17,26,66,0.7);border:1px solid var(--border);border-radius:20px;overflow:hidden;backdrop-filter:blur(12px);animation:cardIn .5s ease both}
        .img-main{height:320px;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,rgba(17,26,66,0.9),rgba(11,20,55,0.9));position:relative;overflow:hidden}
        .img-main::before{content:'';position:absolute;inset:0;background:radial-gradient(circle at 50% 30%,rgba(56,189,248,0.06),transparent 70%)}
        .img-main img{max-width:88%;max-height:88%;object-fit:contain;filter:drop-shadow(0 8px 24px rgba(0,0,0,0.4));position:relative;z-index:1;transition:transform .4s}
        .img-main:hover img{transform:scale(1.05)}
        .img-placeholder{font-size:5rem;color:rgba(255,255,255,0.06);position:relative;z-index:1}
        .img-badge-wrap{position:absolute;top:14px;left:14px;z-index:2;display:flex;gap:7px}
        .img-badge{padding:5px 12px;border-radius:20px;font-size:.68rem;font-weight:700;letter-spacing:.5px;text-transform:uppercase;backdrop-filter:blur(10px)}
        .badge-eq{background:rgba(56,189,248,0.18);border:1px solid rgba(56,189,248,0.35);color:var(--info)}
        .badge-low{background:rgba(251,191,36,0.18);border:1px solid rgba(251,191,36,0.35);color:var(--amber)}
        .badge-out{background:rgba(248,113,113,0.18);border:1px solid rgba(248,113,113,0.35);color:var(--danger)}

        /* Info panel */
        .info-panel{display:flex;flex-direction:column;gap:16px;animation:cardIn .5s .08s ease both}
        .info-card{background:rgba(17,26,66,0.7);border:1px solid var(--border);border-radius:18px;padding:22px 24px;backdrop-filter:blur(12px)}
        .cat-badge{display:inline-flex;align-items:center;gap:6px;padding:4px 12px;border-radius:20px;font-size:.68rem;font-weight:700;letter-spacing:.8px;text-transform:uppercase;margin-bottom:10px;background:rgba(56,189,248,0.1);border:1px solid rgba(56,189,248,0.25);color:var(--info)}
        .part-name{font-size:1.5rem;font-weight:800;color:#fff;letter-spacing:-.4px;margin-bottom:8px;line-height:1.2}
        .part-desc{font-size:.85rem;color:var(--text-2);line-height:1.7;font-weight:300;margin-bottom:16px}
        .price-box{display:flex;align-items:flex-end;gap:10px;margin-bottom:14px}
        .price-main{font-size:1.9rem;font-weight:800;color:var(--amber);letter-spacing:-.5px}
        .price-label{font-size:.72rem;color:var(--muted);margin-bottom:6px}

        /* Stock row */
        .stock-row{display:flex;align-items:center;gap:10px;padding:10px 14px;border-radius:11px;margin-bottom:16px}
        .stock-dot{width:9px;height:9px;border-radius:50%;flex-shrink:0;animation:pulse 2s ease-in-out infinite}
        @keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.6;transform:scale(1.3)}}
        .stock-label{font-size:.83rem;font-weight:700}
        .stock-qty{font-size:.77rem;color:var(--muted);margin-left:auto}
        .action-row{display:flex;gap:8px;flex-wrap:wrap}

        /* Trust grid */
        .trust-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
        .trust-item{display:flex;align-items:center;gap:9px}
        .trust-icon{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.8rem;flex-shrink:0}
        .trust-label{font-size:.74rem;font-weight:700;color:var(--text-2)}
        .trust-sub{font-size:.67rem;color:var(--muted)}

        /* BOTTOM GRID */
        .bottom-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:18px;animation:cardIn .5s .16s ease both}
        .detail-card{background:rgba(17,26,66,0.7);border:1px solid var(--border);border-radius:16px;padding:20px;backdrop-filter:blur(12px)}
        .detail-card-hd{display:flex;align-items:center;gap:9px;margin-bottom:16px;padding-bottom:12px;border-bottom:1px solid var(--border)}
        .dc-icon{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.82rem;flex-shrink:0}
        .dc-title{font-size:.82rem;font-weight:700;color:var(--text-2)}
        .spec-row{display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid rgba(255,255,255,0.04)}
        .spec-row:last-child{border-bottom:none}
        .spec-key{font-size:.75rem;color:var(--muted);font-weight:500}
        .spec-val{font-size:.78rem;color:var(--text-2);font-weight:600;text-align:right}
        .spec-val.mono{font-family:'Courier New',monospace;color:var(--accent-2)}

        /* Units table */
        .units-table-wrap{max-height:280px;overflow-y:auto}
        .units-table-wrap::-webkit-scrollbar{width:3px}
        .units-table-wrap::-webkit-scrollbar-thumb{background:rgba(79,126,248,0.3);border-radius:3px}
        table{width:100%;border-collapse:collapse;font-size:.78rem}
        th{padding:8px 10px;text-align:left;color:var(--muted);font-size:.65rem;text-transform:uppercase;letter-spacing:.8px;font-weight:600;border-bottom:1px solid var(--border)}
        td{padding:8px 10px;border-bottom:1px solid rgba(255,255,255,0.03);color:var(--text-2);vertical-align:middle}
        tr:last-child td{border-bottom:none}
        tbody tr:hover td{background:rgba(79,126,248,0.04)}
        .status-badge{display:inline-flex;align-items:center;gap:4px;padding:3px 8px;border-radius:6px;font-size:.68rem;font-weight:700}
        .s-available{background:var(--green-dim);color:var(--green);border:1px solid rgba(52,211,153,0.2)}
        .s-inuse{background:var(--info-dim);color:var(--info);border:1px solid rgba(56,189,248,0.2)}
        .s-faulty{background:var(--amber-dim);color:var(--amber);border:1px solid rgba(251,191,36,0.2)}
        .s-retired{background:rgba(255,255,255,0.04);color:var(--muted);border:1px solid var(--border)}

        /* MODAL */
        .modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.65);backdrop-filter:blur(6px);z-index:1000;align-items:center;justify-content:center}
        .modal-overlay.show{display:flex}
        .modal{background:var(--navy-card);border:1px solid var(--border);border-radius:16px;padding:28px;width:480px;max-width:95vw;max-height:90vh;overflow-y:auto;box-shadow:0 24px 80px rgba(0,0,0,0.5);animation:cardIn .25s ease}
        .modal::-webkit-scrollbar{width:3px}
        .modal::-webkit-scrollbar-thumb{background:rgba(79,126,248,0.3);border-radius:3px}
        .modal-icon{width:52px;height:52px;border-radius:14px;margin:0 auto 16px;display:flex;align-items:center;justify-content:center;font-size:1.4rem}
        .modal-icon.amber{background:var(--amber-dim);color:var(--amber)}
        .modal-icon.green{background:var(--green-dim);color:var(--green)}
        .modal-icon.danger{background:var(--danger-dim);color:var(--danger)}
        .modal h3{font-size:1rem;font-weight:800;color:#fff;text-align:center;margin-bottom:20px}
        .modal p{color:var(--text-2);font-size:.83rem;text-align:center;line-height:1.6;margin-bottom:20px}
        .modal p strong{color:#fff}
        .form-group{margin-bottom:14px}
        .form-group label{display:block;font-size:.75rem;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.8px;margin-bottom:6px}
        .form-group input,.form-group select{width:100%;padding:9px 13px;background:rgba(255,255,255,0.04);border:1px solid var(--border);border-radius:9px;color:var(--text);font-size:.83rem;font-family:inherit;outline:none;transition:border-color .2s}
        .form-group input:focus,.form-group select:focus{border-color:rgba(79,126,248,0.5);background:rgba(79,126,248,0.05)}
        .form-group select option{background:#0f1c4d}
        .modal-btns{display:flex;gap:10px;margin-top:20px}
        .mbtn{flex:1;padding:10px;border-radius:10px;border:none;font-size:.88rem;font-weight:700;font-family:inherit;cursor:pointer;transition:all .2s}
        .mbtn-save{background:linear-gradient(135deg,var(--green),#059669);color:#fff}
        .mbtn-save:hover{opacity:.9;transform:translateY(-1px)}
        .mbtn-amber{background:var(--amber-dim);color:var(--amber);border:1px solid rgba(251,191,36,0.3)}
        .mbtn-amber:hover{background:rgba(251,191,36,0.2)}
        .mbtn-del{background:var(--danger-dim);color:var(--danger);border:1px solid rgba(248,113,113,0.3)}
        .mbtn-del:hover{background:rgba(248,113,113,0.2)}
        .mbtn-cancel{background:rgba(255,255,255,0.06);color:var(--muted);border:1px solid var(--border)}
        .mbtn-cancel:hover{background:rgba(255,255,255,0.1);color:var(--text)}

        /* IMAGE SECTION (modal) */
        .img-section{border:1px solid var(--border);border-radius:12px;overflow:hidden;margin-bottom:14px}
        .img-tabs{display:flex;border-bottom:1px solid var(--border)}
        .img-tab{flex:1;padding:9px;border:none;cursor:pointer;background:transparent;color:var(--muted);font-size:.76rem;font-weight:600;font-family:inherit;transition:all .2s;display:flex;align-items:center;justify-content:center;gap:6px}
        .img-tab.active{background:rgba(79,126,248,0.1);color:var(--accent-2);border-bottom:2px solid var(--accent)}
        .img-tab-content{padding:14px;display:none}
        .img-tab-content.active{display:block}
        .drop-zone{border:2px dashed rgba(79,126,248,0.3);border-radius:10px;padding:18px 14px;text-align:center;cursor:pointer;transition:all .2s;position:relative}
        .drop-zone:hover,.drop-zone.drag-over{border-color:var(--accent);background:rgba(79,126,248,0.06)}
        .drop-zone input[type="file"]{position:absolute;inset:0;opacity:0;cursor:pointer;width:100%;height:100%}
        .drop-zone-icon{font-size:1.6rem;margin-bottom:6px;color:rgba(79,126,248,0.5)}
        .drop-zone-text{font-size:.76rem;color:var(--muted)}
        .drop-zone-text strong{color:var(--accent-2)}
        .img-preview-wrap{margin-top:10px;display:none;border-radius:10px;overflow:hidden;border:1px solid var(--border);position:relative}
        .img-preview-wrap.show{display:block}
        .img-preview-wrap img{width:100%;max-height:140px;object-fit:contain;display:block}
        .img-preview-remove{position:absolute;top:6px;right:6px;background:rgba(248,113,113,0.85);border:none;border-radius:6px;color:#fff;width:26px;height:26px;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:.7rem}
        .url-input-wrap{position:relative}
        .url-input-wrap input{padding-right:88px}
        .btn-load-url{position:absolute;right:6px;top:50%;transform:translateY(-50%);padding:5px 10px;border-radius:7px;border:none;background:rgba(79,126,248,0.2);color:var(--accent-2);font-size:.72rem;font-weight:700;font-family:inherit;cursor:pointer;transition:all .2s}
        .current-img-badge{display:flex;align-items:center;gap:8px;padding:8px 10px;border-radius:8px;background:rgba(52,211,153,0.06);border:1px solid rgba(52,211,153,0.2);margin-bottom:10px}
        .current-img-badge img{width:36px;height:36px;border-radius:6px;object-fit:cover;border:1px solid var(--border)}
        .cib-label{font-size:.65rem;color:var(--green);font-weight:700;text-transform:uppercase;letter-spacing:.8px}
        .cib-url{font-size:.7rem;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .btn-clear-img{padding:4px 10px;border-radius:6px;border:1px solid rgba(248,113,113,0.2);background:var(--danger-dim);color:var(--danger);font-size:.7rem;font-weight:700;font-family:inherit;cursor:pointer;white-space:nowrap;transition:all .2s;margin-left:auto;flex-shrink:0}

        /* Reduce row */
        .reduce-row{display:flex;align-items:center;gap:10px;padding:12px 14px;border-radius:11px;background:rgba(251,191,36,0.06);border:1px solid rgba(251,191,36,0.15);margin-bottom:6px}
        .reduce-note{font-size:.72rem;color:var(--muted);margin-top:6px}
    </style>
</head>
<body>

<!-- SIDEBAR -->
<aside class="sb">
    <div class="sb-brand">
        <div class="sb-logo"><i class="fas fa-warehouse"></i></div>
        <div><div class="sb-name">DRSMS</div><div class="sb-role">Storekeeper</div></div>
    </div>
    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div>
        <a href="<%=ctx%>/dashboard.jsp" class="sb-item"><i class="fas fa-home"></i> Home</a>
        <a href="<%=ctx%>/storekeeper"   class="sb-item"><i class="fas fa-chart-bar"></i> Statistics</a>
        <div class="sb-lbl">Inventory</div>
        <a href="<%=ctx%>/numberPart"      class="sb-item"><i class="fas fa-puzzle-piece"></i> Parts List</a>
        <a href="<%=ctx%>/numberEquipment" class="sb-item on"><i class="fas fa-desktop"></i> Equipment List</a>
        <div class="sb-lbl">Records</div>
        <a href="<%=ctx%>/transactions" class="sb-item"><i class="fas fa-history"></i> Transaction History</a>
    </nav>
    <div class="sb-foot">
        <a href="<%=ctx%>/profile" class="sb-user">
            <div class="sb-ava">
                <%if(currentUser.getAvatarUrl()!=null&&!currentUser.getAvatarUrl().isEmpty()){%>
                <img src="<%=ctx%><%=currentUser.getAvatarUrl()%>" alt="avatar">
                <%}else{%><%=initials%><%}%>
            </div>
            <div>
                <div class="sb-uname"><%=currentUser.getFullName()!=null?currentUser.getFullName():currentUser.getUsername()%></div>
                <div class="sb-urole">Storekeeper</div>
            </div>
        </a>
        <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
    </div>
</aside>

<!-- MAIN -->
<main class="main">
    <div class="topbar">
        <div class="breadcrumb">
            <a href="<%=ctx%>/numberEquipment"><i class="fas fa-desktop"></i> Equipment List</a>
            <span class="bc-sep">›</span>
            <span class="bc-cur"><%=et.getModel()%></span>
        </div>
        <div style="display:flex;gap:8px">
            <a href="<%=ctx%>/numberEquipment" class="btn btn-back"><i class="fas fa-arrow-left"></i> Back</a>
            <button class="btn btn-edit"   onclick="openEditModal()"><i class="fas fa-pen"></i> Edit</button>
            <button class="btn btn-delete" onclick="openDeleteModal()"><i class="fas fa-trash"></i> Delete</button>
        </div>
    </div>

    <div class="content">
        <%if(flashSuccess!=null){%>
        <div class="alert alert-success"><i class="fas fa-circle-check"></i> <%=flashSuccess%></div>
        <%}%>
        <%if(flashError!=null){%>
        <div class="alert alert-error"><i class="fas fa-circle-exclamation"></i> <%=flashError%></div>
        <%}%>

        <!-- TOP ROW -->
        <div class="detail-grid">

            <!-- Image panel -->
            <div class="img-panel">
                <div class="img-main">
                    <div class="img-badge-wrap">
                        <span class="img-badge badge-eq"><i class="fas fa-desktop"></i> Equipment</span>
                        <%if(outStock){%><span class="img-badge badge-out">Out of Stock</span>
                        <%}else if(lowStock){%><span class="img-badge badge-low">Low Stock</span><%}%>
                    </div>
                    <%if(imgSrc!=null){%>
                    <img src="<%=imgSrc%>" alt="<%=et.getModel()%>"
                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                    <div class="img-placeholder" style="display:none"><i class="fas fa-desktop"></i></div>
                    <%}else{%>
                    <div class="img-placeholder"><i class="fas fa-desktop"></i></div>
                    <%}%>
                </div>
            </div>

            <!-- Info panel -->
            <div class="info-panel">
                <div class="info-card">
                    <div class="cat-badge"><i class="fas fa-tag"></i> <%=et.getCategoryName()%></div>
                    <div class="part-name"><%=et.getModel()%></div>
                    <div class="part-desc"><%=et.getDescription()!=null&&!et.getDescription().isEmpty()?et.getDescription():"No description."%></div>

                    <div class="price-box">
                        <div class="price-main"><%=nf.format((long)et.getUnitPrice())%> ₫</div>
                        <div class="price-label">/ unit · VAT included</div>
                    </div>

                    <div class="stock-row" style="background:<%=outStock?"var(--danger-dim)":lowStock?"var(--amber-dim)":"var(--green-dim)"%>;border:1px solid <%=outStock?"rgba(248,113,113,0.2)":lowStock?"rgba(251,191,36,0.2)":"rgba(52,211,153,0.2)"%>">
                        <div class="stock-dot" style="background:<%=outStock?"var(--danger)":lowStock?"var(--amber)":"var(--green)"%>"></div>
                        <span class="stock-label" style="color:<%=outStock?"var(--danger)":lowStock?"var(--amber)":"var(--green)"%>">
                            <i class="fas fa-<%=outStock?"times-circle":lowStock?"exclamation-triangle":"check-circle"%>" style="margin-right:4px"></i>
                            <%=outStock?"Out of Stock":lowStock?"Low Stock":"In Stock"%>
                        </span>
                        <span class="stock-qty"><%=et.getAvailableUnits()%> available · <%=et.getTotalUnits()%> total</span>
                    </div>

                    <div class="action-row">
                        <button class="btn btn-import" onclick="openStockInModal()">
                            <i class="fas fa-plus-circle"></i> Stock In
                        </button>
                        <%if(et.getAvailableUnits()>0){%>
                        <button class="btn btn-reduce" onclick="openReduceModal()">
                            <i class="fas fa-minus-circle"></i> Reduce Stock
                        </button>
                        <%}%>
                    </div>
                </div>

                <!-- Trust badges -->
                <div class="info-card" style="padding:14px 20px">
                    <div class="trust-grid">
                        <div class="trust-item">
                            <div class="trust-icon" style="background:rgba(52,211,153,0.12);color:var(--green)"><i class="fas fa-check-double"></i></div>
                            <div><div class="trust-label">Available</div><div class="trust-sub"><%=et.getAvailableUnits()%> units ready</div></div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-icon" style="background:rgba(56,189,248,0.12);color:var(--info)"><i class="fas fa-screwdriver-wrench"></i></div>
                            <div><div class="trust-label">In Use</div><div class="trust-sub"><%=et.getInuseUnits()%> units deployed</div></div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-icon" style="background:rgba(251,191,36,0.12);color:var(--amber)"><i class="fas fa-triangle-exclamation"></i></div>
                            <div><div class="trust-label">Faulty</div><div class="trust-sub"><%=et.getFaultyUnits()%> units</div></div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-icon" style="background:rgba(255,255,255,0.05);color:var(--muted)"><i class="fas fa-archive"></i></div>
                            <div><div class="trust-label">Retired</div><div class="trust-sub"><%=et.getRetiredUnits()%> units</div></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- BOTTOM GRID -->
        <div class="bottom-grid">

            <!-- Specs -->
            <div class="detail-card">
                <div class="detail-card-hd">
                    <div class="dc-icon" style="background:rgba(79,126,248,0.15);color:var(--accent-2)"><i class="fas fa-list-ul"></i></div>
                    <div class="dc-title">Equipment Specifications</div>
                </div>
                <div class="spec-row"><span class="spec-key">Equipment ID</span><span class="spec-val mono">#<%=String.format("%05d",et.getId())%></span></div>
                <div class="spec-row"><span class="spec-key">Model</span><span class="spec-val"><%=et.getModel()%></span></div>
                <div class="spec-row"><span class="spec-key">Category</span><span class="spec-val"><%=et.getCategoryName()%></span></div>
                <div class="spec-row"><span class="spec-key">Unit Price</span><span class="spec-val" style="color:var(--amber)"><%=nf.format((long)et.getUnitPrice())%> ₫</span></div>
                <div class="spec-row"><span class="spec-key">Total Units</span><span class="spec-val"><%=et.getTotalUnits()%></span></div>
                <div class="spec-row"><span class="spec-key">Available</span><span class="spec-val" style="color:var(--green)"><%=et.getAvailableUnits()%></span></div>
                <div class="spec-row"><span class="spec-key">In Use</span><span class="spec-val" style="color:var(--info)"><%=et.getInuseUnits()%></span></div>
                <div class="spec-row"><span class="spec-key">Faulty</span><span class="spec-val" style="color:var(--amber)"><%=et.getFaultyUnits()%></span></div>
                <div class="spec-row"><span class="spec-key">Retired</span><span class="spec-val" style="color:var(--muted)"><%=et.getRetiredUnits()%></span></div>
                <div class="spec-row"><span class="spec-key">Updated By</span><span class="spec-val"><%=et.getUpdatedByUsername()!=null?et.getUpdatedByUsername():"—"%></span></div>
                <div class="spec-row"><span class="spec-key">Updated At</span><span class="spec-val"><%=et.getUpdatedAt()!=null?et.getUpdatedAt().toLocalDate():"—"%></span></div>
                <div class="spec-row"><span class="spec-key">Created At</span><span class="spec-val"><%=et.getCreatedAt()!=null?et.getCreatedAt().toLocalDate():"—"%></span></div>
            </div>

            <!-- Units list -->
            <div class="detail-card" style="grid-column:span 2">
                <div class="detail-card-hd">
                    <div class="dc-icon" style="background:rgba(56,189,248,0.15);color:var(--info)"><i class="fas fa-boxes-stacked"></i></div>
                    <div class="dc-title">All Units (<%=units.size()%>)</div>
                    <div style="margin-left:auto;display:flex;gap:8px">
                        <button class="btn btn-import" style="padding:6px 14px;font-size:.76rem" onclick="openStockInModal()">
                            <i class="fas fa-plus"></i> Stock In
                        </button>
                        <%if(et.getAvailableUnits()>0){%>
                        <button class="btn btn-reduce" style="padding:6px 14px;font-size:.76rem" onclick="openReduceModal()">
                            <i class="fas fa-minus"></i> Reduce
                        </button>
                        <%}%>
                    </div>
                </div>
                <%if(units.isEmpty()){%>
                <div style="text-align:center;padding:28px;color:var(--muted);font-size:.82rem">
                    <i class="fas fa-box-open" style="font-size:1.8rem;display:block;margin-bottom:10px;opacity:.2"></i>
                    No units in stock yet. Use Stock In to add.
                </div>
                <%}else{%>
                <div class="units-table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Unit ID</th>
                                <th>Serial Number</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Updated</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%for(EquipmentUnit eu:units){
                            String st=eu.getStatus().toUpperCase();
                            String badgeClass = "AVAILABLE".equals(st)?"s-available":
                                               ("INUSE".equals(st)||"IN_USE".equals(st))?"s-inuse":
                                               "FAULTY".equals(st)?"s-faulty":"s-retired";
                            String iconClass  = "AVAILABLE".equals(st)?"circle-check":
                                               ("INUSE".equals(st)||"IN_USE".equals(st))?"screwdriver-wrench":
                                               "FAULTY".equals(st)?"triangle-exclamation":"archive";
                        %>
                        <tr>
                            <td style="font-family:'Courier New',monospace;color:var(--accent-2)">#<%=eu.getId()%></td>
                            <td style="font-family:'Courier New',monospace;color:var(--info);font-weight:600"><%=eu.getSerialNumber()%></td>
                            <td>
                                <span class="status-badge <%=badgeClass%>">
                                    <i class="fas fa-<%=iconClass%>"></i> <%=eu.getStatus()%>
                                </span>
                            </td>
                            <td style="color:var(--muted);font-size:.74rem"><%=eu.getCreatedAt()!=null?eu.getCreatedAt().toLocalDate():"—"%></td>
                            <td style="color:var(--muted);font-size:.74rem"><%=eu.getUpdatedAt()!=null?eu.getUpdatedAt().toLocalDate():"—"%></td>
                        </tr>
                        <%}%>
                        </tbody>
                    </table>
                </div>
                <%}%>
            </div>
        </div>

    </div><!-- /content -->
</main>

<!-- ════ EDIT MODAL ════ -->
<div class="modal-overlay" id="editModal">
    <div class="modal">
        <div class="modal-icon amber"><i class="fas fa-pen"></i></div>
        <h3>Edit Equipment</h3>
        <form method="post" action="<%=ctx%>/numberEquipment" enctype="multipart/form-data">
            <input type="hidden" name="action"    value="edit">
            <input type="hidden" name="id"        value="<%=et.getId()%>">
            <input type="hidden" name="referer"   value="detailPage">
            <input type="hidden" name="imageUrl"  id="editImageUrl">
            <input type="hidden" name="clearImage" id="editClearImage" value="false">

            <div class="form-group">
                <label>Model Name *</label>
                <input type="text" name="model" required minlength="3" value="<%=et.getModel()%>">
            </div>
            <div class="form-group">
                <label>Category</label>
                <select name="categoryId">
                    <%for(Category cat:categories){%>
                    <option value="<%=cat.getId()%>" <%=cat.getId()==et.getCategoryId()?"selected":""%>><%=cat.getName()%></option>
                    <%}%>
                </select>
            </div>
            <div class="form-group">
                <label>Description</label>
                <input type="text" name="description" maxlength="255" value="<%=et.getDescription()!=null?et.getDescription():""%>">
            </div>
            <div class="form-group">
                <label>Unit Price *</label>
                <input type="number" name="unitPrice" required min="0" step="1000" value="<%=(long)et.getUnitPrice()%>">
            </div>

            <!-- IMAGE -->
            <div class="form-group">
                <label><i class="fas fa-image" style="color:var(--accent-2)"></i> Product Image <span style="color:var(--muted);font-weight:400;text-transform:none">(optional)</span></label>
                <%if(imgSrc!=null){%>
                <div class="current-img-badge" id="editCurBadge" data-original="<%=et.getImageUrl()!=null?et.getImageUrl():""%>">
                    <img src="<%=imgSrc%>" alt="current">
                    <div style="flex:1;min-width:0">
                        <div class="cib-label"><i class="fas fa-circle-check"></i> Current Image</div>
                        <div class="cib-url"><%=et.getImageUrl()%></div>
                    </div>
                    <button type="button" class="btn-clear-img" onclick="clearCurImg()"><i class="fas fa-trash"></i> Remove</button>
                </div>
                <%}%>
                <div class="img-section">
                    <div class="img-tabs">
                        <button type="button" class="img-tab active" onclick="switchTab('file',this)"><i class="fas fa-upload"></i> Upload File</button>
                        <button type="button" class="img-tab" onclick="switchTab('url',this)"><i class="fas fa-link"></i> Image URL</button>
                    </div>
                    <div class="img-tab-content active" id="tab-file">
                        <div class="drop-zone" ondragover="event.preventDefault();this.style.borderColor='var(--accent)'" ondragleave="this.style.borderColor=''" ondrop="handleEditDrop(event)">
                            <input type="file" name="imageFile" id="editFile" accept="image/jpeg,image/png,image/webp,image/gif,image/avif" onchange="showFilePreview(event)">
                            <div class="drop-zone-icon"><i class="fas fa-cloud-arrow-up"></i></div>
                            <div class="drop-zone-text"><strong>Click to browse</strong> or drag & drop<br><small style="color:rgba(255,255,255,0.2)">JPG PNG WEBP GIF AVIF · Max 5MB</small></div>
                        </div>
                        <div class="img-preview-wrap" id="filePreview">
                            <img id="filePreviewImg" src="" alt="preview">
                            <button type="button" class="img-preview-remove" onclick="removeFilePreview()"><i class="fas fa-xmark"></i></button>
                        </div>
                    </div>
                    <div class="img-tab-content" id="tab-url">
                        <div class="url-input-wrap">
                            <input type="url" id="urlInput" placeholder="https://example.com/image.jpg">
                            <button type="button" class="btn-load-url" onclick="loadUrlPreview()"><i class="fas fa-eye"></i> Preview</button>
                        </div>
                        <div class="img-preview-wrap" id="urlPreview" style="margin-top:10px">
                            <img id="urlPreviewImg" src="" alt="preview" onerror="this.style.display='none'">
                            <button type="button" class="img-preview-remove" onclick="removeUrlPreview()"><i class="fas fa-xmark"></i></button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-btns">
                <button type="submit" class="mbtn mbtn-save" onclick="prepareEditSubmit()"><i class="fas fa-save"></i> Save</button>
                <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('editModal')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- ════ STOCK IN MODAL ════ -->
<div class="modal-overlay" id="stockInModal">
    <div class="modal">
        <div class="modal-icon green"><i class="fas fa-plus-circle"></i></div>
        <h3>Stock In</h3>
        <p>Add new <strong>AVAILABLE</strong> units to <strong><%=et.getModel()%></strong>.<br>
        <span style="color:var(--green);font-size:.78rem"><i class="fas fa-robot"></i> Serial numbers will be auto-generated.</span></p>
        <form method="post" action="<%=ctx%>/numberEquipment">
            <input type="hidden" name="action"          value="stockIn">
            <input type="hidden" name="equipmentTypeId" value="<%=et.getId()%>">
            <input type="hidden" name="referer"         value="detailPage">
            <div class="form-group">
                <label>Quantity to Add (1–100)</label>
                <input type="number" name="quantity" required min="1" max="100" value="1">
            </div>
            <div class="modal-btns">
                <button type="submit" class="mbtn mbtn-save"><i class="fas fa-plus"></i> Stock In</button>
                <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('stockInModal')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- ════ REDUCE MODAL ════ -->
<div class="modal-overlay" id="reduceModal">
    <div class="modal">
        <div class="modal-icon amber"><i class="fas fa-minus-circle"></i></div>
        <h3>Reduce Stock</h3>
        <p>Remove <strong>AVAILABLE</strong> units from <strong><%=et.getModel()%></strong>.<br>
        <span style="color:var(--amber);font-size:.78rem"><i class="fas fa-triangle-exclamation"></i> Only AVAILABLE units will be removed. INUSE/FAULTY/RETIRED are not affected.</span></p>
        <form method="post" action="<%=ctx%>/numberEquipment">
            <input type="hidden" name="action"          value="reduceStock">
            <input type="hidden" name="equipmentTypeId" value="<%=et.getId()%>">
            <div class="reduce-row">
                <span style="font-size:.82rem;color:var(--text-2)">Current AVAILABLE:</span>
                <span style="font-size:1.2rem;font-weight:800;color:var(--green)"><%=et.getAvailableUnits()%></span>
            </div>
            <div class="form-group">
                <label>Units to Remove (1–<%=et.getAvailableUnits()%>)</label>
                <input type="number" name="reduceQty" required min="1" max="<%=et.getAvailableUnits()%>" value="1">
            </div>
            <p class="reduce-note" style="text-align:left;margin-top:-8px">
                <i class="fas fa-info-circle"></i> Units are chosen by oldest first from AVAILABLE stock.
            </p>
            <div class="modal-btns">
                <button type="submit" class="mbtn mbtn-amber"><i class="fas fa-minus"></i> Reduce</button>
                <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('reduceModal')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- ════ DELETE MODAL ════ -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal">
        <div class="modal-icon danger"><i class="fas fa-trash"></i></div>
        <h3>Confirm Delete</h3>
        <p>Are you sure you want to permanently delete<br>
        <strong><%=et.getModel()%></strong> (ID: #<%=et.getId()%>)?<br>
        <span style="color:var(--danger);font-size:.78rem">This will also delete all <%=et.getTotalUnits()%> units. This cannot be undone.</span></p>
        <form method="post" action="<%=ctx%>/numberEquipment">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id"     value="<%=et.getId()%>">
            <div class="modal-btns">
                <button type="submit" class="mbtn mbtn-del"><i class="fas fa-trash"></i> Delete</button>
                <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('deleteModal')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script>
function openEditModal()    { document.getElementById('editModal').classList.add('show'); }
function openStockInModal() { document.getElementById('stockInModal').classList.add('show'); }
function openReduceModal()  { document.getElementById('reduceModal').classList.add('show'); }
function openDeleteModal()  { document.getElementById('deleteModal').classList.add('show'); }
function closeModal(id)     { document.getElementById(id).classList.remove('show'); }
window.addEventListener('click', function(e){
    ['editModal','stockInModal','reduceModal','deleteModal'].forEach(function(id){
        var m=document.getElementById(id); if(e.target===m) m.classList.remove('show');
    });
});

// Image tabs
function switchTab(tab, btn) {
    var section = btn.closest('.img-section');
    section.querySelectorAll('.img-tab').forEach(function(t){ t.classList.remove('active'); });
    section.querySelectorAll('.img-tab-content').forEach(function(c){ c.classList.remove('active'); });
    btn.classList.add('active');
    document.getElementById('tab-'+tab).classList.add('active');
    if (tab==='file') removeUrlPreview(); else removeFilePreview();
}

function showFilePreview(event) {
    var file = event.target.files[0]; if (!file) return;
    if (file.size > 5*1024*1024) { alert('Max 5MB'); event.target.value=''; return; }
    var reader = new FileReader();
    reader.onload = function(e) {
        document.getElementById('filePreviewImg').src = e.target.result;
        document.getElementById('filePreview').classList.add('show');
        hideCurBadge();
    };
    reader.readAsDataURL(file);
}
function handleEditDrop(event) {
    event.preventDefault();
    var file = event.dataTransfer.files[0];
    if (!file || !file.type.startsWith('image/')) { alert('Please drop an image.'); return; }
    var dt = new DataTransfer(); dt.items.add(file);
    document.getElementById('editFile').files = dt.files;
    var reader = new FileReader();
    reader.onload = function(e) {
        document.getElementById('filePreviewImg').src = e.target.result;
        document.getElementById('filePreview').classList.add('show');
        hideCurBadge();
    };
    reader.readAsDataURL(file);
}
function removeFilePreview() {
    document.getElementById('filePreviewImg').src='';
    document.getElementById('filePreview').classList.remove('show');
    document.getElementById('editFile').value='';
    restoreCurBadge();
}
function loadUrlPreview() {
    var url = document.getElementById('urlInput').value.trim(); if (!url) return;
    document.getElementById('urlPreviewImg').style.display='';
    document.getElementById('urlPreviewImg').src = url;
    document.getElementById('urlPreview').classList.add('show');
    hideCurBadge();
}
function removeUrlPreview() {
    document.getElementById('urlPreviewImg').src=''; document.getElementById('urlPreviewImg').style.display='';
    document.getElementById('urlInput').value=''; document.getElementById('urlPreview').classList.remove('show');
    restoreCurBadge();
}
function hideCurBadge()    { var b=document.getElementById('editCurBadge'); if(b) b.style.display='none'; }
function restoreCurBadge() { var b=document.getElementById('editCurBadge'); if(b&&b.dataset.original) b.style.display='flex'; }
function clearCurImg() {
    var b=document.getElementById('editCurBadge');
    b.style.display='none'; b.dataset.original='';
    document.getElementById('editClearImage').value='true';
    document.getElementById('editImageUrl').value='';
}
function prepareEditSubmit() {
    var active = document.querySelector('#editModal .img-tab-content.active');
    if (active && active.id==='tab-url') {
        document.getElementById('editImageUrl').value = document.getElementById('urlInput').value.trim();
        document.getElementById('editFile').value='';
    } else {
        var badge = document.getElementById('editCurBadge');
        var hasFile = document.getElementById('editFile').files.length>0;
        if (!hasFile && badge && badge.style.display!=='none' && badge.dataset.original) {
            document.getElementById('editImageUrl').value = badge.dataset.original;
        }
    }
}
</script>
</body>
</html>
