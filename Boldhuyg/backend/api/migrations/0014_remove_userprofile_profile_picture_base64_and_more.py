# Generated by Django 5.1.6 on 2025-04-22 07:24

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0013_remove_userprofile_profile_picture_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='userprofile',
            name='profile_picture_base64',
        ),
        migrations.AddField(
            model_name='userprofile',
            name='profile_picture',
            field=models.ImageField(blank=True, null=True, upload_to='profile_pictures/'),
        ),
    ]
