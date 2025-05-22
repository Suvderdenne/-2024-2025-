from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework.authtoken.views import obtain_auth_token
from .views import (
    register_user, login_user, UserViewSet, TeamViewSet, TeamStatsViewSet,
    PlayerViewSet, GameViewSet, PlayerStatsViewSet, NewsViewSet, PlayerSeasonStatsViewSet
)

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'teams', TeamViewSet)
router.register(r'teamstats', TeamStatsViewSet)
router.register(r'players', PlayerViewSet)
router.register(r'games', GameViewSet)
router.register(r'playerstats', PlayerStatsViewSet)
router.register(r'news', NewsViewSet)
router.register(r'playerseasonstats', PlayerSeasonStatsViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('register/', register_user, name='register'),
    path('login/', login_user, name='login'),
    path('token/', obtain_auth_token, name='token'),
    # Add custom URL pattern for updating user by email
    path('users/update/', UserViewSet.as_view({'post': 'update', 'put': 'update'}), name='user-update'),
]
