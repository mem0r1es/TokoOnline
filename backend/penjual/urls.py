from django.urls import path
from . import views
from .views import tambah_produk

urlpatterns = [
    path('dashboard/', views.dashboard, name='penjual_dashboard'),
    path('produk/', views.product_list, name='product_list'),
    path('penjual/produk/tambah/', tambah_produk, name='tambah_produk'),
]
