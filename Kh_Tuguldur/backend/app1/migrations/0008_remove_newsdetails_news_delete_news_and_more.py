# Generated by Django 5.1.5 on 2025-03-19 14:30

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('app1', '0007_news_newsdetails'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='newsdetails',
            name='news',
        ),
        migrations.DeleteModel(
            name='News',
        ),
        migrations.DeleteModel(
            name='NewsDetails',
        ),
    ]
