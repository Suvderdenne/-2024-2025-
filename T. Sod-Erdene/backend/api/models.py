from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator, MaxValueValidator
import uuid
import base64
from django.core.files.base import ContentFile

class User(AbstractUser):
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    account_pic = models.TextField(blank=True)  # Base64 encoded
    is_admin = models.BooleanField(default=False)
    
    def save_base64_image(self, base64_str):
        format, imgstr = base64_str.split(';base64,')
        ext = format.split('/')[-1]
        data = ContentFile(base64.b64decode(imgstr), name=f'{uuid.uuid4()}.{ext}')
        self.account_pic = data.read().decode('latin1')  # Store as base64 string
        self.save()

class FurnitureCategory(models.Model):
    name = models.CharField(max_length=100)
    
    def __str__(self):
        return self.name

class Furniture(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField()
    color = models.CharField(max_length=50)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    model_3d = models.FileField(upload_to='3d_models/', blank=True, null=True)
    pic = models.TextField()  # Base64 encoded
    rating = models.FloatField(
        default=0.0,
        validators=[MinValueValidator(0.0), MaxValueValidator(5.0)]
    )
    category = models.ForeignKey(FurnitureCategory, on_delete=models.SET_NULL, null=True)
    liked_by = models.ManyToManyField(User, related_name='liked_furniture', blank=True)
    
    def __str__(self):
        return self.title

class Order(models.Model):
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('PROCESSING', 'Processing'),
        ('SHIPPED', 'Shipped'),
        ('DELIVERED', 'Delivered'),
        ('CANCELLED', 'Cancelled'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    shipping_address = models.TextField()
    
    def __str__(self):
        return f"Order {self.id} - {self.user.email}"

class OrderItem(models.Model):
    order = models.ForeignKey(Order, related_name='items', on_delete=models.CASCADE)
    furniture = models.ForeignKey(Furniture, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    price_at_purchase = models.DecimalField(max_digits=10, decimal_places=2)
    is_paid = models.BooleanField(default=False)

    
    def __str__(self):
        return f"{self.quantity}x {self.furniture.title}"

class Review(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    furniture = models.ForeignKey(Furniture, on_delete=models.CASCADE, related_name='reviews')
    rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ['user', 'furniture']
    
    def __str__(self):
        return f"Review by {self.user.email} for {self.furniture.title}"


class Like(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    furniture = models.ForeignKey(Furniture, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'furniture')
class Notification(models.Model):
    NOTIFICATION_TYPES = [
        ('ORDER', 'Order Update'),
        ('DELIVERY', 'Delivery Update'),
        ('PAYMENT', 'Payment Update'),
        ('PROMOTION', 'Promotion'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=200)
    message = models.TextField()
    type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES)
    created_at = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.type} - {self.title} for {self.user.username}"
    
    @classmethod
    def get_unread_count(cls, user):
        """Get the number of unread notifications for a user"""
        return cls.objects.filter(user=user, is_read=False).count()
    
    @classmethod
    def mark_all_as_read(cls, user):
        """Mark all notifications as read for a user"""
        cls.objects.filter(user=user, is_read=False).update(is_read=True)
        
    @classmethod
    def create_order_notification(cls, user, order, status):
        """Create a notification for an order status change"""
        status_messages = {
            'PROCESSING': 'Таны захиалгыг боловсруулж эхэллээ.',
            'SHIPPED': 'Таны захиалга хүргэлтэнд гарлаа.',
            'DELIVERED': 'Таны захиалга амжилттай хүргэгдлээ.',
            'CANCELLED': 'Таны захиалга цуцлагдлаа.',
        }
        
        if status in status_messages:
            cls.objects.create(
                user=user,
                type='ORDER',
                title=f'Захиалгын төлөв өөрчлөгдлөө: {status}',
                message=status_messages[status]
            )

class Cart(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Cart - {self.user.email}"

class CartItem(models.Model):
    cart = models.ForeignKey(Cart, related_name='items', on_delete=models.CASCADE)
    furniture = models.ForeignKey(Furniture, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ['cart', 'furniture']

    def __str__(self):
        return f"{self.quantity}x {self.furniture.title} in {self.cart}"