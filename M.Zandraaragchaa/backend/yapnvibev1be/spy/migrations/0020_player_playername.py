# Generated by Django 5.1.1 on 2025-05-07 08:45

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('spy', '0019_player'),
    ]

    operations = [
        migrations.AddField(
            model_name='player',
            name='playername',
            field=models.CharField(default=1, max_length=100),
            preserve_default=False,
        ),
    ]
