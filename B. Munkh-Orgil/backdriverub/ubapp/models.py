from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.contrib.auth.hashers import make_password, check_password

# Create your models here.
class User(models.Model):
    full_name = models.CharField(max_length=100)
    phone_number = models.CharField(max_length=15, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    profile_photo = models.ImageField(upload_to='profiles/', null=True, blank=True)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    car_model = models.CharField(max_length=100)
    car_plate = models.CharField(max_length=20, unique=True)
    location = models.CharField(max_length=255)

    def __str__(self):
        return self.phone_number  # or self.full_name if you prefer

    def set_password(self, raw_password):
        self.password = make_password(raw_password)

    def check_password(self, raw_password):
        return check_password(raw_password, self.password)
    
class Driver(models.Model):
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    phone_number = models.CharField(max_length=15, unique=True)
    license_number = models.CharField(max_length=50)
    profile_photo = models.ImageField(upload_to='drivers/', null=True, blank=True)
    location = models.CharField(max_length=255, null=True, blank=True)  # Optional location
    latitude = models.FloatField(null=True, blank=True)  # Add latitude field
    longitude = models.FloatField(null=True, blank=True)  # Add longitude field
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.last_name

class Ride(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)  # the one who called
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE)    
    start_time = models.DateTimeField()
    end_time = models.DateTimeField(null=True, blank=True)
    pickup_location = models.CharField(max_length=255)
    dropoff_location = models.CharField(max_length=255)
    status = models.CharField(max_length=20, choices=[
        ("scheduled", "Scheduled"),
        ("in_progress", "In Progress"),
        ("completed", "Completed")
    ], default="scheduled")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Ride from {self.pickup_location} to {self.dropoff_location}"
    
