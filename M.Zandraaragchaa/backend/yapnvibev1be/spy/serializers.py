from rest_framework import serializers
from spy.models import AppUser

class AppUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = AppUser
        fields = ['user_id', 'device', 'created_at']