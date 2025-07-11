# products/models.py - Updated with Seller model
import uuid
import json
from django.db import models
from django.utils import timezone
from django.core.validators import MinValueValidator
from decimal import Decimal

# === NEW SELLER MODEL ===

class Seller(models.Model):
    """Seller/Store model"""
    id = models.UUIDField(
        primary_key=True, 
        default=uuid.uuid4, 
        editable=False
    )
    store_name = models.CharField(
        max_length=255,
        help_text="Nama toko"
    )
    owner_name = models.CharField(
        max_length=255,
        help_text="Nama pemilik toko"
    )
    email = models.EmailField(
        help_text="Email kontak toko"
    )
    phone = models.CharField(
        max_length=20, 
        blank=True, 
        null=True,
        help_text="Nomor telepon"
    )
    address = models.TextField(
        blank=True, 
        null=True,
        help_text="Alamat toko"
    )
    description = models.TextField(
        blank=True, 
        null=True,
        help_text="Deskripsi toko"
    )
    is_active = models.BooleanField(
        default=True,
        help_text="Apakah toko masih aktif"
    )
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.store_name
    
    @property
    def total_products(self):
        """Jumlah produk yang dijual"""
        return self.products.filter(is_active=True).count()
    
    @property
    def active_products_count(self):
        """Jumlah produk aktif"""
        return self.products.filter(is_active=True).count()
    
    class Meta:
        db_table = 'sellers'
        managed = True
        verbose_name = "Seller"
        verbose_name_plural = "Sellers"
        ordering = ['store_name']

# === UPDATED SUPABASE PRODUCT MODEL ===

class SupabaseProduct(models.Model):
    """Main products table yang dipakai Flutter app"""
    id = models.UUIDField(
        primary_key=True, 
        default=uuid.uuid4, 
        editable=False
    )
    name = models.TextField()
    description = models.TextField(blank=True, null=True)
    price = models.DecimalField(max_digits=12, decimal_places=2)
    image_url = models.URLField(blank=True, null=True, max_length=500)
    stock = models.IntegerField(default=0)
    category = models.TextField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True, blank=True, null=True)
    
    # TAMBAHAN: Foreign key ke Seller
    seller = models.ForeignKey(
        Seller, 
        on_delete=models.CASCADE, 
        null=True, 
        blank=True,
        related_name='products',
        help_text="Toko yang menjual produk ini",
        db_column='seller_id'  # Map to seller_id column in Supabase
    )
    
    def __str__(self):
        return self.name
    
    @property
    def seller_name(self):
        """Safe seller name display"""
        return self.seller.store_name if self.seller else "No Seller"
    
    class Meta:
        db_table = 'products'
        managed = True
        verbose_name = "Product"
        verbose_name_plural = "Products"
        ordering = ['-created_at']

# === ORDER HISTORY MODEL (unchanged) ===

