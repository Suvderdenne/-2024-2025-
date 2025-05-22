from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PlayerViewSet, GameViewSet, GameProgressViewSet

router = DefaultRouter()
router.register(r'players', PlayerViewSet)
router.register(r'games', GameViewSet)
router.register(r'game-progress', GameProgressViewSet, basename='game-progress')

urlpatterns = [
    path('', include(router.urls)),
] 