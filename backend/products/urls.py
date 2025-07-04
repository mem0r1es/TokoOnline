from django.urls import path
from . import views

urlpatterns = [
    path('', views.get_products, name='get_products'),
    path('search/', views.search_products, name='search_products'),
    path('categories/', views.get_categories, name='get_categories'),
    path('cart/', views.get_cart, name='get_cart'),
    path('cart/add/', views.add_to_cart, name='add_to_cart'),
    path('cart/update-quantity/', views.update_cart_quantity, name='update_cart_quantity'),  # New
    path('cart/clear/', views.clear_cart, name='clear_cart'),  # New
    path('cart/remove/<str:cart_id>/', views.remove_from_cart, name='remove_from_cart'),
    path('favorites/', views.get_favorites, name='get_favorites'),
    path('favorites/add/', views.add_to_favorites, name='add_to_favorites'),
    path('favorites/remove/<str:favorite_id>/', views.remove_from_favorites, name='remove_from_favorites'),
    path('orders/', views.get_orders, name='get_orders'),
    path('orders/create/', views.create_order, name='create_order'),  # New
    path('orders/<int:order_id>/', views.get_order_detail, name='get_order_detail'),  # New
    path('orders/<int:order_id>/status/', views.update_order_status, name='update_order_status'),  # New
    path('orders/<int:order_id>/cancel/', views.cancel_order, name='cancel_order'),  # New
    path('docs/', views.api_docs, name='api_docs'),
    path('category/<str:category>/', views.get_products_by_category, name='get_products_by_category'),
    path('<str:product_id>/', views.get_product_detail, name='get_product_detail'),
]