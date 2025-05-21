from rest_framework import serializers
from .models import PlantInfo, UserPlant, Category
from django.contrib.auth.models import User
from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ('username', 'password', 'password2', 'email')
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Нууц үг таарахгүй байна."})
        return attrs

    def create(self, validated_data):
        user = User.objects.create(
            username = validated_data['username'],
            email = validated_data['email']
        )
        user.set_password(validated_data['password'])
        user.save()
        return user

class PlantInfoSerializer(serializers.ModelSerializer):
    category_id = serializers.IntegerField(write_only=True)  # Allow category_id to be passed as an integer

    class Meta:
        model = PlantInfo
        fields = '__all__'

    def create(self, validated_data):
        # If category_id is passed, link the category
        category_id = validated_data.pop('category_id', None)
        if category_id:
            category = Category.objects.get(id=category_id)
            validated_data['category'] = category
        return super().create(validated_data)

    def update(self, instance, validated_data):
        category_id = validated_data.pop('category_id', None)
        if category_id:
            category = Category.objects.get(id=category_id)
            instance.category = category
        return super().update(instance, validated_data)


class UserAddPlantSerializer(serializers.ModelSerializer):
    plant_id = serializers.PrimaryKeyRelatedField(queryset=PlantInfo.objects.all(), write_only=True)
    nickname = serializers.CharField(max_length=100)
    last_watered = serializers.DateField(required=False, allow_null=True)
    image_base64 = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = UserPlant
        fields = ['plant_id', 'nickname', 'last_watered', 'image_base64']

    def create(self, validated_data):
        user = self.context['request'].user  # Getting the user from the request context
        plant = validated_data.pop('plant_id')
        user_plant = UserPlant.objects.create(user=user, plant=plant, **validated_data)
        return user_plant

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name']  # Assuming Category has 'id' and 'name' fields




class UserPlantDetailSerializer(serializers.ModelSerializer):
    plant = PlantInfoSerializer(read_only=True)

    class Meta:
        model = UserPlant
        fields = ['id', 'plant', 'nickname', 'last_watered', 'image_base64']
