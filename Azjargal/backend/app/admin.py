from django.contrib import admin
from .models import Category, Brand, CarPart, Order, OrderItem

# Category моделиуд
@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name',)

# Brand моделиуд
@admin.register(Brand)
class BrandAdmin(admin.ModelAdmin):
    list_display = ('name', 'country')
    search_fields = ('name',)

# CarPart моделиуд
@admin.register(CarPart)
class CarPartAdmin(admin.ModelAdmin):
    list_display = ('Нэр', 'Төрөл', 'Үнэ', 'brand', 'Орсон_цаг')
    search_fields = ('Нэр', 'Тайлбар')
    list_filter = ('Төрөл', 'brand')

# Order моделиуд
@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('user', 'total_price', 'status', 'created_at')
    list_filter = ('status',)
    search_fields = ('user__username',)

# OrderItem моделиуд
@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
    list_display = ('order', 'car_part', 'quantity', 'price')
    search_fields = ('order__id', 'car_part__Нэр')
