"""
URL configuration for yapnvibev1be project.

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
from game.views import *
from spy.views import *

urlpatterns = [
    path('admin/', admin.site.urls),
    path('players/', playertype, name='players'),
    path('levels/', questionlevel, name='levels'),
    path('questions/', question, name='question'),
    path('dares/', dare, name='dare'),
    path('user/', user, name='user'),

    path('spies/<str:user_id>/', get_spy_data),
    path('spypack/<str:user_id>/', spypack),
    path('packs/<str:user_id>/', get_pack_data),
    path('packitems/<str:pack_id>/', get_packitem_data),

    path('spy/edit/<int:spy_id>/', edit_spy),
    path('spypack/edit/<str:user_id>/', edit_spypack),
    path('spypackitem/<str:user_id>/', sppc),
    
    path('pack/add/', add_pack),
    path('pack/edit/<int:pack_id>/', edit_pack),
    path('pack/delete/<int:pack_id>/', delete_pack),
    
    path('packitem/add/', add_pack_item),
    path('packitem/delete/<int:item_id>/', delete_pack_item),

    path('players/list/<str:user_id>/', playerlist),
    path('players/add/<str:user_id>/', add_player),
    path('players/edit/<int:player_id>/', edit_player),
    path('players/delete/<int:player_id>/', delete_player),
]
