from django.contrib import admin
from .models import Player, Game, GameProgress

# Register your models here.
admin.site.register(Player)
admin.site.register(Game)
admin.site.register(GameProgress)

