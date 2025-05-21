from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import *
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

router = DefaultRouter()
router.register('plants', PlantInfoViewSet)
# router.register('myplants', UserPlantViewSet, basename='myplants')

urlpatterns = [
    path('', include(router.urls)),
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterView.as_view(), name='auth_register'),  # ← 👈 Бүртгэл энд нэмэгдлээ
    path('create_plant/', PlantInfoCreateView.as_view(), name='plant-create'),
    path('categories/', CategoryListView.as_view(), name='category-list'),
    path('category/<int:category_id>/', PlantsByCategoryAPIView.as_view(), name='plants-by-category'),
    path('user/add_plant/', UserAddPlantView.as_view(), name='user-add-plant'),
    path('user/my_plants/', UserPlantsListView.as_view(), name='user-my-plants'),
    path('assess-health/', PlantHealthAssessmentView.as_view(), name='plant-health-assessment'),
]
