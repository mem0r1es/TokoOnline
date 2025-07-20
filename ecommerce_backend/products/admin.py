from django.contrib import admin
from .models import Category, Product, ProductImage, ProductAttribute

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'description', 'created_at')
    search_fields = ('name', 'description')
    ordering = ('name',)

class ProductImageInline(admin.TabularInline):
    model = ProductImage
    extra = 1
    fields = ('image_url', 'alt_text', 'is_primary', 'order')

class ProductAttributeInline(admin.TabularInline):
    model = ProductAttribute
    extra = 1
    fields = ('name', 'value')

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = (
        'name', 'seller', 'price', 'category', 'condition', 
        'status', 'stock_quantity', 'views_count', 'created_at'
    )
    list_filter = ('status', 'condition', 'category', 'is_featured', 'created_at')
    search_fields = ('name', 'description', 'seller__username', 'seller__email')
    readonly_fields = ('id', 'views_count', 'created_at', 'updated_at')
    ordering = ('-created_at',)
    inlines = [ProductImageInline, ProductAttributeInline]
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('id', 'seller', 'name', 'description', 'price', 'category')
        }),
        ('Product Details', {
            'fields': ('condition', 'status', 'stock_quantity', 'brand', 'model', 'color', 'size', 'weight')
        }),
        ('Visibility & SEO', {
            'fields': ('is_featured', 'views_count')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('seller', 'category')

@admin.register(ProductImage)
class ProductImageAdmin(admin.ModelAdmin):
    list_display = ('product', 'image_url', 'is_primary', 'order', 'created_at')
    list_filter = ('is_primary', 'created_at')
    search_fields = ('product__name', 'alt_text')
    ordering = ('product', 'order')

@admin.register(ProductAttribute)
class ProductAttributeAdmin(admin.ModelAdmin):
    list_display = ('product', 'name', 'value', 'created_at')
    search_fields = ('product__name', 'name', 'value')
    ordering = ('product', 'name')