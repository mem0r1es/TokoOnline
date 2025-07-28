# File: orders/admin.py - REPLACE EXISTING CONTENT

from django.contrib import admin
from django.utils.html import format_html
from django.utils import timezone
from django.contrib import messages
from .models import Order, OrderItem, OrderStatusHistory

class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ['total_price']
    fields = ['product_id', 'product_name', 'quantity', 'unit_price', 'total_price']

class OrderStatusHistoryInline(admin.TabularInline):
    model = OrderStatusHistory
    extra = 0
    readonly_fields = ['created_at']
    fields = ['status', 'changed_by', 'notes', 'created_at']

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = [
        'order_id', 'customer_name', 'customer_email', 
        'status_badge', 'total_amount', 'created_at', 'order_actions'
    ]
    list_filter = ['status', 'payment_method', 'created_at', 'city']
    search_fields = ['order_id', 'customer_name', 'customer_email', 'customer_phone']
    readonly_fields = ['order_id', 'created_at', 'updated_at', 'get_total_items']
    
    fieldsets = (
        ('Order Information', {
            'fields': ('order_id', 'status', 'payment_method', 'created_at', 'updated_at')
        }),
        ('Customer Information', {
            'fields': ('customer_name', 'customer_email', 'customer_phone')
        }),
        ('Shipping Address', {
            'fields': ('shipping_address', 'city', 'province', 'postal_code')
        }),
        ('Pricing', {
            'fields': ('subtotal', 'shipping_cost', 'tax', 'total_amount')
        }),
        ('Timestamps', {
            'fields': ('paid_at', 'shipped_at', 'delivered_at'),
            'classes': ['collapse']
        }),
        ('Notes', {
            'fields': ('notes', 'admin_notes'),
            'classes': ['collapse']
        }),
    )
    
    inlines = [OrderItemInline, OrderStatusHistoryInline]
    
    # AUTO-SYNC ACTION ADDED
    actions = [
        'sync_from_supabase',  # NEW AUTO-SYNC ACTION
        'mark_as_paid', 'mark_as_processing', 'mark_as_shipped', 
        'mark_as_delivered', 'cancel_orders'
    ]
    
    def status_badge(self, obj):
        colors = {
            'pending': '#ffc107',
            'paid': '#28a745', 
            'processing': '#17a2b8',
            'shipped': '#6610f2',
            'delivered': '#28a745',
            'cancelled': '#dc3545',
            'refunded': '#6c757d'
        }
        color = colors.get(obj.status, '#6c757d')
        return format_html(
            '<span style="background-color: {}; color: white; padding: 3px 8px; border-radius: 3px; font-size: 11px;">{}</span>',
            color, obj.get_status_display()
        )
    status_badge.short_description = 'Status'
    
    def order_actions(self, obj):
        actions = []
        if obj.can_cancel():
            actions.append('<a href="#" onclick="cancelOrder({})">Cancel</a>'.format(obj.id))
        if obj.can_ship():
            actions.append('<a href="#" onclick="shipOrder({})">Ship</a>'.format(obj.id))
        if obj.can_deliver():
            actions.append('<a href="#" onclick="deliverOrder({})">Deliver</a>'.format(obj.id))
        
        return format_html(' | '.join(actions)) if actions else '-'
    order_actions.short_description = 'Actions'
    
    def get_total_items(self, obj):
        return obj.get_total_items()
    get_total_items.short_description = 'Total Items'
    
    # NEW AUTO-SYNC ACTION
    def sync_from_supabase(self, request, queryset):
        """Auto-sync latest orders from Supabase"""
        from .services import SupabaseOrderService
        
        try:
            service = SupabaseOrderService()
            synced_count = service.sync_all_orders(limit=50)  # Sync last 50 orders
            
            if synced_count > 0:
                self.message_user(
                    request, 
                    f'✅ Successfully synced {synced_count} new orders from Supabase!',
                    messages.SUCCESS
                )
            else:
                self.message_user(
                    request, 
                    '📋 No new orders to sync. All orders are up to date.',
                    messages.INFO
                )
        except Exception as e:
            self.message_user(
                request, 
                f'❌ Error syncing orders: {str(e)}',
                messages.ERROR
            )
    
    sync_from_supabase.short_description = '🔄 Sync Latest Orders from Supabase'
    
    # EXISTING BULK ACTIONS
    def mark_as_paid(self, request, queryset):
        updated = 0
        for order in queryset:
            if order.status == 'pending':
                order.status = 'paid'
                order.paid_at = timezone.now()
                order.save()
                
                OrderStatusHistory.objects.create(
                    order=order,
                    status='paid',
                    changed_by=request.user,
                    notes=f'Bulk action: Marked as paid by {request.user.username}'
                )
                updated += 1
        
        self.message_user(request, f'{updated} orders marked as paid.')
    mark_as_paid.short_description = 'Mark selected orders as paid'
    
    def mark_as_processing(self, request, queryset):
        updated = 0
        for order in queryset:
            if order.status == 'paid':
                order.status = 'processing'
                order.save()
                
                OrderStatusHistory.objects.create(
                    order=order,
                    status='processing',
                    changed_by=request.user,
                    notes=f'Bulk action: Marked as processing by {request.user.username}'
                )
                updated += 1
        
        self.message_user(request, f'{updated} orders marked as processing.')
    mark_as_processing.short_description = 'Mark selected orders as processing'
    
    def mark_as_shipped(self, request, queryset):
        updated = 0
        for order in queryset:
            if order.status == 'processing':
                order.status = 'shipped'
                order.shipped_at = timezone.now()
                order.save()
                
                OrderStatusHistory.objects.create(
                    order=order,
                    status='shipped',
                    changed_by=request.user,
                    notes=f'Bulk action: Marked as shipped by {request.user.username}'
                )
                updated += 1
        
        self.message_user(request, f'{updated} orders marked as shipped.')
    mark_as_shipped.short_description = 'Mark selected orders as shipped'
    
    def mark_as_delivered(self, request, queryset):
        updated = 0
        for order in queryset:
            if order.status == 'shipped':
                order.status = 'delivered'
                order.delivered_at = timezone.now()
                order.save()
                
                OrderStatusHistory.objects.create(
                    order=order,
                    status='delivered',
                    changed_by=request.user,
                    notes=f'Bulk action: Ma-rked as delivered by {request.user.username}'
                )
                updated += 1
        
        self.message_user(request, f'{updated} orders marked as delivered.')
    mark_as_delivered.short_description = 'Mark selected orders as delivered'
    
    def cancel_orders(self, request, queryset):
        updated = 0
        for order in queryset:
            if order.can_cancel():
                order.status = 'cancelled'
                order.save()
                
                OrderStatusHistory.objects.create(
                    order=order,
                    status='cancelled',
                    changed_by=request.user,
                    notes=f'Bulk action: Cancelled by {request.user.username}'
                )
                updated += 1
        
        self.message_user(request, f'{updated} orders cancelled.')
    cancel_orders.short_description = 'Cancel selected orders'

@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
    list_display = ['order', 'product_name', 'quantity', 'unit_price', 'total_price']
    list_filter = ['order__status', 'product_category']
    search_fields = ['product_name', 'product_sku', 'order__order_id']
    readonly_fields = ['total_price']

@admin.register(OrderStatusHistory)  
class OrderStatusHistoryAdmin(admin.ModelAdmin):
    list_display = ['order', 'status', 'changed_by', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['order__order_id', 'notes']
    readonly_fields = ['created_at']