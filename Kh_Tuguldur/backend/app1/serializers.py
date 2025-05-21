from rest_framework import serializers
from django.contrib.auth.models import User
from .models import *
import mimetypes

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'email', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

class OptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Option
        fields = ['id', 'text', 'career_weight']

class QuestionSerializer(serializers.ModelSerializer):
    options = OptionSerializer(many=True, read_only=True)

    class Meta:
        model = Question
        fields = ['id', 'text', 'options']

class ResponseSerializer(serializers.Serializer):
    option_id = serializers.IntegerField()

# In serializers.py
class SubmitResponsesSerializer(serializers.Serializer):
    responses = serializers.ListField(
        child=serializers.DictField(
            child=serializers.IntegerField(),
            allow_empty=False
        )
    )
# class RecommendationHistorySerializer(serializers.ModelSerializer):
#     class Meta:
#         model = RecommendationHistory
#         fields = ['career', 'recommended_at']

class CareerInsightSerializer(serializers.ModelSerializer):
    image_base64 = serializers.SerializerMethodField()

    class Meta:
        model = CareerInsight
        fields = ['id', 'career', 'description', 'image', 'preparationTime', 'image_base64']

    def get_image_base64(self, obj):
        if obj.image and hasattr(obj.image, 'file'):
            full_base64 = base64.b64encode(obj.image.file.read()).decode('utf-8')
            return full_base64  # Return the full Base64 string
        return None

class CourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = ['id', 'name', 'career', 'description']  # Only return the course name and ID
class UniversitySerializer(serializers.ModelSerializer):
    image_base64 = serializers.SerializerMethodField()

    class Meta:
        model = University
        fields = ['id', 'name', 'description', 'image', 'image_base64']

    def get_image_base64(self, obj):
        if obj.image:
            try:
                mime_type, _ = mimetypes.guess_type(obj.image.name)
                with obj.image.open('rb') as image_file:
                    full_base64 = base64.b64encode(image_file.read()).decode('utf-8')
                    return f'data:{mime_type};base64,{full_base64}'  # Return the full Base64 string
            except Exception as e:
                print(f"Error encoding image: {e}")
        return None
class CareerDetailsSerializer(serializers.ModelSerializer):
    career = CareerInsightSerializer()
    name = serializers.CharField(source='career.career')
    course = CourseSerializer(many=True, read_only=True)
    university = UniversitySerializer(many=True, read_only=True)
    image_base64 = serializers.SerializerMethodField()

    class Meta:
        model = CareerDetails
        fields = [
            'id',
            'name',
            'description',
            'image_base64',  
            'preparationTime',
            'salary',
            'purpose',
            'course',
            'university',
            'career'
        ]

    def get_image_base64(self, obj):
        if obj.image:
            try:
                with obj.image.open('rb') as image_file:
                    full_base64 = base64.b64encode(image_file.read()).decode('utf-8')
                    return full_base64  # Return the full Base64 string
            except Exception as e:
                return None
        return None

class JobListingSerializer(serializers.Serializer):
    title = serializers.CharField()
    company = serializers.CharField()
    location = serializers.CharField()
    url = serializers.URLField()



class UniversityDetailsSerializer(serializers.ModelSerializer):
    university_name = serializers.CharField(source="university.name", read_only=True)
    image_base64 = serializers.SerializerMethodField()
    career_names = serializers.SerializerMethodField()

    class Meta:
        model = UniversityDetails
        fields = [
            'id', 'university_name', 'name', 'ranking', 'description', 'website',
            'location', 'email', 'phone', 'price', 'career_names', 'image', 'image_base64'
        ]

    def get_career_names(self, obj):
        return [career.career for career in obj.careers.all()]

    def get_image_base64(self, obj):
        if obj.image:
            try:
                mime_type, _ = mimetypes.guess_type(obj.image.name)
                with obj.image.open('rb') as image_file:
                    full_base64 = base64.b64encode(image_file.read()).decode('utf-8')
                    return f'data:{mime_type};base64,{full_base64}'  # Return the full Base64 string
            except Exception as e:
                print(f"Error encoding image: {e}")
        return None

class NewsSerializer(serializers.ModelSerializer):
    image_base64 = serializers.SerializerMethodField()

    class Meta:
        model = News
        fields = ['id', 'title', 'description', 'image_base64']

    def get_image_base64(self, obj):
        if obj.image and hasattr(obj.image, 'path'):
            try:
                with open(obj.image.path, 'rb') as image_file:
                    full_base64 = base64.b64encode(image_file.read()).decode('utf-8')
                    return 'data:image/jpeg;base64,' + full_base64  # Return the full Base64 string
            except Exception as e:
                print(f"Error reading News image: {e}")
        return None


class NewsDetailsSerializer(serializers.ModelSerializer):
    image_base64 = serializers.SerializerMethodField()
    news = NewsSerializer()

    class Meta:
        model = NewsDetails
        fields = ['id', 'news', 'title', 'description', 'image_base64', 'created_at', 'publisher', 'source']

    def get_image_base64(self, obj):
        if obj.image and hasattr(obj.image, 'path'):
            try:
                with open(obj.image.path, 'rb') as image_file:
                    full_base64 = base64.b64encode(image_file.read()).decode('utf-8')
                    return 'data:image/jpeg;base64,' + full_base64  # Return the full Base64 string
            except Exception as e:
                print(f"Error reading NewsDetails image: {e}")
        return None
class RecommendationHistorySerializer(serializers.ModelSerializer):
    high_school_subjects = serializers.ListField(
        child=serializers.CharField(),
        source='get_high_school_subjects',
        read_only=True
    )
    recommended_universities = serializers.ListField(
        child=serializers.CharField(),
        source='get_recommended_universities',
        read_only=True
    )

    class Meta:
        model = RecommendationHistory
        fields = [
            'id',
            'user',
            'suggested_career',
            'explanation',
            'high_school_subjects',
            'recommended_universities',
            'responses_json',
            'recommended_at',
        ]
        read_only_fields = ['user', 'recommended_at']

    def to_representation(self, instance):
        """Customize output to convert CSV strings into lists."""
        ret = super().to_representation(instance)
        ret['high_school_subjects'] = instance.high_school_subjects.split(',') if instance.high_school_subjects else []
        ret['recommended_universities'] = instance.recommended_universities.split(',') if instance.recommended_universities else []
        return ret
class PostSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    likes_count = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = [
            'id',
            'user',
            'title',
            'content',
            'image',
            'video',
            'created_at',
            'likes_count',
            'is_liked',  # ✅ <-- Add this line!
        ]

    def get_likes_count(self, obj):
        return obj.like_set.count()

    def get_is_liked(self, obj):
        user = self.context['request'].user
        if user.is_authenticated:
            return obj.like_set.filter(user=user).exists()
        return False

    def validate(self, data):
        if data.get('image') and data.get('video'):
            raise serializers.ValidationError("You can only upload either an image or a video, not both.")
        return data


class EditPostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ['title', 'content', 'image', 'video']

    def validate(self, data):
        if data.get('image') and data.get('video'):
            raise serializers.ValidationError("You can only upload either an image or a video, not both.")
        return data


class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    replies = serializers.SerializerMethodField()

    class Meta:
        model = Comment
        fields = ['id', 'user', 'post', 'content', 'created_at', 'parent', 'replies']

    def get_replies(self, obj):
        if obj.replies.exists():
            return CommentSerializer(obj.replies.all(), many=True).data
        return []

class LikeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Like
        fields = ['id', 'user', 'post', 'created_at']
class EditCommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ['content'] 