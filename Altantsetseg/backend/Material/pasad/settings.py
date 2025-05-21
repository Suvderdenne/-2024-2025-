from pathlib import Path
from datetime import timedelta

# 📁 Base directory
BASE_DIR = Path(__file__).resolve().parent.parent

# 🚨 Secret Key
SECRET_KEY = 'django-insecure-CHANGE_THIS_FOR_PRODUCTION'

# ✅ Debug mode
DEBUG = True

# 🌐 Allowed Hosts
ALLOWED_HOSTS = [
    "127.0.0.1",
    "localhost",
    "10.0.2.2",  # Flutter Android emulator
]

# 🌍 CORS settings (for Flutter)
CORS_ALLOW_ALL_ORIGINS = True

# 📦 Installed Applications
INSTALLED_APPS = [
    # Django core apps
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # 🧱 Custom app
    'material',  # ← таны app-ийн нэр

    # Third-party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
]

# 🔁 Middleware
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # CORS эхэнд
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# 🧠 Templates (admin ажиллахад шаардлагатай)
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,  # ← маш чухал
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',  # ← admin-д хэрэгтэй
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

# 🌍 URLs
ROOT_URLCONF = 'pasad.urls'  # ← өөрийн төслийн нэр
WSGI_APPLICATION = 'pasad.wsgi.application'

# 🗃 Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# 👤 Custom User Model
AUTH_USER_MODEL = 'material.CustomUser'

# 🔐 REST Framework + JWT
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}

# JWT хугацаа тохиргоо (сонголт)
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
    'AUTH_HEADER_TYPES': ('Bearer',),
}

# 🔒 Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# 🌐 Localization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# 🖼 Static & Media
STATIC_URL = 'static/'
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# 🔢 Primary key
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
