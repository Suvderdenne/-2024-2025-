from rest_framework import serializers
from .models import Restaurant, Comment, RestaurantImage

class RestaurantImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = RestaurantImage
        fields = ['id', 'image', 'caption']

class RestaurantSerializer(serializers.ModelSerializer):
    additional_images = RestaurantImageSerializer(many=True, read_only=True)
    
    class Meta:
        model = Restaurant
        fields = [
            'id', 'name', 'description', 'image', 'address1', 'address2',
            'opening_hours', 'phone', 'website', 'has_delivery',
            'has_parking', 'has_wifi', 'popular_dishes', 'additional_images'
        ]

class CommentSerializer(serializers.ModelSerializer):
    restaurant_name = serializers.CharField(source='restaurant.name', read_only=True)
    user_name = serializers.CharField(source='user.username', read_only=True)
    restaurant_image = serializers.CharField(source='restaurant.image', read_only=True)
    address = serializers.CharField(source='restaurant.address1', read_only=True)
    
    class Meta:
        model = Comment
        fields = ['id', 'text', 'rating', 'user', 'user_name', 'restaurant', 'restaurant_name', 'restaurant_image', 'address', 'created_at']
        read_only_fields = ['user', 'user_name', 'restaurant', 'created_at', 'address']
