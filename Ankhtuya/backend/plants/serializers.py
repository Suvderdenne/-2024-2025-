from datetime import datetime, timedelta
from django.utils import timezone
from rest_framework import serializers

class UserPlantDetailSerializer(serializers.ModelSerializer):
    plant = PlantSerializer()
    days_since_watered = serializers.SerializerMethodField()
    next_watering_date = serializers.SerializerMethodField()

    class Meta:
        model = UserPlant
        fields = [
            'id', 'nickname', 'plant', 'last_watered', 
            'image_base64', 'days_since_watered', 'next_watering_date'
        ]

    def get_days_since_watered(self, obj):
        if not obj.last_watered:
            return None
        return (timezone.now().date() - obj.last_watered).days

    def get_next_watering_date(self, obj):
        if not obj.last_watered:
            return None
        return obj.last_watered + timedelta(days=7)  # Assuming weekly watering 