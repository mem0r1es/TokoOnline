# api/urls.py - Backend admin only configuration

from django.contrib import admin
from django.urls import path
from django.http import JsonResponse

def backend_status(request):
    """Status endpoint untuk backend monitoring"""
    return JsonResponse({
        "status": "Backend Running",
        "role": "Admin & Data Management Only",
        "frontend_api": "Use Supabase API directly",
        "supabase_url": "https://mccdwczueketpqlbobyw.supabase.co",
        "admin_panel": "/admin/",
        "note": "This Django backend is for admin management only. Frontend should use Supabase API directly."
    })

urlpatterns = [
    # Django Admin Panel - Main purpose
    path('admin/', admin.site.urls),
    
    # Backend status endpoint
    path('', backend_status, name='backend_status'),
    
    # API endpoints DISABLED - Frontend uses Supabase API directly
    # path('api/', include('myapi.urls')),
    # path('api/products/', include('products.urls')),
    
    # Auth endpoints DISABLED - Use Supabase Auth instead
    # path('auth/login/', views.api_login, name='api_login'),
    # path('auth/register-seller/', views.register_seller, name='register_seller'),
]

# Note: All API functionality moved to Supabase
# Django role: Admin panel + data management only