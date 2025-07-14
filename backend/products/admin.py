# products/admin.py - Enhanced UI with Modern Styling
from django.contrib import admin
from django.utils.html import format_html
from django.utils.safestring import mark_safe
from django.db.models import Count, Sum
from django.utils import timezone
from django.urls import reverse
from datetime import timedelta
import json
from .models import SupabaseProduct, OrderHistory, Contact, Seller

# =============================================================================
# 🎨 CUSTOM ADMIN MEDIA - Modern CSS & JS
# =============================================================================

class ModernAdminMixin:
    """Mixin untuk styling modern di semua admin"""
    
    class Media:
        css = {
            'all': [
                'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css',
            ]
        }
        js = []
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Inject custom CSS langsung
        self.modern_css = """
        <style>
        :root {
            --primary-color: #2563eb;
            --secondary-color: #1e40af;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --danger-color: #ef4444;
            --info-color: #06b6d4;
            --dark-color: #1f2937;
            --light-color: #f8fafc;
            --border-color: #e5e7eb;
            --shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
            --border-radius: 12px;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        /* Header Enhancement */
        #header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            box-shadow: var(--shadow-lg);
            border: none;
            position: relative;
            overflow: hidden;
        }
        
        #header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="rgba(255,255,255,0.1)"/><circle cx="75" cy="75" r="1" fill="rgba(255,255,255,0.1)"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
            opacity: 0.3;
        }
        
        #branding h1 {
            color: white !important;
            font-weight: 800;
            font-size: 1.75rem;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
            position: relative;
            z-index: 1;
        }
        
        #user-tools {
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            border-radius: var(--border-radius);
            padding: 0.75rem 1.25rem;
            position: relative;
            z-index: 1;
        }
        
        #user-tools a {
            color: white !important;
            text-decoration: none;
            font-weight: 600;
            transition: var(--transition);
            padding: 0.25rem 0.5rem;
            border-radius: 6px;
        }
        
        #user-tools a:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-1px);
        }
        
        /* Content Area */
        #content {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            min-height: calc(100vh - 120px);
            padding: 2rem;
        }
        
        /* Breadcrumbs */
        .breadcrumbs {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            padding: 1rem 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: var(--shadow-sm);
        }
        
        .breadcrumbs a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            transition: var(--transition);
            position: relative;
        }
        
        .breadcrumbs a:hover {
            color: var(--secondary-color);
        }
        
        .breadcrumbs a::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 0;
            height: 2px;
            background: var(--primary-color);
            transition: width 0.3s ease;
        }
        
        .breadcrumbs a:hover::after {
            width: 100%;
        }
        
        /* Modules & Cards */
        .module, #result_list, #toolbar, #changelist-filter {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            transition: var(--transition);
        }
        
        .module:hover, #result_list:hover {
            box-shadow: var(--shadow-md);
            transform: translateY(-2px);
        }
        
        .module h2 {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: white;
            padding: 1.25rem 1.5rem;
            margin: 0;
            font-size: 1.125rem;
            font-weight: 700;
            border: none;
            position: relative;
        }
        
        .module h2::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, rgba(255,255,255,0.3) 0%, rgba(255,255,255,0.1) 100%);
        }
        
        /* Table Enhancements */
        #result_list {
            margin-top: 1.5rem;
        }
        
        #result_list thead th {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-bottom: 3px solid var(--primary-color);
            padding: 1.25rem 1rem;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 0.875rem;
            letter-spacing: 0.5px;
            color: var(--dark-color);
            position: relative;
        }
        
        #result_list thead th::after {
            content: '';
            position: absolute;
            bottom: -3px;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent 0%, var(--primary-color) 50%, transparent 100%);
        }
        
        #result_list tbody tr {
            transition: var(--transition);
            border-bottom: 1px solid #f1f5f9;
        }
        
        #result_list tbody tr:hover {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.05) 0%, rgba(30, 64, 175, 0.02) 100%);
            transform: scale(1.001);
            box-shadow: inset 0 0 0 1px rgba(37, 99, 235, 0.1);
        }
        
        #result_list tbody tr:nth-child(even) {
            background: #fafbfc;
        }
        
        #result_list tbody tr:nth-child(even):hover {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.05) 0%, rgba(30, 64, 175, 0.02) 100%);
        }
        
        #result_list td, #result_list th {
            padding: 1rem;
            vertical-align: middle;
        }
        
        /* Search & Toolbar */
        #toolbar {
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            background: linear-gradient(135deg, white 0%, #f8fafc 100%);
        }
        
        #toolbar form#changelist-search {
            display: flex;
            gap: 1rem;
            align-items: center;
        }
        
        #toolbar input[type="text"] {
            flex: 1;
            padding: 0.875rem 1.25rem;
            border: 2px solid var(--border-color);
            border-radius: var(--border-radius);
            font-size: 1rem;
            transition: var(--transition);
            background: white;
            box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.05);
        }
        
        #toolbar input[type="text"]:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1), inset 0 1px 2px rgba(0, 0, 0, 0.05);
            transform: translateY(-1px);
        }
        
        #toolbar input[type="submit"] {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: white;
            border: none;
            padding: 0.875rem 2rem;
            border-radius: var(--border-radius);
            font-weight: 700;
            cursor: pointer;
            transition: var(--transition);
            box-shadow: var(--shadow-sm);
        }
        
        #toolbar input[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }
        
        /* Filters */
        #changelist-filter {
            background: white;
            margin-left: 1.5rem;
        }
        
        #changelist-filter h2 {
            background: linear-gradient(135deg, var(--info-color) 0%, #0891b2 100%);
            color: white;
            padding: 1.25rem;
            margin: 0;
            font-size: 1.125rem;
            font-weight: 700;
        }
        
        #changelist-filter h3 {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            margin: 0;
            padding: 1rem;
            border-bottom: 1px solid var(--border-color);
            font-size: 0.925rem;
            font-weight: 600;
            color: var(--dark-color);
        }
        
        #changelist-filter li a {
            display: block;
            padding: 0.875rem 1.25rem;
            color: var(--dark-color);
            text-decoration: none;
            transition: var(--transition);
            border-left: 3px solid transparent;
        }
        
        #changelist-filter li a:hover {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.05) 0%, rgba(30, 64, 175, 0.02) 100%);
            border-left-color: var(--primary-color);
            padding-left: 1.5rem;
        }
        
        #changelist-filter li.selected a {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: white;
            font-weight: 600;
            border-left-color: white;
        }
        
        /* Form Enhancements */
        fieldset.module {
            margin-bottom: 2rem;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-sm);
            transition: var(--transition);
        }
        
        fieldset.module:hover {
            box-shadow: var(--shadow-md);
        }
        
        .form-row input, .form-row select, .form-row textarea {
            border: 2px solid var(--border-color);
            border-radius: var(--border-radius);
            padding: 0.875rem 1rem;
            font-size: 1rem;
            transition: var(--transition);
            background: white;
            box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.05);
        }
        
        .form-row input:focus, .form-row select:focus, .form-row textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1), inset 0 1px 2px rgba(0, 0, 0, 0.05);
            transform: translateY(-1px);
        }
        
        .form-row label {
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 0.5rem;
            display: block;
        }
        
        /* Buttons */
        .default, input[type="submit"].default {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: white;
            border: none;
            padding: 0.875rem 2rem;
            border-radius: var(--border-radius);
            font-weight: 700;
            cursor: pointer;
            transition: var(--transition);
            box-shadow: var(--shadow-sm);
            text-decoration: none;
            display: inline-block;
        }
        
        .default:hover, input[type="submit"].default:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }
        
        .button, input[type="submit"], input[type="button"] {
            background: white;
            color: var(--primary-color);
            border: 2px solid var(--primary-color);
            padding: 0.75rem 1.5rem;
            border-radius: var(--border-radius);
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            text-decoration: none;
            display: inline-block;
        }
        
        .button:hover, input[type="submit"]:hover, input[type="button"]:hover {
            background: var(--primary-color);
            color: white;
            transform: translateY(-1px);
            box-shadow: var(--shadow-sm);
        }
        
        /* Inline Forms */
        .inline-group {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            margin-bottom: 2rem;
            overflow: hidden;
            box-shadow: var(--shadow-sm);
        }
        
        .inline-group .inline-related {
            border-bottom: 1px solid #f1f5f9;
            padding: 1.5rem;
            transition: var(--transition);
        }
        
        .inline-group .inline-related:hover {
            background: #fafbfc;
        }
        
        .inline-group .inline-related:last-child {
            border-bottom: none;
        }
        
        .inline-group h2 {
            background: linear-gradient(135deg, var(--success-color) 0%, #059669 100%);
            color: white;
            padding: 1.25rem 1.5rem;
            margin: 0;
            font-size: 1.125rem;
            font-weight: 700;
        }
        
        /* Custom badges and status */
        .status-badge {
            padding: 0.375rem 0.875rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.025em;
            display: inline-flex;
            align-items: center;
            gap: 0.375rem;
        }
        
        /* Animations */
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }
        
        .module, #result_list, #toolbar, .inline-group {
            animation: slideIn 0.4s ease-out;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            #content { padding: 1rem; }
            #toolbar form#changelist-search { flex-direction: column; }
            #changelist-filter { margin: 1rem 0 0 0; width: 100%; }
            .results { margin-right: 0; }
        }
        
        /* Loading states */
        .loading::after {
            content: '';
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid currentColor;
            border-right-color: transparent;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            margin-left: 0.5rem;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        </style>
        
        <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Enhanced table row interactions
            const tableRows = document.querySelectorAll('#result_list tbody tr');
            tableRows.forEach(row => {
                row.addEventListener('mouseenter', function() {
                    this.style.transform = 'scale(1.002)';
                });
                row.addEventListener('mouseleave', function() {
                    this.style.transform = 'scale(1)';
                });
            });
            
            // Search enhancement
            const searchInput = document.querySelector('#toolbar input[type="text"]');
            if (searchInput) {
                searchInput.setAttribute('placeholder', '🔍 Search...');
            }
            
            // Button loading states
            const submitButtons = document.querySelectorAll('input[type="submit"], .default');
            submitButtons.forEach(btn => {
                btn.addEventListener('click', function() {
                    this.classList.add('loading');
                    setTimeout(() => this.classList.remove('loading'), 2000);
                });
            });
            
            // Number animation
            function animateValue(element, start, end, duration) {
                const range = end - start;
                const increment = range / (duration / 16);
                let current = start;
                
                const timer = setInterval(() => {
                    current += increment;
                    if (current >= end) {
                        element.textContent = end;
                        clearInterval(timer);
                    } else {
                        element.textContent = Math.floor(current);
                    }
                }, 16);
            }
            
            // Animate dashboard numbers
            const numberElements = document.querySelectorAll('[style*="font-size: 2em"]');
            numberElements.forEach(el => {
                const finalValue = parseInt(el.textContent);
                if (!isNaN(finalValue) && finalValue > 0) {
                    el.textContent = '0';
                    setTimeout(() => animateValue(el, 0, finalValue, 1500), 300);
                }
            });
        });
        </script>
        """

