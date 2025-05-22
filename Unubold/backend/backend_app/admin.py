from django.contrib import admin
from .models import User, RecommendedPlace, PlaceImage, Place, Restaurant, Hotel, Parking

# Custom User Admin
class UserAdmin(admin.ModelAdmin):
    list_display = ('name', 'email', 'password')
    search_fields = ('name', 'email')

# Inline for PlaceImage
class PlaceImageInline(admin.TabularInline):
    model = PlaceImage
    extra = 3

# RecommendedPlace Admin with inline images
@admin.register(RecommendedPlace)
class RecommendedPlaceAdmin(admin.ModelAdmin):
    inlines = [PlaceImageInline]

# Register User separately
admin.site.register(User, UserAdmin)
admin.site.register(Place)
admin.site.register(Restaurant)
admin.site.register(Hotel)
admin.site.register(Parking)
