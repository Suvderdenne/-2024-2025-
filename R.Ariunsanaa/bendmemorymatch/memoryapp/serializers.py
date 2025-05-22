from rest_framework import serializers
from .models import Player, Game, GameProgress

class PlayerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Player
        fields = ['id', 'name', 'created_at']

class GameSerializer(serializers.ModelSerializer):
    player_name = serializers.CharField(source='player.name', read_only=True)
    game_type_display = serializers.CharField(source='get_game_type_display', read_only=True)
    
    class Meta:
        model = Game
        fields = ['id', 'player', 'player_name', 'game_type', 'game_type_display', 'game_name', 'score', 'played_at']

class GameProgressSerializer(serializers.ModelSerializer):
    class Meta:
        model = GameProgress
        fields = ['id', 'player', 'game_type', 'current_level', 'score', 'card_images', 'flipped_cards', 'matched_cards', 'last_updated'] 