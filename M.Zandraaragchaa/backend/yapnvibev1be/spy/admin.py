from django.contrib import admin
from .models import *

admin.site.register(AppUser)
admin.site.register(Spy)
admin.site.register(Pack)
admin.site.register(PackItem)
admin.site.register(Player)
admin.site.register(SpyPack)