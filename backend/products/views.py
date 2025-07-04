from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from .models import Product, Category, Cart, Favorite, SupabaseProduct, UserOrder, OrderItemSupabase, Order, OrderItem
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
            "PUT /api/products/cart/update-quantity/ - Update cart quantity",  # New
            "DELETE /api/products/cart/clear/ - Clear cart",  # New
            "DELETE /api/products/cart/remove/{id}/ - Remove from cart",
            "GET /api/products/favorites/ - Get favorites",
            "POST /api/products/favorites/add/ - Add to favorites",
            "DELETE /api/products/favorites/remove/{id}/ - Remove from favorites",
            "GET /api/products/orders/ - Get all orders",
            "POST /api/products/orders/create/ - Create order from cart",  # New
            "GET /api/products/orders/{id}/ - Get order detail",  # New
            "PUT /api/products/orders/{id}/status/ - Update order status",  # New
            "POST /api/products/orders/{id}/cancel/ - Cancel order",  # New
            "GET /api/products/category/{category}/ - Get products by category",
            "GET /api/products/{id}/ - Get product detail"
        ]
    }
    return JsonResponse(docs)
# Tambahkan di akhir products/views.py

@csrf_exempt
@require_http_methods(["POST"])
def create_order(request):
    try:
        data = json.loads(request.body)
        
        # Customer info
        first_name = data.get('first_name')
        last_name = data.get('last_name')
        email = data.get('email')
        phone = data.get('phone')
        address = data.get('address')
        city = data.get('city')
        province = data.get('province')
        zip_code = data.get('zip_code')
        notes = data.get('notes', '')
        payment_method = data.get('payment_method', 'cash_on_delivery')
        
        # Validation
        required_fields = [first_name, last_name, email, phone, address, city, province, zip_code]
        if not all(required_fields):
            return JsonResponse({"success": False, "message": "All customer info fields are required"}, status=400)
        
        # Get cart items
        cart_items = Cart.objects.all()
        if not cart_items:
            return JsonResponse({"success": False, "message": "Cart is empty"}, status=400)
        
        # Calculate total
        total_amount = 0
        order_items_data = []
        
        for cart_item in cart_items:
            subtotal = cart_item.product.price * cart_item.quantity
            total_amount += subtotal
            
            order_items_data.append({
                'product': cart_item.product,
                'product_name': cart_item.product.name,
                'price': cart_item.product.price,
                'quantity': cart_item.quantity,
                'subtotal': subtotal
            })
        
        # Create order
        order = Order.objects.create(
            first_name=first_name,
            last_name=last_name,
            email=email,
            phone=phone,
            address=address,
            city=city,
            province=province,
            zip_code=zip_code,
            notes=notes,
            payment_method=payment_method,
            total_amount=total_amount,
            status='pending'
        )
        
        # Create order items
        for item_data in order_items_data:
            OrderItem.objects.create(
                order=order,
                product=item_data['product'],
                product_name=item_data['product_name'],
                price=item_data['price'],
                quantity=item_data['quantity'],
                subtotal=item_data['subtotal']
            )
        
        # Clear cart after successful order
        cart_items.delete()
        
        return JsonResponse({
            "success": True,
            "message": "Order created successfully",
            "order": {
                "id": order.id,
                "total_amount": float(order.total_amount),
                "status": order.status,
                "customer": f"{order.first_name} {order.last_name}"
            }
        })
        
    except Exception as e:
        return JsonResponse({"success": False, "message": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["PUT"])
def update_order_status(request, order_id):
    try:
        data = json.loads(request.body)
        new_status = data.get('status')
        
        if new_status not in ['pending', 'processing', 'shipped', 'delivered', 'cancelled']:
            return JsonResponse({"success": False, "message": "Invalid status"}, status=400)
        
        order = Order.objects.get(id=order_id)
        order.status = new_status
        order.save()
        
        return JsonResponse({
            "success": True,
            "message": f"Order status updated to {new_status}",
            "order": {
                "id": order.id,
                "status": order.status,
                "updated_at": order.updated_at
            }
        })
        
    except Order.DoesNotExist:
        return JsonResponse({"success": False, "message": "Order not found"}, status=404)
    except Exception as e:
        return JsonResponse({"success": False, "message": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["PUT"])
def update_cart_quantity(request):
    try:
        data = json.loads(request.body)
        cart_id = data.get('cart_id')
        quantity = data.get('quantity')
        
        if not cart_id or not quantity or quantity < 1:
            return JsonResponse({"success": False, "message": "Invalid cart_id or quantity"}, status=400)
        
        cart_item = Cart.objects.get(id=cart_id)
        cart_item.quantity = quantity
        cart_item.save()
        
        return JsonResponse({
            "success": True,
            "message": "Cart quantity updated",
            "cart_item": {
                "id": cart_item.id,
                "product_name": cart_item.product.name,
                "quantity": cart_item.quantity,
                "total": float(cart_item.product.price * cart_item.quantity)
            }
        })
        
    except Cart.DoesNotExist:
        return JsonResponse({"success": False, "message": "Cart item not found"}, status=404)
    except Exception as e:
        return JsonResponse({"success": False, "message": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["DELETE"])
def clear_cart(request):
    try:
        Cart.objects.all().delete()
        return JsonResponse({"success": True, "message": "Cart cleared successfully"})
    except Exception as e:
        return JsonResponse({"success": False, "message": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def cancel_order(request, order_id):
    try:
        order = Order.objects.get(id=order_id)
        
        if order.status in ['shipped', 'delivered']:
            return JsonResponse({"success": False, "message": "Cannot cancel shipped or delivered orders"}, status=400)
        
        order.status = 'cancelled'
        order.save()
        
        return JsonResponse({
            "success": True,
            "message": "Order cancelled successfully",
            "order": {
                "id": order.id,
                "status": order.status
            }
        })
        
    except Order.DoesNotExist:
        return JsonResponse({"success": False, "message": "Order not found"}, status=404)
    except Exception as e:
        return JsonResponse({"success": False, "message": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["GET"])
def get_order_detail(request, order_id):
    try:
        order = Order.objects.get(id=order_id)
        order_items = OrderItem.objects.filter(order=order)
        
        items = []
        for item in order_items:
            items.append({
                "product_name": item.product_name,
                "price": float(item.price),
                "quantity": item.quantity,
                "subtotal": float(item.subtotal)
            })
        
        return JsonResponse({
            "order": {
                "id": order.id,
                "customer": f"{order.first_name} {order.last_name}",
                "email": order.email,
                "phone": order.phone,
                "address": f"{order.address}, {order.city}, {order.province} {order.zip_code}",
                "total_amount": float(order.total_amount),
                "status": order.status,
                "payment_method": order.payment_method,
                "notes": order.notes,
                "created_at": order.created_at,
                "items": items
            }
        })
        
    except Order.DoesNotExist:
        return JsonResponse({"error": "Order not found"}, status=404)