from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'clothes', views.ClothesViewSet)
router.register(r'categories', views.CategoryViewSet)
router.register(r'cart', views.CartViewSet, basename='cart')
router.register(r'orders', views.OrderViewSet, basename='order')
router.register(r'messages', views.MessageViewSet, basename='message')
router.register(r'ratings', views.SellerRatingViewSet, basename='rating')
router.register(r'users', views.UserProfileViewSet, basename='user')

urlpatterns = [
    path('', include(router.urls)),
    path('register/', views.register_user, name='register'),
    path('login/', views.login_user, name='login'),
    path('logout/', views.logout_user, name='logout'),
]