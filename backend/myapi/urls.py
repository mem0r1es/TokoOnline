from django.urls import path
from . import views

urlpatterns = [
    path("auth/login/", views.login, name="api_login"),
    path("auth/register-seller/", views.register_seller, name="register_seller"),
    path("login/", views.login_page, name="web_login"),
    path("register/", views.register_page, name="web_register"),  # ← WAJIB ADA
]
