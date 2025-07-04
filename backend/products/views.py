from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from .models import Product, Category, Cart, Favorite, Order, OrderItem
import json

@csrf_exempt
@require_http_methods(["GET"])
def get_products(request):
    # HANYA Django products - clean dan simple
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
    
    return JsonResponse({"products": data, "total": len(data)})

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
        # HANYA dari Django categories
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
        
        return JsonResponse({"products": data, "category": category, "total": len(data)})
    except Category.DoesNotExist:
        return JsonResponse({"error": "Category not found"}, status=404)

@csrf_exempt
@require_http_methods(["GET"])
def get_product_detail(request, product_id):
    try:
        # HANYA dari Django products
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
        
        return JsonResponse({"product": data})
    except Product.DoesNotExist:
        return JsonResponse({"error": "Product not found"}, status=404)

@csrf_exempt
@require_http_methods(["GET"])
def search_products(request):
    query = request.GET.get('q', '')
    
    # HANYA search di Django products
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
    
    return JsonResponse({"products": data, "query": query, "total": len(data)})

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
    return JsonResponse({"cart": data, "total_price": total_price, "items_count": len(data)})

@csrf_exempt
@require_http_methods(["POST"])
def add_to_cart(request):
    try:
        data = json.loads(request.body)
        product_id = data.get('product_id')
        quantity = data.get('quantity', 1)
        
        # Validation
        if not product_id:
            return JsonResponse({"success": False, "message": "Product ID is required"}, status=400)
        
        if quantity < 1:
            return JsonResponse({"success": False, "message": "Quantity must be at least 1"}, status=400)
        
        product = Product.objects.get(id=product_id)
        
        # Check stock
        if product.stock < quantity:
            return JsonResponse({"success": False, "message": "Insufficient stock"}, status=400)
        
        cart_item, created = Cart.objects.get_or_create(
            product=product,
            defaults={'quantity': quantity}
        )
        
        if not created:
            cart_item.quantity += quantity
            cart_item.save()
            
        return JsonResponse({
            "success": True, 
            "message": "Added to cart",
            "cart_item": {
                "id": cart_item.id,
                "product_name": cart_item.product.name,
                "quantity": cart_item.quantity
            }
        })
    except Product.DoesNotExist:
        return JsonResponse({"success": False, "message": "Product not found"}, status=404)
    except Exception as e:
        return JsonResponse({"success": False, "message": str(e)}, status=400)

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
        
        # Check stock
        if cart_item.product.stock < quantity:
            return JsonResponse({"success": False, "message": "Insufficient stock"}, status=400)
        
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
        deleted_count = Cart.objects.all().count()
        Cart.objects.all().delete()
        return JsonResponse({
            "success": True, 
            "message": f"Cart cleared successfully. {deleted_count} items removed."
        })
    except Exception as e:
        return JsonResponse({"success": False, "message": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["DELETE"])
def remove_from_cart(request, cart_id):
    try:
        cart_item = Cart.objects.get(id=cart_id)
        product_name = cart_item.product.name
        cart_item.delete()
        return JsonResponse({
            "success": True, 
            "message": f"Removed {product_name} from cart"
        })
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
    return JsonResponse({"favorites": data, "total": len(data)})

@csrf_exempt
@require_http_methods(["POST"])
def add_to_favorites(request):
    try:
        data = json.loads(request.body)
        product_id = data.get('product_id')
        
        if not product_id:
            return JsonResponse({"success": False, "message": "Product ID is required"}, status=400)
        
        product = Product.objects.get(id=product_id)
        favorite, created = Favorite.objects.get_or_create(product=product)
        
        if created:
            return JsonResponse({
                "success": True, 
                "message": f"Added {product.name} to favorites"
            })
        else:
            return JsonResponse({
                "success": False, 
                "message": f"{product.name} is already in favorites"
            })
    except Product.DoesNotExist:
        return JsonResponse({"success": False, "message": "Product not found"}, status=404)

@csrf_exempt
@require_http_methods(["DELETE"])
def remove_from_favorites(request, favorite_id):
    try:
        favorite = Favorite.objects.get(id=favorite_id)
        product_name = favorite.product.name
        favorite.delete()
        return JsonResponse({
            "success": True, 
            "message": f"Removed {product_name} from favorites"
        })
    except Favorite.DoesNotExist:
        return JsonResponse({"success": False, "message": "Favorite not found"}, status=404)

@csrf_exempt
@require_http_methods(["GET"])
def get_orders(request):
    # HANYA Django managed orders
    orders = Order.objects.all().order_by('-created_at')
    data = []
    for order in orders:
        order_items = OrderItem.objects.filter(order=order)
        items = []
        for item in order_items:
            items.append({
                "product_name": item.product_name,
                "quantity": item.quantity,
                "price": float(item.price),
                "subtotal": float(item.subtotal)
            })
        
        data.append({
            "id": order.id,
            "customer": f"{order.first_name} {order.last_name}",
            "email": order.email,
            "total_amount": float(order.total_amount),
            "status": order.status,
            "created_at": order.created_at,
            "items": items
        })
    
    return JsonResponse({"orders": data, "total": len(data)})

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
            return JsonResponse({
                "success": False, 
                "message": "All customer info fields are required"
            }, status=400)
        
        # Get cart items
        cart_items = Cart.objects.all()
        if not cart_items:
            return JsonResponse({
                "success": False, 
                "message": "Cart is empty"
            }, status=400)
        
        # Calculate total and validate stock
        total_amount = 0
        order_items_data = []
        
        for cart_item in cart_items:
            # Check stock availability
            if cart_item.product.stock < cart_item.quantity:
                return JsonResponse({
                    "success": False, 
                    "message": f"Insufficient stock for {cart_item.product.name}"
                }, status=400)
            
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
        
        # Create order items and update stock
        for item_data in order_items_data:
            OrderItem.objects.create(
                order=order,
                product=item_data['product'],
                product_name=item_data['product_name'],
                price=item_data['price'],
                quantity=item_data['quantity'],
                subtotal=item_data['subtotal']
            )
            
            # Update product stock
            product = item_data['product']
            product.stock -= item_data['quantity']
            product.save()
        
        # Clear cart after successful order
        cart_items.delete()
        
        return JsonResponse({
            "success": True,
            "message": "Order created successfully",
            "order": {
                "id": order.id,
                "total_amount": float(order.total_amount),
                "status": order.status,
                "customer": f"{order.first_name} {order.last_name}",
                "items_count": len(order_items_data)
            }
        })
        
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
                "items": items,
                "items_count": len(items)
            }
        })
        
    except Order.DoesNotExist:
        return JsonResponse({"error": "Order not found"}, status=404)

