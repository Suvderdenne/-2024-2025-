# Generated by Django 5.1.7 on 2025-04-12 05:05

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('restaurants', '0003_restaurant_has_delivery_restaurant_has_parking_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='restaurant',
            name='location',
        ),
        migrations.AddField(
            model_name='restaurant',
            name='address1',
            field=models.CharField(default=1, help_text='Үндсэн хаяг (байршил)', max_length=255),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='restaurant',
            name='address2',
            field=models.CharField(blank=True, help_text='Нэмэлт хаяг (давхар хаяг)', max_length=255),
        ),
    ]
