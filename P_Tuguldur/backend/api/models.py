from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone

# Шалгалтын ангилал (Grammar, Vocabulary гэх мэт)
class Category(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

# Түвшин (A1, A2, B1, B2)
class Level(models.Model):
    name = models.CharField(max_length=10)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='levels', default=1)  # Default category ID

    def __str__(self):
        return self.name

# Хичээл (тодорхой төрөл, төвшинд хамаарна)
class Lesson(models.Model):
    title = models.CharField(max_length=200)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    level = models.ForeignKey(Level, on_delete=models.CASCADE)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to='lessons/', blank=True, null=True)  # Хичээлийн зураг
  # Хичээлийн дуу

    def __str__(self):
        return f"{self.title} ({self.category.name} - {self.level.name})"

# Асуулт
class Question(models.Model):
    lesson = models.ForeignKey(Lesson, on_delete=models.CASCADE, related_name='questions')
    text = models.TextField()
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='questions',default=1)

    def __str__(self):
        return self.text

# Сонголт
class Choice(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='choices')
    text = models.CharField(max_length=255)
    is_correct = models.BooleanField(default=False)

    def __str__(self):
        return self.text

# Хэрэглэгчийн хариу
class UserAnswer(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    selected_choice = models.ForeignKey(Choice, on_delete=models.CASCADE)
    is_correct = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True)
# models.py

class TestResult(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    level = models.ForeignKey(Level, on_delete=models.CASCADE)
    score = models.DecimalField(max_digits=5, decimal_places=2)
    date_taken = models.DateTimeField(auto_now_add=True)
    answers = models.JSONField()  # Хариултуудыг хадгалах (question_id -> choice_id)
    
    def __str__(self):
        return f'{self.user} - {self.category} - {self.level} - {self.score}%'
class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)  # Хэрэглэгчтэй холбох
    last_test_score = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)  # Сүүлд өгсөн шалгалтын оноо
    last_test_date = models.DateTimeField(null=True, blank=True)  # Сүүлд өгсөн шалгалтын огноо
    last_test_category = models.ForeignKey('Category', null=True, blank=True, on_delete=models.SET_NULL)  # Тестийн ангилал
    last_test_level = models.ForeignKey('Level', null=True, blank=True, on_delete=models.SET_NULL)  # Тестийн төвшин

    def __str__(self):
        return f'{self.user.username} Profile'

    def update_test_result(self, score, category, level):
        """Хэрэглэгчийн сүүлд өгсөн тестийн дүнг шинэчлэх"""
        self.last_test_score = score
        self.last_test_category = category
        self.last_test_level = level
        self.last_test_date = timezone.now()
        self.save()
class Word(models.Model):
    english = models.CharField(max_length=100)
    mongolian = models.CharField(max_length=100)
    image = models.ImageField(upload_to='words/', blank=True, null=True)  # Үгийн зураг
    audio = models.FileField(upload_to='words/audio/', blank=True, null=True)  # Үгийн дуу

    def __str__(self):
        return self.english

class MyWord(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    word = models.ForeignKey(Word, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('user', 'word')
class TestQuestion(models.Model):
    LEVEL_CHOICES = [('A1', 'A1'), ('A2', 'A2'), ('B1', 'B1'), ('B2', 'B2'), ('C1', 'C1'), ('C2', 'C2')]
    level = models.CharField(max_length=2, choices=LEVEL_CHOICES)
    question = models.TextField()
    choice1 = models.CharField(max_length=255)
    choice2 = models.CharField(max_length=255)
    choice3 = models.CharField(max_length=255)
    choice4 = models.CharField(max_length=255)
    correct_choice = models.IntegerField()  # 1, 2, 3, or 4

class Result(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    score = models.IntegerField()
    level = models.CharField(max_length=2)
    incorrect_questions = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)

class news(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    image = models.ImageField(upload_to='news/', blank=True, null=True)  # Мэдээний зураг
    created_at = models.DateTimeField(auto_now_add=True)
    author = models.CharField(max_length=100, default='Admin')  # Мэдээний зохиогч
    def __str__(self):
        return self.title