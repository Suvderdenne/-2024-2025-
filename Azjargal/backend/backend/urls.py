from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path
from app import views

urlpatterns = [
    # Admin panel
    path('admin/', admin.site.urls),
    
    # User authentication views
    path('register/', views.register_view, name='register'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),

    # User profile views
    path('profile/', views.my_profile, name='my-profile'),
    path('profile/<int:user_id>/', views.profile_detail, name='profile-detail'),

    # Cart related views
    path('cart/', views.cart_view, name='cart'),  # Cart view (GET, POST)
    path('cart/item/<int:item_id>/', views.cart_item_view, name='cart_item'),  # Cart item view (PUT, DELETE)
    path('checkout/', views.checkout_view, name='checkout'),  # Checkout view (POST)
    path('cart/clear/', views.clear_cart_view, name='clear_cart'),
    # Car parts list (optional)
    path('carpart_list/', views.carPart_list, name='carPart_list'),
    path('search/', views.search_car_parts, name='search'),
    path('car-parts/<int:car_part_id>/comments/', views.comment_list, name='comment-list'),
    path('comments/<int:comment_id>/', views.comment_detail, name='comment-detail'),
    
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
