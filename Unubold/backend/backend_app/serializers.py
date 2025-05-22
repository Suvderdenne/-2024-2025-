from rest_framework import serializers
from .models import User, RecommendedPlace, PlaceImage, Place, Restaurant, Hotel, Parking

class UserSerializer(serializers.ModelSerializer):
    # Password field that is write-only (won't be returned in responses)
    password = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'}
    )

    class Meta:
        model = User
        fields = ['id', 'email', 'name', 'password']
        extra_kwargs = {
            'email': {'required': True},
            'name': {'required': True}
        }

    def create(self, validated_data):
        # Use the custom create_user method from UserManager
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            name=validated_data['name']
        )
        return user

class PlaceImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlaceImage
        fields = ['image']

class RecommendedPlaceSerializer(serializers.ModelSerializer):
    images = PlaceImageSerializer(many=True, read_only=True)
    class Meta:
        model = RecommendedPlace
        fields = '__all__'
        

from rest_framework import serializers

class RestaurantSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Restaurant
        fields = '__all__'
    
    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image_url:
            return request.build_absolute_uri(obj.image_url)
        return None

class PlaceSerializer(serializers.ModelSerializer):
    restaurants = RestaurantSerializer(many=True, read_only=True)
    
    class Meta:
        model = Place
        fields = '__all__'
        
class HotelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Hotel
        fields = '__all__'
        
class ParkingSerializer(serializers.ModelSerializer):
    type_display = serializers.CharField(source='get_type_display', read_only=True)
    
    class Meta:
        model = Parking
        fields = ['id', 'name', 'type', 'type_display', 'capacity', 
                 'price', 'distance', 'is_covered', 'place']