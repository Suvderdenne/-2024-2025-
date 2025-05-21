from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import (
    RegisterView,
    get_materials,
    add_material,
    OrderCreateView,  # Энэ мөрийг ганцхан удаа импортлоно
    MockQPayPaymentView,
)

urlpatterns = [
    path('api/register/', RegisterView.as_view(), name='register'),              # POST - бүртгүүлэх
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'), # POST - логин
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),# POST - refresh

    path('api/materials/', get_materials, name='get_materials'),                 # GET
    path('api/materials/add/', add_material, name='add_material'),              # POST (auth required)

    path('api/order/', OrderCreateView.as_view(), name='create_order'),         # POST - захиалга илгээх

    path('api/payment/qpay/', MockQPayPaymentView.as_view(), name='payment_qpay'),  # ✅ зөв
]
