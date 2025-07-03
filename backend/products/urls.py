from django.urls import path
from . import views

urlpatterns = [
    path('', views.get_products, name='get_products'),
    path('search/', views.search_products, name='search_products'),  # Moved up
    path('categories/', views.get_categories, name='get_categories'),  # Moved up
    path('cart/', views.get_cart, name='get_cart'),  # Moved up
    path('cart/add/', views.add_to_cart, name='add_to_cart'),
    path('cart/remove/<str:cart_id>/', views.remove_from_cart, name='remove_from_cart'),
    path('favorites/', views.get_favorites, name='get_favorites'),  # Moved up
    path('favorites/add/', views.add_to_favorites, name='add_to_favorites'),
    path('favorites/remove/<str:favorite_id>/', views.remove_from_favorites, name='remove_from_favorites'),
    path('docs/', views.api_docs, name='api_docs'),  # Moved up
    path('category/<str:category>/', views.get_products_by_category, name='get_products_by_category'),
    path('<str:product_id>/', views.get_product_detail, name='get_product_detail'),  # Moved to bottom
]