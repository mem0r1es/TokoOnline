# api/urls.py - COMPLETE FIXED VERSION
from django.contrib import admin
from django.contrib.auth import authenticate, login
from django.shortcuts import render, redirect
from django.urls import path, include
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
import json
import hashlib
import secrets

from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")

supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)

# ── Status endpoint
def backend_status(request):
    return JsonResponse({
        "status": "E-commerce Backend Running", 
        "admin_portal": "/admin/",
        "penjual_portal": "/penjual/",
        "note": "Interactive e-commerce admin system"
    })

@csrf_exempt
def nuclear_admin_login(request):
    """Interactive admin login with laptop"""
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

# ===============================================
# PENJUAL AUTHENTICATION SYSTEM
# ===============================================

def penjual_portal(request):
    """Main penjual portal with login/register options"""
    return HttpResponse(get_penjual_portal_html(), content_type='text/html')

@csrf_exempt
def penjual_register(request):
    """Handle penjual registration"""
    if request.method == 'GET':
        return HttpResponse(get_penjual_register_html(), content_type='text/html')
    elif request.method == 'POST':
        nama_user = request.POST.get('nama_user', '').strip()
        nama_toko = request.POST.get('nama_toko', '').strip()
        email = request.POST.get('email', '').strip().lower()
        alamat_toko = request.POST.get('alamat_toko', '').strip()  # tetap pakai ini dari form
        password = request.POST.get('password', '')

        if not all([nama_user, nama_toko, email, alamat_toko, password]):
            error = "Semua field harus diisi"
            return HttpResponse(get_penjual_register_html(error), content_type='text/html')

        if len(password) < 6:
            error = "Password minimal 6 karakter"
            return HttpResponse(get_penjual_register_html(error), content_type='text/html')

        password_hash = hashlib.sha256(password.encode()).hexdigest()

        seller_data = {
            'owner_name': nama_user,
            'store_name': nama_toko,
            'email': email,
            'address': alamat_toko,  # ganti dari alamat_toko → address
            'password_hash': password_hash,
        }

        supabase.table('sellers').insert(seller_data).execute()

        return redirect(f'/penjual/dashboard/?welcome=true&store={nama_toko}')


@csrf_exempt  
def penjual_login(request):
    """Handle penjual login"""
    if request.method == 'GET':
        return HttpResponse(get_penjual_login_html(), content_type='text/html')

    elif request.method == 'POST':
        email = request.POST.get('email', '').strip().lower()
        password = request.POST.get('password', '')

        if not all([email, password]):
            error = "Email dan password harus diisi"
            return HttpResponse(get_penjual_login_html(error), content_type='text/html')

        # Ambil seller dari Supabase
        response = supabase.table("sellers").select("*").eq("email", email).execute()
        sellers = response.data

        if not sellers:
            error = "Akun tidak ditemukan"
            return HttpResponse(get_penjual_login_html(error), content_type='text/html')

        seller = sellers[0]

        # Bandingkan password yang di-hash
        input_hash = hashlib.sha256(password.encode()).hexdigest()
        if input_hash != seller.get("password_hash"):
            error = "Password salah"
            return HttpResponse(get_penjual_login_html(error), content_type='text/html')

        # Login berhasil → redirect ke dashboard
        return redirect(f'/penjual/dashboard/?store={seller.get("nama_toko")}')



def penjual_google_auth(request):
    """Handle Google OAuth for penjual"""
    # TODO: Implement Google OAuth
    # For now, redirect to registration
    return redirect('/penjual/register/?source=google')

