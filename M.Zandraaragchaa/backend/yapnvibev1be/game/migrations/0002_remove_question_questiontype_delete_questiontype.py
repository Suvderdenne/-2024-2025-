# Generated by Django 5.1.1 on 2025-02-24 17:09

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('game', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='question',
            name='questiontype',
        ),
        migrations.DeleteModel(
            name='Questiontype',
        ),
    ]
