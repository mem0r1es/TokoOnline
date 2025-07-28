# File: orders/models.py

from django.db import models
from django.conf import settings  # CHANGE: Use this instead of User import
from products.models import Product
from django.utils import timezone

class OrderStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    PAID = 'paid', 'Paid' 
    PROCESSING = 'processing', 'Processing'
    SHIPPED = 'shipped', 'Shipped'
    DELIVERED = 'delivered', 'Delivered'
    CANCELLED = 'cancelled', 'Cancelled'
    REFUNDED = 'refunded', 'Refunded'

class PaymentMethod(models.TextChoices):
    BANK_TRANSFER = 'bank_transfer', 'Bank Transfer'
    CREDIT_CARD = 'credit_card', 'Credit Card'
    E_WALLET = 'e_wallet', 'E-Wallet'
    COD = 'cod', 'Cash on Delivery'

class Order(models.Model):
    # Order info
    order_id = models.CharField(max_length=100, unique=True)
    customer_email = models.EmailField()
    customer_name = models.CharField(max_length=255)
    customer_phone = models.CharField(max_length=20, blank=True)
    
    # Address
    shipping_address = models.TextField()
    city = models.CharField(max_length=100, blank=True)
    province = models.CharField(max_length=100, blank=True)
    postal_code = models.CharField(max_length=10, blank=True)
    
    # Order details
    status = models.CharField(
        max_length=20,
        choices=OrderStatus.choices,
        default=OrderStatus.PENDING
    )
    payment_method = models.CharField(
        max_length=20,
        choices=PaymentMethod.choices,
        blank=True
    )
    
    # Pricing
    subtotal = models.DecimalField(max_digits=12, decimal_places=2)
    shipping_cost = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    tax = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total_amount = models.DecimalField(max_digits=12, decimal_places=2)
    
    # Timestamps
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    shipped_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    
    # Additional info
    notes = models.TextField(blank=True)
    admin_notes = models.TextField(blank=True, help_text="Internal notes for admin")
    
    class Meta:
        ordering = ['-created_at']
        
    def __str__(self):
        return f"Order {self.order_id} - {self.customer_name}"
    
    def get_total_items(self):
        return sum(item.quantity for item in self.orderitem_set.all())
    
    def can_cancel(self):
        return self.status in [OrderStatus.PENDING, OrderStatus.PAID]
    
    def can_ship(self):
        return self.status == OrderStatus.PROCESSING
    
    def can_deliver(self):
        return self.status == OrderStatus.SHIPPED

class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    product_id = models.IntegerField()  # Reference to Supabase product
    product_name = models.CharField(max_length=255)
    product_image = models.URLField(blank=True)
    
    quantity = models.PositiveIntegerField()
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)
    total_price = models.DecimalField(max_digits=12, decimal_places=2)
    
    # Product details at time of order (untuk historical record)
    product_sku = models.CharField(max_length=100, blank=True)
    product_category = models.CharField(max_length=100, blank=True)
    
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        unique_together = ['order', 'product_id']
        
    def __str__(self):
        return f"{self.product_name} x{self.quantity}"
    
    def save(self, *args, **kwargs):
        # Auto calculate total_price
        self.total_price = self.quantity * self.unit_price
        super().save(*args, **kwargs)

class OrderStatusHistory(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='status_history')
    status = models.CharField(max_length=20, choices=OrderStatus.choices)
    # FIXED: Use settings.AUTH_USER_MODEL instead of User
    changed_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        ordering = ['-created_at']
        
    def __str__(self):
        return f"{self.order.order_id} - {self.status} at {self.created_at}"