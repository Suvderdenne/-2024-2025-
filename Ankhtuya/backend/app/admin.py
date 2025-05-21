from django.contrib import admin
from .models import Category, PlantInfo, UserPlant

# Register the Category model
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name')  # Display ID and name in the list
    search_fields = ('name',)  # Allow searching by name

admin.site.register(Category, CategoryAdmin)


# Register the PlantInfo model
class PlantInfoAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'category', 'watering', 'sunlight', 'temperature')
    search_fields = ('name', 'category__name')  # Search by name or category name
    list_filter = ('category',)  # Filter by category

admin.site.register(PlantInfo, PlantInfoAdmin)


# Register the UserPlant model
class UserPlantAdmin(admin.ModelAdmin):
    list_display = ('id', 'nickname', 'user', 'plant', 'last_watered')
    search_fields = ('nickname', 'user__username', 'plant__name')  # Search by nickname, username, or plant name
    list_filter = ('user', 'plant')  # Filter by user or plant

admin.site.register(UserPlant, UserPlantAdmin)
