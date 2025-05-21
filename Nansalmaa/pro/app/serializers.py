from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password
from .models import *
import base64
import re

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'name', 'description')

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ('profile_image',)

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=False)
    profile_image = serializers.CharField(write_only=True, required=False, allow_null=True)
    username = serializers.CharField(required=True)  # Make username required and not read-only

    class Meta:
        model = User
        fields = ('id', 'username', 'password', 'password2', 'email', 'first_name', 'last_name', 'profile_image')
        extra_kwargs = {
            'first_name': {'required': True},
            'last_name': {'required': True},
            'email': {'required': True}
        }

    def validate_profile_image(self, value):
        if value is None:
            return value
            
        # Check if the string is a valid base64 image
        try:
            # Check if it's a data URL
            if value.startswith('data:image'):
                # Extract the base64 part
                value = value.split(',')[1]
            
            # Try to decode the base64 string
            base64.b64decode(value)
            
            # Check if it's not too large (e.g., max 5MB)
            if len(value) > 5 * 1024 * 1024:  # 5MB in base64
                raise serializers.ValidationError("Image size should not exceed 5MB")
            
            return value
        except Exception as e:
            raise serializers.ValidationError("Invalid base64 image data")

    def validate(self, attrs):
        if 'password' in attrs and 'password2' in attrs:
            if attrs['password'] != attrs['password2']:
                raise serializers.ValidationError({"password": "Password fields didn't match."})
        return attrs

    def create(self, validated_data):
        profile_image = validated_data.pop('profile_image', None)
        password2 = validated_data.pop('password2', None)
        user = User.objects.create_user(**validated_data)
        
        # Get or create profile for new user
        profile, created = UserProfile.objects.get_or_create(user=user)
        if profile_image:
            profile.profile_image = profile_image
            profile.save()
            
        return user

    def update(self, instance, validated_data):
        # Handle password update if provided
        if 'password' in validated_data:
            password = validated_data.pop('password')
            instance.set_password(password)
        
        # Remove password2 if present
        validated_data.pop('password2', None)
        
        # Update profile image if provided
        profile_image = validated_data.pop('profile_image', None)
        if profile_image is not None:
            profile, created = UserProfile.objects.get_or_create(user=instance)
            profile.profile_image = profile_image
            profile.save()
        
        # Update other fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        instance.save()
        return instance

    def to_representation(self, instance):
        data = super().to_representation(instance)
        try:
            data['profile_image'] = instance.profile.profile_image
        except UserProfile.DoesNotExist:
            # Create profile if it doesn't exist
            profile = UserProfile.objects.create(user=instance)
            data['profile_image'] = profile.profile_image
        return data

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(required=True)
    password = serializers.CharField(required=True, write_only=True)

class ClothesSerializer(serializers.ModelSerializer):
    seller_name = serializers.SerializerMethodField()
    phone_number = serializers.CharField(write_only=True)  # Hide phone number in list view
    category_name = serializers.SerializerMethodField()

    class Meta:
        model = Clothes
        fields = ('id', 'title', 'description', 'price', 'image_base64', 
                 'phone_number', 'is_sold', 'created_at', 'updated_at', 'seller', 'seller_name',
                 'category', 'category_name', 'gender', 'condition', 'original_price',
                 'size', 'brand', 'available_for_pickup', 'pickup_location',
                 'shipping_cost', 'reason_for_sale')
        read_only_fields = ('seller', 'is_sold', 'created_at', 'updated_at')

    def get_seller_name(self, obj):
        return f"{obj.seller.first_name} {obj.seller.last_name}"

    def get_category_name(self, obj):
        return obj.category.name if obj.category else None

    def validate_image_base64(self, value):
        # Check if the string is a valid base64 image
        try:
            # Check if it's a data URL
            if value.startswith('data:image'):
                # Extract the base64 part
                value = value.split(',')[1]
            
            # Try to decode the base64 string
            base64.b64decode(value)
            
            # Check if it's not too large (e.g., max 5MB)
            if len(value) > 5 * 1024 * 1024:  # 5MB in base64
                raise serializers.ValidationError("Image size should not exceed 5MB")
            
            return value
        except Exception as e:
            raise serializers.ValidationError("Invalid base64 image data")

    def create(self, validated_data):
        validated_data['seller'] = self.context['request'].user
        return super().create(validated_data)

class CartItemSerializer(serializers.ModelSerializer):
    clothes = ClothesSerializer(read_only=True)
    clothes_id = serializers.PrimaryKeyRelatedField(
        queryset=Clothes.objects.filter(is_sold=False),
        write_only=True,
        source='clothes'
    )

    class Meta:
        model = CartItem
        fields = ('id', 'clothes', 'clothes_id', 'quantity', 'created_at')
        read_only_fields = ('created_at',)

class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True, read_only=True)
    total = serializers.SerializerMethodField()

    class Meta:
        model = Cart
        fields = ('id', 'items', 'total', 'created_at', 'updated_at')
        read_only_fields = ('created_at', 'updated_at')

    def get_total(self, obj):
        return sum(item.clothes.price * item.quantity for item in obj.items.all())

class OrderSerializer(serializers.ModelSerializer):
    cart = CartSerializer(read_only=True)
    cart_id = serializers.PrimaryKeyRelatedField(
        queryset=Cart.objects.all(),
        write_only=True,
        source='cart'
    )
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    payment_status_display = serializers.CharField(source='get_payment_status_display', read_only=True)

    class Meta:
        model = Order
        fields = (
            'id', 'cart', 'cart_id', 'total_amount', 'status', 'status_display',
            'payment_status', 'payment_status_display', 'shipping_name',
            'shipping_phone', 'shipping_address', 'created_at', 'updated_at',
            'paid_at', 'shipped_at', 'delivered_at'
        )
        read_only_fields = (
            'total_amount', 'status', 'payment_status', 'created_at',
            'updated_at', 'paid_at', 'shipped_at', 'delivered_at'
        ) 


class SellerRatingSerializer(serializers.ModelSerializer):
    buyer_name = serializers.SerializerMethodField()
    
    class Meta:
        model = SellerRating
        fields = ('id', 'rating', 'comment', 'buyer_name', 'created_at')
        read_only_fields = ('buyer_name', 'created_at')
    
    def get_buyer_name(self, obj):
        return f"{obj.buyer.first_name} {obj.buyer.last_name}"
    
    def validate(self, data):
        # Ensure buyer actually purchased from this seller
        if not self.instance.order.items.filter(clothes__seller=self.instance.seller).exists():
            raise serializers.ValidationError("You can only rate sellers you purchased from")
        return data

class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.SerializerMethodField()
    recipient_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Message
        fields = ('id', 'sender', 'sender_name', 'recipient', 'recipient_name', 
                 'clothing_item', 'content', 'is_read', 'created_at')
        read_only_fields = ('sender', 'sender_name', 'created_at')
    
    def get_sender_name(self, obj):
        return f"{obj.sender.first_name} {obj.sender.last_name}"
    
    def get_recipient_name(self, obj):
        return f"{obj.recipient.first_name} {obj.recipient.last_name}"        