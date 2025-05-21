# forms.py
from django import forms
from .models import User, UserProfile

# User Form
class UserForm(forms.ModelForm):
    class Meta:
        model = User
        fields = ['username', 'phone', 'email', 'is_active', 'is_staff']

# UserProfile Form
class UserProfileForm(forms.ModelForm):
    class Meta:
        model = UserProfile
        fields = ['full_name', 'profile_picture', 'address', 'bio']
