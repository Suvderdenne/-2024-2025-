# Generated by Django 5.1.3 on 2025-05-05 11:12

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('ubapp', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='driver',
            name='latitude',
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='driver',
            name='longitude',
            field=models.FloatField(blank=True, null=True),
        ),
    ]
