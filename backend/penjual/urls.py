from django.urls import path
from . import views

urlpatterns = [
    path('dashboard/', views.dashboard, name='penjual_dashboard'),
    path('produk/', views.product_list, name='penjual_product_list'),
]
