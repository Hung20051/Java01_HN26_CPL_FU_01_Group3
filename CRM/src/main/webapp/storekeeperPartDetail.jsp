<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.PartType, model.PartUnit, model.Category, dao.ReviewDAO, java.util.*, java.text.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    PartType pt       = (PartType) request.getAttribute("part");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<PartUnit> units      = (List<PartUnit>) request.getAttribute("units");
    if (pt == null) { response.sendRedirect(request.getContextPath() + "/numberPart"); return; }
    if (categories == null) categories = new ArrayList<>();
    if (units == null)      units      = new ArrayList<>();

    // ── [THÊM MỚI] Đọc dữ liệu feedback từ request attributes ──
    List<ReviewDAO.Review> reviews = (List<ReviewDAO.Review>) request.getAttribute("reviews");
    double avgRating = request.getAttribute("avgRating") != null ? (double) request.getAttribute("avgRating") : 0;
    Map<Integer,Integer> ratingDist = (Map<Integer,Integer>) request.getAttribute("ratingDist");
    int totalReviews = reviews != null ? reviews.size() : 0;
    if (reviews == null) reviews = new ArrayList<>();
    if (ratingDist == null) ratingDist = new java.util.HashMap<>();
    // ── [KẾT THÚC THÊM MỚI] ─────────────────────────────────────

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    String flashError   = (String) session.getAttribute("flashError");
    session.removeAttribute("flashSuccess");
    session.removeAttribute("flashError");

    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
    String ctx = request.getContextPath();
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";

    String imgSrc = (pt.getImageUrl() != null && !pt.getImageUrl().isEmpty())
        ? (pt.getImageUrl().startsWith("http") ? pt.getImageUrl() : ctx + pt.getImageUrl())
        : null;

    boolean lowStock = pt.getAvailableUnits() > 0 && pt.getAvailableUnits() <= 3;
    boolean outStock = pt.getAvailableUnits() == 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%=pt.getName()%> — DRSMS Storekeeper</title>
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

        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{scroll-behavior:smooth}
        body{font-family:'Sora',sans-serif;background:var(--bg);color:var(--text-b);min-height:100vh;display:flex;}
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-track{background:transparent}
        ::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px}

        /* ═══════════ SIDEBAR ═══════════ */
        .sb{width:var(--sb-width);min-height:100vh;background:var(--sb-bg);border-right:1px solid rgba(79,70,229,0.2);display:flex;flex-direction:column;position:fixed;top:0;left:0;z-index:100;box-shadow:4px 0 24px rgba(0,0,0,0.15);}
        .sb-brand{padding:20px 16px 16px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--sb-border);}
        .sb-logo{width:36px;height:36px;background:linear-gradient(135deg,#818cf8,#a78bfa);border-radius:10px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.9rem;box-shadow:0 4px 12px rgba(129,140,248,0.4);flex-shrink:0;}
        .sb-name{color:#fff;font-size:1.05rem;font-weight:800;letter-spacing:-.3px}
        .sb-role{display:inline-flex;align-items:center;background:rgba(129,140,248,0.2);border:1px solid rgba(129,140,248,0.3);color:var(--sb-accent-2);font-size:.6rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:2px 8px;border-radius:20px;margin-top:3px;}
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
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.8rem;font-weight:600}
        .sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem;margin-top:1px}
        .sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
        .sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1)}

        /* ═══════════ MAIN ═══════════ */
        .main{margin-left:var(--sb-width);flex:1;display:flex;flex-direction:column;min-height:100vh}
        .topbar{display:flex;justify-content:space-between;align-items:center;padding:14px 28px;background:var(--bg-topbar);border-bottom:1px solid var(--border-light);position:sticky;top:0;z-index:50;box-shadow:0 1px 6px rgba(0,0,0,0.06);}
        .breadcrumb{display:flex;align-items:center;gap:7px;font-size:.76rem;color:var(--text-s);}
        .breadcrumb a{color:var(--text-s);text-decoration:none;transition:color .18s}
        .breadcrumb a:hover{color:var(--primary-2)}
        .bc-sep{color:var(--border-light)}
        .bc-cur{color:var(--primary-2);font-weight:700}
        .content{padding:24px 28px;flex:1}

        @keyframes cardIn{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:none}}
        .alert{display:flex;align-items:center;gap:12px;padding:12px 18px;border-radius:12px;margin-bottom:18px;font-size:.84rem;animation:cardIn .4s ease both;}
        .alert-success{background:#d1fae5;border:1px solid #a7f3d0;color:#065f46}
        .alert-success i{color:var(--green)}
        .alert-error{background:#fee2e2;border:1px solid #fca5a5;color:#991b1b}
        .alert-error i{color:var(--red)}

        /* Buttons */
        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 18px;border-radius:10px;border:none;font-size:.82rem;font-weight:600;font-family:inherit;cursor:pointer;text-decoration:none;transition:all .2s;white-space:nowrap;}
        .btn-back  {background:#fff;color:var(--text-m);border:1.5px solid var(--border-light);}
        .btn-back:hover{background:#f3f4f6;color:var(--text-b)}
        .btn-edit  {background:#fef3c7;color:var(--amber);border:1.5px solid #fde68a;}
        .btn-edit:hover{background:#fde68a}
        .btn-delete{background:#fee2e2;color:var(--red);border:1.5px solid #fca5a5;}
        .btn-delete:hover{background:#fecaca}
        .btn-import{background:var(--green);color:#fff;box-shadow:0 3px 10px rgba(22,163,74,0.28);}
        .btn-import:hover{background:#15803d;transform:translateY(-1px)}
        .btn-reduce{background:#fef3c7;color:var(--amber);border:1.5px solid #fde68a;}
        .btn-reduce:hover{background:#fde68a}

        /* Detail grid */
        .detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:24px;margin-bottom:24px;}

        /* Image panel */
        .img-panel{background:var(--bg-card);border:1.5px solid var(--border-light);border-radius:20px;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,0.06);animation:cardIn .5s ease both;}
        .img-main{height:320px;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,#f8f9ff,#f0f2fb);position:relative;overflow:hidden;}
        .img-main::before{content:'';position:absolute;inset:0;background:radial-gradient(circle at 50% 30%,rgba(79,70,229,0.05),transparent 70%);}
        .img-main img{max-width:88%;max-height:88%;object-fit:contain;filter:drop-shadow(0 8px 24px rgba(0,0,0,0.12));position:relative;z-index:1;transition:transform .4s;}
        .img-main:hover img{transform:scale(1.05)}
        .img-placeholder{font-size:5rem;color:var(--border-light);position:relative;z-index:1}
        .img-badge-wrap{position:absolute;top:14px;left:14px;z-index:2;display:flex;gap:7px}
        .img-badge{padding:5px 12px;border-radius:20px;font-size:.68rem;font-weight:700;letter-spacing:.5px;text-transform:uppercase;}
        .badge-part{background:var(--primary-light);border:1px solid rgba(99,102,241,0.3);color:var(--primary-2)}
        .badge-low {background:#fef3c7;border:1px solid #fde68a;color:var(--amber)}
        .badge-out {background:#fee2e2;border:1px solid #fca5a5;color:var(--red)}

        /* Info panel */
        .info-panel{display:flex;flex-direction:column;gap:16px;animation:cardIn .5s .08s ease both;}
        .info-card{background:var(--bg-card);border:1.5px solid var(--border-light);border-radius:18px;padding:22px 24px;box-shadow:0 1px 6px rgba(0,0,0,0.04);}
        .cat-badge{display:inline-flex;align-items:center;gap:6px;padding:4px 12px;border-radius:20px;font-size:.68rem;font-weight:700;letter-spacing:.8px;text-transform:uppercase;margin-bottom:10px;background:var(--primary-light);border:1px solid rgba(99,102,241,0.25);color:var(--primary-2);}
        .part-name{font-size:1.5rem;font-weight:800;color:var(--text-h);letter-spacing:-.4px;margin-bottom:8px;line-height:1.2}
        .part-desc{font-size:.85rem;color:var(--text-m);line-height:1.7;font-weight:400;margin-bottom:16px}
        .price-box{display:flex;align-items:flex-end;gap:10px;margin-bottom:14px}
        .price-main{font-size:1.9rem;font-weight:800;color:var(--amber);letter-spacing:-.5px}
        .price-label{font-size:.72rem;color:var(--text-s);margin-bottom:6px}

        /* Stock row */
        .stock-row{display:flex;align-items:center;gap:10px;padding:10px 14px;border-radius:11px;margin-bottom:16px}
        .stock-dot{width:9px;height:9px;border-radius:50%;flex-shrink:0;animation:pulse 2s ease-in-out infinite}
        @keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.6;transform:scale(1.3)}}
        .stock-label{font-size:.83rem;font-weight:700}
        .stock-qty{font-size:.77rem;color:var(--text-s);margin-left:auto}

        .action-row{display:flex;gap:8px;flex-wrap:wrap}

        /* Trust grid */
        .trust-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
        .trust-item{display:flex;align-items:center;gap:9px}
        .trust-icon{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.8rem;flex-shrink:0}
        .trust-label{font-size:.74rem;font-weight:700;color:var(--text-h)}
        .trust-sub{font-size:.67rem;color:var(--text-s)}

        /* Bottom grid */
        .bottom-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:18px;animation:cardIn .5s .16s ease both;}
        .detail-card{background:var(--bg-card);border:1.5px solid var(--border-light);border-radius:16px;padding:20px;box-shadow:0 1px 6px rgba(0,0,0,0.04);}
        .detail-card-hd{display:flex;align-items:center;gap:9px;margin-bottom:16px;padding-bottom:12px;border-bottom:1px solid var(--border-light2);}
        .dc-icon{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.82rem;flex-shrink:0}
        .dc-title{font-size:.82rem;font-weight:700;color:var(--text-h)}
        .spec-row{display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid var(--border-light2);}
        .spec-row:last-child{border-bottom:none}
        .spec-key{font-size:.75rem;color:var(--text-s);font-weight:500}
        .spec-val{font-size:.78rem;color:var(--text-b);font-weight:600;text-align:right}
        .spec-val.mono{font-family:'Courier New',monospace;color:var(--primary-2)}

        /* Units table */
        .units-table-wrap{max-height:260px;overflow-y:auto}
        .units-table-wrap::-webkit-scrollbar{width:3px}
        .units-table-wrap::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.2);border-radius:3px}
        table{width:100%;border-collapse:collapse;font-size:.78rem}
        th{padding:8px 10px;text-align:left;color:var(--text-s);font-size:.65rem;text-transform:uppercase;letter-spacing:.8px;font-weight:700;border-bottom:1px solid var(--border-light2);}
        td{padding:8px 10px;border-bottom:1px solid var(--border-light2);color:var(--text-b);vertical-align:middle}
        tr:last-child td{border-bottom:none}
        tbody tr{transition:background .12s}
        tbody tr:hover td{background:#f7f8ff}
        .status-badge{display:inline-flex;align-items:center;gap:4px;padding:3px 8px;border-radius:6px;font-size:.68rem;font-weight:700}
        .s-available{background:#d1fae5;color:#065f46;border:1px solid #a7f3d0}
        .s-inuse    {background:#dbeafe;color:#1e40af;border:1px solid #bfdbfe}
        .s-faulty   {background:#fef3c7;color:#92400e;border:1px solid #fde68a}
        .s-retired  {background:#f3f4f6;color:var(--text-s);border:1px solid var(--border-light)}

        /* Modal */
        .modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.45);backdrop-filter:blur(4px);z-index:1000;align-items:center;justify-content:center}
        .modal-overlay.show{display:flex}
        .modal{background:#fff;border:1px solid var(--border-light);border-radius:18px;padding:28px;width:480px;max-width:95vw;max-height:90vh;overflow-y:auto;box-shadow:0 24px 60px rgba(0,0,0,0.15),0 0 0 1px rgba(79,70,229,0.08);animation:cardIn .25s ease}
        .modal-icon{width:52px;height:52px;border-radius:14px;margin:0 auto 16px;display:flex;align-items:center;justify-content:center;font-size:1.4rem}
        .modal-icon.amber {background:#fef3c7;color:var(--amber)}
        .modal-icon.green {background:#dcfce7;color:var(--green)}
        .modal-icon.danger{background:#fee2e2;color:var(--red)}
        .modal-icon.info  {background:#e0f2fe;color:var(--info)}
        .modal h3{font-size:1rem;font-weight:800;color:var(--text-h);text-align:center;margin-bottom:20px}
        .modal p{color:var(--text-m);font-size:.83rem;text-align:center;line-height:1.6;margin-bottom:20px}
        .modal p strong{color:var(--text-h)}
        .form-group{margin-bottom:14px}
        .form-group label{display:block;font-size:.72rem;font-weight:700;color:var(--text-s);text-transform:uppercase;letter-spacing:.8px;margin-bottom:6px}
        .form-group input,.form-group select,.form-group textarea{width:100%;padding:9px 13px;background:#fff;border:1.5px solid var(--border-light);border-radius:9px;color:var(--text-b);font-size:.83rem;font-family:inherit;outline:none;transition:all .2s}
        .form-group input:focus,.form-group select:focus{border-color:rgba(79,70,229,0.4);background:#faf9ff;box-shadow:0 0 0 3px rgba(79,70,229,0.07)}
        .form-group select option{background:#fff;color:var(--text-b)}
        .modal-btns{display:flex;gap:10px;margin-top:20px}
        .mbtn{flex:1;padding:10px;border-radius:10px;border:none;font-size:.88rem;font-weight:700;font-family:inherit;cursor:pointer;transition:all .2s}
        .mbtn-save  {background:var(--green);color:#fff}
        .mbtn-save:hover{background:#15803d;transform:translateY(-1px)}
        .mbtn-amber {background:#fef3c7;color:var(--amber);border:1.5px solid #fde68a}
        .mbtn-amber:hover{background:#fde68a}
        .mbtn-del   {background:#fee2e2;color:var(--red);border:1.5px solid #fca5a5}
        .mbtn-del:hover{background:#fecaca}
        .mbtn-cancel{background:#f3f4f6;color:var(--text-m);border:1.5px solid var(--border-light)}
        .mbtn-cancel:hover{background:#e5e7eb;color:var(--text-b)}

        /* Image upload section */
        .img-section{border:1.5px solid var(--border-light);border-radius:12px;overflow:hidden;margin-bottom:14px}
        .img-tabs{display:flex;border-bottom:1.5px solid var(--border-light)}
        .img-tab{flex:1;padding:9px;border:none;cursor:pointer;background:transparent;color:var(--text-m);font-size:.76rem;font-weight:600;font-family:inherit;transition:all .2s;display:flex;align-items:center;justify-content:center;gap:6px}
        .img-tab.active{background:var(--primary-light);color:var(--primary-2);border-bottom:2px solid var(--primary)}
        .img-tab-content{padding:14px;display:none}
        .img-tab-content.active{display:block}
        .drop-zone{border:2px dashed rgba(79,70,229,0.25);border-radius:10px;padding:18px 14px;text-align:center;cursor:pointer;transition:all .2s;position:relative;background:#fafbff}
        .drop-zone:hover{border-color:var(--primary);background:var(--primary-light)}
        .drop-zone input[type="file"]{position:absolute;inset:0;opacity:0;cursor:pointer;width:100%;height:100%}
        .drop-zone-icon{font-size:1.6rem;margin-bottom:6px;color:rgba(79,70,229,0.4)}
        .drop-zone-text{font-size:.76rem;color:var(--text-m)}
        .drop-zone-text strong{color:var(--primary-2)}
        .img-preview-wrap{margin-top:10px;display:none;border-radius:10px;overflow:hidden;border:1.5px solid var(--border-light);position:relative;background:#fafbff}
        .img-preview-wrap.show{display:block}
        .img-preview-wrap img{width:100%;max-height:140px;object-fit:contain;display:block;background:#f0f0f0}
        .img-preview-remove{position:absolute;top:6px;right:6px;background:rgba(220,38,38,0.85);border:none;border-radius:6px;color:#fff;width:26px;height:26px;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:.7rem}
        .url-input-wrap{position:relative}
        .url-input-wrap input{padding-right:88px}
        .btn-load-url{position:absolute;right:6px;top:50%;transform:translateY(-50%);padding:5px 10px;border-radius:7px;border:none;background:var(--primary-light);color:var(--primary-2);font-size:.72rem;font-weight:700;font-family:inherit;cursor:pointer;transition:all .2s}
        .btn-load-url:hover{background:rgba(99,102,241,0.2)}
        .current-img-badge{display:flex;align-items:center;gap:8px;padding:8px 10px;border-radius:8px;background:#f0fdf4;border:1.5px solid #a7f3d0;margin-bottom:10px}
        .current-img-badge img{width:36px;height:36px;border-radius:6px;object-fit:cover;border:1px solid var(--border-light)}
        .cib-label{font-size:.65rem;color:var(--green);font-weight:700;text-transform:uppercase;letter-spacing:.8px}
        .cib-url{font-size:.7rem;color:var(--text-s);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .btn-clear-img{padding:4px 10px;border-radius:6px;border:1.5px solid #fca5a5;background:#fee2e2;color:var(--red);font-size:.7rem;font-weight:700;font-family:inherit;cursor:pointer;white-space:nowrap;transition:all .2s;margin-left:auto;flex-shrink:0}
        .btn-clear-img:hover{background:#fecaca}

        /* Reduce row */
        .reduce-row{display:flex;align-items:center;gap:10px;padding:12px 14px;border-radius:11px;background:#fffbeb;border:1.5px solid #fde68a;margin-bottom:6px}
        .reduce-note{font-size:.72rem;color:var(--text-s);margin-top:6px}
    </style>
</head>
<body>

<!-- ════════ SIDEBAR ════════ -->
<aside class="sb">
    <div class="sb-brand">
        <div class="sb-logo"><i class="fas fa-warehouse"></i></div>
        <div><div class="sb-name">DRSMS</div><div class="sb-role">Storekeeper</div></div>
    </div>
    <nav class="sb-nav">
        <div class="sb-lbl">Overview</div>
        <a href="<%=ctx%>/dashboard.jsp"   class="sb-item"><i class="fas fa-home"></i> Home</a>
        <a href="<%=ctx%>/storekeeper"     class="sb-item"><i class="fas fa-chart-bar"></i> Statistics</a>
        <div class="sb-lbl">Inventory</div>
        <a href="<%=ctx%>/numberPart"      class="sb-item on"><i class="fas fa-puzzle-piece"></i> Parts List</a>
        <a href="<%=ctx%>/numberEquipment" class="sb-item"><i class="fas fa-desktop"></i> Equipment List</a>
        <div class="sb-lbl">Records</div>
        <a href="<%=ctx%>/transactions"    class="sb-item"><i class="fas fa-history"></i> Transaction History</a>
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

<!-- ════════ MAIN ════════ -->
<main class="main">
    <div class="topbar">
        <div class="breadcrumb">
            <a href="<%=ctx%>/numberPart"><i class="fas fa-puzzle-piece"></i> Parts List</a>
            <span class="bc-sep">›</span>
            <span class="bc-cur"><%=pt.getName()%></span>
        </div>
        <div style="display:flex;gap:8px">
            <a href="<%=ctx%>/numberPart" class="btn btn-back"><i class="fas fa-arrow-left"></i> Back</a>
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
                        <span class="img-badge badge-part"><i class="fas fa-puzzle-piece"></i> Spare Part</span>
                        <%if(outStock){%><span class="img-badge badge-out">Out of Stock</span>
                        <%}else if(lowStock){%><span class="img-badge badge-low">Low Stock</span><%}%>
                    </div>
                    <%if(imgSrc!=null){%>
                    <img src="<%=imgSrc%>" alt="<%=pt.getName()%>"
                         onerror="this.style.display='none';this.nextElementSibling.style.display='block'">
                    <div class="img-placeholder" style="display:none"><i class="fas fa-puzzle-piece"></i></div>
                    <%}else{%>
                    <div class="img-placeholder"><i class="fas fa-puzzle-piece"></i></div>
                    <%}%>
                </div>
            </div>

            <!-- Info panel -->
            <div class="info-panel">
                <div class="info-card">
                    <div class="cat-badge"><i class="fas fa-tag"></i> <%=pt.getCategoryName()%></div>
                    <div class="part-name"><%=pt.getName()%></div>
                    <div class="part-desc"><%=pt.getDescription()!=null&&!pt.getDescription().isEmpty()?pt.getDescription():"No description."%></div>
                    <div class="price-box">
                        <div class="price-main"><%=nf.format((long)pt.getUnitPrice())%> ₫</div>
                        <div class="price-label">/ unit · VAT included</div>
                    </div>
                    <!-- Stock status -->
                    <div class="stock-row" style="background:<%=outStock?"#fee2e2":lowStock?"#fffbeb":"#d1fae5"%>;border:1.5px solid <%=outStock?"#fca5a5":lowStock?"#fde68a":"#a7f3d0"%>">
                        <div class="stock-dot" style="background:<%=outStock?"var(--red)":lowStock?"var(--amber)":"var(--green)"%>"></div>
                        <span class="stock-label" style="color:<%=outStock?"var(--red)":lowStock?"var(--amber)":"var(--green)"%>">
                            <i class="fas fa-<%=outStock?"times-circle":lowStock?"exclamation-triangle":"check-circle"%>" style="margin-right:4px"></i>
                            <%=outStock?"Out of Stock":lowStock?"Low Stock":"In Stock"%>
                        </span>
                        <span class="stock-qty"><%=pt.getAvailableUnits()%> available · <%=pt.getTotalUnits()%> total</span>
                    </div>
                    <div class="action-row">
                        <button class="btn btn-import" onclick="openImportModal()">
                            <i class="fas fa-plus-circle"></i> Import Stock
                        </button>
                        <%if(pt.getAvailableUnits()>0){%>
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
                            <div class="trust-icon" style="background:#dcfce7;color:var(--green)"><i class="fas fa-check-double"></i></div>
                            <div><div class="trust-label">Available</div><div class="trust-sub"><%=pt.getAvailableUnits()%> units ready</div></div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-icon" style="background:#e0f2fe;color:var(--info)"><i class="fas fa-screwdriver-wrench"></i></div>
                            <div><div class="trust-label">In Use</div><div class="trust-sub"><%=pt.getInuseUnits()%> units deployed</div></div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-icon" style="background:#fef3c7;color:var(--amber)"><i class="fas fa-triangle-exclamation"></i></div>
                            <div><div class="trust-label">Faulty</div><div class="trust-sub"><%=pt.getFaultyUnits()%> units</div></div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-icon" style="background:#f3f4f6;color:var(--text-s)"><i class="fas fa-archive"></i></div>
                            <div><div class="trust-label">Retired</div><div class="trust-sub"><%=pt.getRetiredUnits()%> units</div></div>
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
                    <div class="dc-icon" style="background:var(--primary-light);color:var(--primary-2)"><i class="fas fa-list-ul"></i></div>
                    <div class="dc-title">Part Specifications</div>
                </div>
                <div class="spec-row"><span class="spec-key">Part ID</span><span class="spec-val mono">#<%=String.format("%05d",pt.getId())%></span></div>
                <div class="spec-row"><span class="spec-key">Name</span><span class="spec-val"><%=pt.getName()%></span></div>
                <div class="spec-row"><span class="spec-key">Category</span><span class="spec-val"><%=pt.getCategoryName()%></span></div>
                <div class="spec-row"><span class="spec-key">Unit Price</span><span class="spec-val" style="color:var(--amber)"><%=nf.format((long)pt.getUnitPrice())%> ₫</span></div>
                <div class="spec-row"><span class="spec-key">Total Units</span><span class="spec-val"><%=pt.getTotalUnits()%></span></div>
                <div class="spec-row"><span class="spec-key">Available</span><span class="spec-val" style="color:var(--green)"><%=pt.getAvailableUnits()%></span></div>
                <div class="spec-row"><span class="spec-key">In Use</span><span class="spec-val" style="color:var(--info)"><%=pt.getInuseUnits()%></span></div>
                <div class="spec-row"><span class="spec-key">Faulty</span><span class="spec-val" style="color:var(--amber)"><%=pt.getFaultyUnits()%></span></div>
                <div class="spec-row"><span class="spec-key">Retired</span><span class="spec-val" style="color:var(--text-s)"><%=pt.getRetiredUnits()%></span></div>
                <div class="spec-row"><span class="spec-key">Updated By</span><span class="spec-val"><%=pt.getUpdatedByUsername()!=null?pt.getUpdatedByUsername():"—"%></span></div>
                <div class="spec-row"><span class="spec-key">Updated At</span><span class="spec-val"><%=pt.getUpdatedAt()!=null?pt.getUpdatedAt().toLocalDate():"—"%></span></div>
                <div class="spec-row"><span class="spec-key">Created At</span><span class="spec-val"><%=pt.getCreatedAt()!=null?pt.getCreatedAt().toLocalDate():"—"%></span></div>
            </div>

            <!-- Units list (span 2) -->
            <div class="detail-card" style="grid-column:span 2">
                <div class="detail-card-hd">
                    <div class="dc-icon" style="background:#dcfce7;color:var(--green)"><i class="fas fa-boxes-stacked"></i></div>
                    <div class="dc-title">All Units (<%=units.size()%>)</div>
                    <div style="margin-left:auto;display:flex;gap:8px">
                        <button class="btn btn-import" style="padding:6px 14px;font-size:.76rem" onclick="openImportModal()">
                            <i class="fas fa-plus"></i> Import
                        </button>
                        <%if(pt.getAvailableUnits()>0){%>
                        <button class="btn btn-reduce" style="padding:6px 14px;font-size:.76rem" onclick="openReduceModal()">
                            <i class="fas fa-minus"></i> Reduce
                        </button>
                        <%}%>
                    </div>
                </div>
                <%if(units.isEmpty()){%>
                <div style="text-align:center;padding:28px;color:var(--text-s);font-size:.82rem">
                    <i class="fas fa-box-open" style="font-size:1.8rem;display:block;margin-bottom:10px;opacity:.2;color:var(--text-m)"></i>
                    No units in stock yet. Use Import Stock to add.
                </div>
                <%}else{%>
                <div class="units-table-wrap">
                    <table>
                        <thead>
                            <tr><th>Unit ID</th><th>Status</th><th>Created</th><th>Updated</th></tr>
                        </thead>
                        <tbody>
                        <%for(PartUnit pu:units){%>
                        <tr>
                            <td style="font-family:'Courier New',monospace;color:var(--primary-2);font-weight:600">#<%=pu.getId()%></td>
                            <td>
                                <span class="status-badge <%="AVAILABLE".equals(pu.getStatus())?"s-available":"INUSE".equals(pu.getStatus())?"s-inuse":"FAULTY".equals(pu.getStatus())?"s-faulty":"s-retired"%>">
                                    <i class="fas fa-<%="AVAILABLE".equals(pu.getStatus())?"circle-check":"INUSE".equals(pu.getStatus())?"screwdriver-wrench":"FAULTY".equals(pu.getStatus())?"triangle-exclamation":"archive"%>"></i>
                                    <%=pu.getStatus()%>
                                </span>
                            </td>
                            <td style="color:var(--text-s);font-size:.74rem"><%=pu.getCreatedAt()!=null?pu.getCreatedAt().toLocalDate():"—"%></td>
                            <td style="color:var(--text-s);font-size:.74rem"><%=pu.getUpdatedAt()!=null?pu.getUpdatedAt().toLocalDate():"—"%></td>
                        </tr>
                        <%}%>
                        </tbody>
                    </table>
                </div>
                <%}%>
            </div>
        </div><!-- end bottom-grid -->

        <!-- ════════════════════════════════════════════════════════
             [THÊM MỚI] CUSTOMER FEEDBACK SECTION
             Hiển thị tất cả đánh giá của khách hàng về sản phẩm này
             ════════════════════════════════════════════════════════ -->
        <div style="background:var(--bg-card);border:1.5px solid var(--border-light);border-radius:16px;padding:24px;margin-top:0;animation:cardIn .5s .24s ease both;">

            <%-- Header row --%>
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:18px;padding-bottom:14px;border-bottom:1px solid var(--border-light2);">
                <div style="display:flex;align-items:center;gap:10px;">
                    <div style="width:32px;height:32px;border-radius:9px;background:#fef3c7;color:var(--amber);display:flex;align-items:center;justify-content:center;font-size:.82rem;">
                        <i class="fas fa-star"></i>
                    </div>
                    <span style="font-size:.88rem;font-weight:700;color:var(--text-h);">Customer Feedback</span>
                    <%if(totalReviews>0){%>
                    <span style="background:var(--primary-light);color:var(--primary-2);font-size:.68rem;font-weight:700;padding:3px 10px;border-radius:20px;"><%=totalReviews%> review<%=totalReviews>1?"s":""%></span>
                    <%}%>
                </div>
                <%if(totalReviews>0){%>
                <div style="display:flex;align-items:center;gap:6px;">
                    <span style="font-size:1.3rem;font-weight:800;color:var(--amber);"><%=String.format("%.1f",avgRating)%></span>
                    <div style="display:flex;gap:2px;">
                        <%for(int s=1;s<=5;s++){%>
                        <span style="font-size:13px;color:<%=s<=Math.round(avgRating)?"#f59e0b":"#e5e7eb"%>;">★</span>
                        <%}%>
                    </div>
                </div>
                <%}%>
            </div>

            <%if(totalReviews==0){%>
            <%-- Empty state --%>
            <div style="text-align:center;padding:36px 20px;color:var(--text-s);">
                <i class="fas fa-comment-slash" style="font-size:2.2rem;display:block;margin-bottom:12px;opacity:.2;color:var(--text-m);"></i>
                <div style="font-size:.85rem;font-weight:600;color:var(--text-m);margin-bottom:4px;">No reviews yet</div>
                <div style="font-size:.78rem;">Customer feedback will appear here after purchase.</div>
            </div>
            <%}else{%>

            <%-- Rating distribution bar --%>
            <div style="display:flex;gap:20px;align-items:center;background:#f9fafb;border-radius:12px;padding:14px 18px;margin-bottom:20px;">
                <div style="text-align:center;padding-right:18px;border-right:1px solid var(--border-light);">
                    <div style="font-size:2.2rem;font-weight:800;color:var(--amber);line-height:1;"><%=String.format("%.1f",avgRating)%></div>
                    <div style="display:flex;gap:2px;justify-content:center;margin:4px 0 3px;">
                        <%for(int s=1;s<=5;s++){%>
                        <span style="font-size:13px;color:<%=s<=Math.round(avgRating)?"#f59e0b":"#e5e7eb"%>;">★</span>
                        <%}%>
                    </div>
                    <div style="font-size:.7rem;color:var(--text-s);"><%=totalReviews%> reviews</div>
                </div>
                <div style="flex:1;display:flex;flex-direction:column;gap:4px;">
                    <%for(int s=5;s>=1;s--){
                        int cnt=ratingDist.getOrDefault(s,0);
                        int pct=totalReviews>0?cnt*100/totalReviews:0;
                    %>
                    <div style="display:flex;align-items:center;gap:8px;font-size:.73rem;color:var(--text-m);">
                        <span style="min-width:16px;text-align:right;"><%=s%></span>
                        <span style="color:#f59e0b;font-size:11px;">★</span>
                        <div style="flex:1;height:5px;background:#e5e7eb;border-radius:3px;overflow:hidden;">
                            <div style="width:<%=pct%>%;height:100%;background:var(--amber);border-radius:3px;"></div>
                        </div>
                        <span style="min-width:14px;color:var(--text-s);"><%=cnt%></span>
                    </div>
                    <%}%>
                </div>
            </div>

            <%-- Filter tabs --%>
            <div style="display:flex;gap:6px;margin-bottom:16px;flex-wrap:wrap;" id="rvFilterRow">
                <button class="rv-filter-btn active" onclick="filterReviews(this,'all')"
                    style="padding:5px 14px;border-radius:20px;border:1.5px solid var(--border-light);background:var(--primary-light);color:var(--primary-2);font-size:.72rem;font-weight:700;cursor:pointer;font-family:inherit;transition:all .15s;">
                    All (<%=totalReviews%>)
                </button>
                <%for(int s=5;s>=1;s--){
                    int cnt=ratingDist.getOrDefault(s,0);
                    if(cnt>0){%>
                <button class="rv-filter-btn" onclick="filterReviews(this,'<%=s%>')"
                    style="padding:5px 14px;border-radius:20px;border:1.5px solid var(--border-light);background:#fff;color:var(--text-m);font-size:.72rem;font-weight:700;cursor:pointer;font-family:inherit;transition:all .15s;">
                    <%=s%>★ (<%=cnt%>)
                </button>
                <%}}%>
                <button class="rv-filter-btn" onclick="filterReviews(this,'img')"
                    style="padding:5px 14px;border-radius:20px;border:1.5px solid var(--border-light);background:#fff;color:var(--text-m);font-size:.72rem;font-weight:700;cursor:pointer;font-family:inherit;transition:all .15s;">
                    <i class="fas fa-image" style="font-size:10px;"></i> Has Image
                </button>
            </div>

            <%-- Review cards --%>
            <div id="rvList" style="display:flex;flex-direction:column;gap:10px;">
            <%for(ReviewDAO.Review rv : reviews){
                String rvInit = rv.customerName!=null&&!rv.customerName.isEmpty()
                    ? rv.customerName.substring(0,1).toUpperCase() : "?";
                java.text.SimpleDateFormat rvSdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
                String hasImg = (rv.imageUrl!=null&&!rv.imageUrl.isEmpty()) ? "true" : "false";
            %>
            <div class="rv-card" data-stars="<%=rv.rating%>" data-has-img="<%=hasImg%>"
                 style="border:1.5px solid var(--border-light2);border-radius:12px;padding:14px 16px;transition:background .12s;">
                <%-- Top row: avatar + name + date + rating --%>
                <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px;">
                    <div style="width:34px;height:34px;border-radius:50%;background:var(--primary-light);display:flex;align-items:center;justify-content:center;font-size:.8rem;font-weight:700;color:var(--primary-2);flex-shrink:0;">
                        <%=rvInit%>
                    </div>
                    <div style="flex:1;min-width:0;">
                        <div style="font-size:.83rem;font-weight:600;color:var(--text-h);"><%=rv.customerName!=null?rv.customerName:"Unknown"%></div>
                        <div style="font-size:.7rem;color:var(--text-s);"><%=rvSdf.format(rv.createdAt)%></div>
                    </div>
                    <%-- Stars --%>
                    <div style="display:flex;flex-direction:column;align-items:flex-end;gap:3px;">
                        <div style="display:flex;gap:2px;">
                            <%for(int s=1;s<=5;s++){%>
                            <span style="font-size:13px;color:<%=s<=rv.rating?"#f59e0b":"#e5e7eb"%>;">★</span>
                            <%}%>
                        </div>
                        <span style="background:#fef3c7;color:var(--amber);font-size:.65rem;font-weight:700;padding:2px 7px;border-radius:6px;"><%=rv.rating%>/5</span>
                    </div>
                </div>
                <%-- Comment --%>
                <%if(rv.comment!=null&&!rv.comment.isEmpty()){%>
                <p style="font-size:.82rem;color:var(--text-b);line-height:1.65;margin-bottom:<%=hasImg.equals("true")?"8px":"0"%>;"><%=rv.comment%></p>
                <%}%>
                <%-- Image --%>
                <%if(rv.imageUrl!=null&&!rv.imageUrl.isEmpty()){%>
                <div>
                    <img src="<%=ctx+rv.imageUrl%>" alt="review"
                         style="width:76px;height:76px;object-fit:cover;border-radius:8px;border:1.5px solid var(--border-light);cursor:zoom-in;transition:transform .15s;"
                         onmouseover="this.style.transform='scale(1.04)'"
                         onmouseout="this.style.transform='scale(1)'"
                         onclick="openRvLightbox('<%=ctx+rv.imageUrl%>')">
                </div>
                <%}%>
            </div>
            <%}%>
            </div>
            <%}%>
        </div>
        <!-- ════ [KẾT THÚC THÊM MỚI] CUSTOMER FEEDBACK SECTION ════ -->

    </div><!-- end .content -->

<!-- ════ EDIT MODAL ════ -->
<div class="modal-overlay" id="editModal">
    <div class="modal">
        <div class="modal-icon amber"><i class="fas fa-pen"></i></div>
        <h3>Edit Part Type</h3>
        <form method="post" action="<%=ctx%>/numberPart" enctype="multipart/form-data" id="editForm">
            <input type="hidden" name="action"   value="edit">
            <input type="hidden" name="id"       value="<%=pt.getId()%>">
            <input type="hidden" name="referer"  value="detailPage">
            <input type="hidden" name="imageUrl" id="editImageUrl">
            <input type="hidden" name="clearImage" id="editClearImage" value="false">
            <div class="form-group">
                <label>Part Name *</label>
                <input type="text" name="name" required minlength="3" value="<%=pt.getName()%>">
            </div>
            <div class="form-group">
                <label>Category</label>
                <select name="categoryId">
                    <%for(Category cat:categories){%>
                    <option value="<%=cat.getId()%>" <%=cat.getId()==pt.getCategoryId()?"selected":""%>><%=cat.getName()%></option>
                    <%}%>
                </select>
            </div>
            <div class="form-group">
                <label>Description * (10–100 chars)</label>
                <input type="text" name="description" required minlength="10" maxlength="100" value="<%=pt.getDescription()!=null?pt.getDescription():""%>">
            </div>
            <div class="form-group">
                <label>Unit Price *</label>
                <input type="number" name="unitPrice" required min="0" step="1000" value="<%=(long)pt.getUnitPrice()%>">
            </div>
            <div class="form-group">
                <label><i class="fas fa-image" style="color:var(--primary-2)"></i> Product Image <span style="color:var(--text-s);font-weight:400;text-transform:none;letter-spacing:0">(optional)</span></label>
                <%if(imgSrc!=null){%>
                <div class="current-img-badge" id="editCurBadge" data-original="<%=pt.getImageUrl()!=null?pt.getImageUrl():""%>">
                    <img src="<%=imgSrc%>" alt="current">
                    <div style="flex:1;min-width:0">
                        <div class="cib-label"><i class="fas fa-circle-check"></i> Current Image</div>
                        <div class="cib-url"><%=pt.getImageUrl()%></div>
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
                        <div class="drop-zone" ondragover="event.preventDefault();this.style.borderColor='var(--primary)'" ondragleave="this.style.borderColor=''" ondrop="handleDrop(event)">
                            <input type="file" name="imageFile" id="editFile" accept="image/jpeg,image/png,image/webp,image/gif,image/avif" onchange="showFilePreview(event)">
                            <div class="drop-zone-icon"><i class="fas fa-cloud-arrow-up"></i></div>
                            <div class="drop-zone-text"><strong>Click to browse</strong> or drag & drop<br><small style="color:var(--text-s)">JPG PNG WEBP GIF AVIF · Max 5MB</small></div>
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
                            <img id="urlPreviewImg" src="" alt="preview" onerror="document.getElementById('urlPreviewImg').style.display='none'">
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

<!-- ════ IMPORT MODAL ════ -->
<div class="modal-overlay" id="importModal">
    <div class="modal">
        <div class="modal-icon green"><i class="fas fa-plus-circle"></i></div>
        <h3>Import Stock</h3>
        <p>Add new <strong>AVAILABLE</strong> units to <strong><%=pt.getName()%></strong>.</p>
        <form method="post" action="<%=ctx%>/numberPart">
            <input type="hidden" name="action"     value="import">
            <input type="hidden" name="partTypeId" value="<%=pt.getId()%>">
            <input type="hidden" name="referer"    value="detailPage">
            <div class="form-group">
                <label>Quantity to Import (1–100)</label>
                <input type="number" name="quantity" required min="1" max="100" value="1">
            </div>
            <div class="modal-btns">
                <button type="submit" class="mbtn mbtn-save"><i class="fas fa-plus"></i> Import</button>
                <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('importModal')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- ════ REDUCE MODAL ════ -->
<div class="modal-overlay" id="reduceModal">
    <div class="modal">
        <div class="modal-icon amber"><i class="fas fa-minus-circle"></i></div>
        <h3>Reduce Stock</h3>
        <p>Remove <strong>AVAILABLE</strong> units from <strong><%=pt.getName()%></strong>.<br>
        <span style="color:var(--amber);font-size:.78rem"><i class="fas fa-triangle-exclamation"></i> Only AVAILABLE units will be deleted.</span></p>
        <form method="post" action="<%=ctx%>/numberPart">
            <input type="hidden" name="action"     value="reduceStock">
            <input type="hidden" name="partTypeId" value="<%=pt.getId()%>">
            <div class="reduce-row">
                <span style="font-size:.82rem;color:var(--text-b)">Current AVAILABLE:</span>
                <span style="font-size:1.2rem;font-weight:800;color:var(--green)"><%=pt.getAvailableUnits()%></span>
            </div>
            <div class="form-group">
                <label>Units to Remove (1–<%=pt.getAvailableUnits()%>)</label>
                <input type="number" name="reduceQty" required min="1" max="<%=pt.getAvailableUnits()%>" value="1">
            </div>
            <p class="reduce-note" style="text-align:left;margin-top:-8px">
                <i class="fas fa-info-circle"></i> Selected units are chosen randomly from AVAILABLE stock.
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
        <strong><%=pt.getName()%></strong> (ID: #<%=pt.getId()%>)?<br>
        <span style="color:var(--red);font-size:.78rem">This will also delete all <%=pt.getTotalUnits()%> units. This cannot be undone.</span></p>
        <form method="post" action="<%=ctx%>/numberPart">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id"     value="<%=pt.getId()%>">
            <div class="modal-btns">
                <button type="submit" class="mbtn mbtn-del"><i class="fas fa-trash"></i> Delete</button>
                <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('deleteModal')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script>
function openEditModal()   { document.getElementById('editModal').classList.add('show'); }
function openImportModal() { document.getElementById('importModal').classList.add('show'); }
function openReduceModal() { document.getElementById('reduceModal').classList.add('show'); }
function openDeleteModal() { document.getElementById('deleteModal').classList.add('show'); }
function closeModal(id)    { document.getElementById(id).classList.remove('show'); }
window.addEventListener('click', function(e){
    ['editModal','importModal','reduceModal','deleteModal'].forEach(function(id){
        var m=document.getElementById(id); if(e.target===m) m.classList.remove('show');
    });
});
function switchTab(tab, btn) {
    var section = btn.closest('.img-section');
    section.querySelectorAll('.img-tab').forEach(function(t){ t.classList.remove('active'); });
    section.querySelectorAll('.img-tab-content').forEach(function(c){ c.classList.remove('active'); });
    btn.classList.add('active');
    document.getElementById('tab-'+tab).classList.add('active');
    if(tab==='file') removeUrlPreview(); else removeFilePreview();
}
function showFilePreview(event) {
    var file = event.target.files[0]; if(!file) return;
    if(file.size>5*1024*1024){ alert('File too large (max 5MB)'); event.target.value=''; return; }
    var reader=new FileReader();
    reader.onload=function(e){ document.getElementById('filePreviewImg').src=e.target.result; document.getElementById('filePreview').classList.add('show'); hideCurBadge(); };
    reader.readAsDataURL(file);
}
function handleDrop(event) {
    event.preventDefault();
    var file=event.dataTransfer.files[0];
    if(!file||!file.type.startsWith('image/')){ alert('Please drop an image.'); return; }
    var dt=new DataTransfer(); dt.items.add(file);
    document.getElementById('editFile').files=dt.files;
    var reader=new FileReader();
    reader.onload=function(e){ document.getElementById('filePreviewImg').src=e.target.result; document.getElementById('filePreview').classList.add('show'); hideCurBadge(); };
    reader.readAsDataURL(file);
}
function removeFilePreview() {
    document.getElementById('filePreviewImg').src='';
    document.getElementById('filePreview').classList.remove('show');
    document.getElementById('editFile').value='';
    restoreCurBadge();
}
function loadUrlPreview() {
    var url=document.getElementById('urlInput').value.trim(); if(!url) return;
    document.getElementById('urlPreviewImg').style.display='';
    document.getElementById('urlPreviewImg').src=url;
    document.getElementById('urlPreview').classList.add('show');
    hideCurBadge();
}
function removeUrlPreview() {
    document.getElementById('urlPreviewImg').src='';
    document.getElementById('urlPreviewImg').style.display='';
    document.getElementById('urlInput').value='';
    document.getElementById('urlPreview').classList.remove('show');
    restoreCurBadge();
}
function hideCurBadge() { var b=document.getElementById('editCurBadge'); if(b) b.style.display='none'; }
function restoreCurBadge() { var b=document.getElementById('editCurBadge'); if(b&&b.dataset.original) b.style.display='flex'; }
function clearCurImg() {
    var b=document.getElementById('editCurBadge');
    b.style.display='none'; b.dataset.original='';
    document.getElementById('editClearImage').value='true';
    document.getElementById('editImageUrl').value='';
}
function prepareEditSubmit() {
    var activeTab=document.querySelector('#editModal .img-tab-content.active');
    if(activeTab&&activeTab.id==='tab-url'){
        var url=document.getElementById('urlInput').value.trim();
        document.getElementById('editImageUrl').value=url;
        document.getElementById('editFile').value='';
    }else{
        var badge=document.getElementById('editCurBadge');
        var hasFile=document.getElementById('editFile').files.length>0;
        if(!hasFile&&badge&&badge.style.display!=='none'&&badge.dataset.original)
            document.getElementById('editImageUrl').value=badge.dataset.original;
    }
}
</script>
<!-- ════ [THÊM MỚI] Lightbox xem ảnh review ════ -->
<div id="rvLightbox"
     style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,0.82);
            align-items:center;justify-content:center;cursor:zoom-out;"
     onclick="closeRvLightbox()">
    <button onclick="closeRvLightbox()" title="Close"
            style="position:absolute;top:18px;right:22px;background:rgba(255,255,255,0.15);
                   border:none;color:#fff;font-size:1.3rem;width:38px;height:38px;
                   border-radius:50%;cursor:pointer;display:flex;align-items:center;
                   justify-content:center;z-index:1;transition:background .2s;"
            onmouseover="this.style.background='rgba(255,255,255,0.3)'"
            onmouseout="this.style.background='rgba(255,255,255,0.15)'">✕</button>
    <img id="rvLightboxImg" src="" alt="review"
         style="max-width:90vw;max-height:88vh;object-fit:contain;
                border-radius:12px;box-shadow:0 8px 40px rgba(0,0,0,0.5);cursor:default;"
         onclick="event.stopPropagation()">
    <div style="position:absolute;bottom:16px;color:rgba(255,255,255,0.45);font-size:.73rem;">
        Click outside or press ESC to close
    </div>
</div>

<script>
// Lightbox
function openRvLightbox(src){
    document.getElementById('rvLightboxImg').src=src;
    document.getElementById('rvLightbox').style.display='flex';
    document.body.style.overflow='hidden';
}
function closeRvLightbox(){
    document.getElementById('rvLightbox').style.display='none';
    document.getElementById('rvLightboxImg').src='';
    document.body.style.overflow='';
}
document.addEventListener('keydown',function(e){ if(e.key==='Escape') closeRvLightbox(); });

// Filter reviews by star / has image
function filterReviews(btn, type){
    document.querySelectorAll('.rv-filter-btn').forEach(function(b){
        b.style.background='#fff';
        b.style.color='var(--text-m)';
        b.style.borderColor='var(--border-light)';
        b.classList.remove('active');
    });
    btn.style.background='var(--primary-light)';
    btn.style.color='var(--primary-2)';
    btn.style.borderColor='rgba(99,102,241,0.3)';
    btn.classList.add('active');

    document.querySelectorAll('.rv-card').forEach(function(card){
        var stars=parseInt(card.dataset.stars);
        var hasImg=card.dataset.hasImg==='true';
        var show=true;
        if(type==='img') show=hasImg;
        else if(type!=='all') show=(stars===parseInt(type));
        card.style.display=show?'':'none';
    });
}
</script>
<!-- ════ [KẾT THÚC THÊM MỚI] ════ -->

</body>
</html>
