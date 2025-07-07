# api/urls.py - INTERACTIVE E-COMMERCE ADMIN PORTAL
from django.contrib import admin
from django.contrib.auth import authenticate, login
from django.shortcuts import render, redirect
from django.urls import path, include
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt

def backend_status(request):
    return JsonResponse({
        "status": "E-commerce Backend Running",
        "admin_portal": "/admin/",
        "seller_login": "/login/",
        "note": "Interactive e-commerce admin system"
    })

@csrf_exempt
def nuclear_admin_login(request):
    """Interactive e-commerce admin login interface"""
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        
        user = authenticate(request, username=username, password=password)
        if user and (user.is_staff or user.is_superuser):
            login(request, user)
            return redirect('/django-admin/')
        else:
            error = "Invalid credentials or insufficient permissions."
            return HttpResponse(get_interactive_html(error), content_type='text/html')
    
    # GET request - show interactive landing
    return HttpResponse(get_interactive_html(), content_type='text/html')

def get_interactive_html(error=None):
    """Interactive landing page with laptop click-to-login"""
    error_html = f'<div class="error-message">{error}</div>' if error else ''
    
    return f"""
<!DOCTYPE html>
<html>
<head>
    <title>Store Admin | Interactive Portal</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');
        
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        
        body {{
            font-family: 'Poppins', sans-serif;
            background: 
                linear-gradient(135deg, rgba(186, 123, 70, 0.9) 0%, rgba(210, 145, 95, 0.8) 50%, rgba(235, 170, 120, 0.9) 100%),
                url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="shop" patternUnits="userSpaceOnUse" width="30" height="30"><rect width="30" height="30" fill="%23d4915f"/><circle cx="8" cy="8" r="2" fill="%23c8845a" opacity="0.4"/><rect x="18" y="18" width="8" height="6" rx="2" fill="%23bc7b4a" opacity="0.3"/><path d="M5 20h8l2 4h-12z" fill="%23a8704a" opacity="0.2"/></pattern></defs><rect width="100" height="100" fill="url(%23shop)"/></svg>');
            background-size: 250px 250px;
            background-position: 0 0;
            animation: backgroundShift 25s ease-in-out infinite;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            position: relative;
            overflow: hidden;
        }}
        
        @keyframes backgroundShift {{
            0%, 100% {{ background-position: 0 0; }}
            50% {{ background-position: 30px 30px; }}
        }}
        
        /* Landing Page Styles */
        .landing-container {{
            text-align: center;
            z-index: 10;
            transition: all 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            opacity: 1;
            transform: translateY(0);
        }}
        
        .landing-container.hidden {{
            opacity: 0;
            transform: translateY(-50px);
            pointer-events: none;
        }}
        
        .landing-title {{
            color: #ecf0f1;
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 15px;
            animation: titlePulse 4s ease-in-out infinite;
            text-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }}
        
        @keyframes titlePulse {{
            0%, 100% {{ transform: scale(1); }}
            50% {{ transform: scale(1.02); }}
        }}
        
        .landing-subtitle {{
            color: #bdc3c7;
            font-size: 1.2rem;
            margin-bottom: 50px;
            font-weight: 300;
            letter-spacing: 1px;
        }}
        
        .laptop-container {{
            position: relative;
            cursor: pointer;
            transition: all 0.4s ease;
            animation: laptopFloat 6s ease-in-out infinite;
        }}
        
        .laptop-container:hover {{
            transform: translateY(-10px) scale(1.05);
        }}
        
        @keyframes laptopFloat {{
            0%, 100% {{ transform: translateY(0px); }}
            50% {{ transform: translateY(-8px); }}
        }}
        
        .laptop {{
            width: 350px;
            height: 220px;
            background: linear-gradient(145deg, #4a4a4a, #2c2c2c);
            border-radius: 15px 15px 8px 8px;
            position: relative;
            margin: 0 auto;
            box-shadow: 
                0 25px 50px rgba(0,0,0,0.3),
                inset 0 1px 0 rgba(255,255,255,0.1);
            perspective: 1000px;
        }}
        
        .laptop::after {{
            content: '';
            position: absolute;
            bottom: -12px; left: 50%; 
            transform: translateX(-50%);
            width: 370px; height: 18px;
            background: linear-gradient(145deg, #2c2c2c, #4a4a4a);
            border-radius: 0 0 25px 25px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.3);
        }}
        
        .screen {{
            position: absolute;
            top: 12px; left: 12px; right: 12px; bottom: 25px;
            background: linear-gradient(135deg, #87CEEB, #4682B4);
            border-radius: 8px;
            border: 3px solid #333;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }}
        
        .store-3d {{
            position: relative;
            transform-style: preserve-3d;
            animation: store3dFloat 4s ease-in-out infinite;
        }}
        
        @keyframes store3dFloat {{
            0%, 100% {{ transform: translateZ(0px) rotateY(0deg); }}
            50% {{ transform: translateZ(10px) rotateY(2deg); }}
        }}
        
        .store-base {{
            width: 80px;
            height: 50px;
            background: linear-gradient(145deg, #8B4513, #A0522D);
            border-radius: 5px;
            position: relative;
            transform: rotateX(-20deg);
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
        }}
        
        .store-front {{
            position: absolute;
            top: -60px;
            left: 50%;
            transform: translateX(-50%);
            width: 70px;
            height: 55px;
        }}
        
        .awning {{
            width: 80px;
            height: 20px;
            background: repeating-linear-gradient(
                45deg,
                #FF6B35,
                #FF6B35 4px,
                #FFF 4px,
                #FFF 8px
            );
            border-radius: 10px 10px 5px 5px;
            position: absolute;
            top: -10px;
            left: -5px;
            box-shadow: 0 5px 15px rgba(255, 107, 53, 0.4);
            animation: awningWave 3s ease-in-out infinite;
        }}
        
        @keyframes awningWave {{
            0%, 100% {{ transform: scaleY(1); }}
            50% {{ transform: scaleY(1.05); }}
        }}
        
        .storefront {{
            width: 70px;
            height: 50px;
            background: linear-gradient(145deg, #F4E4BC, #E6D690);
            border-radius: 5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 5px;
            box-shadow: inset 0 2px 5px rgba(0,0,0,0.1);
        }}
        
        .window {{
            width: 18px;
            height: 25px;
            background: linear-gradient(135deg, #87CEEB, #4682B4);
            border-radius: 3px;
            border: 2px solid #8B4513;
            position: relative;
            animation: windowGlow 2s ease-in-out infinite;
        }}
        
        @keyframes windowGlow {{
            0%, 100% {{ box-shadow: 0 0 5px rgba(70, 130, 180, 0.5); }}
            50% {{ box-shadow: 0 0 15px rgba(70, 130, 180, 0.8); }}
        }}
        
        .window::after {{
            content: '';
            position: absolute;
            top: 50%; left: 0; right: 0;
            height: 1px;
            background: #8B4513;
        }}
        
        .door {{
            width: 22px;
            height: 35px;
            background: linear-gradient(145deg, #8B4513, #A0522D);
            border-radius: 3px;
            position: relative;
            box-shadow: inset 0 1px 3px rgba(0,0,0,0.2);
        }}
        
        .door::before {{
            content: '';
            position: absolute;
            right: 3px; top: 15px;
            width: 2px; height: 2px;
            background: #FFD700;
            border-radius: 50%;
        }}
        
        .floating-boxes {{
            position: absolute;
            width: 120px;
            height: 120px;
            top: -40px;
            left: -25px;
        }}
        
        .box {{
            position: absolute;
            width: 12px;
            height: 12px;
            background: linear-gradient(145deg, #FF6B35, #FF8C42);
            border-radius: 2px;
            animation: boxFloat 4s ease-in-out infinite;
            box-shadow: 0 3px 8px rgba(255, 107, 53, 0.4);
        }}
        
        .box1 {{
            top: 10px; left: 15px;
            animation-delay: 0s;
        }}
        
        .box2 {{
            top: 30px; right: 20px;
            animation-delay: 1.3s;
        }}
        
        .box3 {{
            bottom: 25px; left: 25px;
            animation-delay: 2.6s;
        }}
        
        @keyframes boxFloat {{
            0%, 100% {{ transform: translateY(0px) rotateZ(0deg); opacity: 0.7; }}
            50% {{ transform: translateY(-15px) rotateZ(180deg); opacity: 1; }}
        }}
        
        .click-indicator {{
            position: absolute;
            top: -40px; left: 50%;
            transform: translateX(-50%);
            color: #ecf0f1;
            font-size: 14px;
            font-weight: 500;
            animation: bounce 2s ease-in-out infinite;
        }}
        
        @keyframes bounce {{
            0%, 100% {{ transform: translateX(-50%) translateY(0); }}
            50% {{ transform: translateX(-50%) translateY(-5px); }}
        }}
        
        /* Shopping elements around laptop */
        .shopping-elements {{
            position: absolute;
            width: 100%;
            height: 100%;
            pointer-events: none;
        }}
        
        .cart {{
            position: absolute;
            font-size: 40px;
            animation: cartMove 8s ease-in-out infinite;
        }}
        
        .cart:nth-child(1) {{
            top: 20%; left: 10%;
            animation-delay: 0s;
        }}
        
        .cart:nth-child(2) {{
            top: 30%; right: 15%;
            animation-delay: 2s;
        }}
        
        .cart:nth-child(3) {{
            bottom: 25%; left: 20%;
            animation-delay: 4s;
        }}
        
        @keyframes cartMove {{
            0%, 100% {{ transform: translate(0, 0) rotate(0deg); opacity: 0.3; }}
            25% {{ transform: translate(15px, -10px) rotate(5deg); opacity: 0.6; }}
            50% {{ transform: translate(0, -20px) rotate(0deg); opacity: 0.8; }}
            75% {{ transform: translate(-10px, -5px) rotate(-3deg); opacity: 0.5; }}
        }}
        
        /* Login Form Styles */
        .login-container {{
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 50px;
            border-radius: 20px;
            box-shadow: 
                0 20px 40px rgba(0, 0, 0, 0.3),
                0 0 0 1px rgba(255, 255, 255, 0.5) inset;
            width: 100%;
            max-width: 450px;
            position: absolute;
            z-index: 20;
            transition: all 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            opacity: 0;
            transform: translateY(50px) scale(0.9);
            pointer-events: none;
        }}
        
        .login-container.active {{
            opacity: 1;
            transform: translateY(0) scale(1);
            pointer-events: all;
        }}
        
        .back-btn {{
            position: absolute;
            top: 20px; left: 20px;
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: #7f8c8d;
            transition: all 0.3s ease;
        }}
        
        .back-btn:hover {{
            color: #D2691E;
            transform: scale(1.1);
        }}
        
        .admin-header {{
            text-align: center;
            margin-bottom: 40px;
            position: relative;
        }}
        
        .admin-icon {{
            width: 70px; height: 70px;
            background: linear-gradient(135deg, #D2691E, #CD853F);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            box-shadow: 0 15px 30px rgba(210, 105, 30, 0.3);
            animation: iconSpin 20s linear infinite;
            font-size: 32px;
        }}
        
        .admin-icon::before {{
            content: "🏪";
        }}
        
        @keyframes iconSpin {{
            from {{ transform: rotate(0deg); }}
            to {{ transform: rotate(360deg); }}
        }}
        
        h1 {{
            color: #2c3e50;
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 8px;
        }}
        
        .subtitle {{
            color: #7f8c8d;
            font-size: 14px;
            font-weight: 400;
            letter-spacing: 1px;
            text-transform: uppercase;
        }}
        
        .form-group {{
            margin-bottom: 25px;
        }}
        
        label {{
            display: block;
            color: #5a6c7d;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 10px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }}
        
        input[type="text"], input[type="password"] {{
            width: 100%;
            padding: 18px 20px;
            background: rgba(248, 249, 250, 0.8);
            border: 2px solid rgba(223, 230, 236, 0.6);
            border-radius: 12px;
            font-size: 15px;
            color: #2c3e50;
            font-family: 'Poppins', sans-serif;
            font-weight: 400;
            transition: all 0.3s ease;
        }}
        
        input::placeholder {{
            color: rgba(127, 140, 157, 0.7);
        }}
        
        input:focus {{
            outline: none;
            border-color: #D2691E;
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 0 0 3px rgba(210, 105, 30, 0.1);
            transform: translateY(-2px);
        }}
        
        .login-btn {{
            width: 100%;
            padding: 18px;
            background: linear-gradient(135deg, #D2691E, #CD853F);
            border: none;
            border-radius: 12px;
            color: white;
            font-size: 16px;
            font-weight: 600;
            letter-spacing: 0.5px;
            cursor: pointer;
            font-family: 'Poppins', sans-serif;
            text-transform: uppercase;
            box-shadow: 0 15px 30px rgba(210, 105, 30, 0.3);
            margin-top: 15px;
            transition: all 0.3s ease;
        }}
        
        .login-btn:hover {{
            transform: translateY(-3px);
            box-shadow: 0 20px 40px rgba(210, 105, 30, 0.4);
        }}
        
        .error-message {{
            background: rgba(231, 76, 60, 0.1);
            border: 1px solid rgba(231, 76, 60, 0.3);
            color: #c0392b;
            padding: 16px 20px;
            margin-bottom: 25px;
            border-radius: 12px;
            font-size: 14px;
            text-align: center;
            font-weight: 500;
            animation: shake 0.5s ease-in-out;
        }}
        
        @keyframes shake {{
            0%, 100% {{ transform: translateX(0); }}
            25% {{ transform: translateX(-5px); }}
            75% {{ transform: translateX(5px); }}
        }}
        
        .admin-footer {{
            text-align: center;
            margin-top: 35px;
            padding-top: 25px;
            border-top: 1px solid rgba(223, 230, 236, 0.5);
        }}
        
        .security-badge {{
            color: #7f8c8d;
            font-size: 12px;
            font-weight: 500;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }}
    </style>
</head>
<body>
    <!-- Landing Page -->
    <div class="landing-container" id="landingPage">
        <h1 class="landing-title">Store Admin Portal</h1>
        <p class="landing-subtitle">Professional E-commerce Management</p>
        
        <div class="laptop-container" onclick="showLogin()">
            <div class="laptop">
                <div class="screen">
                    <div class="store-3d">
                        <div class="store-base"></div>
                        <div class="store-front">
                            <div class="awning"></div>
                            <div class="storefront">
                                <div class="window left-window"></div>
                                <div class="door"></div>
                                <div class="window right-window"></div>
                            </div>
                            <div class="store-shadow"></div>
                        </div>
                        <div class="floating-boxes">
                            <div class="box box1"></div>
                            <div class="box box2"></div>
                            <div class="box box3"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="shopping-elements">
            <div class="cart">🛒</div>
            <div class="cart">📦</div>
            <div class="cart">💳</div>
        </div>
    </div>
    
    <!-- Login Form -->
    <div class="login-container" id="loginForm">
        <button class="back-btn" onclick="showLanding()">←</button>
        
        <div class="admin-header">
            <div class="admin-icon"></div>
            <h1>Store Admin</h1>
            <div class="subtitle">E-commerce Management Portal</div>
        </div>
        
        {error_html}
        
        <form method="post">
            <div class="form-group">
                <label for="username">Store Administrator</label>
                <input type="text" id="username" name="username" placeholder="Enter admin username" required>
            </div>
            
            <div class="form-group">
                <label for="password">Secure Access</label>
                <input type="password" id="password" name="password" placeholder="Enter password" required>
            </div>
            
            <button type="submit" class="login-btn">Access Dashboard</button>
        </form>
        
        <div class="admin-footer">
            <div class="security-badge">
                <span>🔐</span>
                Secured E-commerce Platform
            </div>
        </div>
    </div>
    
    <script>
        function showLogin() {{
            const landing = document.getElementById('landingPage');
            const login = document.getElementById('loginForm');
            
            landing.classList.add('hidden');
            setTimeout(() => {{
                login.classList.add('active');
            }}, 400);
        }}
        
        function showLanding() {{
            const landing = document.getElementById('landingPage');
            const login = document.getElementById('loginForm');
            
            login.classList.remove('active');
            setTimeout(() => {{
                landing.classList.remove('hidden');
            }}, 400);
        }}
        
        // Auto-show login if there's an error
        window.onload = function() {{
            if (document.querySelector('.error-message')) {{
                showLogin();
            }}
        }}
    </script>
</body>
</html>
    """

urlpatterns = [
    # ===============================================
    # INTERACTIVE E-COMMERCE ADMIN PORTAL
    # ===============================================
    path('admin/', nuclear_admin_login, name='interactive_admin'),
    path('admin/login/', nuclear_admin_login, name='admin_login_interactive'),
    path('django-admin/', admin.site.urls),  # Django admin backend
    
    # ===============================================
    # BACKEND STATUS
    # ===============================================
    path('', backend_status, name='backend_status'),
    
    # ===============================================
    # SELLER AUTH
    # ===============================================
    path('', include('myapi.urls')),
]