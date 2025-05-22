from django.contrib import admin
from .models import User, Team, Player, Game, PlayerStats, TeamStats, News, PlayerSeasonStats

admin.site.register(User)
admin.site.register(Team)
admin.site.register(Player)
admin.site.register(Game)
admin.site.register(PlayerStats)
admin.site.register(TeamStats)
admin.site.register(News)
admin.site.register(PlayerSeasonStats)