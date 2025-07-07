# products/admin.py - Fixed Filter Error
from django.contrib import admin
from django.utils.html import format_html
from django.db.models import Count, Sum
from django.utils import timezone
from datetime import timedelta
import json
from .models import SupabaseProduct, OrderHistory, Contact

# =============================================================================
# 🔧 CUSTOM FILTERS (Define before use)
# =============================================================================

class RecentOrdersFilter(admin.SimpleListFilter):
    title = 'Recent Orders'
    parameter_name = 'recent'
    
    def lookups(self, request, model_admin):
        return (
            ('today', 'Today'),
            ('yesterday', 'Yesterday'),
            ('this_week', 'This Week'),
            ('last_week', 'Last Week'),
            ('this_month', 'This Month'),
        )
    
    def queryset(self, request, queryset):
        now = timezone.now()
        
        if self.value() == 'today':
            return queryset.filter(timestamp__date=now.date())
        elif self.value() == 'yesterday':
            yesterday = now.date() - timedelta(days=1)
            return queryset.filter(timestamp__date=yesterday)
        elif self.value() == 'this_week':
            start_week = now.date() - timedelta(days=now.weekday())
            return queryset.filter(timestamp__date__gte=start_week)
        elif self.value() == 'last_week':
            start_last_week = now.date() - timedelta(days=now.weekday() + 7)
            end_last_week = start_last_week + timedelta(days=6)
            return queryset.filter(
                timestamp__date__gte=start_last_week,
                timestamp__date__lte=end_last_week
            )
        elif self.value() == 'this_month':
            return queryset.filter(
                timestamp__year=now.year,
                timestamp__month=now.month
            )

class TotalPriceFilter(admin.SimpleListFilter):
    title = 'Order Value'
    parameter_name = 'price_range'
    
    def lookups(self, request, model_admin):
        return (
            ('under_50k', 'Under Rp 50,000'),
            ('50k_100k', 'Rp 50,000 - 100,000'),
            ('100k_500k', 'Rp 100,000 - 500,000'),
            ('over_500k', 'Over Rp 500,000'),
        )
    
    def queryset(self, request, queryset):
        if self.value() == 'under_50k':
            return queryset.filter(total_price__lt=50000)
        elif self.value() == '50k_100k':
            return queryset.filter(total_price__gte=50000, total_price__lt=100000)
        elif self.value() == '100k_500k':
            return queryset.filter(total_price__gte=100000, total_price__lt=500000)
        elif self.value() == 'over_500k':
            return queryset.filter(total_price__gte=500000)

# =============================================================================
# 🛍️ PRODUCT ADMIN (unchanged)
# =============================================================================

@admin.register(SupabaseProduct)
class SupabaseProductAdmin(admin.ModelAdmin):
    list_display = ['name', 'price', 'stock', 'is_active', 'category', 'created_at']
    list_filter = ['is_active', 'category', 'created_at']
    search_fields = ['name', 'description']
    readonly_fields = ['id', 'created_at', 'updated_at']
    list_editable = ['is_active', 'stock']

# =============================================================================
# 📋 ORDER HISTORY ADMIN
# =============================================================================

