from rest_framework import serializers
from .models import User, Driver, Ride

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'full_name', 'phone_number', 'email', 'profile_photo', 
                 'is_verified', 'car_model', 'car_plate', 'location']
        read_only_fields = ['id', 'is_verified']

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    password_confirm = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    
    class Meta:
        model = User
        fields = ['full_name', 'phone_number', 'email', 'password', 'password_confirm', 
                 'car_model', 'car_plate', 'location']
    
    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError({"password_confirm": "Passwords don't match."})
        return data
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create(
            full_name=validated_data['full_name'],
            phone_number=validated_data['phone_number'],
            email=validated_data['email'],
            car_model=validated_data['car_model'],
            car_plate=validated_data['car_plate'],
            location=validated_data.get('location', 'Ulaanbaatar')
        )
        user.set_password(validated_data['password'])
        user.save()
        return user

class DriverSerializer(serializers.ModelSerializer):
    class Meta:
        model = Driver
        fields = ['id', 'first_name', 'last_name', 'phone_number', 'license_number', 
                 'profile_photo', 'location', 'latitude', 'longitude', 'is_verified']
        read_only_fields = ['id', 'is_verified']

class RideSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    driver = DriverSerializer(read_only=True)
    
    class Meta:
        model = Ride
        fields = ['id', 'user', 'driver', 'start_time', 'end_time', 
                 'pickup_location', 'dropoff_location', 'status', 'created_at']
        read_only_fields = ['id', 'created_at'] 