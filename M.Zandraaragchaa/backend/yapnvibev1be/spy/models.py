from django.db import models

class AppUser(models.Model):
    user_id = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.user_id
    

class Player(models.Model):
    user = models.ForeignKey(AppUser, on_delete=models.CASCADE)  
    playername = models.CharField(max_length=100)
    def __str__(self):
        return self.playername

class Pack(models.Model):
    name = models.CharField(max_length=30, unique=True)
    user = models.ForeignKey(AppUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return f"{self.name}"
    
class PackItem(models.Model):
    itemname = models.CharField(max_length=50, unique=True)
    pack = models.ForeignKey(Pack, on_delete=models.CASCADE)
    def __str__(self):
        return f"{self.itemname}"
    
class Spy(models.Model):
    user = models.ForeignKey(AppUser, on_delete=models.CASCADE)  
    players = models.PositiveIntegerField()
    spies = models.PositiveIntegerField()
    timer = models.PositiveIntegerField()
    def __str__(self):
        return f"Game with {self.players} players, {self.spies} spies, User: {self.user}"
class SpyPack(models.Model):
    user = models.ForeignKey(AppUser, on_delete=models.CASCADE)
    pack = models.ForeignKey(Pack, on_delete=models.CASCADE)
    isown = models.BooleanField()
    def __str__(self):
        return f"SpyPack: {self.user} - {self.pack} - Own: {self.isown}"