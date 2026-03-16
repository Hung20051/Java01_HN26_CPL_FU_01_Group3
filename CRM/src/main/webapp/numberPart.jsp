<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.PartType, model.PartUnit, model.Category, java.util.*, java.text.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"STOREKEEPER".equals(currentUser.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<PartType> parts      = (List<PartType>) request.getAttribute("parts");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    PartType detailPart       = (PartType) request.getAttribute("detailPart");
    List<PartUnit> units      = (List<PartUnit>) request.getAttribute("units");
    String keyword    = request.getAttribute("keyword")     != null ? (String)request.getAttribute("keyword")    : "";
    String categoryId = request.getAttribute("categoryId")  != null ? (String)request.getAttribute("categoryId") : "";
    String sortBy     = request.getAttribute("sortBy")      != null ? (String)request.getAttribute("sortBy")     : "";
    int currentPage   = request.getAttribute("currentPage") != null ? (int)request.getAttribute("currentPage")   : 1;
    int totalPages    = request.getAttribute("totalPages")  != null ? (int)request.getAttribute("totalPages")    : 1;
    int total         = request.getAttribute("total")       != null ? (int)request.getAttribute("total")         : 0;
    if (parts      == null) parts      = new ArrayList<>();
    if (categories == null) categories = new ArrayList<>();

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    String flashError   = (String) session.getAttribute("flashError");
    session.removeAttribute("flashSuccess");
    session.removeAttribute("flashError");

    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
    String ctx = request.getContextPath();
    String initials = currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
        ? currentUser.getFullName().substring(0,1).toUpperCase() : "?";

    boolean hasFilter = !keyword.isEmpty() || !categoryId.isEmpty() || !sortBy.isEmpty();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parts List - DRSMS</title>
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
            display: inline-flex; align-items: center;
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
            background: linear-gradient(90deg, rgba(251,191,36,0.15), rgba(251,191,36,0.04));
            border-left: 2px solid var(--amber);
        }
        .sb-item.on i { background: rgba(251,191,36,0.2); color: var(--amber); }

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
            background: rgba(251,191,36,0.08); border: 1px solid rgba(251,191,36,0.2);
            border-radius: 20px; color: var(--amber); font-size: 0.8rem; font-weight: 600;
        }
        .content { padding: 28px 32px; flex: 1; }

        /* ── ALERTS ── */
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .alert {
            display: flex; align-items: center; gap: 12px;
            padding: 13px 18px; border-radius: 12px; margin-bottom: 18px;
            font-size: 0.84rem; animation: cardIn 0.4s ease both;
        }
        .alert i { font-size: 1rem; flex-shrink: 0; }
        .alert-success {
            background: var(--green-dim); border: 1px solid rgba(52,211,153,0.25); color: var(--green);
        }
        .alert-error {
            background: var(--danger-dim); border: 1px solid rgba(248,113,113,0.25); color: var(--danger);
        }

        /* ── DETAIL PANEL ── */
        .detail-panel {
            background: rgba(17,26,66,0.8); border: 1px solid rgba(79,126,248,0.25);
            border-radius: 14px; padding: 18px 20px; margin-bottom: 22px;
            animation: cardIn 0.4s ease both;
        }
        .detail-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 14px;
        }
        .detail-title {
            font-size: 0.9rem; font-weight: 700; color: #fff;
            display: flex; align-items: center; gap: 8px;
        }
        .detail-title i { color: var(--accent-2); }
        .detail-stats { display: grid; grid-template-columns: repeat(4,1fr); gap: 10px; }
        .detail-stat {
            border-radius: 11px; padding: 14px 16px;
            border: 1px solid var(--border);
            background: rgba(255,255,255,0.025);
            position: relative; overflow: hidden;
        }
        .detail-stat::after {
            content:''; position:absolute; top:0; right:0; bottom:0;
            width:3px; border-radius:0 11px 11px 0;
        }
        .ds-av::after  { background: var(--green);  }
        .ds-fa::after  { background: var(--amber);  }
        .ds-iu::after  { background: var(--accent-2);}
        .ds-rt::after  { background: var(--muted);  }
        .detail-stat-label {
            font-size: 0.62rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: 1px; color: var(--muted); margin-bottom: 6px;
        }
        .detail-stat-value { font-size: 1.8rem; font-weight: 800; line-height: 1; }
        .ds-av .detail-stat-value { color: var(--green);   }
        .ds-fa .detail-stat-value { color: var(--amber);   }
        .ds-iu .detail-stat-value { color: var(--accent-2);}
        .ds-rt .detail-stat-value { color: var(--muted);   }
        .btn-close-detail {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 14px; border-radius: 8px; border: none; cursor: pointer;
            background: var(--danger-dim); color: var(--danger);
            border: 1px solid rgba(248,113,113,0.25);
            font-size: 0.78rem; font-weight: 600; font-family: inherit;
            transition: all 0.2s;
        }
        .btn-close-detail:hover { background: rgba(248,113,113,0.2); }

        /* ── TOOLBAR ── */
        .section-lbl {
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 12px;
        }
        .toolbar {
            display: flex; gap: 10px; align-items: center;
            margin-bottom: 16px; flex-wrap: wrap;
        }
        .search-box {
            flex: 1; min-width: 200px;
            padding: 9px 14px;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border);
            border-radius: 10px; color: var(--text);
            font-size: 0.83rem; font-family: inherit; outline: none;
            transition: border-color 0.2s;
        }
        .search-box::placeholder { color: var(--muted); }
        .search-box:focus { border-color: rgba(79,126,248,0.5); background: rgba(79,126,248,0.05); }
        .select-box {
            padding: 9px 12px;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border);
            border-radius: 10px; color: var(--text);
            font-size: 0.83rem; font-family: inherit; outline: none;
            cursor: pointer; transition: border-color 0.2s;
        }
        .select-box option { background: #0f1c4d; color: #fff; }
        .select-box:focus { border-color: rgba(79,126,248,0.5); }

        /* Buttons */
        .btn {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 9px 16px; border-radius: 10px; border: none;
            font-size: 0.82rem; font-weight: 600; font-family: inherit;
            cursor: pointer; text-decoration: none; transition: all 0.2s;
            white-space: nowrap;
        }
        .btn-search {
            background: rgba(79,126,248,0.15); color: var(--accent-2);
            border: 1px solid rgba(79,126,248,0.3);
        }
        .btn-search:hover { background: rgba(79,126,248,0.28); border-color: rgba(79,126,248,0.5); }
        .btn-new {
            background: linear-gradient(135deg, var(--green), #059669);
            color: #fff;
            box-shadow: 0 4px 14px rgba(52,211,153,0.3);
        }
        .btn-new:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(52,211,153,0.4); }

        /* Reset filter button */
        .btn-reset {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 9px 14px; border-radius: 10px;
            background: rgba(248,113,113,0.1);
            border: 1px solid rgba(248,113,113,0.25);
            color: var(--danger); font-size: 0.82rem; font-weight: 600;
            font-family: inherit; cursor: pointer; text-decoration: none;
            transition: all 0.2s; white-space: nowrap;
        }
        .btn-reset:hover { background: rgba(248,113,113,0.2); border-color: rgba(248,113,113,0.4); }

        /* Active filter tags */
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
        .card-title i { color: var(--amber); }
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
        tbody tr:hover td { background: rgba(79,126,248,0.05); }

        .td-name { font-weight: 700; color: var(--text); font-size: 0.82rem; }
        .td-cat {
            display: inline-flex; align-items: center;
            padding: 3px 9px; border-radius: 6px;
            background: rgba(56,189,248,0.1); border: 1px solid rgba(56,189,248,0.2);
            color: var(--info); font-size: 0.7rem; font-weight: 600;
        }
        .td-price { color: var(--green); font-weight: 700; font-size: 0.82rem; }
        .td-user {
            color: var(--accent-2); font-weight: 600; font-size: 0.78rem;
            text-decoration: none;
        }
        .td-user:hover { color: #fff; }
        .td-muted { color: var(--muted); font-size: 0.75rem; }
        .td-desc {
            max-width: 160px; overflow: hidden;
            text-overflow: ellipsis; white-space: nowrap;
            color: var(--muted); font-size: 0.75rem;
        }

        /* Part thumbnail in table */
        .part-thumb {
            width: 38px; height: 38px; border-radius: 8px;
            object-fit: cover; border: 1px solid var(--border);
            background: rgba(255,255,255,0.04);
        }
        .part-thumb-placeholder {
            width: 38px; height: 38px; border-radius: 8px;
            border: 1px dashed var(--border);
            background: rgba(255,255,255,0.02);
            display: flex; align-items: center; justify-content: center;
            color: rgba(255,255,255,0.1); font-size: 0.8rem;
        }

        /* Action buttons */
        .action-btns { display: flex; gap: 6px; }
        .ab {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 5px 11px; border-radius: 8px; border: none;
            font-size: 0.73rem; font-weight: 600; font-family: inherit;
            cursor: pointer; text-decoration: none; transition: all 0.2s;
        }
        .ab-detail  { background:var(--info-dim);   color:var(--info);   border:1px solid rgba(56,189,248,0.25); }
        .ab-edit    { background:var(--amber-dim);  color:var(--amber);  border:1px solid rgba(251,191,36,0.25); }
        .ab-delete  { background:var(--danger-dim); color:var(--danger); border:1px solid rgba(248,113,113,0.25); }
        .ab-detail:hover  { background:rgba(56,189,248,0.2); }
        .ab-edit:hover    { background:rgba(251,191,36,0.2); }
        .ab-delete:hover  { background:rgba(248,113,113,0.2); }

        /* ── PAGINATION ── */
        .pagination {
            display: flex; justify-content: center; align-items: center;
            gap: 6px; padding: 16px; border-top: 1px solid var(--border);
        }
        .page-btn {
            padding: 6px 13px; border-radius: 8px;
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
            font-size: 0.78rem; color: var(--text-2);
            cursor: pointer; text-decoration: none; transition: all 0.2s;
            font-family: inherit;
        }
        .page-btn.active { background: var(--accent); border-color: var(--accent); color: #fff; font-weight: 700; }
        .page-btn:hover:not(.active):not(.disabled) { background: rgba(79,126,248,0.12); border-color: rgba(79,126,248,0.3); color: #fff; }
        .page-btn.disabled { opacity: 0.3; pointer-events: none; }

        /* ── EMPTY ── */
        .empty {
            text-align: center; padding: 48px 24px;
            color: var(--muted); font-size: 0.82rem;
        }
        .empty i { font-size: 2.2rem; display: block; margin-bottom: 12px; opacity: 0.2; }
        .empty a { color: var(--accent-2); font-weight: 700; text-decoration: none; }

        /* ── MODAL ── */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.65);
            backdrop-filter: blur(6px);
            z-index: 1000; align-items: center; justify-content: center;
        }
        .modal-overlay.show { display: flex; }
        .modal {
            background: var(--navy-card);
            border: 1px solid var(--border);
            border-radius: 16px; padding: 28px;
            width: 520px; max-width: 95vw;
            max-height: 90vh; overflow-y: auto;
            box-shadow: 0 24px 80px rgba(0,0,0,0.5);
            animation: cardIn 0.25s ease;
        }
        .modal::-webkit-scrollbar { width: 3px; }
        .modal::-webkit-scrollbar-thumb { background: rgba(79,126,248,0.3); border-radius: 3px; }
        .modal-icon {
            width: 52px; height: 52px; border-radius: 14px; margin: 0 auto 16px;
            display: flex; align-items: center; justify-content: center; font-size: 1.4rem;
        }
        .modal-icon.green  { background:var(--green-dim);   color:var(--green);   }
        .modal-icon.amber  { background:var(--amber-dim);   color:var(--amber);   }
        .modal-icon.danger { background:var(--danger-dim);  color:var(--danger);  }
        .modal h3 {
            font-size: 1rem; font-weight: 800; color: #fff;
            text-align: center; margin-bottom: 20px;
        }
        .modal p { color: var(--text-2); font-size: 0.83rem; text-align: center; line-height: 1.6; margin-bottom: 20px; }
        .modal p strong { color: #fff; }
        .form-group { margin-bottom: 14px; }
        .form-group label {
            display: block; font-size: 0.75rem; font-weight: 700;
            color: var(--muted); text-transform: uppercase; letter-spacing: 0.8px;
            margin-bottom: 6px;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%; padding: 9px 13px;
            background: rgba(255,255,255,0.04); border: 1px solid var(--border);
            border-radius: 9px; color: var(--text);
            font-size: 0.83rem; font-family: inherit; outline: none;
            transition: border-color 0.2s;
        }
        .form-group input:focus,
        .form-group select:focus { border-color: rgba(79,126,248,0.5); background: rgba(79,126,248,0.05); }
        .form-group select option { background: #0f1c4d; }
        .modal-btns { display: flex; gap: 10px; margin-top: 20px; }
        .mbtn {
            flex: 1; padding: 10px; border-radius: 10px; border: none;
            font-size: 0.88rem; font-weight: 700; font-family: inherit; cursor: pointer;
            transition: all 0.2s;
        }
        .mbtn-save   { background: linear-gradient(135deg, var(--green), #059669); color: #fff; }
        .mbtn-save:hover { opacity: 0.9; transform: translateY(-1px); }
        .mbtn-del    { background: var(--danger-dim); color: var(--danger); border: 1px solid rgba(248,113,113,0.3); }
        .mbtn-del:hover { background: rgba(248,113,113,0.2); }
        .mbtn-cancel { background: rgba(255,255,255,0.06); color: var(--muted); border: 1px solid var(--border); }
        .mbtn-cancel:hover { background: rgba(255,255,255,0.1); color: var(--text); }

        /* ── IMAGE UPLOAD SECTION ── */
        .img-section {
            border: 1px solid var(--border);
            border-radius: 12px; overflow: hidden;
            margin-bottom: 14px;
        }
        .img-tabs {
            display: flex; border-bottom: 1px solid var(--border);
        }
        .img-tab {
            flex: 1; padding: 9px; border: none; cursor: pointer;
            background: transparent; color: var(--muted);
            font-size: 0.76rem; font-weight: 600; font-family: inherit;
            transition: all 0.2s; display: flex; align-items: center;
            justify-content: center; gap: 6px;
        }
        .img-tab.active {
            background: rgba(79,126,248,0.1);
            color: var(--accent-2);
            border-bottom: 2px solid var(--accent);
        }
        .img-tab:hover:not(.active) { background: rgba(255,255,255,0.03); color: var(--text-2); }
        .img-tab-content { padding: 14px; display: none; }
        .img-tab-content.active { display: block; }

        /* Drop zone */
        .drop-zone {
            border: 2px dashed rgba(79,126,248,0.3);
            border-radius: 10px; padding: 20px 14px;
            text-align: center; cursor: pointer;
            transition: all 0.2s; position: relative;
        }
        .drop-zone:hover, .drop-zone.drag-over {
            border-color: var(--accent);
            background: rgba(79,126,248,0.06);
        }
        .drop-zone input[type="file"] {
            position: absolute; inset: 0; opacity: 0;
            cursor: pointer; width: 100%; height: 100%;
        }
        .drop-zone-icon {
            font-size: 1.8rem; margin-bottom: 8px;
            color: rgba(79,126,248,0.5);
        }
        .drop-zone-text {
            font-size: 0.78rem; color: var(--muted); line-height: 1.5;
        }
        .drop-zone-text strong { color: var(--accent-2); }
        .drop-zone-hint {
            font-size: 0.68rem; color: rgba(255,255,255,0.2);
            margin-top: 5px;
        }

        /* Image preview */
        .img-preview-wrap {
            margin-top: 12px; display: none;
            border-radius: 10px; overflow: hidden;
            border: 1px solid var(--border);
            background: rgba(255,255,255,0.02);
            position: relative;
        }
        .img-preview-wrap.show { display: block; }
        .img-preview-wrap img {
            width: 100%; max-height: 160px;
            object-fit: contain; display: block;
            background: rgba(0,0,0,0.2);
        }
        .img-preview-remove {
            position: absolute; top: 6px; right: 6px;
            background: rgba(248,113,113,0.85);
            border: none; border-radius: 6px;
            color: #fff; width: 26px; height: 26px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; font-size: 0.7rem;
            transition: background 0.2s;
        }
        .img-preview-remove:hover { background: var(--danger); }
        .img-preview-name {
            padding: 6px 10px;
            font-size: 0.7rem; color: var(--muted);
            border-top: 1px solid var(--border);
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }

        /* URL input */
        .url-input-wrap { position: relative; }
        .url-input-wrap input {
            padding-right: 90px;
        }
        .btn-load-url {
            position: absolute; right: 6px; top: 50%; transform: translateY(-50%);
            padding: 5px 12px; border-radius: 7px; border: none;
            background: rgba(79,126,248,0.2); color: var(--accent-2);
            font-size: 0.72rem; font-weight: 700; font-family: inherit;
            cursor: pointer; transition: all 0.2s; white-space: nowrap;
        }
        .btn-load-url:hover { background: rgba(79,126,248,0.35); }

        /* Current image badge (edit modal) */
        .current-img-badge {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 10px; border-radius: 8px;
            background: rgba(52,211,153,0.06); border: 1px solid rgba(52,211,153,0.2);
            margin-bottom: 10px;
        }
        .current-img-badge img {
            width: 36px; height: 36px; border-radius: 6px;
            object-fit: cover; border: 1px solid var(--border);
        }
        .current-img-badge-info { flex: 1; min-width: 0; }
        .current-img-badge-label { font-size: 0.65rem; color: var(--green); font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; }
        .current-img-badge-url { font-size: 0.7rem; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .btn-clear-img {
            padding: 4px 10px; border-radius: 6px; border: none;
            background: var(--danger-dim); color: var(--danger);
            font-size: 0.7rem; font-weight: 700; font-family: inherit;
            cursor: pointer; white-space: nowrap; transition: all 0.2s;
            border: 1px solid rgba(248,113,113,0.2);
        }
        .btn-clear-img:hover { background: rgba(248,113,113,0.2); }
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
            <a href="<%=ctx%>/numberPart" class="sb-item on si-parts">
                <i class="fas fa-puzzle-piece"></i> Parts List
            </a>
            <a href="<%=ctx%>/numberEquipment" class="sb-item si-equip">
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
                <div class="topbar-title">Parts List</div>
                <div class="topbar-sub">Manage part types, stock, and pricing.</div>
            </div>
            <div class="topbar-badge">
                <i class="fas fa-puzzle-piece"></i>
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

            <!-- DETAIL PANEL -->
            <%if(detailPart!=null){%>
            <div class="detail-panel">
                <div class="detail-header">
                    <div class="detail-title">
                        <i class="fas fa-chart-pie"></i>
                        Status Breakdown — <span style="color:var(--accent-2)"><%=detailPart.getName()%></span>
                    </div>
                    <button class="btn-close-detail" onclick="location.href='<%=ctx%>/numberPart'">
                        <i class="fas fa-xmark"></i> Close
                    </button>
                </div>
                <div class="detail-stats">
                    <div class="detail-stat ds-av">
                        <div class="detail-stat-label"><i class="fas fa-circle-check"></i> Available</div>
                        <div class="detail-stat-value"><%=detailPart.getAvailableUnits()%></div>
                    </div>
                    <div class="detail-stat ds-fa">
                        <div class="detail-stat-label"><i class="fas fa-triangle-exclamation"></i> Faulty</div>
                        <div class="detail-stat-value"><%=detailPart.getFaultyUnits()%></div>
                    </div>
                    <div class="detail-stat ds-iu">
                        <div class="detail-stat-label"><i class="fas fa-screwdriver-wrench"></i> In Use</div>
                        <div class="detail-stat-value"><%=detailPart.getInuseUnits()%></div>
                    </div>
                    <div class="detail-stat ds-rt">
                        <div class="detail-stat-label"><i class="fas fa-archive"></i> Retired</div>
                        <div class="detail-stat-value"><%=detailPart.getRetiredUnits()%></div>
                    </div>
                </div>
            </div>
            <%}%>

            <!-- TOOLBAR -->
            <div class="section-lbl">Filter & Search</div>
            <form method="get" action="<%=ctx%>/numberPart" id="filterForm">
                <div class="toolbar">
                    <input class="search-box" type="text" name="keyword"
                           placeholder="🔍  Search by name or description…"
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

                    <a href="<%=ctx%>/numberPart" class="btn-reset">
                        <i class="fas fa-filter-circle-xmark"></i> Reset Filters
                    </a>

                    <button type="button" class="btn btn-new" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> New Part
                    </button>
                </div>
            </form>

            <!-- Active filter tags -->
            <div class="filter-tags">
                <span class="filter-tags-lbl">Active filters:</span>
                <%if(!keyword.isEmpty()){%>
                <span class="filter-tag"><i class="fas fa-magnifying-glass"></i> "<%=keyword%>"</span>
                <%}%>
                <%if(!categoryId.isEmpty()){
                    String catName = categoryId;
                    for(Category c : categories){ if(String.valueOf(c.getId()).equals(categoryId)){ catName=c.getName(); break; } }
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
            <div class="section-lbl">Parts (<%=total%> found)</div>
            <div class="card">
                <div class="card-hd">
                    <div class="card-title"><i class="fas fa-puzzle-piece"></i> Part Types</div>
                    <span class="total-badge"><%=total%> records · Page <%=currentPage%> of <%=totalPages%></span>
                </div>
                <%if(parts.isEmpty()){%>
                <div class="empty">
                    <i class="fas fa-box-open"></i>
                    No parts found matching your filters.
                    <br><a href="<%=ctx%>/numberPart">Clear filters</a>
                </div>
                <%}else{%>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Image</th>
                            <th>Part Name</th>
                            <th>Category</th>
                            <th>Description</th>
                            <th>Unit Price</th>
                            <th>Updated By</th>
                            <th>Updated At</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%for(PartType pt:parts){%>
                    <tr>
                        <td class="td-muted">#<%=pt.getId()%></td>
                        <td>
                            <%if(pt.getImageUrl()!=null&&!pt.getImageUrl().isEmpty()){%>
                            <img class="part-thumb"
                                 src="<%=pt.getImageUrl().startsWith("http")?pt.getImageUrl():ctx+pt.getImageUrl()%>"
                                 alt="<%=pt.getName()%>"
                                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                            <div class="part-thumb-placeholder" style="display:none"><i class="fas fa-image"></i></div>
                            <%}else{%>
                            <div class="part-thumb-placeholder"><i class="fas fa-image"></i></div>
                            <%}%>
                        </td>
                       <td class="td-name">
    <a href="<%=ctx%>/numberPart?action=detailPage&id=<%=pt.getId()%>" 
       style="color:inherit;text-decoration:none;transition:color 0.2s"
       onmouseover="this.style.color='var(--accent-2)'" 
       onmouseout="this.style.color='inherit'">
        <%=pt.getName()%>
    </a>
</td>
                        <td><span class="td-cat"><%=pt.getCategoryName()%></span></td>
                        <td class="td-desc" title="<%=pt.getDescription()!=null?pt.getDescription():""%>">
                            <%=pt.getDescription()!=null?pt.getDescription():"—"%>
                        </td>
                        <td class="td-price"><%=nf.format((long)pt.getUnitPrice())%> ₫</td>
                        <td>
                            <a href="#" class="td-user"><%=pt.getUpdatedByUsername()!=null?pt.getUpdatedByUsername():"—"%></a>
                        </td>
                        <td class="td-muted"><%=pt.getUpdatedAt()!=null?pt.getUpdatedAt().toLocalDate():"—"%></td>
                        <td>
                            <div class="action-btns">
                                <a href="<%=ctx%>/numberPart?action=detail&id=<%=pt.getId()%>" class="ab ab-detail">
                                    <i class="fas fa-chart-bar"></i> Detail
                                </a>
                                <button class="ab ab-edit"
                                    onclick="openEditModal(
                                        <%=pt.getId()%>,
                                        '<%=pt.getName().replace("'","\\'")%>',
                                        <%=pt.getCategoryId()%>,
                                        '<%=pt.getDescription()!=null?pt.getDescription().replace("'","\\'"):""%>',
                                        <%=pt.getUnitPrice()%>,
                                        '<%=pt.getImageUrl()!=null?pt.getImageUrl().replace("'","\\'"):""%>'
                                    )">
                                    <i class="fas fa-pen"></i> Edit
                                </button>
                                <button class="ab ab-delete"
                                    onclick="confirmDelete(<%=pt.getId()%>,'<%=pt.getName().replace("'","\\'")%>')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                    <%}%>
                    </tbody>
                </table>
                <%}%>

                <!-- PAGINATION -->
                <div class="pagination">
                    <a href="<%=ctx%>/numberPart?page=1&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                       class="page-btn <%=currentPage==1?"disabled":""%>">« First</a>
                    <a href="<%=ctx%>/numberPart?page=<%=Math.max(1,currentPage-1)%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                       class="page-btn <%=currentPage==1?"disabled":""%>">‹ Prev</a>
                    <%for(int p=Math.max(1,currentPage-2);p<=Math.min(totalPages,currentPage+2);p++){%>
                    <a href="<%=ctx%>/numberPart?page=<%=p%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                       class="page-btn <%=p==currentPage?"active":""%>"><%=p%></a>
                    <%}%>
                    <a href="<%=ctx%>/numberPart?page=<%=Math.min(totalPages,currentPage+1)%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                       class="page-btn <%=currentPage==totalPages?"disabled":""%>">Next ›</a>
                    <a href="<%=ctx%>/numberPart?page=<%=totalPages%>&keyword=<%=keyword%>&categoryId=<%=categoryId%>&sortBy=<%=sortBy%>"
                       class="page-btn <%=currentPage==totalPages?"disabled":""%>">Last »</a>
                </div>
            </div>

        </div><!-- /content -->
    </main>

    <!-- ═══════ CREATE MODAL ═══════ -->
    <div class="modal-overlay" id="createModal">
        <div class="modal">
            <div class="modal-icon green"><i class="fas fa-plus"></i></div>
            <h3>New Part Type</h3>
            <form method="post" action="<%=ctx%>/numberPart" enctype="multipart/form-data" id="createForm">
                <input type="hidden" name="action" value="create">
                <!-- hidden: final resolved image url (if URL tab chosen) -->
                <input type="hidden" name="imageUrl" id="createImageUrl">

                <div class="form-group">
                    <label>Part Name <span style="color:var(--danger)">*</span> (min 3 chars)</label>
                    <input type="text" name="name" required minlength="3" placeholder="e.g. CPU Intel i7">
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
                    <label>Description <span style="color:var(--danger)">*</span> (10–100 chars)</label>
                    <input type="text" name="description" required minlength="10" maxlength="100"
                           placeholder="Short description of the part">
                </div>
                <div class="form-group">
                    <label>Unit Price <span style="color:var(--danger)">*</span></label>
                    <input type="number" name="unitPrice" required min="0" step="1000" value="0">
                </div>
                <div class="form-group">
                    <label>Initial Stock Quantity (1–100)</label>
                    <input type="number" name="quantity" required min="1" max="100" value="1">
                </div>

                <!-- ── IMAGE SECTION ── -->
                <div class="form-group">
                    <label><i class="fas fa-image" style="color:var(--accent-2)"></i> Product Image <span style="color:var(--muted);font-weight:400;text-transform:none;letter-spacing:0">(optional)</span></label>
                    <div class="img-section">
                        <div class="img-tabs">
                            <button type="button" class="img-tab active" onclick="switchImgTab('create','file',this)">
                                <i class="fas fa-upload"></i> Upload File
                            </button>
                            <button type="button" class="img-tab" onclick="switchImgTab('create','url',this)">
                                <i class="fas fa-link"></i> Image URL
                            </button>
                        </div>
                        <!-- File upload tab -->
                        <div class="img-tab-content active" id="create-tab-file">
                            <div class="drop-zone" id="createDropZone"
                                 ondragover="handleDragOver(event,this)"
                                 ondragleave="handleDragLeave(this)"
                                 ondrop="handleDrop(event,'create')">
                                <input type="file" name="imageFile" id="createImageFile"
                                       accept="image/jpeg,image/png,image/webp,image/gif,image/avif"
                                       onchange="handleFileSelect(event,'create')">
                                <div class="drop-zone-icon"><i class="fas fa-cloud-arrow-up"></i></div>
                                <div class="drop-zone-text">
                                    <strong>Click to browse</strong> or drag & drop
                                </div>
                                <div class="drop-zone-hint">JPG, PNG, WEBP, GIF, AVIF · Max 5MB</div>
                            </div>
                            <div class="img-preview-wrap" id="createFilePreview">
                                <img id="createFilePreviewImg" src="" alt="preview">
                                <button type="button" class="img-preview-remove"
                                        onclick="removeFilePreview('create')" title="Remove">
                                    <i class="fas fa-xmark"></i>
                                </button>
                                <div class="img-preview-name" id="createFilePreviewName"></div>
                            </div>
                        </div>
                        <!-- URL tab -->
                        <div class="img-tab-content" id="create-tab-url">
                            <div class="url-input-wrap">
                                <input type="url" id="createUrlInput"
                                       placeholder="https://example.com/image.jpg"
                                       oninput="onUrlInput('create')">
                                <button type="button" class="btn-load-url"
                                        onclick="loadUrlPreview('create')">
                                    <i class="fas fa-eye"></i> Preview
                                </button>
                            </div>
                            <div class="img-preview-wrap" id="createUrlPreview" style="margin-top:10px">
                                <img id="createUrlPreviewImg" src="" alt="preview"
                                     onerror="handleUrlImgError('create')">
                                <button type="button" class="img-preview-remove"
                                        onclick="removeUrlPreview('create')" title="Remove">
                                    <i class="fas fa-xmark"></i>
                                </button>
                                <div class="img-preview-name" id="createUrlPreviewName"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-btns">
                    <button type="submit" class="mbtn mbtn-save" onclick="prepareCreateSubmit()">
                        <i class="fas fa-save"></i> Save
                    </button>
                    <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('createModal')">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- ═══════ EDIT MODAL ═══════ -->
    <div class="modal-overlay" id="editModal">
        <div class="modal">
            <div class="modal-icon amber"><i class="fas fa-pen"></i></div>
            <h3>Edit Part Type</h3>
            <form method="post" action="<%=ctx%>/numberPart" enctype="multipart/form-data" id="editForm">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="editId">
                <input type="hidden" name="imageUrl" id="editImageUrl">
                <input type="hidden" name="clearImage" id="editClearImage" value="false">

                <div class="form-group">
                    <label>Part Name <span style="color:var(--danger)">*</span></label>
                    <input type="text" name="name" id="editName" required minlength="3">
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
                    <label>Description <span style="color:var(--danger)">*</span></label>
                    <input type="text" name="description" id="editDesc" required minlength="10" maxlength="100">
                </div>
                <div class="form-group">
                    <label>Unit Price <span style="color:var(--danger)">*</span></label>
                    <input type="number" name="unitPrice" id="editPrice" required min="0" step="1000">
                </div>

                <!-- ── IMAGE SECTION ── -->
                <div class="form-group">
                    <label><i class="fas fa-image" style="color:var(--accent-2)"></i> Product Image <span style="color:var(--muted);font-weight:400;text-transform:none;letter-spacing:0">(optional)</span></label>

                    <!-- Current image badge -->
                    <div class="current-img-badge" id="editCurrentImgBadge" style="display:none">
                        <img id="editCurrentImgThumb" src="" alt="current">
                        <div class="current-img-badge-info">
                            <div class="current-img-badge-label"><i class="fas fa-circle-check"></i> Current Image</div>
                            <div class="current-img-badge-url" id="editCurrentImgUrl"></div>
                        </div>
                        <button type="button" class="btn-clear-img" onclick="clearCurrentImage()">
                            <i class="fas fa-trash"></i> Remove
                        </button>
                    </div>

                    <div class="img-section">
                        <div class="img-tabs">
                            <button type="button" class="img-tab active" onclick="switchImgTab('edit','file',this)">
                                <i class="fas fa-upload"></i> Upload New File
                            </button>
                            <button type="button" class="img-tab" onclick="switchImgTab('edit','url',this)">
                                <i class="fas fa-link"></i> Image URL
                            </button>
                        </div>
                        <!-- File upload tab -->
                        <div class="img-tab-content active" id="edit-tab-file">
                            <div class="drop-zone" id="editDropZone"
                                 ondragover="handleDragOver(event,this)"
                                 ondragleave="handleDragLeave(this)"
                                 ondrop="handleDrop(event,'edit')">
                                <input type="file" name="imageFile" id="editImageFile"
                                       accept="image/jpeg,image/png,image/webp,image/gif,image/avif"
                                       onchange="handleFileSelect(event,'edit')">
                                <div class="drop-zone-icon"><i class="fas fa-cloud-arrow-up"></i></div>
                                <div class="drop-zone-text">
                                    <strong>Click to browse</strong> or drag & drop
                                </div>
                                <div class="drop-zone-hint">JPG, PNG, WEBP, GIF, AVIF · Max 5MB</div>
                            </div>
                            <div class="img-preview-wrap" id="editFilePreview">
                                <img id="editFilePreviewImg" src="" alt="preview">
                                <button type="button" class="img-preview-remove"
                                        onclick="removeFilePreview('edit')" title="Remove">
                                    <i class="fas fa-xmark"></i>
                                </button>
                                <div class="img-preview-name" id="editFilePreviewName"></div>
                            </div>
                        </div>
                        <!-- URL tab -->
                        <div class="img-tab-content" id="edit-tab-url">
                            <div class="url-input-wrap">
                                <input type="url" id="editUrlInput"
                                       placeholder="https://example.com/image.jpg"
                                       oninput="onUrlInput('edit')">
                                <button type="button" class="btn-load-url"
                                        onclick="loadUrlPreview('edit')">
                                    <i class="fas fa-eye"></i> Preview
                                </button>
                            </div>
                            <div class="img-preview-wrap" id="editUrlPreview" style="margin-top:10px">
                                <img id="editUrlPreviewImg" src="" alt="preview"
                                     onerror="handleUrlImgError('edit')">
                                <button type="button" class="img-preview-remove"
                                        onclick="removeUrlPreview('edit')" title="Remove">
                                    <i class="fas fa-xmark"></i>
                                </button>
                                <div class="img-preview-name" id="editUrlPreviewName"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-btns">
                    <button type="submit" class="mbtn mbtn-save" onclick="prepareEditSubmit()">
                        <i class="fas fa-save"></i> Save
                    </button>
                    <button type="button" class="mbtn mbtn-cancel" onclick="closeModal('editModal')">Cancel</button>
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
                <strong id="deletePartName"></strong>
                <span style="color:var(--muted);font-size:0.75rem"> (ID: <span id="deletePartId"></span>)</span>?<br>
                <span style="color:var(--danger);font-size:0.78rem">This action cannot be undone.</span>
            </p>
            <form method="post" action="<%=ctx%>/numberPart">
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
    // ── Modal open/close ──
    function openCreateModal() {
        resetImgSection('create');
        document.getElementById('createModal').classList.add('show');
    }
    function openEditModal(id, name, catId, desc, price, imgUrl) {
        document.getElementById('editId').value          = id;
        document.getElementById('editName').value        = name;
        document.getElementById('editCategoryId').value  = catId;
        document.getElementById('editDesc').value        = desc;
        document.getElementById('editPrice').value       = price;
        resetImgSection('edit');
        document.getElementById('editClearImage').value  = 'false';

        if (imgUrl && imgUrl.trim() !== '') {
            var badge   = document.getElementById('editCurrentImgBadge');
            var thumb   = document.getElementById('editCurrentImgThumb');
            var urlDisp = document.getElementById('editCurrentImgUrl');
            var src     = imgUrl.startsWith('http') ? imgUrl : '<%=ctx%>' + imgUrl;
            thumb.src   = src;
            urlDisp.textContent = imgUrl;
            badge.style.display = 'flex';
            // store original
            badge.dataset.original = imgUrl;
        }
        document.getElementById('editModal').classList.add('show');
    }
    function confirmDelete(id, name) {
        document.getElementById('deleteId').value             = id;
        document.getElementById('deletePartId').textContent   = id;
        document.getElementById('deletePartName').textContent = name;
        document.getElementById('deleteModal').classList.add('show');
    }
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }
    window.addEventListener('click', function(e) {
        ['createModal','editModal','deleteModal'].forEach(function(id){
            var m = document.getElementById(id);
            if (e.target === m) m.classList.remove('show');
        });
    });

    // ── Image tabs ──
    function switchImgTab(prefix, tab, btn) {
        // deactivate all tabs & contents
        var section = btn.closest('.img-section');
        section.querySelectorAll('.img-tab').forEach(function(t){ t.classList.remove('active'); });
        section.querySelectorAll('.img-tab-content').forEach(function(c){ c.classList.remove('active'); });
        btn.classList.add('active');
        document.getElementById(prefix + '-tab-' + tab).classList.add('active');
        // clear the inactive tab's data
        if (tab === 'file') {
            removeUrlPreview(prefix);
        } else {
            removeFilePreview(prefix);
        }
    }

    // ── File upload ──
    function handleFileSelect(event, prefix) {
        var file = event.target.files[0];
        if (!file) return;
        if (file.size > 5 * 1024 * 1024) {
            alert('File is too large. Maximum size is 5MB.');
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
            alert('Please drop an image file.');
            return;
        }
        if (file.size > 5 * 1024 * 1024) {
            alert('File is too large. Maximum size is 5MB.');
            return;
        }
        // Assign to input (create DataTransfer trick)
        var dt = new DataTransfer();
        dt.items.add(file);
        document.getElementById(prefix + 'ImageFile').files = dt.files;
        showFilePreview(prefix, file);
    }
    function showFilePreview(prefix, file) {
        var reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById(prefix + 'FilePreviewImg').src = e.target.result;
            document.getElementById(prefix + 'FilePreviewName').textContent = file.name + ' (' + (file.size/1024).toFixed(1) + ' KB)';
            document.getElementById(prefix + 'FilePreview').classList.add('show');
        };
        reader.readAsDataURL(file);
        // hide current badge for edit
        if (prefix === 'edit') hideBadge();
    }
    function removeFilePreview(prefix) {
        document.getElementById(prefix + 'FilePreviewImg').src = '';
        document.getElementById(prefix + 'FilePreview').classList.remove('show');
        document.getElementById(prefix + 'ImageFile').value = '';
        if (prefix === 'edit') restoreBadge();
    }

    // ── URL preview ──
    function onUrlInput(prefix) {
        // hide preview until user clicks Preview or pastes complete URL
        var preview = document.getElementById(prefix + 'UrlPreview');
        if (!document.getElementById(prefix + 'UrlInput').value.trim()) {
            preview.classList.remove('show');
        }
    }
    function loadUrlPreview(prefix) {
        var url = document.getElementById(prefix + 'UrlInput').value.trim();
        if (!url) return;
        var img = document.getElementById(prefix + 'UrlPreviewImg');
        img.src = url;
        document.getElementById(prefix + 'UrlPreviewName').textContent = url;
        document.getElementById(prefix + 'UrlPreview').classList.add('show');
        if (prefix === 'edit') hideBadge();
    }
    function handleUrlImgError(prefix) {
        document.getElementById(prefix + 'UrlPreviewName').textContent = '⚠ Could not load image from this URL';
        document.getElementById(prefix + 'UrlPreviewImg').style.display = 'none';
    }
    function removeUrlPreview(prefix) {
        var img = document.getElementById(prefix + 'UrlPreviewImg');
        img.src = '';
        img.style.display = '';
        document.getElementById(prefix + 'UrlInput').value = '';
        document.getElementById(prefix + 'UrlPreviewName').textContent = '';
        document.getElementById(prefix + 'UrlPreview').classList.remove('show');
        if (prefix === 'edit') restoreBadge();
    }

    // ── Edit: current image badge ──
    function hideBadge() {
        var badge = document.getElementById('editCurrentImgBadge');
        if (badge) badge.style.display = 'none';
    }
    function restoreBadge() {
        var badge = document.getElementById('editCurrentImgBadge');
        if (badge && badge.dataset.original) badge.style.display = 'flex';
    }
    function clearCurrentImage() {
        var badge = document.getElementById('editCurrentImgBadge');
        badge.style.display = 'none';
        badge.dataset.original = '';
        document.getElementById('editClearImage').value = 'true';
        document.getElementById('editImageUrl').value   = '';
    }

    // ── Reset entire image section ──
    function resetImgSection(prefix) {
        removeFilePreview(prefix);
        removeUrlPreview(prefix);
        document.getElementById(prefix + 'ImageUrl').value = '';
        if (prefix === 'edit') {
            document.getElementById('editCurrentImgBadge').style.display = 'none';
            document.getElementById('editCurrentImgBadge').dataset.original = '';
        }
        // Reset tabs to File tab
        var modalId = prefix + 'Modal';
        var modal   = document.getElementById(modalId);
        if (!modal) return;
        modal.querySelectorAll('.img-tab').forEach(function(t, i) {
            t.classList.toggle('active', i === 0);
        });
        modal.querySelectorAll('.img-tab-content').forEach(function(c, i) {
            c.classList.toggle('active', i === 0);
        });
    }

    // ── Pre-submit: set imageUrl hidden field from URL tab if active ──
    function prepareCreateSubmit() {
        var activeContent = document.querySelector('#createModal .img-tab-content.active');
        if (activeContent && activeContent.id === 'create-tab-url') {
            var url = document.getElementById('createUrlInput').value.trim();
            document.getElementById('createImageUrl').value = url;
            // clear file input so server ignores it
            document.getElementById('createImageFile').value = '';
        } else {
            document.getElementById('createImageUrl').value = '';
        }
    }
    function prepareEditSubmit() {
        var activeContent = document.querySelector('#editModal .img-tab-content.active');
        if (activeContent && activeContent.id === 'edit-tab-url') {
            var url = document.getElementById('editUrlInput').value.trim();
            document.getElementById('editImageUrl').value = url;
            document.getElementById('editImageFile').value = '';
        } else {
            // keep existing hidden value (cleared or not)
            var badge = document.getElementById('editCurrentImgBadge');
            var hasNewFile = document.getElementById('editImageFile').files.length > 0;
            if (!hasNewFile && badge.style.display !== 'none' && badge.dataset.original) {
                // no new file chosen, current image kept → send original url
                document.getElementById('editImageUrl').value = badge.dataset.original;
            }
        }
    }
    </script>
</body>
</html>
