# backend/app/models.py

from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver

class Category(models.Model):
    name = models.CharField(max_length=255, unique=True)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name

class Brand(models.Model):
    name = models.CharField(max_length=255, unique=True)
    country = models.CharField(max_length=100, blank=True, null=True)

    def __str__(self):
        return self.name

class CarPart(models.Model):
    Нэр = models.CharField(max_length=255)
    Төрөл = models.ForeignKey(Category, on_delete=models.CASCADE)
    Үнэ = models.DecimalField(max_digits=10, decimal_places=2)
    Тайлбар = models.TextField(blank=True, null=True)
    Зураг = models.ImageField(upload_to='car_parts/', blank=True, null=True)
    Орсон_цаг = models.DateTimeField(auto_now_add=True)
    
    # brand талбар нэмэх хэрэгтэй (энэ бол жишээ, хэрэв брэнд байхгүй бол, энэ хэсгийг хасаж болно)
    brand = models.ForeignKey(Brand, on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        return f"{self.Нэр} - {self.brand.name}" if self.brand else self.Нэр  # brand атрибут зассан

class Order(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)         
    status = models.CharField(
        max_length=20,
        choices=[('Pending', 'Pending'), ('Shipped', 'Shipped'), ('Delivered', 'Delivered')],
        default='Pending'
    )

    def __str__(self):
        return f"Order {self.id} - {self.user.username}"

class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    car_part = models.ForeignKey(CarPart, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField()
    price = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"{self.quantity}x {self.car_part.Нэр} in Order {self.order.id}"


class Comment(models.Model):
    car_part = models.ForeignKey(CarPart, on_delete=models.CASCADE, related_name='comments')
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    rating = models.PositiveSmallIntegerField(
        choices=[(1, '1 Star'), (2, '2 Stars'), (3, '3 Stars'), (4, '4 Stars'), (5, '5 Stars')],
        null=True, blank=True
    )
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Comment by {self.user.username} on {self.car_part.Нэр}"

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    profile_picture = models.TextField(blank=True, null=True)  # Store base64 image
    bio = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s Profile"

    def get_profile_picture_url(self):
        if self.profile_picture:
            return self.profile_picture
        return None

# Signal to create/update UserProfile when User is created/updated
@receiver(post_save, sender=User)
def create_or_update_user_profile(sender, instance, created, **kwargs):
    if created:
        # Create profile with user's name and email
        UserProfile.objects.create(
            user=instance,
            bio=f"Welcome to {instance.username}'s profile!"
        )
    else:
        # Update profile if user information changes
        if not hasattr(instance, 'profile'):
            UserProfile.objects.create(
                user=instance,
                bio=f"Welcome to {instance.username}'s profile!"
            )
        else:
            instance.profile.save()