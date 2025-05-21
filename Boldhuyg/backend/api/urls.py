from django.urls import path
from .views import *
from . import views
from .views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('register/', views.register_user, name='register_user'),
    path('login/', views.login_user, name='login_user'),
    path('api/schools/', SchoolList.as_view(), name='school-list'),
    path('subjects/school/<int:school_id>/', SubjectListBySchoolView.as_view(), name='subject-list-by-school'),
    path('api/lesson-groups/subject/<int:id>/', LessonGroupBySubjectDetail.as_view(), name='lesson-group-by-subject-detail'),
    path('animals/by-subject/<int:subject_id>/', AnimalListBySubjectView.as_view(), name='animal-list-by-subject'),
    path('animal-types/', AnimalTypeListAPIView.as_view(), name='animal-type-list'),
    path('animal-types-with-animals/', AnimalTypeWithAnimalsAPIView.as_view(), name='animal-types-with-animals'),
    # Нэвтрэх (access, refresh)
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # Хэрэглэгчийн профайл авах болон шинэчлэх
    path('api/user/profile/<int:user_id>/', views.get_user_profile, name='user_profile'),
    path('api/user/<int:user_id>/upload-profile/', views.upload_profile_picture, name='upload_profile_picture'),
    path('api/user/update/<int:user_id>/', views.update_user_profile, name='update_user_profile'),
    path('lessons/<int:lesson_group_id>/', views.LessonListByGroupView.as_view(), name='lessons-by-group'),

    path('user-progress/', UserProgressListCreateAPIView.as_view(), name='user-progress-list-create'),
    path('activities/', views.get_activities, name='get_activities'),
    path('activities/<int:pk>/', ActivityDetailView.as_view(), name='activity-detail'),
    path('questions/', QuestionListByTypeAPIView.as_view(), name='question-list-by-type'),
    path('questions/<int:activity_id>/', QuestionDetailAPIView.as_view(), name='question-detail'),
    
    path('questions/<int:question_id>/answers/', AnswerListByQuestionAPIView.as_view(), name='answer-list-by-question'),
    path('answers/<int:pk>/', AnswerDetailAPIView.as_view(), name='answer-detail'),
    ]

