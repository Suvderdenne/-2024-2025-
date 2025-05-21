from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Level, Word, GridData, UserProfile
from rest_framework.exceptions import NotFound
from .serializers import LevelSerializer, GridDataSerializer, UserSerializer, UserProfileSerializer
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
from django.shortcuts import get_object_or_404

class LevelViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Level.objects.all()
    serializer_class = LevelSerializer
    permission_classes = [permissions.AllowAny]

    def retrieve(self, request, pk=None):
        try:
            level = get_object_or_404(self.queryset, pk=pk)
            language = request.query_params.get('language', 'EN')  # Default language

            try:
                grid_data = GridData.objects.get(level=level)
            except GridData.DoesNotExist:
                raise NotFound("Grid data not found for this level.")

            words = level.words.filter(language=language)
            serializer = LevelSerializer(level, context={'request': request, 'language': language})
            data = serializer.data
            data['grid'] = GridDataSerializer(grid_data).data['data']  # Access data correctly
            return Response(data)

        except Level.DoesNotExist:
            raise NotFound("Level not found.")
        except Exception as e:  # Catch *any* other error
            print(f"Server Error: {e}")  # Log the error (very important!)
            return Response({"error": "Internal server error"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.AllowAny]

    @action(detail=False, methods=['post'])
    def login(self, request):
        user = get_object_or_404(self.queryset, username=request.data['username'])
        if not user.check_password(request.data['password']):
            return Response({"detail": "Not Found."}, status=status.HTTP_404_NOT_FOUND)
        token, _ = Token.objects.get_or_create(user=user)
        user_profile, _ = UserProfile.objects.get_or_create(user=user)
        return Response({
            "token": token.key,
            "username": user.username,
            "coins": user_profile.coins
        })

    @action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
    def register(self, request):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token, _ = Token.objects.get_or_create(user=user)
            user_profile, _ = UserProfile.objects.get_or_create(user=user)
            return Response({
                "token": token.key,
                "username": user.username,
                "coins": user_profile.coins
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def complete_level(self, request):
        user = request.user
        user_profile = UserProfile.objects.get(user=user)
        level_number = request.data['level']
        level = get_object_or_404(Level, level_number=level_number)

        if level not in user_profile.completed_levels.all():
            user_profile.completed_levels.add(level)
            user_profile.coins += 50  # Award coins
            user_profile.save()

        return Response({
            "message": "Level completed successfully",
            "coins": user_profile.coins,
            "completed_levels": user_profile.completed_levels.count()
        })