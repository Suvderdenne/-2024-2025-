from rest_framework import serializers
from django.contrib.auth.models import User
from .models import *

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category    
        fields = ['id', 'name', 'description']


class BrandSerializer(serializers.ModelSerializer):
    class Meta:
        model = Brand  
        fields = ['id', 'name', 'country']      


from rest_framework import serializers
from .models import CarPart

class CarPartSerializer(serializers.ModelSerializer):
    brand_name = serializers.CharField(source='brand.name', read_only=True)
    category_name = serializers.CharField(source='Төрөл.name', read_only=True)

    class Meta:
        model = CarPart
        fields = ['id', 'Нэр', 'category_name', 'brand_name', 'Үнэ', 'Тайлбар', 'Зураг', 'Орсон_цаг']


class OrderSerializer(serializers.ModelSerializer):
    items = serializers.SerializerMethodField()
    
    class Meta:
        model = Order
        fields = ['id', 'user', 'status', 'total_price', 'created_at', 'items']
    
    def get_items(self, obj):
        items = obj.items.all()
        return OrderItemSerializer(items, many=True).data

class OrderItemSerializer(serializers.ModelSerializer):
    car_part_details = serializers.SerializerMethodField()
    
    class Meta:
        model = OrderItem
        fields = ['id', 'order', 'car_part', 'car_part_details', 'quantity', 'price']
    
    def get_car_part_details(self, obj):
        return {
            'id': obj.car_part.id,
            'name': obj.car_part.Нэр,
            'price': str(obj.car_part.Үнэ),
            'image': self.context['request'].build_absolute_uri(obj.car_part.Зураг.url) if obj.car_part.Зураг else None
        }   



class CarPartSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarPart
        fields = ['id', 'Нэр', 'Төрөл', 'Үнэ', 'Тайлбар', 'Зураг', 'Орсон_цаг']



class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    user_profile_picture = serializers.SerializerMethodField()
    car_part_id = serializers.PrimaryKeyRelatedField(
        queryset=CarPart.objects.all(), 
        source='car_part',
        write_only=True
    )
    
    class Meta:
        model = Comment
        fields = ['id', 'car_part', 'car_part_id', 'user', 'user_profile_picture', 'text', 'rating', 'created_at']
        read_only_fields = ['id', 'created_at', 'user', 'car_part']
    
    def get_user_profile_picture(self, obj):
        try:
            return obj.user.profile.profile_picture
        except UserProfile.DoesNotExist:
            return None

class UserProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    first_name = serializers.CharField(source='user.first_name', read_only=True)
    last_name = serializers.CharField(source='user.last_name', read_only=True)
    
    class Meta:
        model = UserProfile
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'phone_number', 'address', 'profile_picture', 'bio',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']        