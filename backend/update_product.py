import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'api.settings')
django.setup()

from products.models import Category, Product

print("🔄 Updating database - preserving existing data...")

print("📂 Creating/updating categories...")

# Create or update categories
categories_data = [
    {"name": "Electronics", "description": "Smartphones, laptops, tablets, and electronic gadgets"},
    {"name": "Fashion", "description": "Clothing, shoes, accessories for men and women"},
    {"name": "Books", "description": "Educational books, novels, magazines"},
    {"name": "Home & Living", "description": "Furniture, home decor, kitchen appliances"},
    {"name": "Sports & Outdoor", "description": "Sports equipment, outdoor gear, fitness accessories"},
    {"name": "Beauty & Health", "description": "Skincare, makeup, health supplements"},
    {"name": "Food & Beverages", "description": "Snacks, beverages, instant food"},
    {"name": "Automotive", "description": "Car accessories, motorcycle parts, tools"}
]

categories = {}
for cat_data in categories_data:
    category, created = Category.objects.update_or_create(
        name=cat_data["name"], 
        defaults={"description": cat_data["description"]}
    )
    categories[cat_data["name"]] = category
    if created:
        print(f"✅ Created: {category.name}")
    else:
        print(f"🔄 Updated: {category.name}")

print("\n📱 Creating/updating products...")

