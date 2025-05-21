from django.contrib import admin
from .models import (
    Question, Option, UserResponse, University, UniversityDetails,
    Course, CareerInsight, RecommendationHistory,News,NewsDetails,CareerDetails,Post,Comment,Like
)
from django.utils.html import format_html

# Registering the Question model
@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display = ('text',)
    search_fields = ('text',)

# Registering the Option model
@admin.register(Option)
class OptionAdmin(admin.ModelAdmin):
    list_display = ('question', 'text', 'career_weight')
    search_fields = ('question__text', 'text', 'career_weight')
    list_filter = ('question',)

# Registering the UserResponse model
@admin.register(UserResponse)
class UserResponseAdmin(admin.ModelAdmin):
    list_display = ('user', 'question', 'selected_option')
    search_fields = ('user__username', 'question__text', 'selected_option__text')
    list_filter = ('user', 'question')

# Registering the University model
@admin.register(University)
class UniversityAdmin(admin.ModelAdmin):
    list_display = ("name",)  # Removed 'location'
    search_fields = ("name",)

# Registering the UniversityDetails model
@admin.register(UniversityDetails)
class UniversityDetailsAdmin(admin.ModelAdmin):
    list_display = ("university", "location", "ranking")  # Now location is valid
    search_fields = ("university__name", "location")
    list_filter = ("ranking",)

# Registering the Course model
@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ('name', 'career', 'description')
    search_fields = ('name', 'career__career', 'description')
    list_filter = ('career',)

# Registering the CareerInsight model
@admin.register(CareerInsight)
class CareerInsightAdmin(admin.ModelAdmin):
    list_display = ('career', 'description', 'preparationTime')
    search_fields = ('career',)
    list_filter = ('career',)
@admin.register(RecommendationHistory)
class RecommendationHistoryAdmin(admin.ModelAdmin):
    list_display = ('user', 'suggested_career', 'recommended_at')
    list_filter = ('suggested_career', 'recommended_at')
    search_fields = ('user__username', 'suggested_career', 'high_school_subjects', 'recommended_universities')
    readonly_fields = ('recommended_at',)

    fieldsets = (
        (None, {
            'fields': ('user', 'suggested_career', 'explanation')
        }),
        ('Details', {
            'fields': ('high_school_subjects', 'recommended_universities', 'responses_json', 'recommended_at')
        }),
    )
@admin.register(CareerDetails)
class CareerDetailsAdmin(admin.ModelAdmin):
    # Display specific fields in the admin list view
    list_display = ('name', 'career', 'salary', 'preparationTime')
    # Add search functionality for the name and career fields
    search_fields = ('name', 'career__name')
    # Add filters to filter by salary and career
    list_filter = ('career', 'salary')
# Registering the RecommendationHistory model

@admin.register(News)
class NewsAdmin(admin.ModelAdmin):
    list_display = ('title',)
    search_fields = ('title', 'description')

@admin.register(NewsDetails)
class NewsDetailsAdmin(admin.ModelAdmin):
    list_display = ('title', 'publisher', 'created_at')
    search_fields = ('title', 'publisher', 'source')
    list_filter = ('created_at',)
    ordering = ('-created_at',)

class PostAdmin(admin.ModelAdmin):
    list_display = ('title', 'user', 'created_at', 'preview_image')

    def preview_image(self, obj):
        if obj.image:
            return format_html(f'<img src="{obj.image.url}" style="height:50px;" />')
        return "-"
    preview_image.short_description = 'Image'

admin.site.register(Post, PostAdmin)
admin.site.register(Comment)
admin.site.register(Like)