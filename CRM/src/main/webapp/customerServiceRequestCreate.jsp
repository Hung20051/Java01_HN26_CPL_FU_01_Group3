<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,java.util.*" %>
<%
    User me = (User) session.getAttribute("user");
    if(me==null||!"CUSTOMER".equals(me.getRoleName())){response.sendRedirect(request.getContextPath()+"/login.jsp");return;}
    List<Contract> contracts=(List<Contract>)request.getAttribute("contracts"); if(contracts==null)contracts=new ArrayList<>();
    String ctx=request.getContextPath();
    int cartCount=session.getAttribute("shopCart")!=null?((Map<?,?>)session.getAttribute("shopCart")).size():0;
%>
<!DOCTYPE html><html lang="en"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Create Repair Request - DRSMS</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            :root{
                --primary:#4f46e5;
                --sidebar:#0f172a;
                --bg:#f8fafc;
                --surface:#fff;
                --border:#e2e8f0;
                --text:#0f172a;
                --muted:#64748b;
                --success:#10b981;
                --warning:#f59e0b;
                --danger:#ef4444
            }
            *{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            body{
                font-family:'Inter',sans-serif;
                background:var(--bg);
                display:flex;
                min-height:100vh
            }
            .sb{
                width:240px;
                min-height:100vh;
                background:var(--sidebar);
                display:flex;
                flex-direction:column;
                position:fixed
            }
            .sb-brand{
                padding:22px 18px 18px;
                display:flex;
                align-items:center;
                gap:10px;
                border-bottom:1px solid rgba(255,255,255,.07)
            }
            .sb-logo{
                width:34px;
                height:34px;
                background:var(--primary);
                border-radius:9px;
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.9rem
            }
            .sb-name{
                color:#fff;
                font-size:1rem;
                font-weight:700
            }
            .sb-sub{
                color:rgba(255,255,255,.35);
                font-size:.68rem
            }
            .sb-nav{
                flex:1;
                padding:14px 10px
            }
            .sb-lbl{
                color:rgba(255,255,255,.28);
                font-size:.63rem;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1.2px;
                padding:0 8px;
                margin:14px 0 5px
            }
            .sb-item{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:8px;
                margin-bottom:2px;
                color:rgba(255,255,255,.58);
                text-decoration:none;
                font-size:.855rem;
                font-weight:500;
                transition:.15s
            }
            .sb-item:hover{
                color:#fff;
                background:rgba(255,255,255,.07)
            }
            .sb-item.on{
                color:#fff;
                background:var(--primary)
            }
            .sb-item i{
                width:17px;
                text-align:center;
                font-size:.83rem
            }
            .sb-foot{
                padding:14px 10px 18px;
                border-top:1px solid rgba(255,255,255,.07)
            }
            .sb-user{
                display:flex;
                align-items:center;
                gap:9px;
                padding:9px 10px;
                border-radius:9px;
                background:rgba(255,255,255,.05);
                margin-bottom:7px
            }
            .sb-ava{
                width:34px;
                height:34px;
                border-radius:50%;
                background:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                color:#fff;
                font-size:.88rem;
                font-weight:700
            }
            .sb-uname{
                color:#fff;
                font-size:.82rem;
                font-weight:600
            }
            .sb-urole{
                color:rgba(255,255,255,.38);
                font-size:.7rem
            }
            .sb-logout{
                display:flex;
                align-items:center;
                gap:8px;
                width:100%;
                padding:8px 10px;
                border-radius:8px;
                color:rgba(255,255,255,.45);
                text-decoration:none;
                font-size:.82rem;
                transition:.15s
            }
            .sb-logout:hover{
                color:#f87171;
                background:rgba(248,113,113,.1)
            }
            .main{
                margin-left:240px;
                flex:1;
                padding:28px 32px;
                max-width:calc(100vw - 240px)
            }
            .breadcrumb{
                display:flex;
                align-items:center;
                gap:7px;
                font-size:.81rem;
                color:var(--muted);
                margin-bottom:18px
            }
            .breadcrumb a{
                color:var(--muted);
                text-decoration:none
            }
            .breadcrumb a:hover{
                color:var(--primary)
            }
            .breadcrumb-sep{
                color:#cbd5e1
            }
            .form-card{
                background:var(--surface);
                border-radius:15px;
                border:1px solid var(--border);
                max-width:780px
            }
            .form-hd{
                padding:22px 26px;
                border-bottom:1px solid var(--border)
            }
            .form-hd h2{
                font-size:1.15rem;
                font-weight:700;
                color:var(--text);
                display:flex;
                align-items:center;
                gap:9px
            }
            .form-hd h2 i{
                color:var(--primary)
            }
            .form-hd p{
                color:var(--muted);
                font-size:.85rem;
                margin-top:4px
            }
            .form-body{
                padding:26px
            }
            .sec-title{
                font-size:.78rem;
                font-weight:700;
                color:var(--muted);
                text-transform:uppercase;
                letter-spacing:.8px;
                margin-bottom:13px;
                padding-bottom:7px;
                border-bottom:1px solid var(--border)
            }
            .fg{
                margin-bottom:15px
            }
            .lbl{
                display:block;
                font-size:.83rem;
                font-weight:600;
                color:var(--text);
                margin-bottom:5px
            }
            .lbl span{
                color:var(--danger);
                margin-left:3px
            }
            .fc{
                width:100%;
                padding:9px 12px;
                border:1.5px solid var(--border);
                border-radius:9px;
                font-size:.875rem;
                font-family:inherit;
                outline:none;
                transition:.15s;
                color:var(--text);
                background:white
            }
            .fc:focus{
                border-color:var(--primary);
                box-shadow:0 0 0 3px rgba(79,70,229,.08)
            }
            textarea.fc{
                resize:vertical;
                min-height:90px
            }
            .row-2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:14px
            }
            /* Contract type badge */
            .ct-badge{
                display:inline-block;
                padding:3px 9px;
                border-radius:5px;
                font-size:.75rem;
                font-weight:600
            }
            .ct-warranty{
                background:#d1fae5;
                color:#065f46
            }
            .ct-maint{
                background:#dbeafe;
                color:#1e40af
            }
            /* Equipment checklist */
            .eq-wrap{
                border:1.5px solid var(--border);
                border-radius:10px;
                overflow:hidden;
                min-height:48px
            }
            .eq-loading{
                padding:14px;
                text-align:center;
                color:var(--muted);
                font-size:.84rem;
                display:none
            }
            .eq-empty{
                padding:14px;
                text-align:center;
                color:var(--muted);
                font-size:.84rem
            }
            .eq-item{
                display:flex;
                align-items:flex-start;
                gap:10px;
                padding:12px 14px;
                border-bottom:1px solid #f1f5f9;
                transition:.15s
            }
            .eq-item:last-child{
                border-bottom:none
            }
            .eq-item:hover{
                background:#fafbff
            }
            .eq-item input[type=checkbox]{
                width:16px;
                height:16px;
                margin-top:2px;
                accent-color:var(--primary);
                cursor:pointer;
                flex-shrink:0
            }
            .eq-item-info{
                flex:1
            }
            .eq-item-name{
                font-size:.855rem;
                font-weight:600;
                color:var(--text)
            }
            .eq-item-serial{
                font-size:.76rem;
                color:var(--muted);
                font-family:monospace;
                margin-top:1px
            }
            .eq-item-desc{
                margin-top:7px;
                display:none
            }
            .eq-item-desc textarea{
                width:100%;
                padding:7px 10px;
                border:1.5px solid var(--border);
                border-radius:7px;
                font-size:.82rem;
                font-family:inherit;
                outline:none;
                resize:none;
                height:56px;
                transition:.15s
            }
            .eq-item-desc textarea:focus{
                border-color:var(--primary)
            }
            /* Priority selector */
            .prio-grid{
                display:grid;
                grid-template-columns:repeat(4,1fr);
                gap:9px
            }
            .prio-card{
                border:2px solid var(--border);
                border-radius:10px;
                padding:11px 10px;
                cursor:pointer;
                text-align:center;
                transition:.15s;
                position:relative
            }
            .prio-card:hover{
                border-color:var(--primary)
            }
            .prio-card.sel{
                border-color:var(--pc);
                background:var(--pb)
            }
            .prio-card input{
                display:none
            }
            .prio-card-ico{
                font-size:1.3rem;
                margin-bottom:3px
            }
            .prio-card-lbl{
                font-size:.77rem;
                font-weight:600;
                color:var(--text)
            }
            .p-low{
                --pc:#10b981;
                --pb:#f0fdf4
            }
            .p-med{
                --pc:#f59e0b;
                --pb:#fffbeb
            }
            .p-high{
                --pc:#f97316;
                --pb:#fff7ed
            }
            .p-urg{
                --pc:#ef4444;
                --pb:#fef2f2
            }
            .form-ft{
                padding:18px 26px;
                border-top:1px solid var(--border);
                display:flex;
                gap:10px
            }
            .btn-sub{
                padding:10px 22px;
                border-radius:9px;
                background:var(--primary);
                color:#fff;
                border:none;
                cursor:pointer;
                font-size:.9rem;
                font-weight:600;
                display:flex;
                align-items:center;
                gap:7px;
                font-family:inherit;
                transition:.15s
            }
            .btn-sub:hover{
                background:#4338ca
            }
            .btn-back{
                padding:10px 22px;
                border-radius:9px;
                background:var(--bg);
                color:var(--muted);
                border:1.5px solid var(--border);
                cursor:pointer;
                font-size:.9rem;
                font-weight:600;
                text-decoration:none;
                display:flex;
                align-items:center;
                gap:7px;
                transition:.15s
            }
            .btn-back:hover{
                background:#f1f5f9
            }
            .no-contracts{
                background:#fff7ed;
                border:1px solid #fed7aa;
                border-radius:10px;
                padding:14px 16px;
                font-size:.875rem;
                color:#9a3412;
                display:flex;
                align-items:center;
                gap:10px
            }
            .hint-selected{
                margin-top:8px;
                font-size:.8rem;
                color:var(--primary);
                font-weight:500;
                display:none
            }
            .sb-badge{
                background:#ef4444;
                color:#fff;
                font-size:.62rem;
                font-weight:700;
                padding:1px 6px;
                border-radius:10px;
                margin-left:auto
            }
        </style>
    </head><body>
        <aside class="sb">
            <div class="sb-brand"><div class="sb-logo"><i class="fas fa-bolt"></i></div><div><div class="sb-name">DRSMS System</div><div class="sb-sub">Customer</div></div></div>
            <nav class="sb-nav">
                <div class="sb-lbl">Overview</div>
                <a href="<%=ctx%>/customerDashboard"       class="sb-item"><i class="fas fa-home"></i> Home</a>
                <div class="sb-lbl">Services</div>
                <a href="<%=ctx%>/customerServiceRequests" class="sb-item on"><i class="fas fa-clipboard-list"></i> Repair Requests</a>
                <a href="<%=ctx%>/customerContracts"       class="sb-item"><i class="fas fa-file-contract"></i> Contracts</a>
                <a href="<%=ctx%>/customerEquipment"       class="sb-item"><i class="fas fa-desktop"></i> My Equipment</a>
                <div class="sb-lbl">Shop</div>
                <a href="<%=ctx%>/customerShop?action=parts"     class="sb-item"><i class="fas fa-puzzle-piece"></i> Parts</a>
                <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item"><i class="fas fa-server"></i> Equipment</a>
                <a href="<%=ctx%>/customerShop?action=cart"      class="sb-item"><i class="fas fa-shopping-cart"></i> Cart<%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%></a>
                <div class="sb-lbl">Finance</div>
                <a href="<%=ctx%>/customerInvoices"        class="sb-item"><i class="fas fa-receipt"></i> Invoices</a>
                <div class="sb-lbl">Support</div>
                <a href="<%=ctx%>/customerChat"            class="sb-item"><i class="fas fa-comment-dots"></i> Support Chat</a>
            </nav>
            <div class="sb-foot">
                <div class="sb-user"><div class="sb-ava"><%=me.getFullName().substring(0,1).toUpperCase()%></div><div><div class="sb-uname"><%=me.getFullName()%></div><div class="sb-urole">Customer</div></div></div>
                <a href="<%=ctx%>/logout" class="sb-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </aside>

        <main class="main">
            <div class="breadcrumb">
                <a href="<%=ctx%>/customerDashboard"><i class="fas fa-home"></i></a>
                <span class="breadcrumb-sep">›</span>
                <a href="<%=ctx%>/customerServiceRequests">Repair Requests</a>
                <span class="breadcrumb-sep">›</span>
                <span>Create New</span>
            </div>

            <%if(contracts.isEmpty()){%>
            <div class="no-contracts" style="max-width:780px">
                <i class="fas fa-exclamation-triangle" style="font-size:1.2rem;color:var(--warning)"></i>
                <div>You have no active service contracts.
                    Please <a href="<%=ctx%>/customerChat" style="color:var(--primary);font-weight:600">contact a support agent</a> to create a contract.
                </div>
            </div>
            <%}else{%>
            <div class="form-card">
                <div class="form-hd">
                    <h2><i class="fas fa-plus-circle"></i> Create New Repair Request</h2>
                    <p>Select a contract and equipment to repair, then describe the issue to send to the technical team</p>
                </div>
                <form method="post" action="<%=ctx%>/customerServiceRequests" onsubmit="return validate()">
                    <input type="hidden" name="action" value="create">
                    <div class="form-body">
                        <div style="margin-bottom:22px">
                            <div class="sec-title">1. Select Contract</div>
                            <div class="fg">
                                <label class="lbl">Your Contract <span>*</span></label>
                                <select class="fc" name="contractId" id="contractSel" onchange="loadEquipment(this)" required>
                                    <option value="">-- Select a contract --</option>
                                    <%for(Contract c:contracts){%>
                                    <option value="<%=c.getId()%>" data-type="<%=c.getContractType()%>">
                                        <%=c.getContractCode()%> — <%=c.getContractTypeLabel()%> (<%=c.getEquipmentCount()%> equipment · Expires: <%=c.getEndDate()%>)
                                    </option>
                                    <%}%>
                                </select>
                            </div>
                            <div id="contractInfo" style="display:none;background:#f0f9ff;border:1px solid #bae6fd;border-radius:8px;padding:10px 13px;font-size:.83rem;color:#0369a1;margin-top:6px"></div>
                        </div>

                        <div style="margin-bottom:22px">
                            <div class="sec-title">2. Select Equipment to Repair</div>
                            <div class="eq-wrap" id="eqWrap">
                                <div class="eq-empty" id="eqEmpty">← Select a contract to view equipment list</div>
                                <div class="eq-loading" id="eqLoad"><i class="fas fa-spinner fa-spin"></i> Loading...</div>
                            </div>
                            <div class="hint-selected" id="hintSelected"></div>
                        </div>

                        <div style="margin-bottom:22px">
                            <div class="sec-title">3. Describe the General Issue</div>
                            <div class="fg">
                                <label class="lbl">Request Title <span>*</span></label>
                                <input type="text" class="fc" name="title" required minlength="10" maxlength="200"
                                       placeholder="E.g.: Pump making loud noise, air conditioner not reaching temperature...">
                            </div>
                            <div class="fg">
                                <label class="lbl">Detailed Description <span>*</span></label>
                                <textarea class="fc" name="description" required minlength="20"
                                          placeholder="Describe the condition in detail, when it occurred, specific symptoms..."></textarea>
                            </div>
                        </div>

                        <div>
                            <div class="sec-title">4. Priority Level</div>
                            <div class="prio-grid">
                                <label class="prio-card p-low" onclick="selPrio(this)">
                                    <input type="radio" name="priority" value="LOW">
                                    <div class="prio-card-ico">🟢</div><div class="prio-card-lbl">Low</div>
                                </label>
                                <label class="prio-card p-med sel" onclick="selPrio(this)">
                                    <input type="radio" name="priority" value="MEDIUM" checked>
                                    <div class="prio-card-ico">🟡</div><div class="prio-card-lbl">Medium</div>
                                </label>
                                <label class="prio-card p-high" onclick="selPrio(this)">
                                    <input type="radio" name="priority" value="HIGH">
                                    <div class="prio-card-ico">🟠</div><div class="prio-card-lbl">High</div>
                                </label>
                                <label class="prio-card p-urg" onclick="selPrio(this)">
                                    <input type="radio" name="priority" value="URGENT">
                                    <div class="prio-card-ico">🔴</div><div class="prio-card-lbl">Urgent</div>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="form-ft">
                        <button type="submit" class="btn-sub"><i class="fas fa-paper-plane"></i> Submit Request</button>
                        <a href="<%=ctx%>/customerServiceRequests" class="btn-back"><i class="fas fa-arrow-left"></i> Back</a>
                    </div>
                </form>
            </div>
            <%}%>
        </main>

        <script>
            const CTX = '<%=ctx%>';

            function selPrio(el) {
                document.querySelectorAll('.prio-card').forEach(c => c.classList.remove('sel'));
                el.classList.add('sel');
                el.querySelector('input').checked = true;
            }

            function loadEquipment(sel) {
                const cid = sel.value;
                const wrap = document.getElementById('eqWrap');
                const empty = document.getElementById('eqEmpty');
                const load = document.getElementById('eqLoad');
                const info = document.getElementById('contractInfo');
                const hint = document.getElementById('hintSelected');

                // Clear existing equipment items
                wrap.querySelectorAll('.eq-item').forEach(e => e.remove());
                hint.style.display = 'none';
                info.style.display = 'none';

                if (!cid) {
                    empty.style.display = 'block';
                    load.style.display = 'none';
                    return;
                }

                // Show contract type info
                const opt = sel.options[sel.selectedIndex];
                const type = opt.dataset.type;
                info.style.display = 'block';
                info.innerHTML = '<i class="fas fa-info-circle"></i> <strong>' + (type === 'WARRANTY' ? 'Warranty' : 'Maintenance') + '</strong> contract — ' + (type === 'WARRANTY' ? 'Repairs are free within the warranty period' : 'Repair costs will be charged based on actual work');

                empty.style.display = 'none';
                load.style.display = 'block';

                fetch(CTX + '/customerServiceRequests?action=getEquipment&contractId=' + cid)
                        .then(r => r.json())
                        .then(data => {
                            load.style.display = 'none';
                            if (data.length === 0) {
                                empty.textContent = 'This contract has no equipment.';
                                empty.style.display = 'block';
                                return;
                            }
                            data.forEach(eq => {
                                const div = document.createElement('div');
                                div.className = 'eq-item';
                                div.innerHTML =
                                        '<input type="checkbox" name="equipmentIds[]" value="' + eq.id + '" id="eq' + eq.id + '"'
                                        + ' onchange="toggleDesc(this,' + eq.id + ')">'
                                        + '<div class="eq-item-info">'
                                        + '<label for="eq' + eq.id + '" style="cursor:pointer">'
                                        + '<div class="eq-item-name">' + eq.name + '</div>'
                                        + '<div class="eq-item-serial"><i class="fas fa-barcode" style="font-size:.7rem"></i> ' + eq.serial
                                        + ' · <span style="background:' + (eq.source === 'EXTERNAL' ? '#fef9c3' : '#e0e7ff') + ';color:' + (eq.source === 'EXTERNAL' ? '#854d0e' : '#3730a3') + ';padding:1px 5px;border-radius:3px;font-size:.7rem">' + (eq.source === 'EXTERNAL' ? 'External' : 'In-System') + '</span></div>'
                                        + '</label>'
                                        + '<div class="eq-item-desc" id="desc-wrap-' + eq.id + '">'
                                        + '<textarea name="issueDescs[]" placeholder="Describe the specific issue for this equipment (optional)..." id="desc-' + eq.id + '"></textarea>'
                                        + '</div>'
                                        + '</div>';
                                wrap.appendChild(div);
                            });
                            updateHint();
                            wrap.querySelectorAll('input[type=checkbox]').forEach(cb => cb.addEventListener('change', updateHint));
                        })
                        .catch(() => {
                            load.style.display = 'none';
                            empty.textContent = 'Error loading equipment list.';
                            empty.style.display = 'block';
                        });
            }

            function toggleDesc(cb, id) {
                const dw = document.getElementById('desc-wrap-' + id);
                if (dw)
                    dw.style.display = cb.checked ? 'block' : 'none';
                updateHint();
            }

            function updateHint() {
                const checked = document.querySelectorAll('input[name="equipmentIds[]"]:checked').length;
                const h = document.getElementById('hintSelected');
                h.style.display = checked > 0 ? 'block' : 'none';
                if (checked > 0)
                    h.textContent = '✓ ' + checked + ' equipment selected';
            }

            function validate() {
                const cid = document.getElementById('contractSel').value;
                if (!cid) {
                    alert('Please select a contract!');
                    return false;
                }
                const checked = document.querySelectorAll('input[name="equipmentIds[]"]:checked').length;
                if (checked === 0) {
                    alert('Please select at least 1 piece of equipment to repair!');
                    return false;
                }
                return true;
            }
        </script>
    </body></html>
