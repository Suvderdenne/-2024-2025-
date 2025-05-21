from rest_framework import serializers
from .models import Category, Product, Cart, CartItem, Review, OrderItem, Order, Payment
from django.contrib.auth import get_user_model

User = get_user_model()

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'description']

class ProductSerializer(serializers.ModelSerializer):
    category = serializers.CharField(source='category.name', read_only=True)
    category_id = serializers.IntegerField(write_only=True)
    user_rating = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'price', 'stock_quantity',
            'image_url', 'category', 'category_id',
            'created_at', 'updated_at', 'user_rating'
        ]

    def get_user_rating(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            review = obj.reviews.filter(user=request.user).first()
            return review.rating if review else None
        return None

class CartItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    product_id = serializers.IntegerField(write_only=True)
    quantity = serializers.IntegerField(min_value=1)
    subtotal = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = CartItem
        fields = ['id', 'product', 'product_id', 'quantity', 'subtotal']

class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True, read_only=True)
    total = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = Cart
        fields = ['id', 'user', 'items', 'total', 'created_at', 'updated_at']
        read_only_fields = ['user']

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

class ReviewSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = Review
        fields = ['id', 'user', 'product', 'rating', 'comment', 'created_at', 'username']
        read_only_fields = ['user', 'product', 'created_at']

class OrderItemCreateSerializer(serializers.ModelSerializer):
    product_id = serializers.IntegerField()

    class Meta:
        model = OrderItem
        fields = ['product_id', 'quantity']

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemCreateSerializer(many=True)

    class Meta:
        model = Order
        fields = ['phone_number', 'shipping_address', 'total_amount', 'items', 'payment_method']

    def create(self, validated_data):
        request = self.context.get('request')
        user = request.user if request else None
        items_data = validated_data.pop('items')
        order = Order.objects.create(user=user, **validated_data)
        for item_data in items_data:
            product = Product.objects.get(id=item_data['product_id'])
            OrderItem.objects.create(
                order=order,
                product=product,
                quantity=item_data['quantity'],
                price_at_time=product.price
            )
        return order

class PaymentSerializer(serializers.ModelSerializer):
    order = OrderSerializer(read_only=True)
    order_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = Payment
        fields = [
            'id', 'order', 'order_id', 'amount', 'status',
            'shipping_address', 'payment_method', 'transaction_id',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['amount']
