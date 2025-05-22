from django.urls import path
from .views import RestaurantListCreateView, RestaurantDetailView, CommentListCreateView, RegisterView, LoginView, AddCommentView, UserStatsView, UserReviewsView

urlpatterns = [
    path('restaurants/', RestaurantListCreateView.as_view(), name='restaurant-list'),
    path('restaurants/<int:pk>/', RestaurantDetailView.as_view(), name='restaurant-detail'),
    path('restaurants/<int:restaurant_id>/comments/', CommentListCreateView.as_view(), name='comment-list-create'),
    path('restaurants/<int:restaurant_id>/comments/add/', AddCommentView.as_view(), name='add-comment'),
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('stats/', UserStatsView.as_view(), name='user-stats'),
    path('reviews/my/', UserReviewsView.as_view(), name='user-reviews'),
]
