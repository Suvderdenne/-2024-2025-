# utils.py
from django.core.mail import send_mail
from django.conf import settings
import random
import string

# Рандом дугаар үүсгэх функц
def generate_random_code(length=6):
    """Генерейт дугаар үүсгэх"""
    characters = string.ascii_letters + string.digits
    return ''.join(random.choice(characters) for _ in range(length))

# Имэйл илгээх функц
def send_confirmation_email(user_email, confirmation_code):
    """Имэйл илгээх"""
    subject = 'Confirmation Email'
    message = f'Your confirmation code is {confirmation_code}'
    from_email = settings.DEFAULT_FROM_EMAIL
    recipient_list = [user_email]
    
    send_mail(subject, message, from_email, recipient_list)
