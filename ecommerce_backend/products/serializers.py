from rest_framework import serializers
from .models import Product, Category, ProductImage, ProductAttribute
from .supabase_client import supabase_client

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'description']

class ProductImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductImage
        fields = ['id', 'image_url', 'alt_text', 'is_primary', 'order']

class ProductAttributeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductAttribute
        fields = ['id', 'name', 'value']

class ProductListSerializer(serializers.ModelSerializer):
    primary_image = serializers.SerializerMethodField()
    category_name = serializers.CharField(source='category.name', read_only=True)
    seller_name = serializers.CharField(source='seller.get_full_name', read_only=True)
    
    class Meta:
        model = Product
        fields = [
            'id', 'name', 'price', 'condition', 'status', 'stock_quantity',
            'primary_image', 'category_name', 'seller_name', 'is_featured',
            'views_count', 'created_at', 'updated_at'
        ]
    
    def get_primary_image(self, obj):
        primary_image = obj.images.filter(is_primary=True).first()
        if primary_image:
            return ProductImageSerializer(primary_image).data
        return obj.images.first().image_url if obj.images.exists() else None

class ProductDetailSerializer(serializers.ModelSerializer):
    images = ProductImageSerializer(many=True, read_only=True)
    attributes = ProductAttributeSerializer(many=True, read_only=True)
    category = CategorySerializer(read_only=True)
    seller_name = serializers.CharField(source='seller.get_full_name', read_only=True)
    seller_username = serializers.CharField(source='seller.username', read_only=True)
    
    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'price', 'category', 'condition', 
            'status', 'stock_quantity', 'brand', 'model', 'color', 'size', 
            'weight', 'is_featured', 'views_count', 'seller_name', 
            'seller_username', 'images', 'attributes', 'created_at', 'updated_at'
        ]

class ProductCreateUpdateSerializer(serializers.ModelSerializer):
    images = ProductImageSerializer(many=True, required=False)
    attributes = ProductAttributeSerializer(many=True, required=False)
    category_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = Product
        fields = [
            'name', 'description', 'price', 'category_id', 'condition', 
            'stock_quantity', 'brand', 'model', 'color', 'size', 'weight',
            'images', 'attributes'
        ]
    
    def validate_price(self, value):
        if value <= 0:
            raise serializers.ValidationError("Price must be greater than 0")
        return value
    
    def validate_stock_quantity(self, value):
        if value < 0:
            raise serializers.ValidationError("Stock quantity cannot be negative")
        return value
    
    def create(self, validated_data):
        images_data = validated_data.pop('images', [])
        attributes_data = validated_data.pop('attributes', [])
        category_id = validated_data.pop('category_id', None)
        
        if category_id:
            try:
                category = Category.objects.get(id=category_id)
                validated_data['category'] = category
            except Category.DoesNotExist:
                raise serializers.ValidationError("Invalid category ID")
        
        product = Product.objects.create(**validated_data)
        
        # Create images
        for i, image_data in enumerate(images_data):
            ProductImage.objects.create(
                product=product,
                order=i,
                **image_data
            )
        
        # Create attributes
        for attr_data in attributes_data:
            ProductAttribute.objects.create(
                product=product,
                **attr_data
            )
        
        # Sync with Supabase
        self._sync_to_supabase(product, 'create')
        
        return product
    
    def update(self, instance, validated_data):
        images_data = validated_data.pop('images', None)
        attributes_data = validated_data.pop('attributes', None)
        category_id = validated_data.pop('category_id', None)
        
        if category_id:
            try:
                category = Category.objects.get(id=category_id)
                validated_data['category'] = category
            except Category.DoesNotExist:
                raise serializers.ValidationError("Invalid category ID")
        
        # Update product fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        # Update images if provided
        if images_data is not None:
            instance.images.all().delete()
            for i, image_data in enumerate(images_data):
                ProductImage.objects.create(
                    product=instance,
                    order=i,
                    **image_data
                )
        
        # Update attributes if provided
        if attributes_data is not None:
            instance.attributes.all().delete()
            for attr_data in attributes_data:
                ProductAttribute.objects.create(
                    product=instance,
                    **attr_data
                )
        
        # Sync with Supabase
        self._sync_to_supabase(instance, 'update')
        
        return instance
    
    def _sync_to_supabase(self, product, operation):
        try:
            product_data = {
                'id': str(product.id),
                'seller_id': product.seller.id,
                'name': product.name,
                'description': product.description,
                'price': float(product.price),
                'category_id': product.category.id if product.category else None,
                'condition': product.condition,
                'status': product.status,
                'stock_quantity': product.stock_quantity,
                'brand': product.brand,
                'model': product.model,
                'color': product.color,
                'size': product.size,
                'weight': float(product.weight) if product.weight else None,
                'is_featured': product.is_featured,
                'views_count': product.views_count,
                'created_at': product.created_at.isoformat(),
                'updated_at': product.updated_at.isoformat(),
            }
            
            if operation == 'create':
                supabase_client.table('products').insert(product_data).execute()
            elif operation == 'update':
                supabase_client.table('products').update(product_data).eq('id', str(product.id)).execute()
                
        except Exception as e:
            print(f"Supabase sync error for product {product.id}: {e}")