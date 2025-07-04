from django.db import models

# Models sesuai dengan struktur Supabase yang sudah ada

class Category(models.Model):
    name = models.CharField(unique=True, max_length=100)
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        db_table = 'products_category'
        verbose_name_plural = "Categories"

class Product(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField()
    price = models.DecimalField(max_digits=12, decimal_places=2)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    image = models.CharField(max_length=200, blank=True, null=True)
    stock = models.IntegerField()
    is_active = models.BooleanField(default=True)
    featured = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        db_table = 'products_product'

class Cart(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()
    session_id = models.CharField(max_length=100, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.product.name} - Qty: {self.quantity}"
    
    class Meta:
        db_table = 'products_cart'

class Favorite(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    session_id = models.CharField(max_length=100, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Favorite: {self.product.name}"
    
    class Meta:
        db_table = 'products_favorite'

# Models untuk Supabase tables yang sudah ada (UUID based)
class SupabaseProduct(models.Model):
    id = models.UUIDField(primary_key=True)
    name = models.TextField()
    description = models.TextField(blank=True, null=True)
    price = models.DecimalField(max_digits=65535, decimal_places=65535)
    image_url = models.TextField(blank=True, null=True)
    stock = models.IntegerField()
    category = models.TextField(blank=True, null=True)
    is_active = models.BooleanField(blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField(blank=True, null=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        db_table = 'products'
        managed = False  # Django tidak manage table ini

class UserOrder(models.Model):
    id = models.UUIDField(primary_key=True)
    user_id = models.UUIDField(blank=True, null=True)
    first_name = models.TextField()
    last_name = models.TextField()
    company = models.TextField(blank=True, null=True)
    country = models.TextField()
    address = models.TextField()
    city = models.TextField()
    province = models.TextField()
    zip_code = models.TextField()
    phone = models.TextField()
    email = models.TextField()
    notes = models.TextField(blank=True, null=True)
    payment_method = models.TextField()
    total_amount = models.IntegerField()
    status = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(blank=True, null=True)
    updated_at = models.DateTimeField(blank=True, null=True)
    
    def __str__(self):
        return f"Order {self.id} - {self.first_name} {self.last_name}"
    
    class Meta:
        db_table = 'user_orders'
        managed = False

class OrderItemSupabase(models.Model):
    id = models.UUIDField(primary_key=True)
    order = models.ForeignKey(UserOrder, on_delete=models.CASCADE, blank=True, null=True)
    product = models.ForeignKey(SupabaseProduct, on_delete=models.CASCADE, blank=True, null=True)
    product_name = models.TextField()
    quantity = models.IntegerField()
    price = models.IntegerField()
    subtotal = models.IntegerField()
    created_at = models.DateTimeField(blank=True, null=True)
    
    def __str__(self):
        return f"{self.product_name} x {self.quantity}"
    
    class Meta:
        db_table = 'order_items'
        managed = False

# Django managed models for new order system
class Order(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('shipped', 'Shipped'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    ]
    
    user_id = models.CharField(max_length=100, blank=True, null=True)
    session_id = models.CharField(max_length=100, blank=True, null=True)
    total_amount = models.DecimalField(max_digits=12, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    
    # Customer info
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    email = models.EmailField()
    phone = models.CharField(max_length=20)
    
    # Address info
    address = models.TextField()
    city = models.CharField(max_length=100)
    province = models.CharField(max_length=100)
    zip_code = models.CharField(max_length=10)
    country = models.CharField(max_length=100, default='Indonesia')
    
    # Order details
    notes = models.TextField(blank=True, null=True)
    payment_method = models.CharField(max_length=50, default='cash_on_delivery')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Order #{self.id} - {self.first_name} {self.last_name}"
    
    class Meta:
        ordering = ['-created_at']

class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    product_name = models.CharField(max_length=200)
    price = models.DecimalField(max_digits=12, decimal_places=2)
    quantity = models.PositiveIntegerField()
    subtotal = models.DecimalField(max_digits=12, decimal_places=2)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    def save(self, *args, **kwargs):
        self.subtotal = self.price * self.quantity
        super().save(*args, **kwargs)
    
    def __str__(self):
        return f"{self.product_name} x {self.quantity}"