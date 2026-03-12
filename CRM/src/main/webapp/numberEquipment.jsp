<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.EquipmentType, model.EquipmentUnit, model.Category, java.util.*, java.text.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<EquipmentType> equipments = (List<EquipmentType>) request.getAttribute("equipments");
    List<Category> categories      = (List<Category>) request.getAttribute("categories");
    Map<Integer, List<EquipmentUnit>> unitsMap = (Map<Integer, List<EquipmentUnit>>) request.getAttribute("unitsMap");
    String keyword    = request.getAttribute("keyword")     != null ? (String)request.getAttribute("keyword")    : "";
    String categoryId = request.getAttribute("categoryId")  != null ? (String)request.getAttribute("categoryId") : "";
    String sortBy     = request.getAttribute("sortBy")      != null ? (String)request.getAttribute("sortBy")     : "";
    int currentPage   = request.getAttribute("currentPage") != null ? (int)request.getAttribute("currentPage")   : 1;
    int totalPages    = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages")    : 1;
    int total         = request.getAttribute("total")       != null ? (int)request.getAttribute("total")         : 0;
    if (equipments == null) equipments = new ArrayList<>();
    if (categories == null) categories = new ArrayList<>();
    if (unitsMap   == null) unitsMap   = new java.util.HashMap<>();

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    String flashError   = (String) session.getAttribute("flashError");
    session.removeAttribute("flashSuccess");
    session.removeAttribute("flashError");

    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
    String ctx = request.getContextPath();
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Equipment List - DRSMS</title>
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

        /* ════════ SIDEBAR ════════ */
        .sb {
            width: var(--sb-width); min-height: 100vh;
            background: rgba(9,15,40,0.95);
            backdrop-filter: blur(20px);
            border-right: 1px solid var(--border);
            display: flex; flex-direction: column;
            position: fixed; top: 0; left: 0; z-index: 100;
        }
        .sb-brand {
            padding: 22px 18px 16px;
            display: flex; align-items: center; gap: 10px;
            border-bottom: 1px solid var(--border);
        }
        .sb-logo {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, var(--green), var(--info));
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: var(--navy); font-size: 0.88rem;
            box-shadow: 0 4px 14px rgba(52,211,153,0.3);
            flex-shrink: 0;
        }
        .sb-name { color: #fff; font-size: 1rem; font-weight: 700; }
        .sb-role {
            display: inline-flex;
            background: rgba(52,211,153,0.12);
            border: 1px solid rgba(52,211,153,0.25);
            color: var(--green);
            font-size: 0.62rem; font-weight: 700;
            letter-spacing: 1px; text-transform: uppercase;
            padding: 2px 8px; border-radius: 20px; margin-top: 3px;
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
            padding: 9px 10px; border-radius: 9px; margin-bottom: 1px;
            color: rgba(255,255,255,0.45); text-decoration: none;
            font-size: 0.83rem; font-weight: 500;
            transition: all 0.2s; border-left: 2px solid transparent;
        }
        .sb-item i {
            width: 28px; height: 28px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.8rem; border-radius: 8px;
            background: rgba(255,255,255,0.05); flex-shrink: 0; transition: all 0.2s;
        }
        .sb-item.on {
            color: #fff;
            background: linear-gradient(90deg, rgba(56,189,248,0.15), rgba(56,189,248,0.04));
            border-left: 2px solid var(--info);
        }
        .sb-item.on i { background: rgba(56,189,248,0.2); color: var(--info); }

        .sb-item.si-home:hover     { color:#fff; background:rgba(79,126,248,0.1);    border-left-color:var(--accent);  }
        .sb-item.si-home:hover i   { background:rgba(79,126,248,0.2);  color:var(--accent-2); }
        .sb-item.si-stats:hover    { color:#fff; background:rgba(52,211,153,0.08);   border-left-color:var(--green);   }
        .sb-item.si-stats:hover i  { background:rgba(52,211,153,0.2);  color:var(--green);    }
        .sb-item.si-parts:hover    { color:#fff; background:rgba(251,191,36,0.08);   border-left-color:var(--amber);   }
        .sb-item.si-parts:hover i  { background:rgba(251,191,36,0.2);  color:var(--amber);    }
        .sb-item.si-equip:hover    { color:#fff; background:rgba(56,189,248,0.08);   border-left-color:var(--info);    }
        .sb-item.si-equip:hover i  { background:rgba(56,189,248,0.2);  color:var(--info);     }
        .sb-item.si-tx:hover       { color:#fff; background:rgba(167,139,250,0.08);  border-left-color:var(--purple);  }
        .sb-item.si-tx:hover i     { background:rgba(167,139,250,0.2); color:var(--purple);   }

        .sb-foot { padding: 12px 10px 16px; border-top: 1px solid var(--border); }
        .sb-user {
            display: flex; align-items: center; gap: 9px;
            padding: 10px; border-radius: 10px;
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
            margin-bottom: 6px; text-decoration: none; transition: all 0.2s;
        }
        .sb-user:hover { background: rgba(52,211,153,0.08); border-color: rgba(52,211,153,0.2); }
        .sb-ava {
            width: 34px; height: 34px; border-radius: 50%;
            background: linear-gradient(135deg, var(--green), var(--info));
            display: flex; align-items: center; justify-content: center;
            color: var(--navy); font-size: 0.88rem; font-weight: 700;
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

        /* ════════ MAIN ════════ */
        .main {
            margin-left: var(--sb-width); flex: 1; padding: 0;
            min-height: 100vh; display: flex; flex-direction: column;
        }
        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 22px 32px; border-bottom: 1px solid var(--border);
            background: rgba(11,20,55,0.6); backdrop-filter: blur(16px);
            position: sticky; top: 0; z-index: 50;
        }
        .topbar-title { font-size: 1.25rem; font-weight: 800; color: #fff; letter-spacing: -0.3px; }
        .topbar-sub { color: var(--muted); font-size: 0.8rem; margin-top: 2px; font-weight: 300; }
        .topbar-badge {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 8px 16px;
            background: rgba(56,189,248,0.08); border: 1px solid rgba(56,189,248,0.2);
            border-radius: 20px; color: var(--info); font-size: 0.8rem; font-weight: 600;
        }
        .content { padding: 28px 32px; flex: 1; }

        /* ── ANIMATIONS ── */
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── ALERTS ── */
        .alert {
            display: flex; align-items: center; gap: 12px;
            padding: 13px 18px; border-radius: 12px; margin-bottom: 18px;
            font-size: 0.84rem; animation: cardIn 0.4s ease both;
        }
        .alert i { font-size: 1rem; flex-shrink: 0; }
        .alert-success { background:var(--green-dim);  border:1px solid rgba(52,211,153,0.25);  color:var(--green);  }
        .alert-error   { background:var(--danger-dim); border:1px solid rgba(248,113,113,0.25); color:var(--danger); }

        /* ── SECTION LABEL ── */
        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 12px;
        }

        /* ── TOOLBAR ── */
        .toolbar {
            display: flex; gap: 10px; align-items: center;
            margin-bottom: 16px; flex-wrap: wrap;
        }
        .search-box {
            flex: 1; min-width: 200px; padding: 9px 14px;
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
            border-radius: 10px; color: var(--text);
            font-size: 0.83rem; font-family: inherit; outline: none;
            transition: border-color 0.2s;
        }
        .search-box::placeholder { color: var(--muted); }
        .search-box:focus { border-color: rgba(79,126,248,0.5); background: rgba(79,126,248,0.05); }
        .select-box {
            padding: 9px 12px;
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
            border-radius: 10px; color: var(--text);
            font-size: 0.83rem; font-family: inherit; outline: none; cursor: pointer;
            transition: border-color 0.2s;
        }
        .select-box option { background: #0f1c4d; color: #fff; }
        .select-box:focus { border-color: rgba(79,126,248,0.5); }

        .btn {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 9px 16px; border-radius: 10px; border: none;
            font-size: 0.82rem; font-weight: 600; font-family: inherit;
            cursor: pointer; text-decoration: none; transition: all 0.2s; white-space: nowrap;
        }
        .btn-search {
            background: rgba(79,126,248,0.15); color: var(--accent-2);
            border: 1px solid rgba(79,126,248,0.3);
        }
        .btn-search:hover { background: rgba(79,126,248,0.28); border-color: rgba(79,126,248,0.5); }
        .btn-reset {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 9px 14px; border-radius: 10px;
            background: rgba(248,113,113,0.1); border: 1px solid rgba(248,113,113,0.25);
            color: var(--danger); font-size: 0.82rem; font-weight: 600;
            font-family: inherit; cursor: pointer; text-decoration: none;
            transition: all 0.2s; white-space: nowrap;
        }
        .btn-reset:hover { background: rgba(248,113,113,0.2); border-color: rgba(248,113,113,0.4); }
        .btn-new {
            background: linear-gradient(135deg, var(--green), #059669);
            color: #fff; box-shadow: 0 4px 14px rgba(52,211,153,0.3);
        }
        .btn-new:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(52,211,153,0.4); }

        /* Filter tags */
        .filter-tags {
            display: flex; align-items: center; gap: 8px;
            flex-wrap: wrap; margin-bottom: 14px;
        }
        .filter-tag {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 10px; border-radius: 20px;
            background: rgba(79,126,248,0.1); border: 1px solid rgba(79,126,248,0.25);
            color: var(--accent-2); font-size: 0.72rem; font-weight: 600;
        }
        .filter-tag i { font-size: 0.65rem; opacity: 0.7; }
        .filter-tags-lbl { font-size: 0.72rem; color: var(--muted); font-weight: 500; }

        /* ── CARD / TABLE ── */
        .card {
            background: rgba(17,26,66,0.7); border: 1px solid var(--border);
            border-radius: 16px; overflow: hidden;
            backdrop-filter: blur(12px);
            animation: cardIn 0.5s 0.1s ease both;
        }
        .card-hd {
            display: flex; justify-content: space-between; align-items: center;
            padding: 14px 20px; border-bottom: 1px solid var(--border);
        }
        .card-title {
            font-size: 0.87rem; font-weight: 700; color: #fff;
            display: flex; align-items: center; gap: 8px;
        }
        .card-title i { color: var(--info); }
        .total-badge {
            font-size: 0.72rem; color: var(--muted);
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
            padding: 3px 10px; border-radius: 20px;
        }

        table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
        thead tr { background: rgba(255,255,255,0.02); }
        th {
            padding: 10px 16px; text-align: left;
            color: var(--muted); font-weight: 600;
            font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.8px;
            border-bottom: 1px solid var(--border);
        }
        td {
            padding: 12px 16px; border-bottom: 1px solid rgba(255,255,255,0.03);
            vertical-align: middle; color: var(--text-2);
        }
        tr:last-child td { border-bottom: none; }
        tbody tr { transition: background 0.15s; }
        tbody tr:not(.expand-row):hover td { background: rgba(79,126,248,0.05); }

        .td-model { font-weight: 700; color: var(--text); font-size: 0.82rem; }
        .td-cat {
            display: inline-flex; align-items: center;
            padding: 3px 9px; border-radius: 6px;
            background: var(--info-dim); border: 1px solid rgba(56,189,248,0.2);
            color: var(--info); font-size: 0.7rem; font-weight: 600;
        }
        .td-price { color: var(--green); font-weight: 700; font-size: 0.82rem; }
        .td-desc {
            max-width: 180px; overflow: hidden;
            text-overflow: ellipsis; white-space: nowrap;
            color: var(--muted); font-size: 0.75rem;
        }
        .units-count { font-size: 0.8rem; }
        .units-count .avail { color: var(--green); font-weight: 700; }
        .units-count .sep   { color: var(--muted); margin: 0 2px; }
        .units-count .total-u { color: var(--text-2); }
        .units-count .lbl   { color: var(--muted); font-size: 0.7rem; }

        /* Expand button */
        .expand-btn {
            width: 28px; height: 28px; border-radius: 8px;
            background: rgba(56,189,248,0.1); border: 1px solid rgba(56,189,248,0.2);
            color: var(--info); font-size: 0.75rem;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; transition: all 0.2s;
        }
        .expand-btn:hover { background: rgba(56,189,248,0.2); }
        .expand-btn i { transition: transform 0.2s; }

        /* Expand row */
        .expand-row { display: none; }
        .expand-row.show { display: table-row; }
        .expand-content {
            padding: 14px 20px 16px;
            background: rgba(11,20,55,0.5);
            border-top: 1px solid var(--border);
        }
        .expand-label {
            font-size: 0.68rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: 1px; color: var(--muted); margin-bottom: 10px;
            display: flex; align-items: center; gap: 8px;
        }
        .expand-label::after {
            content: ''; flex: 1; height: 1px; background: var(--border);
        }
        .serial-list { display: flex; flex-wrap: wrap; gap: 7px; margin-bottom: 10px; }
        .serial-badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 8px;
            font-size: 0.73rem; font-weight: 600;
        }
        .serial-badge::before { content:''; width:6px; height:6px; border-radius:50%; }
        .s-available { background:var(--green-dim);  color:var(--green);   border:1px solid rgba(52,211,153,0.2); }
        .s-available::before { background:var(--green); }
        .s-inuse     { background:rgba(79,126,248,0.1); color:var(--accent-2); border:1px solid rgba(79,126,248,0.2); }
        .s-inuse::before { background:var(--accent-2); }
        .s-faulty    { background:var(--amber-dim);  color:var(--amber);   border:1px solid rgba(251,191,36,0.2); }
        .s-faulty::before { background:var(--amber); }
        .s-retired   { background:rgba(255,255,255,0.04); color:var(--muted); border:1px solid var(--border); }
        .s-retired::before { background:var(--muted); }

        .expand-detail-link {
            color: var(--accent-2); font-size: 0.75rem; font-weight: 600;
            text-decoration: none; transition: color 0.2s;
        }
        .expand-detail-link:hover { color: #fff; }

        /* Action buttons */
        .action-btns { display: flex; gap: 6px; }
        .ab {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 5px 11px; border-radius: 8px; border: none;
            font-size: 0.73rem; font-weight: 600; font-family: inherit;
            cursor: pointer; text-decoration: none; transition: all 0.2s;
        }
        .ab-stock  { background:var(--green-dim);   color:var(--green);   border:1px solid rgba(52,211,153,0.25); }
        .ab-edit   { background:var(--amber-dim);   color:var(--amber);   border:1px solid rgba(251,191,36,0.25); }
        .ab-delete { background:var(--danger-dim);  color:var(--danger);  border:1px solid rgba(248,113,113,0.25); }
        .ab-stock:hover  { background:rgba(52,211,153,0.2); }
        .ab-edit:hover   { background:rgba(251,191,36,0.2); }
        .ab-delete:hover { background:rgba(248,113,113,0.2); }

        /* ── PAGINATION ── */
        .pagination {
            display: flex; justify-content: center; align-items: center;
            gap: 6px; padding: 16px; border-top: 1px solid var(--border);
        }
        .page-btn {
            padding: 6px 13px; border-radius: 8px;
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
            font-size: 0.78rem; color: var(--text-2);
            cursor: pointer; text-decoration: none; transition: all 0.2s; font-family: inherit;
        }
        .page-btn.active { background: var(--accent); border-color: var(--accent); color: #fff; font-weight: 700; }
        .page-btn:hover:not(.active):not(.disabled) { background: rgba(79,126,248,0.12); border-color: rgba(79,126,248,0.3); color: #fff; }
        .page-btn.disabled { opacity: 0.3; pointer-events: none; }
        .paging-info { color: var(--muted); font-size: 0.75rem; }

        /* ── EMPTY ── */
        .empty {
            text-align: center; padding: 48px 24px;
            color: var(--muted); font-size: 0.82rem;
        }
        .empty i { font-size: 2.2rem; display: block; margin-bottom: 12px; opacity: 0.2; }

        /* ── MODAL ── */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.65); backdrop-filter: blur(6px);
            z-index: 1000; align-items: center; justify-content: center;
        }
        .modal-overlay.show { display: flex; }
        .modal {
            background: var(--navy-card); border: 1px solid var(--border);
            border-radius: 16px; padding: 28px;
            width: 480px; max-width: 95vw;
            box-shadow: 0 24px 80px rgba(0,0,0,0.5);
            animation: cardIn 0.25s ease;
        }
        .modal-icon {
            width: 52px; height: 52px; border-radius: 14px; margin: 0 auto 16px;
            display: flex; align-items: center; justify-content: center; font-size: 1.4rem;
        }
        .modal-icon.green  { background:var(--green-dim);  color:var(--green);  }
        .modal-icon.amber  { background:var(--amber-dim);  color:var(--amber);  }
        .modal-icon.info   { background:var(--info-dim);   color:var(--info);   }
        .modal-icon.danger { background:var(--danger-dim); color:var(--danger); }
        .modal h3 {
            font-size: 1rem; font-weight: 800; color: #fff;
            text-align: center; margin-bottom: 4px;
        }
        .modal-sub {
            text-align: center; color: var(--muted);
            font-size: 0.8rem; margin-bottom: 20px;
        }
        .modal p { color: var(--text-2); font-size: 0.83rem; text-align: center; line-height: 1.6; margin-bottom: 20px; }
        .modal p strong { color: #fff; }
        .form-group { margin-bottom: 14px; }
        .form-group label {
            display: block; font-size: 0.75rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase; letter-spacing: 0.8px; margin-bottom: 6px;
        }
        .form-group input,
        .form-group select {
            width: 100%; padding: 9px 13px;
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
            border-radius: 9px; color: var(--text);
            font-size: 0.83rem; font-family: inherit; outline: none; transition: border-color 0.2s;
        }
        .form-group input:focus,
        .form-group select:focus { border-color: rgba(79,126,248,0.5); background: rgba(79,126,248,0.05); }
        .form-group select option { background: #0f1c4d; }
        .modal-btns { display: flex; gap: 10px; margin-top: 20px; }
        .mbtn {
            flex: 1; padding: 10px; border-radius: 10px; border: none;
            font-size: 0.88rem; font-weight: 700; font-family: inherit; cursor: pointer; transition: all 0.2s;
        }
        .mbtn-save   { background: linear-gradient(135deg, var(--green), #059669); color: #fff; }
        .mbtn-save:hover { opacity: 0.9; transform: translateY(-1px); }
        .mbtn-stock  { background: linear-gradient(135deg, var(--info), #0284c7); color: #fff; }
        .mbtn-stock:hover { opacity: 0.9; transform: translateY(-1px); }
        .mbtn-del    { background: var(--danger-dim); color: var(--danger); border: 1px solid rgba(248,113,113,0.3); }
        .mbtn-del:hover { background: rgba(248,113,113,0.2); }
        .mbtn-cancel { background: rgba(255,255,255,0.06); color: var(--muted); border: 1px solid var(--border); }
        .mbtn-cancel:hover { background: rgba(255,255,255,0.1); color: var(--text); }
    </style>
</head>
<body>

    <!-- ═══════════ SIDEBAR ═══════════ -->
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
            <a href="<%=ctx%>/dashboard.jsp" class="sb-item si-home">
                <i class="fas fa-home"></i> Home
            </a>
            <a href="<%=ctx%>/storekeeper" class="sb-item si-stats">
                <i class="fas fa-chart-bar"></i> Statistics
            </a>
            <div class="sb-lbl">Inventory</div>
            <a href="<%=ctx%>/numberPart" class="sb-item si-parts">
                <i class="fas fa-puzzle-piece"></i> Parts List
            </a>
            <a href="<%=ctx%>/numberEquipment" class="sb-item on si-equip">
                <i class="fas fa-desktop"></i> Equipment List
            </a>
            <div class="sb-lbl">Records</div>
            <a href="<%=ctx%>/transactions" class="sb-item si-tx">
                <i class="fas fa-history"></i> Transaction History
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
                    <div class="sb-uname"><%=currentUser.getFullName()!=null?currentUser.getFullName():currentUser.getUsername()%></div>
                    <div class="sb-urole">Storekeeper</div>
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
                <div class="topbar-title">Equipment List</div>
                <div class="topbar-sub">Manage equipment models, units, and serial numbers.</div>
            </div>
            <div class="topbar-badge">
                <i class="fas fa-desktop"></i>
                <%=currentUser.getFullName()!=null?currentUser.getFullName():currentUser.getUsername()%>
            </div>
        </div>

        <div class="content">

            <%if(flashSuccess!=null){%>
            <div class="alert alert-success"><i class="fas fa-circle-check"></i> <%=flashSuccess%></div>
            <%}%>
            <%if(flashError!=null){%>
            <div class="alert alert-error"><i class="fas fa-circle-exclamation"></i> <%=flashError%></div>
            <%}%>

            <!-- TOOLBAR -->
            <div class="section-lbl">Filter & Search</div>
            <form method="get" action="<%=ctx%>/numberEquipment" id="filterForm">
                <div class="toolbar">
                    <input class="search-box" type="text" name="keyword"
                           placeholder="🔍  Search by model or description…"
                           value="<%=keyword!=null?keyword:""%>">

                    <select class="select-box" name="categoryId" onchange="this.form.submit()">
                        <option value="">All Categories</option>
                        <%for(Category cat:categories){%>
                        <option value="<%=cat.getId()%>" <%=String.valueOf(cat.getId()).equals(categoryId)?"selected":""%>>
                            <%=cat.getName()%>
                        </option>
                        <%}%>
                    </select>

                    <select class="select-box" name="sortBy" onchange="this.form.submit()">
                        <option value="">Sort by…</option>
                        <option value="name_asc"   <%="name_asc".equals(sortBy)  ?"selected":""%>>Name A–Z</option>
                        <option value="name_desc"  <%="name_desc".equals(sortBy) ?"selected":""%>>Name Z–A</option>
                        <option value="price_asc"  <%="price_asc".equals(sortBy) ?"selected":""%>>Price ↑</option>
                        <option value="price_desc" <%="price_desc".equals(sortBy)?"selected":""%>>Price ↓</option>
                    </select>

                    <button type="submit" class="btn btn-search">
                        <i class="fas fa-magnifying-glass"></i> Search
                    </button>
                    <a href="<%=ctx%>/numberEquipment" class="btn-reset">
                        <i class="fas fa-filter-circle-xmark"></i> Reset Filters
                    </a>
                    <button type="button" class="btn btn-new" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> New Equipment
                    </button>
                </div>
            </form>

            <!-- Filter tags -->
            <div class="filter-tags">
                <span class="filter-tags-lbl">Active filters:</span>
                <%if(!keyword.isEmpty()){%>
                <span class="filter-tag"><i class="fas fa-magnifying-glass"></i> "<%=keyword%>"</span>
                <%}%>
                <%if(!categoryId.isEmpty()){
                    String catName = categoryId;
                    for(Category c:categories){ if(String.valueOf(c.getId()).equals(categoryId)){ catName=c.getName(); break; } }
                %>
                <span class="filter-tag"><i class="fas fa-tag"></i> <%=catName%></span>
                <%}%>
                <%if(!sortBy.isEmpty()){%>
                <span class="filter-tag"><i class="fas fa-arrow-up-a-z"></i> <%=sortBy.replace("_"," ")%></span>
                <%}%>
                <%if(keyword.isEmpty()&&categoryId.isEmpty()&&sortBy.isEmpty()){%>
                <span style="color:var(--muted);font-size:0.72rem;font-style:italic">None</span>
                <%}%>
            </div>

            <!-- TABLE -->
            <div class="section-lbl">Equipment Models (<%=total%> found)</div>
            <div class="card">
                <div class="card-hd">
                    <div class="card-title"><i class="fas fa-desktop"></i> Equipment Types</div>
                    <span class="total-badge"><%=total%> records · Page <%=currentPage%> of <%=totalPages%></span>
                </div>

                <%if(equipments.isEmpty()){%>
                <div class="empty">
                    <i class="fas fa-server"></i>
                    No equipment found matching your filters.<br>
                    <a href="<%=ctx%>/numberEquipment" style="color:var(--accent-2);font-weight:700;text-decoration:none;margin-top:8px;display:inline-block">Clear filters</a>
                </div>
                <%}else{%>
                <table>
                    <thead>
                        <tr>
                            <th style="width:44px"></th>
                            <th>Model</th>
                            <th>Category</th>
                            <th>Description</th>
                            <th>Unit Price</th>
                            <th>Units</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%for(EquipmentType et:equipments){%>
                    <tr>
                        <td>
                            <button class="expand-btn" onclick="toggleRow(<%=et.getId()%>)">
                                <i class="fas fa-chevron-right" id="icon-<%=et.getId()%>"></i>
                            </button>
                        </td>
                        <td class="td-model"><%=et.getModel()%></td>
                        <td><span class="td-cat"><%=et.getCategoryName()%></span></td>
                        <td class="td-desc" title="<%=et.getDescription()!=null?et.getDescription():""%>">
                            <%=et.getDescription()!=null?et.getDescription():"—"%>
                        </td>
                        <td class="td-price"><%=nf.format((long)et.getUnitPrice())%> ₫</td>
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
                                <button class="ab ab-stock"
                                    onclick="openAddUnitModal(<%=et.getId()%>,'<%=et.getModel().replace("'","\\'")%>')">
                                    <i class="fas fa-plus"></i> Stock In
                                </button>
                                <button class="ab ab-edit"
                                    onclick="openEditModal(<%=et.getId()%>,'<%=et.getModel().replace("'","\\'")%>',<%=et.getCategoryId()%>,'<%=et.getDescription()!=null?et.getDescription().replace("'","\\'"):""%>',<%=et.getUnitPrice()%>)">
                                    <i class="fas fa-pen"></i> Edit
                                </button>
                                <button class="ab ab-delete"
                                    onclick="confirmDelete(<%=et.getId()%>,'<%=et.getModel().replace("'","\\'")%>')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                    <!-- Expand Row -->
                    <tr class="expand-row" id="expand-<%=et.getId()%>">
                        <td colspan="7">
                            <div class="expand-content">
                                <%
                                    List<EquipmentUnit> etUnits = unitsMap.getOrDefault(et.getId(), new ArrayList<>());
                                    // group by status counts for summary
                                    int cntAvail=0, cntInuse=0, cntFaulty=0, cntRetired=0;
                                    for(EquipmentUnit eu : etUnits) {
                                        String st = eu.getStatus().toUpperCase();
                                        if("AVAILABLE".equals(st))    cntAvail++;
                                        else if("IN_USE".equals(st)||"INUSE".equals(st)) cntInuse++;
                                        else if("FAULTY".equals(st))  cntFaulty++;
                                        else if("RETIRED".equals(st)) cntRetired++;
                                    }
                                %>
                                <!-- Summary mini stats -->
                                <div style="display:flex;align-items:center;gap:12px;margin-bottom:12px;flex-wrap:wrap">
                                    <div class="expand-label" style="margin:0;flex:1">
                                        Serial Numbers
                                        <span style="color:var(--text-2);font-size:0.72rem;font-weight:400;text-transform:none;letter-spacing:0;margin-left:4px">(<%=etUnits.size()%> units)</span>
                                    </div>
                                    <div style="display:flex;gap:8px;flex-wrap:wrap">
                                        <%if(cntAvail>0){%>
                                        <span style="display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;background:var(--green-dim);border:1px solid rgba(52,211,153,0.2);color:var(--green);font-size:0.7rem;font-weight:700">
                                            <i class="fas fa-circle-check" style="font-size:0.6rem"></i> <%=cntAvail%> Available
                                        </span><%}%>
                                        <%if(cntInuse>0){%>
                                        <span style="display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;background:rgba(79,126,248,0.1);border:1px solid rgba(79,126,248,0.2);color:var(--accent-2);font-size:0.7rem;font-weight:700">
                                            <i class="fas fa-screwdriver-wrench" style="font-size:0.6rem"></i> <%=cntInuse%> In Use
                                        </span><%}%>
                                        <%if(cntFaulty>0){%>
                                        <span style="display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;background:var(--amber-dim);border:1px solid rgba(251,191,36,0.2);color:var(--amber);font-size:0.7rem;font-weight:700">
                                            <i class="fas fa-triangle-exclamation" style="font-size:0.6rem"></i> <%=cntFaulty%> Faulty
                                        </span><%}%>
                                        <%if(cntRetired>0){%>
                                        <span style="display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;background:rgba(255,255,255,0.05);border:1px solid var(--border);color:var(--muted);font-size:0.7rem;font-weight:700">
                                            <i class="fas fa-archive" style="font-size:0.6rem"></i> <%=cntRetired%> Retired
                                        </span><%}%>
                                    </div>
                                </div>

                                <!-- Serial badges -->
                                <%if(etUnits.isEmpty()){%>
                                <div style="color:var(--muted);font-size:0.78rem;font-style:italic;padding:8px 0">
                                    <i class="fas fa-inbox" style="margin-right:6px;opacity:0.4"></i> No units in stock yet.
                                </div>
                                <%}else{%>
                                <div class="serial-list">
                                    <%for(EquipmentUnit eu : etUnits){
                                        String st = eu.getStatus().toLowerCase();
                                        String badgeClass = "s-" + (st.equals("in_use")||st.equals("inuse") ? "inuse" : st);
                                    %>
                                    <span class="serial-badge <%=badgeClass%>">
                                        <%=eu.getSerialNumber()%>
                                        <span style="opacity:0.55;font-weight:400;font-size:0.65rem;margin-left:2px">(<%=eu.getStatus()%>)</span>
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

                <!-- PAGINATION -->
                <div class="pagination">
                    <span class="paging-info">Page <%=currentPage%> / <%=totalPages%> · <%=total%> models total</span>
                    &nbsp;
                    <a href="<%=ctx%>/numberEquipment?page=1&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                       class="page-btn <%=currentPage==1?"disabled":""%>">«</a>
                    <a href="<%=ctx%>/numberEquipment?page=<%=Math.max(1,currentPage-1)%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                       class="page-btn <%=currentPage==1?"disabled":""%>">‹</a>
                    <%for(int p=Math.max(1,currentPage-2);p<=Math.min(totalPages,currentPage+2);p++){%>
                    <a href="<%=ctx%>/numberEquipment?page=<%=p%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                       class="page-btn <%=p==currentPage?"active":""%>"><%=p%></a>
                    <%}%>
                    <a href="<%=ctx%>/numberEquipment?page=<%=Math.min(totalPages,currentPage+1)%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                       class="page-btn <%=currentPage==totalPages?"disabled":""%>">›</a>
                    <a href="<%=ctx%>/numberEquipment?page=<%=totalPages%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                       class="page-btn <%=currentPage==totalPages?"disabled":""%>">»</a>
                </div>
            </div>

        </div><!-- /content -->
    </main>

    <!-- ═══════ CREATE MODAL ═══════ -->
    <div class="modal-overlay" id="createModal">
        <div class="modal">
            <div class="modal-icon green"><i class="fas fa-plus"></i></div>
            <h3>New Equipment</h3>
            <div class="modal-sub">Register a new equipment model with initial unit</div>
            <form method="post" action="<%=ctx%>/numberEquipment">
                <input type="hidden" name="action" value="create">
                <div class="form-group">
                    <label>Model Name <span style="color:var(--danger)">*</span> (min 3 chars)</label>
                    <input type="text" name="model" required minlength="3" placeholder="e.g. Daikin VRV-IV">
                </div>
                <div class="form-group">
                    <label>Category</label>
                    <select name="categoryId">
                        <%for(Category cat:categories){%>
                        <option value="<%=cat.getId()%>"><%=cat.getName()%></option>
                        <%}%>
                    </select>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <input type="text" name="description" maxlength="255" placeholder="Short description…">
                </div>
                <div class="form-group">
                    <label>Unit Price <span style="color:var(--danger)">*</span></label>
                    <input type="number" name="unitPrice" required min="0" step="1000" value="0">
                </div>
                <div class="form-group">
                    <label>Serial Number <span style="color:var(--danger)">*</span> (first unit)</label>
                    <input type="text" name="serialNumber" required placeholder="e.g. DAI-VRV4-003">
                </div>
                <div class="modal-btns">
                    <button type="submit" class="mbtn mbtn-save"><i class="fas fa-save"></i> Save</button>
                    <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('createModal')">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- ═══════ EDIT MODAL ═══════ -->
    <div class="modal-overlay" id="editModal">
        <div class="modal">
            <div class="modal-icon amber"><i class="fas fa-pen"></i></div>
            <h3>Edit Equipment</h3>
            <div class="modal-sub">Update model information</div>
            <form method="post" action="<%=ctx%>/numberEquipment">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="editId">
                <div class="form-group">
                    <label>Model Name <span style="color:var(--danger)">*</span></label>
                    <input type="text" name="model" id="editModel" required minlength="3">
                </div>
                <div class="form-group">
                    <label>Category</label>
                    <select name="categoryId" id="editCategoryId">
                        <%for(Category cat:categories){%>
                        <option value="<%=cat.getId()%>"><%=cat.getName()%></option>
                        <%}%>
                    </select>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <input type="text" name="description" id="editDesc">
                </div>
                <div class="form-group">
                    <label>Unit Price <span style="color:var(--danger)">*</span></label>
                    <input type="number" name="unitPrice" id="editPrice" required min="0" step="1000">
                </div>
                <div class="modal-btns">
                    <button type="submit" class="mbtn mbtn-save"><i class="fas fa-save"></i> Save</button>
                    <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('editModal')">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- ═══════ ADD UNIT MODAL ═══════ -->
    <div class="modal-overlay" id="addUnitModal">
        <div class="modal" style="width:500px">
            <div class="modal-icon info"><i class="fas fa-boxes-stacked"></i></div>
            <h3>Stock In Equipment</h3>
            <div class="modal-sub" id="addUnitModelName" style="color:var(--accent-2)"></div>
            <form method="post" action="<%=ctx%>/numberEquipment" id="addUnitForm" onsubmit="return prepareSerials()">
                <input type="hidden" name="action" value="addUnit">
                <input type="hidden" name="equipmentTypeId" id="addUnitTypeId">
                <input type="hidden" name="serialNumbers" id="serialNumbersHidden">

                <!-- Prefix + Quantity -->
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:14px">
                    <div class="form-group" style="margin:0">
                        <label>Serial Prefix <span style="color:var(--danger)">*</span></label>
                        <input type="text" id="serialPrefix" placeholder="e.g. DAI-VRV4"
                               oninput="generatePreview()"
                               style="width:100%;padding:9px 13px;background:rgba(255,255,255,0.04);border:1px solid var(--border);border-radius:9px;color:var(--text);font-size:0.83rem;font-family:inherit;outline:none;transition:border-color 0.2s"
                               onfocus="this.style.borderColor='rgba(79,126,248,0.5)';this.style.background='rgba(79,126,248,0.05)'"
                               onblur="this.style.borderColor='var(--border)';this.style.background='rgba(255,255,255,0.04)'">
                    </div>
                    <div class="form-group" style="margin:0">
                        <label>Start Number</label>
                        <input type="number" id="serialStart" value="1" min="1" max="9999"
                               oninput="generatePreview()"
                               style="width:100%;padding:9px 13px;background:rgba(255,255,255,0.04);border:1px solid var(--border);border-radius:9px;color:var(--text);font-size:0.83rem;font-family:inherit;outline:none;transition:border-color 0.2s"
                               onfocus="this.style.borderColor='rgba(79,126,248,0.5)';this.style.background='rgba(79,126,248,0.05)'"
                               onblur="this.style.borderColor='var(--border)';this.style.background='rgba(255,255,255,0.04)'">
                    </div>
                </div>

                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:16px">
                    <div class="form-group" style="margin:0">
                        <label>Quantity <span style="color:var(--danger)">*</span></label>
                        <input type="number" id="serialQty" value="1" min="1" max="100"
                               oninput="generatePreview()"
                               style="width:100%;padding:9px 13px;background:rgba(255,255,255,0.04);border:1px solid var(--border);border-radius:9px;color:var(--text);font-size:0.83rem;font-family:inherit;outline:none;transition:border-color 0.2s"
                               onfocus="this.style.borderColor='rgba(79,126,248,0.5)';this.style.background='rgba(79,126,248,0.05)'"
                               onblur="this.style.borderColor='var(--border)';this.style.background='rgba(255,255,255,0.04)'">
                    </div>
                    <div class="form-group" style="margin:0">
                        <label>Padding Digits</label>
                        <select id="serialPad" onchange="generatePreview()"
                                style="width:100%;padding:9px 13px;background:rgba(255,255,255,0.04);border:1px solid var(--border);border-radius:9px;color:var(--text);font-size:0.83rem;font-family:inherit;outline:none;cursor:pointer">
                            <option value="1">None (1, 2, 3…)</option>
                            <option value="2">2 digits (01, 02…)</option>
                            <option value="3" selected>3 digits (001, 002…)</option>
                            <option value="4">4 digits (0001, 0002…)</option>
                        </select>
                    </div>
                </div>

                <!-- Preview -->
                <div style="margin-bottom:16px">
                    <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--muted);margin-bottom:8px">
                        Preview <span id="previewCount" style="color:var(--accent-2)"></span>
                    </div>
                    <div id="serialPreview"
                         style="display:flex;flex-wrap:wrap;gap:6px;padding:12px 14px;border-radius:10px;background:rgba(255,255,255,0.025);border:1px solid var(--border);min-height:44px;max-height:110px;overflow-y:auto">
                        <span style="color:var(--muted);font-size:0.75rem;font-style:italic">Fill in the fields above to preview serials…</span>
                    </div>
                </div>

                <div style="padding:10px 14px;border-radius:10px;background:rgba(56,189,248,0.06);border:1px solid rgba(56,189,248,0.15);font-size:0.75rem;color:var(--muted);margin-bottom:4px">
                    <i class="fas fa-circle-info" style="color:var(--info);margin-right:6px"></i>
                    Format: <code style="color:var(--accent-2)">{Prefix}-{Number}</code> — e.g. <strong style="color:#fff">DAI-VRV4-001</strong>
                </div>

                <div class="modal-btns">
                    <button type="submit" class="mbtn mbtn-stock">
                        <i class="fas fa-boxes-stacked"></i> Stock In
                    </button>
                    <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('addUnitModal')">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- ═══════ DELETE MODAL ═══════ -->
    <div class="modal-overlay" id="deleteModal">
        <div class="modal">
            <div class="modal-icon danger"><i class="fas fa-trash"></i></div>
            <h3>Confirm Delete</h3>
            <p>
                Are you sure you want to delete<br>
                <strong id="deleteEqName"></strong>?<br>
                <span style="color:var(--danger);font-size:0.78rem">This action cannot be undone.</span>
            </p>
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
        function toggleRow(id) {
            var row  = document.getElementById('expand-' + id);
            var icon = document.getElementById('icon-' + id);
            if (row.classList.contains('show')) {
                row.classList.remove('show');
                icon.style.transform = '';
            } else {
                row.classList.add('show');
                icon.style.transform = 'rotate(90deg)';
            }
        }
        function openCreateModal()  { document.getElementById('createModal').classList.add('show'); }
        function openEditModal(id, model, catId, desc, price) {
            document.getElementById('editId').value         = id;
            document.getElementById('editModel').value      = model;
            document.getElementById('editCategoryId').value = catId;
            document.getElementById('editDesc').value       = desc;
            document.getElementById('editPrice').value      = price;
            document.getElementById('editModal').classList.add('show');
        }
        function openAddUnitModal(typeId, model) {
            document.getElementById('addUnitTypeId').value          = typeId;
            document.getElementById('addUnitModelName').textContent = model;
            // suggest prefix from model name
            var prefix = model.replace(/\s+/g, '-').toUpperCase().substring(0, 12);
            document.getElementById('serialPrefix').value = prefix;
            document.getElementById('serialStart').value  = 1;
            document.getElementById('serialQty').value    = 1;
            document.getElementById('serialPad').value    = 3;
            generatePreview();
            document.getElementById('addUnitModal').classList.add('show');
        }
        function pad(n, digits) {
            return String(n).padStart(digits, '0');
        }
        function generatePreview() {
            var prefix = document.getElementById('serialPrefix').value.trim();
            var start  = parseInt(document.getElementById('serialStart').value) || 1;
            var qty    = Math.min(Math.max(parseInt(document.getElementById('serialQty').value) || 1, 1), 100);
            var digits = parseInt(document.getElementById('serialPad').value) || 3;
            var box    = document.getElementById('serialPreview');
            var countEl = document.getElementById('previewCount');

            if (!prefix) {
                box.innerHTML = '<span style="color:var(--muted);font-size:0.75rem;font-style:italic">Enter a prefix to preview…</span>';
                countEl.textContent = '';
                return;
            }

            var html = '';
            for (var i = 0; i < qty; i++) {
                var serial = prefix + '-' + pad(start + i, digits);
                html += '<span style="display:inline-flex;align-items:center;padding:3px 9px;border-radius:8px;background:var(--green-dim);border:1px solid rgba(52,211,153,0.2);color:var(--green);font-size:0.72rem;font-weight:600">' + serial + '</span>';
            }
            box.innerHTML = html;
            countEl.textContent = '(' + qty + ' unit' + (qty > 1 ? 's' : '') + ')';
        }
        function prepareSerials() {
            var prefix = document.getElementById('serialPrefix').value.trim();
            var start  = parseInt(document.getElementById('serialStart').value) || 1;
            var qty    = Math.min(Math.max(parseInt(document.getElementById('serialQty').value) || 1, 1), 100);
            var digits = parseInt(document.getElementById('serialPad').value) || 3;

            if (!prefix) { alert('Please enter a serial prefix.'); return false; }
            if (qty < 1)  { alert('Quantity must be at least 1.');  return false; }

            var serials = [];
            for (var i = 0; i < qty; i++) {
                serials.push(prefix + '-' + pad(start + i, digits));
            }
            document.getElementById('serialNumbersHidden').value = serials.join(',');
            return true;
        }
        function confirmDelete(id, name) {
            document.getElementById('deleteId').value           = id;
            document.getElementById('deleteEqName').textContent = name;
            document.getElementById('deleteModal').classList.add('show');
        }
        function closeModal(id) { document.getElementById(id).classList.remove('show'); }
        window.addEventListener('click', function(e) {
            ['createModal','editModal','addUnitModal','deleteModal'].forEach(function(id){
                var m = document.getElementById(id);
                if (e.target === m) m.classList.remove('show');
            });
        });
    </script>
</body>
</html>
