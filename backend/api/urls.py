from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("myapi.urls")),      # ← agar /login/ & /register/ dikenali
    path("api/", include("myapi.urls")),  # endpoint JSON
]