def get_penjual_portal_html():
    """Penjual landing page - DEDICATED SELLER LANDING"""
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Portal Penjual</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                overflow-x: hidden;
                position: relative;
            }

            /* Animated Background Elements */
            .bg-shapes {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                overflow: hidden;
                z-index: 1;
            }

            .shape {
                position: absolute;
                opacity: 0.1;
                animation: float 6s ease-in-out infinite;
            }

            .shape:nth-child(1) {
                top: 10%;
                left: 20%;
                font-size: 60px;
                animation-delay: 0s;
            }

            .shape:nth-child(2) {
                top: 20%;
                right: 20%;
                font-size: 40px;
                animation-delay: 2s;
            }

            .shape:nth-child(3) {
                bottom: 30%;
                left: 10%;
                font-size: 50px;
                animation-delay: 4s;
            }

            .shape:nth-child(4) {
                bottom: 10%;
                right: 15%;
                font-size: 35px;
                animation-delay: 1s;
            }

            .shape:nth-child(5) {
                top: 50%;
                left: 50%;
                font-size: 45px;
                animation-delay: 3s;
            }

            @keyframes float {
                0%, 100% { transform: translateY(0px) rotate(0deg); }
                50% { transform: translateY(-20px) rotate(180deg); }
            }
            
            .container {
                position: relative;
                z-index: 10;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                padding: 40px 20px;
                text-align: center;
            }

            .hero-section {
                margin-bottom: 60px;
            }
            
            .title {
                font-size: 3.5rem;
                font-weight: 800;
                color: white;
                margin-bottom: 20px;
                text-shadow: 0 4px 8px rgba(0,0,0,0.3);
                animation: titleGlow 2s ease-in-out infinite alternate;
            }

            @keyframes titleGlow {
                from { text-shadow: 0 4px 8px rgba(0,0,0,0.3); }
                to { text-shadow: 0 4px 20px rgba(255,255,255,0.3); }
            }
            
            .subtitle {
                color: rgba(255, 255, 255, 0.9);
                margin-bottom: 15px;
                font-size: 1.3rem;
                font-weight: 300;
                line-height: 1.6;
            }

            .description {
                color: rgba(255, 255, 255, 0.8);
                font-size: 1.1rem;
                max-width: 600px;
                margin: 0 auto 40px;
                line-height: 1.7;
            }

            .features {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 30px;
                margin-bottom: 50px;
                max-width: 800px;
                width: 100%;
            }

            .feature-card {
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255, 255, 255, 0.2);
                border-radius: 20px;
                padding: 30px 20px;
                text-align: center;
                transition: all 0.3s ease;
            }

            .feature-card:hover {
                transform: translateY(-10px);
                background: rgba(255, 255, 255, 0.15);
                box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            }

            .feature-icon {
                font-size: 3rem;
                margin-bottom: 15px;
                display: block;
            }

            .feature-title {
                color: white;
                font-size: 1.2rem;
                font-weight: 600;
                margin-bottom: 10px;
            }

            .feature-text {
                color: rgba(255, 255, 255, 0.8);
                font-size: 0.95rem;
                line-height: 1.5;
            }

            .cta-section {
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(15px);
                border: 1px solid rgba(255, 255, 255, 0.2);
                border-radius: 25px;
                padding: 40px;
                max-width: 500px;
                width: 100%;
            }

            .cta-title {
                color: white;
                font-size: 1.8rem;
                font-weight: 700;
                margin-bottom: 20px;
            }

            .cta-text {
                color: rgba(255, 255, 255, 0.9);
                margin-bottom: 30px;
                font-size: 1rem;
            }
            
            .btn {
                width: 100%;
                padding: 16px 24px;
                border: none;
                border-radius: 12px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                margin-bottom: 16px;
                text-decoration: none;
                display: inline-block;
                box-sizing: border-box;
            }
            
            .btn-primary {
                background: white;
                color: #667eea;
                box-shadow: 0 8px 25px rgba(255,255,255,0.3);
            }
            
            .btn-primary:hover {
                transform: translateY(-3px);
                box-shadow: 0 12px 35px rgba(255,255,255,0.4);
            }
            
            .btn-secondary {
                background: rgba(255, 255, 255, 0.1);
                color: white;
                border: 2px solid rgba(255, 255, 255, 0.3);
            }
            
            .btn-secondary:hover {
                background: rgba(255, 255, 255, 0.2);
                transform: translateY(-3px);
            }
            
            .btn-google {
                background: white;
                color: #333;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 12px;
                box-shadow: 0 8px 25px rgba(255,255,255,0.3);
            }
            
            .btn-google:hover {
                transform: translateY(-3px);
                box-shadow: 0 12px 35px rgba(255,255,255,0.4);
            }
            
            .divider {
                margin: 24px 0;
                text-align: center;
                position: relative;
                color: rgba(255, 255, 255, 0.7);
                font-size: 14px;
            }
            
            .divider::before {
                content: '';
                position: absolute;
                top: 50%;
                left: 0;
                right: 0;
                height: 1px;
                background: rgba(255, 255, 255, 0.3);
            }
            
            .divider span {
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
                padding: 0 16px;
                position: relative;
                border-radius: 20px;
            }
            
            .back-link {
                margin-top: 40px;
                padding-top: 30px;
                border-top: 1px solid rgba(255, 255, 255, 0.2);
            }
            
            .back-link a {
                color: rgba(255, 255, 255, 0.8);
                text-decoration: none;
                font-size: 14px;
                transition: color 0.3s ease;
            }

            .back-link a:hover {
                color: white;
            }

            /* Responsive */
            @media (max-width: 768px) {
                .title {
                    font-size: 2.5rem;
                }

                .subtitle {
                    font-size: 1.1rem;
                }

                .features {
                    grid-template-columns: 1fr;
                    gap: 20px;
                }

                .cta-section {
                    margin: 0 10px;
                    padding: 30px 25px;
                }
            }
        </style>
    </head>
    <body>
        <div class="bg-shapes">
            <div class="shape">💰</div>
            <div class="shape">🏪</div>
            <div class="shape">📦</div>
            <div class="shape">🛒</div>
            <div class="shape">💳</div>
        </div>

        <div class="container">
            <div class="hero-section">
                <h1 class="title">Portal Penjual</h1>
                <p class="subtitle">Mulai Perjalanan Bisnis Online Anda</p>
                <p class="description">
                    Bergabunglah dengan marketplace terpercaya dan mulai menjual produk Anda kepada jutaan pembeli. 
                    Platform kami menyediakan semua tools yang Anda butuhkan untuk berkembang.
                </p>
            </div>

            <div class="features">
                <div class="feature-card">
                    <span class="feature-icon">🚀</span>
                    <h3 class="feature-title">Setup Mudah</h3>
                    <p class="feature-text">Daftar dan setup toko online Anda dalam hitungan menit</p>
                </div>
                <div class="feature-card">
                    <span class="feature-icon">📈</span>
                    <h3 class="feature-title">Analytics Lengkap</h3>
                    <p class="feature-text">Pantau penjualan dan performa toko dengan dashboard lengkap</p>
                </div>
                <div class="feature-card">
                    <span class="feature-icon">🛡️</span>
                    <h3 class="feature-title">Pembayaran Aman</h3>
                    <p class="feature-text">Sistem pembayaran terintegrasi dan perlindungan transaksi</p>
                </div>
            </div>

            <div class="cta-section">
                <h2 class="cta-title">Mulai Berjualan Sekarang</h2>
                <p class="cta-text">Pilih cara termudah untuk memulai</p>
                
                <a href="/penjual/google-auth/" class="btn btn-google">
                    <span style="font-weight: bold; color: #4285f4;">G</span>
                    Daftar dengan Google
                </a>
                
                <div class="divider">
                    <span>atau</span>
                </div>
                
                <a href="/penjual/register/" class="btn btn-primary">Buat Akun Baru</a>
                <a href="/penjual/login/" class="btn btn-secondary">Sudah Punya Akun? Login</a>
                
                <div class="back-link">
                    <a href="/admin/">← Kembali ke Portal Utama</a>
                </div>
            </div>
        </div>
    </body>
    </html>
    """

def get_penjual_register_html(error=None):
    """Penjual registration form"""
    error_html = f'<div class="error">{error}</div>' if error else ''
    
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Daftar Penjual</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            * {{ margin: 0; padding: 0; box-sizing: border-box; }}
            
            body {{
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: #f8f9fa;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }}
            
            .container {{
                background: white;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
                width: 100%;
                max-width: 450px;
                border: 1px solid #e9ecef;
            }}
            
            .header {{
                text-align: center;
                margin-bottom: 32px;
            }}
            
            .title {{
                font-size: 24px;
                font-weight: 600;
                color: #212529;
                margin-bottom: 8px;
            }}
            
            .subtitle {{
                font-size: 14px;
                color: #6c757d;
            }}
            
            .form-group {{
                margin-bottom: 20px;
            }}
            
            label {{
                display: block;
                font-size: 14px;
                font-weight: 500;
                color: #495057;
                margin-bottom: 6px;
            }}
            
            input, textarea {{
                width: 100%;
                padding: 12px 16px;
                border: 1px solid #ced4da;
                border-radius: 8px;
                font-size: 14px;
                transition: border-color 0.15s ease;
                background: #fff;
                font-family: inherit;
            }}
            
            textarea {{
                resize: vertical;
                min-height: 80px;
            }}
            
            input:focus, textarea:focus {{
                outline: none;
                border-color: #0d6efd;
                box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1);
            }}
            
            input::placeholder, textarea::placeholder {{
                color: #adb5bd;
            }}
            
            .submit-btn {{
                width: 100%;
                padding: 14px;
                background: #0d6efd;
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 500;
                cursor: pointer;
                transition: background-color 0.15s ease;
                margin-top: 8px;
            }}
            
            .submit-btn:hover {{
                background: #0b5ed7;
            }}
            
            .submit-btn:active {{
                transform: translateY(1px);
            }}
            
            .error {{
                background: #f8d7da;
                color: #721c24;
                padding: 12px 16px;
                border-radius: 8px;
                margin-bottom: 20px;
                font-size: 14px;
                border: 1px solid #f5c6cb;
            }}
            
            .back-link {{
                text-align: center;
                margin-top: 24px;
                padding-top: 20px;
                border-top: 1px solid #e9ecef;
            }}
            
            .back-link a {{
                color: #6c757d;
                text-decoration: none;
                font-size: 14px;
                transition: color 0.15s ease;
            }}
            
            .back-link a:hover {{
                color: #495057;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1 class="title">Daftar Sebagai Penjual</h1>
                <p class="subtitle">Mulai berjualan di marketplace kami</p>
            </div>
            
            {error_html}
            
            <form method="post">
                <div class="form-group">
                    <label for="nama_user">Nama Lengkap</label>
                    <input type="text" id="nama_user" name="nama_user" placeholder="Masukkan nama lengkap Anda" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" placeholder="your@email.com" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="Minimal 6 karakter" required>
                </div>
                
                <div class="form-group">
                    <label for="nama_toko">Nama Toko</label>
                    <input type="text" id="nama_toko" name="nama_toko" placeholder="Nama toko yang unik" required>
                </div>
                
                <div class="form-group">
                    <label for="alamat_toko">Alamat Toko</label>
                    <textarea id="alamat_toko" name="alamat_toko" placeholder="Alamat lengkap toko Anda" required></textarea>
                </div>
                
                <button type="submit" class="submit-btn">Buat Akun Penjual</button>
            </form>
            
            <div class="back-link">
                <a href="/penjual/">← Kembali ke Portal Penjual</a>
            </div>
        </div>
    </body>
    </html>
    """

