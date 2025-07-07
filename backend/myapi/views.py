# myapi/views.py - COMPLETE VERSION
from django.shortcuts import render, redirect
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.http import JsonResponse
from django.conf import settings
from django.contrib.auth import authenticate, login  # ADD THIS
import json

# ======================================================
# 1) API LOGIN (JSON + HTML) -> GET/POST /api/login/
# ======================================================
@csrf_exempt
def login(request):
    """
    - GET  : tampilkan halaman login testing
    - POST : proses login JSON API
    """
    if request.method == "GET":
        return render(request, "api_login.html")
   
    elif request.method == "POST":
        try:
            data = json.loads(request.body)
            email = data.get("email")
            password = data.get("password")

            if not email or not password:
                return JsonResponse({"detail": "Email dan password wajib diisi"}, status=400)

            auth_response = settings.SUPABASE.auth.sign_in_with_password({
                "email": email,
                "password": password
            })

            if auth_response.session is None:
                return JsonResponse({"detail": "Email atau password salah"}, status=401)

            return JsonResponse({
                "access_token": auth_response.session.access_token,
                "refresh_token": auth_response.session.refresh_token,
                "user": {
                    "id": auth_response.user.id,
                    "email": auth_response.user.email,
                    "name": auth_response.user.user_metadata.get("name", ""),
                    "role": auth_response.user.user_metadata.get("role", ""),
                },
            })

        except Exception as e:
            return JsonResponse({"detail": str(e)}, status=500)
   
    return JsonResponse({"detail": "Method not allowed"}, status=405)

# ======================================================
# 2) API REGISTER SELLER -> POST /api/auth/register-seller/
# ======================================================
@csrf_exempt
@require_POST
def register_seller(request):
    try:
        data = json.loads(request.body)
        email = data.get("email")
        password = data.get("password")

        if not email or not password:
            return JsonResponse({"detail": "Email dan password wajib diisi"}, status=400)

        settings.SUPABASE.auth.sign_up({
            "email": email,
            "password": password,
            "options": {"data": {"role": "seller"}},
        })

        return JsonResponse({"detail": "Akun penjual berhasil dibuat. Silakan login."})

    except Exception as e:
        return JsonResponse({"detail": str(e)}, status=500)

# ======================================================
# 3) SELLER LOGIN PAGE -> GET/POST /login/
# ======================================================
@csrf_exempt
def login_page(request):
    if request.method == "POST":
        email = request.POST.get("email")
        password = request.POST.get("password")

        try:
            result = settings.SUPABASE.auth.sign_in_with_password({
                "email": email,
                "password": password
            })

            role = result.user.user_metadata.get("role")
            if result.session and role == "seller":
                return render(request, "login.html", {
                    "success": True,
                    "name": result.user.user_metadata.get("name", "Penjual")
                })

            return render(request, "login.html", {
                "error": "Akun ini bukan penjual atau kredensial salah"
            })

        except Exception as e:
            return render(request, "login.html", {"error": str(e)})

    return render(request, "login.html")

# ======================================================
# 4) SELLER REGISTER PAGE -> GET/POST /register/
# ======================================================
@csrf_exempt
def register_page(request):
    if request.method == "POST":
        email = request.POST.get("email")
        password = request.POST.get("password")

        if not email or not password:
            return render(request, "register.html", {"error": "Email & password wajib"})

        try:
            settings.SUPABASE.auth.sign_up({
                "email": email,
                "password": password,
                "options": {"data": {"role": "seller"}},
            })
            return render(request, "register.html", {
                "success": "Akun berhasil dibuat. Silakan login."
            })

        except Exception as e:
            return render(request, "register.html", {"error": str(e)})

    return render(request, "register.html")
