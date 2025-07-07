# backend/api/urls.py  –  Admin + Auth + Product endpoints

from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

# ── Status endpoint (tetap ada)
def backend_status(request):
    return JsonResponse({
        "status": "Backend Running",
        "role": "Admin & Data Management",
        "frontend_api": "Supabase direct",
        "supabase_url": "https://mccdwczueketpqlbobyw.supabase.co",
        "admin_panel": "/admin/",
        "note": "Django backend untuk admin & penjual; "
                "frontend pembeli pakai Supabase API langsung"
    })


urlpatterns = [
    # ── Admin panel
    path("admin/", admin.site.urls),

    # ── Status JSON di root /
    path("", backend_status, name="backend_status"),

    # ── Endpoints produk
    path("api/products/", include("products.urls")),
]
