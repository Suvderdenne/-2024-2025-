# Generated by Django 5.1.7 on 2025-04-11 02:31

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('restaurants', '0002_comment_rating_comment_user'),
    ]

    operations = [
        migrations.AddField(
            model_name='restaurant',
            name='has_delivery',
            field=models.BooleanField(default=False, help_text='Хүргэлттэй эсэх'),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='has_parking',
            field=models.BooleanField(default=False, help_text='Зогсоолтой эсэх'),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='has_wifi',
            field=models.BooleanField(default=False, help_text='WiFi-тай эсэх'),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='opening_hours',
            field=models.CharField(blank=True, help_text='e.g. 09:00-22:00, Да-Ня', max_length=255),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='phone',
            field=models.CharField(blank=True, help_text='Рестораны утасны дугаар', max_length=20),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='popular_dishes',
            field=models.TextField(blank=True, help_text='Алдартай хоолны цэс'),
        ),
        migrations.AddField(
            model_name='restaurant',
            name='website',
            field=models.URLField(blank=True, help_text='Рестораны вэбсайт'),
        ),
        migrations.CreateModel(
            name='RestaurantImage',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('image', models.ImageField(upload_to='restaurant_images/')),
                ('caption', models.CharField(blank=True, max_length=255)),
                ('restaurant', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='additional_images', to='restaurants.restaurant')),
            ],
        ),
    ]
