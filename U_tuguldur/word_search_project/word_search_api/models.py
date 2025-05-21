from django.db import models
from django.contrib.auth.models import User

class Level(models.Model):
    level_number = models.IntegerField(unique=True)
    grid_size = models.IntegerField()
    category = models.CharField(max_length=255)  # e.g., "Animals", "Fruits"

    def __str__(self):
        return f"Level {self.level_number} ({self.category})"

class Word(models.Model):
    level = models.ForeignKey(Level, related_name='words', on_delete=models.CASCADE)
    word = models.CharField(max_length=255)
    language = models.CharField(max_length=2, choices=[('EN', 'English'), ('MN', 'Mongolian')])

    def __str__(self):
        return f"{self.word} ({self.language}) - Level {self.level.level_number}"

class GridData(models.Model):
    level = models.OneToOneField(Level, related_name='grid_data', on_delete=models.CASCADE)
    data = models.JSONField()  # Store the grid letters as a JSON array

    def __str__(self):
        return f"Grid Data for Level {self.level.level_number}"

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    coins = models.IntegerField(default=0)
    completed_levels = models.ManyToManyField(Level, blank=True)
    english_words_guessed = models.IntegerField(default=0)
    mongolian_words_guessed = models.IntegerField(default=0)

    def __str__(self):
        return self.user.username