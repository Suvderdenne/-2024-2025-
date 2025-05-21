from django.urls import path
from .views import *

urlpatterns = [
    path('register/', register_view, name='register'),
    path('login/', login_view, name='login'),
    path('logout/', logout_view, name='logout'),
    path('carpart_list/', carPart_list, name='carPart_list'),
    path('engine_parts_list/', engine_parts_list, name='engine_parts_list'),
    path('health-check/', health_check, name='health_check'),
    path('search/', search_car_parts, name='search_car_parts'),
    path('carparts/<int:part_id>/', car_part_detail, name='car_part_detail'),
    path('cart/', cart_view, name='cart'),
    path('cart/clear/', clear_cart_view, name='clear_cart'),
    path('cart/<int:item_id>/', cart_item_view, name='cart_item'),
    path('checkout/', checkout_view, name='checkout'),
    path('profile/', my_profile, name='my_profile'),
    path('profile/<int:user_id>/', profile_detail, name='profile_detail'),
    path('carparts/<int:car_part_id>/comments/', comment_list, name='comment_list'),
    path('comments/<int:comment_id>/', comment_detail, name='comment_detail'),
]
