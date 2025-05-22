from django.contrib import admin
from .models import Restaurant, Comment, RestaurantImage

class RestaurantImageInline(admin.TabularInline):
    model = RestaurantImage
    extra = 1

@admin.register(Restaurant)
class RestaurantAdmin(admin.ModelAdmin):
    list_display = ('name', 'address1', 'address2', 'description')
    search_fields = ('name', 'address1', 'address2')
    inlines = [RestaurantImageInline]

@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ('user_name', 'restaurant', 'created_at')
    search_fields = ('user_name', 'restaurant__name')
    list_filter = ('created_at',)