# Comprehensive product data
products_data = [
    # Electronics
    {
        "name": "iPhone 15 Pro Max",
        "description": "Latest iPhone with titanium design, A17 Pro chip, and 48MP camera system",
        "price": 22000000,
        "category": categories["Electronics"],
        "image": "https://via.placeholder.com/400x400/1e3a8a/white?text=iPhone+15+Pro",
        "stock": 25,
        "featured": True,
        "is_active": True
    },
    {
        "name": "Samsung Galaxy S24 Ultra",
        "description": "AI-powered smartphone with S Pen, 200MP camera, and Galaxy AI features",
        "price": 18000000,
        "category": categories["Electronics"],
        "image": "https://via.placeholder.com/400x400/2563eb/white?text=Galaxy+S24",
        "stock": 30,
        "featured": True,
        "is_active": True
    },
    {
        "name": "MacBook Air M3",
        "description": "Ultra-thin laptop with M3 chip, 13-inch Liquid Retina display, all-day battery",
        "price": 20000000,
        "category": categories["Electronics"],
        "image": "https://via.placeholder.com/400x400/6b7280/white?text=MacBook+Air",
        "stock": 15,
        "featured": True,
        "is_active": True
    },
    {
        "name": "iPad Pro 12.9 inch",
        "description": "Professional tablet with M2 chip, Liquid Retina XDR display, Apple Pencil support",
        "price": 15000000,
        "category": categories["Electronics"],
        "image": "https://via.placeholder.com/400x400/374151/white?text=iPad+Pro",
        "stock": 20,
        "featured": False,
        "is_active": True
    },
    {
        "name": "Sony WH-1000XM5",
        "description": "Industry-leading noise canceling wireless headphones with 30-hour battery",
        "price": 4500000,
        "category": categories["Electronics"],
        "image": "https://via.placeholder.com/400x400/111827/white?text=Sony+WH1000XM5",
        "stock": 45,
        "featured": False,
        "is_active": True
    },
    {
        "name": "Apple Watch Series 9",
        "description": "Advanced smartwatch with health monitoring, GPS, and Always-On display",
        "price": 6000000,
        "category": categories["Electronics"],
        "image": "https://via.placeholder.com/400x400/1f2937/white?text=Apple+Watch",
        "stock": 35,
        "featured": True,
        "is_active": True
    },

    # Fashion
    {
        "name": "Nike Air Force 1 '07",
        "description": "Classic white leather sneakers with Nike Air cushioning and rubber outsole",
        "price": 1500000,
        "category": categories["Fashion"],
        "image": "https://via.placeholder.com/400x400/dc2626/white?text=Nike+AF1",
        "stock": 60,
        "featured": True,
        "is_active": True
    },
    {
        "name": "Adidas Ultraboost 22",
        "description": "Running shoes with BOOST midsole, Primeknit upper, and Continental rubber outsole",
        "price": 2200000,
        "category": categories["Fashion"],
        "image": "https://via.placeholder.com/400x400/059669/white?text=Ultraboost",
        "stock": 45,
        "featured": False,
        "is_active": True
    },
    {
        "name": "Uniqlo Heattech Crew Neck T-Shirt",
        "description": "Moisture-wicking, heat-retaining innerwear for ultimate comfort",
        "price": 200000,
        "category": categories["Fashion"],
        "image": "https://via.placeholder.com/400x400/7c3aed/white?text=Heattech+Tee",
        "stock": 100,
        "featured": False,
        "is_active": True
    },
    {
        "name": "Levi's 501 Original Jeans",
        "description": "Classic straight-leg jeans with button fly and signature stitching",
        "price": 1200000,
        "category": categories["Fashion"],
        "image": "https://via.placeholder.com/400x400/1e40af/white?text=Levis+501",
        "stock": 75,
        "featured": False,
        "is_active": True
    },
    {
        "name": "H&M Oversized Hoodie",
        "description": "Comfortable cotton-blend hoodie with kangaroo pocket and drawstring hood",
        "price": 400000,
        "category": categories["Fashion"],
        "image": "https://via.placeholder.com/400x400/7c2d12/white?text=HM+Hoodie",
        "stock": 80,
        "featured": False,
        "is_active": True
    },

    # Books
    {
        "name": "Clean Code by Robert Martin",
        "description": "A handbook of agile software craftsmanship for professional developers",
        "price": 500000,
        "category": categories["Books"],
        "image": "https://via.placeholder.com/400x400/15803d/white?text=Clean+Code",
        "stock": 25,
        "featured": True,
        "is_active": True
    },
    {
        "name": "Python Crash Course 3rd Edition",
        "description": "A hands-on, project-based introduction to programming in Python",
        "price": 600000,
        "category": categories["Books"],
        "image": "https://via.placeholder.com/400x400/b45309/white?text=Python+Book",
        "stock": 30,
        "featured": False,
        "is_active": True
    },
    {
        "name": "The Pragmatic Programmer",
        "description": "From journeyman to master - your journey to mastery in programming",
        "price": 550000,
        "category": categories["Books"],
        "image": "https://via.placeholder.com/400x400/991b1b/white?text=Pragmatic+Prog",
        "stock": 20,
        "featured": False,
        "is_active": True
    },

    # Home & Living
    {
        "name": "IKEA MALM Bed Frame",
        "description": "Modern wooden bed frame with clean lines and under-bed storage space",
        "price": 2500000,
        "category": categories["Home & Living"],
        "image": "https://via.placeholder.com/400x400/a3a3a3/white?text=IKEA+Bed",
        "stock": 15,
        "featured": True,
        "is_active": True
    },
    {
        "name": "Xiaomi Rice Cooker",
        "description": "Smart rice cooker with app control, multiple cooking modes, and 3L capacity",
        "price": 800000,
        "category": categories["Home & Living"],
        "image": "https://via.placeholder.com/400x400/ea580c/white?text=Rice+Cooker",
        "stock": 40,
        "featured": False,
        "is_active": True
    },

    # Sports & Outdoor
    {
        "name": "Yonex Arcsaber 11",
        "description": "Professional badminton racket with Rotational Generator System",
        "price": 3500000,
        "category": categories["Sports & Outdoor"],
        "image": "https://via.placeholder.com/400x400/dc2626/white?text=Yonex+Racket",
        "stock": 12,
        "featured": False,
        "is_active": True
    },
    {
        "name": "Decathlon Yoga Mat",
        "description": "Non-slip yoga mat with 8mm thickness for comfort and stability",
        "price": 300000,
        "category": categories["Sports & Outdoor"],
        "image": "https://via.placeholder.com/400x400/059669/white?text=Yoga+Mat",
        "stock": 50,
        "featured": False,
        "is_active": True
    },

    # Beauty & Health
    {
        "name": "Cetaphil Gentle Skin Cleanser",
        "description": "Mild, non-alkaline cleanser for sensitive and dry skin types",
        "price": 150000,
        "category": categories["Beauty & Health"],
        "image": "https://via.placeholder.com/400x400/2563eb/white?text=Cetaphil",
        "stock": 80,
        "featured": False,
        "is_active": True
    },
    {
        "name": "Vitamin D3 1000 IU Supplements",
        "description": "High-quality vitamin D3 supplements for bone and immune health",
        "price": 200000,
        "category": categories["Beauty & Health"],
        "image": "https://via.placeholder.com/400x400/7c3aed/white?text=Vitamin+D3",
        "stock": 100,
        "featured": False,
        "is_active": True
    },

    # Food & Beverages
    {
        "name": "Indomie Goreng (5 pack)",
        "description": "Indonesia's favorite instant fried noodles with rich savory flavor",
        "price": 25000,
        "category": categories["Food & Beverages"],
        "image": "https://via.placeholder.com/400x400/dc2626/white?text=Indomie",
        "stock": 200,
        "featured": True,
        "is_active": True
    },
    {
        "name": "Pocari Sweat 500ml",
        "description": "Ion supply drink that quickly replenishes water and electrolytes",
        "price": 15000,
        "category": categories["Food & Beverages"],
        "image": "https://via.placeholder.com/400x400/2563eb/white?text=Pocari+Sweat",
        "stock": 150,
        "featured": False,
        "is_active": True
    },

    # Automotive
    {
        "name": "Michelin City Pro Tire",
        "description": "High-performance motorcycle tire with excellent grip and durability",
        "price": 500000,
        "category": categories["Automotive"],
        "image": "https://via.placeholder.com/400x400/1f2937/white?text=Michelin+Tire",
        "stock": 25,
        "featured": False,
        "is_active": True
    },
    {
        "name": "Bosch Car Battery",
        "description": "Maintenance-free car battery with long lifespan and reliable performance",
        "price": 1200000,
        "category": categories["Automotive"],
        "image": "https://via.placeholder.com/400x400/059669/white?text=Bosch+Battery",
        "stock": 20,
        "featured": False,
        "is_active": True
    },

    # Additional products you can add here
    {
        "name": "AirPods Pro 2nd Gen",
        "description": "Active noise cancelling earbuds with personalized spatial audio",
        "price": 3500000,
        "category": categories["Electronics"],
        "image": "https://via.placeholder.com/400x400/6b7280/white?text=AirPods+Pro",
        "stock": 40,
        "featured": True,
        "is_active": True
    },
    {
        "name": "Converse Chuck Taylor",
        "description": "Classic canvas sneakers, timeless design for everyday wear",
        "price": 800000,
        "category": categories["Fashion"],
        "image": "https://via.placeholder.com/400x400/7c2d12/white?text=Converse",
        "stock": 55,
        "featured": False,
        "is_active": True
    }
]

# Create or update all products
created_count = 0
updated_count = 0

for product_data in products_data:
    product, created = Product.objects.update_or_create(
        name=product_data["name"],
        defaults=product_data
    )
    
    if created:
        created_count += 1
        print(f"✅ Created: {product.name} - Rp {product.price:,}")
    else:
        updated_count += 1
        print(f"🔄 Updated: {product.name} - Rp {product.price:,}")

print(f"\n🎉 Database update completed!")
print(f"📂 Total categories: {Category.objects.count()}")
print(f"📦 Total products: {Product.objects.count()}")
print(f"✅ Products created: {created_count}")
print(f"🔄 Products updated: {updated_count}")
print(f"⭐ Featured products: {Product.objects.filter(featured=True).count()}")

# Show summary by category
print(f"\n📊 Products by category:")
for category in Category.objects.all():
    count = Product.objects.filter(category=category).count()
    print(f"   {category.name}: {count} products")

print(f"\n✅ Database ready! Existing data preserved.")
print(f"🔗 Test at: http://127.0.0.1:8000/api/products/")