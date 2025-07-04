from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from .models import Product, Category, Cart, Favorite, SupabaseProduct, UserOrder, OrderItem
import json

@csrf_exempt
@require_http_methods(["GET"])
def get_products(request):
    # Gunakan products Django (products_product table)
    products = Product.objects.filter(is_active=True)
    data = []
    for product in products:
        data.append({
            "id": str(product.id),
            "name": product.name,
            "price": float(product.price),
            "category": product.category.name,
            "image": product.image,
            "stock": product.stock,
            "description": product.description,
            "featured": product.featured
        })
    
    # Jika tidak ada products di Django table, ambil dari Supabase table
    if not data:
        supabase_products = SupabaseProduct.objects.filter(is_active=True)
        for product in supabase_products:
            data.append({
                "id": str(product.id),
                "name": product.name,
                "price": float(product.price),
                "category": product.category,
                "image": product.image_url,
                "stock": product.stock,
                "description": product.description
            })
    
    return JsonResponse({"products": data})

@csrf_exempt
@require_http_methods(["GET"])
def get_categories(request):
    categories = Category.objects.all()
    data = [{"id": cat.id, "name": cat.name, "description": cat.description} for cat in categories]
    return JsonResponse({"categories": data})

@csrf_exempt
@require_http_methods(["GET"])
def get_products_by_category(request, category):
    try:
        # Coba dari Django categories
        cat = Category.objects.get(name=category)
        products = Product.objects.filter(category=cat, is_active=True)
        data = []
        for product in products:
            data.append({
                "id": str(product.id),
                "name": product.name,
                "price": float(product.price),
                "category": product.category.name,
                "image": product.image,
                "stock": product.stock
            })
        
        # Jika tidak ada, coba dari Supabase products
        if not data:
            supabase_products = SupabaseProduct.objects.filter(category=category, is_active=True)
            for product in supabase_products:
                data.append({
                    "id": str(product.id),
                    "name": product.name,
                    "price": float(product.price),
                    "category": product.category,
                    "image": product.image_url,
                    "stock": product.stock
                })
        
        return JsonResponse({"products": data, "category": category})
    except Category.DoesNotExist:
        return JsonResponse({"error": "Category not found"}, status=404)

@csrf_exempt
@require_http_methods(["GET"])
def get_product_detail(request, product_id):
    try:
        # Coba dari Django products dulu
        try:
            product = Product.objects.get(id=product_id)
            data = {
                "id": str(product.id),
                "name": product.name,
                "price": float(product.price),
                "description": product.description,
                "category": product.category.name,
                "image": product.image,
                "stock": product.stock,
                "featured": product.featured
            }
        except Product.DoesNotExist:
            # Jika tidak ada, coba dari Supabase products
            product = SupabaseProduct.objects.get(id=product_id)
            data = {
                "id": str(product.id),
                "name": product.name,
                "price": float(product.price),
                "description": product.description,
                "category": product.category,
                "image": product.image_url,
                "stock": product.stock
            }
        
        return JsonResponse({"product": data})
    except (Product.DoesNotExist, SupabaseProduct.DoesNotExist):
        return JsonResponse({"error": "Product not found"}, status=404)

@csrf_exempt
@require_http_methods(["GET"])
def search_products(request):
    query = request.GET.get('q', '')
    
    # Search di Django products
    products = Product.objects.filter(name__icontains=query, is_active=True)
    data = []
    for product in products:
        data.append({
            "id": str(product.id),
            "name": product.name,
            "price": float(product.price),
            "category": product.category.name,
            "image": product.image
        })
    
    # Jika tidak ada, search di Supabase products
    if not data:
        supabase_products = SupabaseProduct.objects.filter(name__icontains=query, is_active=True)
        for product in supabase_products:
            data.append({
                "id": str(product.id),
                "name": product.name,
                "price": float(product.price),
                "category": product.category,
                "image": product.image_url
            })
    
    return JsonResponse({"products": data, "query": query})

@csrf_exempt
@require_http_methods(["GET"])
def get_cart(request):
    cart_items = Cart.objects.all()
    data = []
    total_price = 0
    for item in cart_items:
        item_total = float(item.product.price) * item.quantity
        total_price += item_total
        data.append({
            "id": str(item.id),
            "product": {
                "id": str(item.product.id),
                "name": item.product.name,
                "price": float(item.product.price),
                "image": item.product.image
            },
            "quantity": item.quantity,
            "total": item_total
        })
    return JsonResponse({"cart": data, "total_price": total_price})