class OrderHistory(models.Model):
    """Order history table - matches Supabase order_history structure exactly"""
    
    # Primary key: bigint auto-increment (not UUID)
    id = models.BigAutoField(primary_key=True)
    
    # Timestamp field (matches Supabase)
    timestamp = models.DateTimeField(
        default=timezone.now,
        help_text="Order timestamp"
    )
    
    # Customer info (single fields)
    full_name = models.TextField(
        blank=True, 
        null=True,
        help_text="Customer full name (First + Last)"
    )
    email = models.TextField(
        blank=True, 
        null=True,
        help_text="Customer email address"
    )
    phone = models.TextField(
        blank=True, 
        null=True,
        help_text="Customer phone number"
    )
    
    # Address (single field - combined)
    address = models.TextField(
        blank=True, 
        null=True,
        help_text="Complete customer address"
    )
    
    # Order details
    item = models.TextField(
        blank=True, 
        null=True,
        help_text="Items in order (JSON string or comma-separated)"
    )
    item_quantity = models.TextField(
        blank=True, 
        null=True,
        help_text="Item quantities (JSON string or comma-separated)"
    )
    total_price = models.BigIntegerField(
        blank=True, 
        null=True,
        help_text="Total order price in Rupiah"
    )
    payment_method = models.TextField(
        blank=True, 
        null=True,
        help_text="Payment method used"
    )
    
    def __str__(self):
        return f"Order #{self.id} - {self.full_name or 'Unknown'} - Rp {self.total_price or 0:,}"
    
    class Meta:
        db_table = 'order_history'
        managed = True
        verbose_name = "Order History"
        verbose_name_plural = "Order History"
        ordering = ['-timestamp']
    
    # === PROPERTIES FOR BETTER DISPLAY ===
    
    @property
    def total_price_formatted(self):
        """Formatted total price with currency"""
        if self.total_price:
            return f"Rp {self.total_price:,.0f}"
        return "Rp 0"
    
    @property
    def order_number(self):
        """Short order number for display"""
        return f"#{self.id:06d}"
    
    @property
    def customer_name(self):
        """Safe customer name display"""
        return self.full_name if self.full_name else "Unknown Customer"
    
    @property
    def customer_email(self):
        """Safe email display"""
        return self.email if self.email else "No email"
    
    @property
    def customer_phone(self):
        """Safe phone display"""
        return self.phone if self.phone else "No phone"
    
    @property
    def payment_method_display(self):
        """Human readable payment method"""
        if not self.payment_method:
            return "Unknown"
        
        # Convert common payment methods to display format
        method_map = {
            'direct_bank_transfer': 'Direct Bank Transfer',
            'bank_transfer': 'Bank Transfer',
            'cash_on_delivery': 'Cash on Delivery',
            'cod': 'Cash on Delivery',
            'credit_card': 'Credit Card',
            'digital_wallet': 'Digital Wallet'
        }
        
        return method_map.get(self.payment_method.lower(), self.payment_method.title())
    
    @property
    def items_list(self):
        """Parse items from text field"""
        if not self.item:
            return []
        
        try:
            # Try parsing as JSON first
            if self.item.startswith('[') or self.item.startswith('{'):
                return json.loads(self.item)
            else:
                # Split by comma if plain text
                return [item.strip() for item in self.item.split(',') if item.strip()]
        except (json.JSONDecodeError, AttributeError):
            return [self.item] if self.item else []
    
    @property
    def quantities_list(self):
        """Parse item quantities from text field"""
        if not self.item_quantity:
            return []
        
        try:
            # Try parsing as JSON first
            if self.item_quantity.startswith('[') or self.item_quantity.startswith('{'):
                return json.loads(self.item_quantity)
            else:
                # Split by comma if plain text
                return [qty.strip() for qty in self.item_quantity.split(',') if qty.strip()]
        except (json.JSONDecodeError, AttributeError):
            return [self.item_quantity] if self.item_quantity else []
    
    @property
    def items_summary(self):
        """Generate items summary for display"""
        items = self.items_list
        quantities = self.quantities_list
        
        if not items:
            return "No items"
        
        summary = []
        for i, item in enumerate(items[:3]):  # Show max 3 items
            qty = quantities[i] if i < len(quantities) else "1"
            summary.append(f"{item} ({qty})")
        
        if len(items) > 3: 
            summary.append(f"... +{len(items) - 3} more items")
        
        return ", ".join(summary)
    
    @property
    def total_items_count(self):
        """Count total number of items"""
        return len(self.items_list)
    
    @property
    def short_address(self):
        """Truncated address for display"""
        if self.address:
            return self.address[:50] + ('...' if len(self.address) > 50 else '')
        return "No address"
    
    @property
    def days_ago(self):
        """Calculate how many days ago the order was made"""
        if self.timestamp:
            delta = timezone.now() - self.timestamp
            days = delta.days
            
            if days == 0:
                hours = delta.seconds // 3600
                if hours == 0:
                    minutes = delta.seconds // 60
                    return f"{minutes}m ago"
                return f"{hours}h ago"
            elif days == 1:
                return "Yesterday"
            elif days <= 7:
                return f"{days} days ago"
            elif days <= 30:
                weeks = days // 7
                return f"{weeks} week{'s' if weeks > 1 else ''} ago"
            else:
                months = days // 30
                return f"{months} month{'s' if months > 1 else ''} ago"
        return "Unknown"

# === CONTACT MODEL (unchanged) ===

class Contact(models.Model):
    """Contact form submissions"""
    id = models.UUIDField(
        primary_key=True, 
        default=uuid.uuid4, 
        editable=False
    )
    name = models.TextField()
    email = models.EmailField()
    phone = models.CharField(max_length=20, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    message = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(default=timezone.now)
    is_read = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.name} - {self.email}"

    class Meta:
        managed = True
        db_table = 'Contact'
        ordering = ['-created_at']
        verbose_name = "Contact Message"
        verbose_name_plural = "Contact Messages"