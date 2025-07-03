from rest_framework.decorators import api_view
from rest_framework.response import Response
from supabase import create_client, Client
import os
from dotenv import load_dotenv

# Load .env file
load_dotenv()

# Hardcode credentials untuk testing
SUPABASE_URL = "https://mccdwczueketpqlbobyw.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jY2R3Y3p1ZWtldHBxbGJvYnl3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTI5MTAxNywiZXhwIjoyMDY2ODY3MDE3fQ.18sMUhVuJmFBGGstcM-vGg3PwBwwhFNszQf8RkPTR_I"

print("✅ Initializing Supabase client...")

# Initialize Supabase client
try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    print("✅ Supabase client initialized successfully")
except Exception as e:
    print(f"❌ Supabase init failed: {e}")
    supabase = None

# Products endpoints
@api_view(['GET'])
def get_products(request):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
    
    try:
        response = supabase.table('products').select('*').execute()
        return Response({
            'success': True,
            'data': response.data,
            'count': len(response.data)
        })
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

@api_view(['GET'])
def get_product_detail(request, product_id):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
        
    try:
        response = supabase.table('products').select('*').eq('id', product_id).execute()
        if response.data:
            return Response({
                'success': True,
                'data': response.data[0]
            })
        else:
            return Response({
                'success': False,
                'error': 'Product not found'
            }, status=404)
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

@api_view(['GET'])
def search_products(request):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
    
    query = request.GET.get('q', '')
    if not query:
        return Response({
            'success': False,
            'error': 'Search query is required'
        }, status=400)
    
    try:
        response = supabase.table('products').select('*').ilike('name', f'%{query}%').execute()
        return Response({
            'success': True,
            'data': response.data,
            'count': len(response.data),
            'query': query
        })
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

@api_view(['GET'])
def get_categories(request):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
    
    try:
        response = supabase.table('products').select('category').execute()
        categories = list(set([item['category'] for item in response.data if item['category']]))
        return Response({
            'success': True,
            'data': categories,
            'count': len(categories)
        })
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

# Cart endpoints
@api_view(['GET'])
def get_cart(request):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
    
    try:
        response = supabase.table('cart').select('*, products(*)').execute()
        return Response({
            'success': True,
            'data': response.data,
            'count': len(response.data)
        })
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

@api_view(['POST'])
def add_to_cart(request):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
    
    try:
        data = request.data
        if not data.get('product_id'):
            return Response({
                'success': False,
                'error': 'product_id is required'
            }, status=400)
        
        response = supabase.table('cart').insert({
            'product_id': data['product_id'],
            'quantity': data.get('quantity', 1)
        }).execute()
        
        return Response({
            'success': True,
            'data': response.data,
            'message': 'Product added to cart'
        })
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

@api_view(['DELETE'])
def remove_from_cart(request, cart_id):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
    
    try:
        response = supabase.table('cart').delete().eq('id', cart_id).execute()
        return Response({
            'success': True,
            'message': 'Item removed from cart'
        })
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

# Favorites endpoints
@api_view(['GET'])
def get_favorites(request):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
    
    try:
        response = supabase.table('favorites').select('*, products(*)').execute()
        return Response({
            'success': True,
            'data': response.data,
            'count': len(response.data)
        })
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

@api_view(['POST'])
def add_to_favorites(request):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
    
    try:
        data = request.data
        if not data.get('product_id'):
            return Response({
                'success': False,
                'error': 'product_id is required'
            }, status=400)
        
        response = supabase.table('favorites').insert({
            'product_id': data['product_id']
        }).execute()
        
        return Response({
            'success': True,
            'data': response.data,
            'message': 'Product added to favorites'
        })
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

@api_view(['DELETE'])
def remove_from_favorites(request, favorite_id):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
    
    try:
        response = supabase.table('favorites').delete().eq('id', favorite_id).execute()
        return Response({
            'success': True,
            'message': 'Item removed from favorites'
        })
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

# Products by category
@api_view(['GET'])
def get_products_by_category(request, category):
    if not supabase:
        return Response({
            'success': False,
            'error': 'Supabase not initialized'
        }, status=500)
    
    try:
        response = supabase.table('products').select('*').eq('category', category).execute()
        return Response({
            'success': True,
            'data': response.data,
            'count': len(response.data),
            'category': category
        })
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=500)

# API Documentation
@api_view(['GET'])
def api_docs(request):
    return Response({
        'message': 'Toko Online API Documentation',
        'version': '1.0',
        'base_url': 'http://127.0.0.1:8000',
        'endpoints': {
            'products': {
                'url': '/api/products/',
                'method': 'GET',
                'description': 'Get all products'
            },
            'product_detail': {
                'url': '/api/products/{id}/',
                'method': 'GET',
                'description': 'Get product by ID (UUID)'
            },
            'search': {
                'url': '/api/products/search/?q=query',
                'method': 'GET',
                'description': 'Search products by name'
            },
            'categories': {
                'url': '/api/products/categories/',
                'method': 'GET',
                'description': 'Get all product categories'
            },
            'products_by_category': {
                'url': '/api/products/category/{category}/',
                'method': 'GET',
                'description': 'Get products by category'
            },
            'cart': {
                'url': '/api/products/cart/',
                'method': 'GET',
                'description': 'Get cart items'
            },
            'add_to_cart': {
                'url': '/api/products/cart/add/',
                'method': 'POST',
                'description': 'Add product to cart',
                'body': {
                    'product_id': 'string (UUID)',
                    'quantity': 'integer (optional, default: 1)'
                }
            },
            'remove_from_cart': {
                'url': '/api/products/cart/remove/{id}/',
                'method': 'DELETE',
                'description': 'Remove item from cart'
            },
            'favorites': {
                'url': '/api/products/favorites/',
                'method': 'GET',
                'description': 'Get favorite items'
            },
            'add_to_favorites': {
                'url': '/api/products/favorites/add/',
                'method': 'POST',
                'description': 'Add product to favorites',
                'body': {
                    'product_id': 'string (UUID)'
                }
            },
            'remove_from_favorites': {
                'url': '/api/products/favorites/remove/{id}/',
                'method': 'DELETE',
                'description': 'Remove item from favorites'
            }
        }
    })