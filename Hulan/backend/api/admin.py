from django.contrib import admin
from django.contrib.auth import get_user_model  # ✅ Django-ийн User-г дуудаж байна
from .models import Category, Product, Order, OrderItem, Payment, Review, Cart, CartItem

User = get_user_model()  # ✅ Default эсвэл Custom User-г автоматаар авна

# Category Admin
@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'description']
    search_fields = ['name']

# Product Admin
@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ['name', 'price', 'stock_quantity', 'category']
    list_filter = ['category']
    search_fields = ['name']

# Order Admin
@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ['user', 'status', 'total_amount', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['user__username']

# OrderItem Admin
@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
    list_display = ['order', 'product', 'quantity', 'price_at_time', 'subtotal']
    readonly_fields = ['price_at_time']

# Payment Admin
@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ['order', 'payment_method', 'status', 'amount', 'transaction_id', 'created_at']
    list_filter = ['status', 'payment_method']
    search_fields = ['transaction_id']

# Review Admin
@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ['user', 'product', 'rating', 'created_at']
    list_filter = ['rating']
    search_fields = ['user__username', 'product__name']

# Cart Admin
@admin.register(Cart)
class CartAdmin(admin.ModelAdmin):
    list_display = ['user', 'total', 'created_at', 'updated_at']
    readonly_fields = ['total']

# CartItem Admin
@admin.register(CartItem)
class CartItemAdmin(admin.ModelAdmin):
    list_display = ['cart', 'product', 'quantity', 'subtotal']
    readonly_fields = ['subtotal']
