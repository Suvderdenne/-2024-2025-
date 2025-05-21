# admin.py

from django.contrib import admin
from .models import Category, Level, Lesson, Question, Choice, UserAnswer, TestResult, UserProfile, MyWord, Word,TestQuestion,Result,news

# Category - Шалгалтын ангилал
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name',)
    search_fields = ('name',)

# Level - Түвшин (A1, A2, B1, B2)
class LevelAdmin(admin.ModelAdmin):
    list_display = ('name',)
    search_fields = ('name',)

# Lesson - Хичээл
class LessonAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'level')
    search_fields = ('title',)
    list_filter = ('category', 'level')

# Question - Асуулт
class QuestionAdmin(admin.ModelAdmin):
    list_display = ('lesson', 'text')
    search_fields = ('text',)
    list_filter = ('lesson',)

# Choice - Сонголт
class ChoiceAdmin(admin.ModelAdmin):
    list_display = ('question', 'text', 'is_correct')
    search_fields = ('text',)
    list_filter = ('question', 'is_correct')

# UserAnswer - Хэрэглэгчийн хариу
class UserAnswerAdmin(admin.ModelAdmin):
    list_display = ('user', 'question', 'selected_choice', 'is_correct', 'created_at')
    search_fields = ('user__username', 'question__text',)
    list_filter = ('is_correct',)

# TestResult - Шалгалтын дүн
class TestResultAdmin(admin.ModelAdmin):
    list_display = ('user', 'category', 'level', 'score', 'date_taken')
    search_fields = ('user__username', 'category__name', 'level__name')
    list_filter = ('category', 'level', 'date_taken')

# UserProfile - Хэрэглэгчийн профайл
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'last_test_score', 'last_test_category', 'last_test_level', 'last_test_date')
    search_fields = ('user__username',)
    list_filter = ('last_test_category', 'last_test_level', 'last_test_date')

@admin.register(MyWord)
class MyWordAdmin(admin.ModelAdmin):
    list_display = ('user', 'word')
    search_fields = ('user__username', 'word__english_word')

@admin.register(Word)
class WordAdmin(admin.ModelAdmin):
    list_display = ('english', 'mongolian')  # Use the correct field names
    search_fields = ('english', 'mongolian')
@admin.register(TestQuestion)
class TestQuestionAdmin(admin.ModelAdmin):
    list_display = ('question', 'level', 'correct_choice')
    list_filter = ('level',)
    search_fields = ('question', 'choice1', 'choice2', 'choice3', 'choice4')
class newsAdmin(admin.ModelAdmin):
    list_display = ('title', 'created_at','author')
    search_fields = ('title', 'content')
    list_filter = ('created_at',)
admin.site.register(news, newsAdmin)
@admin.register(Result)
class ResultAdmin(admin.ModelAdmin):
    list_display = ('user', 'score', 'level', 'created_at')
    list_filter = ('level', 'created_at')
    search_fields = ('user__username',)
    readonly_fields = ('created_at', 'incorrect_questions')
# Бүх моделийг админд бүртгэх
admin.site.register(Category, CategoryAdmin)
admin.site.register(Level, LevelAdmin)
admin.site.register(Lesson, LessonAdmin)
admin.site.register(Question, QuestionAdmin)
admin.site.register(Choice, ChoiceAdmin)
admin.site.register(UserAnswer, UserAnswerAdmin)
admin.site.register(TestResult, TestResultAdmin)
admin.site.register(UserProfile, UserProfileAdmin)
