# Generated by Django 5.1.1 on 2025-05-07 03:27

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('spy', '0011_appuser_created_at'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='appuser',
            name='device',
        ),
    ]