# =============================================================================
# 🔧 CUSTOM FILTERS (Enhanced dengan UI)
# =============================================================================

class RecentOrdersFilter(admin.SimpleListFilter):
    title = '📅 Recent Orders'
    parameter_name = 'recent'
    
    def lookups(self, request, model_admin):
        return (
            ('today', '🔥 Today'),
            ('yesterday', '📆 Yesterday'),
            ('this_week', '📊 This Week'),
            ('last_week', '📈 Last Week'),
            ('this_month', '📋 This Month'),
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
    title = '💰 Order Value'
    parameter_name = 'price_range'
    
    def lookups(self, request, model_admin):
        return (
            ('under_50k', '💸 Under Rp 50,000'),
            ('50k_100k', '💵 Rp 50,000 - 100,000'),
            ('100k_500k', '💴 Rp 100,000 - 500,000'),
            ('over_500k', '💎 Over Rp 500,000'),
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
# 🏪 ENHANCED SELLER ADMIN
# =============================================================================

class ProductInline(admin.TabularInline):
    """Enhanced inline products"""
    model = SupabaseProduct
    extra = 0
    readonly_fields = ('id', 'created_at', 'price_formatted')
    fields = ('name', 'price_formatted', 'price', 'stock', 'category', 'is_active', 'created_at')
    
    def price_formatted(self, obj):
        """Formatted price display"""
        if obj.price:
            return format_html(
                '<span style="background: linear-gradient(135deg, #10b981, #059669); color: white; padding: 4px 8px; border-radius: 6px; font-weight: 600; font-family: monospace;">💰 Rp {}</span>',
                f"{obj.price:,.0f}"
            )
        return format_html('<span style="color: #6b7280;">Rp 0</span>')
    price_formatted.short_description = "💰 Price"

@admin.register(Seller)
class SellerAdmin(ModernAdminMixin, admin.ModelAdmin):
    """Enhanced Seller Admin with Modern UI"""
    
    list_display = [
        'store_name_display', 
        'owner_name', 
        'contact_info_display',
        'products_count_display',
        'status_display',
        'created_at_display'
    ]
    
    list_filter = [
        'is_active', 
        'created_at',
        ('created_at', admin.DateFieldListFilter),
    ]
    
    search_fields = [
        'store_name', 
        'owner_name', 
        'email',
        'phone'
    ]
    
    readonly_fields = [
        'id', 
        'created_at', 
        'updated_at',
        'products_summary_display'
    ]
    
    fieldsets = (
        ('🏪 Store Information', {
            'fields': ('store_name', 'owner_name', 'description'),
            'classes': ('wide',)
        }),
        ('📞 Contact Information', {
            'fields': ('email', 'phone', 'address'),
            'classes': ('wide',)
        }),
        ('📊 Store Statistics', {
            'fields': ('products_summary_display',),
            'classes': ('wide',)
        }),
        ('⚙️ Status', {
            'fields': ('is_active',),
            'classes': ('wide',)
        }),
        ('📅 Timestamps', {
            'fields': ('id', 'created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    inlines = [ProductInline]
    ordering = ['store_name']
    list_per_page = 25
    
    def changelist_view(self, request, extra_context=None):
        extra_context = extra_context or {}
        extra_context['custom_css'] = mark_safe(self.modern_css)
        return super().changelist_view(request, extra_context)
    
    def change_view(self, request, object_id, form_url='', extra_context=None):
        extra_context = extra_context or {}
        extra_context['custom_css'] = mark_safe(self.modern_css)
        return super().change_view(request, object_id, form_url, extra_context)
    
    # =============================================================================
    # 🎨 ENHANCED DISPLAY METHODS
    # =============================================================================
    
    def store_name_display(self, obj):
        """Store name with beautiful styling"""
        return format_html(
            '<div style="display: flex; align-items: center; gap: 8px;">'
            '<span style="background: linear-gradient(135deg, #2563eb, #1e40af); color: white; padding: 6px 10px; border-radius: 8px; font-weight: 700; font-size: 0.9em; box-shadow: 0 2px 4px rgba(37, 99, 235, 0.3);">🏪</span>'
            '<strong style="color: #1f2937; font-size: 1.1em; font-weight: 600;">{}</strong>'
            '</div>',
            obj.store_name
        )
    store_name_display.short_description = "🏪 Store Name"
    store_name_display.admin_order_field = 'store_name'
    
    def contact_info_display(self, obj):
        """Enhanced contact info display"""
        phone = obj.phone if obj.phone else "No phone"
        return format_html(
            '<div style="line-height: 1.6;">'
            '<div style="margin-bottom: 4px; display: flex; align-items: center; gap: 6px;">'
            '<span style="background: #06b6d4; color: white; padding: 2px 6px; border-radius: 4px; font-size: 0.8em;">📧</span>'
            '<span style="color: #374151; font-weight: 500;">{}</span>'
            '</div>'
            '<div style="display: flex; align-items: center; gap: 6px;">'
            '<span style="background: #10b981; color: white; padding: 2px 6px; border-radius: 4px; font-size: 0.8em;">📱</span>'
            '<span style="color: #374151; font-weight: 500;">{}</span>'
            '</div>'
            '</div>',
            obj.email,
            phone
        )
    contact_info_display.short_description = "📞 Contact"
    
    def products_count_display(self, obj):
        """Enhanced product count with beautiful badges"""
        count = obj.total_products
        
        if count > 0:
            url = reverse('admin:products_supabaseproduct_changelist') + f'?seller__id__exact={obj.id}'
            color = '#10b981' if count >= 10 else '#f59e0b' if count >= 5 else '#06b6d4'
            return format_html(
                '<a href="{}" style="text-decoration: none;">'
                '<span style="background: linear-gradient(135deg, {}, {}); color: white; padding: 6px 12px; border-radius: 20px; font-weight: 700; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); transition: all 0.3s ease;" '
                'onmouseover="this.style.transform=\'translateY(-2px)\'; this.style.boxShadow=\'0 4px 8px rgba(0,0,0,0.15)\'" '
                'onmouseout="this.style.transform=\'translateY(0)\'; this.style.boxShadow=\'0 2px 4px rgba(0,0,0,0.1)\'">'
                '📦 {} products'
                '</span>'
                '</a>',
                url, color, color + '20', count
            )
        else:
            return format_html(
                '<span style="background: linear-gradient(135deg, #6b7280, #4b5563); color: white; padding: 6px 12px; border-radius: 20px; font-weight: 700; display: inline-flex; align-items: center; gap: 6px; opacity: 0.7;">'
                '📦 0 products'
                '</span>'
            )
    products_count_display.short_description = "📦 Products"
    
    def status_display(self, obj):
        """Enhanced status with beautiful indicators"""
        if obj.is_active:
            return format_html(
                '<span style="background: linear-gradient(135deg, #10b981, #059669); color: white; padding: 6px 12px; border-radius: 20px; font-weight: 700; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(16, 185, 129, 0.3);">'
                '<span style="width: 8px; height: 8px; background: white; border-radius: 50%; animation: pulse 2s infinite;"></span>'
                '✅ Active'
                '</span>'
            )
        else:
            return format_html(
                '<span style="background: linear-gradient(135deg, #ef4444, #dc2626); color: white; padding: 6px 12px; border-radius: 20px; font-weight: 700; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(239, 68, 68, 0.3);">'
                '<span style="width: 8px; height: 8px; background: white; border-radius: 50%;"></span>'
                '❌ Inactive'
                '</span>'
            )
    status_display.short_description = "⚙️ Status"
    status_display.admin_order_field = 'is_active'
    
    def created_at_display(self, obj):
        """Enhanced date display"""
        if obj.created_at:
            return format_html(
                '<div style="text-align: center;">'
                '<div style="background: linear-gradient(135deg, #8b5cf6, #7c3aed); color: white; padding: 4px 8px; border-radius: 6px; font-weight: 600; margin-bottom: 2px;">{}</div>'
                '<small style="color: #6b7280; font-weight: 500;">{}</small>'
                '</div>',
                obj.created_at.strftime('%d %b %Y'),
                obj.created_at.strftime('%H:%M')
            )
        return format_html('<span style="color: #9ca3af;">No Date</span>')
    created_at_display.short_description = "📅 Created"
    created_at_display.admin_order_field = 'created_at'
    
    def products_summary_display(self, obj):
        """Enhanced products summary with beautiful cards"""
        active_products = obj.products.filter(is_active=True).count()
        total_products = obj.products.count()
        inactive_products = total_products - active_products
        
        return format_html(
            '<div style="background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%); padding: 24px; border-radius: 16px; border-left: 6px solid #2563eb; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">'
            '<h4 style="margin: 0 0 20px 0; color: #1f2937; font-size: 1.25rem; font-weight: 700; display: flex; align-items: center; gap: 8px;">'
            '<span style="background: #2563eb; color: white; padding: 8px; border-radius: 8px;">📊</span>'
            'Products Statistics'
            '</h4>'
            '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 16px;">'
            '<div style="text-align: center; background: white; padding: 16px; border-radius: 12px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); border: 2px solid #10b981;">'
            '<div style="font-size: 2.5rem; font-weight: 800; color: #10b981; margin-bottom: 4px;">{}</div>'
            '<div style="color: #6b7280; font-weight: 600; font-size: 0.875rem;">Active Products</div>'
            '</div>'
            '<div style="text-align: center; background: white; padding: 16px; border-radius: 12px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); border: 2px solid #ef4444;">'
            '<div style="font-size: 2.5rem; font-weight: 800; color: #ef4444; margin-bottom: 4px;">{}</div>'
            '<div style="color: #6b7280; font-weight: 600; font-size: 0.875rem;">Inactive Products</div>'
            '</div>'
            '<div style="text-align: center; background: white; padding: 16px; border-radius: 12px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); border: 2px solid #2563eb;">'
            '<div style="font-size: 2.5rem; font-weight: 800; color: #2563eb; margin-bottom: 4px;">{}</div>'
            '<div style="color: #6b7280; font-weight: 600; font-size: 0.875rem;">Total Products</div>'
            '</div>'
            '</div>'
            '</div>',
            active_products,
            inactive_products,
            total_products
        )
    products_summary_display.short_description = "Products Summary"

# =============================================================================
# 🛍️ ENHANCED PRODUCT ADMIN  
# =============================================================================

@admin.register(SupabaseProduct)
class SupabaseProductAdmin(ModernAdminMixin, admin.ModelAdmin):
    """Enhanced Product Admin with Modern UI"""
    
    list_display = [
        'name', 
        'seller_link_display',
        'price_display', 
        'stock',  # Raw field for editable
        'category_display',
        'is_active',  # Raw field for editable
        'created_at_display'
    ]
    
    list_filter = [
        'is_active', 
        'category', 
        'seller',  # Filter by seller
        'created_at',
        ('created_at', admin.DateFieldListFilter),
    ]
    
    search_fields = [
        'name', 
        'description', 
        'category',
        'seller__store_name',  # Search by seller name
        'seller__owner_name'
    ]
    
    readonly_fields = [
        'id', 
        'created_at', 
        'updated_at'
    ]
    
    list_editable = [
        'is_active', 
        'stock'
    ]
    
    fieldsets = (
        ('📦 Product Information', {
            'fields': ('name', 'description', 'category'),
            'classes': ('wide',)
        }),
        ('🏪 Store Assignment', {
            'fields': ('seller',),
            'classes': ('wide',),
            'description': 'Assign this product to a seller/store'
        }),
        ('💰 Pricing & Stock', {
            'fields': ('price', 'stock'),
            'classes': ('wide',)
        }),
        ('🖼️ Media', {
            'fields': ('image_url',),
            'classes': ('wide',)
        }),
        ('⚙️ Status', {
            'fields': ('is_active',),
            'classes': ('wide',)
        }),
        ('📅 Timestamps', {
            'fields': ('id', 'created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    ordering = ['-created_at']
    list_per_page = 25
    
    def changelist_view(self, request, extra_context=None):
        extra_context = extra_context or {}
        extra_context['custom_css'] = mark_safe(self.modern_css)
        return super().changelist_view(request, extra_context)
    
    def change_view(self, request, object_id, form_url='', extra_context=None):
        extra_context = extra_context or {}
        extra_context['custom_css'] = mark_safe(self.modern_css)
        return super().change_view(request, object_id, form_url, extra_context)
    
    # =============================================================================
    # 🎨 ENHANCED DISPLAY METHODS
    # =============================================================================
    
    def seller_link_display(self, obj):
        """Enhanced seller display with beautiful badges"""
        if obj.seller:
            url = reverse('admin:products_seller_change', args=[obj.seller.id])
            return format_html(
                '<a href="{}" style="text-decoration: none;">'
                '<span style="background: linear-gradient(135deg, #2563eb, #1e40af); color: white; padding: 6px 12px; border-radius: 20px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(37, 99, 235, 0.3); transition: all 0.3s ease;" '
                'onmouseover="this.style.transform=\'translateY(-2px)\'; this.style.boxShadow=\'0 4px 8px rgba(37, 99, 235, 0.4)\'" '
                'onmouseout="this.style.transform=\'translateY(0)\'; this.style.boxShadow=\'0 2px 4px rgba(37, 99, 235, 0.3)\'">'
                '🏪 {}'
                '</span>'
                '</a>',
                url, obj.seller.store_name
            )
        return format_html(
            '<span style="background: linear-gradient(135deg, #ef4444, #dc2626); color: white; padding: 6px 12px; border-radius: 20px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; opacity: 0.8;">'
            '❌ No Seller'
            '</span>'
        )
    seller_link_display.short_description = "🏪 Seller"
    seller_link_display.admin_order_field = 'seller__store_name'
    
    def price_display(self, obj):
        """Enhanced price display with beautiful formatting"""
        return format_html(
            '<span style="background: linear-gradient(135deg, #10b981, #059669); color: white; padding: 6px 12px; border-radius: 8px; font-weight: 700; font-family: monospace; box-shadow: 0 2px 4px rgba(16, 185, 129, 0.3);">💰 Rp {}</span>',
            f"{obj.price:,.0f}"
        )
    price_display.short_description = "💰 Price"
    price_display.admin_order_field = 'price'
    
    def category_display(self, obj):
        """Enhanced category display with beautiful badges"""
        if obj.category:
            colors = {
                'electronics': '#8b5cf6',
                'fashion': '#ec4899', 
                'books': '#06b6d4',
                'food': '#10b981',
                'home': '#f59e0b'
            }
            color = colors.get(obj.category.lower(), '#6b7280')
            return format_html(
                '<span style="background: linear-gradient(135deg, {}, {}); color: white; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 0.875rem; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);">🏷️ {}</span>',
                color, color + '20', obj.category
            )
        return format_html(
            '<span style="color: #9ca3af; font-style: italic; padding: 4px 10px; background: #f3f4f6; border-radius: 12px; font-size: 0.875rem;">No category</span>'
        )
    category_display.short_description = "🏷️ Category"
    category_display.admin_order_field = 'category'
    
    def created_at_display(self, obj):
        """Enhanced date display"""
        if obj.created_at:
            return format_html(
                '<div style="text-align: center;">'
                '<div style="background: linear-gradient(135deg, #8b5cf6, #7c3aed); color: white; padding: 4px 8px; border-radius: 6px; font-weight: 600; margin-bottom: 2px;">{}</div>'
                '<small style="color: #6b7280; font-weight: 500;">{}</small>'
                '</div>',
                obj.created_at.strftime('%d %b %Y'),
                obj.created_at.strftime('%H:%M')
            )
        return format_html('<span style="color: #9ca3af;">No Date</span>')
    created_at_display.short_description = "📅 Created"
    created_at_display.admin_order_field = 'created_at'

# =============================================================================
# 📋 ENHANCED ORDER HISTORY ADMIN
# =============================================================================

@admin.register(OrderHistory)
class OrderHistoryAdmin(ModernAdminMixin, admin.ModelAdmin):
    """Enhanced OrderHistory Admin with Modern UI"""
    
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
    
    def changelist_view(self, request, extra_context=None):
        extra_context = extra_context or {}
        extra_context['custom_css'] = mark_safe(self.modern_css)
        return super().changelist_view(request, extra_context)
    
    def change_view(self, request, object_id, form_url='', extra_context=None):
        extra_context = extra_context or {}
        extra_context['custom_css'] = mark_safe(self.modern_css)
        return super().change_view(request, object_id, form_url, extra_context)
    
    # =============================================================================
    # 🎨 ENHANCED DISPLAY METHODS (keeping all original functionality)
    # =============================================================================
    
    def order_number_display(self, obj):
        """Enhanced order number with beautiful styling"""
        return format_html(
            '<span style="background: linear-gradient(135deg, #2563eb, #1e40af); color: white; padding: 6px 12px; border-radius: 8px; font-family: monospace; font-weight: 700; box-shadow: 0 2px 4px rgba(37, 99, 235, 0.3);">📄 {}</span>',
            obj.order_number
        )
    order_number_display.short_description = "📄 Order #"
    order_number_display.admin_order_field = 'id'
    
    def customer_info_display(self, obj):
        """Enhanced customer info display"""
        name = obj.customer_name
        email = obj.customer_email if obj.email else ''
        
        return format_html(
            '<div style="line-height: 1.6;">'
            '<div><strong style="color: #1f2937; font-weight: 600;">{}</strong></div>'
            '<small style="color: #6b7280; font-weight: 500;">{}</small>'
            '</div>',
            name, email
        )
    customer_info_display.short_description = "👤 Customer"
    
    def phone_display(self, obj):
        """Enhanced phone display"""
        if obj.phone and obj.phone.strip():
            return format_html(
                '<span style="background: linear-gradient(135deg, #06b6d4, #0891b2); color: white; padding: 4px 8px; border-radius: 6px; font-family: monospace; font-weight: 600;">📱 {}</span>',
                obj.phone.strip()
            )
        return format_html('<span style="color: #9ca3af; font-style: italic;">No phone</span>')
    phone_display.short_description = "📱 Phone"
    
    def address_display(self, obj):
        """Enhanced address display"""
        if obj.address and obj.address.strip():
            address = obj.address.strip()
            if len(address) > 20:
                display_address = address[:20] + "..."
            else:
                display_address = address
            return format_html(
                '<span style="background: linear-gradient(135deg, #10b981, #059669); color: white; padding: 4px 8px; border-radius: 6px; font-weight: 600;" title="{}">{}</span>',
                address,  # Full address in tooltip
                display_address  # Truncated for display
            )
        return format_html('<span style="color: #9ca3af; font-style: italic;">No address</span>')
    address_display.short_description = "📍 Address"
    
    def items_summary_display(self, obj):
        """Enhanced items display"""
        items_count = obj.total_items_count
        summary = obj.items_summary
        
        color = '#10b981' if items_count > 0 else '#6b7280'
        
        return format_html(
            '<div style="font-size: 0.9em;">'
            '<span style="background: linear-gradient(135deg, {}, {}); color: white; padding: 4px 8px; border-radius: 12px; font-weight: 700; margin-bottom: 4px; display: inline-block;">📦 {} items</span><br>'
            '<small style="color: #6b7280; line-height: 1.4; font-weight: 500;">{}</small>'
            '</div>',
            color, color + '20', items_count, summary
        )
    items_summary_display.short_description = "📦 Items"
    
    def total_price_display(self, obj):
        """Enhanced price display"""
        if obj.total_price and obj.total_price > 0:
            return format_html(
                '<span style="background: linear-gradient(135deg, #10b981, #059669); color: white; padding: 6px 12px; border-radius: 8px; font-weight: 700; font-family: monospace; font-size: 1.1em; box-shadow: 0 2px 4px rgba(16, 185, 129, 0.3);">💰 {}</span>',
                obj.total_price_formatted
            )
        return format_html('<span style="background: #ef4444; color: white; padding: 4px 8px; border-radius: 6px; font-weight: 600;">💸 Rp 0</span>')
    total_price_display.short_description = "💰 Total"
    total_price_display.admin_order_field = 'total_price'
    
    def payment_method_display(self, obj):
        """Enhanced payment method display"""
        method = obj.payment_method_display
        
        method_colors = {
            'Direct Bank Transfer': '#06b6d4',
            'Bank Transfer': '#06b6d4',
            'Cash on Delivery': '#f59e0b',
            'Credit Card': '#10b981',
            'Digital Wallet': '#8b5cf6'
        }
        
        color = method_colors.get(method, '#6b7280')
        
        return format_html(
            '<span style="background: linear-gradient(135deg, {}, {}); color: white; padding: 4px 10px; border-radius: 12px; font-size: 0.875rem; font-weight: 600; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);">💳 {}</span>',
            color, color + '20', method
        )
    payment_method_display.short_description = "💳 Payment"
    
    def timestamp_display(self, obj):
        """Enhanced timestamp display"""
        if obj.timestamp:
            return format_html(
                '<div style="text-align: center;">'
                '<div style="background: linear-gradient(135deg, #8b5cf6, #7c3aed); color: white; padding: 4px 8px; border-radius: 6px; font-weight: 600; margin-bottom: 2px;">{}</div>'
                '<small style="color: #6b7280; font-weight: 500;">{}</small>'
                '</div>',
                obj.timestamp.strftime('%d %b %Y'),
                obj.timestamp.strftime('%H:%M')
            )
        return format_html('<span style="color: #9ca3af;">No Date</span>')
    timestamp_display.short_description = "📅 Date"
    timestamp_display.admin_order_field = 'timestamp'
    
    def days_ago_display(self, obj):
        """Enhanced days ago display"""
        days_text = obj.days_ago
        
        if 'ago' in days_text and 'day' in days_text:
            try:
                days = int(days_text.split()[0])
                if days <= 1:
                    color = '#10b981'
                elif days <= 7:
                    color = '#f59e0b'
                else:
                    color = '#6b7280'
            except:
                color = '#6b7280'
        elif 'ago' in days_text:
            color = '#10b981'  # Recent (hours/minutes)
        else:
            color = '#6b7280'
        
        return format_html(
            '<span style="background: linear-gradient(135deg, {}, {}); color: white; padding: 4px 8px; border-radius: 6px; font-weight: 600;">⏰ {}</span>',
            color, color + '20', days_text
        )
    days_ago_display.short_description = "⏰ Age"
    
    def customer_summary_display(self, obj):
        """Enhanced customer summary"""
        # Debug values
        phone_debug = f"'{obj.phone}'" if obj.phone else "None/Empty"
        address_debug = f"'{obj.address}'" if obj.address else "None/Empty"
        
        return format_html(
            '<div style="background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%); padding: 20px; border-radius: 16px; border-left: 6px solid #2563eb; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">'
            '<h4 style="margin: 0 0 16px 0; color: #1f2937; font-size: 1.25rem; font-weight: 700; display: flex; align-items: center; gap: 8px;">'
            '<span style="background: #2563eb; color: white; padding: 8px; border-radius: 8px;">👤</span>'
            'Customer Information'
            '</h4>'
            '<div style="grid-template-columns: 1fr; gap: 12px; display: grid;">'
            '<p style="margin: 0; padding: 8px 0; border-bottom: 1px solid #e5e7eb;"><strong style="color: #374151;">Name:</strong> <span style="color: #1f2937;">{}</span></p>'
            '<p style="margin: 0; padding: 8px 0; border-bottom: 1px solid #e5e7eb;"><strong style="color: #374151;">Email:</strong> <span style="color: #1f2937;">{}</span></p>'
            '<p style="margin: 0; padding: 8px 0; border-bottom: 1px solid #e5e7eb;"><strong style="color: #374151;">Phone:</strong> <span style="color: #1f2937;">{}</span> <small style="color: #9ca3af;">(Raw: {})</small></p>'
            '<p style="margin: 0; padding: 8px 0;"><strong style="color: #374151;">Address:</strong> <span style="color: #1f2937;">{}</span> <small style="color: #9ca3af;">(Raw: {})</small></p>'
            '</div>'
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
        """Enhanced items breakdown"""
        items = obj.items_list
        quantities = obj.quantities_list
        
        if not items:
            return format_html('<p style="color: #9ca3af; font-style: italic;">No items found</p>')
        
        html = '<div style="background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%); padding: 20px; border-radius: 16px; border-left: 6px solid #10b981; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">'
        html += '<h4 style="margin: 0 0 16px 0; color: #1f2937; font-size: 1.25rem; font-weight: 700; display: flex; align-items: center; gap: 8px;"><span style="background: #10b981; color: white; padding: 8px; border-radius: 8px;">📦</span>Items Breakdown</h4>'
        
        for i, item in enumerate(items):
            qty = quantities[i] if i < len(quantities) else "1"
            html += f'<p style="margin: 8px 0; padding: 8px 12px; background: white; border-radius: 8px; border-left: 3px solid #10b981;">• <strong style="color: #1f2937;">{item}</strong> <span style="background: #e5e7eb; color: #374151; padding: 2px 6px; border-radius: 4px; font-size: 0.875rem; font-weight: 600;">Qty: {qty}</span></p>'
        
        html += f'<hr style="margin: 16px 0; border: none; height: 1px; background: linear-gradient(90deg, transparent, #d1d5db, transparent);"><p style="margin: 0; font-weight: 700; color: #1f2937; text-align: center; background: white; padding: 8px; border-radius: 8px;">Total Items: {len(items)}</p>'
        html += '</div>'
        
        return format_html(html)
    items_parsed_display.short_description = "Items Breakdown"
    
    # =============================================================================
    # 🔧 ENHANCED CUSTOM ACTIONS (keeping original functionality)
    # =============================================================================
    
    def export_orders_csv(self, request, queryset):
        """Enhanced export with better feedback"""
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
        
        self.message_user(request, f'✅ Successfully exported {queryset.count()} orders to CSV file.')
        return response
    
    export_orders_csv.short_description = "📊 Export selected orders to CSV"

# =============================================================================
# 📞 ENHANCED CONTACT ADMIN
# =============================================================================

@admin.register(Contact)
class ContactAdmin(ModernAdminMixin, admin.ModelAdmin):
    """Enhanced Contact Admin with Modern UI"""
    
    list_display = ['name', 'email', 'phone', 'is_read', 'created_at']
    list_filter = ['is_read', 'created_at']
    search_fields = ['name', 'email']
    list_editable = ['is_read']
    
    def changelist_view(self, request, extra_context=None):
        extra_context = extra_context or {}
        extra_context['custom_css'] = mark_safe(self.modern_css)
        return super().changelist_view(request, extra_context)

# =============================================================================
# 🎨 ENHANCED ADMIN SITE CUSTOMIZATION
# =============================================================================

admin.site.site_header = "🛍️ E-commerce Store Administration"
admin.site.site_title = "Store Admin"
admin.site.index_title = "Welcome to Store Management Dashboard"

# Override admin index template context
def admin_index_context(request):
    return {
        'custom_css': mark_safe(ModernAdminMixin().modern_css)
    }

# Monkey patch to inject CSS everywhere
original_each_context = admin.site.each_context

def enhanced_each_context(request):
    context = original_each_context(request)
    context['custom_css'] = mark_safe(ModernAdminMixin().modern_css)
    return context

admin.site.each_context = enhanced_each_context