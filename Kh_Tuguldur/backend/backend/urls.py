"""
URL configuration for backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from app1.views import (
    login,
    register,
    get_questions,
    get_courses,
    submit_responses,
    get_universities,
    get_university_details,
    get_career_insights,
    get_career_details,
    get_careers,
    get_job_listings,
    get_recommendation_history,
    get_news,
    get_news_details,
    get_profile,
    update_profile,
    delete_profile,
    posts,
    comment_on_post,
    toggle_like,
    get_post_comments,
    edit_post,
    reply_to_comment,
    edit_comment,
    delete_comment
)
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('login/', login, name='login'),
    path('register/', register, name='register'),
    path('questions/', get_questions, name='get_questions'),
    path('submit/', submit_responses, name='submit_responses'),
    # path('careers/<str:career>/', get_career_insights, name='career_insights'),
    path('career-details/<int:career>/', get_career_details, name='career_details'),
    path('careers/', get_careers, name='get_careers'),
    path('job-listings/<str:career>/', get_job_listings, name='job_listings'),
    path('recommendation-history/', get_recommendation_history, name='recommendation_history'),
    path('universities/', get_universities, name="university-list"),
    path('courses/', get_courses, name="course-list"),
    path('universities/<int:university_id>/', get_university_details, name="university-detail"),
    path('news/', get_news, name='get_news'),
    path('news/<int:news_id>/', get_news_details, name='get_news_details'),
    path('profile/', get_profile, name='get-profile'),
    path('profile/update/', update_profile, name='update_profile'),
    path('profile/delete/', delete_profile, name='delete_profile'),
    path('posts/', posts),
    path('posts/<int:post_id>/comments/', get_post_comments, name='get_post_comments'),
    path('posts/<int:post_id>/comment/', comment_on_post),
    path('posts/<int:post_id>/like/', toggle_like),
    path('posts/<int:post_id>/', posts, name='posts_detail'),  # Add post_id for DELETE
    path('posts/<int:post_id>/edit/', edit_post, name='edit_post'),
    path('comments/<int:comment_id>/edit/', edit_comment, name='reply_to_comment'),
    path('comments/<int:comment_id>/delete/', delete_comment, name='get_post_comments'),
    path('posts/<int:post_id>/comments/<int:comment_id>/reply/', reply_to_comment, name='reply_to_comment'),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

