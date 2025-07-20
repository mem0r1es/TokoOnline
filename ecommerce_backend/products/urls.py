from django.urls import path
from . import views

urlpatterns = [
    # Product CRUD operations
    path('', views.product_list_create, name='product_list_create'),
    path('<uuid:product_id>/', views.product_detail, name='product_detail'),
    path('<uuid:product_id>/toggle-status/', views.toggle_product_status, name='toggle_product_status'),
    
    # Categories
    path('categories/', views.categories_list, name='categories_list'),
    
    # Seller dashboard
    path('seller/stats/', views.seller_dashboard_stats, name='seller_dashboard_stats'),
]