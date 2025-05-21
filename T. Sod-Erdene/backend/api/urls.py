# api/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_nested import routers
from .views import *

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'categories', FurnitureCategoryViewSet, basename='category')
router.register(r'furniture', FurnitureViewSet, basename='furniture')
router.register(r'orders', OrderViewSet, basename='order')
router.register(r'reviews', ReviewViewSet, basename='review')
router.register(r'notifications', NotificationViewSet, basename='notification')
router.register(r'cart', CartViewSet, basename='cart')

furniture_router = routers.NestedDefaultRouter(router, r'furniture', lookup='furniture')
furniture_router.register(r'reviews', ReviewViewSet, basename='furniture-reviews')

urlpatterns = [
    path('', include(router.urls)),
    path('', include(furniture_router.urls)),
    path('auth/', include('rest_framework.urls')),
    path('login/', LoginView.as_view(), name='api-login'),
    path('logout/', logout_view, name='api-logout'),
    path('register/', RegisterView.as_view(), name='api-register'),
    path('user/', UserProfileView.as_view(), name='api-user'),
    path('validate-token/', validate_token, name='validate-token'),
    path('users/me/', current_user, name='current-user'),
    path('users/change-password/', change_password, name='change-password'),
    path('users/update-profile/', update_profile, name='update-profile'),
    path('password/reset/', password_reset_request, name='password-reset'),
    path('furniture/liked/', LikedFurnitureList.as_view(), name='liked-furniture'),
    path('furniture/<int:furniture_id>/toggle-like/', ToggleLike.as_view(), name='toggle-like'),
    path('cart/add-item/', CartViewSet.as_view({'post': 'add_item'}), name='cart-add'),
    path('cart/remove/', CartViewSet.as_view({'post': 'remove_item'}), name='cart-remove'),
    path('cart/update-quantity/', CartViewSet.as_view({'post': 'update_quantity'}), name='cart-update-quantity'),
    path('cart/clear/', CartViewSet.as_view({'post': 'clear'}), name='cart-clear'),
]