@admin.register(OrderHistory)
class OrderHistoryAdmin(admin.ModelAdmin):
    """Admin for OrderHistory - matches Supabase order_history table"""
    
    list_display = [
        'order_number_display',
        'customer_info_display',
        'phone_display',
        'address_display', 
        'items_summary_display',
        'total_price_display',
        'payment_method_display',
        'timestamp_display',
        'days_ago_display'
    ]
    
    list_filter = [
        'payment_method',
        'timestamp',
        ('timestamp', admin.DateFieldListFilter),
        RecentOrdersFilter,
        TotalPriceFilter,
    ]
    
    search_fields = [
        'id',
        'full_name',
        'email', 
        'phone',
        'item',
        'address'
    ]
    
    readonly_fields = [
        'id', 
        'timestamp',
        'items_parsed_display',
        'customer_summary_display'
    ]
    
    # Date hierarchy for easy navigation
    date_hierarchy = 'timestamp'
    
    # Ordering
    ordering = ['-timestamp']
    list_per_page = 25
    
    # Actions
    actions = ['export_orders_csv']
    
    # Fieldsets for detail view
    fieldsets = (
        ('📋 Order Information', {
            'fields': ('id', 'timestamp', 'total_price', 'payment_method'),
            'classes': ('wide',)
        }),
        ('👤 Customer Information', {
            'fields': ('customer_summary_display', 'full_name', 'email', 'phone'),
            'classes': ('wide',)
        }),
        ('📍 Address', {
            'fields': ('address',),
            'classes': ('wide',)
        }),
        ('📦 Items Ordered', {
            'fields': ('items_parsed_display', 'item', 'item_quantity'),
            'classes': ('wide',)
        }),
    )
    
    # =============================================================================
    # 🎨 DISPLAY METHODS
    # =============================================================================
    
    def order_number_display(self, obj):
        """Order number with styling"""
        return format_html(
            '<span style="font-family: monospace; font-weight: bold; color: #007cba;">{}</span>',
            obj.order_number
        )
    order_number_display.short_description = "📄 Order #"
    order_number_display.admin_order_field = 'id'
    
    def customer_info_display(self, obj):
        """Customer info with name, email, and phone"""
        name = obj.customer_name
        email = obj.customer_email if obj.email else ''
        
        return format_html(
            '<div><strong style="color: #2c3e50;">{}</strong><br>'
            '<small style="color: #7f8c8d;">{}</small></div>',
            name, email
        )
    customer_info_display.short_description = "👤 Customer"
    
    def phone_display(self, obj):
        """Phone number with styling"""
        if obj.phone and obj.phone.strip():
            return format_html(
                '<span style="font-family: monospace; color: #17a2b8;">📱 {}</span>',
                obj.phone.strip()
            )
        return format_html('<span style="color: #6c757d;">No phone</span>')
    phone_display.short_description = "📱 Phone"
    
    def address_display(self, obj):
        """Address with truncation"""
        if obj.address and obj.address.strip():
            address = obj.address.strip()
            if len(address) > 20:
                display_address = address[:20] + "..."
            else:
                display_address = address
            return format_html(
                '<span style="color: #28a745;" title="{}">{}</span>',
                address,  # Full address in tooltip
                display_address  # Truncated for display
            )
        return format_html('<span style="color: #6c757d;">No address</span>')
    address_display.short_description = "📍 Address"
    
    def items_summary_display(self, obj):
        """Items summary with count"""
        items_count = obj.total_items_count
        summary = obj.items_summary
        
        color = '#28a745' if items_count > 0 else '#6c757d'
        
        return format_html(
            '<div style="font-size: 0.9em;">'
            '<span style="background: {}; color: white; padding: 2px 6px; border-radius: 8px; font-weight: bold; margin-right: 5px;">{} items</span><br>'
            '<small style="color: #6c757d; line-height: 1.3;">{}</small>'
            '</div>',
            color, items_count, summary
        )
    items_summary_display.short_description = "📦 Items"
    
    def total_price_display(self, obj):
        """Formatted total price"""
        if obj.total_price and obj.total_price > 0:
            return format_html(
                '<span style="font-weight: bold; color: #28a745; font-family: monospace; font-size: 1.1em;">{}</span>',
                obj.total_price_formatted
            )
        return format_html('<span style="color: #dc3545;">Rp 0</span>')
    total_price_display.short_description = "💰 Total"
    total_price_display.admin_order_field = 'total_price'
    
    def payment_method_display(self, obj):
        """Payment method with styling"""
        method = obj.payment_method_display
        
        method_colors = {
            'Direct Bank Transfer': '#17a2b8',
            'Bank Transfer': '#17a2b8',
            'Cash on Delivery': '#ffc107',
            'Credit Card': '#28a745',
            'Digital Wallet': '#6f42c1'
        }
        
        color = method_colors.get(method, '#6c757d')
        
        return format_html(
            '<span style="background: {}; color: white; padding: 3px 8px; border-radius: 6px; font-size: 0.8em; font-weight: bold;">{}</span>',
            color, method
        )
    payment_method_display.short_description = "💳 Payment"
    
    def timestamp_display(self, obj):
        """Formatted timestamp"""
        if obj.timestamp:
            return format_html(
                '{}<br><small style="color: #6c757d;">{}</small>',
                obj.timestamp.strftime('%d %b %Y'),
                obj.timestamp.strftime('%H:%M')
            )
        return 'No Date'
    timestamp_display.short_description = "📅 Date"
    timestamp_display.admin_order_field = 'timestamp'
    
    def days_ago_display(self, obj):
        """Days ago with color coding"""
        days_text = obj.days_ago
        
        if 'ago' in days_text and 'day' in days_text:
            try:
                days = int(days_text.split()[0])
                if days <= 1:
                    color = '#28a745'
                elif days <= 7:
                    color = '#ffc107'
                else:
                    color = '#6c757d'
            except:
                color = '#6c757d'
        elif 'ago' in days_text:
            color = '#28a745'  # Recent (hours/minutes)
        else:
            color = '#6c757d'
        
        return format_html(
            '<span style="color: {}; font-weight: bold;">{}</span>',
            color, days_text
        )
    days_ago_display.short_description = "⏰ Age"
    
    def customer_summary_display(self, obj):
        """Customer summary for detail view"""
        # Debug values
        phone_debug = f"'{obj.phone}'" if obj.phone else "None/Empty"
        address_debug = f"'{obj.address}'" if obj.address else "None/Empty"
        
        return format_html(
            '<div style="background: #f8f9fa; padding: 15px; border-radius: 8px; border-left: 4px solid #007cba;">'
            '<h4 style="margin: 0 0 10px 0; color: #2c3e50;">👤 Customer Information</h4>'
            '<p style="margin: 5px 0;"><strong>Name:</strong> {}</p>'
            '<p style="margin: 5px 0;"><strong>Email:</strong> {}</p>'
            '<p style="margin: 5px 0;"><strong>Phone:</strong> {} <small style="color: #666;">(Raw: {})</small></p>'
            '<p style="margin: 5px 0;"><strong>Address:</strong> {} <small style="color: #666;">(Raw: {})</small></p>'
            '</div>',
            obj.customer_name,
            obj.customer_email,
            obj.phone or "❌ No phone data",
            phone_debug,
            obj.address or "❌ No address data", 
            address_debug
        )
    customer_summary_display.short_description = "Customer Summary"
    
    def items_parsed_display(self, obj):
        """Items breakdown for detail view"""
        items = obj.items_list
        quantities = obj.quantities_list
        
        if not items:
            return format_html('<p style="color: #6c757d;">No items found</p>')
        
        html = '<div style="background: #f8f9fa; padding: 15px; border-radius: 8px; border-left: 4px solid #28a745;">'
        html += '<h4 style="margin: 0 0 10px 0; color: #2c3e50;">📦 Items Breakdown</h4>'
        
        for i, item in enumerate(items):
            qty = quantities[i] if i < len(quantities) else "1"
            html += f'<p style="margin: 5px 0;">• <strong>{item}</strong> (Quantity: {qty})</p>'
        
        html += f'<hr style="margin: 10px 0;"><p style="margin: 0; font-weight: bold;">Total Items: {len(items)}</p>'
        html += '</div>'
        
        return format_html(html)
    items_parsed_display.short_description = "Items Breakdown"
    
    # =============================================================================
    # 🔧 CUSTOM ACTIONS
    # =============================================================================
    
    def export_orders_csv(self, request, queryset):
        """Export orders to CSV"""
        import csv
        from django.http import HttpResponse
        
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="order_history.csv"'
        
        writer = csv.writer(response)
        writer.writerow([
            'Order ID', 'Date', 'Customer Name', 'Email', 'Phone',
            'Items', 'Total Price', 'Payment Method', 'Address'
        ])
        
        for order in queryset:
            writer.writerow([
                order.order_number,
                order.timestamp.strftime('%Y-%m-%d %H:%M') if order.timestamp else '',
                order.customer_name,
                order.customer_email,
                order.customer_phone,
                order.items_summary,
                order.total_price or 0,
                order.payment_method_display,
                order.short_address
            ])
        
        self.message_user(request, f'✅ Exported {queryset.count()} orders to CSV.')
        return response
    
    export_orders_csv.short_description = "📊 Export selected orders to CSV"

# =============================================================================
# 📞 CONTACT ADMIN (unchanged)
# =============================================================================

@admin.register(Contact)
class ContactAdmin(admin.ModelAdmin):
    list_display = ['name', 'email', 'phone', 'is_read', 'created_at']
    list_filter = ['is_read', 'created_at']
    search_fields = ['name', 'email']
    list_editable = ['is_read']

# =============================================================================
# 🎨 ADMIN SITE CUSTOMIZATION
# =============================================================================

admin.site.site_header = "🛍️ E-commerce Store Administration"
admin.site.site_title = "Store Admin"
admin.site.index_title = "Welcome to Store Management Dashboard"