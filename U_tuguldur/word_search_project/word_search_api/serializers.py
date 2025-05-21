from rest_framework import serializers
from .models import Level, Word, GridData, UserProfile
from django.contrib.auth.models import User

class WordSerializer(serializers.ModelSerializer):
    class Meta:
        model = Word
        fields = ['word', 'language']

class LevelSerializer(serializers.ModelSerializer):
    words = serializers.SerializerMethodField()

    class Meta:
        model = Level
        fields = ['level_number', 'grid_size', 'category', 'words']

    def get_words(self, obj):
        language = self.context.get('language')
        if language:
            return WordSerializer(obj.words.filter(language=language), many=True).data
        return WordSerializer(obj.words.all(), many=True).data


class GridDataSerializer(serializers.ModelSerializer):
    class Meta:
        model = GridData
        fields = ['data']

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password']
        )
        return user


class UserProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = UserProfile
        fields = ['user', 'coins', 'completed_levels', 'english_words_guessed', 'mongolian_words_guessed']