def get_penjual_login_html(error=None):
    """Penjual login form"""
    error_html = f'<div class="error">{error}</div>' if error else ''
    
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Login Penjual</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            * {{ margin: 0; padding: 0; box-sizing: border-box; }}
            
            body {{
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: #f8f9fa;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }}
            
            .container {{
                background: white;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
                width: 100%;
                max-width: 400px;
                border: 1px solid #e9ecef;
            }}
            
            .header {{
                text-align: center;
                margin-bottom: 32px;
            }}
            
            .title {{
                font-size: 24px;
                font-weight: 600;
                color: #212529;
                margin-bottom: 8px;
            }}
            
            .subtitle {{
                font-size: 14px;
                color: #6c757d;
            }}
            
            .form-group {{
                margin-bottom: 20px;
            }}
            
            label {{
                display: block;
                font-size: 14px;
                font-weight: 500;
                color: #495057;
                margin-bottom: 6px;
            }}
            
            input {{
                width: 100%;
                padding: 12px 16px;
                border: 1px solid #ced4da;
                border-radius: 8px;
                font-size: 14px;
                transition: border-color 0.15s ease;
                background: #fff;
            }}
            
            input:focus {{
                outline: none;
                border-color: #0d6efd;
                box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1);
            }}
            
            input::placeholder {{
                color: #adb5bd;
            }}
            
            .submit-btn {{
                width: 100%;
                padding: 12px;
                background: #0d6efd;
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 14px;
                font-weight: 500;
                cursor: pointer;
                transition: background-color 0.15s ease;
                margin-top: 8px;
            }}
            
            .submit-btn:hover {{
                background: #0b5ed7;
            }}
            
            .submit-btn:active {{
                transform: translateY(1px);
            }}
            
            .error {{
                background: #f8d7da;
                color: #721c24;
                padding: 12px 16px;
                border-radius: 8px;
                margin-bottom: 20px;
                font-size: 14px;
                border: 1px solid #f5c6cb;
            }}
            
            .back-link {{
                text-align: center;
                margin-top: 24px;
                padding-top: 20px;
                border-top: 1px solid #e9ecef;
            }}
            
            .back-link a {{
                color: #6c757d;
                text-decoration: none;
                font-size: 14px;
                transition: color 0.15s ease;
            }}
            
            .back-link a:hover {{
                color: #495057;
            }}
            
            .register-link {{
                text-align: center;
                margin-top: 16px;
                font-size: 14px;
            }}
            
            .register-link a {{
                color: #0d6efd;
                text-decoration: none;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1 class="title">Login Penjual</h1>
                <p class="subtitle">Selamat datang kembali di toko Anda</p>
            </div>
            
            {error_html}
            
            <form method="post">
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" placeholder="your@email.com" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="Masukkan password Anda" required>
                </div>
                
                <button type="submit" class="submit-btn">Login</button>
            </form>
            
            <div class="register-link">
                <p>Belum punya akun? <a href="/penjual/register/">Daftar di sini</a></p>
            </div>
            
            <div class="back-link">
                <a href="/penjual/">← Kembali ke Portal Penjual</a>
            </div>
        </div>
    </body>
    </html>
    """

def get_interactive_html(error=None):
    """Interactive landing page with laptop click-to-login - BASIC VERSION"""
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
            margin-bottom: 30px;
            font-weight: 300;
            letter-spacing: 1px;
        }}

        .landing-links {{
            margin-bottom: 40px;
        }}

        .portal-link {{
            display: inline-block;
            margin: 0 15px;
            padding: 12px 24px;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            font-weight: 500;
            transition: all 0.3s ease;
        }}

        .portal-link:hover {{
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-2px);
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
            box-sizing: border-box;
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
        
        <div class="landing-links">
            <a href="/penjual/" class="portal-link">💰 Portal Penjual</a>
        </div>
        
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
    # ADMIN PORTAL (LAPTOP INTERFACE)
    # ===============================================
    path('admin/', nuclear_admin_login, name='interactive_admin'),
    path('admin/login/', nuclear_admin_login, name='admin_login_interactive'),
    path('django-admin/', admin.site.urls),  # Django admin backend
    
    # ===============================================
    # PENJUAL PORTAL & AUTHENTICATION
    # ===============================================
    path('penjual/', penjual_portal, name='penjual_portal'),
    path('penjual/register/', penjual_register, name='penjual_register'),
    path('penjual/login/', penjual_login, name='penjual_login'),
    path('penjual/google-auth/', penjual_google_auth, name='penjual_google_auth'),
    
    # ===============================================
    # BACKEND STATUS
    # ===============================================
    path('', backend_status, name='backend_status'),

    # ===============================================
    # PENJUAL APP (Dashboard & Features)
    # ===============================================
    path('penjual/', include('penjual.urls')),  # Penjual dashboard (dashboard/, products/, etc.)
]