@csrf_exempt
@require_http_methods(["POST"])
def add_to_cart(request):
    try:
        data = json.loads(request.body)
        product_id = data.get('product_id')
        quantity = data.get('quantity', 1)
        
        product = Product.objects.get(id=product_id)
        cart_item, created = Cart.objects.get_or_create(
            product=product,
            defaults={'quantity': quantity}
        )
        
        if not created:
            cart_item.quantity += quantity
            cart_item.save()
            
        return JsonResponse({"success": True, "message": "Added to cart"})
    except Product.DoesNotExist:
        return JsonResponse({"success": False, "message": "Product not found"}, status=404)
    except Exception as e:
        return JsonResponse({"success": False, "message": str(e)}, status=400)

@csrf_exempt
@require_http_methods(["DELETE"])
def remove_from_cart(request, cart_id):
    try:
        cart_item = Cart.objects.get(id=cart_id)
        cart_item.delete()
        return JsonResponse({"success": True, "message": "Removed from cart"})
    except Cart.DoesNotExist:
        return JsonResponse({"success": False, "message": "Cart item not found"}, status=404)

@csrf_exempt
@require_http_methods(["GET"])
def get_favorites(request):
    favorites = Favorite.objects.all()
    data = []
    for fav in favorites:
        data.append({
            "id": str(fav.id),
            "product": {
                "id": str(fav.product.id),
                "name": fav.product.name,
                "price": float(fav.product.price),
                "image": fav.product.image
            }
        })
    return JsonResponse({"favorites": data})

@csrf_exempt
@require_http_methods(["POST"])
def add_to_favorites(request):
    try:
        data = json.loads(request.body)
        product_id = data.get('product_id')
        
        product = Product.objects.get(id=product_id)
        favorite, created = Favorite.objects.get_or_create(product=product)
        
        if created:
            return JsonResponse({"success": True, "message": "Added to favorites"})
        else:
            return JsonResponse({"success": False, "message": "Already in favorites"})
    except Product.DoesNotExist:
        return JsonResponse({"success": False, "message": "Product not found"}, status=404)

@csrf_exempt
@require_http_methods(["DELETE"])
def remove_from_favorites(request, favorite_id):
    try:
        favorite = Favorite.objects.get(id=favorite_id)
        favorite.delete()
        return JsonResponse({"success": True, "message": "Removed from favorites"})
    except Favorite.DoesNotExist:
        return JsonResponse({"success": False, "message": "Favorite not found"}, status=404)

@csrf_exempt
@require_http_methods(["GET"])
def get_orders(request):
    orders = UserOrder.objects.all().order_by('-created_at')
    data = []
    for order in orders:
        order_items = OrderItem.objects.filter(order=order)
        items = []
        for item in order_items:
            items.append({
                "product_name": item.product_name,
                "quantity": item.quantity,
                "price": item.price,
                "subtotal": item.subtotal
            })
        
        data.append({
            "id": str(order.id),
            "customer": f"{order.first_name} {order.last_name}",
            "email": order.email,
            "total_amount": order.total_amount,
            "status": order.status,
            "created_at": order.created_at,
            "items": items
        })
    
    return JsonResponse({"orders": data})

@csrf_exempt
@require_http_methods(["GET"])
def api_docs(request):
    docs = {
        "endpoints": [
            "GET /api/products/ - Get all products",
            "GET /api/products/search/?q=query - Search products",
            "GET /api/products/categories/ - Get categories",
            "GET /api/products/cart/ - Get cart items",
            "POST /api/products/cart/add/ - Add to cart",
            "DELETE /api/products/cart/remove/{id}/ - Remove from cart",
            "GET /api/products/favorites/ - Get favorites",
            "POST /api/products/favorites/add/ - Add to favorites",
            "DELETE /api/products/favorites/remove/{id}/ - Remove from favorites",
            "GET /api/products/category/{category}/ - Get products by category",
            "GET /api/products/{id}/ - Get product detail",
            "GET /api/products/orders/ - Get all orders"
        ]
    }
    return JsonResponse(docs)