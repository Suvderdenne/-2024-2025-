from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator

# 📦 Ангилал
class Category(models.Model):
    name = models.CharField(max_length=255, unique=True)
    description = models.TextField()

    class Meta:
        verbose_name_plural = "Categories"

    def __str__(self):
        return self.name

# 🛍️ Бүтээгдэхүүн
class Product(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0.01)])
    stock_quantity = models.PositiveIntegerField()
    image_url = models.URLField()
    category = models.ForeignKey(Category, related_name='products', on_delete=models.PROTECT)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    average_rating = models.FloatField(default=0.0)

    def __str__(self):
        return f"{self.name} (${self.price})"

    def update_average_rating(self):
        reviews = self.reviews.all()
        if reviews.exists():
            avg = sum(r.rating for r in reviews) / reviews.count()
            self.average_rating = round(avg, 2)
            self.save()

# 🌟 Үнэлгээ
class Review(models.Model):
    RATING_CHOICES = [(i, f'{i} Star{"s" if i > 1 else ""}') for i in range(1, 6)]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='reviews')
    rating = models.IntegerField(choices=RATING_CHOICES)
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['user', 'product']
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username}'s review for {self.product.name}"

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        self.update_product_average_rating()

    def delete(self, *args, **kwargs):
        product = self.product
        super().delete(*args, **kwargs)
        self.update_product_average_rating(product)

    def update_product_average_rating(self, product=None):
        product = product or self.product
        reviews = product.reviews.all()
        avg = reviews.aggregate(models.Avg('rating'))['rating__avg'] or 0.0
        product.average_rating = round(avg, 1)
        product.save()

# 🛒 Сагс
class Cart(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def total(self):
        return sum(item.subtotal for item in self.items.all())

# 🛍️ Сагсны бараа
class CartItem(models.Model):
    cart = models.ForeignKey(Cart, related_name='items', on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)

    @property
    def subtotal(self):
        return self.product.price * self.quantity

    class Meta:
        unique_together = ['cart', 'product']

# 📦 Захиалга
User = settings.AUTH_USER_MODEL

class Order(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('shipped', 'Shipped'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    shipping_address = models.TextField()
    phone_number = models.CharField(max_length=20)
    payment_method = models.CharField(max_length=50, choices=[('qpay', 'QPay'), ('cash', 'Cash')], default='cash')  # Үндсэн утга 'cash' оруулсан
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def items(self):
        return self.order_items.all()

    def __str__(self):
        return f"Order {self.id} - {self.user.username}"
# 📦 Захиалгын бараа
class OrderItem(models.Model):
    order = models.ForeignKey(Order, related_name='order_items', on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.PROTECT)
    quantity = models.PositiveIntegerField()
    price_at_time = models.DecimalField(max_digits=10, decimal_places=2)

    @property
    def subtotal(self):
        return self.price_at_time * self.quantity

    def __str__(self):
        return f"{self.quantity}x {self.product.name}"

# 💳 Төлбөр
class Payment(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('refunded', 'Refunded'),
    ]

    order = models.OneToOneField(Order, on_delete=models.CASCADE, related_name='payment')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    payment_method = models.CharField(max_length=50)
    transaction_id = models.CharField(max_length=100, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Payment for Order {self.order.id}"
