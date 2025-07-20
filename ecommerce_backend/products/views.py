from rest_framework import status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.pagination import PageNumberPagination
from django.shortcuts import get_object_or_404
from django.db.models import Q
from .models import Product, Category
from .serializers import (
    ProductListSerializer, ProductDetailSerializer, 
    ProductCreateUpdateSerializer, CategorySerializer
)
from .supabase_client import supabase_client

class ProductPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100

@api_view(['GET', 'POST'])
@permission_classes([permissions.IsAuthenticated])
def product_list_create(request):
    """
    GET: List seller's products with pagination and search
    POST: Create new product (sellers only)
    """
    if request.method == 'GET':
        # Only show products for the authenticated seller
        queryset = Product.objects.filter(seller=request.user)
        
        # Search functionality
        search = request.GET.get('search', '')
        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) | 
                Q(description__icontains=search) |
                Q(brand__icontains=search)
            )
        
        # Filter by status
        status_filter = request.GET.get('status', '')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        # Filter by category
        category_id = request.GET.get('category_id', '')
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        
        # Ordering
        ordering = request.GET.get('ordering', '-created_at')
        queryset = queryset.order_by(ordering)
        
        paginator = ProductPagination()
        page = paginator.paginate_queryset(queryset, request)
        
        if page is not None:
            serializer = ProductListSerializer(page, many=True)
            return paginator.get_paginated_response(serializer.data)
        
        serializer = ProductListSerializer(queryset, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        # Only sellers can create products
        if request.user.user_type != 'seller':
            return Response(
                {'error': 'Only sellers can create products'}, 
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = ProductCreateUpdateSerializer(data=request.data)
        if serializer.is_valid():
            product = serializer.save(seller=request.user)
            response_serializer = ProductDetailSerializer(product)
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([permissions.IsAuthenticated])
def product_detail(request, product_id):
    """
    GET: Get product details
    PUT: Update product (seller only)
    DELETE: Delete product (seller only)
    """
    try:
        product = Product.objects.get(id=product_id)
    except Product.DoesNotExist:
        return Response(
            {'error': 'Product not found'}, 
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Check if user is the seller of this product (for PUT/DELETE)
    if request.method in ['PUT', 'DELETE']:
        if product.seller != request.user:
            return Response(
                {'error': 'You can only modify your own products'}, 
                status=status.HTTP_403_FORBIDDEN
            )
    
    if request.method == 'GET':
        # Increment view count for non-seller views
        if request.user != product.seller:
            product.views_count += 1
            product.save(update_fields=['views_count'])
        
        serializer = ProductDetailSerializer(product)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        serializer = ProductCreateUpdateSerializer(product, data=request.data, partial=True)
        if serializer.is_valid():
            updated_product = serializer.save()
            response_serializer = ProductDetailSerializer(updated_product)
            return Response(response_serializer.data)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        # Sync deletion with Supabase
        try:
            supabase_client.table('products').delete().eq('id', str(product.id)).execute()
        except Exception as e:
            print(f"Supabase delete error for product {product.id}: {e}")
        
        product.delete()
        return Response(
            {'message': 'Product deleted successfully'}, 
            status=status.HTTP_204_NO_CONTENT
        )

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def categories_list(request):
    """Get list of all categories"""
    categories = Category.objects.all().order_by('name')
    serializer = CategorySerializer(categories, many=True)
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def toggle_product_status(request, product_id):
    """Toggle product status between active and inactive"""
    try:
        product = Product.objects.get(id=product_id, seller=request.user)
    except Product.DoesNotExist:
        return Response(
            {'error': 'Product not found'}, 
            status=status.HTTP_404_NOT_FOUND
        )
    
    new_status = request.data.get('status')
    if new_status not in ['active', 'inactive']:
        return Response(
            {'error': 'Status must be either "active" or "inactive"'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    product.status = new_status
    product.save()
    
    # Sync with Supabase
    try:
        supabase_client.table('products').update({
            'status': new_status,
            'updated_at': product.updated_at.isoformat()
        }).eq('id', str(product.id)).execute()
    except Exception as e:
        print(f"Supabase status update error for product {product.id}: {e}")
    
    serializer = ProductDetailSerializer(product)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def seller_dashboard_stats(request):
    """Get seller dashboard statistics"""
    if request.user.user_type != 'seller':
        return Response(
            {'error': 'Only sellers can access this endpoint'}, 
            status=status.HTTP_403_FORBIDDEN
        )
    
    seller_products = Product.objects.filter(seller=request.user)
    
    stats = {
        'total_products': seller_products.count(),
        'active_products': seller_products.filter(status='active').count(),
        'inactive_products': seller_products.filter(status='inactive').count(),
        'sold_products': seller_products.filter(status='sold').count(),
        'total_views': seller_products.aggregate(total_views=models.Sum('views_count'))['total_views'] or 0,
        'out_of_stock': seller_products.filter(stock_quantity=0).count(),
    }
    
    return Response(stats)