# Generated by Django 5.1.1 on 2025-05-07 04:01

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('spy', '0015_delete_spy'),
    ]

    operations = [
        migrations.CreateModel(
            name='Spy',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('players', models.PositiveIntegerField()),
                ('spies', models.PositiveIntegerField()),
                ('timer', models.PositiveIntegerField()),
                ('pack', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='spy.pack')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='spy.appuser')),
            ],
        ),
    ]
