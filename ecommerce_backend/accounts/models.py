from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    USER_TYPES = (
        ('admin', 'Admin'),
        ('seller', 'Seller'),
    )
    
    email = models.EmailField(unique=True)
    user_type = models.CharField(max_length=10, choices=USER_TYPES, default='seller')
    contact_number = models.CharField(max_length=20, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username', 'first_name', 'last_name']
    
    def __str__(self):
        return f"{self.email} ({self.user_type})"
    
    class Meta:
        db_table = 'users'