import base64
from rest_framework import serializers
from .models import *
import uuid
from django.core.files.base import ContentFile
# ========== User Serializers ==========

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'phone', 'email', 'is_active', 'is_staff', 'is_superuser']


class UserProfileSerializer(serializers.ModelSerializer):
    profile_picture_base64 = serializers.CharField(write_only=True, required=False)
    
    class Meta:
        model = UserProfile
        fields = ['full_name', 'profile_picture_base64', 'address', 'bio']

    def update(self, instance, validated_data):
        base64_image = validated_data.pop('profile_picture_base64', None)
        if base64_image:
            try:
                format, imgstr = base64_image.split(';base64,')  # data:image/png;base64,...
                ext = format.split('/')[-1]
                file_name = f"{uuid.uuid4()}.{ext}"
                instance.profile_picture.save(file_name, ContentFile(base64.b64decode(imgstr)), save=False)
            except Exception as e:
                raise serializers.ValidationError({'profile_picture_base64': 'Invalid base64 image format.'})

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance

# Хэрэглэгч болон түүний профайлын сериализер
class UserWithProfileSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer()

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'is_active', 'is_staff', 'is_superuser', 'profile']

# ========== School and Subject ==========

class SchoolSerializer(serializers.ModelSerializer):
    icon_base64 = serializers.SerializerMethodField()
    audio_base64 = serializers.SerializerMethodField()

    class Meta:
        model = School
        fields = ['id', 'name', 'icon_base64', 'audio_base64']

    def get_icon_base64(self, obj):
        if obj.icon and hasattr(obj.icon, 'path'):
            with open(obj.icon.path, 'rb') as image_file:
                return base64.b64encode(image_file.read()).decode('utf-8')
        return None

    def get_audio_base64(self, obj):
        if obj.audio and hasattr(obj.audio, 'path'):
            try:
                with open(obj.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None


class SubjectSerializer(serializers.ModelSerializer):
    school = SchoolSerializer()
    icon_base64 = serializers.SerializerMethodField()
    audio_base64 = serializers.SerializerMethodField()
    class Meta:
        model = Subject
        fields = ['id', 'name', 'school', 'description', 'icon_base64', 'audio_base64']

    def get_icon_base64(self, obj):
        if obj.icon:
            with obj.icon.open('rb') as f:
                return base64.b64encode(f.read()).decode('utf-8')
        return None
    def get_audio_base64(self, obj):
        if obj.audio and hasattr(obj.audio, 'path'):
            try:
                with open(obj.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

class AnimalSerializer(serializers.ModelSerializer):
    image_base64 = serializers.SerializerMethodField()
    audio_base64 = serializers.SerializerMethodField()
    video_base64 = serializers.SerializerMethodField()

    class Meta:
        model = Animal
        fields = [
            'id',
            'animal_name',
            'description',
            'image_base64',
            'audio_base64',
            'video_base64',
        ]

    def get_image_base64(self, obj):
        if obj.image and hasattr(obj.image, 'path'):
            try:
                with open(obj.image.path, 'rb') as image_file:
                    return base64.b64encode(image_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

    def get_audio_base64(self, obj):
        if obj.audio and hasattr(obj.audio, 'path'):
            try:
                with open(obj.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

    def get_video_base64(self, obj):
        if obj.video and hasattr(obj.video, 'path'):
            try:
                with open(obj.video.path, 'rb') as video_file:
                    return base64.b64encode(video_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

class AnimalTypeSerializer(serializers.ModelSerializer):
    audio_base64 = serializers.SerializerMethodField()
    animals = serializers.SerializerMethodField()  # 🐾 Add this

    class Meta:
        model = AnimalType
        fields = ['id', 'name', 'audio_base64', 'animals']  # 🐾 Add 'animals'

    def get_audio_base64(self, obj):
        if obj.audio and hasattr(obj.audio, 'path'):
            try:
                with open(obj.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

    def get_animals(self, obj):
        animals = obj.animals.all()  # 'animals' is the related_name from the Animal model
        return AnimalSerializer(animals, many=True).data
# ========== Lesson Group ==========

class LessonGroupSerializer(serializers.ModelSerializer):
    image_base64 = serializers.SerializerMethodField()

    class Meta:
        model = LessonGroup
        fields = ['id', 'subject', 'name', 'description', 'image_base64', 'audio_base64']

    def get_image_base64(self, obj):
        if obj.image:
            with obj.image.open('rb') as image_file:
                return base64.b64encode(image_file.read()).decode('utf-8')
        return None
    def get_audio_base64(self, obj):
        if obj.audio and hasattr(obj.audio, 'path'):
            try:
                with open(obj.audio.path, 'rb') as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except FileNotFoundError:
                return None
        return None

# ========== Lesson ==========

class LessonSerializer(serializers.ModelSerializer):
    lesson_group = serializers.StringRelatedField()
    image_base64 = serializers.SerializerMethodField()
    audio_base64 = serializers.SerializerMethodField()

    class Meta:
        model = Lesson
        fields = ['id', 'lesson_group', 'title', 'description', 'image_base64', 'audio_base64']

    def get_image_base64(self, obj):
        if obj.image:
            with obj.image.open('rb') as f:
                return base64.b64encode(f.read()).decode('utf-8')
        return None

    def get_audio_base64(self, obj):
        if obj.audio:
            with obj.audio.open('rb') as f:
                return base64.b64encode(f.read()).decode('utf-8')
        return None


# ========== Activity ==========

class ActivitySerializer(serializers.ModelSerializer):
    audio_base64 = serializers.SerializerMethodField()
    animals = AnimalSerializer(many=True, read_only=True)  # 🐾 холбоотой амьтад

    class Meta:
        model = Activity
        fields = ['id', 'lesson_group', 'type', 'title', 'content', 'audio_base64', 'animals']

    def get_audio_base64(self, obj):
        return obj.audio_base64

# ========== Question ==========

class QuestionSerializer(serializers.ModelSerializer):
    activity = ActivitySerializer()
    image_base64 = serializers.SerializerMethodField()
    audio_base64 = serializers.SerializerMethodField()

    class Meta:
        model = Question
        fields = ['id', 'activity', 'question_text', 'image_base64', 'audio_base64', 'type']

    def get_image_base64(self, obj):
        if obj.image:
            with obj.image.open('rb') as f:
                return base64.b64encode(f.read()).decode('utf-8')
        return None

    def get_audio_base64(self, obj):
        if obj.audio:
            with obj.audio.open('rb') as f:
                return base64.b64encode(f.read()).decode('utf-8')
        return None



# ========== Answer ==========

class AnswerSerializer(serializers.ModelSerializer):
    question = QuestionSerializer()
    image_base64 = serializers.SerializerMethodField()
    audio_base64 = serializers.SerializerMethodField()

    class Meta:
        model = Answer
        fields = ['id', 'question', 'answer_text', 'is_correct', 'image_base64', 'audio_base64']

    def get_image_base64(self, obj):
        if obj.image:
            with obj.image.open('rb') as f:
                return base64.b64encode(f.read()).decode('utf-8')
        return None

    def get_audio_base64(self, obj):
        if obj.audio:
            with obj.audio.open('rb') as f:
                return base64.b64encode(f.read()).decode('utf-8')
        return None


# ========== User Progress ==========

class UserProgressSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    lesson = LessonSerializer()

    class Meta:
        model = UserProgress
        fields = ['id', 'user', 'lesson_group', 'score', 'completed', 'last_accessed']
