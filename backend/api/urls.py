# api/urls.py - Complete configuration

from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

def home(request):
    return JsonResponse({
        "message": "Django API Server Running",
        "status": "success",
        "endpoints": {
            "api_documentation": "/api/products/docs/",
            "products": "/api/products/",
            "categories": "/api/products/categories/",
            "cart": "/api/products/cart/",
            "favorites": "/api/products/favorites/",
            "orders": "/api/products/orders/",
            "auth_login": "/auth/login/",
            "auth_register": "/auth/register-seller/",
            "api_auth_login": "/api/auth/login/",
            "api_auth_register": "/api/auth/register-seller/",
            "admin": "/admin/"
        },
        "note": "This is the main API server for the e-commerce application"
    })

urlpatterns = [
    # Home endpoint
    path('', home, name='home'),
    
    # Django admin
    path('admin/', admin.site.urls),
    
    # Auth endpoints (Web-based auth yang dibuat temanmu)
    # path('auth/login/', your_auth_views.api_login, name='api_login'),
    # path('auth/register-seller/', your_auth_views.register_seller, name='register_seller'),
    # path('login/', your_auth_views.web_login, name='web_login'),
    # path('register/', your_auth_views.web_register, name='web_register'),
    
    # API endpoints for products (yang sudah kita buat)
    path('api/', include('myapi.urls')),
    path('api/products/', include('products.urls')),
    
    # API Auth endpoints (duplikasi untuk API access)
    # path('api/auth/login/', your_auth_views.api_login, name='api_auth_login'),
    # path('api/auth/register-seller/', your_auth_views.register_seller, name='api_auth_register'),
    # path('api/login/', your_auth_views.web_login, name='api_web_login'),
    # path('api/register/', your_auth_views.web_register, name='api_web_register'),
]

# NOTE: Uncomment dan sesuaikan auth endpoints di atas dengan views yang dibuat temanmu
# Ganti 'your_auth_views' dengan nama file views yang benar untuk auth