# Generated by Django 5.1.1 on 2025-04-24 02:52

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('spy', '0003_player'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='pack',
            name='monname',
        ),
        migrations.RemoveField(
            model_name='packitem',
            name='itemmonname',
        ),
        migrations.AlterField(
            model_name='spy',
            name='players',
            field=models.PositiveIntegerField(),
        ),
        migrations.AlterField(
            model_name='spy',
            name='spies',
            field=models.PositiveIntegerField(),
        ),
        migrations.AlterField(
            model_name='spy',
            name='timer',
            field=models.PositiveIntegerField(),
        ),
    ]
