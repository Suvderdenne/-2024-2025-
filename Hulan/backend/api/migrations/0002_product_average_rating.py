# Generated by Django 5.1.1 on 2025-05-06 09:20

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='product',
            name='average_rating',
            field=models.FloatField(default=0.0),
        ),
    ]
