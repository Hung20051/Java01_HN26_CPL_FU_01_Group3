<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.CartItem, java.util.*, java.text.*" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<CartItem> cartList = (List<CartItem>) request.getAttribute("cartList");
    if (cartList == null) cartList = new ArrayList<>();
    double grandTotal   = request.getAttribute("grandTotal") != null ? (double)request.getAttribute("grandTotal") : 0;
    int    cartCount    = request.getAttribute("cartCount")  != null ? (int)request.getAttribute("cartCount")  : 0;
    int    pendingSR    = request.getAttribute("pendingSR")  != null ? (int)request.getAttribute("pendingSR")  : 0;
    int    unpaidInv    = request.getAttribute("unpaidInv")  != null ? (int)request.getAttribute("unpaidInv")  : 0;
    int    unreadChat   = request.getAttribute("unreadChat") != null ? (int)request.getAttribute("unreadChat") : 0;
    String flashSuccess = (String) request.getAttribute("flashSuccess");
    String flashError   = (String) request.getAttribute("flashError");
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
    String ctx = request.getContextPath();
    String initials = me.getFullName()!=null&&!me.getFullName().isEmpty()
        ? me.getFullName().substring(0,1).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Cart - DRSMS</title>
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

        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{scroll-behavior:smooth}
        body{font-family:'Sora',sans-serif;background:var(--bg);color:var(--text-b);min-height:100vh;display:flex;}
        ::-webkit-scrollbar{width:4px}
        ::-webkit-scrollbar-track{background:transparent}
        ::-webkit-scrollbar-thumb{background:rgba(79,70,229,0.3);border-radius:4px}

        /* ═══════════ SIDEBAR ═══════════ */
        .sb{
            width:var(--sb-width); min-height:100vh;
            background:var(--sb-bg);
            border-right:1px solid rgba(79,70,229,0.2);
            display:flex; flex-direction:column;
            position:fixed; top:0; left:0; z-index:100;
            box-shadow:4px 0 24px rgba(0,0,0,0.15);
        }
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
        .sb-badge{margin-left:auto;background:#ef4444;color:#fff;font-size:.6rem;font-weight:700;padding:2px 7px;border-radius:20px;box-shadow:0 2px 6px rgba(239,68,68,0.5);}
        .sb-foot{padding:12px 10px 14px;border-top:1px solid var(--sb-border)}
        .sb-user{display:flex;align-items:center;gap:9px;padding:9px 10px;border-radius:10px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);margin-bottom:5px;text-decoration:none;transition:all .18s;}
        .sb-user:hover{background:rgba(129,140,248,0.18);border-color:rgba(129,140,248,0.3)}
        .sb-ava{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#818cf8,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:.88rem;font-weight:700;flex-shrink:0;overflow:hidden;}
        .sb-ava img{width:34px;height:34px;object-fit:cover;border-radius:50%}
        .sb-uname{color:#fff;font-size:.8rem;font-weight:600}
        .sb-urole{color:rgba(255,255,255,0.35);font-size:.66rem;margin-top:1px}
        .sb-logout{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border-radius:9px;color:rgba(255,255,255,0.3);text-decoration:none;font-size:.78rem;transition:all .18s;}
        .sb-logout:hover{color:#fca5a5;background:rgba(239,68,68,0.1)}

        /* ═══════════ MAIN (light) ═══════════ */
        .main{margin-left:var(--sb-width);flex:1;min-height:100vh;display:flex;flex-direction:column}

        .topbar{
            display:flex;justify-content:space-between;align-items:center;
            padding:18px 28px;
            background:var(--bg-topbar);
            border-bottom:1px solid var(--border-light);
            position:sticky;top:0;z-index:50;
            box-shadow:0 1px 6px rgba(0,0,0,0.06);
        }
        .topbar-title{font-size:1.2rem;font-weight:800;color:var(--text-h);letter-spacing:-.3px}
        .topbar-sub{color:var(--text-s);font-size:.78rem;margin-top:2px}
        .content{padding:24px 28px;flex:1}

        /* ── ALERTS ── */
        .alert{display:flex;align-items:center;gap:10px;padding:12px 16px;border-radius:12px;font-size:.82rem;margin-bottom:18px;animation:cardIn .4s ease both;}
        .alert-success{background:#d1fae5;border:1px solid #a7f3d0;color:#065f46}
        .alert-error  {background:#fee2e2;border:1px solid #fca5a5;color:#991b1b}
        @keyframes cardIn{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}

        /* ── LAYOUT ── */
        .layout{display:grid;grid-template-columns:1fr 340px;gap:20px;align-items:start;}

        /* ── CART TABLE CARD ── */
        .cart-card{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:16px;overflow:hidden;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
            animation:cardIn .5s ease both;
        }
        .cart-header{
            padding:14px 18px;
            border-bottom:1px solid var(--border-light2);
            display:flex;justify-content:space-between;align-items:center;
            background:#fafbff;
        }
        .cart-header h2{font-size:.9rem;font-weight:700;color:var(--text-h);display:flex;align-items:center;gap:8px;}
        .cart-header h2 i{color:var(--orange)}
        .btn-clear{
            background:none;border:none;
            color:var(--text-s);font-family:'Sora',sans-serif;
            font-size:.77rem;cursor:pointer;
            display:flex;align-items:center;gap:5px;
            transition:all .2s;padding:5px 8px;border-radius:7px;
        }
        .btn-clear:hover{color:var(--red);background:#fee2e2}

        /* Table */
        table{width:100%;border-collapse:collapse;font-size:.81rem}
        thead tr{background:#fafbff}
        th{
            padding:10px 16px;text-align:left;
            color:var(--text-s);font-weight:700;
            font-size:.67rem;text-transform:uppercase;letter-spacing:.8px;
            border-bottom:1px solid var(--border-light2);
        }
        td{
            padding:13px 16px;
            border-bottom:1px solid var(--border-light2);
            vertical-align:middle;color:var(--text-b);
        }
        tr:last-child td{border-bottom:none}
        tbody tr{transition:background .12s}
        tbody tr:hover td{background:#f7f8ff}

        .item-name{font-weight:700;color:var(--text-h);margin-bottom:2px;font-size:.84rem}
        .item-cat {font-size:.72rem;color:var(--text-s)}

        .item-type-badge{
            display:inline-flex;align-items:center;gap:3px;
            padding:2px 7px;border-radius:10px;
            font-size:.67rem;font-weight:700;margin-left:6px;
        }
        .badge-part {background:var(--primary-light);color:var(--purple)}
        .badge-equip{background:#e0f2fe;color:var(--info)}

        /* Qty controls */
        .qty-form{display:flex;align-items:center;gap:6px}
        .qty-btn{
            width:28px;height:28px;
            background:#fff;border:1.5px solid var(--border-light);
            border-radius:7px;cursor:pointer;
            font-size:1rem;font-weight:700;
            display:flex;align-items:center;justify-content:center;
            color:var(--text-m);transition:all .15s;
        }
        .qty-btn:hover{background:var(--primary-light);border-color:rgba(99,102,241,0.3);color:var(--primary-2)}
        .qty-display{width:36px;text-align:center;font-weight:700;font-size:.9rem;color:var(--text-h)}
        .btn-remove{
            background:none;border:none;
            color:var(--text-s);cursor:pointer;
            padding:5px 8px;border-radius:7px;transition:all .15s;
        }
        .btn-remove:hover{color:var(--red);background:#fee2e2}

        .price-cell   {font-weight:700;color:var(--text-m);white-space:nowrap}
        .subtotal-cell{font-weight:800;color:var(--orange);white-space:nowrap}

        /* ── ORDER SUMMARY ── */
        .summary-card{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:16px;padding:20px;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
            position:sticky;top:90px;
            animation:cardIn .5s .1s ease both;
        }
        .summary-title{
            font-size:.9rem;font-weight:700;color:var(--text-h);
            margin-bottom:16px;
            display:flex;align-items:center;gap:7px;
        }
        .summary-title i{color:var(--primary-2)}
        .summary-row{
            display:flex;justify-content:space-between;
            margin-bottom:9px;font-size:.83rem;color:var(--text-m);
        }
        .summary-divider{border:none;border-top:1px solid var(--border-light);margin:13px 0}
        .summary-total{
            display:flex;justify-content:space-between;
            font-size:1.06rem;font-weight:800;color:var(--text-h);
        }
        .summary-total span:last-child{color:var(--orange)}
        .summary-tax{font-size:.71rem;color:var(--text-s);text-align:right;margin-top:4px;margin-bottom:16px}

        /* Payment section */
        .pay-title{
            font-size:.76rem;font-weight:700;
            color:var(--text-s);text-transform:uppercase;
            letter-spacing:.8px;margin-bottom:10px;
        }
        .btn-pay{
            width:100%;padding:12px;border:none;border-radius:11px;
            font-family:'Sora',sans-serif;font-size:.88rem;font-weight:700;cursor:pointer;
            display:flex;align-items:center;justify-content:center;gap:8px;
            margin-bottom:9px;transition:all .2s;
        }
        .btn-cash{
            background:var(--green);color:#fff;
            box-shadow:0 4px 14px rgba(22,163,74,0.25);
        }
        .btn-cash:hover{background:#15803d;transform:translateY(-1px);box-shadow:0 7px 20px rgba(22,163,74,0.38)}
        .btn-vnpay{
            background:linear-gradient(135deg,#e30019,#b50014);
            color:#fff;box-shadow:0 4px 14px rgba(227,0,25,0.25);
        }
        .btn-vnpay:hover{transform:translateY(-1px);box-shadow:0 7px 20px rgba(227,0,25,0.38)}

        .btn-continue{
            width:100%;padding:10px;
            background:#fff;color:var(--text-m);
            border:1.5px solid var(--border-light);
            border-radius:11px;
            font-family:'Sora',sans-serif;font-size:.83rem;font-weight:600;
            cursor:pointer;margin-top:6px;
            display:flex;align-items:center;justify-content:center;gap:6px;
            text-decoration:none;transition:all .2s;
        }
        .btn-continue:hover{background:#f3f4f6;border-color:#d1d5db;color:var(--text-b)}

        /* ── EMPTY CART ── */
        .empty-cart-wrap{
            background:var(--bg-card);
            border:1px solid var(--border-light);
            border-radius:16px;
            box-shadow:0 1px 6px rgba(0,0,0,0.05);
            animation:cardIn .5s ease both;
        }
        .empty-cart{text-align:center;padding:64px 24px;color:var(--text-s);}
        .empty-cart i{font-size:3.5rem;margin-bottom:16px;display:block;opacity:.18;color:var(--text-m)}
        .empty-cart h3{font-size:1.05rem;font-weight:700;margin-bottom:8px;color:var(--text-h)}
        .empty-cart p {font-size:.83rem;color:var(--text-m);margin-bottom:4px}
        .btn-shop{
            display:inline-flex;align-items:center;gap:7px;
            padding:11px 26px;
            background:var(--primary);
            color:#fff;border-radius:11px;text-decoration:none;
            font-size:.875rem;font-weight:700;margin-top:16px;
            box-shadow:0 4px 14px rgba(79,70,229,0.3);
            transition:all .2s;
        }
        .btn-shop:hover{background:#4338ca;transform:translateY(-2px);box-shadow:0 8px 22px rgba(79,70,229,0.42)}
    </style>
</head>
<body>

    <%-- ═══════════ SIDEBAR ═══════════ --%>
    <aside class="sb">
        <div class="sb-brand">
            <div class="sb-logo"><i class="fas fa-bolt"></i></div>
            <div>
                <div class="sb-name">DRSMS</div>
                <div class="sb-role">Customer</div>
            </div>
        </div>
        <nav class="sb-nav">
            <div class="sb-lbl">Overview</div>
            <a href="<%=ctx%>/customerDashboard" class="sb-item">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <div class="sb-lbl">Services</div>
            <a href="<%=ctx%>/customerServiceRequests" class="sb-item">
                <i class="fas fa-clipboard-list"></i> Repair Requests
                <%if(pendingSR>0){%><span class="sb-badge"><%=pendingSR%></span><%}%>
            </a>
            <a href="<%=ctx%>/customerContracts" class="sb-item">
                <i class="fas fa-file-contract"></i> Contracts
            </a>
            <a href="<%=ctx%>/customerEquipment" class="sb-item">
                <i class="fas fa-desktop"></i> My Equipment
            </a>
            <div class="sb-lbl">Shop</div>
            <a href="<%=ctx%>/customerShop?action=parts" class="sb-item">
                <i class="fas fa-puzzle-piece"></i> Parts
            </a>
            <a href="<%=ctx%>/customerShop?action=equipment" class="sb-item">
                <i class="fas fa-server"></i> Equipment
            </a>
            <a href="<%=ctx%>/customerShop?action=cart" class="sb-item on">
                <i class="fas fa-shopping-cart"></i> Cart
                <%if(cartCount>0){%><span class="sb-badge"><%=cartCount%></span><%}%>
            </a>
            <div class="sb-lbl">Finance</div>
            <a href="<%=ctx%>/customerInvoices" class="sb-item">
                <i class="fas fa-receipt"></i> Invoices
                <%if(unpaidInv>0){%><span class="sb-badge"><%=unpaidInv%></span><%}%>
            </a>
            <div class="sb-lbl">Support</div>
            <a href="<%=ctx%>/customerChat" class="sb-item">
                <i class="fas fa-comment-dots"></i> Support Chat
                <%if(unreadChat>0){%><span class="sb-badge"><%=unreadChat%></span><%}%>
            </a>
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
                    <div class="sb-urole">Customer Account</div>
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
                <div class="topbar-title">
                    <i class="fas fa-shopping-cart" style="color:var(--orange);margin-right:8px;font-size:1rem"></i>
                    Cart <span style="color:var(--text-s);font-weight:500;font-size:1rem">(<%=cartCount%> item<%=cartCount!=1?"s":""%>)</span>
                </div>
                <div class="topbar-sub">Review your items and proceed to checkout</div>
            </div>
        </div>

        <div class="content">

            <%if(flashSuccess!=null){%>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=flashSuccess%></div>
            <%}%>
            <%if(flashError!=null){%>
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=flashError%></div>
            <%}%>

            <%if(cartList.isEmpty()){%>
            <div class="empty-cart-wrap">
                <div class="empty-cart">
                    <i class="fas fa-shopping-cart"></i>
                    <h3>Your cart is empty</h3>
                    <p>Add some items from the shop to get started.</p>
                    <a href="<%=ctx%>/customerShop?action=parts" class="btn-shop">
                        <i class="fas fa-store"></i> Continue Shopping
                    </a>
                </div>
            </div>
            <%}else{%>

            <div class="layout">

                <%-- Cart table --%>
                <div class="cart-card">
                    <div class="cart-header">
                        <h2><i class="fas fa-list"></i> Item List</h2>
                        <form method="post" action="<%=ctx%>/customerShop" style="display:inline">
                            <input type="hidden" name="action" value="clearCart">
                            <button type="submit" class="btn-clear"
                                    onclick="return confirm('Clear all items from cart?')">
                                <i class="fas fa-trash"></i> Clear All
                            </button>
                        </form>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>Unit Price</th>
                                <th>Quantity</th>
                                <th>Subtotal</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <%for(CartItem ci:cartList){%>
                            <tr>
                                <td>
                                    <div class="item-name">
                                        <%=ci.getName()%>
                                        <span class="item-type-badge <%="PART".equals(ci.getItemType())?"badge-part":"badge-equip"%>">
                                            <%="PART".equals(ci.getItemType())?"Part":"Equipment"%>
                                        </span>
                                    </div>
                                    <div class="item-cat"><%=ci.getCategoryName()%></div>
                                </td>
                                <td class="price-cell"><%=nf.format((long)ci.getUnitPrice())%> ₫</td>
                                <td>
                                    <div class="qty-form">
                                        <button type="button" class="qty-btn"
                                                onclick="changeQty('<%=ci.getKey()%>',<%=ci.getQuantity()-1%>)">−</button>
                                        <span class="qty-display" id="qty-<%=ci.getKey().replace("_","-")%>"><%=ci.getQuantity()%></span>
                                        <button type="button" class="qty-btn"
                                                onclick="changeQty('<%=ci.getKey()%>',<%=ci.getQuantity()+1%>)"
                                                <%=ci.getQuantity()>=ci.getMaxQty()?"disabled style='opacity:.35;cursor:not-allowed'":" "%>>+</button>
                                    </div>
                                </td>
                                <td class="subtotal-cell"><%=nf.format((long)ci.getSubtotal())%> ₫</td>
                                <td>
                                    <form method="post" action="<%=ctx%>/customerShop" style="display:inline">
                                        <input type="hidden" name="action" value="removeCart">
                                        <input type="hidden" name="key"    value="<%=ci.getKey()%>">
                                        <button type="submit" class="btn-remove">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <%}%>
                        </tbody>
                    </table>
                </div>

                <%-- Order summary --%>
                <div class="summary-card">
                    <div class="summary-title">
                        <i class="fas fa-receipt"></i> Order Summary
                    </div>
                    <div class="summary-row">
                        <span>Subtotal</span>
                        <span><%=nf.format((long)grandTotal)%> ₫</span>
                    </div>
                    <div class="summary-row">
                        <span>VAT (10%)</span>
                        <span><%=nf.format((long)(grandTotal*0.1))%> ₫</span>
                    </div>
                    <hr class="summary-divider">
                    <div class="summary-total">
                        <span>Total</span>
                        <span><%=nf.format((long)(grandTotal*1.1))%> ₫</span>
                    </div>
                    <div class="summary-tax">VAT included</div>

                    <div class="pay-title"><i class="fas fa-credit-card"></i> &nbsp;Payment Method</div>

                    <form method="post" action="<%=ctx%>/customerShop">
                        <input type="hidden" name="action"    value="checkout">
                        <input type="hidden" name="payMethod" value="cash">
                        <button type="submit" class="btn-pay btn-cash">
                            <i class="fas fa-money-bill-wave"></i> Pay with Cash
                        </button>
                    </form>

                    <form method="post" action="<%=ctx%>/customerShop">
                        <input type="hidden" name="action"    value="checkout">
                        <input type="hidden" name="payMethod" value="vnpay">
                        <button type="submit" class="btn-pay btn-vnpay">
                            <span style="font-weight:900;font-size:1rem;letter-spacing:-0.5px">VN</span>Pay &nbsp;— Pay Online
                        </button>
                    </form>

                    <a href="<%=ctx%>/customerShop?action=parts" class="btn-continue">
                        <i class="fas fa-arrow-left"></i> Continue Shopping
                    </a>
                </div>

            </div>
            <%}%>

        </div>
    </main>

    <form method="post" action="<%=ctx%>/customerShop" id="updateForm" style="display:none">
        <input type="hidden" name="action"   value="updateCart">
        <input type="hidden" name="key"      id="updateKey">
        <input type="hidden" name="quantity" id="updateQty">
    </form>

    <script>
        function changeQty(key, newQty) {
            if (newQty < 0) return;
            document.getElementById('updateKey').value = key;
            document.getElementById('updateQty').value = newQty;
            document.getElementById('updateForm').submit();
        }
    </script>
    <%@ include file="customerAIBubble.jsp" %>
</body>
</html>
