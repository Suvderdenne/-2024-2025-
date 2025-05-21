from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Material, Order

User = get_user_model()

# ✅ Хэрэглэгчийн сериалайзер
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username', 'email', 'phone', 'password', 'role')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User(
            username=validated_data.get('username'),
            email=validated_data.get('email'),
            phone=validated_data.get('phone'),
            role=validated_data.get('role', 'user'),
        )
        user.set_password(validated_data['password'])  # 🔐 HASH хийх
        user.is_active = True                          # ✅ Идэвхтэй болгох
        user.save()
        return user

# ✅ Материал сериалайзер
class MaterialSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = Material
        fields = ['id', 'name', 'description', 'price', 'quantity', 'image', 'category', 'category_name']

# ✅ Захиалгын сериалайзер
class OrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'user']

    def create(self, validated_data):
        request = self.context.get('request')
        user = request.user if request else None
        return Order.objects.create(user=user, **validated_data)
    
    
    class Meta:
        model = User
        fields = ('username', 'email', 'phone', 'password', 'role')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)  # ✅ HASH хийх
        user.is_active = True
        user.save()
        return user

class OrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ['id', 'name', 'phone', 'address', 'items', 'total_price', 'created_at']
