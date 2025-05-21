from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.conf import settings
import base64
import ffmpeg
from PIL import Image
import os
from io import BytesIO
from django.core.files.base import ContentFile
from django.core.exceptions import ValidationError
# Custom User Manager
class UserManager(BaseUserManager):
    def create_user(self, phone, password=None, **extra_fields):
        if not phone:
            raise ValueError('The Phone field must be set')
        user = self.model(phone=phone, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, phone, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(phone, password, **extra_fields)


# User Model
class User(AbstractBaseUser):
    username = models.CharField(max_length=100)
    phone = models.CharField(max_length=15, unique=True)
    email = models.EmailField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['username']

    objects = UserManager()

    def __str__(self):
        return self.phone


# UserProfile Model
class UserProfile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    full_name = models.CharField(max_length=100, blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', blank=True, null=True)  # Allow image upload
    address = models.TextField(blank=True, null=True)
    bio = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.user.username} - {self.full_name}"

    @property
    def image_base64(self):
        if self.profile_picture:
            try:
                with self.profile_picture.open('rb') as img_file:  # Use the open method provided by ImageField
                    return base64.b64encode(img_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None


# School Model
class School(models.Model):
    name = models.CharField(max_length=100)
    icon = models.ImageField(
        upload_to='subject_icons/',
        default='subject_icons/default.jpg'
    )   
    audio = models.FileField(upload_to='school_audios/', blank=True, null=True)

    def __str__(self):
        return self.name

    @property
    def audio_base64(self):
        if self.audio and self.audio.path:
            try:
                with open(self.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None


# Subject Model
class Subject(models.Model):
    school = models.ForeignKey(School, related_name='subjects', on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    description = models.TextField()
    icon = models.ImageField(
        upload_to='subject_icons/',
        default='subject_icons/default.jpg'
    )
    audio = models.FileField(upload_to='subjects_audios/', blank=True, null=True)

    def __str__(self):
        return self.name
    @property
    def audio_base64(self):
        if self.audio and self.audio.path:
            try:
                with open(self.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None
    
import base64  # ensure you have this at the top
from django.db import models

def validate_video(value):
        max_size = 500 * 1000 * 1000
        if value.size > max_size:
            raise ValidationError("hemjee chini ihdeed bn boldoo")

class Animal(models.Model):
    subject = models.ForeignKey('Subject', related_name='animals', on_delete=models.CASCADE)
    animal_name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    image = models.ImageField(upload_to='animal_images/', default='animal_images/default.jpg')
    audio = models.FileField(upload_to='animal_audios/', blank=True, null=True)
    video = models.FileField(upload_to='animal_videos/', blank=True, null=True , validators=[validate_video])
    animal_type = models.ForeignKey('AnimalType', related_name='animals', on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        return self.animal_name

    def save(self, *args, **kwargs):
        # 🖼️ Зураг compress хийх
        if self.image:
            try:
                img = Image.open(self.image)
                if img.mode != 'RGB':
                    img = img.convert('RGB')
                img_io = BytesIO()
                img.save(img_io, 'JPEG', quality=60)  # 60% чанар
                self.image.save(self.image.name, ContentFile(img_io.getvalue()), save=False)
            except Exception as e:
                print(f"Image compression error: {e}")

        # 🎥 Видео compress хийх
        if self.video and hasattr(self.video, 'path'):
            input_path = self.video.path
            filename, ext = os.path.splitext(input_path)
            output_path = f"{filename}_compressed{ext}"
            try:
                ffmpeg.input(input_path).output(output_path, vcodec='libx264', crf=28).run(overwrite_output=True)
                with open(output_path, 'rb') as f:
                    self.video.save(os.path.basename(output_path), ContentFile(f.read()), save=False)
                os.remove(output_path)  # Түр файл устгах
            except Exception as e:
                print(f"Video compression error: {e}")

        super().save(*args, **kwargs)

    @property
    def image_base64(self):
        if self.image and self.image.path:
            try:
                with open(self.image.path, 'rb') as img_file:
                    return base64.b64encode(img_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

    @property
    def audio_base64(self):
        if self.audio and self.audio.path:
            try:
                with open(self.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

    @property
    
    def video_base64(self):
        if self.video and self.video.path:
            try:
                with open(self.video.path, 'rb') as video_file:
                    return base64.b64encode(video_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

class AnimalType(models.Model):
    name = models.CharField(max_length=100)
    audio = models.FileField(upload_to='animaltype_audios/', blank=True, null=True)

    def __str__(self):
        return self.name

    @property
    def audio_base64(self):
        if self.audio and self.audio.path:
            try:
                with open(self.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

# Lesson Group Model
class LessonGroup(models.Model):
    subject = models.ForeignKey(Subject, related_name='lesson_groups', on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    description = models.TextField()
    image = models.ImageField(
        upload_to='lesson_group_images/',
        default='lesson_group_images/default.jpg'
    )
    audio = models.FileField(upload_to='lesson_group_audios/', blank=True, null=True)
    def __str__(self):
        return self.name
    @property
    def audio_base64(self):
        if self.audio and self.audio.path:
            try:
                with open(self.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

# Lesson Model
class Lesson(models.Model):
    lesson_group = models.ForeignKey(LessonGroup, related_name='lessons', on_delete=models.CASCADE)
    title = models.CharField(max_length=100)
    description = models.TextField()
    image = models.ImageField(
        upload_to='lesson_images/',
        default='lesson_images/default.jpg'
    )
    audio = models.FileField(upload_to='lesson_audios/', blank=True, null=True)

    def __str__(self):
        return self.title


# Activity Model
class Activity(models.Model):
    lesson_group = models.ForeignKey('LessonGroup', related_name='activities', on_delete=models.CASCADE, null=True, blank=True)
    TYPE_CHOICES = [('танин мэдэх', 'Танин мэдэх'), ('асуулт', 'Асуулт'), ('холбох', 'Холбох')]
    type = models.CharField(max_length=50, choices=TYPE_CHOICES)
    title = models.CharField(max_length=100)
    content = models.TextField()
    audio = models.FileField(upload_to='lesson_audios/', blank=True, null=True)

    # 🐾 Амьтадтай холбох
    animals = models.ManyToManyField('Animal', related_name='activities', blank=True)

    def __str__(self):
        return self.title

    @property
    def audio_base64(self):
        if self.audio and self.audio.path:
            try:
                with open(self.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None


# Question Model
class Question(models.Model):
    activity = models.ForeignKey(Activity, related_name='questions', on_delete=models.CASCADE)
    question_text = models.TextField()
    image = models.ImageField(
        upload_to='question_images/',
        blank=True,
        null=True,
        default='question_images/default.jpg'
    )
    audio = models.FileField(upload_to='question_audios/', blank=True, null=True)
    TYPE_CHOICES = [('сонгох', 'Сонгох'), ('нээлттэй', 'Нээлттэй'), ('зураг-холбох', 'Зураг-холбох')]
    type = models.CharField(max_length=50, choices=TYPE_CHOICES)

    def __str__(self):
        return self.question_text
    
    @property
    def get_image_base64(self, obj):
        if obj.image:
            with obj.image.open('rb') as f:
                return base64.b64encode(f.read()).decode('utf-8')
        else:
            return ""  # Empty string returned for empty images

    def get_audio_base64(self, obj):
        if obj.audio:
            with obj.audio.open('rb') as f:
                return base64.b64encode(f.read()).decode('utf-8')
        else:
            return ""  # Empty string returned for empty audio

# Answer Model
class Answer(models.Model):
    question = models.ForeignKey(Question, related_name='answers', on_delete=models.CASCADE)
    answer_text = models.TextField()
    is_correct = models.BooleanField(default=False)
    image = models.ImageField(
        upload_to='answer_images/',
        blank=True,
        null=True,
        default='answer_images/default.jpg'
    )
    audio = models.FileField(upload_to='answer_audios/', blank=True, null=True)

    def __str__(self):
        return self.answer_text

    @property
    def image_base64(self):
        if self.image and self.image.path:
            try:
                with open(self.image.path, 'rb') as img_file:
                    return base64.b64encode(img_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None
    
    @property
    def audio_base64(self):
        if self.audio and self.audio.path:
            try:
                with open(self.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None
# UserProgress Model
class UserProgress(models.Model):
    user = models.ForeignKey(User, related_name='progress', on_delete=models.CASCADE)
    lesson_group = models.ForeignKey('LessonGroup', related_name='user_progress', on_delete=models.CASCADE, null=True, blank=True)
    score = models.IntegerField(default=0)
    completed = models.BooleanField(default=False)
    last_accessed = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'{self.user} - {self.lesson_group}'