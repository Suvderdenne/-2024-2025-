from rest_framework import serializers
from .models import *
from django.contrib.auth.hashers import make_password

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'phone', 'address', 'created_at')
        read_only_fields = ('id', 'created_at')
        extra_kwargs = {
            'password': {'write_only': True},
            'email': {'required': True},
            'username': {'required': True},
            'phone': {'required': False},
            'address': {'required': False},
        }

    def validate_email(self, value):
        user = self.context['request'].user if 'request' in self.context else None
        if user and User.objects.exclude(pk=user.pk).filter(email=value).exists():
            raise serializers.ValidationError("This email is already in use.")
        return value

    def validate_username(self, value):
        user = self.context['request'].user if 'request' in self.context else None
        if user and User.objects.exclude(pk=user.pk).filter(username=value).exists():
            raise serializers.ValidationError("This username is already in use.")
        return value

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)

class FurnitureCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = FurnitureCategory
        fields = '__all__'

class FurnitureSerializer(serializers.ModelSerializer):
    category = FurnitureCategorySerializer(read_only=True)
    is_liked = serializers.SerializerMethodField()
    
    class Meta:
        model = Furniture
        fields = '__all__'
    
    def get_is_liked(self, obj):
        user = self.context.get('request').user
        return user.is_authenticated and user.liked_furniture.filter(id=obj.id).exists()

class OrderItemSerializer(serializers.ModelSerializer):
    furniture = FurnitureSerializer(read_only=True)
    
    class Meta:
        model = OrderItem
        fields = '__all__'

class OrderSerializer(serializers.ModelSerializer):
    items = serializers.ListField(write_only=True)  # ирж буй items-ийг бичигддэг болгож өгнө
    user = serializers.StringRelatedField(read_only=True)
    is_paid = serializers.BooleanField(read_only=True)

    class Meta:
        model = Order
        fields = ['id', 'user', 'created_at', 'total_price', 'items','is_paid']

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        user = self.context['request'].user
        order = Order.objects.create(user=user, **validated_data)

        for item in items_data:
            OrderItem.objects.create(
                order=order,
                furniture_id=item['id'],
                quantity=item['quantity'],
                price_at_purchase=item['price']
            )
        return order


class ReviewSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    user_info = serializers.SerializerMethodField()
    furniture = serializers.PrimaryKeyRelatedField(queryset=Furniture.objects.all(), required=False)

    class Meta:
        model = Review
        fields = ['id', 'user', 'username', 'user_info', 'furniture', 'rating', 'comment', 'created_at']
        read_only_fields = ['user', 'created_at']
        
    def get_user_info(self, obj):
        return {
            'username': obj.user.username,
            'email': obj.user.email,
        }
        
    def validate_rating(self, value):
        if not (1 <= value <= 5):
            raise serializers.ValidationError('Үнэлгээ 1-5 хооронд байх ёстой')
        return value

    def validate(self, data):
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            raise serializers.ValidationError('Үнэлгээ өгөхийн тулд нэвтэрсэн байх шаардлагатай')
            
        if self.instance:  # Skip on update
            return data

        # Get furniture from URL if not provided in data
        furniture = data.get('furniture')
        if not furniture and 'furniture_pk' in self.context.get('view').kwargs:
            furniture = get_object_or_404(
                Furniture,
                pk=self.context.get('view').kwargs['furniture_pk']
            )
            data['furniture'] = furniture
            
        if not furniture:
            raise serializers.ValidationError('Тавилгыг заавал сонгох шаардлагатай')
            
        if Review.objects.filter(user=request.user, furniture=furniture).exists():
            raise serializers.ValidationError('Та аль хэдийн үнэлгээ өгсөн байна')
            
        return data

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'
class LikeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Like
        fields = '__all__'

class CartItemSerializer(serializers.ModelSerializer):
    furniture = FurnitureSerializer(read_only=True)
    furniture_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = CartItem
        fields = ['id', 'furniture', 'furniture_id', 'quantity', 'added_at']

class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True, read_only=True)
    total = serializers.SerializerMethodField()
    
    class Meta:
        model = Cart
        fields = ['id', 'items', 'total', 'created_at', 'updated_at']
    
    def get_total(self, obj):
        return sum(item.furniture.price * item.quantity for item in obj.items.all())