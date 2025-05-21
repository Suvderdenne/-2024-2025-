from django.contrib import admin
from .models import User, UserProfile, School, Subject, Lesson, Activity, Question, Answer, UserProgress,LessonGroup, Animal, AnimalType
from django.utils.html import format_html
# User Admin
class UserAdmin(admin.ModelAdmin):
    list_display = ('username', 'phone', 'email', 'is_active', 'is_staff', 'is_superuser')
    search_fields = ('username', 'phone', 'email')
    list_filter = ('is_active', 'is_staff')

# UserProfile Admin
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'full_name', 'profile_picture_preview', 'address', 'bio']
    readonly_fields = ['profile_picture_preview']  # Админ дээр preview зураг харагддаг болно

    def profile_picture_preview(self, obj):
        if obj.profile_picture_base64:
            return format_html(
                '<img src="data:image/jpeg;base64,{}" width="60" height="60" style="object-fit: cover; border-radius: 6px;"/>',
                obj.profile_picture_base64
            )
        return "❌ Зураг алга"

    profile_picture_preview.short_description = "Зураг"

# School Admin
class SchoolAdmin(admin.ModelAdmin):
    list_display = ('name', 'icon', 'audio_tag')
    search_fields = ('name',)

    def audio_tag(self, obj):
     if obj.audio_base64:
        return format_html(f'<audio controls src="data:audio/mp3;base64,{obj.audio_base64}"></audio>')
     return "No audio"


# Subject Admin
class SubjectAdmin(admin.ModelAdmin):
    list_display = ('name', 'school', 'description', 'icon', 'audio_tag')
    search_fields = ('name',)
    list_filter = ('school',)
    def audio_tag(self, obj):
     if obj.audio_base64:
        return format_html(f'<audio controls src="data:audio/mp3;base64,{obj.audio_base64}"></audio>')
     return "No audio"
    
@admin.register(Animal)
class AnimalAdmin(admin.ModelAdmin):
    list_display = ('animal_name', 'subject', 'description', 'image_tag', 'audio_tag', 'video_tag')  # 🆕 video_tag нэмэгдлээ
    search_fields = ('animal_name', 'description')
    list_filter = ('subject',)

    def image_tag(self, obj):
        if obj.image:
            return format_html(f'<img src="{obj.image.url}" style="height:50px;"/>')
        return "No image"
    image_tag.short_description = 'Image'

    def audio_tag(self, obj):
        if obj.audio and hasattr(obj, 'audio_base64') and obj.audio_base64:
            return format_html(f'<audio controls src="data:audio/mp3;base64,{obj.audio_base64}"></audio>')
        return "No audio"
    audio_tag.short_description = 'Audio'

    def video_tag(self, obj):
        if obj.video and hasattr(obj, 'video_base64') and obj.video_base64:
            return format_html(f'''
                <video width="120" height="80" controls>
                    <source src="data:video/mp4;base64,{obj.video_base64}" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
            ''')
        return "No video"
    video_tag.short_description = 'Video'

@admin.register(AnimalType)
class AnimalTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'audio_tag')
    search_fields = ('name',)

    def audio_tag(self, obj):
        if obj.audio and hasattr(obj, 'audio') and obj.audio:
            try:
                with open(obj.audio.path, 'rb') as audio_file:
                    import base64
                    audio_base64 = base64.b64encode(audio_file.read()).decode('utf-8')
                    return format_html(f'<audio controls src="data:audio/mp3;base64,{audio_base64}"></audio>')
            except FileNotFoundError:
                return "Audio file not found"
        return "No audio"
    audio_tag.short_description = 'Audio'
# Lesson Admin
class LessonAdmin(admin.ModelAdmin):
    list_display = ('title', 'lesson_group', 'description', 'image', 'audio')
    search_fields = ('title',)
    list_filter = ('lesson_group',)

# Activity Admin
class ActivityAdmin(admin.ModelAdmin):
    list_display = ('title', 'type', 'lesson_group', 'content', 'audio_tag')
    search_fields = ('title', 'lesson_group__name')
    list_filter = ('lesson_group', 'type')
    
    filter_horizontal = ('animals',)  # 🐾 Амьтдыг сонгоход сайжруулалт

    def audio_tag(self, obj):
        if obj.audio:
            return format_html(f'<audio controls><source src="{obj.audio.url}" type="audio/mpeg"></audio>')
        return "No audio"
    audio_tag.short_description = 'Audio'
# Question Admin
class QuestionAdmin(admin.ModelAdmin):
    list_display = ('question_text', 'activity', 'type')
    search_fields = ('question_text',)
    list_filter = ('activity', 'type')
@admin.register(LessonGroup)
class LessonGroupAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'subject', 'description', 'image', 'audio_tag')
    list_filter = ('subject',)
    search_fields = ('name', 'description', 'subject__name')
    def audio_tag(self, obj):
     if obj.audio_base64:
        return format_html(f'<audio controls src="data:audio/mp3;base64,{obj.audio_base64}"></audio>')
     return "No audio"
# Answer Admin
class AnswerAdmin(admin.ModelAdmin):
    list_display = ('answer_text', 'question', 'is_correct')
    search_fields = ('answer_text',)
    list_filter = ('is_correct',)

# UserProgress Admin
class UserProgressAdmin(admin.ModelAdmin):
    list_display = ('user', 'lesson_group', 'score', 'completed', 'last_accessed')
    search_fields = ('user__phone', 'lesson_group__name')
    list_filter = ('completed', 'lesson_group')

# Register models in admin
admin.site.register(User, UserAdmin)
admin.site.register(UserProfile, UserProfileAdmin)
admin.site.register(School, SchoolAdmin)
admin.site.register(Subject, SubjectAdmin)
admin.site.register(Lesson, LessonAdmin)
admin.site.register(Activity, ActivityAdmin)
admin.site.register(Question, QuestionAdmin)
admin.site.register(Answer, AnswerAdmin)
admin.site.register(UserProgress, UserProgressAdmin)
