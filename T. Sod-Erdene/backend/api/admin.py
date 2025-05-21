from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import *

class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'phone', 'is_admin', 'is_staff')
    list_filter = ('is_admin', 'is_staff', 'is_superuser')
    search_fields = ('username', 'email', 'phone')
    ordering = ('-date_joined',)
    
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal Info', {'fields': ('email', 'phone', 'address', 'account_pic')}),
        ('Permissions', {'fields': ('is_active', 'is_admin', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'phone', 'password1', 'password2'),
        }),
    )

class FurnitureCategoryAdmin(admin.ModelAdmin):
    list_display = ('name',)
    search_fields = ('name',)

class FurnitureAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'price', 'rating', 'created_at')
    list_filter = ('category', 'created_at')
    search_fields = ('title', 'description')
    raw_id_fields = ('liked_by',)
    readonly_fields = ('created_at',)

class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    raw_id_fields = ('furniture',)

class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'status', 'total_price', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('user__username', 'user__email')
    inlines = [OrderItemInline]
    readonly_fields = ('created_at', 'updated_at')

class ReviewAdmin(admin.ModelAdmin):
    list_display = ('user', 'furniture', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('user__username', 'furniture__title')
    readonly_fields = ('created_at',)

# Register models with custom admin classes
admin.site.register(User, CustomUserAdmin)
admin.site.register(FurnitureCategory, FurnitureCategoryAdmin)
admin.site.register(Furniture, FurnitureAdmin)
admin.site.register(Order, OrderAdmin)
admin.site.register(Review, ReviewAdmin)

# Customize admin site
admin.site.site_header = "Furniture E-Commerce Administration"
admin.site.site_title = "Furniture Admin Portal"
admin.site.index_title = "Welcome to Furniture Admin Portal"