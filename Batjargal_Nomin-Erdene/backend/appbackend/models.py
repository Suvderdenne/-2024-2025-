from django.db import models
from django.contrib.auth.models import User

class Book(models.Model):
    name = models.CharField(max_length=255)
    type = models.CharField(max_length=50)
    date = models.DateField()
    img_url = models.CharField(max_length=255, blank=True, null=True)
    alt_img_urls = models.TextField(blank=True, null=True)
    audio_url = models.CharField(max_length=255, blank=True, null=True)
    score = models.IntegerField(default=0)
    height = models.IntegerField(default=0)
    duration = models.FloatField(default=0.0)
    title = models.CharField(max_length=255)
    turul = models.CharField(max_length=255)
    review = models.TextField(blank=True)

    class Meta:
        db_table = "books"  # ← PostgreSQL-ийн table name

    def __str__(self):
        return self.title or "Нэргүй ном"



class Comment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    legend_id = models.IntegerField()
    rating_id = models.IntegerField(null=True, blank=True)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.user.username} → {self.content[:30]}'
