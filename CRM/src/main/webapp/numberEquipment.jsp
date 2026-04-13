<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.EquipmentType, model.EquipmentUnit, model.Category, java.util.*, java.text.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    List<EquipmentType> equipments = (List<EquipmentType>) request.getAttribute("equipments");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    Map<Integer, List<EquipmentUnit>> unitsMap = (Map<Integer, List<EquipmentUnit>>) request.getAttribute("unitsMap");
    String keyword = request.getAttribute("keyword") != null ? (String) request.getAttribute("keyword") : "";
    String categoryId = request.getAttribute("categoryId") != null ? (String) request.getAttribute("categoryId") : "";
    String sortBy = request.getAttribute("sortBy") != null ? (String) request.getAttribute("sortBy") : "";
    int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;
    int total = request.getAttribute("total") != null ? (int) request.getAttribute("total") : 0;
    if (equipments == null) {
        equipments = new ArrayList<>();
    }
    if (categories == null) {
        categories = new ArrayList<>();
    }
    if (unitsMap == null) {
        unitsMap = new java.util.HashMap<>();
    }

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    String flashError = (String) session.getAttribute("flashError");
    session.removeAttribute("flashSuccess");
    session.removeAttribute("flashError");

    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    String ctx = request.getContextPath();
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
            ? currentUser.getFullName().substring(0, 1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Equipment List – DRSMS</title>
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
            .topbar-badge{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:8px 16px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:20px;
                color:var(--text-m);
                font-size:.8rem;
                font-weight:600;
            }
            .topbar-badge i{
                color:var(--primary-2)
            }
            .content{
                padding:24px 28px;
                flex:1
            }

            @keyframes cardIn{
                from{
                    opacity:0;
                    transform:translateY(14px)
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
                margin-bottom:18px;
                font-size:.84rem;
                animation:cardIn .4s ease both;
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

            .section-lbl{
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:2px;
                color:var(--primary-2);
                margin-bottom:12px;
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

            /* Toolbar */
            .toolbar{
                display:flex;
                gap:10px;
                align-items:center;
                margin-bottom:16px;
                flex-wrap:wrap
            }
            .search-box{
                flex:1;
                min-width:200px;
                padding:9px 14px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:10px;
                color:var(--text-b);
                font-size:.83rem;
                font-family:inherit;
                outline:none;
                transition:all .2s;
            }
            .search-box::placeholder{
                color:var(--text-s)
            }
            .search-box:focus{
                border-color:rgba(79,70,229,0.4);
                background:#faf9ff;
                box-shadow:0 0 0 3px rgba(79,70,229,0.07);
            }
            .select-box{
                padding:9px 12px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:10px;
                color:var(--text-b);
                font-size:.83rem;
                font-family:inherit;
                outline:none;
                cursor:pointer;
                transition:all .2s;
            }
            .select-box option{
                background:#fff;
                color:var(--text-b)
            }
            .select-box:focus{
                border-color:rgba(79,70,229,0.4);
            }
            .btn{
                display:inline-flex;
                align-items:center;
                gap:7px;
                padding:9px 16px;
                border-radius:10px;
                border:none;
                font-size:.82rem;
                font-weight:600;
                font-family:inherit;
                cursor:pointer;
                text-decoration:none;
                transition:all .2s;
                white-space:nowrap;
            }
            .btn-search{
                background:var(--primary-light);
                color:var(--primary-2);
                border:1.5px solid rgba(99,102,241,0.3);
            }
            .btn-search:hover{
                background:rgba(99,102,241,0.2);
            }
            .btn-reset{
                display:inline-flex;
                align-items:center;
                gap:6px;
                padding:9px 14px;
                border-radius:10px;
                background:#fee2e2;
                border:1.5px solid #fca5a5;
                color:var(--red);
                font-size:.82rem;
                font-weight:600;
                font-family:inherit;
                cursor:pointer;
                text-decoration:none;
                transition:all .2s;
                white-space:nowrap;
            }
            .btn-reset:hover{
                background:#fecaca
            }
            .btn-new{
                background:var(--green);
                color:#fff;
                box-shadow:0 3px 10px rgba(22,163,74,0.28);
            }
            .btn-new:hover{
                background:#15803d;
                transform:translateY(-1px);
                box-shadow:0 6px 18px rgba(22,163,74,0.4);
            }

            .filter-tags{
                display:flex;
                align-items:center;
                gap:8px;
                flex-wrap:wrap;
                margin-bottom:14px
            }
            .filter-tag{
                display:inline-flex;
                align-items:center;
                gap:6px;
                padding:4px 10px;
                border-radius:20px;
                background:var(--primary-light);
                border:1px solid rgba(99,102,241,0.25);
                color:var(--primary-2);
                font-size:.72rem;
                font-weight:600
            }

            /* Card & Table */
            .card{
                background:var(--bg-card);
                border:1px solid var(--border-light);
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 1px 6px rgba(0,0,0,0.05);
                animation:cardIn .5s .1s ease both;
            }
            .card-hd{
                display:flex;
                justify-content:space-between;
                align-items:center;
                padding:14px 18px;
                border-bottom:1px solid var(--border-light2);
                background:#fafbff;
            }
            .card-title{
                font-size:.87rem;
                font-weight:700;
                color:var(--text-h);
                display:flex;
                align-items:center;
                gap:8px;
            }
            .card-title i{
                color:var(--primary-2)
            }
            .total-badge{
                font-size:.72rem;
                color:var(--text-s);
                background:var(--primary-light);
                border:1px solid rgba(99,102,241,0.2);
                padding:3px 10px;
                border-radius:20px;
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
            tbody tr:not(.expand-row){
                transition:background .12s
            }
            tbody tr:not(.expand-row):hover td{
                background:#f7f8ff
            }

            .td-model-link{
                color:var(--text-h);
                font-weight:700;
                font-size:.82rem;
                text-decoration:none;
                transition:color .2s
            }
            .td-model-link:hover{
                color:var(--primary-2)
            }
            .td-cat{
                display:inline-flex;
                align-items:center;
                padding:3px 9px;
                border-radius:6px;
                background:#e0f2fe;
                border:1px solid #bae6fd;
                color:var(--info);
                font-size:.7rem;
                font-weight:600
            }
            .td-price{
                color:var(--green);
                font-weight:700;
                font-size:.82rem
            }
            .td-desc{
                max-width:180px;
                overflow:hidden;
                text-overflow:ellipsis;
                white-space:nowrap;
                color:var(--text-s);
                font-size:.75rem
            }
            .td-muted{
                color:var(--text-s);
                font-size:.75rem
            }

            .eq-thumb{
                width:38px;
                height:38px;
                border-radius:8px;
                object-fit:cover;
                border:1px solid var(--border-light)
            }
            .eq-thumb-placeholder{
                width:38px;
                height:38px;
                border-radius:8px;
                border:1px dashed var(--border-light);
                background:#fafbff;
                display:flex;
                align-items:center;
                justify-content:center;
                color:var(--text-s);
                font-size:.8rem
            }

            .units-count .avail{
                color:var(--green);
                font-weight:700
            }
            .units-count .sep{
                color:var(--text-s);
                margin:0 2px
            }
            .units-count .total-u{
                color:var(--text-b)
            }
            .units-count .lbl{
                color:var(--text-s);
                font-size:.7rem
            }

            /* Expand */
            .expand-btn{
                width:28px;
                height:28px;
                border-radius:8px;
                background:var(--primary-light);
                border:1.5px solid rgba(99,102,241,0.2);
                color:var(--primary-2);
                font-size:.75rem;
                display:flex;
                align-items:center;
                justify-content:center;
                cursor:pointer;
                transition:all .2s;
            }
            .expand-btn:hover{
                background:rgba(99,102,241,0.2)
            }
            .expand-row{
                display:none
            }
            .expand-row.show{
                display:table-row
            }
            .expand-content{
                padding:14px 20px 16px;
                background:#fafbff;
                border-top:1px solid var(--border-light2);
            }

            .serial-list{
                display:flex;
                flex-wrap:wrap;
                gap:7px;
                margin-bottom:10px
            }
            .serial-badge{
                display:inline-flex;
                align-items:center;
                gap:5px;
                padding:4px 10px;
                border-radius:8px;
                font-size:.73rem;
                font-weight:600
            }
            .serial-badge::before{
                content:'';
                width:6px;
                height:6px;
                border-radius:50%
            }
            .s-available{
                background:#dcfce7;
                color:var(--green);
                border:1.5px solid #a7f3d0
            }
            .s-available::before{
                background:var(--green)
            }
            .s-inuse{
                background:#dbeafe;
                color:var(--blue);
                border:1.5px solid #bfdbfe
            }
            .s-inuse::before{
                background:var(--blue)
            }
            .s-faulty{
                background:#fef3c7;
                color:var(--amber);
                border:1.5px solid #fde68a
            }
            .s-faulty::before{
                background:var(--amber)
            }
            .s-retired{
                background:#f3f4f6;
                color:var(--text-s);
                border:1.5px solid var(--border-light)
            }
            .s-retired::before{
                background:var(--text-s)
            }

            /* Action buttons */
            .action-btns{
                display:flex;
                gap:6px
            }
            .ab{
                display:inline-flex;
                align-items:center;
                gap:5px;
                padding:5px 11px;
                border-radius:8px;
                border:none;
                font-size:.73rem;
                font-weight:600;
                font-family:inherit;
                cursor:pointer;
                text-decoration:none;
                transition:all .2s;
            }
            .ab-detail{
                background:#e0f2fe;
                color:var(--info);
                border:1.5px solid #bae6fd
            }
            .ab-edit  {
                background:#fef3c7;
                color:var(--amber);
                border:1.5px solid #fde68a
            }
            .ab-delete{
                background:#fee2e2;
                color:var(--red);
                border:1.5px solid #fca5a5
            }
            .ab-detail:hover{
                background:#bae6fd
            }
            .ab-edit:hover  {
                background:#fde68a
            }
            .ab-delete:hover{
                background:#fecaca
            }

            /* Pagination */
            .pagination{
                display:flex;
                justify-content:center;
                align-items:center;
                gap:6px;
                padding:14px;
                border-top:1px solid var(--border-light2);
            }
            .page-btn{
                padding:6px 13px;
                border-radius:8px;
                background:#fff;
                border:1.5px solid var(--border-light);
                font-size:.78rem;
                color:var(--text-m);
                cursor:pointer;
                text-decoration:none;
                transition:all .2s;
                font-family:inherit;
            }
            .page-btn.active{
                background:var(--primary);
                border-color:transparent;
                color:#fff;
                font-weight:700;
                box-shadow:0 3px 8px rgba(79,70,229,0.3);
            }
            .page-btn:hover:not(.active):not(.disabled){
                background:var(--primary-light);
                border-color:rgba(99,102,241,0.3);
                color:var(--primary-2);
            }
            .page-btn.disabled{
                opacity:.35;
                pointer-events:none
            }

            .empty{
                text-align:center;
                padding:48px 24px;
                color:var(--text-s);
                font-size:.82rem
            }
            .empty i{
                font-size:2.2rem;
                display:block;
                margin-bottom:12px;
                opacity:.2;
                color:var(--text-m)
            }

            /* ══ MODAL ══ */
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
            .modal-overlay.show{
                display:flex;
            }
            .modal{
                background:#fff;
                border:1px solid var(--border-light);
                border-radius:18px;
                padding:28px;
                width:520px;
                max-width:95vw;
                max-height:90vh;
                overflow-y:auto;
                box-shadow:0 24px 60px rgba(0,0,0,0.15),0 0 0 1px rgba(79,70,229,0.08);
                animation:cardIn .25s ease;
            }
            .modal::-webkit-scrollbar{
                width:3px
            }
            .modal::-webkit-scrollbar-thumb{
                background:rgba(79,70,229,0.2);
                border-radius:3px
            }
            .modal-icon{
                width:52px;
                height:52px;
                border-radius:14px;
                margin:0 auto 16px;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:1.4rem;
            }
            .modal-icon.green {
                background:#dcfce7;
                color:var(--green)
            }
            .modal-icon.amber {
                background:#fef3c7;
                color:var(--amber)
            }
            .modal-icon.danger{
                background:#fee2e2;
                color:var(--red)
            }
            .modal h3{
                font-size:1rem;
                font-weight:800;
                color:var(--text-h);
                text-align:center;
                margin-bottom:20px;
            }
            .modal p{
                color:var(--text-m);
                font-size:.83rem;
                text-align:center;
                line-height:1.6;
                margin-bottom:20px
            }
            .modal p strong{
                color:var(--text-h)
            }

            .form-group{
                margin-bottom:14px
            }
            .form-group label{
                display:block;
                font-size:.72rem;
                font-weight:700;
                color:var(--text-s);
                text-transform:uppercase;
                letter-spacing:.8px;
                margin-bottom:6px;
            }
            .form-group input,.form-group select,.form-group textarea{
                width:100%;
                padding:9px 13px;
                background:#fff;
                border:1.5px solid var(--border-light);
                border-radius:9px;
                color:var(--text-b);
                font-size:.83rem;
                font-family:inherit;
                outline:none;
                transition:all .2s;
            }
            .form-group input:focus,.form-group select:focus{
                border-color:rgba(79,70,229,0.4);
                background:#faf9ff;
                box-shadow:0 0 0 3px rgba(79,70,229,0.07);
            }
            .form-group select option{
                background:#fff;
                color:var(--text-b)
            }

            .modal-btns{
                display:flex;
                gap:10px;
                margin-top:20px
            }
            .mbtn{
                flex:1;
                padding:10px;
                border-radius:10px;
                border:none;
                font-size:.88rem;
                font-weight:700;
                font-family:inherit;
                cursor:pointer;
                transition:all .2s;
            }
            .mbtn-save  {
                background:var(--green);
                color:#fff
            }
            .mbtn-save:hover{
                background:#15803d;
                transform:translateY(-1px)
            }
            .mbtn-del   {
                background:#fee2e2;
                color:var(--red);
                border:1.5px solid #fca5a5
            }
            .mbtn-del:hover{
                background:#fecaca
            }
            .mbtn-cancel{
                background:#f3f4f6;
                color:var(--text-m);
                border:1.5px solid var(--border-light)
            }
            .mbtn-cancel:hover{
                background:#e5e7eb;
                color:var(--text-b)
            }

            /* Image upload section */
            .img-section{
                border:1.5px solid var(--border-light);
                border-radius:12px;
                overflow:hidden;
                margin-bottom:14px
            }
            .img-tabs{
                display:flex;
                border-bottom:1.5px solid var(--border-light)
            }
            .img-tab{
                flex:1;
                padding:9px;
                border:none;
                cursor:pointer;
                background:transparent;
                color:var(--text-m);
                font-size:.76rem;
                font-weight:600;
                font-family:inherit;
                transition:all .2s;
                display:flex;
                align-items:center;
                justify-content:center;
                gap:6px;
            }
            .img-tab.active{
                background:var(--primary-light);
                color:var(--primary-2);
                border-bottom:2px solid var(--primary);
            }
            .img-tab:hover:not(.active){
                background:#f9fafb;
                color:var(--text-b)
            }
            .img-tab-content{
                padding:14px;
                display:none
            }
            .img-tab-content.active{
                display:block
            }
            .drop-zone{
                border:2px dashed rgba(79,70,229,0.25);
                border-radius:10px;
                padding:20px 14px;
                text-align:center;
                cursor:pointer;
                transition:all .2s;
                position:relative;
                background:#fafbff;
            }
            .drop-zone:hover,.drop-zone.drag-over{
                border-color:var(--primary);
                background:var(--primary-light);
            }
            .drop-zone input[type="file"]{
                position:absolute;
                inset:0;
                opacity:0;
                cursor:pointer;
                width:100%;
                height:100%
            }
            .drop-zone-icon{
                font-size:1.8rem;
                margin-bottom:8px;
                color:rgba(79,70,229,0.4)
            }
            .drop-zone-text{
                font-size:.78rem;
                color:var(--text-m);
                line-height:1.5
            }
            .drop-zone-text strong{
                color:var(--primary-2)
            }
            .drop-zone-hint{
                font-size:.68rem;
                color:var(--text-s);
                margin-top:5px
            }
            .img-preview-wrap{
                margin-top:12px;
                display:none;
                border-radius:10px;
                overflow:hidden;
                border:1.5px solid var(--border-light);
                background:#fafbff;
                position:relative
            }
            .img-preview-wrap.show{
                display:block
            }
            .img-preview-wrap img{
                width:100%;
                max-height:160px;
                object-fit:contain;
                display:block;
                background:#f0f0f0
            }
            .img-preview-remove{
                position:absolute;
                top:6px;
                right:6px;
                background:rgba(220,38,38,0.85);
                border:none;
                border-radius:6px;
                color:#fff;
                width:26px;
                height:26px;
                display:flex;
                align-items:center;
                justify-content:center;
                cursor:pointer;
                font-size:.7rem;
                transition:background .2s
            }
            .img-preview-remove:hover{
                background:var(--red)
            }
            .img-preview-name{
                padding:6px 10px;
                font-size:.7rem;
                color:var(--text-s);
                border-top:1px solid var(--border-light2);
                white-space:nowrap;
                overflow:hidden;
                text-overflow:ellipsis
            }
            .url-input-wrap{
                position:relative
            }
            .url-input-wrap input{
                padding-right:90px
            }
            .btn-load-url{
                position:absolute;
                right:6px;
                top:50%;
                transform:translateY(-50%);
                padding:5px 12px;
                border-radius:7px;
                border:none;
                background:var(--primary-light);
                color:var(--primary-2);
                font-size:.72rem;
                font-weight:700;
                font-family:inherit;
                cursor:pointer;
                transition:all .2s;
                white-space:nowrap
            }
            .btn-load-url:hover{
                background:rgba(99,102,241,0.2)
            }
            .current-img-badge{
                display:flex;
                align-items:center;
                gap:8px;
                padding:8px 10px;
                border-radius:8px;
                background:#f0fdf4;
                border:1.5px solid #a7f3d0;
                margin-bottom:10px
            }
            .current-img-badge img{
                width:36px;
                height:36px;
                border-radius:6px;
                object-fit:cover;
                border:1px solid var(--border-light)
            }
            .cib-label{
                font-size:.65rem;
                color:var(--green);
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:.8px
            }
            .cib-url{
                font-size:.7rem;
                color:var(--text-s);
                white-space:nowrap;
                overflow:hidden;
                text-overflow:ellipsis
            }
            .btn-clear-img{
                padding:4px 10px;
                border-radius:6px;
                border:1.5px solid #fca5a5;
                background:#fee2e2;
                color:var(--red);
                font-size:.7rem;
                font-weight:700;
                font-family:inherit;
                cursor:pointer;
                white-space:nowrap;
                transition:all .2s;
                margin-left:auto;
                flex-shrink:0
            }
            .btn-clear-img:hover{
                background:#fecaca
            }
        </style>
    </head>
    <body>

        <!-- ═══════════ SIDEBAR ═══════════ -->
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
                        <%if (currentUser.getAvatarUrl() != null && !currentUser.getAvatarUrl().isEmpty()) {%>
                        <img src="<%=ctx%><%=currentUser.getAvatarUrl()%>" alt="avatar">
                        <%} else {%><%=initials%><%}%>
                    </div>
                    <div>
                        <div class="sb-uname"><%=currentUser.getFullName() != null ? currentUser.getFullName() : currentUser.getUsername()%></div>
                        <div class="sb-urole">Storekeeper</div>
                    </div>
                </a>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Sign Out</a>
            </div>
        </aside>

        <!-- ═══════════ MAIN ═══════════ -->
        <main class="main">
            <div class="topbar">
                <div>
                    <div class="topbar-greeting"><i class="fas fa-desktop"></i> Equipment List</div>
                    <div class="topbar-sub">Manage equipment models, units, and serial numbers.</div>
                </div>
                <div class="topbar-badge">
                    <i class="fas fa-desktop"></i>
                    <%=currentUser.getFullName() != null ? currentUser.getFullName() : currentUser.getUsername()%>
                </div>
            </div>

            <div class="content">
                <%if (flashSuccess != null) {%>
                <div class="alert alert-success"><i class="fas fa-circle-check"></i> <%=flashSuccess%></div>
                <%}%>
                <%if (flashError != null) {%>
                <div class="alert alert-error"><i class="fas fa-circle-exclamation"></i> <%=flashError%></div>
                <%}%>

                <div class="section-lbl">Filter & Search</div>
                <form method="get" action="<%=ctx%>/numberEquipment" id="filterForm">
                    <div class="toolbar">
                        <input class="search-box" type="text" name="keyword"
                               placeholder="🔍  Search by model or description…"
                               value="<%=keyword != null ? keyword : ""%>">
                        <select class="select-box" name="categoryId" onchange="this.form.submit()">
                            <option value="">All Categories</option>
                            <%for (Category cat : categories) {%>
                            <option value="<%=cat.getId()%>" <%=String.valueOf(cat.getId()).equals(categoryId) ? "selected" : ""%>><%=cat.getName()%></option>
                            <%}%>
                        </select>
                        <select class="select-box" name="sortBy" onchange="this.form.submit()">
                            <option value="">Sort by…</option>
                            <option value="name_asc"   <%="name_asc".equals(sortBy) ? "selected" : ""%>>Name A–Z</option>
                            <option value="name_desc"  <%="name_desc".equals(sortBy) ? "selected" : ""%>>Name Z–A</option>
                            <option value="price_asc"  <%="price_asc".equals(sortBy) ? "selected" : ""%>>Price ↑</option>
                            <option value="price_desc" <%="price_desc".equals(sortBy) ? "selected" : ""%>>Price ↓</option>
                        </select>
                        <button type="submit" class="btn btn-search"><i class="fas fa-magnifying-glass"></i> Search</button>
                        <a href="<%=ctx%>/numberEquipment" class="btn-reset"><i class="fas fa-filter-circle-xmark"></i> Reset</a>
                        <button type="button" class="btn btn-new" onclick="openCreateModal()"><i class="fas fa-plus"></i> New Equipment</button>
                    </div>
                </form>

                <div class="filter-tags">
                    <span style="color:var(--text-s);font-size:.72rem;font-weight:500">Active filters:</span>
                    <%if (!keyword.isEmpty()) {%><span class="filter-tag"><i class="fas fa-magnifying-glass"></i> "<%=keyword%>"</span><%}%>
                    <%if (!categoryId.isEmpty()) {
                            String catName = categoryId;
                            for (Category c : categories) {
                                if (String.valueOf(c.getId()).equals(categoryId)) {
                                    catName = c.getName();
                                    break;
                                }
                            }
                    %><span class="filter-tag"><i class="fas fa-tag"></i> <%=catName%></span><%}%>
                    <%if (!sortBy.isEmpty()) {%><span class="filter-tag"><i class="fas fa-arrow-up-a-z"></i> <%=sortBy.replace("_", " ")%></span><%}%>
                    <%if (keyword.isEmpty() && categoryId.isEmpty() && sortBy.isEmpty()) {%>
                    <span style="color:var(--text-s);font-size:.72rem;font-style:italic">None</span><%}%>
                </div>

                <div class="section-lbl">Equipment Models (<%=total%> found)</div>
                <div class="card">
                    <div class="card-hd">
                        <div class="card-title"><i class="fas fa-desktop"></i> Equipment Types</div>
                        <span class="total-badge"><%=total%> records · Page <%=currentPage%> of <%=totalPages%></span>
                    </div>
                    <%if (equipments.isEmpty()) {%>
                    <div class="empty">
                        <i class="fas fa-server"></i>
                        No equipment found.
                        <a href="<%=ctx%>/numberEquipment" style="color:var(--primary-2);font-weight:700;text-decoration:none">Clear filters</a>
                    </div>
                    <%} else {%>
                    <table>
                        <thead>
                            <tr>
                                <th style="width:44px"></th>
                                <th>Image</th><th>Model</th><th>Category</th>
                                <th>Description</th><th>Unit Price</th><th>Units</th><th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%for (EquipmentType et : equipments) {
                                    String etImgSrc = (et.getImageUrl() != null && !et.getImageUrl().isEmpty())
                                            ? (et.getImageUrl().startsWith("http") ? et.getImageUrl() : ctx + et.getImageUrl()) : null;
                            %>
                            <tr>
                                <td>
                                    <button class="expand-btn" onclick="toggleRow(<%=et.getId()%>)">
                                        <i class="fas fa-chevron-right" id="icon-<%=et.getId()%>" style="transition:transform .2s"></i>
                                    </button>
                                </td>
                                <td>
                                    <%if (etImgSrc != null) {%>
                                    <img class="eq-thumb" src="<%=etImgSrc%>" alt="<%=et.getModel()%>"
                                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                                    <div class="eq-thumb-placeholder" style="display:none"><i class="fas fa-desktop"></i></div>
                                        <%} else {%>
                                    <div class="eq-thumb-placeholder"><i class="fas fa-desktop"></i></div>
                                        <%}%>
                                </td>
                                <td>
                                    <a href="<%=ctx%>/numberEquipment?action=detailPage&id=<%=et.getId()%>" class="td-model-link"><%=et.getModel()%></a>
                                </td>
                                <td><span class="td-cat"><%=et.getCategoryName()%></span></td>
                                <td class="td-desc" title="<%=et.getDescription() != null ? et.getDescription() : ""%>">
                                    <%=et.getDescription() != null && !et.getDescription().isEmpty() ? et.getDescription() : "—"%>
                                </td>
                                <td class="td-price"><%=nf.format((long) et.getUnitPrice())%> ₫</td>
                                <td>
                                    <span class="units-count">
                                        <span class="avail"><%=et.getAvailableUnits()%></span>
                                        <span class="sep">/</span>
                                        <span class="total-u"><%=et.getTotalUnits()%></span>
                                        <span class="lbl"> avail/total</span>
                                    </span>
                                </td>
                                <td>
                                    <div class="action-btns">
                                        <a href="<%=ctx%>/numberEquipment?action=detailPage&id=<%=et.getId()%>" class="ab ab-detail"><i class="fas fa-chart-bar"></i> Detail</a>
                                        <button class="ab ab-edit"
                                                onclick="openEditModal(<%=et.getId()%>, '<%=et.getModel().replace("'", "\\'")%>',<%=et.getCategoryId()%>, '<%=et.getDescription() != null ? et.getDescription().replace("'", "\\'") : ""%>',<%=et.getUnitPrice()%>, '<%=et.getImageUrl() != null ? et.getImageUrl().replace("'", "\\'") : ""%>')">
                                            <i class="fas fa-pen"></i> Edit
                                        </button>
                                        <button class="ab ab-delete"
                                                onclick="confirmDelete(<%=et.getId()%>, '<%=et.getModel().replace("'", "\\'")%>')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <!-- Expand Row -->
                            <tr class="expand-row" id="expand-<%=et.getId()%>">
                                <td colspan="8">
                                    <div class="expand-content">
                                        <%
                                            List<EquipmentUnit> etUnits = unitsMap.getOrDefault(et.getId(), new ArrayList<>());
                                            int cntA = 0, cntI = 0, cntF = 0, cntR = 0;
                                            for (EquipmentUnit eu : etUnits) {
                                                String st = eu.getStatus().toUpperCase();
                                                if ("AVAILABLE".equals(st)) {
                                                    cntA++;
                                                } else if ("INUSE".equals(st) || "IN_USE".equals(st)) {
                                                    cntI++;
                                                } else if ("FAULTY".equals(st)) {
                                                    cntF++;
                                                } else if ("RETIRED".equals(st)) {
                                                    cntR++;
                                                }
                                            }
                                        %>
                                        <div style="display:flex;align-items:center;gap:12px;margin-bottom:12px;flex-wrap:wrap">
                                            <div style="font-size:.68rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--text-s);flex:1">
                                                Serial Numbers <span style="color:var(--text-b);font-size:.72rem;font-weight:400;text-transform:none;letter-spacing:0">(<%=etUnits.size()%> units)</span>
                                            </div>
                                            <div style="display:flex;gap:8px;flex-wrap:wrap">
                                                <%if (cntA > 0) {%><span style="display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;background:#dcfce7;border:1px solid #a7f3d0;color:var(--green);font-size:.7rem;font-weight:700"><i class="fas fa-circle-check" style="font-size:.6rem"></i><%=cntA%> Available</span><%}%>
                                                <%if (cntI > 0) {%><span style="display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;background:#dbeafe;border:1px solid #bfdbfe;color:var(--blue);font-size:.7rem;font-weight:700"><i class="fas fa-screwdriver-wrench" style="font-size:.6rem"></i><%=cntI%> In Use</span><%}%>
                                                <%if (cntF > 0) {%><span style="display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;background:#fef3c7;border:1px solid #fde68a;color:var(--amber);font-size:.7rem;font-weight:700"><i class="fas fa-triangle-exclamation" style="font-size:.6rem"></i><%=cntF%> Faulty</span><%}%>
                                                <%if (cntR > 0) {%><span style="display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;background:#f3f4f6;border:1px solid var(--border-light);color:var(--text-s);font-size:.7rem;font-weight:700"><i class="fas fa-archive" style="font-size:.6rem"></i><%=cntR%> Retired</span><%}%>
                                            </div>
                                        </div>
                                        <%if (etUnits.isEmpty()) {%>
                                        <div style="color:var(--text-s);font-size:.78rem;font-style:italic;padding:8px 0">
                                            <i class="fas fa-inbox" style="margin-right:6px;opacity:.4"></i>No units yet.
                                        </div>
                                        <%} else {%>
                                        <div class="serial-list">
                                            <%for (EquipmentUnit eu : etUnits) {
                                                    String st = eu.getStatus().toLowerCase();
                                                    String bc = "s-" + (st.equals("in_use") || st.equals("inuse") ? "inuse" : st);
                                            %>
                                            <span class="serial-badge <%=bc%>">
                                                <%=eu.getSerialNumber()%>
                                                <span style="opacity:.55;font-weight:400;font-size:.65rem;margin-left:2px">(<%=eu.getStatus()%>)</span>
                                            </span>
                                            <%}%>
                                        </div>
                                        <%}%>
                                    </div>
                                </td>
                            </tr>
                            <%}%>
                        </tbody>
                    </table>
                    <%}%>
                    <div class="pagination">
                        <a href="<%=ctx%>/numberEquipment?page=1&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                           class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">« First</a>
                        <a href="<%=ctx%>/numberEquipment?page=<%=Math.max(1, currentPage - 1)%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                           class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">‹ Prev</a>
                        <%for (int p = Math.max(1, currentPage - 2); p <= Math.min(totalPages, currentPage + 2); p++) {%>
                        <a href="<%=ctx%>/numberEquipment?page=<%=p%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                           class="page-btn <%=p == currentPage ? "active" : ""%>"><%=p%></a>
                        <%}%>
                        <a href="<%=ctx%>/numberEquipment?page=<%=Math.min(totalPages, currentPage + 1)%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                           class="page-btn <%=currentPage == totalPages ? "disabled" : ""%>">Next ›</a>
                        <a href="<%=ctx%>/numberEquipment?page=<%=totalPages%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                           class="page-btn <%=currentPage == totalPages ? "disabled" : ""%>">Last »</a>
                    </div>
                </div>
            </div>
        </main>

        <!-- ═══ CREATE MODAL ═══ -->
        <div class="modal-overlay" id="createModal">
            <div class="modal">
                <div class="modal-icon green"><i class="fas fa-plus"></i></div>
                <h3>New Equipment</h3>
                <form method="post" action="<%=ctx%>/numberEquipment" enctype="multipart/form-data" id="createForm">
                    <input type="hidden" name="action" value="create">
                    <input type="hidden" name="imageUrl" id="createImageUrl">
                    <div class="form-group">
                        <label>Model Name * (min 3 chars)</label>
                        <input type="text" name="model" required minlength="3" placeholder="e.g. Daikin VRV-IV">
                    </div>
                    <div class="form-group">
                        <label>Category</label>
                        <select name="categoryId">
                            <%for (Category cat : categories) {%>
                            <option value="<%=cat.getId()%>"><%=cat.getName()%></option>
                            <%}%>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <input type="text" name="description" maxlength="255" placeholder="Short description…">
                    </div>
                    <div class="form-group">
                        <label>Unit Price *</label>
                        <input type="number" name="unitPrice" required min="0" step="1000" value="0">
                    </div>
                    <div class="form-group">
                        <label><i class="fas fa-image" style="color:var(--primary-2)"></i> Product Image <span style="color:var(--text-s);font-weight:400;text-transform:none;letter-spacing:0">(optional)</span></label>
                        <div class="img-section">
                            <div class="img-tabs">
                                <button type="button" class="img-tab active" onclick="switchImgTab('create', 'file', this)"><i class="fas fa-upload"></i> Upload File</button>
                                <button type="button" class="img-tab" onclick="switchImgTab('create', 'url', this)"><i class="fas fa-link"></i> Image URL</button>
                            </div>
                            <div class="img-tab-content active" id="create-tab-file">
                                <div class="drop-zone" id="createDropZone" ondragover="handleDragOver(event,this)" ondragleave="handleDragLeave(this)" ondrop="handleDrop(event, 'create')">
                                    <input type="file" name="imageFile" id="createImageFile" accept="image/jpeg,image/png,image/webp,image/gif,image/avif" onchange="handleFileSelect(event, 'create')">
                                    <div class="drop-zone-icon"><i class="fas fa-cloud-arrow-up"></i></div>
                                    <div class="drop-zone-text"><strong>Click to browse</strong> or drag & drop</div>
                                    <div class="drop-zone-hint">JPG, PNG, WEBP, GIF, AVIF · Max 5MB</div>
                                </div>
                                <div class="img-preview-wrap" id="createFilePreview">
                                    <img id="createFilePreviewImg" src="" alt="preview">
                                    <button type="button" class="img-preview-remove" onclick="removeFilePreview('create')"><i class="fas fa-xmark"></i></button>
                                    <div class="img-preview-name" id="createFilePreviewName"></div>
                                </div>
                            </div>
                            <div class="img-tab-content" id="create-tab-url">
                                <div class="url-input-wrap">
                                    <input type="url" id="createUrlInput" placeholder="https://example.com/image.jpg">
                                    <button type="button" class="btn-load-url" onclick="loadUrlPreview('create')"><i class="fas fa-eye"></i> Preview</button>
                                </div>
                                <div class="img-preview-wrap" id="createUrlPreview" style="margin-top:10px">
                                    <img id="createUrlPreviewImg" src="" alt="preview" onerror="handleUrlImgError('create')">
                                    <button type="button" class="img-preview-remove" onclick="removeUrlPreview('create')"><i class="fas fa-xmark"></i></button>
                                    <div class="img-preview-name" id="createUrlPreviewName"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div style="padding:10px 14px;border-radius:10px;background:#f0fdf4;border:1.5px solid #a7f3d0;font-size:.76rem;color:var(--text-m);margin-bottom:14px">
                        <i class="fas fa-robot" style="color:var(--green);margin-right:6px"></i>
                        Serial number will be <strong style="color:var(--text-h)">auto-generated</strong> (UUID format: EQ-XXXX-XXXXXXXX)
                    </div>
                    <div class="modal-btns">
                        <button type="submit" class="mbtn mbtn-save" onclick="prepareCreateSubmit()"><i class="fas fa-save"></i> Save</button>
                        <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('createModal')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- ═══ EDIT MODAL ═══ -->
        <div class="modal-overlay" id="editModal">
            <div class="modal">
                <div class="modal-icon amber"><i class="fas fa-pen"></i></div>
                <h3>Edit Equipment</h3>
                <form method="post" action="<%=ctx%>/numberEquipment" enctype="multipart/form-data" id="editForm">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="id" id="editId">
                    <input type="hidden" name="imageUrl" id="editImageUrl">
                    <input type="hidden" name="clearImage" id="editClearImage" value="false">
                    <div class="form-group">
                        <label>Model Name *</label>
                        <input type="text" name="model" id="editModel" required minlength="3">
                    </div>
                    <div class="form-group">
                        <label>Category</label>
                        <select name="categoryId" id="editCategoryId">
                            <%for (Category cat : categories) {%>
                            <option value="<%=cat.getId()%>"><%=cat.getName()%></option>
                            <%}%>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <input type="text" name="description" id="editDesc" maxlength="255">
                    </div>
                    <div class="form-group">
                        <label>Unit Price *</label>
                        <input type="number" name="unitPrice" id="editPrice" required min="0" step="1000">
                    </div>
                    <div class="form-group">
                        <label><i class="fas fa-image" style="color:var(--primary-2)"></i> Product Image <span style="color:var(--text-s);font-weight:400;text-transform:none;letter-spacing:0">(optional)</span></label>
                        <div class="current-img-badge" id="editCurrentImgBadge" style="display:none">
                            <img id="editCurrentImgThumb" src="" alt="current">
                            <div style="flex:1;min-width:0">
                                <div class="cib-label"><i class="fas fa-circle-check"></i> Current Image</div>
                                <div class="cib-url" id="editCurrentImgUrl"></div>
                            </div>
                            <button type="button" class="btn-clear-img" onclick="clearCurrentImage()"><i class="fas fa-trash"></i> Remove</button>
                        </div>
                        <div class="img-section">
                            <div class="img-tabs">
                                <button type="button" class="img-tab active" onclick="switchImgTab('edit', 'file', this)"><i class="fas fa-upload"></i> Upload New</button>
                                <button type="button" class="img-tab" onclick="switchImgTab('edit', 'url', this)"><i class="fas fa-link"></i> Image URL</button>
                            </div>
                            <div class="img-tab-content active" id="edit-tab-file">
                                <div class="drop-zone" id="editDropZone" ondragover="handleDragOver(event,this)" ondragleave="handleDragLeave(this)" ondrop="handleDrop(event, 'edit')">
                                    <input type="file" name="imageFile" id="editImageFile" accept="image/jpeg,image/png,image/webp,image/gif,image/avif" onchange="handleFileSelect(event, 'edit')">
                                    <div class="drop-zone-icon"><i class="fas fa-cloud-arrow-up"></i></div>
                                    <div class="drop-zone-text"><strong>Click to browse</strong> or drag & drop</div>
                                    <div class="drop-zone-hint">JPG, PNG, WEBP, GIF, AVIF · Max 5MB</div>
                                </div>
                                <div class="img-preview-wrap" id="editFilePreview">
                                    <img id="editFilePreviewImg" src="" alt="preview">
                                    <button type="button" class="img-preview-remove" onclick="removeFilePreview('edit')"><i class="fas fa-xmark"></i></button>
                                    <div class="img-preview-name" id="editFilePreviewName"></div>
                                </div>
                            </div>
                            <div class="img-tab-content" id="edit-tab-url">
                                <div class="url-input-wrap">
                                    <input type="url" id="editUrlInput" placeholder="https://example.com/image.jpg">
                                    <button type="button" class="btn-load-url" onclick="loadUrlPreview('edit')"><i class="fas fa-eye"></i> Preview</button>
                                </div>
                                <div class="img-preview-wrap" id="editUrlPreview" style="margin-top:10px">
                                    <img id="editUrlPreviewImg" src="" alt="preview" onerror="handleUrlImgError('edit')">
                                    <button type="button" class="img-preview-remove" onclick="removeUrlPreview('edit')"><i class="fas fa-xmark"></i></button>
                                    <div class="img-preview-name" id="editUrlPreviewName"></div>
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

        <!-- ═══ DELETE MODAL ═══ -->
        <div class="modal-overlay" id="deleteModal">
            <div class="modal">
                <div class="modal-icon danger"><i class="fas fa-trash"></i></div>
                <h3>Confirm Delete</h3>
                <p>Are you sure you want to delete<br><strong id="deleteEqName"></strong>?<br>
                    <span style="color:var(--red);font-size:.78rem">This cannot be undone.</span></p>
                <form method="post" action="<%=ctx%>/numberEquipment">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteId">
                    <div class="modal-btns">
                        <button type="submit" class="mbtn mbtn-del"><i class="fas fa-trash"></i> Delete</button>
                        <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('deleteModal')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function openCreateModal() {
                resetImgSection('create');
                document.getElementById('createModal').classList.add('show');
            }
            function openEditModal(id, model, catId, desc, price, imgUrl) {
                document.getElementById('editId').value = id;
                document.getElementById('editModel').value = model;
                document.getElementById('editCategoryId').value = catId;
                document.getElementById('editDesc').value = desc;
                document.getElementById('editPrice').value = price;
                resetImgSection('edit');
                document.getElementById('editClearImage').value = 'false';
                if (imgUrl && imgUrl.trim() !== '') {
                    var badge = document.getElementById('editCurrentImgBadge');
                    var thumb = document.getElementById('editCurrentImgThumb');
                    var urlDisp = document.getElementById('editCurrentImgUrl');
                    var src = imgUrl.startsWith('http') ? imgUrl : '<%=ctx%>' + imgUrl;
                    thumb.src = src;
                    urlDisp.textContent = imgUrl;
                    badge.style.display = 'flex';
                    badge.dataset.original = imgUrl;
                }
                document.getElementById('editModal').classList.add('show');
            }
            function confirmDelete(id, name) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteEqName').textContent = name;
                document.getElementById('deleteModal').classList.add('show');
            }
            function closeModal(id) {
                document.getElementById(id).classList.remove('show');
            }
            window.addEventListener('click', function (e) {
                ['createModal', 'editModal', 'deleteModal'].forEach(function (id) {
                    var m = document.getElementById(id);
                    if (e.target === m)
                        m.classList.remove('show');
                });
            });
            function toggleRow(id) {
                var row = document.getElementById('expand-' + id);
                var icon = document.getElementById('icon-' + id);
                if (row.classList.contains('show')) {
                    row.classList.remove('show');
                    icon.style.transform = '';
                } else {
                    row.classList.add('show');
                    icon.style.transform = 'rotate(90deg)';
                }
            }
            function switchImgTab(prefix, tab, btn) {
                var section = btn.closest('.img-section');
                section.querySelectorAll('.img-tab').forEach(function (t) {
                    t.classList.remove('active');
                });
                section.querySelectorAll('.img-tab-content').forEach(function (c) {
                    c.classList.remove('active');
                });
                btn.classList.add('active');
                document.getElementById(prefix + '-tab-' + tab).classList.add('active');
                if (tab === 'file')
                    removeUrlPreview(prefix);
                else
                    removeFilePreview(prefix);
            }
            function handleFileSelect(event, prefix) {
                var file = event.target.files[0];
                if (!file)
                    return;
                if (file.size > 5 * 1024 * 1024) {
                    alert('Max 5MB');
                    event.target.value = '';
                    return;
                }
                showFilePreview(prefix, file);
            }
            function handleDragOver(event, zone) {
                event.preventDefault();
                zone.classList.add('drag-over');
            }
            function handleDragLeave(zone) {
                zone.classList.remove('drag-over');
            }
            function handleDrop(event, prefix) {
                event.preventDefault();
                var zone = document.getElementById(prefix + 'DropZone');
                zone.classList.remove('drag-over');
                var file = event.dataTransfer.files[0];
                if (!file || !file.type.startsWith('image/')) {
                    alert('Drop an image file');
                    return;
                }
                if (file.size > 5 * 1024 * 1024) {
                    alert('Max 5MB');
                    return;
                }
                var dt = new DataTransfer();
                dt.items.add(file);
                document.getElementById(prefix + 'ImageFile').files = dt.files;
                showFilePreview(prefix, file);
            }
            function showFilePreview(prefix, file) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    document.getElementById(prefix + 'FilePreviewImg').src = e.target.result;
                    document.getElementById(prefix + 'FilePreviewName').textContent = file.name + ' (' + (file.size / 1024).toFixed(1) + ' KB)';
                    document.getElementById(prefix + 'FilePreview').classList.add('show');
                };
                reader.readAsDataURL(file);
                if (prefix === 'edit')
                    hideBadge();
            }
            function removeFilePreview(prefix) {
                document.getElementById(prefix + 'FilePreviewImg').src = '';
                document.getElementById(prefix + 'FilePreview').classList.remove('show');
                document.getElementById(prefix + 'ImageFile').value = '';
                if (prefix === 'edit')
                    restoreBadge();
            }
            function loadUrlPreview(prefix) {
                var url = document.getElementById(prefix + 'UrlInput').value.trim();
                if (!url)
                    return;
                var img = document.getElementById(prefix + 'UrlPreviewImg');
                img.style.display = '';
                img.src = url;
                document.getElementById(prefix + 'UrlPreviewName').textContent = url;
                document.getElementById(prefix + 'UrlPreview').classList.add('show');
                if (prefix === 'edit')
                    hideBadge();
            }
            function handleUrlImgError(prefix) {
                document.getElementById(prefix + 'UrlPreviewName').textContent = '⚠ Could not load image';
                document.getElementById(prefix + 'UrlPreviewImg').style.display = 'none';
            }
            function removeUrlPreview(prefix) {
                var img = document.getElementById(prefix + 'UrlPreviewImg');
                img.src = '';
                img.style.display = '';
                document.getElementById(prefix + 'UrlInput').value = '';
                document.getElementById(prefix + 'UrlPreviewName').textContent = '';
                document.getElementById(prefix + 'UrlPreview').classList.remove('show');
                if (prefix === 'edit')
                    restoreBadge();
            }
            function hideBadge() {
                var b = document.getElementById('editCurrentImgBadge');
                if (b)
                    b.style.display = 'none';
            }
            function restoreBadge() {
                var b = document.getElementById('editCurrentImgBadge');
                if (b && b.dataset.original)
                    b.style.display = 'flex';
            }
            function clearCurrentImage() {
                var b = document.getElementById('editCurrentImgBadge');
                b.style.display = 'none';
                b.dataset.original = '';
                document.getElementById('editClearImage').value = 'true';
                document.getElementById('editImageUrl').value = '';
            }
            function resetImgSection(prefix) {
                removeFilePreview(prefix);
                removeUrlPreview(prefix);
                document.getElementById(prefix + 'ImageUrl').value = '';
                if (prefix === 'edit') {
                    var b = document.getElementById('editCurrentImgBadge');
                    b.style.display = 'none';
                    b.dataset.original = '';
                }
                var modal = document.getElementById(prefix + 'Modal');
                if (!modal)
                    return;
                modal.querySelectorAll('.img-tab').forEach(function (t, i) {
                    t.classList.toggle('active', i === 0);
                });
                modal.querySelectorAll('.img-tab-content').forEach(function (c, i) {
                    c.classList.toggle('active', i === 0);
                });
            }
            function prepareCreateSubmit() {
                var active = document.querySelector('#createModal .img-tab-content.active');
                if (active && active.id === 'create-tab-url') {
                    document.getElementById('createImageUrl').value = document.getElementById('createUrlInput').value.trim();
                    document.getElementById('createImageFile').value = '';
                } else {
                    document.getElementById('createImageUrl').value = '';
                }
            }
            function prepareEditSubmit() {
                var active = document.querySelector('#editModal .img-tab-content.active');
                if (active && active.id === 'edit-tab-url') {
                    document.getElementById('editImageUrl').value = document.getElementById('editUrlInput').value.trim();
                    document.getElementById('editImageFile').value = '';
                } else {
                    var badge = document.getElementById('editCurrentImgBadge');
                    var hasFile = document.getElementById('editImageFile').files.length > 0;
                    if (!hasFile && badge.style.display !== 'none' && badge.dataset.original)
                        document.getElementById('editImageUrl').value = badge.dataset.original;
                }
            }
        </script>
    </body>
</html>