@csrf_exempt
@require_http_methods(["PUT"])
def update_order_status(request, order_id):
    try:
        data = json.loads(request.body)
        new_status = data.get('status')
        
        valid_statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
        if new_status not in valid_statuses:
            return JsonResponse({
                "success": False, 
                "message": f"Invalid status. Valid options: {', '.join(valid_statuses)}"
            }, status=400)
        
        order = Order.objects.get(id=order_id)
        old_status = order.status
        order.status = new_status
        order.save()
        
        return JsonResponse({
            "success": True,
            "message": f"Order status updated from {old_status} to {new_status}",
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
@require_http_methods(["POST"])
def cancel_order(request, order_id):
    try:
        order = Order.objects.get(id=order_id)
        
        if order.status in ['shipped', 'delivered']:
            return JsonResponse({
                "success": False, 
                "message": "Cannot cancel shipped or delivered orders"
            }, status=400)
        
        # Restore product stock if cancelling
        if order.status != 'cancelled':
            order_items = OrderItem.objects.filter(order=order)
            for item in order_items:
                product = item.product
                product.stock += item.quantity
                product.save()
        
        order.status = 'cancelled'
        order.save()
        
        return JsonResponse({
            "success": True,
            "message": "Order cancelled successfully. Product stock restored.",
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
def api_docs(request):
    docs = {
        "message": "Django E-commerce API - Simplified Version",
        "version": "1.0",
        "data_source": "Django PostgreSQL (Supabase hosted)",
        "endpoints": [
            "GET /api/products/ - Get all active products",
            "GET /api/products/search/?q=query - Search products by name",
            "GET /api/products/categories/ - Get all categories",
            "GET /api/products/category/{category}/ - Get products by category",
            "GET /api/products/{id}/ - Get product detail",
            "GET /api/products/cart/ - Get cart items",
            "POST /api/products/cart/add/ - Add product to cart",
            "PUT /api/products/cart/update-quantity/ - Update cart item quantity",
            "DELETE /api/products/cart/clear/ - Clear entire cart",
            "DELETE /api/products/cart/remove/{id}/ - Remove item from cart",
            "GET /api/products/favorites/ - Get favorite products",
            "POST /api/products/favorites/add/ - Add product to favorites",
            "DELETE /api/products/favorites/remove/{id}/ - Remove from favorites",
            "GET /api/products/orders/ - Get all orders",
            "POST /api/products/orders/create/ - Create order from cart",
            "GET /api/products/orders/{id}/ - Get order detail",
            "PUT /api/products/orders/{id}/status/ - Update order status",
            "POST /api/products/orders/{id}/cancel/ - Cancel order",
            "GET /api/products/docs/ - This documentation"
        ],
        "features": [
            "Stock management (auto-update on orders)",
            "Cart management with validation",
            "Order tracking with status updates",
            "Product search and filtering",
            "Favorites system",
            "Comprehensive error handling"
        ]
    }
    return JsonResponse(docs)