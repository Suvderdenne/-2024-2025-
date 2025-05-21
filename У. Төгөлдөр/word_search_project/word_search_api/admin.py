from django.contrib import admin
from .models import Level, Word, GridData, UserProfile

class WordInline(admin.TabularInline):
    model = Word
    extra = 3

class LevelAdmin(admin.ModelAdmin):
    inlines = [WordInline]
    list_display = ('level_number', 'grid_size', 'category')

admin.site.register(Level, LevelAdmin)
admin.site.register(GridData)
admin.site.register(UserProfile)