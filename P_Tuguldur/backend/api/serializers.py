from rest_framework import serializers
from .models import Category, Level, Lesson, Question, Choice, UserProfile,UserAnswer,TestResult,Word, MyWord,TestQuestion,Result,news
from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from django.conf import settings
import base64
from django.core.files.base import ContentFile
class ChoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Choice
        fields = ['id', 'text']

class QuestionSerializer(serializers.ModelSerializer):
    choices = ChoiceSerializer(many=True)

    class Meta:
        model = Question
        fields = ['id', 'text', 'choices']

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name'] # Keep these as they are

class LevelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Level
        fields = ['id', 'name'] # Keep these as they are

class LessonSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    image_base64 = serializers.SerializerMethodField()

    category = CategorySerializer(read_only=True)
    level = LevelSerializer(read_only=True)

    class Meta:
        model = Lesson
        fields = ['id', 'title', 'category', 'level', 'description', 'image_url', 'image_base64']

    def get_image_url(self, obj):
        # Return the full media URL for the image
        if obj.image:
            return f"{settings.MEDIA_URL}{obj.image}"
        return None

    def get_image_base64(self, obj):
        # Convert the image to Base64
        if obj.image and obj.image.path:
            try:
                with open(obj.image.path, "rb") as img_file:
                    return base64.b64encode(img_file.read()).decode('utf-8')
            except Exception as e:
                return None
        return None

class UserAnswerCreateSerializer(serializers.Serializer):
    question_id = serializers.IntegerField()
    selected_choice_id = serializers.IntegerField()

class SubmitTestSerializer(serializers.Serializer):
    user_id = serializers.IntegerField()
    answers = UserAnswerCreateSerializer(many=True)
# serializers.py

class TestResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = TestResult
        fields = ['user', 'category', 'level', 'score', 'date_taken', 'answers']
class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("This username is already taken. Please choose a different one.")
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email'),
            password=validated_data['password']
        )
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        user = authenticate(username=data['username'], password=data['password'])
        if not user:
            raise serializers.ValidationError("Invalid credentials")
        data['user'] = user
        return data

class WordSerializer(serializers.ModelSerializer):
    audio_base64 = serializers.SerializerMethodField()
    image_base64 = serializers.SerializerMethodField()

    class Meta:
        model = Word
        fields = ['id', 'english', 'mongolian', 'image_base64', 'audio_base64']

    def get_audio_base64(self, obj):
        if obj.audio and obj.audio.path:
            try:
                with open(obj.audio.path, "rb") as audio_file:
                    return base64.b64encode(audio_file.read()).decode('utf-8')
            except:
                return None
        return None

    def get_image_base64(self, obj):
        if obj.image and obj.image.path:
            try:
                with open(obj.image.path, "rb") as img_file:
                    return base64.b64encode(img_file.read()).decode('utf-8')
            except:
                return None
        return None

class MyWordSerializer(serializers.ModelSerializer):
    word = WordSerializer(read_only=True)

    class Meta:
        model = MyWord
        fields = ['id', 'word']
class TestQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = TestQuestion
        fields = ['id', 'question', 'choice1', 'choice2', 'choice3', 'choice4']

class TestResultSerializer(serializers.ModelSerializer):
    incorrect_questions = serializers.SerializerMethodField()

    class Meta:
        model = Result
        fields = ['score', 'total', 'level', 'level_description', 'incorrect_questions']

    def get_incorrect_questions(self, obj):
        result_data = []
        for iq in obj.incorrect_answers.all():
            question = iq.question
            result_data.append({
                'question': question.question,
                'your_answer': iq.your_answer,
                'your_answer_text': getattr(question, f'choice{iq.your_answer}', 'N/A'),
                'correct_answer': iq.correct_answer,
                'correct_answer_text': getattr(question, f'choice{iq.correct_answer}', 'N/A'),
            })
        return result_data
class newsSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    image_base64 = serializers.SerializerMethodField()

    class Meta:
        model = news
        fields = ['id', 'title', 'content', 'created_at', 'image_url', 'image_base64', 'author']

    def get_image_url(self, obj):
        # Return the full media URL for the image
        if obj.image:
            return f"{settings.MEDIA_URL}{obj.image}"
        return None

    def get_image_base64(self, obj):
        # Convert the image to Base64
        if obj.image and obj.image.path:
            try:
                with open(obj.image.path, "rb") as img_file:
                    return base64.b64encode(img_file.read()).decode('utf-8')
            except Exception as e:
                return None
        return None  # Add 'image' field here if you have it in your model

class UserProfileSerializer(serializers.ModelSerializer):
    # Access username and email from the related User model
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    # last_test_score and last_test_level are directly on UserProfile
    # last_test_level is a CharField, so no special handling needed here

    # SerializerMethodField to get the incorrect questions from the latest result
    incorrect_questions = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        # Include fields from User and UserProfile, plus the method field
        fields = ['username', 'email', 'last_test_score', 'last_test_level', 'incorrect_questions']

    def get_incorrect_questions(self, obj):
        # obj is the UserProfile instance for the current user
        user = obj.user

        # Find the most recent Result for this user, ordered by creation date descending
        latest_result = Result.objects.filter(user=user).order_by('-created_at').first()

        # If a result exists and it has incorrect questions data
        if latest_result and latest_result.incorrect_questions:
            # Return the JSON data directly.
            # We assume the SubmitView has saved the data in the correct format
            # including the text fields, matching the Flutter model expectation.
            return latest_result.incorrect_questions
        return [] # Return an empty list if no results or no incorrect questions
