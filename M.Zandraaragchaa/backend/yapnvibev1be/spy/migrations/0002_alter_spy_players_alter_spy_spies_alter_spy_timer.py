# Generated by Django 5.1.1 on 2025-04-24 00:40

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('spy', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='spy',
            name='players',
            field=models.PositiveIntegerField(default=10),
        ),
        migrations.AlterField(
            model_name='spy',
            name='spies',
            field=models.PositiveIntegerField(default=3),
        ),
        migrations.AlterField(
            model_name='spy',
            name='timer',
            field=models.PositiveIntegerField(default=3),
        ),
    ]
