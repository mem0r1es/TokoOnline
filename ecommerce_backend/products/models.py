from django.db import models
from django.contrib.auth import get_user_model
from django.core.validators import MinValueValidator, MaxValueValidator
import uuid

User = get_user_model()

class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'categories'
        verbose_name_plural = 'Categories'
    
    def __str__(self):
        return self.name

class Product(models.Model):
    CONDITION_CHOICES = [
        ('new', 'New'),
        ('like_new', 'Like New'),
        ('good', 'Good'),
        ('fair', 'Fair'),
        ('poor', 'Poor'),
    ]
    
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('inactive', 'Inactive'),
        ('sold', 'Sold'),
        ('pending', 'Pending Review'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    seller = models.ForeignKey(User, on_delete=models.CASCADE, related_name='seller_products')
    name = models.CharField(max_length=200)
    description = models.TextField()
    price = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0)])
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True)
    condition = models.CharField(max_length=10, choices=CONDITION_CHOICES, default='good')
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='active')
    stock_quantity = models.PositiveIntegerField(default=1)
    
    # Product details
    brand = models.CharField(max_length=100, blank=True, null=True)
    model = models.CharField(max_length=100, blank=True, null=True)
    color = models.CharField(max_length=50, blank=True, null=True)
    size = models.CharField(max_length=50, blank=True, null=True)
    weight = models.DecimalField(max_digits=8, decimal_places=2, blank=True, null=True, help_text="Weight in kg")
    
    # SEO and visibility
    is_featured = models.BooleanField(default=False)
    views_count = models.PositiveIntegerField(default=0)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'products'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['seller', 'status']),
            models.Index(fields=['category', 'status']),
            models.Index(fields=['price']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"{self.name} - {self.seller.username}"
    
    @property
    def is_available(self):
        return self.status == 'active' and self.stock_quantity > 0

class ProductImage(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='images')
    image_url = models.URLField(max_length=500)
    alt_text = models.CharField(max_length=200, blank=True, null=True)
    is_primary = models.BooleanField(default=False)
    order = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'product_images'
        ordering = ['order', 'created_at']
        unique_together = [['product', 'order']]
    
    def __str__(self):
        return f"Image for {self.product.name}"
    
    def save(self, *args, **kwargs):
        if self.is_primary:
            # Ensure only one primary image per product
            ProductImage.objects.filter(product=self.product, is_primary=True).update(is_primary=False)
        super().save(*args, **kwargs)

class ProductAttribute(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='attributes')
    name = models.CharField(max_length=100)
    value = models.CharField(max_length=200)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'product_attributes'
        unique_together = [['product', 'name']]
    
    def __str__(self):
        return f"{self.name}: {self.value} ({self.product.name})"