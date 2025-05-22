from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.response import Response
from .models import Player, Game, GameProgress
from .serializers import PlayerSerializer, GameSerializer, GameProgressSerializer
from rest_framework.decorators import api_view
from rest_framework.decorators import action

# Create your views here.

class PlayerViewSet(viewsets.ModelViewSet):
    queryset = Player.objects.all()
    serializer_class = PlayerSerializer

    @action(detail=False, methods=['get'], url_path='check-name/(?P<name>[^/.]+)')
    def check_name(self, request, name=None):
        exists = Player.objects.filter(name=name).exists()
        return Response({'exists': exists})

    def create(self, request, *args, **kwargs):
        # Check for duplicate name before creating
        name = request.data.get('name')
        if Player.objects.filter(name=name).exists():
            return Response(
                {'error': 'This name is already taken'},
                status=400
            )
        return super().create(request, *args, **kwargs)

class GameViewSet(viewsets.ModelViewSet):
    queryset = Game.objects.all()
    serializer_class = GameSerializer

class GameProgressViewSet(viewsets.ModelViewSet):
    queryset = GameProgress.objects.all()
    serializer_class = GameProgressSerializer

    @action(detail=False, methods=['get'])
    def get_progress(self, request):
        player_id = request.query_params.get('player_id')
        game_type = request.query_params.get('game_type')
        
        if not player_id or not game_type:
            return Response({'error': 'player_id and game_type are required'}, status=400)
        
        try:
            progress = GameProgress.objects.get(player_id=player_id, game_type=game_type)
            serializer = self.get_serializer(progress)
            return Response(serializer.data)
        except GameProgress.DoesNotExist:
            return Response({'error': 'Progress not found'}, status=404)

    @action(detail=False, methods=['post'])
    def save_progress(self, request):
        player_id = request.data.get('player_id')
        game_type = request.data.get('game_type')
        
        if not player_id or not game_type:
            return Response({'error': 'player_id and game_type are required'}, status=400)
        
        try:
            progress, created = GameProgress.objects.update_or_create(
                player_id=player_id,
                game_type=game_type,
                defaults={
                    'current_level': request.data.get('current_level', 1),
                    'score': request.data.get('score', 0),
                    'card_images': request.data.get('card_images', []),
                    'flipped_cards': request.data.get('flipped_cards', []),
                    'matched_cards': request.data.get('matched_cards', []),
                }
            )
            serializer = self.get_serializer(progress)
            return Response(serializer.data)
        except Exception as e:
            return Response({'error': str(e)}, status=400)
