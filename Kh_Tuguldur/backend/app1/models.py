from django.db import models
from django.contrib.auth.models import User
import google.generativeai as genai
import base64
from django.core.files.base import ContentFile


class CareerInsight(models.Model):
    career = models.CharField(max_length=255, unique=True)
    description = models.TextField(null=True, blank=True)
    image = models.ImageField(upload_to="career_images/", null=True, blank=True)
    preparationTime = models.CharField(max_length=255, null=True, blank=True)

    def __str__(self):
        return self.career

    def image_base64(self):
        if self.image and hasattr(self.image, 'file'):
            return base64.b64encode(self.image.file.read()).decode('utf-8')
        return None

class CareerDetails(models.Model):
    career = models.OneToOneField(CareerInsight, on_delete=models.CASCADE, related_name="details")
    name = models.CharField(max_length=255, unique=True, default="Unknown Career")
    description = models.TextField(null=True, blank=True)
    image = models.ImageField(upload_to="career_images/", null=True, blank=True)
    preparationTime = models.CharField(max_length=255, null=True, blank=True)
    salary = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    purpose = models.TextField(null=True, blank=True)
    course = models.ManyToManyField('Course', blank=True)
    university = models.ManyToManyField('University', blank=True)

    def __str__(self):
        return self.name

    def image_base64(self):
        if self.image and hasattr(self.image, 'file'):
            return base64.b64encode(self.image.file.read()).decode('utf-8')
        return None

class Course(models.Model):
    name = models.CharField(max_length=255)
    career = models.ForeignKey(CareerInsight, on_delete=models.CASCADE, related_name="courses")  
    description = models.TextField()

    def __str__(self):
        return self.name
class RecommendationHistory(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    suggested_career = models.CharField(max_length=255, default="Unknown Career")  # ✅ Default added
    explanation = models.TextField(null=True, blank=True)
    high_school_subjects = models.TextField(default="Unknown")
    recommended_universities = models.TextField(default="Unknown University")
    responses_json = models.JSONField(default=dict)
    recommended_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.suggested_career}"
class University(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    image = models.ImageField(upload_to="university_images/", null=True, blank=True)

    def __str__(self):
        return self.name


class UniversityDetails(models.Model):
    university = models.OneToOneField(University, on_delete=models.CASCADE, related_name="details")
    name = models.CharField(max_length=255)  # Added university name
    ranking = models.IntegerField(null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    website = models.URLField(null=True, blank=True)
    location = models.CharField(max_length=255)
    email = models.EmailField(null=True, blank=True)
    phone = models.CharField(max_length=20, null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)  # Tuition fees
    careers = models.ManyToManyField(CareerInsight, blank=True)  # Related careers
    image = models.ImageField(upload_to="uniDetails_images/", null=True, blank=True)

    def __str__(self):
        return f"{self.name} - Details"


class Question(models.Model):
    text = models.CharField(max_length=255)

    def __str__(self):
        return self.text


class Option(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    text = models.CharField(max_length=255)
    career_weight = models.JSONField(default=dict)  # Ensure it always has data

    def __str__(self):
        return f"{self.text} (Q: {self.question.text})"

class UserResponse(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    selected_option = models.ForeignKey(Option, on_delete=models.CASCADE)


class News(models.Model):
    title = models.CharField(max_length=150)
    description = models.TextField(null=True, blank=True)
    image = models.ImageField(upload_to="news_images/", null=True, blank=True)
    def __str__(self):
        return self.title
class NewsDetails(models.Model):
    news = models.OneToOneField(News, on_delete=models.CASCADE, related_name="details")
    title = models.CharField(max_length=150)
    description = models.TextField(null=True, blank=True)
    image = models.ImageField(upload_to="newsdetails_images/", null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    publisher = models.CharField(max_length=150)
    source = models.URLField()
    def __str__(self):
        return f"{self.title} - Details"


class Post(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    content = models.TextField(blank=True)
    image = models.ImageField(upload_to='post_images/', blank=True, null=True)
    video = models.FileField(upload_to='post_videos/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} - {self.user.username}"
class Comment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    parent = models.ForeignKey('self', null=True, blank=True, on_delete=models.CASCADE, related_name='replies')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)


class Like(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    post = models.ForeignKey(Post, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ['user', 'post']

# Configure Generative AI
genai.configure(api_key="AIzaSyCkyRZR6f38Lg8KtoFEoEtY-9-klbwDRkM")
models = genai.list_models()

for model in models:
    print(model.name)