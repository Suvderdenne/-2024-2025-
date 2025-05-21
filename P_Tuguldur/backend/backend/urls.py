from django.urls import path
from api.views import *
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
urlpatterns = [
    path('admin/', admin.site.urls),  # Fixed this line
    path('lessons/', LessonListView.as_view(), name='lesson-list'),
    path('questions/<int:pk>/', LessonQuestionsView.as_view(), name='lesson-questions'),
    path('submit-test/', SubmitTestView.as_view(), name='submit-test'),
    path('user-stats/', UserScoreStatsView.as_view(), name='user-stats'),
    path('get-quiz/', GetQuizView.as_view(), name='get-quiz'),
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('categories/', CategoryListView.as_view(), name='category-list'),
    path('levels/', LevelListView.as_view(), name='level-list'),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('words/', WordListView.as_view()),
    path('words/<int:pk>/', WordDetailView.as_view(), name='word-detail'),
    path('my-words/', MyWordsView.as_view()),
    path('my-words/<int:word_id>/', MyWordsView.as_view()),  # <--- add <int:word_id>
    path('bookmark/', BookmarkWordView.as_view()),
    path('test-questions/', GetTestQuestionsView.as_view()),
    path('submit/', SubmitView.as_view()),
    path('news/', newsListView.as_view(), name='news-list'),
    path('api/profile/', UserProfileView.as_view(), name='user-profile'),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
