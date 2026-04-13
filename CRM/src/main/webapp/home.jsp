<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>DRSMS System — Device Repair Service Management</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                /* Landing page dark palette — kept */
                --navy:      #0b1437;
                --navy-2:    #0f1c4d;
                --navy-3:    #162055;
                --navy-card: #111a42;

                /* Accent — synced to Dashboard indigo palette */
                --accent:      #4f46e5;
                --accent-2:    #6366f1;
                --accent-3:    #818cf8;
                --accent-glow: rgba(79,70,229,0.28);

                --surface:   #ffffff;
                --text:      #ffffff;
                --text-2:    #c8d4f0;
                --muted:     #7a8ab8;
                --border:    rgba(255,255,255,0.08);
            }
            *, *::before, *::after {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            html {
                scroll-behavior: smooth;
            }
            body {
                font-family: 'Sora', sans-serif;
                background: var(--navy);
                color: var(--text);
                overflow-x: hidden;
            }
            /* Scrollbar — synced from Dashboard */
            ::-webkit-scrollbar {
                width: 4px;
            }
            ::-webkit-scrollbar-track {
                background: transparent;
            }
            ::-webkit-scrollbar-thumb {
                background: rgba(79,70,229,0.4);
                border-radius: 4px;
            }

            /* ── NAVBAR ── */
            .navbar {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                z-index: 200;
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 20px 64px;
                transition: all 0.4s cubic-bezier(.4,0,.2,1);
            }
            .navbar.scrolled {
                background: rgba(11,20,55,0.92);
                backdrop-filter: blur(24px);
                border-bottom: 1px solid var(--border);
                box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            }
            .navbar-brand {
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 1.1rem;
                font-weight: 700;
                color: white;
                text-decoration: none;
                letter-spacing: -0.3px;
            }
            .brand-icon {
                width: 36px;
                height: 36px;
                background: linear-gradient(135deg, #818cf8, #a78bfa);
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 0.85rem;
                box-shadow: 0 4px 12px rgba(129,140,248,0.4);
            }
            .navbar-links {
                display: flex;
                align-items: center;
                gap: 32px;
            }
            .nav-link {
                font-size: 0.82rem;
                font-weight: 500;
                color: var(--muted);
                text-decoration: none;
                position: relative;
                padding: 4px 0;
                transition: color 0.25s;
            }
            .nav-link::after {
                content: '';
                position: absolute;
                bottom: 0;
                left: 0;
                width: 0;
                height: 2px;
                background: linear-gradient(to right, var(--accent-3), var(--accent-2));
                border-radius: 2px;
                transition: width 0.3s cubic-bezier(.4,0,.2,1);
            }
            .nav-link:hover, .nav-link.active {
                color: white;
            }
            .nav-link:hover::after, .nav-link.active::after {
                width: 100%;
            }
            .nav-user {
                font-size: 0.82rem;
                color: var(--muted);
                font-weight: 500;
            }
            .btn-signin {
                display: inline-flex;
                align-items: center;
                gap: 7px;
                padding: 9px 22px;
                background: var(--accent);
                color: white;
                text-decoration: none;
                font-size: 0.82rem;
                font-weight: 600;
                border-radius: 100px;
                box-shadow: 0 4px 16px var(--accent-glow);
                transition: all 0.3s cubic-bezier(.4,0,.2,1);
            }
            .btn-signin:hover {
                background: #4338ca;
                transform: translateY(-2px);
                box-shadow: 0 8px 28px rgba(79,70,229,0.45);
            }
            .btn-logout {
                display: inline-flex;
                align-items: center;
                gap: 7px;
                padding: 8px 18px;
                border: 1px solid var(--border);
                color: var(--muted);
                text-decoration: none;
                font-size: 0.82rem;
                font-weight: 500;
                border-radius: 100px;
                transition: all 0.25s;
            }
            .btn-logout:hover {
                border-color: #ef4444;
                color: #ef4444;
            }

            /* ── HERO ── */
            .hero {
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 120px 64px 80px;
                position: relative;
                overflow: hidden;
                background: radial-gradient(ellipse 80% 60% at 50% 0%, #162055 0%, var(--navy) 70%);
            }
            .hero::before {
                content: '';
                position: absolute;
                inset: 0;
                background-image:
                    radial-gradient(1.5px 1.5px at 15% 20%, rgba(255,255,255,0.5) 0%, transparent 100%),
                    radial-gradient(1px 1px at 35% 45%, rgba(255,255,255,0.3) 0%, transparent 100%),
                    radial-gradient(2px 2px at 55% 15%, rgba(255,255,255,0.4) 0%, transparent 100%),
                    radial-gradient(1px 1px at 70% 60%, rgba(255,255,255,0.25) 0%, transparent 100%),
                    radial-gradient(1.5px 1.5px at 85% 30%, rgba(255,255,255,0.45) 0%, transparent 100%),
                    radial-gradient(1px 1px at 25% 70%, rgba(255,255,255,0.3) 0%, transparent 100%),
                    radial-gradient(2px 2px at 90% 80%, rgba(255,255,255,0.2) 0%, transparent 100%),
                    radial-gradient(1px 1px at 45% 85%, rgba(255,255,255,0.35) 0%, transparent 100%);
                pointer-events: none;
            }
            .orb {
                position: absolute;
                border-radius: 50%;
                filter: blur(100px);
                pointer-events: none;
            }
            .orb-1 {
                width: 500px;
                height: 500px;
                background: radial-gradient(circle, rgba(79,70,229,0.2) 0%, transparent 70%);
                top: -80px;
                right: 0;
                animation: orbFloat 10s ease-in-out infinite;
            }
            .orb-2 {
                width: 350px;
                height: 350px;
                background: radial-gradient(circle, rgba(129,140,248,0.15) 0%, transparent 70%);
                bottom: 0;
                left: -50px;
                animation: orbFloat 13s ease-in-out infinite reverse;
            }
            @keyframes orbFloat {
                0%,100%{
                    transform:translate(0,0)
                }
                50%{
                    transform:translate(30px,-30px)
                }
            }

            .hero-inner {
                position: relative;
                z-index: 1;
                text-align: center;
                max-width: 820px;
            }

            .hero-badge {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 7px 18px;
                background: rgba(79,70,229,0.15);
                border: 1px solid rgba(129,140,248,0.35);
                color: var(--accent-3);
                font-size: 0.75rem;
                font-weight: 600;
                border-radius: 100px;
                margin-bottom: 28px;
                opacity: 0;
                animation: slideUp 0.6s 0.1s ease forwards;
            }
            .hero-badge i {
                color: #fbbf24;
            }

            .hero-title {
                font-size: clamp(2.8rem, 6vw, 5rem);
                font-weight: 800;
                line-height: 1.08;
                letter-spacing: -2px;
                color: white;
                margin-bottom: 24px;
                opacity: 0;
                animation: slideUp 0.7s 0.25s ease forwards;
            }
            .hero-title .highlight {
                background: linear-gradient(135deg, #a5b4fc 0%, #818cf8 50%, #c4b5fd 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }

            .hero-sub {
                font-size: 1.05rem;
                font-weight: 300;
                color: var(--text-2);
                line-height: 1.8;
                max-width: 580px;
                margin: 0 auto 48px;
                opacity: 0;
                animation: slideUp 0.7s 0.4s ease forwards;
            }

            .hero-actions {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 14px;
                opacity: 0;
                animation: slideUp 0.7s 0.55s ease forwards;
            }
            .btn-hero-primary {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 15px 34px;
                background: var(--accent);
                color: white;
                text-decoration: none;
                font-size: 0.9rem;
                font-weight: 600;
                border-radius: 100px;
                box-shadow: 0 8px 32px var(--accent-glow);
                transition: all 0.35s cubic-bezier(.4,0,.2,1);
            }
            .btn-hero-primary:hover {
                background: #4338ca;
                transform: translateY(-3px);
                box-shadow: 0 16px 48px rgba(79,70,229,0.5);
            }
            .btn-hero-primary i {
                transition: transform 0.3s;
            }
            .btn-hero-primary:hover i {
                transform: translateX(4px);
            }

            .btn-hero-ghost {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 15px 28px;
                color: var(--text-2);
                text-decoration: none;
                font-size: 0.9rem;
                font-weight: 500;
                border-radius: 100px;
                border: 1px solid var(--border);
                transition: all 0.3s;
                background: rgba(255,255,255,0.04);
            }
            .btn-hero-ghost:hover {
                border-color: rgba(255,255,255,0.25);
                color: white;
                background: rgba(255,255,255,0.08);
                transform: translateY(-2px);
            }

            /* Stat cards */
            .hero-cards {
                display: flex;
                justify-content: center;
                gap: 16px;
                margin-top: 64px;
                opacity: 0;
                animation: slideUp 0.8s 0.7s ease forwards;
            }
            .hero-stat-card {
                background: rgba(255,255,255,0.06);
                border: 1px solid var(--border);
                border-radius: 16px;
                padding: 18px 24px;
                display: flex;
                align-items: center;
                gap: 12px;
                backdrop-filter: blur(12px);
                transition: all 0.3s cubic-bezier(.4,0,.2,1);
            }
            .hero-stat-card:hover {
                background: rgba(255,255,255,0.1);
                border-color: rgba(129,140,248,0.4);
                transform: translateY(-4px);
                box-shadow: 0 12px 32px rgba(0,0,0,0.3);
            }
            .hero-stat-icon {
                width: 40px;
                height: 40px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1rem;
            }
            .hero-stat-num {
                font-size: 1.3rem;
                font-weight: 800;
                color: white;
                line-height: 1;
            }
            .hero-stat-lbl {
                font-size: 0.72rem;
                color: var(--muted);
                margin-top: 2px;
            }

            /* ── DIVIDER ── */
            .section-divider {
                height: 1px;
                background: linear-gradient(to right, transparent, var(--border), transparent);
                margin: 0 64px;
            }

            /* ── SECTIONS ── */
            section {
                padding: 100px 64px;
            }
            .sec-label {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                font-size: 0.7rem;
                font-weight: 700;
                letter-spacing: 2.5px;
                text-transform: uppercase;
                color: var(--accent-3);
                margin-bottom: 16px;
            }
            .sec-label::before {
                content: '';
                display: inline-block;
                width: 20px;
                height: 2px;
                background: var(--accent-3);
                border-radius: 2px;
            }
            .sec-title {
                font-size: clamp(1.8rem, 3.5vw, 2.8rem);
                font-weight: 800;
                letter-spacing: -0.8px;
                line-height: 1.15;
                color: white;
                margin-bottom: 14px;
            }
            .sec-sub {
                font-size: 0.95rem;
                color: var(--muted);
                line-height: 1.75;
                max-width: 500px;
                font-weight: 300;
            }

            /* ── FEATURES ── */
            .features-section {
                background: linear-gradient(180deg, var(--navy) 0%, var(--navy-2) 100%);
            }
            .features-grid {
                display: grid;
                grid-template-columns: repeat(3,1fr);
                gap: 20px;
                margin-top: 52px;
            }
            .feat-card {
                background: var(--navy-card);
                border: 1px solid var(--border);
                border-radius: 20px;
                padding: 36px 30px;
                transition: all 0.4s cubic-bezier(.4,0,.2,1);
                position: relative;
                overflow: hidden;
            }
            .feat-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 2px;
                background: linear-gradient(to right, transparent, var(--accent-3), transparent);
                opacity: 0;
                transition: opacity 0.4s;
            }
            .feat-card:hover {
                transform: translateY(-8px);
                border-color: rgba(129,140,248,0.3);
                box-shadow: 0 24px 48px rgba(0,0,0,0.4), 0 0 0 1px rgba(79,70,229,0.1);
            }
            .feat-card:hover::before {
                opacity: 1;
            }
            .feat-icon {
                width: 52px;
                height: 52px;
                border-radius: 14px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.2rem;
                margin-bottom: 22px;
                transition: transform 0.35s cubic-bezier(.4,0,.2,1);
            }
            .feat-card:hover .feat-icon {
                transform: scale(1.12) rotate(-5deg);
            }
            .feat-card h3 {
                font-size: 1.05rem;
                font-weight: 700;
                color: white;
                margin-bottom: 10px;
            }
            .feat-card p {
                font-size: 0.85rem;
                color: var(--muted);
                line-height: 1.75;
                font-weight: 300;
            }

            /* ── ABOUT ── */
            .about-section {
                background: var(--navy-2);
            }
            .about-grid {
                display: grid;
                grid-template-columns: repeat(3,1fr);
                gap: 24px;
                margin-top: 52px;
            }
            .about-card {
                padding: 36px 28px;
                border-radius: 20px;
                background: rgba(255,255,255,0.03);
                border: 1px solid var(--border);
                transition: all 0.35s cubic-bezier(.4,0,.2,1);
            }
            .about-card:hover {
                transform: translateY(-6px);
                background: rgba(79,70,229,0.07);
                border-color: rgba(129,140,248,0.25);
                box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            }
            .about-num {
                font-size: 3.5rem;
                font-weight: 800;
                line-height: 1;
                margin-bottom: 12px;
                letter-spacing: -2px;
                color: rgba(255,255,255,0.07);
                transition: color 0.35s;
            }
            .about-card:hover .about-num {
                color: rgba(79,70,229,0.3);
            }
            .about-card i {
                font-size: 1.2rem;
                margin-bottom: 14px;
                display: block;
            }
            .about-card h3 {
                font-size: 1rem;
                font-weight: 700;
                color: white;
                margin-bottom: 10px;
            }
            .about-card p {
                font-size: 0.84rem;
                color: var(--muted);
                line-height: 1.75;
                font-weight: 300;
            }

            /* ── CONTACT ── */
            .contact-section {
                background: var(--navy);
            }
            .contact-grid {
                display: grid;
                grid-template-columns: repeat(3,1fr);
                gap: 20px;
                margin-top: 52px;
            }
            .contact-card {
                background: var(--navy-card);
                border-radius: 20px;
                padding: 36px 28px;
                border: 1px solid var(--border);
                text-align: center;
                transition: all 0.35s cubic-bezier(.4,0,.2,1);
            }
            .contact-card:hover {
                transform: translateY(-6px);
                border-color: rgba(129,140,248,0.3);
                box-shadow: 0 20px 40px rgba(0,0,0,0.35);
            }
            .contact-icon {
                width: 56px;
                height: 56px;
                border-radius: 16px;
                background: rgba(79,70,229,0.12);
                color: var(--accent-3);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.2rem;
                margin: 0 auto 20px;
                transition: all 0.3s;
            }
            .contact-card:hover .contact-icon {
                background: linear-gradient(135deg, #818cf8, #a78bfa);
                color: white;
                transform: scale(1.1);
                box-shadow: 0 8px 20px rgba(129,140,248,0.35);
            }
            .contact-card h3 {
                font-size: 0.9rem;
                font-weight: 700;
                color: white;
                margin-bottom: 10px;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            .contact-card p {
                font-size: 0.84rem;
                color: var(--muted);
                line-height: 1.9;
                font-weight: 300;
            }

            /* ── CTA BANNER ── */
            .cta-banner {
                margin: 0 64px 80px;
                border-radius: 24px;
                padding: 72px 64px;
                text-align: center;
                background: linear-gradient(135deg, var(--navy-3) 0%, #1a2a7a 50%, #1e1060 100%);
                border: 1px solid rgba(129,140,248,0.25);
                position: relative;
                overflow: hidden;
                box-shadow: 0 32px 80px rgba(0,0,0,0.4), inset 0 1px 0 rgba(255,255,255,0.08);
            }
            .cta-banner::before {
                content: '';
                position: absolute;
                top: -120px;
                right: -80px;
                width: 400px;
                height: 400px;
                background: radial-gradient(circle, rgba(79,70,229,0.2) 0%, transparent 70%);
                border-radius: 50%;
            }
            .cta-banner::after {
                content: '';
                position: absolute;
                bottom: -100px;
                left: -60px;
                width: 300px;
                height: 300px;
                background: radial-gradient(circle, rgba(167,139,250,0.15) 0%, transparent 70%);
                border-radius: 50%;
            }
            .cta-banner h2 {
                font-size: 2.4rem;
                font-weight: 800;
                color: white;
                margin-bottom: 14px;
                letter-spacing: -0.8px;
                position: relative;
                z-index: 1;
            }
            .cta-banner p  {
                font-size: 1rem;
                color: var(--text-2);
                margin-bottom: 36px;
                font-weight: 300;
                position: relative;
                z-index: 1;
            }
            .btn-cta {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 14px 36px;
                background: var(--accent);
                color: white;
                text-decoration: none;
                font-size: 0.9rem;
                font-weight: 700;
                border-radius: 100px;
                position: relative;
                z-index: 1;
                box-shadow: 0 8px 28px var(--accent-glow);
                transition: all 0.3s cubic-bezier(.4,0,.2,1);
            }
            .btn-cta:hover {
                background: #4338ca;
                transform: translateY(-3px) scale(1.03);
                box-shadow: 0 16px 48px rgba(79,70,229,0.5);
            }
            .btn-cta i {
                transition: transform 0.3s;
            }
            .btn-cta:hover i {
                transform: translateX(5px);
            }

            /* ── FOOTER ── */
            .footer {
                background: var(--navy);
                border-top: 1px solid var(--border);
                padding: 32px 64px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .footer-brand {
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 0.95rem;
                font-weight: 700;
                color: white;
            }
            .footer p {
                font-size: 0.8rem;
                color: var(--muted);
            }

            /* ── ANIMATIONS ── */
            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(24px);
                }
                to   {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            .reveal {
                opacity: 0;
                transform: translateY(30px);
                transition: opacity 0.65s cubic-bezier(.4,0,.2,1), transform 0.65s cubic-bezier(.4,0,.2,1);
            }
            .reveal.visible {
                opacity: 1;
                transform: translateY(0);
            }
            .reveal-d1 {
                transition-delay: 0.1s;
            }
            .reveal-d2 {
                transition-delay: 0.2s;
            }
            .reveal-d3 {
                transition-delay: 0.3s;
            }
        </style>
    </head>
    <body>

        <nav class="navbar" id="navbar">
            <a href="home.jsp" class="navbar-brand">
                <div class="brand-icon"><i class="fas fa-bolt"></i></div>
                DRSMS
            </a>
            <div class="navbar-links">
                <a href="home.jsp" class="nav-link active">Home</a>
                <a href="#features" class="nav-link">Features</a>
                <a href="#about" class="nav-link">About</a>
                <a href="#contact" class="nav-link">Contact</a>
                <% if (currentUser != null) { %>
                <span class="nav-user">Hello, <%= currentUser.getFullName() %></span>
                <a href="<%=ctx%>/logout" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
                <% } else { %>
                <a href="<%=ctx%>/login.jsp" class="btn-signin"><i class="fas fa-arrow-right"></i> Sign In</a>
                <% } %>
            </div>
        </nav>

        <!-- HERO -->
        <section class="hero">
            <div class="orb orb-1"></div>
            <div class="orb orb-2"></div>
            <div class="hero-inner">
                <div class="hero-badge"><i class="fas fa-star"></i> Trusted by 500+ businesses</div>
                <h1 class="hero-title">
                    Manage Repairs<br>
                    <span class="highlight">Smarter & Faster</span>
                </h1>
                <p class="hero-sub">A comprehensive platform for customer care, contract management, and equipment tracking — built to elevate your repair service operation.</p>
                <div class="hero-actions">
                    <a href="<%=ctx%>/login.jsp" class="btn-hero-primary">Get Started <i class="fas fa-arrow-right"></i></a>
                    <a href="#features" class="btn-hero-ghost"><i class="fas fa-play"></i> See Features</a>
                </div>
                <div class="hero-cards">
                    <div class="hero-stat-card">
                        <div class="hero-stat-icon" style="background:rgba(129,140,248,0.15);color:#a5b4fc"><i class="fas fa-users"></i></div>
                        <div><div class="hero-stat-num">500+</div><div class="hero-stat-lbl">Businesses</div></div>
                    </div>
                    <div class="hero-stat-card">
                        <div class="hero-stat-icon" style="background:rgba(16,185,129,0.15);color:#34d399"><i class="fas fa-check-circle"></i></div>
                        <div><div class="hero-stat-num">99.9%</div><div class="hero-stat-lbl">Uptime</div></div>
                    </div>
                    <div class="hero-stat-card">
                        <div class="hero-stat-icon" style="background:rgba(251,191,36,0.15);color:#fbbf24"><i class="fas fa-headset"></i></div>
                        <div><div class="hero-stat-num">24/7</div><div class="hero-stat-lbl">Support</div></div>
                    </div>
                </div>
            </div>
        </section>

        <!-- FEATURES -->
        <section class="features-section" id="features">
            <div class="sec-label reveal">Core Features</div>
            <h2 class="sec-title reveal">Everything You Need<br>In One Platform</h2>
            <p class="sec-sub reveal">Powerful tools designed to streamline every aspect of your repair service business.</p>
            <div class="features-grid">
                <div class="feat-card reveal reveal-d1">
                    <div class="feat-icon" style="background:rgba(79,70,229,0.12);color:#a5b4fc"><i class="fas fa-users"></i></div>
                    <h3>Customer Management</h3>
                    <p>Track complete information and transaction history for every customer in one organized, accessible place.</p>
                </div>
                <div class="feat-card reveal reveal-d2">
                    <div class="feat-icon" style="background:rgba(16,185,129,0.12);color:#34d399"><i class="fas fa-laptop"></i></div>
                    <h3>Equipment Management</h3>
                    <p>Monitor equipment status, maintenance schedules, and repair history with effortless precision.</p>
                </div>
                <div class="feat-card reveal reveal-d3">
                    <div class="feat-icon" style="background:rgba(251,191,36,0.12);color:#fbbf24"><i class="fas fa-file-contract"></i></div>
                    <h3>Contract Management</h3>
                    <p>Create, track, and manage all customer contracts with smart notifications and status tracking.</p>
                </div>
            </div>
        </section>

        <div class="section-divider"></div>

        <!-- ABOUT -->
        <section class="about-section" id="about">
            <div class="sec-label reveal">About Us</div>
            <h2 class="sec-title reveal">Built with Purpose,<br>Designed for Growth</h2>
            <p class="sec-sub reveal">A passionate team focused on delivering the most intuitive service management experience.</p>
            <div class="about-grid">
                <div class="about-card reveal reveal-d1">
                    <div class="about-num">01</div>
                    <i class="fas fa-bullseye" style="color:var(--accent-3)"></i>
                    <h3>Our Vision</h3>
                    <p>To become Vietnam's most trusted repair service platform — empowering thousands of businesses to operate with confidence.</p>
                </div>
                <div class="about-card reveal reveal-d2">
                    <div class="about-num">02</div>
                    <i class="fas fa-heart" style="color:#f87171"></i>
                    <h3>Core Values</h3>
                    <p>Customer-first thinking, radical transparency, and a relentless commitment to continuous improvement in everything we build.</p>
                </div>
                <div class="about-card reveal reveal-d3">
                    <div class="about-num">03</div>
                    <i class="fas fa-trophy" style="color:#fbbf24"></i>
                    <h3>Recognition</h3>
                    <p>Trusted by over 500 businesses with 99.9% uptime and a dedicated 24/7 support team always ready to help.</p>
                </div>
            </div>
        </section>

        <div class="section-divider"></div>

        <!-- CONTACT -->
        <section class="contact-section" id="contact">
            <div class="sec-label reveal">Get in Touch</div>
            <h2 class="sec-title reveal">We're Here<br>Whenever You Need Us</h2>
            <p class="sec-sub reveal">Reach out through any channel — our team responds promptly and with care.</p>
            <div class="contact-grid">
                <div class="contact-card reveal reveal-d1">
                    <div class="contact-icon"><i class="fas fa-map-marker-alt"></i></div>
                    <h3>Address</h3>
                    <p>Hoa Lac Hi-Tech Park<br>Hanoi, Vietnam</p>
                </div>
                <div class="contact-card reveal reveal-d2">
                    <div class="contact-icon"><i class="fas fa-phone"></i></div>
                    <h3>Phone</h3>
                    <p>Hotline: 1800 1234<br>Support: (024) 3768 9999</p>
                </div>
                <div class="contact-card reveal reveal-d3">
                    <div class="contact-icon"><i class="fas fa-envelope"></i></div>
                    <h3>Email</h3>
                    <p>support@drsmsystem.vn<br>sales@drsmsystem.vn</p>
                </div>
            </div>
        </section>

        <!-- CTA -->
        <div class="cta-banner reveal">
            <h2>Ready to Get Started?</h2>
            <p>Join hundreds of businesses already using DRSMS to streamline their operations.</p>
            <a href="<%=ctx%>/login.jsp" class="btn-cta">Start for Free <i class="fas fa-arrow-right"></i></a>
        </div>

        <!-- FOOTER -->
        <footer class="footer">
            <div class="footer-brand">
                <div class="brand-icon" style="width:28px;height:28px;font-size:0.7rem"><i class="fas fa-bolt"></i></div>
                DRSMS System
            </div>
            <p>&copy; 2026 DRSMS System. All rights reserved.</p>
        </footer>

        <script>
            const navbar = document.getElementById('navbar');
            window.addEventListener('scroll', () => {
                navbar.classList.toggle('scrolled', window.scrollY > 40);
            }, {passive: true});

            const io = new IntersectionObserver((entries) => {
                entries.forEach(e => {
                    if (e.isIntersecting) {
                        e.target.classList.add('visible');
                        io.unobserve(e.target);
                    }
                });
            }, {threshold: 0.1});
            document.querySelectorAll('.reveal').forEach(el => io.observe(el));
        </script>
    </body>
</html>
