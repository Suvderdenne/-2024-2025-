from django.db import models

class Restaurant(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    image = models.ImageField(upload_to='restaurant_images/', null=True, blank=True)
    address1 = models.CharField(
        max_length=255,
        help_text="Үндсэн хаяг (байршил)"
    )
    address2 = models.CharField(
        max_length=255,
        blank=True,
        help_text="Нэмэлт хаяг (давхар хаяг)"
    )
    
    # New fields
    opening_hours = models.CharField(
        max_length=255,
        blank=True,
        help_text="e.g. 09:00-22:00, Да-Ня"
    )
    phone = models.CharField(
        max_length=20,
        blank=True,
        help_text="Рестораны утасны дугаар"
    )
    website = models.URLField(
        blank=True,
        help_text="Рестораны вэбсайт"
    )
    has_delivery = models.BooleanField(
        default=False,
        help_text="Хүргэлттэй эсэх"
    )
    has_parking = models.BooleanField(
        default=False,
        help_text="Зогсоолтой эсэх"
    )
    has_wifi = models.BooleanField(
        default=False,
        help_text="WiFi-тай эсэх"
    )
    popular_dishes = models.TextField(
        blank=True,
        help_text="Алдартай хоолны цэс"
    )

    def __str__(self):
        return self.name

class RestaurantImage(models.Model):
    restaurant = models.ForeignKey(
        Restaurant,
        on_delete=models.CASCADE,
        related_name='additional_images'
    )
    image = models.ImageField(upload_to='restaurant_images/')
    caption = models.CharField(max_length=255, blank=True)

    def __str__(self):
        return f"Image for {self.restaurant.name}"

from django.contrib.auth import get_user_model

User = get_user_model()

class Comment(models.Model):
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name="comments")
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="comments")
    user_name = models.CharField(max_length=255)
    text = models.TextField()
    rating = models.IntegerField(default=5)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.restaurant.name}"

    def save(self, *args, **kwargs):
        if not hasattr(self, 'user') or not self.user:
            raise ValueError("Comment must have a user")
        # Always update user_name from current user.username
        self.user_name = self.user.username
        super().save(*args, **kwargs)
