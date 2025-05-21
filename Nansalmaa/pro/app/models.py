from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver

class Category(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = "Categories"

    def __str__(self):
        return self.name

class Clothes(models.Model):
    GENDER_CHOICES = [
        ('M', 'Male'),
        ('F', 'Female'),
        ('U', 'Unisex'),
    ]
    
    CONDITION_CHOICES = [
        ('new', 'Brand New (with tags)'),
        ('like_new', 'Like New'),
        ('good', 'Good'),
        ('fair', 'Fair'),
        ('poor', 'Poor'),
    ]

    # Existing fields (keep exactly as they are)
    seller = models.ForeignKey(User, on_delete=models.CASCADE, related_name='listed_clothes')
    title = models.CharField(max_length=200)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    image_base64 = models.TextField()
    phone_number = models.CharField(max_length=15)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name='clothes')
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES, default='U')
    is_sold = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Modified field (change with default that matches existing 'New' values)
    condition = models.CharField(
        max_length=20,
        choices=CONDITION_CHOICES,
        default='good',  # Will set default for new records
    )
    
    # New fields (all optional/nullable to preserve existing data)
    original_price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True
    )
    size = models.CharField(
        max_length=20,
        blank=True,
        null=True
    )
    brand = models.CharField(
        max_length=100,
        blank=True,
        null=True
    )
    available_for_pickup = models.BooleanField(
        default=False
    )
    pickup_location = models.CharField(
        max_length=200,
        blank=True,
        null=True
    )
    shipping_cost = models.DecimalField(
        max_digits=6,
        decimal_places=2,
        null=True,
        blank=True
    )
    reason_for_sale = models.TextField(
        blank=True,
        null=True
    )

    def __str__(self):
        return self.title

    class Meta:
        verbose_name_plural = "Clothing Items"
        ordering = ['-created_at']

class Cart(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    session_id = models.CharField(max_length=100, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Cart {self.id}"

class CartItem(models.Model):
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE, related_name='items')
    clothes = models.ForeignKey(Clothes, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.quantity} x {self.clothes.title}"

class Order(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('shipped', 'Shipped'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    ]

    PAYMENT_STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('paid', 'Paid'),
        ('failed', 'Failed'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS_CHOICES, default='pending')
    
    # Shipping details
    shipping_address = models.TextField(null=True, blank=True)
    shipping_name = models.CharField(max_length=200, null=True, blank=True)
    shipping_phone = models.CharField(max_length=15, null=True, blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    shipped_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Order {self.id} - {self.status}"

    class Meta:
        ordering = ['-created_at']


class Message(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages')
    clothing_item = models.ForeignKey(Clothes, on_delete=models.CASCADE, null=True, blank=True)
    content = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']

class SellerRating(models.Model):
    RATING_CHOICES = [
        (1, '1 - Poor'),
        (2, '2 - Fair'),
        (3, '3 - Good'),
        (4, '4 - Very Good'),
        (5, '5 - Excellent'),
    ]
    
    seller = models.ForeignKey(User, on_delete=models.CASCADE, related_name='ratings_received')
    buyer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='ratings_given')
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='ratings')
    rating = models.PositiveSmallIntegerField(choices=RATING_CHOICES)
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ('order', 'buyer')  # One rating per order per buyer        

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    profile_image = models.TextField(null=True, blank=True)  # Base64 encoded image

    def __str__(self):
        return f"{self.user.username}'s profile"

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()        